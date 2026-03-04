---
name: best-practices-doc
description: Best practices and common workflows for effective Claude Code usage
user-invocable: false
---

# Claude Code Best Practices & Common Workflows

## Core Constraint: Context Window

Context fills fast and performance degrades as it fills. Manage it aggressively.

- Track usage with a custom status line
- Run `/clear` between unrelated tasks
- Use subagents for investigation (keeps main context clean)
- After two failed corrections, `/clear` and rewrite the prompt

## Top Best Practices

| Practice | Key Point |
|---|---|
| **Verify your work** | Provide tests, screenshots, or expected outputs so Claude can self-check |
| **Explore then plan then code** | Use Plan Mode to separate research from implementation |
| **Be specific** | Reference exact files, constraints, and patterns — not vague descriptions |
| **Write an effective CLAUDE.md** | Short, human-readable; only what Claude can't infer from code |
| **Use CLI tools** | `gh`, `aws`, `gcloud` are context-efficient for external services |

## The Explore → Plan → Implement → Commit Workflow

```
# 1. Explore (Plan Mode — Shift+Tab twice, or --permission-mode plan)
read /src/auth and understand how sessions and login work

# 2. Plan
I want to add Google OAuth. What files need to change? Create a plan.
# Press Ctrl+G to open plan in editor

# 3. Implement (switch back to Normal Mode)
implement the OAuth flow. write tests and fix any failures.

# 4. Commit
commit with a descriptive message and open a PR
```

Use Plan Mode for multi-file changes, unfamiliar code, or uncertain approaches. Skip it for small, obvious fixes.

## Prompting Tips

| Strategy | Weak | Strong |
|---|---|---|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering logged-out edge case, avoid mocks" |
| Reference patterns | "add a calendar widget" | "follow HotDogWidget.php pattern to implement a calendar widget" |
| Describe symptoms | "fix the login bug" | "login fails after session timeout — check src/auth/, write a failing test, then fix it" |
| Point to sources | "why is ExecutionFactory's API weird?" | "look through ExecutionFactory's git history and summarize" |

### Rich Input Methods

- `@file.ts` — include file contents directly
- Paste images (Ctrl+V) or drag-and-drop
- `cat error.log | claude` — pipe data in
- Give URLs; use `/permissions` to allowlist domains

## CLAUDE.md Guidelines

| Include | Exclude |
|---|---|
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Code style rules that differ from defaults | Standard language conventions |
| Test runner instructions | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | File-by-file descriptions |
| Common gotchas / non-obvious behaviors | Self-evident practices |

- Run `/init` to generate a starter file
- Keep it under ~20 meaningful lines; prune ruthlessly
- Add `@path/to/file` imports for supplementary docs
- CLAUDE.md locations: `~/.claude/`, project root, parent dirs, child dirs

## Session Management

| Command / Key | Effect |
|---|---|
| `Esc` | Stop Claude, preserve context |
| `Esc Esc` or `/rewind` | Open rewind menu — restore conversation and/or code |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact with custom focus |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Pick from recent sessions |
| `/rename <name>` | Name the current session |

## Automation & Scaling

```bash
# Non-interactive / CI
claude -p "your prompt"
claude -p "List API endpoints" --output-format json
claude -p "Analyze log" --output-format stream-json

# Batch file migration
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done

# Pipe in/out
cat build-error.txt | claude -p 'explain root cause' > output.txt
```

## Common Failure Patterns

| Pattern | Fix |
|---|---|
| Kitchen-sink session (unrelated tasks mixed) | `/clear` between tasks |
| Correcting Claude repeatedly on the same issue | `/clear` + rewrite prompt with lessons learned |
| Over-specified CLAUDE.md (rules get ignored) | Ruthlessly prune; convert stable rules to hooks |
| Trust-then-verify gap (untested plausible output) | Always provide tests or verification scripts |
| Infinite exploration consuming main context | Scope investigations or use subagents |

## Plan Mode Quick Reference

```bash
# Start in plan mode
claude --permission-mode plan

# Headless plan-mode query
claude --permission-mode plan -p "Analyze auth system and suggest improvements"
```

Toggle during session: **Shift+Tab** (Normal → Auto-Accept → Plan Mode)
Edit plan in editor: **Ctrl+G**

## Git Worktrees for Parallel Sessions

```bash
claude --worktree feature-auth      # creates .claude/worktrees/feature-auth/
claude --worktree bugfix-123        # separate isolated session
claude --worktree                   # auto-generates name
```

Add `.claude/worktrees/` to `.gitignore`. When you exit, Claude prompts to keep or remove if changes exist.

## Reference Files

- [claude-code-best-practices.md](references/claude-code-best-practices.md) — Tips and patterns for effective usage
- [claude-code-common-workflows.md](references/claude-code-common-workflows.md) — Step-by-step recipes for everyday tasks
