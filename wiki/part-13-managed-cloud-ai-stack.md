---
title: "Part 13 — The Managed Cloud AI Stack (AgentCore, Bedrock, SageMaker)"
summary: "The inverse of Part 11: managed feels safe but isn't done. A hyperscaler's agent stack is SOC-compliant and hands you isolation, a token vault, and an audit plane — which is exactly what makes teams stop at 'the platform handles security.' It handles its half. This part is the shared-responsibility line across the three layers: the managed agent runtime (AgentCore), the managed model (Bedrock), and the model-building platform (SageMaker), each mapped back to the controls the guide already built."
part: 13
updated: 2026-07-17
---

# Part 13 — The Managed Cloud AI Stack

Part 11's lesson was that local inference *feels private, so it gets treated as safe* — and is neither. This part is the mirror image. A managed cloud AI stack **feels safe** — it is SOC-compliant, it isolates each agent session, it stores credentials in a vault, it emits an audit plane — and that is precisely what makes teams stop reading the shared-responsibility line. The platform genuinely owns a large half of the problem. It does not own *your* half, and your half is where every earlier part of this guide lives.

There is a striking way to see it: the managed stack is **this guide's own recommended architecture, productized.** A managed agent runtime gives you the [Part 3](part-3-architecture-gateways-and-remote-defense.md) MCP broker, the [Part 10](part-10-agent-identity.md) credential boundary, the [Part 2](part-2-endpoint-hardening-and-policy-playbook.md)/[4](part-4-beyond-the-hyperscalers.md) sandbox, [Part 1](part-1-risk-surface-and-control-model.md)/[2](part-2-endpoint-hardening-and-policy-playbook.md) enforcement, and the [Part 9](part-9-detection-monitoring-ir.md) audit chain, as managed services. So this part is not teaching a new threat. It is teaching how to *adopt a managed implementation of controls you already understand* without handing over the half you keep. We use AWS — **Amazon Bedrock AgentCore** (the agent runtime), **Amazon Bedrock** (the managed model), and **Amazon SageMaker** (model building) — as the worked example, with peer platforms named so the model is vendor-neutral. (Product controls move fast; verify every specific against current vendor docs.)

## Section 1: The Managed Agent Runtime (AgentCore)

The genuinely new surface: a fully-managed agent runtime plus an MCP-native gateway plus an identity broker. Each piece is a managed version of a control from earlier parts.

- **Gateway — the [Part 3](part-3-architecture-gateways-and-remote-defense.md) MCP broker, managed.** AgentCore Gateway is a managed AI gateway that turns OpenAPI/Smithy/Lambda targets into MCP tools behind a single entry point, and (as of 2026) does **both** ingress authentication (it acts as an OAuth resource server, working with Cognito/Okta/Auth0) and egress authentication. Lambda **interceptors** let you inject fine-grained access control and sanitization, and it supports PrivateLink so traffic stays in your VPC. This is the broker model you would otherwise self-host.
- **Identity — the [Part 10](part-10-agent-identity.md) credential boundary, managed.** AgentCore Identity is a token vault and workload-identity broker: "neither the Gateway nor the MCP servers manage credentials directly." That is exactly Part 10's credential boundary — the agent never holds the provider secret — delivered as a service. (See Part 10 for why this dead-ends the [Part 1](part-1-risk-surface-and-control-model.md) exfiltration path; this section only adds that AWS now offers it off the shelf.)
- **Runtime — the sandbox, managed.** Per-session isolation, streaming, human-approval pause/resume, and zero-trust identity propagation — the [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) human-in-the-loop and [Part 4](part-4-beyond-the-hyperscalers.md) isolated-execution primitives, without hand-rolled session stores or shared service-account credentials.
- **Policy — enforcement, managed.** Deterministic guardrails defined around your tools at a central plane — [Part 1](part-1-risk-surface-and-control-model.md)/[2](part-2-endpoint-hardening-and-policy-playbook.md) allow/ask/deny, centralized.

**The half you still own.** SOC 1/2/3 compliance covers the platform's controls, not your configuration decisions. You still own: *which* tools you expose through the Gateway and how broadly; the IAM role scoping on each Lambda/Smithy target (excessive agency, LLM06, lives right here — a broadly-scoped target role is a broadly-capable agent); whether PrivateLink/VPC isolation is actually enabled versus the public default; tenant-isolation configuration for multi-tenant tools; wiring the managed observability logs into *your* SOC ([Part 9](part-9-detection-monitoring-ir.md) — the logs exist, but nobody investigates them for you); and the fact that the model on top is still promptable, so prompt injection (LLM01) reaches whatever tools you exposed. The managed runtime moves the plumbing off your plate; it does not move the exposure decisions.

**Peers (same shape, named for neutrality):** Azure AI Foundry Agent Service and Google Vertex AI Agent Engine present the same managed-runtime + shared-responsibility structure. The control questions transfer unchanged.

## Section 2: The Managed Model Layer (Bedrock)

This layer *extends* the [Part 7](part-7-agentic-workflow-platforms.md) AI-gateway discussion — it does not repeat it. Part 7 established that model calls should pass a governed egress chokepoint; here is what the managed model service adds on top of that, and must be switched on to get.

- **Bedrock Guardrails — a complement, not a replacement.** Content filters, denied topics, PII redaction, and contextual-grounding checks screen model input and output. Position them exactly as Part 1 positions the gateway: **necessary, not sufficient.** A guardrail inspects the prompt and completion; it does not gate the agent's local tool actions. It reduces the odds a bad instruction gets generated; it does not stop an already-compromised agent from acting.
- **Model-invocation logging from day zero.** Bedrock can log every invocation (prompt, completion, metadata) to your log store — turn it on *before* first use and forward it, because it is the model-layer slice of the [Part 9](part-9-detection-monitoring-ir.md) causal chain. A managed model with logging off is an ungoverned model with a nicer console.
- **Data handling and residency.** Where prompts and completions land, cross-region inference and the regions it may traverse, and the [Part 8](part-8-work-ai-and-dspm.md) "no raw PII in prompts" boundary applied to a managed endpoint. Confirm the data path before sensitive corpora flow through it.
- **Consumption as an availability control.** Provisioned throughput and spend limits are the managed-model answer to unbounded consumption (LLM10) — a runaway or abused agent can burn tokens and budget; cap it.

The section's throughline: the managed model layer hands you screening and logging levers, and the shared-responsibility catch is that they ship *off by default enough* to matter — you must enable them and route the agent's calls through them, exactly as Part 7 said for the gateway.

## Section 3: The Model-Building Layer (SageMaker)

SageMaker builds and hosts models; it is not itself an agent runtime. But it sits upstream of, and downstream from, agents in ways that are squarely in this guide's scope — each mapped back to an existing part.

- **The endpoint-as-tool boundary.** A SageMaker inference endpoint that an agent calls is a connector like any other: scope its invoke identity to least privilege, put it behind the egress allowlist, and log the calls ([Parts 7](part-7-agentic-workflow-platforms.md)/[10](part-10-agent-identity.md)/[9](part-9-detection-monitoring-ir.md)). A self-built model wired behind an agent raises the same excessive-agency question (LLM06) as any tool.
- **Training-data poisoning (LLM04) as a supply-chain surface.** The training data and the pipeline that produced a model are upstream of everything the agent later does with it — [Part 6](part-6-extension-supply-chain.md) (supply chain) and [Part 11](part-11-local-open-source-models.md) (model provenance) applied to a model you *train* rather than download. Data lineage, provenance, and pipeline integrity are the controls.
- **Notebook / Studio execution-role sprawl.** SageMaker notebooks and Studio run arbitrary code under an execution role that is a classic over-broad-IAM footgun and a long-lived non-human identity — [Part 10](part-10-agent-identity.md) (NHI lifecycle) plus [Part 6](part-6-extension-supply-chain.md) (notebooks execute code). Scope the role tightly, prefer short-lived credentials, and inventory idle notebooks as shadow compute ([Part 1](part-1-risk-surface-and-control-model.md)).
- **Model Registry as an approval gate.** SageMaker Model Registry with a manual approval step before a model becomes deployable is the model-building analog of [Part 7](part-7-agentic-workflow-platforms.md)'s workflows-as-code security-review gate — the same "review before it can act" pattern, applied to a model artifact.
- **Network isolation.** VPC-only training and hosting, with no direct internet for jobs, is the [Part 3](part-3-architecture-gateways-and-remote-defense.md)/[4](part-4-beyond-the-hyperscalers.md) egress-control story applied to training compute.

**Where this stops.** Deep MLSecOps — adversarial ML, model extraction and inversion, full data-governance programs — is a different guide. This section covers the infra-security and agentic-consumption slices only; that boundary is the point, not a gap.

## The Shared-Responsibility Line

The centerpiece. The managed stack does not remove the guide's controls — it splits each one into a half the platform runs and a half you keep.

| Control (earlier part) | The managed stack provides | You still own |
|---|---|---|
| MCP broker ([P3](part-3-architecture-gateways-and-remote-defense.md)) | Gateway: managed ingress+egress auth, tool translation, PrivateLink | Which tools are exposed, how broadly |
| Credential boundary ([P10](part-10-agent-identity.md)) | Identity: token vault, workload identity | Which connections exist, their scopes |
| Sandbox ([P2](part-2-endpoint-hardening-and-policy-playbook.md)/[P4](part-4-beyond-the-hyperscalers.md)) | Runtime: per-session isolation, approval gates | Turning isolation on vs. public default |
| Enforcement ([P1](part-1-risk-surface-and-control-model.md)/[P2](part-2-endpoint-hardening-and-policy-playbook.md)) | Policy: central guardrails; Bedrock Guardrails | The tool/target IAM scoping (excessive agency) |
| Audit chain ([P9](part-9-detection-monitoring-ir.md)) | Managed application + identity logs; invocation logging | Wiring logs into your SOC; enabling logging |
| Data boundary ([P8](part-8-work-ai-and-dspm.md)) | Region controls, PII redaction options | No-PII-in-prompts; confirming the data path |
| Supply chain ([P6](part-6-extension-supply-chain.md)) | Model Registry approval gate | Training-data provenance; notebook role scope |

The adoption play follows straight from the table: **prefer the managed broker/identity/runtime over hand-rolling** — it *is* the architecture this guide recommends — but adopt it with your half wired: scoped tool exposure, least-privilege target IAM, isolation on, logs into your SOC, model still gated, provenance tracked. This maps cleanly onto [Part 12](part-12-governance-compliance.md)'s registry: a managed AI system in the registry should record *who owns which half*.

## The Playbook (the security engineer's half)

The platform runs its half automatically; this is the half you own, as a checklist you can work top to bottom when a team adopts a managed AI stack.

- **Inventory what's adopted.** Find the AgentCore/Bedrock/SageMaker usage (it arrives through the console and IaC, not procurement) and register each system with an owner and a data classification ([Part 12](part-12-governance-compliance.md)). "Managed" does not mean "discovered."
- **Scope the target IAM, not just the gateway.** For every Gateway tool (Lambda/Smithy target), audit the assumed role — a broadly-scoped target role is a broadly-capable agent. This is where excessive agency (LLM06) actually lives; least-privilege each one.
- **Turn on isolation and confirm it.** PrivateLink / VPC-only for the runtime and for SageMaker training/hosting; verify it's enabled rather than the public default. Bind agent traffic inside your VPC boundary.
- **Enable logging before first use.** Bedrock model-invocation logging on from day zero, AgentCore observability and identity logs forwarded to your SOC ([Part 9](part-9-detection-monitoring-ir.md)). Managed logs exist; nobody investigates them for you until you wire them.
- **Set the guardrails you own.** Bedrock Guardrails (PII redaction, denied topics) as a complement to — not a replacement for — tool gating; AgentCore Policy for deterministic tool guardrails. Remember the model is still promptable, so keep the tool-side controls.
- **Scope credentials and identities.** Use AgentCore Identity's vault (no provider secrets in agent config, per [Part 10](part-10-agent-identity.md)); scope each connection; give SageMaker notebook/Studio execution roles least privilege and short-lived creds; inventory idle notebooks as shadow compute.
- **Cap consumption.** Provisioned-throughput and spend limits so a runaway or abused agent can't burn budget or availability (LLM10).
- **Record who owns which half.** In the [Part 12](part-12-governance-compliance.md) registry, note the shared-responsibility split per system, so an audit can answer "who is accountable for this control" without a scramble.

## Bottom Line

A managed cloud AI stack is the most seductive place to stop thinking about security, because so much of it is genuinely handled. AgentCore is your MCP broker, credential boundary, sandbox, and audit plane as a service; Bedrock is your governed model with guardrails and logging; SageMaker is your model factory with a registry gate. None of that is the trap. The trap is "managed, therefore done." The platform owns its half; you own tool exposure, identity scope, isolation toggles, log wiring, the still-promptable model, and model provenance. Adopt the managed stack — it beats hand-rolling the same controls — but adopt it as a shared-responsibility model, not as a place to hand the problem away.

## Sources

- https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html
- https://aws.amazon.com/blogs/machine-learning/introducing-amazon-bedrock-agentcore-identity-securing-agentic-ai-at-scale/
- https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-security-best-practices.html
- https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html
- https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html
- https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html

---

Nav: **[← Index](../index.md)** · **[Glossary](../glossary.md)** · **[Start Here](../start-here.md)** · _Part 13 is the final part._
