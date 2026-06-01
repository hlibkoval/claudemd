---
name: best-practices-doc
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices: core patterns, common workflows, large codebase configuration, ultraplan (cloud planning), ultrareview (deep code review), and dynamic workflows.

## Quick Reference

### Core Constraint: Context Window

Everything in a session — messages, file reads, command output — fills the context window. Performance degrades as it fills. Managing context is the single most important practice.

| Signal | Action |
|:-------|:-------|
| Repeated corrections on same issue | `/clear` and rewrite prompt incorporating lessons learned |
| Unrelated tasks accumulating | `/clear` between tasks |
| Long exploration consuming context | Use subagents — they read files in their own context |
| Context approaching limit | `/compact <focus>` or `Esc+Esc` → Summarize |

### Workflow Phases: Explore → Plan → Implement → Commit

| Phase | Mode | What happens |
|:------|:-----|:-------------|
| Explore | Plan mode | Claude reads files, answers questions; no edits |
| Plan | Plan mode | Claude creates implementation plan; `Ctrl+G` to edit in your editor |
| Implement | Default | Claude codes, runs tests, fixes failures |
| Commit | Default | Claude commits with message and opens PR |

Use `--permission-mode plan` or `Shift+Tab` to toggle plan mode.

### Give Claude a Way to Verify Its Work

| Gate level | How | Setup cost |
|:-----------|:----|:----------|
| Single prompt | Ask Claude to run check and iterate in same message | None |
| `/goal` condition | Evaluator re-checks after every turn until condition holds | Low |
| Stop hook | Script blocks turn from ending until check passes (max 8 blocks) | Medium |
| Verification subagent | Fresh model tries to refute the result | Medium |

### Prompt Specificity Patterns

| Strategy | Vague | Specific |
|:---------|:------|:---------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case. avoid mocks." |
| Point to sources | "why is this API weird?" | "look through ExecutionFactory's git history and summarize how its API evolved" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php to understand widget patterns, then implement a calendar widget" |
| Describe symptom | "fix the login bug" | "users report login fails after session timeout. check src/auth/, write a failing test, then fix it" |

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

### Session Management Commands

| Command | Effect |
|:--------|:-------|
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc+Esc` or `/rewind` | Open rewind menu to restore prior state |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact with focus, e.g. `/compact Focus on API changes` |
| `/btw` | Side question — answer never enters conversation history |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Choose from session list |
| `/rename` | Name current session (e.g. `oauth-migration`) |

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

Writer/Reviewer pattern example:
- Session A: `Implement a rate limiter for our API endpoints`
- Session B: `Review @src/middleware/rateLimiter.ts for edge cases, race conditions, and consistency with existing patterns`
- Session A: `Here's the review feedback: [Session B output]. Address these issues.`

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen sink session — mixing unrelated tasks | `/clear` between tasks |
| Correcting the same issue more than twice | `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md — rules get lost in noise | Ruthlessly prune; convert rules Claude follows naturally into hooks |
| Trust-then-verify gap — plausible but incorrect implementation | Always provide verification: tests, scripts, screenshots |
| Infinite exploration — Claude reads hundreds of files | Scope investigations narrowly or use subagents |

---

### Large Codebases and Monorepos

| Goal | Setting / Mechanism |
|:-----|:--------------------|
| Load only relevant conventions | Per-directory CLAUDE.md files |
| Exclude other teams' CLAUDE.md files | `claudeMdExcludes` in `settings.local.json` |
| Block reads of build output and vendored code | `Read` deny rules in `permissions.deny` |
| Symbol navigation without file scanning | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktree checkout | `worktree.sparsePaths` in `settings.json` |
| Cross-package file access | `additionalDirectories` setting or `--add-dir` flag |
| Per-package skills | `.claude/skills/` inside the subdirectory |

**Starting directory determines scope:**
- Start from repo root → access to all files; only root CLAUDE.md at launch
- Start from subdirectory → that subtree only; that directory's + all ancestor CLAUDE.md files loaded

**Key settings file locations:**
- `.claude/settings.json` — committed, applies from starting directory
- `.claude/settings.local.json` — personal, gitignored

---

### Ultraplan (Cloud Planning)

| Entry point | How |
|:------------|:----|
| Command | `/ultraplan <prompt>` |
| Keyword | Include "ultraplan" anywhere in a normal prompt |
| From local plan | In approval dialog, choose "No, refine with Ultraplan on Claude Code on the web" |

Status indicators:
- `◇ ultraplan` — Claude is drafting the plan remotely
- `◇ ultraplan needs your input` — open session link to answer a clarifying question
- `◆ ultraplan ready` — plan is ready to review in browser

Execution options after review:
- **Approve and start coding** — implement in the same cloud session; review diff and open PR from web
- **Approve and teleport back to terminal** — implement locally; web session is archived

Teleport options in terminal dialog:
- **Implement here** — inject plan into current conversation
- **Start new session** — fresh context with plan only
- **Cancel** — save plan to file; Claude prints the path

Requires Claude Code on the web account and a GitHub repository. Not available on Bedrock, Vertex AI, or Foundry.

---

### Ultrareview (Deep Code Review)

| Command | Scope |
|:--------|:------|
| `/code-review ultra` | Current branch diff vs. default branch (including uncommitted changes) |
| `/code-review ultra 1234` | GitHub pull request by number |
| `claude ultrareview` | Non-interactive; same as above, exits with findings on stdout |
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

Non-interactive flags:
- `--json` — print raw `bugs.json` instead of formatted findings
- `--timeout <minutes>` — max wait time (default: 30)

---

### Dynamic Workflows

| When to use | Subagents | Skills | Workflows |
|:------------|:----------|:-------|:----------|
| Who decides what runs next | Claude, turn by turn | Claude, following prompt | The script |
| Where intermediate results live | Claude's context | Claude's context | Script variables |
| Scale | Few delegated tasks | Same | Dozens to hundreds of agents per run |
| Interruption | Restarts the turn | Restarts the turn | Resumable in same session |

**Launch options:**
- Include the word `workflow` in a prompt → Claude writes and runs a script for that task
- `/effort ultracode` → Claude automatically plans workflows for every substantive task
- `/deep-research <question>` — built-in workflow; fans out web searches, cross-checks sources, returns cited report
- `/workflows` — list and monitor running/completed workflows

**Approval modes:**

| Permission mode | When prompted |
|:----------------|:--------------|
| Default, accept edits | Every run (unless "don't ask again" selected) |
| Auto | First launch only |
| Bypass permissions, `-p`, Agent SDK | Never |

**Save for reuse:** In `/workflows`, select a run and press `s`. Save to `.claude/workflows/` (shared) or `~/.claude/workflows/` (personal). Saved workflows become `/<name>` commands.

**Limits:** Up to 16 concurrent agents; 1,000 agents total per run. No mid-run user input (except permission prompts).

**Disable workflows:**
- `/config` → toggle off, or `"disableWorkflows": true` in `settings.json`, or `CLAUDE_CODE_DISABLE_WORKFLOWS=1`

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
| Scheduled task | Use Routines (Anthropic cloud), Desktop scheduled tasks, GitHub Actions, or `/loop` |

**Reference files with `@`:** `@src/utils/auth.js` adds file content; `@src/components` adds directory listing.

**Provide rich context:** paste images (Ctrl+V), give URLs, pipe data with `cat error.log | claude`.

**Let Claude interview you for large features:**
> "I want to build [brief description]. Interview me in detail using the AskUserQuestion tool. Ask about technical implementation, UI/UX, edge cases, and tradeoffs. Keep interviewing until we've covered everything, then write a complete spec to SPEC.md."

Start fresh after the spec is written — new session, clean context, focused on implementation.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — Core patterns: verify work, explore-plan-implement, prompt specificity, CLAUDE.md, permissions, session management, parallel sessions, common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — Prompt recipes for codebase exploration, bug fixing, refactoring, testing, PRs, documentation; resume sessions; worktrees; plan mode; subagents; piping Claude into scripts
- [Monorepos and Large Codebases](references/claude-code-large-codebases.md) — Per-directory CLAUDE.md, claudeMdExcludes, Read deny rules, code intelligence plugins, sparse worktrees, cross-package access, per-directory skills
- [Ultraplan](references/claude-code-ultraplan.md) — Cloud-based planning: launch from CLI, review and revise in browser, execute on web or teleport back to terminal
- [Ultrareview](references/claude-code-ultrareview.md) — Deep multi-agent code review: run from CLI or non-interactively, pricing/free runs, tracking, comparison with local `/review`
- [Dynamic Workflows](references/claude-code-workflows.md) — Orchestrating subagents at scale: when to use, bundled `/deep-research`, writing custom workflows, ultracode, approval modes, saving for reuse, managing runs

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Monorepos and Large Codebases: https://code.claude.com/docs/en/large-codebases.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Dynamic Workflows: https://code.claude.com/docs/en/workflows.md
