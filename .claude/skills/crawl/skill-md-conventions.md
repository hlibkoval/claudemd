# SKILL.md Conventions for claudemd Plugin

Skills in this plugin are **documentation reference skills** — they summarize official Claude Code docs for quick lookup. They are not interactive tools or user-facing commands.

## Frontmatter requirements

- `name` must match the skill's directory name
- `user-invocable: false` — these are background reference skills, not user actions
- Do NOT set `disable-model-invocation` — Claude should auto-load these when relevant

## Body template

Every skill in this plugin follows this structure:

```markdown
# <Topic> Documentation

This skill provides the complete official documentation for <topic>.

## Quick Reference

<Concise summary tables and key info extracted from the reference docs.
NOT a copy of the full docs — distill into reference tables, key config fields,
CLI flags, common patterns, important enums/values.>

## Full Documentation

For the complete official documentation, see the reference files:

- [<Doc Title>](references/<filename>) — <one-line description>
...

## Sources

- <Doc Title>: <original URL>
...
```

## Project-specific rules

1. Reference files in `references/` are curl'd word-for-word copies of upstream docs. Never modify them.
2. Include source URLs for every reference doc. Read `skill-map.json` (in the project root) for the canonical URLs.
3. **Never write `!` immediately followed by a backtick.** Claude Code's permission system interprets `!\`` as a bash command pattern and blocks the skill from loading.
4. Study 2-3 existing sibling SKILL.md files (e.g., `skills/hooks-doc/SKILL.md`, `skills/plugins-doc/SKILL.md`) to match the established pattern.
