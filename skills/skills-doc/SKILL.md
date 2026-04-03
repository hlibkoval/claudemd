---
name: skills-doc
description: Complete documentation for Claude Code skills (Agent Skills) -- creating, configuring, sharing, and troubleshooting skills. Covers the Agent Skills open standard (SKILL.md format, frontmatter fields, directory structure, progressive disclosure, file references, validation), Claude Code skill features (bundled skills, skill locations, automatic discovery, invocation control, disable-model-invocation, user-invocable, allowed-tools, context fork, subagent execution, arguments and $ARGUMENTS/$N substitutions, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}, dynamic context injection, path restrictions, shell selection, hooks in skills, effort/model overrides, supporting files, permission rules for Skill tool, description budget, SLASH_COMMAND_TOOL_CHAR_BUDGET), bundled skills (/batch, /claude-api, /debug, /loop, /simplify), skill sharing (project, plugin, managed), visual output generation, and troubleshooting (skill not triggering, triggers too often, descriptions cut short). Load when discussing skills, SKILL.md, Agent Skills, skill frontmatter, skill creation, skill configuration, skill invocation, bundled skills, /batch, skill arguments, $ARGUMENTS, context fork, disable-model-invocation, user-invocable, allowed-tools, skill paths, skill description, progressive disclosure, skill validation, skill sharing, skill troubleshooting, or any skills-related topic for Claude Code.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills -- reusable instructions packaged as SKILL.md files that extend what Claude can do.

## Quick Reference

### Skill Locations

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Nested `.claude/skills/` directories are auto-discovered (monorepo support). `--add-dir` also loads skills from added directories.

### Skill Directory Structure

```
skill-name/
├── SKILL.md           # Required: metadata + instructions
├── scripts/           # Optional: executable code
├── references/        # Optional: documentation
├── assets/            # Optional: templates, resources
└── examples/          # Optional: example outputs
```

### Frontmatter Fields (Claude Code)

| Field | Required | Description |
|:------|:---------|:-----------|
| `name` | No | Display name (directory name if omitted). Lowercase letters, numbers, hyphens only (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Truncated at 250 chars in listings. |
| `argument-hint` | No | Hint for autocomplete, e.g. `[issue-number]`. |
| `disable-model-invocation` | No | `true` = only user can invoke (not in Claude's context). Default: `false`. |
| `user-invocable` | No | `false` = hidden from `/` menu (Claude-only background knowledge). Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without permission when skill is active. Space-separated or YAML list. |
| `model` | No | Model override when skill is active. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `max` (Opus 4.6 only). |
| `context` | No | `fork` = run in a forked subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom). |
| `hooks` | No | Hooks scoped to skill lifecycle. |
| `paths` | No | Glob patterns limiting when skill auto-activates. Comma-separated or YAML list. |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell`. |

### Frontmatter Fields (Agent Skills Standard)

| Field | Required | Constraints |
|:------|:---------|:-----------|
| `name` | Yes | 1-64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens, must match directory name. |
| `description` | Yes | 1-1024 chars. Describes what the skill does and when to use it. |
| `license` | No | License name or reference to bundled file. |
| `compatibility` | No | 1-500 chars. Environment requirements. |
| `metadata` | No | Arbitrary string key-value pairs. |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental). |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context behavior |
|:------------|:---------------|:-----------------|:----------------|
| (default) | Yes | Yes | Description always loaded; full skill loads on invoke |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads when user invokes |
| `user-invocable: false` | No | Yes | Description always loaded; full skill loads on invoke |

### String Substitutions

| Variable | Description |
|:---------|:-----------|
| `$ARGUMENTS` | All arguments passed when invoking. Appended as `ARGUMENTS: <value>` if not present in content. |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md. |

### Dynamic Context Injection

The `` !`<command>` `` syntax runs shell commands before skill content is sent to Claude. Output replaces the placeholder (preprocessing, not Claude execution).

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Orchestrate large-scale parallel changes across a codebase using git worktrees. |
| `/claude-api` | Load Claude API and Agent SDK reference material. Auto-activates on `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk` imports. |
| `/debug [description]` | Enable debug logging and troubleshoot issues. |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval (default 10m). |
| `/simplify [focus]` | Review changed files for reuse, quality, and efficiency issues with three parallel agents. |

### Subagent Execution (`context: fork`)

| Approach | System prompt | Task | Also loads |
|:---------|:-------------|:-----|:-----------|
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

### Permission Control for Skills

```text
# Allow specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)

# Disable all skills
Skill
```

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with arguments.

### Progressive Disclosure

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): Full SKILL.md loaded when activated
3. **Resources** (as needed): Supporting files loaded only when required

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Skill Description Budget

Description budget scales at 1% of context window (fallback: 8,000 chars). Each entry capped at 250 chars. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.

### Troubleshooting

| Problem | Solution |
|:--------|:--------|
| Skill not triggering | Check description keywords match user requests; verify with "What skills are available?"; invoke directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Front-load key use case; trim to under 250 chars; raise budget via `SLASH_COMMAND_TOOL_CHAR_BUDGET` |

### Validation (Agent Skills Standard)

```bash
skills-ref validate ./my-skill
```

Validates SKILL.md frontmatter and naming conventions using the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with Skills](references/claude-code-skills.md) -- Claude Code skills guide: creation, configuration, bundled skills, invocation control, arguments, subagent execution, dynamic context, sharing, visual output, and troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) -- The Agent Skills open standard: SKILL.md format, frontmatter fields, directory structure, progressive disclosure, file references, and validation

## Sources

- Extend Claude with Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
