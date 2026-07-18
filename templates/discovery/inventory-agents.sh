#!/usr/bin/env bash
# Agent + MCP-server discovery — EXAMPLE. A de-identified version of the discovery
# layer from Part 1 and the first of the five controls in start-here.md
# ("Discover before you defend"). It inventories the coding agents installed for
# THIS user on THIS machine and the MCP tool servers they are wired to reach, and
# emits one JSON line per finding so a fleet can roll the results up centrally.
#
# It is READ-ONLY: it lists files and parses configs, it changes nothing. Run it
# per-user across the fleet (MDM / login script), not once on your own laptop —
# the gap between the agents you know about and the agents that are actually
# installed is exactly where shadow AI lives.
#
# Output: JSON Lines on stdout. One object per finding:
#   {"host":"...","user":"...","kind":"agent|mcp_server|local_model","name":"...","detail":"...","source":"<path>"}
# Pipe to your SIEM / data lake and dedupe by (host,user,kind,name).
#
# Requires: bash, and `jq` for the MCP-config parsing (degrades gracefully without it).
set -uo pipefail

HOST="$(hostname 2>/dev/null || echo unknown)"
USER_NAME="${USER:-$(id -un 2>/dev/null || echo unknown)}"
HAVE_JQ=0; command -v jq >/dev/null 2>&1 && HAVE_JQ=1

emit() { # kind name detail source
  printf '{"host":"%s","user":"%s","kind":"%s","name":"%s","detail":"%s","source":"%s"}\n' \
    "$HOST" "$USER_NAME" "$1" "$2" "${3//\"/\'}" "$4"
}

# --- 1. installed agent CLIs / runtimes on PATH -----------------------------
# Extend this list; treat anything here that is NOT on your sanctioned allowlist
# (start-here.md control #3) as a finding to review.
for bin in claude cursor cursor-agent codex opencode aider goose cline \
           ollama lms lm-studio jan gpt4all; do
  p="$(command -v "$bin" 2>/dev/null || true)"
  [ -n "$p" ] && emit agent "$bin" "on PATH" "$p"
done

# --- 2. agent config directories (presence = the agent has been run here) ----
while IFS='|' read -r label path; do
  [ -e "$HOME/$path" ] && emit agent "$label" "config present" "$HOME/$path"
done <<'CFG'
claude-code|.claude
claude-code|.claude.json
codex|.codex
cursor|.cursor
opencode|.opencode
aider|.aider.conf.yml
CFG

# VS Code extensions dir — coding-assistant extensions (Cline, Continue, Copilot, ...)
for extdir in "$HOME/.vscode/extensions" "$HOME/.vscode-server/extensions" \
              "$HOME/.cursor/extensions"; do
  [ -d "$extdir" ] || continue
  # shellcheck disable=SC2044
  for d in "$extdir"/*/; do
    b="$(basename "$d")"
    case "$b" in
      *cline*|*continue*|*copilot*|*roo-*|*aider*|*sourcegraph*|*codeium*)
        emit agent "vscode-ext:${b%-*}" "editor extension" "$d" ;;
    esac
  done
done

# --- 3. MCP tool servers the agents are wired to reach -----------------------
# The high-value part: which external tool servers can these agents call? Parse
# the mcpServers map from every config we know how to read. An MCP server pointed
# at a community/remote endpoint outside your infra is a finding.
mcp_from_json() { # file
  local f="$1"
  [ -f "$f" ] || return 0
  if [ "$HAVE_JQ" -eq 1 ]; then
    jq -r '(.mcpServers // {}) | to_entries[]
           | .key + "\t" + ((.value.command // .value.url // "?") | tostring)' \
       "$f" 2>/dev/null | while IFS=$'\t' read -r name target; do
        [ -n "$name" ] && emit mcp_server "$name" "target=$target" "$f"
      done
  else
    # no jq: at least flag that the file declares MCP servers
    grep -q '"mcpServers"' "$f" 2>/dev/null && \
      emit mcp_server "(unparsed)" "mcpServers present; install jq to enumerate" "$f"
  fi
}
mcp_from_json "$HOME/.claude.json"
mcp_from_json "$HOME/.cursor/mcp.json"
mcp_from_json "$HOME/.codex/config.json"
# project-local MCP definitions under the user's code roots (bounded depth)
for root in "$HOME"/{src,code,work,repos,projects,dev}; do
  [ -d "$root" ] || continue
  while IFS= read -r f; do mcp_from_json "$f"; done < <(
    find "$root" -maxdepth 4 -name '.mcp.json' -type f 2>/dev/null | head -100)
done

# --- 4. local inference endpoints (bypass the AI gateway — Part 11) ----------
# A listening local model server is an agent egress path your gateway never sees.
if command -v lsof >/dev/null 2>&1; then
  for port in 11434 1234 8080 5000; do   # ollama, LM Studio, common local servers
    lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1 && \
      emit local_model "port-$port" "local inference server LISTENING" "tcp/$port"
  done
fi
