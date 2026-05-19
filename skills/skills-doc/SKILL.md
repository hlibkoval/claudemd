---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating skills (SKILL.md format, frontmatter fields, directory layout), skill locations and scopes, invocation control (user-invocable, disable-model-invocation), dynamic context injection, subagent forking, allowed-tools, arguments and substitutions, skill content lifecycle, skillOverrides, skill listing budget, the Agent Skills open standard, and the full SKILL.md specification (name/description/compatibility/metadata/allowed-tools fields, progressive disclosure, file references, validation).
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### What Skills Are

Skills extend Claude's capabilities via a `SKILL.md` file. Skills are invoked with `/skill-name` or loaded automatically when relevant. Unlike CLAUDE.md content, a skill's body loads only when used.

Custom commands (`.claude/commands/*.md`) and skills (`.claude/skills/<name>/SKILL.md`) are equivalent; skills add a directory for supporting files and more frontmatter options.

### Skill Directory Layout

```text
my-skill/
├── SKILL.md        # Required: frontmatter + instructions
├── references/     # Optional: detailed docs, loaded on demand
├── scripts/        # Optional: executable code
└── assets/         # Optional: templates, static resources
```

### Skill Locations and Scopes

| Location   | Path                                              | Applies to                     |
| :--------- | :------------------------------------------------ | :----------------------------- |
| Enterprise | Managed settings                                  | All users in organization      |
| Personal   | `~/.claude/skills/<name>/SKILL.md`                | All your projects              |
| Project    | `.claude/skills/<name>/SKILL.md`                  | This project only              |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`                 | Where plugin is enabled        |

Enterprise overrides personal; personal overrides project. Plugin skills use `plugin-name:skill-name` namespace. If a skill and a command share the same name, the skill takes precedence.

### SKILL.md Frontmatter Fields (Claude Code)

| Field                      | Required    | Description |
| :------------------------- | :---------- | :---------- |
| `name`                     | No          | Display name; defaults to directory name. Lowercase, numbers, hyphens, max 64 chars. |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this to decide when to apply it. |
| `when_to_use`              | No          | Additional trigger phrases/examples. Appended to `description` in skill listing. |
| `argument-hint`            | No          | Hint shown in autocomplete, e.g. `[issue-number]`. |
| `arguments`                | No          | Named positional args for `$name` substitution; space-separated string or YAML list. |
| `disable-model-invocation` | No          | `true` = only you can invoke; removes from Claude's context entirely. |
| `user-invocable`           | No          | `false` = hidden from `/` menu; Claude can still load automatically. |
| `allowed-tools`            | No          | Tools Claude can use without approval when this skill is active. |
| `model`                    | No          | Override model for this skill's turn only. |
| `effort`                   | No          | Override effort level: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context`                  | No          | `fork` = run in an isolated subagent context. |
| `agent`                    | No          | Which subagent type to use when `context: fork` is set. |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle. |
| `paths`                    | No          | Glob patterns limiting when this skill auto-activates. |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`. |

### Invocation Control

| Frontmatter                      | You can invoke | Claude can invoke | In context |
| :------------------------------- | :------------- | :---------------- | :--------- |
| (default)                        | Yes            | Yes               | Description always in context |
| `disable-model-invocation: true` | Yes            | No                | Description NOT in context |
| `user-invocable: false`          | No             | Yes               | Description always in context |

### String Substitutions

| Variable               | Description |
| :--------------------- | :---------- |
| `$ARGUMENTS`           | All arguments passed when invoking the skill. |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index. |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`. |
| `$name`                | Named argument declared in `arguments` frontmatter. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_EFFORT}`     | Current effort level. |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. |

Multi-word arguments use shell-style quoting: `/my-skill "hello world" second` makes `$0` = `hello world`.

### Dynamic Context Injection

Two forms — note: do not reproduce the literal tokens in documentation or they will execute at skill load time.

- **Inline form:** an exclamation mark immediately followed by a backtick-wrapped shell command. The command runs before Claude sees the skill, and its output replaces the placeholder.
- **Multi-line form:** a fenced code block whose opening fence (three backticks) is immediately followed by an exclamation mark. Runs multiple commands, output replaces the block.

Substitution runs once; command output is not re-scanned for further placeholders. To disable for untrusted sources, set `"disableSkillShellExecution": true` in settings.

### Subagent Forking (`context: fork`)

| Approach                     | System prompt      | Task               | Also loads |
| :--------------------------- | :----------------- | :----------------- | :--------- |
| Skill with `context: fork`   | From agent type    | SKILL.md content   | CLAUDE.md (except with Explore/Plan agent) |
| Subagent with `skills` field | Subagent markdown  | Claude's delegation | Preloaded skills + CLAUDE.md |

Built-in agent options: `Explore`, `Plan`, `general-purpose`, or any custom agent from `.claude/agents/`. Defaults to `general-purpose`.

### Skill Content Lifecycle

- When invoked, rendered SKILL.md content enters the conversation as a single message and stays for the rest of the session.
- Auto-compaction carries skills forward within a token budget: most recent invocation of each skill is re-attached after summary (first 5,000 tokens each; combined budget of 25,000 tokens).
- Older skills may be dropped entirely after compaction if many were invoked.

### Skill Listing Budget

All skill names are always in context. Descriptions are truncated if you have many skills (budget = 1% of context window by default). Adjust with `skillListingBudgetFraction` setting or `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. Each description+`when_to_use` is capped at 1,536 chars (configurable via `maxSkillDescriptionChars`). Run `/doctor` to check budget overflow.

### `skillOverrides` Setting

Control skill visibility from settings instead of editing SKILL.md (e.g., for shared project skills):

| Value                   | Listed to Claude     | In `/` menu |
| :---------------------- | :------------------- | :---------- |
| `"on"` (default)        | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

Plugin skills are not affected by `skillOverrides`.

### Restrict Claude's Skill Access

```text
# Deny all skills:
Skill

# Allow only specific skills:
Skill(commit)
Skill(review-pr *)

# Deny specific skills:
Skill(deploy *)
```

Syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with arguments.

### Agent Skills Specification (Open Standard)

SKILL.md frontmatter fields per the open standard:

| Field           | Required | Constraints |
| :-------------- | :------- | :---------- |
| `name`          | Yes      | Max 64 chars. Lowercase letters, numbers, hyphens. No leading/trailing/consecutive hyphens. Must match directory name. |
| `description`   | Yes      | Max 1,024 chars. Non-empty. Should describe what and when. |
| `license`       | No       | License name or bundled file reference. |
| `compatibility` | No       | Max 500 chars. Environment requirements (product, packages, network). |
| `metadata`      | No       | Arbitrary key-value mapping. |
| `allowed-tools` | No       | Space-delimited pre-approved tools. (Experimental) |

**Progressive disclosure tiers:**
1. Metadata (~100 tokens): `name` and `description` loaded at startup for all skills
2. Instructions (<5,000 tokens recommended): full `SKILL.md` body loaded on activation
3. Resources (as needed): files in `scripts/`, `references/`, `assets/` loaded on demand

Keep `SKILL.md` under 500 lines. Validate with `skills-ref validate ./my-skill`.

### Bundled Skills

Claude Code includes built-in prompt-based skills: `/simplify`, `/batch`, `/debug`, `/loop`, `/claude-api`. Listed alongside built-in commands in the commands reference, marked **Skill** in the Purpose column.

### Discovery and Change Detection

- Project skills load from `.claude/skills/` in the starting directory and all parent directories up to repo root.
- Nested `.claude/skills/` in subdirectories are also discovered on demand (supports monorepos).
- File changes (add/edit/remove) take effect within the current session without restart.
- A brand-new top-level skills directory requires restarting Claude Code.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, frontmatter fields, invocation control, dynamic context injection, subagent forking, allowed-tools, arguments, skill lifecycle, skillOverrides, sharing, troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — open standard SKILL.md format, directory structure, frontmatter fields, body content, optional directories, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
