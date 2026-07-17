# Cursor baseline

Cursor has **no single pushed managed-settings file** like Claude Code's
`managed-settings.json` or Codex's `requirements.toml`. You harden it through the
**Team / org dashboard**, so this directory is guidance, not a droppable file. See
[Part 2](../../wiki/part-2-endpoint-hardening-and-policy-playbook.md) and
[Part 3](../../wiki/part-3-architecture-gateways-and-remote-defense.md).

Set, at the org level:

- **Run Modes** — default to a mode that keeps the human in the loop; disable the
  unattended/auto-run mode for the org (the Cursor equivalent of Claude Code's
  `disableAutoMode` / Codex excluding `danger-full-access`).
- **MCP allowlist** — allow only reviewed MCP servers; deny the rest. Prefer pointing
  MCP at the trusted gateway ([Part 3](../../wiki/part-3-architecture-gateways-and-remote-defense.md)).
- **Sandbox network modes** — restrict what the in-app sandbox can reach.
- **Egress** — Cursor has no workspace IP allowlist; allowlist Cursor's egress domains
  on the corporate firewall instead ([Part 3](../../wiki/part-3-architecture-gateways-and-remote-defense.md)).

There is no server-side hook equivalent to `pretooluse-guard.sh`; the endpoint layer for
Cursor is application control (which agents may install at all) plus the dashboard
settings above, with the durable controls server-side.
