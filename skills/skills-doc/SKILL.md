---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. A skill is a directory with a `SKILL.md` file (YAML frontmatter + Markdown body). Claude loads skills automatically when relevant, or users invoke them directly with `/skill-name`. Custom commands (`.claude/commands/*.md`) still work but skills are preferred for new workflows.

Skills follow the [Agent Skills](https://agentskills.io) open standard. Claude Code extends the standard with invocation control, subagent execution, and dynamic context injection.

### Where skills live

| Scope      | Path                                    | Applies to                     |
| :--------- | :-------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                        | All users in your organization |
| Personal   | `~/.claude/skills/<name>/SKILL.md`      | All your projects              |
| Project    | `.claude/skills/<name>/SKILL.md`        | This project only              |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`       | Where plugin is enabled        |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills take precedence over same-name commands.

### Skill directory structure

```
my-skill/
  SKILL.md           # Main instructions (required)
  references/        # Additional documentation (loaded on demand)
  scripts/           # Executable code
  assets/            # Templates, images, data files
```

### Frontmatter fields (Claude Code)

| Field                      | Required    | Description                                                                                                     |
| :------------------------- | :---------- | :-------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Display name; defaults to directory name. Lowercase, numbers, hyphens only (max 64 chars).                      |
| `description`              | Recommended | What the skill does and when to use it. Truncated at 1,536 chars in skill listing.                              |
| `when_to_use`              | No          | Additional trigger context; appended to `description`, shares the 1,536-char cap.                               |
| `argument-hint`            | No          | Autocomplete hint for expected arguments (e.g. `[issue-number]`).                                               |
| `disable-model-invocation` | No          | `true` = only the user can invoke. Default: `false`.                                                            |
| `user-invocable`           | No          | `false` = hidden from `/` menu; only Claude can invoke. Default: `true`.                                        |
| `allowed-tools`            | No          | Tools pre-approved while this skill is active. Space-separated string or YAML list.                             |
| `model`                    | No          | Model to use when this skill is active.                                                                         |
| `effort`                   | No          | Effort level override (`low`, `medium`, `high`, `xhigh`, `max`).                                               |
| `context`                  | No          | `fork` = run in a forked subagent context.                                                                      |
| `agent`                    | No          | Which subagent type when `context: fork` (built-in or custom from `.claude/agents/`). Default: `general-purpose`.|
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle.                                                                         |
| `paths`                    | No          | Glob patterns limiting auto-activation to matching files. Comma-separated or YAML list.                         |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                    |

### Frontmatter fields (Agent Skills standard)

| Field           | Required | Description                                                         |
| :-------------- | :------- | :------------------------------------------------------------------ |
| `name`          | Yes      | 1-64 chars, lowercase alphanumeric + hyphens, must match directory. |
| `description`   | Yes      | 1-1024 chars. What the skill does and when to use it.               |
| `license`       | No       | License name or reference to bundled license file.                  |
| `compatibility` | No       | Max 500 chars. Environment requirements.                            |
| `metadata`      | No       | Arbitrary key-value map for additional metadata.                    |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools. Experimental.           |

### `name` validation rules

- 1-64 characters, lowercase `a-z`, numbers, hyphens only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name

### Invocation control

| Frontmatter                      | User can invoke | Claude can invoke | Context behavior                                             |
| :------------------------------- | :-------------- | :---------------- | :----------------------------------------------------------- |
| (default)                        | Yes             | Yes               | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes             | No                | Description not in context; loads only on user invocation    |
| `user-invocable: false`          | No              | Yes               | Description always in context; full skill loads when invoked |

### String substitutions

| Variable               | Description                                                       |
| :--------------------- | :---------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking the skill.                     |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index (shell-style quoting applies). |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                               |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md file.                   |

### Dynamic context injection

The `` !`<command>` `` syntax runs a shell command before the skill content is sent to Claude. Output replaces the placeholder. For multi-line commands, use a fenced code block opened with ` ```! `. Disable with `"disableSkillShellExecution": true` in settings.

### Skill content lifecycle

- Rendered SKILL.md enters the conversation as a single message and stays for the session.
- Auto-compaction carries invoked skills forward, keeping up to 5,000 tokens per skill and 25,000 tokens combined, prioritizing most recently invoked.
- Project-root CLAUDE.md re-reads from disk after compaction; skills do not auto-reload.

### Running skills in a subagent

Add `context: fork` to frontmatter. The skill content becomes the subagent's task prompt (it does not see conversation history). Choose the agent type with the `agent` field (`Explore`, `Plan`, `general-purpose`, or a custom agent from `.claude/agents/`).

### Progressive disclosure

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills
2. **Instructions** (< 5,000 tokens recommended): full SKILL.md body loaded on activation
3. **Resources** (as needed): supporting files loaded only when required

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Sharing skills

| Method           | How                                                         |
| :--------------- | :---------------------------------------------------------- |
| Project skills   | Commit `.claude/skills/` to version control                 |
| Plugins          | Create a `skills/` directory in your plugin                 |
| Managed          | Deploy organization-wide through managed settings           |

### Live change detection

Claude Code watches skill directories for file changes. Edits take effect within the current session. Creating a top-level skills directory that did not exist at startup requires restarting Claude Code.

### Description budget

Skill descriptions share a character budget (1% of context window, fallback 8,000 chars). Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. Each entry's combined `description` + `when_to_use` is capped at 1,536 chars -- front-load key use cases.

### Restricting skill access

- **Disable all skills**: deny the `Skill` tool in permissions.
- **Allow/deny specific skills**: `Skill(name)` for exact match, `Skill(name *)` for prefix match.
- **Hide individual skills**: set `disable-model-invocation: true` in frontmatter.

### Validation (Agent Skills standard)

```bash
skills-ref validate ./my-skill
```

Uses the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library.

### Troubleshooting

- **Skill not triggering** -- check description keywords, verify with "What skills are available?", try `/skill-name` directly.
- **Skill triggers too often** -- make description more specific; add `disable-model-invocation: true`.
- **Descriptions cut short** -- front-load key use cases; raise `SLASH_COMMAND_TOOL_CHAR_BUDGET`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- full guide covering skill creation, directory layout, frontmatter reference, invocation control, arguments, dynamic context injection, subagent execution, supporting files, sharing, bundled skills, visual output generation, and troubleshooting.
- [Agent Skills Specification](references/agent-skills-specification.md) -- the complete Agent Skills open standard format specification covering directory structure, SKILL.md format, frontmatter fields (name, description, license, compatibility, metadata, allowed-tools), body content, optional directories (scripts, references, assets), progressive disclosure, file references, and validation.

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
