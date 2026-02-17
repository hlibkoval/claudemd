# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin (`claudemd`) that packages official Claude Code documentation as Agent Skills. Each skill covers one topic, with a hand-written quick-reference `SKILL.md` and `references/` containing word-for-word copies of the source docs (downloaded via `curl`).

## Architecture

```
.claude-plugin/plugin.json     → Plugin manifest (name: "claudemd")
skills/<topic>/SKILL.md        → Quick-reference summary (< 200 lines, auto-generated)
skills/<topic>/references/*.md → Curl'd copies of official docs (never hand-edited)
.claude/skills/crawl/          → Maintenance skill: downloads docs, detects changes
.claude/skills/generate-skill-md/ → Forked skill: regenerates SKILL.md from references
.claude/skills/skills          → Symlink to skills/skills/ (so /skills works locally)
.claude/skills/crawl/skill-map.json → Source of truth: maps skill names → doc URLs
```

## Key Conventions

- **Reference files are curl'd, never hand-written.** They must be exact copies of the source URLs.
- **SKILL.md files are generated summaries.** They contain quick-reference tables + links to the reference files. Kept under 200 lines.
- **All plugin skills use `user-invocable: false`** — they're background knowledge Claude loads automatically, not user commands.
- **skill-map.json is the canonical mapping** of which doc URLs belong to which skill. Adding a new skill means adding an entry here.

## Maintenance Workflow

Run `/crawl` to update all docs. It:
1. Reads `skill-map.json`
2. Curls all doc URLs into `skills/<name>/references/`
3. Detects orphaned references not in the map
4. Uses `git diff` to find changed references
5. Regenerates SKILL.md for changed skills via `/generate-skill-md <name>`

To add a new skill: add entries to `skill-map.json`, then run `/crawl <skill-name>`.

## Testing Locally

```bash
claude --plugin-dir .
```
