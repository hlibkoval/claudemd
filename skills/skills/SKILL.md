---
name: skills
description: Reference documentation for creating and configuring Claude Code skills and the Agent Skills open standard. Use when creating skills, writing SKILL.md files, configuring skill frontmatter, understanding skill invocation control, passing arguments to skills, or learning about the Agent Skills specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit.

### Skill Locations

| Location   | Path                                     | Applies to              |
|:-----------|:-----------------------------------------|:------------------------|
| Enterprise | Managed settings                         | All org users           |
| Personal   | `~/.claude/skills/<name>/SKILL.md`       | All your projects       |
| Project    | `.claude/skills/<name>/SKILL.md`         | This project only       |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`        | Where plugin is enabled |

### Frontmatter Fields

| Field                      | Required    | Description                                                            |
|:---------------------------|:------------|:-----------------------------------------------------------------------|
| `name`                     | No          | Display name (lowercase, hyphens, max 64 chars). Defaults to dir name |
| `description`              | Recommended | What the skill does and when to use it                                 |
| `argument-hint`            | No          | Hint shown during autocomplete, e.g. `[issue-number]`                 |
| `disable-model-invocation` | No          | `true` = only user can invoke. Default: `false`                        |
| `user-invocable`           | No          | `false` = hidden from `/` menu. Default: `true`                        |
| `allowed-tools`            | No          | Tools Claude can use without permission when skill is active           |
| `model`                    | No          | Model override when skill is active                                    |
| `context`                  | No          | `fork` = run in isolated subagent context                              |
| `agent`                    | No          | Subagent type for `context: fork` (e.g. `Explore`, `Plan`)            |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle                                 |

### String Substitutions

| Variable               | Description                                         |
|:-----------------------|:----------------------------------------------------|
| `$ARGUMENTS`           | All arguments passed when invoking the skill        |
| `$ARGUMENTS[N]` / `$N`| Specific argument by 0-based index                  |
| `${CLAUDE_SESSION_ID}` | Current session ID                                  |
| `` !`command` ``       | Dynamic context injection (shell command output)    |

### Invocation Control

| Frontmatter                      | User | Claude | Context loading                     |
|:---------------------------------|:-----|:-------|:------------------------------------|
| (default)                        | Yes  | Yes    | Description always, full on invoke  |
| `disable-model-invocation: true` | Yes  | No     | Not in context, full on user invoke |
| `user-invocable: false`          | No   | Yes    | Description always, full on invoke  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent Skills Specification](references/agent-skills-specification.md) — the open standard format specification from agentskills.io
- [Claude Code Skills](references/claude-code-skills.md) — complete Claude Code skills documentation with all examples and advanced patterns

## Sources

- Agent Skills Specification: https://agentskills.io/specification.md
- Claude Code Skills: https://code.claude.com/docs/en/skills.md
