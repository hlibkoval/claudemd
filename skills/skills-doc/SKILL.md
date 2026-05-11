---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating SKILL.md files, frontmatter fields, skill locations and scoping, dynamic context injection, subagent execution, arguments, allowed-tools, invocation control, skill content lifecycle, and the Agent Skills open standard specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills (custom commands and reusable prompts).

## Quick Reference

### Skill Directory Structure

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── references/       # Optional: detailed docs loaded on demand
├── scripts/          # Optional: executable code
└── assets/           # Optional: templates, static resources
```

### Where Skills Live

| Location   | Path                                              | Applies to                     |
| :--------- | :------------------------------------------------ | :----------------------------- |
| Enterprise | See managed settings                              | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`          | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`            | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`           | Where plugin is enabled        |

Enterprise overrides personal; personal overrides project. Plugin skills use `plugin-name:skill-name` namespace. `.claude/commands/` files still work; skills take precedence if names conflict.

### Frontmatter Fields

| Field                      | Required    | Description                                                                                                      |
| :------------------------- | :---------- | :--------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Display name. Defaults to directory name. Lowercase, numbers, hyphens only (max 64 chars).                       |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this to decide when to apply the skill automatically.        |
| `when_to_use`              | No          | Additional trigger context. Appended to `description` in the skill listing (combined cap: 1,536 chars).          |
| `argument-hint`            | No          | Hint shown in autocomplete. Example: `[issue-number]`.                                                           |
| `arguments`                | No          | Named positional args for `$name` substitution. Space-separated string or YAML list.                             |
| `disable-model-invocation` | No          | `true` = only you can invoke (Claude won't auto-trigger; description hidden from Claude's context).              |
| `user-invocable`           | No          | `false` = hidden from `/` menu; Claude-only background knowledge. Default: `true`.                               |
| `allowed-tools`            | No          | Tools Claude can use without approval when skill is active. Space-separated string or YAML list.                 |
| `model`                    | No          | Model override for this skill's turn. Accepts same values as `/model` or `inherit`.                              |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                                  |
| `context`                  | No          | `fork` = run in a forked subagent context.                                                                       |
| `agent`                    | No          | Subagent type when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, or custom agent name.        |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle.                                                                          |
| `paths`                    | No          | Glob patterns limiting when the skill activates. Comma-separated string or YAML list.                            |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                     |

### Invocation Control

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                      |
| :------------------------------- | :------------- | :---------------- | :------------------------------------------------------------ |
| (default)                        | Yes            | Yes               | Description always in context; full skill loads when invoked  |
| `disable-model-invocation: true` | Yes            | No                | Description not in context; full skill loads when you invoke  |
| `user-invocable: false`          | No             | Yes               | Description always in context; full skill loads when invoked  |

### String Substitutions

| Variable               | Description                                                                 |
| :--------------------- | :-------------------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking the skill                                |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index                                          |
| `$N`                   | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`)                            |
| `$name`                | Named argument declared in `arguments` frontmatter                          |
| `${CLAUDE_SESSION_ID}` | Current session ID                                                          |
| `${CLAUDE_EFFORT}`     | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`           |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md file                              |

### Dynamic Context Injection

Use `` !`command` `` to run shell commands before the skill content reaches Claude. The output replaces the placeholder inline (preprocessing, not Claude execution).

```yaml
---
name: summarize-changes
description: Summarize uncommitted git changes and flag risks
---

## Current changes

!`git diff HEAD`

## Instructions

Summarize the changes above...
```

For multi-line commands, use a fenced block opened with ` ```! `.

Disable shell execution for user/project/plugin skills: set `"disableSkillShellExecution": true` in settings.

### Skill Content Lifecycle

- When invoked, rendered SKILL.md enters the conversation and stays for the rest of the session
- Claude Code does not re-read the skill file on later turns
- Auto-compaction carries invoked skills forward (first 5,000 tokens each; combined budget: 25,000 tokens)
- Older/less-recently-invoked skills may be dropped after compaction

### Agent Skills Open Standard (agentskills.io)

Claude Code skills follow the open Agent Skills spec. Key spec constraints:

| Field         | Constraints                                                                    |
| :------------ | :----------------------------------------------------------------------------- |
| `name`        | 1–64 chars; lowercase alphanumeric and hyphens only; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | 1–1024 chars; non-empty                                                        |
| `compatibility` | Max 500 chars if provided                                                    |
| `metadata`    | Arbitrary string key-value map                                                 |
| `allowed-tools` | Space-delimited list (experimental; support varies by agent)               |

The spec also defines `scripts/`, `references/`, and `assets/` optional directories. Progressive disclosure: metadata (~100 tokens) loaded at startup for all skills; full SKILL.md body loaded on activation; reference files loaded only on demand.

### `skillOverrides` Setting

Override skill visibility from settings without editing SKILL.md:

| Value                   | Listed to Claude     | In `/` menu |
| :---------------------- | :------------------- | :---------- |
| `"on"`                  | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

The `/skills` menu can write `skillOverrides` to `.claude/settings.local.json` interactively. Plugin skills are not affected.

### Troubleshooting

| Symptom                       | Fix                                                                                                     |
| :---------------------------- | :------------------------------------------------------------------------------------------------------ |
| Skill not triggering          | Check description keywords; verify with "What skills are available?"; invoke directly with `/skill-name` |
| Skill triggers too often      | Make description more specific; add `disable-model-invocation: true`                                    |
| Descriptions cut short        | Many skills overflowing budget; adjust `skillListingBudgetFraction` or trim descriptions                |
| Skill stops influencing after first response | Content is present but model is choosing other approaches; strengthen description/instructions or use hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with Skills](references/claude-code-skills.md) — creating skills, frontmatter, locations, invocation control, arguments, dynamic context injection, subagent execution, allowed-tools, skill content lifecycle, share skills, troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — open standard format, SKILL.md frontmatter schema, optional directories, progressive disclosure, file references, validation

## Sources

- Extend Claude with Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
