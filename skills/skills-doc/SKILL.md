---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills specification — creating skills (SKILL.md, frontmatter, markdown body), skill locations (personal, project, plugin, enterprise), bundled skills (/simplify, /batch, /debug, /loop, /claude-api), frontmatter fields (name, description, disable-model-invocation, user-invocable, allowed-tools, model, context, agent, hooks, argument-hint), string substitutions ($ARGUMENTS, $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), dynamic context injection with bang-backtick, supporting files (scripts/, references/, assets/), running skills in subagents (context fork), controlling invocation (user vs model), restricting tool access, permission rules for skills, sharing and distributing skills, generating visual output, troubleshooting skill triggering, the Agent Skills open standard specification (directory structure, frontmatter schema, progressive disclosure, validation). Load when discussing skill creation, SKILL.md authoring, skill configuration, slash commands, skill triggering, skill frontmatter, skill arguments, the Agent Skills spec, or the /skills menu.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills specification.

## Quick Reference

Skills extend what Claude can do. A skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions. Claude loads skills automatically when relevant, or users can invoke them directly with `/skill-name`. Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard.

### Bundled Skills

| Skill | Description |
|:------|:------------|
| `/simplify` | Reviews recently changed files for code reuse, quality, and efficiency; spawns three review agents in parallel |
| `/batch <instruction>` | Orchestrates large-scale codebase changes in parallel using git worktrees; decomposes work into 5-30 units |
| `/debug [description]` | Troubleshoots the current session by reading the debug log |
| `/loop [interval] <prompt>` | Runs a prompt repeatedly on an interval (e.g., `/loop 5m check if the deploy finished`) |
| `/claude-api` | Loads Claude API and Agent SDK reference for your project's language; auto-activates on anthropic SDK imports |

### Skill Locations

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills are namespaced (`plugin:skill`) and cannot conflict. Skills from `--add-dir` directories and nested `.claude/skills/` in subdirectories are auto-discovered.

### Skill Directory Structure

```
my-skill/
  SKILL.md           # Main instructions (required)
  scripts/           # Executable code Claude can run
  references/        # Additional docs loaded on demand
  assets/            # Static resources (templates, images, data files)
```

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | No | Display name; uses directory name if omitted. Lowercase letters, numbers, hyphens only (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Claude uses this to decide when to load the skill. |
| `argument-hint` | No | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | No | `true` prevents Claude from auto-loading. User-only via `/name`. Default: `false`. |
| `user-invocable` | No | `false` hides from `/` menu. Background knowledge only. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without asking permission when skill is active. |
| `model` | No | Model to use when skill is active. |
| `context` | No | `fork` to run in a forked subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (built-in: `Explore`, `Plan`, `general-purpose`; or custom from `.claude/agents/`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|:------------|:----------------|:------------------|:----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context; loads when invoked |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index (e.g., `$0`, `$1`) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md file |

If `$ARGUMENTS` is not present in the content, arguments are appended as `ARGUMENTS: <value>`.

### Dynamic Context Injection

The bang-backtick syntax runs shell commands before the skill content is sent to Claude. The command output replaces the placeholder inline:

```
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
```

This is preprocessing -- Claude only sees the final rendered output.

### Running Skills in Subagents

Add `context: fork` to run a skill in isolation. The skill content becomes the subagent's prompt (no conversation history). Pair with `agent: Explore` or other agent types for specialized execution environments.

Only use `context: fork` for skills with explicit task instructions. Reference/guideline-only skills produce no meaningful output in a fork.

### Restricting Skill Access

| Method | Effect |
|:-------|:-------|
| `disable-model-invocation: true` | Removes skill from Claude's context entirely |
| Permission deny rule: `Skill(deploy *)` | Blocks Claude from invoking matching skills |
| Permission allow rule: `Skill(commit)` | Allows only specific skills |
| Deny all: `Skill` | Blocks Claude from using any skill |

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with any arguments.

### Skill Description Budget

Skill descriptions are loaded into context so Claude knows what is available. The character budget is 2% of the context window (fallback: 16,000 characters). Run `/context` to check for warnings about excluded skills. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

### Sharing Skills

| Method | How |
|:-------|:----|
| Project | Commit `.claude/skills/` to version control |
| Plugin | Put `skills/` directory in your plugin |
| Managed | Deploy organization-wide through managed settings |

### Agent Skills Specification (agentskills.io)

The Agent Skills open standard defines the portable skill format used by Claude Code and other AI tools.

**Frontmatter schema:**

| Field | Required | Constraints |
|:------|:---------|:------------|
| `name` | Yes | 1-64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens, must match directory name |
| `description` | Yes | 1-1024 chars, describes what the skill does and when to use it |
| `license` | No | License name or reference to bundled file |
| `compatibility` | No | Max 500 chars; environment requirements |
| `metadata` | No | Arbitrary key-value map (string to string) |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

**Progressive disclosure (three-level loading):**

| Level | Content | Token budget |
|:------|:--------|:-------------|
| Metadata | `name` + `description` | ~100 tokens; always loaded |
| Instructions | Full SKILL.md body | < 5000 tokens recommended; loaded on activation |
| Resources | scripts/, references/, assets/ | Unlimited; loaded on demand |

**Validation:** Use `skills-ref validate ./my-skill` to check frontmatter and naming conventions.

### Enabling Extended Thinking

Include the word "ultrathink" anywhere in skill content to enable extended thinking mode.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- creating skills, bundled skills, skill locations, frontmatter reference, supporting files, invocation control, tool restrictions, arguments and substitutions, dynamic context injection, running in subagents, restricting skill access, sharing, generating visual output, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) -- the Agent Skills open standard: directory structure, SKILL.md format, frontmatter schema (name, description, license, compatibility, metadata, allowed-tools), body content, optional directories (scripts/, references/, assets/), progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
