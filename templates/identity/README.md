# Identity examples

Copy-ready shapes for the agent-identity controls in
[Part 10](../../wiki/part-10-agent-identity.md). Examples — adapt to your IdP / cloud and test.

- **`jit-scoped-grant.json`** — the shape of a just-in-time, task-scoped, time-bound grant
  (the intent-based / IBAC model): the agent declares the task, gets exactly the access that
  task needs, and it auto-expires. This is a conceptual contract, not a specific vendor's API
  — map it onto your JIT-access platform.
- **`cross-account-role-trust.json`** — an AWS IAM role trust policy done right: a specific
  principal (no wildcard), an `ExternalId` condition to defeat the confused-deputy problem,
  and short session duration. The delegation primitive from Part 10, at the cloud layer.
