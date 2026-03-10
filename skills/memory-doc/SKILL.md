---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files (project, user, managed policy locations, directory hierarchy loading, subdirectory lazy loading, @path imports, /init generation), .claude/rules/ (path-specific rules with glob patterns, user-level rules, symlinks), auto memory (MEMORY.md entrypoint, topic files, 200-line limit, per-project storage, enable/disable, audit/edit), claudeMdExcludes for monorepos, /memory command, effective instruction writing (size, structure, specificity), additional directories with --add-dir, troubleshooting (adherence, compaction survival, InstructionsLoaded hook). Load when discussing CLAUDE.md setup, memory configuration, project instructions, .claude/rules, auto memory, /memory command, or how Claude persists knowledge across sessions.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers project context across sessions.

## Quick Reference

Claude Code has two complementary memory systems loaded at the start of every conversation:

| | CLAUDE.md files | Auto memory |
|:-|:----------------|:------------|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session (full file) | Every session (first 200 lines of MEMORY.md) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, discovered preferences |

### CLAUDE.md File Locations

| Scope | Location | Purpose | Shared with |
|:------|:---------|:--------|:------------|
| Managed policy | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Organization-wide instructions (IT/DevOps managed) | All users in org |
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared project instructions | Team via source control |
| User | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you |

Loading behavior:
- Files in the directory hierarchy **above** the working directory are loaded in full at launch.
- Files in **subdirectories** load on demand when Claude reads files in those directories.
- Use `--add-dir` with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to load CLAUDE.md from additional directories.

### Writing Effective Instructions

| Aspect | Guideline |
|:-------|:----------|
| Size | Target under 200 lines per file; longer files reduce adherence |
| Structure | Use markdown headers and bullets to group related instructions |
| Specificity | Concrete and verifiable: "Use 2-space indentation" not "Format code properly" |
| Consistency | Remove conflicting instructions across files; use `claudeMdExcludes` for monorepos |

### @path Imports

CLAUDE.md files can import additional files using `@path/to/import` syntax. Imported files expand at launch.

- Relative paths resolve relative to the file containing the import (not the working directory).
- Recursive imports supported up to 5 hops deep.
- Personal imports: reference `@~/.claude/my-project-instructions.md` from a shared CLAUDE.md.
- First encounter with external imports shows an approval dialog.

### .claude/rules/ Directory

Organize instructions into modular files under `.claude/rules/`. Each `.md` file covers one topic.

**Path-specific rules** use YAML frontmatter to scope to matching files:

```yaml
---
paths:
  - "src/api/**/*.ts"
---
```

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root only |
| `src/components/*.tsx` | React components in a specific directory |

Multiple patterns and brace expansion (`*.{ts,tsx}`) are supported.

Rules without a `paths` field load unconditionally at launch. Path-scoped rules trigger when Claude reads matching files.

**User-level rules** in `~/.claude/rules/` apply to every project. Project rules take higher priority.

**Symlinks** are supported for sharing rules across projects.

### Auto Memory

Auto memory lets Claude accumulate knowledge across sessions without manual effort.

| Setting | Detail |
|:--------|:-------|
| Toggle | `/memory` command or `autoMemoryEnabled: false` in project settings |
| Disable via env | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| Storage | `~/.claude/projects/<project>/memory/` |
| Entrypoint | `MEMORY.md` (first 200 lines loaded each session) |
| Topic files | `debugging.md`, `api-conventions.md`, etc. (read on demand, not at startup) |
| Scope | Machine-local; all worktrees/subdirectories in same git repo share one directory |

### /memory Command

Lists all loaded CLAUDE.md and rules files, lets you toggle auto memory, and opens memory files in your editor. When you tell Claude to "remember" something, it saves to auto memory. To add to CLAUDE.md instead, ask explicitly or edit via `/memory`.

### /init Command

Generates a starting CLAUDE.md by analyzing your codebase (build commands, test instructions, conventions). If a CLAUDE.md already exists, `/init` suggests improvements rather than overwriting.

### claudeMdExcludes

Skip irrelevant CLAUDE.md files in monorepos. Set in `.claude/settings.local.json`:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match against absolute file paths using glob syntax. Configurable at any settings layer; arrays merge across layers. Managed policy CLAUDE.md files cannot be excluded.

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Claude not following CLAUDE.md | Run `/memory` to verify files are loaded; make instructions more specific; check for conflicting instructions |
| Unknown auto memory contents | Run `/memory`, select auto memory folder; all files are plain editable markdown |
| CLAUDE.md too large | Move details into `@path` imports or `.claude/rules/` files |
| Instructions lost after `/compact` | CLAUDE.md survives compaction (re-read from disk). Conversation-only instructions do not. Add them to CLAUDE.md. |
| Debug which files load | Use the `InstructionsLoaded` hook to log loaded instruction files |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md files (locations, loading, imports, writing guidelines), .claude/rules/ (path-specific rules, user-level rules, symlinks), auto memory (storage, MEMORY.md, topic files, enable/disable), /memory command, claudeMdExcludes, organization-wide deployment, troubleshooting

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
