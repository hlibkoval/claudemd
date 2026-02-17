---
name: memory
description: Reference documentation for Claude Code memory — CLAUDE.md files, auto memory, project rules, imports, and the memory hierarchy. Use when configuring memory locations, writing CLAUDE.md files, organizing project rules, setting up auto memory, using imports, or understanding memory precedence.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for managing Claude Code's memory across sessions.

## Quick Reference

Claude Code has two kinds of persistent memory:

- **CLAUDE.md files** — markdown files you write and maintain with instructions, rules, and preferences.
- **Auto memory** — notes Claude writes for itself based on what it discovers during sessions.

Both load into context at the start of every session.

### Memory Hierarchy

| Type                   | Location                                                          | Scope                       | Shared with               |
|:-----------------------|:------------------------------------------------------------------|:----------------------------|:--------------------------|
| **Managed policy**     | `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS)       | Organization-wide           | All users in organization |
| **Project memory**     | `./CLAUDE.md` or `./.claude/CLAUDE.md`                            | Team-shared project         | Team via source control   |
| **Project rules**      | `./.claude/rules/*.md`                                            | Modular project instructions| Team via source control   |
| **User memory**        | `~/.claude/CLAUDE.md`                                             | Personal, all projects      | Just you                  |
| **Project local**      | `./CLAUDE.local.md`                                               | Personal, current project   | Just you (gitignored)     |
| **Auto memory**        | `~/.claude/projects/<project>/memory/`                            | Per-project auto notes      | Just you                  |

More specific instructions take precedence over broader ones.

### Memory Loading Behavior

| Source                       | When loaded                                          |
|:-----------------------------|:-----------------------------------------------------|
| CLAUDE.md in parent dirs     | At launch (full contents)                            |
| CLAUDE.md in child dirs      | On demand, when Claude reads files in that subtree   |
| Auto memory (MEMORY.md)      | At launch (first 200 lines only)                     |
| Auto memory topic files      | On demand, when Claude needs the information         |
| `.claude/rules/*.md`         | At launch (same priority as `.claude/CLAUDE.md`)     |

### CLAUDE.md Imports

CLAUDE.md files can import other files using `@path/to/file` syntax:

```markdown
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
- @~/.claude/my-project-instructions.md
```

- Relative paths resolve relative to the file containing the import
- Absolute paths and `~` home-directory paths are supported
- Imports can be recursive, max depth of 5 hops
- Imports inside code spans and code blocks are ignored
- First encounter triggers an approval dialog (one-time per project)

## Auto Memory

Claude automatically saves project patterns, debugging insights, architecture notes, and preferences.

### Directory Structure

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index loaded into every session (first 200 lines)
├── debugging.md       # Topic file (loaded on demand)
├── api-conventions.md # Topic file (loaded on demand)
└── ...
```

The `<project>` path derives from the git repo root. All subdirectories in the same repo share one auto memory directory. Git worktrees get separate directories.

### Control Auto Memory

```bash
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1  # Force off
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=0  # Force on
```

To save something specific, tell Claude directly: "remember that we use pnpm, not npm".

Use `/memory` to open auto memory files in your editor.

## Project Rules (`.claude/rules/`)

Organize instructions into modular files instead of one large CLAUDE.md.

### Path-Specific Rules

Scope rules to specific files using YAML frontmatter:

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Rules
- All endpoints must include input validation
```

Rules without `paths` load unconditionally.

### Glob Patterns

| Pattern                | Matches                                |
|:-----------------------|:---------------------------------------|
| `**/*.ts`              | All TypeScript files in any directory  |
| `src/**/*`             | All files under `src/`                 |
| `*.md`                 | Markdown files in project root         |
| `src/**/*.{ts,tsx}`    | Both `.ts` and `.tsx` files under src  |
| `{src,lib}/**/*.ts`    | `.ts` files under `src/` or `lib/`     |

### Rules Organization

- Subdirectories are supported (discovered recursively)
- Symlinks are supported (shared rules across projects)
- User-level rules go in `~/.claude/rules/` (lower priority than project rules)

## Additional Directories

Load memory from directories outside your working directory:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### Key Commands

| Command    | Purpose                                      |
|:-----------|:---------------------------------------------|
| `/init`    | Bootstrap a CLAUDE.md for the current project |
| `/memory`  | Open memory files in your system editor       |

## Best Practices

- **Be specific**: "Use 2-space indentation" over "Format code properly"
- **Use structure**: Bullet points grouped under descriptive markdown headings
- **Review periodically**: Update memories as the project evolves
- **Keep rules focused**: One topic per file in `.claude/rules/`
- **Use descriptive filenames**: Filename should indicate what the rules cover
- **Use conditional rules sparingly**: Only add `paths` when rules truly apply to specific file types

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Memory](references/claude-code-memory.md) -- memory hierarchy, auto memory, CLAUDE.md imports, project rules, and organization-level memory management

## Sources

- Claude Code Memory: https://code.claude.com/docs/en/memory.md
