---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files, auto memory, .claude/rules/, CLAUDE.local.md, import syntax, path-scoped rules, organization-wide managed CLAUDE.md, claudeMdExcludes, load order, troubleshooting, and the .claude directory structure.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for how Claude Code remembers your project across sessions.

## Quick Reference

### Two Memory Systems

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (load order: broadest to most specific)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team members via source control |
| **Local instructions** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

### Key CLAUDE.md Rules

- Target **under 200 lines** per file — longer files reduce adherence
- Use markdown headers and bullets for structure
- Write concrete, verifiable instructions: "Use 2-space indentation" not "Format code properly"
- Avoid conflicting instructions across files
- HTML block comments (`<!-- notes -->`) are stripped before injection — use for maintainer notes

### Import Syntax

Use `@path/to/file` anywhere in CLAUDE.md to import other files into context at launch:

```text
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

- Both relative (resolved from the importing file) and absolute paths work
- Imported files can recursively import up to 5 hops deep
- Imports load into context at launch — they reduce adherence the same as adding lines directly

### AGENTS.md Compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other agents:

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

Or create a symlink: `ln -s AGENTS.md CLAUDE.md` (requires Admin/Developer Mode on Windows).

### CLAUDE.md Load Order

1. Walk up from cwd, loading `CLAUDE.md` and `CLAUDE.local.md` at each level
2. Content ordered from filesystem root down (parent loads before child)
3. Within each directory: `CLAUDE.md` then `CLAUDE.local.md`
4. Subdirectory files load on demand when Claude reads files there

Use `--add-dir` with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to also load memory from additional directories.

### `.claude/rules/` — Path-Scoped Rules

Organize instructions into topic files that load conditionally. Place `.md` files in `.claude/rules/`:

```text
.claude/
└── rules/
    ├── code-style.md   # no paths: → loads at launch
    ├── testing.md      # with paths: → loads when matching files open
    └── security.md
```

Rules with `paths:` frontmatter load only when Claude reads matching files:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "tests/**/*.test.ts"
---

# API Rules
- All endpoints must validate input
```

Path glob patterns:

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

Rules without `paths:` load unconditionally at session start. User-level rules (`~/.claude/rules/`) load before project rules (lower priority).

### Exclude CLAUDE.md Files

Skip irrelevant files in large monorepos using `claudeMdExcludes` in `.claude/settings.local.json`:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute paths. Arrays merge across settings layers. Managed policy CLAUDE.md files cannot be excluded.

### Managed (Organization-Wide) CLAUDE.md

Deploy via MDM/Ansible to the managed policy location. Alternatively, embed in `managed-settings.json`:

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

Difference from managed settings:

| Concern | Use |
| :--- | :--- |
| Block tools, commands, file paths | `permissions.deny` in managed settings |
| Enforce sandbox | `sandbox.enabled` in managed settings |
| Code style, compliance reminders | Managed CLAUDE.md |
| Behavioral guidance for Claude | Managed CLAUDE.md |

### Auto Memory

Requires Claude Code v2.1.59+. Toggle with `/memory` or:

```json
{ "autoMemoryEnabled": false }
```

Disable via env var: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

**Storage**: `~/.claude/projects/<project>/memory/` — keyed by git repository root. Shared across all worktrees of the same repo. Machine-local only.

Custom location (user settings only):

```json
{ "autoMemoryDirectory": "~/my-custom-memory-dir" }
```

**Directory structure**:

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index loaded every session (first 200 lines or 25KB)
├── debugging.md       # Topic file — Claude reads on demand
└── api-conventions.md # Topic file — Claude reads on demand
```

- `MEMORY.md` acts as the index; Claude keeps it concise by offloading detail to topic files
- Topic files are NOT loaded at startup — Claude reads them on demand
- Edit or delete any file at any time; run `/memory` to browse

### `/memory` Command

Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session. Lets you toggle auto memory. Provides a link to open the auto memory folder. Select any file to open it in your editor.

### Troubleshooting

| Problem | Steps |
| :--- | :--- |
| Claude not following CLAUDE.md | Run `/memory` to verify files are listed. Check file location. Make instructions more specific. Look for conflicts. |
| Instructions feel lost after `/compact` | Project-root CLAUDE.md re-injects after compaction. Nested CLAUDE.md files reload next time Claude reads a file there. |
| CLAUDE.md too large | Use path-scoped rules; trim content not needed every session. `@path` imports don't reduce context. |
| Unknown auto memory contents | Run `/memory` → open auto memory folder |

For instructions that must run at specific lifecycle points (before commit, after edit), use [hooks](/en/hooks-guide) instead — they execute as shell commands regardless of what Claude decides.

For system-prompt-level instructions, use `--append-system-prompt` (must be passed every invocation).

### .claude Directory — Complete File Reference

| File | Scope | Purpose |
| :--- | :--- | :--- |
| `CLAUDE.md` / `.claude/CLAUDE.md` | Project + global | Instructions loaded every session |
| `CLAUDE.local.md` | Project only (gitignored) | Personal project-specific preferences |
| `.claude/rules/*.md` | Project + global | Topic-scoped instructions, optionally path-gated |
| `.claude/settings.json` | Project + global | Permissions, hooks, env vars, model defaults |
| `.claude/settings.local.json` | Project only | Personal settings overrides, auto-gitignored |
| `.claude/skills/<name>/SKILL.md` | Project + global | Reusable prompts invoked with `/name` |
| `.claude/agents/*.md` | Project + global | Subagent definitions |
| `.claude/agent-memory/<name>/` | Project | Persistent memory for subagents with `memory: project` |
| `~/.claude/projects/<project>/memory/` | Global | Auto memory — Claude's notes per project |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, CLAUDE.local.md, import syntax, rules, auto memory, /memory command, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — complete file tree reference for project and global configuration directories

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
