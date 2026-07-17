---
title: "Part 4 — Beyond the Hyperscalers: Securing GPU and Sandbox-Native Execution"
summary: "Re-onboarding mature cloud security controls onto GPU-first neoclouds and sandbox-native providers, and the self-hosted-sandbox model as the control lever."
part: 4
updated: 2026-07-17
---

# Part 4 — Beyond the Hyperscalers: Securing GPU and Sandbox-Native Execution

Agentic workloads are increasingly outgrowing the standard compute offerings of major hyperscalers. To maintain performance, these agents require specialized infrastructure: high-density GPU capacity for inference, and sandbox-native environments for ephemeral, per-session execution of untrusted code. This has given rise to a new tier of specialized providers that split into two camps carrying different data:

- **GPU-first neoclouds** (e.g. Nebius, Crusoe, CoreWeave, Lambda) — sell raw accelerator capacity for model inference, fine-tuning, and heavy compute. The data at risk is your prompts, context, and any fine-tuning corpus.
- **Sandbox-native platforms** (e.g. E2B, Modal, Daytona, Blaxel, Namespace, Vercel Sandbox, Cloudflare, Superserve, plus hyperscaler-native offerings like AWS Lambda MicroVMs and GKE Agent Sandbox) — provide ephemeral microVMs to run agent-generated code. The data at risk is your source, filesystem, and the credentials the tools touch.

The security consequence is stark: moving compute to these younger platforms requires a total re-onboarding of the cloud security controls that are mature on AWS, GCP, and Azure. Organizations are trading hardened control planes for emerging ones, and onboarding a fresh set of risks with them.

## Legacy Control Erosion: What You Leave Behind

On a hyperscaler you inherit, largely for free, a tuned control stack that must now be accounted for on GPU and sandbox providers:

- **Identity and access** — IAM roles, short-lived STS credentials, and organization-wide guardrails / SCPs.
- **Audit and compliance** — centralized, tamper-resistant trails (CloudTrail / Cloud Audit Logs / Azure Activity Log) streamed to the SIEM.
- **Network perimeter** — private subnets, VPC security groups, and NAT egress allowlists.
- **Data protection** — integrated secret managers and KMS-managed encryption at rest.
- **Threat detection** — native CSPM and threat detection (GuardDuty / Security Command Center / Defender).

Move agent execution to a GPU or sandbox-native provider and each of these stops being a given and becomes a question you have to answer.

## The New Risk Surface: Control-Domain Analysis

Audit the following domains when evaluating sandbox and GPU neoclouds:

- **Tenancy and isolation** — determine whether sessions use Firecracker-class microVMs with hardware-backed isolation or shared containers. For GPU providers, verify VRAM is scrubbed between tenants. Ephemeral per-session teardown is a real win only if the isolation underneath is real.
- **Credential hygiene** — avoid passing long-lived cloud keys to third-party sandboxes; demand narrowly scoped, short-lived tokens.
- **Network egress** — without VPC controls, the sandbox is often open-internet by default. Enforce a strict egress allowlist to mitigate prompt-injection exfiltration paths.
- **Auditability** — ensure provider logs can be exported to a SIEM; young platforms often lack an immutable audit trail.
- **Data residency** — audit model-training terms and data-retention contracts so prompt data is not used for provider-side training.
- **Compliance and maturity** — SOC 2 / ISO, a single-tenant option, a real security team, incident-response commitments. Providers optimizing for GPU price and spin-up speed are often early here.
- **Availability and lock-in** — a young vendor is now in the critical path for developer compute.

## Hardening Strategy: The Self-Hosted Sandbox Model

The most effective control lever is the self-hosted sandbox. This architecture keeps agent orchestration on the vendor side while moving tool execution into infrastructure you control. Only tool inputs and outputs flow to the model control plane; the actual source code, filesystem, and network egress never leave your environment.

The core of the strategy is the **environment worker** — a process running on your vetted infrastructure that claims work items from a queue, downloads the agent's skills, runs the tool calls, and posts results back:

- **Credential separation** — the worker authenticates to its queue with an environment key, keeping your model-provider API key off the worker host. Custom tools run inside your sandbox and reach only the internal services, credentials, and egress you configured.
- **Isolated execution** — each session runs in a fresh sandbox image with resource limits and per-session network controls — exactly what the microVM providers are built to give you.

Platform-specific worker guides exist for AWS Lambda MicroVMs, Blaxel, Cloudflare, Daytona, E2B, GKE Agent Sandbox, Modal, Namespace, Superserve, and Vercel. Choose on isolation model, egress control, and compliance — not on GPU price and spin-up latency alone.

## Enforcement and Policy Migration

Controls from the earlier parts must be ported to this new compute boundary:

- **Agent hardening** — pre-tool hooks and managed settings (see [Part 2](part-2-endpoint-hardening-and-policy-playbook.md)) must be baked into the sandbox image as root-owned configurations, not delivered via MDM.
- **MCP gateway** — route all sandbox-originating tool calls through a trusted MCP gateway (see [Part 3](part-3-architecture-gateways-and-remote-defense.md)) to enforce data-aware rules and secret blocking.
- **Network guardrails** — rebuild default-deny egress inside the provider's network policy to prevent data exfiltration.

## The Playbook

The security engineer's checklist when agent compute moves to a GPU-first or sandbox-native provider — work it top to bottom.

- **Audit the provider across the control domains before onboarding.** Tenancy/isolation (real microVM isolation and VRAM scrubbing, not shared containers), credential hygiene, egress control, exportable audit trail, data-residency/no-training terms, and compliance maturity (SOC 2/ISO, single-tenant option, IR commitments). Assess it like any vendor holding your source and secrets.
- **Prefer the self-hosted sandbox worker.** Keep orchestration vendor-side, move tool execution onto infrastructure you control via an environment worker, so source, filesystem, and egress never leave your boundary — only tool I/O flows to the model plane.
- **Separate credentials.** The worker uses an environment key to its queue; the model-provider API key stays off the worker host, and custom tools reach only the internal services and egress you configured.
- **Bake the endpoint controls into the sandbox image.** Pre-tool hooks and managed settings ([Part 2](part-2-endpoint-hardening-and-policy-playbook.md)) as root-owned config in the image — MDM cannot reach this compute.
- **Route tool calls through the MCP broker ([Part 3](part-3-architecture-gateways-and-remote-defense.md)).** Enforce data-aware rules and secret blocking on every sandbox-originating call.
- **Rebuild default-deny egress inside the provider's network policy.** No VPC means open-internet by default; re-establish the allowlist to close the prompt-injection exfiltration path.
- **Re-establish the audit trail.** Export provider logs to your SIEM ([Part 9](part-9-detection-monitoring-ir.md)); do not assume an immutable trail exists on a young platform.

## Bottom Line

Shifting agent compute to specialized providers improves isolation through ephemeral microVMs, but the security gain is illusory if the foundational layers of IAM, audit, and egress control are not re-established. Assess these providers with the same rigor as any vendor holding your source code and secrets, and prioritize the self-hosted-sandbox worker model to keep execution and data inside a boundary you control while still leveraging high-performance agentic compute.

## Sources

- https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes

---

Nav: **[← Index](../index.md)** · **[Glossary](../glossary.md)** · Next → **[Part 5 — Personal, Always-On AI Assistants](part-5-personal-always-on-assistants.md)**
