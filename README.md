# Practical Guide to Agentic AI Policies

A security engineer's playbook for defending **agentic AI coding assistants** — Claude Code, Claude Cowork, Codex, Cursor and peers — across developer laptops, remote/cloud development environments, and the new tier of GPU-first and sandbox-native compute providers.

It is organized as an **LLM Wiki** (following [Andrej Karpathy's pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)): a compounding, cross-referenced set of markdown pages that both humans and LLMs can read, extend, and maintain. Start at [`index.md`](index.md); the structure and conventions are described in [`CLAUDE.md`](CLAUDE.md); change history is in [`log.md`](log.md).

## The guide

1. **[Part 1 — The Risk Surface and Control Model](wiki/part-1-risk-surface-and-control-model.md)** — why an agent that *acts* is a different security problem than a chat window, the risk model, and the discovery + enforcement two-layer defense.
2. **[Part 2 — Endpoint Hardening and Policy Playbook](wiki/part-2-endpoint-hardening-and-policy-playbook.md)** — tool-call and MCP controls, data-aware rules, managed-settings baselines for Claude Code / Codex / Cursor, a real PreToolUse hook that guards GitHub Enterprise admin, and Claude Cowork controls.
3. **[Part 3 — Architecture, Gateways, and Remote Defense](wiki/part-3-architecture-gateways-and-remote-defense.md)** — the MCP broker model, IP allowlisting vs device trust, and defending remote/cloud development environments.
4. **[Part 4 — Beyond the Hyperscalers](wiki/part-4-beyond-the-hyperscalers.md)** — re-onboarding mature cloud security controls onto GPU-first neoclouds and sandbox-native providers, and the self-hosted-sandbox model as the control lever.
5. **[Part 5 — Personal, Always-On AI Assistants](wiki/part-5-personal-always-on-assistants.md)** — securing the OpenClaw / NanoClaw class: autonomous, messaging-connected, self-scheduling assistants that act without a prompt and answer to anyone who can message them.
6. **[Part 6 — The Agent Extension Supply Chain](wiki/part-6-extension-supply-chain.md)** — governing the skills, plugins, commands, hooks, and subagents you load into an agent as a reviewed software supply chain, not a convenience.

## Who it's for

Security engineers, platform / developer-experience teams, and CISOs standing up guardrails for AI coding agents.

## Notes

- Vendor and product names are **examples, not endorsements**. Agent controls change quickly — verify against the vendor docs cited on each page before relying on a specific setting.
- This is a general playbook; nothing here is specific to any one organization.
- Living document. See [`log.md`](log.md) for history.
