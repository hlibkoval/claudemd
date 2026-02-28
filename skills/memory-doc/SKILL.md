---
name: memory-doc
description: Complete documentation for Claude Code memory — CLAUDE.md files (locations, scoping, imports, loading order), .claude/rules/ path-specific rules, auto memory (MEMORY.md, topic files, 200-line limit), /memory command, claudeMdExcludes, and troubleshooting. Load when discussing CLAUDE.md configuration, project instructions, auto memory, rules files, or persistent context.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers your project across sessions.

## Quick Reference

Two mechanisms carry knowledge across sessions: **CLAUDE.md files** (instructions you write) and **auto memory** (notes Claude writes itself). Both load at the start of every conversation.

### CLAUDE.md vs Auto Memory

|                      | CLAUDE.md files                    | Auto memory                                           |
|:---------------------|:-----------------------------------|:------------------------------------------------------|
| **Who writes it**    | You                                | Claude                                                |
| **What it contains** | Instructions and rules             | Learnings and patterns                                |
| **Scope**            | Project, user, or org              | Per working tree                                      |
| **Loaded into**      | Every session (full)               | Every session (first 200 lines of MEMORY.md)          |
| **Use for**          | Coding standards, workflows, arch  | Build commands, debugging, preferences Claude discovers |

### CLAUDE.md File Locations

| Scope              | Location                                                      | Shared with                     |
|:-------------------|:--------------------------------------------------------------|:--------------------------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`    | All users in org                |
|                    | Linux/WSL: `/etc/claude-code/CLAUDE.md`                       |                                 |
|                    | Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`              |                                 |
| **Project**        | `./CLAUDE.md` or `./.claude/CLAUDE.md`                        | Team via source control         |
| **User**           | `~/.claude/CLAUDE.md`                                         | Just you (all projects)         |
| **Local**          | `./CLAUDE.local.md`                                           | Just you (current project)      |

More specific locations take precedence over broader ones. Files above the working directory load in full at launch. Files in subdirectories load on demand when Claude reads files there.

### Writing Effective CLAUDE.md

- **Size**: target under 200 lines per file
- **Structure**: use markdown headers and bullets
- **Specificity**: concrete, verifiable instructions (e.g. "Use 2-space indentation" not "Format code properly")
- **Consistency**: avoid conflicting instructions across files

### Imports (`@path` Syntax)

Reference other files with `@path/to/file` anywhere in CLAUDE.md. Relative paths resolve from the file containing the import. Max depth: 5 hops.

```text
See @README for project overview and @package.json for npm commands.
```

### `.claude/rules/` Directory

| Feature              | Description                                          |
|:---------------------|:-----------------------------------------------------|
| **Location**         | `.claude/rules/*.md` (project) or `~/.claude/rules/*.md` (user) |
| **Discovery**        | Recursive, supports subdirectories                   |
| **Path scoping**     | Add `paths` frontmatter to scope rules to file globs |
| **Load behavior**    | No `paths` field = loaded at launch; with `paths` = on demand |
| **Symlinks**         | Supported for sharing rules across projects          |

Path-scoped rule frontmatter example:

```yaml
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
---
```

### `claudeMdExcludes` Setting

Skip irrelevant CLAUDE.md files by path or glob pattern (useful in monorepos):

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Configurable at any settings layer. Arrays merge across layers. Managed policy CLAUDE.md cannot be excluded.

### Auto Memory

| Aspect           | Detail                                                        |
|:-----------------|:--------------------------------------------------------------|
| **Toggle**       | `/memory` command, or `autoMemoryEnabled: false` in settings  |
| **Env disable**  | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`                           |
| **Storage**      | `~/.claude/projects/<project>/memory/`                        |
| **Entrypoint**   | `MEMORY.md` (first 200 lines loaded at session start)         |
| **Topic files**  | Separate `.md` files for detailed notes (loaded on demand)    |
| **Scope**        | Machine-local; all worktrees in same git repo share one dir   |

### `/memory` Command

Lists all loaded CLAUDE.md and rules files. Lets you toggle auto memory, open memory folder, and edit files in your editor.

### Additional Directories

Load CLAUDE.md from `--add-dir` directories by setting:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### `/init` Command

Run `/init` to auto-generate a starting CLAUDE.md from codebase analysis. If one already exists, suggests improvements instead.

### Troubleshooting

| Problem                           | Fix                                                          |
|:----------------------------------|:-------------------------------------------------------------|
| Claude ignores CLAUDE.md          | Run `/memory` to verify file is loaded; make instructions specific; check for conflicts |
| Unknown auto memory contents      | Run `/memory` and browse the auto memory folder              |
| CLAUDE.md too large               | Move content to `@imports` or `.claude/rules/` files         |
| Instructions lost after `/compact`| CLAUDE.md survives compaction; if lost, it was conversation-only — add to CLAUDE.md |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, locations, imports, loading order, `.claude/rules/`, auto memory, `/memory` command, troubleshooting

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
