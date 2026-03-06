---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context management, prompt specificity, verification-driven development, Plan Mode, CLAUDE.md configuration, permissions, subagents, session management (/clear, /rewind, /compact, --continue, --resume), parallel sessions, worktrees, non-interactive mode (claude -p), fan-out patterns, thinking mode, and step-by-step workflow recipes for codebase exploration, debugging, refactoring, testing, PRs, documentation, images, file references, and piping. Load when discussing how to use Claude Code effectively, prompt techniques, session workflows, scaling with parallel sessions, or common development tasks.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common development workflows.

## Quick Reference

Claude Code is an agentic coding environment. The most important resource to manage is the context window -- performance degrades as it fills. Most best practices stem from this constraint.

### Core Principles

| Principle | Key takeaway |
|:----------|:-------------|
| **Verify work** | Provide tests, screenshots, or expected outputs so Claude can check itself -- highest-leverage practice |
| **Explore, plan, code** | Use Plan Mode (Shift+Tab) to separate research from implementation |
| **Be specific** | Reference files, mention constraints, point to example patterns |
| **Manage context** | Use `/clear` between tasks; use subagents for research to keep main context clean |
| **Course-correct early** | Interrupt with Esc, undo with `/rewind`, start fresh after two failed corrections |

### Prompt Strategies

| Strategy | Before | After |
|:---------|:-------|:------|
| Provide verification | "implement validateEmail" | "write validateEmail with test cases, run them after" |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering logged-out edge case, avoid mocks" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php, follow the pattern for a new calendar widget" |
| Describe symptoms | "fix the login bug" | "login fails after session timeout, check src/auth/ token refresh, write a failing test then fix" |

### Providing Rich Context

| Method | Usage |
|:-------|:------|
| `@file` references | `@src/utils/auth.js` -- includes file content in conversation |
| Paste images | Copy/paste or drag-and-drop into the prompt |
| Give URLs | Use `/permissions` to allowlist domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to pull context via Bash, MCP, or file reads |

### Environment Setup Checklist

| Setup | Purpose | How |
|:------|:--------|:----|
| CLAUDE.md | Persistent project context (code style, commands, workflow rules) | `/init` to generate, then refine |
| Permissions | Reduce approval interruptions | `/permissions` to allowlist; `/sandbox` for OS isolation |
| CLI tools | Context-efficient external service access | Install `gh`, `aws`, `gcloud`, etc. |
| MCP servers | Connect Notion, Figma, databases | `claude mcp add` |
| Hooks | Deterministic automation (format, block, notify) | `/hooks` or `.claude/settings.json` |
| Skills | Domain knowledge and reusable workflows | `.claude/skills/<name>/SKILL.md` |
| Subagents | Isolated tasks with separate context | `.claude/agents/<name>.md` |
| Plugins | Bundled extensions from marketplace | `/plugin` to browse/install |

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Things Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Test instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently changing information |
| Architectural decisions | Long tutorials |
| Developer environment quirks | File-by-file codebase descriptions |

CLAUDE.md locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project root), parent directories (monorepo), child directories (loaded on demand). Use `@path/to/import` syntax to import additional files.

### Session Management

| Action | Command |
|:-------|:--------|
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc+Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact context | `/compact [instructions]` |
| Partial compact | `/rewind` then "Summarize from here" |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` |
| Resume from PR | `claude --from-pr 123` |
| Rename session | `/rename auth-refactor` |

### Session Picker Shortcuts

| Key | Action |
|:----|:-------|
| Up/Down | Navigate sessions |
| Right/Left | Expand/collapse grouped sessions |
| Enter | Resume selected session |
| P | Preview session |
| R | Rename session |
| / | Search/filter |
| A | Toggle current directory vs. all projects |
| B | Filter to current git branch |

### Plan Mode

Activate with Shift+Tab (cycle Normal -> Auto-Accept -> Plan) or `claude --permission-mode plan`. Plan Mode uses read-only operations and `AskUserQuestion` to gather requirements. Press Ctrl+G to open the plan in your editor for direct editing.

Best for: multi-step implementations, code exploration, interactive development. Skip for: small, obvious changes.

### Extended Thinking

Enabled by default. Opus 4.6 uses adaptive reasoning controlled by effort level (low/medium/high). Other models use a fixed budget (up to 31,999 tokens).

| Control | How |
|:--------|:----|
| Effort level | `/model` or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| `ultrathink` keyword | Include in prompt for one-off high effort (Opus 4.6 / Sonnet 4.6) |
| Toggle on/off | Option+T (macOS) / Alt+T |
| Global default | `/config` |
| Limit budget | `MAX_THINKING_TOKENS` env var (ignored on Opus 4.6 unless set to 0) |
| Disable adaptive | `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` |

### Parallel Sessions & Worktrees

| Method | Use case |
|:-------|:---------|
| Claude Code desktop app | Multiple local sessions with isolated worktrees |
| Claude Code on the web | Remote VMs on Anthropic infrastructure |
| Agent teams | Automated multi-session coordination |
| `claude --worktree name` | Git worktree at `.claude/worktrees/<name>/` |
| `claude --worktree` (no name) | Auto-generated random name |

Worktree cleanup: no changes = auto-removed; changes exist = prompted to keep or remove. Add `.claude/worktrees/` to `.gitignore`. Subagents can use `isolation: worktree` in frontmatter.

### Non-Interactive & Automation

| Pattern | Command |
|:--------|:--------|
| One-off query | `claude -p "prompt"` |
| Structured output | `claude -p "prompt" --output-format json` |
| Streaming | `claude -p "prompt" --output-format stream-json` |
| Fan-out migration | `for file in $(cat files.txt); do claude -p "Migrate $file" --allowedTools "Edit,Bash(git commit *)"; done` |
| CI linting | `claude -p "look at changes vs main, report typos"` in package.json scripts |
| Pipe in/out | `cat build-error.txt \| claude -p "explain root cause" > output.txt` |
| Skip permissions | `claude --dangerously-skip-permissions` (use only in sandboxed containers) |

### Common Workflow Recipes

| Workflow | Key steps |
|:---------|:----------|
| **Codebase overview** | "give me an overview" then narrow down to architecture, data models, auth |
| **Find relevant code** | "find files that handle X" then "how do they work together?" then "trace the flow" |
| **Fix bugs** | Share error, ask for fix suggestions, apply fix |
| **Refactor** | Find deprecated usage, get recommendations, apply changes, run tests |
| **Write tests** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **Create PRs** | Summarize changes, "create a pr", enhance description |
| **Documentation** | Find undocumented code, generate docs, review, verify standards |
| **Images** | Drag/drop or paste, analyze content, use for context, generate code from mockups |
| **Subagents** | `/agents` to view, use automatically or explicitly request, create custom in `.claude/agents/` |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (unrelated tasks in one session) | `/clear` between unrelated tasks |
| Repeated corrections (same mistake multiple times) | `/clear` after two failures, write a better prompt |
| Over-specified CLAUDE.md (too long, rules get lost) | Prune ruthlessly; convert to hooks for hard requirements |
| Trust-then-verify gap (no edge case coverage) | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration (unbounded investigation) | Scope narrowly or use subagents |

### Notifications Hook

Use the `Notification` hook event to get desktop alerts when Claude finishes or needs input:

| OS | Command |
|:---|:--------|
| macOS | `osascript -e 'display notification "Claude Code needs your attention" with title "Claude Code"'` |
| Linux | `notify-send 'Claude Code' 'Claude Code needs your attention'` |
| Windows | PowerShell with `System.Windows.Forms.MessageBox` |

Matchers: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`. Configure via `/hooks` > Notification.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices](references/claude-code-best-practices.md) -- context management, verification-driven development, Plan Mode workflow, prompt specificity, CLAUDE.md configuration, permissions, CLI tools, MCP, hooks, skills, subagents, plugins, session management, course-correction, context compaction, checkpoints, parallel sessions, non-interactive mode, fan-out patterns, autonomous mode, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) -- step-by-step recipes for codebase exploration, finding code, debugging, refactoring, subagents, Plan Mode, testing, PRs, documentation, images, file references, extended thinking, session resumption, worktrees, notifications, unix-style piping, output formats, CI integration

## Sources

- Best practices: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
