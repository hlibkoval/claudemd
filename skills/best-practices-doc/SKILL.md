---
name: best-practices-doc
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, large codebase configuration, dynamic workflows, ultraplan, and ultrareview.

## Quick Reference

### Core Constraint: Context Window

Everything in a session — messages, file reads, command output — fills the context window. Performance degrades as it fills. Managing context is the single most important practice.

| Signal | Action |
|:-------|:-------|
| Claude "forgetting" earlier instructions | `/clear` and restart with a tighter prompt |
| Claude ignoring CLAUDE.md rules | CLAUDE.md is too long — prune it |
| Claude reads hundreds of files to find a symbol | Install a code intelligence plugin |
| Long session drifting off track | `/compact <instructions>` or `/rewind` |

---

### Workflow Phases: Explore → Plan → Implement → Commit

| Phase | Mode | What happens |
|:------|:-----|:-------------|
| Explore | Plan mode | Claude reads files, answers questions; no edits |
| Plan | Plan mode | Claude creates implementation plan; `Ctrl+G` to edit in your editor |
| Implement | Default | Claude codes, runs tests, fixes failures |
| Commit | Default | Claude commits with message and opens PR |

Use `--permission-mode plan` or `Shift+Tab` to toggle plan mode. Skip planning for one-sentence changes.

---

### Give Claude a Way to Verify Its Work

| Gate level | How | Setup cost |
|:-----------|:----|:----------|
| Single prompt | Ask Claude to run check and iterate in same message | None |
| `/goal` condition | Evaluator re-checks after every turn until condition holds | Low |
| Stop hook | Script blocks turn from ending until check passes (max 8 consecutive blocks) | Medium |
| Verification subagent | Fresh model tries to refute the result independently | Medium |

Always ask Claude to show evidence (test output, screenshot, command result) rather than asserting success.

---

### Prompt Specificity Patterns

| Strategy | Vague | Specific |
|:---------|:------|:---------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case. avoid mocks." |
| Point to sources | "why is this API weird?" | "look through ExecutionFactory's git history and summarize how its API evolved" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php to understand widget patterns, then implement a calendar widget without new libraries" |
| Describe symptom | "fix the login bug" | "users report login fails after session timeout. check src/auth/, write a failing test, then fix the root cause" |

Rich content: use `@file` references, paste images directly, give URLs, or pipe data with `cat error.log | claude`.

---

### CLAUDE.md Guidelines

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

CLAUDE.md placement options:
- `~/.claude/CLAUDE.md` — applies to all sessions
- `./CLAUDE.md` — check in to share with team
- `./CLAUDE.local.md` — personal project-specific notes (gitignore this)
- Parent/child directories — loaded hierarchically as Claude reads files there

Import other files with `@path/to/file` syntax inside CLAUDE.md.

---

### Session Management Commands

| Command | Effect |
|:--------|:-------|
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc Esc` or `/rewind` | Open rewind menu to restore prior conversation/code state |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact with focus, e.g. `/compact Focus on API changes` |
| `/btw` | Side question — answer never enters conversation history |
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Choose from session list |
| `/rename` | Name current session (e.g. `oauth-migration`) |

After two failed corrections on the same issue, `/clear` and write a better initial prompt incorporating what you learned.

---

### Parallel and Automation Patterns

| Pattern | Command / Method |
|:--------|:----------------|
| Non-interactive one-off | `claude -p "prompt"` |
| Structured output | `claude -p "prompt" --output-format json` |
| Streaming | `claude -p "prompt" --output-format stream-json --verbose` |
| Isolated parallel session | `claude --worktree feature-auth` |
| Fan-out migration | Loop calling `claude -p` per file with `--allowedTools` |
| Auto mode (unattended) | `claude --permission-mode auto -p "fix all lint errors"` |
| Adversarial review | Ask subagent to review diff against plan; report gaps not style |

Writer/Reviewer pattern:
- Session A: `Implement a rate limiter for our API endpoints`
- Session B: `Review @src/middleware/rateLimiter.ts for edge cases, race conditions, and consistency with existing patterns`
- Session A: `Here's the review feedback: [Session B output]. Address these issues.`

---

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen sink session — mixing unrelated tasks | `/clear` between tasks |
| Correcting the same issue more than twice | `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md — rules get lost in noise | Ruthlessly prune; convert always-true rules to hooks |
| Trust-then-verify gap — plausible but incorrect implementation | Always provide verification: tests, scripts, screenshots |
| Infinite exploration — Claude reads hundreds of files | Scope investigations narrowly or delegate to a subagent |

---

### Large Codebases and Monorepos

| Goal | Setting / Mechanism |
|:-----|:--------------------|
| Load only relevant conventions | Per-directory CLAUDE.md files |
| Exclude other teams' CLAUDE.md files | `claudeMdExcludes` in `settings.local.json` |
| Block reads of build output and vendored code | `Read` deny rules in `permissions.deny` |
| Symbol navigation without file scanning | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktree checkout | `worktree.sparsePaths` in `.claude/settings.json` |
| Avoid duplicating `node_modules` across worktrees | `worktree.symlinkDirectories` |
| Cross-package file access | `additionalDirectories` setting or `--add-dir` flag |
| Load CLAUDE.md from `--add-dir` directories | Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |
| Per-package skills | `.claude/skills/` inside the subdirectory |

**Starting directory determines scope:**
- Start from repo root → access to all files; only root CLAUDE.md at launch
- Start from subdirectory → that subtree only; that directory's + all ancestor CLAUDE.md files loaded

**Key settings file locations:**
- `.claude/settings.json` — committed, applies from starting directory
- `.claude/settings.local.json` — personal, gitignored

---

### Common Workflow Recipes

| Task | Prompt pattern |
|:-----|:---------------|
| Codebase overview | "give me an overview of this codebase" |
| Understand component | "how do these authentication files work together?" |
| Trace a flow | "trace the login process from front-end to database" |
| Fix a bug | "I'm seeing this error: [error]. reproduce it with a failing test, then fix the root cause" |
| Refactor safely | "refactor utils.js to use ES2024 features while maintaining the same behavior. run tests after" |
| Add tests | "find functions in NotificationsService.swift not covered by tests, add edge-case tests, run and fix failures" |
| Create PR | "create a pr" or "summarize my changes, then create a pr" |
| Scheduled task | Use Routines (Anthropic cloud), Desktop scheduled tasks, GitHub Actions, or `/loop` (current session) |

**Reference files with `@`:** `@src/utils/auth.js` adds file content; `@src/components` adds directory listing. MCP resources use `@server:resource` format.

**Let Claude interview you for large features:**
> "I want to build [brief description]. Interview me in detail using the AskUserQuestion tool. Ask about technical implementation, UI/UX, edge cases, and tradeoffs. Keep interviewing until we've covered everything, then write a complete spec to SPEC.md."

Start a fresh session to implement the spec — clean context, focused on implementation.

---

### Ultraplan (Cloud Planning)

Ultraplan hands a planning task to a Claude Code on the web session running in plan mode. Your terminal stays free while the plan is drafted remotely.

| Entry point | How |
|:------------|:----|
| Command | `/ultraplan <prompt>` |
| Keyword | Include "ultraplan" anywhere in a normal prompt |
| From local plan | In approval dialog, choose "No, refine with Ultraplan on Claude Code on the web" |

Status indicators:

| Status | Meaning |
|:-------|:--------|
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Open the session link to answer a clarifying question |
| `◆ ultraplan ready` | Plan is ready to review in browser |

After review, choose:
- **Approve and start coding** — implement in the same cloud session; review diff and open PR from web
- **Approve and teleport back to terminal** — implement locally; web session archived; terminal dialog offers: Implement here / Start new session / Cancel (saves plan to file)

Requires Claude Code on the web account and a GitHub repository. Not available on Bedrock, Vertex AI, or Foundry.

---

### Ultrareview (Deep Code Review)

| Command | Scope |
|:--------|:------|
| `/code-review ultra` | Current branch diff vs. default branch (including uncommitted changes) |
| `/code-review ultra 1234` | GitHub pull request by number |
| `claude ultrareview` | Non-interactive; findings printed to stdout |
| `claude ultrareview 1234` | Non-interactive PR review |
| `claude ultrareview origin/main` | Non-interactive diff against a base branch |

**`/review` vs. `/code-review ultra`:**

| | `/review` | `/code-review ultra` |
|:-|:----------|:--------------------|
| Runs | Locally in session | Remotely in cloud sandbox |
| Depth | Single-pass | Multi-agent fleet with independent verification |
| Duration | Seconds to a few minutes | Roughly 5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 per review as usage credits |
| Best for | Quick feedback while iterating | Pre-merge confidence on substantial changes |

Free runs: Pro and Max get 3 (one-time, non-refreshing). Team and Enterprise: none included. Usage credits must be enabled for paid runs.

Non-interactive flags: `--json` (raw `bugs.json`), `--timeout <minutes>` (default: 30).

---

### Dynamic Workflows

Workflows move orchestration into a JavaScript script so intermediate results stay in script variables, not Claude's context. Supports up to 1,000 agents per run, 16 concurrent.

| | Subagents | Skills | Workflows |
|:-|:----------|:-------|:----------|
| Who decides what runs next | Claude, turn by turn | Claude, following prompt | The script |
| Intermediate results | Claude's context | Claude's context | Script variables |
| Scale | Few per turn | Same | Dozens to hundreds per run |
| Interruption | Restarts the turn | Restarts the turn | Resumable in same session |

**Launch options:**
- Include the word `workflow` in a prompt → Claude writes and runs a script for that task
- `/effort ultracode` → Claude automatically plans workflows for every substantive task in the session
- `/deep-research <question>` — built-in fan-out web research workflow
- `/workflows` — list and monitor running/completed workflows

**Progress view keys:**

| Key | Action |
|:----|:-------|
| `↑`/`↓` | Select phase or agent |
| `Enter`/`→` | Drill into phase or agent detail |
| `p` | Pause or resume the run |
| `x` | Stop agent or whole workflow |
| `r` | Restart selected running agent |
| `s` | Save run's script as a reusable command |

**Approval modes:**

| Permission mode | When prompted |
|:----------------|:--------------|
| Default, accept edits | Every run (unless "don't ask again" selected) |
| Auto | First launch only |
| Bypass permissions, `-p`, Agent SDK | Never |

**Save for reuse:** In `/workflows`, press `s`. Save to `.claude/workflows/` (shared) or `~/.claude/workflows/` (personal). Saved workflows become `/<name>` commands.

**Disable:** `/config` toggle, `"disableWorkflows": true` in `settings.json`, or `CLAUDE_CODE_DISABLE_WORKFLOWS=1`.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — Core patterns: verify work, explore-plan-implement, prompt specificity, CLAUDE.md, permissions, hooks, skills, subagents, plugins, session management, non-interactive mode, parallel sessions, failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — Prompt recipes for codebase exploration, bug fixing, refactoring, testing, PRs, documentation, images, scheduled tasks; resume sessions; worktrees; plan mode; subagents; piping Claude into scripts
- [Monorepos and Large Codebases](references/claude-code-large-codebases.md) — Layered CLAUDE.md files, claudeMdExcludes, Read deny rules, code intelligence plugins, sparse worktrees, symlinkDirectories, additionalDirectories, per-directory skills, centralizing with plugins
- [Ultraplan](references/claude-code-ultraplan.md) — Cloud-based planning: launch methods, status indicators, inline comments and reactions in browser, execute on web vs. teleport back to terminal
- [Ultrareview](references/claude-code-ultrareview.md) — Multi-agent remote code review: pricing and free runs, tracking runs, non-interactive subcommand, comparison with local `/review`
- [Dynamic Workflows](references/claude-code-workflows.md) — When to use workflows vs. subagents vs. skills, bundled `/deep-research`, having Claude write a workflow, ultracode, approval flow, saving for reuse, managing runs, cost, disabling

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Monorepos and Large Codebases: https://code.claude.com/docs/en/large-codebases.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Dynamic Workflows: https://code.claude.com/docs/en/workflows.md
