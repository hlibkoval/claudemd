---
name: skills-doc
user-invocable: false
description: Complete official documentation for Claude Code skills — creating, configuring, sharing, and managing skills and the Agent Skills open standard specification.
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### Skill Storage Locations

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Enterprise overrides personal, personal overrides project. A skill at any level overrides a bundled skill with the same name. Plugin skills use `plugin-name:skill-name` namespace.

### Skill Directory Structure

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── references/        # Optional: detailed docs loaded on demand
├── assets/            # Optional: templates, resources
└── scripts/           # Optional: executable scripts
```

### Frontmatter Reference

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Display name shown in skill listings. Does not change the `/` command name (except for plugin-root SKILL.md). |
| `description` | Recommended | What the skill does and when to use it. Claude uses this to decide when to apply the skill. Truncated at 1,536 chars in listing. |
| `when_to_use` | No | Additional trigger phrases/examples; appended to `description`, counts toward 1,536-char cap. |
| `argument-hint` | No | Hint shown during autocomplete. Example: `[issue-number]`. |
| `arguments` | No | Named positional arguments for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No | `true` = only user can invoke. Removes skill from Claude's context entirely. Default: `false`. |
| `user-invocable` | No | `false` = hidden from `/` menu; Claude can still load it. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without permission prompts when skill is active. Space/comma-separated or YAML list. |
| `disallowed-tools` | No | Tools removed from Claude's pool while skill is active. Restriction clears on next user message. |
| `model` | No | Model override for this skill's turn. Accepts same values as `/model` or `inherit`. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | No | Set to `fork` to run in a forked subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, `general-purpose`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |
| `paths` | No | Glob patterns limiting when skill auto-activates. Same format as path-specific rules. |
| `shell` | No | Shell for inline injection commands: `bash` (default) or `powershell`. |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | When loaded into context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always in context; full skill on invoke |
| `disable-model-invocation: true` | Yes | No | Not in context; full skill loads on user invoke |
| `user-invocable: false` | No | Yes | Description always in context; full skill on invoke |

### How Command Names Are Determined

| Skill location | Command name source |
| :--- | :--- |
| `~/.claude/skills/<name>/` or `.claude/skills/<name>/` | Directory name → `/name` |
| Nested `.claude/skills/` (clashing name) | Relative path + dir name → `/apps/web:deploy` |
| `.claude/commands/<name>.md` | File name without extension → `/name` |
| Plugin `skills/<name>/` | Namespaced by plugin → `/plugin-name:skill-name` |
| Plugin root `SKILL.md` | Frontmatter `name` (or plugin dir name as fallback) → `/plugin-name:name` |

### String Substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | All arguments passed on invocation |
| `$ARGUMENTS[N]` | Argument at 0-based index N |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named argument from `arguments` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level string |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

Escape a literal `$` before a digit or `ARGUMENTS` with a backslash: `\$1.00`.

### Dynamic Context Injection

Two injection syntaxes run shell commands before Claude sees the skill content:

- **Inline form**: an exclamation mark immediately followed by a backtick-wrapped command, at the start of a line or after whitespace. Output replaces the entire line.
- **Block form**: a fenced code block whose opening fence is immediately followed by an exclamation mark. Multi-line commands, output replaces the block.

This is preprocessing — Claude only sees the rendered output, not the injection tokens themselves. Substitution runs once; command output is not re-scanned. Disable with `"disableSkillShellExecution": true` in settings.

### Subagent Execution (context: fork)

| Approach | System prompt | Task | Also loads |
| :--- | :--- | :--- | :--- |
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md (except Explore/Plan agents) |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

`context: fork` only works for skills with explicit task instructions — guidelines without a task return without useful output.

### Skill Content Lifecycle

- Rendered SKILL.md content enters the conversation as a single message and stays for the rest of the session.
- Auto-compaction carries invoked skills forward, keeping the first 5,000 tokens of each.
- Re-attached skills share a combined budget of 25,000 tokens (most-recently-invoked fills first).

### skillOverrides Values

Control skill visibility from settings instead of editing SKILL.md:

| Value | Listed to Claude | In `/` menu |
| :--- | :--- | :--- |
| `"on"` | Name and description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

Set via the `/skills` menu (Space to cycle, Enter to save) or directly in `.claude/settings.local.json` under `"skillOverrides"`.

### Skill Description Budget

- All skill names always included; descriptions are shortened to fit the budget when needed.
- Budget scales at 1% of model context window (configurable via `skillListingBudgetFraction`).
- Each skill's combined `description` + `when_to_use` is capped at 1,536 chars (configurable via `maxSkillDescriptionChars`).
- Run `/doctor` to see which skills have shortened or dropped descriptions.
- To free budget: set low-priority skills to `"name-only"` in `skillOverrides`.

### `allowed-tools` Permission Behavior

- Grants those tools without per-use approval while the skill is active.
- Does not restrict other tools — all tools remain callable.
- For project skills in `.claude/skills/`, takes effect after accepting the workspace trust dialog.

### Bundled Skills

Available in every session unless `disableBundledSkills: true` in settings:

| Skill | Purpose |
| :--- | :--- |
| `/code-review` | Review current diff for correctness and quality |
| `/debug` | Systematic debugging assistance |
| `/batch` | Run multiple independent tasks in parallel |
| `/loop` | Run a command on a recurring interval |
| `/claude-api` | Reference for Claude API / Anthropic SDK |
| `/run` | Launch and drive the app to see a change working |
| `/verify` | Build and run the app to confirm a change works |
| `/run-skill-generator` | Teach `/run` and `/verify` how to launch your project |

`/run`, `/verify`, and `/run-skill-generator` require Claude Code v2.1.145+.

### Agent Skills Open Standard Frontmatter

The open standard (`agentskills.io`) defines a minimal portable subset:

| Field | Required | Constraints |
| :--- | :--- | :--- |
| `name` | Yes | 1-64 chars; lowercase letters, numbers, hyphens; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | Yes | 1-1024 chars; describe what skill does and when to use it |
| `license` | No | License name or path to bundled file |
| `compatibility` | No | 1-500 chars; environment requirements |
| `metadata` | No | Arbitrary key-value map for additional properties |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

Claude Code adds additional fields on top of this base standard.

### Progressive Disclosure (Agent Skills Standard)

1. Metadata (~100 tokens): `name` and `description` loaded at startup for all skills
2. Instructions (<5,000 tokens recommended): full SKILL.md body loaded when skill activates
3. Resources (as needed): files in `scripts/`, `references/`, `assets/` loaded on demand

Keep SKILL.md under 500 lines; move detailed reference material to separate files.

### Skill Resolution Priority (Restrict Claude's Access)

- **Deny Skill tool entirely**: add `Skill` to deny rules in `/permissions`
- **Allow/deny specific skills**: `Skill(name)` (exact), `Skill(name *)` (prefix with args)
- **Hide from Claude**: `disable-model-invocation: true` in frontmatter

Note: `user-invocable` only controls menu visibility, not Skill tool access. Use `disable-model-invocation: true` to block programmatic invocation.

### Live Change Detection

Skills in `~/.claude/skills/`, project `.claude/skills/`, or `--add-dir` directory `.claude/skills/` update within the current session without restarting. Creating a top-level skills directory requires restarting Claude Code. SKILL.md text changes take effect live; plugin component changes (`hooks/`, `.mcp.json`, `agents/`, `output-styles/`) require `/reload-plugins`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — Creating, configuring, sharing, and advanced patterns for Claude Code skills
- [Agent Skills specification](references/agent-skills-specification.md) — The open standard: SKILL.md format, frontmatter fields, directory structure, progressive disclosure

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
