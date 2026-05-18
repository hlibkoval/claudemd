---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating and configuring SKILL.md files, frontmatter fields (name, description, user-invocable, disable-model-invocation, allowed-tools, context, agent, hooks, paths, arguments, model, effort, shell), dynamic context injection, supporting files, skill lifecycle, invocation control, subagent integration, string substitutions ($ARGUMENTS, $N, ${CLAUDE_SKILL_DIR}), skillOverrides setting, sharing and distributing skills, and the Agent Skills open standard specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills.

## Quick Reference

### Where Skills Live

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Enterprise overrides personal, personal overrides project. Plugin skills use `plugin-name:skill-name` namespace and cannot conflict with other levels.

### Skill Directory Structure

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── reference.md       # Detailed docs — loaded when needed
├── examples/
│   └── sample.md
└── scripts/
    └── helper.py
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Frontmatter Reference

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Display name. Directory name used if omitted. Lowercase letters, numbers, hyphens; max 64 chars. |
| `description` | Recommended | What the skill does and when to use it. Combined with `when_to_use`, truncated at 1,536 chars in skill listing. |
| `when_to_use` | No | Additional trigger context. Appended to `description`; counts toward 1,536-char cap. |
| `argument-hint` | No | Autocomplete hint, e.g., `[issue-number]`. |
| `arguments` | No | Named positional args for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No | `true` = only user can invoke; removed from Claude's context. Default: `false`. |
| `user-invocable` | No | `false` = hidden from `/` menu; Claude-only. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without per-use approval when skill is active. Space-separated or YAML list. |
| `model` | No | Model override for this skill's turn. Use `/model` values or `inherit`. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | No | `fork` = run in isolated subagent context. |
| `agent` | No | Which subagent type to use when `context: fork` is set (e.g., `Explore`, `Plan`, `general-purpose`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. Cleaned up when skill finishes. |
| `paths` | No | Glob patterns — skill auto-loads only when working with matching files. |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell`. |

### Invocation Control Matrix

| Frontmatter | You can invoke | Claude can invoke | When loaded into context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description NOT in context; full skill loads when you invoke |
| `user-invocable: false` | No | Yes | Description always in context; full skill loads when invoked |

### String Substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | All arguments passed when invoking the skill. Appended as `ARGUMENTS: <value>` if not present. |
| `$ARGUMENTS[N]` | Argument by 0-based index (e.g., `$ARGUMENTS[0]`). |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g., `$0`, `$1`). |
| `$name` | Named argument from `arguments` frontmatter list. Maps to position order. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_EFFORT}` | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`. |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's `SKILL.md`. |

Multi-word arguments: use shell-style quoting, e.g., `/my-skill "hello world" second` → `$0` = `hello world`, `$1` = `second`.

### Dynamic Context Injection

An exclamation mark immediately followed by a backtick-wrapped command runs the command before Claude sees the skill. The output replaces the placeholder — Claude receives actual data, not the command.

- Inline form: an exclamation mark followed by a backtick-wrapped shell command on a single line.
- Multi-line form: a fenced code block whose opening fence is immediately followed by an exclamation mark.

Runs once over the original file; output is not re-scanned for further placeholders. To disable for user/project/plugin sources, set `"disableSkillShellExecution": true` in settings.

### Skill Content Lifecycle

- When invoked, rendered `SKILL.md` enters conversation as a single message and stays for the rest of the session.
- Auto-compaction carries invoked skills forward within a token budget; first 5,000 tokens of each skill re-attached after compaction.
- Re-attached skills share a combined budget of 25,000 tokens, filled starting from most-recently-invoked skill.

### Skills with `context: fork`

| Approach | System prompt | Task | Also loads |
| :--- | :--- | :--- | :--- |
| Skill with `context: fork` | From agent type (`Explore`, `Plan`, etc.) | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

### skillOverrides Setting

Controls skill visibility from settings without editing `SKILL.md`. Written by the `/skills` menu (highlight + `Space` to cycle, `Enter` to save to `.claude/settings.local.json`).

| Value | Listed to Claude | In `/` menu |
| :--- | :--- | :--- |
| `"on"` | Name and description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

Absent from `skillOverrides` = treated as `"on"`. Plugin skills are not affected; manage those via `/plugin`.

### Restricting Claude's Skill Access

- **Deny all skills**: add `Skill` to deny rules in `/permissions`.
- **Allow/deny specific skills**: `Skill(commit)`, `Skill(review-pr *)` (prefix match with `*`).
- **Hide individual skills**: `disable-model-invocation: true` in frontmatter.

### Skill Description Budget

All skill names always included in context; descriptions shortened to fit character budget (~1% of model context window). To adjust:
- Set `skillListingBudgetFraction` in settings (e.g., `0.02` = 2%).
- Or set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var to a fixed character count.
- Set low-priority skills to `"name-only"` in `skillOverrides`.
- Per-entry cap: 1,536 chars (configurable via `maxSkillDescriptionChars`).

### Bundled Skills

Claude Code bundles: `/simplify`, `/batch`, `/debug`, `/loop`, `/claude-api`, and others. Listed in the commands reference, marked **Skill** in the Purpose column.

### Agent Skills Open Standard

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard. Standard frontmatter fields:

| Field | Required (spec) | Constraints |
| :--- | :--- | :--- |
| `name` | Yes | Max 64 chars; lowercase letters, numbers, hyphens; no leading/trailing/consecutive hyphens; must match directory name. |
| `description` | Yes | Max 1,024 chars; non-empty; describe what and when. |
| `license` | No | License name or reference to bundled license file. |
| `compatibility` | No | Max 500 chars; environment requirements (product, packages, network, etc.). |
| `metadata` | No | Arbitrary key-value mapping for additional metadata. |
| `allowed-tools` | No | Space-delimited pre-approved tools. Experimental. |

Claude Code extends the standard with additional fields (`disable-model-invocation`, `user-invocable`, `context`, `agent`, `hooks`, `paths`, `model`, `effort`, `shell`, `when_to_use`, `argument-hint`, `arguments`).

### Progressive Disclosure (Spec)

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills.
2. **Instructions** (< 5,000 tokens recommended): Full `SKILL.md` body loaded when skill is activated.
3. **Resources** (as needed): Files in `scripts/`, `references/`, or `assets/` loaded only when required.

### Troubleshooting

| Issue | Fix |
| :--- | :--- |
| Skill not triggering | Check description keywords; verify skill appears in "What skills are available?"; invoke directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Check `/doctor` for budget overflow; trim `description`/`when_to_use`; use `skillOverrides` `"name-only"` for low-priority skills |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, frontmatter reference, dynamic context injection, supporting files, invocation control, subagent integration, skill lifecycle, sharing, visual output patterns, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — open standard format, frontmatter schema, directory structure, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
