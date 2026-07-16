# Log

Append-only. One entry per change, newest at the bottom.

## [2026-07-17] created | Initial LLM Wiki from the four-part guide

Imported the four-part "Practical Guide to Agentic AI Policies" as cross-referenced wiki pages under `wiki/`, and added `index.md` (catalog), `CLAUDE.md` (schema), and this log. Pages: Part 1 (risk surface and control model), Part 2 (endpoint hardening and policy playbook, including the GitHub Enterprise admin PreToolUse hook example and Claude Cowork controls), Part 3 (architecture, gateways, remote defense), Part 4 (GPU-first neoclouds and sandbox-native execution).

## [2026-07-17] add | Part 5 — Personal, Always-On AI Assistants (OpenClaw / NanoClaw class)

Added `wiki/part-5-personal-always-on-assistants.md` covering the personal always-on assistant class (OpenClaw, NanoClaw): autonomy at trigger time (heartbeat / no human prompt), messaging channels as both injection and exfil surface, consumer-virality shadow AI, the OpenClaw-vs-NanoClaw isolation/credential split, and the guard ecosystem (ClawGuard, ClawKeeper, openclaw-shield, NVIDIA NemoClaw) with a caution on judge-LLM gates. Updated `index.md` and `README.md`.

## [2026-07-17] add | Part 6 — The Agent Extension Supply Chain (Skills, Plugins, Commands, Hooks, Subagents)

Added `wiki/part-6-extension-supply-chain.md` treating the agent-extension layer (skills / plugins / commands / hooks / subagents) as a software supply chain: what each artifact is and why it is risky, evidence the marketplaces are already seeded with malicious skills (Snyk ToxicSkills and the ClawHavoc campaign), and a playbook (provenance + version pinning, administrator-managed hooks and permission rules, scanning instruction packs like code, inventorying the extension layer, least-privilege subagents, change control, and brokering bundled MCP servers). Updated `index.md` and `README.md`.
