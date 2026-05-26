---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files (locations, load order, scopes, import syntax, path-scoped rules, auto memory), the .claude directory structure (CLAUDE.md, settings.json, rules/, skills/, commands/, agents/, agent-memory/, output-styles/, auto memory at ~/.claude/projects/), application data paths, and the claude project purge command.
user-invocable: false
---

# Memory & .claude Directory Documentation

This skill provides the complete official documentation for Claude Code memory systems and the .claude directory layout.

## Quick Reference

### Two Memory Systems

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
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users on machine (cannot be excluded) |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **Local** | `./CLAUDE.local.md` | Just you (add to .gitignore) |

Files in the directory tree above the working directory load in full at launch. Files in subdirectories load on demand when Claude reads files there.

### CLAUDE.md Best Practices

- Target under 200 lines per file — longer files reduce adherence
- Use markdown headers and bullets for structure
- Write concrete, verifiable instructions ("Use 2-space indentation" not "Format code properly")
- Use HTML block comments (`<!-- notes -->`) for maintainer notes — stripped before injection into context
- Import other files with `@path/to/file` syntax (relative to the importing file, max 5 hops deep)
- Use `AGENTS.md` interop: create a `CLAUDE.md` that imports `@AGENTS.md` to share instructions with other agents

### Import Syntax

```text
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

### Path-Scoped Rules (`.claude/rules/`)

Rules in `.claude/rules/` keep instructions modular. Without `paths:` frontmatter they load at session start. With `paths:` they load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "tests/**/*.test.ts"
---

# API Development Rules
- All endpoints must include input validation
```

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

User-level rules (`~/.claude/rules/`) apply to every project; project rules take higher priority.

### `claudeMdExcludes` Setting

Skip specific CLAUDE.md files in large monorepos:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute file paths. Managed policy CLAUDE.md files cannot be excluded.

### Auto Memory

- **Requires** Claude Code v2.1.59+
- **On by default.** Toggle with `/memory` or `autoMemoryEnabled` in settings, or set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`
- **Storage**: `~/.claude/projects/<project>/memory/` — keyed by git repository, shared across worktrees
- Custom location: set `autoMemoryDirectory` in `~/.claude/settings.json` (absolute path or `~/`; not accepted in project/local settings)
- First 200 lines or 25KB of `MEMORY.md` loaded every session; topic files loaded on demand

Auto memory directory structure:

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session
├── debugging.md       # Detailed notes on debugging patterns
├── api-conventions.md # API design decisions
└── ...                # Topic files Claude creates as needed
```

### `/memory` Command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session, lets you toggle auto memory on/off, and opens the auto memory folder. Select any file to open it in your editor.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify the file is loaded; make instructions more specific; check for conflicts across files |
| Instructions use `--append-system-prompt` | Pass at every invocation; suited to scripts not interactive use |
| Instructions lost after `/compact` | Project-root CLAUDE.md is re-injected after compact; nested CLAUDE.md files reload next time a file in that subdir is read |
| CLAUDE.md too large | Use path-scoped rules or trim content; `@path` imports organize but do not reduce context |

For hook-based enforcement (must run at specific lifecycle points), use [hooks](/en/hooks) instead of CLAUDE.md instructions.

### .claude Directory — Quick File Reference

| File | Scope | Commit | Purpose |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | Project + global | Yes | Instructions loaded every session |
| `rules/*.md` | Project + global | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Project + global | Yes | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | Project only | No | Personal overrides, auto-gitignored |
| `.mcp.json` | Project only | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Project only | Yes | Gitignored files to copy into new worktrees |
| `skills/<name>/SKILL.md` | Project + global | Yes | Reusable prompts invoked with `/name` |
| `commands/*.md` | Project + global | Yes | Single-file prompts (legacy; prefer skills) |
| `output-styles/*.md` | Project + global | Yes | Custom system-prompt sections |
| `agents/*.md` | Project + global | Yes | Subagent definitions |
| `agent-memory/<name>/` | Project + global | Yes | Persistent memory for subagents |
| `~/.claude.json` | Global only | No | App state, OAuth, UI toggles, personal MCP servers |
| `projects/<project>/memory/` | Global only | No | Auto memory: Claude's notes per project |
| `keybindings.json` | Global only | No | Custom keyboard shortcuts |
| `themes/*.json` | Global only | No | Custom color themes |

### Application Data (Auto-cleaned after `cleanupPeriodDays`, default 30 days)

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `projects/<project>/<session>/subagents/` | Subagent conversation transcripts |
| `file-history/<session>/` | Pre-edit file snapshots (checkpoint restore) |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs |
| `paste-cache/`, `image-cache/` | Large pastes and attached images |

### Application Data (Kept Until Manually Deleted)

| Path | Contents |
| :--- | :--- |
| `~/.claude/history.jsonl` | Every prompt typed, with timestamp |
| `~/.claude/stats-cache.json` | Token and cost counts for `/usage` |
| `~/.claude/remote-settings.json` | Cached server-managed settings |

### `claude project purge` Command

Deletes all Claude Code state for one project: transcripts, auto memory, task lists, debug logs, and prompt history lines.

```bash
claude project purge ~/work/my-repo --dry-run   # Preview without deleting
claude project purge ~/work/my-repo             # Delete with confirmation
claude project purge ~/work/my-repo --yes       # Skip confirmation
claude project purge --all                      # Purge all projects
```

Do not delete `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/` — those hold auth, preferences, and installed plugins.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, auto memory, path-scoped rules, import syntax, organization-wide deployment, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive directory explorer content, every file and folder explained with when it loads, examples, and tips; application data paths; `claude project purge`

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
