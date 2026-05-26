---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating SKILL.md files, frontmatter fields (name, description, disable-model-invocation, user-invocable, allowed-tools, context, agent, arguments, paths, hooks, model, effort, shell), skill locations (personal/project/plugin/enterprise), dynamic context injection, subagent execution with context:fork, argument substitution ($ARGUMENTS, $N, named args), skill content lifecycle, auto-compaction behavior, bundled skills (/run, /verify, /code-review), skillOverrides, skill visibility settings, the Agent Skills open standard and specification (name/description/license/compatibility/metadata/allowed-tools fields, directory structure, progressive disclosure).
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### What Skills Are

Skills extend what Claude can do. Create a `SKILL.md` file with instructions and Claude adds it to its toolkit — loading it automatically when relevant or when invoked directly with `/skill-name`.

### Skill Locations

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | See managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

When names conflict: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace.

### Frontmatter Reference

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Display name (does not change the `/` command name, except for plugin-root SKILL.md) |
| `description` | Recommended | What the skill does and when to use it. Truncated at 1,536 chars in skill listing |
| `when_to_use` | No | Additional trigger context, appended to `description` in listing |
| `argument-hint` | No | Hint shown during autocomplete, e.g. `[issue-number]` |
| `arguments` | No | Named positional args for `$name` substitution (space-separated string or YAML list) |
| `disable-model-invocation` | No | `true` = only you can invoke; skill hidden from Claude's context entirely |
| `user-invocable` | No | `false` = hidden from `/` menu; Claude can still auto-invoke |
| `allowed-tools` | No | Tools Claude can use without approval prompts while skill is active |
| `model` | No | Model override for this skill's turn (not saved to session) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `context` | No | `fork` = run in isolated subagent context |
| `agent` | No | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, custom name) |
| `hooks` | No | Lifecycle hooks scoped to this skill |
| `paths` | No | Glob patterns; Claude only auto-loads when working with matching files |
| `shell` | No | `bash` (default) or `powershell` for inline shell command execution |

### Invocation Control

| Frontmatter | You can invoke | Claude can invoke | Full skill loads when |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Either invokes |
| `disable-model-invocation: true` | Yes | No | You invoke |
| `user-invocable: false` | No | Yes | Claude invokes |

### Command Name Sources

| Skill location | Command name |
| :--- | :--- |
| `~/.claude/skills/<dir>/SKILL.md` or `.claude/skills/<dir>/SKILL.md` | Directory name |
| `.claude/commands/<file>.md` | Filename without extension |
| Plugin `skills/<dir>/SKILL.md` | Directory name, namespaced by plugin |
| Plugin root `SKILL.md` | `name` frontmatter field (fallback: plugin dir name) |

### String Substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | All arguments passed at invocation |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named argument from `arguments` frontmatter list |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Dynamic Context Injection

Use an exclamation mark immediately followed by a backtick-wrapped shell command at the start of a line — Claude Code runs the command and replaces the token with its output before Claude sees the skill.

For multi-line commands, use a fenced code block whose opening fence is immediately followed by an exclamation mark.

- Runs once before Claude sees the content; output is plain text, not re-scanned
- Only recognized when `!` appears at the start of a line or after whitespace
- Disable with `"disableSkillShellExecution": true` in settings

### Skill Content Lifecycle

- Rendered SKILL.md enters the conversation as a single message and stays for the rest of the session
- Auto-compaction: most recently invoked skills are re-attached after compaction (first 5,000 tokens each, shared 25,000 token budget)
- Older skills may be dropped if many have been invoked

### Bundled Skills

| Skill | Purpose |
| :--- | :--- |
| `/run` | Launch and drive your app to see a change working |
| `/verify` | Confirm a change does what it should against the running app |
| `/run-skill-generator` | Record the recipe for building and launching your project |
| `/code-review` | Review code changes |
| `/debug` | Debug issues |
| `/loop` | Run a task on a recurring interval |
| `/claude-api` | Build, debug, and optimize Claude API apps |
| `/batch` | Run batch operations |

### `skillOverrides` Settings

Controls skill visibility without editing SKILL.md:

| Value | Listed to Claude | In `/` menu |
| :--- | :--- | :--- |
| `"on"` | Name and description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

Set via `/skills` menu (Space to cycle, Enter to save to `.claude/settings.local.json`). Does not affect plugin skills.

### Agent Skills Open Standard (agentskills.io)

Claude Code skills follow the Agent Skills open standard. The spec defines:

**Required SKILL.md frontmatter fields:**

| Field | Constraints |
| :--- | :--- |
| `name` | Max 64 chars, lowercase letters/numbers/hyphens, no leading/trailing/consecutive hyphens, must match directory name |
| `description` | Max 1,024 chars, describes what the skill does and when to use it |

**Optional spec fields:** `license`, `compatibility` (max 500 chars, for environment requirements), `metadata` (arbitrary key-value map), `allowed-tools` (space-delimited, experimental)

**Directory structure:**
```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
```

**Progressive disclosure:** metadata (~100 tokens always loaded) → SKILL.md body (<5,000 tokens on activation) → supporting files (on demand). Keep SKILL.md under 500 lines.

### Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Skill not triggering | Check description has natural keywords; try `/skill-name` directly; check `/doctor` for budget overflow |
| Triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Set `skillListingBudgetFraction` (e.g. `0.02`); set low-priority entries to `"name-only"` in `skillOverrides`; trim `description`/`when_to_use` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, frontmatter reference, dynamic context injection, subagent execution, argument substitution, bundled skills, skillOverrides, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — open standard format, SKILL.md frontmatter fields and constraints, directory structure, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
