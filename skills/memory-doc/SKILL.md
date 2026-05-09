---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files, scoping and load order, path-scoped rules (.claude/rules/), imports, auto memory, MEMORY.md, the /memory command, and the full .claude directory structure including settings, skills, agents, hooks, and application data.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers your project across sessions.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Local instructions** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

### Load Order

- Files in the directory hierarchy **above** the working directory load at launch (from root down to cwd)
- `CLAUDE.local.md` loads after `CLAUDE.md` at each level (personal notes read last)
- Files in **subdirectories** load on demand when Claude reads files there
- Managed policy CLAUDE.md cannot be excluded

### Writing Effective Instructions

| Rule | Good example | Weak example |
| :--- | :--- | :--- |
| Specific | "Use 2-space indentation" | "Format code properly" |
| Actionable | "Run `npm test` before committing" | "Test your changes" |
| Located | "API handlers live in `src/api/handlers/`" | "Keep files organized" |

- **Target under 200 lines** per CLAUDE.md — longer files reduce adherence
- Use markdown headers and bullets; organized sections are easier to follow
- Review periodically for conflicting rules across CLAUDE.md files and rules/

### Imports

```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

- Both relative and absolute paths allowed; relative paths resolve from the importing file
- Max import depth: 5 hops
- Imported files load at launch alongside the CLAUDE.md that references them (same context cost)

### AGENTS.md Compatibility

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

Or symlink: `ln -s AGENTS.md CLAUDE.md`

### `.claude/rules/` — Path-Scoped Instructions

Rules without `paths:` load at session start like CLAUDE.md. Rules with `paths:` only load when Claude reads a matching file.

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
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

- Subdirectories in `.claude/rules/` are discovered recursively
- User-level rules in `~/.claude/rules/` apply to every project
- Symlinks in `.claude/rules/` are supported (circular symlinks detected)
- When CLAUDE.md approaches 200 lines, split into rules

### `claudeMdExcludes` — Skip Irrelevant Files

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Matched against absolute file paths. Configurable at any settings layer; arrays merge across layers. Managed policy CLAUDE.md cannot be excluded.

### Additional Directories

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

Loads `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `CLAUDE.local.md` from the additional directory.

### HTML Comments

Block-level HTML comments (`<!-- maintainer notes -->`) are stripped before injection into context. Use for human notes without spending tokens. Comments inside code blocks are preserved.

### Auto Memory

- Requires Claude Code v2.1.59+
- Enabled by default; toggle via `/memory` or `"autoMemoryEnabled": false` in settings
- Disable via env: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

**Storage location:** `~/.claude/projects/<project>/memory/`
- All worktrees and subdirectories within the same git repo share one auto memory directory
- Outside a git repo, the project root is used
- Custom location: set `autoMemoryDirectory` in `~/.claude/settings.json` (absolute or `~/` path; user/policy settings only — not project or local settings)

**MEMORY.md structure:**

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session
├── debugging.md       # Detailed notes on debugging patterns
├── api-conventions.md # API design decisions
└── ...                # Any other topic files Claude creates
```

- First 200 lines of MEMORY.md, or first 25KB, loaded at session start
- Topic files (e.g. `debugging.md`) are NOT loaded at startup — Claude reads them on demand
- CLAUDE.md files load in full regardless of length

### `/memory` Command

Opens a list of all CLAUDE.md, CLAUDE.local.md, and rules files in the current session, plus a toggle for auto memory and a link to the auto memory folder. Select any file to open it in your editor.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude ignores CLAUDE.md | Run `/memory` to verify files are loaded; check file location matches scope; make instructions more specific; look for conflicting rules |
| Instruction must run reliably | Use a [hook](/en/hooks) instead (shell commands at fixed lifecycle events) |
| CLAUDE.md too large | Use path-scoped rules or trim content; splitting into `@path` imports helps organization but not context cost |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-reads after compaction; nested files reload next time Claude reads that subdirectory |
| Need system-prompt-level instruction | Use `--append-system-prompt` (pass every invocation; better for scripts than interactive use) |

Use the [`InstructionsLoaded` hook](/en/hooks#instructionsloaded) to log exactly which instruction files are loaded and when.

### .claude Directory Quick Reference

| File | Scope | Commit | Purpose |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | Project + global | Yes | Instructions loaded every session |
| `rules/*.md` | Project + global | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Project + global | Yes | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | Project only | No (auto-gitignored) | Personal overrides |
| `.mcp.json` | Project only | Yes | Team-shared MCP servers |
| `skills/<name>/SKILL.md` | Project + global | Yes | Reusable prompts invoked with `/name` |
| `agents/*.md` | Project + global | Yes | Subagent definitions |
| `agent-memory/<name>/` | Project + global | Yes | Persistent subagent memory |
| `~/.claude.json` | Global only | No | App state, OAuth, UI toggles, personal MCP servers |
| `projects/<project>/memory/` | Global only | No | Auto memory: Claude's notes per project |
| `keybindings.json` | Global only | No | Custom keyboard shortcuts |
| `themes/*.json` | Global only | No | Custom color themes |

### Application Data (auto-cleaned after `cleanupPeriodDays`, default 30 days)

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcripts |
| `projects/<project>/<session>/tool-results/` | Large tool outputs |
| `file-history/<session>/` | Pre-edit file snapshots for checkpoint restore |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs |
| `paste-cache/`, `image-cache/` | Pasted content and attached images |

Purge a project's data: `claude project purge ~/work/my-repo` (use `--dry-run` to preview, `--yes` to skip confirmation, `--all` for all projects).

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, load order, imports, AGENTS.md compatibility, path-scoped rules, managing for large teams, auto memory, `/memory` command, and troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — full directory structure for project and global config, every file's purpose, load timing, application data, and `claude project purge`

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
