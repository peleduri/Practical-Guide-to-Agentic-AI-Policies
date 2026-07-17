# Identity examples

Copy-ready shapes for the agent-identity controls in
[Part 10](../../wiki/part-10-agent-identity.md). Examples — adapt to your IdP / cloud and test.

- **`jit-scoped-grant.json`** — the shape of a just-in-time, task-scoped, time-bound grant
  (the intent-based / IBAC model): the agent declares the task, gets exactly the access that
  task needs, and it auto-expires. This is a conceptual contract, not a specific vendor's API
  — map it onto your JIT-access platform.
- **`cross-account-role-trust.json`** — an AWS IAM role trust policy done right: a specific
  principal (no wildcard) and an `ExternalId` condition to defeat the confused-deputy problem.
  The delegation primitive from Part 10, at the cloud layer. Replace the account IDs, role name,
  and `ExternalId` (store the `ExternalId` as a secret, not in source), and cap session length
  separately via the role's `MaxSessionDuration` — the trust policy doesn't set it.
- **`credential-broker.md`** — the credential-boundary wiring: the agent points at a broker
  and holds **no** provider secrets; the broker keeps them behind its runtime boundary and
  returns only metadata, scoped actions, and results. Part 10's "kill secrets sprawl", made
  structural.
