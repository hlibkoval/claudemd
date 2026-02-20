---
name: best-practices
description: Reference documentation for Claude Code best practices and common workflows — prompting strategies, context management, Plan Mode, verification patterns, CLAUDE.md authoring, session management, parallel sessions, headless mode, fan-out, worktrees, and step-by-step recipes for debugging, testing, refactoring, PRs, and documentation.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for getting the most out of Claude Code, including prompting patterns, environment setup, session management, and step-by-step workflow recipes.

## Quick Reference

The single most important resource to manage is **context**. Performance degrades as the context window fills. Track usage with a custom status line and clear between tasks.

### Core Principles

| Principle | What to do |
|:----------|:-----------|
| **Verify work** | Provide tests, screenshots, or expected outputs so Claude can check itself |
| **Explore first** | Use Plan Mode (`Shift+Tab`) to research before coding |
| **Be specific** | Reference files, mention constraints, point to example patterns |
| **Manage context** | `/clear` between unrelated tasks; `/compact` to summarize |
| **Course-correct early** | `Esc` to stop, `Esc+Esc` or `/rewind` to restore, `/clear` to reset |

### Prompting Strategies

| Strategy | Before | After |
|:---------|:-------|:------|
| Verification criteria | "implement email validation" | "write validateEmail, test: user@example.com=true, invalid=false. Run the tests" |
| Scope the task | "add tests for foo.py" | "test foo.py edge case where user is logged out. avoid mocks" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php, follow the pattern to implement a calendar widget" |
| Describe symptoms | "fix the login bug" | "login fails after session timeout. check src/auth/ token refresh. write a failing test, then fix" |

### Providing Rich Content

- **`@` references** -- include files directly instead of describing paths
- **Paste images** -- drag and drop or copy/paste into the prompt
- **Give URLs** -- use `/permissions` to allowlist frequently-used domains
- **Pipe data** -- `cat error.log | claude` sends file contents directly
- **Let Claude fetch** -- tell Claude to pull context via Bash, MCP, or file reads

### Plan Mode

Toggle with `Shift+Tab` or start with `--permission-mode plan`. Four phases:

1. **Explore** -- read files, answer questions (Plan Mode)
2. **Plan** -- create detailed implementation plan; `Ctrl+G` to edit in editor
3. **Implement** -- switch to Normal Mode, code against the plan
4. **Commit** -- commit with descriptive message, open PR

Skip planning for small, clear tasks (typo fix, rename, log line).

### Session Management

| Action | How |
|:-------|:----|
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc+Esc` or `/rewind` |
| Undo changes | "undo that" |
| Clear context | `/clear` |
| Compact context | `/compact <focus>` |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` |
| Name session | `/rename <name>` |

### Environment Setup Checklist

| Setup step | How |
|:-----------|:----|
| CLAUDE.md | `/init` to bootstrap, then refine; keep it concise |
| Permissions | `/permissions` to allowlist safe commands, or `/sandbox` |
| CLI tools | Install `gh`, `aws`, `gcloud`, etc. for context-efficient service access |
| MCP servers | `claude mcp add` for Notion, Figma, databases, etc. |
| Hooks | `/hooks` or `.claude/settings.json` for deterministic actions |
| Skills | `.claude/skills/<name>/SKILL.md` for domain knowledge |
| Subagents | `.claude/agents/<name>.md` for specialized isolated tasks |
| Plugins | `/plugin` to browse the marketplace |

### CLAUDE.md Authoring

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Anything Claude can infer from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions, preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branches, PRs) | Frequently changing info |
| Architecture decisions, common gotchas | Long tutorials, file-by-file descriptions |

### Scaling & Automation

| Pattern | Command / approach |
|:--------|:-------------------|
| Headless mode | `claude -p "prompt"` with `--output-format text\|json\|stream-json` |
| Parallel sessions | Desktop app, Claude on the web, or agent teams |
| Writer/Reviewer | Session A implements; Session B reviews with fresh context |
| Fan-out | Loop `claude -p` per file with `--allowedTools` to scope permissions |
| Worktrees | `claude -w <name>` for isolated working directories |
| Autonomous | `--dangerously-skip-permissions` in sandboxed container only |

### Common Workflows

| Workflow | Key prompts |
|:---------|:------------|
| Codebase overview | "give me an overview of this codebase", "explain the main architecture" |
| Fix bugs | Share error output, ask for fix recommendations, apply and verify |
| Refactor | "find deprecated API usage", "refactor to ES2024, maintain behavior", run tests |
| Write tests | "find untested functions in X", "add edge case tests", "run and fix failures" |
| Create PR | "create a pr" or `/commit-push-pr`; resume later with `claude --from-pr <n>` |
| Documentation | "find functions without JSDoc in X", "add comments", "verify standards" |
| Images | Drag/drop or paste screenshots; "generate CSS to match this design mockup" |

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen sink session (mixed unrelated tasks) | `/clear` between tasks |
| Correcting over and over (>2 failed fixes) | `/clear`, rewrite prompt with lessons learned |
| Over-specified CLAUDE.md (rules get lost) | Prune ruthlessly; convert to hooks if deterministic |
| Trust-then-verify gap (no validation) | Always provide tests, scripts, or screenshots |
| Infinite exploration (unbounded research) | Scope narrowly or delegate to subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) -- prompting strategies, context management, environment setup, session management, scaling patterns, and common failure modes
- [Common Workflows](references/claude-code-common-workflows.md) -- step-by-step recipes for codebase exploration, debugging, refactoring, testing, PRs, documentation, images, Plan Mode, worktrees, session resume, and headless/piped usage

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
