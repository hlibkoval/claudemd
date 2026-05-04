---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, ultraplan (cloud-based planning), and ultrareview (multi-agent code review) — prompting patterns, context management, session control, parallel sessions, automation, and scheduled tasks.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and the ultraplan and ultrareview features.

## Quick Reference

### Core Constraint: Context Window

Claude's context window fills quickly and performance degrades as it fills. Managing context is the single most important resource constraint.

| Signal | Action |
| :--- | :--- |
| Claude forgetting earlier instructions | `/clear` — reset context |
| Two failed corrections on same issue | `/clear` and rewrite prompt from scratch |
| Long session with unrelated tasks | `/clear` between each task |
| Large codebase investigation | Use subagents so reads don't fill main context |
| Bloated CLAUDE.md | Ruthlessly prune — long files cause Claude to ignore rules |

### Give Claude a Way to Verify Its Work

| Strategy | Weak prompt | Strong prompt |
| :--- | :--- | :--- |
| Provide verification criteria | "implement email validation" | "write validateEmail. test cases: user@example.com=true, invalid=false. run tests after implementing" |
| Verify UI visually | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot of the result and compare it to the original" |
| Address root causes | "the build is failing" | "the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause" |

### Explore → Plan → Implement → Commit

```
# Step 1: Explore (plan mode — no edits)
read /src/auth and understand how we handle sessions and login.

# Step 2: Plan (still plan mode)
I want to add Google OAuth. What files need to change? Create a plan.
# Press Ctrl+G to open the plan in your editor for review

# Step 3: Implement (switch out of plan mode)
implement the OAuth flow from your plan. write tests and fix any failures.

# Step 4: Commit
commit with a descriptive message and open a PR
```

Use plan mode for changes that touch multiple files or when you're unfamiliar with the code. Skip planning for small, clear-scope tasks.

### Provide Specific Context

| Strategy | Example |
| :--- | :--- |
| Scope the task | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Reference files with `@` | `@src/auth.js` — Claude reads the file before responding |
| Point to existing patterns | "look at HotDogWidget.php to understand patterns, then implement a calendar widget" |
| Describe the symptom | "users report login fails after session timeout. check src/auth/, write a failing test, then fix it" |
| Pipe data | `cat error.log \| claude` |

### CLAUDE.md: What to Include vs. Exclude

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

CLAUDE.md files support `@path/to/import` syntax for importing other files. Place them at `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project, commit to git), `./CLAUDE.local.md` (personal, gitignore it), or in subdirectories.

### Permission Modes

| Mode | How | Best for |
| :--- | :--- | :--- |
| Default | Prompts for each risky action | Careful, step-by-step work |
| Auto mode | Classifier blocks risky actions automatically | Trusting the task direction without click-through |
| Allowlists | Permit specific tools (e.g., `npm run lint`) | Known-safe repeated commands |
| Sandbox | OS-level filesystem/network isolation | Unrestricted execution within boundaries |

### Session Management Commands

| Command | Effect |
| :--- | :--- |
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc + Esc` or `/rewind` | Open rewind menu — restore conversation/code to a checkpoint |
| `/clear` | Reset the context window entirely |
| `/compact <instructions>` | Compact with custom focus (e.g., `/compact Focus on the API changes`) |
| `/btw` | Side question — answer shown in overlay, never enters context |
| `/rename` | Name the current session |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Choose a session from a list |

### Automation and Parallelism

```bash
# Non-interactive one-off
claude -p "Explain what this project does"

# Structured output for scripts
claude -p "List all API endpoints" --output-format json

# Streaming for real-time processing
claude -p "Analyze this log file" --output-format stream-json

# Batch migration (fan-out pattern)
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done

# Auto mode for uninterrupted runs
claude --permission-mode auto -p "fix all lint errors"
```

### Parallel Sessions

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Worktrees (`claude --worktree <name>`) | Isolated git checkouts | Parallel edits without collisions |
| Desktop app | Multiple local sessions visually | Managed parallel local work |
| Claude Code on the web | Anthropic-managed cloud VMs | Remote execution |
| Agent teams | Coordinated multi-session with shared tasks | Automated orchestration |

**Writer/Reviewer pattern:** Session A implements; Session B reviews `@src/middleware/rateLimiter.ts` for edge cases without bias from having written it.

### Scheduled Tasks

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Routines | Anthropic-managed infrastructure | Tasks that run even when your computer is off |
| Desktop scheduled tasks | Your machine (desktop app) | Tasks needing local file/tool access |
| GitHub Actions | CI pipeline | Repo-event-triggered or cron tasks |
| `/loop` | Current CLI session | Quick polling while a session is open |

### Common Failure Patterns to Avoid

| Failure pattern | Fix |
| :--- | :--- |
| Kitchen sink session (mixing unrelated tasks) | `/clear` between unrelated tasks |
| Correcting over and over (polluted context) | After two failures, `/clear` and rewrite the prompt |
| Over-specified CLAUDE.md (rules get ignored) | Ruthlessly prune; convert stable rules to hooks |
| Trust-then-verify gap (plausible but broken output) | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration (Claude reads hundreds of files) | Scope investigations narrowly or use subagents |

### Common Workflow Prompts

| Task | Prompt |
| :--- | :--- |
| Codebase overview | "give me an overview of this codebase" |
| Find relevant code | "find the files that handle user authentication" |
| Fix a bug | "I'm seeing an error when I run npm test" → "update user.ts to add the null check you suggested" |
| Refactor | "find deprecated API usage" → "refactor utils.js to use ES2024 features while maintaining behavior" |
| Write tests | "find functions in NotificationsService.swift that are not covered by tests" |
| Create a PR | "create a pr" (or ask Claude directly; PR is linked to the session for `/resume`) |
| Documentation | "find functions without proper JSDoc comments in the auth module" → "add JSDoc comments" |
| Research delegation | "use a subagent to investigate how our auth system handles token refresh" |
| Interview for specs | "I want to build [X]. Interview me in detail using the AskUserQuestion tool." |

---

### Ultraplan (Cloud-Based Planning)

Ultraplan hands a planning task to a Claude Code on the web session in plan mode. Claude drafts the plan remotely while your terminal stays free.

**Launch from the CLI:**

```
/ultraplan migrate the auth service from sessions to JWTs
```

Or include the word `ultraplan` anywhere in a prompt. Or, when Claude finishes a local plan, choose "No, refine with Ultraplan on Claude Code on the web."

**Status indicators while the cloud session works:**

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is researching your codebase and drafting the plan |
| `◇ ultraplan needs your input` | Claude has a clarifying question; open the session link |
| `◆ ultraplan ready` | Plan is ready to review in your browser |

**Review in browser:** inline comments on individual sections, emoji reactions, outline sidebar for navigation.

**Execute options (from browser):**
- **Approve Claude's plan and start coding** — implements in the cloud session; review diff and create PR from the web interface
- **Approve plan and teleport back to terminal** — sends plan to your waiting terminal; choose Implement here, Start new session, or Cancel (saves to file)

**Requirements:** Claude.ai account + GitHub repository. Not available on Amazon Bedrock, Vertex AI, or Microsoft Foundry.

---

### Ultrareview (Multi-Agent Cloud Code Review)

Ultrareview runs a fleet of reviewer agents in a remote sandbox to find and independently verify bugs before merge.

**Run from CLI:**

```
/ultrareview            # Reviews diff between current branch and default branch
/ultrareview 1234       # Reviews GitHub PR #1234
claude ultrareview      # Non-interactive (CI/scripts) — blocks, prints findings, exits 0/1
claude ultrareview 1234
claude ultrareview origin/main
```

**Comparison with `/review`:**

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | locally in your session | remotely in a cloud sandbox |
| Depth | single-pass review | multi-agent fleet with independent verification |
| Duration | seconds to a few minutes | ~5–10 minutes |
| Cost | normal usage | 3 free runs (Pro/Max, expires May 5 2026), then ~$5–$20 extra usage |
| Best for | quick feedback while iterating | pre-merge confidence on substantial changes |

**Non-interactive flags:**

| Flag | Description |
| :--- | :--- |
| `--json` | Print raw `bugs.json` payload instead of formatted findings |
| `--timeout <minutes>` | Max minutes to wait (default: 30) |

**Track progress:** use `/tasks` to see running/completed reviews, open detail view, or stop a review. Stopping archives the cloud session; partial findings are not returned.

**Requirements:** Claude.ai account (run `/login` if using API key only). Not available on Bedrock, Vertex AI, Microsoft Foundry, or with Zero Data Retention enabled. Extra usage must be enabled for paid reviews.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, verification, explore-plan-implement workflow, CLAUDE.md setup, permissions, hooks, skills, subagents, plugins, session management, automation, parallel sessions, and common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — prompt recipes for exploring codebases, fixing bugs, refactoring, testing, PRs, documentation, images, file references, and scheduled tasks; plus resume, worktrees, plan mode, subagents, and piping
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching ultraplan, status indicators, browser review interface (inline comments, reactions, outline sidebar), execute on the web vs. teleport back to terminal
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — running ultrareview interactively and non-interactively, pricing/free runs, tracking progress, comparing with `/review`

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
