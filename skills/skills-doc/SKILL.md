---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills specification — creating skills, SKILL.md format, frontmatter fields (name, description, user-invocable, disable-model-invocation, allowed-tools, model, context, agent, hooks, argument-hint), bundled skills (/simplify, /batch, /debug, /loop, /claude-api), skill locations (enterprise, personal, project, plugin), supporting files (scripts, references, assets), progressive disclosure, string substitutions ($ARGUMENTS, $CLAUDE_SKILL_DIR, $CLAUDE_SESSION_ID), dynamic context injection, running skills in subagents (context: fork), controlling invocation, restricting tool/skill access, generating visual output, sharing skills, troubleshooting triggering, and the Agent Skills open standard. Load when discussing skill creation, SKILL.md authoring, slash commands, skill configuration, or the Agent Skills spec.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills specification.

## Quick Reference

Skills extend what Claude can do. A skill is a directory with a `SKILL.md` file containing YAML frontmatter and markdown instructions. Claude loads skills automatically when relevant, or users invoke them directly with `/skill-name`. Skills follow the [Agent Skills](https://agentskills.io) open standard.

### Bundled Skills

| Skill | Description |
|:------|:------------|
| `/simplify` | Reviews recently changed files for code reuse, quality, and efficiency; spawns three parallel review agents |
| `/batch <instruction>` | Orchestrates large-scale parallel changes across a codebase using git worktrees; spawns one agent per unit |
| `/debug [description]` | Troubleshoots the current session by reading the debug log |
| `/loop [interval] <prompt>` | Runs a prompt repeatedly on a schedule (cron-based) |
| `/claude-api` | Loads Claude API and Agent SDK reference material for your project's language |

### Skill Locations

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Nested `.claude/skills/` directories in subdirectories are auto-discovered (monorepo support). Skills from `--add-dir` directories are loaded and support live change detection.

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No (uses dir name) | Lowercase letters, numbers, hyphens (max 64 chars). Must match parent directory name. |
| `description` | Recommended | What the skill does and when to use it. Claude uses this for auto-invocation decisions. Max 1024 chars. |
| `argument-hint` | No | Hint for autocomplete, e.g. `[issue-number]` |
| `disable-model-invocation` | No | `true` prevents Claude from loading/invoking automatically. Default: `false`. |
| `user-invocable` | No | `false` hides from `/` menu. Default: `true`. |
| `allowed-tools` | No | Space-delimited tools pre-approved when skill is active |
| `model` | No | Model to use when skill is active |
| `context` | No | `fork` to run in a forked subagent context |
| `agent` | No | Which subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom) |
| `hooks` | No | Hooks scoped to this skill's lifecycle |
| `license` | No | License name or reference (Agent Skills spec) |
| `compatibility` | No | Environment requirements (Agent Skills spec, max 500 chars) |
| `metadata` | No | Arbitrary key-value pairs (Agent Skills spec) |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context behavior |
|:------------|:----------------|:------------------|:-----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context; loads when Claude invokes |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking. If absent, args appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]` / `$N` | Access argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Skill Directory Structure

```
skill-name/
├── SKILL.md           # Required — instructions + frontmatter
├── scripts/           # Executable code Claude can run
├── references/        # Detailed docs loaded on demand
└── assets/            # Templates, images, data files
```

### Progressive Disclosure

1. **Metadata** (~100 tokens): `name` + `description` always in context for all skills
2. **Instructions** (<5000 tokens recommended): full SKILL.md loads when skill activates
3. **Resources** (as needed): supporting files load only when required

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Dynamic Context Injection

The `` !`command` `` syntax runs a shell command before skill content is sent to Claude. Output replaces the placeholder. Example: `` !`gh pr diff` `` fetches live PR data. This is preprocessing -- Claude only sees the final rendered output.

### Running Skills in a Subagent

Add `context: fork` to run a skill in isolation. The skill content becomes the subagent's task prompt. Use `agent` to select the execution environment (built-in or custom from `.claude/agents/`). The subagent does not see conversation history.

### Restricting Skill Access

- **Disable all skills**: deny `Skill` tool in `/permissions`
- **Allow/deny specific skills**: `Skill(name)` for exact match, `Skill(name *)` for prefix match
- **Hide individual skills**: `disable-model-invocation: true` in frontmatter

### Skill Description Budget

Skill descriptions share a character budget: 2% of context window (fallback 16,000 chars). Run `/context` to check for excluded skills. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

### Sharing Skills

- **Project**: commit `.claude/skills/` to version control
- **Plugins**: create `skills/` directory in your plugin
- **Managed**: deploy organization-wide through managed settings

### Agent Skills Spec Validation

```bash
skills-ref validate ./my-skill
```

Validates SKILL.md frontmatter and naming conventions using the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library.

### Tips

- Include "ultrathink" in skill content to enable extended thinking
- Use `once` field in skill hooks to fire only on first invocation
- Commands and skills both create `/name` commands; skills take precedence if names collide

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- creating skills, bundled skills, frontmatter reference, skill locations, supporting files, invocation control, tool restrictions, argument passing, dynamic context injection, subagent execution, skill access control, visual output generation, sharing, and troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) -- the open standard format: directory structure, SKILL.md format, frontmatter fields (name, description, license, compatibility, metadata, allowed-tools), body content, optional directories (scripts, references, assets), progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
