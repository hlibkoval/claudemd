---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices and common workflows — context management, verification strategies, CLAUDE.md authoring, prompt patterns, session management, parallel sessions, Plan Mode, extended thinking, git worktrees, ultraplan (cloud planning), and ultrareview (multi-agent code review).
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices and common workflows.

## Quick Reference

### Core constraint: context window fills fast

Context holds all messages, file reads, and command output. Performance degrades as it fills. The single most important resource to manage.

| Tool | Purpose |
| :--- | :--- |
| `/clear` | Reset context between unrelated tasks |
| `/compact <instructions>` | Targeted compaction with custom focus |
| `/btw` | Side questions that never enter context |
| Esc+Esc / `/rewind` | Open rewind menu to restore conversation/code state |
| Subagents | Research in a separate context window; only summary enters main context |

### Give Claude a way to verify its work

| Strategy | Example prompt |
| :--- | :--- |
| Provide test cases | "write validateEmail. test cases: user@example.com is true, invalid is false. run the tests after." |
| Verify UI visually | "[paste screenshot] implement this design. take a screenshot, compare, list differences, fix them." |
| Address root causes | "the build fails with this error: [paste error]. fix it and verify the build succeeds. don't suppress the error." |

UI verification: use the Claude in Chrome extension to open tabs, test, and iterate.

### Explore-plan-implement workflow (Plan Mode)

Use Plan Mode (`Shift+Tab` twice, or `--permission-mode plan`) for multi-file and unfamiliar changes.

| Phase | Mode | Action |
| :--- | :--- | :--- |
| Explore | Plan Mode | Claude reads files without making changes |
| Plan | Plan Mode | Ask for a detailed implementation plan. `Ctrl+G` opens plan in editor. |
| Implement | Normal Mode | Claude codes, verifying against the plan |
| Commit | Normal Mode | Commit and open a PR |

Skip planning for small, scoped tasks (single-sentence diffs).

### Prompt quality patterns

| Strategy | Weak | Strong |
| :--- | :--- | :--- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case. avoid mocks." |
| Point to sources | "why is this API weird?" | "look through ExecutionFactory's git history and summarize how its api evolved" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php as a pattern example. build a calendar widget following that pattern." |
| Describe symptom | "fix the login bug" | "users report login fails after session timeout. check auth flow in src/auth/. write a failing test, then fix it." |

Rich content: use `@filename` to reference files, paste screenshots/images, give URLs, pipe data with `cat file | claude`.

### CLAUDE.md authoring

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API documentation (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently-changing information |
| Architectural decisions specific to the project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices ("write clean code") |

CLAUDE.md locations: `~/.claude/CLAUDE.md` (all projects), `./CLAUDE.md` (project, commit to git), `./CLAUDE.local.md` (personal, gitignore), subdirectories (loaded on demand). Import files with `@path/to/file`. Add emphasis (`IMPORTANT`, `YOU MUST`) to improve adherence to critical rules. Keep it concise — bloated CLAUDE.md files cause Claude to ignore instructions.

### Permission modes

| Mode | How to activate | What it does |
| :--- | :--- | :--- |
| Normal | Default | Prompts for each potentially impactful action |
| Auto mode | `Shift+Tab` / `--permission-mode auto` | Classifier reviews commands; blocks only risky actions |
| Plan Mode | `Shift+Tab` twice / `--permission-mode plan` | Read-only analysis; no writes or executions |

Configure default: `{ "permissions": { "defaultMode": "plan" } }` in `.claude/settings.json`.

Permission allowlists: use `/permissions` to allowlist specific commands. Sandboxing: `/sandbox` for OS-level isolation.

### Session management

| Command | Purpose |
| :--- | :--- |
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc+Esc` / `/rewind` | Open rewind menu: restore conversation, code, or both |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact with focus (e.g., `/compact Focus on API changes`) |
| `/btw` | Side question — answer appears in overlay, never enters context |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` / `claude -n <name>` | Resume named session or open picker |
| `/rename` | Give session a descriptive name |

Session picker shortcuts: `↑↓` navigate, `Space` preview, `Ctrl+R` rename, `/` or printable chars to search, `Ctrl+A` all projects, `Ctrl+W` all worktrees, `Ctrl+B` current branch.

Checkpoints: every Claude action creates a checkpoint. Esc+Esc / `/rewind` to restore. Persists across sessions.

### Scaling with parallel sessions

| Pattern | How |
| :--- | :--- |
| Writer/Reviewer | One session implements; fresh session reviews (unbiased) |
| Fan-out migrations | `for file in $(cat files.txt); do claude -p "migrate $file" --allowedTools "Edit,Bash(git commit *)"; done` |
| Non-interactive CI | `claude -p "prompt" --output-format stream-json` |
| Auto mode unattended | `claude --permission-mode auto -p "fix all lint errors"` |

Output formats for `-p`: `text` (default), `json`, `stream-json`.

Parallel session options: Claude Code desktop app (visual, isolated worktrees), Claude Code on the web (cloud VMs), agent teams (coordinated with shared tasks).

### Git worktrees

Create isolated worktrees for parallel Claude sessions:

```bash
claude --worktree feature-auth   # creates .claude/worktrees/feature-auth/
claude --worktree                # auto-generates name
```

Worktrees branch from `origin/HEAD`. To re-sync: `git remote set-head origin -a`.

Copy gitignored files (e.g., `.env`) to worktrees: add a `.worktreeinclude` file using `.gitignore` syntax.

Cleanup: no changes — auto-removed. Changes exist — Claude prompts to keep or remove.

### Extended thinking (thinking mode)

Enabled by default. Useful for complex architectural decisions, challenging bugs, multi-step planning.

| Configuration | How |
| :--- | :--- |
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| `ultrathink` keyword | Include in prompt for deeper reasoning that turn |
| Toggle thinking | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` to toggle; saved as `alwaysThinkingEnabled` |
| Limit budget | `MAX_THINKING_TOKENS` env var |

View thinking: `Ctrl+O` for verbose mode (gray italic text).

### Ultraplan (cloud-based planning)

Hands a planning task from local CLI to a Claude Code on the web session in plan mode. Requires a Claude.ai account and GitHub repo. Not available on Bedrock/Vertex/Foundry.

Launch:
- `/ultraplan <prompt>` — command form
- Include "ultraplan" in a prompt — keyword form
- From a local plan dialog — choose "No, refine with Ultraplan"

Status indicators: `◇ ultraplan` (drafting), `◇ ultraplan needs your input` (question pending), `◆ ultraplan ready` (review in browser).

Review in browser: inline comments on sections, emoji reactions, outline sidebar, iterate revisions.

Execute options: "Approve and start coding" (runs in cloud) or "Approve and teleport back to terminal" (implements locally).

### Ultrareview (multi-agent code review)

Deep code review running on Claude Code on the web. Multiple reviewer agents in a remote sandbox independently verify findings. Requires Claude.ai authentication.

```bash
/ultrareview          # review branch vs default branch
/ultrareview 1234     # review a specific GitHub PR number
```

Non-interactive use:
```bash
claude ultrareview
claude ultrareview 1234
claude ultrareview origin/main
```

Flags: `--json` (raw bugs.json), `--timeout <minutes>` (default 30).

| Comparison | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | locally | remote cloud sandbox |
| Depth | single-pass | multi-agent with verification |
| Duration | seconds to minutes | 5–10 minutes |
| Cost | normal usage | free runs, then ~$5–$20 extra usage |
| Best for | quick feedback | pre-merge on substantial changes |

Pricing: Pro/Max get 3 free runs (expire May 5, 2026); Team/Enterprise billed as extra usage.

### Common failure patterns

| Failure | Fix |
| :--- | :--- |
| Kitchen sink session (many unrelated tasks) | `/clear` between unrelated tasks |
| Repeated corrections on same issue | After 2 failures, `/clear` and rewrite with a better prompt |
| Over-specified CLAUDE.md (Claude ignores rules) | Ruthlessly prune; convert to hooks if truly deterministic |
| Plausible implementation without edge case handling | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration (Claude reads hundreds of files) | Scope investigations narrowly or use subagents |

### Scheduled task options

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Routines | Anthropic-managed cloud | Tasks that should run even when machine is off |
| Desktop scheduled tasks | Your machine via desktop app | Tasks needing local files or uncommitted changes |
| GitHub Actions | CI pipeline | Repo events or cron alongside workflow config |
| `/loop` | Current CLI session | Quick polling while session is open |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices](references/claude-code-best-practices.md) — context management, verification strategies, explore/plan/implement workflow, CLAUDE.md authoring, permissions configuration, MCP, hooks, skills, subagents, plugins, communication patterns, session management, parallel sessions, fan-out patterns, auto mode, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — step-by-step guides for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, tests, pull requests, documentation, notes/non-code folders, images, file references, extended thinking, session resuming, git worktrees, notifications, unix-style CLI usage, scheduled tasks
- [Ultraplan](references/claude-code-ultraplan.md) — cloud-based planning from the CLI, launching ultraplan, reviewing and revising plans in the browser, choosing where to execute (cloud or teleport to terminal)
- [Ultrareview](references/claude-code-ultrareview.md) — multi-agent deep code review, running interactively and non-interactively, pricing and free runs, tracking running reviews, comparison with local `/review`

## Sources

- Best practices: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
