---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, and ultraplan — covering context management, Plan Mode, CLAUDE.md tuning, verification strategies, subagents, parallel sessions, headless automation, worktrees, and cloud-based planning.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for getting the most out of Claude Code: proven patterns, step-by-step workflows for everyday tasks, and the cloud-based `ultraplan` feature.

## Quick Reference

### The core constraint: context window

Claude's context window holds the entire conversation — messages, file reads, and command output. Performance degrades as it fills. Most best practices derive from managing this constraint.

### Core best practices

| Practice | How to apply it |
|---|---|
| **Give Claude a way to verify its work** | Include tests, screenshots, expected outputs, linters, or Bash commands that check success. The single highest-leverage thing. |
| **Explore, plan, then code** | Use Plan Mode (Shift+Tab cycles modes) for multi-file or unfamiliar changes. Skip planning only for one-sentence diffs. |
| **Provide specific context** | Reference files with `@`, point to example patterns, name constraints, describe symptoms + likely locations + what "fixed" looks like. |
| **Course-correct early** | Press `Esc` to redirect, `Esc+Esc` or `/rewind` to restore state, `"undo that"` to revert. After 2 failed corrections, `/clear` and restart with a better prompt. |
| **Manage context aggressively** | `/clear` between unrelated tasks. `/compact <instructions>` for targeted compaction. `/btw` for quick questions that don't enter history. |
| **Delegate to subagents** | `"use subagents to investigate X"` — they explore in a separate context and report a summary, keeping your main conversation clean. |

### The four-phase workflow

| Phase | Mode | Example prompt |
|---|---|---|
| 1. Explore | Plan Mode | `read /src/auth and understand how we handle sessions and login` |
| 2. Plan | Plan Mode | `I want to add Google OAuth. What files need to change? Create a plan.` (Press `Ctrl+G` to edit in your editor.) |
| 3. Implement | Normal Mode | `implement the OAuth flow from your plan. write tests, run them, fix failures.` |
| 4. Commit | Normal Mode | `commit with a descriptive message and open a PR` |

### CLAUDE.md — what to include vs. exclude

| Include | Exclude |
|---|---|
| Bash commands Claude can't guess | Anything Claude can figure out from the code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions, preferred test runners | Detailed API docs (link instead) |
| Repository etiquette (branch naming, PRs) | Information that changes frequently |
| Architectural decisions specific to the project | Long explanations or tutorials |
| Env quirks (required env vars) | File-by-file descriptions |
| Non-obvious gotchas | Self-evident practices ("write clean code") |

CLAUDE.md locations:

| Location | Scope |
|---|---|
| `~/.claude/CLAUDE.md` | All sessions |
| `./CLAUDE.md` | Project (commit to share) |
| `./CLAUDE.local.md` | Project (gitignored) |
| Parent directories | Monorepos — pulled in automatically |
| Child directories | Pulled in on demand when working in them |

Use `@path/to/file` inside CLAUDE.md to import additional files. Run `/init` to generate a starter.

### Plan Mode

| How to enter | Command |
|---|---|
| Toggle during a session | `Shift+Tab` (cycles Normal → Auto-Accept → Plan) |
| Start a new session in Plan Mode | `claude --permission-mode plan` |
| Headless plan | `claude --permission-mode plan -p "..."` |
| Set as default | `{"permissions": {"defaultMode": "plan"}}` in `.claude/settings.json` |
| Edit a plan in your editor | `Ctrl+G` |

Accepting a plan auto-names the session from plan content (unless you already named it).

### Permission-reduction strategies

| Strategy | When to use |
|---|---|
| Auto mode | A classifier approves/blocks. Best when you trust the direction but not every step. `claude --permission-mode auto` |
| Permission allowlists | Pre-approve safe tools via `/permissions` |
| Sandboxing | OS-level filesystem/network isolation via `/sandbox` |

### Session management commands

| Command | Purpose |
|---|---|
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc+Esc` or `/rewind` | Open rewind menu: restore conversation, code, both, or summarize-from-here |
| `/clear` | Reset context between unrelated tasks |
| `/compact <instructions>` | Manual compaction with guidance |
| `/btw` | Ask a side question that never enters conversation history |
| `claude --continue` | Resume the most recent conversation in the current directory |
| `claude --resume [name]` | Open picker or resume by name |
| `claude --from-pr <number>` | Resume a session linked to a PR |
| `claude -n <name>` / `/rename <name>` | Name a session for later retrieval |

### Picker shortcuts (`/resume`)

| Key | Action |
|---|---|
| `↑` / `↓` | Navigate |
| `→` / `←` | Expand/collapse grouped sessions |
| `Enter` | Resume highlighted session |
| `P` | Preview session |
| `R` | Rename |
| `/` | Search/filter |
| `A` | Toggle current dir ↔ all projects |
| `B` | Filter to current git branch |
| `Esc` | Exit |

### Extended thinking

Enabled by default; gives Claude space to reason before responding. `Ctrl+O` toggles verbose mode to see reasoning.

| Control | How |
|---|---|
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var (Opus 4.6 / Sonnet 4.6 use adaptive reasoning) |
| `ultrathink` keyword | Include in prompt → sets effort to high for that turn |
| Toggle shortcut | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` → saves as `alwaysThinkingEnabled` |
| Token budget | `MAX_THINKING_TOKENS` env var (on 4.6 models only `0` applies unless `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`) |

Phrases like "think", "think hard", "think more" are normal instructions, not thinking-budget triggers.

### Rich input methods

| Method | Usage |
|---|---|
| `@file` | Inline-include file contents; also pulls in `CLAUDE.md` from that file's directory and parents |
| `@directory` | Include a directory listing (not contents) |
| `@server:resource` | MCP resource |
| Paste image | Copy/paste or drag-and-drop (Ctrl+V, not Cmd+V in the CLI) |
| Pipe data | `cat error.log | claude` |
| URL | Claude can fetch; use `/permissions` to allowlist domains |

### Non-interactive / headless mode

```bash
claude -p "prompt"                                  # one-off
claude -p "prompt" --output-format json             # structured output with metadata
claude -p "prompt" --output-format stream-json      # real-time streaming
claude -p "prompt" --allowedTools "Edit,Bash(git commit *)"
claude --permission-mode auto -p "fix all lint errors"
```

Auto mode in `-p` runs aborts if the classifier repeatedly blocks (no user to fall back to). Use `--verbose` during development.

### Parallel session patterns

| Mechanism | Where to use |
|---|---|
| Desktop app sessions | Managed locally, each gets an isolated worktree |
| Claude Code on the web | Runs in Anthropic-managed VMs |
| Agent teams | Multi-session coordination with shared tasks and messaging |
| Writer/Reviewer | Separate contexts — one writes, another reviews with no bias |
| Fan-out | Loop `claude -p` over a file list for bulk migration |

### Git worktrees

```bash
claude --worktree feature-auth        # named, creates .claude/worktrees/feature-auth/
claude --worktree                     # auto-generates a name like "bright-running-fox"
claude -w bugfix-123                  # -w is the short form
```

| Detail | Value |
|---|---|
| Location | `<repo>/.claude/worktrees/<name>` |
| Branch name | `worktree-<name>` |
| Base branch | Wherever `origin/HEAD` points (resync with `git remote set-head origin -a`) |
| Full control | Configure a `WorktreeCreate` hook |
| Subagent worktrees | Set `isolation: worktree` in subagent frontmatter |
| Copy gitignored files | Add patterns to `.worktreeinclude` in project root |
| Cleanup | No changes → auto-removed; changes → prompts keep/remove |

Add `.claude/worktrees/` to `.gitignore`.

### Scheduled/recurring task options

| Option | Where it runs | Best for |
|---|---|---|
| [Routines](https://code.claude.com/docs/en/routines) | Anthropic infra | Runs when computer is off; schedule/API/GitHub triggers |
| [Desktop scheduled tasks](https://code.claude.com/docs/en/desktop-scheduled-tasks) | Your machine (desktop app) | Needs local file/tool access |
| [GitHub Actions](https://code.claude.com/docs/en/github-actions) | CI pipeline | Repo events or cron alongside workflow config |
| `/loop` | Current CLI session | Quick polling; cancelled when session exits |

### Ultraplan (research preview, v2.1.91+)

Hands off planning to a Claude Code on the web session in Plan Mode; review and revise in a browser with inline comments, then execute in the cloud or teleport back to your terminal. Requires a Claude Code on the web account + a GitHub repo. Not available on Bedrock/Vertex/Foundry.

**Launch from CLI:**

| Method | Command |
|---|---|
| Slash command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` anywhere in a prompt |
| From a local plan | Choose "No, refine with Ultraplan..." in the approval dialog |

**Status indicators (in the prompt input):**

| Status | Meaning |
|---|---|
| `◇ ultraplan` | Researching and drafting |
| `◇ ultraplan needs your input` | Clarifying question pending in browser |
| `◆ ultraplan ready` | Plan ready to review |

Run `/tasks` to see the ultraplan entry with a session link and a **Stop ultraplan** action.

**Review surface (browser):** inline comments on highlighted passages, emoji reactions, outline sidebar.

**Execution choices:**

| Choice | Behavior |
|---|---|
| Approve and start coding | Implements in the same cloud session; create a PR from the web UI when done |
| Approve and teleport back | Sends plan to waiting terminal with three sub-options: **Implement here**, **Start new session**, or **Cancel** (saves plan to file) |

Starting ultraplan disconnects Remote Control (they share the claude.ai/code UI).

### Common failure patterns

| Pattern | Fix |
|---|---|
| **Kitchen sink session** — jumping between unrelated tasks | `/clear` between tasks |
| **Correcting over and over** — context polluted with failed attempts | After 2 failed corrections, `/clear` and rewrite the prompt with what you learned |
| **Over-specified CLAUDE.md** — rules get lost in noise | Ruthlessly prune; convert enforceable rules to hooks |
| **Trust-then-verify gap** — plausible-looking but broken output | Always provide verification (tests, scripts, screenshots) |
| **Infinite exploration** — "investigate" without scope | Scope narrowly or delegate to subagents |

### Workflow quick-reference

| Goal | Example prompt or command |
|---|---|
| Codebase overview | `give me an overview of this codebase` |
| Find relevant code | `find the files that handle user authentication` |
| Fix a bug | `I'm seeing an error when I run npm test` + paste stack trace |
| Refactor | `refactor utils.js to use ES2024 features while maintaining the same behavior` |
| Add tests | `find functions in NotificationsService.swift not covered by tests` |
| Create a PR | `create a pr for my changes` (auto-links session to the PR) |
| Documentation | `add JSDoc comments to the undocumented functions in auth.js` |
| Analyze an image | Drag/drop, paste (Ctrl+V), or provide a path |
| Notifications | Add a `Notification` hook calling `osascript` / `notify-send` / `powershell` |
| Unix utility | `cat build-error.txt | claude -p 'explain the root cause' > output.txt` |

### Matcher values for the `Notification` hook

| Matcher | Fires when |
|---|---|
| `permission_prompt` | Tool use needs approval |
| `idle_prompt` | Claude is done and waiting for input |
| `auth_success` | Authentication completes |
| `elicitation_dialog` | Claude is asking a question |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — Patterns for getting the most out of Claude Code: context management, verification, planning, CLAUDE.md tuning, permissions, subagents, parallel sessions, fan-out, auto mode, and common failure patterns.
- [Common workflows](references/claude-code-common-workflows.md) — Step-by-step recipes for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, testing, PRs, docs, images, `@` references, extended thinking, session resume, git worktrees, notifications, unix-utility usage, and scheduled tasks.
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — Research-preview feature to hand off planning to Claude Code on the web, iterate with browser comments, and execute on the web or back in your terminal.

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
