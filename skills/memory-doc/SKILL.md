---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- covering CLAUDE.md files (project/user/managed-policy scopes, placement hierarchy, @ imports, /init generation, effective instructions with size/structure/specificity, AGENTS.md compatibility, load order with directory tree walk and subdirectory lazy loading, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD, claudeMdExcludes for monorepos, HTML comment stripping), .claude/rules/ (topic-scoped markdown files, path-specific rules with paths frontmatter and glob patterns, recursive discovery in subdirectories, symlinks for shared rules, user-level rules at ~/.claude/rules/), auto memory (MEMORY.md entrypoint with 200-line/25KB cap, topic files read on demand, per-project storage at ~/.claude/projects/<project>/memory/, toggle with /memory or autoMemoryEnabled, custom directory with autoMemoryDirectory, git-repo-scoped sharing across worktrees, machine-local only), /memory command (list loaded files, toggle auto memory, open memory folder, open files in editor), managed CLAUDE.md deployment (macOS/Linux/Windows paths, MDM/Ansible distribution, cannot be excluded), organization-wide configuration (managed settings vs managed CLAUDE.md, permissions/sandbox/env in settings, style/compliance/behavior in CLAUDE.md), troubleshooting (instructions not followed with /memory debug and specificity and conflicts, unknown auto memory contents, CLAUDE.md too large with @ imports and rules splitting, instructions lost after /compact survive because CLAUDE.md reloads from disk), .claude directory structure (project-level CLAUDE.md, .mcp.json, .worktreeinclude, .claude/ with settings.json, settings.local.json, rules/, skills/, commands/, output-styles/, agents/, agent-memory/), and global ~/.claude/ directory (CLAUDE.md, settings.json, keybindings.json, projects/ auto memory, rules/, skills/, commands/, output-styles/, agents/). Load when discussing CLAUDE.md files, project instructions, auto memory, /memory command, .claude/rules/, path-specific rules, memory troubleshooting, organization-wide CLAUDE.md deployment, claudeMdExcludes, @ imports in CLAUDE.md, .claude directory layout, or any topic about how Claude Code remembers context across sessions.
user-invocable: false
---

# Memory and .claude Directory Documentation

This skill provides the complete official documentation for Claude Code memory systems (CLAUDE.md, auto memory, .claude/rules/) and the .claude directory structure.

## Quick Reference

### CLAUDE.md vs Auto Memory

| | CLAUDE.md files | Auto memory |
|:---|:---|:---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session (full file) | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, preferences |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users (cannot be excluded) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |

CLAUDE.md files above the working directory load in full at launch. CLAUDE.md files in subdirectories load on demand when Claude reads files there. Use `claudeMdExcludes` in settings to skip irrelevant files in monorepos.

### Writing Effective Instructions

| Aspect | Guidance |
|:-------|:---------|
| **Size** | Target under 200 lines per file |
| **Structure** | Use markdown headers and bullets |
| **Specificity** | "Use 2-space indentation" not "Format code properly" |
| **Consistency** | Review periodically to remove conflicting rules |
| **Imports** | Use `@path/to/file` to pull in external content (max depth: 5 hops) |

Run `/init` to auto-generate a starter CLAUDE.md. Set `CLAUDE_CODE_NEW_INIT=1` for the interactive multi-phase flow.

### CLAUDE.md Imports

Use `@path/to/file` syntax anywhere in CLAUDE.md. Relative paths resolve relative to the containing file. First encounter triggers an approval dialog.

```text
See @README for project overview and @package.json for npm commands.
@~/.claude/my-project-instructions.md
```

### AGENTS.md Compatibility

If your repo uses AGENTS.md for other agents, import it into CLAUDE.md:

```text
@AGENTS.md

## Claude Code
Use plan mode for changes under src/billing/.
```

### .claude/rules/ Directory

| Feature | Details |
|:--------|:--------|
| **Location** | `.claude/rules/*.md` (project) or `~/.claude/rules/*.md` (user) |
| **Discovery** | Recursive -- subdirectories like `rules/frontend/` work |
| **Unconditional rules** | No `paths:` frontmatter -- loaded at session start |
| **Path-specific rules** | `paths:` frontmatter with globs -- loaded when matching files enter context |
| **Symlinks** | Supported; circular symlinks handled gracefully |
| **Priority** | User-level rules load before project rules (project takes precedence) |

#### Path Glob Patterns

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under src/ |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

Multiple patterns and brace expansion supported: `"src/**/*.{ts,tsx}"`.

### Auto Memory

| Setting | Details |
|:--------|:--------|
| **Toggle** | `/memory` command, `autoMemoryEnabled` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| **Storage** | `~/.claude/projects/<project>/memory/` (keyed by git repo; all worktrees share one directory) |
| **Custom directory** | `autoMemoryDirectory` in user or local settings (not accepted from project settings) |
| **Entrypoint** | `MEMORY.md` -- first 200 lines or 25KB loaded at session start |
| **Topic files** | `debugging.md`, `api-conventions.md`, etc. -- read on demand, not at startup |
| **Requires** | Claude Code v2.1.59 or later |
| **Machine-local** | Not shared across machines or cloud environments |

### /memory Command

Lists all loaded CLAUDE.md and rules files, lets you toggle auto memory, provides a link to the auto memory folder, and opens files in your editor.

To make Claude remember something: say "always use pnpm, not npm" or "remember that API tests require local Redis." To add to CLAUDE.md instead, say "add this to CLAUDE.md" or edit via `/memory`.

### Managed CLAUDE.md vs Managed Settings

| Concern | Configure in |
|:--------|:-------------|
| Block specific tools/commands/file paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Environment variables and API routing | Managed settings: `env` |
| Authentication and org lock | Managed settings: `forceLoginMethod`, `forceLoginOrgUUID` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### .claude Directory Structure (Project)

```
your-project/
  CLAUDE.md                        # Project instructions (or .claude/CLAUDE.md)
  .mcp.json                        # Project-scoped MCP servers
  .worktreeinclude                  # Gitignored files to copy into worktrees
  .claude/
    settings.json                   # Permissions, hooks, configuration (committed)
    settings.local.json             # Personal overrides (gitignored)
    rules/                          # Topic-scoped instructions with optional path globs
    skills/                         # Reusable prompts invoked by /name
    commands/                       # Single-file prompts invoked by /name
    output-styles/                  # Project-scoped output styles
    agents/                         # Subagents with own context window
    agent-memory/                   # Subagent persistent memory (committed)
```

### ~/.claude Directory Structure (Global)

```
~/
  .claude.json                      # App state, UI preferences, personal MCP servers
  .claude/
    CLAUDE.md                       # Personal preferences for all projects
    settings.json                   # Default settings for all projects
    keybindings.json                # Custom keyboard shortcuts
    projects/<project>/memory/      # Auto memory per project
      MEMORY.md                     # Index loaded at session start
      debugging.md                  # Topic files read on demand
    rules/                          # User-level rules for all projects
    skills/                         # Personal skills for all projects
    commands/                       # Personal commands for all projects
    output-styles/                  # Personal output styles
    agents/                         # Personal subagents
```

### Troubleshooting

| Problem | Solution |
|:--------|:---------|
| Claude not following CLAUDE.md | Run `/memory` to verify files are loaded. Check location, make instructions specific, remove conflicts |
| Unknown auto memory contents | Run `/memory` and browse the auto memory folder. All files are editable plain markdown |
| CLAUDE.md too large | Move content to `@path` imports or `.claude/rules/` files. Target under 200 lines |
| Instructions lost after `/compact` | CLAUDE.md survives compaction (reloads from disk). If lost, the instruction was only in conversation -- add it to CLAUDE.md |
| Instructions not loading from --add-dir | Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |

Use the `InstructionsLoaded` hook to log exactly which instruction files load, when, and why.

### CLAUDE.md Load Behavior

- Walks up the directory tree from the working directory, loading CLAUDE.md at each level
- Subdirectory CLAUDE.md files load on demand when Claude reads files in those directories
- Block-level HTML comments (`<!-- ... -->`) are stripped before injection into context (preserved in code blocks)
- Additional directories via `--add-dir` do not load CLAUDE.md by default (enable with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`)

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude Remembers Your Project](references/claude-code-memory.md) -- CLAUDE.md files (scopes, placement, effective writing, @ imports, AGENTS.md compatibility, load order, directory tree walk, subdirectory lazy loading, --add-dir, claudeMdExcludes), .claude/rules/ (setup, path-specific rules with glob frontmatter, symlinks, user-level rules), auto memory (enable/disable, storage location with autoMemoryDirectory, MEMORY.md entrypoint with 200-line/25KB cap, topic files on demand, machine-local), /memory command, organization-wide CLAUDE.md deployment (managed policy paths, MDM distribution, managed settings vs managed CLAUDE.md), and troubleshooting (instructions not followed, unknown auto memory contents, CLAUDE.md too large, instructions lost after /compact)
- [Explore the .claude Directory](references/claude-code-claude-directory.md) -- Interactive reference for the .claude directory structure: project-level files (CLAUDE.md, .mcp.json, .worktreeinclude), .claude/ contents (settings.json, settings.local.json, rules/, skills/, commands/, output-styles/, agents/, agent-memory/), and global ~/.claude/ contents (CLAUDE.md, settings.json, keybindings.json, projects/ auto memory, rules/, skills/, commands/, output-styles/, agents/)

## Sources

- How Claude Remembers Your Project: https://code.claude.com/docs/en/memory.md
- Explore the .claude Directory: https://code.claude.com/docs/en/claude-directory.md
