---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files, auto memory, .claude/rules/, the /memory command, troubleshooting, and the .claude directory reference including all config files, settings precedence, and application data paths.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

Claude Code persists knowledge across sessions through two complementary systems loaded at the start of every conversation.

### CLAUDE.md vs auto memory

|                      | CLAUDE.md files                                   | Auto memory                                                      |
| :------------------- | :------------------------------------------------ | :--------------------------------------------------------------- |
| **Who writes it**    | You                                               | Claude                                                           |
| **What it contains** | Instructions and rules                            | Learnings and patterns                                           |
| **Scope**            | Project, user, or org                             | Per working tree                                                 |
| **Loaded into**      | Every session                                     | Every session (first 200 lines or 25KB of MEMORY.md)            |
| **Use for**          | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md file locations

More specific locations take precedence over broader ones.

| Scope                | Location                                                          | Shared with                     |
| :------------------- | :---------------------------------------------------------------- | :------------------------------ |
| **Managed policy**   | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org (cannot be excluded) |
| **Project**          | `./CLAUDE.md` or `./.claude/CLAUDE.md`                           | Team via source control         |
| **User**             | `~/.claude/CLAUDE.md`                                             | Just you (all projects)         |
| **Local project**    | `./CLAUDE.local.md` (add to `.gitignore`)                        | Just you (current project)      |

### Writing effective CLAUDE.md

- **Size**: target under 200 lines per file; longer files still load but reduce adherence
- **Structure**: use markdown headers and bullets for grouping
- **Specificity**: concrete and verifiable instructions work best (e.g., "Use 2-space indentation" not "Format code properly")
- **Imports**: use `@path/to/file` syntax to pull in other files (max 5 hops deep); relative paths resolve from the importing file

### How CLAUDE.md files load

- Walk up directory tree from cwd; each `CLAUDE.md` and `CLAUDE.local.md` found is concatenated into context
- `CLAUDE.local.md` appended after `CLAUDE.md` at each level (personal notes win on conflict)
- Subdirectory `CLAUDE.md` files load on demand when Claude reads files in those directories (not at launch)
- HTML block comments (`<!-- ... -->`) are stripped before injection (saves context tokens)
- Use `claudeMdExcludes` in settings to skip specific files by path or glob (managed policy files cannot be excluded)
- Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` with `--add-dir` to also load memory from extra directories

### .claude/rules/ directory

Splits instructions into topic files that can load conditionally.

| Behavior             | How                                                          |
| :------------------- | :----------------------------------------------------------- |
| Always load          | Rule file has no `paths:` frontmatter                        |
| Load on demand       | Rule file has `paths:` frontmatter with glob patterns        |
| Path triggers        | When Claude reads a file matching a `paths:` glob            |
| User-level rules     | `~/.claude/rules/` — apply to every project                  |
| Symlinks supported   | Circular symlinks detected and handled gracefully            |

Path-scoped rule example:
```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Rules
- All endpoints must validate input
```

Supported glob patterns: `**/*.ts`, `src/**/*`, `*.md`, `src/components/*.tsx`, brace expansion `{ts,tsx}`.

### Auto memory

- Requires Claude Code v2.1.59 or later
- On by default; toggle with `/memory` or `autoMemoryEnabled` in settings
- Disable via env: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`
- Machine-local; all worktrees and subdirectories within the same git repo share one directory

**Storage location**: `~/.claude/projects/<project>/memory/`
Override with `autoMemoryDirectory` in user or local settings (not accepted from project settings).

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index loaded every session (first 200 lines / 25KB)
├── debugging.md       # Topic files — read on demand, not at startup
└── api-conventions.md
```

### /memory command

- Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in current session
- Toggles auto memory on/off
- Provides link to open the auto memory folder
- Select any file to open it in your editor

### Troubleshooting

| Symptom                              | Cause / Fix                                                                                                  |
| :----------------------------------- | :----------------------------------------------------------------------------------------------------------- |
| Claude ignores CLAUDE.md             | Content is context, not enforced config. Run `/memory` to verify files are loaded. Make instructions specific. |
| Instructions conflict                | Check for contradictions across multiple CLAUDE.md files; Claude may pick one arbitrarily                    |
| CLAUDE.md is too large               | Over 200 lines reduces adherence; split with `@path` imports or `.claude/rules/` files                       |
| Instructions lost after `/compact`   | Project-root CLAUDE.md survives; nested files reload next time Claude reads a file in that directory          |
| Don't know what auto memory saved    | Run `/memory` and select the auto memory folder to browse plain-markdown files                               |
| System-prompt–level enforcement      | Use `--append-system-prompt` (must pass every invocation; suited for scripts/automation)                     |
| Debug which files load               | Use the `InstructionsLoaded` hook to log exactly which instruction files load, when, and why                  |

### .claude directory quick reference

Key files and when they load:

| File                              | Commit | When it loads                                        |
| :-------------------------------- | :----: | :--------------------------------------------------- |
| `CLAUDE.md` / `.claude/CLAUDE.md` | ✓      | Every session                                        |
| `.claude/rules/*.md` (no paths)   | ✓      | Every session (same priority as CLAUDE.md)           |
| `.claude/rules/*.md` (with paths) | ✓      | When a matching file enters context                  |
| `.claude/settings.json`           | ✓      | Overrides `~/.claude/settings.json`                  |
| `.claude/settings.local.json`     |        | Overrides settings.json; auto-gitignored             |
| `.mcp.json` (project root)        | ✓      | Servers connect at session start                     |
| `.worktreeinclude` (project root) | ✓      | When a new worktree is created                       |
| `skills/<name>/SKILL.md`          | ✓      | On invocation or when Claude matches the task        |
| `agents/*.md`                     | ✓      | Fresh context window when invoked or delegated to    |
| `.claude/agent-memory/<name>/`    | ✓      | Into subagent system prompt when subagent starts     |
| `~/.claude/projects/<proj>/memory/MEMORY.md` | — | First 200 lines / 25KB at session start   |

**Settings precedence** (highest to lowest): managed policy → CLI flags → `settings.local.json` → project `settings.json` → `~/.claude/settings.json`. Array settings (e.g., `permissions.allow`) merge across all layers; scalar settings use the most specific value.

### Check what loaded in a session

| Command        | Shows                                                                 |
| :------------- | :-------------------------------------------------------------------- |
| `/context`     | Token usage by category: system prompt, memory, skills, MCP, messages |
| `/memory`      | Which CLAUDE.md and rules files loaded; auto-memory entries           |
| `/agents`      | Configured subagents and their settings                               |
| `/hooks`       | Active hook configurations                                            |
| `/skills`      | Available skills from project, user, and plugin sources               |
| `/permissions` | Current allow and deny rules                                          |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, import syntax, auto memory, /memory command, troubleshooting, and related resources
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive directory reference covering every config file, when it loads, examples, file reference table, troubleshooting, and application data paths

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
