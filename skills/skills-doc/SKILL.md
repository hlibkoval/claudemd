---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills open standard -- creating skills (SKILL.md format, YAML frontmatter, markdown body), skill locations (enterprise/personal/project/plugin), frontmatter fields (name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, context, agent, hooks), string substitutions ($ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), supporting files (scripts/, references/, assets/), controlling invocation (user-only vs model-only vs both), passing arguments, dynamic context injection with shell commands, running skills in subagents (context fork, agent types), restricting tool access, skill permission rules (Skill(name), Skill(name *)), sharing and distributing skills, bundled skills (/simplify, /batch, /debug, /loop, /claude-api), generating visual output, automatic discovery from nested directories, skill description budget (SLASH_COMMAND_TOOL_CHAR_BUDGET), Agent Skills specification (directory structure, frontmatter schema, progressive disclosure, file references, validation). Load when discussing Claude Code skills, custom commands, slash commands, SKILL.md files, skill creation, skill frontmatter, skill configuration, skill invocation, skill permissions, the Agent Skills standard, or extending Claude Code with custom capabilities.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. A skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions. Claude loads skills automatically when relevant, or users invoke them directly with `/skill-name`.

### Skill Directory Structure

```
skill-name/
  SKILL.md           # Required: frontmatter + instructions
  scripts/           # Optional: executable code
  references/        # Optional: documentation loaded on demand
  assets/            # Optional: templates, resources
```

### Skill Locations

| Scope | Path | Applies to |
|:------|:-----|:-----------|
| **Enterprise** | Managed settings | All users in your organization |
| **Personal** | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| **Project** | `.claude/skills/<name>/SKILL.md` | This project only |
| **Plugin** | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace and cannot conflict. Skills from `--add-dir` directories are also loaded. Nested `.claude/skills/` in subdirectories are discovered automatically (supports monorepos).

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | Display name (lowercase, hyphens, max 64 chars). Defaults to directory name. |
| `description` | Recommended | What the skill does and when to use it. Claude uses this for auto-triggering. |
| `argument-hint` | No | Autocomplete hint, e.g., `[issue-number]` or `[filename] [format]` |
| `disable-model-invocation` | No | `true` = only user can invoke (prevents auto-trigger). Default: `false`. |
| `user-invocable` | No | `false` = hidden from `/` menu, only Claude can invoke. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without asking permission when skill is active. |
| `model` | No | Model override when this skill is active. |
| `context` | No | `fork` = run in an isolated subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (e.g., `Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context behavior |
|:------------|:----------------|:------------------|:-----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context; loads when Claude invokes |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` | Specific argument by 0-based index (e.g., `$ARGUMENTS[0]`) |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g., `$0`, `$1`) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md file |

If `$ARGUMENTS` is not present in skill content, arguments are appended as `ARGUMENTS: <value>`.

### Dynamic Context Injection

The `!` + backtick-command syntax runs shell commands before skill content is sent to Claude. Output replaces the placeholder. This is preprocessing -- Claude only sees the final result.

### Running Skills in Subagents

Add `context: fork` to run a skill in isolation. The skill content becomes the subagent prompt (no conversation history). The `agent` field selects the execution environment. If omitted, uses `general-purpose`.

Skills and subagents work together in two directions:

| Approach | System prompt | Task | Also loads |
|:---------|:-------------|:-----|:-----------|
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

### Bundled Skills

| Skill | Description |
|:------|:------------|
| `/simplify` | Reviews recently changed files for code reuse, quality, and efficiency; spawns 3 parallel review agents, aggregates findings, applies fixes |
| `/batch <instruction>` | Orchestrates large-scale parallel changes across a codebase; decomposes work into 5-30 units, each in an isolated git worktree with its own PR |
| `/debug [description]` | Troubleshoots the current session by reading the session debug log |
| `/loop [interval] <prompt>` | Runs a prompt repeatedly on an interval (e.g., `/loop 5m check if the deploy finished`) |
| `/claude-api` | Loads Claude API and Agent SDK reference for your project's language; also activates when importing `anthropic` or `@anthropic-ai/sdk` |

### Skill Permission Rules

Control which skills Claude can invoke using permission rules:

| Rule | Effect |
|:-----|:-------|
| `Skill` (in deny) | Disable all skill invocation |
| `Skill(commit)` | Exact skill name match |
| `Skill(review-pr *)` | Prefix match with any arguments |
| `Skill(deploy *)` (in deny) | Block specific skill |

### Skill Description Budget

Skill descriptions are loaded into context so Claude knows what is available. The budget scales at 2% of the context window (fallback: 16,000 characters). Run `/context` to check for excluded-skills warnings. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.

### Agent Skills Specification (agentskills.io)

Claude Code skills follow the Agent Skills open standard. The spec defines:

**Required frontmatter fields** (per the open standard):
- `name`: 1-64 chars, lowercase alphanumeric + hyphens, must match directory name, no leading/trailing/consecutive hyphens
- `description`: 1-1024 chars, describes what the skill does and when to use it

**Optional spec fields**:
- `license`: license name or reference to bundled file
- `compatibility`: max 500 chars, environment requirements
- `metadata`: arbitrary key-value map for additional properties
- `allowed-tools`: space-delimited pre-approved tools (experimental)

**Progressive disclosure** (recommended token budgets):
1. Metadata (~100 tokens): name + description, loaded at startup for all skills
2. Instructions (<5000 tokens): full SKILL.md body, loaded when skill activates
3. Resources (as needed): scripts/, references/, assets/ files loaded on demand

Keep SKILL.md under 500 lines. Use relative paths from skill root for file references. Validate with `skills-ref validate ./my-skill`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- creating skills, skill locations, frontmatter reference, string substitutions, supporting files, invocation control, arguments, dynamic context injection, subagent execution, permission rules, bundled skills, sharing skills, generating visual output, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) -- directory structure, SKILL.md format, frontmatter schema (name, description, license, compatibility, metadata, allowed-tools), body content guidelines, optional directories (scripts/, references/, assets/), progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
