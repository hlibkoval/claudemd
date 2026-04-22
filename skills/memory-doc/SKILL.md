---
name: memory-doc
description: Claude Code memory — CLAUDE.md files (scopes, load order, imports, rules), auto memory (MEMORY.md, topic files, storage), /memory command, and the .claude directory structure (all config files, when they load, application data).
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory structure.

## Quick Reference

### Two memory systems

| | CLAUDE.md files | Auto memory |
|---|---|---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

---

### CLAUDE.md file locations (most specific wins)

| Scope | Location | Shared with |
|---|---|---|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All org users — cannot be excluded |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team (via version control) |
| **User (global)** | `~/.claude/CLAUDE.md` | Just you, all projects |
| **Local** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you, current project |

**Load order:** Walk up from cwd; all discovered files are concatenated (not overriding). `CLAUDE.local.md` appended after `CLAUDE.md` at each level. Subdirectory CLAUDE.md files load on demand when Claude reads files there.

**Imports:** Use `@path/to/file` anywhere in CLAUDE.md. Relative paths resolve from the containing file. Max depth: 5 hops.

**HTML comments** (`<!-- ... -->`) are stripped before injection into context. Code block comments are preserved.

**Size guidance:** Target under 200 lines per file. Use `.claude/rules/` or `@` imports to split large files.

---

### `.claude/rules/` — path-scoped instructions

Rules without `paths:` frontmatter load at session start (same as CLAUDE.md).
Rules with `paths:` load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "tests/**/*.test.ts"
---

Instructions here only apply to matching files.
```

**Glob patterns:**

| Pattern | Matches |
|---|---|
| `**/*.ts` | All TypeScript files |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown at project root |
| `src/components/*.tsx` | Components in a specific dir |

- User-level rules: `~/.claude/rules/` (applied before project rules)
- Symlinks are supported; circular symlinks are handled
- Use `claudeMdExcludes` in settings to skip ancestor CLAUDE.md files in monorepos

---

### Auto memory

- **Requires** Claude Code v2.1.59+
- **Storage:** `~/.claude/projects/<project>/memory/` (keyed by git repo; worktrees share one directory)
- **Custom location:** set `autoMemoryDirectory` in user or local settings (not project settings)
- **Toggle:** `/memory` command, `"autoMemoryEnabled": false` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

**Directory structure:**

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index — first 200 lines / 25KB loaded every session
├── debugging.md       # Topic file — read on demand, not at startup
└── api-conventions.md # Topic file — Claude creates these as MEMORY.md grows
```

- `MEMORY.md` is the only file loaded at session start (cap: 200 lines or 25KB, whichever comes first)
- Topic files are read on demand; Claude creates them when MEMORY.md gets long
- Auto memory is machine-local; not shared across machines or cloud environments
- Subagents can maintain their own auto memory (see sub-agents-doc skill)

---

### `/memory` command

- Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session
- Toggles auto memory on/off
- Provides a link to open the auto memory folder
- Select any file to open it in your editor

---

### Exclude CLAUDE.md files (monorepos)

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute file paths. Arrays merge across settings layers. Managed policy CLAUDE.md cannot be excluded.

---

### `.claude` directory — all config files

**Project scope (`.claude/` in repo):**

| File | Committed | Purpose |
|---|---|---|
| `CLAUDE.md` / `.claude/CLAUDE.md` | Yes | Project instructions every session |
| `rules/*.md` | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Yes | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | No (auto-gitignored) | Personal overrides for this project |
| `skills/<name>/SKILL.md` | Yes | Reusable prompts invoked with `/name` |
| `commands/*.md` | Yes | Single-file prompts (same mechanism as skills) |
| `output-styles/*.md` | Yes | Custom system-prompt sections |
| `agents/*.md` | Yes | Subagent definitions |
| `agent-memory/<name>/` | Yes | Persistent memory for project subagents |

**Project root (not inside `.claude/`):**

| File | Committed | Purpose |
|---|---|---|
| `CLAUDE.md` | Yes | Project instructions (alternative to `.claude/CLAUDE.md`) |
| `CLAUDE.local.md` | No (add to `.gitignore`) | Personal project preferences |
| `.mcp.json` | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Yes | Gitignored files to copy into new worktrees |

**Global scope (`~/.claude/`):**

| File | Purpose |
|---|---|
| `CLAUDE.md` | Personal instructions for all projects |
| `settings.json` | Default settings for all projects |
| `rules/` | User-level rules applied everywhere |
| `skills/` | Personal skills available in every project |
| `agents/` | Personal subagents available everywhere |
| `agent-memory/` | Cross-project subagent memory (`memory: user`) |
| `output-styles/` | Custom output styles |
| `keybindings.json` | Custom keyboard shortcuts |
| `projects/<project>/memory/` | Auto memory per project |

**`~/.claude.json`** — App state: theme, OAuth, UI toggles, per-project trust decisions, personal MCP servers. Managed via `/config`.

---

### Application data in `~/.claude/`

**Auto-deleted after `cleanupPeriodDays` (default: 30 days):**

| Path | Contents |
|---|---|
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `projects/<project>/<session>/tool-results/` | Large tool outputs |
| `file-history/<session>/` | Pre-edit snapshots for checkpoint restore |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs (`--debug` or `/debug`) |
| `paste-cache/`, `image-cache/` | Paste and image contents |
| `session-env/` | Per-session environment metadata |

**Kept until manually deleted:**

| Path | Contents |
|---|---|
| `history.jsonl` | Every prompt typed (used for up-arrow recall) |
| `stats-cache.json` | Token/cost counts for `/cost` |
| `backups/` | Copies of `~/.claude.json` before config migrations |

Transcripts are not encrypted at rest. Use `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` or `--no-session-persistence` (non-interactive) to skip writing them.

---

### Choose the right file

| You want to | Edit | Reference |
|---|---|---|
| Give Claude project context and conventions | `CLAUDE.md` | Memory |
| Scope instructions to specific file types | `.claude/rules/` with `paths:` | Rules |
| Personal project preferences (not committed) | `CLAUDE.local.md` | Memory |
| Organization-wide instructions | Managed policy `CLAUDE.md` | Memory |
| Allow or block specific tool calls | `settings.json` `permissions` | Permissions |
| Reusable prompt invoked with `/name` | `skills/<name>/SKILL.md` | Skills |

---

### Troubleshooting

**Claude isn't following CLAUDE.md:**
- Run `/memory` to verify the file is listed (if missing, it's not loaded)
- Check the file is in a location that loads for your session
- Make instructions more specific ("Use 2-space indentation" not "format code nicely")
- Look for conflicting instructions across CLAUDE.md files
- For system-prompt level enforcement, use `--append-system-prompt`

**Instructions lost after `/compact`:**
- Project-root CLAUDE.md and unscoped rules: re-injected automatically
- Nested CLAUDE.md in subdirectories: reload next time Claude reads a file in that subdir
- Path-scoped rules: reload next time a matching file is read
- Fix: move conversation-only instructions to CLAUDE.md

**CLAUDE.md too large:** Keep under 200 lines. Split via `@path` imports or `.claude/rules/` files.

**Debug with hook:** Use `InstructionsLoaded` hook to log exactly which files load and when.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [claude-code-memory.md](references/claude-code-memory.md) — CLAUDE.md files, auto memory, /memory command, rules, troubleshooting
- [claude-code-claude-directory.md](references/claude-code-claude-directory.md) — Interactive .claude directory explorer, all config files, application data

## Sources

- Memory: https://code.claude.com/docs/en/memory.md
- Claude directory: https://code.claude.com/docs/en/claude-directory.md
