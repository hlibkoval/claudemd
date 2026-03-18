---
name: memory-doc
description: Complete documentation for Claude Code memory — CLAUDE.md files (project, user, managed policy locations, load order, imports with @path syntax, writing effective instructions, size/structure/specificity guidance), .claude/rules/ (path-specific rules with glob patterns, user-level rules, symlinks), auto memory (enable/disable, storage location, MEMORY.md entrypoint, topic files, 200-line limit, how it works), /memory command, claudeMdExcludes for monorepos, organization-wide deployment, troubleshooting (instructions not followed, too large, lost after /compact). Load when discussing CLAUDE.md files, memory, auto memory, project instructions, .claude/rules/, path-specific rules, /memory command, remembering preferences, persistent instructions, claudeMdExcludes, organization-wide CLAUDE.md, managed policy CLAUDE.md, autoMemoryEnabled, autoMemoryDirectory, @imports in CLAUDE.md, or how Claude remembers project context.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers project context via CLAUDE.md files and auto memory.

## Quick Reference

Claude Code has two complementary memory systems that carry knowledge across sessions:

| | CLAUDE.md files | Auto memory |
|:--|:--|:--|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session (in full) | Every session (first 200 lines of MEMORY.md) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, preferences |

### CLAUDE.md File Locations

| Scope | Location | Purpose | Shared with |
|:------|:---------|:--------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Organization-wide instructions managed by IT/DevOps | All users in organization |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared instructions | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you |

More specific locations take precedence over broader ones. Files in the directory hierarchy above the working directory load in full at launch. Files in subdirectories load on demand when Claude reads files in those directories.

Run `/init` to generate a starting CLAUDE.md automatically. Set `CLAUDE_CODE_NEW_INIT=true` for an interactive multi-phase flow.

### Writing Effective Instructions

- **Size**: target under 200 lines per file; longer files consume more context and reduce adherence
- **Structure**: use markdown headers and bullets to group related instructions
- **Specificity**: write concrete, verifiable instructions (e.g., "Use 2-space indentation" not "Format code properly")
- **Consistency**: remove outdated or conflicting instructions; contradictions lead to arbitrary choices

### Importing Files

CLAUDE.md files can import additional files using `@path/to/import` syntax. Both relative and absolute paths work. Relative paths resolve from the importing file, not the working directory. Maximum import depth: five hops.

```text
See @README for project overview and @package.json for available npm commands.
@~/.claude/my-project-instructions.md
```

External imports require an approval dialog on first encounter.

### Load from Additional Directories

The `--add-dir` flag gives Claude access to additional directories. To also load their CLAUDE.md files:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### .claude/rules/ Directory

For larger projects, organize instructions into modular files under `.claude/rules/`. Each `.md` file covers one topic. Rules without `paths` frontmatter load at launch. Path-scoped rules load only when Claude works with matching files.

#### Path-Specific Rules

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Development Rules
- All API endpoints must include input validation
```

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

Multiple patterns and brace expansion (e.g., `"src/**/*.{ts,tsx}"`) are supported.

#### User-Level Rules

Personal rules in `~/.claude/rules/` apply to every project. User-level rules load before project rules (project rules have higher priority).

#### Symlinks

The `.claude/rules/` directory supports symlinks for sharing rules across projects. Circular symlinks are detected and handled gracefully.

### Excluding CLAUDE.md Files

In monorepos, use `claudeMdExcludes` to skip irrelevant CLAUDE.md files:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Configurable at any settings layer (user, project, local, managed policy). Arrays merge across layers. Managed policy CLAUDE.md cannot be excluded.

### Organization-Wide Deployment

| Concern | Configure in |
|:--------|:-------------|
| Block specific tools, commands, or file paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

Settings rules are enforced by the client. CLAUDE.md instructions shape behavior but are not a hard enforcement layer.

### Auto Memory

Auto memory lets Claude accumulate knowledge across sessions. Claude saves notes for itself: build commands, debugging insights, architecture notes, code style preferences. Requires Claude Code v2.1.59+.

#### Enable/Disable

On by default. Toggle via `/memory` or settings:

```json
{
  "autoMemoryEnabled": false
}
```

Or set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

#### Storage

Each project's memory lives at `~/.claude/projects/<project>/memory/`. The `<project>` path derives from the git repository (all worktrees share one directory). Outside git, uses the project root.

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Concise index, loaded every session
  debugging.md       # Detailed notes on debugging patterns
  api-conventions.md # API design decisions
```

Custom location via `autoMemoryDirectory` (accepted in policy, local, and user settings; not from project settings):

```json
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

#### How It Works

- First 200 lines of `MEMORY.md` are loaded at session start (content beyond line 200 is not loaded)
- This limit applies only to MEMORY.md; CLAUDE.md files load in full regardless of length
- Topic files are read on demand, not at startup
- Claude keeps `MEMORY.md` concise by moving detailed notes into topic files

Subagents can also maintain their own auto memory (see subagent configuration).

### /memory Command

Lists all CLAUDE.md and rules files loaded in the current session. Lets you toggle auto memory and open the memory folder. Select any file to open it in your editor.

When you ask Claude to remember something (e.g., "always use pnpm, not npm"), Claude saves it to auto memory. To add to CLAUDE.md instead, ask explicitly or edit via `/memory`.

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Claude not following CLAUDE.md | Run `/memory` to verify files are loaded; check location is correct; make instructions more specific; look for conflicting instructions |
| Don't know what auto memory saved | Run `/memory` and browse the auto memory folder; all files are plain markdown |
| CLAUDE.md too large | Target under 200 lines; use `@path` imports or `.claude/rules/` to split |
| Instructions lost after `/compact` | CLAUDE.md survives compaction (re-read from disk). If lost, instruction was given in conversation only -- add it to CLAUDE.md |

Use the `InstructionsLoaded` hook to log exactly which instruction files are loaded, when they load, and why.

For system prompt level instructions, use `--append-system-prompt` (must be passed every invocation; suited to scripts/automation).

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md files (locations, scoping, load order, writing effective instructions, @path imports, additional directories), .claude/rules/ (setup, path-specific rules with glob patterns, symlinks, user-level rules), managing CLAUDE.md for large teams (organization-wide deployment, claudeMdExcludes), auto memory (enable/disable, storage location, MEMORY.md entrypoint, topic files, 200-line limit, how it works, auditing), /memory command, troubleshooting (not following instructions, unknown auto memory content, too large, lost after /compact)

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
