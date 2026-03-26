---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills specification -- creating skills (SKILL.md with YAML frontmatter and markdown body, skill directories with scripts/references/assets), where skills live (enterprise > personal > project > plugin precedence, ~/.claude/skills/ personal, .claude/skills/ project, automatic discovery from nested directories, --add-dir loading), frontmatter fields (name with lowercase-hyphens max 64 chars must match directory, description recommended for auto-invocation, argument-hint for autocomplete, disable-model-invocation to prevent auto-loading, user-invocable false to hide from slash menu, allowed-tools for pre-approved tools, model override, effort level override, context fork for subagent execution, agent type selection, hooks scoped to skill lifecycle, shell bash or powershell), string substitutions ($ARGUMENTS and $ARGUMENTS[N] and $N shorthand and ${CLAUDE_SESSION_ID} and ${CLAUDE_SKILL_DIR}), supporting files (references/ scripts/ assets/ kept under 500 lines in SKILL.md), invocation control (default both user and model, disable-model-invocation true for manual-only, user-invocable false for background knowledge, context loading behavior for each mode), restricting tool access (allowed-tools field), passing arguments ($ARGUMENTS placeholder and positional $ARGUMENTS[N] and $N), dynamic context injection (exclamation-backtick command syntax for shell preprocessing), running in subagent (context fork with agent field for Explore/Plan/general-purpose/custom agents, skill content becomes subagent prompt), restricting Claude's skill access (deny Skill tool in /permissions, allow/deny specific skills with Skill(name) and Skill(name *) prefix match, disable-model-invocation true to hide entirely), sharing skills (project via git, plugins via skills/ directory, managed via organization settings), generating visual output (bundled scripts pattern for HTML/interactive output), troubleshooting (skill not triggering check description keywords, skill triggers too often narrow description, skill budget 2% context window with SLASH_COMMAND_TOOL_CHAR_BUDGET override), bundled skills (/batch for parallel codebase changes with git worktrees, /claude-api for API reference, /debug for session logging, /loop for repeated prompts, /simplify for code review), Agent Skills specification (SKILL.md format with YAML frontmatter, name field 1-64 chars lowercase alphanumeric hyphens no consecutive hyphens must match directory, description field 1-1024 chars with keywords, license field, compatibility field max 500 chars for environment requirements, metadata field string key-value map, allowed-tools field space-delimited, body content with step-by-step instructions and examples and edge cases, optional directories scripts/ references/ assets/, progressive disclosure metadata ~100 tokens then instructions <5000 tokens then resources on demand, file references with relative paths one level deep, validation with skills-ref tool). Load when discussing Claude Code skills, SKILL.md, creating skills, skill frontmatter, skill configuration, disable-model-invocation, user-invocable, allowed-tools in skills, context fork, skill arguments, $ARGUMENTS, dynamic context injection, skill subagents, skill permissions, Skill tool permissions, sharing skills, bundled skills, /batch, /claude-api, /debug, /loop, /simplify, Agent Skills specification, agentskills.io, skill validation, skills-ref, skill directories, skill references, skill scripts, skill metadata, skill description, skill name conventions, argument-hint, skill effort, skill model override, skill hooks, skill shell, ${CLAUDE_SKILL_DIR}, ${CLAUDE_SESSION_ID}, SLASH_COMMAND_TOOL_CHAR_BUDGET, progressive disclosure, supporting files, or any topic related to extending Claude Code with skills.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard -- creating, configuring, sharing, and troubleshooting skills that extend Claude's capabilities.

## Quick Reference

Skills extend what Claude can do. Create a `SKILL.md` file with frontmatter and instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`.

### Where Skills Live

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Precedence: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). If a skill and a `.claude/commands/` command share a name, the skill wins. Nested `.claude/skills/` directories are discovered automatically (supports monorepos). Skills from `--add-dir` directories are loaded with live change detection.

### Skill Directory Structure

```
my-skill/
  SKILL.md           # Required: frontmatter + instructions
  scripts/           # Optional: executable code
  references/        # Optional: documentation
  assets/            # Optional: templates, resources
```

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | Display name; defaults to directory name. Lowercase letters, numbers, hyphens only (max 64 chars). Must match directory name. No leading/trailing/consecutive hyphens. |
| `description` | Recommended | What the skill does and when to use it (max 1024 chars). Claude uses this to decide when to auto-load. |
| `argument-hint` | No | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | No | `true` to prevent Claude from auto-loading. For manual-only workflows like `/deploy`. Default: `false`. |
| `user-invocable` | No | `false` to hide from `/` menu. For background knowledge only. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without permission when skill is active (e.g., `Read, Grep, Glob`). |
| `model` | No | Model override when skill is active. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `max` (Opus 4.6 only). |
| `context` | No | `fork` to run in an isolated subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |
| `shell` | No | `bash` (default) or `powershell` for inline shell commands. |
| `license` | No | License name or reference to bundled file. |
| `compatibility` | No | Environment requirements (max 500 chars). |
| `metadata` | No | Arbitrary string key-value map for additional properties. |

### Invocation Control

| Frontmatter | You invoke | Claude invokes | Context loading |
|:------------|:-----------|:---------------|:----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads when you invoke |
| `user-invocable: false` | No | Yes | Description always in context; loads when invoked |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking. If absent, arguments appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]` / `$N` | Access specific argument by 0-based index. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md. |

### Passing Arguments

Arguments are available via `$ARGUMENTS`. Example: `/fix-issue 123` with `$ARGUMENTS` in content becomes "Fix GitHub issue 123...". Use `$ARGUMENTS[0]`, `$ARGUMENTS[1]` or shorthand `$0`, `$1` for positional access.

### Dynamic Context Injection

The `` !`<command>` `` syntax runs shell commands before content is sent to Claude. Output replaces the placeholder:

```yaml
---
name: pr-summary
context: fork
agent: Explore
---
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
```

Commands execute immediately as preprocessing; Claude only sees the final rendered output.

### Running Skills in a Subagent

Add `context: fork` to run in isolation. The skill content becomes the subagent's prompt (no conversation history access). Pair with `agent` field to select execution environment.

Only use `context: fork` for skills with explicit task instructions. Reference/guideline skills without a concrete task produce no meaningful output in a subagent.

### Restricting Claude's Skill Access

| Method | How |
|:-------|:----|
| Disable all skills | Deny `Skill` tool in `/permissions` |
| Allow/deny specific | `Skill(name)` exact match or `Skill(name *)` prefix match in permission rules |
| Hide individual | `disable-model-invocation: true` in frontmatter |

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Parallel codebase changes across git worktrees (5-30 units, one PR per unit) |
| `/claude-api` | Claude API + Agent SDK reference for your project's language |
| `/debug [description]` | Enable debug logging and troubleshoot session issues |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval (e.g., `/loop 5m check deploy`) |
| `/simplify [focus]` | Review recent changes for reuse/quality/efficiency with 3 parallel agents |

### Skill Description Budget

Skill descriptions are loaded into context so Claude knows what is available. Budget is 2% of context window (fallback 16,000 chars). Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. Run `/context` to check for excluded skills.

### Progressive Disclosure (Agent Skills Spec)

| Layer | Size | When loaded |
|:------|:-----|:------------|
| Metadata (`name` + `description`) | ~100 tokens | Startup, for all skills |
| Instructions (SKILL.md body) | < 5,000 tokens recommended | When skill is activated |
| Resources (scripts/, references/, assets/) | As needed | Only when required |

Keep SKILL.md under 500 lines. Move detailed reference material to separate files. Reference them with relative paths one level deep from SKILL.md.

### Validation (Agent Skills Spec)

```bash
skills-ref validate ./my-skill
```

Checks frontmatter validity and naming conventions using the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library.

### Troubleshooting

| Problem | Fix |
|:--------|:----|
| Skill not triggering | Check description includes natural keywords; verify with "What skills are available?"; try `/skill-name` directly |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Claude doesn't see all skills | Budget exceeded; check `/context` for warnings; set `SLASH_COMMAND_TOOL_CHAR_BUDGET` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- Claude Code skills overview, bundled skills (/batch, /claude-api, /debug, /loop, /simplify), creating first skill (directory structure, SKILL.md with frontmatter and body, testing), where skills live (enterprise/personal/project/plugin locations, precedence, automatic discovery from nested directories, --add-dir loading), configuring skills (reference vs task content, complete frontmatter reference with name/description/argument-hint/disable-model-invocation/user-invocable/allowed-tools/model/effort/context/agent/hooks/shell fields, string substitutions $ARGUMENTS and $ARGUMENTS[N] and $N and ${CLAUDE_SESSION_ID} and ${CLAUDE_SKILL_DIR}), supporting files (references/scripts/assets directories, keeping SKILL.md under 500 lines), invocation control (disable-model-invocation for manual-only, user-invocable false for background knowledge, context loading behavior table), restricting tool access (allowed-tools field), passing arguments ($ARGUMENTS placeholder, positional access), dynamic context injection (exclamation-backtick command preprocessing, ultrathink keyword), running in subagent (context fork, agent field for Explore/Plan/general-purpose/custom, skill as subagent prompt), restricting Claude's skill access (deny Skill tool, allow/deny specific with Skill(name)/Skill(name *) permission syntax, disable-model-invocation to hide), sharing skills (project via git, plugins, managed settings), generating visual output (bundled scripts pattern, codebase visualizer example), troubleshooting (not triggering, triggers too often, budget exceeded with SLASH_COMMAND_TOOL_CHAR_BUDGET)
- [Agent Skills specification](references/agent-skills-specification.md) -- the complete Agent Skills open standard format specification; directory structure (SKILL.md required, optional scripts/references/assets); SKILL.md format with YAML frontmatter (name field 1-64 chars lowercase alphanumeric hyphens no consecutive hyphens must match directory, description 1-1024 chars with task keywords, license, compatibility max 500 chars, metadata string key-value map, allowed-tools space-delimited experimental); body content (no format restrictions, recommended step-by-step instructions and examples and edge cases); optional directories (scripts/ for executable code, references/ for documentation, assets/ for templates and images and data); progressive disclosure (metadata ~100 tokens at startup, instructions <5000 tokens on activation, resources on demand); file references (relative paths one level deep); validation with skills-ref library

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
