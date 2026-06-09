---
name: skills-doc
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills: creating and configuring skills, frontmatter reference, dynamic context injection, subagent execution, skill invocation control, argument passing, and the Agent Skills open standard.

## Quick Reference

### Skill File Locations

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | See managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Precedence (highest → lowest): enterprise → personal → project. Plugin skills are namespaced as `plugin-name:skill-name`.

### Skill Directory Structure

```
my-skill/
├── SKILL.md           # Required: metadata + instructions
├── references/        # Optional: detailed docs loaded on demand
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, data files
```

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | Display name; command name comes from directory (exception: plugin-root SKILL.md) |
| `description` | Recommended | What the skill does and when to use it; Claude uses this to auto-invoke |
| `when_to_use` | No | Extra trigger context; appended to `description` in listings |
| `argument-hint` | No | Autocomplete hint, e.g. `[issue-number]` |
| `arguments` | No | Named positional args for `$name` substitution (space-separated or YAML list) |
| `disable-model-invocation` | No | `true` → only you can invoke; removed from Claude's context |
| `user-invocable` | No | `false` → hidden from `/` menu; Claude still loads automatically |
| `allowed-tools` | No | Tools pre-approved while skill is active (space/comma-separated or list) |
| `disallowed-tools` | No | Tools removed from pool while skill is active; clears on next user message |
| `model` | No | Model override for this skill's turn |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `context` | No | `fork` → run in isolated subagent |
| `agent` | No | Subagent type when `context: fork` is set |
| `hooks` | No | Lifecycle hooks scoped to this skill |
| `paths` | No | Glob patterns; skill auto-activates only when working with matching files |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell` |

### Invocation Control

| Frontmatter | You can invoke | Claude can invoke | Context loading |
|:------------|:--------------|:------------------|:----------------|
| (default) | Yes | Yes | Description always present; full skill loads on invoke |
| `disable-model-invocation: true` | Yes | No | Description not in context; full skill loads when you invoke |
| `user-invocable: false` | No | Yes | Description always present; full skill loads on invoke |

### String Substitutions

| Variable | Expands to |
|:---------|:-----------|
| `$ARGUMENTS` | Full argument string as typed |
| `$ARGUMENTS[N]` | Argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named argument declared in `arguments` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Active effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing this skill's SKILL.md |

Escape a literal `$` before a substitution token with a backslash: `\$1.00`.

### Dynamic Context Injection

Two forms of shell injection run before Claude sees the skill content:

- **Inline**: an exclamation mark immediately followed by a backtick-wrapped command (e.g., on its own line or after whitespace). The command's output replaces the placeholder. Only recognized when `!` appears at the start of a line or after whitespace — not when it follows another character.
- **Block**: a fenced code block whose opening fence is immediately followed by an exclamation mark. All lines in the block run as a shell script; output replaces the block.

Injection runs once over the original file. Output is plain text and is not re-scanned. To disable for user/project/plugin skills, set `"disableSkillShellExecution": true` in settings.

### Subagent Execution (`context: fork`)

Add `context: fork` to run a skill in an isolated subagent. The skill content becomes the task prompt. The subagent has no access to your conversation history.

| `agent` value | Description |
|:--------------|:------------|
| `Explore` | Read-only codebase exploration; skips CLAUDE.md and git status |
| `Plan` | Planning agent; skips CLAUDE.md and git status |
| `general-purpose` | Default; full tool access |
| Custom name | Any subagent defined in `.claude/agents/` |

### Skill Content Lifecycle

- Invoked skill content enters the conversation as a single message and stays for the rest of the session.
- Auto-compaction carries skills forward (up to first 5,000 tokens each; shared 25,000-token budget across all invoked skills, filled from most recent).
- Older skills can be dropped after compaction if many have been invoked — re-invoke to restore.

### `skillOverrides` Setting

Override visibility from settings without editing the skill's frontmatter. Managed via the `/skills` menu (highlight + `Space` to cycle, `Enter` to save to `.claude/settings.local.json`).

| Value | Listed to Claude | In `/` menu |
|:------|:----------------|:------------|
| `"on"` | Name and description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

### Controlling Claude's Skill Access

- Deny the `Skill` tool entirely in `/permissions` to block all skills.
- Allow/deny specific skills: `Skill(name)` (exact) or `Skill(name *)` (prefix).
- Set `disable-model-invocation: true` on individual skills to hide them from Claude.

### Skill Budget Troubleshooting

If skill descriptions are truncated: run `/doctor` to check budget overflow. Adjust with `skillListingBudgetFraction` (e.g. `0.02`) or `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. Use `skillOverrides` with `"name-only"` for low-priority skills. Per-entry text is capped at 1,536 characters (configurable via `maxSkillDescriptionChars`).

### Agent Skills Open Standard (agentskills.io)

SKILL.md frontmatter fields from the open standard:

| Field | Required | Constraints |
|:------|:---------|:------------|
| `name` | Yes | 1–64 chars; lowercase letters, numbers, hyphens only; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | Yes | 1–1024 chars; describe what and when |
| `license` | No | License name or path to bundled file |
| `compatibility` | No | 1–500 chars; environment requirements |
| `metadata` | No | Arbitrary key-value map |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

Claude Code extends this standard with additional frontmatter fields and features (invocation control, subagent execution, dynamic context injection).

Progressive disclosure levels:
1. **Metadata** (~100 tokens): `name` and `description` loaded at startup
2. **Instructions** (<5,000 tokens recommended): full SKILL.md body loaded on activation
3. **Resources** (as needed): files in `scripts/`, `references/`, or `assets/` loaded on demand

Validate a skill with: `skills-ref validate ./my-skill`

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — Creating and configuring skills: file locations, frontmatter reference, invocation control, arguments, dynamic context injection, subagent execution, sharing, bundled skills, and troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — Open standard format: SKILL.md structure, frontmatter fields, optional directories, progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
