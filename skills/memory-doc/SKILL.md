---
name: memory-doc
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory — how Claude retains knowledge across sessions using CLAUDE.md files, `.claude/rules/`, and auto memory.

## Quick Reference

### Two Memory Systems Compared

| | CLAUDE.md files | Auto memory |
| :--- | :--- | :--- |
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per repository, shared across worktrees |
| **Loaded into** | Every session | Every session (first 200 lines or 25KB) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md File Locations (load order, broadest → most specific)

| Scope | Location | Shared with |
| :--- | :--- | :--- |
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in organization |
| **User instructions** | `~/.claude/CLAUDE.md` | Just you (all projects) |
| **Project instructions** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team (via source control) |
| **Local instructions** | `./CLAUDE.local.md` (add to `.gitignore`) | Just you (current project) |

Files in ancestor directories load at launch (broadest to closest). Files in subdirectories load on demand when Claude reads files there.

### Writing Effective CLAUDE.md Instructions

| Guideline | Detail |
| :--- | :--- |
| **Size** | Target under 200 lines per file; longer files reduce adherence |
| **Structure** | Use markdown headers and bullets; organized sections are easier to follow |
| **Specificity** | Concrete and verifiable: "Use 2-space indentation" not "Format code properly" |
| **Consistency** | Review periodically for contradictions across nested files and rules |

### File Import Syntax

Use `@path/to/file` anywhere in CLAUDE.md to import another file. Both relative and absolute paths work. Relative paths resolve from the file containing the import. Maximum import depth: 4 hops. Imported files are expanded into context at launch.

Example:
```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

### AGENTS.md Compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other tools:

```markdown
@AGENTS.md

## Claude Code

Use plan mode for changes under `src/billing/`.
```

Or create a symlink: `ln -s AGENTS.md CLAUDE.md` (Windows: use the `@AGENTS.md` import instead, symlinks require elevated privileges).

### `.claude/rules/` — Path-Scoped Instructions

Rules files live in `.claude/rules/` (project) or `~/.claude/rules/` (user). Files without `paths:` frontmatter load at session start like CLAUDE.md. Files with `paths:` load only when Claude reads a matching file.

**Example rule with path scoping:**
```markdown
---
paths:
  - "src/api/**/*.ts"
  - "**/*.test.ts"
---

# API Rules
- Validate all inputs with Zod schemas
- Return shape: { data: T } | { error: string }
```

**Glob pattern examples:**

| Pattern | Matches |
| :--- | :--- |
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

Rules directories support symlinks for sharing across projects. User-level rules (`~/.claude/rules/`) load before project rules.

### Excluding CLAUDE.md Files

Use `claudeMdExcludes` in `.claude/settings.local.json` to skip specific files in monorepos:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute paths using glob syntax. Managed policy CLAUDE.md cannot be excluded.

### Managed Organization CLAUDE.md

Put behavioral instructions in `managed-settings.json` using the `claudeMd` key instead of deploying a separate file:

```json
{
  "claudeMd": "Always run `make lint` before committing.\nNever push directly to main."
}
```

| Concern | Configure in |
| :--- | :--- |
| Block tools, commands, or file paths | `permissions.deny` in managed settings |
| Enforce sandbox isolation | `sandbox.enabled` in managed settings |
| Code style and quality guidelines | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### Auto Memory

Auto memory requires Claude Code v2.1.59 or later. Check with `claude --version`.

**Storage location:**

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Concise index, loaded into every session
├── debugging.md       # Topic file — Claude reads on demand
├── api-conventions.md # Topic file — Claude reads on demand
└── ...
```

All worktrees and subdirectories within the same git repository share one auto memory directory. Auto memory is machine-local (not synced across machines).

**Loading behavior:**
- First 200 lines of `MEMORY.md`, or first 25KB, whichever comes first, load at session start
- Topic files (e.g., `debugging.md`) are not loaded at startup — Claude reads them on demand
- CLAUDE.md files are always loaded in full regardless of length

**Enable/disable:**

```json
{
  "autoMemoryEnabled": false
}
```

Or set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` as an environment variable. Toggle within a session via `/memory`.

**Custom storage location:**

```json
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

Must be an absolute path or start with `~/`. When set in project settings, requires workspace trust dialog acceptance.

### Managing Memory with `/memory`

The `/memory` command:
- Lists all CLAUDE.md, CLAUDE.local.md, and rules files loaded in the current session
- Provides a toggle for auto memory on/off
- Links to open the auto memory folder
- Lets you select any file to open it in your editor

### Loading from Additional Directories

The `--add-dir` flag gives Claude access to additional directories. To also load their CLAUDE.md files:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

This loads `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `CLAUDE.local.md` from the additional directory.

### Troubleshooting

| Symptom | Action |
| :--- | :--- |
| Claude isn't following CLAUDE.md | Run `/memory` to verify the file is loaded; check location; make instructions more specific; look for conflicts |
| Instructions lost after `/compact` | Project-root CLAUDE.md re-injects on compact; nested subdirectory files do not — add to CLAUDE.md |
| CLAUDE.md too large | Use path-scoped rules; trim content not needed every session |
| Don't know what auto memory saved | Run `/memory` and select the auto memory folder; everything is plain markdown |
| Need to enforce an instruction | Use a [PreToolUse hook](/en/hooks-guide) instead — hooks are enforced, CLAUDE.md is guidance |

**InstructionsLoaded hook:** Use this hook to log exactly which instruction files are loaded, when, and why — useful for debugging path-specific rules or lazy-loaded subdirectory files.

### `.claude` Directory — Key Memory-Related Files

| File | Loaded when | Notes |
| :--- | :--- | :--- |
| `CLAUDE.md` / `.claude/CLAUDE.md` | Every session | Project instructions; commit to share with team |
| `CLAUDE.local.md` | Every session | Personal per-project preferences; add to `.gitignore` |
| `.claude/rules/*.md` | Session start (no `paths:`); on file read (with `paths:`) | Modular instructions, optionally path-scoped |
| `~/.claude/CLAUDE.md` | Every session | Personal preferences across all projects |
| `~/.claude/rules/*.md` | Session start or on file read | User-level rules for all projects |
| `~/.claude/projects/<project>/memory/MEMORY.md` | Session start (first 200 lines / 25KB) | Auto memory index; Claude maintains this |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude Remembers Your Project](references/claude-code-memory.md) — CLAUDE.md files, auto memory, rules, imports, troubleshooting
- [Explore the .claude Directory](references/claude-code-claude-directory.md) — Interactive directory reference: every config file, when it loads, and examples

## Sources

- How Claude Remembers Your Project: https://code.claude.com/docs/en/memory.md
- Explore the .claude Directory: https://code.claude.com/docs/en/claude-directory.md
