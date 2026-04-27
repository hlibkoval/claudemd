---
name: memory-doc
description: Complete official documentation for Claude Code memory and configuration directory — CLAUDE.md files, auto memory, .claude/rules/, path-scoped rules, file imports, team management, and the full .claude directory reference including settings, skills, subagents, hooks, and application data.
user-invocable: false
---

# Memory & .claude Directory Documentation

This skill provides the complete official documentation for Claude Code memory systems and the `.claude` configuration directory.

## Quick Reference

Claude Code carries knowledge across sessions via two complementary mechanisms: **CLAUDE.md files** (you write) and **auto memory** (Claude writes). Both are loaded at the start of every session.

### CLAUDE.md vs auto memory

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md file locations (precedence: more specific wins)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization (cannot be excluded) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Local instructions** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

### CLAUDE.md loading behavior

- Files are loaded by walking **up** the directory tree from the working directory.
- All discovered files are **concatenated** into context; they do not override each other.
- `CLAUDE.local.md` is appended after `CLAUDE.md` at each directory level.
- Subdirectory CLAUDE.md files load **on demand** when Claude reads files there, not at launch.
- HTML block comments (`<!-- ... -->`) are stripped before injection but preserved when you read the file directly.
- Use `--add-dir` + `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to load CLAUDE.md from extra directories.

### Writing effective CLAUDE.md instructions

- **Size**: target under 200 lines per file. Longer files consume more context.
- **Structure**: use markdown headers and bullets to group related instructions.
- **Specificity**: write verifiable instructions ("Use 2-space indentation" not "Format code properly").
- **Consistency**: resolve conflicts across files — Claude may pick one arbitrarily if two rules contradict.
- **Imports**: use `@path/to/file` syntax to pull in other files (max 5 hops deep). Imported files load at launch and count toward context.

### Exclude CLAUDE.md files in monorepos

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute file paths. Configure in any settings layer; arrays merge across layers. Managed policy CLAUDE.md files cannot be excluded.

### .claude/rules/ — path-scoped instructions

Rules live in `.claude/rules/` (project) or `~/.claude/rules/` (user). Each `.md` file covers one topic.

- Rules **without** `paths:` frontmatter load at session start like CLAUDE.md.
- Rules **with** `paths:` frontmatter load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "**/*.test.{ts,tsx}"
---
# Rules that only load for matched files
```

Supported glob patterns:

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in specific directory |

Symlinks in `.claude/rules/` are resolved and loaded normally.

### Auto memory

- Requires Claude Code v2.1.59+. On by default.
- Toggle with `/memory` or `autoMemoryEnabled: false` in settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.
- Storage: `~/.claude/projects/<project>/memory/` (keyed by git repo; shared across worktrees).
- Override location: `autoMemoryDirectory` in user or local settings (not accepted from project settings).

#### Auto memory directory structure

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index; first 200 lines or 25KB loaded every session
├── debugging.md       # Topic file (read on demand, not at startup)
├── api-conventions.md
└── ...
```

- `MEMORY.md` is the index. Claude reads and writes it throughout the session.
- Topic files are not loaded at startup; Claude reads them on demand.
- All files are plain markdown — edit or delete at any time.
- Run `/memory` to browse, open, or toggle auto memory from within a session.

### Managed CLAUDE.md vs managed settings

| Concern | Configure in |
| :--- | :--- |
| Block tools, commands, or file paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Environment variables and API routing | Managed settings: `env` |
| Authentication method and org lock | Managed settings: `forceLoginMethod`, `forceLoginOrgUUID` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

Settings rules are enforced by the client. CLAUDE.md instructions shape Claude's behavior but are not a hard enforcement layer.

### Troubleshooting memory issues

| Symptom | Fix |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify files are loaded; make instructions more specific; check for conflicting instructions |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-injects after compact; nested CLAUDE.md files reload only when Claude next reads files in that subdirectory |
| CLAUDE.md is too large | Use path-scoped rules; trim content; note that `@path` imports don't reduce context |
| Don't know what auto memory saved | Run `/memory` and open the auto memory folder |

### AGENTS.md compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions between tools:

```markdown
<!-- CLAUDE.md -->
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

### .claude directory — choosing the right file

| You want to | Edit | Reference |
| :--- | :--- | :--- |
| Give Claude project context and conventions | `CLAUDE.md` | Memory |
| Allow or block specific tool calls | `settings.json` `permissions` or `hooks` | Permissions, Hooks |
| Run a script before/after tool calls | `settings.json` `hooks` | Hooks |
| Set environment variables for the session | `settings.json` `env` | Settings |
| Keep personal overrides out of git | `settings.local.json` | Settings scopes |
| Add a prompt invoked with `/name` | `skills/<name>/SKILL.md` | Skills |
| Define a specialized subagent | `agents/*.md` | Subagents |
| Connect external tools over MCP | `.mcp.json` | MCP |
| Change how Claude formats responses | `output-styles/*.md` | Output styles |

### Key file reference

| File | Scope | Committed | What it does |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | Project and global | Yes | Instructions loaded every session |
| `.claude/rules/*.md` | Project and global | Yes | Topic-scoped instructions, optionally path-gated |
| `.claude/settings.json` | Project and global | Yes | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | Project only | No (auto-gitignored) | Personal overrides |
| `.mcp.json` | Project only | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Project only | Yes | Gitignored files to copy into new worktrees |
| `skills/<name>/SKILL.md` | Project and global | Yes | Reusable prompts invoked with `/name` or auto-invoked |
| `agents/*.md` | Project and global | Yes | Subagent definitions with their own prompt and tools |
| `.claude/agent-memory/<name>/` | Project and global | Yes | Persistent memory for subagents |
| `~/.claude.json` | Global only | No | App state, OAuth, UI toggles, personal MCP servers |
| `~/.claude/projects/<project>/memory/` | Global only | No | Auto memory: Claude's notes to itself |
| `~/.claude/keybindings.json` | Global only | No | Custom keyboard shortcuts |
| `~/.claude/themes/*.json` | Global only | No | Custom color themes |

### Application data cleanup

Paths cleaned up automatically after `cleanupPeriodDays` (default 30 days):

- `projects/<project>/<session>.jsonl` — full conversation transcripts
- `file-history/<session>/` — pre-edit file snapshots
- `plans/`, `debug/`, `paste-cache/`, `image-cache/`, `session-env/`, `tasks/`, `shell-snapshots/`, `backups/`

Kept until you delete them: `history.jsonl` (prompt recall), `stats-cache.json` (usage totals).

Do NOT delete `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/` — those hold auth, preferences, and installed plugins.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, auto memory, .claude/rules/, path-scoped rules, imports, team management, the /memory command, and troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive directory reference covering every file in the project and global .claude directories, when each loads, what it does, and application data stored by Claude Code

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
