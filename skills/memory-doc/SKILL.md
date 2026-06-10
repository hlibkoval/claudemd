---
name: memory-doc
user-invocable: false
description: Reference documentation for Claude Code memory systems — CLAUDE.md files, .claude/rules/, auto memory, and the .claude directory layout.
---

# Memory & Configuration Directory Documentation

This skill provides the complete official documentation for Claude Code memory systems and the `.claude` directory structure.

## Quick Reference

### Memory Systems Comparison

| Feature | CLAUDE.md files | Auto memory |
|---|---|---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (load order, broadest → most specific)

| Scope | Location | Shared with |
|---|---|---|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **Local instructions** | `./CLAUDE.local.md` | Just you (current project, add to .gitignore) |

### Key Settings

| Setting | Location | Description |
|---|---|---|
| `autoMemoryEnabled` | `settings.json` | Toggle auto memory on/off (default: true) |
| `autoMemoryDirectory` | `settings.json` | Override auto memory storage path (absolute or `~/`) |
| `claudeMdExcludes` | `settings.json` | Glob patterns for CLAUDE.md files to skip |
| `claudeMd` | `managed-settings.json` only | Inline managed CLAUDE.md content |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | env var | Set to `1` to disable auto memory |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | env var | Set to `1` to load CLAUDE.md from `--add-dir` paths |

### Auto Memory Storage

- Location: `~/.claude/projects/<project>/memory/`
- `<project>` derived from git root; all worktrees share one directory
- `MEMORY.md`: index file, first 200 lines or 25KB loaded at session start
- Topic files (e.g. `debugging.md`): created by Claude, read on demand
- Requires Claude Code v2.1.59 or later

### .claude/rules/ — Path-Scoped Instructions

Rules are markdown files in `.claude/rules/`. Without `paths:` frontmatter, they load at session start like CLAUDE.md. With `paths:`, they load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "tests/**/*.test.ts"
---

# API Rules
- Validate all inputs with Zod
```

Glob pattern examples:

| Pattern | Matches |
|---|---|
| `**/*.ts` | All TypeScript files anywhere |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown at project root |
| `src/components/*.tsx` | React components in a specific dir |

### Import Syntax

CLAUDE.md files can pull in other files using `@path/to/file` syntax. Paths resolve relative to the importing file. Max import depth: 4 hops.

### CLAUDE.md Writing Tips

- Target under 200 lines per file — longer files reduce adherence
- Use markdown headers and bullets; organized sections are easier to follow
- Write specific, verifiable instructions: "Use 2-space indentation" not "Format code properly"
- Use `<!-- comment -->` block-level HTML comments for maintainer notes (stripped before injection)
- Nested CLAUDE.md files in subdirectories load on demand (not at launch)

### .claude Directory — Key Files

| File | Scope | Committed | Purpose |
|---|---|---|---|
| `CLAUDE.md` or `.claude/CLAUDE.md` | Project + global | Yes | Instructions loaded every session |
| `.claude/rules/*.md` | Project + global | Yes | Topic-scoped instructions, optionally path-gated |
| `.claude/settings.json` | Project + global | Yes | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | Project only | No (gitignored) | Personal overrides |
| `CLAUDE.local.md` | Project only | No (gitignored) | Personal project preferences |
| `~/.claude/projects/<project>/memory/` | Global only | No | Auto memory: Claude's notes to itself |

### Application Data Cleanup

Files under `~/.claude/projects/` (transcripts, tool results) are deleted on startup after `cleanupPeriodDays` (default: 30). Run `claude project purge ~/work/my-repo` (requires v2.1.124+) to delete all state for one project.

### Troubleshooting

- Run `/memory` to see which files are loaded and toggle auto memory
- Instructions not followed? Check `/memory` list, ensure file is in a loaded location, make instructions more specific
- After `/compact`: project-root CLAUDE.md is re-injected; nested CLAUDE.md files reload next time Claude reads a file in that subdirectory
- CLAUDE.md too large? Use path-scoped rules; splitting into `@path` imports helps organization but does NOT reduce context load

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, auto memory, rules, imports, and troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — Interactive reference for every file in `.claude/` and `~/.claude/`, including application data paths

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
