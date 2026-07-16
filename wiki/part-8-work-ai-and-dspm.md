---
title: "Part 8 — Enterprise Work AI and the DSPM Prerequisite (Glean and peers)"
summary: "Why a permission-aware Work AI platform is dangerous precisely because it faithfully mirrors your permissions, and why DSPM — knowing what sensitive data exists and who can reach it — is the non-optional companion."
part: 8
updated: 2026-07-17
---

# Part 8 — Enterprise Work AI and the DSPM Prerequisite

An enterprise Work AI platform (Glean and its peers, and the assistant side of Microsoft Copilot and the Gemini Enterprise app from [Part 7](part-7-agentic-workflow-platforms.md)) indexes everything the company has connected — Drive, SharePoint, Slack, Jira, Confluence, email, wikis, code, tickets — and answers natural-language questions across all of it. These tools are built to be **permission-aware**: they check ACLs at index and query time and honor least privilege, so they never grant a user access they didn't already have. That sounds like the safety story. It is actually the risk.

## The Core Risk: A Faithful Mirror of Permissions You Never Audited

The danger is not that the platform leaks past your permissions. It is that it enforces them perfectly, and your permissions are already overshared. Two named failure modes:

- **Oversharing.** Content that was technically accessible but practically buried — an "anyone with the link" Drive doc, an overshared SharePoint site, a Slack channel half the company sits in, a folder a departed employee's stale ACL still exposes — was safe by obscurity. Nobody navigated to it. Work AI removes the obscurity: now anyone who asks the right question in plain English gets it. The assistant can also stitch together individually-permissible fragments into an answer that is, in aggregate, sensitive.
- **Access sprawl.** Broad group entitlements ("all-company," a catch-all "engineering" group) let people see far more than their role needs. The AI inherits that group access and will surface, on request, data the user technically can reach but never should — and may present it from sources the person has never directly opened.

The concrete version of the question you asked: an **engineer** types a normal question and the assistant surfaces **HR compensation spreadsheets, an unreleased marketing plan, or M&A documents** — not because the platform is broken, but because those files were overshared and the engineer was, on paper, entitled. Work AI converts "technically has access but never looked" into "asks in English and receives." Whom you are exposing to which content is decided by ACLs that accreted over years and were never reviewed.

## Why DSPM Is the Critical Connection

You cannot safely switch on a Work AI platform without first answering: *what sensitive data exists, and who can reach it?* That is exactly what Data Security Posture Management (DSPM) does — continuously discover sensitive data, classify it, map who-can-access-what (access governance), and flag exposure: public/external links, overshared folders, inactive accounts, stale ACLs. "DSPM for AI" extends this to how data flows into LLM retrieval and prompting.

DSPM is both the **prerequisite** and the **ongoing control**:

- **Before you connect the corpus,** DSPM tells you what the assistant *would* surface and to whom, so you remediate the oversharing first instead of discovering it through a leaked answer.
- **After you go live,** DSPM keeps watching, because oversharing drifts: new documents, new links, reorgs, and departures constantly re-open exposure.

Without DSPM, turning on Work AI is turning on a natural-language index of an attack surface you have never measured.

## The Playbook

- **Do not mistake "permission-aware" for "safe."** The platform enforcing ACLs faithfully is the risk when the ACLs are overshared. Permission-awareness is necessary, not sufficient.
- **Run DSPM before you connect the corpus.** Discover and classify the sensitive classes (compensation, PII, source, secrets, M&A, legal), map who-can-access-what, and remediate the worst oversharing — kill "anyone with the link," fix stale ACLs, tighten overshared sites and groups — *before* the assistant makes it queryable.
- **Fix the source ACLs, not just the AI.** The exposure lives in SharePoint / Drive / Slack; the Work AI only reveals it. Remediate at the source. Use the platform's hide/exclude capability (Glean Protect-style continuous scanning that auto-hides overshared sensitive content from Search, Assistant, and Agents) as a compensating control, not the fix.
- **Deliberately map audience to content.** Decide which content classes and connectors are in scope and who should see them — engineers vs. HR vs. marketing vs. finance — rather than inheriting whatever accreted. Exclude crown jewels (comp, M&A, security, legal) from the general assistant or scope them to the right groups.
- **Least-privilege the identity layer too.** The AI inherits group membership, so a bloated all-company or catch-all group is an exposure vector. Trim entitlements and stale accounts (this is where access sprawl actually lives).
- **Audit and monitor queries.** Log who asked what and what surfaced, and alert when a user pulls content far outside their role — the "engineer surfacing comp" signal is your earliest warning.
- **Treat it as continuous, not a launch checklist.** Oversharing re-accretes; DSPM and the platform's governance scanner must run continuously and alert on newly overshared sensitive content and newly stale access.

## Bottom Line

An enterprise Work AI platform is a faithful mirror of your permissions — which is exactly why it is dangerous, because it turns years of quiet oversharing into a single natural-language query. DSPM is the non-optional companion: know what sensitive data exists and who can reach it, remediate the oversharing at the source before you connect the corpus, deliberately decide which audience sees which content, and keep watching, because exposure drifts. The platform will enforce your permissions perfectly; DSPM is how you make sure those permissions are ones you can live with.

## Sources

- https://www.glean.com/security
- https://www.glean.com/blog/secure-generative-ai-for-the-enterprise-requires-the-right-permissions-structure
- https://docs.glean.com/administration/protect/overview
- https://www.knostic.ai/blog/glean-data-security
- https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about
- https://securiti.ai/what-is-dspm/

---

Nav: **[← Index](../index.md)** · **[Glossary](../glossary.md)** · Next → **[Part 9 — Detection, Monitoring, and Incident Response for Agents](part-9-detection-monitoring-ir.md)**
