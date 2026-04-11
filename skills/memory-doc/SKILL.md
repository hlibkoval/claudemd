---
name: memory-doc
description: Complete documentation for Claude Code memory — CLAUDE.md files, auto memory, path-scoped rules in .claude/rules/, and the full .claude directory layout (settings, skills, agents, MCP, hooks, memory, application data).
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory (CLAUDE.md files, auto memory, rules) and the `.claude` directory layout.

## Quick Reference

### Two memory systems

|                      | CLAUDE.md files                      | Auto memory                                        |
| :------------------- | :----------------------------------- | :------------------------------------------------- |
| **Who writes it**    | You                                  | Claude                                             |
| **Contains**         | Instructions and rules               | Learnings and patterns                             |
| **Scope**            | Project, user, or org                | Per working tree                                   |
| **Loaded into**      | Every session (in full)              | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for**          | Standards, workflows, architecture   | Build commands, debug insights, discovered prefs   |

### CLAUDE.md locations (most-specific wins)

| Scope                | Location                                                                                                                                       | Shared with                     |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| Managed policy       | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` · Linux/WSL: `/etc/claude-code/CLAUDE.md` · Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users on the machine        |
| Project              | `./CLAUDE.md` or `./.claude/CLAUDE.md`                                                                                                         | Team via source control         |
| User                 | `~/.claude/CLAUDE.md`                                                                                                                          | You, across all projects        |
| Local (gitignored)   | `./CLAUDE.local.md`                                                                                                                            | You, current project only       |

All discovered `CLAUDE.md`/`CLAUDE.local.md` files in the ancestor directory chain are concatenated (not overridden); `CLAUDE.local.md` is appended after `CLAUDE.md` within a directory. Subdirectory files load on demand. Block-level HTML comments are stripped before injection.

### Writing effective CLAUDE.md

- Target under 200 lines; longer files reduce adherence.
- Use markdown headers and bullets for structure.
- Be specific and verifiable ("Use 2-space indentation", not "format nicely").
- Remove conflicting instructions; Claude picks arbitrarily between them.
- Use `@path/to/file` imports (relative or absolute, up to 5 hops deep) to pull in README, package.json, or other docs.
- `AGENTS.md`: Claude Code reads `CLAUDE.md` only — import it with `@AGENTS.md` if your repo uses both.
- First-time external imports show an approval dialog; declining disables them permanently.
- Run `/init` to auto-generate a starter CLAUDE.md. `CLAUDE_CODE_NEW_INIT=1` enables the interactive multi-phase flow.

### Path-scoped rules (`.claude/rules/`)

Split large CLAUDE.md into topic files. Rules without `paths:` frontmatter load at session start; rules with `paths:` load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
---
# API Development Rules
- All endpoints validate input with Zod
```

| Pattern                | Matches                                  |
| ---------------------- | ---------------------------------------- |
| `**/*.ts`              | All TypeScript files anywhere            |
| `src/**/*`             | All files under `src/`                   |
| `*.md`                 | Markdown files at project root           |
| `src/components/*.tsx` | React components in that directory       |

Symlinks in `.claude/rules/` are supported (including circular detection). User-level rules in `~/.claude/rules/` load before project rules (project rules win).

### Auto memory

- On by default (requires v2.1.59+). Toggle via `/memory`, `autoMemoryEnabled: false` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.
- Storage: `~/.claude/projects/<project>/memory/` (project derived from git repo; all worktrees share one). Override with `autoMemoryDirectory` setting (not accepted from project settings for security).
- `MEMORY.md` is the index; first 200 lines or 25KB loaded every session. Topic files (`debugging.md`, `patterns.md`, etc.) load on demand.
- Files are plain markdown; edit or delete any time. "Writing memory" / "Recalled memory" indicators show live activity.

### Troubleshooting

| Problem                              | Fix                                                                                          |
| ------------------------------------ | -------------------------------------------------------------------------------------------- |
| Claude ignores CLAUDE.md             | Run `/memory` to verify it loaded; make instructions specific; remove conflicts              |
| CLAUDE.md too large                  | Split with `@imports` or move to `.claude/rules/` files                                      |
| Instructions lost after `/compact`   | Project-root CLAUDE.md re-injects; nested ones reload on next file read in that subdirectory |
| System-prompt-level instructions     | Use `--append-system-prompt` CLI flag                                                        |
| Monorepo: unwanted ancestor CLAUDE.md | Set `claudeMdExcludes` glob array in settings (merged across layers)                         |
| Debug what loaded                    | `/memory`, `/context`, or the `InstructionsLoaded` hook                                      |

Additional directories loaded with `--add-dir` don't load their CLAUDE.md by default. Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to opt in (still skips `CLAUDE.local.md`).

Managed policy CLAUDE.md cannot be excluded by `claudeMdExcludes`.

### The `.claude` directory — file reference

| File                               | Scope              | Commit | Purpose                                                  |
| ---------------------------------- | ------------------ | :----: | -------------------------------------------------------- |
| `CLAUDE.md`                        | Project + global   |   Y    | Instructions loaded every session                        |
| `rules/*.md`                       | Project + global   |   Y    | Topic-scoped instructions, optionally path-gated         |
| `settings.json`                    | Project + global   |   Y    | Permissions, hooks, env vars, model defaults             |
| `settings.local.json`              | Project only       |        | Personal overrides, auto-gitignored                      |
| `.mcp.json`                        | Project only       |   Y    | Team-shared MCP servers (project root, not `.claude/`)   |
| `.worktreeinclude`                 | Project only       |   Y    | Gitignored files to copy into new git worktrees          |
| `skills/<name>/SKILL.md`           | Project + global   |   Y    | Reusable prompts (user-invoked or model-invoked)         |
| `commands/*.md`                    | Project + global   |   Y    | Single-file prompts (same mechanism as skills)           |
| `output-styles/*.md`               | Project + global   |   Y    | Custom system-prompt sections                            |
| `agents/*.md`                      | Project + global   |   Y    | Subagent definitions with their own prompt and tools     |
| `agent-memory/<name>/`             | Project + global   |   Y    | Persistent memory for subagents                          |
| `~/.claude.json`                   | Global only        |        | App state, OAuth, UI toggles, personal MCP servers       |
| `projects/<project>/memory/`       | Global only        |        | Auto memory: Claude's notes to itself across sessions    |
| `keybindings.json`                 | Global only        |        | Custom keyboard shortcuts                                |

Managed policy settings and CLI flags can override these files. Set `CLAUDE_CONFIG_DIR` to relocate every `~/.claude` path.

### Check what loaded in a session

| Command        | Shows                                                                                 |
| -------------- | ------------------------------------------------------------------------------------- |
| `/context`     | Token usage by category (system, memory, skills, MCP, messages)                       |
| `/memory`      | Which CLAUDE.md, CLAUDE.local.md, and rules files loaded, plus auto-memory entries    |
| `/agents`      | Configured subagents                                                                  |
| `/hooks`       | Active hook configurations                                                            |
| `/mcp`         | Connected MCP servers and status                                                      |
| `/skills`      | Available skills from project, user, and plugin sources                               |
| `/permissions` | Current allow and deny rules                                                          |
| `/doctor`      | Installation and configuration diagnostics                                            |

### Application data under `~/.claude/`

**Auto-cleaned** (after `cleanupPeriodDays`, default 30): `projects/<project>/<session>.jsonl` (full transcripts), `projects/<project>/<session>/tool-results/`, `file-history/<session>/`, `plans/`, `debug/`, `paste-cache/`, `image-cache/`, `session-env/`.

**Kept until deleted**: `history.jsonl` (prompt history), `stats-cache.json` (cost totals), `backups/` (`.claude.json` migration backups), `todos/` (legacy).

Plaintext storage: transcripts are **not encrypted**. Tool inputs/outputs (including `.env` reads) land in `session.jsonl`. Mitigations: lower `cleanupPeriodDays`, pass `--no-session-persistence` with `-p` (or `persistSession: false` in the SDK), deny credential reads via permissions.

Do **not** delete `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/` (auth, preferences, installed plugins).

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, `.claude/rules/`, auto memory, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive explorer for every file in `.claude/` and `~/.claude/`, plus application data

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
