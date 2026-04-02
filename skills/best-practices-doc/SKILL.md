---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- covering context window management (context fills fast, performance degrades, /clear between tasks, /compact with instructions, auto compaction, /btw for side questions), verification strategies (tests, screenshots, linters, expected outputs, Claude in Chrome extension), explore-plan-implement workflow (Plan Mode with Shift+Tab or --permission-mode plan, Ctrl+G to edit plan, when to skip planning), prompt specificity (scope tasks, point to sources, reference patterns, describe symptoms, @ file references, paste images, pipe data, give URLs), environment configuration (CLAUDE.md writing with /init, concise rules, emphasis for adherence, @ imports, placement hierarchy, pruning), permissions (auto mode, allowlists, sandboxing), CLI tools (gh, aws, gcloud, sentry-cli, learning new CLIs), MCP servers (claude mcp add), hooks (deterministic actions, eslint after edit, block writes), skills (SKILL.md in .claude/skills/, domain knowledge, repeatable workflows), subagents (.claude/agents/, isolated context, security-reviewer example), plugins (/plugin marketplace, code intelligence), communication patterns (codebase questions, interview workflow with AskUserQuestion, spec-then-implement), session management (Esc to stop, Esc+Esc or /rewind to restore checkpoints, /clear between tasks, /compact focus instructions, subagents for investigation, --continue and --resume, /rename sessions), automation and scaling (claude -p non-interactive, --output-format json/stream-json, parallel sessions with desktop app/web/agent teams, writer-reviewer pattern, fan-out with --allowedTools, auto mode with --permission-mode auto), common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), common workflows (codebase overview, find relevant code, fix bugs, refactor, subagents with /agents, Plan Mode for safe analysis, tests, pull requests with gh pr create and --from-pr, documentation, images with drag-drop/paste/path, @ file and directory references, extended thinking with adaptive reasoning and ultrathink and effort level, resume sessions with --continue/--resume/--from-pr, session picker with keyboard shortcuts, git worktrees with --worktree/-w and .worktreeinclude and subagent worktree isolation, notifications with Notification hook, unix-style utility with pipes and --output-format, scheduled tasks with cloud/desktop/GitHub Actions//loop). Load when discussing best practices, effective prompting, context management, verification strategies, Plan Mode, environment setup, CLAUDE.md writing tips, session management, parallel sessions, automation, non-interactive mode, common workflows, debugging workflows, refactoring, testing patterns, pull request creation, git worktrees, extended thinking, or any topic about how to use Claude Code effectively.
user-invocable: false
---

# Best Practices and Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common workflows.

## Quick Reference

### Core Principle: Context Window Management

The context window is the most important resource to manage. Performance degrades as it fills. Every file read, command output, and message consumes tokens.

| Action | When to use |
|:-------|:------------|
| `/clear` | Between unrelated tasks |
| `/compact <instructions>` | Mid-session to free space while preserving key context |
| `Esc + Esc` or `/rewind` then **Summarize from here** | Compact only part of the conversation |
| `/btw` | Quick side questions that should not enter context |
| Subagents | Investigations that would read many files |

### Verification Strategies

| Strategy | Example prompt |
|:---------|:--------------|
| **Provide test cases** | "write validateEmail. test: user@example.com true, invalid false. run tests after implementing" |
| **Visual verification** | "[paste screenshot] implement this design. screenshot result, compare, list differences, fix" |
| **Root-cause debugging** | "build fails with [error]. fix and verify build succeeds. address root cause, don't suppress" |
| **Automated checks** | Test suites, linters, Bash commands, Claude in Chrome extension |

### Explore-Plan-Implement Workflow

| Phase | Mode | Action |
|:------|:-----|:-------|
| **Explore** | Plan Mode (`Shift+Tab` x2) | Read files, understand codebase |
| **Plan** | Plan Mode | Create implementation plan; `Ctrl+G` to edit in editor |
| **Implement** | Normal Mode (`Shift+Tab`) | Code against the plan, run tests |
| **Commit** | Normal Mode | Commit and open PR |

Skip planning when the change is small and the scope is clear. Planning is most useful when uncertain about the approach or modifying multiple files.

### Plan Mode

| Method | How |
|:-------|:----|
| **Toggle in session** | `Shift+Tab` (cycles Normal -> Auto-Accept -> Plan) |
| **Start in Plan Mode** | `claude --permission-mode plan` |
| **Headless Plan Mode** | `claude --permission-mode plan -p "analyze..."` |
| **Default to Plan Mode** | `"permissions": { "defaultMode": "plan" }` in `.claude/settings.json` |

### Prompt Specificity

| Strategy | Weak prompt | Strong prompt |
|:---------|:------------|:--------------|
| **Scope the task** | "add tests for foo.py" | "write a test for foo.py covering the edge case where user is logged out. avoid mocks." |
| **Point to sources** | "why does ExecutionFactory have a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| **Reference patterns** | "add a calendar widget" | "look at how widgets are implemented on the home page. HotDogWidget.php is a good example. follow the pattern..." |
| **Describe symptoms** | "fix the login bug" | "users report login fails after session timeout. check auth flow in src/auth/, especially token refresh. write a failing test, then fix" |

### Providing Rich Content

| Method | Usage |
|:-------|:------|
| `@file` | Reference files directly in prompts |
| Paste images | Copy/paste or drag-drop into prompt |
| URLs | Give doc URLs; use `/permissions` to allowlist domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to pull context via Bash, MCP, or file reads |

### CLAUDE.md Quick Tips

| Do | Don't |
|:---|:------|
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Style rules that differ from defaults | Standard language conventions |
| Test instructions and runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PRs) | Info that changes frequently |
| Architecture decisions | Long tutorials or file-by-file descriptions |

Run `/init` to generate a starter. Keep concise -- bloated files cause Claude to ignore rules. Use emphasis ("IMPORTANT", "YOU MUST") for critical rules. Use `@path` imports for external content.

### Session Management

| Key/Command | Effect |
|:------------|:-------|
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc + Esc` or `/rewind` | Open rewind menu to restore conversation/code/both |
| "Undo that" | Revert Claude's changes |
| `/clear` | Reset context between unrelated tasks |
| `/compact <focus>` | Summarize context, optionally with focus instructions |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Pick from recent sessions |
| `claude --from-pr <n>` | Resume session linked to a PR |
| `/rename <name>` | Name sessions for easy retrieval |

After two failed corrections in one session, `/clear` and start fresh with a better prompt.

### Automation and Scaling

| Pattern | Usage |
|:--------|:------|
| **Non-interactive** | `claude -p "prompt"` -- for CI, scripts, hooks |
| **Output formats** | `--output-format text\|json\|stream-json` |
| **Parallel sessions** | Desktop app, Claude Code on the web, agent teams |
| **Writer/Reviewer** | Session A implements; Session B reviews with fresh context |
| **Fan-out** | Loop `claude -p` over file list with `--allowedTools` |
| **Auto mode** | `claude --permission-mode auto -p "fix all lint errors"` |
| **Scheduled tasks** | Cloud, desktop, GitHub Actions, or `/loop` |

### Git Worktrees

| Flag/Feature | Details |
|:-------------|:--------|
| `claude --worktree <name>` or `-w` | Create isolated worktree at `.claude/worktrees/<name>/` |
| `claude --worktree` (no name) | Auto-generates random name |
| Base branch | `origin/HEAD`; sync with `git remote set-head origin -a` |
| `.worktreeinclude` | List gitignored files (`.env`, secrets) to copy into worktrees |
| Subagent worktrees | `isolation: worktree` in agent frontmatter |
| Cleanup | Auto-removed if no changes; prompted if changes exist |

### Extended Thinking

| Control | Method |
|:--------|:-------|
| **Effort level** | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| **ultrathink** | Include "ultrathink" in prompt for one-off high effort |
| **Toggle** | `Option+T` / `Alt+T` for current session |
| **Global default** | `/config` to set `alwaysThinkingEnabled` |
| **Limit budget** | `MAX_THINKING_TOKENS` env var |
| **View thinking** | `Ctrl+O` for verbose mode |

Opus 4.6 and Sonnet 4.6 use adaptive reasoning -- thinking depth scales with effort level. "think" and "think hard" are regular prompt words, not thinking controls.

### Common Workflows Quick Reference

| Workflow | Key prompts/steps |
|:---------|:------------------|
| **Codebase overview** | "give me an overview of this codebase" then narrow down |
| **Find code** | "find the files that handle user authentication" |
| **Fix bugs** | Share error -> ask for fix suggestions -> apply fix |
| **Refactor** | Identify legacy code -> get recommendations -> apply -> run tests |
| **Write tests** | Find untested code -> generate scaffolding -> add edge cases -> run |
| **Create PR** | "create a pr" (auto-links session; resume with `--from-pr`) |
| **Resume sessions** | `--continue`, `--resume`, `/resume` picker with `P` preview, `R` rename, `B` branch filter |
| **Images** | Drag-drop, paste (`Ctrl+V`), or provide path |
| **Notifications** | `Notification` hook in settings with `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` matchers |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (mixing unrelated tasks) | `/clear` between tasks |
| Repeated corrections (context polluted with failures) | `/clear` and rewrite prompt after two failures |
| Over-specified CLAUDE.md (rules getting lost) | Prune ruthlessly; convert obvious rules to hooks |
| Trust-then-verify gap (no success criteria) | Always provide tests, scripts, or screenshots |
| Infinite exploration (unbounded investigation) | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) -- Context window management, verification strategies (tests/screenshots/root-cause), explore-plan-implement workflow with Plan Mode, prompt specificity (scope/sources/patterns/symptoms), rich content (@ files/images/URLs/pipes), environment configuration (CLAUDE.md writing, permissions with auto mode/allowlists/sandboxing, CLI tools, MCP servers, hooks, skills, subagents, plugins), communication patterns (codebase questions, interview workflow with AskUserQuestion), session management (Esc/rewind/clear/compact/subagents for investigation/resume with --continue/--resume), automation and scaling (non-interactive mode with -p, parallel sessions, writer-reviewer pattern, fan-out with --allowedTools, auto mode), common failure patterns, and developing intuition
- [Common Workflows](references/claude-code-common-workflows.md) -- Step-by-step guides for codebase exploration, finding code, fixing bugs, refactoring, specialized subagents (/agents), Plan Mode for safe analysis (Shift+Tab, --permission-mode plan, Ctrl+G plan editing), testing, pull requests (gh pr create, --from-pr), documentation, image handling (drag-drop/paste/path), @ file and directory references, extended thinking (adaptive reasoning, ultrathink, effort level, toggle, MAX_THINKING_TOKENS), resuming sessions (--continue/--resume/--from-pr, /resume picker, session naming with /rename), git worktrees (--worktree/-w, .worktreeinclude, subagent isolation, cleanup, non-git VCS hooks), notifications (Notification hook with platform-specific commands), unix-style utility (claude -p in scripts, piping, --output-format text/json/stream-json), and scheduled tasks (cloud/desktop/GitHub Actions//loop)

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
