---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the underlying Agent Skills open standard.

## Quick Reference

A **skill** is a directory with a `SKILL.md` file containing YAML frontmatter and Markdown instructions. Claude loads the description at startup and loads the full body when the skill is invoked. Custom commands have been merged into skills: `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy`.

### Where skills live

| Location   | Path                                                | Applies to                     |
| :--------- | :-------------------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                                    | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`            | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`              | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`             | Where plugin is enabled        |

Precedence: enterprise > personal > project. Plugin skills use a `plugin-name:skill-name` namespace and cannot conflict with other levels. Skills win over same-named files in `.claude/commands/`. Live change detection picks up edits within the current session; creating a new top-level skills directory requires a restart.

### Standard directory layout

```
my-skill/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable code Claude can run
├── references/       # Optional: detailed docs loaded on demand
├── assets/           # Optional: templates, images, data files
└── ...               # Anything else
```

Reference supporting files from `SKILL.md` so Claude knows what to load. Keep `SKILL.md` under 500 lines and reference files one level deep.

### Agent Skills spec frontmatter

Required by the open Agent Skills standard (https://agentskills.io):

| Field           | Required | Constraints                                                                                              |
| :-------------- | :------- | :------------------------------------------------------------------------------------------------------- |
| `name`          | Yes      | 1-64 chars, lowercase `a-z`, digits, hyphens; no leading/trailing/consecutive hyphens; matches dir name. |
| `description`   | Yes      | 1-1024 chars. Describe what the skill does and when to use it. Include trigger keywords.                 |
| `license`       | No       | License name or path to a bundled license file.                                                          |
| `compatibility` | No       | Max 500 chars. Note environment requirements (product, packages, network, etc.).                         |
| `metadata`      | No       | Arbitrary string-to-string map for client-specific metadata.                                             |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools. Experimental; varies between agents.                         |

### Claude Code-specific frontmatter

Claude Code accepts every spec field above and adds these:

| Field                      | Purpose                                                                                              |
| :------------------------- | :--------------------------------------------------------------------------------------------------- |
| `when_to_use`              | Extra trigger context appended to `description` (counts toward 1,536-char cap).                      |
| `argument-hint`            | Autocomplete hint, e.g. `[issue-number]`.                                                            |
| `disable-model-invocation` | `true` blocks Claude from auto-invoking; only the user can run it. Hides the description from context.|
| `user-invocable`           | `false` hides the skill from the `/` menu (still loadable by Claude). Default `true`.                |
| `model`                    | Override the session model while this skill is active.                                               |
| `effort`                   | `low` / `medium` / `high` / `max` (Opus 4.6). Overrides session effort.                              |
| `context`                  | Set to `fork` to run in a forked subagent context.                                                   |
| `agent`                    | When `context: fork`, picks the subagent type (`Explore`, `Plan`, `general-purpose`, custom).        |
| `hooks`                    | Hooks scoped to this skill's lifecycle.                                                              |
| `paths`                    | Glob patterns; auto-load only when working with matching files.                                      |
| `shell`                    | `bash` (default) or `powershell` for inline shell injection.                                         |

### Invocation matrix

| Frontmatter                      | User can invoke | Claude can invoke | Description in context  |
| :------------------------------- | :-------------- | :---------------- | :---------------------- |
| (default)                        | Yes             | Yes               | Always                  |
| `disable-model-invocation: true` | Yes             | No                | Hidden                  |
| `user-invocable: false`          | No              | Yes               | Always                  |

`user-invocable` only controls menu visibility — to truly block Claude from invoking a skill, use `disable-model-invocation: true` or deny it via permissions (`Skill(name)` for exact, `Skill(name *)` for prefix).

### Argument substitutions

| Variable               | Meaning                                                                  |
| :--------------------- | :----------------------------------------------------------------------- |
| `$ARGUMENTS`           | Full argument string. Auto-appended as `ARGUMENTS: ...` if not present.  |
| `$ARGUMENTS[N]` / `$N` | Positional argument by 0-based index, shell-style quoted.                |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                      |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md` (use for bundled scripts).   |

### Dynamic context injection

Use the inline shell-injection syntax (a bang followed by a backticked command) to run a command before the skill content is sent to Claude — the output replaces the placeholder. Use a fenced code block opened with three backticks plus a bang for multi-line shell blocks. Disable globally with `"disableSkillShellExecution": true` in settings.

### Run skills in a subagent

| Approach                     | System prompt                             | Task                        | Also loads                   |
| :--------------------------- | :---------------------------------------- | :-------------------------- | :--------------------------- |
| Skill with `context: fork`   | From agent type (`Explore`, `Plan`, etc.) | SKILL.md content            | CLAUDE.md                    |
| Subagent with `skills` field | Subagent's markdown body                  | Claude's delegation message | Preloaded skills + CLAUDE.md |

`context: fork` only makes sense for skills with explicit task instructions, not pure reference content.

### Progressive disclosure budget

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills.
2. **Instructions** (<5,000 tokens recommended): full `SKILL.md` body loaded on activation.
3. **Resources**: files in `scripts/`, `references/`, `assets/` loaded only when needed.

After auto-compaction, Claude Code re-attaches the most recent invocation of each skill (first 5,000 tokens each) within a combined 25,000-token budget, filled most-recent first.

### Sharing scopes

- **Project**: commit `.claude/skills/` to version control.
- **Plugins**: ship a `skills/` directory in your plugin.
- **Managed**: deploy organization-wide via managed settings.

### Troubleshooting

| Symptom                          | Fix                                                                                       |
| :------------------------------- | :---------------------------------------------------------------------------------------- |
| Skill not triggering             | Add trigger keywords to `description`; verify it shows in "What skills are available?"; rephrase request; invoke directly with `/name`. |
| Skill triggers too often         | Tighten `description`; set `disable-model-invocation: true` for manual-only.              |
| Description gets cut off         | Front-load the key use case; raise `SLASH_COMMAND_TOOL_CHAR_BUDGET`; combined text is capped at 1,536 chars per entry. |
| Skill stops influencing behavior | Content usually still present; strengthen description or use hooks to enforce; re-invoke after compaction to restore. |

### Validation

Validate skills against the open standard with the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library: `skills-ref validate ./my-skill` checks frontmatter and naming.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — Full Claude Code skills guide: bundled skills, getting started, where skills live (with live change detection and additional-directory loading), frontmatter reference, supporting files, invocation control, content lifecycle, allowed-tools, argument passing, dynamic context injection, running skills in a subagent, restricting Claude's skill access, sharing, generating visual output, and troubleshooting.
- [Agent Skills specification](references/agent-skills-specification.md) — The portable Agent Skills open standard: directory structure, full `SKILL.md` format, every spec frontmatter field with constraints and examples, body content guidance, optional `scripts/`/`references/`/`assets/` directories, progressive disclosure, file references, and validation with `skills-ref`.

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
