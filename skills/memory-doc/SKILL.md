---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files (scopes, locations, imports, rules, path-specific rules, AGENTS.md interop, how files load, monorepo exclusion), auto memory (MEMORY.md, topic files, storage location, enable/disable), the /memory command, troubleshooting (not following instructions, large files, post-compact loss), and the .claude directory explorer (all project and global files: settings.json, rules/, skills/, agents/, agent-memory/, output-styles/, keybindings.json, themes/, auto-cleanup paths, application data).
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory systems and the `.claude` directory layout.

## Quick Reference

### Two Memory Systems Compared

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (Load Order, Broadest to Most Specific)

| Scope | Location | Purpose | Shared with |
| :--- | :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Organization-wide, managed by IT/DevOps | All users in org |
| **User instructions** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared instructions | Team via source control |
| **Local instructions** | `./CLAUDE.local.md` | Personal project-specific; add to `.gitignore` | Just you (current project) |

CLAUDE.md files above the working directory load in full at launch. Files in subdirectories load on demand when Claude reads files there. Within each directory, `CLAUDE.local.md` appends after `CLAUDE.md`.

### CLAUDE.md Import Syntax

Use `@path/to/file` anywhere in CLAUDE.md to import additional files. Both relative and absolute paths work. Imports are recursive up to 4 hops deep. Imported files load into context at launch alongside the referencing CLAUDE.md.

```text
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

For cross-worktree personal instructions, import from home directory:
```text
@~/.claude/my-project-instructions.md
```

### AGENTS.md Interop

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To use both:
```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```
Or create a symlink (`ln -s AGENTS.md CLAUDE.md`) if no Claude-specific additions are needed.

### Path-Scoped Rules in `.claude/rules/`

Rules files can have YAML frontmatter with a `paths` field. They load only when Claude reads a matching file — reducing noise and saving context.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All endpoints must include input validation
```

Rules without `paths` load at session start. All `.md` files in `.claude/rules/` are discovered recursively. Symlinks are supported.

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

User-level rules at `~/.claude/rules/` apply to every project (lower priority than project rules).

### Writing Effective CLAUDE.md

- **Size**: target under 200 lines per file; longer files reduce adherence
- **Structure**: use headers and bullets; organized sections are easier to follow
- **Specificity**: "Use 2-space indentation" beats "Format code properly"
- **Consistency**: conflicting rules cause arbitrary picks; review periodically

### Excluding CLAUDE.md Files in Monorepos

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Arrays merge across settings layers. Managed policy CLAUDE.md files cannot be excluded.

### Managed Policy `claudeMd` Key

Add behavioral instructions directly to `managed-settings.json` instead of deploying a separate file:
```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

Accepted from managed/policy settings only. Loads before user and project CLAUDE.md.

### Auto Memory

- **Requires**: Claude Code v2.1.59+
- **Storage**: `~/.claude/projects/<project>/memory/` (keyed by git repo; worktrees share one directory)
- **On by default**: toggle with `/memory` or `autoMemoryEnabled: false` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`
- **Custom location**: `autoMemoryDirectory: "~/my-dir"` in `~/.claude/settings.json` (absolute or `~/`-prefixed; user/policy settings only)

Auto memory directory structure:
```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, first 200 lines/25KB loaded every session
├── debugging.md       # Topic files Claude creates for overflow detail
├── api-conventions.md
└── ...
```

`MEMORY.md` is the index. Topic files are not loaded at startup — Claude reads them on demand. When you see "Writing memory" or "Recalled memory" in the UI, Claude is updating or reading from this directory.

### `/memory` Command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session; lets you toggle auto memory; provides a link to the auto memory folder. Select any file to open it in your editor.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify files are listed; check location; make instructions more specific; look for conflicts |
| Don't know what auto memory saved | Run `/memory` and open the auto memory folder |
| CLAUDE.md is too large | Use path-scoped rules or trim; `@` imports help organize but don't reduce context |
| Instructions lost after `/compact` | Project-root CLAUDE.md is re-injected; nested CLAUDE.md reloads when matching files are read; conversation-only instructions are lost |

For instructions that must run at a specific point, use a hook instead — hooks execute as shell commands at fixed lifecycle events regardless of what Claude decides.

### `.claude` Directory: Choose the Right File

| You want to | Edit | Scope | Reference |
| :--- | :--- | :--- | :--- |
| Give Claude project context and conventions | `CLAUDE.md` | project or global | Memory |
| Allow or block specific tool calls | `settings.json` `permissions` or `hooks` | project or global | Permissions, Hooks |
| Run a script before or after tool calls | `settings.json` `hooks` | project or global | Hooks |
| Set environment variables | `settings.json` `env` | project or global | Settings |
| Keep personal overrides out of git | `settings.local.json` | project only | Settings scopes |
| Add a prompt you invoke with `/name` | `skills/<name>/SKILL.md` | project or global | Skills |
| Define a specialized subagent | `agents/*.md` | project or global | Subagents |
| Connect external tools over MCP | `.mcp.json` | project only | MCP |
| Change how Claude formats responses | `output-styles/*.md` | project or global | Output styles |

### Project `.claude/` File Reference

| File | Commit | What it does |
| :--- | :--- | :--- |
| `CLAUDE.md` / `.claude/CLAUDE.md` | Yes | Instructions loaded every session |
| `CLAUDE.local.md` | No (gitignored) | Personal overrides for this project |
| `.claude/rules/*.md` | Yes | Topic-scoped instructions, optionally path-gated |
| `.claude/settings.json` | Yes | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | No (auto-gitignored) | Personal overrides, highest user-editable priority |
| `.mcp.json` | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Yes | Gitignored files to copy into new worktrees |
| `.claude/skills/<name>/SKILL.md` | Yes | Reusable prompts invoked with `/name` |
| `.claude/commands/*.md` | Yes | Single-file prompts (legacy; prefer skills) |
| `.claude/output-styles/*.md` | Yes | Custom system-prompt sections |
| `.claude/agents/*.md` | Yes | Subagent definitions |
| `.claude/agent-memory/<name>/` | Yes | Persistent memory for project-scoped subagents |

### Global `~/.claude/` File Reference

| File | What it does |
| :--- | :--- |
| `~/.claude.json` | App state, OAuth, UI toggles, personal MCP servers |
| `~/.claude/CLAUDE.md` | Personal preferences across every project |
| `~/.claude/settings.json` | Default settings for all projects |
| `~/.claude/settings.local.json` | Highest-priority personal settings |
| `~/.claude/rules/` | User-level rules applying to every project |
| `~/.claude/skills/` | Personal skills available in every project |
| `~/.claude/output-styles/` | Custom output styles available everywhere |
| `~/.claude/agents/` | Personal subagents available in every project |
| `~/.claude/agent-memory/` | Persistent memory for user-scoped subagents |
| `~/.claude/keybindings.json` | Custom keyboard shortcuts |
| `~/.claude/themes/*.json` | Custom color themes |
| `~/.claude/projects/<project>/memory/` | Auto memory: Claude's notes per project |

### Application Data (Auto-cleanup after `cleanupPeriodDays`, default 30 days)

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `projects/<project>/<session>/subagents/` | Subagent conversation transcripts |
| `projects/<project>/<session>/tool-results/` | Large tool outputs |
| `file-history/<session>/` | Pre-edit file snapshots (checkpoint restore) |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs (with `--debug`) |
| `paste-cache/`, `image-cache/` | Large pastes and attached images |
| `session-env/` | Per-session environment metadata |
| `tasks/` | Per-session task lists |

### Kept Until Manually Deleted

| Path | Contents |
| :--- | :--- |
| `history.jsonl` | Every prompt typed, with timestamp (up-arrow recall) |
| `stats-cache.json` | Token and cost counts for `/usage` |
| `remote-settings.json` | Cached server-managed settings |

### Purging Project Data

```bash
claude project purge ~/work/my-repo          # Review plan and confirm
claude project purge ~/work/my-repo --dry-run  # Preview without deleting
claude project purge ~/work/my-repo --yes    # Skip confirmation
claude project purge --all                   # All projects at once
```

Purges: transcripts, auto memory, per-session tasks/debug/file-history, matching prompt history, and project entry in `~/.claude.json`. Does not touch `shell-snapshots/` or `backups/`.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, imports, path-specific rules, auto memory, /memory command, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive explorer of all project and global files, choose-the-right-file table, application data, purge commands

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
