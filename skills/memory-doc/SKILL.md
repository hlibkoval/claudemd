---
name: memory-doc
description: Complete documentation for Claude Code memory systems -- CLAUDE.md files (project/user/managed-policy scopes, location hierarchy, subdirectory lazy-loading, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD, @path import syntax with recursive imports up to 5 hops, /init interactive setup with CLAUDE_CODE_NEW_INIT, writing effective instructions with size/structure/specificity/consistency guidelines, claudeMdExcludes for monorepo filtering), .claude/rules/ directory (path-specific rules with glob patterns in YAML frontmatter paths field, unconditional rules, recursive discovery, symlink support, user-level rules in ~/.claude/rules/), managed policy CLAUDE.md (macOS/Linux/Windows locations, IT/DevOps deployment, MDM/Ansible/Group Policy distribution, cannot be excluded), auto memory (Claude-written notes persisted across sessions, MEMORY.md entrypoint with 200-line context limit, topic files loaded on demand, storage at ~/.claude/projects/<project>/memory/, autoMemoryEnabled toggle, autoMemoryDirectory custom path, /memory command, git-repo-scoped sharing across worktrees), /memory command (list loaded files, toggle auto memory, open memory folder, edit files in editor), troubleshooting (instructions not followed -- check /memory listing and specificity and conflicts, auto memory audit -- /memory browse, CLAUDE.md too large -- split with @imports or .claude/rules/, instructions lost after /compact -- CLAUDE.md survives compaction but conversation-only instructions do not, --append-system-prompt for system prompt level). Load when discussing CLAUDE.md files, memory, auto memory, .claude/rules/, project instructions, user instructions, managed policy CLAUDE.md, /init, @imports, path-specific rules, claudeMdExcludes, /memory command, MEMORY.md, memory troubleshooting, instructions not followed, effective CLAUDE.md writing, organization-wide instructions, monorepo CLAUDE.md management, or persistent context across sessions.
user-invocable: false
---

# Memory Documentation

This skill provides the complete official documentation for Claude Code's memory systems -- CLAUDE.md files for persistent instructions you write, auto memory for notes Claude accumulates on its own, and .claude/rules/ for modular path-scoped rules.

## Quick Reference

Claude Code starts each session with a fresh context window. Two mechanisms carry knowledge across sessions: **CLAUDE.md files** (instructions you write) and **auto memory** (notes Claude writes itself). Both are loaded at the start of every conversation.

### CLAUDE.md vs Auto Memory

| | CLAUDE.md files | Auto memory |
|:---|:---|:---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session (full file) | Every session (first 200 lines of MEMORY.md) |
| **Use for** | Coding standards, workflows, architecture | Build commands, debugging insights, preferences |

### CLAUDE.md File Locations

| Scope | Location | Purpose | Shared with |
|:------|:---------|:--------|:------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Organization-wide instructions | All users in org |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared project instructions | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you |

Files in the directory hierarchy above the working directory are loaded in full at launch. Files in subdirectories load on demand when Claude reads files in those directories.

### Writing Effective Instructions

| Guideline | Detail |
|:----------|:-------|
| **Size** | Target under 200 lines per file; longer files reduce adherence |
| **Structure** | Use markdown headers and bullets to group related instructions |
| **Specificity** | Concrete and verifiable: "Use 2-space indentation" not "Format code properly" |
| **Consistency** | Remove conflicting or outdated rules; check across all CLAUDE.md and rules files |

Run `/init` to generate a starter CLAUDE.md. Set `CLAUDE_CODE_NEW_INIT=true` for an interactive multi-phase flow.

### @Import Syntax

Reference additional files with `@path/to/import` anywhere in a CLAUDE.md. Both relative and absolute paths are supported. Relative paths resolve from the file containing the import, not the working directory. Imports can recurse up to 5 hops deep.

```
See @README for project overview and @package.json for available npm commands.

# Individual Preferences
- @~/.claude/my-project-instructions.md
```

First-time external imports show an approval dialog.

### .claude/rules/ Directory

Place markdown files in `.claude/rules/` for modular, topic-specific instructions. Files are discovered recursively, and symlinks are supported.

**Unconditional rules** (no frontmatter) load at launch with the same priority as `.claude/CLAUDE.md`.

**Path-specific rules** use YAML frontmatter with a `paths` field to scope to matching files:

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All API endpoints must include input validation
```

Path-scoped rules load when Claude reads files matching the pattern.

| Pattern | Matches |
|:--------|:--------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

Multiple patterns and brace expansion (`*.{ts,tsx}`) are supported.

**User-level rules** in `~/.claude/rules/` apply to every project on your machine, loaded before project rules.

### Additional Directories

Use `--add-dir` to give Claude access to directories outside the main working directory. CLAUDE.md files from additional directories are not loaded by default. Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to also load them:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### claudeMdExcludes

Skip irrelevant CLAUDE.md files in monorepos using `claudeMdExcludes` in settings:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match against absolute file paths. Configurable at user, project, local, or managed policy layers (arrays merge). Managed policy CLAUDE.md files cannot be excluded.

### Auto Memory

Auto memory lets Claude accumulate knowledge across sessions without you writing anything. Claude saves build commands, debugging insights, architecture notes, code style preferences, and workflow habits when it determines the information would be useful later.

| Setting | Detail |
|:--------|:-------|
| **Toggle** | `/memory` command, or `autoMemoryEnabled: false` in project settings, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| **Storage** | `~/.claude/projects/<project>/memory/` |
| **Custom directory** | `autoMemoryDirectory` in user or local settings (not project settings) |
| **Context loading** | First 200 lines of `MEMORY.md` loaded at session start; topic files read on demand |
| **Scope** | Machine-local; all worktrees/subdirectories in the same git repo share one directory |
| **Requires** | Claude Code v2.1.59 or later |

Storage structure:

```
~/.claude/projects/<project>/memory/
  MEMORY.md          # Concise index, loaded every session
  debugging.md       # Detailed notes (loaded on demand)
  api-conventions.md # API design decisions (loaded on demand)
```

### /memory Command

Lists all CLAUDE.md and rules files loaded in the current session. Provides toggles for auto memory and a link to open the memory folder. Select any file to open it in your editor.

To ask Claude to remember something (e.g., "always use pnpm, not npm"), it saves to auto memory. To add instructions to CLAUDE.md instead, ask explicitly ("add this to CLAUDE.md") or edit the file yourself via `/memory`.

### Managed Policy vs Managed Settings

| Concern | Configure in |
|:--------|:-------------|
| Block specific tools, commands, or file paths | Managed settings: `permissions.deny` |
| Enforce sandbox isolation | Managed settings: `sandbox.enabled` |
| Environment variables and API provider routing | Managed settings: `env` |
| Authentication method and organization lock | Managed settings: `forceLoginMethod`, `forceLoginOrgUUID` |
| Code style and quality guidelines | Managed CLAUDE.md |
| Data handling and compliance reminders | Managed CLAUDE.md |
| Behavioral instructions for Claude | Managed CLAUDE.md |

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Claude isn't following CLAUDE.md | Run `/memory` to verify files are loaded; check file location is reachable; make instructions more specific; look for conflicting instructions across files |
| Don't know what auto memory saved | Run `/memory` and select the auto memory folder to browse plain markdown files |
| CLAUDE.md is too large | Move detailed content into `@path` imports or split into `.claude/rules/` files |
| Instructions lost after `/compact` | CLAUDE.md survives compaction; conversation-only instructions do not -- add them to CLAUDE.md |
| System-prompt-level instructions needed | Use `--append-system-prompt` (must be passed every invocation; suited for scripts/automation) |

Use the `InstructionsLoaded` hook to log which instruction files are loaded, when, and why -- useful for debugging path-specific rules or lazy-loaded subdirectory files.

## Full Documentation

For the complete official documentation, see the reference files:

- [How Claude remembers your project](references/claude-code-memory.md) -- CLAUDE.md files (project/user/managed-policy scopes, location hierarchy with directory walk-up and subdirectory lazy-loading, /init with CLAUDE_CODE_NEW_INIT interactive mode, writing effective instructions with size/structure/specificity/consistency, @import syntax with relative/absolute paths and recursive imports up to 5 hops, first-time approval dialog, load resolution order, --add-dir with CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), .claude/rules/ directory (setup with topic-specific markdown files, path-specific rules with YAML frontmatter paths field and glob patterns, recursive discovery, symlink support, user-level rules in ~/.claude/rules/), managing CLAUDE.md for large teams (organization-wide managed policy deployment at OS-specific paths, MDM/Ansible/Group Policy distribution, managed CLAUDE.md vs managed settings distinction, claudeMdExcludes for monorepo filtering with glob patterns), auto memory (Claude-written notes across sessions, enable/disable with /memory toggle or autoMemoryEnabled or CLAUDE_CODE_DISABLE_AUTO_MEMORY, storage at ~/.claude/projects/<project>/memory/ with git-repo scoping, autoMemoryDirectory custom path from policy/local/user settings, MEMORY.md entrypoint with 200-line context limit, topic files on demand, audit and edit as plain markdown), /memory command (list loaded files, toggle auto memory, open folder, edit in editor, "remember" saves to auto memory vs explicit CLAUDE.md), troubleshooting (instructions not followed -- /memory verification and location and specificity and conflicts, auto memory audit, CLAUDE.md too large -- @imports and .claude/rules/, instructions lost after /compact -- CLAUDE.md survives but conversation instructions do not, --append-system-prompt for system-prompt level, InstructionsLoaded hook for debugging)

## Sources

- How Claude remembers your project: https://code.claude.com/docs/en/memory.md
