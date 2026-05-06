---
name: skills-doc
description: Complete official documentation for Claude Code skills — creating SKILL.md files, frontmatter fields (name, description, disable-model-invocation, user-invocable, allowed-tools, context, agent, arguments, paths, model, effort, hooks, shell), skill locations (personal/project/plugin/enterprise), dynamic context injection, subagent execution with context:fork, passing arguments, string substitutions ($ARGUMENTS, $N, ${CLAUDE_SKILL_DIR}), supporting files, invocation control, skill content lifecycle, and the Agent Skills open standard specification.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard specification.

## Quick Reference

### Skill Directory Structure

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── references/       # Optional: detailed docs loaded on demand
├── scripts/          # Optional: executable code
└── assets/           # Optional: templates, resources
```

### Where Skills Live

| Location   | Path                                             | Applies to                     |
| :--------- | :----------------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                                 | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where plugin is enabled        |

Plugin skills use a `plugin-name:skill-name` namespace. Skills take precedence over same-named `.claude/commands/` files. Skill directories are watched for live changes within a session.

### Frontmatter Fields

| Field                      | Required    | Description                                                                                                                    |
| :------------------------- | :---------- | :----------------------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Display name. Lowercase letters, numbers, hyphens only. Max 64 chars. Defaults to directory name.                             |
| `description`              | Recommended | What the skill does and when to use it. Claude uses this to decide when to apply the skill. Truncated at 1,536 chars in listing. |
| `when_to_use`              | No          | Additional trigger context. Appended to `description`; counts toward the 1,536-char cap.                                      |
| `argument-hint`            | No          | Hint shown during autocomplete. E.g. `[issue-number]` or `[filename] [format]`.                                               |
| `arguments`                | No          | Named positional arguments for `$name` substitution. Space-separated or YAML list.                                            |
| `disable-model-invocation` | No          | `true` = only you can invoke (removed from Claude's context entirely). Use for side-effect workflows like `/deploy`.           |
| `user-invocable`           | No          | `false` = hidden from `/` menu; only Claude can invoke. Use for background knowledge. Default: `true`.                        |
| `allowed-tools`            | No          | Tools Claude can use without prompting when this skill is active. Space-separated or YAML list.                                |
| `model`                    | No          | Model override for this skill's turn; reverts after.                                                                           |
| `effort`                   | No          | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                                               |
| `context`                  | No          | Set to `fork` to run in an isolated subagent context.                                                                          |
| `agent`                    | No          | Subagent type when `context: fork` is set. Options: `Explore`, `Plan`, `general-purpose`, or any custom agent.                |
| `hooks`                    | No          | Lifecycle hooks scoped to this skill.                                                                                          |
| `paths`                    | No          | Glob patterns; skill auto-activates only when working with matching files. Comma-separated or YAML list.                       |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                                   |

### Invocation Control Matrix

| Frontmatter                      | You can invoke | Claude can invoke | Context loading                                          |
| :------------------------------- | :------------- | :---------------- | :------------------------------------------------------- |
| (default)                        | Yes            | Yes               | Description always in context; body loads when invoked   |
| `disable-model-invocation: true` | Yes            | No                | Description not in context; body loads when you invoke   |
| `user-invocable: false`          | No             | Yes               | Description always in context; body loads when invoked   |

### String Substitutions

| Variable               | Description                                                                               |
| :--------------------- | :---------------------------------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking. Appended as `ARGUMENTS: <value>` if not in content.  |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index.                                                       |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`: `$0` = first arg, `$1` = second.                          |
| `$name`                | Named argument declared in `arguments` frontmatter, mapped by position.                   |
| `${CLAUDE_SESSION_ID}` | Current session ID. Useful for logging or session-specific files.                         |
| `${CLAUDE_EFFORT}`     | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`.                        |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. Use to reference bundled scripts reliably.  |

Multi-word arguments require shell-style quoting: `/my-skill "hello world" second` → `$0` = `hello world`, `$1` = `second`.

### Dynamic Context Injection

The `` !`<command>` `` syntax runs shell commands before the skill content is sent to Claude. Output replaces the placeholder — Claude receives rendered data, not the command.

```yaml
## Current changes
!`git diff HEAD`
```

For multi-line commands use a fenced block opened with ` ```! `:

````
```!
node --version
git status --short
```
````

To disable for user/project/plugin skills, set `"disableSkillShellExecution": true` in settings. Bundled and managed skills are unaffected.

### Running a Skill in a Subagent

Add `context: fork` to run the skill in an isolated context. The skill content becomes the subagent's prompt — it won't have access to conversation history.

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly: find relevant files, read and analyze, summarize findings.
```

The `agent` field selects the execution environment (`Explore`, `Plan`, `general-purpose`, or any `.claude/agents/` custom agent). Omitting it defaults to `general-purpose`.

### Skill Content Lifecycle

- When invoked, rendered `SKILL.md` enters the conversation as a message and stays for the session.
- During auto-compaction, the most recent invocation of each skill is re-attached (first 5,000 tokens each, 25,000 token combined budget across all skills).
- Skills not re-attached after compaction can be re-invoked to restore full content.

### Controlling Claude's Access to Skills

```text
# Deny all skills
Skill

# Allow only specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)
```

Syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with any arguments.

### Pre-Approving Tools

`allowed-tools` grants permission for listed tools while the skill is active — other tools still require normal approval. For project skills, takes effect after workspace trust is accepted.

```yaml
---
name: commit
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)
---
```

### Agent Skills Open Standard — SKILL.md Frontmatter

The Agent Skills spec (agentskills.io) defines the portable subset of fields:

| Field           | Required | Constraints                                                                           |
| :-------------- | :------- | :------------------------------------------------------------------------------------ |
| `name`          | Yes      | 1–64 chars. Lowercase alphanumeric + hyphens. No leading/trailing/consecutive hyphens. Must match directory name. |
| `description`   | Yes      | 1–1024 chars. Describe what the skill does and when to use it.                       |
| `license`       | No       | License name or bundled license filename.                                             |
| `compatibility` | No       | 1–500 chars. Environment requirements (product, packages, network).                   |
| `metadata`      | No       | Arbitrary key-value map for additional properties.                                    |
| `allowed-tools` | No       | Space-delimited pre-approved tools. (Experimental)                                    |

Claude Code extends this standard with invocation control, subagent execution, dynamic context injection, string substitutions, and more.

### Progressive Disclosure

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills.
2. **Instructions** (under 5,000 tokens recommended): Full `SKILL.md` body loaded when skill activates.
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded only when required.

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files and reference them from the body.

### Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Skill not triggering | Check description includes natural keywords; verify with "What skills are available?"; try invoking directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` for manual-only invocation |
| Descriptions cut short | Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var; trim `description`/`when_to_use` — put key use case first |
| Skill stops influencing after first response | Content is still present; strengthen instructions or use hooks for deterministic enforcement; re-invoke after compaction |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — creating skills, skill locations, frontmatter reference, invocation control, dynamic context injection, subagent execution, arguments, tool pre-approval, sharing skills, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — portable open standard: SKILL.md format, frontmatter fields, optional directories (scripts/, references/, assets/), progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
