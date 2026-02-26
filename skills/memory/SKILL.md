---
name: memory
description: Reference documentation for Claude Code memory management -- CLAUDE.md files, auto memory, memory hierarchy, project rules (.claude/rules/), modular rules with path-specific scoping, CLAUDE.local.md, /memory command, /init command, imports with @path syntax, organization-level managed policy, and memory best practices.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory management.

## Quick Reference

Claude Code has two kinds of persistent memory: **auto memory** (Claude writes for itself) and **CLAUDE.md files** (you write for Claude). Both load at session start.

### Memory Types (Priority Order)

| Type                   | Location                                                                                     | Purpose                                       | Shared with                     |
|:-----------------------|:---------------------------------------------------------------------------------------------|:----------------------------------------------|:--------------------------------|
| **Managed policy**     | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux: `/etc/claude-code/CLAUDE.md` | Organization-wide instructions from IT/DevOps | All org users                   |
| **Project memory**     | `./CLAUDE.md` or `./.claude/CLAUDE.md`                                                       | Team-shared project instructions              | Team via source control         |
| **Project rules**      | `./.claude/rules/*.md`                                                                       | Modular, topic-specific project instructions  | Team via source control         |
| **User memory**        | `~/.claude/CLAUDE.md`                                                                        | Personal preferences for all projects         | Just you (all projects)         |
| **Project local**      | `./CLAUDE.local.md`                                                                          | Personal project-specific preferences         | Just you (auto-gitignored)      |
| **Auto memory**        | `~/.claude/projects/<project>/memory/`                                                       | Claude's automatic notes and learnings        | Just you (per project)          |

More specific instructions take precedence over broader ones. CLAUDE.md files in parent directories load at launch; those in child directories load on demand.

### Auto Memory

Auto memory is enabled by default. Claude saves project patterns, debugging insights, architecture notes, and user preferences.

| Setting                                 | Effect                                      |
|:----------------------------------------|:--------------------------------------------|
| `autoMemoryEnabled: false` in user settings (`~/.claude/settings.json`) | Disable for all projects   |
| `autoMemoryEnabled: false` in project settings (`.claude/settings.json`) | Disable for one project   |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`     | Force off (overrides all other settings)    |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY=0`     | Force on (overrides all other settings)     |

Auto memory structure:

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Index file, first 200 lines loaded at startup
  debugging.md       # Topic files, loaded on demand
  api-conventions.md
  ...
```

Toggle auto memory or open files for editing with the `/memory` command.

### CLAUDE.md Imports

Use `@path/to/file` syntax to import additional files into any CLAUDE.md:

```
See @README for project overview.
@docs/git-instructions.md
@~/.claude/my-project-instructions.md
```

- Relative paths resolve relative to the importing file
- Absolute and home-directory (`~`) paths supported
- Recursive imports up to 5 levels deep
- Not evaluated inside code spans or code blocks
- First-time imports require user approval per project

### Project Rules (`.claude/rules/`)

Organize modular project instructions as separate markdown files:

```
.claude/rules/
  frontend/
    react.md
    styles.md
  backend/
    api.md
    database.md
  general.md
```

All `.md` files discovered recursively. Same priority as `.claude/CLAUDE.md`.

**Path-specific rules** use `paths` frontmatter to scope to matching files:

```yaml
---
paths:
  - "src/api/**/*.ts"
---
```

| Glob pattern           | Matches                                |
|:-----------------------|:---------------------------------------|
| `**/*.ts`              | All TypeScript files in any directory  |
| `src/**/*`             | All files under `src/`                 |
| `*.md`                 | Markdown files in project root         |
| `src/**/*.{ts,tsx}`    | Both `.ts` and `.tsx` under `src/`     |
| `{src,lib}/**/*.ts`    | `.ts` files under `src/` or `lib/`    |

Rules without `paths` apply unconditionally.

**User-level rules** at `~/.claude/rules/` apply to all projects (lower priority than project rules).

Symlinks in `.claude/rules/` are supported for sharing rules across projects.

### Useful Commands

| Command    | Description                                      |
|:-----------|:-------------------------------------------------|
| `/memory`  | Open memory files in editor; toggle auto memory  |
| `/init`    | Bootstrap a CLAUDE.md for the current project    |

### Additional Directories

Load memory from extra directories with `--add-dir`:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### Best Practices

- Be specific: "Use 2-space indentation" beats "Format code properly"
- Structure with bullet points under descriptive headings
- Review and update periodically as the project evolves
- Use `CLAUDE.local.md` for private per-project preferences
- Keep rules files focused on one topic each

## Full Documentation

For the complete official documentation, see the reference files:

- [Manage Claude's Memory](references/claude-code-memory.md) -- memory types hierarchy, auto memory, CLAUDE.md imports, project rules, path-specific rules, organization-level memory, /memory and /init commands, best practices

## Sources

- Manage Claude's Memory: https://code.claude.com/docs/en/memory.md
