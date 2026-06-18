---
name: memory-doc
user-invocable: false
---

# Memory & .claude Directory Documentation

This skill provides the complete official documentation for Claude Code's memory systems — CLAUDE.md files, auto memory, `.claude/rules/`, and the full `.claude` directory layout.

## Quick Reference

### Memory System Comparison

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (Load Order, Broadest → Most Specific)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization (cannot be excluded) |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team members via source control |
| **Local instructions** | `./CLAUDE.local.md` | Just you (current project; add to `.gitignore`) |

### Key CLAUDE.md Behaviors

- Files in the directory hierarchy **above** the working directory load in full at launch; files in **subdirectories** load on demand when Claude reads files there
- Content is concatenated (not overriding): ordered from filesystem root down to working directory; `CLAUDE.local.md` appended after `CLAUDE.md` at each level
- HTML block comments (`<!-- notes -->`) are stripped before injection — use for maintainer notes without spending tokens
- Target under **200 lines** per file; longer files reduce adherence
- Import other files with `@path/to/file` syntax (relative or absolute, max 4 hops deep); wrap in backticks to prevent importing
- `claudeMdExcludes` setting skips specific files by path/glob (merged across settings layers; managed policy files cannot be excluded)
- `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` + `--add-dir` also loads CLAUDE.md from extra directories

### .claude/rules/ Setup

Place `.md` files in `.claude/rules/` (discovered recursively). Two loading modes:

| Rule type | Frontmatter | When it loads |
| :--- | :--- | :--- |
| Unconditional | No `paths:` field | Every session, same priority as `.claude/CLAUDE.md` |
| Path-scoped | `paths:` YAML list | When Claude reads a file matching any listed glob |

Path glob examples: `**/*.ts` (all TypeScript), `src/**/*` (all under src/), `src/components/*.tsx` (specific directory). Brace expansion works: `src/**/*.{ts,tsx}`. Supports symlinks (circular symlinks detected gracefully). User-level rules at `~/.claude/rules/` apply to every project; project rules take higher priority.

### Auto Memory

- Requires Claude Code v2.1.59+
- Toggle: `/memory` in session, or `autoMemoryEnabled: false` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`
- Storage: `~/.claude/projects/<project>/memory/` (keyed by git repo root; all worktrees share one directory)
- Custom location: `autoMemoryDirectory` setting (absolute path or `~/`-prefixed; honored after workspace trust dialog for project settings)

Auto memory directory layout:
```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index — first 200 lines or 25KB loaded each session
├── debugging.md       # Topic files — read on demand by Claude, not at startup
└── api-conventions.md
```

- `MEMORY.md` acts as an index; Claude moves detailed notes to topic files when it grows large
- Topic files are plain markdown; edit or delete them anytime
- Run `/memory` to browse, open files, and toggle auto memory on/off

### Subagent Memory

Subagents can maintain their own memory. Set `memory:` frontmatter in the agent definition:

| Value | Storage location | Shared |
| :--- | :--- | :--- |
| `project` | `.claude/agent-memory/<agent-name>/` | With team (committed) |
| `local` | `.claude/agent-memory-local/<agent-name>/` | Local only |
| `user` | `~/.claude/agent-memory/<agent-name>/` | Across all your projects |

### /memory Command

`/memory` lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session, provides a link to the auto memory folder, lets you toggle auto memory, and opens any file in your editor.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude ignores CLAUDE.md | Run `/memory` to verify the file is listed; check location is in the load path; make instructions more specific; look for conflicting rules |
| Instructions need guaranteed execution | Use a [hook](/en/hooks-guide) instead — hooks enforce behavior regardless of Claude's decisions |
| Don't know what auto memory saved | Run `/memory` and open the auto memory folder |
| CLAUDE.md too large | Use path-scoped rules; split content; note that `@path` imports still load at launch |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-injected after compact; nested CLAUDE.md files reload next time Claude reads files in that subdirectory |

### .claude Directory: Choose the Right File

| You want to | Edit | Reference |
| :--- | :--- | :--- |
| Give Claude project context and conventions | `CLAUDE.md` | Memory |
| Topic-scoped instructions, optionally path-gated | `.claude/rules/*.md` | Rules |
| Allow or block specific tool calls | `.claude/settings.json` `permissions` | Permissions |
| Run scripts at lifecycle events | `.claude/settings.json` `hooks` | Hooks |
| Keep personal overrides out of git | `.claude/settings.local.json` | Settings scopes |
| Add a reusable prompt invoked with `/name` | `.claude/skills/<name>/SKILL.md` | Skills |
| Define a specialized subagent | `.claude/agents/*.md` | Subagents |
| Orchestrate subagents from a script | `.claude/workflows/*.js` | Dynamic workflows |
| Connect external tools over MCP | `.mcp.json` | MCP |
| Change Claude's response format | `.claude/output-styles/*.md` | Output styles |

### Application Data Cleanup

Auto-cleaned after `cleanupPeriodDays` (default 30) days on startup:
- `~/.claude/projects/<project>/<session>.jsonl` — full transcripts
- `~/.claude/file-history/` — pre-edit file snapshots (checkpoint restore)
- `~/.claude/plans/`, `~/.claude/debug/`, `~/.claude/paste-cache/`, etc.

Kept indefinitely (delete manually if needed):
- `~/.claude/history.jsonl` — prompt history (up-arrow recall)
- `~/.claude/stats-cache.json` — token/cost totals for `/usage`

Run `claude project purge <path>` (v2.1.124+) to delete all state for one project. Use `--dry-run` to preview, `--yes` to skip confirmation, `--all` to purge all projects.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, auto memory, .claude/rules/, imports, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — Full directory layout, file reference table, application data, cleanup

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
