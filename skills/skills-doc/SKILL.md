---
name: skills-doc
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills — how to create, configure, invoke, and distribute them — plus the Agent Skills open standard specification.

## Quick Reference

### Skill Locations and Precedence

| Location | Path | Scope |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Precedence: enterprise > personal > project > bundled. Plugin skills use `plugin-name:skill-name` namespace and cannot conflict with other levels.

### Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Display name; only sets command name for plugin-root SKILL.md. |
| `description` | Recommended | What the skill does and when to use it (truncated at 1,536 chars in listing). |
| `when_to_use` | No | Additional trigger phrases; appended to `description` in listing. |
| `argument-hint` | No | Hint shown in autocomplete, e.g. `[issue-number]`. |
| `arguments` | No | Named positional args for `$name` substitution; space-separated or YAML list. |
| `disable-model-invocation` | No | `true` = only user can invoke; skill hidden from Claude's context entirely. |
| `user-invocable` | No | `false` = hidden from `/` menu; Claude still auto-loads. Default: `true`. |
| `allowed-tools` | No | Tools pre-approved while skill is active (no per-use prompt). |
| `disallowed-tools` | No | Tools removed from Claude's pool while skill is active; clears on next message. |
| `model` | No | Model override for this skill's turn; reverts on next prompt. |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | No | `fork` = run in isolated subagent. |
| `agent` | No | Subagent type when `context: fork` is set (e.g. `Explore`, `general-purpose`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |
| `paths` | No | Glob patterns that limit when the skill auto-activates. |
| `shell` | No | `bash` (default) or `powershell` for inline shell commands. |

### Invocation Control Matrix

| Frontmatter | User can invoke | Claude can invoke | In Claude's context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always present |
| `disable-model-invocation: true` | Yes | No | Not in context |
| `user-invocable: false` | No | Yes | Description always present |

### String Substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | Full argument string passed on invocation |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named argument declared in `arguments` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Command Name Resolution

| Skill location | Command name source |
| :--- | :--- |
| `~/.claude/skills/<dir>/SKILL.md` | Directory name |
| `.claude/skills/<dir>/SKILL.md` | Directory name |
| Nested `.claude/skills/` (name clash) | `subdir/path:skill-dir` |
| `.claude/commands/<file>.md` | Filename without extension |
| Plugin `skills/<dir>/SKILL.md` | `plugin-name:dir-name` |
| Plugin root `SKILL.md` | Frontmatter `name` (or plugin dir name) |

### Dynamic Context Injection

Inline form: an exclamation mark immediately followed by a backtick-wrapped command — placed at the start of a line or after whitespace. The command runs before Claude sees the skill; output replaces the placeholder.

Multi-line form: a fenced code block whose opening fence is immediately followed by an exclamation mark. Runs multiple commands and inlines combined output.

Both forms run once at skill load time. Output is not re-scanned for further injection tokens. Disable with `"disableSkillShellExecution": true` in settings.

### Skill Content Lifecycle

- On invocation: rendered SKILL.md enters conversation as a single message and remains for the rest of the session.
- On compaction: skill is re-attached (up to first 5,000 tokens); all re-attached skills share a 25,000-token combined budget, filled newest-first.
- Re-invoke a skill after compaction if it stops influencing behavior.

### `skillOverrides` States (in settings.json)

| Value | Listed to Claude | In `/` menu |
| :--- | :--- | :--- |
| `"on"` (default) | Name + description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

Set via `/skills` menu (highlight + Space to cycle, Enter to save) or directly in `.claude/settings.local.json`.

### Bundled Skills

Always available unless `disableBundledSkills: true` in settings:

| Skill | Purpose |
| :--- | :--- |
| `/code-review` | Review current diff for bugs and cleanups |
| `/batch` | Run multiple tasks in parallel |
| `/debug` | Debug issues |
| `/loop` | Run a command on a recurring interval |
| `/claude-api` | Reference for Claude API / Anthropic SDK |
| `/run` | Launch and drive the app to see a change |
| `/verify` | Confirm a change works without falling back to tests |
| `/run-skill-generator` | Record the recipe for how to build and launch the project |

`/run` and `/verify` require Claude Code v2.1.145+.

### Agent Skills Open Standard Frontmatter (agentskills.io)

| Field | Required | Constraints |
| :--- | :--- | :--- |
| `name` | Yes | 1-64 chars; lowercase letters, numbers, hyphens; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | Yes | 1-1024 chars; describe what and when |
| `license` | No | License name or path to bundled file |
| `compatibility` | No | 1-500 chars; environment requirements |
| `metadata` | No | Arbitrary key-value map |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

### Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Skill not triggering | Check description has natural-language keywords; verify via `What skills are available?`; invoke directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Run `/doctor`; raise budget via `skillListingBudgetFraction` (e.g. `0.02`) or `SLASH_COMMAND_TOOL_CHAR_BUDGET`; set low-priority skills to `name-only` in `skillOverrides` |
| Malformed YAML | Run with `--debug`; skill body still loads but Claude has no `description` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — Creating, configuring, invoking, sharing skills in Claude Code; bundled skills; dynamic context injection; subagent execution; skill evals
- [Agent Skills specification](references/agent-skills-specification.md) — Open standard format: directory structure, SKILL.md frontmatter fields, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
