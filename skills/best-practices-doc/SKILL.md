---
name: best-practices-doc
description: Reference documentation for Claude Code best practices and common workflows -- context window management, verify-your-work strategies, explore/plan/implement cycle, writing effective CLAUDE.md files, permissions, subagents, parallel sessions, non-interactive mode, session management, worktrees, Plan Mode, and avoiding common failure patterns.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for getting the most out of Claude Code.

## Quick Reference

The central constraint underlying all best practices: **Claude's context window fills up fast, and performance degrades as it fills.** Everything else follows from this.

### Core Workflow: Explore → Plan → Implement → Commit

| Phase | Mode | What to do |
|:------|:-----|:-----------|
| Explore | Plan Mode (`Shift+Tab` twice, or `--permission-mode plan`) | Read files, ask questions — no changes made |
| Plan | Plan Mode | Ask for a detailed implementation plan; press `Ctrl+G` to edit in your editor |
| Implement | Normal Mode | Let Claude code against its plan; run tests as verification |
| Commit | Normal Mode | `commit with a descriptive message and open a PR` |

Use planning for multi-file changes or unfamiliar code. Skip it for single-line fixes.

### Give Claude a Way to Verify Its Work

| Strategy | Weak prompt | Strong prompt |
|:---------|:------------|:--------------|
| Provide test cases | "implement validateEmail" | "write validateEmail; test cases: user@example.com=true, invalid=false. run tests after" |
| Verify UI visually | "make the dashboard look better" | "[screenshot] implement this design, take a screenshot, compare, list and fix differences" |
| Address root causes | "the build is failing" | "build fails with [error]. fix it and verify the build succeeds. address the root cause" |

### Prompt Specificity

| Strategy | Instead of | Write |
|:---------|:-----------|:------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case. avoid mocks." |
| Point to sources | "why is this API weird?" | "look through ExecutionFactory's git history and summarize how its API came to be" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php, follow the same pattern to implement a calendar widget" |
| Describe the symptom | "fix the login bug" | "users report login fails after session timeout. check src/auth/, write a failing test, fix it" |

### CLAUDE.md: What to Include vs. Exclude

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API docs (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices |

Keep CLAUDE.md short. If Claude keeps ignoring a rule, the file is too long. Use `@path/to/file` imports to split it up.

### Session Management Commands

| Command | Effect |
|:--------|:-------|
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc` + `Esc` or `/rewind` | Open rewind menu; restore conversation or code to any checkpoint |
| `/clear` | Reset context entirely between unrelated tasks |
| `/compact <instructions>` | Compact with custom focus, e.g. `/compact Focus on the API changes` |
| `/rename <name>` | Name a session for later retrieval |
| `claude --continue` | Resume the most recent conversation |
| `claude --resume` | Select from recent conversations |
| `claude --resume <name>` | Resume a named session |

### Non-Interactive (Headless) Mode

```bash
claude -p "your prompt"                             # one-off query
claude -p "List API endpoints" --output-format json
claude -p "Analyze this log" --output-format stream-json
claude --permission-mode plan -p "Analyze auth and suggest improvements"

# Fan out across files
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### Parallel Sessions / Worktrees

```bash
claude --worktree feature-auth      # isolated worktree + new branch
claude --worktree bugfix-123
claude --worktree                   # auto-generated name
```

Worktrees are created at `<repo>/.claude/worktrees/<name>`. Branch is named `worktree-<name>`. Add `.claude/worktrees/` to `.gitignore`.

Writer/Reviewer pattern: one session implements, a second fresh session reviews the output — no bias from having written the code.

### Plan Mode

```bash
claude --permission-mode plan                    # start in Plan Mode
Shift+Tab                                        # cycle: Normal → Auto-Accept → Plan
Ctrl+G                                           # open plan in editor
```

Configure as default:
```json
{ "permissions": { "defaultMode": "plan" } }
```

### Permissions

```bash
/permissions          # interactive allowlist configuration
/sandbox              # OS-level isolation (safer than --dangerously-skip-permissions)
--dangerously-skip-permissions   # bypass all checks (use in containers only)
```

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen-sink session (mixed unrelated tasks) | `/clear` between tasks |
| Correcting Claude 3+ times on the same mistake | `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md (rules get ignored) | Ruthlessly prune; convert to hooks if determinism needed |
| Trust-then-verify gap (plausible but broken output) | Always provide verification: tests, scripts, screenshots |
| Infinite exploration (Claude reads hundreds of files) | Scope narrowly or use subagents |

### Subagents for Context Management

Delegate investigation to subagents to keep your main context clean:

```
Use subagents to investigate how our authentication system handles token
refresh, and whether we have any existing OAuth utilities I should reuse.
```

```
use a subagent to review this code for edge cases
```

### Extended Thinking (Plan Mode)

Extended thinking is on by default. Toggle with `Option+T` (macOS) / `Alt+T` (Linux/Windows), or `Ctrl+O` for verbose mode to see reasoning.

For Opus 4.6: effort level controls depth. Set via `/model` or `CLAUDE_CODE_EFFORT_LEVEL` (low/medium/high). `MAX_THINKING_TOKENS=0` disables thinking on any model.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) -- context management, verify-your-work, explore/plan/implement, CLAUDE.md authoring, permissions, CLI tools, MCP, hooks, skills, subagents, plugins, session management, parallel sessions, non-interactive mode, failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) -- step-by-step guides for codebase exploration, bug fixing, refactoring, testing, PRs, documentation, images, file references, Plan Mode, worktrees, notifications, headless/pipe usage, and session resumption

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
