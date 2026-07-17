# PreToolUse hook

`pretooluse-guard.sh` is a working example of the endpoint enforcement hook from
[Part 2](../../wiki/part-2-endpoint-hardening-and-policy-playbook.md). It runs before every
agent tool call and returns allow / ask / block.

## Contract (Claude Code PreToolUse)

| Result | Meaning |
|--------|---------|
| `exit 2` | **Block** the tool call; stderr is shown to the user |
| `exit 0` + `{"hookSpecificOutput":{"permissionDecision":"ask",...}}` | **Ask** the user to confirm |
| `exit 0`, no output | **Allow**, fast |

The hook reads the tool call as JSON on stdin (`tool_name`, `tool_input.command`, `tool_input.file_path`).

## Wire it in

Deliver it as a **managed** hook so a user or a bundled plugin cannot replace it — set
`allowManagedHooksOnly: true` in [`../claude-code/managed-settings.json`](../claude-code/managed-settings.json)
and register this script as the `PreToolUse` hook. Make the file root-owned and not
user-writable. Requires `jq`.

## Design rules (from Part 2)

- **Fail open.** If input can't be parsed or `jq` is missing, allow and log — a broken
  guardrail must never brick the developer. Hard enforcement lives server-side.
- **Normalize before matching.** Collapse newlines/CR before running patterns, or a
  multi-line command evades single-line rules.
- **Prefer ask over block** for prod-affecting actions; reserve block for the
  genuinely unrecoverable.

## The honest limit

This is **layer 1** — the developer's endpoint, and only this agent. It cannot see UI
clicks in a browser admin console, subprocesses fired inside a wrapper that was already
allowed, a second machine with no hook, or direct `curl`/PAT use outside the agent. The
durable layers are server-side: branch protection / rulesets, tightened PAT/OAuth policy,
and SIEM alerts on the sensitive mutations. Wire both.
