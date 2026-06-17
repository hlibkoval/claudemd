---
name: skills-doc
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills — creating, configuring, and sharing skills (custom commands), including the Agent Skills open standard specification.

## Quick Reference

### Skill Locations

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

**Precedence:** enterprise > personal > project. Plugin skills are namespaced (`plugin-name:skill-name`) and cannot conflict. Skills override bundled skills of the same name. A skill at any scope takes precedence over a same-named `.claude/commands/` file.

### SKILL.md Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Display name (in listings). Lowercase, hyphens, max 64 chars. Must match directory name (except plugin root). |
| `description` | Recommended | What the skill does and when to use it. Claude uses this for auto-invocation. Capped at 1,536 chars in listing. |
| `when_to_use` | No | Extra trigger context appended to `description` (counts toward 1,536-char cap). |
| `argument-hint` | No | Hint shown in autocomplete, e.g. `[issue-number]`. |
| `arguments` | No | Named positional args for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No | `true` = only user can invoke; hides skill from Claude's context entirely. Default: `false`. |
| `user-invocable` | No | `false` = hides from `/` menu (Claude still auto-invokes). Default: `true`. |
| `allowed-tools` | No | Tools pre-approved for this skill (no per-use prompt). Space/comma-separated or YAML list. |
| `disallowed-tools` | No | Tools removed from Claude's pool while skill is active (clears on next message). |
| `model` | No | Model override for this skill's turn. Accepts same values as `/model` or `inherit`. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | No | Set to `fork` to run in an isolated subagent context. |
| `agent` | No | Subagent type when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, or any custom agent. |
| `hooks` | No | Lifecycle hooks scoped to this skill. |
| `paths` | No | Glob patterns — skill auto-activates only when working with matching files. |
| `shell` | No | Shell for dynamic context injection: `bash` (default) or `powershell`. |

### Invocation Control Matrix

| Frontmatter | User can invoke | Claude can invoke | Loaded into context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always; full content when invoked |
| `disable-model-invocation: true` | Yes | No | Not in context; loads only when user invokes |
| `user-invocable: false` | No | Yes | Description always; full content when invoked |

### String Substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | All arguments passed at invocation |
| `$ARGUMENTS[N]` | Argument at 0-based index N |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named arg declared in `arguments` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level string |
| `${CLAUDE_SKILL_DIR}` | Absolute path to the skill's directory |

Wrap multi-word values in quotes: `/my-skill "hello world"`. Escape literal `$` with a backslash: `\$1.00`.

### Dynamic Context Injection

Two syntaxes inject shell command output before Claude sees the skill content:

- **Inline:** an exclamation mark immediately followed by a backtick-wrapped command (recognized only when `!` appears at the start of a line or after whitespace)
- **Multi-line block:** a fenced code block whose opening fence is immediately followed by an exclamation mark

Command output is inserted as plain text and is not re-scanned. To disable for user/project/plugin skills: set `"disableSkillShellExecution": true` in settings.

### Command Naming Rules

| Skill location | Command name source |
| :--- | :--- |
| Under `~/.claude/skills/` or `.claude/skills/` | Directory name |
| File under `.claude/commands/` | Filename without extension |
| Plugin `skills/` subdirectory | Directory name, namespaced: `plugin:skill` |
| Plugin root `SKILL.md` | Frontmatter `name` (fallback: plugin dir name) |

Nested skills (below working directory) get a qualified name like `apps/web:deploy`. Type `/deploy` for the root-level variant, `/apps/web:deploy` for the nested one.

### Skill Content Lifecycle

- Rendered SKILL.md enters conversation as a single message and stays for the rest of the session.
- On compaction: skills are re-attached (first 5,000 tokens each) within a 25,000-token combined budget, filled from most-recently-invoked first.
- Subagents with `preloaded skills` get full content injected at startup instead.

### skillOverrides Setting

Controls visibility without editing SKILL.md. The `/skills` menu writes this to `.claude/settings.local.json`.

| Value | Listed to Claude | In `/` menu |
| :--- | :--- | :--- |
| `"on"` (default) | Name and description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

Plugin skills are not affected by `skillOverrides`.

### Bundled Skills

Available in every session unless `disableBundledSkills` is set. Key bundled skills:

| Skill | Purpose |
| :--- | :--- |
| `/code-review` | Review code changes |
| `/debug` | Debug issues |
| `/batch` | Run batch operations |
| `/loop` | Recurring interval tasks |
| `/run` | Launch and drive your app |
| `/verify` | Confirm a change works in the running app |
| `/run-skill-generator` | Record the project's launch recipe for `/run` and `/verify` |
| `/claude-api` | Reference for the Claude API |

`/run`, `/verify`, and `/run-skill-generator` require Claude Code v2.1.145+.

### Restricting Claude's Skill Access

Three approaches:

- **Deny all skills:** add `Skill` to deny rules in permissions settings
- **Allow/deny specific skills:** use `Skill(name)` for exact match, `Skill(name *)` for prefix match
- **Hide individual skills:** add `disable-model-invocation: true` to frontmatter

### Skill Description Budget

Skill descriptions are truncated to fit a budget (default: 1% of model context window). To raise it, set `skillListingBudgetFraction` (e.g. `0.02`) or `SLASH_COMMAND_TOOL_CHAR_BUDGET`. Each entry's combined `description`+`when_to_use` text is capped at 1,536 chars (configurable with `maxSkillDescriptionChars`). Run `/doctor` to diagnose overflow.

### Agent Skills Open Standard Frontmatter (agentskills.io)

Core spec fields (interoperable across AI tools):

| Field | Required | Constraints |
| :--- | :--- | :--- |
| `name` | Yes | Max 64 chars; lowercase, hyphens only; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | Yes | Max 1024 chars; describes what skill does and when to use it |
| `license` | No | License name or reference to bundled file |
| `compatibility` | No | Max 500 chars; environment requirements (product, system packages, network, etc.) |
| `metadata` | No | Arbitrary key-value map for additional properties |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

### Directory Structure (Agent Skills spec)

```text
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation (loaded on demand)
├── assets/           # Optional: templates, resources
└── ...
```

Progressive disclosure: metadata (~100 tokens) loads at startup; full SKILL.md body (<5,000 tokens recommended) loads on activation; supporting files load only when needed. Keep SKILL.md under 500 lines.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with Skills](references/claude-code-skills.md) — Creating, configuring, sharing, and advanced patterns for Claude Code skills
- [Agent Skills Specification](references/agent-skills-specification.md) — The open standard format specification for SKILL.md (agentskills.io)

## Sources

- Extend Claude with Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
