---
name: best-practices
description: Reference documentation for Claude Code best practices and common workflows — context management, prompting strategies, environment configuration, session management, parallel execution, headless mode, Plan Mode, and common failure patterns. Use when optimizing Claude Code usage, writing effective prompts, managing context windows, configuring CLAUDE.md, running parallel sessions, or automating workflows.
user-invocable: false
---

# Best Practices & Common Workflows

This skill provides the complete official documentation for getting the most out of Claude Code.

## Quick Reference

The single most important constraint: **Claude's context window fills up fast, and performance degrades as it fills.** Most best practices follow from managing this.

### Core Principles

| Principle | What to do |
|:----------|:-----------|
| **Verify work** | Provide tests, screenshots, or expected outputs so Claude can check itself |
| **Explore, plan, then code** | Use Plan Mode to separate research from implementation |
| **Be specific** | Reference files, mention constraints, point to example patterns |
| **Manage context** | Use `/clear` between tasks, `/compact` to summarize, subagents to investigate |
| **Course-correct early** | Press `Esc` to stop, `Esc+Esc` or `/rewind` to restore, `/clear` to reset |

### Prompting Strategies

| Strategy | Weak prompt | Strong prompt |
|:---------|:------------|:--------------|
| Provide verification | "implement email validation" | "write validateEmail, run these test cases: user@example.com=true, invalid=false" |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering logged-out edge case, avoid mocks" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php, follow the pattern to implement a calendar widget" |
| Describe symptoms | "fix the login bug" | "login fails after session timeout, check src/auth/ token refresh, write a failing test" |

### Providing Rich Content

| Method | Example |
|:-------|:--------|
| `@` file references | `Explain the logic in @src/utils/auth.js` |
| Paste images | Copy/paste or drag-drop images into the prompt |
| Give URLs | Use `/permissions` to allowlist frequently-used domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to pull context via Bash, MCP, or file reads |

### Plan Mode (Explore-Plan-Implement-Commit)

1. **Explore** (Plan Mode): Read files, ask questions — no changes made
2. **Plan** (Plan Mode): Create a detailed implementation plan; `Ctrl+G` to edit in your editor
3. **Implement** (Normal Mode): Code against the plan, run tests, fix failures
4. **Commit** (Normal Mode): Commit with a descriptive message, open a PR

Toggle Plan Mode with `Shift+Tab`. Start a session in Plan Mode: `claude --permission-mode plan`.

Skip planning when the task is small (typo fix, rename, single-line change).

### Environment Configuration Checklist

| Setup | How |
|:------|:----|
| **CLAUDE.md** | Run `/init` to generate, then prune to essentials. Check into git. |
| **Permissions** | Use `/permissions` to allowlist safe commands, or `/sandbox` for OS isolation |
| **CLI tools** | Install `gh`, `aws`, `gcloud`, etc. — most context-efficient external integration |
| **MCP servers** | `claude mcp add` for Notion, Figma, databases, etc. |
| **Hooks** | Deterministic actions (lint after edit, block writes to migrations) |
| **Skills** | Domain knowledge in `.claude/skills/` — loaded on demand, not every session |
| **Subagents** | Specialized assistants in `.claude/agents/` with scoped tools |
| **Plugins** | Run `/plugin` to browse marketplace for packaged extensions |

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Things Claude can infer from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and runners | Detailed API docs (link instead) |
| Branch naming, PR conventions | Frequently changing information |
| Architectural decisions, gotchas | File-by-file descriptions |

Place CLAUDE.md at: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project), parent dirs (monorepo), child dirs (on demand). Use `@path/to/import` to include other files.

### Session Management

| Action | Command |
|:-------|:--------|
| Resume most recent | `claude --continue` |
| Pick from recent sessions | `claude --resume` |
| Resume by name | `claude --resume auth-refactor` |
| Resume from PR | `claude --from-pr 123` |
| Name current session | `/rename oauth-migration` |
| Clear context | `/clear` |
| Compact with focus | `/compact Focus on the API changes` |
| Partial rewind + summarize | `Esc+Esc` or `/rewind`, select checkpoint, "Summarize from here" |
| Undo changes | "Undo that" or `/rewind` to restore code |

### Parallel Execution

| Method | Use case |
|:-------|:---------|
| Claude Code desktop app | Multiple local sessions with isolated worktrees |
| Claude Code on the web | Cloud VMs with isolated environments |
| Agent teams | Automated coordination with shared tasks and messaging |
| Git worktrees | `git worktree add ../feature-a -b feature-a`, run `claude` in each |
| Fan-out with `claude -p` | `for file in $(cat files.txt); do claude -p "Migrate $file" --allowedTools "Edit"; done` |
| Writer/Reviewer pattern | Session A implements, Session B reviews with fresh context |

### Headless Mode

```bash
claude -p "Explain this project"                          # plain text output
claude -p "List API endpoints" --output-format json       # structured JSON
claude -p "Analyze log" --output-format stream-json       # streaming JSON
cat build-error.txt | claude -p 'explain root cause'      # pipe in data
```

Use `--allowedTools` to restrict permissions for unattended runs. Use `--dangerously-skip-permissions` only in sandboxed containers without internet.

### Extended Thinking

Enabled by default. Opus 4.6 uses adaptive reasoning controlled by effort level (low/medium/high).

| Control | Method |
|:--------|:-------|
| Toggle on/off | `Option+T` (macOS) / `Alt+T` |
| Adjust effort | `/model` or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| View thinking | `Ctrl+O` (verbose mode) |
| Limit budget | `MAX_THINKING_TOKENS` env var (ignored on Opus 4.6 except `=0`) |
| Global default | `/config` to toggle |

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| **Kitchen sink session** — mixing unrelated tasks | `/clear` between unrelated tasks |
| **Correcting over and over** — context polluted with failed attempts | After 2 failed corrections, `/clear` and rewrite prompt |
| **Over-specified CLAUDE.md** — too long, rules get lost | Prune ruthlessly; convert to hooks if deterministic |
| **Trust-then-verify gap** — no way to validate output | Always provide tests, scripts, or screenshots |
| **Infinite exploration** — unscoped investigation fills context | Scope narrowly or use subagents for research |

### Common Workflows at a Glance

| Workflow | Key approach |
|:---------|:-------------|
| **Understand a codebase** | Start broad ("overview"), narrow down ("how is auth handled?") |
| **Fix bugs** | Share the error + repro steps, ask for root cause, write a failing test |
| **Refactor** | Identify legacy code, get recommendations, apply in small increments, run tests |
| **Write tests** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **Create PRs** | "create a pr" or `/commit-push-pr`; linked sessions resume with `--from-pr` |
| **Documentation** | Find undocumented code, generate docs, verify against project standards |
| **Images** | Drag-drop/paste/path screenshots, mockups, diagrams for visual context |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) — context management, prompting strategies, environment setup, session management, parallel execution, and common pitfalls
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step guides for codebase exploration, debugging, refactoring, testing, PRs, Plan Mode, images, extended thinking, and session resumption

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
