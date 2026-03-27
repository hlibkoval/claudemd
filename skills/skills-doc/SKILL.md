---
name: skills-doc
description: Complete documentation for Claude Code skills (Agent Skills) -- creating, configuring, sharing, and troubleshooting skills. Covers the Agent Skills open standard (SKILL.md format, frontmatter fields, directory structure, progressive disclosure, file references, validation with skills-ref), Claude Code skill features (bundled skills /batch /claude-api /debug /loop /simplify, skill locations personal/project/plugin/enterprise/monorepo auto-discovery, frontmatter fields name/description/argument-hint/disable-model-invocation/user-invocable/allowed-tools/model/effort/context/agent/hooks/paths/shell, string substitutions $ARGUMENTS/$ARGUMENTS[N]/$N/${CLAUDE_SESSION_ID}/${CLAUDE_SKILL_DIR}, dynamic context injection with shell commands, context: fork for subagent execution with agent types Explore/Plan/general-purpose, invocation control disable-model-invocation vs user-invocable, tool restriction allowed-tools, permission rules Skill(name)/Skill(name *), supporting files references/scripts/assets, sharing via project commit/plugins/managed settings, visual output generation pattern, SLASH_COMMAND_TOOL_CHAR_BUDGET, skill triggering and troubleshooting). Load when discussing Claude Code skills, Agent Skills specification, creating skills, SKILL.md format, skill frontmatter, custom commands, slash commands, bundled skills, /batch, /claude-api, /debug, /loop, /simplify, skill invocation control, disable-model-invocation, user-invocable, context: fork, skill subagents, $ARGUMENTS, dynamic context injection, shell command injection in skills, allowed-tools, skill permissions, skill triggering, skill directory structure, progressive disclosure, skill sharing, agentskills.io, or any skill-related topic for Claude Code.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Orchestrate large-scale parallel changes across a codebase in isolated git worktrees |
| `/claude-api` | Load Claude API and Agent SDK reference for your project's language; auto-activates on `anthropic` imports |
| `/debug [description]` | Enable debug logging and troubleshoot issues by reading session debug logs |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval (e.g., `/loop 5m check if the deploy finished`) |
| `/simplify [focus]` | Review recently changed files for code reuse, quality, and efficiency issues, then fix them |

### Skill Locations

| Scope | Path | Applies to |
|:------|:-----|:-----------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills from `--add-dir` directories are also loaded with live change detection. Monorepo auto-discovery: editing files in `packages/frontend/` also searches `packages/frontend/.claude/skills/`.

### Directory Structure

```
my-skill/
  SKILL.md           # Required: frontmatter + instructions
  scripts/           # Optional: executable code
  references/        # Optional: documentation loaded on demand
  assets/            # Optional: templates, resources
```

### Frontmatter Fields (Claude Code)

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | Display name; defaults to directory name. Lowercase letters, numbers, hyphens (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Claude uses this for auto-invocation decisions. |
| `argument-hint` | No | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | No | `true` prevents Claude from auto-loading the skill. Default: `false`. |
| `user-invocable` | No | `false` hides from `/` menu. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without per-use approval when the skill is active. |
| `model` | No | Model to use when the skill is active. |
| `effort` | No | Effort level override. Options: `low`, `medium`, `high`, `max`. |
| `context` | No | Set to `fork` to run in a forked subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (e.g., `Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |
| `paths` | No | Glob patterns limiting when the skill auto-activates; comma-separated or YAML list. |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell`. |

### Frontmatter Fields (Agent Skills Standard)

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | 1-64 chars, lowercase alphanumeric + hyphens, must match directory name. |
| `description` | Yes | 1-1024 chars, describes what the skill does and when to use it. |
| `license` | No | License name or reference to bundled license file. |
| `compatibility` | No | Max 500 chars. Environment requirements (product, packages, network). |
| `metadata` | No | Arbitrary key-value mapping for additional metadata. |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental). |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|:------------|:----------------|:------------------|:----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads on manual invoke |
| `user-invocable: false` | No | Yes | Description always in context; loads when invoked |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Dynamic Context Injection

The `` !`<command>` `` syntax runs shell commands before skill content is sent to Claude. Output replaces the placeholder inline -- this is preprocessing, not something Claude executes.

### Running Skills in a Subagent

Set `context: fork` to run a skill in isolation. The skill content becomes the subagent's prompt (no conversation history access). The `agent` field selects the execution environment: built-in agents (`Explore`, `Plan`, `general-purpose`) or custom agents from `.claude/agents/`.

Only makes sense for skills with explicit task instructions. Guidelines-only skills (e.g., "use these conventions") produce no meaningful output in a forked context.

### Permission Rules for Skills

Control which skills Claude can invoke via permission rules:

| Rule | Effect |
|:-----|:-------|
| `Skill` (in deny rules) | Disable all skill invocation |
| `Skill(name)` | Allow/deny exact skill name |
| `Skill(name *)` | Allow/deny skill name prefix with any arguments |

The `user-invocable` field controls menu visibility only, not Skill tool access. Use `disable-model-invocation: true` to block programmatic invocation.

### Progressive Disclosure

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): Full SKILL.md body loaded on activation
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded only when required

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Skill Character Budget

Skill descriptions are loaded into context so Claude knows what is available. Budget: 2% of context window (fallback 16,000 chars). Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. Run `/context` to check for warnings about excluded skills.

### Troubleshooting

| Issue | Solution |
|:------|:---------|
| Skill not triggering | Check description keywords; verify with "What skills are available?"; try `/skill-name` directly |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Claude doesn't see all skills | Check `/context` for budget warnings; increase `SLASH_COMMAND_TOOL_CHAR_BUDGET` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Skills](references/claude-code-skills.md) -- Creating and configuring skills, bundled skills (/batch, /claude-api, /debug, /loop, /simplify), skill locations (enterprise, personal, project, plugin, monorepo auto-discovery, --add-dir), full frontmatter reference (name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, effort, context, agent, hooks, paths, shell), string substitutions ($ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), dynamic context injection with shell commands, context: fork for subagent execution, invocation control (disable-model-invocation vs user-invocable), tool restriction, permission rules (Skill(name), Skill(name *)), supporting files, sharing via project/plugins/managed settings, visual output generation pattern, troubleshooting, skill character budget
- [Agent Skills Specification](references/agent-skills-specification.md) -- Agent Skills open standard (agentskills.io), SKILL.md format specification, directory structure (scripts/, references/, assets/), required and optional frontmatter fields (name, description, license, compatibility, metadata, allowed-tools), name field constraints (lowercase, hyphens, max 64 chars, must match directory), description best practices, body content recommendations, progressive disclosure (metadata ~100 tokens, instructions < 5000 tokens, resources on demand), file references with relative paths, validation with skills-ref CLI tool

## Sources

- Claude Code Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
