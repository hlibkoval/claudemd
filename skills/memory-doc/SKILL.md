---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files (project, user, managed policy locations, directory hierarchy loading, lazy-loading from subdirectories), writing effective instructions (size, structure, specificity, consistency), `@path` imports (relative/absolute, recursive up to 5 hops), `.claude/rules/` (path-specific rules with `paths` frontmatter, glob patterns, symlinks, user-level rules), `claudeMdExcludes` for monorepos, organization-wide managed policy CLAUDE.md, auto memory (MEMORY.md entrypoint, topic files, 200-line load limit, `autoMemoryEnabled`, `autoMemoryDirectory`, storage location, `/memory` command), `--add-dir` with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD`, troubleshooting (instructions not followed, too-large files, lost after /compact). Load when discussing CLAUDE.md files, memory, persistent instructions, project rules, `.claude/rules/`, auto memory, `/memory`, `@` imports, `claudeMdExcludes`, or how Claude remembers project context.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers project context across sessions, covering CLAUDE.md files, `.claude/rules/`, and auto memory.

## Quick Reference

Claude Code has two complementary memory systems, both loaded at the start of every conversation:

| | CLAUDE.md files | Auto memory |
|:---|:---|:---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, preferences |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |

More specific locations take precedence over broader ones. Files above the working directory load in full at launch. Files in subdirectories load on demand when Claude reads files in those directories.

### Writing Effective Instructions

- **Size:** target under 200 lines per file; longer files reduce adherence
- **Structure:** use markdown headers and bullets to group related instructions
- **Specificity:** concrete and verifiable ("Use 2-space indentation" not "Format code properly")
- **Consistency:** avoid conflicting instructions across files; review periodically

Run `/init` to generate a starting CLAUDE.md automatically.

### `@path` Imports

CLAUDE.md files can import additional files using `@path/to/import` syntax. Both relative and absolute paths are supported. Relative paths resolve relative to the file containing the import. Imports can be recursive up to 5 hops deep. First-time external imports require approval.

### `.claude/rules/` Directory

Organize instructions into modular files. Each `.md` file covers one topic. Files are discovered recursively (supports subdirectories).

#### Path-Specific Rules

Scope rules to file patterns using `paths` frontmatter:

```yaml
---
paths:
  - "src/api/**/*.ts"
---
```

Rules without `paths` load unconditionally. Path-scoped rules trigger when Claude reads matching files.

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

Multiple patterns and brace expansion (`*.{ts,tsx}`) are supported.

#### Symlinks and User-Level Rules

- `.claude/rules/` supports symlinks for sharing rules across projects
- Personal rules in `~/.claude/rules/` apply to every project (loaded before project rules)

### Excluding CLAUDE.md Files

In monorepos, use `claudeMdExcludes` in `.claude/settings.local.json` to skip irrelevant files:

```json
{
  "claudeMdExcludes": ["**/monorepo/CLAUDE.md", "/home/user/monorepo/other-team/.claude/rules/**"]
}
```

Patterns match against absolute paths using glob syntax. Configurable at any settings layer; arrays merge. Managed policy CLAUDE.md cannot be excluded.

### Loading from Additional Directories

Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` with `--add-dir` to also load CLAUDE.md, `.claude/CLAUDE.md`, and `.claude/rules/*.md` from those directories.

### Auto Memory

Claude saves notes for itself across sessions: build commands, debugging insights, architecture notes, preferences. Requires v2.1.59+.

#### Storage

Each project gets its own directory at `~/.claude/projects/<project>/memory/`. All worktrees and subdirectories within the same git repo share one directory.

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Index file, first 200 lines loaded every session
  debugging.md       # Topic files loaded on demand
  api-conventions.md
```

Override with `autoMemoryDirectory` in user or local settings (not accepted from project settings).

#### Configuration

| Method | Details |
|:-------|:--------|
| Toggle in session | `/memory` command |
| Settings | `"autoMemoryEnabled": false` |
| Environment | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |

#### How It Works

- First 200 lines of `MEMORY.md` loaded at session start (content beyond line 200 is not loaded)
- Topic files are read on demand, not at startup
- CLAUDE.md files are loaded in full regardless of length (the 200-line limit applies only to MEMORY.md)
- `/memory` lists all loaded CLAUDE.md and rules files, provides toggle, and links to open memory folder

Subagents can also maintain their own auto memory (see subagent configuration).

### Troubleshooting

| Problem | Solution |
|:--------|:---------|
| Claude not following CLAUDE.md | Run `/memory` to verify file is loaded; make instructions more specific; check for conflicts |
| Unknown auto memory contents | Run `/memory`, select auto memory folder to browse plain markdown files |
| CLAUDE.md too large | Move detail into `@path` imports or `.claude/rules/` files |
| Instructions lost after `/compact` | CLAUDE.md survives compaction (re-read from disk); if lost, the instruction was only in conversation -- add it to CLAUDE.md |

Use the `InstructionsLoaded` hook to log exactly which instruction files are loaded, when, and why.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md file locations and loading order, writing effective instructions, `@path` imports, `.claude/rules/` with path-specific rules (glob patterns, symlinks), user-level rules, managed policy deployment, `claudeMdExcludes`, `--add-dir` with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD, auto memory (storage, MEMORY.md, topic files, 200-line limit, configuration), `/memory` command, troubleshooting

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
