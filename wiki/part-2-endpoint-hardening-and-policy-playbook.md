---
title: "Part 2 — Endpoint Hardening and Policy Playbook"
summary: "Tool-call and MCP controls, data-aware rules, managed-settings baselines for Claude Code / Codex / Cursor, a real PreToolUse hook that guards GitHub Enterprise admin, and Claude Cowork controls."
part: 2
updated: 2026-07-17
---

# Part 2 — Endpoint Hardening and Policy Playbook

Agentic AI coding assistants represent a fundamental shift in the developer security surface. Unlike traditional chat interfaces, these agents can execute commands, read and write to the filesystem, and interact with external tool servers. This part is a playbook for implementing robust endpoint policies and hardening configurations to mitigate risks like credential exposure and data exfiltration. It builds on the two-layer model in [Part 1](part-1-risk-surface-and-control-model.md).

## Core Policy Patterns for Active Enforcement

A mature posture requires an active enforcement layer that intercepts agent activity in real time, evaluating actions at three surfaces: prompt submission, pre-tool execution, and post-tool response.

### Tool-Call Control and MCP Governance

- **Gate high-impact actions** — high-impact tool categories, specifically shell/command execution and filesystem edits, should default to "ask" or "deny".
- **Explicit allow-listing for MCP** — inventory and explicitly allow-list every external MCP tool server; deny all others by default.
- **Granular permissioning** — allow read-only tools on a server while blocking execution capabilities.

### Data-Aware Rules and Credential Protection

- **Content inspection** — policies must inspect the content flowing through tool calls, not just the call itself.
- **Secret and PII blocking** — block secrets from being sent through tool servers and warn when personal or regulated data appears in database results.
- **Response monitoring** — inspecting tool *responses* is critical for catching sensitive data being pulled out of a system.
- **Path restriction** — block agent access to credential file paths and known credential-usage patterns to prevent long-lived secrets from being compromised.

### Agent Allowlisting (Keep a Short Sanctioned List, Block the Rest)

Left unmanaged, AI coding agents sprawl — discovery on a real fleet surfaces a long tail of agents, IDE extensions, and CLIs. Reduce that to a small, explicit allowlist of sanctioned agents (often the top ~5 your teams standardize on) and block or remove everything else. Fewer approved agents means fewer runtimes to harden and a far smaller shadow-AI surface. Enforce it with application control (gate new installs), pair it with removal of already-installed unsanctioned agents, and remember: blocking future installs does not remove what is already deployed — both steps are required for a real ban.

## Hardening the Agent Fleet: Enforced Managed Settings

Hardening is only effective if users cannot loosen the settings. Deliver them via MDM or admin-controlled configuration files that take precedence over local user settings.

### Claude Code Hardening Baseline

For Claude Code, the following JSON establishes a secure foundation that prioritizes human-in-the-loop validation and sandboxing:

```json
{
  "permissions": {
    "defaultMode": "plan",
    "disableBypassPermissionsMode": "disable"
  },
  "autoUpdatesChannel": "stable",
  "disableAutoMode": "disable",
  "skipAutoPermissionPrompt": false,
  "skipDangerousModePermissionPrompt": false,
  "skipWebFetchPreflight": false,
  "allowManagedHooksOnly": true,
  "allowManagedPermissionRulesOnly": true,
  "sandbox": {
    "enabled": true,
    "allowUnsandboxedCommands": false
  }
}
```

- **Human-in-the-loop** — `defaultMode: plan` makes the agent propose actions before execution.
- **Removing escape hatches** — `disableBypassPermissionsMode` and `disableAutoMode` prevent users from switching to unguarded execution; `allowManagedPermissionRulesOnly` stops user/project settings from defining their own allow/ask/deny rules; `allowManagedHooksOnly` loads only admin-approved hooks.
- **Sandboxing** — enforcing the OS sandbox (macOS Seatbelt / Linux Landlock+seccomp) ensures commands cannot opt out.
- **Keep prompts on** — the `skip*` settings stay `false` so the human confirmations (including the web-fetch preflight) are not skipped; `autoUpdatesChannel: stable` follows the delayed channel that skips regressions.

### Codex and Cursor Equivalents

The delivery mechanisms vary, but the same posture ports across agents:

- **Codex** — enforce with `requirements.toml`: `allowed_approval_policies`, `allowed_sandbox_modes` (excluding `danger-full-access`), and `allow_managed_hooks_only = true`, delivered via MDM (`com.openai.codex`).
- **Cursor** — enforce via the Team/org dashboard: Run Modes, the MCP allowlist, and sandbox network modes. There is no single pushed managed-settings file equivalent.

### Delivery and Infrastructure Considerations

- **Laptops** — MDM-delivered managed preferences (`com.anthropic.claudecode` on macOS; `HKLM\SOFTWARE\Policies\ClaudeCode` on Windows).
- **Cloud development environments** — MDM cannot reach a Linux pod, so bake the managed configuration (e.g. `managed-settings.json`) directly into the base workspace image (see [Part 3](part-3-architecture-gateways-and-remote-defense.md)).
- **Template-based security** — workspace templates must be root-owned and not user-writable so every rebuild stays compliant.

## Real-World Example: A PreToolUse Hook That Guards GitHub Enterprise Admin Actions

The enforcement model above is not theoretical. Here is a concrete implementation run in production: a PreToolUse hook that sits in front of the coding agent (built for Claude Code, mirrored for Cursor) and gates the exact actions that could reconfigure a GitHub Enterprise. It is a small shell script the agent invokes before every tool call.

The decision contract is the agent's native hook interface:

- `exit 2` → block the tool call; the reason is shown to the user.
- `exit 0` with `{"hookSpecificOutput":{"permissionDecision":"ask",...}}` → prompt the user to confirm before proceeding.
- `exit 0` with no output → allow, fast.

**What it blocks (hard stop):** destructive commands that should never run inside an agent session — `rm -rf` on `/` or `$HOME`, `dd if=`, `mkfs`, fork bombs, and force-pushes to `main` / `master` / `release` / `production`.

**What it asks on, specific to GitHub Enterprise admin:**

- `gh api` calls with `-X POST|PUT|PATCH|DELETE` against `/orgs/...`, `/enterprises/...` (rulesets, actions, audit-log, settings), or repo-level `actions` / `environments` / `rulesets` / `branches` / `hooks` / `secrets` / `variables` / `deployments`.
- `gh api graphql` mutations that change enterprise posture: `setEnterpriseAdministrator`, `setEnterpriseTwoFactorAuthenticatedUsersOnlyPolicy`, `setEnterpriseDefaultRepositoryPermission`, `updateRule` / `deleteRule`, `transferRepository`, `archiveRepository`, `removeCollaborator`, `grantMigratorRole`.
- MCP tools whose names match admin patterns: `github-admin`, `enterprise-(admin|owner|policy|ruleset)`, `ruleset-(create|update|delete)`, `app-install`, `oauth-app-(approve|policy)`, `pat-(approve|policy)`, `audit-log-stream`.
- Reads or writes to sensitive paths: `.github/workflows/`, `CODEOWNERS`, ruleset JSON and apply scripts, agent config (`.claude/`, `.cursor/`, `CLAUDE.md`), and credential material (`*.pem`, `*.key`, `~/.aws/`, `~/.ssh/`, `.env`).

Every decision is appended to a local guardrails log (timestamp, tool, decision, command), giving an audit trail of what the agent attempted.

**The honest part: what a local hook cannot catch.** A hook on the developer's endpoint is the *first* layer, not the durable one. It cannot see UI clicks made directly in the GitHub Enterprise admin console in a browser, subprocess commands fired inside a wrapper script after the wrapper itself was allowed, a second laptop or a teammate's session running without the hook, or direct `curl` / personal-access-token use outside the agent.

So the hook is layer 1 of a defense-in-depth design. The durable layers live on the server side: GitHub Enterprise rulesets that enforce the same posture regardless of who or what makes the change, tightened PAT and OAuth-app policy, and audit-log streaming into the SIEM with alerts on the sensitive mutations. The endpoint hook makes the agent safe-by-default and gives fast, in-context feedback; the server-side controls are what actually hold the line.

**Design notes worth copying:**

- **Fail open.** If the hook cannot parse its input or a dependency is missing, it allows and logs, so a broken guardrail never bricks the developer. Hard enforcement is the server-side layer's job.
- **Normalize before matching.** Collapse newlines and carriage returns in the command string before running your patterns, or a multi-line command slips past single-line rules.
- **Prefer ask over block for prod-affecting actions.** Blocking everything trains people to work around you; asking keeps the human in the loop. Reserve the hard block for the genuinely unrecoverable.

## Specific Controls for Claude Cowork (the Autonomous Desktop Agent)

Claude Cowork brings Claude Code's agentic engine into Claude Desktop for knowledge work. It can reach local files, browser sessions, plugins, MCP servers and connectors, scheduled tasks, and approved desktop apps. That autonomy is why it needs its own control set, separate from the CLI baseline above.

Start with the two execution paths, because their risk is not the same:

- **Sandboxed environment** — most of Claude's work runs in an isolated, temporary environment on Anthropic's servers, separate from the user's computer and unable to reach the local network.
- **Computer use** — has *no* sandbox between Claude and what is on the screen. It drives the actual desktop and browser directly. This is the high-risk path; restrict who can use it and on what data.

**Oversight modes (user-selectable, per task sensitivity):**

- **Manually approve** — recommended for sensitive tasks; the user confirms each action.
- **Automatically approve** — the default. Claude screens each action for safety and blocks what it judges unsafe, and untrusted content entering context is scanned for prompt injection.
- **Skip all approvals** — minimal oversight; avoid for anything sensitive.
- File deletion always requires an explicit **Allow** prompt regardless of mode.

**Admin and enterprise controls (Organization settings):**

- **Cowork toggle** — on by default; owners can disable it under Organization settings > Capabilities. All-or-nothing on Team; Enterprise can scope per group or custom role.
- **Connector tool approvals** — "Allow 'Always allow' for connector tools" is **off by default**, so members cannot skip per-task approval for write-capable tools. Keep it off.
- **Per-tool MCP connector restrictions** — lock each connector tool to Allow / Ask / Blocked via the `toolPolicy` key in `managedMcpServers`, and use a managed allowlist so only pre-approved MCP servers can connect (delivered through `managed-settings.json`).
- **Network egress controls** — restrict outbound access from the code-execution environment. Caveat: egress permissions do *not* apply to web fetch, web search, or MCPs — govern those separately.
- **Web search / Claude in Chrome** — can be disabled organization-wide.
- **Identity** — Enterprise adds SSO enforcement, SCIM provisioning, and group-based RBAC; Team plans lack per-team access control.
- **Plugins** — managed via the org plugin marketplace (Installed by default / Available / Required / Not available), overridable per group on Enterprise.

**Monitoring gaps to plan around:**

- Cowork activity is **not** captured in the Compliance API at this time. Stream Cowork events to your SIEM via OpenTelemetry instead.
- Cowork stores conversation history locally on users' machines, so it sits outside standard server-side data-retention policy — factor that into DLP and retention.

**Bottom-line posture for Cowork:** manual-approve (or at minimum default auto-approve, never skip-all) for sensitive data; keep "Always allow" for connectors off and lock them to an allowlist; treat computer use as the unsandboxed, highest-risk path; wire OpenTelemetry to the SIEM from day one.

## Sources

- https://support.claude.com/en/articles/13364135-use-claude-cowork-safely
- https://support.claude.com/en/articles/13455879-use-claude-cowork-on-team-and-enterprise-plans
