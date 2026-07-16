---
title: "Part 10 — Agent Identity and Non-Human Identity (NHI)"
summary: "The identity spine the whole guide leaned on: who the agent is, as whom it acts (delegation vs impersonation), and how to govern ephemeral, just-in-time, least-privilege access for a population of machine identities growing at machine speed."
part: 10
updated: 2026-07-17
---

# Part 10 — Agent Identity and Non-Human Identity (NHI)

Every earlier part leaned on a phrase it never defined: "the agent's identity," "scoped tokens," "least privilege." This part makes identity the subject, because it is the spine the other nine hang off — discovery attributes actions to an identity, enforcement decides based on one, the audit trail records one, and the kill switch revokes one. And it is the fastest-moving gap in the field: the non-human identity (NHI) population grew about 44% year over year into 2025, most organizations have no policy for creating or removing AI identities, exposed AI-related secrets jumped roughly 81% in a year, and few teams believe their human-era IAM can manage any of it. Identities are being created at machine speed and governed at human speed.

## The Core Question: As Whom Does the Agent Act?

When an agent does something on a user's behalf, the downstream system has to answer: who is accountable? There are two models, and the choice is foundational.

- **Impersonation** — the agent assumes the user's identity directly. The downstream service sees only the user; the agent is an invisible proxy. This collapses the identity boundary: there is no way to tell a human action from an agent action, no independent accountability, and no way to revoke the agent without cutting off the user. Tolerable for a dumb pass-through tool; dangerous for an autonomous system that makes decisions.
- **Delegation (prefer this)** — the agent keeps its **own** identity and acts on behalf of the user under a scoped, time-bound, traceable grant. The downstream service sees all three: *this agent, acting for this user, under this grant, for this task.* OAuth-style scoped "on-behalf-of" is the right primitive. Zero trust for agents means delegation over impersonation, because an autonomous agent creates intent — it is not merely forwarding the user's — so it must be a responsible, named actor with its own accountability and its own revocation.

The practical payoff: a delegated, per-agent token can be revoked on its own when the agent is compromised or retired, without nuking the user's sessions — the containment lever [Part 9](part-9-detection-monitoring-ir.md) depends on.

## Why Agent Identity Breaks Human-Era IAM

- **Standing privilege and access sprawl.** Agents get handed broad, permanent role grants — often inheriting standing admin — because that is how we provisioned humans. With the NHI count exploding, standing privilege becomes the dominant attack surface.
- **Secrets sprawl.** Agents authenticate with long-lived keys that end up hardcoded in configs, prompts, and repos (the [Part 7](part-7-agentic-workflow-platforms.md) credential-store and [Part 6](part-6-extension-supply-chain.md) supply-chain problems). Exposed AI secrets are rising fast.
- **No lifecycle.** Human identities have joiners/movers/leavers; agent identities are created ad hoc, tracked by no one, and never decommissioned — orphaned credentials with standing access.
- **Protocol mismatch.** OAuth and SAML were built for human sessions; they need real augmentation to express a short-lived, task-scoped, delegated agent identity.

## The Controls

- **Give every agent its own identity, and delegate — don't impersonate.** Each agent is a named principal; when it acts for a user it does so under a scoped on-behalf-of grant so every action traces to *agent + user + grant + task*. Never let an agent silently wear a human's identity.
- **Make credentials ephemeral and task-scoped.** Short-lived, context-aware credentials tailored to the agent's current task and scope — the emerging foundational principle for agent auth — instead of long-lived standing tokens. Bind the token to the agent and the task; let it expire on its own.
- **Just-in-time access, no standing privilege.** Grant access at request time, scoped to the exact task, auto-expiring when the task completes, with request-time approval and contextual guardrails rather than a pre-built library of broad roles. JIT access platforms such as Apono generate the scoped grant on demand in the target's native policy language (AWS, Azure, GCP, Kubernetes, databases) and revoke it automatically, and apply the same model to non-human/agent identities so an agent carries no standing admin between tasks.
- **Validate intent against action.** Have the agent declare what it intends to do, grant access for exactly that, and check its actual calls against the declaration — an agent that declared "read a ticket" but reaches for a production database is stopped. Apono calls this Intent-Based Access Control (IBAC); the declared task becomes the permission boundary.
- **Scope the grant, not the role.** Delegate a specific subset of the user's permissions for the task, never the full set; OAuth-style scoped delegation is the primitive.
- **Govern the NHI lifecycle.** Track every agent identity's creation, owner, and decommission; inventory them (the discovery of [Part 1](part-1-risk-surface-and-control-model.md) and the registry of [Parts 6](part-6-extension-supply-chain.md)/[9](part-9-detection-monitoring-ir.md) extended to identities); and deprovision aggressively so orphaned agents with standing access do not accumulate.
- **Kill secrets sprawl.** No hardcoded agent keys — broker credentials through a vault or gateway ([Part 3](part-3-architecture-gateways-and-remote-defense.md)/[Part 7](part-7-agentic-workflow-platforms.md)), prefer short-lived tokens over static ones, and scan repos and configs for leaked AI secrets.
- **Make revocation per-agent and instant.** Because the agent has its own delegated identity, you can revoke it in isolation — the clean containment path when detection fires.

## Bottom Line

Identity is the spine of everything in this guide. Give each agent its own identity and prefer delegation over impersonation so every action is accountable as *agent-acting-for-user-under-a-grant*; make access ephemeral, just-in-time, and task-scoped with no standing privilege; validate the agent's actual actions against its declared intent; kill the secrets sprawl; and govern the NHI lifecycle from creation to decommission. The field is minting agent identities at machine speed — the job is to give them least-privilege, short-lived, revocable identities before the standing-privilege sprawl becomes the breach.

## Sources

- https://labs.cloudsecurityalliance.org/research/csa-whitepaper-nonhuman-identity-agentic-ai-governance-v1-cs/
- https://blog.christianposta.com/agent-identity-impersonation-or-delegation/
- https://next.redhat.com/2026/05/21/zero-trust-for-ai-agents-why-delegation-beats-impersonation/
- https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-user-oauth-flow
- https://www.paloaltonetworks.com/cyberpedia/what-is-a-non-human-identity
- https://www.apono.io/
