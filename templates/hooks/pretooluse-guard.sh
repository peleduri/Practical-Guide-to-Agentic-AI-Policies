#!/usr/bin/env bash
# PreToolUse guard — EXAMPLE. A de-identified version of the hook described in Part 2.
# It sits in front of a coding agent (built for Claude Code; the same shape ports to
# Cursor) and gates tool calls before they run. Adapt the patterns to your org and
# TEST before deploying. This is layer 1 (fast, in-context, endpoint) — the durable
# enforcement is server-side (branch protection, rulesets, SIEM alerts).
#
# Contract (Claude Code PreToolUse):
#   exit 2                                  -> BLOCK the tool call (reason shown to user)
#   exit 0 + {"hookSpecificOutput":{...}}   -> ASK the user to confirm
#   exit 0 + no output                      -> ALLOW, fast
#
# Design notes carried over from Part 2:
#   - Fail OPEN: if input can't be parsed or a dependency is missing, allow + log,
#     so a broken guardrail never bricks the developer. Hard enforcement is server-side.
#   - Normalize the command (strip newlines) before matching, or a multi-line command
#     slips past single-line patterns.
#   - Prefer ASK over BLOCK for prod-affecting actions; reserve BLOCK for the truly
#     unrecoverable. Blocking everything trains people to route around you.
set -uo pipefail

LOG="${AGENT_GUARDRAIL_LOG:-$HOME/.agent-guardrails/events.log}"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

# --- read hook input (JSON on stdin); fail open if we can't parse it ---
input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
# normalize: collapse newlines/CR so multi-line commands can't evade single-line rules
norm="$(printf '%s' "$cmd" | tr '\n\r' '  ')"

log() { printf '%s\t%s\t%s\t%s\n' "$(date -u +%FT%TZ)" "$1" "${tool:-?}" "${2:-}" >>"$LOG" 2>/dev/null || true; }
ask() { log ASK "$1"; printf '{"hookSpecificOutput":{"permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$1"; exit 0; }
block() { log BLOCK "$1"; echo "BLOCKED by guard: $1" >&2; exit 2; }
# allow() takes an optional reason for symmetry with ask()/block(); the default
# path calls it bare, so silence SC2120 (older shellcheck flags the unused arg).
# shellcheck disable=SC2120
allow() { log ALLOW "${1:-}"; exit 0; }

# --- 1. HARD BLOCK: destructive, unrecoverable commands ---
case "$norm" in
  *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf \$HOME"*)              block "recursive delete of / or \$HOME" ;;  # "rm -rf /" already covers "rm -rf /*"
  *"dd if="*"of=/dev/"*)                                     block "raw disk write (dd to device)" ;;
  *mkfs*)                                                    block "filesystem format (mkfs)" ;;
  *":(){ :|:& };:"*)                                         block "fork bomb" ;;
  *"git push"*"--force"*|*"git push"*"-f "*)
    case "$norm" in
      *" main"*|*" master"*|*" release"*|*" production"*|*origin*) block "force-push to a protected branch" ;;
    esac ;;
esac

# --- 2. ASK: prod-affecting / admin mutations (example: GitHub Enterprise admin) ---
case "$norm" in
  *"gh api"*-X*POST*|*"gh api"*-X*PUT*|*"gh api"*-X*PATCH*|*"gh api"*-X*DELETE*)
    case "$norm" in
      */orgs/*|*/enterprises/*|*rulesets*|*/actions/*|*/environments/*|*/secrets/*|*/hooks/*)
        ask "gh api mutation against org/enterprise/admin surface" ;;
    esac ;;
  *"gh api graphql"*setEnterprise*|*updateRule*|*deleteRule*|*transferRepository*|*archiveRepository*|*removeCollaborator*)
    ask "gh graphql mutation that changes enterprise posture" ;;
esac

# --- 3. ASK: reads/writes of sensitive paths ---
for target in "$path" "$norm"; do
  case "$target" in
    *".env"*|*"/.aws/"*|*"/.ssh/"*|*".pem"*|*".key"*|*"credentials"*)
      ask "access to credential material" ;;
    *".github/workflows/"*|*"CODEOWNERS"*|*"/.claude/"*|*"/.cursor/"*|*"CLAUDE.md"*)
      ask "write to agent-config or CI-policy path" ;;
  esac
done

# --- default: allow ---
allow
