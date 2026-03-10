---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context window management, verification strategies (tests, screenshots, expected outputs), explore-plan-implement workflow, Plan Mode, prompt engineering (scoping tasks, referencing files with @, providing rich content), CLAUDE.md writing guidelines (what to include/exclude, imports, locations), permission configuration (/permissions, /sandbox, --dangerously-skip-permissions), CLI tool integration (gh, aws, gcloud), MCP server setup, hooks for deterministic automation, skills and subagents, plugins, session management (/clear, /rewind, /compact, --continue, --resume), extended thinking (effort levels, ultrathink, adaptive reasoning), common failure patterns (kitchen sink, over-correction, over-specified CLAUDE.md), non-interactive mode (claude -p, --output-format), parallel sessions (desktop app, web, agent teams, worktrees), fan-out patterns (--allowedTools), codebase exploration, debugging workflows, refactoring, test generation, PR creation, documentation generation, image analysis, file referencing with @, piping data, and using Claude as a unix-style utility. Load when discussing how to use Claude Code effectively, prompting strategies, workflow optimization, session management, productivity tips, or common development tasks.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common development workflows.

## Quick Reference

### Core Principle: Manage Context

Claude's context window is the most important resource to manage. Performance degrades as context fills. Track usage with a custom status line, use `/clear` between unrelated tasks, and keep sessions focused.

### Verification Strategies

Provide ways for Claude to check its own work -- this is the single highest-leverage practice.

| Strategy | Example |
|:---------|:--------|
| Test cases | *"write a validateEmail function. test cases: user@example.com is true, invalid is false. run the tests after implementing"* |
| Visual comparison | *"[paste screenshot] implement this design. take a screenshot and compare it to the original"* |
| Root cause focus | *"the build fails with this error: [paste error]. fix it and verify the build succeeds"* |
| Linter / script | Run a Bash command or linter that validates output |

### Explore-Plan-Implement Workflow

| Phase | Mode | What to do |
|:------|:-----|:-----------|
| **Explore** | Plan Mode | Read files, understand the codebase |
| **Plan** | Plan Mode | Create a detailed implementation plan; press `Ctrl+G` to edit in your editor |
| **Implement** | Normal Mode | Code against the plan, run tests |
| **Commit** | Normal Mode | Commit with a descriptive message, open a PR |

Skip planning when the task is small (typo, log line, rename). Plan when scope is uncertain, multi-file, or unfamiliar.

### Prompting Patterns

| Pattern | Before | After |
|:--------|:-------|:------|
| **Scope the task** | *"add tests for foo.py"* | *"write a test for foo.py covering the edge case where the user is logged out. avoid mocks."* |
| **Point to sources** | *"why does ExecutionFactory have such a weird api?"* | *"look through ExecutionFactory's git history and summarize how its api came to be"* |
| **Reference patterns** | *"add a calendar widget"* | *"look at how existing widgets are implemented. HotDogWidget.php is a good example. follow the pattern"* |
| **Describe the symptom** | *"fix the login bug"* | *"users report login fails after session timeout. check src/auth/, especially token refresh. write a failing test, then fix it"* |

### Rich Content Methods

- **`@` file references** -- include file contents directly
- **Paste images** -- drag/drop or copy/paste into the prompt
- **Give URLs** -- use `/permissions` to allowlist domains
- **Pipe data** -- `cat error.log | claude`
- **Let Claude fetch** -- tell Claude to pull context via Bash, MCP, or file reads

### CLAUDE.md Guidelines

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Things Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Test instructions and runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently changing information |
| Architectural decisions | Long explanations or tutorials |
| Environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas | Self-evident practices |

CLAUDE.md locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project root), parent/child directories. Supports `@path/to/import` syntax for imports.

### Environment Configuration

| Feature | Purpose | Setup |
|:--------|:--------|:------|
| CLAUDE.md | Persistent context per session | `/init` to generate, refine over time |
| Permissions | Reduce approval interruptions | `/permissions` to allowlist, `/sandbox` for OS isolation |
| CLI tools | Context-efficient external service access | Install `gh`, `aws`, `gcloud`, `sentry-cli`, etc. |
| MCP servers | Connect external tools (Notion, Figma, DBs) | `claude mcp add` |
| Hooks | Deterministic automation (format, block, notify) | `/hooks` or `.claude/settings.json` |
| Skills | Domain knowledge and reusable workflows | Add `SKILL.md` in `.claude/skills/` |
| Subagents | Isolated tasks in separate context | Define in `.claude/agents/` |
| Plugins | Bundled skills, hooks, agents, MCP | `/plugin` to browse marketplace |

### Session Management

| Action | Command / Key |
|:-------|:-------------|
| Stop mid-action | `Esc` |
| Rewind (restore state) | `Esc + Esc` or `/rewind` |
| Undo changes | *"Undo that"* |
| Clear context | `/clear` |
| Compact context | `/compact [instructions]` or auto-compaction |
| Partial compact | `Esc + Esc` then "Summarize from here" |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` |
| Resume from PR | `claude --from-pr <number>` |
| Name a session | `/rename <name>` |

### Extended Thinking

| Control | How |
|:--------|:----|
| Effort level | `/model` menu or `CLAUDE_CODE_EFFORT_LEVEL` env var (low/medium/high) |
| One-off deep reasoning | Include "ultrathink" in the prompt |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` to toggle |
| Limit budget | `MAX_THINKING_TOKENS` env var (set to 0 to disable) |
| View thinking | `Ctrl+O` for verbose mode |

Opus 4.6 uses adaptive reasoning (dynamic allocation by effort level). Other models use a fixed budget up to 31,999 tokens. Set `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` to revert to fixed budget.

### Non-Interactive & Automation

```bash
claude -p "prompt"                          # One-off query
claude -p "prompt" --output-format json     # Structured output
claude -p "prompt" --output-format stream-json  # Streaming
```

### Parallel Sessions

| Method | Description |
|:-------|:-----------|
| Desktop app | Multiple local sessions with isolated worktrees |
| Claude Code on the web | Cloud infrastructure in isolated VMs |
| Agent teams | Automated coordination with shared tasks and messaging |
| Git worktrees | `claude --worktree <name>` for isolated working directories |

### Fan-Out Pattern

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### Git Worktrees

```bash
claude --worktree feature-auth    # Named worktree
claude --worktree                 # Auto-generated name
claude -w bugfix-123              # Short flag
```

Worktrees are created at `<repo>/.claude/worktrees/<name>`. Cleanup is automatic when no changes exist; Claude prompts otherwise. Add `.claude/worktrees/` to `.gitignore`.

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| **Kitchen sink session** -- unrelated tasks in one session | `/clear` between tasks |
| **Repeated corrections** -- correcting the same mistake 3+ times | `/clear`, write a better initial prompt |
| **Over-specified CLAUDE.md** -- too long, rules get lost | Prune ruthlessly; convert obvious rules to hooks |
| **Trust-then-verify gap** -- no verification provided | Always include tests, scripts, or screenshots |
| **Infinite exploration** -- unbounded investigation fills context | Scope narrowly or use subagents |

### Common Workflows

| Workflow | Key Steps |
|:---------|:----------|
| **Codebase exploration** | Start broad, narrow down; ask architecture and pattern questions |
| **Bug fixing** | Share error, ask for fix recommendations, apply and verify |
| **Refactoring** | Identify legacy code, get recommendations, apply in small increments, run tests |
| **Test generation** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **PR creation** | Summarize changes, `create a pr`, review description |
| **Documentation** | Find undocumented code, generate docs, verify against standards |
| **Image analysis** | Drag/drop or paste images, ask Claude to analyze or generate code from visuals |
| **Subagent delegation** | `/agents` to view; ask Claude to use subagents for isolated tasks |

### Plan Mode

| Entry method | Command |
|:-------------|:--------|
| Toggle during session | `Shift+Tab` (cycles Normal -> Auto-Accept -> Plan) |
| Start in Plan Mode | `claude --permission-mode plan` |
| Headless Plan Mode | `claude --permission-mode plan -p "prompt"` |
| Default to Plan Mode | Set `"permissions": {"defaultMode": "plan"}` in `.claude/settings.json` |

Press `Ctrl+G` to open the plan in your text editor for direct editing.

### Session Picker Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Up/Down` | Navigate sessions |
| `Right/Left` | Expand/collapse grouped sessions |
| `Enter` | Resume selected session |
| `P` | Preview session |
| `R` | Rename session |
| `/` | Search/filter |
| `A` | Toggle current directory / all projects |
| `B` | Filter to current git branch |
| `Esc` | Exit picker |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) -- context management, verification strategies, explore-plan-implement workflow, prompting patterns, rich content, CLAUDE.md writing guidelines, permission configuration, CLI tools, MCP servers, hooks, skills, subagents, plugins, session management, course-correction, context compaction, checkpoints, resuming sessions, non-interactive mode, parallel sessions, fan-out patterns, common failure patterns, developing intuition
- [Common Workflows](references/claude-code-common-workflows.md) -- codebase exploration, bug fixing, refactoring, subagent usage, Plan Mode, test generation, PR creation, documentation, image analysis, file referencing with @, extended thinking configuration, session resumption, git worktrees, desktop notifications, unix-style piping, output format control

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
