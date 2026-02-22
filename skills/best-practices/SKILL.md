---
name: best-practices
description: Reference documentation for Claude Code best practices and common workflows — context management, prompt techniques, Plan Mode, verification strategies, CLAUDE.md writing, session management, parallel sessions, headless mode, fan-out patterns, debugging, refactoring, testing, and pull request workflows.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and everyday workflow recipes.

## Quick Reference

### Core Principle

Context is the most important resource. LLM performance degrades as the context window fills. Track usage with a custom status line, use `/clear` between unrelated tasks, and use `/compact` to reclaim space.

### Verification Strategies

| Strategy                  | Example prompt                                                                                            |
|:--------------------------|:----------------------------------------------------------------------------------------------------------|
| Provide test cases        | "write validateEmail. test: user@example.com is true, invalid is false. run the tests after implementing" |
| Verify UI visually        | "[paste screenshot] implement this design. take a screenshot and compare it to the original"              |
| Address root causes       | "the build fails with this error: [paste]. fix it and verify the build succeeds"                          |
| Use test suites / linters | Point Claude at your existing test runner or lint command as the success criterion                         |

### Explore-Plan-Implement-Commit Workflow

| Phase       | Mode        | What to do                                                       |
|:------------|:------------|:-----------------------------------------------------------------|
| 1. Explore  | Plan Mode   | Read files, understand architecture. No changes.                 |
| 2. Plan     | Plan Mode   | Create detailed implementation plan. `Ctrl+G` to edit in editor. |
| 3. Implement| Normal Mode | Code against the plan. Run tests.                                |
| 4. Commit   | Normal Mode | Commit with descriptive message, open PR.                        |

Skip planning for small, obvious changes (typo fix, rename, add log line).

### Prompt Techniques

| Technique           | Before                                | After                                                                                     |
|:--------------------|:--------------------------------------|:------------------------------------------------------------------------------------------|
| Scope the task      | "add tests for foo.py"                | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks" |
| Point to sources    | "why does ExecutionFactory have a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be"  |
| Reference patterns  | "add a calendar widget"               | "look at HotDogWidget.php, follow the pattern to implement a new calendar widget"         |
| Describe symptoms   | "fix the login bug"                   | "users report login fails after session timeout. check src/auth/, especially token refresh"|

### Rich Content Methods

- `@file.ts` -- reference files directly
- Paste or drag-drop images into the prompt
- Give URLs (allowlist domains with `/permissions`)
- Pipe data: `cat error.log | claude`
- Let Claude fetch context itself via Bash, MCP, or file reads

### CLAUDE.md Essentials

| Include                                        | Exclude                                       |
|:-----------------------------------------------|:-----------------------------------------------|
| Bash commands Claude cannot guess              | Anything Claude can figure out from code       |
| Code style rules differing from defaults       | Standard language conventions                  |
| Testing instructions / preferred test runners  | Detailed API docs (link instead)               |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently            |
| Architectural decisions specific to project    | Long explanations or tutorials                 |
| Dev environment quirks (required env vars)     | File-by-file codebase descriptions             |

Run `/init` to bootstrap. Keep it concise -- if Claude ignores a rule, the file is probably too long.

### Session Management

| Action                         | How                                                  |
|:-------------------------------|:-----------------------------------------------------|
| Stop mid-action                | `Esc`                                                |
| Rewind to checkpoint           | `Esc + Esc` or `/rewind`                             |
| Undo last changes              | "Undo that"                                          |
| Clear context                  | `/clear`                                             |
| Compact with focus             | `/compact Focus on the API changes`                  |
| Summarize from checkpoint      | `/rewind` then select **Summarize from here**        |
| Resume last session            | `claude --continue`                                  |
| Pick from recent sessions      | `claude --resume`                                    |
| Name a session                 | `/rename auth-refactor`                              |

### Parallel & Headless Patterns

| Pattern                  | Command / approach                                                            |
|:-------------------------|:------------------------------------------------------------------------------|
| Headless one-off         | `claude -p "prompt"`                                                         |
| Structured output        | `claude -p "prompt" --output-format json`                                    |
| Streaming output         | `claude -p "prompt" --output-format stream-json`                             |
| Fan-out migration        | `for file in $(cat files.txt); do claude -p "migrate $file" --allowedTools "Edit,Bash(git commit *)"; done` |
| Writer / Reviewer        | Session A implements, Session B reviews with fresh context                   |
| Worktree isolation       | `claude --worktree feature-auth`                                             |
| Skip permissions (CI)    | `claude --dangerously-skip-permissions` (use in sandbox only)                |

### Plan Mode

| How to enter                             | Notes                                  |
|:-----------------------------------------|:---------------------------------------|
| `Shift+Tab` (cycle modes)               | Normal -> Auto-Accept -> Plan          |
| `claude --permission-mode plan`          | Start new session in Plan Mode         |
| `claude --permission-mode plan -p "..."` | Headless Plan Mode                     |
| `.claude/settings.json` `defaultMode`    | Set Plan Mode as default               |

### Common Workflow Recipes

| Workflow          | Key steps                                                                             |
|:------------------|:--------------------------------------------------------------------------------------|
| Codebase overview | "give me an overview" then narrow: architecture, data models, auth                    |
| Fix a bug         | Share error + repro steps, ask for fix suggestions, apply and verify                  |
| Refactor          | Find legacy code, get suggestions, apply in small increments, run tests               |
| Write tests       | Find uncovered code, generate scaffolding, add edge cases, run and fix                |
| Create PR         | `/commit-push-pr` or step-by-step: summarize, create PR, enhance description         |
| Documentation     | Find undocumented code, generate docs, review, verify against standards               |

### Common Failure Patterns

| Anti-pattern               | Fix                                                                      |
|:---------------------------|:-------------------------------------------------------------------------|
| Kitchen sink session       | `/clear` between unrelated tasks                                         |
| Repeated corrections       | After 2 failures, `/clear` and write a better initial prompt             |
| Over-specified CLAUDE.md   | Prune ruthlessly; convert to hooks if rule must always apply             |
| Trust-then-verify gap      | Always provide verification (tests, scripts, screenshots)                |
| Infinite exploration       | Scope investigations narrowly or delegate to subagents                   |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) -- tips for context management, verification, prompting, environment setup, session management, parallel execution, and common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) -- step-by-step recipes for codebase exploration, debugging, refactoring, testing, PRs, Plan Mode, worktrees, session resumption, and headless usage

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
