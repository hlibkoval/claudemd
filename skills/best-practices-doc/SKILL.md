---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context window management, verification strategies (tests, screenshots, expected outputs), Plan Mode (explore/plan/implement/commit), prompting techniques (scoping tasks, referencing patterns, rich content with @ mentions and images), CLAUDE.md authoring (what to include/exclude, placement, imports), permission configuration, CLI tool usage, MCP servers, hooks, skills, subagents, plugins, effective communication (codebase questions, interview-driven development), session management (course-correcting, /clear, /compact, /rewind, checkpoints, resuming), non-interactive mode (claude -p), parallel sessions (worktrees, Writer/Reviewer, fan-out), common failure patterns, and step-by-step workflows for debugging, refactoring, testing, PRs, documentation, images, extended thinking, and git worktrees. Load when discussing Claude Code tips, best practices, effective prompting, workflow patterns, context management, Plan Mode, session management, parallel sessions, common workflows, debugging workflows, refactoring, writing tests, creating PRs, worktrees, non-interactive mode, or how to get better results from Claude Code.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for getting the most out of Claude Code, from prompting techniques and environment setup to step-by-step workflow recipes.

## Quick Reference

### Core Principle: Manage Context

Claude's context window is the most important resource. Performance degrades as it fills. Track usage with a custom status line and apply these strategies:

| Action | When to use |
|:-------|:------------|
| `/clear` | Between unrelated tasks |
| `/compact <instructions>` | Mid-session when context is large; optionally focus on specific topics |
| Esc + Esc or `/rewind` > Summarize | Condense messages from a checkpoint forward |
| Subagents for research | Delegate file-heavy exploration to separate context |
| `/btw` | Quick side questions that should not enter history |

### Give Claude Verification

The single highest-leverage practice: let Claude check its own work.

| Strategy | Example |
|:---------|:--------|
| Provide test cases | "write validateEmail, run these tests: user@example.com -> true, invalid -> false" |
| Visual verification | Paste a screenshot, ask Claude to implement and compare |
| Root-cause fixes | Paste the error, ask Claude to fix and verify the build succeeds |

### Explore, Plan, Implement, Commit

Use Plan Mode (Shift+Tab to toggle, or `--permission-mode plan`) to separate research from execution:

1. **Explore** -- Plan Mode: read files, understand the codebase
2. **Plan** -- Plan Mode: create a detailed implementation plan (Ctrl+G to edit in editor)
3. **Implement** -- Normal Mode: code against the plan, run tests
4. **Commit** -- Normal Mode: commit and open a PR

Skip planning for small, obvious changes where you could describe the diff in one sentence.

### Prompting Techniques

| Technique | Details |
|:----------|:--------|
| **Scope the task** | Specify file, scenario, testing preferences |
| **Point to sources** | Direct Claude to git history, specific files, or docs |
| **Reference patterns** | Point to an existing implementation to follow |
| **Describe symptoms** | Provide error text, reproduction steps, expected behavior |
| **Provide rich content** | `@file` references, paste images, give URLs, pipe data with `cat file \| claude` |

Vague prompts are fine for exploration; specific prompts reduce corrections.

### CLAUDE.md Authoring

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Anything Claude can infer from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently changing information |
| Architectural decisions, dev environment quirks | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices |

Run `/init` to generate a starter file. Keep it concise -- bloated files cause Claude to ignore rules. Add emphasis ("IMPORTANT") for critical rules. Check it into git. Use `@path/to/import` syntax to import other files.

**Placement**: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project root, shared), parent directories (monorepos), child directories (loaded on demand).

### Environment Setup

| Setup | How |
|:------|:----|
| **Permissions** | `/permissions` to allowlist safe commands; `/sandbox` for OS-level isolation |
| **CLI tools** | Install `gh`, `aws`, `gcloud`, etc. -- most context-efficient way to use external services |
| **MCP servers** | `claude mcp add` for Notion, Figma, databases, etc. |
| **Hooks** | Deterministic scripts at lifecycle points (e.g., lint after edit, block writes to migrations) |
| **Skills** | `.claude/skills/SKILL.md` for domain knowledge and reusable workflows |
| **Subagents** | `.claude/agents/*.md` for specialized tasks in isolated context |
| **Plugins** | `/plugin` to browse the marketplace |

### Session Management

| Action | Command / Key |
|:-------|:-------------|
| Stop mid-action | `Esc` |
| Rewind conversation + code | `Esc + Esc` or `/rewind` |
| Undo changes | "undo that" |
| Clear context | `/clear` |
| Compact context | `/compact` or `/compact Focus on API changes` |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` or `claude --resume session-name` |
| Name a session | `/rename auth-refactor` |
| Resume from PR | `claude --from-pr 123` |

After two failed corrections on the same issue, `/clear` and write a better initial prompt.

### Parallel Sessions & Automation

| Pattern | Details |
|:--------|:--------|
| **Non-interactive** | `claude -p "prompt"` for CI, scripts, pre-commit hooks |
| **Output formats** | `--output-format text\|json\|stream-json` |
| **Worktrees** | `claude --worktree feature-auth` for isolated parallel sessions |
| **Writer/Reviewer** | Session A implements, Session B reviews with fresh context |
| **Fan-out** | Loop `claude -p` over a file list with `--allowedTools` to scope permissions |
| **Agent teams** | Automated coordination of multiple sessions with shared tasks |
| **Autonomous mode** | `--dangerously-skip-permissions` in sandboxed containers only |

### Extended Thinking

Enabled by default. Opus 4.6 uses adaptive reasoning controlled by effort level (low/medium/high).

| Control | Method |
|:--------|:-------|
| Effort level | `/model` menu or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in prompt |
| Toggle on/off | Option+T (macOS) / Alt+T |
| Global default | `/config` |
| Limit budget | `MAX_THINKING_TOKENS` env var (set to 0 to disable) |

### Common Workflows

| Workflow | Key steps |
|:---------|:----------|
| **Codebase exploration** | Start broad, narrow down; ask questions like you would ask a senior engineer |
| **Bug fixing** | Share error + repro steps, ask for fix suggestions, apply and verify |
| **Refactoring** | Find deprecated usage, get recommendations, apply incrementally, run tests |
| **Writing tests** | Identify untested code, generate scaffold, add edge cases, run and fix |
| **Creating PRs** | Summarize changes, `create a pr`, enhance description |
| **Documentation** | Find undocumented code, generate docs, review and verify standards |
| **Image analysis** | Drag/drop or paste images, ask for analysis, use for UI implementation |
| **Git worktrees** | `claude --worktree name` for isolated parallel work; auto-cleanup on exit |
| **Desktop notifications** | `/hooks` > Notification event > configure OS-specific notify command |
| **Unix-style piping** | `cat file \| claude -p "prompt" > output.txt` |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session (mixed unrelated tasks) | `/clear` between tasks |
| Repeated corrections (>2 on same issue) | `/clear`, write a better prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks if deterministic |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) -- context management, verification strategies, Plan Mode workflow, prompting techniques, CLAUDE.md authoring, environment configuration (permissions, CLI tools, MCP, hooks, skills, subagents, plugins), communication patterns (codebase questions, interview-driven development), session management (course-correcting, context management, checkpoints, resuming), automation and scaling (non-interactive mode, parallel sessions, fan-out, autonomous mode), common failure patterns, and developing intuition
- [Common workflows](references/claude-code-common-workflows.md) -- step-by-step recipes for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, writing tests, creating PRs, documentation, images, file references, extended thinking, resuming sessions, git worktrees, desktop notifications, Unix-style piping, and output formats

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
