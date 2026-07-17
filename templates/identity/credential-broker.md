# Credential broker (the credential boundary)

Wiring sketch for the credential-boundary pattern in
[Part 10](../../wiki/part-10-agent-identity.md): the agent authenticates to a broker and
**never holds a downstream provider secret**. The broker keeps the provider keys / OAuth
tokens behind its runtime boundary and returns only metadata, safe account labels, and
results. A compromised or prompt-injected agent can't exfiltrate a credential it was
never given. Example — an EXAMPLE to adapt and test.

## The rule

- **No provider secrets in the agent's config.** The agent config contains exactly one
  endpoint: the broker. No `OPENAI_API_KEY`, `GITHUB_TOKEN`, Slack token, etc.
- **Point the agent's MCP at the broker**, not at each provider's own MCP/server.
- **Per-connection identity, scopes, and action policies** live in the broker, not the
  agent — so you can scope and revoke per connection without touching the agent.
- **Every call is logged** at the broker (the [Part 9](../../wiki/part-9-detection-monitoring-ir.md) audit trail).

## Agent MCP config — points at the broker only

```json
{
  "mcpServers": {
    "actions": {
      "type": "http",
      "url": "http://127.0.0.1:3000/mcp",
      "_comment": "The broker. It holds provider secrets; this agent config holds none. Bind to loopback (or an internal address behind auth), never 0.0.0.0 — see Part 11."
    }
  }
}
```

## What NOT to do (the anti-pattern this replaces)

```json
{
  "mcpServers": {
    "github":  { "env": { "GITHUB_TOKEN": "ghp_REAL_TOKEN_ON_DISK" } },
    "slack":   { "env": { "SLACK_TOKEN":  "xoxb-REAL_TOKEN_ON_DISK" } }
  }
}
```

Here the raw tokens sit in the agent's reach — exactly the secret the Part 1 attack path
reads and exfiltrates. The broker removes them from the agent side entirely.

## Checklist

- [ ] Agent config references the broker endpoint and **no** provider secrets.
- [ ] Broker runs behind auth; its port is loopback or internal, never `0.0.0.0`.
- [ ] Each connection is scoped to the minimum actions the agent needs.
- [ ] Broker run logs stream to the SIEM.
- [ ] Connections are revocable per-agent / per-connection.

An open-source implementation of this pattern is OpenConnector
(https://github.com/oomol-lab/open-connector); the concept is what matters, not the
specific tool — verify any broker's isolation and logging before you trust it.
