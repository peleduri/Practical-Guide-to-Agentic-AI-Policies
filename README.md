# Practical Guide to Agentic AI Policies

[![lint](https://github.com/peleduri/Practical-Guide-to-Agentic-AI-Policies/actions/workflows/lint.yml/badge.svg)](https://github.com/peleduri/Practical-Guide-to-Agentic-AI-Policies/actions/workflows/lint.yml) [![docs: CC BY 4.0](https://img.shields.io/badge/docs-CC%20BY%204.0-blue.svg)](LICENSE) [![code: MIT](https://img.shields.io/badge/code-MIT-green.svg)](LICENSE-CODE)

**Defend AI coding agents — Claude Code, Cowork, Codex, Cursor — and the wider agentic stack across laptops, remote workspaces, and GPU/sandbox clouds.** Cross-referenced parts, from the risk model through endpoint hardening, detection, agent identity, and governance. For security engineers, platform / developer-experience teams, and CISOs. → **New here? [Start here](start-here.md).**

A security engineer's playbook for defending **agentic AI coding assistants** — Claude Code, Claude Cowork, Codex, Cursor and peers — across developer laptops, remote/cloud development environments, and the new tier of GPU-first and sandbox-native compute providers.

It is organized as an **LLM Wiki** (following [Andrej Karpathy's pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)): a compounding, cross-referenced set of markdown pages that both humans and LLMs can read, extend, and maintain. **New readers should start at [`start-here.md`](start-here.md)** — it carries reader tracks (security engineer / platform-DevEx / CISO), the first five controls in order, and a crawl/walk/run maturity model. The full catalog is [`index.md`](index.md); term definitions are in [`glossary.md`](glossary.md); the structure and conventions are described in [`CLAUDE.md`](CLAUDE.md); change history is in [`log.md`](log.md).

## Use this guide

- **Browse it as a site.** The wiki is published with GitHub Pages at **https://peleduri.github.io/Practical-Guide-to-Agentic-AI-Policies/** (also in the About panel).
- **Point your agent at it.** This is an LLM Wiki, meant to be pulled by an agent as a policy source. Machine index: [`llms.txt`](llms.txt). Every page is plain Markdown at a stable raw URL, e.g. `https://raw.githubusercontent.com/peleduri/Practical-Guide-to-Agentic-AI-Policies/main/wiki/part-2-endpoint-hardening-and-policy-playbook.md`.
- **Lift the controls.** Copy-ready configs, a working PreToolUse hook, Sigma+SPL detections, and identity/workflow examples live in [`templates/`](templates/) — adapt and test before deploying.

## The guide

1. **[Part 1 — The Risk Surface and Control Model](wiki/part-1-risk-surface-and-control-model.md)** — why an agent that *acts* is a different security problem than a chat window, the risk model, and the discovery + enforcement two-layer defense.
2. **[Part 2 — Endpoint Hardening and Policy Playbook](wiki/part-2-endpoint-hardening-and-policy-playbook.md)** — tool-call and MCP controls, data-aware rules, managed-settings baselines for Claude Code / Codex / Cursor, a real PreToolUse hook that guards GitHub Enterprise admin, and Claude Cowork controls.
3. **[Part 3 — Architecture, Gateways, and Remote Defense](wiki/part-3-architecture-gateways-and-remote-defense.md)** — the MCP broker model, IP allowlisting vs device trust, and defending remote/cloud development environments.
4. **[Part 4 — Beyond the Hyperscalers](wiki/part-4-beyond-the-hyperscalers.md)** — re-onboarding mature cloud security controls onto GPU-first neoclouds and sandbox-native providers, and the self-hosted-sandbox model as the control lever.
5. **[Part 5 — Personal, Always-On AI Assistants](wiki/part-5-personal-always-on-assistants.md)** — securing the OpenClaw / NanoClaw class: autonomous, messaging-connected, self-scheduling assistants that act without a prompt and answer to anyone who can message them.
6. **[Part 6 — The Agent Extension Supply Chain](wiki/part-6-extension-supply-chain.md)** — governing the skills, plugins, commands, hooks, and subagents you load into an agent as a reviewed software supply chain, not a convenience.
7. **[Part 7 — Agentic Workflow Platforms (n8n, Gemini Enterprise)](wiki/part-7-agentic-workflow-platforms.md)** — securing the automation and agent platforms wired into enterprise data: the SaaS-vs-self-hosted (and license-tier) decision, arbitrary-code and connector risk, the credential concentration, and shipping workflows as code (GitOps + AI security-review gate) with external secrets and the AI gateway for model calls (with concrete AI-gateway examples — LiteLLM, Kong AI Gateway).
8. **[Part 8 — Enterprise Work AI and the DSPM Prerequisite (Glean and peers)](wiki/part-8-work-ai-and-dspm.md)** — why a permission-aware Work AI platform is dangerous precisely because it faithfully mirrors overshared permissions, and why DSPM is the non-optional companion for knowing what sensitive data exists and who can reach it.
9. **[Part 9 — Detection, Monitoring, and Incident Response for Agents](wiki/part-9-detection-monitoring-ir.md)** — the operational other half of the guide: log the causal chain (not just the action), detect on agent behavioral IOCs, pre-build a fail-safe kill switch, do agent forensics, and use an AI-native SOC (governed by this same guide).
10. **[Part 10 — Agent Identity and Non-Human Identity (NHI)](wiki/part-10-agent-identity.md)** — the identity spine the guide leaned on: give each agent its own identity and delegate (don't impersonate), make access ephemeral / just-in-time / task-scoped with no standing privilege, validate intent against action, and govern the NHI lifecycle.
11. **[Part 11 — Local and Open-Source Models on the Endpoint (Cline, LM Studio, Ollama)](wiki/part-11-local-open-source-models.md)** — running open-weights models locally feels private and is therefore treated as safe; it is neither. It bypasses the AI gateway, the model file executes code on load, the local server is an unauthenticated socket, and the agent still acts — plus the govern-don't-ban playbook.
12. **[Part 12 — Governance and Compliance](wiki/part-12-governance-compliance.md)** — the CISO crosswalk: map the guide's controls to NIST AI RMF, ISO 42001, the EU AI Act, the OWASP LLM Top 10, and MITRE ATLAS, and add the program layer (AI/agent intake + registry, named owners, risk tiers, and the handful of metrics a CISO reports).
13. **[Part 13 — The Managed Cloud AI Stack (AgentCore, Bedrock, SageMaker)](wiki/part-13-managed-cloud-ai-stack.md)** — the inverse of Part 11: managed feels safe but isn't done. A hyperscaler's agent stack is SOC-compliant and productizes this guide's own architecture (managed broker, credential vault, sandbox, audit plane), which is exactly what makes teams stop at "the platform handles security." The shared-responsibility line across the agent runtime, the model, and the model-building layer.
14. **[Part 14 — Multi-Agent and Agent-to-Agent (A2A) Systems](wiki/part-14-multi-agent-a2a.md)** — the guide's controls re-applied at every edge of an agent mesh. Prompt injection that self-replicates and gets laundered into a more trusted form as it hops, low-privilege agents driving high-privilege peers as confused deputies, fleet-level blast radius, and the orchestration framework itself (LangChain/LangGraph) as attack surface. Secure the graph, not just the nodes.

## Who it's for

Security engineers, platform / developer-experience teams, and CISOs standing up guardrails for AI coding agents.

## Notes

- Vendor and product names are **examples, not endorsements**. Agent controls change quickly — verify against the vendor docs cited on each page before relying on a specific setting.
- This is a general playbook; nothing here is specific to any one organization.
- Every action-oriented part ends with a **security engineer's playbook** — a scannable "what to do" checklist. Governance (Part 12) also carries an engineer-facing "operationalize the governance" checklist alongside the CISO material.
- Living document. See [`log.md`](log.md) for history.

## Roadmap

Planned, not yet written — issues and contributions welcome:

- **A DevEx rollout part** — staged pilot, break-glass / exceptions, and the guardrail-vs-velocity tradeoff.
- **Site search** — a docs theme with full-text search across all parts.

## License

- **Documentation** (all prose and diagrams): [Creative Commons Attribution 4.0 International](LICENSE) (CC BY 4.0) — share and adapt freely, with credit.
- **Code** (`scripts/`, `.github/`, and the config / hook snippets): [MIT](LICENSE-CODE).

## Author

By Uri Peled — [LinkedIn](https://www.linkedin.com/in/uri-peled/). Feedback, corrections, and contributions welcome via issues and pull requests.
