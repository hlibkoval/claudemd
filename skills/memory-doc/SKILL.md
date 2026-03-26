---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files and auto memory. Covers CLAUDE.md file locations and scopes (managed policy at /Library/Application Support/ClaudeCode/ or /etc/claude-code/ or C:\Program Files\ClaudeCode\, project at ./CLAUDE.md or ./.claude/CLAUDE.md, user at ~/.claude/CLAUDE.md), writing effective instructions (size under 200 lines, structure with markdown, specificity, consistency), importing files with @path syntax (relative paths, recursive up to 5 hops, external imports approval), AGENTS.md compatibility (@AGENTS.md import), CLAUDE.md loading order (walks up directory tree, subdirectory on-demand loading, HTML comment stripping, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), .claude/rules/ directory (path-specific rules with paths frontmatter and glob patterns, unconditional rules loaded at launch, symlinks for shared rules, user-level rules at ~/.claude/rules/), managing CLAUDE.md for large teams (organization-wide managed policy deployment, claudeMdExcludes setting with glob patterns for monorepos, managed CLAUDE.md cannot be excluded), auto memory (enabled by default, autoMemoryEnabled setting, CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 env var, storage at ~/.claude/projects/<project>/memory/ derived from git repo, autoMemoryDirectory setting in policy/local/user not project, MEMORY.md entrypoint with 200-line load limit, topic files loaded on demand, /memory command for browsing and toggling), /init command for generating starting CLAUDE.md (CLAUDE_CODE_NEW_INIT=true for interactive multi-phase flow), troubleshooting (CLAUDE.md not followed -- check /memory listing and specificity and conflicts, --append-system-prompt for system-level instructions, InstructionsLoaded hook for debugging, auto memory audit via /memory, large CLAUDE.md split with @imports or .claude/rules/, /compact preserves CLAUDE.md). Load when discussing CLAUDE.md, memory, auto memory, project instructions, .claude/rules/, rules files, path-specific rules, /memory command, /init command, MEMORY.md, autoMemoryEnabled, claudeMdExcludes, managed CLAUDE.md, @imports in CLAUDE.md, AGENTS.md, remembering preferences, persistent instructions, or any memory-related topic for Claude Code.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code's memory systems -- CLAUDE.md files for persistent instructions and auto memory for automatic learning across sessions.

## Quick Reference

Claude Code starts each session with a fresh context window. Two mechanisms carry knowledge across sessions:

- **CLAUDE.md files**: instructions you write to give Claude persistent context
- **Auto memory**: notes Claude writes itself based on your corrections and preferences

Both are loaded at the start of every conversation. Claude treats them as context, not enforced configuration.

### CLAUDE.md vs Auto Memory

| | CLAUDE.md files | Auto memory |
|:--|:----------------|:------------|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session (full file) | Every session (first 200 lines of MEMORY.md) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, discovered preferences |

### CLAUDE.md File Locations

| Scope | Location | Shared with |
|:------|:---------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | All users in org (cannot be excluded) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Just you (all projects) |

Files in the directory hierarchy above the working directory load in full at launch. Files in subdirectories load on demand when Claude reads files in those directories.

### Writing Effective Instructions

- **Size**: target under 200 lines per file; longer files reduce adherence
- **Structure**: use markdown headers and bullets
- **Specificity**: "Use 2-space indentation" not "Format code properly"
- **Consistency**: conflicting rules may be followed arbitrarily; review periodically
- Run `/init` to generate a starting CLAUDE.md (set `CLAUDE_CODE_NEW_INIT=true` for interactive multi-phase flow)

### Importing Files

Use `@path/to/file` syntax anywhere in CLAUDE.md to import additional files into context at launch:

```
See @README for project overview and @package.json for npm commands.
@docs/git-instructions.md
@~/.claude/my-project-instructions.md
```

- Relative paths resolve relative to the file containing the import
- Recursive imports up to 5 hops deep
- First encounter triggers an approval dialog for external imports

### AGENTS.md Compatibility

Import an existing `AGENTS.md` so both tools read the same instructions:

```
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

### CLAUDE.md Loading Behavior

- Walks up the directory tree from cwd, loading each CLAUDE.md found
- Subdirectory CLAUDE.md files load on demand when Claude reads files there
- HTML comments (`<!-- ... -->`) are stripped before injection (use for maintainer notes)
- `--add-dir` directories do not load CLAUDE.md by default; set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to enable

### .claude/rules/ Directory

Organize instructions into modular files under `.claude/rules/`. Each `.md` file covers one topic.

```
.claude/
  CLAUDE.md
  rules/
    code-style.md
    testing.md
    security.md
```

**Unconditional rules** (no frontmatter): loaded at launch with same priority as `.claude/CLAUDE.md`.

**Path-specific rules**: use `paths` frontmatter with glob patterns; load only when Claude works with matching files:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
---
# API Development Rules
...
```

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |

**Symlinks**: supported for sharing rules across projects. Circular symlinks are detected.

**User-level rules**: `~/.claude/rules/*.md` apply to every project; loaded before project rules (lower priority).

### claudeMdExcludes

Skip irrelevant CLAUDE.md files in monorepos via the `claudeMdExcludes` setting:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match against absolute paths using glob syntax. Configurable at any settings layer (user, project, local, managed policy). Managed policy CLAUDE.md files cannot be excluded.

### Auto Memory

Auto memory lets Claude accumulate knowledge across sessions automatically. Claude saves build commands, debugging insights, architecture notes, code style preferences, and workflow habits when it judges they would be useful in future conversations.

| Setting | Purpose |
|:--------|:--------|
| `autoMemoryEnabled` | Toggle in project settings (default: `true`) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` | Disable via env var |
| `autoMemoryDirectory` | Custom storage location (accepted in policy, local, user settings; not project settings) |
| `/memory` | Browse, toggle, and open memory files in editor |

**Storage**: `~/.claude/projects/<project>/memory/` (derived from git repo; all worktrees share one directory).

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Index, first 200 lines loaded every session
  debugging.md       # Topic file, loaded on demand
  api-conventions.md # Topic file, loaded on demand
```

`MEMORY.md` acts as an index. Content beyond line 200 is not loaded at session start. Topic files are read on demand by Claude when needed. Auto memory is machine-local and not shared across machines.

### Troubleshooting

| Issue | Solution |
|:------|:---------|
| Claude not following CLAUDE.md | Run `/memory` to verify file is loaded; make instructions more specific; check for conflicts across files |
| System-level instructions needed | Use `--append-system-prompt` (must be passed every invocation) |
| Debug which files load and when | Use the `InstructionsLoaded` hook |
| Unknown auto memory contents | Run `/memory` to browse; all files are plain editable markdown |
| CLAUDE.md too large | Move content to `@path` imports or `.claude/rules/` files |
| Instructions lost after `/compact` | CLAUDE.md survives compaction; conversation-only instructions do not -- add them to CLAUDE.md |

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md files and auto memory overview, CLAUDE.md vs auto memory comparison, file locations and scopes (managed policy, project, user), writing effective instructions (size, structure, specificity, consistency), /init command (CLAUDE_CODE_NEW_INIT interactive flow), importing files with @path syntax (relative paths, recursive up to 5 hops, external imports approval dialog), AGENTS.md compatibility, CLAUDE.md loading order (directory tree walk, subdirectory on-demand, HTML comment stripping, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), .claude/rules/ directory (path-specific rules with paths frontmatter and glob patterns, unconditional rules, symlinks, user-level rules at ~/.claude/rules/), managing for large teams (organization-wide managed policy deployment via MDM/Ansible, managed CLAUDE.md vs managed settings comparison, claudeMdExcludes with glob patterns, managed CLAUDE.md cannot be excluded), auto memory (enabled by default, autoMemoryEnabled setting, CLAUDE_CODE_DISABLE_AUTO_MEMORY=1, storage at ~/.claude/projects/<project>/memory/ derived from git repo, autoMemoryDirectory in policy/local/user, MEMORY.md 200-line load limit, topic files on demand, machine-local), /memory command (list loaded files, toggle auto memory, open in editor), subagent auto memory reference, troubleshooting (CLAUDE.md not followed, --append-system-prompt, InstructionsLoaded hook, auto memory audit, large CLAUDE.md splitting, /compact behavior)

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
