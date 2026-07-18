#!/usr/bin/env bash
# Agent kill switch — EXAMPLE. A de-identified version of the fail-safe kill switch
# from Part 9 and the fifth of the five controls in start-here.md. Prevention fails
# eventually; when an agent goes wrong you need to STOP it in minutes, on the endpoint,
# without waiting to build the tooling under pressure. Pre-build and test this cold.
#
# It errs toward STOPPING (fail-safe), with one hard rule: it PRESERVES evidence first
# and never wipes agent logs/history — forensics (Part 9) needs the causal chain intact.
#
# Order of operations (each step is best-effort and logged; a failure does not abort
# the rest):
#   1. SNAPSHOT   copy agent logs/history/config to a read-only evidence dir  (do this first)
#   2. KILL       terminate local agent processes and their MCP server children
#   3. FREEZE     rename agent configs so nothing relaunches cleanly           (reversible)
#   4. CUT EGRESS call your isolation control (EDR / firewall) — wired by you
#   5. REVOKE     print the durable, server-side checklist you must run next
#
# Safety: destructive to running agent work, so it will only ACT with --yes.
# Without it, it prints the plan (dry run) and changes nothing.
set -uo pipefail

CONFIRM=0; [ "${1:-}" = "--yes" ] && CONFIRM=1
TS="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="${AGENT_KILL_EVIDENCE_DIR:-$HOME/.agent-incident/$TS}"
act() { if [ "$CONFIRM" -eq 1 ]; then eval "$1"; else echo "  [dry-run] $1"; fi; }
say() { printf '[kill-switch %s] %s\n' "$TS" "$1"; }

[ "$CONFIRM" -eq 1 ] || say "DRY RUN — re-run with --yes to act. Nothing will change."

# --- 1. SNAPSHOT evidence FIRST (never skip, never wipe) --------------------
say "1/5 snapshot evidence -> $EVID"
act "mkdir -p '$EVID'"
for src in "$HOME/.claude" "$HOME/.claude.json" "$HOME/.codex" "$HOME/.cursor" \
           "$HOME/.agent-guardrails/events.log"; do
  [ -e "$src" ] && act "cp -a '$src' '$EVID/' 2>/dev/null || true"
done

# --- 2. KILL local agent + MCP-server processes -----------------------------
say "2/5 terminate agent processes"
for pat in 'claude' 'cursor-agent' 'codex' 'opencode' 'aider' \
           'mcp-server' 'modelcontextprotocol' 'ollama'; do
  act "pkill -TERM -f '$pat' 2>/dev/null || true"
done
act "sleep 2"
for pat in 'claude' 'cursor-agent' 'codex' 'mcp-server' 'ollama'; do
  act "pkill -KILL -f '$pat' 2>/dev/null || true"   # SIGKILL the stragglers
done

# --- 3. FREEZE config so nothing auto-relaunches (reversible) ---------------
say "3/5 freeze agent configs (rename -> .halted-$TS; reverse by renaming back)"
for cfg in "$HOME/.claude.json" "$HOME/.cursor/mcp.json" "$HOME/.codex/config.json"; do
  [ -e "$cfg" ] && act "mv '$cfg' '$cfg.halted-$TS'"
done

# --- 4. CUT EGRESS — wire this to YOUR isolation control --------------------
# The local process kill does not stop a cloud/remote agent or an already-open
# connection. Replace the body with your real control: EDR host isolation, a
# deny-all firewall rule, pulling the machine's cert, revoking the VPN session.
cut_egress() {
  say "4/5 cut egress — STUB. Wire your EDR/firewall isolation here."
  # act "crowdstrike-isolate --host $(hostname)"        # example
  # act "sudo pfctl -e -f /etc/agent-isolate.pf.conf"   # example (macOS)
  return 0
}
cut_egress

# --- 5. REVOKE — the DURABLE kill is server-side (print the checklist) -------
# Killing local processes buys minutes. The agent's real power is the identity and
# credentials it holds; those must be revoked where they live (Part 10). This script
# cannot do that for you — it is org-specific — so it hands you the list to run now.
cat <<'NEXT'

5/5 DURABLE KILL — run these NOW (server-side; the local steps only bought minutes):
    [ ] Revoke the agent's non-human identity / service account at the IdP
    [ ] Rotate every credential the agent could reach (not just the one it used)
    [ ] Disable the agent's OAuth grant / API token / session
    [ ] Revoke short-lived cloud role sessions the agent assumed
    [ ] Confirm SIEM captured the session; do NOT delete the evidence dir above
    [ ] Open the incident and hand the evidence dir to forensics (Part 9)
NEXT
say "done. evidence: $EVID"
