---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files (project, user, org, local scopes), auto memory (MEMORY.md, topic files), .claude/rules/ with path-scoped frontmatter, imports, the /memory command, and the full .claude directory layout including settings, skills, agents, and application data.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code persists knowledge across sessions, including CLAUDE.md files, auto memory, and the full `.claude` directory layout.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB of MEMORY.md) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Local** | `./CLAUDE.local.md` | Just you (current project) |

More specific locations take precedence. Files in the directory hierarchy above the working directory load at launch; subdirectory files load on demand when Claude reads files there.

### Writing Effective CLAUDE.md

- **Size**: target under 200 lines per file; longer files still load in full but reduce adherence
- **Structure**: use markdown headers and bullets to group related instructions
- **Specificity**: "Use 2-space indentation" not "Format code properly"; "Run `npm test` before committing" not "Test your changes"
- **Consistency**: conflicting instructions cause Claude to pick arbitrarily — review periodically

### Import Additional Files

```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

Both relative and absolute paths work. Relative paths resolve relative to the importing file. Max import depth: 5 hops. Imports load at launch (still consume context). First-time external imports trigger an approval dialog.

### AGENTS.md Interop

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other agents:

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

### Load from Additional Directories

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

Loads `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `CLAUDE.local.md` from the additional directory.

### Exclude Specific CLAUDE.md Files

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute paths. Arrays merge across settings layers. Managed policy CLAUDE.md files cannot be excluded.

### HTML Comments in CLAUDE.md

Block-level HTML comments (`<!-- notes -->`) are stripped before injecting into context. Use for maintainer notes without spending tokens. Comments inside code blocks are preserved.

### .claude/rules/ — Topic-Scoped Instructions

Place `.md` files in `.claude/rules/`. Rules without `paths:` frontmatter load at session start like CLAUDE.md. Rules with `paths:` load only when Claude reads matching files.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules

- All API endpoints must include input validation
```

**Path glob examples:**

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

Multiple patterns and brace expansion (`{ts,tsx}`) are supported. Rules support symlinks; circular symlinks are detected.

**User-level rules** at `~/.claude/rules/` apply to every project. They load before project rules (lower priority).

### Auto Memory

Auto memory requires Claude Code v2.1.59+. Toggle via `/memory` or:

```json
{ "autoMemoryEnabled": false }
```

Disable via env var: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

**Storage location**: `~/.claude/projects/<project>/memory/` — shared by all worktrees and subdirectories of the same git repo.

Custom location (user settings only):
```json
{ "autoMemoryDirectory": "~/my-custom-memory-dir" }
```

**Memory directory layout:**
```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session
├── debugging.md       # Detailed notes on debugging patterns
├── api-conventions.md # API design decisions
└── ...
```

- `MEMORY.md`: first 200 lines or 25KB loaded at session start; Claude keeps it concise by moving detail to topic files
- Topic files (e.g. `debugging.md`): not loaded at startup; Claude reads on demand
- This limit applies only to `MEMORY.md` — CLAUDE.md files load in full regardless

### /memory Command

`/memory` lists all CLAUDE.md, CLAUDE.local.md, and rules files in the current session, shows the auto memory toggle, and provides a link to open the auto memory folder. Select any file to open it in your editor.

To save something to auto memory, tell Claude: "always use pnpm, not npm". To add to CLAUDE.md instead, say "add this to CLAUDE.md".

### Managed Policy vs. CLAUDE.md

| Concern | Configure in |
| :--- | :--- |
| Block specific tools, commands, or file paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Environment variables and API routing | Managed settings: `env` |
| Authentication method and org lock | Managed settings: `forceLoginMethod` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### .claude Directory Overview

| File | Scope | What it does |
| :--- | :--- | :--- |
| `CLAUDE.md` | Project and global | Instructions loaded every session |
| `rules/*.md` | Project and global | Topic-scoped instructions, optionally path-gated |
| `settings.json` | Project and global | Permissions, hooks, env vars, model defaults |
| `settings.local.json` | Project only | Personal overrides, auto-gitignored |
| `.mcp.json` | Project only | Team-shared MCP servers |
| `.worktreeinclude` | Project only | Gitignored files to copy into new worktrees |
| `skills/<name>/SKILL.md` | Project and global | Reusable prompts invoked with `/name` |
| `commands/*.md` | Project and global | Single-file prompts (same mechanism as skills) |
| `agents/*.md` | Project and global | Subagent definitions with their own prompt and tools |
| `agent-memory/<name>/` | Project and global | Persistent memory for subagents |
| `~/.claude.json` | Global only | App state, OAuth, UI toggles, personal MCP servers |
| `projects/<project>/memory/` | Global only | Auto memory: Claude's notes to itself across sessions |
| `keybindings.json` | Global only | Custom keyboard shortcuts |
| `themes/*.json` | Global only | Custom color themes |

### Application Data Cleanup

Auto-deleted after `cleanupPeriodDays` (default 30):

| Path under `~/.claude/` | Contents |
| :--- | :--- |
| `projects/<project>/<session>.jsonl` | Full conversation transcript |
| `projects/<project>/<session>/tool-results/` | Large tool outputs |
| `file-history/<session>/` | Pre-edit file snapshots for checkpoint restore |
| `plans/` | Plan mode files |
| `debug/` | Per-session debug logs |
| `paste-cache/`, `image-cache/` | Pastes and attached images |

**Purge project state:**
```bash
claude project purge ~/work/my-repo          # Confirm then delete
claude project purge ~/work/my-repo --dry-run  # Preview only
claude project purge ~/work/my-repo --yes      # Skip confirmation
claude project purge --all                     # All projects
```

### Troubleshooting

**Claude isn't following my CLAUDE.md:**
- Run `/memory` to verify files are loaded
- Check the file is in a location that loads for your session
- Make instructions more specific
- Look for conflicting instructions across CLAUDE.md files
- For system-prompt level enforcement, use `--append-system-prompt` (scripts/automation only)
- Use the `InstructionsLoaded` hook to log which files load and when

**CLAUDE.md too large:** Use path-scoped rules to load instructions only when relevant files are open. Splitting into `@path` imports helps organization but does not reduce context.

**Instructions lost after `/compact`:** Project-root CLAUDE.md survives compaction (re-read from disk). Nested CLAUDE.md files in subdirectories reload next time Claude reads a file there. Add conversation-only instructions to CLAUDE.md to persist them.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, scopes, auto memory, .claude/rules/, /memory command, imports, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — interactive file-tree reference for every config file, when it loads, and the application data Claude writes during sessions

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
