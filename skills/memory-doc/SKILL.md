---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files (project, user, local, managed policy, imports, rules), auto memory (MEMORY.md, topic files, storage, limits), the .claude/ directory structure (settings, rules, skills, commands, agents, output styles, agent memory), file loading order, path-specific rules, claudeMdExcludes, /memory command, and troubleshooting. Covers all CLAUDE.md scopes and locations, @-import syntax, .claude/rules/ with paths frontmatter, auto memory toggle and storage settings (autoMemoryEnabled, autoMemoryDirectory), MEMORY.md 200-line/25KB cap, /init command, AGENTS.md compatibility, managed CLAUDE.md deployment, HTML comment stripping, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD, CLAUDE.local.md, symlinked rules, user-level rules, InstructionsLoaded hook for debugging, and the full .claude/ directory layout (settings.json, settings.local.json, rules/, skills/, commands/, agents/, agent-memory/, output-styles/). Load when discussing CLAUDE.md, memory, auto memory, MEMORY.md, .claude directory, rules, instructions, project memory, persistent context, /memory, /init, claudeMdExcludes, path-specific rules, or any memory-related topic for Claude Code.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code's memory systems -- CLAUDE.md files, auto memory, `.claude/rules/`, and the `.claude/` directory structure.

## Quick Reference

### Memory Systems Overview

| | CLAUDE.md files | Auto memory |
|:-----|:----------------|:------------|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, preferences |

### CLAUDE.md File Locations

| Scope | Location | Purpose | Shared with |
|:------|:---------|:--------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Organization-wide instructions | All users in org |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared project instructions | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you (all projects) |
| **Local** | `./CLAUDE.local.md` | Personal project-specific preferences (gitignored) | Just you (current project) |

### CLAUDE.md Loading Behavior

- Files walk up the directory tree from `cwd`, loading `CLAUDE.md` and `CLAUDE.local.md` at each level
- All files are concatenated, not overridden; `CLAUDE.local.md` appended after `CLAUDE.md` at each level
- Subdirectory CLAUDE.md files load on demand when Claude reads files in those directories
- HTML comments (`<!-- ... -->`) are stripped before injection (preserved in code blocks)
- Target under 200 lines per file for best adherence

### @-Import Syntax

Reference additional files with `@path/to/file` anywhere in CLAUDE.md:
- Relative paths resolve relative to the containing file
- Maximum depth: 5 hops of recursive imports
- First encounter shows an approval dialog for external imports
- Example: `@README`, `@docs/git-instructions.md`, `@~/.claude/my-project-instructions.md`

### `.claude/rules/` Directory

| Feature | Details |
|:--------|:--------|
| **Location** | `.claude/rules/*.md` (project) or `~/.claude/rules/*.md` (user) |
| **Discovery** | Recursive; subdirectories like `frontend/` work |
| **Unconditional rules** | No `paths:` frontmatter; loaded at session start |
| **Path-specific rules** | `paths:` frontmatter with globs; loaded when matching files enter context |
| **Symlinks** | Supported; circular links detected gracefully |
| **User-level rules** | `~/.claude/rules/` loaded before project rules (lower priority) |

### Path-Specific Rule Patterns

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |
| `src/**/*.{ts,tsx}` | Brace expansion for multiple extensions |

### Auto Memory

| Setting | Description |
|:--------|:-----------|
| **Toggle** | `/memory` command or `autoMemoryEnabled` in settings; env var `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| **Storage** | `~/.claude/projects/<project>/memory/` (all worktrees of same repo share one directory) |
| **Custom directory** | `autoMemoryDirectory` in user or local settings (not project settings) |
| **Entrypoint** | `MEMORY.md` -- first 200 lines or 25KB loaded at session start |
| **Topic files** | e.g. `debugging.md`, `api-conventions.md` -- read on demand, not at startup |
| **Requires** | Claude Code v2.1.59 or later |

### `.claude/` Directory Structure (Project)

```
your-project/
├── CLAUDE.md                    # Project instructions (committed)
├── CLAUDE.local.md              # Personal project preferences (gitignored)
├── .mcp.json                    # Project MCP servers (committed)
├── .worktreeinclude             # Gitignored files to copy into worktrees
└── .claude/
    ├── CLAUDE.md                # Alternative project instructions location
    ├── settings.json            # Permissions, hooks, config (committed)
    ├── settings.local.json      # Personal settings overrides (gitignored)
    ├── rules/                   # Topic-scoped instruction files
    │   ├── testing.md           # Can have paths: frontmatter
    │   └── api-design.md
    ├── skills/                  # Reusable prompts invoked by /name
    │   └── <name>/SKILL.md
    ├── commands/                # Single-file prompts (legacy; prefer skills)
    │   └── fix-issue.md
    ├── agents/                  # Subagents with own context window
    │   └── code-reviewer.md
    ├── agent-memory/            # Subagent memory (memory: project)
    │   └── <agent>/MEMORY.md
    └── output-styles/           # Custom system-prompt styles
```

### `~/` Global Directory Structure

```
~/
├── .claude.json                 # App state, UI prefs, personal MCP servers
└── .claude/
    ├── CLAUDE.md                # Personal preferences (all projects)
    ├── settings.json            # Default settings (all projects)
    ├── keybindings.json         # Custom keyboard shortcuts
    ├── rules/                   # User-level rules (all projects)
    ├── skills/                  # Personal skills (all projects)
    ├── commands/                # Personal commands (all projects)
    ├── agents/                  # Personal subagents (all projects)
    ├── agent-memory/            # Subagent memory (memory: user)
    ├── output-styles/           # Personal output styles
    └── projects/                # Auto memory per project
        └── <project>/memory/
            ├── MEMORY.md        # Index loaded at session start
            └── debugging.md     # Topic files read on demand
```

### Key Settings

| Setting | Scope | Purpose |
|:--------|:------|:--------|
| `autoMemoryEnabled` | Project settings | Toggle auto memory (default: `true`) |
| `autoMemoryDirectory` | User or local settings | Custom auto memory location |
| `claudeMdExcludes` | Any settings layer | Skip specific CLAUDE.md files by path/glob |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | Env var | Load CLAUDE.md from `--add-dir` directories |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Env var | Disable auto memory |

### `/memory` Command

- Lists all loaded CLAUDE.md, CLAUDE.local.md, and rules files
- Toggle auto memory on/off
- Link to open the auto memory folder
- Select any file to open in your editor

### `/init` Command

- Generates a starting CLAUDE.md by analyzing the codebase
- If CLAUDE.md exists, suggests improvements rather than overwriting
- Set `CLAUDE_CODE_NEW_INIT=1` for interactive multi-phase flow (CLAUDE.md, skills, hooks)

### AGENTS.md Compatibility

Import AGENTS.md into CLAUDE.md to share instructions with other coding agents:
```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

### Troubleshooting

| Problem | Solution |
|:--------|:--------|
| Claude not following CLAUDE.md | Run `/memory` to verify file is loaded; make instructions specific; check for conflicts |
| Don't know what auto memory saved | Run `/memory`, select auto memory folder to browse |
| CLAUDE.md too large | Move content to `@path` imports or `.claude/rules/` files; target under 200 lines |
| Instructions lost after `/compact` | CLAUDE.md survives compaction; conversation-only instructions do not |
| Subdirectory CLAUDE.md not loading | These load on demand when Claude reads files in that directory, not at launch |
| Monorepo picks up other teams' files | Use `claudeMdExcludes` in `settings.local.json` |
| Debug which files load | Use the `InstructionsLoaded` hook to log loaded instruction files |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude Remembers Your Project](references/claude-code-memory.md) -- CLAUDE.md files, auto memory, `.claude/rules/`, imports, loading order, `/memory` command, troubleshooting
- [Explore the .claude Directory](references/claude-code-claude-directory.md) -- Interactive directory explorer covering every file and folder in the project `.claude/` directory and `~/.claude/` global directory

## Sources

- How Claude Remembers Your Project: https://code.claude.com/docs/en/memory.md
- Explore the .claude Directory: https://code.claude.com/docs/en/claude-directory.md
