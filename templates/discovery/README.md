# Discovery — inventory the agents before you defend them

`inventory-agents.sh` is a working example of the **discovery layer** from
[Part 1](../../wiki/part-1-risk-surface-and-control-model.md) and the **first of the five
controls** in [`../../start-here.md`](../../start-here.md): *you cannot govern what you
cannot see.* It lists the coding agents installed for one user on one machine and the MCP
tool servers they are wired to reach.

## What it finds

| Kind | What it means |
|------|---------------|
| `agent` | An agent CLI on `PATH`, a config directory that exists, or a coding-assistant editor extension |
| `mcp_server` | An MCP tool server declared in an agent config (`~/.claude.json`, `~/.cursor/mcp.json`, project `.mcp.json`, ...) with its command/URL target |
| `local_model` | A local inference server listening on a well-known port (bypasses the AI gateway — [Part 11](../../wiki/part-11-local-open-source-models.md)) |

Output is **JSON Lines** on stdout, one object per finding, so it rolls up. Requires `jq`
for MCP-config parsing (it degrades to a "config present" flag without it).

## Wire it in

- **Run it fleet-wide, per user**, via MDM / a login script, not once on your own laptop —
  the whole point is the gap between the agents you know about and the agents actually
  installed. Ship stdout to your SIEM / data lake and **dedupe by `(host,user,kind,name)`**.
- **Diff against your sanctioned allowlist** (start-here control #3). Anything installed
  that is not on the allowlist, and every `mcp_server` pointed at a community or remote
  endpoint outside your infra, is a finding to review.
- **Feed the results into the agent registry** (the Part 12 program layer): discovery is how
  the registry stays honest instead of becoming a stale spreadsheet.

## The honest limit

This is **endpoint- and user-scoped**, and read-only. It sees what is on disk for the user
who runs it. It will **not** see: agents another user installed on the same box, agentic
browsers and browser-extension assistants, business-user agents built inside low-code / SaaS
platforms ([Part 7](../../wiki/part-7-agentic-workflow-platforms.md)), or anything on a
machine you never ran it on. Discovery on the endpoint is necessary but not sufficient —
pair it with **network-egress detection** (see
[`../detections/local-inference-endpoint.yml`](../detections/local-inference-endpoint.yml)
and your gateway logs) so an agent you failed to enumerate on disk still shows up by the
traffic it makes.
