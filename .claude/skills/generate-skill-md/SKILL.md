---
name: generate-skill-md
description: Generate a SKILL.md file for a claudemd plugin skill from its reference docs.
context: fork
agent: general-purpose
allowed-tools: Read, Write, Glob, Grep, Bash, Skill
---

# Generate SKILL.md for: $ARGUMENTS

You are generating a `SKILL.md` file for the `$ARGUMENTS` skill in the claudemd plugin.

## Context

First, invoke `/skills-doc` to load the skills documentation — this tells you the SKILL.md format, frontmatter fields, and best practices.

## Locate the skill

The skill directory is at one of:
- `skills/$ARGUMENTS/` (relative to project root)

Read all files in `skills/$ARGUMENTS/references/` — these are the source documentation pages.

## Study existing examples

Read 2-3 existing SKILL.md files from sibling skills to understand the established pattern:

```
skills/hooks-doc/SKILL.md
skills/sub-agents-doc/SKILL.md
skills/plugins-doc/SKILL.md
skills/skills-doc/SKILL.md
```

## Generate the SKILL.md

Write `skills/$ARGUMENTS/SKILL.md` following this exact structure:

### Frontmatter

```yaml
---
name: <skill-name>
description: <Comprehensive description of what documentation this skill covers. Include specific keywords for when Claude should load it. 1-2 sentences.>
user-invocable: false
---
```

- `name` must match the directory name (`$ARGUMENTS`)
- `user-invocable: false` because these are background reference skills, not user actions
- Do NOT set `disable-model-invocation` (Claude should auto-load these)

### Body

```markdown
# <Topic> Documentation

This skill provides the complete official documentation for <topic>.

## Quick Reference

<Extract the most useful quick-reference content from the docs:
- Key tables (config fields, options, CLI flags)
- Common patterns / code snippets
- Important enums or values

Keep this section CONCISE — only the most frequently needed info.
Use markdown tables for structured data.
Do NOT copy the full docs here. Summarize into reference tables.>

## Full Documentation

For the complete official documentation, see the reference files:

- [<Doc Title>](references/<filename>) — <one-line description>
- [<Doc Title>](references/<filename>) — <one-line description>
...

## Sources

- <Doc Title>: <original URL>
- <Doc Title>: <original URL>
...
```

## Rules

1. The Quick Reference section must be YOUR summary — concise tables and key info extracted from the docs. NOT a copy of the full docs.
2. The reference files in `references/` are the word-for-word copies. Do not modify them.
3. Keep SKILL.md under 200 lines. The goal is a quick-reference card, not a copy.
4. Include source URLs for every referenced document.
5. Extract the original URL from each reference file's first lines (look for `> Source:` or the `> Fetch the complete documentation index at:` pattern, or reconstruct from the filename).
6. Read the skill-map at `.claude/skills/crawl/skill-map.json` to get the exact source URLs for this skill's docs.
7. **NEVER write `!` immediately followed by a backtick.** Claude Code's permission system interprets this as a bash command pattern and blocks the skill from loading. Always separate them — write `!` + (backtick)command(backtick) as two separate code spans.
