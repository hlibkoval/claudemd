---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices (context management, prompting patterns, CLAUDE.md guidance, session management, parallelism, common failure modes), common workflows (codebase exploration, bug fixing, refactoring, testing, PRs, scheduled tasks), ultraplan (cloud-assisted planning, plan review, execution routing), and ultrareview (multi-agent cloud code review, pricing, CI integration).
user-invocable: false
---

# Best Practices and Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common development workflows, and the ultraplan and ultrareview premium features.

## Quick Reference

### The Core Constraint: Context Window

Everything in Claude Code's best practices flows from one constraint: **context fills fast and performance degrades as it fills**.

| Signal | What to do |
| :--- | :--- |
| Claude "forgetting" earlier instructions | Context is too full — `/clear` and restart with a focused prompt |
| Claude making more mistakes over time | Same; context degradation is cumulative |
| Corrected the same issue twice | Stop correcting; `/clear` and write a better initial prompt |
| Long debugging or exploration session | Use subagents so reads don't consume your main context |

### Give Claude a Way to Verify Its Work

| Strategy | Vague | Specific |
| :--- | :--- | :--- |
| Provide verification criteria | "implement email validation" | "write validateEmail; test cases: user@example.com → true, invalid → false; run the tests after" |
| Verify UI changes visually | "make the dashboard look better" | "[screenshot] implement this design. screenshot the result, compare, list differences, fix them" |
| Address root causes | "the build is failing" | "build fails with [error]. fix it and verify the build succeeds. address root cause, don't suppress" |

### The Explore → Plan → Implement → Commit Workflow

| Phase | Mode | What Claude does |
| :--- | :--- | :--- |
| **Explore** | Plan mode | Reads files, answers questions, makes no changes |
| **Plan** | Plan mode | Produces a written implementation plan; press `Ctrl+G` to open in editor |
| **Implement** | Normal mode | Codes against the plan; runs tests; fixes failures |
| **Commit** | Normal mode | Commits with descriptive message; opens PR |

Skip planning when: scope is clear, the diff is describable in one sentence, the change is small (typo, log line, rename).

### Prompt Specificity Patterns

| Strategy | Before | After |
| :--- | :--- | :--- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "why does ExecutionFactory have a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "add a calendar widget" | "look at how existing widgets are implemented (HotDogWidget.php is a good example), follow the pattern to add a calendar widget…" |
| Describe the symptom | "fix the login bug" | "users report login fails after session timeout. check auth flow in src/auth/, especially token refresh. write a failing test, then fix it" |

### Rich Content Inputs

| Method | How |
| :--- | :--- |
| Reference files | `@path/to/file` — Claude reads it before responding |
| Paste images | Copy/paste or drag-and-drop into prompt |
| Give URLs | Use `/permissions` to allowlist frequently-used domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to use Bash, MCP tools, or file reads to pull its own context |

### CLAUDE.md: What to Include vs. Exclude

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can infer from reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

**Size rule:** If removing a line wouldn't cause Claude to make mistakes, cut it. Bloated CLAUDE.md causes Claude to ignore the actual instructions. Target under ~200 lines. Add emphasis ("IMPORTANT", "YOU MUST") for rules Claude keeps missing.

**CLAUDE.md can import files** using `@path/to/file` syntax:
```markdown
See @README.md for project overview.
- Git workflow: @docs/git-instructions.md
```

**CLAUDE.md locations and scope:**

| Location | Scope |
| :--- | :--- |
| `~/.claude/CLAUDE.md` | All sessions, all projects |
| `./CLAUDE.md` | Project (check into git, shared with team) |
| `./CLAUDE.local.md` | Personal project-specific notes (add to `.gitignore`) |
| Parent directories | Monorepos — both root and subdirectory files auto-load |
| Child directories | Load on demand when Claude works with files there |

### Session Management

| Action | Command / Key |
| :--- | :--- |
| Stop mid-action, preserve context | `Esc` |
| Open rewind menu (restore or summarize) | `Esc Esc` or `/rewind` |
| Reset context entirely | `/clear` |
| Compact with focus instructions | `/compact Focus on the API changes` |
| Side question without entering context | `/btw` |
| Continue most recent session | `claude --continue` |
| Choose a session to resume | `claude --resume` or `/resume` |
| Name a session | `/rename` |

**Rewind options:** restore conversation only, restore code only, restore both, or summarize from a selected message. Checkpoints are created automatically before each change and persist across sessions.

**Auto-compaction** triggers near context limit (~95%); override threshold with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`.

### Permission Modes

| Mode | How it works | Best for |
| :--- | :--- | :--- |
| **Default** | Prompts for file writes, Bash, MCP tools | First-time use; unfamiliar tasks |
| **Auto mode** | Classifier reviews each command; blocks scope escalation, unknown infra, hostile-content actions | Trust the direction, don't want to click through every step |
| **Plan mode** | Claude reads files and plans but makes no edits | Reviewing changes before they touch disk |
| **Allowlists** | Permit specific tools like `npm run lint` or `git commit` | Known-safe recurring commands |
| **Sandbox** | OS-level filesystem/network isolation | Untrusted code or high-risk tasks |

### Parallelism Options

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Worktrees | Separate git checkouts, local | Concurrent edits without collisions |
| Desktop app | Multiple local sessions, visual management | Managing parallel sessions from one screen |
| Claude Code on the web | Anthropic cloud VMs | Tasks that don't need local environment |
| Agent teams | Automated multi-session coordination | Complex workflows needing shared tasks and messaging |

**Writer/Reviewer pattern:** Session A implements; Session B reviews the same code from a clean context (no bias toward code it wrote). Swap for test-first workflows too.

**Fan-out for large migrations:**
```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### Non-Interactive Mode (`-p` flag)

```bash
claude -p "Explain what this project does"
claude -p "List all API endpoints" --output-format json
claude -p "Analyze this log file" --output-format stream-json
claude --permission-mode auto -p "fix all lint errors"
git log --oneline -20 | claude -p "summarize these recent commits"
```

### Common Failure Patterns

| Pattern | Fix |
| :--- | :--- |
| Kitchen-sink session (mixed unrelated tasks) | `/clear` between unrelated tasks |
| Correcting over and over (same issue) | After two failed corrections, `/clear` and write a better prompt |
| Over-specified CLAUDE.md (rules get lost) | Ruthlessly prune; convert ignored rules to hooks |
| Trust-then-verify gap (plausible but broken output) | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration (reads hundreds of files) | Scope investigations narrowly or delegate to subagents |

### Scheduled Task Options

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Routines | Anthropic infrastructure | Tasks that run when your computer is off; trigger on schedule, API, or GitHub events |
| Desktop scheduled tasks | Your machine via desktop app | Tasks needing local files, tools, or uncommitted changes |
| GitHub Actions | CI pipeline | Repo-event tasks (PR opened) or cron schedules |
| `/loop` | Current CLI session | Quick polling while a session is open |

---

### Ultraplan

Ultraplan hands a planning task to a Claude Code on the web session running in plan mode. Your CLI stays free while the plan drafts in the cloud.

**Requirements:** Claude Code on the web account + GitHub repository. Not available on Amazon Bedrock, Google Cloud Vertex AI, or Microsoft Foundry.

**Launch methods:**
- `/ultraplan <your prompt>` — explicit command
- Include the word `ultraplan` anywhere in a normal prompt
- From a local plan dialog — choose "Refine with Ultraplan on Claude Code on the web"

**Status indicators:**

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Researching codebase, drafting plan |
| `◇ ultraplan needs your input` | Clarifying question; open session link to respond |
| `◆ ultraplan ready` | Plan ready to review in browser |

**Browser review features:** inline comments on individual sections, emoji reactions, outline sidebar for navigation.

**Execution choices (from browser):**

| Choice | What happens |
| :--- | :--- |
| Approve and start coding (web) | Implements in the same cloud session; review diff and create PR from browser |
| Approve and teleport back to terminal | Sends plan to terminal; terminal shows "Ultraplan approved" dialog |

**Terminal dialog options after teleport:** Implement here (inject into current conversation), Start new session (fresh context + plan), Cancel (save plan to file).

---

### Ultrareview

Ultrareview launches a fleet of reviewer agents in a remote sandbox to find and independently verify bugs before merge.

**Requirements:** Claude.ai account authentication (`/login`). Not available on Bedrock, Vertex AI, Microsoft Foundry, or with Zero Data Retention enabled.

**How it differs from `/review`:**

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | Locally in your session | Remotely in a cloud sandbox |
| Depth | Single-pass | Multi-agent fleet with independent verification |
| Duration | Seconds to a few minutes | ~5 to 10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 per review as usage credits |
| Best for | Quick feedback while iterating | Pre-merge confidence on substantial changes |

**Usage:**
```text
/ultrareview          # Review branch diff vs. default branch (includes staged/unstaged)
/ultrareview 1234     # Review a specific GitHub PR (clones from GitHub, not local tree)
```

**Non-interactive (CI/scripts):**
```bash
claude ultrareview
claude ultrareview 1234
claude ultrareview origin/main
```

Flags: `--json` (raw bugs.json payload), `--timeout <minutes>` (default 30).

Exit codes: 0 = success (with or without findings), 1 = launch failure/timeout/error, 130 = Ctrl-C interrupted.

**Pricing:**

| Plan | Free runs | After free runs |
| :--- | :--- | :--- |
| Pro | 3 (one-time, non-refreshing) | Usage credits (~$5–$20/review) |
| Max | 3 (one-time, non-refreshing) | Usage credits (~$5–$20/review) |
| Team/Enterprise | None | Usage credits |

Usage credits must be enabled in billing settings before paid reviews can launch. Run `/usage-credits` to check or change.

**Tracking:** Use `/tasks` to see running/completed reviews, open the detail view, or stop a review in progress. Findings appear as a notification with file location and explanation when complete.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, verification strategies, explore-plan-implement workflow, prompting patterns, CLAUDE.md guidance, permissions, tools/MCP/hooks/skills/subagents/plugins, session management, parallelism, non-interactive mode, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — codebase exploration, bug fixing, refactoring, testing, pull requests, documentation, images, @ file references, scheduling options, working in non-code folders
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launch methods, status indicators, browser review interface, execute on web vs. teleport to terminal, requirements and limitations
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — multi-agent review fleet, branch vs. PR mode, pricing and free runs, tracking, non-interactive CI usage, comparison with /review

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
