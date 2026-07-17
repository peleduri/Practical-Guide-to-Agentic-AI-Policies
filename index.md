# Index

The catalog of this wiki. Each page: one link, one-line summary. New here? Start with [`start-here.md`](start-here.md) for reader tracks and the first five controls. Term definitions live in [`glossary.md`](glossary.md). Copy-ready control files are in [`templates/`](templates/README.md).

## Guide

- [Part 1 — The Risk Surface and Control Model](wiki/part-1-risk-surface-and-control-model.md) — why agentic AI is a new security surface; the risk model; the discovery + enforcement two-layer model.
- [Part 2 — Endpoint Hardening and Policy Playbook](wiki/part-2-endpoint-hardening-and-policy-playbook.md) — tool-call and MCP controls, data-aware rules, managed-settings baselines for Claude Code / Codex / Cursor, a real PreToolUse hook example, and Claude Cowork controls.
- [Part 3 — Architecture, Gateways, and Remote Defense](wiki/part-3-architecture-gateways-and-remote-defense.md) — the MCP broker model, IP allowlisting vs device trust, and defending remote/cloud dev environments.
- [Part 4 — Beyond the Hyperscalers](wiki/part-4-beyond-the-hyperscalers.md) — re-onboarding cloud controls on GPU-first neoclouds and sandbox-native providers; the self-hosted-sandbox model.
- [Part 5 — Personal, Always-On AI Assistants (OpenClaw / NanoClaw class)](wiki/part-5-personal-always-on-assistants.md) — securing autonomous, messaging-connected, self-scheduling personal assistants; the risks the coding-agent parts miss.
- [Part 6 — The Agent Extension Supply Chain](wiki/part-6-extension-supply-chain.md) — governing skills, plugins, commands, hooks, and subagents as a software supply chain loaded into the agent.
- [Part 7 — Agentic Workflow Platforms (n8n, Gemini Enterprise)](wiki/part-7-agentic-workflow-platforms.md) — securing platforms where agentic workflows are wired into enterprise data; the SaaS-vs-self-hosted decision, the connector layer, and shipping workflows as code with an AI security-review gate.
- [Part 8 — Enterprise Work AI and the DSPM Prerequisite (Glean and peers)](wiki/part-8-work-ai-and-dspm.md) — why permission-aware Work AI is dangerous because it mirrors overshared permissions, and why DSPM (what sensitive data exists + who can reach it) is the non-optional companion.
- [Part 9 — Detection, Monitoring, and Incident Response for Agents](wiki/part-9-detection-monitoring-ir.md) — the operational other half: what to log (the causal chain), agent behavioral IOCs, a fail-safe kill switch, agent forensics, and the AI-native SOC.
- [Part 10 — Agent Identity and Non-Human Identity (NHI)](wiki/part-10-agent-identity.md) — the identity spine: delegation vs impersonation, ephemeral/just-in-time task-scoped access, intent-based access, and NHI lifecycle governance.
- [Part 11 — Local and Open-Source Models on the Endpoint (Cline, LM Studio, Ollama)](wiki/part-11-local-open-source-models.md) — why local inference feels private but is not safe: it bypasses the AI gateway, the model file executes code on load, the local server is an unauthenticated socket, and the agent still acts; the govern-don't-ban playbook.
- [Part 12 — Governance and Compliance](wiki/part-12-governance-compliance.md) — the CISO crosswalk: map the guide's controls to NIST AI RMF, ISO 42001, the EU AI Act, the OWASP LLM Top 10, and MITRE ATLAS, plus the program layer (intake/registry, owners, risk tiers, metrics).

## Key concepts (where they're defined)

One-line pointers to the part that defines each. For the definitions themselves, see [`glossary.md`](glossary.md).

- Discovery + enforcement (two-layer model) → Part 1
- Prompt / pre-tool / post-tool interception; allow / ask / deny → Part 1, Part 2
- Managed-settings baseline (Claude Code) → Part 2
- PreToolUse hook for GitHub Enterprise admin → Part 2
- Claude Cowork controls (two execution paths) → Part 2
- MCP broker / trusted gateway → Part 3
- IP allowlisting vs device trust → Part 3
- Remote / cloud workspace defense (template-baked config) → Part 3
- Self-hosted sandbox / environment worker → Part 4
- GPU-first neoclouds vs sandbox-native providers → Part 4
- Personal always-on assistants (OpenClaw / NanoClaw class) → Part 5
- Autonomy at trigger time (heartbeat / no human prompt) → Part 5
- Messaging-channel governance (injection + exfil surface) → Part 5
- Container isolation + credential vault (OpenClaw vs NanoClaw) → Part 5
- `before_tool_call` guard hooks + the judge-LLM caution → Part 5
- Extension supply chain (skills / plugins / commands / hooks / subagents) → Part 6
- Managed-only hooks + permission rules; marketplace provenance & pinning → Part 6
- Instruction packs as executable trust (SKILL.md scanning) → Part 6
- Internal skills registry / artifact repository (Artifactory-style, pull-only) → Part 6
- Agentic workflow platforms (n8n, Gemini Enterprise) → Part 7
- n8n Cloud vs Enterprise/self-hosted; the license-tier boundary → Part 7
- Connector-layer least privilege + exact identity mapping → Part 7
- Workflows as code (IaC/GitOps) + AI security-review gate before publish → Part 7
- External secret management + AI gateway for workflow LLM calls → Part 7
- Enterprise Work AI (Glean and peers) — permission-aware is not safe → Part 8
- Oversharing / access sprawl surfaced by natural language → Part 8
- DSPM as the prerequisite: what sensitive data exists + who can reach it → Part 8
- Agent audit trail: log the causal chain, not just the action → Part 9
- Behavioral IOCs + the fail-safe kill switch + agent forensics → Part 9
- AI-native / context-graph SOC; watching agents with an agent → Part 9
- Agent / non-human identity (NHI); delegation vs impersonation → Part 10
- Ephemeral / just-in-time task-scoped access; no standing privilege → Part 10
- Intent-based access (declared task = permission boundary); NHI lifecycle → Part 10
- Local inference bypasses the AI gateway (private ≠ safe) → Part 11
- Model-file supply chain (pickle/GGUF executes on load) → Part 11
- Autonomous agent + YOLO / auto-approve on a local model → Part 11
- Framework crosswalk (OWASP LLM Top 10, MITRE ATLAS, NIST AI RMF, ISO 42001, EU AI Act) → Part 12
- Program layer: AI/agent intake + registry, risk tiers, metrics → Part 12

## Sources

External vendor docs are cited at the foot of each page.
