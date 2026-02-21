---
name: best-practices
description: Best practices and common workflows for Claude Code — prompting strategies, context management, CLAUDE.md authoring, Plan Mode, session management, verification patterns, headless mode, parallel sessions, fan-out scripting, debugging, refactoring, testing, PR creation, and git worktrees.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for getting the most out of Claude Code, including prompting patterns, environment configuration, session management, and step-by-step workflow recipes.

## Quick Reference

### Core Principle

Claude's context window is the most important resource to manage. Performance degrades as it fills. Use `/clear` between unrelated tasks and track usage with a custom status line.

### Prompting Strategies

| Strategy | Bad | Good |
|:---------|:----|:-----|
| Provide verification criteria | "implement email validation" | "write validateEmail, test with these cases, run tests after" |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case, avoid mocks" |
| Reference existing patterns | "add a calendar widget" | "look at HotDogWidget.php, follow that pattern to build a calendar widget" |
| Describe the symptom | "fix the login bug" | "login fails after session timeout, check src/auth/ token refresh, write a failing test then fix" |
| Use Plan Mode first | "implement OAuth" | "Enter Plan Mode, explore auth system, create plan, then switch to Normal Mode to implement" |

### Recommended Workflow Phases

1. **Explore** (Plan Mode) -- read files, understand the codebase
2. **Plan** (Plan Mode) -- create a detailed implementation plan; press Ctrl+G to edit in your editor
3. **Implement** (Normal Mode) -- code against the plan, run tests
4. **Commit** (Normal Mode) -- commit with a descriptive message, open a PR

Skip planning when the change is small enough to describe in one sentence.

### Providing Context

| Method | When to use |
|:-------|:------------|
| `@file` reference | Include specific files in your prompt |
| Paste images | UI mockups, error screenshots, diagrams |
| Give URLs | Documentation and API references |
| Pipe data in | Pipe file contents into claude via stdin |
| Let Claude fetch | Tell Claude to pull context via Bash, MCP, or reading files |

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Anything Claude can infer from code |
| Code style rules differing from defaults | Standard language conventions |
| Test instructions and runners | Detailed API docs (link instead) |
| Branch naming, PR conventions | Frequently changing information |
| Architectural decisions | Long tutorials |
| Dev environment quirks (env vars) | File-by-file codebase descriptions |

Use `/init` to generate a starter CLAUDE.md. Keep it concise: if removing a line would not cause mistakes, cut it.

### Session Management

| Action | How |
|:-------|:----|
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc + Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact context | `/compact <instructions>` |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` |
| Name a session | `/rename <name>` |

### Plan Mode

| Method | Command |
|:-------|:--------|
| Toggle during session | Shift+Tab (cycle through modes) |
| Start in Plan Mode | `claude --permission-mode plan` |
| Headless Plan Mode | `claude --permission-mode plan -p "prompt"` |
| Set as default | `"permissions": { "defaultMode": "plan" }` in settings |

### Headless Mode and Automation

| Pattern | Command |
|:--------|:--------|
| One-off query | `claude -p "prompt"` |
| JSON output | `claude -p "prompt" --output-format json` |
| Streaming JSON | `claude -p "prompt" --output-format stream-json` |
| Fan-out over files | Loop with `claude -p` and `--allowedTools` per file |
| Skip permissions | `claude --dangerously-skip-permissions` (sandboxed, offline containers only) |

### Parallel Sessions

| Method | Description |
|:-------|:------------|
| Desktop app | Manage multiple local sessions visually with isolated worktrees |
| Claude Code on the web | Run on Anthropic cloud infrastructure in isolated VMs |
| Agent teams | Automated coordination with shared tasks and messaging |
| Writer/Reviewer pattern | Session A implements, Session B reviews with fresh context |

### Git Worktrees

Start Claude in an isolated worktree: `claude --worktree feature-name` or `claude -w feature-name`. Worktrees are created at `<repo>/.claude/worktrees/<name>`. On exit, unchanged worktrees are auto-removed; changed ones prompt to keep or remove.

### Common Workflow Recipes

| Workflow | Key steps |
|:---------|:----------|
| **Explore codebase** | Ask for overview, then narrow into architecture, data models, auth |
| **Fix bugs** | Share the error, ask for fix suggestions, apply and verify |
| **Refactor** | Find deprecated usage, get recommendations, apply safely, run tests |
| **Write tests** | Find untested code, generate scaffolding, add edge cases, run tests |
| **Create PRs** | Summarize changes, "create a pr" or `/commit-push-pr` |
| **Documentation** | Find undocumented code, generate docs, review, verify standards |
| **Work with images** | Drag/drop or paste images, ask for analysis, get code from mockups |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (mixed unrelated tasks) | `/clear` between tasks |
| Correcting over and over | After two failures, `/clear` and rewrite the prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks where possible |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope investigations narrowly or use subagents |

### Extended Thinking

Enabled by default. Toggle with Option+T (macOS) or Alt+T. On Opus 4.6, uses adaptive reasoning controlled by effort level (low/medium/high). On other models, fixed budget up to 31,999 tokens, limited via MAX_THINKING_TOKENS. Set to 0 to disable on any model.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) — prompting strategies, verification patterns, CLAUDE.md authoring, environment configuration (permissions, CLI tools, MCP, hooks, skills, subagents, plugins), session management, context management, parallel sessions, headless mode, fan-out patterns, and common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step recipes for codebase exploration, bug fixing, refactoring, subagent usage, Plan Mode, testing, PR creation, documentation, images, file references, extended thinking, session resumption, git worktrees, notifications, and headless/pipe usage

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
