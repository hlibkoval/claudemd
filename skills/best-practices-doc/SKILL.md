---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- effective prompting patterns (verification criteria, explore-plan-implement-commit workflow, specific context with @file references and images and piped data), environment configuration (writing effective CLAUDE.md with include/exclude guidelines and emphasis tuning and @import syntax, location hierarchy, /init starter generation, permissions setup with auto mode and allowlists and sandboxing, CLI tool integration with gh/aws/gcloud, MCP server connections, hooks for deterministic actions, skills for domain knowledge, subagents for isolated tasks, plugins for bundled extensions), communication strategies (codebase questions for onboarding, letting Claude interview you for feature specs, Plan Mode with Shift+Tab toggle and --permission-mode plan), session management (/clear between unrelated tasks, Esc to stop and Esc+Esc or /rewind to restore checkpoints, /compact with custom focus instructions, /btw for side questions, subagents for investigation to preserve main context, --continue and --resume and /rename for session persistence), automation and scaling (non-interactive mode with -p and --output-format text/json/stream-json, parallel sessions with desktop app and web and agent teams, fan-out with scripted claude -p loops and --allowedTools, auto mode with --permission-mode auto), common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), common workflows (codebase exploration and overview, finding relevant code, bug fixing with reproduction and stack traces, refactoring with backward compatibility, specialized subagents with /agents and custom agents in .claude/agents/, Plan Mode for safe analysis with Shift+Tab and Ctrl+G plan editing and defaultMode setting, test writing and coverage, PR creation with gh pr create and --from-pr resume, documentation generation, image analysis with drag-drop and paste and path reference, @file and @directory references and @server:resource MCP references, extended thinking with adaptive reasoning and effort levels and ultrathink keyword and Option+T toggle and MAX_THINKING_TOKENS, session resumption with --continue and --resume and /resume picker with keyboard shortcuts and session naming, git worktrees with --worktree flag and .claude/worktrees/ and subagent isolation and cleanup and manual management, notification hooks with Notification event and platform-specific osascript/notify-send/powershell commands, unix-style usage with piped data and --output-format and build script integration, scheduled tasks with cloud/desktop/GitHub Actions//loop options, Claude self-documentation queries). Load when discussing Claude Code best practices, effective prompting, prompt engineering for Claude Code, context management, session management, /clear, /compact, /rewind, checkpoints, Plan Mode, CLAUDE.md writing tips, environment setup, automation, parallel sessions, non-interactive mode, fan-out, common workflows, codebase exploration, debugging workflows, refactoring, test writing, PR creation, documentation, image analysis, extended thinking, ultrathink, session resumption, --continue, --resume, git worktrees, --worktree, notification hooks, unix-style usage, piped data, scheduled tasks, /loop, subagents for investigation, common mistakes, failure patterns, or general tips for getting the most out of Claude Code.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common development workflows -- effective prompting, environment configuration, session management, automation patterns, and step-by-step guides for everyday tasks.

## Quick Reference

### Core Constraint: Context Window

Claude's context window holds the entire conversation, every file read, and every command output. Performance degrades as context fills. Track usage with a custom status line and manage context aggressively.

### Give Claude Verification

The single highest-leverage practice: include tests, screenshots, or expected outputs so Claude can check its own work.

| Strategy | Before | After |
|:---------|:-------|:------|
| **Verification criteria** | "implement email validation" | "write validateEmail, test: user@example.com true, invalid false, user@.com false. run the tests after implementing" |
| **Visual verification** | "make the dashboard look better" | "[paste screenshot] implement this design, take a screenshot, compare, list differences and fix them" |
| **Root causes** | "the build is failing" | "the build fails with [error]. fix it and verify the build succeeds. address the root cause" |

UI changes can be verified with the Claude in Chrome extension.

### Explore-Plan-Implement-Commit Workflow

| Phase | Mode | What happens |
|:------|:-----|:-------------|
| **Explore** | Plan Mode | Claude reads files and answers questions, no changes |
| **Plan** | Plan Mode | Claude creates a detailed implementation plan; press Ctrl+G to edit the plan in your editor |
| **Implement** | Normal Mode | Claude codes, verifying against the plan |
| **Commit** | Normal Mode | Claude commits with a descriptive message and opens a PR |

Skip planning when the scope is clear and the fix is small. Planning is most useful when the approach is uncertain, the change spans multiple files, or you are unfamiliar with the code.

### Providing Specific Context

| Strategy | Example |
|:---------|:--------|
| **Scope the task** | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| **Point to sources** | "look through ExecutionFactory's git history and summarize how its API came to be" |
| **Reference existing patterns** | "look at how existing widgets are implemented. HotDogWidget.php is a good example. follow the pattern" |
| **Describe the symptom** | "users report login fails after session timeout. check src/auth/, especially token refresh. write a failing test, then fix it" |

Rich content methods: `@file` references, paste images, give URLs (use `/permissions` to allowlist domains), pipe data with `cat file | claude`, or let Claude fetch what it needs.

### Environment Configuration Checklist

| Setup | How | Key detail |
|:------|:----|:-----------|
| **CLAUDE.md** | `/init` to generate starter, refine over time | Keep concise; only include what Claude can't infer from code; use emphasis for critical rules |
| **Permissions** | Auto mode, `/permissions` allowlists, or `/sandbox` | Auto mode uses a classifier to block risky commands while allowing routine ones |
| **CLI tools** | Install `gh`, `aws`, `gcloud`, `sentry-cli` | Most context-efficient way to interact with external services |
| **MCP servers** | `claude mcp add` | Connect Notion, Figma, databases, monitoring |
| **Hooks** | `.claude/settings.json` or ask Claude to write one | Deterministic actions that must happen every time with zero exceptions |
| **Skills** | `.claude/skills/<name>/SKILL.md` | Domain knowledge and reusable workflows; loaded on demand |
| **Subagents** | `.claude/agents/<name>.md` | Isolated tasks with their own context, tools, and model |
| **Plugins** | `/plugin` to browse marketplace | Bundled skills, hooks, agents, and MCP servers; code intelligence plugins for typed languages |

### Writing Effective CLAUDE.md

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Branch naming and PR conventions | Information that changes frequently |
| Architectural decisions | Long explanations or tutorials |
| Developer environment quirks | File-by-file codebase descriptions |
| Common gotchas | Self-evident practices like "write clean code" |

CLAUDE.md locations: `~/.claude/CLAUDE.md` (all sessions), `./CLAUDE.md` (project root, shared via git), parent directories (monorepos), child directories (loaded on demand). Use `@path/to/import` to reference additional files.

### Communication Patterns

| Pattern | When to use |
|:--------|:------------|
| **Codebase questions** | Onboarding: "How does logging work?", "How do I make a new API endpoint?" |
| **Let Claude interview you** | Larger features: "I want to build [description]. Interview me in detail using AskUserQuestion" |
| **Plan Mode** | Multi-step implementation, code exploration, interactive iteration; toggle with Shift+Tab |

### Session Management

| Action | Command | When to use |
|:-------|:--------|:------------|
| **Stop mid-action** | `Esc` | Redirect Claude immediately |
| **Rewind** | `Esc+Esc` or `/rewind` | Restore previous conversation and code state |
| **Undo changes** | "Undo that" | Revert Claude's changes |
| **Clear context** | `/clear` | Between unrelated tasks; after 2+ failed corrections on same issue |
| **Compact context** | `/compact <focus>` | Summarize while preserving specific aspects |
| **Partial compact** | `Esc+Esc` then Summarize from here | Condense from a checkpoint forward |
| **Side question** | `/btw` | Quick question without growing context |
| **Subagent investigation** | "use subagents to investigate X" | Research in separate context, keeps main conversation clean |
| **Resume** | `claude --continue` / `claude --resume` | Pick up previous session; `/rename` to name sessions |
| **Checkpoints** | Double-tap Esc or `/rewind` | Restore conversation, code, or both to any previous checkpoint |

### Automation & Scaling

| Pattern | Command/approach |
|:--------|:-----------------|
| **Non-interactive** | `claude -p "prompt"` with `--output-format text/json/stream-json` |
| **Parallel sessions** | Desktop app, Claude Code on the web, or agent teams |
| **Fan-out** | Loop `claude -p` over file list with `--allowedTools` to scope permissions |
| **Auto mode** | `claude --permission-mode auto -p "task"` for uninterrupted execution |
| **Writer/Reviewer** | Session A implements, Session B reviews with fresh context |
| **Scheduled tasks** | Cloud tasks, desktop tasks, GitHub Actions, or `/loop` for CLI polling |

### Common Workflows

| Workflow | Key steps |
|:---------|:----------|
| **Codebase overview** | "give me an overview of this codebase" then narrow to architecture, data models, auth |
| **Find relevant code** | "find files that handle user authentication" then "how do these files work together?" |
| **Fix bugs** | Share error, ask for fix suggestions, apply fix, verify with tests |
| **Refactor** | Find deprecated usage, get recommendations, apply with tests, verify |
| **Subagents** | `/agents` to view/create; use `description` fields for auto-delegation; limit tool access |
| **Plan Mode** | Shift+Tab to toggle; `--permission-mode plan` to start in plan mode; Ctrl+G to edit plan |
| **Write tests** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **Create PRs** | "create a pr" or step-by-step; session auto-links to PR; resume with `--from-pr` |
| **Documentation** | Find undocumented code, generate docs, review, verify against standards |
| **Images** | Drag-drop, paste with Ctrl+V, or provide path; use for errors, designs, diagrams |
| **Extended thinking** | Enabled by default; `/effort` or `CLAUDE_CODE_EFFORT_LEVEL` to adjust; "ultrathink" for one-off deep reasoning |

### Extended Thinking Configuration

| Scope | How |
|:------|:----|
| **Effort level** | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| **ultrathink keyword** | Include "ultrathink" in prompt for one-off high effort |
| **Toggle** | Option+T (macOS) / Alt+T (Windows/Linux) |
| **Global default** | `/config` to toggle thinking mode |
| **Token budget** | `MAX_THINKING_TOKENS` env var (on Opus/Sonnet 4.6, only 0 applies unless adaptive reasoning disabled) |

### Git Worktrees

Start Claude in an isolated worktree with `--worktree <name>` or `claude --worktree` (auto-named). Worktrees are created at `<repo>/.claude/worktrees/<name>/` branching from the default remote branch. Add `.claude/worktrees/` to `.gitignore`.

Subagents can use worktree isolation via `isolation: worktree` in agent frontmatter. Cleanup is automatic for unchanged worktrees; Claude prompts to keep or remove if changes exist.

### Session Resumption

| Command | Purpose |
|:--------|:--------|
| `claude --continue` | Resume most recent conversation in current directory |
| `claude --resume` | Open session picker or resume by name |
| `claude --from-pr 123` | Resume sessions linked to a PR |
| `/resume` | Switch to a different conversation mid-session |
| `/rename` | Give session a descriptive name |

Session picker shortcuts: arrows to navigate, Enter to select, P to preview, R to rename, / to search, A to toggle all projects, B to filter by branch.

### Notification Hooks

Configure the `Notification` hook event in `~/.claude/settings.json` to get desktop notifications when Claude needs attention. Matchers: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`. Use platform-native commands (osascript on macOS, notify-send on Linux, PowerShell on Windows).

### Common Failure Patterns

| Pattern | Symptom | Fix |
|:--------|:--------|:----|
| **Kitchen sink session** | One task, then unrelated task, then back | `/clear` between unrelated tasks |
| **Repeated corrections** | Same fix attempted 3+ times | `/clear` and write a better initial prompt |
| **Over-specified CLAUDE.md** | Claude ignores half your rules | Prune ruthlessly; convert to hooks when possible |
| **Trust-then-verify gap** | Plausible output that misses edge cases | Always provide verification (tests, scripts, screenshots) |
| **Infinite exploration** | Unscoped investigation fills context | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices](references/claude-code-best-practices.md) -- tips and patterns for getting the most out of Claude Code; context window as the key constraint; giving Claude verification criteria (tests, screenshots, expected outputs, root cause analysis); explore-plan-implement-commit workflow with Plan Mode (Ctrl+G to edit plan); providing specific context (scoping tasks, pointing to sources, referencing existing patterns, describing symptoms); rich content input (@file references, images, URLs, piped data); environment configuration (effective CLAUDE.md writing with include/exclude guidelines and emphasis tuning and @import syntax and /init and location hierarchy and pruning, permission modes with auto mode and allowlists and sandboxing, CLI tool integration, MCP server connections, hooks for deterministic actions, skills for domain knowledge, subagents for isolated tasks, plugins from marketplace); communication strategies (codebase questions for onboarding, letting Claude interview you for feature specs); session management (Esc to stop, Esc+Esc or /rewind for checkpoints, /clear between tasks, /compact with custom instructions, /btw for side questions, subagents for investigation, --continue and --resume for session persistence); automation and scaling (non-interactive mode with -p and --output-format, parallel sessions with desktop app and web and agent teams, fan-out with scripted claude -p loops and --allowedTools, auto mode with --permission-mode auto); common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration); developing intuition for when to follow or deviate from patterns
- [Common workflows](references/claude-code-common-workflows.md) -- step-by-step guides for everyday development tasks; understanding new codebases (quick overview, finding relevant code, tracing execution flow); fixing bugs (sharing errors, getting fix recommendations, applying and verifying); refactoring (finding deprecated usage, modernization, backward compatibility, testing); specialized subagents (/agents command, automatic delegation, explicit usage, custom creation in .claude/agents/); Plan Mode for safe code analysis (Shift+Tab toggle, --permission-mode plan, Ctrl+G plan editing, headless plan queries, defaultMode setting); working with tests (finding untested code, generating scaffolding, edge cases, running and fixing); creating pull requests (summarizing changes, generating PR, --from-pr resume); handling documentation (finding undocumented code, generating docs, reviewing); working with images (drag-drop, paste with Ctrl+V, path reference, analysis, code suggestions from visual content); @file and @directory references and @server:resource MCP references; extended thinking with adaptive reasoning (effort levels, ultrathink keyword, Option+T/Alt+T toggle, /config global default, MAX_THINKING_TOKENS, verbose mode with Ctrl+O); resuming previous conversations (--continue, --resume, --from-pr, /resume picker with keyboard shortcuts, session naming with /rename); parallel sessions with git worktrees (--worktree flag, .claude/worktrees/, subagent worktree isolation, cleanup behavior, manual management, non-git VCS hooks); notification hooks (Notification event, platform-specific commands for macOS/Linux/Windows, matcher values for permission_prompt/idle_prompt/auth_success/elicitation_dialog); unix-style usage (build script integration with claude -p, piped data, --output-format text/json/stream-json); scheduled tasks (cloud/desktop/GitHub Actions//loop options); asking Claude about its own capabilities

## Sources

- Best practices: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
