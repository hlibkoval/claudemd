---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files (scopes, load order, imports, path-scoped rules, AGENTS.md interop, large-team management, claudeMdExcludes), auto memory (MEMORY.md, storage location, enable/disable, audit), the /memory command, troubleshooting, and the .claude directory structure (all config files, application data, project purge).
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md Scopes and Load Order

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team (via source control) |
| **Local instructions** | `./CLAUDE.local.md` | Just you (current project, add to `.gitignore`) |

Files load from filesystem root down to the working directory; `CLAUDE.local.md` appends after `CLAUDE.md` at each level. Subdirectory CLAUDE.md files load on demand when Claude reads files there.

### CLAUDE.md Writing Tips

| Concern | Guideline |
| :--- | :--- |
| **Size** | Target under 200 lines per file; longer files reduce adherence |
| **Structure** | Use markdown headers and bullets; organized sections are easier to follow |
| **Specificity** | Concrete and verifiable: "Use 2-space indentation" not "Format code properly" |
| **Consistency** | No contradicting rules across files; use `claudeMdExcludes` for irrelevant monorepo files |

### Imports

Reference other files with `@path/to/file` syntax anywhere in a CLAUDE.md. Both relative and absolute paths work; relative paths resolve from the containing file. Maximum import depth: 5 hops. Imported files enter context at launch (they do not reduce token usage).

### Path-Scoped Rules (`.claude/rules/`)

```markdown
---
paths:
  - "src/api/**/*.ts"
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

Rules without `paths:` load at session start (same priority as `.claude/CLAUDE.md`). Rules with `paths:` load only when a matching file enters context.

User-level rules in `~/.claude/rules/` apply to every project. Load order: user rules before project rules (project rules have higher priority).

### AGENTS.md Interop

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other agents, create a `CLAUDE.md` that imports it:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

Or create a symlink (requires Admin/Developer Mode on Windows).

### Excluding CLAUDE.md Files

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute paths using glob syntax. Configurable at any settings layer (arrays merge across layers). Managed policy CLAUDE.md files cannot be excluded.

### `claudeMd` in Managed Settings

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

Puts managed CLAUDE.md content directly in `managed-settings.json`. Only honored in managed/policy settings.

### Auto Memory Storage

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, first 200 lines / 25KB loaded every session
├── debugging.md       # Detailed notes on debugging patterns (read on demand)
├── api-conventions.md # API design decisions (read on demand)
└── ...
```

- All worktrees and subdirectories of the same git repo share one auto memory directory.
- Requires Claude Code v2.1.59+.
- Custom location: set `autoMemoryDirectory` in `~/.claude/settings.json` (must be absolute path or `~/`; not accepted in project/local settings).

### Auto Memory Enable/Disable

| Method | Command/Value |
| :--- | :--- |
| Toggle in session | `/memory` → auto memory toggle |
| Settings file | `"autoMemoryEnabled": false` |
| Environment variable | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |

### The `/memory` Command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session. Lets you toggle auto memory on/off and open the auto memory folder. Select any file to open it in your editor.

Use it to ask Claude to remember something (saved to auto memory) or to verify which files are loaded (troubleshooting).

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude not following CLAUDE.md | Run `/memory` to confirm the file is listed; check location scope; make instructions more specific; look for conflicts across files |
| Don't know what auto memory saved | Run `/memory` and select the auto memory folder |
| CLAUDE.md too large (>200 lines) | Use path-scoped rules; trim content not needed every session; note: `@path` imports do NOT reduce context |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-injected after compaction; nested CLAUDE.md files reload next time a file in that subdirectory is read; add conversation-only instructions to CLAUDE.md |
| Need instruction to run at a fixed lifecycle point | Use a [hook](/en/hooks-guide) instead — hooks execute as shell commands regardless of Claude's decisions |

### `.claude` Directory Quick Reference

| File | Scope | Commit | What it does |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | Project and global | Yes | Instructions loaded every session |
| `rules/*.md` | Project and global | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Project and global | Yes | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | Project only | No | Personal overrides, auto-gitignored |
| `.mcp.json` | Project only | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Project only | Yes | Gitignored files to copy into new worktrees |
| `skills/<name>/SKILL.md` | Project and global | Yes | Reusable prompts invoked with `/name` or auto-invoked |
| `commands/*.md` | Project and global | Yes | Single-file prompts (same mechanism as skills) |
| `output-styles/*.md` | Project and global | Yes | Custom system-prompt sections |
| `agents/*.md` | Project and global | Yes | Subagent definitions with own prompt and tools |
| `agent-memory/<name>/` | Project and global | Yes | Persistent memory for subagents |
| `~/.claude.json` | Global only | No | App state, OAuth, UI toggles, personal MCP servers |
| `projects/<project>/memory/` | Global only | No | Auto memory: Claude's notes to itself |
| `keybindings.json` | Global only | No | Custom keyboard shortcuts |
| `themes/*.json` | Global only | No | Custom color themes |

### Application Data (auto-cleaned after `cleanupPeriodDays`, default 30 days)

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `projects/<project>/<session>/subagents/` | Subagent transcripts |
| `projects/<project>/<session>/tool-results/` | Large tool outputs |
| `file-history/<session>/` | Pre-edit snapshots for checkpoint restore |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs |
| `paste-cache/`, `image-cache/` | Large pastes and attached images |

### Project Purge

```bash
claude project purge ~/work/my-repo          # Review plan, confirm, then delete
claude project purge ~/work/my-repo --dry-run  # Preview only
claude project purge ~/work/my-repo --yes    # Skip confirmation
claude project purge --all                  # All projects
```

Deletes transcripts, auto memory, tasks, debug logs, file-history entries, and the project's entry in `~/.claude.json`. Does not touch `shell-snapshots/` or `backups/`.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, load order, imports, path-scoped rules, AGENTS.md interop, auto memory, /memory command, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive file tree reference, all config files and application data explained, project purge

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
