---
name: skills-doc
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills — how to create, configure, invoke, and distribute them — plus the Agent Skills open standard specification.

## Quick Reference

### Skill Directory Structure

```
skill-name/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Optional: detailed docs loaded on demand
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, resources
```

Skill locations and scope:

| Location   | Path                                             | Applies to                     |
|:-----------|:-------------------------------------------------|:-------------------------------|
| Enterprise | See managed settings                             | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`         | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`           | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`          | Where plugin is enabled        |

Command name comes from the skill's **directory name** (not the `name` frontmatter field, except for plugin-root `SKILL.md`). Plugin skills are namespaced: `/plugin-name:skill-name`.

### Frontmatter Reference

All fields are optional except `description` (recommended):

| Field                      | Description                                                                                                 |
|:---------------------------|:------------------------------------------------------------------------------------------------------------|
| `name`                     | Display label in skill listings. Does not change the invocation command (except for plugin-root SKILL.md).  |
| `description`              | What the skill does and when to use it. Used by Claude for auto-invocation matching. Max 1,536 chars combined with `when_to_use`. |
| `when_to_use`              | Additional trigger context appended to `description` in the skill listing.                                  |
| `argument-hint`            | Hint shown during autocomplete, e.g. `[issue-number]`.                                                      |
| `arguments`                | Space-separated or YAML list of named positional argument names for `$name` substitution.                  |
| `disable-model-invocation` | `true` = only user can invoke; description hidden from Claude's context.                                    |
| `user-invocable`           | `false` = hidden from `/` menu; Claude still auto-invokes. Default: `true`.                                |
| `allowed-tools`            | Tools pre-approved while this skill is active (space/comma-separated or YAML list).                        |
| `disallowed-tools`         | Tools removed from Claude's pool while skill is active. Clears on next user message.                       |
| `model`                    | Model override for this skill's turn. Reverts on next prompt.                                              |
| `effort`                   | Effort override: `low`, `medium`, `high`, `xhigh`, `max`.                                                  |
| `context`                  | Set to `fork` to run in an isolated subagent context.                                                       |
| `agent`                    | Which subagent type to use when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, custom.    |
| `hooks`                    | Hooks scoped to this skill's lifecycle.                                                                     |
| `paths`                    | Glob patterns: skill auto-activates only when working with matching files.                                  |
| `shell`                    | Shell for inline command execution: `bash` (default) or `powershell`.                                      |

### Invocation Control

| Frontmatter                      | User can invoke | Claude can invoke | Loaded into context                                          |
|:---------------------------------|:----------------|:------------------|:-------------------------------------------------------------|
| (default)                        | Yes             | Yes               | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes             | No                | Description not in context; full skill loads when you invoke |
| `user-invocable: false`          | No              | Yes               | Description always in context; full skill loads when invoked |

### String Substitutions

| Variable               | Description                                                                                     |
|:-----------------------|:------------------------------------------------------------------------------------------------|
| `$ARGUMENTS`           | Full argument string passed at invocation.                                                      |
| `$ARGUMENTS[N]`        | Argument by 0-based index.                                                                      |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`.                                                                  |
| `$name`                | Named argument from `arguments` frontmatter list (maps by position).                            |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                                             |
| `${CLAUDE_EFFORT}`     | Active effort level: `low`, `medium`, `high`, `xhigh`, `max`, `ultra`.                         |
| `${CLAUDE_SKILL_DIR}`  | Directory containing this skill's `SKILL.md`. Use to reference bundled scripts reliably.       |

### Dynamic Context Injection

Two forms of pre-processing inject live command output before Claude sees the skill content:

- **Inline form**: an exclamation mark immediately followed by a backtick-wrapped command on its own line or after whitespace. The command runs and its output replaces the placeholder.
- **Multi-line form**: a fenced code block whose opening fence is three backticks immediately followed by an exclamation mark. Each line in the block is a separate command; outputs are concatenated.

This is preprocessing — Claude only sees the rendered result, never the original token. Substitution runs once; injected output is not re-scanned. Disable for all user/project/plugin skills with `"disableSkillShellExecution": true` in settings.

### Skill Content Lifecycle

- Invoked skill content enters the conversation as a single message and **stays for the rest of the session**.
- Auto-compaction carries skills forward (up to 5,000 tokens each, 25,000 combined budget, most-recently-invoked first).
- Re-invoke a skill after compaction to restore it if it was dropped.

### Context Budget & Troubleshooting

- All skill names are always listed; descriptions may be truncated when the budget overflows.
- Budget defaults to 1% of the model's context window. Adjust with `skillListingBudgetFraction` or `SLASH_COMMAND_TOOL_CHAR_BUDGET`.
- Each entry's combined `description` + `when_to_use` text is capped at 1,536 characters (configurable via `maxSkillDescriptionChars`).
- Run `/doctor` to diagnose budget overflow and see which skills are affected.
- Use `skillOverrides` in settings to control visibility without editing SKILL.md:

| Value                   | Listed to Claude     | In `/` menu |
|:------------------------|:---------------------|:------------|
| `"on"`                  | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

### Bundled Skills (Selected)

| Skill                    | Purpose                                                          |
|:-------------------------|:-----------------------------------------------------------------|
| `/code-review`           | Review current diff for bugs and improvements                    |
| `/debug`                 | Debug issues systematically                                      |
| `/run`                   | Launch and drive the app to see a change working                 |
| `/verify`                | Confirm a code change does what it should against the running app |
| `/run-skill-generator`   | Record how to build and launch the project for `/run`/`/verify`  |
| `/loop`                  | Run a prompt or skill on a recurring interval                    |
| `/claude-api`            | Build/debug Claude API / Anthropic SDK apps                      |
| `/batch`                 | Run batch tasks                                                  |

### Agent Skills Open Standard (agentskills.io)

Claude Code skills follow the Agent Skills open standard. Key spec rules for the `name` field:

- 1–64 characters, lowercase alphanumeric and hyphens only
- Must not start or end with a hyphen; no consecutive hyphens (`--`)
- Must match the parent directory name

Validate a skill with the reference library:

```bash
skills-ref validate ./my-skill
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with Skills](references/claude-code-skills.md) — Creating skills, skill locations, frontmatter reference, dynamic context injection, subagent forking, bundled skills, sharing, and troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) — Open standard format: SKILL.md schema, frontmatter fields, optional directories (`scripts/`, `references/`, `assets/`), progressive disclosure, file references, and validation

## Sources

- Extend Claude with Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
