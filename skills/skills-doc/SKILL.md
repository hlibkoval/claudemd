---
name: skills-doc
description: Complete documentation for Claude Code skills and the Agent Skills open standard -- creating skills (SKILL.md structure, frontmatter fields, markdown body), skill locations (enterprise, personal ~/.claude/skills/, project .claude/skills/, plugin), automatic discovery from nested directories and --add-dir, frontmatter reference (name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, context, agent, hooks), string substitutions ($ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}), supporting files (references/, scripts/, assets/, progressive disclosure), invocation control (disable-model-invocation vs user-invocable, invocation matrix), restricting tool access (allowed-tools), passing arguments ($ARGUMENTS, positional $0/$1/$2), dynamic context injection with bang-backtick syntax, running skills in subagents (context: fork, agent field, Explore/Plan/general-purpose), restricting Claude's skill access (Skill permission rules, Skill(name), Skill(name *)), sharing skills (project commit, plugins, managed settings), generating visual output (bundled scripts pattern), bundled skills (/batch, /claude-api, /debug, /loop, /simplify), troubleshooting (skill not triggering, triggers too often, Claude doesn't see all skills, SLASH_COMMAND_TOOL_CHAR_BUDGET), Agent Skills specification (directory structure, SKILL.md format, name/description/license/compatibility/metadata/allowed-tools fields, body content recommendations, optional directories scripts/references/assets, progressive disclosure, file references, validation with skills-ref). Load when discussing skills, SKILL.md, creating skills, skill frontmatter, slash commands, custom commands, .claude/commands/, skill invocation, disable-model-invocation, user-invocable, context fork, allowed-tools in skills, $ARGUMENTS, string substitutions in skills, bundled skills, /batch, /simplify, /debug, /loop, /claude-api, Agent Skills specification, agentskills.io, skill sharing, plugin skills, supporting files in skills, progressive disclosure, or skill troubleshooting.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. A `SKILL.md` file with YAML frontmatter and markdown instructions becomes part of Claude's toolkit. Claude loads skills automatically when relevant, or users invoke them directly with `/skill-name`.

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard, with Claude Code extensions for invocation control, subagent execution, and dynamic context injection.

### Skill Locations

| Scope | Path | Applies to |
|:------|:-----|:-----------|
| **Enterprise** | Managed settings | All users in organization |
| **Personal** | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| **Project** | `.claude/skills/<name>/SKILL.md` | This project only |
| **Plugin** | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts with other levels). Nested `.claude/skills/` directories are auto-discovered when working in subdirectories. Skills from `--add-dir` directories are loaded and support live change detection.

### Skill Directory Structure

```
my-skill/
  SKILL.md           # Main instructions (required)
  template.md        # Template for Claude to fill in
  examples/
    sample.md        # Example output
  scripts/
    validate.sh      # Script Claude can execute
```

### Frontmatter Reference

All fields are optional. Only `description` is recommended.

| Field | Description |
|:------|:------------|
| `name` | Display name (lowercase, numbers, hyphens; max 64 chars). Defaults to directory name. |
| `description` | What the skill does and when to use it. Claude uses this for auto-loading decisions. |
| `argument-hint` | Hint shown during autocomplete (e.g., `[issue-number]`). |
| `disable-model-invocation` | `true` = only user can invoke. Hides from Claude's context entirely. |
| `user-invocable` | `false` = hidden from `/` menu. Only Claude can invoke. |
| `allowed-tools` | Tools Claude can use without asking permission when skill is active. |
| `model` | Model to use when skill is active. |
| `context` | Set to `fork` to run in a forked subagent context. |
| `agent` | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom). |
| `hooks` | Hooks scoped to this skill's lifecycle. |

### Invocation Control Matrix

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|:------------|:----------------|:------------------|:----------------|
| (default) | Yes | Yes | Description always loaded; full skill on invoke |
| `disable-model-invocation: true` | Yes | No | Description not in context; loads on user invoke |
| `user-invocable: false` | No | Yes | Description always loaded; full skill on invoke |

### String Substitutions

| Variable | Description |
|:---------|:------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g., `$0`, `$1`) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

### Dynamic Context Injection

The bang-backtick syntax runs shell commands before the skill content is sent to Claude. The command output replaces the placeholder.

Example: `- PR diff:` followed by bang-backtick `gh pr diff` runs `gh pr diff` and inserts the output. This is preprocessing -- Claude only sees the final result.

### Running Skills in Subagents

Add `context: fork` to run a skill in isolation. The skill content becomes the subagent's prompt (no conversation history). The `agent` field selects the execution environment:

- `Explore` -- read-only tools optimized for codebase exploration
- `Plan` -- planning-focused agent
- `general-purpose` -- default full-capability agent
- Custom agents from `.claude/agents/`

### Restricting Claude's Skill Access

Three mechanisms:

| Method | How |
|:-------|:----|
| **Disable all skills** | Deny the `Skill` tool in `/permissions` |
| **Allow/deny specific skills** | Permission rules: `Skill(name)` exact match, `Skill(name *)` prefix match |
| **Hide individual skills** | `disable-model-invocation: true` in frontmatter |

### Passing Arguments

Arguments are available via `$ARGUMENTS`. If `$ARGUMENTS` is not present in the content, arguments are appended as `ARGUMENTS: <value>`. Positional access: `$ARGUMENTS[0]` or `$0` for first argument, etc.

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Orchestrate large-scale parallel changes across a codebase using git worktrees |
| `/claude-api` | Load Claude API and Agent SDK reference for your project's language |
| `/debug [description]` | Troubleshoot current session by reading the debug log |
| `/loop [interval] <prompt>` | Run a prompt repeatedly on an interval |
| `/simplify [focus]` | Review recently changed files for reuse, quality, and efficiency issues |

### Agent Skills Specification (agentskills.io)

The open standard that Claude Code skills are built on.

#### Spec Frontmatter Fields

| Field | Required | Constraints |
|:------|:---------|:------------|
| `name` | Yes | Max 64 chars, lowercase alphanumeric + hyphens, must match directory name |
| `description` | Yes | Max 1024 chars, describes what/when |
| `license` | No | License name or reference to bundled file |
| `compatibility` | No | Max 500 chars, environment requirements |
| `metadata` | No | Arbitrary key-value mapping |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

#### Name Constraints

- 1-64 characters, lowercase letters + numbers + hyphens only
- Must not start/end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name

#### Progressive Disclosure

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (<5000 tokens recommended): full SKILL.md body loaded when skill is activated
3. **Resources** (as needed): files in `scripts/`, `references/`, `assets/` loaded only when required

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

#### Validation

```bash
skills-ref validate ./my-skill
```

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Skill not triggering | Check description keywords; verify with "What skills are available?"; try `/skill-name` directly |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Claude doesn't see all skills | Descriptions may exceed character budget (2% of context window, fallback 16,000 chars); run `/context` to check; override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var |

### Sharing Skills

- **Project**: commit `.claude/skills/` to version control
- **Plugins**: create a `skills/` directory in your plugin
- **Managed**: deploy organization-wide through managed settings

### Custom Commands Compatibility

`.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy`. Existing `.claude/commands/` files keep working. If a skill and a command share the same name, the skill takes precedence.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) -- creating skills, skill locations, frontmatter reference, invocation control, string substitutions, dynamic context injection, running skills in subagents, restricting skill access, passing arguments, supporting files, bundled skills (/batch, /claude-api, /debug, /loop, /simplify), generating visual output, sharing skills, troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) -- the open standard for agent skills: SKILL.md format, directory structure, frontmatter fields (name, description, license, compatibility, metadata, allowed-tools), body content recommendations, optional directories (scripts/, references/, assets/), progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
