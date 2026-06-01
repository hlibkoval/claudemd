---
name: skills-doc
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills: creating, configuring, and distributing skills, plus the Agent Skills open standard specification.

## Quick Reference

### Skill Directory Layout

```
skill-name/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Optional: detailed docs loaded on demand
├── scripts/           # Optional: executable helpers
└── assets/            # Optional: templates, images, data files
```

### Where Skills Live

| Location   | Path                                             | Applies to                     |
|:-----------|:-------------------------------------------------|:-------------------------------|
| Enterprise | See managed settings                             | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where plugin is enabled        |

Enterprise overrides personal; personal overrides project. Plugin skills are namespaced as `plugin-name:skill-name`.

### Frontmatter Reference

| Field                      | Required    | Description                                                                                                          |
|:---------------------------|:------------|:---------------------------------------------------------------------------------------------------------------------|
| `name`                     | No          | Display name. Defaults to directory name. Only sets command name for plugin-root `SKILL.md`.                        |
| `description`              | Recommended | What the skill does and when to use it. Combined with `when_to_use`, capped at 1,536 characters in skill listing.   |
| `when_to_use`              | No          | Additional trigger phrases/examples appended to `description` in the skill listing.                                  |
| `argument-hint`            | No          | Hint shown in autocomplete, e.g. `[issue-number]`.                                                                  |
| `arguments`                | No          | Named positional arguments for `$name` substitution. Space-separated string or YAML list.                           |
| `disable-model-invocation` | No          | `true` = only you can invoke; description excluded from Claude's context. Default: `false`.                          |
| `user-invocable`           | No          | `false` = hidden from `/` menu; Claude still loads it automatically. Default: `true`.                                |
| `allowed-tools`            | No          | Tools pre-approved while skill is active (no per-use prompt). Space- or comma-separated or YAML list.               |
| `disallowed-tools`         | No          | Tools removed from available pool while skill is active. Clears after your next message.                             |
| `model`                    | No          | Model override for this skill's turn. Same values as `/model`, or `inherit`.                                         |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                                     |
| `context`                  | No          | `fork` = run skill in an isolated subagent context.                                                                  |
| `agent`                    | No          | Subagent type when `context: fork` is set. Options: `Explore`, `Plan`, `general-purpose`, or any custom agent.      |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle.                                                                              |
| `paths`                    | No          | Glob patterns limiting when the skill auto-activates. Comma-separated or YAML list.                                  |
| `shell`                    | No          | Shell for inline injection commands: `bash` (default) or `powershell`.                                               |

### Invocation Control

| Frontmatter                      | You can invoke | Claude can invoke | Loaded into context                                          |
|:---------------------------------|:---------------|:------------------|:-------------------------------------------------------------|
| (default)                        | Yes            | Yes               | Description always present; full skill loads when invoked    |
| `disable-model-invocation: true` | Yes            | No                | Description excluded; full skill loads when you invoke       |
| `user-invocable: false`          | No             | Yes               | Description always present; full skill loads when invoked    |

### String Substitutions

| Variable               | Description                                                                              |
|:-----------------------|:-----------------------------------------------------------------------------------------|
| `$ARGUMENTS`           | All arguments passed at invocation. Appended as `ARGUMENTS: <value>` if not in content. |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index.                                                      |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`.                                                           |
| `$name`                | Named argument declared in `arguments` frontmatter.                                      |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                                      |
| `${CLAUDE_EFFORT}`     | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`.                       |
| `${CLAUDE_SKILL_DIR}`  | Directory containing this skill's `SKILL.md`. Use for bundled script paths.             |

### Command Name Sources

| Skill location                                  | Command name source                                  |
|:------------------------------------------------|:-----------------------------------------------------|
| Under `~/.claude/skills/` or `.claude/skills/`  | Directory name                                       |
| Under `.claude/commands/`                       | File name without extension                          |
| Plugin `skills/` subdirectory                   | Directory name, namespaced by plugin                 |
| Plugin root `SKILL.md`                          | Frontmatter `name` (falls back to plugin dir name)   |

### Dynamic Context Injection

Two syntaxes run shell commands before the skill content is sent to Claude:

- **Inline**: an exclamation mark immediately followed by a backtick-wrapped command, at the start of a line or after whitespace
- **Multi-line**: a fenced code block whose opening fence is immediately followed by an exclamation mark

The output replaces the placeholder before Claude sees anything. This is preprocessing — Claude only sees the final rendered text. To disable this behavior, set `"disableSkillShellExecution": true` in settings.

Substitution runs once over the original file. Command output is not re-scanned for further injection placeholders.

### Skill Content Lifecycle

- Rendered `SKILL.md` content enters the conversation as a single message and stays for the rest of the session.
- Auto-compaction re-attaches the most recent invocation of each skill (up to 5,000 tokens per skill, 25,000 tokens combined budget). Most recently invoked skill is prioritized.
- Skill descriptions are truncated to fit a token budget (1% of context window by default). Configure with `skillListingBudgetFraction` or `SLASH_COMMAND_TOOL_CHAR_BUDGET`. Per-skill cap: `maxSkillDescriptionChars` (default 1,536 chars).

### `skillOverrides` Settings Values

| Value                   | Listed to Claude     | In `/` menu |
|:------------------------|:---------------------|:------------|
| `"on"`                  | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

Plugin skills are not affected by `skillOverrides`. Absent entries default to `"on"`.

### Controlling Claude's Skill Access

- **Deny all skills**: add `Skill` to deny rules in `/permissions`
- **Allow specific**: `Skill(commit)` or `Skill(review-pr *)`
- **Deny specific**: `Skill(deploy *)`
- **Hide from Claude entirely**: add `disable-model-invocation: true` to the skill's frontmatter

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match.

### Progressive Disclosure (Agent Skills Spec)

| Layer        | Tokens   | Content                                       |
|:-------------|:---------|:----------------------------------------------|
| Metadata     | ~100     | `name` and `description` — always loaded      |
| Instructions | < 5,000  | Full `SKILL.md` body — loaded when activated  |
| Resources    | As needed| Files in `scripts/`, `references/`, `assets/` |

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Agent Skills Spec: `name` Field Rules

- 1–64 characters, lowercase alphanumeric and hyphens only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name

### Forked Subagent Skills

| Approach                   | System prompt   | Task                 | Also loads                                          |
|:---------------------------|:----------------|:---------------------|:----------------------------------------------------|
| Skill with `context: fork` | From agent type | SKILL.md content     | CLAUDE.md, except when agent is Explore or Plan     |
| Subagent with `skills`     | Agent's body    | Claude's delegation  | Preloaded skills + CLAUDE.md                        |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with Skills](references/claude-code-skills.md) — Creating skills, frontmatter reference, invocation control, dynamic context injection, subagent forks, supporting files, sharing, and troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — Open standard for skill format: directory structure, SKILL.md frontmatter schema, optional directories, progressive disclosure, file references, and validation

## Sources

- Extend Claude with Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
