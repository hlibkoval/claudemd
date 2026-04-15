---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files, .claude/rules/, auto memory, and the full layout of project .claude/ and global ~/.claude/ directories.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

Claude Code starts each session with a fresh context window. Two complementary mechanisms carry knowledge across sessions:

|                      | CLAUDE.md files                         | Auto memory                                           |
| :------------------- | :-------------------------------------- | :---------------------------------------------------- |
| **Who writes it**    | You                                     | Claude                                                |
| **What it contains** | Instructions and rules                  | Learnings and patterns                                |
| **Scope**            | Project, user, or org                   | Per working tree (per git repo)                       |
| **Loaded into**      | Every session, in full                  | Every session (first 200 lines or 25KB of MEMORY.md)  |
| **Use for**          | Coding standards, workflows, layout     | Build commands, debugging insights, discovered prefs  |

Both load into the user message after the system prompt — they are guidance, not enforcement. Use [hooks](https://code.claude.com/docs/en/hooks) or [permissions](https://code.claude.com/docs/en/permissions) for hard enforcement.

### CLAUDE.md locations and precedence

More specific locations take precedence. All discovered files concatenate into context (rather than overriding key by key, like settings.json).

| Scope                    | Location                                                                                                                                                  | Shared with                     |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| **Managed policy**       | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` <br> Linux/WSL: `/etc/claude-code/CLAUDE.md` <br> Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users on the machine        |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md`                                                                                                                     | Team via source control         |
| **User instructions**    | `~/.claude/CLAUDE.md`                                                                                                                                      | Just you (all projects)         |
| **Local instructions**   | `./CLAUDE.local.md` (gitignore it)                                                                                                                         | Just you (current project)      |

Within each directory, `CLAUDE.local.md` is appended after `CLAUDE.md`. Files in subdirectories under cwd lazy-load when Claude reads files there. Managed policy CLAUDE.md cannot be excluded.

### How CLAUDE.md loads

- Walks up the directory tree from cwd; every `CLAUDE.md` and `CLAUDE.local.md` along the way is concatenated into context.
- Subdirectory CLAUDE.md files load on demand when Claude reads files in that subdir.
- Block-level HTML comments (`<!-- ... -->`) are stripped before injection (preserved inside code blocks and when read directly with the Read tool).
- `--add-dir` directories do NOT load CLAUDE.md unless `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` is set.
- Project-root CLAUDE.md survives `/compact` (re-read from disk). Nested ones do not auto-reload.
- Use `claudeMdExcludes` (settings) to skip ancestor files in monorepos.

### Imports

Use `@path/to/file` syntax inside CLAUDE.md to pull in additional files at launch. Relative paths resolve relative to the importing file. Recursive imports allowed up to depth 5. First time a project uses external imports, Claude Code shows an approval dialog.

```text
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
- @~/.claude/my-project-instructions.md
```

`AGENTS.md` is not read directly — create a CLAUDE.md that imports it: `@AGENTS.md`.

### Writing effective instructions

- **Size**: target under 200 lines per CLAUDE.md. Longer files reduce adherence.
- **Structure**: use markdown headers and bullets — Claude scans structure like readers do.
- **Specificity**: "Use 2-space indentation" beats "Format code properly".
- **Consistency**: review across nested files for contradictions.

Run `/init` to auto-generate a starting CLAUDE.md. Set `CLAUDE_CODE_NEW_INIT=1` for the interactive multi-phase flow that also offers to set up skills and hooks.

### `.claude/rules/` — modular instructions

Topic-scoped instructions in `.claude/rules/*.md` (recursive). Same priority as `.claude/CLAUDE.md` when no `paths:` frontmatter. With `paths:` frontmatter, rules become **path-scoped** and only load when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "**/*.test.{ts,tsx}"
---

# API Development Rules
- All API endpoints must include input validation
```

| Pattern                | Matches                              |
| ---------------------- | ------------------------------------ |
| `**/*.ts`              | All TypeScript files anywhere        |
| `src/**/*`             | Everything under `src/`              |
| `*.md`                 | Markdown files at project root only  |
| `src/components/*.tsx` | React components in one directory    |

User-level rules in `~/.claude/rules/` apply to every project; project rules take precedence. Symlinks (including circular) are supported and resolved.

### Auto memory

On by default in v2.1.59+. Claude decides what to remember; not everything is saved.

- **Storage**: `~/.claude/projects/<project>/memory/` (keyed by git repo root, so all worktrees share one). Customize with `autoMemoryDirectory` in user/local/policy settings (NOT project settings — security).
- **Toggle**: `/memory` in session, or `autoMemoryEnabled: false` in settings, or env var `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.
- **MEMORY.md**: index file, first 200 lines or 25KB (whichever first) loaded every session. Topic files like `debugging.md`, `api-conventions.md` load on demand.
- **Machine-local**: never synced across machines or cloud environments.
- Subagents can have their own auto memory — see [subagent persistent memory](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory).

### Managed CLAUDE.md vs managed settings

| Concern                                       | Configure in                                              |
| :-------------------------------------------- | :-------------------------------------------------------- |
| Block tools/commands/file paths               | Managed settings: `permissions.deny`                      |
| Sandbox isolation                             | Managed settings: `sandbox.enabled`                       |
| Env vars / API provider routing               | Managed settings: `env`                                   |
| Authentication / org lock                     | Managed settings: `forceLoginMethod`, `forceLoginOrgUUID` |
| Code style and quality guidelines             | Managed CLAUDE.md                                         |
| Behavioral instructions / compliance reminders | Managed CLAUDE.md                                         |

Settings are enforced; CLAUDE.md is guidance.

### `/memory` command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the session, toggles auto memory, links to the auto memory folder, and opens any file in your editor. Saying "remember that..." in chat saves to auto memory; saying "add this to CLAUDE.md" writes to the project file.

### Project `.claude/` directory layout

| Path                                | Badge       | What it is                                                                                  |
| :---------------------------------- | :---------- | :------------------------------------------------------------------------------------------ |
| `./CLAUDE.md`                       | committed   | Project instructions, every session                                                         |
| `./CLAUDE.local.md`                 | gitignored  | Personal per-project preferences                                                            |
| `./.mcp.json`                       | committed   | Project-scoped MCP servers (project root, not under `.claude/`)                             |
| `./.worktreeinclude`                | committed   | Gitignored files to copy into new git worktrees (project root, git-only)                    |
| `.claude/CLAUDE.md`                 | committed   | Alternate location for project CLAUDE.md                                                    |
| `.claude/settings.json`             | committed   | Permissions, hooks, statusLine, model, env, outputStyle                                     |
| `.claude/settings.local.json`       | gitignored  | Personal overrides; auto-added to `~/.config/git/ignore`                                    |
| `.claude/rules/`                    | committed   | Topic instructions, optionally path-scoped via `paths:` frontmatter                         |
| `.claude/skills/<name>/SKILL.md`    | committed   | Skills (folder-bundled, can include supporting files)                                       |
| `.claude/commands/<name>.md`        | committed   | Single-file slash commands (skills are now preferred for new workflows)                     |
| `.claude/output-styles/`            | committed   | Project-shared output styles (most live in `~/.claude/output-styles/` instead)              |
| `.claude/agents/<name>.md`          | committed   | Subagent definitions (own context window, own tool allowlist)                               |
| `.claude/agent-memory/<agent>/MEMORY.md` | committed   | Subagent memory when `memory: project` in subagent frontmatter                              |
| `.claude/agent-memory-local/`       | gitignored  | Subagent memory when `memory: local`                                                        |

### Global `~/` and `~/.claude/` layout

| Path                                          | What it is                                                                       |
| :-------------------------------------------- | :------------------------------------------------------------------------------- |
| `~/.claude.json`                              | App state, theme, OAuth, per-project trust, personal MCP servers, UI toggles     |
| `~/.claude/CLAUDE.md`                         | Personal instructions, loaded in every session of every project                  |
| `~/.claude/settings.json`                     | Default settings; project settings.json overrides matching keys                  |
| `~/.claude/keybindings.json`                  | Custom keyboard shortcuts; hot-reloaded; Ctrl+C/D/M reserved                     |
| `~/.claude/projects/<project>/memory/MEMORY.md` | Auto memory index per project (first 200 lines / 25KB loaded each session)      |
| `~/.claude/projects/<project>/memory/*.md`    | Auto memory topic files, loaded on demand                                        |
| `~/.claude/rules/`                            | User-level rules across all projects                                             |
| `~/.claude/skills/`                           | Personal skills available in every project                                       |
| `~/.claude/commands/`                         | Personal single-file commands available in every project                        |
| `~/.claude/output-styles/`                    | Custom output styles (built-ins: Explanatory, Learning)                          |
| `~/.claude/agents/`                           | Personal subagents available in every project                                    |
| `~/.claude/agent-memory/<agent>/MEMORY.md`    | Subagent memory when `memory: user`                                              |

File badges: **committed** (in version control), **gitignored** (auto-ignored), **local only** (under `~/`), **Claude writes** (autogenerated).

### Troubleshooting

- **Claude isn't following CLAUDE.md** → run `/memory` to verify it loaded; check location precedence; make instructions more specific; check for conflicting nested files. For system-prompt-level instructions, use `--append-system-prompt`. Use the `InstructionsLoaded` hook to log exactly which files load and when.
- **Don't know what auto memory saved** → `/memory` then open the auto memory folder; everything is plain markdown.
- **CLAUDE.md too large** → split via `@path` imports or `.claude/rules/` files.
- **Instructions seem lost after `/compact`** → project-root CLAUDE.md is re-read automatically; nested CLAUDE.md only reloads when Claude next reads a file in that subdir; conversation-only instructions don't survive — add them to CLAUDE.md.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — full guide to CLAUDE.md files, .claude/rules/ (including path-scoped rules and symlinks), auto memory (storage, configuration, how it works), `/memory` command, managing CLAUDE.md for large teams, and troubleshooting.
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive file-tree explorer documenting every file and folder under a project `.claude/` and global `~/.claude/`, including CLAUDE.md, settings.json, .mcp.json, .worktreeinclude, rules/, skills/, commands/, output-styles/, agents/, agent-memory/, projects/, keybindings.json, and the `~/.claude.json` app state file. Each entry covers when it loads, what it contains, examples, and tips.

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
