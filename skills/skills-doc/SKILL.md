---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend Claude by loading a `SKILL.md` file as instructions. They are loaded automatically when relevant, or invoked directly with `/skill-name`. Skills are the successor to `.claude/commands/` files and add supporting files, frontmatter control, and subagent execution.

### Directory layout

```
skill-name/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Optional: docs loaded on demand
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, static resources
```

### Skill storage locations (priority order)

| Location   | Path                                             | Scope                          |
| :--------- | :----------------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                                 | All users in the organization  |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All projects for you           |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where the plugin is enabled    |

Plugin skills use a `plugin-name:skill-name` namespace and cannot conflict with other levels. Same-name skills: enterprise > personal > project.

### SKILL.md frontmatter fields

| Field                      | Required    | Description                                                                                                         |
| :------------------------- | :---------- | :------------------------------------------------------------------------------------------------------------------ |
| `name`                     | No          | Lowercase letters, numbers, hyphens; max 64 chars. Defaults to directory name.                                      |
| `description`              | Recommended | When and what the skill does. Claude uses this for auto-invocation. Front-load the key use case; capped at 1,536 chars combined with `when_to_use`. |
| `when_to_use`              | No          | Additional trigger context; appended to `description` in the listing.                                              |
| `argument-hint`            | No          | Autocomplete hint for expected arguments, e.g. `[issue-number]`.                                                   |
| `disable-model-invocation` | No          | `true` = only user can invoke; skill is hidden from Claude's context. Default: `false`.                             |
| `user-invocable`           | No          | `false` = hidden from `/` menu; Claude-only background skill. Default: `true`.                                      |
| `allowed-tools`            | No          | Space-separated tools Claude may use without per-use approval while skill is active.                                |
| `model`                    | No          | Model to use when this skill is active.                                                                             |
| `effort`                   | No          | Effort level: `low`, `medium`, `high`, `xhigh`, `max`. Overrides session effort.                                   |
| `context`                  | No          | Set to `fork` to run skill in an isolated subagent.                                                                 |
| `agent`                    | No          | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom).                        |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle.                                                                             |
| `paths`                    | No          | Glob patterns; skill only auto-activates when working with matching files.                                          |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                        |

### Invocation control matrix

| Frontmatter                      | User can invoke | Claude can invoke | Description loaded into context |
| :------------------------------- | :-------------- | :---------------- | :------------------------------ |
| (default)                        | Yes             | Yes               | Yes                             |
| `disable-model-invocation: true` | Yes             | No                | No                              |
| `user-invocable: false`          | No              | Yes               | Yes                             |

### String substitutions in skill content

| Variable               | Expands to                                                    |
| :--------------------- | :------------------------------------------------------------ |
| `$ARGUMENTS`           | Full argument string typed after the skill name               |
| `$ARGUMENTS[N]`        | Nth argument (0-based); multi-word values require quotes      |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`                                 |
| `${CLAUDE_SESSION_ID}` | Current session ID                                            |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`                   |

If `$ARGUMENTS` is absent from skill content, arguments are appended as `ARGUMENTS: <value>`.

### Dynamic context injection

Inline shell syntax runs before skill content reaches Claude:

- Inline: `` !`<command>` `` — output replaces the placeholder
- Block: fenced code block opened with ` ```! ` — multi-line commands

Commands execute at invocation time; Claude sees only the rendered output. Disable with `"disableSkillShellExecution": true` in settings (bundled/managed skills are unaffected).

### Running a skill in a subagent

Add `context: fork` to run the skill in an isolated context. The skill body becomes the subagent's task prompt; it does not inherit conversation history. Use `agent` to pick the subagent type.

| Approach                   | System prompt           | Task                 | Also loads            |
| :------------------------- | :---------------------- | :------------------- | :-------------------- |
| Skill with `context: fork` | From agent type         | SKILL.md body        | CLAUDE.md             |
| Subagent with `skills`     | Subagent's markdown body | Claude's delegation | Preloaded skills + CLAUDE.md |

### Skill content lifecycle

- Full `SKILL.md` content is injected once per invocation and persists for the session.
- After auto-compaction, the most recent invocation of each skill is re-attached (up to 5,000 tokens each, shared 25,000-token budget across all re-attached skills). Older skills may be dropped.

### Agent Skills open standard frontmatter (cross-tool)

The open standard (`agentskills.io`) defines a portable baseline:

| Field           | Required | Constraints                                                          |
| :-------------- | :------- | :------------------------------------------------------------------- |
| `name`          | Yes      | 1-64 chars; lowercase alphanumeric + hyphens; no leading/trailing/consecutive hyphens; must match directory name |
| `description`   | Yes      | 1-1024 chars; what the skill does and when to use it                 |
| `license`       | No       | License name or reference to a bundled file                          |
| `compatibility` | No       | 1-500 chars; environment requirements                                |
| `metadata`      | No       | Arbitrary key-value map for additional properties                    |
| `allowed-tools` | No       | Space-delimited pre-approved tools (experimental)                    |

Claude Code extends the standard with `disable-model-invocation`, `user-invocable`, `context`, `agent`, `effort`, `model`, `hooks`, `paths`, `shell`, `when_to_use`, and `argument-hint`.

### Progressive disclosure (context efficiency)

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills
2. **Instructions** (recommended < 5,000 tokens / 500 lines): full `SKILL.md` body loaded on invocation
3. **Resources**: files in `references/`, `scripts/`, `assets/` loaded only when Claude reads them

### Troubleshooting

| Problem                         | Fix                                                                                   |
| :------------------------------ | :------------------------------------------------------------------------------------ |
| Skill not triggering            | Add trigger keywords to `description`; verify it appears in "What skills are available?" |
| Skill triggers too often        | Narrow `description`; add `disable-model-invocation: true`                            |
| Descriptions cut short          | Front-load key use case; trim `description` + `when_to_use` to stay under 1,536 chars; raise `SLASH_COMMAND_TOOL_CHAR_BUDGET` |
| Skill stops influencing behavior after first response | Content is still present — strengthen `description` and instructions, or re-invoke after compaction |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — full Claude Code guide covering bundled skills, creating and configuring skills, frontmatter reference, supporting files, invocation control, content lifecycle, tool pre-approval, arguments, dynamic context injection, subagent execution, sharing skills, and troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — the open standard format spec covering directory structure, frontmatter fields, body content, optional directories, progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
