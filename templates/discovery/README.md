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
| `skill` | An installed `SKILL.md` instruction pack (`~/.claude/skills`, `~/.codex/skills`, `~/.cursor/skills`) — the extension supply chain ([Part 6](../../wiki/part-6-extension-supply-chain.md)) |
| `command` | A custom slash command / prompt file (`~/.claude/commands`, `~/.codex/prompts`, `~/.cursor/commands`) |
| `subagent` | A delegated helper in `~/.claude/agents` — check its tool scope (least privilege) |
| `plugin` | An installed plugin bundle in `~/.claude/plugins` (can ship its own hooks/commands/MCP servers) |
| `hook` | A lifecycle trigger declared in settings, tagged **MANAGED** (admin-set) or **USER** (should be managed) |
| `baseline` | The Part 2 Claude Code hardening baseline: `MISSING` / `PARTIAL` / `PRESENT`, with which flags are set and whether the managed-settings file is root-owned (enforced) or user-writable |

Output is **JSON Lines** on stdout, one object per finding, so it rolls up. The
`skill` / `command` / `subagent` / `plugin` / `hook` kinds are the **agent extension supply
chain** ([Part 6](../../wiki/part-6-extension-supply-chain.md)) — the packs, commands, helpers,
plugins, and triggers loaded *into* the agents, which is where the risk hides. `local_model`
covers **[Part 11](../../wiki/part-11-local-open-source-models.md)** (runtime present, weights
on disk, live socket) and `baseline` is the deterministic **[Part 2](../../wiki/part-2-endpoint-hardening-and-policy-playbook.md)**
hardening-baseline probe. Requires `jq` for config, hook, and baseline parsing (it degrades to
a "config present" flag without it).

## Wire it in

- **Run it fleet-wide, per user**, via MDM / a login script, not once on your own laptop —
  the whole point is the gap between the agents you know about and the agents actually
  installed. Ship stdout to your SIEM / data lake and **dedupe by `(host,user,kind,name)`**.
- **Run it on remote / cloud dev environments too** ([Part 4](../../wiki/part-4-beyond-the-hyperscalers.md)):
  Coder workspaces, Codespaces, dev VMs, GPU-first neoclouds. Run it **where the agents live —
  inside the user's workspace**, because the agents, skills, MCP configs, and model weights sit
  in that workspace's home dir. Two mechanisms:
  - **Bake it into the workspace template's startup script** (simplest — Coder `startup_script`,
    a Codespaces lifecycle hook, or the image's login script), so every ephemeral box reports on
    start. `ssh box bash < inventory-agents.sh` works for a one-off.
  - **Or a sidecar container in the workspace pod** that shares the workspace filesystem — k8s-native,
    no base-image change.

  A standalone k8s **Deployment / DaemonSet is the wrong layer**: container isolation means it
  cannot see into other pods' home dirs (a DaemonSet sees the node, not the workspace). It only
  works if home is a shared PVC it mounts, or you want node-level signals. Ship stdout to your
  SIEM; the `host`+`user` in each line rolls a throwaway-workspace fleet up centrally, and for
  ephemeral boxes run it at **startup and on a schedule** to catch drift. It also fingerprints
  the personal always-on assistant class (OpenClaw / NanoClaw —
  [Part 5](../../wiki/part-5-personal-always-on-assistants.md)); extend the runtime and
  config-dir lists at the top of the script for anything else in your estate.
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
