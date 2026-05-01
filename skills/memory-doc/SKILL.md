---
name: memory-doc
description: Complete official documentation for Claude Code memory systems — CLAUDE.md files, auto memory, .claude/rules/, the .claude directory structure, and application data management.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

Claude Code carries knowledge across sessions via two complementary mechanisms: **CLAUDE.md files** (human-written instructions) and **auto memory** (Claude-written notes). Both are loaded at the start of every conversation.

### CLAUDE.md vs auto memory

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md file locations (precedence: more specific wins)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org (cannot be excluded) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Local instructions** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

### Writing effective CLAUDE.md instructions

| Principle | Good example | Avoid |
| :--- | :--- | :--- |
| **Size** | Target under 200 lines per file | Overly long files reduce adherence |
| **Specificity** | "Use 2-space indentation" | "Format code properly" |
| **Specificity** | "Run `npm test` before committing" | "Test your changes" |
| **Consistency** | Review for conflicting rules periodically | Contradictory instructions in the same or nested files |

### Import syntax

Reference external files with `@path/to/file` syntax anywhere in a CLAUDE.md. Relative paths resolve from the file containing the import. Max import depth: 5 hops. Imported files load at launch (they consume context tokens).

```text
See @README for project overview and @package.json for available commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

### AGENTS.md interop

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. Import AGENTS.md from CLAUDE.md to share instructions across tools:

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

### How CLAUDE.md files load

- Walk up the directory tree from the working directory, loading every `CLAUDE.md` and `CLAUDE.local.md` found
- All files are concatenated (not overridden); order is filesystem root → working directory; `CLAUDE.local.md` appends after `CLAUDE.md` at each level
- Subdirectory CLAUDE.md files load on demand when Claude reads files in those subdirectories
- Block HTML comments (`<!-- notes -->`) are stripped from context (but visible when you open the file)
- `--add-dir` directories: set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to also load their CLAUDE.md files

### Excluding CLAUDE.md files (`claudeMdExcludes`)

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns matched against absolute file paths. Managed policy CLAUDE.md files cannot be excluded.

### `.claude/rules/` — topic-scoped instructions

Place `.md` files in `.claude/rules/`. Files without `paths:` frontmatter load at session start. Files with `paths:` load only when Claude reads matching files.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules

- All API endpoints must include input validation
- Use the standard error response format
```

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

User-level rules in `~/.claude/rules/` apply to every project. Symlinks in `.claude/rules/` are resolved and loaded normally.

### Managed org CLAUDE.md

Deploy to the managed policy location via MDM, Group Policy, or Ansible. Cannot be excluded by individual settings. Use managed CLAUDE.md for behavioral guidance; use managed `settings.json` for technical enforcement.

| Concern | Configure in |
| :--- | :--- |
| Block specific tools, commands, or paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |

### Auto memory

Auto memory requires Claude Code v2.1.59 or later. Toggle via `/memory` or setting:

```json
{ "autoMemoryEnabled": false }
```

Disable via env var: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

**Storage**: `~/.claude/projects/<project>/memory/` — keyed by git repository root; all worktrees and subdirectories share one directory.

Custom location:
```json
{ "autoMemoryDirectory": "~/my-custom-memory-dir" }
```

(Accepted from policy, local, and user settings; not from project settings.)

**Auto memory file structure:**

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index — first 200 lines / 25KB loaded every session
├── debugging.md       # Detailed notes on debugging patterns
├── api-conventions.md # API design decisions
└── ...                # Other topic files Claude creates
```

Topic files are not loaded at startup; Claude reads them on demand. Auto memory is machine-local.

### `/memory` command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files in the current session. Lets you toggle auto memory, open the auto memory folder, and open any file in your editor.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify the file is loaded; check location; make instructions more specific; look for conflicting rules |
| Need system-prompt level enforcement | Use `--append-system-prompt` (must be passed every invocation) |
| Don't know what auto memory saved | Run `/memory` and open the auto memory folder |
| CLAUDE.md too large | Use path-scoped rules; trim content not needed every session |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-injects after compact; nested CLAUDE.md files reload next time Claude reads a file in that subdirectory |

Use the [`InstructionsLoaded` hook](/en/hooks#instructionsloaded) to log exactly which instruction files load, when, and why.

### `.claude` directory — key files at a glance

| File | Scope | Commit | Purpose |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | Project + global | Yes | Instructions loaded every session |
| `.claude/rules/*.md` | Project + global | Yes | Topic-scoped instructions, optionally path-gated |
| `.claude/settings.json` | Project + global | Yes | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | Project only | No | Personal overrides, auto-gitignored |
| `.mcp.json` | Project only | Yes | Team-shared MCP servers |
| `.worktreeinclude` | Project only | Yes | Gitignored files to copy into new worktrees |
| `~/.claude.json` | Global only | No | App state, OAuth, UI toggles, personal MCP servers |
| `~/.claude/projects/<project>/memory/` | Global only | No | Auto memory: Claude's notes per project |
| `~/.claude/keybindings.json` | Global only | No | Custom keyboard shortcuts |
| `~/.claude/themes/*.json` | Global only | No | Custom color themes |

### Application data (auto-cleaned after `cleanupPeriodDays`, default 30 days)

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `projects/<project>/<session>/tool-results/` | Large tool outputs |
| `file-history/<session>/` | Pre-edit snapshots for checkpoint restore |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs (only with `--debug`) |
| `paste-cache/`, `image-cache/` | Large pastes and attached images |

**Kept until manually deleted:** `history.jsonl` (up-arrow recall), `stats-cache.json` (usage totals).

**Clear project data:** `claude project purge ~/work/my-repo [--dry-run] [--yes] [--all]`

**Privacy:** Transcripts are not encrypted at rest. To reduce exposure: lower `cleanupPeriodDays`, set `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1`, or pass `--no-session-persistence` in non-interactive mode.

## Full Documentation

For the complete official documentation, see the reference files:

- [Memory](references/claude-code-memory.md) — CLAUDE.md files, auto memory, `.claude/rules/`, import syntax, load order, org management, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive directory explorer, file reference table, choose-the-right-file guide, application data paths, `claude project purge`

## Sources

- Memory: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
