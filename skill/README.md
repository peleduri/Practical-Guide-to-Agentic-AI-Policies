# The guide as a skill

`agentic-ai-hardening/` is the [Practical Guide to Securing AI Agents](../README.md)
packaged as a runnable **[Agent Skill](https://agentskills.io)** — the portable
`SKILL.md` standard that Claude Code, OpenAI Codex CLI, and Cursor all read natively
(one file, no per-tool rewrite). It turns the guide from *read it yourself* into
*point your coding agent at it and it hardens your setup*.

## What it does

The workflow is the guide's own controls, executed:

1. **Discover** (read-only) — the agents installed on this machine and the MCP servers
   they reach, via the **bundled** `agentic-ai-hardening/scripts/inventory-agents.sh` (a
   verbatim, lint-synced copy of [`templates/discovery/inventory-agents.sh`](../templates/discovery/README.md);
   bundled so the skill never fetches and executes a remote script at runtime).
2. **Assess** — score the posture against the *first five controls* and place the org on
   the crawl / walk / run maturity model from [`start-here.md`](../start-here.md).
3. **Report** — where you are, the ranked gaps, the single next control to implement, and
   a self-contained, screenshot-ready **scorecard** (`scripts/scorecard.sh`) that shows
   posture only — maturity + per-control status — and deliberately no machine inventory,
   so it is safe to share.
4. **Harden (opt-in)** — offer to install the matching copy-ready controls from
   [`templates/`](../templates/README.md), **showing the diff and asking before any write**.

The one script it **executes** (discovery) is bundled and reviewed at install time. The
**controls** it writes are fetched from the guide's canonical raw URLs — but only ever
written after a preview and your yes — so you get the maintained, tested version without
the skill running remote code.

## Safety model (the skill eats its own dog food)

- **Assess is read-only.** Discovery and scoring change nothing.
- **Harden is opt-in and previewed.** No file is written without showing its content and
  destination and getting an explicit "yes" for that specific control. One at a time.
- **Fails safe.** An ambiguous check is reported as a gap, never assumed covered.
- **Never disables a gate to pass.** It will not set a bypass flag or widen an allowlist
  "to be safe."

These are the same principles the guide preaches ([Part 2](../wiki/part-2-endpoint-hardening-and-policy-playbook.md),
[Part 14](../wiki/part-14-multi-agent-a2a.md)) — the tool that applies them has to follow them.

## Install

It is a standard `SKILL.md` skill: drop the `agentic-ai-hardening/` folder into your
agent's skills directory. Exact paths move fast — verify against your tool's current
docs — but as of writing:

- **Claude Code** — copy into `~/.claude/skills/agentic-ai-hardening/` (personal) or
  `.claude/skills/agentic-ai-hardening/` (project). Then ask it to "assess my agentic AI
  posture" or run `/agentic-ai-hardening`.
- **OpenAI Codex CLI** — place the folder in your Codex skills directory (e.g.
  `~/.codex/skills/`) and invoke it by name.
- **Cursor** — add it to your Cursor skills location and trigger it by description.

Quick copy from a clone of the guide repo:

```bash
# Claude Code, personal scope
cp -R skill/agentic-ai-hardening ~/.claude/skills/
```

## Scope and honest limits

It hardens the machine it runs on. It does not deploy org infrastructure (it writes the
control file; you deliver it the durable way — MDM root-owned config, a registered
managed hook, a compiled SIEM detection), it cannot see agents on other machines or in
SaaS builders (run it per machine, pair with egress detection), and it is a hardening
assistant, not a compliance attestation ([Part 12](../wiki/part-12-governance-compliance.md)
owns the framework crosswalk). The [`SKILL.md`](agentic-ai-hardening/SKILL.md) states the
remaining manual step for every control.
