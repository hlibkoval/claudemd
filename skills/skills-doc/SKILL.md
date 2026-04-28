---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit — loading it automatically when relevant or when you invoke it with `/skill-name`.

### Skill locations (precedence: enterprise > personal > project)

| Scope      | Path                                              | Applies to                     |
| :--------- | :------------------------------------------------ | :----------------------------- |
| Enterprise | Managed settings                                  | All users in organization      |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`          | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`            | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`           | Where plugin is enabled        |

Plugin skills use `plugin-name:skill-name` namespace to avoid conflicts. When names collide across levels, enterprise overrides personal, personal overrides project.

### Skill directory layout

```
my-skill/
├── SKILL.md           # Required — main instructions and frontmatter
├── references/        # Optional — detailed docs loaded on demand
├── scripts/           # Optional — executable code Claude can run
└── assets/            # Optional — templates, data files, images
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Frontmatter fields

All fields are optional except where noted. Only `description` is strongly recommended.

| Field                      | Required    | Description |
| :------------------------- | :---------- | :---------- |
| `name`                     | No          | Lowercase letters, numbers, hyphens only (max 64 chars). Defaults to directory name. Becomes the `/slash-command`. |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this for automatic loading. Front-load the key use case; combined `description` + `when_to_use` capped at 1,536 characters in skill listing. |
| `when_to_use`              | No          | Additional trigger context, appended to `description` in the skill listing. |
| `argument-hint`            | No          | Autocomplete hint, e.g. `[issue-number]` or `[filename] [format]`. |
| `arguments`                | No          | Named positional arguments for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No          | `true` = only you can invoke; removes from Claude's context entirely. Use for side-effect workflows like `/deploy` or `/commit`. |
| `user-invocable`           | No          | `false` = hidden from `/` menu; only Claude can invoke. Use for background knowledge skills. Default: `true`. |
| `allowed-tools`            | No          | Tools Claude can use without per-use approval while this skill is active. Space-separated or YAML list. |
| `model`                    | No          | Model override for this skill's turn. Accepts same values as `/model`. Resets after the turn. |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context`                  | No          | Set to `fork` to run skill in an isolated subagent. |
| `agent`                    | No          | Subagent type when `context: fork` is set. Options: `Explore`, `Plan`, `general-purpose`, or any custom subagent. |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle. |
| `paths`                    | No          | Glob patterns that limit automatic activation to matching files. |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`. |

### Invocation control matrix

| Frontmatter                      | You can invoke | Claude can invoke | Loaded into context |
| :------------------------------- | :------------- | :---------------- | :------------------ |
| (default)                        | Yes            | Yes               | Description always; full content on invoke |
| `disable-model-invocation: true` | Yes            | No                | Not in context; full content when you invoke |
| `user-invocable: false`          | No             | Yes               | Description always; full content on invoke |

### String substitutions

| Variable               | Description |
| :--------------------- | :---------- |
| `$ARGUMENTS`           | All arguments passed at invocation. If not present in content, appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index. |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`. |
| `$name`                | Named argument declared in `arguments` frontmatter. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_EFFORT}`     | Current effort level. |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. Useful for referencing bundled scripts. |

Wrap multi-word arguments in quotes: `/my-skill "hello world" second` makes `$0` = `hello world`, `$1` = `second`.

### Dynamic context injection

Use `` !`<command>` `` to run shell commands before the skill is sent to Claude. Output replaces the placeholder — Claude sees the result, not the command.

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
```

For multi-line commands, use a fenced block opened with ` ```! `.

Disable shell execution for all user/project/plugin skills: set `"disableSkillShellExecution": true` in settings.

### Running skills in a subagent

Add `context: fork` to isolate the skill in a new context. The skill content becomes the subagent's prompt; it has no access to conversation history.

| Approach                   | System prompt           | Task               | Also loads            |
| :------------------------- | :---------------------- | :----------------- | :-------------------- |
| Skill with `context: fork` | From agent type         | SKILL.md content   | CLAUDE.md             |
| Subagent with `skills:`    | Subagent's markdown     | Delegation message | Preloaded skills + CLAUDE.md |

### Skill content lifecycle

- Rendered `SKILL.md` enters the conversation as a single message and stays for the session.
- Auto-compaction carries skills forward (first 5,000 tokens per skill, 25,000 token shared budget).
- Skills are re-attached most-recent-first after compaction; old skills may be dropped if many were invoked.

### Progressive disclosure (Agent Skills open standard)

| Layer            | Tokens          | When loaded |
| :--------------- | :-------------- | :---------- |
| Metadata (`name` + `description`) | ~100 | Always, at startup |
| `SKILL.md` body  | < 5,000 recommended | When skill is activated |
| Supporting files | As needed       | On demand only |

### Controlling Claude's skill access

**Deny the Skill tool entirely** (in `/permissions`):
```
Skill
```

**Allow or deny specific skills**:
```
Skill(commit)          # exact match
Skill(review-pr *)     # prefix match
```

**Hide from Claude** by setting `disable-model-invocation: true` in frontmatter.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Skill not triggering | Check description has natural keywords; verify it appears in "What skills are available?"; try invoking directly with `/skill-name` |
| Skill triggers too often | Narrow the description; add `disable-model-invocation: true` |
| Descriptions cut short | Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var; trim `description`/`when_to_use` and front-load key use case |
| Skill stops influencing after first response | Content is likely still present — strengthen description and instructions; re-invoke after compaction |

### Agent Skills open standard — `name` constraints

`name` in the spec is **required** (Claude Code makes it optional, defaulting to directory name):

- 1–64 characters
- Lowercase alphanumeric and hyphens only (`a-z`, `0-9`, `-`)
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name

### Sharing skills

| Method | How |
| :--- | :--- |
| Project | Commit `.claude/skills/` to version control |
| Plugin | Add `skills/` directory in your plugin |
| Managed | Deploy organization-wide via managed settings |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — full Claude Code skills guide covering getting started, skill locations, frontmatter reference, string substitutions, dynamic context injection, subagent execution, invocation control, tool pre-approval, arguments, visual output patterns, sharing, and troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — open standard format for SKILL.md files, required and optional frontmatter fields, directory structure, progressive disclosure, file references, validation, and the skills-ref validation tool

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
