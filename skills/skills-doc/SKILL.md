---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. A `SKILL.md` file with YAML frontmatter and markdown instructions creates a skill that Claude can invoke automatically, or that you can invoke directly with `/skill-name`. Custom commands in `.claude/commands/` and skills in `.claude/skills/` are equivalent; skills add optional extra features.

### Where skills live

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

When names conflict, enterprise overrides personal, personal overrides project. Plugin skills use a `plugin-name:skill-name` namespace and cannot conflict with other levels. Skills take precedence over commands of the same name.

### Skill directory layout

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── reference.md       # Detailed docs — loaded on demand
├── examples/
│   └── sample.md      # Example output
└── scripts/
    └── helper.py      # Executable script
```

Keep `SKILL.md` under 500 lines. Move reference material to separate files.

### Frontmatter fields (Claude Code)

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Skill name (= slash command). Lowercase letters, numbers, hyphens, max 64 chars. Defaults to directory name. |
| `description` | Recommended | What it does and when to use it. Claude uses this for auto-invocation. Falls back to first paragraph if omitted. Front-load key use case; truncated at 1,536 chars in listing. |
| `when_to_use` | No | Extra trigger context appended to `description` in listing; counts toward the 1,536-char cap. |
| `argument-hint` | No | Hint shown in autocomplete: e.g. `[issue-number]`. |
| `arguments` | No | Named positional arguments for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No | `true` — Claude cannot invoke it; description hidden from context. Use for manual-only workflows. Default: `false`. |
| `user-invocable` | No | `false` — hides from `/` menu; Claude can still invoke it automatically. Default: `true`. |
| `allowed-tools` | No | Tools pre-approved without prompting while the skill is active. Space-separated or YAML list. |
| `model` | No | Model override for the turn (not saved). Accepts same values as `/model`, or `inherit`. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. Default: inherits from session. |
| `context` | No | `fork` — run in an isolated subagent context. |
| `agent` | No | Subagent type to use when `context: fork`. Built-in: `Explore`, `Plan`, `general-purpose`, or any custom agent. |
| `hooks` | No | Lifecycle hooks scoped to this skill. See Hooks documentation. |
| `paths` | No | Glob patterns limiting when the skill auto-activates (only files matching patterns). Comma-separated or YAML list. |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell`. |

### Agent Skills open standard frontmatter fields

| Field | Required | Constraints |
| :--- | :--- | :--- |
| `name` | Yes | 1–64 chars, lowercase alphanumeric and hyphens, no leading/trailing/consecutive hyphens, must match directory name. |
| `description` | Yes | 1–1024 chars. Describe what the skill does and when to use it. |
| `license` | No | License name or bundled license filename. |
| `compatibility` | No | 1–500 chars. Environment requirements (product, packages, network, etc.). |
| `metadata` | No | Arbitrary key-value map for additional properties. |
| `allowed-tools` | No | Space-delimited pre-approved tools. Experimental. |

### Invocation control matrix

| Frontmatter | You can invoke | Claude can invoke | When loaded into context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always present; full body loads on invoke |
| `disable-model-invocation: true` | Yes | No | Description absent; full body loads when you invoke |
| `user-invocable: false` | No | Yes | Description always present; full body loads on invoke |

### String substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | Full argument string passed on invocation. If absent in content, appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]` | Argument by 0-based index. |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`). |
| `$name` | Named argument from the `arguments` frontmatter field (mapped by position). |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_SKILL_DIR}` | Directory containing this skill's `SKILL.md`. |

Wrap multi-word argument values in quotes: `/my-skill "hello world" second` makes `$0` = `hello world`.

### Dynamic context injection

Use `` !`<command>` `` to run a shell command before Claude sees the skill. Output replaces the placeholder:

```yaml
---
name: pr-summary
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
```

For multi-line commands, use a fenced block opened with ` ```! `.

To disable shell injection organization-wide, set `"disableSkillShellExecution": true` in managed settings.

### Running skills in a subagent

Add `context: fork` to run in an isolated context. The skill content becomes the subagent's task prompt. It has no access to conversation history.

| Approach | System prompt | Task | Also loads |
| :--- | :--- | :--- | :--- |
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

### Context lifecycle after invocation

- Rendered `SKILL.md` content enters the conversation as a single message and stays for the session.
- Auto-compaction re-attaches the most recent invocation of each skill (up to first 5,000 tokens each).
- All re-attached skills share a 25,000-token combined budget, filled starting from most recently invoked.

### Restricting Claude's skill access

```text
# Deny all skills
Skill

# Allow only specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)
```

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix with any arguments.

### Progressive disclosure (Agent Skills standard)

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills.
2. **Instructions** (< 5,000 tokens recommended): Full `SKILL.md` body loaded on activation.
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded on demand.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Skill not triggering | Add keywords users naturally say; verify it appears in "What skills are available?"; invoke directly with `/skill-name`. |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true`. |
| Descriptions cut short | Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var; trim `description`/`when_to_use`; front-load key use case. |
| Skill stops working after a while | Skill body may have been dropped by compaction; re-invoke after compaction. |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — full Claude Code guide: creating skills, skill locations, live change detection, frontmatter fields, string substitutions, dynamic context injection, subagent execution, sharing, and troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — the open standard: SKILL.md format, frontmatter constraints, optional directories (`scripts/`, `references/`, `assets/`), progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
