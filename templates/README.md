# Templates — copy-ready controls

Lift-and-adapt files for the controls the guide describes in prose. Each maps to the
part that explains the *why*; this tree is the *how*.

> **These are examples. Adapt and test before you deploy.** Field names, paths, enum
> values, thresholds, account IDs, and policy language are placeholders. A control you
> pasted without reading and tuning is a liability, not a safeguard. Verify every
> vendor-specific setting against the current vendor docs (agent surfaces move fast).

## What's here

| Path | What it is | Part |
|------|-----------|------|
| `claude-code/managed-settings.json` | Claude Code hardening baseline (plan mode, no bypass, sandbox, managed hooks/rules only) | [2](../wiki/part-2-endpoint-hardening-and-policy-playbook.md) |
| `codex/requirements.toml` | Codex equivalent baseline (delivered via MDM) | [2](../wiki/part-2-endpoint-hardening-and-policy-playbook.md) |
| `cursor/README.md` | Cursor dashboard settings (no single pushed file) | [2](../wiki/part-2-endpoint-hardening-and-policy-playbook.md) |
| `hooks/pretooluse-guard.sh` | A working, de-identified PreToolUse enforcement hook | [2](../wiki/part-2-endpoint-hardening-and-policy-playbook.md) |
| `detections/*.yml` + `*.spl` | Agent behavioral-IOC detections as Sigma + a Splunk example | [9](../wiki/part-9-detection-monitoring-ir.md), [11](../wiki/part-11-local-open-source-models.md) |
| `identity/jit-scoped-grant.json` | Just-in-time, task-scoped grant shape (IBAC) | [10](../wiki/part-10-agent-identity.md) |
| `identity/cross-account-role-trust.json` | AWS role trust done right (specific principal + ExternalId) | [10](../wiki/part-10-agent-identity.md) |
| `identity/credential-broker.md` | The credential boundary: agent holds no provider secrets, a broker does | [10](../wiki/part-10-agent-identity.md) |
| `workflows/ai-security-review-gate.md` | The pre-publish review-gate checklist for agentic workflows | [7](../wiki/part-7-agentic-workflow-platforms.md) |

## How to use it

- **Config baselines** — deliver via MDM / root-owned config so users can't loosen them
  (Part 2). Keep the file owned by root, not user-writable.
- **The hook** — register as a managed `PreToolUse` hook; see `hooks/README.md` for the
  contract and the honest limits.
- **Detections** — compile the Sigma `.yml` to your SIEM (`sigma convert -t splunk ...`);
  the `.spl` files show the intended logic. Map field names to your telemetry and tune
  thresholds before enabling. See `detections/README.md`.
- **Identity** — map the JSON shapes onto your IdP / cloud; the ExternalId and any secrets
  are placeholders to replace, never commit real ones.

New here? Start at [`../start-here.md`](../start-here.md). Everything in this tree is under
the licenses in [`../LICENSE-CODE`](../LICENSE-CODE) (code) and [`../LICENSE`](../LICENSE) (docs).
