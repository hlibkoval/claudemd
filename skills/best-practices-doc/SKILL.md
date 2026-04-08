---
name: best-practices-doc
description: Complete documentation for Claude Code best practices, common workflows, and ultraplan. Covers context window management, verification strategies (tests, screenshots, expected outputs), explore-plan-implement workflow, Plan Mode (Shift+Tab toggle, --permission-mode plan, Ctrl+G to edit plan), providing specific context (@-references, images, URLs, piped data), CLAUDE.md conventions (placement, @-imports, include/exclude guidelines, emphasis tuning), permission configuration (auto mode, allowlists, sandboxing), CLI tools (gh, aws, gcloud), MCP servers, hooks, skills, subagents, plugins, effective communication (codebase questions, interview prompts, AskUserQuestion), session management (Esc, Esc+Esc, /rewind, /clear, /compact, /btw, /rename, --continue, --resume, --from-pr), subagent delegation for investigation, checkpoint rewind, context compaction, non-interactive mode (claude -p, --output-format text/json/stream-json), parallel sessions (desktop app, web, agent teams), fan-out patterns (--allowedTools, batch scripting), auto mode (--permission-mode auto), git worktrees (--worktree, -w, subagent worktrees, .worktreeinclude, worktree cleanup, WorktreeCreate hooks), notification hooks (Notification event, permission_prompt, idle_prompt), unix-style usage (piping, build script linting, output formats), scheduled tasks (cloud, desktop, GitHub Actions, /loop), extended thinking (adaptive reasoning, effort level, /effort, ultrathink keyword, Option+T/Alt+T toggle, MAX_THINKING_TOKENS), common failure patterns, common workflows (codebase overview, find code, fix bugs, refactor, tests, PRs, documentation, images, @-references, session picker), and ultraplan (cloud planning, /ultraplan command, inline comments, emoji reactions, execute on web vs teleport to terminal). Load when discussing best practices, common workflows, ultraplan, Plan Mode, context management, CLAUDE.md, session management, parallel sessions, git worktrees, non-interactive mode, fan-out, verification strategies, extended thinking, thinking mode, or any best-practices-related topic for Claude Code.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and ultraplan.

## Quick Reference

### Core Principle: Context Window Management

Claude's context window is the most important resource to manage. Performance degrades as context fills. All best practices flow from this constraint.

| Action | Command / Shortcut |
|:-------|:-------------------|
| Clear context between tasks | `/clear` |
| Compact with focus | `/compact <instructions>` |
| Side question (no context cost) | `/btw` |
| Summarize from checkpoint | `Esc + Esc` or `/rewind` then "Summarize from here" |
| Track context usage | Configure a custom status line |

### Verification Strategies

| Strategy | Example prompt |
|:---------|:--------------|
| Test-driven | "Write a validateEmail function. Test cases: user@example.com is true, invalid is false. Run the tests after implementing" |
| Visual verification | "[paste screenshot] Implement this design. Take a screenshot and compare it to the original" |
| Root cause debugging | "The build fails with this error: [paste error]. Fix it and verify the build succeeds" |
| CLI tool verification | Use linters, test suites, or Bash commands as automated checks |

### Explore-Plan-Implement Workflow

| Phase | Mode | What to do |
|:------|:-----|:-----------|
| 1. Explore | Plan Mode | Read files, ask questions, understand the codebase |
| 2. Plan | Plan Mode | Create detailed implementation plan; press `Ctrl+G` to edit in your editor |
| 3. Implement | Normal Mode | Code against the plan, run tests, fix failures |
| 4. Commit | Normal Mode | Commit with descriptive message, open PR |

Skip planning for small, clear-scope tasks (typo fix, log line, variable rename).

### Plan Mode

| Method | How |
|:-------|:----|
| Toggle during session | `Shift+Tab` (cycles Normal -> Auto-Accept -> Plan) |
| Start session in Plan Mode | `claude --permission-mode plan` |
| Headless Plan Mode | `claude --permission-mode plan -p "your query"` |
| Set as default | `"permissions": { "defaultMode": "plan" }` in `.claude/settings.json` |
| Edit plan in editor | Press `Ctrl+G` when a plan is displayed |

### Providing Context

| Method | Usage |
|:-------|:------|
| `@` file references | `@src/utils/auth.js` -- includes full file content |
| `@` directory references | `@src/components` -- shows directory listing |
| Paste images | Copy/paste or drag-and-drop into prompt |
| Give URLs | Provide documentation links; use `/permissions` to allowlist domains |
| Pipe data | `cat error.log \| claude` |
| MCP resources | `@server:protocol://path` |

### CLAUDE.md Conventions

| Location | Scope |
|:---------|:------|
| `~/.claude/CLAUDE.md` | All sessions (global) |
| `./CLAUDE.md` | Project root, shared via git |
| `./CLAUDE.local.md` | Personal project notes (gitignore this) |
| Parent directories | Auto-loaded (useful for monorepos) |
| Child directories | Loaded on demand when working in those directories |

**Include:** Bash commands Claude cannot guess, code style deviations, test instructions, repo etiquette, architectural decisions, env quirks, gotchas.

**Exclude:** Things Claude infers from code, standard conventions, detailed API docs (link instead), frequently changing info, long tutorials, file-by-file descriptions.

**Tips:** Use `@path/to/import` syntax for imports. Add emphasis ("IMPORTANT", "YOU MUST") for critical rules. Run `/init` to generate a starter file.

### Session Management

| Action | Command / Shortcut |
|:-------|:-------------------|
| Stop mid-action | `Esc` |
| Rewind (open menu) | `Esc + Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact context | `/compact <focus>` |
| Side question | `/btw` |
| Rename session | `/rename name` or `-n name` at startup |
| Resume latest | `claude --continue` |
| Resume by name | `claude --resume name` |
| Resume from PR | `claude --from-pr <number>` |
| Session picker | `claude --resume` (no args) or `/resume` |
| Fork session | `/branch` |

### Session Picker Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Up/Down` | Navigate between sessions |
| `Right/Left` | Expand/collapse grouped sessions |
| `Enter` | Resume selected session |
| `P` | Preview session |
| `R` | Rename session |
| `/` | Search/filter |
| `A` | Toggle current directory / all projects |
| `B` | Filter to current git branch |
| `Esc` | Exit picker |

### Subagent Delegation

Use subagents to keep investigations out of your main context:

```
Use subagents to investigate how our auth system handles token refresh.
```

Subagents explore in a separate context window and report back summaries. Also useful for post-implementation review.

### Environment Setup Checklist

| Setup step | How |
|:-----------|:----|
| CLAUDE.md | `/init` then refine |
| Permissions | Auto mode, `/permissions` allowlists, or `/sandbox` |
| CLI tools | Install `gh`, `aws`, `gcloud`, `sentry-cli`, etc. |
| MCP servers | `claude mcp add` for Notion, Figma, databases, etc. |
| Hooks | "Write a hook that runs eslint after every file edit" |
| Skills | Add `SKILL.md` files in `.claude/skills/` |
| Subagents | Define in `.claude/agents/` |
| Plugins | `/plugin` to browse marketplace |

### Non-Interactive Mode

| Usage | Command |
|:------|:--------|
| One-off query | `claude -p "your prompt"` |
| JSON output | `claude -p "prompt" --output-format json` |
| Streaming JSON | `claude -p "prompt" --output-format stream-json` |
| Text output (default) | `claude -p "prompt" --output-format text` |
| Pipe data through | `cat file \| claude -p "prompt" > output.txt` |
| Auto mode | `claude --permission-mode auto -p "prompt"` |

### Parallel Sessions

| Method | Where it runs |
|:-------|:-------------|
| Desktop app | Local, with visual session management and isolated worktrees |
| Claude Code on the web | Anthropic cloud infrastructure, isolated VMs |
| Agent teams | Automated multi-session coordination with shared tasks |

**Writer/Reviewer pattern:** Session A implements, Session B reviews with fresh context, Session A addresses feedback.

### Fan-Out Pattern

1. Generate a task list (e.g., files to migrate)
2. Loop with `claude -p` per item, using `--allowedTools` to scope permissions
3. Test on a few files, refine prompt, then run at scale

### Git Worktrees

| Command | Description |
|:--------|:-----------|
| `claude --worktree name` | Create worktree at `.claude/worktrees/<name>/`, branch `worktree-<name>` |
| `claude --worktree` (no name) | Auto-generate random name |
| `claude -w name` | Short form |
| `.worktreeinclude` file | List gitignored files to copy (e.g., `.env`, `.env.local`) |

**Cleanup:** No changes = auto-removed. Changes exist = prompted to keep or remove.

**Subagent worktrees:** Add `isolation: worktree` to agent frontmatter, or say "use worktrees for your agents."

**Non-git VCS:** Configure `WorktreeCreate` and `WorktreeRemove` hooks.

**Sync origin/HEAD:** `git remote set-head origin -a`

### Extended Thinking

| Control | Method |
|:--------|:-------|
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in your prompt |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` to toggle |
| Limit budget | `MAX_THINKING_TOKENS` env var |
| View thinking | `Ctrl+O` for verbose mode |

Opus 4.6 and Sonnet 4.6 use adaptive reasoning (dynamic allocation based on effort level). Older models use a fixed token budget.

### Notification Hooks

| Matcher | Fires when |
|:--------|:-----------|
| `permission_prompt` | Claude needs tool approval |
| `idle_prompt` | Claude is done, waiting for next prompt |
| `auth_success` | Authentication completes |
| `elicitation_dialog` | Claude is asking a question |

### Scheduled Tasks

| Option | Where it runs | Best for |
|:-------|:-------------|:---------|
| Cloud scheduled tasks | Anthropic infrastructure | Tasks when computer is off |
| Desktop scheduled tasks | Local machine, desktop app | Access to local files/tools |
| GitHub Actions | CI pipeline | Repo events, cron schedules |
| `/loop` | Current CLI session | Quick polling while session is open |

### Common Workflows Summary

| Workflow | Key prompts |
|:---------|:-----------|
| Codebase overview | "give me an overview of this codebase" |
| Find code | "find the files that handle user authentication" |
| Fix bugs | "I'm seeing an error when I run npm test" |
| Refactor | "refactor utils.js to use ES2024 features while maintaining the same behavior" |
| Write tests | "add tests for the notification service" |
| Create PRs | "create a pr" |
| Documentation | "add JSDoc comments to the undocumented functions in auth.js" |
| Image analysis | Drag/drop, paste, or provide path to image |

### Ultraplan

Ultraplan sends a planning task to a Claude Code on the web session in plan mode, freeing your terminal.

| Launch method | How |
|:-------------|:----|
| Command | `/ultraplan <prompt>` |
| Keyword | Include "ultraplan" in any prompt |
| From local plan | Choose "No, refine with Ultraplan on Claude Code on the web" at approval dialog |

**Status indicators:**

| Status | Meaning |
|:-------|:--------|
| `ultraplan` | Drafting the plan |
| `ultraplan needs your input` | Clarifying question -- open session link |
| `ultraplan ready` | Plan ready for review in browser |

**Browser review features:** Inline comments on any passage, emoji reactions, outline sidebar navigation.

**Execution options:**

| Option | What happens |
|:-------|:-------------|
| Approve and start coding (web) | Implements in the same cloud session; create PR from web |
| Approve and teleport to terminal | Archives web session; plan appears in terminal with options: implement here, start new session, or cancel (save to file) |

Requires Claude Code on the web account and a GitHub repository. Not available with Bedrock, Vertex AI, or Foundry.

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (unrelated tasks accumulate) | `/clear` between unrelated tasks |
| Repeated corrections (3+ attempts) | `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) -- Tips and patterns for getting the most out of Claude Code, from environment setup to scaling with parallel sessions
- [Common Workflows](references/claude-code-common-workflows.md) -- Step-by-step guides for exploring codebases, fixing bugs, refactoring, testing, creating PRs, worktrees, and more
- [Plan in the Cloud with Ultraplan](references/claude-code-ultraplan.md) -- Start a plan from your CLI, draft and review it on Claude Code on the web, then execute remotely or locally

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the Cloud with Ultraplan: https://code.claude.com/docs/en/ultraplan.md
