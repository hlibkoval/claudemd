---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### What skills are

Skills extend Claude's capabilities via `SKILL.md` files. Claude loads them automatically when relevant, or you invoke one directly with `/skill-name`. Skill body content only loads when the skill is used — long reference material costs nothing until needed.

**Custom commands are merged into skills.** A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy`. Skills add a directory for supporting files, frontmatter control, and auto-invocation.

---

### Where skills live

| Location   | Path                                             | Applies to                     |
| :--------- | :----------------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                                 | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where plugin is enabled        |

Priority when names conflict: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace, avoiding conflicts.

---

### Directory structure

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── template.md        # Optional template
├── examples/
│   └── sample.md      # Optional example output
└── scripts/
    └── validate.sh    # Optional executable script
```

---

### Frontmatter reference (Claude Code extensions)

| Field                      | Required    | Description                                                                                                      |
| :------------------------- | :---------- | :--------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Directory name used if omitted. Lowercase, numbers, hyphens only; max 64 chars.                                  |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this for auto-invocation. Falls back to first paragraph.     |
| `when_to_use`              | No          | Extra trigger context appended to `description` in the skill listing.                                            |
| `argument-hint`            | No          | Hint shown during autocomplete (e.g. `[issue-number]`).                                                          |
| `arguments`                | No          | Named positional arguments for `$name` substitution. Space-separated string or YAML list.                        |
| `disable-model-invocation` | No          | `true` = only user can invoke; description hidden from Claude's context. Use for `/deploy`, `/commit`, etc.      |
| `user-invocable`           | No          | `false` = hidden from `/` menu; Claude can still load automatically. Use for background knowledge skills.        |
| `allowed-tools`            | No          | Tools Claude can use without approval prompts when this skill is active. Space-separated or YAML list.           |
| `model`                    | No          | Model override for this skill's turn. Resets after turn. Same values as `/model`.                                |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. Resets after turn.                              |
| `context`                  | No          | Set to `fork` to run skill in an isolated subagent context.                                                      |
| `agent`                    | No          | Which subagent type to use when `context: fork` is set. Built-in: `Explore`, `Plan`, `general-purpose`.         |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle.                                                                          |
| `paths`                    | No          | Glob patterns: Claude auto-loads the skill only when working with matching files.                                 |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                     |

---

### Invocation control

| Frontmatter                      | User can invoke | Claude can invoke | When loaded into context                                     |
| :------------------------------- | :-------------- | :---------------- | :----------------------------------------------------------- |
| (default)                        | Yes             | Yes               | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes             | No                | Description NOT in context; full skill loads when user invokes |
| `user-invocable: false`          | No              | Yes               | Description always in context; full skill loads when invoked |

---

### String substitutions

| Variable               | Expands to                                                         |
| :--------------------- | :----------------------------------------------------------------- |
| `$ARGUMENTS`           | Full argument string typed after skill name                        |
| `$ARGUMENTS[N]`        | N-th argument (0-based)                                            |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`                                      |
| `$name`                | Named argument declared in `arguments` frontmatter                 |
| `${CLAUDE_SESSION_ID}` | Current session ID                                                 |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`                        |

---

### Dynamic context injection

The `` !`<command>` `` syntax runs shell commands before skill content is sent to Claude. Output replaces the placeholder — Claude only sees the final rendered result.

```yaml
---
name: pr-summary
context: fork
agent: Explore
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
```

For multi-line commands, use a fenced block opened with ` ```! `.

Disable org-wide: `"disableSkillShellExecution": true` in managed settings.

---

### Running skills in a subagent

Add `context: fork` to run the skill in isolation. The skill content becomes the subagent's prompt; it won't have access to conversation history.

```yaml
---
name: deep-research
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

---

### Skill content lifecycle

- Rendered `SKILL.md` enters the conversation as a single message and stays for the session.
- After auto-compaction: top 5,000 tokens of each invoked skill are re-attached, shared budget of 25,000 tokens total. Oldest skills drop first.
- Re-invoke after compaction if a skill stops influencing behavior.

---

### Restrict Claude's skill access

```text
# Deny all skills
Skill

# Allow only specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)
```

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with any arguments.

---

### Agent Skills open standard frontmatter

Fields from the [agentskills.io](https://agentskills.io) specification (subset supported by Claude Code):

| Field           | Required | Constraints                                                                 |
| :-------------- | :------- | :-------------------------------------------------------------------------- |
| `name`          | Yes      | 1-64 chars; `a-z`, `0-9`, `-` only; no leading/trailing/consecutive hyphens; matches directory name |
| `description`   | Yes      | 1-1024 chars; describe what it does AND when to use it                      |
| `license`       | No       | License name or reference to bundled license file                           |
| `compatibility` | No       | 1-500 chars; environment requirements (OS, packages, network access)        |
| `metadata`      | No       | Arbitrary key-value map for additional metadata                             |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools (experimental in open standard)  |

---

### Progressive disclosure (open standard)

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): full `SKILL.md` body loaded on activation
3. **Resources** (as needed): files in `scripts/`, `references/`, `assets/` loaded on demand

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

---

### Troubleshooting

| Problem | Fix |
| :------ | :-- |
| Skill not triggering | Add keywords users would naturally say to `description`; try `/skill-name` directly |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Description cut short | Front-load key use case; `description` + `when_to_use` capped at 1,536 chars per skill; raise `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var |
| Skill stops influencing after first response | Re-invoke after compaction; strengthen `description` and instructions |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [claude-code-skills.md](references/claude-code-skills.md) — Full Claude Code skills guide: creating skills, skill locations, frontmatter fields, invocation control, dynamic context injection, subagent execution, sharing, troubleshooting
- [agent-skills-specification.md](references/agent-skills-specification.md) — Agent Skills open standard specification: directory structure, SKILL.md format, frontmatter fields, optional directories, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
