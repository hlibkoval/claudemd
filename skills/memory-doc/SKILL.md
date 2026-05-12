---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files (scopes, loading order, imports, path-scoped rules, org deployment), auto memory (MEMORY.md, storage location, how it works), the /memory command, troubleshooting, and the full .claude directory reference including settings, skills, agents, subagent memory, and application data.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory systems and the `.claude` directory structure.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations

| Scope | Location | Purpose | Shared with |
| :--- | :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Org-wide instructions managed by IT/DevOps | All users in organization |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared instructions for the project | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you (all projects) |
| **Local** | `./CLAUDE.local.md` | Personal project-specific prefs; add to `.gitignore` | Just you (current project) |

More specific locations take precedence over broader ones. Cannot exclude managed policy files.

### How CLAUDE.md Files Load

- Claude walks up the directory tree from the working directory, loading all discovered `CLAUDE.md` and `CLAUDE.local.md` files
- Files are concatenated (not overriding); ordered from filesystem root down to working directory
- Subdirectory CLAUDE.md files load on demand when Claude reads files in those subdirectories
- Block-level HTML comments (`<!-- ... -->`) are stripped before injection into context; use for maintainer notes
- Target under 200 lines per file; longer files reduce adherence

### Imports (`@path/to/file`)

Add `@path/to/file` anywhere in CLAUDE.md to import another file at launch. Relative paths resolve from the file, not the working directory. Max depth: 5 hops. Imports load into context (do not reduce context size).

```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

External imports show an approval dialog the first time they're encountered.

### AGENTS.md Compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. Bridge with an import or symlink:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

Or: `ln -s AGENTS.md CLAUDE.md` (Windows requires Administrator or Developer Mode for symlinks).

### `.claude/rules/` — Path-Scoped Instructions

Rules in `.claude/rules/` let you organize instructions into topic files. Use `paths:` frontmatter to scope them:

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules

- All API endpoints must include input validation
```

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` directory |
| `*.md` | Markdown files in the project root |

Rules without `paths:` load at session start (same priority as `.claude/CLAUDE.md`). Rules with `paths:` load only when Claude reads a matching file. Subdirectories in `rules/` are discovered automatically. Symlinks are supported.

User-level rules in `~/.claude/rules/` apply to every project.

### Excluding CLAUDE.md Files (`claudeMdExcludes`)

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute file paths. Arrays merge across settings layers. Managed policy CLAUDE.md files cannot be excluded.

### Managed Organization CLAUDE.md (`claudeMd` in managed-settings.json)

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

Honored only in managed/policy settings. Loads before user and project CLAUDE.md. Use for behavioral guidance; use `permissions.deny` in settings for hard enforcement.

### Auto Memory

Auto memory requires Claude Code v2.1.59+. Check with `claude --version`.

| Setting | Value |
| :--- | :--- |
| Default | Enabled |
| Toggle in session | `/memory` → auto memory toggle |
| Settings key | `autoMemoryEnabled: false` |
| Environment variable | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| Custom directory | `autoMemoryDirectory: "~/my-custom-memory-dir"` in `~/.claude/settings.json` |

`autoMemoryDirectory` must be absolute or start with `~/`. Accepted from policy, user settings, and `--settings`. Not accepted from project or local settings.

### Auto Memory Storage

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, first 200 lines or 25KB loaded every session
├── debugging.md       # Topic files — not loaded at startup, read on demand
├── api-conventions.md
└── ...
```

- `<project>` is derived from the git repository; all worktrees and subdirectories share one auto memory directory
- Auto memory is machine-local; not shared across machines or cloud environments
- `MEMORY.md` cap (200 lines / 25KB) applies only to MEMORY.md; CLAUDE.md files are loaded in full

### `/memory` Command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session. Provides an auto memory toggle and a link to open the auto memory folder. Select any file to open it in your editor.

### Troubleshooting

| Symptom | Diagnosis / Fix |
| :--- | :--- |
| Claude not following CLAUDE.md | Run `/memory` to verify files are listed; make instructions more specific; check for conflicting instructions |
| Instructions disappear after `/compact` | Project-root CLAUDE.md survives; nested CLAUDE.md reloads on next file access; add conversation-only instructions to CLAUDE.md |
| CLAUDE.md too large | Use path-scoped rules; trim content; note that `@path` imports don't reduce context |
| Don't know what auto memory saved | Run `/memory` and select the auto memory folder |
| Need guaranteed behavior | Use hooks (shell commands at lifecycle events) instead of CLAUDE.md |

Use the `InstructionsLoaded` hook to log which instruction files are loaded and when.

### `.claude` Directory — File Reference

| File | Scope | Committed | Purpose |
| :--- | :--- | :---: | :--- |
| `CLAUDE.md` | Project + global | Yes | Instructions loaded every session |
| `rules/*.md` | Project + global | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Project + global | Yes | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | Project only | No (auto-gitignored) | Personal overrides |
| `.mcp.json` | Project only | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Project only | Yes | Gitignored files to copy into new worktrees |
| `skills/<name>/SKILL.md` | Project + global | Yes | Reusable prompts invoked with `/name` or auto-invoked |
| `agents/*.md` | Project + global | Yes | Subagent definitions with own prompt and tools |
| `agent-memory/<name>/` | Project + global | Yes | Persistent memory for subagents |
| `~/.claude.json` | Global only | No | App state, OAuth, UI toggles, personal MCP servers |
| `projects/<project>/memory/` | Global only | No | Auto memory: Claude's notes to itself |
| `keybindings.json` | Global only | No | Custom keyboard shortcuts |
| `themes/*.json` | Global only | No | Custom color themes |

### Application Data (auto-cleaned after `cleanupPeriodDays`, default 30 days)

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `projects/<project>/<session>/subagents/` | Subagent conversation transcripts |
| `projects/<project>/<session>/tool-results/` | Large tool outputs |
| `file-history/<session>/` | Pre-edit file snapshots (checkpoint restore) |
| `plans/` | Plan mode plan files |
| `debug/` | Per-session debug logs |
| `paste-cache/`, `image-cache/` | Large pastes and attached images |

Kept until deleted: `history.jsonl` (prompt recall), `stats-cache.json` (token/cost counts), `remote-settings.json` (cached org settings).

**Plaintext storage warning:** Transcripts are not encrypted. If a tool reads a `.env` or a command prints a credential, that value lands in the transcript. Use `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` to disable transcript and prompt history writing.

### `claude project purge`

Deletes all state for a project: transcripts, auto memory, task/debug/file-history entries, matching prompt lines in `history.jsonl`, and the project's entry in `~/.claude.json`.

```bash
claude project purge ~/work/my-repo --dry-run  # preview only
claude project purge ~/work/my-repo            # with confirmation
claude project purge ~/work/my-repo --yes      # skip confirmation
claude project purge --all                     # all projects
```

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, loading order, imports, path-scoped rules, org-wide deployment, auto memory, /memory command, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — full file tree reference for project and global configuration, application data, file reference table, `claude project purge`

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
