---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files and auto memory. Covers CLAUDE.md file locations and scopes (project ./CLAUDE.md or ./.claude/CLAUDE.md, user ~/.claude/CLAUDE.md, managed policy /etc/claude-code/CLAUDE.md), writing effective instructions (size under 200 lines, structure with markdown headers, specificity, consistency), importing additional files with @path syntax (relative paths, recursive imports up to 5 hops, external imports approval dialog), AGENTS.md interop, how CLAUDE.md files load (directory tree walk, subdirectory on-demand loading, HTML comment stripping, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), organizing rules with .claude/rules/ (path-specific rules with paths: frontmatter globs, unconditional rules, symlinks for sharing, user-level rules in ~/.claude/rules/), managing CLAUDE.md for large teams (managed policy deployment via MDM/Ansible, claudeMdExcludes setting for monorepos with glob patterns), auto memory (MEMORY.md entrypoint, topic files, ~/.claude/projects/<project>/memory/ storage, autoMemoryEnabled setting, CLAUDE_CODE_DISABLE_AUTO_MEMORY env var, autoMemoryDirectory setting, first 200 lines or 25KB loaded per session, subagent memory), /memory command (browse loaded files, toggle auto memory, open memory folder), troubleshooting (instructions not followed, checking with /memory, conflicting instructions, --append-system-prompt, InstructionsLoaded hook, CLAUDE.md too large, instructions lost after /compact), .claude directory structure (settings.json, settings.local.json, rules/, skills/, commands/, agents/, agent-memory/, output-styles/), and global ~/.claude/ directory (CLAUDE.md, settings.json, keybindings.json, projects/ auto memory, rules/, skills/, commands/, output-styles/). Load when discussing Claude Code memory, CLAUDE.md files, project instructions, auto memory, MEMORY.md, /memory command, .claude/rules/, path-specific rules, claudeMdExcludes, managed CLAUDE.md, @import syntax, instruction files, how Claude remembers, .claude directory, ~/.claude directory, autoMemoryEnabled, autoMemoryDirectory, InstructionsLoaded hook, rules frontmatter paths, user-level rules, or any memory and instruction-related topic for Claude Code.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code's memory systems -- CLAUDE.md instruction files and auto memory -- covering how Claude remembers your project across sessions, plus the .claude directory structure.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
|:--|:----------------|:------------|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree (git repo) |
| **Loaded into** | Every session (full file) | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, discovered preferences |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org (cannot be excluded) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |

Files in ancestor directories above the working directory load in full at launch. Files in subdirectories load on demand when Claude reads files there.

### Writing Effective Instructions

| Guideline | Detail |
|:----------|:-------|
| **Size** | Target under 200 lines per file; longer files reduce adherence |
| **Structure** | Use markdown headers and bullets to group related instructions |
| **Specificity** | Concrete and verifiable: "Use 2-space indentation" not "Format code properly" |
| **Consistency** | Avoid contradictions across files; review periodically |

### Import Syntax

Use `@path/to/file` in CLAUDE.md to import additional files:

- Relative paths resolve relative to the containing file, not the working directory
- Recursive imports supported, max depth of 5 hops
- Absolute paths and `~` home paths work: `@~/.claude/my-project-instructions.md`
- First encounter of external imports triggers an approval dialog
- HTML comments (`<!-- ... -->`) are stripped before injection (preserved in code blocks)

### .claude/rules/ Directory

| Feature | Detail |
|:--------|:-------|
| **Location** | `.claude/rules/*.md` (recursive discovery, subdirectories OK) |
| **User-level** | `~/.claude/rules/*.md` (applies to all projects, lower priority) |
| **Unconditional rules** | No `paths:` frontmatter -- loaded at session start like CLAUDE.md |
| **Path-specific rules** | `paths:` frontmatter with glob patterns -- loaded when matching files enter context |
| **Symlinks** | Supported for sharing rules across projects |

Path glob examples:

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |
| `src/**/*.{ts,tsx}` | Brace expansion for multiple extensions |

### Auto Memory

| Setting | Detail |
|:--------|:-------|
| **Toggle** | `/memory` command, or `autoMemoryEnabled: false` in project settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| **Storage** | `~/.claude/projects/<project>/memory/` (keyed by git repo; shared across worktrees) |
| **Custom directory** | `autoMemoryDirectory` in user or local settings (not accepted from project settings) |
| **Entrypoint** | `MEMORY.md` -- concise index loaded each session |
| **Load limit** | First 200 lines or 25KB of MEMORY.md, whichever comes first |
| **Topic files** | `debugging.md`, `api-conventions.md`, etc. -- read on demand, not at startup |
| **Requires** | Claude Code v2.1.59 or later |

### CLAUDE.md Loading Behavior

- Walks up directory tree from cwd, loading each CLAUDE.md found
- Subdirectory CLAUDE.md files load on demand when Claude reads files there
- `--add-dir` directories: set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to load their CLAUDE.md files
- `claudeMdExcludes` setting skips specific files by path or glob (useful in monorepos)
- Managed policy CLAUDE.md cannot be excluded
- `/init` generates a starting CLAUDE.md (set `CLAUDE_CODE_NEW_INIT=true` for interactive multi-phase flow)
- CLAUDE.md fully survives `/compact` -- re-read from disk after compaction

### Managed CLAUDE.md vs Managed Settings

| Concern | Configure in |
|:--------|:-------------|
| Block tools, commands, or file paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Environment variables, API routing | Managed settings: `env` |
| Auth method, org lock | Managed settings: `forceLoginMethod`, `forceLoginOrgUUID` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### Troubleshooting

| Problem | Solution |
|:--------|:---------|
| Claude ignores CLAUDE.md | Run `/memory` to verify file is loaded; check location scope; make instructions more specific; look for conflicts |
| Don't know what auto memory saved | Run `/memory` and browse auto memory folder; all plain markdown |
| CLAUDE.md too large | Move content to `@path` imports or `.claude/rules/` files; target under 200 lines |
| Instructions lost after `/compact` | CLAUDE.md survives compaction; if an instruction disappeared, it was conversation-only -- add it to CLAUDE.md |
| System-prompt-level instructions | Use `--append-system-prompt` (better for scripts/automation than interactive use) |
| Debug which files load | Use the `InstructionsLoaded` hook to log loaded instruction files |

### /memory Command

- Lists all CLAUDE.md and rules files loaded in current session
- Toggle auto memory on/off
- Link to open auto memory folder
- Select any file to open in editor

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md files, auto memory, .claude/rules/, /memory command, and troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) -- Interactive reference for all files and directories in project .claude/ and global ~/.claude/

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
