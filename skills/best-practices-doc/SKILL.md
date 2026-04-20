---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices — prompting patterns, context management, environment configuration, common workflows, Plan Mode, parallel sessions, ultraplan, and ultrareview.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, ultraplan, and ultrareview.

## Quick Reference

### Core principle

Claude's context window is the most important resource to manage. Performance degrades as context fills. Use `/clear` between unrelated tasks, `/compact` to summarize, and subagents to offload exploration.

### Highest-leverage practices

| Practice | Why it matters |
| :------- | :------------- |
| **Give Claude a way to verify its work** | Tests, screenshots, linter checks let Claude self-correct instead of relying on you |
| **Explore, plan, then code** | Separate research (Plan Mode) from implementation to avoid solving the wrong problem |
| **Provide specific context** | Reference files with `@`, paste images, give URLs, pipe data — reduce ambiguity |
| **Course-correct early** | `Esc` to stop, `Esc+Esc` or `/rewind` to restore, `/clear` to reset context |
| **Use subagents for investigation** | Exploration in a separate context keeps your main window clean |

### Prompting patterns

| Strategy | Before | After |
| :------- | :----- | :---- |
| Verification criteria | "implement email validation" | "write validateEmail, run these test cases after implementing" |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case, avoid mocks" |
| Point to sources | "why does ExecutionFactory have a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "add a calendar widget" | "look at HotDogWidget.php, follow the pattern to implement a calendar widget" |
| Describe the symptom | "fix the login bug" | "users report login fails after session timeout, check src/auth/ token refresh, write a failing test then fix it" |

### Environment setup checklist

| Setup | How |
| :---- | :-- |
| **CLAUDE.md** | `/init` to generate; keep under 200 lines; include commands Claude can't guess, code style deviations, test instructions, architectural decisions |
| **Permissions** | Auto mode, `/permissions` allowlists, or `/sandbox` for OS-level isolation |
| **CLI tools** | Install `gh`, `aws`, `gcloud`, `sentry-cli` etc. for context-efficient external service interaction |
| **MCP servers** | `claude mcp add` for Notion, Figma, databases, monitoring |
| **Hooks** | Deterministic actions (e.g. "run eslint after every file edit"); configure in `.claude/settings.json` or ask Claude |
| **Skills** | `.claude/skills/<name>/SKILL.md` for domain knowledge and reusable workflows |
| **Subagents** | `.claude/agents/<name>.md` for isolated tasks with specialized focus |
| **Plugins** | `/plugin` to browse marketplace; code intelligence plugins recommended for typed languages |

### Session management

| Action | Command / key |
| :----- | :------------ |
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc+Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact with focus | `/compact Focus on the API changes` |
| Side question (no context growth) | `/btw` |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` |
| Name a session | `claude -n auth-refactor` or `/rename` |

### Plan Mode

Use Plan Mode (`Shift+Tab` to cycle, or `claude --permission-mode plan`) for multi-step implementations, codebase exploration, and interactive development. Claude uses read-only operations and `AskUserQuestion` to gather requirements before proposing a plan. Press `Ctrl+G` to edit the plan in your text editor. Set as default with `"defaultMode": "plan"` in `.claude/settings.json`.

### Parallel sessions and scaling

| Method | Use case |
| :----- | :------- |
| Desktop app sessions | Multiple local sessions, each with isolated worktree |
| Claude Code on the web | Cloud infrastructure, isolated VMs |
| Agent teams | Automated multi-session coordination with shared tasks and messaging |
| `claude -p "prompt"` in a loop | Fan-out across files for migrations/analyses; use `--allowedTools` to scope |
| Auto mode (`--permission-mode auto`) | Uninterrupted execution with background safety classifier |
| Writer/Reviewer pattern | One session implements, another reviews with fresh context |

### Git worktrees

`claude --worktree feature-auth` creates an isolated worktree at `.claude/worktrees/<name>/` branching from `origin/HEAD`. Use `-w` as shorthand. Add `.claude/worktrees/` to `.gitignore`. Create a `.worktreeinclude` file to copy gitignored files (`.env`, secrets) into worktrees. Subagents support `isolation: worktree` in frontmatter.

### Common workflow recipes

| Workflow | Key steps |
| :------- | :-------- |
| **Understand codebase** | Start broad ("give me an overview"), then narrow ("how is auth handled?") |
| **Fix bugs** | Share the error, ask for fix suggestions, apply and verify |
| **Refactor** | Find deprecated usage, get recommendations, apply safely, run tests |
| **Write tests** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **Create PRs** | Summarize changes, `create a pr`, enhance description; session auto-links to PR |
| **Documentation** | Find undocumented code, generate docs, review, verify standards |
| **Images** | Drag/drop, copy/paste, or provide path; analyze screenshots, mockups, diagrams |
| **File references** | `@src/utils/auth.js` for files, `@src/components` for directories, `@server:resource` for MCP |

### Extended thinking

Enabled by default with adaptive reasoning. Control with `/effort`, `Option+T`/`Alt+T` toggle, or `MAX_THINKING_TOKENS` env var. The `ultrathink` keyword in a prompt adds an in-context instruction for deeper reasoning on that turn. View thinking with `Ctrl+O` (verbose mode).

### Ultraplan

Launch with `/ultraplan <prompt>` or include the word "ultraplan" in a prompt. Drafts a plan in a Claude Code on the web session (plan mode) while your terminal stays free. Review in browser with inline comments, emoji reactions, and outline navigation. Execute on the web (creates PR) or send back to terminal. Requires Claude.ai account and GitHub repo. Not available with Bedrock, Vertex AI, or Foundry.

| CLI status | Meaning |
| :--------- | :------ |
| `ultraplan` | Claude is drafting the plan |
| `ultraplan needs your input` | Clarifying question; open session link |
| `ultraplan ready` | Plan ready to review in browser |

### Ultrareview

Launch with `/ultrareview` (branch diff) or `/ultrareview 1234` (PR number). Runs a multi-agent fleet of reviewers in a remote sandbox. Every finding is independently reproduced and verified. Takes 5-10 minutes; runs as a background task. Not available with Bedrock, Vertex AI, or Foundry.

| | `/review` | `/ultrareview` |
| :--- | :-------- | :------------- |
| **Runs** | Locally | Remote cloud sandbox |
| **Depth** | Single-pass | Multi-agent fleet with verification |
| **Duration** | Seconds to minutes | 5-10 minutes |
| **Cost** | Normal usage | Free runs (3 one-time), then ~$5-$20 per review as extra usage |
| **Best for** | Quick feedback while iterating | Pre-merge confidence on substantial changes |

### Common failure patterns

| Pattern | Fix |
| :------ | :-- |
| Kitchen sink session (mixed unrelated tasks) | `/clear` between tasks |
| Correcting over and over | After 2 failed corrections, `/clear` and write a better prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks if possible |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope narrowly or use subagents |

### Scheduled tasks

| Option | Where it runs | Best for |
| :----- | :------------ | :------- |
| Routines | Anthropic infrastructure | Tasks when computer is off; API/GitHub triggers |
| Desktop scheduled tasks | Local machine via desktop app | Tasks needing local files/tools |
| GitHub Actions | CI pipeline | Repo events, cron schedules |
| `/loop` | Current CLI session | Quick polling while session is open |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — prompting patterns, verification strategies, environment configuration (CLAUDE.md, permissions, CLI tools, MCP, hooks, skills, subagents, plugins), session management (context, checkpoints, subagents), scaling with parallel sessions, fan-out, and auto mode, and common failure patterns.
- [Common workflows](references/claude-code-common-workflows.md) — step-by-step recipes for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, testing, PRs, documentation, images, file references, extended thinking, session resumption, git worktrees, notifications, unix-style piping, output formats, and scheduled tasks.
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching ultraplan from the CLI, reviewing and revising plans in the browser, choosing where to execute (web or terminal), and status indicators.
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — running ultrareview from the CLI, branch vs PR mode, pricing and free runs, tracking running reviews, and comparison with `/review`.

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
