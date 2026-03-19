---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context window management (context fills fast, performance degrades), verification strategies (tests, screenshots, expected outputs as highest-leverage practice), explore-plan-implement workflow (Plan Mode for research then Normal Mode for coding), specific prompts (scope tasks, point to sources, reference patterns, describe symptoms), rich content (@file references, images, piped data, URLs), environment setup (CLAUDE.md writing and pruning, /init, @imports, file placement hierarchy, permission allowlists, sandboxing, --dangerously-skip-permissions, CLI tools like gh/aws/gcloud, MCP servers, hooks for deterministic actions, skills for domain knowledge, subagents for isolated tasks, plugins for bundled extensions), effective communication (codebase questions, interview workflow with AskUserQuestion, spec generation), session management (course-correct with Esc/rewind/undo/clear, context management with /clear and /compact and /btw, subagents for investigation, checkpoints and /rewind, resume with --continue/--resume/--from-pr, /rename sessions), automation and scaling (non-interactive mode with claude -p, --output-format text/json/stream-json, parallel sessions with desktop/web/agent-teams, writer/reviewer pattern, fan-out with --allowedTools), common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), developing intuition, common workflows (codebase overview, finding code, fixing bugs, refactoring, specialized subagents, Plan Mode for safe analysis with Shift+Tab/--permission-mode plan/Ctrl+G, configure as default, working with tests, creating PRs, documentation, images, @file references, @directory references, @MCP resources, extended thinking with adaptive reasoning/effort level/ultrathink/Option+T toggle/MAX_THINKING_TOKENS, resuming sessions with --continue/--resume/--from-pr and /resume picker with keyboard shortcuts, parallel sessions with git worktrees --worktree flag and subagent worktrees and cleanup, desktop notifications via Notification hook, unix-style utility usage with claude -p in scripts/CI and piping and --output-format). Load when discussing Claude Code best practices, effective prompting, context management, verification strategies, Plan Mode, session management, parallel sessions, non-interactive mode, fan-out patterns, CLAUDE.md writing, environment setup, common workflows, codebase exploration, debugging, refactoring, testing, pull requests, documentation, extended thinking, git worktrees, resuming conversations, automation, scaling Claude Code, unix-style usage, piping data, course correction, checkpoints, subagents for investigation, writer/reviewer pattern, or developing intuition with Claude Code.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for getting the most out of Claude Code, from configuring your environment to scaling across parallel sessions, plus step-by-step guides for everyday development tasks.

## Quick Reference

Claude Code is an agentic coding environment that reads files, runs commands, makes changes, and works through problems autonomously. The key constraint: Claude's context window fills up fast, and performance degrades as it fills. Managing context is the most important thing you can do.

### Core Principles

| Principle | Key technique |
|:----------|:-------------|
| **Verify work** | Provide tests, screenshots, or expected outputs so Claude can check itself (highest-leverage practice) |
| **Explore first, then plan, then code** | Use Plan Mode for research, then switch to Normal Mode for implementation |
| **Be specific** | Reference files, mention constraints, point to example patterns |
| **Manage context aggressively** | Use `/clear` between unrelated tasks, `/compact` to summarize, `/btw` for side questions |
| **Course-correct early** | Use `Esc` to stop, `Esc+Esc` or `/rewind` to restore, `/clear` after repeated corrections |

### Verification Strategies

| Strategy | Example |
|:---------|:--------|
| Provide test cases | "write validateEmail, test with user@example.com (true), invalid (false). run the tests" |
| Verify UI visually | "[paste screenshot] implement this design. take a screenshot and compare to the original" |
| Address root causes | "the build fails with this error: [paste]. fix it and verify the build succeeds" |

### Explore-Plan-Implement Workflow

1. **Explore** (Plan Mode): read files, ask questions, no changes
2. **Plan** (Plan Mode): create detailed implementation plan; `Ctrl+G` to edit in text editor
3. **Implement** (Normal Mode): code against the plan, run tests
4. **Commit** (Normal Mode): commit and create PR

Skip planning when the scope is clear and the fix is small.

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules differing from defaults | Standard language conventions Claude already knows |
| Testing instructions and preferred runners | Detailed API documentation (link instead) |
| Branch naming, PR conventions | Information that changes frequently |
| Architectural decisions | Long explanations or tutorials |
| Developer environment quirks | File-by-file codebase descriptions |
| Common gotchas | Self-evident practices like "write clean code" |

**Key tips:** Run `/init` to generate a starter file. Keep it concise -- bloated files cause Claude to ignore instructions. Use `@path/to/import` syntax to import additional files. Add emphasis ("IMPORTANT", "YOU MUST") for critical rules. Check into git for team sharing.

**File locations:** `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project root), parent directories (monorepo), child directories (on-demand).

### Environment Setup Checklist

| Setup | How |
|:------|:----|
| CLAUDE.md | `/init` to generate, then refine over time |
| Permissions | `/permissions` to allowlist safe commands; `/sandbox` for OS-level isolation |
| CLI tools | Install `gh`, `aws`, `gcloud`, etc. for context-efficient service interaction |
| MCP servers | `claude mcp add` to connect Notion, Figma, databases, etc. |
| Hooks | Deterministic scripts at specific workflow points (unlike advisory CLAUDE.md) |
| Skills | `SKILL.md` files in `.claude/skills/` for domain knowledge and reusable workflows |
| Subagents | `.claude/agents/` for specialized assistants with isolated contexts |
| Plugins | `/plugin` to browse marketplace for bundled extensions |

### Session Management

| Action | Command |
|:-------|:--------|
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc+Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact context | `/compact <instructions>` |
| Side question (no context cost) | `/btw` |
| Summarize from checkpoint | `Esc+Esc` then "Summarize from here" |
| Resume most recent | `claude --continue` |
| Resume by name | `claude --resume <name>` |
| Resume from PR | `claude --from-pr <number>` |
| Name a session | `claude -n <name>` or `/rename <name>` |

### Automation & Scaling

| Pattern | Usage |
|:--------|:------|
| Non-interactive mode | `claude -p "prompt"` in CI, hooks, scripts |
| Output formats | `--output-format text` (default), `json`, `stream-json` |
| Parallel sessions | Desktop app, Claude Code on the web, agent teams |
| Writer/Reviewer | Session A implements, Session B reviews with fresh context |
| Fan-out | Loop `claude -p` over file list with `--allowedTools` to scope permissions |
| Pipe in/out | `cat error.log \| claude -p 'explain this' > output.txt` |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (unrelated tasks accumulate) | `/clear` between unrelated tasks |
| Repeated corrections (failed approaches clutter context) | After 2 failures, `/clear` and write a better prompt |
| Over-specified CLAUDE.md (rules get lost) | Prune ruthlessly; convert to hooks where possible |
| Trust-then-verify gap (no edge case handling) | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration (reads hundreds of files) | Scope narrowly or use subagents |

### Common Workflows

| Workflow | Key steps |
|:---------|:----------|
| Codebase exploration | Start broad, narrow down; ask questions like you would of a senior engineer |
| Bug fixing | Share error, ask for fix suggestions, apply and verify |
| Refactoring | Identify legacy code, get recommendations, apply safely, run tests |
| Testing | Identify untested code, generate scaffolding, add edge cases, run and verify |
| Pull requests | Summarize changes, `create a pr`, review and refine description |
| Documentation | Find undocumented code, generate docs, review and verify against standards |
| Images | Drag/drop, copy/paste, or provide path; analyze screenshots, mockups, diagrams |
| File references | `@path/to/file` for content, `@dir/` for listing, `@server:resource` for MCP |

### Plan Mode

Toggle with `Shift+Tab` (cycles Normal -> Auto-Accept -> Plan). Start a session in Plan Mode with `--permission-mode plan`. Configure as default in `.claude/settings.json` under `permissions.defaultMode`. Press `Ctrl+G` to open plan in text editor for direct editing.

### Extended Thinking

Enabled by default. Opus 4.6 and Sonnet 4.6 use adaptive reasoning that dynamically allocates thinking tokens based on effort level.

| Control | Method |
|:--------|:-------|
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in prompt |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` |
| Global default | `/config` to toggle |
| Limit budget | `MAX_THINKING_TOKENS` env var |
| View thinking | `Ctrl+O` for verbose mode |

### Git Worktrees for Parallel Sessions

Use `claude --worktree <name>` (or `claude -w <name>`) to create an isolated worktree. Worktrees are created at `<repo>/.claude/worktrees/<name>` branching from the default remote branch.

Subagents can also use worktree isolation with `isolation: worktree` in agent frontmatter.

**Cleanup:** no changes = auto-removed; changes exist = prompted to keep or remove. Add `.claude/worktrees/` to `.gitignore`.

### Desktop Notifications

Configure a `Notification` hook in `~/.claude/settings.json` using platform-native commands (macOS: `osascript`, Linux: `notify-send`). Matchers: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`.

### Session Picker Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Up/Down` | Navigate sessions |
| `Right/Left` | Expand/collapse grouped sessions |
| `Enter` | Resume selected session |
| `P` | Preview session |
| `R` | Rename session |
| `/` | Search/filter |
| `A` | Toggle current directory / all projects |
| `B` | Filter to current git branch |
| `Esc` | Exit picker |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) -- context window as key constraint (fills fast, performance degrades), verification strategies (tests, screenshots, expected outputs as highest-leverage practice, Claude in Chrome extension for UI), explore-plan-implement workflow (Plan Mode for research with Ctrl+G editor, Normal Mode for execution, when to skip planning), specific prompts (scope tasks, point to sources, reference patterns, describe symptoms), rich content (@file references, images, URLs, piped data), environment setup (CLAUDE.md writing with /init and pruning and @imports and placement hierarchy, permissions with allowlists and sandboxing and --dangerously-skip-permissions, CLI tools, MCP servers, hooks for deterministic actions, skills for domain knowledge, subagents for isolated tasks, plugins for bundled extensions), effective communication (codebase questions, interview workflow with AskUserQuestion and spec generation), session management (course-correct with Esc/rewind/undo/clear, context management with /clear and /compact and /btw and Esc+Esc summarize-from-here and CLAUDE.md compaction instructions, subagents for investigation, checkpoints with /rewind, resuming with --continue/--resume and /rename), automation and scaling (non-interactive mode with claude -p and --output-format, parallel sessions with desktop/web/agent-teams, writer/reviewer pattern, fan-out with --allowedTools), common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), developing intuition
- [Common workflows](references/claude-code-common-workflows.md) -- codebase exploration (overview, finding relevant code, code intelligence plugins), bug fixing (share error, suggest fixes, apply and verify), refactoring (identify legacy code, get recommendations, apply safely, verify with tests), specialized subagents (/agents, automatic delegation, explicit requests, creating custom subagents), Plan Mode for safe code analysis (when to use, Shift+Tab toggle, --permission-mode plan, headless plan queries, planning complex refactors, Ctrl+G editor, configure as default in settings), testing (identify untested code, generate scaffolding, edge cases, run and verify), creating pull requests (summarize, create, refine, --from-pr linking), documentation (find undocumented code, generate, review, verify), images (drag/drop, copy/paste, path reference, analysis, code suggestions from visual content), file and directory references (@file for content, @dir for listing, @MCP resources), extended thinking (adaptive reasoning with Opus 4.6/Sonnet 4.6, effort level, ultrathink keyword, Option+T toggle, /config global default, MAX_THINKING_TOKENS, verbose mode with Ctrl+O), resuming conversations (--continue, --resume, --from-pr, /resume, session naming with -n and /rename, session picker with keyboard shortcuts), parallel sessions with git worktrees (--worktree flag, auto-naming, subagent worktrees with isolation: worktree, cleanup behavior, .gitignore, manual management, non-git VCS hooks), desktop notifications (Notification hook with platform commands, matcher types), unix-style utility usage (claude -p in build scripts/CI, piping data, --output-format text/json/stream-json), asking Claude about its capabilities

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
