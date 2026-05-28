---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating and configuring skills (SKILL.md format, frontmatter fields, invocation control, arguments, dynamic context injection, subagent execution), skill storage locations and discovery, bundled skills, the Agent Skills open standard (directory structure, frontmatter spec, progressive disclosure), sharing skills via plugins or managed settings, and troubleshooting.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### What Skills Are

Skills extend what Claude can do. Each skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions. Claude uses skills automatically when relevant, or you invoke one directly with `/skill-name`. Unlike CLAUDE.md, a skill's body loads only when activated — long reference material costs nothing until needed.

Custom commands (`.claude/commands/*.md`) and skills (`.claude/skills/<name>/SKILL.md`) are equivalent; skills add optional features like supporting files, invocation control, and subagent execution.

### Skill Storage Locations

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Enterprise overrides personal; personal overrides project. Plugin skills use `plugin-name:skill-name` namespace. Skills are also discovered from parent directories up to the repo root, and from nested `.claude/skills/` dirs when editing files in subdirectories (monorepo support). Changes to skill files take effect immediately within a running session.

### SKILL.md Frontmatter Fields (Claude Code)

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Display name (defaults to directory name). Only sets command name for plugin-root SKILL.md |
| `description` | Recommended | What the skill does and when. Used by Claude to decide when to auto-load. Combined with `when_to_use`, capped at 1,536 chars |
| `when_to_use` | No | Additional context for auto-invocation trigger phrases |
| `argument-hint` | No | Hint shown in autocomplete (e.g. `[issue-number]`) |
| `arguments` | No | Named positional args for `$name` substitution. Space-separated or YAML list |
| `disable-model-invocation` | No | `true` = only user can invoke; removes from Claude's context |
| `user-invocable` | No | `false` = hidden from `/` menu; Claude can still auto-load |
| `allowed-tools` | No | Tools pre-approved while skill is active (no per-use prompt) |
| `disallowed-tools` | No | Tools removed from pool while skill is active; clears on next message |
| `model` | No | Model override for skill's turn. Accepts same values as `/model` or `inherit` |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max` |
| `context` | No | `fork` to run in an isolated subagent context |
| `agent` | No | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, `general-purpose`) |
| `hooks` | No | Lifecycle hooks scoped to this skill |
| `paths` | No | Glob patterns limiting when skill auto-activates |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell` |

### Agent Skills Standard Frontmatter Fields

| Field | Required | Constraints |
| :--- | :--- | :--- |
| `name` | Yes | 1–64 chars, lowercase + hyphens only, no leading/trailing/consecutive hyphens, must match directory name |
| `description` | Yes | 1–1024 chars, describe what it does and when to use it |
| `license` | No | License name or path to bundled license file |
| `compatibility` | No | 1–500 chars; system packages, network needs, etc. Most skills omit this |
| `metadata` | No | Arbitrary key-value map for additional properties |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

### String Substitutions

| Variable | Value |
| :--- | :--- |
| `$ARGUMENTS` | All arguments passed to the skill invocation |
| `$ARGUMENTS[N]` | Argument at 0-based index N |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named argument declared in `arguments` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing this skill's SKILL.md |

Multi-word arguments: wrap in quotes (`/my-skill "hello world" second` → `$0` = `hello world`).

### Invocation Control

| Frontmatter | You can invoke | Claude can invoke | Context loaded |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always; full body when invoked |
| `disable-model-invocation: true` | Yes | No | Not in context; full body when you invoke |
| `user-invocable: false` | No | Yes | Description always; full body when invoked |

Use `disable-model-invocation: true` for side-effect commands (deploy, commit). Use `user-invocable: false` for background knowledge that isn't a user action.

### Dynamic Context Injection

An exclamation mark immediately followed by a backtick-wrapped command runs that shell command before Claude sees the skill content. The output replaces the placeholder inline. This is preprocessing — Claude only sees the final rendered result.

For multi-line commands: use a fenced code block whose opening fence is immediately followed by an exclamation mark.

- Commands run once over the original file; output is not re-scanned for further placeholders
- The inline form only fires when `!` appears at the start of a line or after whitespace
- Disable with `"disableSkillShellExecution": true` in settings (replaces each command with `[shell command execution disabled by policy]`)

### Skill Content Lifecycle

- Rendered SKILL.md content enters the conversation as one message and stays for the session
- Auto-compaction carries skills forward within a token budget: up to 5,000 tokens each, 25,000 tokens combined, most-recently-invoked first
- Older skills can be dropped after compaction if many are active

### Subagent Execution (`context: fork`)

Add `context: fork` to run the skill in an isolated subagent. The skill content becomes the subagent's prompt; it has no access to conversation history. The `agent` field selects the subagent type (`Explore`, `Plan`, `general-purpose`, or any custom agent in `.claude/agents/`).

| | Skill with `context: fork` | Subagent with `skills` field |
| :--- | :--- | :--- |
| System prompt | From agent type | Subagent's markdown body |
| Task | SKILL.md content | Claude's delegation message |
| Also loads | CLAUDE.md (except Explore/Plan) | Preloaded skills + CLAUDE.md |

### Restricting Skill Access

```text
# Deny all skills:
Skill

# Allow only specific skills:
Skill(commit)
Skill(review-pr *)

# Deny specific skills:
Skill(deploy *)
```

Syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match.

### `skillOverrides` Setting

Override skill visibility without editing SKILL.md (the `/skills` menu writes this for you):

| Value | Listed to Claude | In `/` menu |
| :--- | :--- | :--- |
| `"on"` | Name and description | Yes |
| `"name-only"` | Name only | Yes |
| `"user-invocable-only"` | Hidden | Yes |
| `"off"` | Hidden | Hidden |

Plugin skills are not affected by `skillOverrides`.

### Bundled Skills

| Skill | Purpose |
| :--- | :--- |
| `/run` | Launch and drive your app to see a change working |
| `/verify` | Confirm a code change works without falling back to tests |
| `/run-skill-generator` | Record how to build/launch your project for `/run` and `/verify` |
| `/code-review` | Review diff for correctness and cleanup |
| `/batch` | Run multiple tasks in parallel |
| `/debug` | Debug failing code or tests |
| `/loop` | Run a prompt or command on a recurring interval |
| `/claude-api` | Build/debug/optimize Claude API apps |

### Progressive Disclosure (Agent Skills Standard)

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): full SKILL.md body loaded when activated
3. **Resources** (as needed): files in `scripts/`, `references/`, `assets/` loaded on demand

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Skill Directory Structure

```text
my-skill/
├── SKILL.md           # Main instructions (required)
├── references/        # Detailed docs loaded on demand
├── scripts/           # Executable code
└── assets/            # Templates, data files, images
```

### Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Skill not triggering | Check description keywords; verify via "What skills are available?"; invoke directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Run `/doctor`; raise `skillListingBudgetFraction`; set low-priority skills to `"name-only"` in `skillOverrides`; trim `description`/`when_to_use` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, storage locations, frontmatter reference, invocation control, dynamic context injection, subagent execution, arguments, bundled skills, sharing, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — open standard directory structure, SKILL.md format, frontmatter fields, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
