---
name: memory-doc
description: Complete documentation for Claude Code memory -- CLAUDE.md files (project/user/managed-policy scopes, directory hierarchy loading, effective instruction writing, size/structure/specificity guidelines, @path imports with recursive resolution, subdirectory lazy loading, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), .claude/rules/ (path-specific rules with glob patterns, user-level rules, symlinks for shared rules), auto memory (MEMORY.md entrypoint, topic files, 200-line loading limit, per-project storage at ~/.claude/projects/, autoMemoryEnabled toggle, autoMemoryDirectory setting, subagent auto memory), /memory command (browse loaded files, toggle auto memory, open memory folder), organization-wide managed CLAUDE.md (macOS/Linux/Windows paths, MDM deployment), claudeMdExcludes (glob patterns for monorepos, settings layers), /init for generating starter CLAUDE.md, troubleshooting (instructions not followed, auto memory audit, large CLAUDE.md, /compact behavior). Load when discussing CLAUDE.md files, memory, auto memory, project instructions, user instructions, managed policy instructions, .claude/rules/, path-specific rules, /memory command, /init command, claudeMdExcludes, @path imports, instruction loading, instruction scoping, memory troubleshooting, MEMORY.md, autoMemoryEnabled, autoMemoryDirectory, or how Claude remembers project context across sessions.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers project context across sessions -- CLAUDE.md files, .claude/rules/, and auto memory.

## Quick Reference

Two mechanisms carry knowledge across Claude Code sessions:

| Mechanism | Who writes it | What it contains | Scope | Loaded into every session |
|:----------|:-------------|:-----------------|:------|:--------------------------|
| **CLAUDE.md** | You | Instructions and rules | Project, user, or org | Yes (full file) |
| **Auto memory** | Claude | Learnings and patterns | Per working tree | Yes (first 200 lines of MEMORY.md) |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team (via source control) |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |

More specific locations take precedence over broader ones. Files in the directory hierarchy above the working directory load in full at launch. CLAUDE.md files in subdirectories load on demand when Claude reads files in those directories.

### Writing Effective Instructions

- **Size**: target under 200 lines per file; split with imports or rules if growing large
- **Structure**: use markdown headers and bullets to group related instructions
- **Specificity**: write concrete, verifiable instructions (e.g., "Use 2-space indentation" not "Format code properly")
- **Consistency**: review periodically for conflicting instructions across files

Run `/init` to generate a starter CLAUDE.md. If one already exists, `/init` suggests improvements.

### @path Imports

CLAUDE.md files can import additional files using `@path/to/import` syntax. Imported files expand into context at launch.

- Both relative and absolute paths are allowed
- Relative paths resolve relative to the file containing the import
- Recursive imports supported (max depth: five hops)
- First encounter with external imports shows an approval dialog

### .claude/rules/ Directory

Organize instructions into modular per-topic files. Files without `paths` frontmatter load at launch. Path-scoped rules load only when Claude works with matching files.

**Path-specific rules** use YAML frontmatter:

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
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

Brace expansion supported: `"src/**/*.{ts,tsx}"`.

**User-level rules**: `~/.claude/rules/` applies to every project. Loaded before project rules (project rules take higher priority).

**Symlinks**: supported in `.claude/rules/` for sharing rules across projects. Circular symlinks detected and handled gracefully.

### Auto Memory

Claude saves notes across sessions: build commands, debugging insights, architecture notes, code style preferences. Requires Claude Code v2.1.59+.

**Storage**: `~/.claude/projects/<project>/memory/`

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Concise index, loaded into every session (first 200 lines)
  debugging.md       # Detailed topic notes (loaded on demand)
  api-conventions.md # More topic notes
```

The `<project>` path derives from the git repository -- all worktrees and subdirectories within the same repo share one auto memory directory.

**Toggle auto memory:**

| Method | How |
|:-------|:----|
| In session | `/memory` toggle |
| Settings | `"autoMemoryEnabled": false` in project settings |
| Environment | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |

**Custom storage location**: set `autoMemoryDirectory` in user or local settings (not accepted from project settings to prevent redirection to sensitive paths).

**Loading behavior**: first 200 lines of MEMORY.md loaded at session start. Content beyond line 200 is not loaded. Topic files are read on demand. CLAUDE.md files load in full regardless of length.

Subagents can maintain their own auto memory (see subagent configuration).

### /memory Command

Lists all CLAUDE.md and rules files loaded in the current session. Lets you toggle auto memory, open the auto memory folder, and select any file to open in your editor.

When you ask Claude to "remember" something, it saves to auto memory. To add instructions to CLAUDE.md instead, ask explicitly or edit via `/memory`.

### claudeMdExcludes

Skip irrelevant CLAUDE.md files in large monorepos. Add to `.claude/settings.local.json`:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match against absolute file paths using glob syntax. Configurable at any settings layer (user, project, local, managed policy). Arrays merge across layers. Managed policy CLAUDE.md files cannot be excluded.

### Loading from Additional Directories

The `--add-dir` flag gives Claude access to additional directories. CLAUDE.md files from these directories are not loaded by default. Enable with:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Claude not following CLAUDE.md | Run `/memory` to verify files are loaded; check file location; make instructions more specific; look for conflicting instructions |
| Unknown auto memory contents | Run `/memory` and browse the auto memory folder; all files are plain editable markdown |
| CLAUDE.md too large | Move detailed content to `@path` imports or `.claude/rules/` files; target under 200 lines |
| Instructions lost after `/compact` | CLAUDE.md survives compaction (re-read from disk). Conversation-only instructions do not -- add them to CLAUDE.md |
| Debug instruction loading | Use the `InstructionsLoaded` hook to log which files load, when, and why |
| System prompt-level instructions | Use `--append-system-prompt` (must pass every invocation; suited for scripts/automation) |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md files (scopes, locations, precedence, directory hierarchy loading, subdirectory lazy loading), writing effective instructions (size, structure, specificity, consistency), @path imports (relative/absolute, recursive, approval dialog), .claude/rules/ (setup, path-specific rules with glob patterns, symlinks, user-level rules), --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD, managing CLAUDE.md for large teams (organization-wide managed policy deployment, claudeMdExcludes), auto memory (enable/disable, storage location, autoMemoryDirectory, MEMORY.md index, topic files, 200-line loading limit, audit and edit), /memory command, /init for starter generation, troubleshooting (instructions not followed, auto memory audit, large files, /compact behavior)

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
