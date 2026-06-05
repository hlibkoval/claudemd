---
name: memory-doc
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory: CLAUDE.md files, auto memory, `.claude/rules/`, the `.claude` directory layout, and application data management.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
|:---|:---|:---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (load order, broadest → most specific)

| Scope | Location | Shared with |
|:------|:---------|:-----------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **Local instructions** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

Files in ancestor directories load at launch. Files in subdirectories load on demand when Claude reads files there. Content is concatenated (not overridden), ordered from root down to working directory.

### Writing Effective CLAUDE.md

| Guideline | Details |
|:----------|:--------|
| **Size** | Target under 200 lines per file; longer files reduce adherence |
| **Structure** | Use markdown headers and bullets; organized sections are easier to follow |
| **Specificity** | Concrete and verifiable: "Use 2-space indentation" not "Format code properly" |
| **Consistency** | Remove conflicting instructions; Claude may pick one arbitrarily |

- `@path/to/file` syntax imports additional files (relative or absolute; up to 4 hops deep)
- `CLAUDE.md` can import `@AGENTS.md` to share instructions with other coding agents
- Block-level HTML comments (`<!-- notes -->`) are stripped before injection into context
- Run `/init` to generate a starting CLAUDE.md automatically

### `.claude/rules/` — Path-Scoped Instructions

Rules are markdown files in `.claude/rules/` (or `~/.claude/rules/` for user-level). Without `paths:` frontmatter they load at session start like CLAUDE.md; with `paths:` they load only when Claude reads matching files.

```
---
paths:
  - "src/api/**/*.ts"
---
```

Glob patterns in `paths:`: `**/*.ts` (all TypeScript), `src/**/*` (all under src/), `*.md` (root markdown), `src/components/*.tsx` (specific directory). Multiple patterns and brace expansion (`**/*.{ts,tsx}`) are supported.

Rules load unconditionally without `paths:`, and support symlinks (circular symlinks are handled gracefully). User-level rules (`~/.claude/rules/`) load before project rules.

### Auto Memory

| Detail | Value |
|:-------|:------|
| **Requires** | Claude Code v2.1.59+ |
| **Default** | On |
| **Toggle** | `/memory` in session, or `"autoMemoryEnabled": false` in settings |
| **Env disable** | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| **Storage** | `~/.claude/projects/<project>/memory/` |
| **Custom location** | `"autoMemoryDirectory": "~/my-dir"` in settings (any scope) |
| **Session load** | First 200 lines or 25KB of `MEMORY.md`, whichever comes first |
| **Topic files** | Read on demand by Claude; not loaded at startup |

`MEMORY.md` acts as an index; Claude moves detailed notes into separate topic files (e.g. `debugging.md`, `api-conventions.md`). All files are plain markdown — edit or delete at any time. Machine-local; not shared across machines.

### `/memory` Command

- Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session
- Toggle auto memory on/off
- Link to open the auto memory folder
- Select any file to open it in your editor

### `claudeMdExcludes` Setting

Skip specific CLAUDE.md files in large monorepos:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute file paths. Arrays merge across settings layers. Managed policy CLAUDE.md cannot be excluded.

### `claudeMd` in Managed Settings

Embed CLAUDE.md content directly in `managed-settings.json` instead of deploying a separate file:

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

Only honored in managed/policy settings; has no effect in user, project, or local settings.

### Managed CLAUDE.md vs. Managed Settings

| Concern | Configure in |
|:--------|:------------|
| Block tools, commands, or file paths | `managed settings: permissions.deny` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### Loading CLAUDE.md from Additional Directories

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

Loads `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `CLAUDE.local.md` from the additional directory.

### `.claude` Directory — Key Files

| File | Scope | Purpose |
|:-----|:------|:--------|
| `CLAUDE.md` / `.claude/CLAUDE.md` | Project + global | Instructions every session |
| `CLAUDE.local.md` | Project (gitignored) | Personal project overrides |
| `.claude/rules/*.md` | Project + global | Topic-scoped, optionally path-gated rules |
| `~/.claude/projects/<project>/memory/` | Global only (auto-written) | Auto memory: Claude's accumulated notes |
| `settings.json` | Project + global | Permissions, hooks, env vars, model |
| `settings.local.json` | Project (gitignored) | Personal settings overrides |
| `skills/<name>/SKILL.md` | Project + global | Reusable prompts |
| `agents/*.md` | Project + global | Subagent definitions |
| `agent-memory/<name>/` | Project + global | Subagent persistent memory |

### Application Data — Auto-Cleaned (default 30 days, `cleanupPeriodDays`)

| Path under `~/.claude/` | Contents |
|:------------------------|:---------|
| `projects/<project>/<session>.jsonl` | Full conversation transcripts |
| `projects/<project>/<session>/subagents/` | Subagent transcripts |
| `file-history/<session>/` | Pre-edit file snapshots (checkpoint restore) |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs (`--debug` or `/debug`) |
| `paste-cache/`, `image-cache/` | Large paste and image contents |

### Application Data — Kept Until Deleted

| Path under `~/.claude/` | Contents |
|:------------------------|:---------|
| `history.jsonl` | Every prompt typed, with timestamp and project path |
| `stats-cache.json` | Token and cost counts for `/usage` |
| `remote-settings.json` | Cached server-managed settings (refreshed on launch) |

### `claude project purge` Command

Deletes transcripts, auto memory, and project state for one project. Requires v2.1.124+.

```bash
claude project purge ~/work/my-repo --dry-run   # Preview only
claude project purge ~/work/my-repo              # With confirmation
claude project purge ~/work/my-repo --yes        # Skip confirmation
claude project purge --all                       # All projects at once
```

Do not delete `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/` — those hold auth, preferences, and installed plugins.

### Troubleshooting

| Symptom | Check |
|:--------|:------|
| Claude not following CLAUDE.md | Run `/memory` to verify the file is listed; make instructions more specific; check for conflicting instructions across files |
| Don't know what auto memory saved | Run `/memory` and open the auto memory folder |
| CLAUDE.md too large | Use path-scoped rules or trim; `@path` imports help organization but don't reduce context |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-injects automatically; nested CLAUDE.md files reload when Claude next reads files in that subdirectory |

For must-run instructions (e.g., before every commit), use a [hook](/en/hooks-guide) — hooks execute as shell commands at fixed lifecycle events regardless of what Claude decides. For system-prompt-level instructions, use `--append-system-prompt`.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, load order, import syntax, AGENTS.md interop, path-scoped rules, auto memory, the `/memory` command, and troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — Complete directory layout for project and global config: every file Claude Code reads, when it loads, and what it does; application data and cleanup

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
