---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows — context window management, verification strategies (tests, screenshots, expected outputs), explore-plan-implement workflow (Plan Mode, Shift+Tab, Ctrl+G), writing effective prompts (scoping tasks, referencing files, pointing to sources, describing symptoms), providing rich content (@ file references, images, URLs, piped data), configuring your environment (CLAUDE.md best practices, permission allowlists, sandboxing, CLI tools, MCP servers, hooks, skills, subagents, plugins), communication patterns (codebase questions, interview-driven design with AskUserQuestion), session management (Esc to stop, /rewind checkpoints, /clear context resets, /compact instructions, /btw side questions, subagents for investigation, --continue and --resume), automation and scaling (non-interactive mode with -p, parallel sessions, fan-out across files with --allowedTools, Writer/Reviewer pattern), common failure patterns (kitchen sink sessions, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), common workflows for debugging (sharing errors, fix recommendations), refactoring (legacy code, modern patterns), testing (coverage gaps, edge cases, test scaffolding), creating pull requests (summarize, create, enhance), documentation generation (JSDoc, docstrings), working with images (drag/drop, paste, screenshots), @ file and directory references, extended thinking (effort level, ultrathink, Option+T toggle, MAX_THINKING_TOKENS, adaptive reasoning), Plan Mode (Shift+Tab, --permission-mode plan, Ctrl+G to edit plans), resuming sessions (--continue, --resume, /rename, session picker), git worktrees (--worktree flag, subagent worktrees, cleanup, manual management), notification hooks (Notification event, permission_prompt/idle_prompt matchers), unix-style usage (piping, --output-format text/json/stream-json, build scripts), specialized subagents (/agents, custom agents). Load when discussing Claude Code best practices, effective prompting, context management, session workflows, Plan Mode, verification strategies, CLAUDE.md writing tips, parallel sessions, fan-out patterns, common workflows, debugging with Claude, refactoring, test generation, PR creation, git worktrees, extended thinking, ultrathink, effort level, notification hooks, non-interactive mode, piping data, output formats, @ file references, /clear, /compact, /rewind, /resume, --continue, --worktree, subagent delegation, or scaling Claude Code usage.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common development workflows.

## Quick Reference

Claude Code is an agentic coding environment. Performance degrades as the context window fills, making context management the most important resource to manage. Track usage with a custom status line and clear context between unrelated tasks.

### Core Principles

| Principle | Key Action |
|:----------|:-----------|
| **Verify work** | Provide tests, screenshots, or expected outputs so Claude can check itself |
| **Explore first** | Use Plan Mode to research before implementing |
| **Be specific** | Reference files, mention constraints, point to example patterns |
| **Manage context** | Run `/clear` between tasks; use subagents for investigation |
| **Course-correct early** | Press Esc to stop, `/rewind` to restore, `/clear` to reset |

### Verification Strategies

Give Claude a way to verify its work -- this is the single highest-leverage practice. Include test cases, expected outputs, screenshots to compare, or commands that validate results. Use the Claude in Chrome extension for visual UI verification.

### Explore-Plan-Implement Workflow

| Phase | Mode | Action |
|:------|:-----|:-------|
| Explore | Plan Mode (Shift+Tab) | Read files and answer questions without making changes |
| Plan | Plan Mode | Create a detailed implementation plan; press Ctrl+G to edit in text editor |
| Implement | Normal Mode | Code and verify against the plan |
| Commit | Normal Mode | Commit with a descriptive message and open a PR |

Skip planning when the scope is clear and the fix is small (one-sentence diff).

### Prompting Patterns

| Strategy | Example |
|:---------|:--------|
| **Scope the task** | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| **Point to sources** | "look through ExecutionFactory's git history and summarize how its api came to be" |
| **Reference patterns** | "look at how existing widgets are implemented. HotDogWidget.php is a good example. follow the pattern." |
| **Describe symptoms** | "users report login fails after session timeout. check src/auth/, especially token refresh." |

### Providing Rich Content

- `@file.ts` -- reference files directly in prompts
- Paste or drag-and-drop images into the prompt
- Give URLs for docs and API references; use `/permissions` to allowlist domains
- Pipe data: `cat error.log | claude`
- Tell Claude to fetch what it needs with Bash, MCP, or file reads

### CLAUDE.md Best Practices

CLAUDE.md is loaded every session, so keep it concise. Include what Claude cannot infer from code alone.

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Anything Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently-changing information |
| Architectural decisions and developer environment quirks | Long explanations, tutorials, or file-by-file descriptions |

Use `@path/to/import` syntax to import additional files. Place CLAUDE.md at `~/`, project root, parent dirs, or child dirs. Treat it like code: prune regularly, review when behavior goes wrong.

### Session Management

| Action | How |
|:-------|:----|
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc + Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact with focus | `/compact Focus on the API changes` |
| Summarize from a point | `/rewind` then select message and choose Summarize from here |
| Side question (no context cost) | `/btw` |
| Resume last session | `claude --continue` |
| Pick from recent sessions | `claude --resume` |
| Name a session | `claude -n auth-refactor` or `/rename auth-refactor` |

After two failed corrections on the same issue, `/clear` and restart with a better prompt.

### Using Subagents for Investigation

Delegate research to subagents to avoid filling your main context with file reads. The subagent explores in a separate context window and reports back a summary.

### Automation and Scaling

| Pattern | Usage |
|:--------|:------|
| **Non-interactive mode** | `claude -p "prompt"` for CI, scripts, pre-commit hooks |
| **Structured output** | `--output-format json` or `--output-format stream-json` |
| **Parallel sessions** | Desktop app, Claude Code on the web, or agent teams |
| **Writer/Reviewer** | Session A implements, Session B reviews in fresh context |
| **Fan-out** | Loop `claude -p` over a file list with `--allowedTools` to scope permissions |

### Extended Thinking

Enabled by default. Opus 4.6 and Sonnet 4.6 use adaptive reasoning that scales thinking depth based on effort level.

| Control | Method |
|:--------|:-------|
| Adjust effort | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in the prompt |
| Toggle on/off | Option+T (macOS) / Alt+T (Windows/Linux) |
| Global default | `/config` to toggle thinking mode |
| Limit budget | `MAX_THINKING_TOKENS` env var |

View thinking with Ctrl+O (verbose mode).

### Git Worktrees

Use `claude --worktree <name>` to start Claude in an isolated worktree. Each worktree gets its own files and branch while sharing repository history. Subagents can also use worktree isolation with `isolation: worktree` in agent frontmatter.

Worktrees are created at `<repo>/.claude/worktrees/<name>/`. Add `.claude/worktrees/` to `.gitignore`. On exit, empty worktrees are auto-removed; changed worktrees prompt to keep or remove.

### Plan Mode

| Method | Command |
|:-------|:--------|
| Toggle during session | Shift+Tab (cycles Normal -> Auto-Accept -> Plan) |
| Start new session | `claude --permission-mode plan` |
| Headless query | `claude --permission-mode plan -p "analyze the auth system"` |
| Set as default | `"permissions": { "defaultMode": "plan" }` in settings.json |

Press Ctrl+G to open the plan in your text editor for direct editing.

### Notification Hooks

Add a `Notification` hook in `~/.claude/settings.json` to get desktop alerts when Claude finishes or needs input. Filter with matchers: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`.

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (mixing unrelated tasks) | `/clear` between tasks |
| Repeated corrections (3+ tries) | `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; if Claude already does it right, delete the rule |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope investigations narrowly or use subagents |

### Common Workflows

| Workflow | Key Steps |
|:---------|:----------|
| **Codebase exploration** | Ask broad questions, narrow down, request glossary of project terms |
| **Bug fixing** | Share the error, ask for fix recommendations, apply and verify |
| **Refactoring** | Identify legacy code, get recommendations, apply incrementally, run tests |
| **Test writing** | Find untested code, generate scaffolding, add edge cases, run and verify |
| **Pull requests** | Summarize changes, `create a pr`, enhance description |
| **Documentation** | Find undocumented code, generate JSDoc/docstrings, verify against project standards |
| **Working with images** | Drag/drop, paste (Ctrl+V), or provide path; ask to analyze or generate code from visuals |

### Session Picker Shortcuts

| Shortcut | Action |
|:---------|:-------|
| Up/Down | Navigate sessions |
| Right/Left | Expand/collapse grouped sessions |
| Enter | Resume selected session |
| P | Preview session content |
| R | Rename session |
| / | Search/filter |
| A | Toggle current directory vs all projects |
| B | Filter to current git branch |

### Unix-Style Usage

Pipe data through Claude and control output format:

```bash
cat build-error.txt | claude -p 'explain the root cause' > output.txt
claude -p "List all API endpoints" --output-format json
```

Add Claude to build scripts as a linter or code reviewer with `claude -p` in package.json scripts.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) -- context window management (tracking usage, reducing tokens), verification strategies (tests, screenshots, expected outputs, Claude in Chrome), explore-plan-implement workflow (Plan Mode phases, when to skip planning), specific prompting (scoping tasks, pointing to sources, referencing patterns, describing symptoms), providing rich content (@ references, images, URLs, piped data), environment configuration (CLAUDE.md writing and placement, @imports, permission allowlists, sandboxing, CLI tools, MCP servers, hooks, skills, subagents, plugins), communication patterns (codebase questions, interview-driven design with AskUserQuestion), session management (Esc, /rewind, /clear, /compact, /btw, subagents for investigation, checkpoints, --continue, --resume, /rename), automation and scaling (non-interactive mode with -p, --output-format, parallel sessions via desktop/web/agent teams, Writer/Reviewer pattern, fan-out with --allowedTools), common failure patterns (kitchen sink, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), developing intuition
- [Common workflows](references/claude-code-common-workflows.md) -- codebase exploration (overview, finding relevant code), bug fixing (sharing errors, fix recommendations), refactoring (identifying legacy code, modern patterns, testing), specialized subagents (/agents, custom agents, explicit delegation), Plan Mode (Shift+Tab, --permission-mode plan, Ctrl+G, headless queries, configuring as default), test workflows (untested code, scaffolding, edge cases), creating pull requests (summarize, create, enhance, --from-pr), documentation generation (JSDoc, docstrings), working with images (drag/drop, paste, analyze, generate code from visuals), @ file and directory references (MCP resources), extended thinking (effort level, ultrathink, Option+T toggle, MAX_THINKING_TOKENS, adaptive reasoning, verbose mode), resuming sessions (--continue, --resume, --from-pr, /rename, session picker shortcuts), git worktrees (--worktree flag, subagent worktrees, cleanup, manual management, non-git VCS hooks), notification hooks (Notification event, matchers, platform-specific commands), unix-style usage (build scripts, piping, --output-format text/json/stream-json)

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
