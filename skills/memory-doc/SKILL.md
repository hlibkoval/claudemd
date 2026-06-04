---
name: memory-doc
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory: CLAUDE.md files, auto memory, `.claude/rules/`, the `.claude` directory layout, and how instructions persist across sessions.

## Quick Reference

### CLAUDE.md vs Auto Memory

| | CLAUDE.md files | Auto memory |
|:--|:--|:--|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session (in full) | Every session (first 200 lines or 25 KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (Load Order: Broadest → Most Specific)

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team members via source control |
| **Local instructions** | `./CLAUDE.local.md` | Just you (current project); add to `.gitignore` |

Files in ancestor directories (above cwd) load at launch in full. Nested subdirectory CLAUDE.md files load on demand when Claude reads files in that directory.

### Writing Effective CLAUDE.md Instructions

| Principle | Guidance |
|:----------|:---------|
| **Size** | Target under 200 lines per file; longer files reduce adherence |
| **Structure** | Use markdown headers and bullets to group related rules |
| **Specificity** | Concrete and verifiable: "Use 2-space indentation" not "Format code properly" |
| **Consistency** | Review periodically; conflicting rules cause arbitrary behavior |

### Import Syntax

Use `@path/to/file` anywhere in CLAUDE.md to inline another file at load time. Relative paths resolve from the containing file. Maximum import depth: 4 hops. External imports show a one-time approval dialog.

```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

### AGENTS.md Compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

Or create a symlink: `ln -s AGENTS.md CLAUDE.md` (requires Admin/Developer Mode on Windows).

### `.claude/rules/` — Path-Scoped Instructions

Rules are markdown files in `.claude/rules/` (or `~/.claude/rules/` for user-level). Rules without `paths:` frontmatter load at session start; rules with `paths:` load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "tests/**/*.test.ts"
---

# API Rules
- All endpoints must validate input with Zod schemas
```

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

Rules load into context every session or when matching files are opened. For task-specific instructions, use skills instead.

### `claudeMdExcludes` — Skip CLAUDE.md Files in Monorepos

Add to `.claude/settings.local.json`:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute paths. Managed policy CLAUDE.md files cannot be excluded.

### Managed Settings: `claudeMd` Key

Put behavioral instructions directly in `managed-settings.json` instead of a separate file:

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

| Concern | Where |
|:--------|:------|
| Block specific tools, commands, or file paths | Managed settings: `permissions.deny` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### Auto Memory

Auto memory requires Claude Code v2.1.59+. Toggle with `/memory` or `autoMemoryEnabled` in settings. Disable via env: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

| Setting | Description |
|:--------|:------------|
| `autoMemoryEnabled` | `true` (default) / `false` |
| `autoMemoryDirectory` | Override storage location; must be absolute path or `~/…` |

**Storage:** `~/.claude/projects/<project>/memory/` — keyed by git repo; all worktrees share one directory.

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index, loaded into every session (first 200 lines / 25 KB)
├── debugging.md       # Detailed topic notes (read on demand, not at startup)
└── api-conventions.md # Additional topic files Claude creates as needed
```

Auto memory is machine-local; not shared across machines or cloud environments.

### `/memory` Command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session. Provides a link to the auto memory folder and lets you toggle auto memory on/off. Select any file to open it in your editor.

### How CLAUDE.md Files Load

- Walk up the directory tree from cwd; load every `CLAUDE.md` and `CLAUDE.local.md` found
- Content is concatenated (not overridden); ordered from filesystem root down to cwd
- Within each directory: `CLAUDE.md` first, then `CLAUDE.local.md`
- Subdirectory files load on demand when Claude reads files there
- HTML comments (`<!-- … -->`) are stripped before injection; not counted against tokens
- Use `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` with `--add-dir` to also load memory from additional directories

### `.claude` Directory Layout (Key Files)

| File | Scope | Commit | Purpose |
|:-----|:------|:------:|:--------|
| `CLAUDE.md` / `.claude/CLAUDE.md` | Project + global | Yes | Instructions every session |
| `.claude/rules/*.md` | Project + global | Yes | Topic-scoped instructions, optionally path-gated |
| `.claude/settings.json` | Project + global | Yes | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | Project | No | Personal overrides; auto-gitignored |
| `~/.claude/projects/<proj>/memory/` | Global | No | Auto memory: Claude's notes to itself |
| `~/.claude.json` | Global | No | App state, OAuth, UI toggles, personal MCP servers |

### Troubleshooting

| Problem | Fix |
|:--------|:----|
| Claude isn't following CLAUDE.md | Run `/memory` to verify files are loaded; make instructions more specific; check for conflicts across files |
| Don't know what auto memory saved | Run `/memory` → select auto memory folder; everything is plain markdown |
| CLAUDE.md is too large | Use path-scoped rules; trim content; splitting into `@path` imports helps organize but doesn't reduce context |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-injects after compaction; nested CLAUDE.md files reload next time Claude reads that subdirectory |
| Need guaranteed behavior | Use a [hook](/en/hooks-guide) instead; hooks execute at fixed lifecycle events regardless of what Claude decides |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude Remembers Your Project](references/claude-code-memory.md) — CLAUDE.md files, location scopes, import syntax, AGENTS.md compatibility, how files load, rules, large-team management, auto memory, `/memory` command, troubleshooting
- [Explore the .claude Directory](references/claude-code-claude-directory.md) — Interactive reference for every file and folder in the project `.claude/` directory and `~/.claude/`, including when each loads, examples, and application data management

## Sources

- How Claude Remembers Your Project: https://code.claude.com/docs/en/memory.md
- Explore the .claude Directory: https://code.claude.com/docs/en/claude-directory.md
