---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files and auto memory. Covers CLAUDE.md file locations and scopes (managed policy, project, user, local), CLAUDE.local.md for personal preferences, .claude/CLAUDE.md alternative location, writing effective instructions (size, structure, specificity, consistency), @path import syntax (relative paths, recursive imports, max depth 5), AGENTS.md interop, CLAUDE.md load order (directory walk-up, subdirectory lazy loading, HTML comment stripping, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), .claude/rules/ directory (path-specific rules with paths frontmatter, glob patterns, subdirectory discovery, symlinks, user-level rules at ~/.claude/rules/), organization-wide managed CLAUDE.md deployment (macOS, Linux, Windows locations), claudeMdExcludes setting for monorepos, auto memory (MEMORY.md entrypoint, topic files, ~/.claude/projects/<project>/memory/ storage, autoMemoryEnabled toggle, autoMemoryDirectory setting, 200-line/25KB load limit, /memory command), /init command for generating CLAUDE.md, /memory command for browsing and editing, troubleshooting (instructions not followed, auto memory audit, large CLAUDE.md, /compact behavior), and .claude directory structure (settings.json, settings.local.json, rules/, skills/, commands/, agents/, agent-memory/, output-styles/). Load when discussing CLAUDE.md, memory, auto memory, MEMORY.md, .claude/rules, rules files, path-specific rules, claudeMdExcludes, /memory, /init, CLAUDE.local.md, project instructions, user instructions, managed policy CLAUDE.md, @imports in CLAUDE.md, AGENTS.md, autoMemoryEnabled, autoMemoryDirectory, .claude directory structure, settings.json locations, or any memory and instruction-related topic for Claude Code.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers your project across sessions, covering both CLAUDE.md instruction files and auto memory.

## Quick Reference

### Memory Systems Overview

| | CLAUDE.md files | Auto memory |
|:--|:--|:--|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, discovered preferences |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Local** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

**Precedence:** More specific locations take precedence. Within each directory, `CLAUDE.local.md` is appended after `CLAUDE.md`.

### CLAUDE.md Loading Behavior

- Files in the directory hierarchy **above** the working directory are loaded in full at launch
- Files in **subdirectories** load on demand when Claude reads files in those directories
- `CLAUDE.md` and `CLAUDE.local.md` are concatenated, not overridden
- HTML comments (`<!-- ... -->`) are stripped before injection into context (code block comments preserved)
- `--add-dir` directories do **not** load CLAUDE.md by default; set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to enable
- `/init` generates a starting CLAUDE.md (or suggests improvements if one exists); set `CLAUDE_CODE_NEW_INIT=1` for interactive multi-phase flow

### Writing Effective Instructions

| Aspect | Guideline |
|:-------|:----------|
| **Size** | Target under 200 lines per file |
| **Structure** | Use markdown headers and bullets |
| **Specificity** | Concrete, verifiable rules (e.g., "Use 2-space indentation") |
| **Consistency** | Avoid contradicting rules across files |

### @Import Syntax

Reference additional files in CLAUDE.md with `@path/to/file`:

- Both relative and absolute paths allowed
- Relative paths resolve relative to the containing file
- Recursive imports supported, max depth of 5 hops
- Expanded and loaded at launch alongside the CLAUDE.md
- First-time external imports trigger an approval dialog

```text
See @README for project overview and @package.json for npm commands.
@docs/git-instructions.md
```

### AGENTS.md Interop

Import `AGENTS.md` from `CLAUDE.md` so both tools share the same instructions:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

### .claude/rules/ Directory

Modular instruction files that can be scoped to specific file paths.

| Feature | Detail |
|:--------|:-------|
| **Location** | `.claude/rules/*.md` (project) or `~/.claude/rules/*.md` (user) |
| **Discovery** | Recursive: subdirectories like `frontend/` work |
| **Loading** | Without `paths:` frontmatter: loaded at launch; with `paths:`: loaded when matching files enter context |
| **Symlinks** | Supported; circular symlinks detected and handled |
| **Priority** | User-level rules load before project rules; project rules have higher priority |

#### Path-Specific Rules Frontmatter

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "**/*.test.{ts,tsx}"
---
```

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

### claudeMdExcludes

Skip irrelevant CLAUDE.md files in monorepos. Patterns matched against absolute paths using glob syntax:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Configurable at any settings layer (user, project, local, managed policy). Arrays merge across layers. Managed policy CLAUDE.md files cannot be excluded.

### Organization-Wide Managed CLAUDE.md

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/CLAUDE.md` |
| Linux/WSL | `/etc/claude-code/CLAUDE.md` |
| Windows | `C:\Program Files\ClaudeCode\CLAUDE.md` |

Deploy with MDM, Group Policy, Ansible, or similar. Cannot be excluded by individual settings. Use for code style guidelines, compliance reminders, and behavioral instructions. For technical enforcement (blocking tools, sandbox isolation), use managed settings instead.

### Auto Memory

| Setting | Detail |
|:--------|:-------|
| **Default state** | Enabled (requires v2.1.59+) |
| **Toggle** | `/memory` command, `autoMemoryEnabled` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| **Storage** | `~/.claude/projects/<project>/memory/` |
| **Custom directory** | `autoMemoryDirectory` in user or local settings (not accepted from project settings) |
| **Load limit** | First 200 lines or 25KB of `MEMORY.md`, whichever comes first |
| **Topic files** | Read on demand, not at startup |
| **Scope** | Machine-local; all worktrees in same git repo share one directory |

#### Auto Memory Directory Structure

```text
~/.claude/projects/<project>/memory/
+-- MEMORY.md          # Concise index, loaded every session
+-- debugging.md       # Topic file (read on demand)
+-- api-conventions.md # Topic file (read on demand)
```

`MEMORY.md` acts as an index. Claude moves detailed notes into topic files to keep it concise. Topic files are read on demand when the current task relates to them.

### /memory Command

- Lists all loaded CLAUDE.md, CLAUDE.local.md, and rules files
- Toggle auto memory on/off
- Link to open the auto memory folder
- Select any file to open it in your editor

### .claude Directory Structure

#### Project: `your-project/.claude/`

| File/Dir | Purpose | Shared |
|:---------|:--------|:-------|
| `CLAUDE.md` | Alternative location for project instructions | Committed |
| `settings.json` | Permissions, hooks, model, env vars, statusLine, outputStyle | Committed |
| `settings.local.json` | Personal settings overrides | Gitignored |
| `rules/` | Topic-scoped instructions, optionally path-gated | Committed |
| `skills/` | Reusable prompts invoked by name | Committed |
| `commands/` | Single-file prompts (legacy; prefer skills/) | Committed |
| `agents/` | Subagents with own context window | Committed |
| `agent-memory/` | Subagent persistent memory (`memory: project`) | Committed |
| `output-styles/` | Project-scoped output styles | Committed |

#### Global: `~/.claude/`

| File/Dir | Purpose |
|:---------|:--------|
| `CLAUDE.md` | Personal preferences across all projects |
| `settings.json` | Default settings for all projects |
| `keybindings.json` | Custom keyboard shortcuts |
| `rules/` | User-level rules for all projects |
| `skills/` | Personal skills for all projects |
| `commands/` | Personal commands for all projects |
| `agents/` | Personal subagents for all projects |
| `agent-memory/` | Subagent memory (`memory: user`) |
| `output-styles/` | Custom output styles |
| `projects/` | Auto memory, per project |

#### Other Global Files

| File | Purpose |
|:-----|:--------|
| `~/.claude.json` | App state, UI preferences, personal MCP servers, per-project trust decisions |
| `.mcp.json` (project root) | Project-scoped MCP servers, shared with team |
| `.worktreeinclude` (project root) | Gitignored files to copy into new worktrees |

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Claude not following CLAUDE.md | Run `/memory` to verify files are loaded. Make instructions specific. Check for conflicts across files |
| Don't know what auto memory saved | Run `/memory`, select auto memory folder to browse plain markdown files |
| CLAUDE.md too large | Move content to `@path` imports or `.claude/rules/` files. Target under 200 lines |
| Instructions lost after `/compact` | CLAUDE.md survives compaction. Conversational instructions do not -- add them to CLAUDE.md |
| Debugging which files load | Use the `InstructionsLoaded` hook to log instruction file loading |
| System-prompt-level instructions | Use `--append-system-prompt` (must be passed every invocation) |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md files, auto memory, .claude/rules/, imports, organization deployment, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) -- Interactive directory explorer covering all project and global .claude files and directories

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
