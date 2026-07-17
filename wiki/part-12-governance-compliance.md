---
title: "Part 12 — Governance and Compliance: Mapping the Controls to the Frameworks"
summary: "The CISO layer. The first eleven parts are technical controls; this part is the crosswalk that lets you evidence and report them in the language auditors, regulators, and boards use — NIST AI RMF, ISO 42001, the EU AI Act, the OWASP LLM Top 10, and MITRE ATLAS — plus the program scaffolding (intake, registry, roles, metrics) that no single control provides."
part: 12
updated: 2026-07-17
---

# Part 12 — Governance and Compliance

Parts 1–11 are controls: harden the endpoint, broker the tools, govern the extensions, detect the anomaly, scope the identity. A control that exists but cannot be *named* in the frameworks your auditors, regulators, and board already use is a control you cannot evidence, report, or defend in a review. This part is the crosswalk from the guide's controls to the five frameworks that matter, plus the program scaffolding — intake, registry, roles, metrics — that is governance rather than engineering. It is the layer a CISO needs and the earlier parts deferred.

## Five Frameworks, Three Jobs

Do not treat these as five checklists. They answer three different questions:

- **What can go wrong** — the **OWASP Top 10 for LLM Applications** (the vulnerability classes) and **MITRE ATLAS** (the adversary tactics and techniques). Threat vocabularies.
- **How to run a program** — the **NIST AI Risk Management Framework** (voluntary; Govern / Map / Measure / Manage) and **ISO/IEC 42001** (a certifiable AI management system). Program scaffolding.
- **What the law requires** — the **EU AI Act** (risk-tiered obligations with real deadlines and fines). Regulation.

You implement the controls once. You then *report* them five ways. That is the whole move.

## Crosswalk 1 — OWASP LLM Top 10 (2025) → the control that answers it

The 2025 list is the threat catalog this guide has been countering all along.

| OWASP (2025) | Countered mainly in |
|---|---|
| LLM01 Prompt Injection | [Part 1](part-1-risk-surface-and-control-model.md) attack path, [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) enforcement, [Part 5](part-5-personal-always-on-assistants.md) inbound-channel injection |
| LLM02 Sensitive Information Disclosure | [Part 8](part-8-work-ai-and-dspm.md) DSPM + oversharing, [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) response inspection |
| LLM03 Supply Chain | [Part 6](part-6-extension-supply-chain.md) extensions, [Part 11](part-11-local-open-source-models.md) model files |
| LLM04 Data and Model Poisoning | [Part 11](part-11-local-open-source-models.md) model provenance, [Part 5](part-5-personal-always-on-assistants.md) memory poisoning |
| LLM05 Improper Output Handling | [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) post-tool inspection, [Part 7](part-7-agentic-workflow-platforms.md) output→tool paths |
| LLM06 Excessive Agency | [Part 1](part-1-risk-surface-and-control-model.md)/[Part 2](part-2-endpoint-hardening-and-policy-playbook.md) tool gating, [Part 10](part-10-agent-identity.md) scoped/JIT identity |
| LLM07 System Prompt Leakage | [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) hardening, [Part 9](part-9-detection-monitoring-ir.md) detection |
| LLM08 Vector and Embedding Weaknesses | [Part 8](part-8-work-ai-and-dspm.md) retrieval/permission-aware access (RAG boundary) |
| LLM09 Misinformation | human-in-the-loop ([Part 2](part-2-endpoint-hardening-and-policy-playbook.md)); largely an AppSec/quality concern beyond this infra guide |
| LLM10 Unbounded Consumption | [Part 9](part-9-detection-monitoring-ir.md) token/cost-spike detection + the kill switch |

## Crosswalk 2 — MITRE ATLAS → the control, focused on agent techniques

ATLAS (v5.1.0, ~16 tactics / 84 techniques as of late 2025) added a wave of agent-specific techniques — the ones that map directly onto this guide.

| ATLAS technique (agentic) | Countered in |
|---|---|
| Context / memory poisoning | [Part 5](part-5-personal-always-on-assistants.md) memory, [Part 9](part-9-detection-monitoring-ir.md) memory-tamper detection |
| Agent configuration tampering | [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) hook gating config paths, [Part 6](part-6-extension-supply-chain.md) managed-only hooks/rules |
| Credential harvesting | [Part 1](part-1-risk-surface-and-control-model.md) credential-path blocking, [Part 10](part-10-agent-identity.md) credential boundary |
| Exfiltration via tool invocation | [Part 9](part-9-detection-monitoring-ir.md) credential-read-then-egress detection, [Part 3](part-3-architecture-gateways-and-remote-defense.md)/[4](part-4-beyond-the-hyperscalers.md) egress allowlist |
| RAG poisoning / false RAG entry | [Part 8](part-8-work-ai-and-dspm.md) source ACLs + DSPM |
| AI supply-chain compromise | [Part 6](part-6-extension-supply-chain.md), [Part 11](part-11-local-open-source-models.md) |
| Impersonation | [Part 10](part-10-agent-identity.md) delegation-over-impersonation |

## Crosswalk 3 — NIST AI RMF (and ISO 42001)

The AI RMF's four functions line up with the shape of this whole guide, and the RMF is the standard implementation path toward ISO/IEC 42001 certification (there is a published crosswalk between them).

- **Govern** (cross-cutting) — agent/NHI identity governance and lifecycle ([Part 10](part-10-agent-identity.md)), plus the program layer below.
- **Map** (context, inventory, harms) — discovery and shadow-AI inventory ([Part 1](part-1-risk-surface-and-control-model.md)), the extension and runtime inventories ([Parts 6](part-6-extension-supply-chain.md)/[11](part-11-local-open-source-models.md)).
- **Measure** (metrics, evaluation) — the detection and behavioral-IOC layer and its logging ([Part 9](part-9-detection-monitoring-ir.md)).
- **Manage** (risk response) — real-time enforcement ([Parts 2](part-2-endpoint-hardening-and-policy-playbook.md)/[3](part-3-architecture-gateways-and-remote-defense.md)), incident response and the fail-safe kill switch ([Part 9](part-9-detection-monitoring-ir.md)).

NIST's **Generative AI Profile (AI 600-1)** names 12 GenAI-specific risk categories (confabulation, prompt injection, data-privacy degradation, value-chain risk, and others); each maps to the parts above. **ISO/IEC 42001** is the certifiable management-system wrapper — the guide's practices become the evidence its risk-assessment, controls, monitoring, and continual-improvement clauses ask for.

## Crosswalk 4 — EU AI Act (obligations and dates)

The Act is law, risk-tiered (unacceptable / high / limited / minimal), with fines up to EUR 35M or 7% of global turnover. What matters for an agentic-AI security program:

- **Human oversight** (high-risk requirement) — the human-in-the-loop posture of [Part 2](part-2-endpoint-hardening-and-policy-playbook.md) (plan/ask defaults, no unattended bypass).
- **Cybersecurity of high-risk systems** — effectively the entire guide.
- **Logging / record-keeping** — the causal-chain audit trail of [Part 9](part-9-detection-monitoring-ir.md).
- **Risk management + technical documentation** — this part plus the program layer.

Dates to plan against (verify against the current text, which is shifting): prohibited practices enforceable since **2 Feb 2025**; GPAI-model obligations since **2 Aug 2025**; high-risk (Annex III) obligations now anchored at **2 Dec 2027** and product-embedded (Annex I) at **2 Aug 2028** following the 2026 Digital Omnibus revision. The deadlines move; the direction does not.

## The Program Layer (governance, not a technical control)

No single control in Parts 1–11 provides these; they are the connective tissue a CISO owns.

- **AI / agent intake and registry.** Extend the [Part 1](part-1-risk-surface-and-control-model.md) discovery inventory into a governed registry: every agent, workflow, Work-AI connection, and model, with an owner, a purpose, a risk classification (map to the EU tiers), and a decommission date. Discovery finds shadow AI; the registry is what you govern and audit against.
- **Named ownership and roles.** Every registered AI system has an accountable owner; security, AppSec, and GRC scopes are assigned (routing, not diffusion).
- **Risk classification per intake.** Tier each system (EU-Act-style) so obligations scale with risk instead of being uniform.
- **Metrics a CISO reports.** A handful, not a dashboard graveyard: shadow-AI discovered vs sanctioned, % of agents under the managed baseline, mean time to revoke a compromised agent identity, open high-severity agent findings, registry coverage.
- **Evidence collection.** Wire the enforcement and detection logs (Parts 2/3/9) so an audit answer is a query, not a scramble.
- **Continual review.** AI RMF and ISO 42001 are cycles; the registry, classifications, and control mappings are reviewed on a cadence, because the surface (and the regulations) keep moving.

## Bottom Line

The frameworks do not replace the controls in this guide; they are the languages you evidence and report those controls in. OWASP and ATLAS name what you are defending against, NIST and ISO give you the program to run and certify, and the EU AI Act sets the legal floor with real deadlines. Build the controls once, map them once, and you can answer a red-team threat model, a NIST assessment, an ISO audit, and a regulator's inquiry from the same body of work — plus the program scaffolding (registry, owners, tiers, metrics) that turns a pile of controls into a governable program.

## Sources

- https://genai.owasp.org/llm-top-10/
- https://atlas.mitre.org/
- https://www.nist.gov/itl/ai-risk-management-framework
- https://www.iso.org/standard/81230.html
- https://artificialintelligenceact.eu/

---

Nav: **[← Index](../index.md)** · **[Glossary](../glossary.md)** · **[Start Here](../start-here.md)** · _Part 12 is the final part._
