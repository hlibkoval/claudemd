---
name: best-practices-doc
description: Claude Code best practices, common workflows, ultraplan (cloud-based planning), and ultrareview (deep multi-agent code review).
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and premium cloud features ultraplan and ultrareview.

## Quick Reference

### Core constraint: manage context aggressively

Claude's context window fills fast and performance degrades as it fills. Every file read, command output, and correction consumes tokens. Managing context is the #1 leverage point.

| Signal | Action |
|--------|--------|
| Claude forgetting earlier instructions | `/clear` — reset context entirely |
| Repeated corrections on same issue | `/clear` after 2 failures, restart with better prompt |
| Deep codebase exploration needed | Use subagents (explore in separate context) |
| Context full but work ongoing | `/compact <instructions>` or `Esc+Esc` → Summarize from here |

---

### Give Claude a way to verify its work

| Strategy | Vague prompt | Specific prompt |
|----------|-------------|-----------------|
| Provide verification criteria | *"implement email validation"* | *"write validateEmail. test cases: user@example.com=true, invalid=false. run tests after"* |
| Verify UI visually | *"make dashboard look better"* | *"[paste screenshot] implement this design. take a screenshot and compare. list and fix differences"* |
| Address root causes | *"the build is failing"* | *"build fails with [error]. fix it and verify build succeeds. address root cause, don't suppress the error"* |

---

### Explore → Plan → Implement → Commit workflow

| Phase | Mode | Action |
|-------|------|--------|
| **Explore** | Plan Mode | Read files, understand existing code — no changes |
| **Plan** | Plan Mode | Ask Claude to create a detailed implementation plan; `Ctrl+G` to edit plan in editor |
| **Implement** | Normal Mode | Let Claude code against the plan; verify with tests |
| **Commit** | Normal Mode | Commit with descriptive message, open PR |

Use Plan Mode (`Shift+Tab` twice, or `--permission-mode plan`) for multi-file changes, unfamiliar code, or uncertain approach. Skip planning for single-sentence diffs.

---

### Provide specific context

| Strategy | Do |
|----------|----|
| Scope the task | Specify file, scenario, testing preferences |
| Point to sources | Direct Claude to git history, specific files |
| Reference patterns | Name an existing example (`HotDogWidget.php is a good example`) |
| Describe the symptom | Provide error text, location, and what "fixed" looks like |
| Reference files with `@` | `@src/auth/login.ts` — Claude reads before responding |
| Pipe data | `cat error.log \| claude` |

---

### CLAUDE.md quick rules

| Include | Exclude |
|---------|---------|
| Bash commands Claude can't guess | Anything Claude infers from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Branch naming, PR conventions | Information that changes frequently |
| Architectural decisions specific to project | Long explanations or tutorials |
| Required env vars / environment quirks | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices |

CLAUDE.md can import other files: `@README.md`, `@docs/git-instructions.md`, `@~/.claude/my-overrides.md`.

CLAUDE.md locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project, commit to git), `./CLAUDE.local.md` (personal, gitignore), parent/child directories (auto-loaded).

---

### Permission / interruption modes

| Mode | How to enable | Best for |
|------|--------------|----------|
| **Normal** | Default | Full control, approve each action |
| **Auto mode** | `--permission-mode auto` or `Shift+Tab` → `⏵⏵` | Trust direction but not every step |
| **Plan Mode** | `--permission-mode plan` or `Shift+Tab` twice | Read-only exploration and planning |
| **Allowlists** | `/permissions` | Permit specific safe commands permanently |
| **Sandboxing** | `/sandbox` | OS-level filesystem/network isolation |

---

### Session management commands

| Command | Effect |
|---------|--------|
| `Esc` | Stop Claude mid-action, preserve context |
| `Esc + Esc` / `/rewind` | Open rewind menu — restore conversation, code, or both |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Summarize conversation with guidance on what to preserve |
| `/btw` | Side question that never enters conversation history |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Open session picker |
| `claude -n <name>` / `/rename` | Name a session for later retrieval |

---

### Scaling and automation

| Pattern | Command / approach |
|---------|--------------------|
| Non-interactive (CI, scripts) | `claude -p "prompt" --output-format text\|json\|stream-json` |
| Fan-out across files | Loop `claude -p` calls; use `--allowedTools` to scope permissions |
| Parallel sessions | Claude Code desktop app, worktrees, or agent teams |
| Uninterrupted auto runs | `claude --permission-mode auto -p "..."` |
| Writer / Reviewer pattern | Session A implements; Session B reviews in fresh context |

---

### Common failure patterns

| Anti-pattern | Fix |
|-------------|-----|
| Kitchen sink session (unrelated tasks mixed) | `/clear` between tasks |
| Correcting the same issue repeatedly | After 2 failures: `/clear` + better prompt |
| Over-specified CLAUDE.md (rules get ignored) | Ruthlessly prune; convert stable rules to hooks |
| Trust-then-verify gap (no success criteria) | Always provide tests, scripts, or screenshots |
| Infinite exploration (reads hundreds of files) | Scope investigations narrowly or delegate to subagents |

---

### Common workflows — quick prompts

**Codebase exploration**
- `give me an overview of this codebase`
- `how does authentication work?`
- `trace the login process from front-end to database`

**Bug fixing**
- Share the error → ask for fix recommendations → apply and verify

**Refactoring**
- `find deprecated API usage in our codebase`
- `refactor utils.js to use ES2024 features while maintaining the same behavior`

**Tests**
- `find functions in NotificationsService.swift that are not covered by tests`
- `add tests for the notification service`
- `run the new tests and fix any failures`

**Pull requests**
- `create a pr` (or `summarize changes` → `create a pr` → refine)
- Resume linked PR session later with `claude --from-pr <number>`

**Worktrees (parallel sessions)**
```bash
claude --worktree feature-auth    # Creates .claude/worktrees/feature-auth/
claude --worktree bugfix-123      # Separate worktree, no conflicts
claude --worktree                 # Auto-generates name
```
Use `.worktreeinclude` to copy gitignored files (`.env`) into new worktrees.

**Scheduled tasks**

| Option | Runs on | Best for |
|--------|---------|----------|
| Routines | Anthropic cloud | Tasks needing no local access, or when machine is off |
| Desktop scheduled tasks | Local machine | Tasks needing local files/tools |
| GitHub Actions | CI pipeline | PR/push-triggered tasks |
| `/loop` | Current CLI session | Quick polling while session is open |

**Extended thinking (thinking mode)**
- On by default; toggle with `Option+T` / `Alt+T`
- View thinking: `Ctrl+O` (verbose mode) — gray italic text
- Adjust depth: `/effort`, `--effort` flag, or `CLAUDE_CODE_EFFORT_LEVEL`
- `ultrathink` keyword in prompt = hint to reason more on that turn
- `MAX_THINKING_TOKENS=0` disables thinking entirely

---

### Ultraplan — cloud-based planning

Launches a planning session on Claude Code on the web (plan mode) while your terminal stays free.

| Launch method | Command |
|--------------|---------|
| Command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` anywhere in a prompt |
| From local plan | Choose "Refine with Ultraplan" from plan approval dialog |

**Status indicators in CLI:**

| Indicator | Meaning |
|-----------|---------|
| `◇ ultraplan` | Drafting in progress |
| `◇ ultraplan needs your input` | Claude has a clarifying question — open the link |
| `◆ ultraplan ready` | Plan ready to review in browser |

**Browser review actions:** inline comments on passages, emoji reactions, outline sidebar navigation, iterate as many times as needed.

**Execution options (from browser):**
- **Approve and start coding** — implements in cloud session; review diff, open PR from web
- **Approve and teleport back to terminal** — sends plan to local terminal; choose: implement here / start new session / cancel (saves to file)

Requires Claude Code on the web account + GitHub repo. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

---

### Ultrareview — deep multi-agent code review

Runs a fleet of reviewer agents in a remote cloud sandbox; every finding is independently verified.

| Aspect | `/review` | `/ultrareview` |
|--------|-----------|---------------|
| Runs | Locally | Remote cloud sandbox |
| Depth | Single-pass | Multi-agent with independent verification |
| Duration | Seconds to minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 per review (extra usage) |
| Best for | Quick feedback while iterating | Pre-merge confidence on substantial changes |

**Usage:**
```
/ultrareview           # reviews diff between current branch and default branch
/ultrareview 1234      # reviews GitHub PR #1234 (requires github.com remote)
```

**Free runs:**

| Plan | Free runs | After |
|------|-----------|-------|
| Pro / Max | 3 through May 5, 2026 | Extra usage billing |
| Team / Enterprise | None | Extra usage billing |

Use `/tasks` to track running reviews, view findings, or stop a review in progress. Stopping archives the cloud session — no partial findings returned.

Requires claude.ai account login. Not available on Bedrock, Vertex AI, Foundry, or with Zero Data Retention enabled.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [claude-code-best-practices.md](references/claude-code-best-practices.md) — Tips and patterns for getting the most out of Claude Code: context management, verification, plan mode workflow, CLAUDE.md, permissions, scaling, common failure patterns
- [claude-code-common-workflows.md](references/claude-code-common-workflows.md) — Step-by-step recipes for exploring codebases, fixing bugs, refactoring, testing, PRs, worktrees, extended thinking, session management, scheduling, and unix-style piping
- [claude-code-ultraplan.md](references/claude-code-ultraplan.md) — Ultraplan: launch, review, and execute cloud-based plans from the CLI
- [claude-code-ultrareview.md](references/claude-code-ultrareview.md) — Ultrareview: deep multi-agent pre-merge code review in a remote sandbox

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
