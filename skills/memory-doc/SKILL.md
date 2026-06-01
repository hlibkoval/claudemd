---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files, auto memory, .claude/rules/, the /memory command, scoping, imports, load order, troubleshooting, and the full .claude directory layout.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25 KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (Load Order: Broadest → Most Specific)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org — cannot be excluded |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via version control |
| **Local instructions** | `./CLAUDE.local.md` | Just you (add to `.gitignore`) |

Files in ancestor directories load at launch; files in subdirectories load on demand when Claude reads files there.

### Import Syntax

Reference additional files inside CLAUDE.md using `@path/to/file` syntax. Imported files are expanded at launch. Relative paths resolve from the importing file. Maximum depth: 4 hops.

```text
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

To bridge AGENTS.md (used by other tools) into Claude: add `@AGENTS.md` as the first line of CLAUDE.md, or use a symlink.

### Writing Effective Instructions

| Concern | Guidance |
| :--- | :--- |
| **Size** | Target under 200 lines per file; longer files reduce adherence |
| **Structure** | Use markdown headers and bullets; organized sections are easier to follow |
| **Specificity** | "Use 2-space indentation" not "Format code properly" |
| **Consistency** | Conflicting instructions → Claude may pick one arbitrarily |

CLAUDE.md loads as a user message after the system prompt — it is context Claude reads, not enforced configuration. Use hooks for guaranteed enforcement.

### .claude/rules/ — Scoped Instructions

Rules are markdown files in `.claude/rules/`. Rules without `paths:` frontmatter load at session start. Rules with `paths:` load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All endpoints must include input validation
```

**Glob pattern examples:**

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/**/*.{ts,tsx}` | TypeScript and TSX files under `src/` |

Rules support symlinks. User-level rules in `~/.claude/rules/` apply to every project.

### Excluding CLAUDE.md Files

Use `claudeMdExcludes` in `.claude/settings.local.json` to skip ancestor CLAUDE.md files in monorepos:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute paths. Managed policy CLAUDE.md files cannot be excluded.

### Organization-Wide CLAUDE.md via Managed Settings

The `claudeMd` key in `managed-settings.json` embeds instructions directly without deploying a separate file:

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

| Concern | Configure in |
| :--- | :--- |
| Block tools or commands | Managed `settings.json` (`permissions.deny`) |
| Code style / behavioral guidance | Managed CLAUDE.md |
| Data handling reminders | Managed CLAUDE.md |

### Auto Memory

Requires Claude Code v2.1.59+. On by default. Claude decides what is worth saving — it does not save something every session.

**Enable/disable:**
- Toggle with `/memory` in a session
- Or set `autoMemoryEnabled: false` in `settings.json`
- Or set env var `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

**Storage layout:**

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session
├── debugging.md       # Detailed topic notes
├── api-conventions.md # Additional topic files Claude creates
```

The `<project>` path derives from the git repository; all worktrees share one directory. Outside a git repo, the project root is used.

To use a custom location, set `autoMemoryDirectory` in `settings.json`:

```json
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

**Load behavior:** The first 200 lines of `MEMORY.md` (or 25 KB, whichever comes first) are loaded every session. Topic files are read on demand, not at startup. CLAUDE.md files load in full regardless of length.

When you see "Writing memory" or "Recalled memory" in the interface, Claude is actively reading from or writing to `~/.claude/projects/<project>/memory/`.

### /memory Command

`/memory` lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session, lets you toggle auto memory on or off, and provides a link to the auto memory folder. Select any file to open it in your editor.

To save something to auto memory: ask Claude ("always use pnpm, not npm"). To add to CLAUDE.md instead: ask Claude directly ("add this to CLAUDE.md") or edit via `/memory`.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify the file is listed; make instructions more specific; check for conflicting instructions across files |
| Don't know what auto memory saved | Run `/memory` → select auto memory folder; everything is plain markdown |
| CLAUDE.md is too large | Use path-scoped rules; trim entries not needed every session; note that `@path` imports don't reduce context (they load at launch) |
| Instructions lost after `/compact` | Project-root CLAUDE.md is re-injected after compaction; nested CLAUDE.md files reload only when Claude reads a file in that subdirectory |

For enforced behavior (e.g., run before every commit), use a hook instead of CLAUDE.md. For instructions at the system prompt level, use `--append-system-prompt` (CLI flag, not interactive).

### .claude Directory: Key Files at a Glance

| File | Scope | What it does |
| :--- | :--- | :--- |
| `CLAUDE.md` / `.claude/CLAUDE.md` | Project + global | Instructions loaded every session |
| `CLAUDE.local.md` | Project only | Personal per-project notes; add to `.gitignore` |
| `.claude/rules/*.md` | Project + global | Topic-scoped instructions, optionally path-gated |
| `.claude/settings.json` | Project + global | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | Project only | Personal overrides; auto-gitignored |
| `.mcp.json` | Project only | Team-shared MCP servers |
| `.claude/skills/<name>/SKILL.md` | Project + global | Reusable prompts invoked with `/name` |
| `.claude/agents/*.md` | Project + global | Subagent definitions |
| `.claude/agent-memory/` | Project | Subagent persistent memory (committed) |
| `~/.claude/projects/<project>/memory/` | Global only | Main session auto memory |
| `~/.claude.json` | Global only | App state, OAuth, UI toggles, personal MCP |

Application data Claude writes (transcripts, history, caches) lives under `~/.claude/projects/` and is cleaned up after `cleanupPeriodDays` (default: 30 days). Run `claude project purge` to delete all state for a project.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scoping, import syntax, AGENTS.md integration, load order, .claude/rules/, auto memory, /memory command, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — Full interactive reference for every file in the project .claude/ and global ~/.claude/ directories, with examples and load timing

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
