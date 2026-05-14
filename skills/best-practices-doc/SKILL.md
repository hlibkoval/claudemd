---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, ultraplan (cloud-based planning), and ultrareview (deep multi-agent code review) — context management, verification strategies, prompting patterns, session management, parallel sessions, scheduling, and automation.
user-invocable: false
---

# Best Practices & Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and the ultraplan and ultrareview features.

## Quick Reference

### Core Constraint: Context Window

Most best practices flow from one constraint: **context fills fast and performance degrades as it fills**.

| Action | Effect on context |
| :----- | :---------------- |
| File read | Adds full file content |
| Command output | Adds all output |
| Long sessions | Accumulates all history |
| Subagent delegation | Exploration stays in separate context |

### Give Claude a Way to Verify Its Work

| Strategy | Vague | Specific |
| :------- | :---- | :------- |
| Verification criteria | "implement email validator" | "write validateEmail, run tests: user@example.com=true, invalid=false" |
| UI changes | "make the dashboard look better" | "implement this design [screenshot], take a screenshot, compare, fix differences" |
| Root cause | "the build is failing" | "build fails with [error]. Fix it and verify build succeeds. Address root cause." |

### Explore → Plan → Implement → Commit Workflow

1. **Explore** (plan mode): read files, understand structure — no edits
2. **Plan** (plan mode): ask for detailed implementation plan; press `Ctrl+G` to edit it
3. **Implement** (default mode): code with tests, verify against plan
4. **Commit**: ask Claude to commit with a descriptive message and open a PR

Use plan mode for multi-file changes, unfamiliar code, or uncertain approach. Skip it for single-line fixes.

### Prompting Patterns

| Strategy | Before | After |
| :------- | :----- | :---- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case. avoid mocks." |
| Point to sources | "why does ExecutionFactory have a weird api?" | "look through ExecutionFactory's git history and summarize how its api evolved" |
| Reference existing patterns | "add a calendar widget" | "look at HotDogWidget.php as an example pattern, implement a calendar widget from scratch" |
| Describe symptom | "fix the login bug" | "login fails after session timeout. check src/auth/, write a failing test, then fix it" |

**Rich input methods:** `@file` references, paste images directly, give URLs, pipe data via `cat file | claude`, let Claude fetch context itself.

### CLAUDE.md Guidelines

| Include | Exclude |
| :------ | :------ |
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

**Locations:**
- `~/.claude/CLAUDE.md` — all sessions
- `./CLAUDE.md` — project (commit to git)
- `./CLAUDE.local.md` — personal project overrides (gitignore)
- Parent/child directories — loaded automatically for monorepos

**Import other files:** `@path/to/file` syntax inside CLAUDE.md.

### Session Management

| Command | Action |
| :------ | :----- |
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc + Esc` or `/rewind` | Open rewind menu — restore conversation/code state or summarize |
| `/clear` | Reset context entirely between unrelated tasks |
| `/compact <instructions>` | Compact with custom focus (e.g., `/compact Focus on the API changes`) |
| `/btw` | Side question — answer shown in overlay, never enters context |
| `/rename` | Name the current session |
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Choose from session list |

**Rule:** after two failed corrections on the same issue, `/clear` and write a better initial prompt.

### Automation and Scaling

```bash
# Non-interactive (CI, scripts, hooks)
claude -p "your prompt"
claude -p "List all API endpoints" --output-format json
claude -p "Analyze this log file" --output-format stream-json

# Auto mode (classifier handles approvals)
claude --permission-mode auto -p "fix all lint errors"

# Fan-out across files
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done

# Pipe into scripts
git log --oneline -20 | claude -p "summarize these recent commits"
```

**Parallel approaches:** worktrees, desktop app sessions, Claude Code on the web, agent teams.

**Writer/Reviewer pattern:** Session A implements → Session B reviews with fresh context → Session A addresses feedback.

### Scheduling Options

| Option | Where it runs | Best for |
| :----- | :------------ | :------- |
| Routines | Anthropic-managed infrastructure | Tasks that run when your computer is off; GitHub/API triggers |
| Desktop scheduled tasks | Your machine (desktop app) | Tasks needing local files or uncommitted changes |
| GitHub Actions | CI pipeline | Repo-event tasks or cron schedules |
| `/loop` | Current CLI session | Quick polling while a session is open |

### Common Failure Patterns

| Pattern | Fix |
| :------ | :-- |
| Kitchen sink session (multiple unrelated tasks) | `/clear` between tasks |
| Correcting over and over (context polluted with failed attempts) | After two failures, `/clear` and write a better prompt |
| Over-specified CLAUDE.md (rules get lost in noise) | Ruthlessly prune; convert to hooks if possible |
| Trust-then-verify gap (plausible but wrong implementation) | Always provide tests, scripts, or screenshots for verification |
| Infinite exploration (hundreds of files consumed) | Scope investigations narrowly; use subagents |

### Ultraplan (Cloud Planning)

Hands planning from your local CLI to a Claude Code on the web session running in plan mode.

**Launch methods:**
- `/ultraplan <prompt>` — command
- Include "ultraplan" anywhere in a prompt — keyword trigger
- After a local plan: choose "No, refine with Ultraplan on Claude Code on the web"

**Status indicators:**

| Status | Meaning |
| :----- | :------ |
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Clarifying question — open session link |
| `◆ ultraplan ready` | Plan ready to review in browser |

**Execution options (from browser):**
- "Approve Claude's plan and start coding" — implements in cloud session
- "Approve plan and teleport back to terminal" — sends plan to waiting local terminal
  - **Implement here**: inject into current conversation
  - **Start new session**: fresh context with only the plan
  - **Cancel**: save plan to file

Requires Claude.ai account and GitHub repo. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

### Ultrareview (Deep Cloud Code Review)

Multi-agent code review running in a remote sandbox that independently reproduces and verifies every finding.

```bash
# Review diff between current branch and default branch
/ultrareview

# Review a specific GitHub PR
/ultrareview 1234

# Non-interactive (CI/scripts)
claude ultrareview
claude ultrareview 1234
claude ultrareview origin/main
claude ultrareview --json          # raw bugs.json output
claude ultrareview --timeout 45   # custom timeout in minutes
```

**Pricing:**

| Plan | Free runs | After free runs |
| :--- | :-------- | :-------------- |
| Pro | 3 (one-time) | Extra usage (~$5–$20/review) |
| Max | 3 (one-time) | Extra usage (~$5–$20/review) |
| Team / Enterprise | None | Extra usage (~$5–$20/review) |

**Comparison:**

| | `/review` | `/ultrareview` |
| :- | :--------- | :-------------- |
| Runs | Locally in your session | Remotely in cloud sandbox |
| Depth | Single-pass | Multi-agent fleet with independent verification |
| Duration | Seconds to a few minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 extra usage |
| Best for | Quick feedback while iterating | Pre-merge confidence on substantial changes |

Use `/tasks` to track, stop, or open detail view for a running review. Requires Claude.ai authentication. Not available on Bedrock, Vertex AI, Microsoft Foundry, or with Zero Data Retention.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, verification, explore/plan/implement workflow, CLAUDE.md, permissions, hooks, skills, subagents, session management, parallel sessions, automation, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — prompt recipes for exploring codebases, fixing bugs, refactoring, testing, PRs, documentation, images, scheduling, resuming sessions, worktrees, plan mode, subagents, piping to scripts
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launch methods, status indicators, browser review interface, execution options (web vs. terminal)
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — multi-agent cloud review, pricing, non-interactive CLI subcommand, comparison with /review

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
