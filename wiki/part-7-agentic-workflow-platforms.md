---
title: "Part 7 — Agentic Workflow Platforms (n8n, Gemini Enterprise)"
summary: "Securing platforms where non-developers build agentic workflows wired into enterprise data — automation platforms like n8n and hyperscaler agent platforms like Google Gemini Enterprise; the SaaS-vs-self-hosted decision and the connector layer."
part: 7
updated: 2026-07-17
---

# Part 7 — Agentic Workflow Platforms (n8n, Gemini Enterprise)

Parts 1-6 lived on the developer's machine and the agent it runs. This part moves up a level, to the platforms where people (often not developers) assemble agentic workflows — an LLM plus tools plus triggers — and wire them into the organization's data. Two archetypes: the automation platform (n8n and its kind), and the hyperscaler agent platform (Google Gemini Enterprise, the evolution of Vertex AI). They differ in shape but share a security shift: the risk is no longer one laptop, it is a central platform that can run code, call tools, and reach into every connected system.

## The Shared Shift: From Endpoint to Platform + Connectors

Three properties define this class and its risk:

- **It executes.** These platforms run arbitrary code (n8n's Code node is a JavaScript/Python execution surface by design) and call tools, so "the workflow" is really "code plus API calls a non-engineer wired together."
- **It connects to everything.** The value is the connector catalog — the platform reaches Drive, Gmail, SharePoint, Salesforce, Slack, databases, internal APIs. An agentic workflow inherits that reach, so a prompt injection or a bad step becomes cross-system data movement.
- **It concentrates credentials.** One platform holds the tokens and keys for every system it touches. That store is a honeypot, and its encryption key is the whole ballgame.

## n8n: The Automation Platform

The general risks, independent of where it runs:

- **Arbitrary code.** The Code node runs untrusted JavaScript/Python inside the instance. Treat it as remote code execution and restrict who can author it.
- **Community nodes are a supply chain.** Installing a community node pulls unverified npm code that has full access to the host and to the data in your workflows. Disable it unless vetted (`N8N_COMMUNITY_PACKAGES_ENABLED=false`), and treat any allowed node like a dependency you review.
- **Webhooks are a public trigger surface.** Self-hosted instances expose endpoints external services call; authenticate them and treat inbound payloads as untrusted input to an agentic workflow.
- **The credential store and encryption key.** n8n encrypts stored credentials with `N8N_ENCRYPTION_KEY`; lose it and the store is unrecoverable, leak it and the store is wide open. Protect and rotate it like any root secret.

### Cloud vs Enterprise / Self-Hosted: Where the Boundary Actually Is

The instinct is "Cloud = less safe, self-hosted = safe." That is not where the line runs. The real boundary is the **license tier**, and the hosting choice is mostly about **data residency and operational burden**:

- **n8n Cloud (SaaS):** runs on the vendor's infrastructure (Azure, EU/Frankfurt-fixed residency), with your workflow payloads, OAuth tokens, and credentials stored there (encrypted at rest). You skip patching and uptime, but your data transits and lives in vendor infra, and residency is not yours to choose.
- **Self-hosted (Community or Enterprise):** runs in your own VPC or on-prem, so payloads, credentials, and logs never leave your boundary; you pick the region and can run air-gapped with no telemetry — the requirement for strict GDPR / HIPAA / ISO 27001 / SOC 2 setups. In exchange you own patching, backups, hardening, and the encryption key.
- **The tier is what gates the security features:** SSO / SAML / LDAP and audit-log streaming to a SIEM are **Enterprise-only**; RBAC is on paid tiers. So self-hosting the free Community edition does *not* give you SSO or SIEM streaming — for a governed deployment you need self-hosted **Enterprise**, not just self-hosted.

Decision: sensitive data or a compliance regime → self-hosted **Enterprise** (data in your VPC + SSO + audit streaming, air-gap where needed). Lower-sensitivity work with no DevOps capacity → Cloud is reasonable, accepting vendor data transit, fixed residency, and no SIEM streaming below Enterprise.

## Gemini Enterprise: The Hyperscaler Agent Platform

Google's Gemini Enterprise Agent Platform builds, deploys, and governs enterprise agents, with prebuilt connectors into Google sources (BigQuery, Cloud Storage, Drive, Gmail, Calendar, Cloud SQL, Spanner, and more) and third-party sources (Jira, Confluence, Microsoft Entra ID / OneDrive / Outlook / SharePoint, ServiceNow, Box, Salesforce, Slack). The reach is the point, and the risk:

- **Connector over-reach.** An agent grounded on Drive/Gmail/SharePoint inherits broad read access; if ACLs and identity mapping are not exact, the agent surfaces data the invoking user should never see.
- **MCP connector surface.** Tool poisoning and trust-boundary abuse apply directly. The publicly discussed "GeminiJack" issue showed zero-click data exfiltration from an ordinary query when the connector surface was misconfigured — the failure is a misconfiguration, not a rare exploit.
- **The usual agentic risks, at platform scale.** Prompt injection, tool-connected agents acting on it, shadow-AI agents nobody registered, and sensitive data flowing into systems whose native controls do not govern it at runtime.

Google ships the controls to match, and they map cleanly onto this guide: an **Agent Gateway** and **agent identity authentication** (front every production agent, authenticate the caller), **Model Armor** on all agent endpoints (prompt/response screening), **Agent Threat Detection** and an **Agent Registry** (inventory + watch for unexpected external connections — the discovery and audit layers from Parts 1 and 6), **VPC Service Controls / Private Service Connect** (egress boundary, the Part 3/4 theme), **CMEK** (own the keys), and content / semantic governance policies (data-leakage guardrails). Configure the gateway and identity *before* enabling production agents, not after.

## Deploying Workflows Safely: GitOps, Secrets, and the AI Gateway

Three controls matter most before an agentic workflow is published and wired to a critical system.

**Ship workflows as code (IaC / GitOps), with an AI security-review gate.** Do not hand-build and publish workflows in the UI straight against production. Export every workflow to version control (n8n Enterprise supports git-based source control plus dev/staging/prod environments) and treat it exactly like application code: a change is a pull request, reviewed and gated before it can be promoted. Add an **AI-powered security review** to that gate that reads the workflow definition and flags the dangerous shapes a human skims past — a Code node that reads credentials or `.env`, an HTTP node posting data to an un-allowlisted domain, a newly added community node, an over-broad credential, a webhook with no auth, or a path from untrusted input straight to an exfil-capable tool. Nothing reaches a critical system until that review plus a human approval pass. This is the [Part 6](part-6-extension-supply-chain.md) change-control discipline applied to workflows, and it is where you catch the prompt-injection-to-exfil chain before it is live, not after.

**Manage secrets externally; never inline them.** The workflow definition and its nodes must not carry raw secrets. Use an external secret manager (n8n Enterprise pulls external secrets from Vault and the AWS/GCP/Azure secret managers) and reference secrets by name so they are injected at run time and never committed to the git-stored workflow or pasted into a prompt. Protect and rotate the platform's own encryption key (n8n's `N8N_ENCRYPTION_KEY`), scope each stored credential to the narrowest system and permission the workflow needs, and rotate on a schedule and on any departure. A secret baked into a workflow JSON that lands in git is a leaked secret.

**Route all LLM calls through the AI gateway.** Agentic workflows call models; send those calls through the organization's AI gateway rather than embedding a provider API key in a node. The gateway gives you a model allowlist, one place to hold provider credentials (so keys never live in the workflow), prompt/response logging, spend controls, and a policy chokepoint (no raw PII in prompts, blocked models). A workflow that talks to a provider endpoint directly with an inlined key is both an ungoverned egress path and a credential-leak risk; the gateway turns model access into a governed, audited call — the same egress-allowlist principle as [Part 3](part-3-architecture-gateways-and-remote-defense.md) and [Part 4](part-4-beyond-the-hyperscalers.md), applied to model traffic.

## The Playbook (Both Platforms)

- **Choose hosting by data sensitivity, and know the tier is the real gate.** Sensitive/regulated data → self-hosted Enterprise (n8n) or a locked-down project with VPC-SC + CMEK + private connectivity (Gemini). Don't assume "on-prem" or "our cloud project" gives you SSO, RBAC, and SIEM streaming — those are edition/config features you must switch on.
- **Kill arbitrary code where you can.** Disable code and community nodes unless a specific one is vetted; treat every code/tool node as RCE and restrict authorship to reviewed users.
- **Least-privilege the connector layer, with exact identity mapping.** Each connector gets the narrowest scope; the agent must never see more than the user who invoked it. Allowlist which connectors and tools an agent may use.
- **Authenticate every trigger; treat inbound data as untrusted.** Webhooks and inbound events are the injection path into an agentic workflow — require auth and validate.
- **Protect the credential concentration.** The platform's credential store is a honeypot: guard and rotate the encryption key (n8n), prefer CMEK plus a real secret manager (Gemini), never inline secrets in a node or prompt.
- **Inventory, govern, and stream to your SIEM.** Register every workflow/agent, forward audit and agent-action logs to your SIEM (n8n Enterprise log streaming; Gemini Agent Threat Detection), and alert on unexpected external connections — the exfil signal.
- **Constrain egress.** An agentic workflow that can call any HTTP endpoint is an exfiltration path; allowlist destinations (VPC-SC / network policy), the same lever as [Part 3](part-3-architecture-gateways-and-remote-defense.md) and [Part 4](part-4-beyond-the-hyperscalers.md).
- **Use runtime content guardrails, but don't make an LLM the only gate.** Model-Armor-style screening and semantic governance help, but as [Part 5](part-5-personal-always-on-assistants.md) noted, an LLM judge is promptable and non-deterministic; pair it with deterministic connector-scope and egress limits.

## Bottom Line

Agentic workflow platforms move the risk from the developer's machine to a central platform that runs code, calls tools, and is wired into all of your data. The hosting decision (self-hosted Enterprise vs SaaS) sets your data-residency and audit posture — and the real gate is the edition, not merely cloud-vs-on-prem. But wherever it runs, the durable controls are the same: kill arbitrary code, least-privilege the connectors with exact ACL/identity mapping, authenticate the triggers, protect the credential store, constrain egress, and stream every agent action to your SIEM.

## Sources

- https://docs.n8n.io/integrations/community-nodes/risks
- https://n8n.io/legal/security/
- https://docs.cloud.google.com/gemini-enterprise-agent-platform/overview
- https://docs.cloud.google.com/gemini-enterprise-agent-platform/govern
- https://beyondscale.tech/blog/google-gemini-enterprise-security
