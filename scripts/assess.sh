#!/usr/bin/env bash
# One-command local assessment. Runs the read-only discovery scan, summarizes it,
# and renders a STARTER posture scorecard — all locally, nothing changed, nothing
# sent, nothing committed. This is the "run it" front door: clone the repo and
#
#   bash scripts/assess.sh
#
# It is deliberately conservative. Discovery can only *measure* a couple of controls
# on its own (that an inventory exists, and whether a managed baseline is present).
# The rest default to "missing" until you confirm them — run the agentic-ai-hardening
# skill for the full assessment, which applies the assess rubric and asks about the
# controls that can't be measured from disk.
#
# PRIVACY: output goes to a LOCAL directory (default ./.agent-assessment, gitignored)
# and reflects THIS machine. Do not commit it. The scorecard itself is posture-only
# (safe to share); the inventory next to it is not.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
disc="$root/templates/discovery/inventory-agents.sh"
card="$root/skill/agentic-ai-hardening/scripts/scorecard.sh"
out="${AGENT_ASSESSMENT_OUT:-$PWD/.agent-assessment}"

command -v jq >/dev/null 2>&1 || { echo "assess.sh: jq is required (brew install jq / apt-get install jq)" >&2; exit 1; }
[ -f "$disc" ] || { echo "assess.sh: discovery script not found at $disc — run this from a clone of the repo" >&2; exit 1; }
[ -f "$card" ] || { echo "assess.sh: scorecard renderer not found at $card" >&2; exit 1; }

mkdir -p "$out"
inv="$out/inventory.jsonl"
posture="$out/posture.json"
html="$out/scorecard.html"

echo "Running read-only discovery — nothing is changed, nothing is sent…" >&2
bash "$disc" > "$inv" 2>/dev/null

echo "Inventory written to $inv. Found:" >&2
jq -r '.kind' "$inv" 2>/dev/null | sort | uniq -c | sort -rn | sed 's/^/  /' >&2 || true

# Only what discovery can determine on its own. The managed-baseline probe (Part 2)
# reports PRESENT / PARTIAL / MISSING in its detail string.
baseline_detail="$(jq -r 'select(.kind=="baseline") | .detail' "$inv" 2>/dev/null | head -1)"
case "$baseline_detail" in
  PRESENT*) bstat="present" ;;
  PARTIAL*) bstat="partial" ;;
  *)        bstat="missing" ;;
esac
[ "$bstat" = "present" ] && maturity="walk" || maturity="crawl"

jq -n --arg b "$bstat" --arg m "$maturity" --arg d "$(date +%F)" '{
  maturity: $m,
  date: $d,
  next_control: "Push a managed hardening baseline users cannot loosen (Part 2)",
  controls: [
    { label: "Discovery inventory (agents + MCP servers)", status: "present" },
    { label: "Managed hardening baseline (Part 2)",        status: $b },
    { label: "Sanctioned-agent allowlist",                 status: "missing" },
    { label: "MCP server allowlist",                       status: "missing" },
    { label: "SIEM streaming of agent logs",               status: "missing" },
    { label: "Headless permission gate",                   status: "missing" }
  ]
}' > "$posture"

bash "$card" "$posture" > "$html" 2>/dev/null

cat >&2 <<NOTE

Starter scorecard: $html
Starter posture:   $posture

This is a CONSERVATIVE starting point from what discovery can measure on its own.
The controls it cannot see from disk (allowlists, SIEM streaming, the headless gate)
default to "missing" until you confirm them. Run the agentic-ai-hardening skill for
the full assessment. Everything above stays in $out (local only) — do NOT commit it;
it reflects this machine. The scorecard is posture-only and safe to share.
NOTE
