---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context management, prompting strategies, verification patterns, Plan Mode, environment configuration (CLAUDE.md, permissions, hooks, skills, subagents, plugins, MCP), session management (/clear, /compact, /rewind, /resume, checkpoints), parallel sessions, git worktrees, non-interactive mode, fan-out patterns, auto mode, extended thinking, subagent delegation, notification hooks, codebase exploration, debugging, refactoring, testing, pull requests, documentation generation, image analysis, file references, output formats, scheduled tasks, and common failure patterns. Load when discussing best practices, effective prompting, context window management, Plan Mode, CLAUDE.md tips, session management, parallel sessions, worktrees, non-interactive mode, fan-out, auto mode, extended thinking, common workflows, debugging workflows, refactoring, test generation, PR creation, documentation, image support, file references, output formats, scheduled tasks, Unix-style usage, or any topic about getting the most out of Claude Code.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common workflows.

## Quick Reference

### Core Principle

Context window management is the single most important factor. Performance degrades as context fills. Track usage with a custom status line and use `/clear` between unrelated tasks.

### Highest-Leverage Practices

| Practice | Why it matters |
|:---------|:--------------|
| **Provide verification criteria** | Tests, screenshots, or expected outputs let Claude self-check. Single highest-leverage improvement. |
| **Explore, plan, then code** | Use Plan Mode (`Shift+Tab`) to separate research from implementation. Skip for small/obvious changes. |
| **Give specific context** | Reference files with `@`, paste images, give URLs, pipe data. Reduces corrections. |
| **Use `/clear` aggressively** | Reset context between unrelated tasks. Stale context degrades quality. |
| **Delegate to subagents** | Research in separate context windows keeps your main session clean. |

### Prompting Strategies

| Strategy | Weak prompt | Strong prompt |
|:---------|:-----------|:-------------|
| Verification | "implement email validation" | "write validateEmail, test with user@example.com (true), invalid (false), user@.com (false). run tests after" |
| Visual verification | "make the dashboard look better" | "[paste screenshot] implement this design. screenshot result, compare, list differences, fix them" |
| Root cause | "the build is failing" | "build fails with [error]. fix it, verify build succeeds. address root cause, don't suppress" |
| Scoped task | "add tests for foo.py" | "write a test for foo.py covering edge case where user is logged out. avoid mocks" |
| Pattern reference | "add a calendar widget" | "look at HotDogWidget.php for patterns. follow pattern for new calendar widget with month select and pagination" |

### Plan Mode

| Action | How |
|:-------|:----|
| Toggle during session | `Shift+Tab` (cycles Normal -> Auto-Accept -> Plan) |
| Start session in Plan Mode | `claude --permission-mode plan` |
| Headless Plan Mode | `claude --permission-mode plan -p "analyze..."` |
| Edit plan in editor | `Ctrl+G` |
| Set as default | `"permissions": { "defaultMode": "plan" }` in `.claude/settings.json` |

### Environment Configuration Checklist

| Setup step | Command / Location | Purpose |
|:-----------|:-------------------|:--------|
| CLAUDE.md | `/init` then refine | Persistent project context (build cmds, code style, workflow rules) |
| Permissions | `/permissions`, `/sandbox`, or auto mode | Reduce approval interruptions |
| CLI tools | Install `gh`, `aws`, `gcloud`, etc. | Context-efficient external service access |
| MCP servers | `claude mcp add` | Connect Notion, Figma, databases, etc. |
| Hooks | `.claude/settings.json` or `/hooks` | Deterministic actions (lint after edit, block writes) |
| Skills | `.claude/skills/<name>/SKILL.md` | Domain knowledge loaded on demand |
| Subagents | `.claude/agents/<name>.md` | Isolated specialists with own tool sets |
| Plugins | `/plugin` | Community bundles of skills, hooks, MCP |

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Anything Claude figures out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently changing information |
| Architectural decisions specific to project | Long explanations or tutorials |
| Dev environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices ("write clean code") |

CLAUDE.md file locations (all loaded automatically):
- `~/.claude/CLAUDE.md` -- all sessions
- `./CLAUDE.md` -- project root (commit to git)
- `./CLAUDE.local.md` -- personal, gitignored
- Parent directories -- monorepo support
- Child directories -- loaded on demand when working in that directory

### Session Management

| Action | Shortcut / Command |
|:-------|:-------------------|
| Stop mid-action | `Esc` |
| Rewind / restore checkpoint | `Esc + Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact with focus | `/compact Focus on the API changes` |
| Summarize from checkpoint | `Esc + Esc` -> select message -> "Summarize from here" |
| Side question (no context cost) | `/btw` |
| Resume most recent | `claude --continue` |
| Pick a session | `claude --resume` |
| Resume by name | `claude --resume auth-refactor` |
| Resume from PR | `claude --from-pr 123` |
| Name a session | `claude -n auth-refactor` or `/rename auth-refactor` |

### Session Picker Shortcuts

| Key | Action |
|:----|:-------|
| `Up/Down` | Navigate sessions |
| `Right/Left` | Expand/collapse grouped sessions |
| `Enter` | Resume selected session |
| `P` | Preview session |
| `R` | Rename session |
| `/` | Search/filter |
| `A` | Toggle current dir / all projects |
| `B` | Filter to current git branch |

### Parallel Sessions & Worktrees

| Method | Best for |
|:-------|:---------|
| Desktop app sessions | Visual multi-session management with isolated worktrees |
| Claude Code on the web | Cloud infrastructure, isolated VMs |
| Agent teams | Automated multi-session coordination with messaging |
| `claude --worktree <name>` | CLI-based isolated worktrees |
| `claude -w` (no name) | Auto-named random worktree |

Worktrees are created at `<repo>/.claude/worktrees/<name>`, branching from `origin/HEAD`. Use `.worktreeinclude` to copy gitignored files (`.env`, etc.) into new worktrees.

### Non-Interactive & Automation

| Pattern | Command |
|:--------|:--------|
| One-off query | `claude -p "Explain what this project does"` |
| JSON output | `claude -p "List endpoints" --output-format json` |
| Streaming JSON | `claude -p "Analyze log" --output-format stream-json` |
| Fan-out migration | `for file in $(cat files.txt); do claude -p "Migrate $file" --allowedTools "Edit,Bash(git commit *)"; done` |
| Auto mode (no prompts) | `claude --permission-mode auto -p "fix all lint errors"` |
| Pipe in/out | `cat error.log \| claude -p "explain root cause" > output.txt` |
| CI linter | `claude -p "look at changes vs main, report typos"` |

### Extended Thinking

| Control | How |
|:--------|:----|
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep thinking | Include "ultrathink" in prompt (Opus 4.6 / Sonnet 4.6) |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` -> toggle thinking mode |
| Limit budget | `MAX_THINKING_TOKENS` env var |
| View thinking | `Ctrl+O` for verbose mode |

### Scheduled Tasks

| Option | Where it runs | Best for |
|:-------|:-------------|:---------|
| Cloud scheduled tasks | Anthropic infrastructure | Tasks that run when computer is off |
| Desktop scheduled tasks | Local machine via desktop app | Tasks needing local file access |
| GitHub Actions | CI pipeline | Repo-event-driven tasks |
| `/loop` | Current CLI session | Quick polling while session is open |

### Common Workflows

| Workflow | Key steps |
|:---------|:----------|
| **Codebase exploration** | Start broad ("give me an overview"), narrow down, ask about patterns/architecture |
| **Bug fixing** | Share error, ask for fix recommendations, apply and verify |
| **Refactoring** | Find deprecated patterns, get recommendations, apply incrementally, run tests |
| **Test generation** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **PR creation** | Summarize changes, `create a pr`, refine description |
| **Documentation** | Find undocumented code, generate docs, review, verify standards |
| **Image analysis** | Drag/drop, paste (`Ctrl+V`), or give path; ask Claude to analyze |
| **File references** | Use `@path/to/file` to include content, `@dir/` for listings |

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen sink session (mixed unrelated tasks) | `/clear` between unrelated tasks |
| Repeated corrections (3+ attempts) | `/clear`, write better initial prompt with lessons learned |
| Over-specified CLAUDE.md (rules ignored) | Prune ruthlessly; convert obvious rules to hooks |
| Trust-then-verify gap (no validation) | Always provide tests, scripts, or screenshots |
| Infinite exploration (reads hundreds of files) | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) -- Context management, verification, planning, prompting, environment setup, session management, scaling, and failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) -- Step-by-step guides for codebase exploration, debugging, refactoring, testing, PRs, documentation, images, Plan Mode, worktrees, sessions, thinking mode, and scheduled tasks

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
