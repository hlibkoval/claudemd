---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, ultraplan, and ultrareview — covering context management, prompting patterns, environment setup, session management, automation, git worktrees, extended thinking, and cloud-based planning and review tools.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices and common workflows.

## Quick Reference

### Core constraint: context window fills fast

Claude's context window holds the entire conversation, every file read, and every command output. Performance degrades as it fills. Managing context is the single most important resource concern.

### Top leverage actions

| Action | Why it matters |
| :----- | :------------- |
| Provide tests / screenshots / expected outputs | Claude self-verifies; fewer corrections needed |
| Use Plan Mode before coding (`Shift+Tab` twice, or `--permission-mode plan`) | Separates exploration from implementation |
| Give specific file references, patterns, and constraints in prompts | Fewer wrong-direction attempts |
| Run `/clear` between unrelated tasks | Resets noisy context |
| Use subagents for investigation | Keeps main context clean |
| Write a lean `CLAUDE.md` | Persistent context without bloating every session |

### Explore → Plan → Implement → Commit workflow

1. **Explore** (Plan Mode): read files, understand the codebase — no changes
2. **Plan** (Plan Mode): ask for a detailed implementation plan; `Ctrl+G` to edit it
3. **Implement** (Normal Mode): code with verification (run tests, fix failures)
4. **Commit**: descriptive message + PR

Skip planning for simple, clearly scoped changes (one-sentence diffs).

### Prompting patterns

| Pattern | Vague | Specific |
| :------ | :---- | :------- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case; avoid mocks" |
| Point to sources | "why is ExecutionFactory weird?" | "look through ExecutionFactory's git history and summarize how its API came to be" |
| Reference patterns | "add a calendar widget" | "follow HotDogWidget.php as the pattern; implement a calendar widget from scratch" |
| Describe symptom | "fix the login bug" | "login fails after session timeout; check src/auth/ token refresh; write a failing test then fix it" |

### Rich content methods

- `@file` — inline file contents before responding
- Paste / drag images directly into the prompt
- `cat error.log | claude` — pipe data in
- Give URLs; use `/permissions` to allowlist frequently-used domains

### CLAUDE.md quick guide

| Include | Exclude |
| :------ | :------ |
| Bash commands Claude can't infer | Anything Claude infers from reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Test runner and testing instructions | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to the project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas / non-obvious behaviors | Self-evident practices ("write clean code") |

CLAUDE.md supports `@path/to/import` syntax. Locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project, commit to git), `./CLAUDE.local.md` (personal, gitignored), parent/child directories.

### Permission modes

| Mode | How to enable | Best for |
| :--- | :------------ | :------- |
| Normal (default) | — | Standard interactive work |
| Auto-accept edits | `Shift+Tab` once | Trusted, routine file edits |
| Plan Mode | `Shift+Tab` twice, or `--permission-mode plan` | Read-only exploration and planning |
| Auto mode | `--permission-mode auto` | Unattended runs with classifier safety |
| Sandbox | `/sandbox` | OS-level filesystem/network isolation |

Permission allowlists: use `/permissions` to permit specific tools (e.g., `npm run lint`, `git commit`).

### Session management commands

| Command / key | Effect |
| :------------ | :----- |
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc Esc` or `/rewind` | Open rewind menu; restore conversation/code to a checkpoint |
| `/clear` | Reset context window entirely |
| `/compact <instructions>` | Compact with focus (e.g., `/compact Focus on API changes`) |
| `/btw` | Side question; answer never enters conversation history |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Open session picker |
| `claude -n <name>` or `/rename` | Name a session for later retrieval |

### Non-interactive / automation

```bash
claude -p "prompt"                          # One-off headless query
claude -p "prompt" --output-format json     # Structured output
claude -p "prompt" --output-format stream-json  # Streaming JSON
claude --permission-mode auto -p "fix all lint errors"  # Auto mode
```

Fan-out pattern for large migrations:

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### Git worktrees for parallel sessions

```bash
claude --worktree feature-auth   # Creates .claude/worktrees/feature-auth/
claude --worktree                # Auto-generated name
```

- Each worktree gets its own branch (`worktree-<name>`) based off `origin/HEAD`
- Re-sync base branch: `git remote set-head origin -a`
- Copy gitignored files (`.env`, etc.) automatically via `.worktreeinclude` in project root
- Add `.claude/worktrees/` to `.gitignore`
- Cleanup: no changes → removed automatically; changes → Claude prompts

### Extended thinking (thinking mode)

| Setting | How |
| :------ | :-- |
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| `ultrathink` keyword | Include "ultrathink" in any prompt for deeper reasoning on that turn |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux), or `/config` |
| View reasoning | `Ctrl+O` (verbose mode) — shown as gray italic text |
| Limit token budget | `MAX_THINKING_TOKENS` env var (set to `0` to disable) |

Adaptive reasoning (Opus 4.6, Sonnet 4.6, Opus 4.7+) dynamically allocates thinking tokens based on effort level. "Think", "think hard", "think more" are plain instructions, not token allocators.

### Ultraplan — cloud-based planning

Ultraplan hands a planning task to a Claude Code on the web session in plan mode. Your terminal stays free while the cloud session drafts the plan.

**Launch methods:**
- `/ultraplan <prompt>` — command
- Include "ultraplan" anywhere in a normal prompt
- From a local plan approval dialog → choose "Refine with Ultraplan"

**Status indicators in the CLI:**

| Status | Meaning |
| :----- | :------ |
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Claude has a clarifying question |
| `◆ ultraplan ready` | Plan ready to review in browser |

**Execution options (in browser):**
- "Approve and start coding" — implements in the cloud session
- "Approve and teleport back to terminal" — sends plan to local CLI

**Requirements:** Claude Code v2.1.91+, Claude.ai account, GitHub repository. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

### Ultrareview — cloud-based deep code review

Ultrareview runs a fleet of reviewer agents in a remote sandbox. Every finding is independently reproduced and verified before being reported.

```text
/ultrareview          # Review diff between current branch and default branch
/ultrareview 1234     # Review GitHub PR #1234
```

**Comparison:**

| | `/review` | `/ultrareview` |
| :-- | :-------- | :------------- |
| Runs | locally in session | remotely in cloud sandbox |
| Depth | single-pass | multi-agent with independent verification |
| Duration | seconds to minutes | ~5–10 minutes |
| Cost | normal usage | 3 free runs (Pro/Max, expires May 5 2026), then ~$5–$20/review as extra usage |
| Best for | quick feedback while iterating | pre-merge confidence on substantial changes |

**Requirements:** Claude.ai account (`/login`), Claude Code v2.1.86+. Not available on Bedrock, Vertex AI, Foundry, or with Zero Data Retention enabled.

Track running reviews with `/tasks`.

### Common failure patterns to avoid

| Pattern | Fix |
| :------ | :-- |
| Kitchen sink session (mixing unrelated tasks) | `/clear` between unrelated tasks |
| Correcting the same issue twice | After two failed corrections, `/clear` and write a better prompt |
| Over-specified CLAUDE.md (rules get ignored) | Ruthlessly prune; convert stable patterns to hooks |
| Trust-then-verify gap (plausible but broken output) | Always provide verification: tests, scripts, or screenshots |
| Infinite exploration (hundreds of files read) | Scope narrowly or delegate to a subagent |

### Scheduling options

| Option | Where it runs | Best for |
| :----- | :------------ | :------- |
| Routines | Anthropic-managed infra | Tasks that run even when computer is off |
| Desktop scheduled tasks | Local machine via desktop app | Tasks needing local files/tools |
| GitHub Actions | CI pipeline | Repo-event or cron tasks |
| `/loop` | Current CLI session | Quick polling while session is open |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — context management, verification strategies, the explore-plan-implement-commit workflow, prompting, CLAUDE.md authoring, permissions, environment setup (CLI tools, MCP, hooks, skills, subagents, plugins), communication patterns, session management, and automation at scale
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step recipes for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, testing, PRs, documentation, images, @ file references, extended thinking, session resumption, git worktrees, desktop notifications, Unix-style piping, output formats, and scheduling
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching ultraplan, status indicators, inline browser review/revision, and choosing between cloud or terminal execution
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — running ultrareview on a branch or PR, pricing and free runs, tracking background reviews, and comparison with local `/review`

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
