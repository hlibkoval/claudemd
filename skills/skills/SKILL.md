---
name: skills
description: Reference documentation for Claude Code skills — creating SKILL.md files, frontmatter fields, invocation control, argument passing, string substitutions, dynamic context injection, subagent execution, supporting files, sharing skills, and the Agent Skills open standard specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`.

### Skill Locations

| Location   | Path                                     | Applies to              |
|:-----------|:-----------------------------------------|:------------------------|
| Enterprise | Managed settings                         | All org users           |
| Personal   | `~/.claude/skills/<name>/SKILL.md`       | All your projects       |
| Project    | `.claude/skills/<name>/SKILL.md`         | This project only       |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`        | Where plugin is enabled |

Higher-priority locations win: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace and cannot conflict. Skills in `.claude/commands/` also work; if both exist with the same name, the skill wins. Nested `.claude/skills/` in subdirectories are auto-discovered (monorepo support). Skills from `--add-dir` directories are loaded with live change detection.

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

### Name Constraints (Agent Skills Spec)

- 1-64 characters, lowercase alphanumeric and hyphens only
- Must not start/end with `-` or contain `--`
- Must match the parent directory name

### Invocation Control

| Frontmatter                      | User | Claude | Context loading                     |
|:---------------------------------|:-----|:-------|:------------------------------------|
| (default)                        | Yes  | Yes    | Description always, full on invoke  |
| `disable-model-invocation: true` | Yes  | No     | Not in context, full on user invoke |
| `user-invocable: false`          | No   | Yes    | Description always, full on invoke  |

### String Substitutions

| Variable               | Description                                         |
|:-----------------------|:----------------------------------------------------|
| `$ARGUMENTS`           | All arguments passed when invoking the skill        |
| `$ARGUMENTS[N]` / `$N`| Specific argument by 0-based index                  |
| `${CLAUDE_SESSION_ID}` | Current session ID                                  |
| `!` + `` `command` ``  | Dynamic context injection (shell command output)    |

If `$ARGUMENTS` is not present in skill content, arguments are appended as `ARGUMENTS: <value>`.

### Subagent Execution (`context: fork`)

Add `context: fork` to run a skill in an isolated subagent. The skill content becomes the subagent's task prompt. Use `agent` to pick the agent type (`Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`). Defaults to `general-purpose`. The subagent does not have access to conversation history. Only makes sense for skills with explicit task instructions, not passive guidelines.

### Directory Structure

```
my-skill/
+-- SKILL.md           # Main instructions (required)
+-- references/        # Detailed reference material (loaded on demand)
+-- scripts/           # Executable scripts
+-- assets/            # Templates, images, data files
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Progressive Disclosure

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (<5000 tokens recommended): full `SKILL.md` body loaded when skill is activated
3. **Resources** (as needed): supporting files loaded only when required

### Permission Control

| Method                               | Effect                                          |
|:-------------------------------------|:------------------------------------------------|
| `Skill` in deny rules               | Disable all skills for Claude                   |
| `Skill(name)` / `Skill(name *)`     | Allow/deny specific skills (exact or prefix)    |
| `disable-model-invocation: true`     | Hide skill from Claude entirely                 |

### Skill Description Budget

Descriptions are loaded into context at ~2% of the context window (fallback: 16,000 chars). If you have many skills, some may be excluded. Check `/context` for warnings. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET`.

### Sharing Skills

- **Project**: commit `.claude/skills/` to version control
- **Plugin**: create a `skills/` directory in your plugin
- **Managed**: deploy organization-wide through managed settings

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent Skills Specification](references/agent-skills-specification.md) -- the open standard format specification from agentskills.io
- [Claude Code Skills](references/claude-code-skills.md) -- complete Claude Code skills documentation with all examples and advanced patterns

## Sources

- Agent Skills Specification: https://agentskills.io/specification.md
- Claude Code Skills: https://code.claude.com/docs/en/skills.md
