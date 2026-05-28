---
name: best-practices-doc
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, large codebase configuration, ultraplan, and ultrareview.

## Quick Reference

### Core Constraint: Context Window

LLM performance degrades as the context window fills. Every file read, command output, and message consumes it. Managing context is the single most important resource discipline.

| Signal | Action |
|:-------|:-------|
| Claude repeating mistakes after corrections | `/clear` and rewrite prompt with lessons learned |
| Unrelated tasks mixed in one session | `/clear` between tasks |
| Exploring a large codebase | Use subagents so file reads stay out of main context |
| Context growing during investigation | Scope the investigation narrowly before starting |

### Highest-Leverage Practices

| Practice | Why it matters |
|:---------|:--------------|
| Give Claude a way to verify its work (tests, screenshots, scripts) | Without self-verification, Claude produces plausible-but-broken output |
| Explore in plan mode first, then implement | Prevents solving the wrong problem; separates research from execution |
| Provide specific context: file names, constraints, example patterns | Reduces correction cycles significantly |
| Use `@file` references, paste images, pipe data directly | Rich context produces better output |
| Keep CLAUDE.md short and actionable | Bloated CLAUDE.md causes Claude to ignore rules |

### Explore → Plan → Implement → Commit Workflow

1. **Enter plan mode** (`Shift+Tab` or `claude --permission-mode plan`). Claude reads files, no edits.
2. **Ask Claude to plan** the change in detail.
3. **Press `Ctrl+G`** to open the plan in your editor and refine it directly.
4. **Switch out of plan mode** and implement, verifying against the plan.
5. **Commit** with a descriptive message and open a PR.

Skip planning for one-sentence changes. Use it when scope is unclear, multiple files are involved, or the codebase is unfamiliar.

### Session Management Commands

| Command / Key | Effect |
|:--------------|:-------|
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc Esc` or `/rewind` | Open rewind menu: restore conversation, code, or both to a checkpoint |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact with custom focus |
| `/btw` | Side question; answer appears as overlay, never enters context |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Pick from session list |
| `/rename` | Name the current session |

### Prompt Patterns

| Strategy | Weak | Strong |
|:---------|:-----|:-------|
| Verification | *"implement email validator"* | *"write validateEmail; test cases: user@example.com→true, invalid→false; run tests after"* |
| Bug fix | *"fix the login bug"* | *"login fails after session timeout; check src/auth/ token refresh; write failing test then fix"* |
| Refactor | *"add a calendar widget"* | *"look at HotDogWidget.php for patterns; implement calendar widget for month/year selection; no new libraries"* |
| Investigation | *"fix the build"* | *"build fails with [error]. fix it and verify the build succeeds; address root cause, not symptoms"* |

### CLAUDE.md Guidelines

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude infers from reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Common gotchas, non-obvious behaviors | Self-evident practices like "write clean code" |
| Developer environment quirks, required env vars | File-by-file codebase descriptions |

CLAUDE.md supports `@path/to/file` imports. Place at `~/.claude/CLAUDE.md` (all projects), `./CLAUDE.md` (shared project), `./CLAUDE.local.md` (personal project, gitignored), or in parent/child directories (loaded hierarchically).

### Automation and Scaling

| Technique | When to use |
|:----------|:------------|
| `claude -p "prompt"` | Non-interactive: CI, pre-commit hooks, scripts |
| `--output-format json` / `stream-json` | Parse results programmatically |
| `--worktree <name>` | Parallel sessions in isolated git checkouts |
| `--permission-mode auto` | Unattended execution with classifier safety checks |
| Fan-out loop: `for file in ...; do claude -p "..." done` | Large migrations across many files |
| Writer/Reviewer pattern (two sessions) | Higher quality output; fresh context avoids writer bias |
| `use subagents to investigate X` | Research without consuming main context |

### Large Codebases / Monorepos

| Goal | Setting / Approach |
|:-----|:------------------|
| Load only relevant conventions | Per-directory CLAUDE.md files (committed alongside code) |
| Exclude other teams' CLAUDE.md files | `claudeMdExcludes` in `.claude/settings.local.json` |
| Block reads of build output and vendored code | `Read` deny rules in `permissions.deny` |
| Navigate symbols without scanning files | Install a code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktrees (faster checkout) | `worktree.sparsePaths` in `.claude/settings.json` |
| Avoid duplicating node_modules across worktrees | `worktree.symlinkDirectories` |
| Access sibling package or repo | `additionalDirectories` setting or `--add-dir` flag |
| Per-area skills that load on demand | `.claude/skills/` inside each subdirectory |

Settings files load only from the starting directory — not inherited from parents. Place `.claude/settings.json` at the directory you launch Claude from.

`--add-dir` loads CLAUDE.md and skills from the added directory (with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` for CLAUDE.md). `additionalDirectories` grants file access only, no instructions or skills.

### Ultraplan

Cloud-assisted planning that frees your terminal while a remote session drafts the plan.

**Requirements:** Claude Code on the web account, GitHub repository; not available on Bedrock/Vertex/Foundry.

**Launch options:**
- `/ultraplan <prompt>` — command form
- Include `ultraplan` anywhere in a prompt — keyword form
- From a local plan approval dialog — choose "Refine with Ultraplan"

**Status indicators:**

| Status | Meaning |
|:-------|:--------|
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Clarifying question pending in browser |
| `◆ ultraplan ready` | Plan ready to review |

**Review in browser:** inline comments on sections, emoji reactions, outline sidebar, iterative revisions.

**Execution choices:**
- **Approve and start coding** — implement in same cloud session; create PR from web interface
- **Approve and teleport back to terminal** — implement locally with full environment access
- **Cancel** — save plan to file without executing

### Ultrareview

Deep multi-agent code review running on cloud infrastructure. Every finding is independently reproduced and verified.

**Requirements:** Claude.ai account (not API key only); not available on Bedrock/Vertex/Foundry/ZDR.

**Commands:**

| Command | What it reviews |
|:--------|:----------------|
| `/code-review ultra` | Diff between current branch and default branch (including uncommitted changes) |
| `/code-review ultra 1234` | GitHub PR number |
| `claude ultrareview` | Non-interactive (CI/scripts); blocks until done, prints findings to stdout |
| `claude ultrareview 1234` | PR mode non-interactive |
| `claude ultrareview origin/main` | Compare against specific base branch |

**Non-interactive flags:**

| Flag | Description |
|:-----|:------------|
| `--json` | Print raw `bugs.json` payload |
| `--timeout <minutes>` | Max wait time (default: 30) |

**Pricing:**

| Plan | Free runs | After free runs |
|:-----|:----------|:----------------|
| Pro / Max | 3 (one-time, non-refreshing) | ~$5–$20 per review as usage credits |
| Team / Enterprise | None | ~$5–$20 per review as usage credits |

Usage credits must be enabled to launch paid reviews. Check/change with `/usage-credits`.

**vs. `/review`:**

| | `/review` | `/code-review ultra` |
|:-|:----------|:--------------------|
| Runs | Locally in session | Remote cloud sandbox |
| Depth | Single-pass | Multi-agent with independent verification |
| Duration | Seconds to minutes | ~5–10 minutes |
| Best for | Fast feedback while iterating | Pre-merge confidence on substantial changes |

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen-sink session (mixed unrelated tasks) | `/clear` between tasks |
| Correcting the same issue more than twice | `/clear` and write a better initial prompt |
| Bloated CLAUDE.md (rules get lost) | Ruthlessly prune; convert to hooks if needed |
| Trust-then-verify gap (no success criteria) | Always provide tests, scripts, or screenshots |
| Infinite exploration (hundreds of file reads) | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — Context management, verification, planning workflow, CLAUDE.md authoring, session management, automation patterns, and failure anti-patterns
- [Common Workflows](references/claude-code-common-workflows.md) — Step-by-step recipes for codebase exploration, bug fixing, refactoring, tests, PRs, documentation, images, scheduling, and scripting
- [Large Codebases and Monorepos](references/claude-code-large-codebases.md) — Per-directory CLAUDE.md layering, claudeMdExcludes, deny rules, code intelligence plugins, sparse worktrees, additionalDirectories, per-directory skills, and centralized conventions
- [Ultraplan](references/claude-code-ultraplan.md) — Cloud-assisted planning with browser-based review and flexible execution targets
- [Ultrareview](references/claude-code-ultrareview.md) — Multi-agent cloud code review with verified findings, pricing, and non-interactive CI usage

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Large Codebases and Monorepos: https://code.claude.com/docs/en/large-codebases.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
