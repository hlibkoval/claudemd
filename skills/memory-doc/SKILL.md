---
name: memory-doc
user-invocable: false
---

# Memory & CLAUDE.md Documentation

This skill provides the complete official documentation for Claude Code's memory systems: CLAUDE.md files, auto memory, `.claude/rules/`, and the `.claude` directory layout.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
|:--|:----------------|:------------|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25 KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (load order, broadest → most specific)

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **Local** | `./CLAUDE.local.md` | Just you (current project) |

- Files above the working directory load in full at launch; subdirectory files load on demand when Claude reads files there.
- All discovered files are concatenated, ordered from filesystem root down to working directory. Within a directory, `CLAUDE.local.md` appends after `CLAUDE.md`.
- HTML comments (`<!-- ... -->`) are stripped before injection into context.

### Writing Effective CLAUDE.md Instructions

| Principle | Guidance |
|:----------|:---------|
| **Size** | Target under 200 lines; longer files consume context and reduce adherence |
| **Structure** | Use markdown headers and bullets to group related instructions |
| **Specificity** | Concrete and verifiable: "Run `npm test` before committing", not "Test your changes" |
| **Consistency** | Conflicting rules may be picked arbitrarily; review periodically |

### Imports (`@path/to/file`)

Reference other files anywhere in CLAUDE.md with `@path/to/import`. Both relative and absolute paths work; relative paths resolve from the file containing the import. Max recursion depth: 4 hops. Imported files load into context at launch — they organize content but do not reduce token usage.

### AGENTS.md Compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other agents, import from within CLAUDE.md:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

Or use a symlink if no Claude-specific additions are needed.

### `.claude/rules/` — Path-Scoped Instructions

Rules files in `.claude/rules/` are markdown files, one topic per file. Rules without `paths:` frontmatter load at session start like CLAUDE.md. Rules with `paths:` load only when Claude reads a matching file, reducing context noise.

**Path-scoped rule frontmatter:**

```yaml
---
paths:
  - "src/api/**/*.ts"
  - "**/*.test.ts"
---
```

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |

- Rules files are discovered recursively in `.claude/rules/`; subdirectories are supported.
- User-level rules in `~/.claude/rules/` apply to every project and load before project rules.
- The directory supports symlinks for sharing rules across projects.

### Large Team / Monorepo Settings

| Setting | Purpose |
|:--------|:--------|
| `claudeMdExcludes` in `settings.local.json` | Skip specific CLAUDE.md files by path or glob (managed policy CLAUDE.md cannot be excluded) |
| `claudeMd` key in `managed-settings.json` | Embed managed CLAUDE.md content directly in settings instead of deploying a separate file |

Managed CLAUDE.md loads before user and project CLAUDE.md. Use `claudeMdExcludes` at any settings layer; arrays merge across layers.

### Auto Memory

- **Requires** Claude Code v2.1.59+.
- **Storage:** `~/.claude/projects/<project>/memory/` — path derived from git repo, so all worktrees share one directory. Custom path: `autoMemoryDirectory` in `~/.claude/settings.json` (absolute or `~/`-prefixed; accepted only from policy, user settings, or `--settings`).
- **At session start:** first 200 lines of `MEMORY.md` (or 25 KB, whichever comes first) are loaded. Topic files (`debugging.md`, etc.) are read on demand, not at startup.
- **Toggle:** `/memory` command in-session, or `autoMemoryEnabled: false` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

**Memory directory layout:**
```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index; loaded every session
├── debugging.md       # Topic file; read on demand
└── api-conventions.md # Topic file; read on demand
```

### `/memory` Command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session, toggles auto memory, and links to the auto memory folder. Select any file to open it in your editor.

### `--add-dir` and Additional Directories

By default, CLAUDE.md files from `--add-dir` directories are not loaded. To also load them:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

This loads CLAUDE.md, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and CLAUDE.local.md from the added directory.

### Troubleshooting

| Symptom | Fix |
|:--------|:----|
| Claude isn't following CLAUDE.md | Run `/memory` to verify the file is loaded; make instructions more specific; check for conflicts across files |
| Instructions must run at a specific lifecycle point | Use a [hook](/en/hooks-guide) instead — hooks execute as shell commands regardless of what Claude decides |
| Instructions lost after `/compact` | Project-root CLAUDE.md is re-injected after compaction; nested CLAUDE.md files reload next time Claude reads files in that subdirectory |
| CLAUDE.md too large | Use path-scoped rules; trim content not needed every session; note that `@path` imports do not reduce context |
| Don't know what auto memory saved | Run `/memory` → open the auto memory folder; all files are plain markdown |

### `.claude` Directory: Key Files at a Glance

| File / Path | Scope | Purpose |
|:------------|:------|:--------|
| `CLAUDE.md` or `.claude/CLAUDE.md` | Project | Project instructions loaded every session |
| `CLAUDE.local.md` | Project (gitignored) | Personal per-project preferences |
| `~/.claude/CLAUDE.md` | User (global) | Personal preferences across all projects |
| `.claude/rules/*.md` | Project | Topic-scoped instructions, path-gated optional |
| `~/.claude/rules/*.md` | User (global) | Personal rules for all projects |
| `~/.claude/projects/<project>/memory/` | User (global, auto-written) | Auto memory: MEMORY.md index + topic files |
| `.claude/settings.json` | Project | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | Project (gitignored) | Personal settings overrides |
| `~/.claude/settings.json` | User | Default settings for all projects |

For the full `.claude` directory reference (skills, agents, workflows, MCP, output-styles, keybindings, themes, application data, and `claude project purge`), see the `.claude` directory reference doc.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, imports, AGENTS.md compatibility, load order, `.claude/rules/`, path-specific rules, large-team settings, auto memory, `/memory` command, and troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — Interactive reference covering every file in the project `.claude/` directory and `~/.claude/`, including when each file loads, examples, and application data lifecycle

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
