---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend Claude with reusable instructions. Each skill is a directory with a `SKILL.md` file (plus optional supporting files). Claude loads skills automatically when relevant, or you invoke them directly with `/skill-name`.

### Directory layout

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── references/       # Optional: detailed docs loaded on demand
├── scripts/          # Optional: executable code
└── assets/           # Optional: templates, data files
```

### Where skills live

| Scope      | Path                                             | Available to                  |
| :--------- | :----------------------------------------------- | :---------------------------- |
| Enterprise | Managed settings                                 | All users in org              |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All your projects             |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only             |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where plugin is enabled       |

Priority when names collide: enterprise > personal > project. Plugin skills use a `plugin-name:skill-name` namespace and never conflict.

### Frontmatter fields

| Field                      | Required    | Description                                                                                                        |
| :------------------------- | :---------- | :----------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Skill name / slash command (directory name used if omitted). Lowercase letters, numbers, hyphens; max 64 chars.   |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this for auto-activation. Max effective ~1,536 chars.         |
| `when_to_use`              | No          | Extra trigger context appended to `description` in the skill listing; counts toward the 1,536-char cap.           |
| `argument-hint`            | No          | Autocomplete hint for expected arguments, e.g. `[issue-number]`.                                                  |
| `arguments`                | No          | Named positional args for `$name` substitution. Space-separated string or YAML list.                              |
| `disable-model-invocation` | No          | `true` — only user can invoke; removes skill from Claude's context entirely. Default: `false`.                    |
| `user-invocable`           | No          | `false` — hide from `/` menu; Claude can still auto-load. Default: `true`.                                        |
| `allowed-tools`            | No          | Tools pre-approved while skill is active. Space-separated string or YAML list.                                    |
| `model`                    | No          | Model override for this skill's turn. Reverts after the turn ends.                                                |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                                  |
| `context`                  | No          | `fork` — run skill in an isolated subagent context.                                                               |
| `agent`                    | No          | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or a custom agent name).        |
| `hooks`                    | No          | Lifecycle hooks scoped to this skill.                                                                              |
| `paths`                    | No          | Glob patterns; skill only auto-activates when working with matching files.                                         |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                      |
| `license`                  | No          | (Agent Skills spec) License name or path to bundled license file.                                                 |
| `compatibility`            | No          | (Agent Skills spec) Environment requirements; max 500 chars.                                                      |
| `metadata`                 | No          | (Agent Skills spec) Arbitrary key-value map for additional properties.                                            |

### Invocation control matrix

| Frontmatter                      | User can invoke | Claude can invoke | Description in context               |
| :------------------------------- | :-------------- | :---------------- | :----------------------------------- |
| (default)                        | Yes             | Yes               | Always present                       |
| `disable-model-invocation: true` | Yes             | No                | Not in context                       |
| `user-invocable: false`          | No              | Yes               | Always present                       |

### String substitutions

| Placeholder            | Expands to                                                               |
| :--------------------- | :----------------------------------------------------------------------- |
| `$ARGUMENTS`           | Full argument string as typed                                            |
| `$ARGUMENTS[N]`        | Argument at 0-based index N                                              |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`                                            |
| `$name`                | Named argument declared in `arguments` frontmatter (maps by position)   |
| `${CLAUDE_SESSION_ID}` | Current session ID                                                       |
| `${CLAUDE_SKILL_DIR}`  | Absolute path to the skill's directory                                   |

### Dynamic context injection

Use `` !`<command>` `` in skill content to run shell commands before Claude sees the skill. Output replaces the placeholder:

```markdown
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
```

Multi-line variant uses a fenced block opened with ` ```! `.

Disable shell execution in settings: `"disableSkillShellExecution": true`.

### Running skills in a subagent

Add `context: fork` to run the skill in an isolated context. The skill content becomes the subagent's prompt — it won't have your conversation history. Use `agent` to pick the execution environment.

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---
Research $ARGUMENTS thoroughly...
```

### Progressive disclosure (Agent Skills spec)

| Layer        | Token budget      | When loaded                              |
| :----------- | :---------------- | :--------------------------------------- |
| Metadata     | ~100 tokens       | Always — name + description at startup  |
| SKILL.md body | <5,000 recommended | When skill is activated                |
| Supporting files | As needed     | On demand when referenced               |

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Compaction behavior

After auto-compaction, Claude Code re-attaches the most recent invocation of each skill (first 5,000 tokens each), within a shared 25,000-token budget. Skills are filled from most-recently-invoked; older ones may be dropped entirely.

### Troubleshooting activation

| Problem                   | Fix                                                                           |
| :------------------------ | :---------------------------------------------------------------------------- |
| Skill not triggering      | Add keywords users would say to `description`; try `/skill-name` directly     |
| Triggers too often        | Make description more specific; add `disable-model-invocation: true`          |
| Descriptions cut short    | Trim `description`; front-load the key use case; set `SLASH_COMMAND_TOOL_CHAR_BUDGET` |
| Stops influencing behavior | Re-invoke after compaction; use hooks to enforce behavior deterministically   |

### Permission control for skills

```text
# Deny all skill invocations by Claude
Skill

# Allow only specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)
```

Syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix with any arguments.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — full guide covering creating skills, directory layout, frontmatter, invocation control, dynamic context injection, subagent execution, sharing skills, troubleshooting, and advanced patterns
- [Agent Skills Specification](references/agent-skills-specification.md) — open standard format for SKILL.md files, frontmatter schema, optional directories, progressive disclosure, file references, and validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
