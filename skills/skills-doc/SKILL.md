---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating and configuring SKILL.md files, frontmatter fields (description, disable-model-invocation, user-invocable, allowed-tools, context, agent, arguments, paths, model, effort, hooks, shell), string substitutions ($ARGUMENTS, $N, ${CLAUDE_SKILL_DIR}), dynamic context injection, supporting files, subagent execution, skill content lifecycle, invocation control, and the Agent Skills open standard specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills.

## Quick Reference

### Skill Directory Structure

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── references/        # Optional: detailed docs loaded on demand
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, resources
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Where Skills Live

| Location   | Path                                             | Applies to                     |
| :--------- | :----------------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                                 | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where plugin is enabled        |

Enterprise overrides personal; personal overrides project. Plugin skills use a `plugin-name:skill-name` namespace.

### Frontmatter Reference

| Field                      | Required    | Description                                                                                                                                                          |
| :------------------------- | :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Display name. Lowercase letters, numbers, hyphens only (max 64 chars). Defaults to directory name.                                                                   |
| `description`              | Recommended | When to use the skill. Claude uses this to auto-invoke. Combined with `when_to_use`, capped at 1,536 chars in listing.                                               |
| `when_to_use`              | No          | Additional trigger phrases; appended to `description` in skill listing.                                                                                              |
| `argument-hint`            | No          | Autocomplete hint, e.g. `[issue-number]`.                                                                                                                            |
| `arguments`                | No          | Named positional args for `$name` substitution. Space-separated string or YAML list.                                                                                 |
| `disable-model-invocation` | No          | `true` = only you can invoke (manual `/name` only). Hides from Claude's context. Default: `false`.                                                                   |
| `user-invocable`           | No          | `false` = hidden from `/` menu; Claude only. Default: `true`.                                                                                                        |
| `allowed-tools`            | No          | Tools Claude can use without approval while this skill is active. Space-separated or YAML list.                                                                      |
| `model`                    | No          | Model override for this skill's turn. Accepts same values as `/model`, or `inherit`.                                                                                 |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                                                                                     |
| `context`                  | No          | `fork` = run in isolated subagent context.                                                                                                                           |
| `agent`                    | No          | Subagent type when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, or custom agents.                                                                 |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle.                                                                                                                              |
| `paths`                    | No          | Glob patterns limiting when this skill auto-activates. Comma-separated or YAML list.                                                                                 |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                                                                        |

### Invocation Control Matrix

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                      |
| :------------------------------- | :------------- | :---------------- | :------------------------------------------------------------ |
| (default)                        | Yes            | Yes               | Description always in context; full skill loads when invoked  |
| `disable-model-invocation: true` | Yes            | No                | Description not in context; full skill loads when you invoke  |
| `user-invocable: false`          | No             | Yes               | Description always in context; full skill loads when invoked  |

### String Substitutions

| Variable               | Description                                                                                          |
| :--------------------- | :--------------------------------------------------------------------------------------------------- |
| `$ARGUMENTS`           | Full argument string. If absent from content, appended as `ARGUMENTS: <value>`.                      |
| `$ARGUMENTS[N]`        | Argument by 0-based index.                                                                           |
| `$N`                   | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`).                                                    |
| `$name`                | Named argument declared in `arguments` frontmatter list.                                             |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                                                  |
| `${CLAUDE_EFFORT}`     | Active effort level: `low`, `medium`, `high`, `xhigh`, or `max`.                                    |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. Use to reference bundled scripts at any install level. |

Multi-word argument values: wrap in quotes — `/my-skill "hello world" second` makes `$0` = `hello world`, `$1` = `second`.

### Dynamic Context Injection

Use `` !`<command>` `` to run shell commands before Claude sees the skill content. Output replaces the placeholder inline. This is preprocessing — Claude only sees the final rendered result.

Multi-line form uses a fenced block opened with ` ```! `.

Disable for untrusted sources: set `"disableSkillShellExecution": true` in settings.

### Skill Content Lifecycle

- Rendered `SKILL.md` enters the conversation as a single message on invocation and stays for the rest of the session.
- Claude Code does not re-read the file on later turns.
- Auto-compaction carries skills forward, keeping the first 5,000 tokens of each, up to a combined budget of 25,000 tokens across all invoked skills. Oldest skills may be dropped.

### `skillOverrides` Setting

Controls visibility without editing the skill file. Set via `/skills` menu (highlight + `Space`) or directly in `.claude/settings.local.json`.

| Value                   | Listed to Claude     | In `/` menu |
| :---------------------- | :------------------- | :---------- |
| `"on"`                  | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

Plugin skills are not affected by `skillOverrides`.

### Restrict Claude's Skill Access

```text
# Deny all skills
Skill

# Allow specific skills only
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)
```

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with arguments.

### Agent Skills Open Standard (agentskills.io)

Claude Code skills follow the Agent Skills open standard. Standard frontmatter fields:

| Field           | Required (standard) | Notes                                                                         |
| :-------------- | :------------------ | :---------------------------------------------------------------------------- |
| `name`          | Yes                 | Lowercase, hyphens, max 64 chars. Must match directory name.                  |
| `description`   | Yes                 | Max 1,024 chars. Include what and when.                                       |
| `license`       | No                  | License name or bundled file reference.                                       |
| `compatibility` | No                  | Max 500 chars. Environment requirements (product, packages, network access).  |
| `metadata`      | No                  | Arbitrary key-value map for additional properties.                            |
| `allowed-tools` | No (experimental)   | Space-delimited pre-approved tools.                                           |

Progressive disclosure tiers: metadata (~100 tokens, loaded at startup) → full `SKILL.md` body (<5,000 tokens, loaded on activation) → supporting files (loaded on demand).

Validate with: `skills-ref validate ./my-skill`

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, frontmatter reference, string substitutions, dynamic context injection, supporting files, invocation control, subagent execution, skill content lifecycle, sharing, troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — open standard format spec, frontmatter fields and constraints, directory structure, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
