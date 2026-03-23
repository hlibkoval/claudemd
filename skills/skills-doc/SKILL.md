---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills open standard -- SKILL.md file format (YAML frontmatter + markdown body), frontmatter fields (name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, effort, context, agent, hooks), skill locations and priority (enterprise > personal > project, plugin namespace, automatic discovery from nested directories, --add-dir), bundled skills (/batch, /claude-api, /debug, /loop, /simplify), string substitutions ($ARGUMENTS, $ARGUMENTS[N], $N shorthand, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), supporting files (references/, scripts/, assets/, progressive disclosure with metadata/instructions/resources), invocation control (disable-model-invocation for user-only, user-invocable for Claude-only, context loading behavior), context: fork for subagent execution (agent field with Explore/Plan/general-purpose/custom agents), dynamic context injection with bang-backtick syntax, allowed-tools for tool restriction, argument passing and positional arguments, permission control (Skill tool deny, Skill(name) allow/deny, prefix match with *), sharing skills (project commit, plugins, managed settings), visual output generation (bundled scripts, HTML output), troubleshooting (skill not triggering, triggers too often, budget limit with SLASH_COMMAND_TOOL_CHAR_BUDGET), Agent Skills specification (directory structure, SKILL.md format, name/description/license/compatibility/metadata/allowed-tools fields, name validation rules, body content recommendations, optional directories scripts/references/assets, progressive disclosure levels, file references, validation with skills-ref). Load when discussing skills, SKILL.md, slash commands, custom commands, skill creation, skill frontmatter, skill invocation, disable-model-invocation, user-invocable, allowed-tools, context fork, subagent skills, bundled skills, /batch, /claude-api, /debug, /loop, /simplify, $ARGUMENTS, argument substitution, skill discovery, skill locations, skill priority, skill permissions, Agent Skills standard, agentskills.io, skill specification, skill validation, skill supporting files, progressive disclosure, dynamic context injection, bang-backtick, skill sharing, plugin skills, visual output skills, or extending Claude Code with skills.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills -- reusable SKILL.md-based extensions that teach Claude new capabilities, workflows, and domain knowledge -- plus the Agent Skills open standard specification that skills follow.

## Quick Reference

Skills extend what Claude can do. A `SKILL.md` file with YAML frontmatter and markdown instructions becomes part of Claude's toolkit. Claude loads skills automatically when relevant, or users invoke them directly with `/skill-name`.

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Orchestrate large-scale parallel changes across a codebase using isolated git worktrees |
| `/claude-api` | Load Claude API and Agent SDK reference for your project's language |
| `/debug [description]` | Troubleshoot the current session by reading the debug log |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval while the session stays open |
| `/simplify [focus]` | Review recently changed files for code quality and efficiency, then fix issues |

### Skill Locations and Priority

| Location | Path | Scope |
|:---------|:-----|:------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority order: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts with other levels). If a skill and a `.claude/commands/` file share the same name, the skill takes precedence.

Nested `.claude/skills/` directories are auto-discovered (e.g., `packages/frontend/.claude/skills/`). Skills from `--add-dir` directories are also loaded and support live change detection.

### Frontmatter Reference

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | Display name; defaults to directory name. Lowercase letters, numbers, hyphens only (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Claude uses this to decide when to load the skill. |
| `argument-hint` | No | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | No | `true` = only user can invoke via `/name`. Default: `false`. |
| `user-invocable` | No | `false` = hidden from `/` menu, only Claude can invoke. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without permission when this skill is active. |
| `model` | No | Model to use when this skill is active. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `max` (Opus 4.6 only). |
| `context` | No | `fork` = run in a forked subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|:------------|:----------------|:------------------|:----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; full skill loads on user invoke |
| `user-invocable: false` | No | Yes | Description always in context; full skill loads when invoked |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

If `$ARGUMENTS` is absent from skill content, arguments are appended as `ARGUMENTS: <value>`.

### Skill Directory Structure

```
my-skill/
  SKILL.md           # Required: metadata + instructions
  scripts/           # Optional: executable code
  references/        # Optional: documentation loaded on demand
  assets/            # Optional: templates, resources
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files and reference them from SKILL.md so Claude knows when to load them.

### Progressive Disclosure

| Level | Content | Size guidance |
|:------|:--------|:-------------|
| Metadata | `name` + `description` (always loaded for all skills) | ~100 tokens |
| Instructions | Full SKILL.md body (loaded when skill activates) | < 5000 tokens recommended |
| Resources | Files in scripts/, references/, assets/ (loaded on demand) | Unlimited |

### Dynamic Context Injection

The `` !`<command>` `` syntax runs shell commands before the skill content reaches Claude. The command output replaces the placeholder inline. Example: `` !`gh pr diff` `` gets replaced with the actual diff output.

### Subagent Execution (context: fork)

Set `context: fork` to run a skill in an isolated subagent. The skill content becomes the subagent's prompt (no conversation history). Specify `agent` to choose the execution environment:

| Agent | Description |
|:------|:------------|
| `Explore` | Read-only tools optimized for codebase exploration |
| `Plan` | Planning-focused agent |
| `general-purpose` | Default agent with full tool access |
| Custom | Any agent defined in `.claude/agents/` |

### Permission Control

| Method | Syntax |
|:-------|:-------|
| Deny all skills | Add `Skill` to deny rules in `/permissions` |
| Allow specific skill | `Skill(commit)` (exact match) |
| Allow with prefix | `Skill(review-pr *)` (prefix match with any args) |
| Deny specific skill | `Skill(deploy *)` in deny rules |
| Hide from Claude | `disable-model-invocation: true` in frontmatter |

### Skill Description Budget

Skill descriptions are loaded into context so Claude knows what is available. The budget scales at 2% of the context window (fallback: 16,000 characters). Run `/context` to check for warnings about excluded skills. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.

### Agent Skills Specification (agentskills.io)

Claude Code skills follow the Agent Skills open standard. Key specification rules:

**Name field constraints:**
- 1-64 characters, lowercase alphanumeric + hyphens only
- No leading/trailing hyphens, no consecutive hyphens
- Must match parent directory name

**Description field:** 1-1024 characters, should describe both what the skill does and when to use it.

**Optional spec fields:**

| Field | Constraint | Purpose |
|:------|:-----------|:--------|
| `license` | Free-form | License name or reference to bundled file |
| `compatibility` | Max 500 chars | Environment requirements (tools, packages, network) |
| `metadata` | String key-value map | Arbitrary additional properties |
| `allowed-tools` | Space-delimited | Pre-approved tools (experimental) |

**Validation:** Use `skills-ref validate ./my-skill` to check frontmatter and naming conventions.

### Sharing Skills

| Method | How |
|:-------|:----|
| Project | Commit `.claude/skills/` to version control |
| Plugin | Add `skills/` directory in a plugin |
| Organization | Deploy via managed settings |

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Skill not triggering | Check description includes natural keywords; verify skill appears in `What skills are available?`; try `/skill-name` directly |
| Triggers too often | Make description more specific; add `disable-model-invocation: true` for manual-only |
| Too many skills, some excluded | Run `/context` to check budget; set `SLASH_COMMAND_TOOL_CHAR_BUDGET` to increase limit |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- creating skills (SKILL.md with frontmatter + markdown), skill locations and priority (enterprise > personal > project, plugin namespace, nested auto-discovery, --add-dir), bundled skills (/batch, /claude-api, /debug, /loop, /simplify), configure skills (reference vs task content, frontmatter reference with all fields, supporting files, invocation control with disable-model-invocation and user-invocable, tool restriction with allowed-tools, argument passing with $ARGUMENTS/$N positional), advanced patterns (dynamic context injection with bang-backtick, subagent execution with context: fork and agent field, permission control with Skill tool allow/deny), sharing (project, plugins, managed settings), visual output generation (bundled scripts, HTML output, codebase-visualizer example), troubleshooting (not triggering, triggers too often, budget limit), related resources
- [Agent Skills specification](references/agent-skills-specification.md) -- open standard directory structure (SKILL.md + optional scripts/references/assets), SKILL.md format (YAML frontmatter + markdown body), frontmatter fields (name with validation rules, description 1-1024 chars, license, compatibility max 500 chars, metadata string map, allowed-tools space-delimited), body content recommendations (step-by-step instructions, examples, edge cases), optional directories (scripts for executable code, references for documentation, assets for static resources), progressive disclosure (metadata ~100 tokens, instructions < 5000 tokens, resources on demand), file references (relative paths, one level deep), validation with skills-ref tool

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
