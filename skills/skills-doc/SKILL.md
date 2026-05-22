---
name: skills-doc
description: Complete official documentation for Claude Code skills — SKILL.md format, frontmatter fields (name, description, user-invocable, disable-model-invocation, allowed-tools, context, agent, model, effort, hooks, paths, arguments, argument-hint, when_to_use, shell), string substitutions ($ARGUMENTS, $N, $ARGUMENTS[N], named args, ${CLAUDE_SESSION_ID}, ${CLAUDE_EFFORT}, ${CLAUDE_SKILL_DIR}), dynamic context injection (inline and multi-line forms), skill scopes and load order, invocation control, subagent forking (context: fork), skill content lifecycle, skillOverrides, bundled skills, and the Agent Skills open standard specification (directory structure, validation).
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### What Skills Are

Skills extend Claude's capabilities via a `SKILL.md` file containing YAML frontmatter and markdown instructions. Claude loads skills automatically when relevant, or you can invoke them directly with `/skill-name`. Unlike CLAUDE.md content, a skill's body loads only when it is used.

### Skill Directory Structure

```
skill-name/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Optional: detailed reference docs
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, resources
```

Keep `SKILL.md` under 500 lines. Move detailed material to supporting files.

### Where Skills Live (Scope and Load Order)

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

When skills share the same name across levels, enterprise overrides personal, and personal overrides project. Plugin skills use a `plugin-name:skill-name` namespace. Skills also load from `.claude/skills/` inside `--add-dir` directories. Live change detection picks up edits without restarting (except adding a brand-new top-level skills directory).

### Frontmatter Reference

All fields are optional except `description` (recommended so Claude knows when to use the skill).

| Field | Description |
| :--- | :--- |
| `name` | Display name. Lowercase, numbers, hyphens only; max 64 chars. Defaults to directory name. |
| `description` | What the skill does and when to use it. Combined with `when_to_use`, capped at 1,536 chars in the skill listing. |
| `when_to_use` | Extra trigger context appended to `description` in the listing. |
| `argument-hint` | Shown in autocomplete. Example: `[issue-number]`. |
| `arguments` | Named positional args for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | `true` — only you can invoke; description hidden from Claude's context; also prevents preloading into subagents. |
| `user-invocable` | `false` — hides from `/` menu; Claude can still invoke. |
| `allowed-tools` | Tools pre-approved for use while skill is active. Space-separated or YAML list. |
| `model` | Model override for this skill's turn (not saved to settings). |
| `effort` | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | Set to `fork` to run in an isolated subagent context. |
| `agent` | Subagent type for `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, or custom. |
| `hooks` | Hooks scoped to this skill's lifecycle. |
| `paths` | Glob patterns; skill auto-activates only when working with matching files. |
| `shell` | Shell for inline injection commands: `bash` (default) or `powershell`. |

### Invocation Control

| Frontmatter | You can invoke | Claude can invoke | When loaded into context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always; full skill loads on invocation |
| `disable-model-invocation: true` | Yes | No | Description not in context; full skill loads when you invoke |
| `user-invocable: false` | No | Yes | Description always; full skill loads on invocation |

### String Substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | All arguments passed at invocation; appended as `ARGUMENTS: <value>` if not in content |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named argument from `arguments` frontmatter list |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's `SKILL.md` |

Multi-word arguments must be quoted: `/my-skill "hello world" second` → `$0` = `hello world`, `$1` = `second`.

### Dynamic Context Injection

Skills support two forms of shell injection that execute before Claude sees the content:

**Inline form:** An exclamation mark immediately followed by a backtick-wrapped shell command at the start of a line or after whitespace. The command output replaces the token. Does not trigger when `!` follows another character (e.g., `KEY=!...`).

**Multi-line form:** A fenced code block whose opening fence (three backticks) is immediately followed by an exclamation mark. All commands in the block execute and their combined output replaces the block.

Both forms are preprocessing — Claude only sees the rendered output, not the original tokens. Command output is inserted as plain text and not re-scanned for further expansion. To disable for user/project/plugin skills, set `"disableSkillShellExecution": true` in settings.

### Skill Content Lifecycle

- When invoked, the rendered `SKILL.md` enters the conversation as a single message and stays for the rest of the session.
- Claude Code does not re-read the file on later turns.
- On auto-compaction, invoked skills are re-attached after the summary (first 5,000 tokens each; 25,000 token combined budget, filled from most-recently-invoked first).

### Subagent Forking (`context: fork`)

Add `context: fork` to run the skill in an isolated subagent. The skill content becomes the subagent's prompt (no access to conversation history).

| Approach | System prompt | Task | Also loads |
| :--- | :--- | :--- | :--- |
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md, except for Explore or Plan agents |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

### Controlling Claude's Skill Access

| Method | How |
| :--- | :--- |
| Disable all skills | Deny the `Skill` tool in `/permissions` |
| Allow specific skills | `Skill(commit)`, `Skill(review-pr *)` |
| Deny specific skills | Add `Skill(deploy *)` to deny rules |
| Hide from Claude | `disable-model-invocation: true` in frontmatter |

### `skillOverrides` Setting

Controls skill visibility from settings without editing the skill's frontmatter. The `/skills` menu writes it for you (highlight a skill, press `Space` to cycle, `Enter` to save).

| Value | Listed to Claude | In `/` menu |
| :--- | :--- | :--- |
| `"on"` | Name and description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

Plugin skills are not affected by `skillOverrides`.

### Bundled Skills

Claude Code ships with bundled skills available in every session. Key ones:

| Skill | Purpose |
| :--- | :--- |
| `/run` | Launch and drive your app to see a change working |
| `/verify` | Build and run the app to confirm a change (requires v2.1.145+) |
| `/run-skill-generator` | Record your project's build/launch recipe for `/run` and `/verify` |
| `/code-review` | Review code for correctness |
| `/debug` | Debug a problem |
| `/loop` | Run a prompt or command on a recurring interval |
| `/claude-api` | Build and optimize Claude API apps |

### Agent Skills Open Standard

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard. Key spec rules for `SKILL.md` frontmatter:

| Field | Required | Constraints |
| :--- | :--- | :--- |
| `name` | Yes | 1–64 chars; lowercase letters, numbers, hyphens; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | Yes | 1–1024 chars; describe what the skill does and when to use it |
| `license` | No | License name or reference to a bundled license file |
| `compatibility` | No | 1–500 chars; environment requirements (OS, packages, network) |
| `metadata` | No | Arbitrary key-value mapping |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

Validate a skill with the `skills-ref` reference library:

```bash
skills-ref validate ./my-skill
```

### Skill Description Budget

All skill descriptions are loaded into context so Claude knows what's available. If you have many skills, descriptions are shortened to fit the budget (1% of model context window by default). To adjust: set `skillListingBudgetFraction` in settings (e.g. `0.02` = 2%), set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var to a fixed character count, or set low-priority entries to `"name-only"` in `skillOverrides`. Individual entries are capped at 1,536 combined chars (`description` + `when_to_use`); configurable with `maxSkillDescriptionChars`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — getting started, skill creation, frontmatter reference, string substitutions, dynamic context injection, invocation control, subagent forking, bundled skills, sharing, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — open standard directory structure, SKILL.md format and frontmatter schema, progressive disclosure model, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
