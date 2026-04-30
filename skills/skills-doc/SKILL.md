---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend Claude's capabilities via a `SKILL.md` file with YAML frontmatter + markdown instructions. Skills live in a named directory. The directory name becomes the `/slash-command`. Claude auto-loads skills whose `description` matches the conversation, or users invoke them directly.

### Where skills live

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | Managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Enterprise > personal > project precedence. Plugin skills use `plugin-name:skill-name` namespace (no conflicts).

### Skill directory structure

```
my-skill/
├── SKILL.md           # Required: metadata + instructions
├── scripts/           # Optional: executable code
├── references/        # Optional: documentation loaded on demand
├── assets/            # Optional: templates, static resources
└── ...
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### SKILL.md frontmatter fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | No | Display name. Defaults to directory name. Lowercase, numbers, hyphens; max 64 chars. |
| `description` | Recommended | What the skill does and when to use it. Claude uses this to decide when to auto-load. First 1,536 chars (combined with `when_to_use`) indexed. |
| `when_to_use` | No | Additional trigger context appended to `description` in the skill listing. |
| `argument-hint` | No | Autocomplete hint for expected arguments (e.g. `[issue-number]`). |
| `arguments` | No | Named positional args for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No | `true` = only user can invoke. Removes skill from Claude's context. Default: `false`. |
| `user-invocable` | No | `false` = hidden from `/` menu; only Claude can invoke. Default: `true`. |
| `allowed-tools` | No | Tools pre-approved for use while skill is active (no per-use approval). Space-separated or YAML list. |
| `model` | No | Model override for the skill's turn. Accepts same values as `/model` or `inherit`. |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | No | `fork` = run in an isolated subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, `general-purpose`). |
| `hooks` | No | Hooks scoped to this skill's lifecycle (same format as settings hooks). |
| `paths` | No | Glob patterns limiting when the skill auto-activates (comma-separated or YAML list). |
| `shell` | No | Shell for inline commands: `bash` (default) or `powershell`. |

#### Agent Skills open standard frontmatter (subset supported by agentskills.io)

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | 1–64 chars, lowercase alphanumeric + hyphens; must match directory name; no consecutive hyphens. |
| `description` | Yes | 1–1,024 chars. What it does and when to use it. |
| `license` | No | License name or path to bundled file. |
| `compatibility` | No | Up to 500 chars. Environment requirements (intended product, packages, network). |
| `metadata` | No | Arbitrary key→value map for additional properties. |
| `allowed-tools` | No | Space-delimited pre-approved tools. Experimental. |

### Invocation control matrix

| Frontmatter | User can invoke | Claude can invoke | When in context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always; full content on invocation |
| `disable-model-invocation: true` | Yes | No | Description not in context; full content on user invocation |
| `user-invocable: false` | No | Yes | Description always; full content on invocation |

### String substitutions

| Variable | Description |
| :--- | :--- |
| `$ARGUMENTS` | All arguments passed to the skill. Appended as `ARGUMENTS: <value>` if not present in content. |
| `$ARGUMENTS[N]` | Specific argument by 0-based index. |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`). |
| `$name` | Named argument declared in `arguments` frontmatter. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_EFFORT}` | Current effort level string. |
| `${CLAUDE_SKILL_DIR}` | Directory containing this skill's `SKILL.md`. Use for bundled scripts. |

Wrap multi-word arguments in quotes: `/my-skill "hello world" second` → `$0` = `hello world`, `$1` = `second`.

### Dynamic context injection

The `!` followed by a backtick-delimited command runs shell commands before skill content is sent to Claude. Output replaces the placeholder. This is preprocessing — Claude only sees the final result.

For multi-line commands use a fenced block opened with three backticks and `!`.

To disable this behavior: set `"disableSkillShellExecution": true` in settings. Each command is replaced with `[shell command execution disabled by policy]`.

### Running skills in a subagent (`context: fork`)

Add `context: fork` to run the skill in an isolated context (no conversation history). The `agent` field picks the subagent type. Results are summarized back to the main conversation.

| Approach | System prompt | Task | Also loads |
| :--- | :--- | :--- | :--- |
| Skill with `context: fork` | From agent type (`Explore`, `Plan`, etc.) | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

Warning: `context: fork` only makes sense for skills with explicit task instructions — guidelines without a task return without meaningful output.

### Controlling which skills Claude can invoke

Three ways:

- **Deny all**: add `Skill` to deny rules in `/permissions`
- **Allow/deny specific**: use permission rules `Skill(commit)`, `Skill(deploy *)`
- **Per-skill**: add `disable-model-invocation: true` to the skill's frontmatter

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match.

### Skill content lifecycle

- When invoked, the rendered `SKILL.md` enters the conversation as a single message and stays for the session.
- Auto-compaction: keeps first 5,000 tokens of each invoked skill; combined budget 25,000 tokens across all skills.
- If compacted out, re-invoke the skill to restore full content.

### Pre-approving tools

`allowed-tools` grants permission for listed tools while the skill is active. Does not restrict other tools — your permission settings still govern everything else.

### Progressive disclosure (Agent Skills standard)

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills.
2. **Instructions** (< 5,000 tokens recommended): full `SKILL.md` body loaded on activation.
3. **Resources** (as needed): files in `scripts/`, `references/`, `assets/` loaded only when required.

### Validating skills (Agent Skills standard)

```bash
skills-ref validate ./my-skill
```

Checks that `SKILL.md` frontmatter is valid and follows naming conventions.

### Sharing skills

| Scope | Method |
| :--- | :--- |
| Project skills | Commit `.claude/skills/` to version control |
| Plugins | Add a `skills/` directory in your plugin |
| Managed | Deploy organization-wide through managed settings |

### Live change detection

Editing skills under `~/.claude/skills/` or the project `.claude/skills/` takes effect in the current session without restarting. Creating a brand-new top-level skills directory requires restarting Claude Code.

### Troubleshooting

| Problem | Resolution |
| :--- | :--- |
| Skill not triggering | Check description includes natural-language keywords; verify skill appears in "What skills are available?"; invoke directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var; trim `description`/`when_to_use` and front-load the key use case (capped at 1,536 chars per entry) |
| Skill stops influencing behavior | Content is likely still present but model chose other approaches; strengthen description or use hooks for deterministic enforcement; re-invoke after compaction |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — getting started, skill types (reference vs task content), frontmatter reference, string substitutions, adding supporting files, invocation control, skill content lifecycle, pre-approving tools, passing arguments, dynamic context injection, running skills in subagents, restricting skill access, sharing skills, generating visual output, and troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — open standard for skills across AI tools: directory structure, SKILL.md format, all frontmatter fields with constraints, body content guidance, optional directories (scripts/references/assets), progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
