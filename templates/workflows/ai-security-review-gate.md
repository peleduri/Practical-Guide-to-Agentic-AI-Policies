# AI security-review gate for agentic workflows

A checklist for the pre-publish review gate from [Part 7](../../wiki/part-7-agentic-workflow-platforms.md):
ship workflows as code (GitOps), and before any workflow can be promoted to a critical
system, an AI-powered security review plus a human approval must pass. Wire this as a
required check on the pull request that promotes a workflow definition.

## What the AI review must flag (block promotion until resolved)

- **Arbitrary code that touches secrets** — a Code node (n8n) or script step that reads
  `.env`, a credential store, or environment secrets.
- **Egress to an un-allowlisted destination** — an HTTP node posting data to a domain not
  on the approved list (the exfiltration path).
- **A newly added community / third-party node** — treat as a dependency bump: unreviewed
  code with full host access ([Part 6](../../wiki/part-6-extension-supply-chain.md)).
- **An over-broad credential** — a connector scoped wider than the workflow needs; require
  exact identity mapping ([Part 7](../../wiki/part-7-agentic-workflow-platforms.md)).
- **An unauthenticated trigger** — a webhook with no auth accepting untrusted input.
- **An untrusted-input → exfil-capable-tool path** — any route from an inbound event to a
  tool that can send data out (the prompt-injection-to-exfil chain).
- **Inline secrets** — any secret pasted into a node or prompt instead of referenced from
  an external secret manager.
- **Model calls not routed through the AI gateway** — a provider API key embedded in a node
  instead of the governed gateway ([Part 7](../../wiki/part-7-agentic-workflow-platforms.md)).

## Gate rules

- Every workflow change is a pull request against version control — no hand-editing in the
  console straight against production.
- The AI review is advisory input to a **required human approval**, not a replacement for it
  (an LLM judge is promptable; see [Part 5](../../wiki/part-5-personal-always-on-assistants.md)).
- Nothing promotes to a critical system until both pass.
- Log the review verdict and the approver to the SIEM.
