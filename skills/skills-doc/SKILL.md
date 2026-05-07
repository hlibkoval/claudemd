---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating and configuring SKILL.md files, frontmatter fields, invocation control, dynamic context injection, subagent execution, argument passing, supporting files, skill lifecycle, allowed-tools, skillOverrides, and the Agent Skills open standard specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills.

## Quick Reference

### Where Skills Live

| Location   | Path                                                | Applies to                     |
| :--------- | :-------------------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                                    | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`            | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`              | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`             | Where plugin is enabled        |

### SKILL.md Frontmatter Fields (Claude Code)

| Field                      | Required    | Description |
| :------------------------- | :---------- | :---------- |
| `name`                     | No          | Display name. Lowercase letters, numbers, hyphens only (max 64 chars). Defaults to directory name. |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this for auto-loading. Truncated at 1,536 chars in listing. |
| `when_to_use`              | No          | Additional trigger context. Appended to `description` in listing; counts toward 1,536-char cap. |
| `argument-hint`            | No          | Hint shown during autocomplete (e.g. `[issue-number]`). |
| `arguments`                | No          | Named positional arguments for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No          | `true` = only user can invoke; hides from Claude's context entirely. Default: `false`. |
| `user-invocable`           | No          | `false` = hide from `/` menu; Claude-only background knowledge. Default: `true`. |
| `allowed-tools`            | No          | Tools Claude may use without approval when skill is active. Space-separated or YAML list. |
| `model`                    | No          | Model override for this skill's turn. Accepts same values as `/model` or `inherit`. |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context`                  | No          | Set to `fork` to run in a forked subagent context. |
| `agent`                    | No          | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, `general-purpose`). |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle. |
| `paths`                    | No          | Glob patterns limiting when skill auto-activates (comma-separated or YAML list). |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`. |

### Invocation Control

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                          |
| :------------------------------- | :------------- | :---------------- | :---------------------------------------------------------------- |
| (default)                        | Yes            | Yes               | Description always in context; full skill loads when invoked      |
| `disable-model-invocation: true` | Yes            | No                | Description not in context; full skill loads when you invoke      |
| `user-invocable: false`          | No             | Yes               | Description always in context; full skill loads when invoked      |

### String Substitutions

| Variable               | Description |
| :--------------------- | :---------- |
| `$ARGUMENTS`           | All arguments passed when invoking. If absent, args appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index. |
| `$N`                   | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`). |
| `$name`                | Named argument declared in `arguments` frontmatter. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_EFFORT}`     | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`. |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. Resolves correctly for personal/project/plugin installs. |

### Dynamic Context Injection

Use `` !`<command>` `` inline or a fenced block opened with ` ```! ` for multi-line commands. The command runs before Claude sees the skill; output replaces the placeholder.

```
!`git diff HEAD`
```

To disable shell execution from user/project/plugin skills, set `"disableSkillShellExecution": true` in settings. Bundled and managed skills are unaffected.

### Skill Content Lifecycle

- Rendered `SKILL.md` enters the conversation as one message and stays for the session.
- Auto-compaction re-attaches the most recent invocation of each skill (up to 5,000 tokens each, 25,000 tokens combined budget).
- Skills are filled from most-recently-invoked first; older skills may be dropped after heavy compaction.

### skillOverrides Settings

| Value                   | Listed to Claude     | In `/` menu |
| :---------------------- | :------------------- | :---------- |
| `"on"`                  | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

Set via `/skills` menu (`Space` to cycle, `Enter` to save) or directly in `.claude/settings.local.json`. Plugin skills are not affected.

### Restrict Claude's Skill Access (Permission Rules)

```
# Allow only specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)

# Disable all skills
Skill
```

Use `disable-model-invocation: true` in frontmatter to hide a skill from Claude entirely.

### Skill Directory Structure

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── template.md        # Template for Claude to fill in
├── examples/
│   └── sample.md      # Example output showing expected format
└── scripts/
    └── validate.sh    # Script Claude can execute
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Agent Skills Open Standard Frontmatter (agentskills.io)

| Field           | Required | Constraints |
| :-------------- | :------- | :---------- |
| `name`          | Yes      | Max 64 chars. Lowercase letters, numbers, hyphens. No leading/trailing/consecutive hyphens. Must match directory name. |
| `description`   | Yes      | Max 1,024 chars. Describes what the skill does and when to use it. |
| `license`       | No       | License name or reference to bundled license file. |
| `compatibility` | No       | Max 500 chars. Environment requirements (product, packages, network). |
| `metadata`      | No       | Arbitrary key-value mapping for additional metadata. |
| `allowed-tools` | No       | Space-delimited pre-approved tools. (Experimental) |

### Progressive Disclosure (Agent Skills Spec)

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills.
2. **Instructions** (< 5,000 tokens recommended): Full `SKILL.md` body loaded on activation.
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded on demand.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, SKILL.md format, frontmatter reference, invocation control, dynamic context injection, subagent execution, argument passing, supporting files, skill lifecycle, skillOverrides, sharing, and troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — open standard directory structure, frontmatter schema, optional directories (scripts/, references/, assets/), progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
