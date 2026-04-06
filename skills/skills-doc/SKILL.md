---
name: skills-doc
description: Complete documentation for Claude Code skills (Agent Skills) -- creating, configuring, sharing, and troubleshooting skills. Covers the Agent Skills open standard (SKILL.md format, frontmatter fields, directory structure, progressive disclosure, file references, validation), Claude Code skill features (bundled skills, skill locations, frontmatter reference with all fields, invocation control, disable-model-invocation, user-invocable, allowed-tools, context fork, subagent execution, argument passing with $ARGUMENTS/$N, string substitutions, dynamic context injection with shell commands, path-based activation, skill hooks, shell selection, supporting files), bundled skills (/batch, /claude-api, /debug, /loop, /simplify), sharing and distribution (project skills, plugins, managed settings), visual output generation, and troubleshooting (skill not triggering, triggers too often, descriptions cut short, SLASH_COMMAND_TOOL_CHAR_BUDGET). Load when discussing skills, SKILL.md, Agent Skills, skill creation, skill frontmatter, skill configuration, bundled skills, /batch, /simplify, /loop, /debug, /claude-api, disable-model-invocation, user-invocable, allowed-tools, context fork, $ARGUMENTS, skill arguments, dynamic context injection, skill shell commands, skill paths, skill hooks, skill sharing, skill troubleshooting, skill description budget, SLASH_COMMAND_TOOL_CHAR_BUDGET, agentskills.io, or any skills-related topic for Claude Code.
user-invocable: false
---

# Skills Documentation

This skill provides the complete official documentation for Claude Code skills (Agent Skills) -- extending Claude's capabilities with custom instructions, reference material, and task workflows.

## Quick Reference

### Agent Skills Specification (agentskills.io)

#### SKILL.md Frontmatter (Open Standard)

| Field | Required | Constraints |
|:------|:---------|:-----------|
| `name` | Yes | 1-64 chars, lowercase `a-z`, digits, hyphens; no leading/trailing/consecutive hyphens; must match directory name |
| `description` | Yes | 1-1024 chars; describe what skill does and when to use it |
| `license` | No | License name or reference to bundled license file |
| `compatibility` | No | 1-500 chars; environment requirements (product, packages, network) |
| `metadata` | No | Arbitrary string key-value map for additional properties |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

#### Skill Directory Structure (Open Standard)

```
skill-name/
  SKILL.md          # Required: metadata + instructions
  scripts/          # Optional: executable code
  references/       # Optional: documentation
  assets/           # Optional: templates, resources
```

#### Progressive Disclosure

| Layer | Token Budget | When Loaded |
|:------|:-------------|:-----------|
| Metadata (`name`, `description`) | ~100 tokens | Startup, all skills |
| Instructions (SKILL.md body) | < 5000 recommended | When skill is activated |
| Resources (scripts/, references/, assets/) | As needed | Only when required |

Keep SKILL.md under 500 lines. Move detailed reference material to separate files.

#### Validation

```bash
skills-ref validate ./my-skill
```

### Claude Code Skill Features

#### Where Skills Live

| Location | Path | Applies to |
|:---------|:-----|:-----------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills in `.claude/commands/` still work; if both exist with same name, skill wins.

Nested `.claude/skills/` directories are auto-discovered (supports monorepos). Skills from `--add-dir` directories are also loaded and support live change detection.

#### Frontmatter Reference (Claude Code Extensions)

| Field | Required | Description |
|:------|:---------|:-----------|
| `name` | No | Display name; defaults to directory name. Lowercase, numbers, hyphens (max 64 chars) |
| `description` | Recommended | What skill does and when to use it. Front-load key use case; truncated at 250 chars in listings |
| `argument-hint` | No | Autocomplete hint for expected arguments, e.g. `[issue-number]` |
| `disable-model-invocation` | No | `true` prevents Claude auto-loading. For manual `/name` only. Default: `false` |
| `user-invocable` | No | `false` hides from `/` menu. For background knowledge. Default: `true` |
| `allowed-tools` | No | Tools Claude can use without permission when skill is active. Space-separated or YAML list |
| `model` | No | Model to use when skill is active |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `context` | No | `fork` to run in a forked subagent context |
| `agent` | No | Subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom) |
| `hooks` | No | Hooks scoped to skill lifecycle |
| `paths` | No | Glob patterns limiting when skill auto-activates. Comma-separated or YAML list |
| `shell` | No | `bash` (default) or `powershell` for inline shell commands |

#### Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Context behavior |
|:------------|:---------------|:-----------------|:----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context; full skill loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context; full skill loads when invoked |

#### String Substitutions

| Variable | Description |
|:---------|:-----------|
| `$ARGUMENTS` | All arguments passed when invoking. Appended as `ARGUMENTS: <value>` if not in content |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

#### Dynamic Context Injection

Inline: `` !`command` `` runs shell command before skill content is sent; output replaces placeholder.

Multi-line: open fenced block with `` ```! `` for multi-line commands.

Disable with `"disableSkillShellExecution": true` in settings.

#### Subagent Execution (context: fork)

| Approach | System prompt | Task | Also loads |
|:---------|:-------------|:-----|:-----------|
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Delegation message | Preloaded skills + CLAUDE.md |

#### Restricting Skill Access

- **Deny all:** add `Skill` to deny rules in `/permissions`
- **Allow/deny specific:** `Skill(commit)` for exact match, `Skill(deploy *)` for prefix match
- **Hide individual:** `disable-model-invocation: true` removes from Claude's context entirely

### Bundled Skills

| Skill | Purpose |
|:------|:--------|
| `/batch <instruction>` | Large-scale parallel changes across codebase using git worktrees; spawns one agent per unit |
| `/claude-api` | Claude API/SDK reference (Python, TS, Java, Go, Ruby, C#, PHP, cURL); auto-activates on SDK imports |
| `/debug [description]` | Enable debug logging and troubleshoot by reading session debug log |
| `/loop [interval] <prompt>` | Run prompt repeatedly on interval (default 10m); useful for polling |
| `/simplify [focus]` | Review changed files for reuse/quality/efficiency; spawns 3 parallel review agents |

### Skill Description Budget

Descriptions are loaded into context at 1% of context window (fallback 8,000 chars). Each entry capped at 250 chars. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

### Troubleshooting

| Problem | Solution |
|:--------|:--------|
| Skill not triggering | Check description keywords; verify with "What skills are available?"; invoke directly with `/skill-name` |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Descriptions cut short | Front-load key use case; raise budget with `SLASH_COMMAND_TOOL_CHAR_BUDGET` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude with Skills](references/claude-code-skills.md) -- Creating skills, bundled skills, skill locations, frontmatter reference, invocation control, arguments, dynamic context injection, subagent execution, sharing, visual output, troubleshooting
- [Agent Skills Specification](references/agent-skills-specification.md) -- Open standard spec: directory structure, SKILL.md format, frontmatter fields, body content, optional directories, progressive disclosure, file references, validation

## Sources

- Extend Claude with Skills: https://code.claude.com/docs/en/skills.md
- Agent Skills Specification: https://agentskills.io/specification.md
