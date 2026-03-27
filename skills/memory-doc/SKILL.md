---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files, auto memory, .claude/rules/, and the /memory command. Covers CLAUDE.md file locations and scoping (project, user, managed policy), writing effective instructions (size, structure, specificity, consistency), @path imports and recursive resolution, AGENTS.md integration, CLAUDE.md load order (directory tree walk, subdirectory lazy loading, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), .claude/rules/ directory (path-specific rules with paths: frontmatter and glob patterns, symlinks, user-level rules), claudeMdExcludes for monorepos, managed policy CLAUDE.md deployment (macOS/Linux/Windows paths, MDM/Group Policy/Ansible), /init command (CLAUDE_CODE_NEW_INIT interactive flow), auto memory (MEMORY.md entrypoint, topic files, ~/.claude/projects/<project>/memory/, autoMemoryEnabled, autoMemoryDirectory, 200-line/25KB loading limit, /memory command), subagent memory scopes (project/local/user), HTML comment stripping, InstructionsLoaded hook for debugging, /compact CLAUDE.md re-injection, and the .claude directory structure (CLAUDE.md, settings.json, settings.local.json, rules/, skills/, commands/, agents/, agent-memory/, output-styles/, keybindings.json, ~/.claude.json). Also covers the complete .claude directory explorer with every file and folder that Claude Code reads: project-level (.claude/CLAUDE.md, .mcp.json, settings.json, settings.local.json, rules/, skills/, commands/, output-styles/, agents/, agent-memory/) and global-level (~/.claude.json, ~/.claude/CLAUDE.md, ~/.claude/settings.json, ~/.claude/keybindings.json, ~/.claude/projects/, ~/.claude/rules/, ~/.claude/skills/, ~/.claude/commands/, ~/.claude/output-styles/, ~/.claude/agents/, ~/.claude/agent-memory/). Load when discussing CLAUDE.md, memory, auto memory, rules, .claude/rules/, instructions, /memory, /init, claudeMdExcludes, memory files, MEMORY.md, project instructions, user instructions, managed policy CLAUDE.md, @imports, path-specific rules, the .claude directory, .claude folder structure, settings.json vs settings.local.json, where Claude reads configuration, project vs global config, keybindings.json, output styles, agent memory, or any topic about how Claude Code remembers project context.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code's memory systems and the `.claude` directory structure.

## Quick Reference

### Memory Systems Overview

Claude Code has two complementary memory systems, both loaded at the start of every conversation:

| | CLAUDE.md files | Auto memory |
|:---|:---|:---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:---|:---|:---|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |

More specific locations take precedence over broader ones. CLAUDE.md files above the working directory load in full at launch. CLAUDE.md files in subdirectories load on demand when Claude reads files there.

### Writing Effective Instructions

- **Size**: target under 200 lines per CLAUDE.md file
- **Structure**: use markdown headers and bullets to group related instructions
- **Specificity**: write concrete, verifiable instructions (e.g., "Use 2-space indentation" not "Format code properly")
- **Consistency**: review periodically to remove outdated or conflicting instructions

### @path Imports

CLAUDE.md files can import additional files using `@path/to/import` syntax. Both relative and absolute paths are allowed. Relative paths resolve relative to the containing file. Imports can recurse up to five hops deep.

```text
See @README for project overview and @package.json for available npm commands.

# Individual Preferences
- @~/.claude/my-project-instructions.md
```

External imports require user approval on first encounter.

### AGENTS.md Integration

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. Import it if your repo uses AGENTS.md for other tools:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

### CLAUDE.md Load Order

1. Walk up the directory tree from cwd, loading each CLAUDE.md found
2. Subdirectory CLAUDE.md files load on demand when Claude reads files there
3. `--add-dir` directories do not load CLAUDE.md by default; set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to include them
4. HTML comments (`<!-- ... -->`) are stripped before injection into context
5. CLAUDE.md fully survives `/compact` -- it is re-read from disk after compaction

### .claude/rules/ Directory

Organize instructions into modular markdown files. Each file covers one topic.

| Rule type | When loaded |
|:---|:---|
| No `paths:` frontmatter | At session start (like CLAUDE.md) |
| With `paths:` frontmatter | When Claude reads a matching file |

**Path-specific rules** use YAML frontmatter with glob patterns:

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Development Rules
- All API endpoints must include input validation
```

| Pattern | Matches |
|:---|:---|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

Multiple patterns and brace expansion (`*.{ts,tsx}`) are supported. Symlinks are followed. User-level rules live in `~/.claude/rules/` and load before project rules.

### claudeMdExcludes

Skip irrelevant CLAUDE.md files in monorepos via settings:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match against absolute file paths using glob syntax. Configurable at any settings layer. Managed policy CLAUDE.md files cannot be excluded.

### /init Command

Run `/init` to generate a starting CLAUDE.md automatically. If one exists, `/init` suggests improvements. Set `CLAUDE_CODE_NEW_INIT=true` for an interactive multi-phase flow that asks which artifacts to set up (CLAUDE.md, skills, hooks), explores the codebase with a subagent, and presents a reviewable proposal.

### Auto Memory

Claude saves notes for itself as it works: build commands, debugging insights, architecture notes, code style preferences.

**Storage**: `~/.claude/projects/<project>/memory/` (derived from git repo path; all worktrees share one directory)

```text
~/.claude/projects/<project>/memory/
  MEMORY.md          # Index, loaded every session
  debugging.md       # Topic file, read on demand
  api-conventions.md # Topic file, read on demand
```

**Loading**: first 200 lines of MEMORY.md (or 25KB, whichever first) load at session start. Topic files load on demand only.

**Configuration**:

| Setting / Variable | Purpose |
|:---|:---|
| `autoMemoryEnabled` | Toggle auto memory (default: on) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` | Disable via environment variable |
| `autoMemoryDirectory` | Custom storage location (user/local/policy settings only) |
| `/memory` command | Browse, toggle, and edit memory files |

### Subagent Memory Scopes

| Frontmatter value | Storage location | Shared |
|:---|:---|:---|
| `memory: project` | `.claude/agent-memory/<agent>/` | With team (committed) |
| `memory: local` | `.claude/agent-memory-local/<agent>/` | Not shared (gitignored) |
| `memory: user` | `~/.claude/agent-memory/<agent>/` | Across your projects |

### Managed Policy vs Managed Settings

| Concern | Configure in |
|:---|:---|
| Block specific tools, commands, or file paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Environment variables, API provider routing | Managed settings: `env` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### The .claude Directory Structure

**Project-level** (`your-project/`):

| Path | Purpose | Shared |
|:---|:---|:---|
| `CLAUDE.md` | Project instructions | Committed |
| `.mcp.json` | Project-scoped MCP servers | Committed |
| `.claude/CLAUDE.md` | Alternative project instructions location | Committed |
| `.claude/settings.json` | Permissions, hooks, model, env vars | Committed |
| `.claude/settings.local.json` | Personal settings overrides | Gitignored |
| `.claude/rules/*.md` | Topic-scoped instructions | Committed |
| `.claude/skills/<name>/SKILL.md` | Reusable prompts invoked by name | Committed |
| `.claude/commands/<name>.md` | Single-file prompts (legacy, prefer skills) | Committed |
| `.claude/output-styles/*.md` | Project-scoped output styles | Committed |
| `.claude/agents/<name>.md` | Subagent definitions | Committed |
| `.claude/agent-memory/<agent>/` | Subagent project-scoped memory | Committed |

**Global-level** (`~/`):

| Path | Purpose |
|:---|:---|
| `~/.claude.json` | App state, UI preferences, personal MCP servers |
| `~/.claude/CLAUDE.md` | Personal preferences across all projects |
| `~/.claude/settings.json` | Default settings for all projects |
| `~/.claude/keybindings.json` | Custom keyboard shortcuts |
| `~/.claude/rules/*.md` | User-level rules (all projects) |
| `~/.claude/skills/<name>/SKILL.md` | Personal skills (all projects) |
| `~/.claude/commands/<name>.md` | Personal commands (all projects) |
| `~/.claude/output-styles/*.md` | Custom output styles |
| `~/.claude/agents/<name>.md` | Personal subagents (all projects) |
| `~/.claude/agent-memory/<agent>/` | Subagent user-scoped memory |
| `~/.claude/projects/<project>/memory/` | Auto memory per project |

### Troubleshooting

| Issue | Solution |
|:---|:---|
| Claude not following CLAUDE.md | Run `/memory` to verify loading; make instructions more specific; check for conflicts |
| Don't know what auto memory saved | Run `/memory`, select auto memory folder to browse |
| CLAUDE.md too large | Move content to `@path` imports or `.claude/rules/` files |
| Instructions lost after `/compact` | CLAUDE.md survives compaction; if lost, the instruction was only in conversation |
| Debugging which files loaded | Use the `InstructionsLoaded` hook to log loaded instruction files |

## Full Documentation

For the complete official documentation, see the reference files:

- [Memory](references/claude-code-memory.md) -- CLAUDE.md files and auto memory: CLAUDE.md locations and scoping (project, user, managed policy), writing effective instructions (size, structure, specificity, consistency), @path imports with recursive resolution up to five hops, AGENTS.md integration, CLAUDE.md load order (directory walk, subdirectory lazy loading, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), HTML comment stripping, .claude/rules/ directory (path-specific rules with paths: frontmatter and glob patterns, brace expansion, symlinks, user-level rules), managed policy deployment (macOS/Linux/Windows paths, MDM/Ansible), claudeMdExcludes for monorepos, /init and CLAUDE_CODE_NEW_INIT interactive flow, auto memory (MEMORY.md entrypoint with 200-line/25KB limit, topic files on demand, ~/.claude/projects/ storage, autoMemoryEnabled, CLAUDE_CODE_DISABLE_AUTO_MEMORY, autoMemoryDirectory, /memory command), subagent memory scopes, troubleshooting (InstructionsLoaded hook, /compact behavior)
- [.claude Directory Explorer](references/claude-code-claude-directory.md) -- Interactive reference for every file and folder Claude Code reads: project-level (CLAUDE.md, .mcp.json, .claude/settings.json, .claude/settings.local.json, .claude/rules/ with path-specific examples, .claude/skills/ with bundled resources and CLAUDE_SKILL_DIR, .claude/commands/ with $ARGUMENTS, .claude/output-styles/, .claude/agents/ with tools: frontmatter, .claude/agent-memory/ with memory: project scope) and global-level (~/.claude.json for app state and personal MCP servers, ~/.claude/CLAUDE.md, ~/.claude/settings.json, ~/.claude/keybindings.json with /keybindings command, ~/.claude/projects/ auto memory directory, ~/.claude/rules/, ~/.claude/skills/, ~/.claude/commands/, ~/.claude/output-styles/ with keep-coding-instructions frontmatter, ~/.claude/agents/, ~/.claude/agent-memory/ with memory: user scope)

## Sources

- Memory: https://code.claude.com/docs/en/memory.md
- .claude Directory Explorer: https://code.claude.com/docs/en/claude-directory.md
