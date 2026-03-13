---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context window management, verification strategies (tests, screenshots, linting), explore-plan-implement workflow, Plan Mode (Shift+Tab, --permission-mode plan, Ctrl+G to edit plans), writing effective CLAUDE.md files (/init, placement, @-imports, pruning), providing specific context (@-references, images, URLs, piped data), configuring permissions (/permissions, sandboxing, --dangerously-skip-permissions), CLI tools (gh, aws, gcloud), MCP servers, hooks for deterministic actions, skills for domain knowledge, subagents for isolated investigation, plugins, session management (/clear, /rewind, /compact, /btw, Esc, --continue, --resume, /rename), extended thinking (adaptive reasoning, effort levels, ultrathink, Option+T toggle, MAX_THINKING_TOKENS), non-interactive mode (claude -p, --output-format, --allowedTools), parallel sessions (desktop app, web, agent teams, writer/reviewer pattern), fan-out across files, common failure patterns (kitchen sink session, over-correction, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), common workflows for debugging, refactoring, testing, PRs, documentation, images, file references, git worktrees (--worktree, subagent worktrees, cleanup), desktop notifications via hooks, and unix-style piping. Load when discussing Claude Code tips, best practices, productivity, effective prompting, session management, context management, Plan Mode, CLAUDE.md writing, common workflows, debugging, refactoring, testing, PR creation, worktrees, parallel sessions, or scaling Claude Code usage.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for getting the most out of Claude Code, from effective prompting and environment configuration to step-by-step workflows for debugging, testing, refactoring, and more.

## Quick Reference

### Core Principle: Manage Context

Claude's context window is the most important resource. Performance degrades as it fills. Track usage with a custom status line and use `/clear` between unrelated tasks.

### Give Claude a Way to Verify Its Work

The single highest-leverage practice. Provide tests, screenshots, or expected outputs so Claude can check itself.

| Strategy | Example |
|:---------|:--------|
| Verification criteria | "write validateEmail, test cases: user@example.com true, invalid false. run tests after implementing" |
| Visual verification | "[paste screenshot] implement this design. screenshot the result and compare" |
| Root cause focus | "build fails with [error]. fix it and verify the build succeeds" |

### Explore-Plan-Implement Workflow

1. **Explore** (Plan Mode): read files, understand the codebase
2. **Plan** (Plan Mode): create a detailed implementation plan; press `Ctrl+G` to edit in your text editor
3. **Implement** (Normal Mode): code against the plan, run tests
4. **Commit**: descriptive message and PR

Skip planning when the scope is clear and the change is small.

### Plan Mode

| Method | How |
|:-------|:----|
| Toggle during session | `Shift+Tab` (cycles Normal > Auto-Accept > Plan) |
| Start new session | `claude --permission-mode plan` |
| Headless query | `claude --permission-mode plan -p "Analyze the auth system"` |
| Set as default | `.claude/settings.json`: `{"permissions": {"defaultMode": "plan"}}` |

### Providing Context

| Technique | Usage |
|:----------|:------|
| `@` file references | `@src/utils/auth.js` -- includes file content |
| `@` directory references | `@src/components` -- shows directory listing |
| `@` MCP resources | `@github:repos/owner/repo/issues` |
| Paste images | Drag-and-drop or Ctrl+V into the prompt |
| Give URLs | Use `/permissions` to allowlist frequently-used domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to pull context itself via Bash, MCP, or file reads |

### Writing Effective CLAUDE.md

Run `/init` to generate a starter file. Place at:

| Location | Scope |
|:---------|:------|
| `~/.claude/CLAUDE.md` | All sessions |
| `./CLAUDE.md` | Project (check into git) |
| Parent directories | Monorepos (auto-pulled) |
| Child directories | On-demand when Claude works in that directory |

Include: bash commands Claude cannot guess, non-default code style rules, test instructions, repo etiquette, architectural decisions, environment quirks, common gotchas. Exclude: anything Claude can infer from code, standard language conventions, detailed API docs (link instead), frequently-changing info, self-evident practices.

Use `@path/to/import` syntax to import additional files. Prune regularly -- if Claude ignores a rule, the file is likely too long.

### Environment Configuration

| Feature | Purpose |
|:--------|:--------|
| Permissions (`/permissions`) | Allowlist safe commands to reduce interruptions |
| Sandboxing (`/sandbox`) | OS-level isolation for freer operation |
| CLI tools (gh, aws, etc.) | Context-efficient way to interact with external services |
| MCP servers (`claude mcp add`) | Connect Notion, Figma, databases, etc. |
| Hooks (`/hooks`) | Deterministic actions (unlike advisory CLAUDE.md instructions) |
| Skills (`.claude/skills/`) | Domain knowledge and reusable workflows |
| Subagents (`.claude/agents/`) | Isolated tasks with own context and tool access |
| Plugins (`/plugin`) | Bundled skills, hooks, agents, MCP from community |

### Session Management

| Action | How |
|:-------|:----|
| Stop mid-action | `Esc` |
| Rewind | `Esc + Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact with focus | `/compact Focus on the API changes` |
| Partial compact | `/rewind` > select checkpoint > "Summarize from here" |
| Side question (no context) | `/btw` |
| Resume most recent | `claude --continue` |
| Resume by name | `claude --resume auth-refactor` |
| Name a session | `/rename auth-refactor` |

Rule of thumb: after two failed corrections on the same issue, `/clear` and start fresh with a better prompt.

### Extended Thinking

Enabled by default. Opus 4.6 uses adaptive reasoning with effort levels (low/medium/high).

| Control | Method |
|:--------|:-------|
| Effort level | `/model` or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in your prompt |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` |
| Global default | `/config` |
| Limit token budget | `MAX_THINKING_TOKENS` env var (ignored on Opus 4.6 unless set to 0) |

View thinking with `Ctrl+O` (verbose mode).

### Scaling with Parallel Sessions

| Method | Description |
|:-------|:------------|
| Desktop app | Multiple local sessions, each with its own worktree |
| Claude Code on the web | Cloud VMs with isolated environments |
| Agent teams | Automated coordination with shared tasks and messaging |
| Writer/Reviewer pattern | Session A implements, Session B reviews with fresh context |

### Git Worktrees

Use `--worktree` (or `-w`) to create isolated working copies:

```bash
claude --worktree feature-auth    # Named worktree
claude --worktree                 # Auto-generated name
```

Worktrees are created at `<repo>/.claude/worktrees/<name>`. Cleanup is automatic for unchanged worktrees; Claude prompts for changed ones. Subagents can also use worktree isolation with `isolation: worktree` in agent frontmatter.

### Non-Interactive & Fan-Out

```bash
claude -p "prompt"                          # One-off query
claude -p "prompt" --output-format json     # Structured output
cat data.txt | claude -p "summarize" > out  # Piped data
```

Fan-out pattern for large migrations:

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue" \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### Common Workflows

| Workflow | Key steps |
|:---------|:----------|
| Codebase exploration | Start broad, narrow down; ask architecture, data models, patterns |
| Bug fixing | Share error + reproduction steps, ask for root cause fix, verify |
| Refactoring | Identify legacy code, get recommendations, apply in small increments, test |
| Testing | Find untested code, generate scaffolding, add edge cases, run and fix |
| Pull requests | Summarize changes, `create a pr`, enhance description |
| Documentation | Find undocumented code, generate docs, review, verify standards |
| Images | Drag-and-drop or paste; use for errors, designs, diagrams |
| Desktop notifications | `/hooks` > Notification event > add OS notification command |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen sink session | `/clear` between unrelated tasks |
| Repeated corrections | After 2 failures, `/clear` and write a better prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks if needed |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices](references/claude-code-best-practices.md) -- context management, verification strategies, explore-plan-implement workflow, specific prompting, rich content (@-refs, images, URLs, piping), CLAUDE.md writing and placement, permissions and sandboxing, CLI tools, MCP servers, hooks, skills, subagents, plugins, session management (/clear, /rewind, /compact, /btw, --continue, --resume), extended thinking (adaptive reasoning, effort levels, ultrathink), non-interactive mode, parallel sessions, fan-out, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) -- codebase exploration, finding relevant code, bug fixing, refactoring, subagent usage, Plan Mode (toggle, CLI, headless, configuration), testing, pull requests, documentation, image analysis, file and directory references, extended thinking configuration, session resumption (/resume, naming, picker shortcuts), git worktrees (--worktree, subagent worktrees, cleanup, manual management, non-git VCS), desktop notifications via hooks, unix-style utility usage (linting, piping, output formats)

## Sources

- Best practices: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
