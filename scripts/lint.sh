#!/usr/bin/env bash
# Wiki lint: the test suite for this LLM Wiki.
# Fails on (1) a broken relative markdown link and (2) an orphan part
# (a wiki/part-*.md not listed in index.md). Dependency-free; runs locally
# or in CI (.github/workflows/lint.yml). Run from anywhere:  bash scripts/lint.sh
set -uo pipefail
cd "$(dirname "$0")/.."   # repo root, regardless of caller's cwd

fail=0

# 1. Broken relative-link check across every markdown file.
#    process substitution (not a pipe) so `fail` survives in this shell.
while IFS= read -r -d '' md; do
  dir=$(dirname "$md")
  # Strip inline-code spans first (`...`) so a link written as a documentation
  # example inside backticks is not mistaken for a real, navigable link.
  targets=$(sed -E 's/`[^`]*`//g' "$md" 2>/dev/null \
    | grep -oE '\]\([^)]+\.md(#[^)]*)?\)' \
    | sed -E 's/^\]\(//; s/\)$//; s/#.*$//')
  for target in $targets; do
    case "$target" in
      http://*|https://*) continue ;;   # external links are not our job
    esac
    if [ ! -f "$dir/$target" ]; then
      echo "BROKEN LINK: $md -> $target"
      fail=1
    fi
  done
done < <(find . -name '*.md' -not -path './.git/*' -print0)

# 2. Orphan check: every part must be catalogued in index.md.
for part in wiki/part-*.md; do
  base=$(basename "$part")
  grep -q "$base" index.md || { echo "ORPHAN: $base is not listed in index.md"; fail=1; }
done

if [ "$fail" -ne 0 ]; then
  echo "FAIL: fix the issues above."
  exit 1
fi
echo "OK: all relative links resolve and every part is in index.md."
