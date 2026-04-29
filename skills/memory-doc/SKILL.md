---
name: memory-doc
description: Complete official documentation for Claude Code memory systems — CLAUDE.md files, auto memory, MEMORY.md, .claude/rules/, path-scoped rules, imports, organization-wide managed CLAUDE.md, the .claude directory layout, and all config files Claude Code reads at startup.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

Claude Code carries knowledge across sessions with two complementary mechanisms: CLAUDE.md files you write, and auto memory Claude writes itself.

### CLAUDE.md vs auto memory

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25 KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md file locations and scope

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org (cannot be excluded) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User (global)** | `~/.claude/CLAUDE.md` | Just you, all projects |
| **Local (private)** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you, current project |

More specific locations take precedence over broader ones. All discovered files are concatenated, not overridden.

### How CLAUDE.md files load

- Walks up the directory tree from the working directory, loading `CLAUDE.md` and `CLAUDE.local.md` at each level
- `CLAUDE.local.md` appended after `CLAUDE.md` at the same level (local wins on conflict)
- Subdirectory CLAUDE.md files load on demand when Claude reads files in those directories
- Block-level HTML comments (`<!-- ... -->`) are stripped before injection (invisible in context, visible when read directly)
- Use `--add-dir` + `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to also load memory from extra directories

### Import syntax

```text
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

- Relative paths resolve from the file containing the import
- Recursive imports supported up to 5 hops deep
- Imported files load at launch — they reduce organization but not context size
- External imports show an approval dialog the first time

### AGENTS.md interop

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other agents:

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

### Writing effective instructions

| Concern | Guidance |
| :--- | :--- |
| **Size** | Target under 200 lines per file; longer files load in full but reduce adherence |
| **Structure** | Use markdown headers and bullets; organized sections are easier to follow |
| **Specificity** | "Use 2-space indentation" not "format code properly" |
| **Consistency** | Review periodically; conflicting rules may be picked arbitrarily |

### Excluding CLAUDE.md files (monorepos)

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns are matched against absolute paths. Managed policy CLAUDE.md files cannot be excluded. Arrays merge across settings layers.

### .claude/rules/ — path-scoped instructions

Rules in `.claude/rules/` load per-topic. Without `paths:` frontmatter they load at session start; with `paths:` they load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "tests/**/*.test.ts"
---

# API Development Rules
- All endpoints must validate input
```

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

- Subdirectories are discovered recursively (e.g., `.claude/rules/frontend/react.md`)
- Symlinks are supported and circular symlinks are handled
- User-level rules at `~/.claude/rules/` apply to every project; project rules take higher priority

### Auto memory

Auto memory is on by default. Toggle with `/memory` or set `autoMemoryEnabled: false` in settings. Disable via env: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

**Storage location**: `~/.claude/projects/<project>/memory/`
- `<project>` is derived from the git repo — all worktrees share one directory
- Override with `autoMemoryDirectory` in user or local settings (not project settings)

**Memory directory structure**:

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded first 200 lines / 25 KB each session
├── debugging.md       # Detailed notes on debugging patterns (read on demand)
├── api-conventions.md # API design decisions (read on demand)
└── ...
```

- `MEMORY.md` is the index; topic files are read on demand via standard file tools
- The 200-line / 25 KB limit applies only to `MEMORY.md`; CLAUDE.md files load in full
- Auto memory is machine-local; not shared across machines

### /memory command

`/memory` lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session, lets you toggle auto memory, and links to the auto memory folder.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify file is listed; use `--append-system-prompt` for system-prompt-level enforcement |
| Don't know what auto memory saved | Run `/memory`, open auto memory folder; files are plain markdown |
| CLAUDE.md too large | Use path-scoped rules or trim content; `@path` imports help organization but not context |
| Instructions lost after `/compact` | Project-root CLAUDE.md is re-injected after compaction; nested CLAUDE.md files reload on next file read |

### .claude directory at a glance

| File | Scope | Committed | Purpose |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | Project + global | Yes | Instructions every session |
| `rules/*.md` | Project + global | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Project + global | Yes | Permissions, hooks, env, model |
| `settings.local.json` | Project | No | Personal overrides (auto-gitignored) |
| `.mcp.json` | Project | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Project | Yes | Gitignored files to copy into worktrees |
| `skills/<name>/SKILL.md` | Project + global | Yes | Reusable prompts invoked with `/name` |
| `commands/*.md` | Project + global | Yes | Single-file prompts (same mechanism as skills) |
| `output-styles/*.md` | Project + global | Yes | Custom system-prompt style sections |
| `agents/*.md` | Project + global | Yes | Subagent definitions |
| `agent-memory/<name>/` | Project + global | Yes | Persistent memory for subagents |
| `~/.claude.json` | Global | No | App state, OAuth, UI, personal MCP servers |
| `projects/<project>/memory/` | Global | No | Auto memory: Claude's notes to itself |
| `keybindings.json` | Global | No | Custom keyboard shortcuts |
| `themes/*.json` | Global | No | Custom color themes |

### Application data lifecycle

Files auto-deleted after `cleanupPeriodDays` (default 30): session transcripts, tool result spills, file-history snapshots, plans, debug logs, paste/image caches, session-env, tasks, shell-snapshots, backups.

Files kept until you delete them: `history.jsonl` (prompt recall), `stats-cache.json` (usage counts), `todos/` (legacy, safe to delete).

Do not delete `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/` — these hold auth, preferences, and installed plugins.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files (locations, writing effective instructions, imports, AGENTS.md interop, load order, organization-wide managed CLAUDE.md, excludes), `.claude/rules/` (path-specific rules, symlinks, user-level rules), auto memory (enable/disable, storage, how it works, audit), `/memory` command, and troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive reference covering every file Claude Code reads: CLAUDE.md, settings.json, settings.local.json, .mcp.json, .worktreeinclude, skills/, commands/, output-styles/, agents/, agent-memory/, ~/.claude.json, projects/ (auto memory), keybindings.json, themes/; also covers application data paths and cleanup

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
