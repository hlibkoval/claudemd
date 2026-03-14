---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills specification — creating skills (SKILL.md structure, frontmatter fields, markdown instructions), skill locations (enterprise/personal/project/plugin), skill types (reference content vs task content), frontmatter reference (name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, context, agent, hooks), string substitutions ($ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), passing arguments to skills, supporting files (references/, scripts/, assets/), invocation control (user-invocable, disable-model-invocation), tool restrictions (allowed-tools), dynamic context injection (bang-backtick syntax), running skills in subagents (context: fork, agent field), skill permissions (Skill tool rules, allow/deny patterns), sharing and distributing skills, bundled skills (/batch, /claude-api, /debug, /loop, /simplify), generating visual output with bundled scripts, automatic discovery from nested directories, skills from --add-dir directories, skill description budget (SLASH_COMMAND_TOOL_CHAR_BUDGET), troubleshooting (not triggering, triggers too often, character budget), Agent Skills open standard specification (directory structure, SKILL.md format, frontmatter schema, name/description/license/compatibility/metadata/allowed-tools fields, body content, optional directories scripts/references/assets, progressive disclosure, file references, validation). Load when discussing Claude Code skills, creating skills, SKILL.md, skill frontmatter, skill invocation, slash commands, custom commands, skill arguments, $ARGUMENTS, context fork, disable-model-invocation, user-invocable, allowed-tools in skills, skill descriptions, skill triggering, bundled skills, /batch, /claude-api, /debug, /loop, /simplify, Agent Skills specification, agentskills.io, skill directories, skill supporting files, dynamic context injection in skills, skill permissions, skill sharing, or extending Claude Code with skills.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard specification.

## Quick Reference

Skills extend what Claude can do. A skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions. Claude loads skills automatically when relevant, or users invoke them directly with `/skill-name`.

Custom commands (`.claude/commands/`) have been merged into skills. Both create `/name` and work the same way. Skills add optional features: supporting files, frontmatter for invocation control, and automatic loading.

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard, with extensions for invocation control, subagent execution, and dynamic context injection.

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Orchestrate large-scale parallel changes across a codebase using git worktrees |
| `/claude-api` | Load Claude API and Agent SDK reference for your project's language |
| `/debug [description]` | Troubleshoot current session by reading the debug log |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval while session stays open |
| `/simplify [focus]` | Review recently changed files for code reuse, quality, and efficiency issues |

### Where Skills Live

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). If a skill and a legacy command share the same name, the skill takes precedence.

Skills in nested `.claude/skills/` directories are auto-discovered (supports monorepo setups). Skills from `--add-dir` directories are also loaded and support live change detection.

### Skill Directory Structure

```
my-skill/
  SKILL.md           # Main instructions (required)
  references/        # Docs loaded into context as needed
  scripts/           # Executable code Claude can run
  assets/            # Templates, images, data files
  examples/          # Example outputs
```

### Frontmatter Reference

All fields are optional. Only `description` is recommended.

| Field | Description |
|:------|:------------|
| `name` | Display name (lowercase, hyphens, max 64 chars). Defaults to directory name |
| `description` | What the skill does and when to use it. Claude uses this to decide when to load |
| `argument-hint` | Hint shown during autocomplete (e.g., `[issue-number]`) |
| `disable-model-invocation` | `true` prevents Claude from auto-loading. Use for manual-only workflows |
| `user-invocable` | `false` hides from `/` menu. Use for background knowledge |
| `allowed-tools` | Tools Claude can use without asking permission when skill is active |
| `model` | Model to use when skill is active |
| `context` | `fork` to run in a forked subagent context |
| `agent` | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom) |
| `hooks` | Hooks scoped to this skill's lifecycle |

### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | When loaded into context |
|:------------|:----------------|:------------------|:-------------------------|
| (default) | Yes | Yes | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context, full skill loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context, full skill loads when invoked |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Access specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

If `$ARGUMENTS` is not present in the content, arguments are appended as `ARGUMENTS: <value>`.

### Skill Types

**Reference content** -- adds knowledge Claude applies to current work (conventions, patterns, style guides). Runs inline.

**Task content** -- step-by-step instructions for specific actions (deploy, commit, code generation). Often paired with `disable-model-invocation: true` for manual-only invocation.

### Dynamic Context Injection

The bang-backtick syntax runs shell commands before skill content is sent to Claude. The command output replaces the placeholder:

```yaml
## Pull request context
- PR diff: INJECT(gh pr diff)
- Changed files: INJECT(gh pr diff --name-only)
```

(Where `INJECT(cmd)` represents the bang-backtick syntax: exclamation mark followed by the command in backticks.)

This is preprocessing -- Claude only sees the final result with actual data.

### Running Skills in a Subagent

Add `context: fork` to run a skill in isolation. The skill content becomes the subagent's prompt (no conversation history access). The `agent` field selects the execution environment.

Skills with `context: fork` need explicit task instructions. Guidelines-only content (e.g., "use these API conventions") without a task will return without meaningful output.

### Skill Permissions

Control which skills Claude can invoke via permission rules:

| Rule | Effect |
|:-----|:-------|
| `Skill` (in deny rules) | Disable all skills |
| `Skill(name)` | Allow/deny exact skill name |
| `Skill(name *)` | Allow/deny skill name prefix with any arguments |

The `user-invocable` field only controls menu visibility, not Skill tool access. Use `disable-model-invocation: true` to block programmatic invocation.

### Skill Description Budget

Skill descriptions are loaded into context so Claude knows what is available. If many skills exceed the character budget, some may be excluded. The budget scales at 2% of the context window (fallback: 16,000 characters). Run `/context` to check for warnings. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.

### Agent Skills Specification (agentskills.io)

The Agent Skills open standard defines the portable format used across multiple AI tools.

**Required frontmatter fields (per spec):**

| Field | Constraints |
|:------|:------------|
| `name` | 1-64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens, must match directory name |
| `description` | 1-1024 chars, describes what the skill does and when to use it |

**Optional spec fields:** `license`, `compatibility` (max 500 chars, environment requirements), `metadata` (arbitrary key-value map), `allowed-tools` (space-delimited, experimental).

**Progressive disclosure (spec):**
1. Metadata (~100 tokens) -- name + description loaded at startup for all skills
2. Instructions (< 5000 tokens recommended) -- full SKILL.md body loaded on activation
3. Resources (as needed) -- scripts/, references/, assets/ loaded only when required

**Validation:** use `skills-ref validate ./my-skill` to check frontmatter and naming conventions.

Note: Claude Code extends the spec with additional fields (`disable-model-invocation`, `user-invocable`, `model`, `context`, `agent`, `hooks`, `argument-hint`) that are not part of the base Agent Skills standard.

### Sharing Skills

- **Project skills**: commit `.claude/skills/` to version control
- **Plugins**: create a `skills/` directory in your plugin
- **Managed**: deploy organization-wide through managed settings

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Skill not triggering | Check description includes keywords users would say; verify with "What skills are available?"; try `/skill-name` directly |
| Triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Not all skills visible | May exceed character budget; run `/context` to check; set `SLASH_COMMAND_TOOL_CHAR_BUDGET` to override |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- creating skills (SKILL.md structure, frontmatter, first skill walkthrough), skill locations (enterprise/personal/project/plugin with priority rules), automatic discovery from nested directories, skills from --add-dir, skill types (reference vs task content), complete frontmatter reference (all fields with descriptions), string substitutions ($ARGUMENTS, $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), supporting files, invocation control (disable-model-invocation, user-invocable with behavior matrix), tool restrictions (allowed-tools), passing arguments to skills, dynamic context injection (bang-backtick preprocessing), running skills in subagents (context: fork, agent field, Explore/Plan/general-purpose agents), restricting skill access (permission rules, Skill tool patterns), bundled skills (/batch, /claude-api, /debug, /loop, /simplify), sharing skills (project/plugin/managed), generating visual output with bundled scripts (codebase visualizer example), troubleshooting (not triggering, triggers too often, character budget)
- [Agent Skills specification](references/agent-skills-specification.md) -- open standard directory structure, SKILL.md format, required frontmatter (name constraints, description), optional frontmatter (license, compatibility, metadata, allowed-tools), body content recommendations, optional directories (scripts/, references/, assets/), progressive disclosure (metadata/instructions/resources), file references, validation with skills-ref

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
