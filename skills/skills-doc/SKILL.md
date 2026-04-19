---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

Skills extend what Claude can do. A skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions. Claude loads skills automatically when relevant, or users invoke them directly with `/skill-name`.

Create a skill when you keep pasting the same playbook, checklist, or multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather than a fact. Unlike CLAUDE.md content, a skill's body loads only when invoked.

### Skill directory structure

```
skill-name/
  SKILL.md           # Required: metadata + instructions
  scripts/           # Optional: executable code
  references/        # Optional: documentation
  assets/            # Optional: templates, resources
```

### Where skills live

| Scope      | Path                                       | Applies to                     |
| :--------- | :----------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                           | All users in your organization |
| Personal   | `~/.claude/skills/<name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`          | Where plugin is enabled        |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills from `--add-dir` directories are also loaded automatically.

### Frontmatter fields (Agent Skills standard)

| Field           | Required | Description                                                                  |
| :-------------- | :------- | :--------------------------------------------------------------------------- |
| `name`          | Yes      | 1-64 chars. Lowercase `a-z`, digits, hyphens. Must match directory name.     |
| `description`   | Yes      | 1-1024 chars. What the skill does and when to use it.                        |
| `license`       | No       | License name or reference to a bundled license file.                         |
| `compatibility` | No       | Max 500 chars. Environment requirements (product, packages, network, etc.).  |
| `metadata`      | No       | Arbitrary key-value map for additional properties.                           |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools. (Experimental)                   |

Name rules: no uppercase, no leading/trailing hyphens, no consecutive hyphens (`--`).

### Frontmatter fields (Claude Code extensions)

| Field                      | Default     | Description                                                                                |
| :------------------------- | :---------- | :----------------------------------------------------------------------------------------- |
| `name`                     | dir name    | Display name. Lowercase letters, numbers, hyphens (max 64 chars).                          |
| `description`              | 1st para    | What the skill does. Truncated at 1,536 chars in skill listing.                            |
| `when_to_use`              | -           | Additional trigger phrases. Appended to description, shares 1,536-char cap.                |
| `argument-hint`            | -           | Shown during autocomplete, e.g. `[issue-number]`.                                          |
| `disable-model-invocation` | `false`     | `true` = only the user can invoke (prevents Claude auto-loading).                          |
| `user-invocable`           | `true`      | `false` = hidden from `/` menu; only Claude can invoke.                                    |
| `allowed-tools`            | -           | Tools Claude can use without permission prompts while skill is active.                     |
| `model`                    | -           | Model to use when this skill is active.                                                    |
| `effort`                   | session     | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                           |
| `context`                  | -           | Set to `fork` to run in a forked subagent context.                                         |
| `agent`                    | general     | Subagent type when `context: fork` (e.g. `Explore`, `Plan`, or custom).                   |
| `hooks`                    | -           | Hooks scoped to this skill's lifecycle.                                                    |
| `paths`                    | -           | Glob patterns limiting auto-activation to matching files.                                  |
| `shell`                    | `bash`      | Shell for inline commands. `bash` or `powershell`.                                         |

### Invocation control matrix

| Frontmatter                      | User can invoke | Claude can invoke | Context behavior                                             |
| :------------------------------- | :-------------- | :---------------- | :----------------------------------------------------------- |
| (default)                        | Yes             | Yes               | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes             | No                | Description not in context; loads only when user invokes     |
| `user-invocable: false`          | No              | Yes               | Description always in context; full skill loads when invoked |

### String substitutions

| Variable               | Description                                                    |
| :--------------------- | :------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking the skill.                  |
| `$ARGUMENTS[N]` / `$N` | Access a specific argument by 0-based index.                  |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                            |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md file.               |

Indexed arguments use shell-style quoting; multi-word values must be quoted.

### Dynamic context injection

The `` !`<command>` `` syntax runs a shell command before the skill content is sent to Claude. The output replaces the placeholder. For multi-line commands, use a fenced code block opened with ` ```! `:

````
```!
node --version
npm --version
git status --short
```
````

Disable with `"disableSkillShellExecution": true` in settings (most useful in managed settings).

### Progressive disclosure (context efficiency)

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): full SKILL.md loads when the skill is activated
3. **Resources** (as needed): files in `scripts/`, `references/`, `assets/` loaded only when required

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Skill content lifecycle

- Rendered SKILL.md enters the conversation as a single message and stays for the session.
- Auto-compaction re-attaches the most recent invocation of each skill (first 5,000 tokens each, 25,000 tokens combined budget, ordered by most recently invoked).
- Re-invoke a skill after compaction to restore full content if needed.

### Running skills in a subagent

Add `context: fork` to run in isolation. The skill content becomes the subagent prompt (no conversation history access).

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---
```

| Approach                     | System prompt                             | Task                        |
| :--------------------------- | :---------------------------------------- | :-------------------------- |
| Skill with `context: fork`   | From agent type (`Explore`, `Plan`, etc.) | SKILL.md content            |
| Subagent with `skills` field | Subagent's markdown body                  | Claude's delegation message |

### Restricting skill access

- **Disable all skills**: deny the `Skill` tool in permissions
- **Allow/deny specific skills**: `Skill(commit)`, `Skill(deploy *)`
- **Hide individual skills**: `disable-model-invocation: true` in frontmatter

### Sharing skills

| Distribution | Method                                                      |
| :----------- | :---------------------------------------------------------- |
| Project      | Commit `.claude/skills/` to version control                 |
| Plugin       | Create a `skills/` directory in your plugin                 |
| Managed      | Deploy organization-wide through managed settings           |

### Skill description budget

Descriptions are loaded into context so Claude knows what's available. Budget scales at 1% of context window (fallback: 8,000 chars). Each entry's combined `description` + `when_to_use` text is capped at 1,536 chars. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

### Validation (Agent Skills standard)

```bash
skills-ref validate ./my-skill
```

Uses the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library.

### Troubleshooting

| Problem                    | Fix                                                                                    |
| :------------------------- | :------------------------------------------------------------------------------------- |
| Skill not triggering       | Check description keywords; verify with "What skills are available?"; try `/skill-name` |
| Skill triggers too often   | Make description more specific; add `disable-model-invocation: true`                   |
| Descriptions cut short     | Front-load key use case; raise `SLASH_COMMAND_TOOL_CHAR_BUDGET`; trim text             |

### Live change detection

Adding, editing, or removing a skill takes effect within the current session without restarting. Creating a top-level skills directory that did not exist when the session started requires restarting Claude Code.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — full Claude Code skills guide covering creation, directory layout, frontmatter reference, invocation control, arguments, supporting files, dynamic context injection, subagent execution, sharing, visual output generation, and troubleshooting.
- [Agent Skills Specification](references/agent-skills-specification.md) — the complete Agent Skills open standard format specification covering directory structure, SKILL.md format, frontmatter fields (name, description, license, compatibility, metadata, allowed-tools), body content, optional directories (scripts, references, assets), progressive disclosure, file references, and validation.

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
