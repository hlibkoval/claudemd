---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files, auto memory, .claude/rules/, CLAUDE.local.md, imports, path-scoped rules, organization-wide deployment, claudeMdExcludes, the /memory command, troubleshooting, and the .claude directory structure and file reference.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

Claude Code carries knowledge across sessions via two mechanisms: **CLAUDE.md files** (you write) and **auto memory** (Claude writes). Both load at the start of every conversation.

### CLAUDE.md vs auto memory

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md file locations

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org (cannot be excluded) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Local instructions** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

More specific locations take precedence over broader ones. Files above the working directory load at launch; files in subdirectories load on demand.

### Writing effective CLAUDE.md instructions

- **Size**: target under 200 lines per file — longer files reduce adherence
- **Structure**: use markdown headers and bullets to group related instructions
- **Specificity**: concrete and verifiable (`"Use 2-space indentation"` not `"Format code properly"`)
- **Consistency**: conflicting rules across files cause arbitrary behavior — review periodically
- Run `/init` to generate a starting CLAUDE.md automatically; set `CLAUDE_CODE_NEW_INIT=1` for interactive multi-phase flow

### Imports

Use `@path/to/file` syntax anywhere in CLAUDE.md to expand another file into context at launch:

```text
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

- Both relative and absolute paths allowed; relative paths resolve from the file containing the import
- Recursive imports supported up to 5 hops deep
- Imported files load at launch (they do NOT reduce context — they're fully inlined)
- First-time external imports trigger an approval dialog

### AGENTS.md compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other coding agents:

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

### .claude/rules/ — path-scoped rules

Rules files in `.claude/rules/` organize instructions by topic. Rules without `paths:` frontmatter load at launch (same as CLAUDE.md). Rules with `paths:` load only when Claude reads matching files.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All endpoints must validate input
```

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

- Supports brace expansion: `"src/**/*.{ts,tsx}"`
- Supports symlinks (circular symlinks handled gracefully)
- User-level rules at `~/.claude/rules/` apply to every project; project rules have higher priority

### Loading additional directories

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

Loads `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `CLAUDE.local.md` from the additional directory.

### Excluding CLAUDE.md files (monorepos)

Add to `.claude/settings.local.json` to skip files by path or glob:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Arrays merge across settings layers. Managed policy CLAUDE.md files cannot be excluded.

### Block comments in CLAUDE.md

HTML block comments (`<!-- notes -->`) are stripped before injecting into context — use them for maintainer notes without spending tokens. Comments inside code blocks are preserved.

### Auto memory

Auto memory requires Claude Code v2.1.59 or later. Toggle via `/memory` or settings:

```json
{ "autoMemoryEnabled": false }
```

Or via environment variable: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

**Storage location**: `~/.claude/projects/<project>/memory/` (keyed by git repo; all worktrees share one directory)

Custom location:
```json
{ "autoMemoryDirectory": "~/my-custom-memory-dir" }
```

(Accepted from policy, local, and user settings — not project settings.)

**Memory directory structure:**

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session (first 200 lines or 25KB)
├── debugging.md       # Detailed notes — read on demand, not at startup
├── api-conventions.md
└── ...
```

- `MEMORY.md` acts as an index; Claude keeps it concise by moving detail to topic files
- Topic files are NOT loaded at startup — Claude reads them on demand via standard file tools
- Auto memory is machine-local; not shared across machines or cloud environments
- When you see "Writing memory" or "Recalled memory", Claude is updating `~/.claude/projects/<project>/memory/`

### /memory command

`/memory` lists all CLAUDE.md, CLAUDE.local.md, and rules files in your session, lets you toggle auto memory, and links to the auto memory folder. Select any file to open it in your editor.

### Subagent memory

Subagents with `memory: project` frontmatter get a dedicated directory at `.claude/agent-memory/<agent-name>/`. Use `memory: local` for `.claude/agent-memory-local/` (not committed) or `memory: user` for `~/.claude/agent-memory/` (cross-project).

### Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Claude not following CLAUDE.md | Run `/memory` to verify the file is loaded; make instructions more specific; check for conflicting rules across files |
| Don't know what auto memory saved | Run `/memory` and open the auto memory folder — all plain markdown |
| CLAUDE.md too large | Use path-scoped rules; trim content not needed every session; note that `@path` imports do NOT reduce context |
| Instructions lost after `/compact` | Project-root CLAUDE.md survives compaction; nested CLAUDE.md files reload next time Claude reads a file in that subdirectory |
| Need system-prompt-level instructions | Use `--append-system-prompt` flag (must be passed every invocation) |
| Debug which files load | Use the `InstructionsLoaded` hook to log exactly which files are loaded and when |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, auto memory, .claude/rules/, imports, organization deployment, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — complete file reference for project and global .claude directories, file-by-file descriptions, application data, and choose-the-right-file table

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
