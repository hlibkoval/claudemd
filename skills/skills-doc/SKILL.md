---
name: skills-doc
description: Complete documentation for Claude Code skills (Agent Skills) -- creating, configuring, sharing, and troubleshooting skills. Covers the Agent Skills open standard (SKILL.md format, frontmatter fields, directory structure, progressive disclosure, file references). Use when the user asks about authoring skills, bundled skills, slash commands merged into skills, invocation control, context forking, dynamic context injection, or troubleshooting skill activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills specification.

## Quick Reference

### What a skill is

A skill is a directory with a `SKILL.md` (YAML frontmatter + markdown body). Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard. Custom commands have been merged into skills: a file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy`.

### Where skills live (precedence: enterprise > personal > project; plugin skills are namespaced)

| Location   | Path                                      | Applies to                     |
| ---------- | ----------------------------------------- | ------------------------------ |
| Enterprise | Managed settings                          | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`  | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`    | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`   | Where plugin is enabled        |

Nested `.claude/skills/` directories are auto-discovered when working in subdirectories (monorepo support). `--add-dir` loads `.claude/skills/` from added directories (exception to the usual rule that added dirs only grant file access).

### Directory layout

```
my-skill/
├── SKILL.md           # Required: frontmatter + instructions
├── scripts/           # Optional: executable code
├── references/        # Optional: loaded on demand
├── assets/            # Optional: templates, images, data
└── ...
```

Keep `SKILL.md` under 500 lines. Move detail into `references/` and link from `SKILL.md` so Claude loads files only when needed.

### Claude Code frontmatter fields

All fields optional; `description` is strongly recommended.

| Field                      | Purpose                                                                                  |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| `name`                     | Display name, becomes `/slash-command`. Lowercase, hyphens, max 64 chars. Defaults to directory name. |
| `description`              | What the skill does and when to use it. First 250 chars are used in the skill listing.   |
| `argument-hint`            | Hint shown during autocomplete (e.g., `[issue-number]`).                                 |
| `disable-model-invocation` | `true` = only user can invoke. Skill description is NOT kept in context.                |
| `user-invocable`           | `false` = hidden from `/` menu. Only Claude can invoke. Description still in context.   |
| `allowed-tools`            | Tools pre-approved while skill is active. Space-separated or YAML list.                 |
| `model`                    | Model to use when skill is active.                                                       |
| `effort`                   | `low` / `medium` / `high` / `max` (Opus 4.6 only).                                       |
| `context`                  | Set to `fork` to run in a forked subagent context.                                       |
| `agent`                    | Subagent type when `context: fork` (e.g., `Explore`, `Plan`, `general-purpose`).         |
| `hooks`                    | Hooks scoped to this skill's lifecycle.                                                  |
| `paths`                    | Glob patterns that limit auto-activation to matching files.                              |
| `shell`                    | `bash` (default) or `powershell` for inline shell command syntax.                        |

### Agent Skills standard frontmatter fields

The upstream [agentskills.io](https://agentskills.io) spec defines a smaller core:

| Field           | Required | Notes                                                                                                            |
| --------------- | -------- | ---------------------------------------------------------------------------------------------------------------- |
| `name`          | Yes      | 1-64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens, must match directory name. |
| `description`   | Yes      | 1-1024 chars, describes both what the skill does and when to use it.                                             |
| `license`       | No       | License name or bundled license file reference.                                                                  |
| `compatibility` | No       | Max 500 chars. Environment requirements (product, system packages, network).                                     |
| `metadata`      | No       | Arbitrary string key/value map for client-specific data.                                                         |
| `allowed-tools` | No       | Space-delimited pre-approved tools list (experimental).                                                          |

### Invocation control matrix

| Frontmatter                      | User invokes | Claude invokes | Context behavior                                              |
| -------------------------------- | ------------ | -------------- | ------------------------------------------------------------- |
| (default)                        | Yes          | Yes            | Description always in context; full skill loads when invoked  |
| `disable-model-invocation: true` | Yes          | No             | Description not in context; full skill loads when you invoke  |
| `user-invocable: false`          | No           | Yes            | Description always in context; full skill loads when invoked  |

Note: `user-invocable` only controls `/` menu visibility. To block programmatic Skill tool access, use `disable-model-invocation: true` or `Skill(name)` deny rules in `/permissions`.

### Argument substitutions

| Variable               | Meaning                                                                 |
| ---------------------- | ----------------------------------------------------------------------- |
| `$ARGUMENTS`           | Full argument string as typed.                                          |
| `$ARGUMENTS[N]` / `$N` | 0-indexed positional argument (shell-style quoting for multi-word).    |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                     |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. Use for bundled scripts.   |

If you pass arguments to a skill that doesn't reference `$ARGUMENTS`, Claude Code appends `ARGUMENTS: <value>` automatically.

### Dynamic context injection (preprocessing)

Inline form: backtick-bang-command-backtick runs a shell command before the skill is sent to Claude, replacing the placeholder with the command output. Multi-line form: open a fenced code block with three backticks followed by a bang.

Disable globally with `"disableSkillShellExecution": true` in settings. Bundled and managed skills are not affected. Shell is `bash` by default; set `shell: powershell` and `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` for Windows PowerShell.

Tip: include the word `ultrathink` anywhere in skill content to enable extended thinking.

### Running skills in a subagent (`context: fork`)

| Approach                     | System prompt                    | Task                        | Also loads                   |
| ---------------------------- | -------------------------------- | --------------------------- | ---------------------------- |
| Skill with `context: fork`   | From agent type                  | SKILL.md content            | CLAUDE.md                    |
| Subagent with `skills` field | Subagent's markdown body         | Claude's delegation message | Preloaded skills + CLAUDE.md |

`context: fork` only makes sense for skills with explicit task instructions; pure reference skills will return with no output.

### Restricting skill access

- Deny all skills: add `Skill` to deny rules in `/permissions`.
- Allow/deny specific: `Skill(commit)` (exact), `Skill(review-pr *)` (prefix).
- Hide individual skills: `disable-model-invocation: true`.

### Content lifecycle

Invoked skill content enters the conversation as a single message and stays. Claude Code does not re-read the skill file later -- write guidance as standing instructions. After auto-compaction, the most recent invocation of each skill is re-attached (first 5000 tokens per skill, 25000 combined budget, most-recent-first). Re-invoke large skills after compaction if needed.

### Sharing scopes

- **Project skills**: commit `.claude/skills/` to version control.
- **Plugins**: create a `skills/` directory in a plugin (see plugins docs).
- **Managed**: deploy org-wide through managed settings.

### Troubleshooting

| Symptom                        | Fix                                                                                  |
| ------------------------------ | ------------------------------------------------------------------------------------ |
| Skill not triggering           | Add keywords to `description`; verify via `What skills are available?`; invoke `/name` directly. |
| Skill triggers too often       | Make `description` more specific; set `disable-model-invocation: true`.              |
| Descriptions cut short         | Raise `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var; front-load key use case (each entry capped at 250 chars). |
| Behavior fades after compaction| Re-invoke the skill; strengthen description/instructions; enforce via hooks.         |

### Progressive disclosure budget (Agent Skills spec)

1. **Metadata** (~100 tokens): name + description loaded at startup for all skills.
2. **Instructions** (< 5000 tokens recommended): full `SKILL.md` body loaded on activation.
3. **Resources**: files in `scripts/`, `references/`, `assets/` loaded only when required.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills (Claude Code)](references/claude-code-skills.md) -- the full Claude Code skills guide: bundled skills, frontmatter reference, supporting files, invocation control, dynamic context, subagent forking, permissions, sharing, visual-output patterns, and troubleshooting.
- [Agent Skills Specification](references/agent-skills-specification.md) -- the upstream agentskills.io format spec: directory structure, required/optional frontmatter fields, field constraints, body content, optional directories (`scripts/`, `references/`, `assets/`), progressive disclosure, file references, and validation.

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
