---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills specification — creating skills, SKILL.md format, frontmatter fields, skill locations, invocation control, argument passing, string substitutions, dynamic context injection, subagent execution, supporting files, bundled skills, permission control, sharing skills, troubleshooting, and the Agent Skills open standard. Load when discussing skill creation, SKILL.md authoring, slash commands, skill configuration, or the Agent Skills spec.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills specification.

## Quick Reference

Skills extend what Claude can do via `SKILL.md` files with YAML frontmatter and markdown instructions. Claude loads them automatically when relevant, or users invoke them with `/skill-name`. Skills follow the [Agent Skills](https://agentskills.io) open standard.

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/simplify` | Reviews recently changed files for reuse, quality, and efficiency; spawns 3 parallel review agents |
| `/batch <instruction>` | Orchestrates large-scale parallel changes across a codebase using git worktrees |
| `/debug [description]` | Troubleshoots current session by reading the debug log |
| `/claude-api` | Loads Claude API + Agent SDK reference for your project's language |

### Skill Locations & Priority

| Level | Path | Scope |
|:------|:-----|:------|
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Higher-priority locations win when names conflict: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills in `.claude/commands/` still work; if a skill and command share a name, the skill wins.

Nested `.claude/skills/` directories are auto-discovered (supports monorepos). Additional directories via `--add-dir` also load skills.

### Frontmatter Fields (Claude Code)

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | Display name; defaults to directory name. Lowercase letters, numbers, hyphens (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Used for auto-invocation matching. |
| `argument-hint` | No | Hint shown during autocomplete, e.g. `[issue-number]`. |
| `disable-model-invocation` | No | `true` to prevent Claude from auto-loading. Default: `false`. |
| `user-invocable` | No | `false` to hide from `/` menu. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without permission when skill is active. |
| `model` | No | Model to use when skill is active. |
| `context` | No | `fork` to run in a forked subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, `general-purpose`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |

### Frontmatter Fields (Agent Skills Spec)

| Field | Required | Constraints |
|:------|:---------|:------------|
| `name` | Yes | 1-64 chars; lowercase alphanumeric + hyphens; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | Yes | 1-1024 chars; describes what the skill does and when to use it |
| `license` | No | License name or reference to bundled license file |
| `compatibility` | No | Max 500 chars; environment requirements |
| `metadata` | No | Arbitrary key-value mapping (string to string) |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context behavior |
|:------------|:----------------|:------------------|:-----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context; loads when invoked |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

If `$ARGUMENTS` is not present in content, arguments are appended as `ARGUMENTS: <value>`.

### Dynamic Context Injection

The `! + backtick` syntax (exclamation mark immediately before a backtick-wrapped command) runs shell commands before skill content reaches Claude. Output replaces the placeholder. This is preprocessing — Claude only sees the result.

### Subagent Execution

Add `context: fork` to run a skill in an isolated subagent. The skill content becomes the subagent's prompt. The `agent` field selects which subagent type to use. The subagent does not have access to conversation history.

### Skill Directory Structure

```
my-skill/
├── SKILL.md           # Required — main instructions
├── template.md        # Optional — template for Claude to fill in
├── examples/          # Optional — example outputs
├── scripts/           # Optional — executable scripts
└── references/        # Optional — additional docs loaded on demand
```

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Restricting Skill Access

- **Deny all skills**: add `Skill` to deny rules in `/permissions`
- **Allow/deny specific skills**: `Skill(name)` for exact match, `Skill(name *)` for prefix match
- **Hide from Claude**: add `disable-model-invocation: true` to frontmatter

Skill descriptions budget: 2% of context window (fallback 16,000 chars). Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

### Agent Skills Spec: Progressive Disclosure

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): full SKILL.md body loaded on activation
3. **Resources** (as needed): files in `scripts/`, `references/`, `assets/` loaded only when required

### Sharing Skills

- **Project**: commit `.claude/skills/` to version control
- **Plugin**: add `skills/` directory to your plugin
- **Managed**: deploy organization-wide through managed settings

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, bundled skills, skill locations, frontmatter reference, invocation control, arguments, dynamic context injection, subagent execution, tool restrictions, sharing, visual output, and troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — the open standard format specification covering directory structure, SKILL.md format, frontmatter fields, optional directories, progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
