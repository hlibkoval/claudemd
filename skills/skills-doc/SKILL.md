---
name: skills-doc
description: Complete documentation for Claude Code skills (Agent Skills) -- creating, configuring, sharing, and troubleshooting skills. Covers the Agent Skills open standard (SKILL.md format, frontmatter fields, directory structure, progressive disclosure, file references, validation with skills-ref), Claude Code skills (bundled skills /batch /claude-api /debug /loop /simplify, skill creation tutorial, skill locations enterprise/personal/project/plugin, automatic discovery from nested directories, skills from --add-dir directories), skill configuration (reference content vs task content, frontmatter reference with name/description/argument-hint/disable-model-invocation/user-invocable/allowed-tools/model/effort/context/agent/hooks/paths/shell, string substitutions $ARGUMENTS/$ARGUMENTS[N]/$N/${CLAUDE_SESSION_ID}/${CLAUDE_SKILL_DIR}, supporting files with references/scripts/assets, invocation control disable-model-invocation/user-invocable and loading behavior table, restrict tool access with allowed-tools, passing arguments with $ARGUMENTS and positional $0/$1/$2), advanced patterns (dynamic context injection with shell command syntax, run skills in subagent with context fork and agent field, skill+subagent comparison table, research skill example with Explore agent, restrict Claude skill access via permissions Skill(name)/Skill(name *)), sharing skills (project commit, plugins, managed settings, visual output generation with bundled scripts and HTML example codebase-visualizer), troubleshooting (skill not triggering, skill triggers too often, skill descriptions cut short with SLASH_COMMAND_TOOL_CHAR_BUDGET and 250-char cap), and the Agent Skills specification (directory structure SKILL.md/scripts/references/assets, frontmatter fields name/description/license/compatibility/metadata/allowed-tools with constraints, name validation rules, body content recommendations, optional directories scripts/references/assets, progressive disclosure metadata/instructions/resources token budgets, file references with relative paths, validation with skills-ref CLI). Load when discussing Claude Code skills, Agent Skills, SKILL.md format, creating skills, skill frontmatter, skill configuration, skill invocation, skill sharing, skill troubleshooting, disable-model-invocation, user-invocable, context fork, allowed-tools in skills, $ARGUMENTS, dynamic context injection, bundled skills, /batch, slash commands, skill directories, progressive disclosure, skill validation, or any topic about extending Claude Code with skills.
user-invocable: false
---

# Skills (Agent Skills) Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard -- covering creation, configuration, sharing, invocation control, subagent execution, dynamic context injection, and troubleshooting.

## Quick Reference

### Skill Directory Structure

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files
```

### SKILL.md Frontmatter Fields (Agent Skills Standard)

| Field | Required | Constraints |
|:------|:---------|:------------|
| `name` | Yes | Max 64 chars. Lowercase `a-z`, numbers, hyphens. No leading/trailing/consecutive hyphens. Must match directory name |
| `description` | Yes | Max 1024 chars. What the skill does and when to use it |
| `license` | No | License name or reference to bundled license file |
| `compatibility` | No | Max 500 chars. Environment requirements (product, packages, network) |
| `metadata` | No | Arbitrary key-value string map |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

### Claude Code Frontmatter Fields (Extensions)

| Field | Required | Default | Description |
|:------|:---------|:--------|:------------|
| `name` | No | Directory name | Display name. Lowercase letters, numbers, hyphens (max 64 chars) |
| `description` | Recommended | First paragraph | What skill does and when to use it. Truncated at 250 chars in listing |
| `argument-hint` | No | — | Hint shown in autocomplete (e.g., `[issue-number]`) |
| `disable-model-invocation` | No | `false` | `true` = only user can invoke (not Claude) |
| `user-invocable` | No | `true` | `false` = hidden from `/` menu, only Claude can invoke |
| `allowed-tools` | No | — | Tools Claude can use without permission when skill is active |
| `model` | No | — | Model to use when skill is active |
| `effort` | No | Inherited | Effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `context` | No | — | Set to `fork` to run in a forked subagent |
| `agent` | No | `general-purpose` | Subagent type when `context: fork` is set (e.g., `Explore`, `Plan`) |
| `hooks` | No | — | Hooks scoped to this skill's lifecycle |
| `paths` | No | — | Glob patterns limiting when skill auto-activates (comma-separated or YAML list) |
| `shell` | No | `bash` | Shell for inline commands. `powershell` on Windows with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|:------------|:----------------|:------------------|:----------------|
| (default) | Yes | Yes | Description always loaded; full skill on invocation |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads when user invokes |
| `user-invocable: false` | No | Yes | Description always loaded; full skill on invocation |

### Where Skills Live

| Scope | Path | Applies to |
|:------|:-----|:-----------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills take precedence over commands at same name.

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking. Appended as `ARGUMENTS: <value>` if not present in content |
| `$ARGUMENTS[N]` | Specific argument by 0-based index (e.g., `$ARGUMENTS[0]`) |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g., `$0`, `$1`) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Parallel large-scale codebase changes via git worktrees (5-30 units) |
| `/claude-api` | Claude API and SDK reference (auto-activates on anthropic imports) |
| `/debug [description]` | Enable debug logging and troubleshoot issues |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval |
| `/simplify [focus]` | Review changed files for reuse, quality, efficiency; fix issues |

### Dynamic Context Injection

Shell commands in skill content run before Claude sees the prompt:

```
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
```

Each command executes immediately and output replaces the placeholder. This is preprocessing -- Claude only sees the final result.

### Subagent Execution

Add `context: fork` to run a skill in isolation. The skill content becomes the subagent's task prompt (no conversation history access).

| Approach | System prompt | Task | Also loads |
|:---------|:-------------|:-----|:-----------|
| Skill with `context: fork` | From agent type (`Explore`, `Plan`, etc.) | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

### Permission Control for Skills

```
# Allow specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)

# Disable all skills
Skill
```

Syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with arguments.

### Progressive Disclosure (Token Budgets)

| Level | Content | Budget |
|:------|:--------|:-------|
| Metadata | `name` + `description` | ~100 tokens, loaded at startup for all skills |
| Instructions | Full SKILL.md body | < 5000 tokens recommended, loaded on activation |
| Resources | scripts/, references/, assets/ | As needed, loaded on demand |

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Troubleshooting

| Problem | Solution |
|:--------|:---------|
| Skill not triggering | Check description keywords; verify with "What skills are available?"; invoke directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Front-load key use case (250-char cap per entry); raise `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var; budget = 1% of context window (fallback 8000 chars) |

### Validation

```bash
skills-ref validate ./my-skill
```

Validates SKILL.md frontmatter and naming conventions using the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Skills](references/claude-code-skills.md) -- Bundled skills (/batch, /claude-api, /debug, /loop, /simplify), skill creation tutorial (explain-code example), skill locations (enterprise/personal/project/plugin with priority), automatic discovery from nested directories (monorepo support), skills from --add-dir directories (exception to config loading), skill configuration (reference content vs task content, frontmatter reference table, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, effort, context, agent, hooks, paths, shell), string substitutions ($ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), supporting files (references, scripts, assets, keep SKILL.md under 500 lines), invocation control (disable-model-invocation vs user-invocable with behavior table), restrict tool access (allowed-tools field), passing arguments ($ARGUMENTS placeholder, positional $0/$1/$2), advanced patterns (dynamic context injection with shell command preprocessing, subagent execution with context fork and agent field, skill+subagent comparison table, Explore agent research example), restrict Claude skill access (deny Skill tool, allow/deny specific skills with Skill(name)/Skill(name *), disable-model-invocation), sharing skills (project commit, plugins, managed settings), visual output generation (bundled scripts, HTML codebase-visualizer example with Python), troubleshooting (not triggering, triggers too often, descriptions cut short with SLASH_COMMAND_TOOL_CHAR_BUDGET), and related resources (subagents, plugins, hooks, memory, commands, permissions)
- [Agent Skills Specification](references/agent-skills-specification.md) -- Directory structure (SKILL.md required, scripts/references/assets optional), SKILL.md format (YAML frontmatter + Markdown body), frontmatter fields (name with validation rules, description with keyword guidance, license, compatibility, metadata key-value map, allowed-tools space-delimited), body content recommendations (step-by-step instructions, examples, edge cases), optional directories (scripts with self-contained executables, references with focused docs, assets with templates/images/data), progressive disclosure (metadata ~100 tokens at startup, instructions <5000 tokens on activation, resources on demand), file references (relative paths from skill root, one level deep), and validation (skills-ref CLI tool)

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
