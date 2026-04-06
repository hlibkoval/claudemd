---
name: best-practices-doc
description: Complete documentation for Claude Code best practices, common workflows, and ultraplan. Covers context window management, verification strategies (tests, screenshots, expected outputs), the explore-plan-implement-commit workflow, Plan Mode (Shift+Tab, --permission-mode plan, Ctrl+G editor), prompt specificity (scoping tasks, referencing patterns, providing symptoms), rich content inputs (@ file references, images, URLs, piped data), CLAUDE.md configuration (placement, format, pruning, @ imports), permission modes (auto mode, allowlists, sandboxing), CLI tool integration (gh, aws, gcloud), MCP servers, hooks, skills, subagents, plugins, codebase exploration (overview, find relevant code, trace execution), debugging workflows (share error, suggest fixes, apply and verify), refactoring (identify legacy code, apply changes, verify tests), test workflows (identify untested code, generate scaffolding, add edge cases, run tests), PR creation (summarize changes, create PR, enhance description), documentation generation (find undocumented code, generate docs, verify standards), image analysis (drag-and-drop, paste, file paths), @ file and directory references, extended thinking (adaptive reasoning, ultrathink keyword, effort levels, thinking toggle, MAX_THINKING_TOKENS), session management (Esc to stop, Esc+Esc or /rewind to restore, /clear to reset, /compact, /btw side questions), subagent delegation for investigation, checkpoint rewind (restore conversation/code/both), session resume (--continue, --resume, --from-pr, /resume, session naming, session picker shortcuts), git worktrees (--worktree flag, subagent worktrees, worktree cleanup, .worktreeinclude, manual management, non-git VCS), desktop notifications (Notification hook, matcher values), non-interactive mode (claude -p, --output-format text/json/stream-json), parallel sessions (desktop app, web, agent teams, writer/reviewer pattern), fan-out patterns (--allowedTools, batch scripting), auto mode for autonomous execution, common failure patterns (kitchen sink session, over-correction, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), scheduled tasks (cloud, desktop, GitHub Actions, /loop), Unix-style utility usage (linter scripts, pipe in/out), ultraplan (cloud planning from CLI, /ultraplan command, ultrathink keyword, review and revise in browser, inline comments, execute on web or send back to terminal). Load when discussing best practices, common workflows, effective prompting, context management, Plan Mode, CLAUDE.md tips, verification strategies, session management, worktrees, parallel sessions, non-interactive mode, fan-out, subagent delegation, extended thinking, ultraplan, or any usage patterns and tips for Claude Code.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and ultraplan -- patterns, tips, and step-by-step guides for getting the most out of Claude Code.

## Quick Reference

### Core Principle: Manage Context

Context window is the most important resource. Performance degrades as it fills. Every file read, command output, and message consumes tokens.

| Action | Command / Shortcut |
|:-------|:-------------------|
| Clear context between tasks | `/clear` |
| Compact with focus | `/compact <instructions>` |
| Side question without growing context | `/btw` |
| Track context usage | Custom status line (`/statusline`) |
| Partial rewind and summarize | `Esc + Esc` or `/rewind`, then **Summarize from here** |

### Verification Strategies

| Strategy | Example prompt |
|:---------|:-------------|
| Provide test cases | *"write validateEmail. test: user@example.com true, invalid false. run tests after"* |
| Visual verification | *"implement this design. take a screenshot, compare to original, list differences and fix"* |
| Root cause, not symptom | *"build fails with [error]. fix root cause, don't suppress the error"* |
| Use Chrome extension | Opens tabs, tests UI, iterates until working |

### Explore-Plan-Implement-Commit Workflow

| Phase | Mode | What to do |
|:------|:-----|:-----------|
| 1. Explore | Plan Mode | Read files, ask questions, no changes |
| 2. Plan | Plan Mode | Create detailed implementation plan; `Ctrl+G` to edit in editor |
| 3. Implement | Normal Mode | Code against the plan, run tests |
| 4. Commit | Normal Mode | Commit with descriptive message, open PR |

Skip planning for small, obvious changes. Use it for uncertain approaches, multi-file changes, or unfamiliar code.

### Plan Mode

| Entry method | How |
|:-------------|:----|
| During session | `Shift+Tab` (cycles: Normal -> Auto-Accept -> Plan) |
| New session | `claude --permission-mode plan` |
| Headless query | `claude --permission-mode plan -p "..."` |
| Default for project | `"permissions": { "defaultMode": "plan" }` in `.claude/settings.json` |
| Edit plan in editor | `Ctrl+G` |

### Prompt Specificity

| Strategy | Before | After |
|:---------|:-------|:------|
| Scope the task | *"add tests for foo.py"* | *"test foo.py edge case: logged-out user. avoid mocks"* |
| Point to sources | *"why weird API?"* | *"look through git history, summarize how API evolved"* |
| Reference patterns | *"add calendar widget"* | *"look at HotDogWidget.php pattern, build calendar widget..."* |
| Describe symptom | *"fix login bug"* | *"login fails after session timeout. check src/auth/ token refresh..."* |

### Rich Content Inputs

| Method | Usage |
|:-------|:------|
| `@` file reference | `@src/utils/auth.js` -- reads file before responding |
| Paste images | Copy/paste or drag-and-drop into prompt |
| URLs | Give documentation URLs; `/permissions` to allowlist domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to use Bash, MCP, or file reads |

### CLAUDE.md Configuration

| Location | Scope |
|:---------|:------|
| `~/.claude/CLAUDE.md` | All sessions (personal) |
| `./CLAUDE.md` | Project root (shared via git) |
| `./CLAUDE.local.md` | Project root (personal, gitignored) |
| Parent directories | Monorepo roots |
| Child directories | Loaded on demand |

**Include:** Bash commands Claude can't guess, non-default code style, test instructions, repo etiquette, architecture decisions, env quirks, common gotchas.

**Exclude:** Anything Claude can infer from code, standard conventions, detailed API docs, frequently-changing info, long tutorials, file-by-file descriptions.

Use `@path/to/import` syntax to import other files. Add emphasis ("IMPORTANT", "YOU MUST") for critical rules.

### Session Management

| Action | Command / Shortcut |
|:-------|:-------------------|
| Stop mid-action | `Esc` |
| Rewind / restore | `Esc + Esc` or `/rewind` |
| Undo changes | *"Undo that"* |
| Clear context | `/clear` |
| Resume most recent | `claude --continue` |
| Pick from recent | `claude --resume` |
| Resume by name | `claude --resume auth-refactor` |
| Resume from PR | `claude --from-pr <number>` |
| Name a session | `claude -n auth-refactor` or `/rename auth-refactor` |

### Session Picker Shortcuts (`/resume`)

| Key | Action |
|:----|:-------|
| `Up/Down` | Navigate sessions |
| `Right/Left` | Expand/collapse groups |
| `Enter` | Resume selected |
| `P` | Preview session |
| `R` | Rename session |
| `/` | Search/filter |
| `A` | Toggle current dir / all projects |
| `B` | Filter to current branch |

### Extended Thinking

| Scope | How to configure |
|:------|:----------------|
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| `ultrathink` keyword | Include in prompt for one-off high effort (Opus 4.6, Sonnet 4.6) |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Win/Linux) |
| Global default | `/config` -> `alwaysThinkingEnabled` |
| Limit budget | `MAX_THINKING_TOKENS` env var |
| View thinking | `Ctrl+O` verbose mode |

### Git Worktrees

| Command | Effect |
|:--------|:-------|
| `claude --worktree feature-auth` | Create named worktree + branch |
| `claude --worktree` | Auto-generate random name |
| `claude -w feature-auth` | Short flag |
| Subagent worktrees | `isolation: worktree` in agent frontmatter |
| Copy gitignored files | `.worktreeinclude` in project root |

Worktrees are created at `<repo>/.claude/worktrees/<name>`, branching from `origin/HEAD`. Add `.claude/worktrees/` to `.gitignore`.

### Parallel Sessions

| Method | Where it runs |
|:-------|:-------------|
| Desktop app | Local, visual session management |
| Claude Code on the web | Anthropic cloud infrastructure |
| Agent teams | Automated multi-session coordination |
| Fan-out script | `for file in $(cat files.txt); do claude -p "..." --allowedTools "Edit,Bash(git commit *)"; done` |

### Non-Interactive Mode

| Flag | Purpose |
|:-----|:--------|
| `claude -p "prompt"` | One-off query, no session |
| `--output-format text` | Plain text (default) |
| `--output-format json` | Full conversation JSON |
| `--output-format stream-json` | Streaming JSON objects |
| `--permission-mode auto` | Auto mode for unattended runs |

### Scheduled Tasks

| Option | Where it runs | Best for |
|:-------|:-------------|:---------|
| Cloud scheduled tasks | Anthropic infrastructure | Runs when computer is off |
| Desktop scheduled tasks | Local machine | Access to local files/tools |
| GitHub Actions | CI pipeline | Repo events, cron schedules |
| `/loop` | Current CLI session | Quick polling while session open |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (unrelated tasks mixed) | `/clear` between unrelated tasks |
| Repeated corrections (2+ failed fixes) | `/clear`, write better initial prompt |
| Over-specified CLAUDE.md (rules get lost) | Prune ruthlessly; convert to hooks |
| Trust-then-verify gap (no validation) | Always provide tests, scripts, screenshots |
| Infinite exploration (reads hundreds of files) | Scope narrowly or use subagents |

### Notification Hook (Desktop Alerts)

| Matcher | Fires when |
|:--------|:-----------|
| `permission_prompt` | Claude needs tool approval |
| `idle_prompt` | Claude done, waiting for prompt |
| `auth_success` | Authentication completes |
| `elicitation_dialog` | Claude asking a question |

### Common Workflows Quick Reference

| Workflow | Key steps |
|:---------|:---------|
| Explore codebase | `give me an overview` -> `explain architecture` -> `how is auth handled?` |
| Fix bugs | Share error -> suggest fixes -> apply fix -> verify |
| Refactor | Find deprecated usage -> get recommendations -> apply safely -> run tests |
| Write tests | Find untested code -> generate scaffolding -> add edge cases -> run and fix |
| Create PR | Summarize changes -> `create a pr` -> enhance description |
| Use subagents | `/agents` to view; `use the code-reviewer subagent to check...` |
| Use as linter | `claude -p 'you are a linter...'` in build scripts |
| Pipe data | `cat file \| claude -p 'analyze...' > output.txt` |

### Ultraplan

| Feature | Details |
|:--------|:--------|
| Launch | `/ultraplan <prompt>`, or include "ultraplan" in prompt, or from local plan approval dialog |
| Status indicators | `ultraplan` (drafting), `ultraplan needs your input` (question), `ultraplan ready` (review) |
| Browser review | Inline comments, emoji reactions, outline sidebar |
| Execute on web | Creates PR from cloud session |
| Send to terminal | **Implement here**, **Start new session**, or **Cancel** (saves to file) |
| Manage | `/tasks` to view, stop, or open session link |
| Requirements | Claude Code on the web account + GitHub repository |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) -- Tips and patterns for context management, verification, planning, prompting, environment configuration, session management, scaling, and common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) -- Step-by-step guides for codebase exploration, debugging, refactoring, testing, PRs, documentation, images, Plan Mode, worktrees, sessions, extended thinking, scheduling, and non-interactive usage
- [Ultraplan](references/claude-code-ultraplan.md) -- Cloud-based planning from CLI, browser review with inline comments, and flexible execution (web or terminal)

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the Cloud with Ultraplan: https://code.claude.com/docs/en/ultraplan.md
