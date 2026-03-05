---
name: memory-doc
description: Complete documentation for Claude Code memory — CLAUDE.md files (project, user, local, managed policy), .claude/rules/ path-scoped rules, auto memory, imports, load order, claudeMdExcludes, /memory command, and troubleshooting. Load when discussing CLAUDE.md authoring, memory persistence, rules configuration, auto memory settings, or instruction loading.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory systems (CLAUDE.md files and auto memory).

## Quick Reference

Claude Code has two complementary memory systems, both loaded at the start of every conversation:

| | CLAUDE.md files | Auto memory |
|:--|:--|:--|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session (full file) | Every session (first 200 lines of MEMORY.md) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, preferences |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All org users |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team (via VCS) |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Local** | `./CLAUDE.local.md` | Just you (current project) |

More specific locations take precedence over broader ones. CLAUDE.md files above the working directory load in full at launch. CLAUDE.md files in subdirectories load on demand when Claude reads files there.

### Writing Effective Instructions

- **Size**: target under 200 lines per file
- **Structure**: use markdown headers and bullets
- **Specificity**: concrete, verifiable rules ("Use 2-space indentation" not "Format code properly")
- **Consistency**: avoid contradicting rules across files

### Imports

Use `@path/to/file` syntax to import additional files into CLAUDE.md. Relative paths resolve relative to the importing file. Max depth: 5 hops. Example:

```
See @README for project overview and @package.json for npm commands.
```

### `.claude/rules/` Directory

Organize instructions into modular markdown files. All `.md` files are discovered recursively.

**Path-scoped rules** use YAML frontmatter to apply only when Claude works with matching files:

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API rules here
```

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

Rules without `paths` are loaded unconditionally at launch. User-level rules in `~/.claude/rules/` apply to every project. Symlinks are supported.

### `claudeMdExcludes`

Skip specific CLAUDE.md files by path or glob. Configured in settings at any layer (user, project, local, managed policy). Arrays merge across layers. Managed policy CLAUDE.md cannot be excluded.

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

### `--add-dir` CLAUDE.md Loading

By default, `--add-dir` directories do not load CLAUDE.md files. Enable with:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### Auto Memory

Claude saves notes automatically across sessions. Storage per project at `~/.claude/projects/<project>/memory/`:

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Index, first 200 lines loaded every session
  debugging.md       # Topic file (loaded on demand)
  api-conventions.md # Topic file (loaded on demand)
```

All worktrees/subdirectories within the same git repo share one auto memory directory. Machine-local, not shared across machines.

**Toggle auto memory:**
- `/memory` command in session
- `"autoMemoryEnabled": false` in project settings
- `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` environment variable

### `/memory` Command

Lists all CLAUDE.md and rules files loaded in the current session. Lets you toggle auto memory, open the auto memory folder, or select any file to edit.

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Claude not following CLAUDE.md | Run `/memory` to verify loading; check file location; make instructions more specific; look for conflicts |
| Unknown auto memory contents | Run `/memory` and browse the auto memory folder; all files are editable markdown |
| CLAUDE.md too large | Move content to `@path` imports or `.claude/rules/` files; target under 200 lines |
| Instructions lost after `/compact` | CLAUDE.md survives compaction (re-read from disk); conversation-only instructions do not -- add them to CLAUDE.md |

Use the `InstructionsLoaded` hook to log exactly which instruction files are loaded and when.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, .claude/rules/, auto memory, /memory command, imports, load order, claudeMdExcludes, and troubleshooting

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
