---
title: "Start Here — How to Use This Wiki"
summary: "The on-ramp: pick your reader track, do the first five controls in order, and place yourself on a crawl / walk / run maturity model before diving into the parts."
updated: 2026-07-17
---

# Start Here

This is a security engineer's playbook for defending **agentic AI** — coding assistants (Claude Code, Codex, Cursor), autonomous desktop and personal assistants, workflow platforms, and enterprise Work AI — across laptops, remote/cloud development environments, and the new tier of GPU-first and sandbox-native compute.

The guide is a set of cross-linked parts (see [`index.md`](index.md)). That is a lot to land on cold. This page exists so you don't read it front to back. Pick your track, do the first five controls, and find yourself on the maturity model.

If you take one idea from the whole guide, take this: **an agent that *acts* is an endpoint and identity problem, not a chat-gateway problem.** Your model-egress gateway never sees the local file read, the tool call, or the credential the agent was talked into exfiltrating ([Part 1](wiki/part-1-risk-surface-and-control-model.md)).

## Pick your track

**Security engineer / implementer — you stand up the controls.**
Read [Part 1](wiki/part-1-risk-surface-and-control-model.md) (risk model + the one attack path) → [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md) (managed settings, MCP governance, the real hook) → [Part 3](wiki/part-3-architecture-gateways-and-remote-defense.md) (MCP broker, remote environments). Then read whichever surface parts match your org: [6](wiki/part-6-extension-supply-chain.md) (extensions), [7](wiki/part-7-agentic-workflow-platforms.md) (workflow platforms), [10](wiki/part-10-agent-identity.md) (identity). Finish with [Part 9](wiki/part-9-detection-monitoring-ir.md) (detection and IR).

**Platform / DevEx — you own the rollout and the friction.**
Focus on delivery and blast-radius: [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md) (managed settings and how they reach laptops vs. cloud pods) → [Part 3](wiki/part-3-architecture-gateways-and-remote-defense.md) (remote/cloud dev environments, template-baked config) → [Part 4](wiki/part-4-beyond-the-hyperscalers.md) (GPU-first and sandbox-native compute) → [Part 6](wiki/part-6-extension-supply-chain.md) (an internal, pull-only extension registry). The controls only stick if developers can't quietly route around them, and if the guardrail failing open never bricks the developer — both are design themes in Part 2.

**CISO / security leadership — you prioritize, justify, and report.**
Read [Part 1](wiki/part-1-risk-surface-and-control-model.md) (the risk model and the single attack path you can explain to a board) and the *first five controls* below. Then skim [Part 8](wiki/part-8-work-ai-and-dspm.md) (Work AI faithfully mirrors your oversharing — the data-exposure story), [Part 10](wiki/part-10-agent-identity.md) (identities minted at machine speed, governed at human speed), and [Part 9](wiki/part-9-detection-monitoring-ir.md) (you cannot claim coverage without detection and a tested kill switch). The rest is reference for your engineers.

## The first five controls (do these in order)

Ranked, and each one already lives in the guide — nothing here is aspirational. If you do only these, you have broken the core attack path.

1. **Discover before you defend.** Inventory which agents are installed and which MCP tool servers they reach. You cannot govern what you cannot see, and shadow AI is the fastest-growing part of the surface. ([Part 1](wiki/part-1-risk-surface-and-control-model.md), discovery layer.)
2. **Push a managed baseline users cannot loosen.** Plan/ask by default, bypass and auto modes disabled, OS sandbox enforced, managed-hooks-and-rules-only. Deliver it so local settings cannot override it. ([Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md), managed settings.)
3. **Cut the agent list to a sanctioned few, block the rest.** A small explicit allowlist (often ~5) means fewer runtimes to harden and a far smaller shadow-AI tail — and remember blocking new installs does not remove what is already deployed. ([Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md), agent allowlisting.)
4. **Allowlist MCP servers and block credential paths.** Deny-by-default on tool servers, and block the agent from reading credential files and secret stores. This is the step that severs the read-credential-then-egress chain from Part 1. ([Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md), MCP governance and credential protection.)
5. **Stream agent actions to the SIEM and pre-build a kill switch.** Prevention fails eventually; you need to see the failure and stop it in minutes. Log the causal chain, not just the action. ([Part 9](wiki/part-9-detection-monitoring-ir.md).)

## Maturity model: crawl → walk → run

Place your program honestly. Most organizations are at crawl and think they are at walk.

**Crawl — get visibility.** Discovery inventory of agents and MCP servers; the managed baseline pushed to your top agents; an MCP allowlist; agent events flowing to the SIEM. You can now see the surface and have raised the floor.

**Walk — enforce at the endpoint.** Real-time enforcement gating high-impact actions (shell, filesystem edits) at prompt-submit / pre-tool / post-tool; credential-path blocking; the sanctioned-agent allowlist enforced with application control; extension supply-chain provenance and pinning ([Part 6](wiki/part-6-extension-supply-chain.md)); DSPM run *before* you connect a Work AI corpus ([Part 8](wiki/part-8-work-ai-and-dspm.md)). You now stop the common attack paths, not just watch them.

**Run — govern identity and autonomy.** Each agent has its own delegated identity with just-in-time, task-scoped access and no standing privilege ([Part 10](wiki/part-10-agent-identity.md)); agent behavioral detections, a tested fail-safe kill switch, and forensics ([Part 9](wiki/part-9-detection-monitoring-ir.md)); workflow platforms shipped as code with an AI security-review gate ([Part 7](wiki/part-7-agentic-workflow-platforms.md)); and, if you go there, a context-graph SOC governed by this same guide. Autonomy is now safe to widen.

## How this wiki is organized

- [`index.md`](index.md) — the catalog: every part, one line each, grouped into a reading arc (Foundations → deployment surfaces → operations and identity → the compute spectrum and its program → multi-agent), plus where each key concept is defined.
- `wiki/part-N-*.md` — the parts. Each is standalone and cross-linked, so the part number is a stable identifier, not a required reading order; sources are cited at the foot of every page.
- [`glossary.md`](glossary.md) — one place for the terms the parts use (discovery/enforcement, MCP broker, NHI, DSPM, delegation vs impersonation, and the rest).
- [`CLAUDE.md`](CLAUDE.md) — the schema and conventions, so a human or an LLM can extend the wiki without breaking it.
- [`log.md`](log.md) — append-only change history.

## Scope and freshness

This is a general, vendor-neutral playbook; nothing here is specific to any one organization. Vendor and product names are examples, not endorsements. The agent ecosystem moves fast — treat every specific setting as a pointer and **verify it against the vendor docs cited on each page** before you rely on it. Each page carries an `updated` date; the guide is a living document.
