---
name: skills-doc
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills — how to create, configure, invoke, and distribute them — plus the Agent Skills open standard specification that Claude Code implements.

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

| Scope      | Path                                              | Applies to                      |
| :--------- | :------------------------------------------------ | :------------------------------ |
| Enterprise | Managed settings path                             | All users in organization       |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`          | All your projects               |
| Project    | `.claude/skills/<skill-name>/SKILL.md`            | This project only               |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`           | Where plugin is enabled         |

When names conflict: enterprise overrides personal overrides project. Plugin skills are namespaced as `plugin-name:skill-name` and never conflict.

### Frontmatter Reference

All fields are optional except `description` (recommended).

| Field                      | Description                                                                                                                                 |
| :------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                     | Display label in skill listings. Does NOT change the `/command` name (which comes from the directory name), except for plugin-root SKILL.md |
| `description`              | What the skill does and when to use it. Claude uses this to decide when to auto-load. Truncated at 1,536 chars in the listing.             |
| `when_to_use`              | Additional trigger context appended to `description` in the skill listing; counts toward the 1,536-char cap.                               |
| `argument-hint`            | Autocomplete hint for expected arguments, e.g. `[issue-number]`                                                                            |
| `arguments`                | Named positional arguments for `$name` substitution. Space-separated string or YAML list.                                                  |
| `disable-model-invocation` | `true` → only you can invoke; hidden from Claude's context entirely. Use for side-effecting workflows like `/deploy`.                       |
| `user-invocable`           | `false` → hidden from the `/` menu; Claude can still auto-load it. Use for background reference skills.                                    |
| `allowed-tools`            | Tools Claude may use without per-use approval while the skill is active.                                                                    |
| `disallowed-tools`         | Tools removed from Claude's pool while skill is active. Clears on your next message.                                                        |
| `model`                    | Model override for this skill's turn. Resets on your next prompt.                                                                           |
| `effort`                   | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`.                                                                            |
| `context`                  | Set to `fork` to run in an isolated subagent context.                                                                                       |
| `agent`                    | Which subagent type to use when `context: fork` is set.                                                                                     |
| `hooks`                    | Hooks scoped to this skill's lifecycle.                                                                                                     |
| `paths`                    | Glob patterns limiting when Claude auto-activates the skill.                                                                                |
| `shell`                    | Shell for dynamic context injection commands: `bash` (default) or `powershell`.                                                             |

### Invocation Control Matrix

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                      |
| :------------------------------- | :------------- | :---------------- | :------------------------------------------------------------ |
| (default)                        | Yes            | Yes               | Description always in context; full skill loads when invoked  |
| `disable-model-invocation: true` | Yes            | No                | Description NOT in context; full skill loads when you invoke  |
| `user-invocable: false`          | No             | Yes               | Description always in context; full skill loads when invoked  |

### String Substitutions

| Variable               | Description                                                                                      |
| :--------------------- | :----------------------------------------------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed on invocation. Appended as `ARGUMENTS: <value>` if not present in content. |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index.                                                              |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`.                                                                   |
| `$name`                | Named argument declared in `arguments` frontmatter; maps to positional order.                    |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                                              |
| `${CLAUDE_EFFORT}`     | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`.                               |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md. Use for scripts bundled with the skill.               |

Escape a literal `$` before a substitution token with a backslash: `\$1.00`.

### Dynamic Context Injection

Two forms are available — the preprocessor runs them before Claude sees the skill content:

- **Inline form**: an exclamation mark immediately followed by a backtick-wrapped shell command at the start of a line or after whitespace. The command output replaces the line.
- **Block form**: a fenced code block whose opening fence is immediately followed by an exclamation mark. All lines inside the block are run as a multi-line shell script; the block is replaced with combined output.

Substitution runs once. Command output is not re-scanned for further injection tokens. If `!` follows a non-whitespace character (e.g. `KEY=!`cmd``), the token is left as literal text.

Disable for user/project/plugin skills with `"disableSkillShellExecution": true` in settings. Bundled and managed skills are unaffected.

### Skill Content Lifecycle

- Rendered SKILL.md content enters the conversation as a single message when invoked and stays in context for the rest of the session.
- Auto-compaction carries invoked skills forward (first 5,000 tokens per skill, 25,000 token combined budget; filled from most-recently-invoked first).
- Claude Code does not re-read the skill file on later turns — write guidance as standing instructions.

### Subagent Execution (`context: fork`)

Add `context: fork` to run the skill in an isolated subagent. The skill body becomes the subagent's task prompt; it has no access to conversation history.

| Approach                   | System prompt       | Task               | Also loads                                            |
| :------------------------- | :------------------ | :----------------- | :---------------------------------------------------- |
| Skill with `context: fork` | From agent type     | SKILL.md content   | CLAUDE.md, except when agent is Explore or Plan       |
| Subagent with `skills`     | Subagent's body     | Claude's message   | Preloaded skills + CLAUDE.md                          |

`agent` field accepts built-in types (`Explore`, `Plan`, `general-purpose`) or any custom subagent from `.claude/agents/`. Defaults to `general-purpose` if omitted.

### skillOverrides Setting

Override visibility from settings without editing SKILL.md:

| Value                   | Listed to Claude     | In `/` menu |
| :---------------------- | :------------------- | :---------- |
| `"on"`                  | Name and description | Yes         |
| `"name-only"`           | Name only            | Yes         |
| `"user-invocable-only"` | Hidden               | Yes         |
| `"off"`                 | Hidden               | Hidden      |

Edit via `/skills` menu (highlight + `Space` to cycle, `Enter` to save) or manually in `.claude/settings.local.json` under `"skillOverrides"`. Does not apply to plugin skills.

### Bundled Skills

Available in every session unless disabled with `disableBundledSkills` setting:

| Skill                  | Purpose                                                              |
| :--------------------- | :------------------------------------------------------------------- |
| `/code-review`         | Review code for correctness and quality                              |
| `/batch`               | Run multiple tasks in parallel                                       |
| `/debug`               | Debug an issue                                                       |
| `/loop`                | Run a prompt on a recurring interval                                 |
| `/claude-api`          | Reference for the Claude API / Anthropic SDK                        |
| `/run`                 | Launch and drive your app to see a change working                    |
| `/verify`              | Confirm a code change does what it should (requires v2.1.145+)       |
| `/run-skill-generator` | Record how to build and launch your project for `/run` and `/verify` |

### Agent Skills Specification (agentskills.io)

Claude Code implements the open Agent Skills standard. Key spec fields:

| Field           | Required | Constraints                                                           |
| :-------------- | :------- | :-------------------------------------------------------------------- |
| `name`          | Yes      | 1–64 chars; lowercase letters, numbers, hyphens; no leading/trailing/consecutive hyphens; must match directory name |
| `description`   | Yes      | 1–1024 chars; describe what the skill does and when to use it         |
| `license`       | No       | License name or bundled file reference                                |
| `compatibility` | No       | 1–500 chars; environment requirements                                 |
| `metadata`      | No       | Arbitrary string key-value map                                        |
| `allowed-tools` | No       | Space-delimited pre-approved tools (experimental)                     |

Progressive disclosure tiers: metadata (~100 tokens, always loaded) → SKILL.md body (<5,000 tokens recommended, loaded on activation) → supporting files (loaded on demand). Keep SKILL.md under 500 lines.

### Troubleshooting

| Symptom                        | Fix                                                                                                       |
| :----------------------------- | :-------------------------------------------------------------------------------------------------------- |
| Skill not triggering           | Verify description has matching keywords; check `What skills are available?`; try invoking directly with `/skill-name` |
| Skill triggers too often       | Tighten description; add `disable-model-invocation: true` for manual-only invocation                      |
| Descriptions cut short         | Run `/doctor`; set `skillListingBudgetFraction` or trim descriptions; set low-priority skills to `"name-only"` in `skillOverrides` |
| Skill stops influencing output | Content is still in context — strengthen description and instructions; re-invoke after compaction          |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with skills](references/claude-code-skills.md) — Creating skills, frontmatter reference, invocation control, dynamic context injection, subagent execution, skill lifecycle, evals, sharing, troubleshooting
- [Agent Skills specification](references/agent-skills-specification.md) — Open standard: SKILL.md format, directory structure, frontmatter fields, progressive disclosure, file references, validation

## Sources

- Extend Claude with skills: https://code.claude.com/docs/en/skills.md
- Agent Skills specification: https://agentskills.io/specification.md
