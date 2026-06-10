---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard. Use when working with SKILL.md files, skill frontmatter fields, invocation control, dynamic context injection, subagent forking, argument substitution, skill scopes, bundled skills, or the agentskills.io specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### Skill directory layout

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: reference docs (loaded on demand)
└── assets/           # Optional: templates, data files
```

### Skill scopes (where they live)

| Scope      | Path                                              | Applies to                     |
| :--------- | :------------------------------------------------ | :----------------------------- |
| Enterprise | Managed settings                                  | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`          | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`            | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`           | Where plugin is enabled        |

Enterprise overrides personal; personal overrides project. Plugin skills use a `plugin-name:skill-name` namespace.

### Frontmatter fields (Claude Code)

| Field                      | Required    | Description                                                                                           |
| :------------------------- | :---------- | :---------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Display name. Defaults to directory name. Only sets command name for plugin-root `SKILL.md`.          |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this for auto-invocation decisions.               |
| `when_to_use`              | No          | Additional trigger context, appended to `description` in listing. Combined cap: 1,536 chars.          |
| `argument-hint`            | No          | Autocomplete hint, e.g. `[issue-number]`.                                                             |
| `arguments`                | No          | Named positional args for `$name` substitution. Space-separated string or YAML list.                  |
| `disable-model-invocation` | No          | `true` = user-only invocation; hides from Claude's context. Use for side-effectful workflows.         |
| `user-invocable`           | No          | `false` = hide from `/` menu. Use for background reference skills. Default: `true`.                   |
| `allowed-tools`            | No          | Tools pre-approved while skill is active. Space/comma-separated or YAML list.                         |
| `disallowed-tools`         | No          | Tools removed while skill is active. Clears on next user message.                                     |
| `model`                    | No          | Model override for current turn only.                                                                 |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                       |
| `context`                  | No          | `fork` = run in a forked subagent context.                                                            |
| `agent`                    | No          | Subagent type when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, or custom name.    |
| `hooks`                    | No          | Skill-scoped lifecycle hooks.                                                                         |
| `paths`                    | No          | Glob patterns limiting when skill auto-activates.                                                     |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                          |

### Frontmatter fields (Agent Skills spec — agentskills.io)

| Field           | Required | Constraints                                                  |
| :-------------- | :------- | :----------------------------------------------------------- |
| `name`          | Yes      | 1–64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens |
| `description`   | Yes      | 1–1024 chars. Describe what it does AND when to use it.      |
| `license`       | No       | License name or bundled file reference.                      |
| `compatibility` | No       | 1–500 chars. Environment requirements (product, packages, network). |
| `metadata`      | No       | Arbitrary key-value map for additional properties.           |
| `allowed-tools` | No       | Space-delimited pre-approved tools (experimental).           |

### Invocation control matrix

| Frontmatter                      | User can invoke | Claude can invoke | Loaded into context          |
| :------------------------------- | :-------------- | :---------------- | :--------------------------- |
| (default)                        | Yes             | Yes               | Description always; full body on invoke |
| `disable-model-invocation: true` | Yes             | No                | Not in context; full body when user invokes |
| `user-invocable: false`          | No              | Yes               | Description always; full body on invoke |

### String substitutions

| Variable               | Value                                                              |
| :--------------------- | :----------------------------------------------------------------- |
| `$ARGUMENTS`           | Full argument string passed on invocation                          |
| `$ARGUMENTS[N]`        | Argument by 0-based index                                          |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`                                      |
| `$name`                | Named argument from `arguments` frontmatter (maps to position)     |
| `${CLAUDE_SESSION_ID}` | Current session ID                                                 |
| `${CLAUDE_EFFORT}`     | Active effort level: `low`, `medium`, `high`, `xhigh`, or `max`   |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`                        |

Escape a literal `$` before a digit or known name with a backslash: `\$1.00`.

### Dynamic context injection

Two forms inject shell command output into skill content before Claude sees it:

- **Inline form**: an exclamation mark immediately followed by a backtick-wrapped command on its own line (or after whitespace). Output replaces the placeholder.
- **Block form**: a fenced code block whose opening fence is immediately followed by an exclamation mark. Runs all lines in the block as a script.

Injection runs once; output is not re-scanned. Disable org-wide with `"disableSkillShellExecution": true` in settings.

### `skillOverrides` states

| Value                   | Listed to Claude     | In `/` menu |
| :---------------------- | :------------------- | :---------- |
| `"on"` (default)        | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

### Bundled skills

`/run`, `/verify`, `/run-skill-generator`, `/code-review`, `/batch`, `/debug`, `/loop`, `/claude-api`. Disable with `disableBundledSkills` setting.

### Progressive disclosure (Agent Skills spec)

1. Metadata (~100 tokens): `name` + `description` loaded at startup for all skills
2. Instructions (< 5000 tokens recommended): full `SKILL.md` body loaded on activation
3. Resources (as needed): files in `scripts/`, `references/`, `assets/` loaded on demand

Keep `SKILL.md` under 500 lines.

### Skill content lifecycle

Once invoked, rendered `SKILL.md` content stays in context for the session. Auto-compaction re-attaches up to the first 5,000 tokens of each invoked skill, shared budget of 25,000 tokens, filled from most-recently invoked first.

### Permission control for skills

- Deny all: add `Skill` to deny rules in `/permissions`
- Allow/deny specific: `Skill(commit)`, `Skill(deploy *)` in permission rules
- Per-skill: use `disable-model-invocation: true` in frontmatter

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — Full Claude Code skills guide: creating, configuring, scopes, frontmatter, dynamic context, subagent forking, bundled skills, troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — The open standard for skill format, directory layout, frontmatter schema, and progressive disclosure

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
