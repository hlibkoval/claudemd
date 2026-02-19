---
name: best-practices
description: Best practices and common workflows for Claude Code — prompting patterns, context management, CLAUDE.md authoring, Plan Mode, parallel sessions, headless automation, verification strategies, and step-by-step recipes for debugging, refactoring, testing, PRs, and more.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for getting the most out of Claude Code.

## Quick Reference

### Context Management

Context is the primary resource to manage — performance degrades as the window fills.

| Technique | When to use |
|:----------|:------------|
| `/clear` | Between unrelated tasks to reset context entirely |
| `/compact <instructions>` | Preserve key info during long sessions |
| `Esc + Esc` / `/rewind` | Restore conversation/code to a prior checkpoint |
| Subagents for investigation | Delegate file exploration so it doesn't pollute main context |

### Plan Mode

| Action | How |
|:-------|:----|
| Toggle during session | `Shift+Tab` (cycles Normal → Auto-Accept → Plan) |
| Start in Plan Mode | `claude --permission-mode plan` |
| Headless Plan Mode | `claude --permission-mode plan -p "..."` |
| Set as default | `{"permissions": {"defaultMode": "plan"}}` in `.claude/settings.json` |
| Edit plan in editor | `Ctrl+G` while Claude presents a plan |

Use Plan Mode when: change touches multiple files, approach is uncertain, or you're unfamiliar with the code. Skip it for single-line fixes.

### Prompting Patterns

| Pattern | Vague | Specific |
|:--------|:------|:---------|
| Verification | "implement email validator" | "write validateEmail, run tests: user@example.com=true, invalid=false" |
| Scoping | "add tests for foo.py" | "test the logged-out edge case in foo.py, no mocks" |
| Bug fix | "fix login bug" | "login fails after session timeout — check src/auth/ token refresh, write failing test then fix" |
| UI change | "make dashboard look better" | "implement this design [screenshot], screenshot result, compare, list diffs, fix them" |

### CLAUDE.md Authorship

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude infers from code |
| Code style rules that differ from defaults | Standard language conventions |
| Test runners and testing instructions | Detailed API docs (link instead) |
| Branch naming and PR conventions | Info that changes frequently |
| Required env vars / environment quirks | File-by-file codebase descriptions |
| Common gotchas and non-obvious behaviors | Self-evident practices ("write clean code") |

Import other files with `@path/to/file` syntax inside CLAUDE.md. CLAUDE.md locations:
- `~/.claude/CLAUDE.md` — all sessions
- `./CLAUDE.md` — project (commit to git) or `CLAUDE.local.md` (gitignored)
- Parent/child directories — monorepo support

### Session Management

| Command | Action |
|:--------|:-------|
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Open session picker |
| `claude --resume <name>` | Resume named session |
| `claude --from-pr 123` | Resume session linked to a PR |
| `/rename <name>` | Name the current session |
| `/resume` | Switch sessions from within Claude |

### Headless / Automation

```bash
claude -p "prompt"                          # Non-interactive, plain text output
claude -p "prompt" --output-format json     # Structured output for scripts
claude -p "prompt" --output-format stream-json  # Streaming real-time output

# Fan-out across files
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue" --allowedTools "Edit,Bash(git commit *)"
done

# Pipe integration
cat build-error.txt | claude -p "explain the root cause" > output.txt
```

### Extended Thinking

| Scope | How |
|:------|:----|
| Effort level (Opus 4.6) | `/model` or `CLAUDE_CODE_EFFORT_LEVEL=low/medium/high` |
| Toggle thinking | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` → toggle thinking |
| Limit token budget | `MAX_THINKING_TOKENS=10000` (ignored on Opus 4.6 unless `=0`) |
| View reasoning | `Ctrl+O` (verbose mode — gray italic text) |

### Parallel Sessions

| Method | Description |
|:-------|:------------|
| Desktop app | Multiple sessions with isolated git worktrees |
| Claude Code on the web | Cloud VMs with isolated environments |
| Agent teams | Automated coordination with shared tasks and messaging |
| Git worktrees + CLI | `git worktree add ../feature-a -b feature-a`, then `claude` in each dir |

**Writer/Reviewer pattern**: Session A implements, Session B reviews from fresh context, Session A addresses feedback.

### Common Failure Patterns

| Failure | Fix |
|:--------|:----|
| Kitchen sink session (mixing tasks) | `/clear` between unrelated tasks |
| Correcting repeatedly in same session | After 2 corrections, `/clear` and write a better prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert stale rules to hooks |
| Trust-then-verify gap | Always provide tests, scripts, or screenshots for verification |
| Infinite exploration | Scope narrowly or delegate to subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) — prompting patterns, CLAUDE.md setup, permissions, MCP, hooks, skills, subagents, plugins, session management, parallel sessions, and avoiding failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step recipes for codebase exploration, bug fixing, refactoring, tests, PRs, documentation, images, Plan Mode, sessions, worktrees, Unix-style automation, and extended thinking

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
