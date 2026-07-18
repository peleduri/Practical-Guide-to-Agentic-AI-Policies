# Headless permission gate

`permission-gate.sh` is the control for **[Part 14](../../wiki/part-14-multi-agent-a2a.md), Failure Mode 5**:
when an agent drives a coding agent headlessly — acpx over ACP, a CI job, an orchestrator —
the `allow / ask / deny` gate has no human to answer "ask." This hook makes **"ask" collapse
to deny** and enforces a **deny-by-default tool allowlist**, so a driven agent can only do the
small, explicit set of things the flow actually needs.

## Contract (Claude Code PreToolUse / PermissionRequest)

| Result | Meaning |
|--------|---------|
| `exit 2` | **Deny** the tool call; stderr is logged with the driver identity |
| `exit 0` | **Allow** — only for an allowlisted tool or command |

There is deliberately **no "ask" branch** — headless has no one to ask. Register it as the
`PreToolUse` (or `PermissionRequest`) hook for the *driven* agent; in the SDK it maps to the
`canUseTool` handler. Requires `jq`.

## It fails CLOSED — on purpose

This inverts the one rule from [`../hooks/pretooluse-guard.sh`](../hooks/pretooluse-guard.sh):

| Hook | On parse error / uncertainty | Why |
|------|------------------------------|-----|
| `../hooks/pretooluse-guard.sh` | **fail OPEN** (allow + log) | a broken guard must never brick a working human developer |
| `permission-gate.sh` (this) | **fail CLOSED** (deny) | there is no human here; the safe default is STOP |

## Wire it in

- **Register it for the driven agent**, and set `ACP_DRIVER_ID` (or `AGENT_DRIVER`) in the
  flow so every decision is attributed to the *driver*, not just the coding agent ([Part 9](../../wiki/part-9-detection-monitoring-ir.md)).
- **Never pair it with a bypass.** If `--dangerously-skip-permissions` / `bypassPermissions`
  is set, the auto-approved tool never reaches a hook at all — so this gate also treats a
  bypass flag it *can* see as a finding and denies. The real fix is to not set the flag.
- **Widen the two allowlists deliberately.** `ALLOWED_TOOLS` (read-only by default) and
  `ALLOWED_CMD_RE` (a conservative command prefix set) are the whole policy. Open them per
  flow, for the specific tools that flow needs — not "to be safe."
- **One command per call.** The gate allows only a *single simple command* — any `;`, `&&`,
  `|`, `$(...)`, backtick, redirect, or newline is denied, because a prefix allowlist cannot
  vouch for what runs after them (`git status && rm -rf ~` would otherwise pass on the
  `git status` prefix). Widen the allowlist with exact commands, never compound ones.

## The honest limit

This gates the driven agent's tool calls on one endpoint. It does **not**, by itself: stop a
malicious *argument* to an allowlisted tool, govern *which* driver may drive *which* agent, or
revoke the identity the driven agent holds. Pair it with the rest of the guide — the driven
agent under its own scoped non-human identity ([Part 10](../../wiki/part-10-agent-identity.md)),
the driver→agent edge brokered and allow-listed ([Part 3](../../wiki/part-3-architecture-gateways-and-remote-defense.md)),
and driver-attributed session logging streamed to the SIEM ([Part 9](../../wiki/part-9-detection-monitoring-ir.md)).
The gate is the checkpoint that went missing when the human left the console; it is not the
whole defense.
