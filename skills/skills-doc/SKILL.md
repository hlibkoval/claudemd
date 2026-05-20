---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating and configuring SKILL.md files (frontmatter fields, body content, string substitutions, dynamic context injection, subagent forking), skill scopes (personal/project/plugin/enterprise), invocation control (user-invocable, disable-model-invocation), allowed-tools, skill content lifecycle, skillOverrides, arguments, supporting files, bundled skills (/run /verify /simplify etc.), and the Agent Skills open standard (SKILL.md format, directory structure, validation).
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### What Skills Are

Skills extend Claude's capabilities via `SKILL.md` files containing instructions. Invoke directly with `/skill-name` or let Claude load them automatically. Unlike CLAUDE.md content, a skill's body loads only when used — long reference material costs nothing until needed.

### Skill Directory Structure

```
skill-name/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Optional: detailed reference docs
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, static resources
```

Keep `SKILL.md` under 500 lines. Move detailed material to supporting files referenced from `SKILL.md`.

### Where Skills Live

| Location   | Path                                             | Applies to                     |
| :--------- | :----------------------------------------------- | :----------------------------- |
| Enterprise | See managed settings                             | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where plugin is enabled        |

Name conflicts: enterprise overrides personal, personal overrides project. Plugin skills use `plugin-name:skill-name` namespace. Skills take precedence over same-named `.claude/commands/` files.

### Frontmatter Reference

| Field                      | Required    | Description                                                                                                        |
| :------------------------- | :---------- | :----------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Display name. If omitted, uses directory name. Lowercase letters, numbers, hyphens only (max 64 chars).            |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this for auto-invocation. First 1,536 chars count toward budget. |
| `when_to_use`              | No          | Additional trigger context appended to `description` in skill listing (counts toward 1,536-char cap).             |
| `argument-hint`            | No          | Autocomplete hint, e.g. `[issue-number]` or `[filename] [format]`.                                               |
| `arguments`                | No          | Named positional arguments for `$name` substitution. Space-separated string or YAML list.                         |
| `disable-model-invocation` | No          | `true` prevents Claude auto-loading. Use for side-effect workflows you want to control manually.                   |
| `user-invocable`           | No          | `false` hides from `/` menu. Use for background knowledge not actionable as a command.                             |
| `allowed-tools`            | No          | Tools Claude can use without per-use approval when this skill is active.                                           |
| `model`                    | No          | Model override for this skill's turn; session model resumes on next prompt.                                        |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                                   |
| `context`                  | No          | `fork` to run in an isolated subagent context.                                                                     |
| `agent`                    | No          | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, `general-purpose`, or custom agent name).      |
| `hooks`                    | No          | Skill-scoped lifecycle hooks.                                                                                      |
| `paths`                    | No          | Glob patterns limiting when skill auto-activates (comma-separated string or YAML list).                           |
| `shell`                    | No          | Shell for inline injection commands: `bash` (default) or `powershell`.                                            |

### Invocation Control

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                     |
| :------------------------------- | :------------- | :---------------- | :----------------------------------------------------------- |
| (default)                        | Yes            | Yes               | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes            | No                | Description not in context, full skill loads when you invoke |
| `user-invocable: false`          | No             | Yes               | Description always in context, full skill loads when invoked |

### String Substitutions

| Variable               | Description                                                                                              |
| :--------------------- | :------------------------------------------------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed to the skill. If absent, arguments appended as `ARGUMENTS: <value>`.               |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index.                                                                      |
| `$N`                   | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`).                                                        |
| `$name`                | Named argument declared in `arguments` frontmatter, maps to position in order.                           |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                                                      |
| `${CLAUDE_EFFORT}`     | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`.                                       |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. Use to reference bundled scripts regardless of cwd.        |

Wrap multi-word arguments in quotes: `/my-skill "hello world" second` → `$0` = `hello world`, `$1` = `second`.

### Dynamic Context Injection

Two forms for running shell commands before Claude sees the skill content:

- **Inline form:** an exclamation mark immediately followed by a backtick-wrapped command on its own line or after whitespace. The output replaces the placeholder in-place.
- **Multi-line form:** a fenced code block whose opening fence (three backticks) is immediately followed by an exclamation mark. All commands inside run; their combined output replaces the block.

This is preprocessing — Claude only sees the final rendered output, not the commands themselves. Substitution runs once; command output is not re-scanned for further injection placeholders.

Disable for user/project/plugin/additional-directory skills with `"disableSkillShellExecution": true` in settings (managed skills unaffected).

### Subagent Forking (`context: fork`)

Add `context: fork` when a skill should run in isolation without access to conversation history. The skill content becomes the subagent's prompt.

| Approach                     | System prompt       | Task                | Also loads                                          |
| :--------------------------- | :------------------ | :------------------ | :-------------------------------------------------- |
| Skill with `context: fork`   | From agent type     | SKILL.md content    | CLAUDE.md, except when agent is Explore or Plan     |
| Subagent with `skills` field | Subagent's markdown | Claude's delegation | Preloaded skills + CLAUDE.md                        |

Only use `context: fork` for skills with explicit task instructions, not reference-only content.

### Skill Content Lifecycle

- On invoke: rendered `SKILL.md` enters the conversation as a single message and stays for the rest of the session. Claude does not re-read the file on later turns.
- After compaction: skills are re-attached within a 25,000-token budget (first 5,000 tokens each), starting from most recently invoked. Older skills may be dropped.
- If a skill stops influencing behavior, re-invoke it after compaction to restore full content.

### skillOverrides

Override skill visibility from settings without editing `SKILL.md`. The `/skills` menu writes this for you (highlight skill, press Space, then Enter).

| Value                   | Listed to Claude     | In `/` menu |
| :---------------------- | :------------------- | :---------- |
| `"on"`                  | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

Absent from `skillOverrides` = treated as `"on"`. Plugin skills not affected; manage via `/plugin`.

### Restricting Claude's Skill Access

- **Deny all skills:** add `Skill` to deny rules in `/permissions`.
- **Allow/deny specific skills:** use `Skill(name)` (exact) or `Skill(name *)` (prefix) in permission rules.
- **Hide individual skills:** add `disable-model-invocation: true` to their frontmatter.

Note: `user-invocable` only controls menu visibility, not Skill tool access.

### Bundled Skills

| Skill                   | Purpose                                                        |
| :---------------------- | :------------------------------------------------------------- |
| `/run`                  | Launch and drive your app to see a change working              |
| `/verify`               | Confirm a code change does what it should against the running app |
| `/run-skill-generator`  | Record a project's build/launch recipe so `/run` and `/verify` use it |
| `/simplify`             | Review changed code for quality and efficiency                 |
| `/debug`                | Debug an issue                                                 |
| `/loop`                 | Run a prompt on a recurring interval                           |
| `/batch`                | Run multiple tasks in parallel                                 |
| `/claude-api`           | Build and optimize Claude API apps                             |

`/run`, `/verify`, and `/run-skill-generator` require Claude Code v2.1.145+.

### Skill Description Budget

All skill names always load into context; descriptions are shortened if the budget overflows. The budget scales at 1% of the model's context window. To tune:

- Raise budget: `skillListingBudgetFraction` setting (e.g. `0.02`) or `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.
- Free budget: set low-priority skills to `"name-only"` in `skillOverrides`.
- Cap per entry: 1,536 characters (combined `description` + `when_to_use`); configurable with `maxSkillDescriptionChars`.

Run `/doctor` to check whether the budget is overflowing and which skills are affected.

### Troubleshooting

| Symptom                     | Fix                                                                                                  |
| :-------------------------- | :--------------------------------------------------------------------------------------------------- |
| Skill not triggering        | Check description keywords; verify skill appears in `What skills are available?`; invoke directly with `/skill-name` |
| Skill triggers too often    | Make description more specific; add `disable-model-invocation: true` for manual-only invocation     |
| Descriptions cut short      | Check `/doctor`; use `skillOverrides` to set low-priority skills to `"name-only"`; trim description  |

### Agent Skills Open Standard — SKILL.md Frontmatter

The Agent Skills spec (agentskills.io) defines a portable SKILL.md format. Key fields:

| Field           | Required | Constraints                                                                 |
| :-------------- | :------- | :-------------------------------------------------------------------------- |
| `name`          | Yes      | Max 64 chars. Lowercase letters, numbers, hyphens only. No leading/trailing/consecutive hyphens. Must match directory name. |
| `description`   | Yes      | Max 1,024 chars. Describes what the skill does and when to use it.          |
| `license`       | No       | License name or reference to bundled license file.                          |
| `compatibility` | No       | Max 500 chars. Environment requirements (product, packages, network, etc.). |
| `metadata`      | No       | Arbitrary key-value mapping for additional metadata.                        |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools (experimental).                  |

Validate with the `skills-ref` reference library: `skills-ref validate ./my-skill`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, skill scopes, frontmatter reference, string substitutions, dynamic context injection, subagent forking, invocation control, allowed-tools, skill content lifecycle, skillOverrides, bundled skills, troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — portable SKILL.md format, directory structure, frontmatter fields, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
