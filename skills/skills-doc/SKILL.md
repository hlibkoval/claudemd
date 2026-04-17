---
name: skills-doc
description: Complete official documentation for Claude Code skills and the Agent Skills open standard — authoring SKILL.md files, frontmatter fields, directory layout, progressive disclosure, invocation control, dynamic context injection, running skills in subagents, sharing skills, and troubleshooting activation.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills and the Agent Skills open standard.

## Quick Reference

### What skills are

A skill is a directory containing a `SKILL.md` file (required) plus optional supporting files. Skills extend what Claude can do by injecting instructions into context when relevant. Claude loads them automatically or users invoke them with `/skill-name`.

Create a skill when you keep pasting the same playbook, checklist, or multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather than a fact. Unlike CLAUDE.md content, a skill's body loads only when activated, so long reference material costs almost nothing until needed.

Custom commands (`.claude/commands/*.md`) still work and support the same frontmatter, but skills are preferred for new workflows since they support supporting files and additional features.

### Where skills live

| Scope      | Path                                       | Applies to                     |
| :--------- | :----------------------------------------- | :----------------------------- |
| Enterprise | Managed settings                           | All users in your organization |
| Personal   | `~/.claude/skills/<name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`          | Where plugin is enabled        |

Priority: enterprise > personal > project. Plugin skills use a `plugin-name:skill-name` namespace (no conflicts with other levels). Skills from `--add-dir` directories are loaded automatically. Live change detection picks up edits within a session (no restart needed unless a new top-level skills directory was created).

### SKILL.md format

YAML frontmatter (between `---` markers) followed by Markdown body content.

### Frontmatter fields (Claude Code)

| Field                      | Required    | Description                                                                                                                              |
| :------------------------- | :---------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                     | No          | Lowercase letters, numbers, hyphens only (max 64 chars). Must not start/end with hyphen or contain `--`. Defaults to directory name.     |
| `description`              | Recommended | What the skill does and when to use it. Truncated at 1,536 chars in the skill listing. If omitted, uses first paragraph of body.         |
| `when_to_use`              | No          | Extra trigger phrases/examples; appended to `description` and counts toward 1,536-char cap.                                              |
| `argument-hint`            | No          | Hint shown during autocomplete (e.g., `[issue-number]`).                                                                                |
| `disable-model-invocation` | No          | `true` = only the user can invoke via `/name`. Default: `false`.                                                                         |
| `user-invocable`           | No          | `false` = hidden from `/` menu; only Claude can invoke. Default: `true`.                                                                 |
| `allowed-tools`            | No          | Pre-approved tools while skill is active. Space-separated string or YAML list. Does not restrict other tools.                            |
| `model`                    | No          | Model to use when this skill is active.                                                                                                  |
| `effort`                   | No          | Effort level override. Options: `low`, `medium`, `high`, `xhigh`, `max`.                                                                |
| `context`                  | No          | `fork` = run in an isolated subagent context.                                                                                            |
| `agent`                    | No          | Subagent type when `context: fork` (`Explore`, `Plan`, `general-purpose`, or custom `.claude/agents/` name).                             |
| `hooks`                    | No          | Hooks scoped to this skill's lifecycle.                                                                                                  |
| `paths`                    | No          | Glob patterns limiting automatic activation to matching files. Comma-separated string or YAML list.                                      |
| `shell`                    | No          | Shell for inline commands: `bash` (default) or `powershell`.                                                                             |

### Frontmatter fields (Agent Skills open standard)

| Field           | Required | Description                                                                    |
| :-------------- | :------- | :----------------------------------------------------------------------------- |
| `name`          | Yes      | 1-64 chars, lowercase alphanumeric + hyphens. Must match parent directory.     |
| `description`   | Yes      | 1-1024 chars. What the skill does and when to use it.                          |
| `license`       | No       | License name or reference to a bundled license file.                           |
| `compatibility` | No       | Max 500 chars. Environment requirements.                                       |
| `metadata`      | No       | Arbitrary key-value mapping (string keys to string values).                    |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools. Experimental.                      |

### Invocation control

| Frontmatter                      | User can invoke | Claude can invoke | Context behavior                                             |
| :------------------------------- | :-------------- | :---------------- | :----------------------------------------------------------- |
| (default)                        | Yes             | Yes               | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes             | No                | Description not in context; loads when user invokes          |
| `user-invocable: false`          | No              | Yes               | Description always in context; loads when Claude invokes     |

### String substitutions

| Variable               | Description                                                       |
| :--------------------- | :---------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking the skill                      |
| `$ARGUMENTS[N]` / `$N` | Access a specific argument by 0-based index                       |
| `${CLAUDE_SESSION_ID}` | Current session ID                                                |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md                         |

Arguments use shell-style quoting: `"hello world"` counts as one argument.

### Dynamic context injection

The `` !`<command>` `` inline syntax and ` ```! ` fenced blocks run shell commands before the skill content is sent to Claude. Output replaces the placeholder. This is preprocessing, not something Claude executes.

Disable with `"disableSkillShellExecution": true` in settings (bundled and managed skills unaffected).

### Skill content lifecycle

Rendered SKILL.md enters the conversation as a single message and stays for the session. Auto-compaction re-attaches the most recent invocation of each skill (first 5,000 tokens each, combined budget of 25,000 tokens across all skills, most recently invoked first).

### Directory structure (Agent Skills standard)

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files
```

### Progressive disclosure

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (< 5,000 tokens recommended): full SKILL.md body loaded when activated
3. **Resources** (as needed): supporting files loaded only when required

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

### Running skills in a subagent

Add `context: fork` to run in isolation. The skill content becomes the subagent's task prompt (no conversation history). The `agent` field picks the execution environment.

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

### Sharing skills

- **Project**: commit `.claude/skills/` to version control
- **Plugins**: create a `skills/` directory in your plugin
- **Managed**: deploy org-wide through managed settings

### Restricting Claude's skill access

- Deny all skills: add `Skill` to deny rules in `/permissions`
- Allow/deny specific: `Skill(commit)`, `Skill(review-pr *)`, `Skill(deploy *)`
- Hide individual: set `disable-model-invocation: true` in frontmatter

### Troubleshooting

| Problem                   | Fix                                                                                           |
| :------------------------ | :-------------------------------------------------------------------------------------------- |
| Skill not triggering      | Check description keywords; verify with "What skills are available?"; invoke directly with `/` |
| Skill triggers too often  | Make description more specific; add `disable-model-invocation: true`                          |
| Descriptions cut short    | Budget is 1% of context window (fallback 8K chars); set `SLASH_COMMAND_TOOL_CHAR_BUDGET`; front-load key use case in description |

### Validation (Agent Skills standard)

```bash
skills-ref validate ./my-skill
```

Uses the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) library to check frontmatter and naming conventions.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — Full Claude Code skills guide: creating skills, where they live, frontmatter reference, supporting files, invocation control, skill content lifecycle, pre-approving tools, passing arguments, dynamic context injection, running skills in subagents, restricting skill access, sharing skills, generating visual output, and troubleshooting.
- [Agent Skills specification](references/agent-skills-specification.md) — The Agent Skills open standard: directory structure, SKILL.md format, frontmatter fields (name, description, license, compatibility, metadata, allowed-tools), body content, optional directories (scripts, references, assets), progressive disclosure, file references, and validation.

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
