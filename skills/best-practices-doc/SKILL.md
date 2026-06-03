---
name: best-practices-doc
user-invocable: false
---

# Best Practices & Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, large-codebase configuration, ultraplan, ultrareview, and dynamic workflows.

## Quick Reference

### Core Best Practices

| Practice | Key guidance |
|:---------|:-------------|
| **Give Claude a verification check** | Provide tests, build exit codes, linters, or screenshots — closes the feedback loop without human polling |
| **Explore first, then plan, then code** | Use plan mode to separate research from implementation; `Shift+Tab` or `--permission-mode plan` |
| **Provide specific context** | Reference files with `@`, paste images/errors, point to example patterns, scope the task |
| **Manage context aggressively** | `/clear` between unrelated tasks; `/compact <instructions>` for selective compaction |
| **Course-correct early** | `Esc` to stop, `Esc+Esc` / `/rewind` to restore prior state |
| **Use subagents for investigation** | Delegate file exploration so reads don't fill your main context |

### Explore → Plan → Implement → Commit Workflow

| Phase | Mode | What to do |
|:------|:-----|:-----------|
| Explore | Plan mode | Read files, answer questions — no edits |
| Plan | Plan mode | Ask for an implementation plan; `Ctrl+G` to edit in your text editor |
| Implement | Default mode | Code against the plan, run tests, fix failures |
| Commit | Default mode | Commit with a descriptive message, open a PR |

Skip planning when the change is small enough to describe in one sentence.

### Verification Strategies

| Approach | Setup | When to use |
|:---------|:------|:------------|
| Inline check in prompt | None | Any task today |
| `/goal` condition | Moderate | Unattended session that must reach a state |
| Stop hook | Script | Deterministic gate — blocks until check passes (overridden after 8 consecutive blocks) |
| Verification subagent | Prompt | Fresh-context review; not biased toward code it just wrote |

### Context Management

| Command / pattern | Effect |
|:-----------------|:-------|
| `/clear` | Reset context window entirely |
| `/compact <instructions>` | Compact with custom focus (e.g. "Focus on the API changes") |
| `Esc+Esc` / `/rewind` → Summarize | Condense part of the conversation history |
| `/btw` | Side question in dismissible overlay — never enters conversation history |
| Use subagents for exploration | File reads stay out of main context |

### CLAUDE.md Guidelines

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude infers from code |
| Code style rules that differ from defaults | Standard language conventions |
| Test runner instructions | Detailed API docs (link instead) |
| Branch naming, PR conventions | Info that changes frequently |
| Architectural decisions specific to your project | File-by-file codebase descriptions |
| Developer environment quirks, required env vars | Long explanations or tutorials |
| Common non-obvious gotchas | Self-evident practices ("write clean code") |

Treat CLAUDE.md like code: prune regularly, use `@path` imports, add emphasis ("IMPORTANT", "YOU MUST") for critical rules. Check it in to git.

### Session Management Commands

| Command | Effect |
|:--------|:-------|
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc+Esc` / `/rewind` | Open rewind menu — restore conversation, code, or both to any checkpoint |
| `/clear` | Reset context between unrelated tasks |
| `/rename` | Name the current session |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Pick a session from a list |

### Parallelism & Automation Patterns

| Pattern | How |
|:--------|:----|
| Parallel sessions | Worktrees, Desktop app, cloud, or agent teams |
| Writer / Reviewer | Session A implements; Session B reviews the diff in a fresh context |
| Non-interactive CI | `claude -p "prompt"` — pipe stdin/stdout; `--output-format json` or `stream-json` |
| Fan-out migration | Generate file list → loop `claude -p "Migrate $file …" --allowedTools "Edit,Bash(git commit *)"` |
| Autonomous run | `claude --permission-mode auto -p "fix all lint errors"` |
| Adversarial review | Subagent reviews diff against a plan; returns gaps to implementing session |

### Common Failure Patterns to Avoid

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen-sink session (unrelated tasks mixed) | `/clear` between tasks |
| Repeated corrections on same issue | After two failures, `/clear` and write a better prompt |
| Over-specified CLAUDE.md (rules get lost) | Ruthlessly prune; convert ignored rules to hooks |
| Trust-then-verify gap (no check) | Always provide tests, scripts, or screenshots |
| Infinite exploration (no scope) | Scope investigations narrowly or delegate to subagents |

---

### Large Codebases / Monorepo Settings

| Goal | Setting / mechanism |
|:-----|:-------------------|
| Load only relevant conventions | Per-directory `CLAUDE.md` files (committed alongside code) |
| Exclude other teams' CLAUDE.md files | `claudeMdExcludes` in `.claude/settings.local.json` (glob patterns) |
| Block reads of generated/vendored code | `Read` deny rules in `permissions.deny` (e.g. `"Read(./**/dist/**)"`) |
| Navigate symbols without file scans | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktrees | `worktree.sparsePaths` in `.claude/settings.json` (list directories, not files) |
| Symlink large dirs across worktrees | `worktree.symlinkDirectories` |
| Access sibling packages | `additionalDirectories` in settings, or `--add-dir ../shared` at launch |
| Load CLAUDE.md from `--add-dir` directories | Set env var `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |
| Per-directory skills | `.claude/skills/<name>/SKILL.md` inside the subdirectory (committed) |
| Scope a skill to file patterns | `paths` frontmatter glob in the skill |
| Centralize conventions at scale | Plugin owned by platform team; MCP code-search server |

**`additionalDirectories` vs `--add-dir`:**

| Added with | Loads CLAUDE.md and rules | Loads skills |
|:-----------|:--------------------------|:-------------|
| `additionalDirectories` setting | Never | Never |
| `--add-dir` / `/add-dir` | Only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` | Yes |

**Where to start Claude in a monorepo:**

| Start from | File access | CLAUDE.md loaded at launch |
|:-----------|:------------|:--------------------------|
| Repository root | Every file | Root only; subdirs load on demand |
| A subdirectory | That subtree only | That dir's + every ancestor's |

---

### Ultraplan (Cloud Planning — Research Preview)

Requires Claude Code v2.1.91+. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

| Trigger | How |
|:--------|:----|
| CLI command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` anywhere in a prompt |
| From local plan | At plan approval dialog, choose "No, refine with Ultraplan" |

**Status indicators while cloud session works:**

| Indicator | Meaning |
|:----------|:--------|
| `◇ ultraplan` | Drafting in progress |
| `◇ ultraplan needs your input` | Clarifying question — open session link |
| `◆ ultraplan ready` | Plan ready for browser review |

**Execution choices (from browser):**

| Option | Result |
|:-------|:-------|
| Approve and start coding (web) | Cloud session implements; review diff and open PR from browser |
| Approve and teleport to terminal | Web session archived; terminal shows plan with Implement / Start new session / Cancel |

---

### Ultrareview (Cloud Code Review — Research Preview)

Requires Claude Code v2.1.86+. Requires Claude.ai authentication. Not available on Bedrock, Vertex AI, Foundry, or with Zero Data Retention.

| Command | Scope |
|:--------|:------|
| `/code-review ultra` | Diff between current branch and default branch (including uncommitted changes) |
| `/code-review ultra 1234` | GitHub PR number (clones from host; works with GitHub Enterprise) |
| `claude ultrareview` | Non-interactive / CI; blocks until done, prints findings to stdout |
| `claude ultrareview 1234` | PR review in CI |
| `claude ultrareview origin/main` | Review diff against a named base branch |

**`claude ultrareview` flags:**

| Flag | Description |
|:-----|:------------|
| `--json` | Print raw `bugs.json` payload |
| `--timeout <minutes>` | Max wait time (default 30) |

**Exit codes:** 0 = success (with or without findings); 1 = launch failure, remote error, or timeout; 130 = Ctrl-C.

**`/review` vs `/code-review ultra`:**

| | `/review` | `/code-review ultra` |
|:-|:---------|:--------------------|
| Runs | Locally | Remote cloud sandbox |
| Depth | Single-pass | Multi-agent fleet + independent verification |
| Duration | Seconds–minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs (3 for Pro/Max), then ~$5–$20 per review |

**Pricing:** Pro and Max get 3 one-time free runs; Team and Enterprise start billing immediately. Runs count against usage credits once free runs are exhausted. Enable usage credits at `/usage-credits` or billing settings.

---

### Dynamic Workflows (Research Preview)

Requires Claude Code v2.1.154+. Available on all paid plans and all providers.

A workflow is a JavaScript script Claude writes that orchestrates many subagents. The runtime executes it in the background; intermediate results stay in script variables, not Claude's context.

**When to use workflows vs. other coordination:**

| | Subagents | Skills | Agent teams | Workflows |
|:-|:---------|:-------|:------------|:---------|
| Orchestrator | Claude, turn by turn | Claude, prompt | Lead agent | The script |
| Intermediate results | Context window | Context window | Shared task list | Script variables |
| Repeatable unit | Worker definition | Instructions | Team definition | Orchestration itself |
| Scale | Few per turn | Same | Handful of peers | Dozens–hundreds per run |
| Interruption | Restarts turn | Restarts turn | Peers keep running | Resumable in same session |

**Triggering a workflow:**

| Method | How |
|:-------|:----|
| Bundled workflow | `/deep-research <question>` |
| Ask for one | Include `ultracode` keyword in prompt, or say "use a workflow" |
| Session-wide | `/effort ultracode` (plans a workflow for every substantive task) |

**`/workflows` progress view key bindings:**

| Key | Action |
|:----|:-------|
| `↑` / `↓` | Select phase or agent |
| `Enter` / `→` | Drill into phase or agent |
| `Esc` | Back out one level |
| `j` / `k` | Scroll within agent detail |
| `p` | Pause / resume |
| `x` | Stop selected agent or whole workflow |
| `r` | Restart selected agent |
| `s` | Save run's script as a command |

**Save a workflow:** press `s` in `/workflows` — saves to `.claude/workflows/` (project, shared) or `~/.claude/workflows/` (personal). Runs as `/<name>` in future sessions.

**Runtime limits:**

| Constraint | Value |
|:-----------|:------|
| Concurrent agents | Up to 16 (fewer on low-CPU machines) |
| Total agents per run | 1,000 |
| Mid-run user input | Not supported (only permission prompts can pause) |
| Resume | Within same session only |

**Disable workflows:** toggle in `/config`, set `"disableWorkflows": true` in settings, or set `CLAUDE_CODE_DISABLE_WORKFLOWS=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, verification strategies, CLAUDE.md guidelines, parallelism, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — prompt recipes for exploring code, fixing bugs, refactoring, testing, PRs, documentation; sessions, worktrees, piping Claude into scripts
- [Set up Claude Code in a monorepo or large codebase](references/claude-code-large-codebases.md) — per-directory CLAUDE.md, claudeMdExcludes, Read deny rules, code intelligence plugins, sparse worktrees, additionalDirectories, per-directory skills
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launch, status indicators, inline comments, browser review, execute on web or teleport to terminal
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — `/code-review ultra`, PR mode, pricing, non-interactive CI usage, comparison with `/review`
- [Orchestrate subagents at scale with dynamic workflows](references/claude-code-workflows.md) — bundled workflows, writing custom workflows, ultracode keyword, `/workflows` UI, saving/reusing, runtime limits, cost management

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Set up Claude Code in a monorepo or large codebase: https://code.claude.com/docs/en/large-codebases.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Orchestrate subagents at scale with dynamic workflows: https://code.claude.com/docs/en/workflows.md
