# Repository schema — LLM Wiki

This repository is an **LLM Wiki** (per Andrej Karpathy's pattern): a compounding, cross-referenced set of markdown pages that a human or an LLM can read, extend, and maintain. It is the practical companion to a ten-part security guide on defending agentic AI.

## Layout

- `index.md` — the catalog. Every page gets one link and a one-line summary, grouped by category. Update it whenever a page is added, renamed, or removed.
- `log.md` — append-only history. One entry per change: `## [YYYY-MM-DD] <operation> | <title>`.
- `wiki/` — the pages. Each page is a self-contained markdown file with YAML frontmatter (`title`, `summary`, `part`, `updated`).
- `README.md` — the human entry point.
- `start-here.md` — the on-ramp: reader tracks (security engineer / platform-DevEx / CISO), the first five controls in order, and a crawl/walk/run maturity model.
- `glossary.md` — one-line definitions of the terms used across the parts, each pointing to the part that defines it. Definitions live here; `index.md`'s "Key concepts" is only a compact concept→part pointer.
- `scripts/lint.sh` — the wiki's test suite: fails on a broken relative link or an orphan part. CI runs it on every PR via `.github/workflows/lint.yml`.

## Conventions

- **Links:** pages cross-reference with GitHub-native relative markdown links, e.g. `[Part 2](part-2-endpoint-hardening-and-policy-playbook.md)`. This is the GitHub-friendly form of Karpathy's `[[wikilink]]` — it renders for humans on GitHub and parses cleanly for LLMs.
- **Frontmatter:** every page starts with `title`, `summary`, `part` (when applicable), and `updated` (ISO date).
- **Vendor names** appear as concrete examples, not endorsements. Product controls change fast — verify against the linked vendor docs before relying on a specific setting.
- **Sources** are cited inline as plain URLs at the foot of a page.

## Workflows

- **Ingest** (add a source or finding): read the source, write or update the relevant page in `wiki/`, add or refresh its line in `index.md`, and append a `log.md` entry.
- **Query:** search the pages, answer with citations to page + section. A good synthesized answer can be filed back as a new page.
- **Lint:** run `scripts/lint.sh` (CI runs it on every PR) to catch orphans (a page not listed in `index.md`) and broken relative links; still review by hand for contradictions across pages and stale claims (a control the vendor has since changed).

## Scope note

Vendor and product specifics (Claude Code, Claude Cowork, Codex, Cursor, Coder, GPU-first neoclouds, sandbox-native providers) are named as concrete examples. Nothing here is organization-specific; it is a general playbook.
