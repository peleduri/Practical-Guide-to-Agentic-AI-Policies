---
title: "Glossary"
summary: "One-line definitions of the terms used across the ten parts, each pointing to the part where it is defined in full."
updated: 2026-07-17
---

# Glossary

Terms the guide leans on, defined once. The link points to the part where the term is developed in full. New to the wiki? Read [`start-here.md`](start-here.md) first.

## A

- **Agent allowlisting** — reducing the sprawl of installed AI agents to a small, explicit set of sanctioned ones and blocking or removing the rest; fewer runtimes to harden, smaller shadow-AI surface. → [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
- **Agentic AI coding assistant** — an AI tool that does not just answer but *acts* on the developer's machine: runs commands, reads and writes files, makes network calls, and drives external tools. Its ability to act is its primary risk. → [Part 1](wiki/part-1-risk-surface-and-control-model.md)
- **Agentic workflow platform** — a platform (e.g. n8n, Gemini Enterprise) that wires agentic automations into enterprise data and systems via triggers, connectors, and sometimes arbitrary code. → [Part 7](wiki/part-7-agentic-workflow-platforms.md)
- **Agent forensics** — preserving the full context of an agent incident — prompts, tool I/O, guardrail decisions, retrieval bundles, memory and sandbox snapshots — tamper-evidently, because action logs alone cannot reconstruct what happened. → [Part 9](wiki/part-9-detection-monitoring-ir.md)
- **AI / agent registry (intake)** — a governed inventory (the discovery of Part 1 turned into a system of record) of every agent, workflow, Work-AI connection, and model, each with an owner, purpose, risk tier, and decommission date; what you govern and audit against. → [Part 12](wiki/part-12-governance-compliance.md)
- **AI gateway (model-egress gateway)** — the proxy that governs prompts leaving the org for an LLM. Necessary but not sufficient: it sees the prompt, not the agent's local actions. Route workflow and agent model calls through it. → [Part 1](wiki/part-1-risk-surface-and-control-model.md), [Part 7](wiki/part-7-agentic-workflow-platforms.md)
- **AI-native / context-graph SOC** — a detection-and-response approach that investigates each alert against a living graph of the environment (architecture, identities, past cases) instead of static rules; itself an agent subject to this guide. → [Part 9](wiki/part-9-detection-monitoring-ir.md)
- **Allow / Ask / Deny** — the three outcomes of an enforcement decision: permit silently, prompt the human to confirm, or block outright. → [Part 1](wiki/part-1-risk-surface-and-control-model.md), [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
- **Autonomy at trigger time** — an assistant that acts on a heartbeat or inbound event with no human prompt in the loop, so anyone who can reach its trigger can set it acting. → [Part 5](wiki/part-5-personal-always-on-assistants.md)

## B

- **Behavioral IOC** — an indicator of compromise expressed as agent behavior rather than a file signature: a credential read followed by egress, an unusual tool sequence, a token/cost spike, a key used from a new context. → [Part 9](wiki/part-9-detection-monitoring-ir.md)

## C

- **Causal chain (agent audit trail)** — logging each agent action as a decision with its full context: identity, triggering input, policy evaluated, decision, tool and arguments, response, and the reasoning the agent had — not just the bare action. → [Part 9](wiki/part-9-detection-monitoring-ir.md)
- **Claude Cowork / computer use** — the autonomous desktop agent; "computer use" is its unsandboxed path that drives the actual screen and browser, the highest-risk mode. → [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
- **Connector** — an integration that grants a workflow or Work AI platform access to a data source or system; over-reaching connectors are a primary risk, so map each to an exact, least-privilege identity. → [Part 7](wiki/part-7-agentic-workflow-platforms.md), [Part 8](wiki/part-8-work-ai-and-dspm.md)
- **Credential boundary / broker** — a gateway that holds downstream provider secrets and exposes only metadata, scoped actions, and results to the agent, so the agent authenticates to the broker and never holds the raw credential; a compromised agent can't exfiltrate a secret it never received. → [Part 10](wiki/part-10-agent-identity.md)

## D

- **Delegation vs impersonation** — the foundational identity choice: an agent acting under its *own* identity on behalf of a user via a scoped grant (delegation, preferred, revocable per-agent) versus silently wearing the user's identity (impersonation, no independent accountability). → [Part 10](wiki/part-10-agent-identity.md)
- **Discovery (passive)** — Layer 1 of the defense: a lightweight scan of agent configuration to inventory installed agents and their tool servers, redacting secret values. You cannot govern what you cannot see. → [Part 1](wiki/part-1-risk-surface-and-control-model.md)
- **DSPM (Data Security Posture Management)** — discovering and classifying sensitive data and mapping who can access it; the non-optional prerequisite before connecting a corpus to a Work AI platform. → [Part 8](wiki/part-8-work-ai-and-dspm.md)

## E

- **Enforcement (active)** — Layer 2 of the defense: intercepting agent activity in real time at prompt-submit, pre-tool, and post-tool surfaces and applying allow/ask/deny. → [Part 1](wiki/part-1-risk-surface-and-control-model.md), [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
- **Ephemeral / just-in-time / task-scoped access** — credentials granted at request time, scoped to the exact task, expiring on their own, with no standing privilege left behind between tasks. → [Part 10](wiki/part-10-agent-identity.md)
- **Extension supply chain** — the skills, plugins, commands, hooks, and subagents loaded into an agent, treated as reviewed software (provenance, pinning, scanning) rather than convenient add-ons. → [Part 6](wiki/part-6-extension-supply-chain.md)

## F

- **Framework crosswalk** — mapping the guide's technical controls to the frameworks a program is evidenced and reported in: OWASP LLM Top 10 and MITRE ATLAS (threats), NIST AI RMF and ISO/IEC 42001 (program), and the EU AI Act (law). Build the controls once, report them many ways. → [Part 12](wiki/part-12-governance-compliance.md)

## G

- **GPU-first neocloud vs sandbox-native** — two non-hyperscaler compute tiers: raw-GPU providers where you re-onboard cloud security controls, versus providers that offer isolated execution sandboxes as the primitive. → [Part 4](wiki/part-4-beyond-the-hyperscalers.md)

## I

- **Instruction pack** — an extension whose content is executable trust: natural-language instructions (e.g. a SKILL.md) that steer the agent and must be scanned and reviewed like code. → [Part 6](wiki/part-6-extension-supply-chain.md)
- **Intent-based access (IBAC)** — the agent declares what it intends to do, access is granted for exactly that, and its actual calls are checked against the declaration; the declared task becomes the permission boundary. → [Part 10](wiki/part-10-agent-identity.md)
- **Internal skills registry / artifact repository** — a curated, pull-only internal store (Artifactory-style) for approved agent extensions, so teams install from a vetted source rather than the open marketplace. → [Part 6](wiki/part-6-extension-supply-chain.md)
- **IP allowlisting vs device trust** — restricting access by source network versus by managed/attested device. Network location is not device posture; allowlisting narrows but does not prove trust. → [Part 3](wiki/part-3-architecture-gateways-and-remote-defense.md)

## K

- **Kill switch (fail-safe)** — a pre-built, tested containment lever (per-agent and per-fleet) that halts the agent, revokes its credentials, and cuts egress — designed to fail *safe* (graceful completion, state snapshot), not to cause more damage than the incident. → [Part 9](wiki/part-9-detection-monitoring-ir.md)

## L

- **Local inference (on-device model)** — running an open-weights model on the developer's own machine via a runtime like Ollama or LM Studio, so the model call never crosses the network. Feels private; bypasses the AI gateway and all its logging, screening, and allowlisting. → [Part 11](wiki/part-11-local-open-source-models.md)

## M

- **Managed settings baseline** — a hardened configuration delivered by admins (MDM or root-owned config) that users cannot loosen: plan/ask default, bypass and auto modes disabled, sandbox enforced, managed-hooks-and-rules-only. → [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
- **MCP (Model Context Protocol)** — the protocol agents use to reach external tool servers (databases, tickets, chat). Powerful and un-vetted by default, so it needs allowlisting and brokering. → [Part 1](wiki/part-1-risk-surface-and-control-model.md)
- **MCP broker / trusted gateway** — a central, governed chokepoint through which all MCP tool access is routed, allow-listed, and logged, instead of each agent connecting to servers directly. → [Part 3](wiki/part-3-architecture-gateways-and-remote-defense.md)
- **Model-file supply chain** — treating downloaded model weights as executable artifacts: pickle-format models run code on load (RCE), even "safe" formats like GGUF have carried payloads in metadata, and the loading runtime itself has had RCE CVEs. Allowlist sources, prefer safetensors, scan, and pin. → [Part 11](wiki/part-11-local-open-source-models.md)

## N

- **Non-human identity (NHI)** — the population of machine/agent identities. Growing fast, mostly ungoverned by joiner/mover/leaver lifecycle, and now the dominant standing-privilege attack surface. → [Part 10](wiki/part-10-agent-identity.md)

## O

- **Oversharing / access sprawl** — the accumulated over-broad permissions (anyone-with-link, stale ACLs, bloated all-company groups) that a permission-aware Work AI platform faithfully surfaces via natural-language query. → [Part 8](wiki/part-8-work-ai-and-dspm.md)

## P

- **Personal always-on assistant** — an autonomous, messaging-connected, self-scheduling assistant (the OpenClaw / NanoClaw class) that acts without a prompt and answers to anyone who can message it. → [Part 5](wiki/part-5-personal-always-on-assistants.md)
- **PreToolUse hook** — a script the agent invokes before every tool call that returns allow / ask / block; the concrete endpoint enforcement primitive (Part 2 ships a real, de-identified one that guards GitHub Enterprise admin). → [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
- **Prompt-submit / pre-tool / post-tool interception** — the three enforcement surfaces: reviewing the instruction before the LLM sees it, checking a tool call before it runs, and inspecting a tool response before the agent consumes it. → [Part 1](wiki/part-1-risk-surface-and-control-model.md), [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)

## R

- **Remote / cloud development environment** — a hosted dev workspace (cloud IDE, dev pod) that must be hardened like a developer endpoint, with the managed config baked into a root-owned base image since MDM cannot reach it. → [Part 3](wiki/part-3-architecture-gateways-and-remote-defense.md)

## S

- **Sandbox (OS-level)** — enforcing an operating-system sandbox (macOS Seatbelt, Linux Landlock + seccomp) so agent commands cannot opt out of the confinement. → [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
- **Self-hosted sandbox / environment worker** — running the agent's execution environment on infrastructure you control, which becomes the lever for applying your own security controls to agent compute. → [Part 4](wiki/part-4-beyond-the-hyperscalers.md)
- **Shadow AI** — unsanctioned agents, tool servers, and AI chatbots proliferating faster than security can inventory them; the reason discovery comes first. → [Part 1](wiki/part-1-risk-surface-and-control-model.md)

## T

- **Two-layer model (discovery + enforcement)** — the spine of the guide: passive discovery to map the surface, plus active real-time enforcement to gate high-impact actions. → [Part 1](wiki/part-1-risk-surface-and-control-model.md)

## W

- **Work AI platform** — an enterprise assistant (e.g. Glean) connected to org data. Permission-aware by design, which is exactly the risk: it mirrors overshared permissions into a natural-language interface. → [Part 8](wiki/part-8-work-ai-and-dspm.md)
- **Workflows as code (GitOps + AI security-review gate)** — treating automations as version-controlled code that passes an AI-powered security review before it is published and connected to critical systems, rather than clicked together in a console. → [Part 7](wiki/part-7-agentic-workflow-platforms.md)

## Y

- **YOLO mode / auto-approve** — an agent setting that removes the human-in-the-loop by auto-approving actions; full "YOLO" disables every safety check (file deletion, system changes, and network calls included). Paired with a local model it produces a fully ungoverned autonomous loop. → [Part 11](wiki/part-11-local-open-source-models.md), [Part 2](wiki/part-2-endpoint-hardening-and-policy-playbook.md)
