---
title: "Part 6 — The Agent Extension Supply Chain (Skills, Plugins, Commands, Hooks, Subagents)"
summary: "Governing the config and instruction packages you load into an agent — skills, plugins, commands, hooks, subagents — as a software supply chain."
part: 6
updated: 2026-07-17
---

# Part 6 — The Agent Extension Supply Chain

Parts 1-5 governed what an agent may do and where it runs. This part is about what you pour *into* it. Modern agents are extended by small config packages that reshape their behavior, and each one is executable trust: instructions the model will obey, or scripts that fire on your machine, authored by someone who is not you. Left ungoverned, the extension layer is a fresh software supply chain living inside the agent — and the marketplaces that feed it are already seeded with hostile entries.

## The Five Things You Load (and why each is a risk)

- **On-demand instruction packs** (Claude Code / Codex "skills"; a coding agent's rules file fills the same slot). The agent pulls one in mid-task to pick up a workflow. Because the pack *is* instructions the model follows, a poisoned one is prompt injection with a shelf life: it can tell the agent to read an `.env` or SSH key and fold it into a commit, or to quietly add a chosen dependency.
- **Bundles** ("plugins"). One installable package that ships instruction packs, slash commands, lifecycle triggers, and tool-server connectors together, usually from a marketplace. This is the main entry point, because a single install drags in every other category at once from a third party.
- **Saved invocations** ("commands"). A stored slash command a person fires deliberately. It looks user-initiated, which is exactly why hidden steps or arguments buried inside it are easy to miss.
- **Lifecycle triggers** ("hooks"). A rule that runs a shell command when the agent hits an event — a prompt is submitted, a tool is about to run. This is the sharpest one: it executes *outside* the model's reasoning and the approval prompts, so a trigger fired on prompt-submit can rewrite the permissions file and silently switch off the human-in-the-loop everything else depends on.
- **Delegated helpers** ("subagents"). A scoped agent the primary one spawns for a sub-task. It inherits tools and privilege, its own guiding prompt can be tampered with, and its activity is harder to watch than the main thread's.

## Why This Is a Supply Chain, Not a Convenience

The moment an agent can fetch a bundle, load an instruction pack, run a trigger, attach a tool server, and remember a permission choice, that extension layer belongs to your software supply chain — and it earns the same scrutiny as a package install, a CI action, or a browser extension. The evidence that it is already under attack is not hypothetical:

- A February 2026 audit of roughly 3,984 skills on a third-party marketplace found about 13% carried a critical issue, roughly 37% had some vulnerability, many contained confirmed malicious payloads, about 11% leaked secrets, and about 18% pulled untrusted third-party content at runtime.
- A separate study of around 2,857 skills surfaced 341 malicious entries tied to coordinated campaigns.
- Prompt injection topped the 2026 AI threat lists, and an instruction pack is a clean delivery vehicle for it.

The failure mode is plain: a pack or bundle is content the agent trusts by default, so a malicious one turns your own agent into the attacker — reading credentials and committing them, injecting a backdoored dependency, or running an install step that plants persistence.

## The Playbook

- **Govern provenance; pin versions.** Load bundles and packs only from known, trusted sources. Block unknown marketplaces, reject arbitrary plugin URLs and side-load flags, and pin to a reviewed version rather than "latest." (In Claude Code: `strictKnownMarketplaces`, `blockedMarketplaces`, `disableSideloadFlags`.)
- **Curate an internal registry; pull only from it.** The durable answer to marketplace risk is the one you already use for packages: stand up a governed internal registry for agent extensions (an artifact repository such as Artifactory) and make it the *only* source your agents may pull from, with public marketplaces blocked. Treat each skill as a first-class software asset — immutable, tagged versions (so "which skill is in production" is never ambiguous and rollback is one step); pre-publish scanning for prompt injection, secret reads, and dangerous init steps; a dev-to-staging-to-production promotion gate so an unvetted skill never reaches a production agent; and a searchable catalog carrying ownership, dependencies, provenance/signing, and a trust score. This is the *positive* control (a vetted source to pull from); it pairs with the *negative* controls in this list (administrator-managed triggers, blocked marketplaces, no side-loading), because a registry governs what you distribute — it does not by itself stop a trigger from executing or a user from side-loading a URL.
- **Force administrator-managed triggers and rules.** Let only admin-approved lifecycle triggers load and only admin-defined permission rules apply, so a user- or bundle-supplied trigger cannot rewrite policy. Allowlist any HTTP endpoint a trigger may call, and switch triggers off entirely where they are not needed. (In Claude Code: `allowManagedHooksOnly`, `allowManagedPermissionRulesOnly`, `allowedHttpHookUrls`, `disableAllHooks`.)
- **Review instruction packs like code.** Treat every pack as executable trust. Before it is allowed, scan for the tells the marketplace audits key on: reads of credential files, additions of specific packages, init/shell steps, and runtime fetches of outside content. Static-scan on the way in, not after something breaks.
- **Inventory the extension layer.** Discovery (see [Part 1](part-1-risk-surface-and-control-model.md)) must enumerate the installed packs, bundles, commands, triggers, and delegated helpers — not just the agent binary. This is where the risk hides, and an unlisted trigger is the thing you least want to miss.
- **Least privilege for delegated helpers.** Scope a subagent's tools to its task; do not let it inherit the full tool set of the primary agent.
- **Put the extension layer under change control.** Adding or updating any of these is a reviewed change, the same as a dependency bump — pull request, approval, audit trail. The enforcement analog already exists: the endpoint hook in [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) treats `.claude/`, `.cursor/`, `CLAUDE.md`, trigger directories, and ruleset files as sensitive paths and gates writes to them.
- **Route bundled tool servers through the broker.** A bundle often ships its own tool-server connectors; send them through the trusted gateway from [Part 3](part-3-architecture-gateways-and-remote-defense.md) instead of letting the bundle wire them in directly.

## Bottom Line

The extension layer is code and instructions you did not write, running inside your agent with your privileges. Govern where it comes from, pin what you load, force triggers and permission rules to be administrator-managed, scan instruction packs the way you scan packages, and inventory everything that is loaded — because the marketplaces are already shipping malicious entries, and a single trusted-by-default pack is enough to turn the agent against you.

## Sources

- https://pluto.security/blog/claude-extension-ecosystem-security-practitioner-guide/
- https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/
- https://www.sentinelone.com/blog/marketplace-skills-and-dependency-hijack-in-claude-code/
- https://www.promptarmor.com/resources/hijacking-claude-code-via-injected-marketplace-plugins
- https://www.agensi.io/learn/are-ai-agent-skills-safe-security-risks

---

Nav: **[← Index](../index.md)** · **[Glossary](../glossary.md)** · Next → **[Part 7 — Agentic Workflow Platforms](part-7-agentic-workflow-platforms.md)**
