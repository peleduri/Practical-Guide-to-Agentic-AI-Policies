# Practical Guide to Securing AI Agents

[![lint](https://github.com/peleduri/Practical-Guide-to-Securing-AI-Agents/actions/workflows/lint.yml/badge.svg)](https://github.com/peleduri/Practical-Guide-to-Securing-AI-Agents/actions/workflows/lint.yml) [![docs: CC BY 4.0](https://img.shields.io/badge/docs-CC%20BY%204.0-blue.svg)](LICENSE) [![code: MIT](https://img.shields.io/badge/code-MIT-green.svg)](LICENSE-CODE)

**Defend AI coding agents — Claude Code, Cowork, Codex, Cursor — and the wider agentic stack across laptops, remote workspaces, and GPU/sandbox clouds.** Cross-referenced parts, from the risk model through endpoint hardening, detection, agent identity, and governance. For security engineers, platform / developer-experience teams, and CISOs. → **New here? [Start here](start-here.md).**

It is organized as an **LLM Wiki** (following [Andrej Karpathy's pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)): a compounding, cross-referenced set of Markdown pages that both humans and LLMs can read, extend, and maintain.

The full catalog is [`index.md`](index.md); term definitions are in [`glossary.md`](glossary.md); the structure and conventions are in [`CLAUDE.md`](CLAUDE.md); change history is in [`log.md`](log.md).

## Run it — get your posture scorecard

You don't have to read all 14 parts to start. Point your coding agent at this guide and **run the assessment**: it discovers the AI agents and MCP servers on a machine, scores your posture on a **crawl / walk / run** maturity model, and writes a shareable scorecard. Assess is **read-only**; hardening is opt-in and previewed before anything is written.

**[→ See an example scorecard](https://peleduri.github.io/Practical-Guide-to-Securing-AI-Agents/examples/scorecard.html)** — synthetic data, but it's exactly what you get back.

Two ways to run, both read-only:

- **As an Agent Skill** (Claude Code / Codex CLI / Cursor) — the portable [`agentic-ai-hardening` skill](skill/README.md) runs the whole loop: discover → assess → report → (opt-in) harden.
- **Just the discovery scan** — clone and run one bundled script:

  ```bash
  git clone https://github.com/peleduri/Practical-Guide-to-Securing-AI-Agents
  bash Practical-Guide-to-Securing-AI-Agents/templates/discovery/inventory-agents.sh
  # read-only; emits JSON Lines you can roll up to your SIEM
  ```

**Share your result.** The scorecard prints a copy-ready maturity badge for your own README — e.g. ![agent security: walk](https://img.shields.io/badge/agent%20security-walk-yellow) — so your posture links back here.

The 14-part guide below is the **why** behind every control the assessment checks.

## What this is — and what it isn't

Security frameworks and risk catalogs — OWASP's Agentic and LLM Top 10s, NIST AI RMF, ISO 42001, the EU AI Act, and agent-specific frameworks like Pillar's SAIL — tell you **what** to worry about: the risks, the taxonomy, which standard each one maps to. They are the map, and you should use them.

This guide is the **implementation companion** — the part that ships the control. Where a catalog row says *"discover shadow agents,"* *"enforce action-level authorization,"* or *"pre-build a kill switch,"* this hands you the working files:

- a read-only [discovery scan](templates/discovery/inventory-agents.sh) for installed agents and the MCP servers they reach;
- [managed-settings baselines](templates/claude-code/managed-settings.json) users can't loosen (Claude Code, Codex, Cursor) and a working [`PreToolUse` enforcement hook](templates/hooks/pretooluse-guard.sh);
- agent behavioral-IOC [detections as Sigma + Splunk](templates/detections/);
- [just-in-time, task-scoped identity grants](templates/identity/) and a credential-broker pattern;
- a fail-safe [agent kill switch](templates/incident/agent-kill-switch.sh) and a [pre-publish review gate](templates/workflows/ai-security-review-gate.md) for agentic workflows.

Use it **alongside** those frameworks, not instead of them: they catalog the risk, this closes it. The [five first controls](start-here.md) each ship a copy-ready artifact in [`templates/`](templates/); every part explains the *why* in prose and links the *how*. And the whole loop runs as a [skill](skill/README.md) — point your coding agent at it and it assesses your posture and, with your confirmation, installs the controls. A catalog can't do that.

## Use this guide

- **Browse it as a site.** The wiki is published with GitHub Pages at **https://peleduri.github.io/Practical-Guide-to-Securing-AI-Agents/** (also in the About panel).
- **Point your agent at it.** This is an LLM Wiki, meant to be pulled by an agent as a policy source. Machine index: [`llms.txt`](llms.txt). Every page is plain Markdown at a stable raw URL, e.g. `https://raw.githubusercontent.com/peleduri/Practical-Guide-to-Securing-AI-Agents/main/wiki/part-2-endpoint-hardening-and-policy-playbook.md`.
- **Lift the controls.** Copy-ready configs, a working PreToolUse hook, Sigma+SPL detections, and identity/workflow examples live in [`templates/`](templates/) — adapt and test before deploying.
- **Run it as a skill.** The guide is packaged as a portable [Agent Skill](skill/README.md) (`SKILL.md`, the standard Claude Code / Codex CLI / Cursor all read). Point your coding agent at it and it discovers your installed agents, scores your posture on the maturity model, and — with your confirmation — installs the matching controls.

## The guide

The parts are grouped below into a reading arc. Part numbers are stable identifiers, not a strict reading order — each part is standalone and cross-linked, and [`start-here.md`](start-here.md) offers reader tracks that cut a shorter path.

**Foundations — the model, the endpoint, the architecture.**

- **[Part 1 — The Risk Surface and Control Model](wiki/part-1-risk-surface-and-control-model.md)** — why an agent that *acts* is a different security problem than a chat window, the risk model, and the discovery + enforcement two-layer defense.
- **[Part 2 — Endpoint Hardening and Policy Playbook](wiki/part-2-endpoint-hardening-and-policy-playbook.md)** — tool-call and MCP controls, data-aware rules, managed-settings baselines for Claude Code / Codex / Cursor, a real PreToolUse hook that guards GitHub Enterprise admin, and Claude Cowork controls.
- **[Part 3 — Architecture, Gateways, and Remote Defense](wiki/part-3-architecture-gateways-and-remote-defense.md)** — the MCP broker model, IP allowlisting vs device trust, and defending remote/cloud development environments.

**Deployment surfaces — where else agents run and act.**

- **[Part 4 — Beyond the Hyperscalers](wiki/part-4-beyond-the-hyperscalers.md)** — re-onboarding mature cloud security controls onto GPU-first neoclouds and sandbox-native providers, and the self-hosted-sandbox model as the control lever.
- **[Part 5 — Personal, Always-On AI Assistants](wiki/part-5-personal-always-on-assistants.md)** — securing the OpenClaw / NanoClaw class: autonomous, messaging-connected, self-scheduling assistants that act without a prompt and answer to anyone who can message them.
- **[Part 6 — The Agent Extension Supply Chain](wiki/part-6-extension-supply-chain.md)** — governing the skills, plugins, commands, hooks, and subagents you load into an agent as a reviewed software supply chain, not a convenience.
- **[Part 7 — Agentic Workflow Platforms (n8n, Gemini Enterprise)](wiki/part-7-agentic-workflow-platforms.md)** — securing the automation and agent platforms wired into enterprise data: the SaaS-vs-self-hosted (and license-tier) decision, arbitrary-code and connector risk, trigger-point governance (a Jira comment or Slack message is an indirect-injection path even when the webhook is authenticated), the credential concentration, and shipping workflows as code (GitOps + AI security-review gate) with external secrets and the AI gateway for model calls (with concrete AI-gateway examples — LiteLLM, Kong AI Gateway).
- **[Part 8 — Enterprise Work AI and the DSPM Prerequisite (Glean and peers)](wiki/part-8-work-ai-and-dspm.md)** — why a permission-aware Work AI platform is dangerous precisely because it faithfully mirrors overshared permissions, and why DSPM is the non-optional companion for knowing what sensitive data exists and who can reach it.

**Operations and identity — the cross-cutting spine.**

- **[Part 9 — Detection, Monitoring, and Incident Response for Agents](wiki/part-9-detection-monitoring-ir.md)** — the operational other half of the guide: log the causal chain (not just the action), detect on agent behavioral IOCs, pre-build a fail-safe kill switch, do agent forensics, and use an AI-native SOC (governed by this same guide).
- **[Part 10 — Agent Identity and Non-Human Identity (NHI)](wiki/part-10-agent-identity.md)** — the identity spine the guide leaned on: give each agent its own identity and delegate (don't impersonate), make access ephemeral / just-in-time / task-scoped with no standing privilege, validate intent against action, and govern the NHI lifecycle.

**The compute spectrum and the program over it.** Local-on-the-endpoint (Part 11) and managed-cloud (Part 13) are the two ends of where agents compute; governance (Part 12) is the throughline that has to hold across both.

- **[Part 11 — Local and Open-Source Models on the Endpoint (Cline, LM Studio, Ollama)](wiki/part-11-local-open-source-models.md)** — running open-weights models locally feels private and is therefore treated as safe; it is neither. It bypasses the AI gateway, the model file executes code on load, the local server is an unauthenticated socket, and the agent still acts — plus the govern-don't-ban playbook.
- **[Part 12 — Governance and Compliance](wiki/part-12-governance-compliance.md)** — the CISO crosswalk: map the guide's controls to NIST AI RMF, ISO 42001, the EU AI Act, the OWASP LLM Top 10, and MITRE ATLAS, and add the program layer (AI/agent intake + registry, named owners, risk tiers, and the handful of metrics a CISO reports).
- **[Part 13 — The Managed Cloud AI Stack (AgentCore, Bedrock, SageMaker)](wiki/part-13-managed-cloud-ai-stack.md)** — the inverse of Part 11: managed feels safe but isn't done. A hyperscaler's agent stack is SOC-compliant and productizes this guide's own architecture (managed broker, credential vault, sandbox, audit plane), which is exactly what makes teams stop at "the platform handles security." The shared-responsibility line across the agent runtime, the model, and the model-building layer.

**Advanced — many agents, not one.**

- **[Part 14 — Multi-Agent and Agent-to-Agent (A2A) Systems](wiki/part-14-multi-agent-a2a.md)** — the guide's controls re-applied at every edge of an agent mesh. Prompt injection that self-replicates and gets laundered into a more trusted form as it hops, low-privilege agents driving high-privilege peers as confused deputies, fleet-level blast radius, and the orchestration framework itself (LangChain/LangGraph) as attack surface. Secure the graph, not just the nodes.

## Who it's for

Security engineers, platform / developer-experience teams, and CISOs standing up guardrails for AI coding agents.

## Notes

- Vendor and product names are **examples, not endorsements**. Agent controls change quickly — verify against the vendor docs cited on each page before relying on a specific setting.
- This is a general playbook; nothing here is specific to any one organization.
- Every action-oriented part ends with a **security engineer's playbook** — a scannable "what to do" checklist. Governance (Part 12) also carries an engineer-facing "operationalize the governance" checklist alongside the CISO material.
- The shell templates in [`templates/`](templates/) and the repo scripts are **`shellcheck`-clean** (warning level and above) — you are copying controls into your fleet, so they hold to the bar you would hold your own security tooling to. Still, read and adapt each one before deploying.
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
