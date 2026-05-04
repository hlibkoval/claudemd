---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for creating, configuring, and sharing Claude Code skills, plus the Agent Skills open standard specification.

## Quick Reference

### Skill Directory Layout

```
skill-name/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Optional: detailed docs loaded on demand
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, data files
```

Skills live at:

| Level      | Path                                              | Scope                          |
| :--------- | :------------------------------------------------ | :----------------------------- |
| Enterprise | Managed settings                                  | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`          | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`            | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`           | Where plugin is enabled        |

### Frontmatter Fields (Claude Code)

| Field                      | Required    | Description |
| :------------------------- | :---------- | :---------- |
| `name`                     | No          | Display name (dir name used if omitted). Lowercase letters, numbers, hyphens; max 64 chars. |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this for auto-invocation. Combined with `when_to_use`, truncated at 1,536 chars in the skill listing. |
| `when_to_use`              | No          | Additional trigger context appended to `description` in the skill listing. |
| `argument-hint`            | No          | Shown during autocomplete. E.g. `[issue-number]`. |
| `arguments`                | No          | Named positional args for `$name` substitution. Space-separated or YAML list. |
| `disable-model-invocation` | No          | `true` = user-only invocation; skill hidden from Claude's context entirely. |
| `user-invocable`           | No          | `false` = hidden from `/` menu; Claude can still auto-load. Default: `true`. |
| `allowed-tools`            | No          | Tools Claude can use without prompting when the skill is active. |
| `model`                    | No          | Model override for this skill's turn. |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context`                  | No          | `fork` = run in a forked subagent context. |
| `agent`                    | No          | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`). |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle. |
| `paths`                    | No          | Glob patterns that limit when the skill auto-activates. |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`. |

### Invocation Control

| Frontmatter                      | You can invoke | Claude can invoke | Loaded into context |
| :------------------------------- | :------------- | :---------------- | :------------------ |
| (default)                        | Yes            | Yes               | Description always; full body when invoked |
| `disable-model-invocation: true` | Yes            | No                | Not in context; full body loads when you invoke |
| `user-invocable: false`          | No             | Yes               | Description always; full body when invoked |

### String Substitutions

| Variable               | Expands to |
| :--------------------- | :--------- |
| `$ARGUMENTS`           | Full argument string as typed |
| `$ARGUMENTS[N]`        | Argument at 0-based index N |
| `$N`                   | Shorthand for `$ARGUMENTS[N]` |
| `$name`                | Named arg declared in `arguments` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}`     | Current effort level |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md |

### Dynamic Context Injection

Use `` !`<command>` `` to run shell commands before the skill reaches Claude. Output replaces the placeholder inline:

```yaml
---
name: summarize-changes
description: Summarize uncommitted changes and flag risks.
---

## Current changes

!`git diff HEAD`

## Instructions

Summarize the diff above in 2-3 bullets, then list risks.
```

Multi-line commands use a fenced block opened with ` ```! `.

Disable for all user/project/plugin skills: set `"disableSkillShellExecution": true` in settings.

### Run in a Subagent (`context: fork`)

```yaml
---
name: deep-research
description: Research a topic thoroughly using read-only exploration.
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with file references
```

The `agent` field accepts built-in types (`Explore`, `Plan`, `general-purpose`) or a custom subagent name. Defaults to `general-purpose` if omitted.

### Pre-approve Tools

```yaml
---
name: commit
description: Stage and commit current changes.
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)
---
```

`allowed-tools` grants permission for listed tools while the skill is active; all other tools remain governed by your permission settings.

### Skill Lifecycle and Compaction

Invoked skill content enters the conversation as a single message and stays for the session. On auto-compaction, the most recent invocation of each skill is re-attached (first 5,000 tokens each), sharing a combined 25,000-token budget. Re-invoke a skill after compaction to restore full content.

### Restrict Claude's Access to Skills

```text
# Deny the Skill tool entirely:
Skill

# Allow only specific skills:
Skill(commit)
Skill(review-pr *)

# Deny specific skills:
Skill(deploy *)
```

`Skill(name)` = exact match; `Skill(name *)` = prefix match with any arguments.

### Agent Skills Open Standard — Frontmatter

| Field           | Required | Constraints |
| :-------------- | :------- | :---------- |
| `name`          | Yes      | 1-64 chars; lowercase letters, numbers, hyphens; no leading/trailing/consecutive hyphens; must match directory name. |
| `description`   | Yes      | 1-1024 chars; describe what it does and when to use it. |
| `license`       | No       | License name or bundled license file reference. |
| `compatibility` | No       | 1-500 chars; environment requirements (product, packages, network). |
| `metadata`      | No       | Arbitrary string key-value map. |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools (experimental). |

### Progressive Disclosure (Open Standard)

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills.
2. **Instructions** (< 5,000 tokens recommended): Full `SKILL.md` body loaded when skill is activated.
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded only when required.

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Troubleshooting

| Symptom | Fix |
| :------ | :-- |
| Skill not triggering | Add keywords to `description` matching natural user phrasing; try `/skill-name` to invoke directly. |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true`. |
| Descriptions cut short | Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var, or trim `description`/`when_to_use` text (key use case first). |
| Skill stops influencing behavior | Content likely still present; strengthen description or re-invoke after compaction. |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, directory layout, frontmatter reference, string substitutions, dynamic context injection, subagent execution, invocation control, tool pre-approval, skill content lifecycle, sharing, and troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — open standard for skill format: frontmatter fields, body content, optional directories, progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
