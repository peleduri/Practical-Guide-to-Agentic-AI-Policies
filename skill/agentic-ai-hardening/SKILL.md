---
name: agentic-ai-hardening
description: >-
  Assess and harden an organization's agentic-AI coding setup against the Practical
  Guide to Securing AI Agents. Discovers installed agents and the MCP servers they
  reach, scores posture on a crawl / walk / run maturity model, reports the gaps, and
  (only with explicit confirmation) installs copy-ready controls. Use when asked to
  "secure my AI agents", "assess agentic AI posture", "harden Claude Code / Codex /
  Cursor", "run the agentic AI playbook", or "what's my AI agent security posture".
license: CC-BY-4.0
---

# Agentic-AI Hardening

You are running the **Practical Guide to Securing AI Agents** as an executable
assessment. Your job, in order: discover what agentic AI is installed, score the
org's security posture against the guide's controls, report the gaps, and — only
with explicit confirmation — install the matching controls. You are the guide,
runnable.

The guide is the source of truth. Its machine index is
`https://raw.githubusercontent.com/peleduri/Practical-Guide-to-Securing-AI-Agents/main/llms.txt`
— read it if you need a control's rationale. Never invent a control; fetch the
canonical, tested version from the URLs in the Control Catalog below.

## Guardrails — read before you touch anything

- **Assess is READ-ONLY.** Discovery and scoring only list files and read configs.
  They change nothing.
- **Harden is OPT-IN and previewed.** Never write a file without first showing its
  full content and destination and getting an explicit "yes" for *that specific
  control*. Never batch-apply. Never `git add -A`.
- **Fail safe.** If a check is ambiguous, report it as a **gap**, do not assume it is
  covered. Under-claiming coverage is correct; over-claiming is a security failure.
- **Never disable a gate to make something pass.** In particular, never set
  `--dangerously-skip-permissions` / a bypass mode, and never widen an allowlist "to
  be safe." Widen deliberately, per need.
- **This is a general playbook.** Adapt every control to the org (paths, allowlists,
  identities) and verify vendor-specific settings against current vendor docs before
  relying on them. Agent surfaces move fast.
- **Secrets are placeholders.** Never commit a real key, token, or ExternalId.
- **Install, don't commit.** When you write a control file, put it in place — do not
  `git add`, stage, or commit it, and never `git add -A`. Version control is the reader's
  call, not the skill's.

## Step 1 — Discover (read-only)

Run the **bundled** discovery inventory. It is read-only: it enumerates installed agent
CLIs / config dirs / editor extensions, the MCP servers each agent is wired to reach, any
listening local-inference ports, and the **agent extension supply chain** — installed
skills, custom commands, subagents, plugins, and hooks ([Part 6](https://raw.githubusercontent.com/peleduri/Practical-Guide-to-Securing-AI-Agents/main/wiki/part-6-extension-supply-chain.md)).
It emits one JSON object per finding.

- **Run the script that ships with this skill: `scripts/inventory-agents.sh`** (in this
  skill's own directory). It is bundled on purpose: a security skill must not fetch and
  execute a remote script at runtime, so the code you run is the code that was reviewed
  when the skill was installed. (It is a verbatim copy of the guide's
  `templates/discovery/inventory-agents.sh`, kept identical by the repo's lint.) Never
  replace it with a `curl … | sh` of a remote URL.
- **If you cannot run a shell** in this host, do the inventory read-only by reading the
  known config locations directly: `~/.claude/`, `~/.claude.json` (its `mcpServers` map),
  `~/.codex/`, `~/.cursor/` and `~/.cursor/mcp.json`, the VS Code / Cursor extensions dirs,
  and check for a listening local-model server (ports 11434, 1234).
- Collect the findings and summarize:
  - which agents are installed (flag any not on a sanctioned allowlist),
  - which MCP servers they reach (flag any pointed at a community / remote endpoint
    outside the org's infra),
  - local & open-source models on the endpoint (Part 11): runtimes installed, model
    weights on disk (they execute code on load), and any live inference socket,
  - the extension supply chain (Part 6): flag **USER** (non-managed) hooks, plugins or
    skills from unknown sources, and subagents with a broad tool scope — each is executable
    trust loaded into the agent, and an unlisted trigger is the one you least want to miss,
  - the **`baseline`** finding (Part 2): it reports the Claude Code managed hardening baseline
    as `MISSING` / `PARTIAL` / `PRESENT` with its flags and whether it is root-owned (enforced)
    or user-writable — this is the deterministic probe for control #2, use it directly.

Then read (read-only) the current config to judge the controls in Step 2: the managed
settings file if present (`managed-settings.json` for Claude Code, the Codex
equivalent), any registered hooks, and whether agent events reach a SIEM. Do not
modify these.

## Step 2 — Assess against the first five controls + the maturity model

For each control, decide **present / partial / missing** from what Step 1 found. These
are the guide's first five controls (the ones that break the core attack path), plus
the headless gate:

| # | Control | Present means | Guide |
|---|---------|---------------|-------|
| 1 | **Discovery** | agents + MCP servers are inventoried, fleet-wide, not just ad hoc | Part 1 |
| 2 | **Managed baseline users can't loosen** | plan/ask default, bypass + auto disabled, OS sandbox on, managed-hooks/rules-only, delivered root-owned | Part 2 |
| 3 | **Sanctioned-agent allowlist** | a small explicit set is allowed; the rest blocked/removed | Part 2 |
| 4 | **MCP allowlist + credential-path blocking** | deny-by-default on tool servers; agent blocked from reading credential files/stores | Part 2 |
| 5 | **Actions streamed to SIEM + a pre-built kill switch** | agent tool calls logged as the causal chain; a tested kill switch exists | Part 9 |
| + | **Headless permission gate** | any agent-driven / CI run resolves "ask" to a deny-by-default machine policy, never a bypass flag | Part 14 |

Score each control from a **concrete, deterministic probe — not a judgment call** — so
the same machine always yields the same score (a score that flaps is worthless, and a CI
gate that flaps gets disabled):

- **present** = the concrete artifact/config is in place *and enforced* (a root-owned
  `managed-settings.json` with bypass disabled; a registered *managed* hook; detections
  actually shipping to the SIEM).
- **partial** = present but not enforced or not rolled out fleet-wide (a settings file the
  user can override; a hook registered non-managed; discovery run once, not on a schedule).
- **missing** = absent.

Not every control is measurable from one machine. Tag each as **probe** or **attested** and
treat them differently:

- **Probe controls** (measured — check a concrete local signal, deterministically):
  - *Managed baseline* — `stat` the managed-settings file: it exists, is root-owned / not
    user-writable, and carries the flags (plan default, bypass + auto disabled, sandbox on,
    managed-only hooks/rules).
  - *MCP allowlist + credential-path block* — a deny-by-default MCP allowlist is configured,
    and the registered hook blocks credential paths (`.env`, `.aws`, `.ssh`, secret stores).
  - *Headless permission gate* — a deny-by-default headless gate is registered as the
    PreToolUse / PermissionRequest hook, and no `--dangerously-skip-permissions` / bypass is set.
- **Attested controls** (asked — no local signal; **ask the operator and default to `missing`
  until they confirm**; never assume present):
  - *Discovery inventory* — is there a fleet-wide, *scheduled* inventory feeding a registry /
    SIEM? (Running this skill's discovery once is `partial`, not `present`.)
  - *Sanctioned-agent allowlist* — is non-sanctioned-agent execution actually blocked
    (application control / MDM)?
  - *SIEM streaming + kill switch* — are agent events reaching the SIEM, and is a kill switch
    staged and tested?

Set `"attested": true` on each attested control in the posture JSON so the scorecard tags it
**self-reported** — a reader must be able to tell a measured status from one taken on trust.
Never present an attested answer as if it were a probe result.

Roll up to maturity by a fixed threshold: **run** = 0 missing and ≤1 partial; **walk** =
≤2 missing; **crawl** = otherwise. Rank the gaps by guide order (discovery → baseline →
allowlist → MCP+creds → SIEM/kill-switch → headless), which is also roughly blast-radius
order.

Then place the org on the maturity model (definitions:
`https://raw.githubusercontent.com/peleduri/Practical-Guide-to-Securing-AI-Agents/main/start-here.md`):

- **Crawl** — discovery done, a managed baseline on the top agents, an MCP allowlist,
  agent events reaching the SIEM. You can see the surface.
- **Walk** — real-time enforcement at the endpoint (pre-tool gating, credential-path
  blocking), the agent allowlist enforced, extension provenance/pinning, DSPM before
  any Work-AI corpus.
- **Run** — per-agent scoped identity with JIT/task-scoped access, agent behavioral
  detections + a tested kill switch + forensics, workflows shipped as code with an AI
  review gate.

Most orgs are at crawl and think they are at walk. Score honestly.

## Step 3 — Report

Produce a short posture report:

- **Maturity: crawl / walk / run** — with the one-line reason.
- **Per-control table** — present / partial / missing, from Step 2.
- **The single highest-value next control** — the earliest missing control in guide
  order (discovery → baseline → allowlist → MCP+creds → SIEM/kill-switch → headless).
- **Each gap → the control that fixes it** — name the control, its part, and its
  template (from the Catalog). This is the reader's ranked to-do list.

Then render a **shareable scorecard**. Write a `posture.json` with only the score, and
run the bundled generator:

    scripts/scorecard.sh posture.json > scorecard.html

`posture.json` schema (the generator ignores any other field on purpose):

    { "maturity": "crawl|walk|run",
      "controls": [ { "label": "Discovery inventory", "status": "present|partial|missing",
                      "attested": true }, ... ],   // set "attested": true on the 3 asked controls
      "next_control": "Push a managed baseline users can't loosen",
      "date": "YYYY-MM-DD" }

**Privacy is mandatory.** The `posture.json` and the card carry **posture only** — the
maturity level, the per-control status, and the next control. They must contain **none of
the discovery output**: no agent names, MCP server URLs, hostnames, file paths, or org
identifiers. Posture is safe to screenshot and post; the machine inventory that produced
it is not. `scorecard.sh` renders only the known posture fields, so inventory can't leak
through it — never add inventory fields to the JSON.

Stop here unless the reader asks to harden.

## Step 4 — Harden (opt-in, preview-then-write)

Ask which gaps to fix. For each control the reader chooses, in guide order:

1. **Fetch the canonical template** from its raw URL in the Catalog. Use the maintained
   version — do not hand-write a control.
2. **Adapt placeholders** to this environment (paths, tool/command allowlists, account
   IDs, thresholds). Leave every secret/ExternalId as a placeholder.
3. **Preview, and never blind-overwrite.** Show exactly what will be written and where. If
   a file already exists at the destination, **back it up first** (`.bak`), show a diff that
   makes clear **what the template would remove or change**, and prefer to **merge** the
   template's additions into their file rather than replace it — a reader's existing
   managed-settings, hook, or detection may carry rules you must not silently drop.
4. **Get an explicit "yes" for that control**, then write it. One control at a time.
5. **State the manual step that remains** — the part the skill cannot do: deliver
   `managed-settings.json` via MDM as a root-owned file; register the hook as a managed
   `PreToolUse` hook; wire the kill switch's `cut_egress()` to your EDR; compile the
   Sigma detections to your SIEM and tune thresholds; map identity JSON onto your IdP.
6. **Re-check** that control moved to present, and update the report.

Never apply a control the reader did not choose. Never skip the preview.

## Control Catalog (canonical, tested templates)

Base: `https://raw.githubusercontent.com/peleduri/Practical-Guide-to-Securing-AI-Agents/main/templates/`

| Control | Maturity | Guide | Template path (under base) |
|---------|----------|-------|-----------------------------|
| Discovery inventory | crawl | Part 1 | `discovery/inventory-agents.sh` |
| Managed-settings baseline (Claude Code) | crawl | Part 2 | `claude-code/managed-settings.json` |
| Codex baseline | crawl | Part 2 | `codex/requirements.toml` |
| Cursor hardening notes | crawl | Part 2 | `cursor/README.md` |
| PreToolUse enforcement hook | walk | Part 2 | `hooks/pretooluse-guard.sh` |
| Headless permission gate (deny-by-default, fails closed) | walk / run | Part 14 | `headless/permission-gate.sh` |
| Agent behavioral detections (Sigma + Splunk) | crawl → walk | Part 9 | `detections/` |
| JIT / task-scoped identity grant | run | Part 10 | `identity/jit-scoped-grant.json` |
| Cross-account role trust (specific principal + ExternalId) | run | Part 10 | `identity/cross-account-role-trust.json` |
| Credential broker pattern | run | Part 10 | `identity/credential-broker.md` |
| Fail-safe kill switch | walk | Part 9 | `incident/agent-kill-switch.sh` |
| Workflow pre-publish review gate | run | Part 7 | `workflows/ai-security-review-gate.md` |

Read `templates/README.md` at the base for each file's contract and honest limits
before installing it.

## What this does NOT do (honest limits)

- **It does not deploy org infrastructure.** It writes a control file; *you* deliver it
  the durable way (MDM-pushed root-owned config, a registered managed hook, a compiled
  SIEM detection). The skill says which manual step remains for each control.
- **It is endpoint- and machine-scoped.** It cannot see agents on other machines, in
  the cloud, or inside SaaS low-code builders. Run it per machine and pair it with
  network-egress detection so an agent it could not enumerate still shows up by its
  traffic.
- **It is a hardening assistant, not a compliance attestation.** Mapping controls to
  frameworks (OWASP, NIST, ISO 42001, EU AI Act) is the guide's Part 12, not this skill.

## Sources

- The guide: https://github.com/peleduri/Practical-Guide-to-Securing-AI-Agents
- Machine index: https://raw.githubusercontent.com/peleduri/Practical-Guide-to-Securing-AI-Agents/main/llms.txt
