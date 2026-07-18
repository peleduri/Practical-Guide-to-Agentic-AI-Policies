#!/usr/bin/env bash
# Headless permission gate — EXAMPLE. The control for Part 14 Failure Mode 5:
# when an agent drives a coding agent headlessly (acpx over ACP, a CI job, an
# orchestrator), the allow / ask / deny gate has no human to answer "ask". This
# hook makes "ask" collapse to DENY and enforces a deny-by-default tool allowlist,
# so a driven agent can only do the small, explicit set of things the flow needs.
#
# Register it as the PreToolUse / PermissionRequest hook for the DRIVEN agent
# (Claude Code / Codex). It is the headless sibling of ../hooks/pretooluse-guard.sh
# and inverts one rule on purpose:
#
#   ../hooks/pretooluse-guard.sh  fails OPEN  — a broken guard must never brick a human dev.
#   this gate                     fails CLOSED — there is no human here; the safe default is STOP.
#
# Contract (Claude Code PreToolUse): exit 2 = DENY (reason on stderr); exit 0 = ALLOW.
# There is deliberately no "ask" branch — headless has no one to ask.
set -uo pipefail

LOG="${HEADLESS_GATE_LOG:-$HOME/.agent-guardrails/headless.log}"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
# Attribute the DRIVER, not just the driven agent (Part 9). Set this in the flow.
DRIVER="${ACP_DRIVER_ID:-${AGENT_DRIVER:-unknown-driver}}"

input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)"
cmd="$(printf '%s'  "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
norm="$(printf '%s' "$cmd" | tr '\n\r' '  ')"

log()   { printf '%s\t%s\tdriver=%s\t%s\t%s\n' "$(date -u +%FT%TZ)" "$1" "$DRIVER" "${tool:-?}" "${2:-}" >>"$LOG" 2>/dev/null || true; }
deny()  { log DENY  "$1"; echo "DENIED (headless gate): $1" >&2; exit 2; }
allow() { log ALLOW "${1:-}"; exit 0; }

# 0. FAIL CLOSED. If we could not parse the tool call, deny — do not guess in an
#    unattended run. (The Part 2 hook allows here; this one must not.)
[ -n "$tool" ] || deny "unparseable tool call in headless mode (fail closed)"

# 1. A bypass flag on a DRIVEN agent is itself the finding, not a convenience.
case " ${CLAUDE_PERMISSION_MODE:-} ${CLAUDE_FLAGS:-} ${*:-} " in
  *dangerously-skip-permissions*|*bypassPermissions*|*" --yolo "*)
    deny "permission bypass set on a headless/driven agent — the gate was being disabled" ;;
esac

# 2. DENY-BY-DEFAULT ALLOWLIST. Only the small, explicit set the flow needs passes.
#    Widen these two lists DELIBERATELY, per flow — do not open them "to be safe".
ALLOWED_TOOLS="Read Grep Glob WebSearch"                 # read-only by default
ALLOWED_CMD_RE='^(git (status|diff|log|show)|ls|cat|rg|grep|pytest|npm (test|run test)|make test)( |$)'

case " $ALLOWED_TOOLS " in
  *" $tool "*) allow "allowlisted tool: $tool" ;;
esac

# Shell/command tools: only the command allowlist passes; everything else denies.
case "$tool" in
  Bash|Shell|Execute|run_command|run_terminal_cmd)
    # A deny-by-default gate can only vouch for a SINGLE SIMPLE command. The prefix
    # allowlist below cannot speak for whatever runs after a `;`, `&&`, `|`, `$(...)`,
    # a backtick, a redirect, or a newline — so reject any of those outright. (Checked
    # against the RAW command, so a smuggled second line can't slip past.) Need a
    # compound command? Widen the allowlist deliberately with the exact command.
    case "$cmd" in
      *';'*|*'&'*|*'|'*|*'`'*|*'$('*|*'>'*|*'<'*|*$'\n'*|*$'\r'*)
        deny "shell metacharacter in a headless command (compound/expansion is not allowlistable)" ;;
    esac
    if [ -n "$norm" ] && printf '%s' "$norm" | grep -Eq "$ALLOWED_CMD_RE"; then
      allow "allowlisted command"
    fi
    deny "command not on the headless allowlist: ${norm:0:80}"
    ;;
esac

# 3. Anything not explicitly allowed above is denied — "ask" has no human.
deny "tool not on the headless allowlist: $tool (ask collapses to deny)"
