---
name: memory-doc
description: Complete official documentation for Claude Code memory — CLAUDE.md files, auto memory, .claude/rules/, the .claude directory layout, and all config files Claude reads at startup.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code memory and the `.claude` directory.

## Quick Reference

Claude Code carries knowledge across sessions through two complementary mechanisms: **CLAUDE.md files** (instructions you write) and **auto memory** (notes Claude writes itself). Both are loaded at the start of every conversation.

### CLAUDE.md vs auto memory

|                      | CLAUDE.md files                                   | Auto memory                                                      |
| :------------------- | :------------------------------------------------ | :--------------------------------------------------------------- |
| **Who writes it**    | You                                               | Claude                                                           |
| **What it contains** | Instructions and rules                            | Learnings and patterns                                           |
| **Scope**            | Project, user, or org                             | Per working tree                                                 |
| **Loaded into**      | Every session                                     | Every session (first 200 lines or 25KB)                          |
| **Use for**          | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences Claude discovers |

### CLAUDE.md file locations

More specific locations take precedence over broader ones.

| Scope                | Location                                                                                                                                                                | Shared with                     |
| :------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------ |
| **Managed policy**   | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` · Linux/WSL: `/etc/claude-code/CLAUDE.md` · Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`                | All users in organization       |
| **Project**          | `./CLAUDE.md` or `./.claude/CLAUDE.md`                                                                                                                                  | Team members via source control |
| **User**             | `~/.claude/CLAUDE.md`                                                                                                                                                   | Just you (all projects)         |
| **Local**            | `./CLAUDE.local.md` (add to `.gitignore`)                                                                                                                               | Just you (current project)      |

### Writing effective CLAUDE.md

- **Size**: target under 200 lines per file. Longer files still load but may reduce adherence.
- **Structure**: use markdown headers and bullets to group related instructions.
- **Specificity**: write verifiable rules — "Use 2-space indentation" not "Format code properly".
- **Consistency**: conflicting instructions across files cause arbitrary behavior — review periodically.
- Use `@path/to/file` syntax to import other files (max 5 hops deep). Imported files load into context at launch.
- Block-level HTML comments (`<!-- notes -->`) are stripped before injection — use them for maintainer notes without spending context tokens.
- Run `/init` to auto-generate a starting CLAUDE.md from your codebase.

### .claude/rules/

Break large CLAUDE.md files into topic-specific files under `.claude/rules/`. Rules without `paths:` frontmatter load at session start. Rules with `paths:` load only when Claude reads a matching file.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Rules
- All endpoints must validate input with Zod
```

| Pattern                | Matches                               |
| :--------------------- | :------------------------------------ |
| `**/*.ts`              | All TypeScript files in any directory |
| `src/**/*`             | All files under `src/`                |
| `*.md`                 | Markdown files in project root        |
| `src/components/*.tsx` | React components in a specific dir    |

User-level rules at `~/.claude/rules/` apply to every project. Project rules take precedence.

### CLAUDE.md loading order

- Walking up the directory tree from your working directory, each `CLAUDE.md` and `CLAUDE.local.md` found is loaded and concatenated (not overridden).
- `CLAUDE.local.md` is appended after `CLAUDE.md` at each level — personal notes win on conflict.
- Subdirectory CLAUDE.md files load on demand when Claude reads files in those directories.
- Use `claudeMdExcludes` in settings to skip specific paths by glob in large monorepos.
- Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` with `--add-dir` to also load memory from additional directories.

### AGENTS.md compatibility

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. To share instructions with other agents, create a `CLAUDE.md` that imports `AGENTS.md`:

```markdown
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

### Auto memory

Auto memory requires Claude Code v2.1.59 or later.

| Setting                | Description                                                                   |
| :--------------------- | :---------------------------------------------------------------------------- |
| `autoMemoryEnabled`    | Toggle auto memory on/off (default: `true`)                                   |
| `autoMemoryDirectory`  | Override default storage location (user/local settings only, not project)     |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` | Environment variable to disable                              |

**Storage**: `~/.claude/projects/<project>/memory/` — derived from git repo, shared across worktrees.

**Structure**:

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # Index, loaded every session (first 200 lines / 25KB)
├── debugging.md       # Topic file (read on demand, not at startup)
└── api-conventions.md
```

- `MEMORY.md` is the session-start index; topic files are read on demand.
- Auto memory is machine-local and not shared across machines.
- Use `/memory` to browse, toggle, and open memory files from within a session.

### Exclude CLAUDE.md files (large monorepos)

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match absolute file paths. Managed policy CLAUDE.md files cannot be excluded.

### Managed vs settings — what goes where

| Concern                                       | Configure in                                              |
| :-------------------------------------------- | :-------------------------------------------------------- |
| Block tools, commands, or file paths          | Managed settings: `permissions.deny`                      |
| Enforce sandbox isolation                     | Managed settings: `sandbox.enabled`                       |
| Code style and quality guidelines             | Managed CLAUDE.md                                         |
| Data handling and compliance reminders        | Managed CLAUDE.md                                         |

### .claude directory layout (key files)

| File                          | Scope              | Commit | Purpose                                              |
| :---------------------------- | :----------------- | :----- | :--------------------------------------------------- |
| `CLAUDE.md`                   | Project and global | yes    | Instructions loaded every session                    |
| `rules/*.md`                  | Project and global | yes    | Topic-scoped instructions, optionally path-gated     |
| `settings.json`               | Project and global | yes    | Permissions, hooks, env vars, model defaults         |
| `settings.local.json`         | Project only       | no     | Personal overrides, auto-gitignored                  |
| `.mcp.json`                   | Project only       | yes    | Team-shared MCP servers                              |
| `skills/<name>/SKILL.md`      | Project and global | yes    | Reusable prompts invoked with `/name`                |
| `agents/*.md`                 | Project and global | yes    | Subagent definitions                                 |
| `agent-memory/<name>/`        | Project and global | yes    | Persistent memory for subagents                      |
| `~/.claude.json`              | Global only        | no     | App state, OAuth, UI toggles, personal MCP servers   |
| `projects/<project>/memory/`  | Global only        | no     | Auto memory: Claude's notes across sessions          |
| `keybindings.json`            | Global only        | no     | Custom keyboard shortcuts                            |

### Troubleshooting

| Symptom                                    | Fix                                                                                           |
| :----------------------------------------- | :-------------------------------------------------------------------------------------------- |
| Claude isn't following CLAUDE.md           | Run `/memory` to verify the file is loaded; make instructions more specific; check for conflicts |
| I don't know what auto memory saved        | Run `/memory` and select the auto memory folder to browse                                     |
| CLAUDE.md is too large                     | Use path-scoped rules or trim content not needed every session                                |
| Instructions lost after `/compact`         | Project-root CLAUDE.md re-injects after compact; nested files reload next time files are read |

For instructions at the system prompt level (stronger than context), use `--append-system-prompt` (scripts/automation only). Use the `InstructionsLoaded` hook to debug which instruction files load and when.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) — CLAUDE.md files, auto memory, .claude/rules/, import syntax, managed CLAUDE.md, troubleshooting
- [Explore the .claude directory](references/claude-code-claude-directory.md) — full directory layout for project and global config, file reference table, application data, and cleanup

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
- Explore the .claude directory: https://code.claude.com/docs/en/claude-directory.md
