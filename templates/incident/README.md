# Incident — the agent kill switch

`agent-kill-switch.sh` is a working example of the **fail-safe kill switch** from
[Part 9](../../wiki/part-9-detection-monitoring-ir.md) and the **fifth of the five controls**
in [`../../start-here.md`](../../start-here.md). Prevention fails eventually; when an agent
goes wrong you have to stop it in minutes, on the endpoint, without building the tooling
under pressure. Pre-build and rehearse it cold.

## What it does (in order)

| Step | Action | Reversible? |
|------|--------|-------------|
| 1 | **Snapshot** agent logs/history/config to a read-only evidence dir — *first, always* | n/a (copy) |
| 2 | **Kill** local agent processes and their MCP-server children | no |
| 3 | **Freeze** agent configs (rename to `.halted-<ts>`) so nothing relaunches cleanly | yes (rename back) |
| 4 | **Cut egress** via your isolation control (EDR / firewall) — *you wire this* | depends |
| 5 | **Revoke** — prints the durable server-side checklist to run next | n/a (checklist) |

It **errs toward stopping** (fail-safe), with one hard rule: it preserves evidence before
it kills anything and never wipes agent history — forensics needs the causal chain
([Part 9](../../wiki/part-9-detection-monitoring-ir.md)).

## Wire it in

- **It only acts with `--yes`.** Without the flag it prints the plan and changes nothing —
  so you can read and test it safely. Killing running agent work is destructive by design.
- **Step 4 is a stub on purpose.** A local process kill does not stop a cloud/remote agent
  or an open connection. Replace `cut_egress()` with your real control: EDR host isolation,
  a deny-all firewall rule, VPN-session revocation.
- **Rehearse it.** A kill switch you have never run is a hope, not a control. Test the dry
  run, then test `--yes` against a throwaway agent, and time it.

## The honest limit

The local steps buy **minutes**. They do not stop an agent running in the cloud, and they do
not un-leak a secret that already left. The **durable kill is server-side** and org-specific:
revoke the agent's non-human identity, rotate every credential it could reach (not just the
one it used), and disable its OAuth grant / token ([Part 10](../../wiki/part-10-agent-identity.md)).
The script cannot do that for you, so step 5 hands you the checklist to run immediately — and
tells you to keep, not delete, the evidence directory.
