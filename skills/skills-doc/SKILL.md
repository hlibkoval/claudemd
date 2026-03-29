---
name: skills-doc
description: Complete documentation for Claude Code skills (Agent Skills) -- creating, configuring, sharing, and troubleshooting skills. Covers the Agent Skills open standard (SKILL.md format, frontmatter fields, directory structure, progressive disclosure, file references, validation with skills-ref), Claude Code skills (creating skills, skill locations enterprise/personal/project/plugin, automatic discovery from nested directories, --add-dir skills, types of skill content reference vs task, frontmatter reference with all fields name/description/argument-hint/disable-model-invocation/user-invocable/allowed-tools/model/effort/context/agent/hooks/paths/shell, string substitutions $ARGUMENTS/$ARGUMENTS[N]/$N/${CLAUDE_SESSION_ID}/${CLAUDE_SKILL_DIR}, supporting files, controlling who invokes a skill, invocation control table, restricting tool access, passing arguments with $ARGUMENTS and positional $0/$1/$2, dynamic context injection with inline shell commands, running skills in subagents with context fork and agent field, restricting Claude's skill access with permission rules Skill(name)/Skill(name *), bundled skills /batch /claude-api /debug /loop /simplify, sharing skills project/plugin/managed, generating visual output with bundled scripts, troubleshooting skill not triggering/triggers too often/descriptions cut short with SLASH_COMMAND_TOOL_CHAR_BUDGET). Load when discussing Claude Code skills, Agent Skills specification, SKILL.md format, skill frontmatter, skill creation, skill configuration, skill directory structure, skill invocation control, disable-model-invocation, user-invocable, allowed-tools, skill arguments $ARGUMENTS, context fork, skill subagents, dynamic context injection, bundled skills /batch /claude-api /debug /loop /simplify, skill sharing, skill troubleshooting, progressive disclosure, skill validation, skill paths, skill effort, skill model, skill hooks, skill shell, inline shell commands in skills, or any skills-related topic for Claude Code.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills (Agent Skills) -- covering the Agent Skills open standard specification and Claude Code's skills system.

## Quick Reference

### Skill Directory Structure

```
skill-name/
+-- SKILL.md           # Required: metadata + instructions
+-- scripts/           # Optional: executable code
+-- references/        # Optional: documentation
+-- assets/            # Optional: templates, resources
```

### Where Skills Live

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills in `.claude/commands/` still work; if both exist with same name, skill wins.

### Frontmatter Reference

**Agent Skills spec fields:**

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | 1-64 chars. Lowercase letters, numbers, hyphens only. No leading/trailing/consecutive hyphens. Must match directory name |
| `description` | Yes | 1-1024 chars. What the skill does and when to use it |
| `license` | No | License name or reference to bundled license file |
| `compatibility` | No | 1-500 chars. Environment requirements (product, packages, network) |
| `metadata` | No | Arbitrary key-value map (string keys to string values) |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

**Claude Code additional fields:**

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | If omitted, uses directory name. Max 64 chars, lowercase + hyphens |
| `description` | Recommended | Claude uses this to decide when to load. Truncated at 250 chars in listing |
| `argument-hint` | No | Hint shown during autocomplete (e.g., `[issue-number]`) |
| `disable-model-invocation` | No | `true` = only user can invoke. Default: `false` |
| `user-invocable` | No | `false` = hidden from `/` menu, only Claude can invoke. Default: `true` |
| `allowed-tools` | No | Tools Claude can use without permission when skill is active |
| `model` | No | Model to use when skill is active |
| `effort` | No | Effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only). Overrides session |
| `context` | No | Set to `fork` to run in a forked subagent |
| `agent` | No | Subagent type when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/` |
| `hooks` | No | Hooks scoped to skill lifecycle |
| `paths` | No | Glob patterns limiting when skill activates. Comma-separated string or YAML list |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell` |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context behavior |
|:------------|:----------------|:------------------|:-----------------|
| (default) | Yes | Yes | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context, full skill loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context, full skill loads when invoked |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking. If absent, appended as `ARGUMENTS: <value>` |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g., `$0`, `$1`) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Dynamic Context Injection

Prefix a backtick-wrapped shell command with an exclamation mark to run it before skill content reaches Claude. The syntax is an exclamation mark followed by a backtick-wrapped command (e.g., the command `gh pr diff` wrapped in backticks with a leading exclamation mark). The command output replaces the placeholder inline. Commands execute immediately as preprocessing -- Claude only sees the final output.

Include the word "ultrathink" anywhere in skill content to enable extended thinking.

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Orchestrate large-scale parallel changes across a codebase using git worktrees |
| `/claude-api` | Load Claude API and SDK reference material. Auto-activates on anthropic SDK imports |
| `/debug [description]` | Enable debug logging and troubleshoot issues |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval (default 10m) |
| `/simplify [focus]` | Review changed files for reuse, quality, efficiency; spawns 3 parallel review agents |

### Progressive Disclosure (Token Budget)

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): Full SKILL.md body loads when skill activates
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded on demand

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Restricting Claude's Skill Access

**Deny all skills** in permission rules: `Skill`

**Allow/deny specific skills:**
- `Skill(commit)` -- exact match
- `Skill(review-pr *)` -- prefix match with any arguments
- `Skill(deploy *)` -- deny prefix (in deny rules)

**Hide individual skills:** `disable-model-invocation: true` in frontmatter removes from Claude's context entirely.

### Skill Description Budget

Descriptions are loaded into context so Claude knows available skills. Budget scales at 1% of context window (fallback: 8,000 chars). Each entry capped at 250 chars. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.

### Validation

```bash
skills-ref validate ./my-skill
```

Validates SKILL.md frontmatter and naming conventions using the Agent Skills reference library.

### Troubleshooting

| Issue | Solution |
|:------|:---------|
| Skill not triggering | Check description keywords, verify in `What skills are available?`, try `/skill-name` directly |
| Skill triggers too often | Make description more specific, add `disable-model-invocation: true` |
| Descriptions cut short | Front-load key use case (250 char cap per entry), raise budget with `SLASH_COMMAND_TOOL_CHAR_BUDGET` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with Skills](references/claude-code-skills.md) -- Bundled skills (/batch, /claude-api, /debug, /loop, /simplify), creating skills with SKILL.md, skill locations (enterprise/personal/project/plugin), automatic discovery from nested directories and --add-dir, types of skill content (reference vs task), full frontmatter reference (name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, effort, context, agent, hooks, paths, shell), string substitutions ($ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), supporting files, invocation control (user-only vs Claude-only vs both), restricting tool access, passing arguments with positional access, dynamic context injection with inline shell commands, running skills in subagents with context fork and agent field, restricting Claude's skill access with Skill() permission rules, sharing skills (project/plugin/managed), generating visual output with bundled scripts, troubleshooting (not triggering, triggers too often, descriptions cut short, SLASH_COMMAND_TOOL_CHAR_BUDGET)
- [Agent Skills Specification](references/agent-skills-specification.md) -- The complete Agent Skills open standard format specification: directory structure (SKILL.md, scripts/, references/, assets/), SKILL.md format with YAML frontmatter (name, description, license, compatibility, metadata, allowed-tools) and Markdown body, field validation rules (name constraints, description guidelines), optional directories (scripts with executable code, references with documentation, assets with static resources), progressive disclosure (metadata ~100 tokens, instructions < 5000 tokens, resources as needed), file references with relative paths, validation with skills-ref

## Sources

- Extend Claude with Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
