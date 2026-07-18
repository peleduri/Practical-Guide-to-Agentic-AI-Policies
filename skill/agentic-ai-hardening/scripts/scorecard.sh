#!/usr/bin/env bash
# Posture scorecard — renders a self-contained, screenshot-ready HTML card from a
# posture JSON. Part of the agentic-ai-hardening skill (Report step). Deterministic:
# it renders exactly what the JSON says, no model discretion, so the same posture
# always produces the same card (a score that flaps is worthless, and a CI gate that
# flaps gets disabled).
#
# PRIVACY: this renders POSTURE ONLY — the maturity level, the per-control status,
# and the next control. It deliberately reads NO other fields, so the discovery
# inventory (agent names, MCP server URLs, hostnames, file paths, org identifiers)
# can never leak into a card you screenshot and post. Posture is shareable; the
# machine inventory that produced it is not. Do not add inventory fields here.
#
# Usage:
#   scorecard.sh posture.json > scorecard.html      # from a file
#   ... | scorecard.sh > scorecard.html             # from stdin
#
# Input schema (extra fields are ignored on purpose):
#   {
#     "maturity": "crawl" | "walk" | "run",
#     "controls": [ { "label": "Discovery inventory", "status": "present|partial|missing" }, ... ],
#     "next_control": "Push a managed baseline users can't loosen",
#     "date": "YYYY-MM-DD"
#   }
set -uo pipefail
command -v jq >/dev/null 2>&1 || { echo "scorecard.sh: jq is required" >&2; exit 1; }

src="${1:-/dev/stdin}"
json="$(cat "$src" 2>/dev/null)"
[ -n "$json" ] || { echo "scorecard.sh: empty posture JSON" >&2; exit 1; }

maturity="$(printf '%s' "$json" | jq -r '.maturity // "crawl"' | tr '[:upper:]' '[:lower:]')"
case "$maturity" in crawl|walk|run) ;; *) echo "scorecard.sh: maturity must be crawl|walk|run" >&2; exit 1 ;; esac
next="$(printf '%s' "$json" | jq -r '.next_control // "—"')"
date="$(printf '%s' "$json" | jq -r '.date // "—"')"
has_att="$(printf '%s' "$json" | jq -r 'any(.controls[]?; .attested == true) // false')"

case "$maturity" in
  crawl) mcol="#cc0000"; mlabel="CRAWL"; mpos="0"; mshield="red" ;;
  walk)  mcol="#b8860b"; mlabel="WALK";  mpos="1"; mshield="yellow" ;;
  run)   mcol="#228b22"; mlabel="RUN";   mpos="2"; mshield="brightgreen" ;;
esac

# Shareable maturity badge (the copy-back loop). Text-only in the card so it stays
# self-contained and offline; the shields.io image only loads when someone pastes
# this into their own README — which is the point, that README then links back here.
repo_url="https://github.com/peleduri/Practical-Guide-to-Securing-AI-Agents"
badge_img="https://img.shields.io/badge/agent%20security-${maturity}-${mshield}"
badge_md="[![agent security: ${maturity}](${badge_img})](${repo_url})"

# HTML-escape helper for label/next text (defense against odd characters in labels).
esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

rows=""
while IFS=$'\t' read -r label status attested; do
  [ -n "$label" ] || continue
  case "$status" in
    present) dot="#228b22"; word="present" ;;
    partial) dot="#b8860b"; word="partial" ;;
    *)       dot="#cc0000"; word="missing" ;;
  esac
  att=""; [ "$attested" = "true" ] && att="<span class=\"att\">self-reported</span>"
  rows="$rows<li><span class=\"dot\" style=\"background:$dot\"></span><span class=\"lbl\">$(esc "$label")$att</span><span class=\"st\" style=\"color:$dot\">$word</span></li>"
done < <(printf '%s' "$json" | jq -r '.controls[]? | [(.label // ""), (.status // "missing"), (.attested // false)] | @tsv')

cat <<HTML
<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agentic-AI Security Posture</title>
<style>
  :root{--ink:#14161a;--sub:#55606f;--rule:#e6e8e4;--card:#fff;--ground:#f4f5f3;--mono:ui-monospace,"SF Mono",Menlo,Consolas,monospace;--sans:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
  *{box-sizing:border-box}body{margin:0;background:var(--ground);font-family:var(--sans);color:var(--ink);-webkit-font-smoothing:antialiased}
  .card{max-width:36rem;margin:2rem auto;background:var(--card);border:1px solid var(--rule);border-radius:14px;padding:1.6rem 1.7rem;box-shadow:0 10px 30px -18px rgba(20,22,26,.35)}
  .eyebrow{font-family:var(--mono);font-size:.68rem;letter-spacing:.18em;text-transform:uppercase;color:var(--sub);font-weight:600}
  h1{font-size:1.28rem;margin:.25rem 0 1rem;letter-spacing:-.01em}
  .badge{display:inline-block;font-family:var(--mono);font-weight:700;font-size:1.1rem;letter-spacing:.08em;color:#fff;background:$mcol;padding:.35rem .8rem;border-radius:8px}
  .scale{display:flex;gap:.4rem;margin:.8rem 0 1.1rem;font-family:var(--mono);font-size:.7rem;color:var(--sub)}
  .seg{flex:1;text-align:center;padding:.28rem 0;border-radius:6px;border:1px solid var(--rule)}
  .seg.on{color:#fff;background:$mcol;border-color:$mcol;font-weight:700}
  ul{list-style:none;margin:0;padding:0}
  li{display:flex;align-items:center;gap:.6rem;padding:.5rem 0;border-bottom:1px solid var(--rule);font-size:.94rem}
  li:last-child{border-bottom:0}
  .dot{width:.7rem;height:.7rem;border-radius:50%;flex:none}
  .lbl{flex:1}.st{font-family:var(--mono);font-size:.74rem;text-transform:uppercase;letter-spacing:.06em}
  .att{display:inline-block;margin-left:.45rem;font-family:var(--mono);font-size:.58rem;color:var(--sub);text-transform:uppercase;letter-spacing:.07em;vertical-align:middle;border:1px solid var(--rule);border-radius:4px;padding:.04rem .3rem}
  .next{margin:1.1rem 0 .3rem;padding:.7rem .9rem;background:var(--ground);border-radius:8px;font-size:.92rem}
  .next b{color:$mcol}
  footer{margin-top:1.1rem;font-family:var(--mono);font-size:.72rem;color:var(--sub);line-height:1.5}
  footer a{color:var(--sub)}
  .share{margin-top:.9rem;padding:.6rem .8rem;background:var(--ground);border-radius:8px;font-family:var(--mono);font-size:.68rem;color:var(--sub)}
  .share code{display:block;margin-top:.35rem;padding:.4rem .5rem;background:var(--card);border:1px solid var(--rule);border-radius:6px;word-break:break-all;color:var(--ink);white-space:pre-wrap}
</style></head>
<body><div class="card">
  <div class="eyebrow">Agentic-AI Security Posture</div>
  <h1>Maturity: <span class="badge">$mlabel</span></h1>
  <div class="scale">
    <div class="seg $([ "$mpos" = 0 ] && echo on)">crawl</div>
    <div class="seg $([ "$mpos" = 1 ] && echo on)">walk</div>
    <div class="seg $([ "$mpos" = 2 ] && echo on)">run</div>
  </div>
  <ul>$rows</ul>
  <div class="next">Next control to implement: <b>$(esc "$next")</b></div>
  <div class="share">Share your result — add this badge to your README:<code>$(esc "$badge_md")</code></div>
  <footer>
    Assessed with the Practical Guide to Securing AI Agents · $(esc "$date")<br>
    $([ "$has_att" = "true" ] && printf 'A %s control was confirmed by the operator, not locally measured.<br>' '"self-reported"')Posture only — no machine inventory. Run it yourself:
    <a href="$repo_url">peleduri/Practical-Guide-to-Securing-AI-Agents</a>
  </footer>
</div></body></html>
HTML

# Also print the copy-ready badge to stderr, so a CLI user who redirected the HTML
# to a file still gets the snippet to paste into their README.
printf 'Share badge (add to your README):\n%s\n' "$badge_md" >&2
