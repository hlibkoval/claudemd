---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files (where to put them, load order, how to write effective instructions, imports, AGENTS.md interop, rules), .claude/rules/ path-scoped rules, auto memory (storage location, enable/disable, how MEMORY.md works, topic files, audit/edit), the /memory command, troubleshooting memory issues, the .claude directory structure (all project and global files, when each loads, application data, cleanup), and the "choose the right file" reference table.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the .claude directory.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25 KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

CLAUDE.md is guidance Claude reads — it is not enforced configuration. For guaranteed behavior, use hooks or permissions instead.

### CLAUDE.md File Locations (load order, broadest → most specific)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| Managed policy | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| User | `~/.claude/CLAUDE.md` | Just you (all projects) |
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| Local | `./CLAUDE.local.md` | Just you (current project) — add to `.gitignore` |

CLAUDE.md and CLAUDE.local.md files in ancestor directories above the working directory are loaded at launch. Files in subdirectories load on demand when Claude reads files there. Within each directory, `CLAUDE.local.md` appends after `CLAUDE.md`.

### Writing Effective CLAUDE.md Instructions

- **Size**: target under 200 lines. Longer files consume more context and reduce adherence.
- **Structure**: use markdown headers and bullets; organized sections are easier to follow than dense paragraphs.
- **Specificity**: "Use 2-space indentation" rather than "Format code properly"; "Run `npm test` before committing" rather than "Test your changes".
- **Consistency**: review periodically for conflicting instructions across CLAUDE.md files and rules.

### CLAUDE.md Imports

Use `@path/to/file` syntax inside CLAUDE.md to pull in additional files. Imported files expand into context at launch. Relative paths resolve relative to the file containing the import; max depth 4 hops.

```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

For per-worktree personal instructions, import from your home directory:

```text
# Individual Preferences
- @~/.claude/my-project-instructions.md
```

### AGENTS.md Interop

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other coding agents without duplication, import from AGENTS.md:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

A symlink also works if no Claude-specific additions are needed.

### `.claude/rules/` Path-Scoped Rules

Place markdown files in `.claude/rules/` (project) or `~/.claude/rules/` (user). Rules without `paths:` frontmatter load at session start. Rules with `paths:` load only when Claude reads matching files.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---

# API Development Rules
- All endpoints must include input validation
```

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

Brace expansion is supported: `"src/**/*.{ts,tsx}"`.

Rules are loaded in full for matching files; for task-specific instructions that don't need to be in context all the time, use skills instead.

### Exclude Specific CLAUDE.md Files

Use `claudeMdExcludes` in `.claude/settings.local.json` to skip files in large monorepos:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute paths using glob syntax. Arrays merge across settings layers. Managed policy CLAUDE.md files cannot be excluded.

### Managed CLAUDE.md (Org-wide)

Set the `claudeMd` key in `managed-settings.json` to inject instructions without deploying a separate file:

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

| Concern | Configure in |
| :--- | :--- |
| Block specific tools, commands, or file paths | Managed settings: `permissions.deny` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### Auto Memory

Auto memory requires Claude Code v2.1.59 or later. On by default.

**Storage**: `~/.claude/projects/<project>/memory/` — keyed by git repository, shared across all worktrees and subdirectories in the same repo. Machine-local only.

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session
├── debugging.md       # Detailed notes on debugging patterns
├── api-conventions.md # API design decisions
└── ...
```

**How it loads**: the first 200 lines or 25 KB of `MEMORY.md` (whichever comes first) are loaded at the start of every session. Topic files (`debugging.md`, etc.) are not loaded at startup — Claude reads them on demand when a related task comes up.

**Toggle auto memory**:

```json
{
  "autoMemoryEnabled": false
}
```

Or set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

**Custom storage location** (user or policy settings only, not project):

```json
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

Subagents can also maintain their own auto memory with the `memory:` frontmatter field; scopes are `user`, `project`, and `local`.

### `/memory` Command

`/memory` lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in your current session, lets you toggle auto memory on or off, and provides a link to open the auto memory folder. Select any file to open it in your editor.

### `--add-dir` and CLAUDE.md

By default, CLAUDE.md files from `--add-dir` directories are not loaded. To load them:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### Troubleshooting

| Symptom | Steps |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify the file is listed. Check it's in a loaded location. Make instructions more specific. Look for conflicting instructions across files. |
| Instructions disappear after `/compact` | Project-root CLAUDE.md survives compaction and reloads automatically. Nested subdirectory CLAUDE.md files reload next time Claude reads a file there. Conversation-only instructions do not survive. |
| CLAUDE.md is too large | Use path-scoped rules to load instructions only when Claude works with matching files. Target under 200 lines. |
| Don't know what auto memory saved | Run `/memory` and open the auto memory folder to browse plain markdown files. |

For instructions that must run at a specific point (before every commit, after each file edit), use a hook instead. Hooks execute as shell commands at fixed lifecycle events.

### .claude Directory — Choose the Right File

| You want to | Edit | Scope |
| :--- | :--- | :--- |
| Give Claude project context and conventions | `CLAUDE.md` | project or global |
| Allow or block specific tool calls | `settings.json` `permissions` or `hooks` | project or global |
| Run a script before/after tool calls | `settings.json` `hooks` | project or global |
| Set environment variables | `settings.json` `env` | project or global |
| Keep personal overrides out of git | `settings.local.json` | project only |
| Add a prompt invoked with `/name` | `skills/<name>/SKILL.md` | project or global |
| Define a specialized subagent | `agents/*.md` | project or global |
| Connect external tools over MCP | `.mcp.json` | project only |

### Key .claude Files Reference

| File | Commit | What it does |
| :--- | :--- | :--- |
| `CLAUDE.md` | Yes | Instructions loaded every session |
| `rules/*.md` | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Yes | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | No | Personal overrides, auto-gitignored |
| `.mcp.json` | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Yes | Gitignored files to copy into new worktrees |
| `skills/<name>/SKILL.md` | Yes | Reusable prompts invoked with `/name` |
| `agents/*.md` | Yes | Subagent definitions |
| `agent-memory/<name>/` | Yes | Project-scoped subagent persistent memory |
| `~/.claude.json` | No | App state, OAuth, UI toggles, personal MCP servers |
| `~/.claude/projects/<project>/memory/` | No | Auto memory: Claude's notes per project |
| `~/.claude/keybindings.json` | No | Custom keyboard shortcuts |
| `~/.claude/themes/*.json` | No | Custom color themes |

### Application Data Cleanup

Files under `~/.claude/projects/` (transcripts, auto memory) and related session data are deleted after `cleanupPeriodDays` (default 30). `history.jsonl`, `stats-cache.json`, and `remote-settings.json` persist until manually deleted.

Run `claude project purge ~/work/my-repo` to delete all state for a project (transcripts, auto memory, task lists, matching history lines). Use `--dry-run` to preview, `--yes` to skip confirmation.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, load order, effective instructions, imports, AGENTS.md interop, .claude/rules/, path-scoped rules, auto memory, /memory command, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — complete file tree explorer (project and global), what each file does and when it loads, choose-the-right-file table, application data paths, cleanup, `claude project purge`

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
