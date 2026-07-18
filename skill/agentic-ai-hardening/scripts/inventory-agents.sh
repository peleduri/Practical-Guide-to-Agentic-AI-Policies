#!/usr/bin/env bash
# Agent, MCP-server, and extension-layer discovery — EXAMPLE. A de-identified version
# of the discovery layer from Part 1 and the first of the five controls in start-here.md
# ("Discover before you defend"). It inventories, for THIS user on THIS machine: the
# coding agents installed, the MCP tool servers they reach, listening local-model ports,
# and the agent extension supply chain (skills, commands, subagents, hooks, plugins —
# Part 6). It emits one JSON line per finding so a fleet can roll the results up centrally.
#
# It is READ-ONLY: it lists files and parses configs, it changes nothing. Run it
# per-user across the fleet (MDM / login script), not once on your own laptop — and
# INSIDE remote / cloud dev environments (Coder, Codespaces, dev VMs, GPU-first
# neoclouds — Part 4) by baking it into the workspace image so every ephemeral box
# reports on startup; the host+user in each line rolls the fleet up. The gap between
# the agents you know about and the agents actually installed is where shadow AI lives.
#
# Output: JSON Lines on stdout. One object per finding:
#   {"host":"...","user":"...","kind":"agent|mcp_server|local_model|skill|command|subagent|plugin|hook|baseline","name":"...","detail":"...","source":"<path>"}
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
           openclaw nanoclaw \
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
openclaw|.openclaw
nanoclaw|.nanoclaw
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

# --- 4. local & open-source models on the endpoint (Part 11) -----------------
# Local inference feels private and is therefore treated as safe; it is neither: it
# bypasses the AI gateway, the model file executes code on load (pickle/GGUF), and the
# local server is often an unauthenticated socket. Detect the runtime, the downloaded
# model files, and a live server — a runtime that is installed but not running now still
# counts, and the weights on disk are the supply-chain risk.

# 4a. local-model runtimes present (config/data dir) — installed even if not serving now.
while IFS='|' read -r rt dir; do
  [ -e "$HOME/$dir" ] && emit local_model "$rt" "local-model runtime present (bypasses the AI gateway)" "$HOME/$dir"
done <<'RT'
ollama|.ollama
lm-studio|.lmstudio
lm-studio|.cache/lm-studio
jan|.jan
gpt4all|.local/share/nomic.ai/GPT4All
llama.cpp|.cache/llama.cpp
RT

# 4b. downloaded model files — the model-file supply chain. A poisoned pickle/GGUF/
#     safetensors executes on load; count what is on disk per store.
for mdir in "$HOME/.ollama/models" "$HOME/.cache/huggingface/hub" \
            "$HOME/.lmstudio/models" "$HOME/.cache/lm-studio/models" "$HOME/.jan/models"; do
  [ -d "$mdir" ] || continue
  n=$(find "$mdir" -maxdepth 6 -type f \( -name '*.gguf' -o -name '*.safetensors' \
        -o -name '*.bin' -o -name '*.pt' -o -name '*.pth' -o -name '*.pkl' -o -name '*.ckpt' \) \
        2>/dev/null | head -2000 | wc -l | tr -d ' ')
  [ "${n:-0}" -gt 0 ] 2>/dev/null && \
    emit local_model "model-files" "$n downloaded model file(s) — execute code on load (Part 11 supply chain)" "$mdir"
done

# 4c. a LIVE local inference server — an unauthenticated socket the gateway never sees.
if command -v lsof >/dev/null 2>&1; then
  for port in 11434 1234 8080 5000; do   # ollama, LM Studio, common local servers
    lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1 && \
      emit local_model "port-$port" "local inference server LISTENING (unauthenticated socket)" "tcp/$port"
  done
fi

# --- 5. the extension supply chain (Part 6) ---------------------------------
# Inventory the packs, commands, delegated helpers, plugins, and triggers loaded INTO
# the agents above. "This is where the risk hides, and an unlisted trigger is the thing
# you least want to miss." Each is executable trust; enumerate it so it can be reviewed.

# Skills (instruction packs): a SKILL.md is code that runs when the skill activates.
for sdir in "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.cursor/skills"; do
  [ -d "$sdir" ] || continue
  while IFS= read -r f; do
    emit skill "$(basename "$(dirname "$f")")" "SKILL.md instruction pack" "$f"
  done < <(find "$sdir" -maxdepth 3 -name 'SKILL.md' -type f 2>/dev/null | head -200)
done

# Slash commands / prompt files: user-defined instructions invoked by name.
for cdir in "$HOME/.claude/commands" "$HOME/.codex/prompts" "$HOME/.cursor/commands"; do
  [ -d "$cdir" ] || continue
  while IFS= read -r f; do
    emit command "$(basename "$f" .md)" "custom command / prompt" "$f"
  done < <(find "$cdir" -maxdepth 2 -name '*.md' -type f 2>/dev/null | head -200)
done

# Subagents / delegated helpers: each can act with its own tool scope (least-privilege it).
if [ -d "$HOME/.claude/agents" ]; then
  while IFS= read -r f; do
    emit subagent "$(basename "$f" .md)" "delegated helper (check its tool scope)" "$f"
  done < <(find "$HOME/.claude/agents" -maxdepth 2 -name '*.md' -type f 2>/dev/null | head -200)
fi

# Plugins: bundles that can ship their own hooks, commands, and MCP servers.
if [ -d "$HOME/.claude/plugins" ]; then
  for d in "$HOME/.claude/plugins"/*/; do
    [ -d "$d" ] && emit plugin "$(basename "$d")" "installed plugin bundle" "$d"
  done
fi

# Hooks: lifecycle triggers that can execute or rewrite policy. Note MANAGED (admin-set)
# vs USER — only admin-managed hooks should load (Part 2 / Part 6).
hooks_from_json() { # file label
  local f="$1" label="$2"
  [ -f "$f" ] || return 0
  if [ "$HAVE_JQ" -eq 1 ]; then
    jq -r '(.hooks // {}) | keys[]?' "$f" 2>/dev/null | while IFS= read -r ev; do
      [ -n "$ev" ] && emit hook "$ev" "$label" "$f"
    done
  else
    grep -q '"hooks"' "$f" 2>/dev/null && emit hook "(unparsed)" "$label; install jq to enumerate" "$f"
  fi
}
hooks_from_json "$HOME/.claude/managed-settings.json" "MANAGED hook (admin-set)"
hooks_from_json "$HOME/.claude/settings.json"         "USER hook (should be managed)"
hooks_from_json "$HOME/.claude/settings.local.json"   "USER hook (local; should be managed)"

# --- 6. endpoint hardening baseline (Part 2) --------------------------------
# Control #2: is a managed hardening baseline applied that users cannot loosen? Probe
# the Claude Code managed-settings file — presence, ownership (a user-writable copy is
# NOT enforcement), and the key flags. Deterministic: same machine, same result.
ms="$HOME/.claude/managed-settings.json"
if [ ! -f "$ms" ]; then
  emit baseline "claude-code" "MISSING — no managed hardening baseline (Part 2)" "$ms"
elif [ "$HAVE_JQ" -eq 1 ]; then
  flags=""
  add_flag() { [ "$1" = "true" ] && flags="$flags $2=yes" || flags="$flags $2=NO"; }
  add_flag "$(jq -r '(.permissions.defaultMode=="plan")'                "$ms" 2>/dev/null)" plan-default
  add_flag "$(jq -r '(.permissions.disableBypassPermissionsMode=="disable")' "$ms" 2>/dev/null)" bypass-disabled
  add_flag "$(jq -r '(.disableAutoMode=="disable")'                     "$ms" 2>/dev/null)" auto-disabled
  add_flag "$(jq -r '(.sandbox.enabled==true)'                         "$ms" 2>/dev/null)" sandbox
  add_flag "$(jq -r '(.allowManagedHooksOnly==true)'                   "$ms" 2>/dev/null)" managed-hooks-only
  add_flag "$(jq -r '(.allowManagedPermissionRulesOnly==true)'         "$ms" 2>/dev/null)" managed-rules-only
  # a managed file the user can rewrite is not enforcement
  owner="$(stat -f '%Su' "$ms" 2>/dev/null || stat -c '%U' "$ms" 2>/dev/null || echo '?')"
  if [ "$owner" != "$USER_NAME" ] && [ ! -w "$ms" ]; then own="root-owned/enforced"; else own="USER-WRITABLE (not enforced)"; fi
  case "$flags $own" in
    *=NO*|*USER-WRITABLE*) status="PARTIAL" ;;
    *)                     status="PRESENT" ;;
  esac
  emit baseline "claude-code" "$status — $own;$flags" "$ms"
else
  emit baseline "claude-code" "present (install jq to check flags/ownership)" "$ms"
fi
