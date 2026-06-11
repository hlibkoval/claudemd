---
name: memory-doc
user-invocable: false
description: >
  Complete official documentation for Claude Code memory systems: CLAUDE.md files,
  auto memory, .claude/rules/, and the .claude directory layout. Load when answering
  questions about persistent instructions, CLAUDE.md scopes and syntax, path-scoped
  rules, auto memory configuration, the /memory command, or what lives in ~/.claude.
---

# Memory & .claude Directory Documentation

This skill provides the complete official documentation for Claude Code's memory systems — CLAUDE.md files, auto memory, rules, and the .claude directory layout.

## Quick Reference

### Two memory systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25 KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md file locations (load order, broadest to narrowest)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team (via source control) |
| **Local** | `./CLAUDE.local.md` | Just you (current project); add to `.gitignore` |

Files in ancestor directories load at launch in full; files in subdirectories load on demand when Claude reads files there.

### Key CLAUDE.md authoring rules

- Target under 200 lines per file; longer files consume more context and reduce adherence
- Use markdown headers and bullets; Claude scans structure the same way readers do
- Write concrete, verifiable instructions ("Use 2-space indentation" not "Format code nicely")
- Avoid conflicting instructions across nested files; Claude may pick one arbitrarily
- Import other files with `@path/to/file` syntax (relative paths allowed; max 4 hops deep)
- HTML block comments (`<!-- ... -->`) are stripped before injection; use for maintainer notes
- Instructions are context, not enforced config — use hooks for guaranteed enforcement

### .claude/rules/ (path-scoped instructions)

Place `.md` files in `.claude/rules/` — one topic per file, organized into subdirectories if needed. Rules without `paths` frontmatter load unconditionally at launch. Rules with `paths` load only when Claude reads matching files:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---
```

Glob patterns: `**/*.ts` (any dir), `src/**/*` (under src/), `*.md` (root only), `src/components/*.tsx` (specific dir). User-level rules live in `~/.claude/rules/` and load before project rules (lower priority).

### Auto memory

| Setting | Default | How to change |
| :--- | :--- | :--- |
| Enabled | Yes | `/memory` toggle or `"autoMemoryEnabled": false` in settings |
| Storage | `~/.claude/projects/<project>/memory/` | `"autoMemoryDirectory": "~/custom-dir"` in settings |
| MEMORY.md load limit | First 200 lines or 25 KB | Not configurable |
| Disable via env | — | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |

Requires Claude Code v2.1.59+. All worktrees in the same git repo share one memory directory. Topic files (e.g. `debugging.md`) are not loaded at startup — Claude reads them on demand.

### Memory directory layout

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session
├── debugging.md       # Detailed notes on debugging patterns (on demand)
├── api-conventions.md # API design decisions (on demand)
└── ...
```

### /memory command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session. Lets you toggle auto memory and open any listed file in your editor. When you ask Claude to "remember" something, it saves to auto memory; to write to CLAUDE.md instead, ask Claude explicitly or edit via `/memory`.

### claudeMdExcludes (monorepo use)

Skip specific files with glob patterns matched against absolute paths — useful in large monorepos to ignore other teams' CLAUDE.md files. Configure in `.claude/settings.local.json`:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Managed policy CLAUDE.md files cannot be excluded.

### .claude directory — choose the right file

| You want to | Edit | Reference |
| :--- | :--- | :--- |
| Give Claude project context and conventions | `CLAUDE.md` | Memory |
| Allow or block specific tool calls | `settings.json` `permissions` or `hooks` | Permissions, Hooks |
| Run a script before or after tool calls | `settings.json` `hooks` | Hooks |
| Set env vars for the session | `settings.json` `env` | Settings |
| Keep personal overrides out of git | `settings.local.json` | Settings scopes |
| Add a prompt invoked with `/name` | `skills/<name>/SKILL.md` | Skills |
| Define a specialized subagent | `agents/*.md` | Subagents |
| Connect external tools over MCP | `.mcp.json` | MCP |

### .claude file reference (all scopes)

| File | Commit | What it does |
| :--- | :--- | :--- |
| `CLAUDE.md` | Yes | Instructions loaded every session |
| `rules/*.md` | Yes | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Yes | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | No | Personal overrides, gitignored |
| `.mcp.json` | Yes | Team-shared MCP servers |
| `skills/<name>/SKILL.md` | Yes | Reusable prompts, auto-invoked or via `/name` |
| `agents/*.md` | Yes | Subagent definitions |
| `workflows/*.js` | Yes | Dynamic workflow scripts |
| `~/.claude/projects/<project>/memory/` | No | Auto memory: Claude's notes to itself |
| `~/.claude.json` | No | App state, OAuth, UI toggles, personal MCP servers |
| `~/.claude/keybindings.json` | No | Custom keyboard shortcuts |
| `~/.claude/themes/*.json` | No | Custom color themes |

### Application data (auto-cleaned after `cleanupPeriodDays`, default 30 days)

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `file-history/<session>/` | Pre-edit snapshots for checkpoint restore |
| `plans/` | Plan mode plan files |
| `debug/` | Per-session debug logs |
| `paste-cache/`, `image-cache/` | Large pastes and attached images |

Transcripts are plaintext, not encrypted at rest. Use `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` to skip writing them. Run `claude project purge <path>` (requires v2.1.124+) to delete all state for a project.

### Troubleshooting memory issues

| Symptom | Fix |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify files are loaded; make instructions more specific; check for conflicts |
| Don't know what auto memory saved | Run `/memory`, select auto memory folder |
| CLAUDE.md is too large | Use path-scoped rules; trim content not needed every session |
| Instructions lost after `/compact` | Project-root CLAUDE.md is re-injected; nested files reload when Claude next reads that subdirectory |
| Need instructions at system-prompt level | Use `--append-system-prompt` (per-invocation) |
| Instruction must run at a fixed lifecycle point | Use a hook instead |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, imports, path-scoped rules, auto memory, /memory command, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — Full .claude directory layout, file reference table, application data, `claude project purge`, plaintext storage

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
