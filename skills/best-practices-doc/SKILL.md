---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context management (context window constraints, /clear, /compact, /rewind, /btw side questions, auto-compaction, summarize-from-here), verification strategies (tests, screenshots, linters, expected outputs, Claude in Chrome for UI), planning workflow (Plan Mode, Shift+Tab toggle, Ctrl+G edit plan, explore-plan-implement-commit phases), effective prompting (specific context, @file references, image paste, pipe data, CLI tools, rich content), CLAUDE.md configuration (what to include/exclude, pruning, emphasis, @path imports, placement locations home/project/parent/child), permissions (/permissions allowlists, /sandbox OS isolation, --dangerously-skip-permissions), hooks (deterministic actions, /hooks), skills (SKILL.md in .claude/skills/, user-invocable workflows, background knowledge), subagents (.claude/agents/, separate context, security-reviewer example, investigation delegation), plugins (/plugin marketplace, code intelligence, extensions), session management (Esc stop/rewind, /clear between tasks, /compact focus, course-correct early, --continue/--resume, /rename sessions, session picker), non-interactive mode (claude -p, --output-format text/json/stream-json, CI/CD pipelines, scripts), parallel sessions (desktop app, cloud VMs, agent teams, Writer/Reviewer pattern), fan-out patterns (batch processing, --allowedTools scoping), git worktrees (--worktree flag, subagent worktree isolation, cleanup), common workflows (codebase overview, find relevant code, fix bugs, refactor, tests, PRs, documentation, images, @ file references, MCP resources), extended thinking (adaptive reasoning, effort levels, /effort, ultrathink keyword, Option+T toggle, MAX_THINKING_TOKENS), Plan Mode (--permission-mode plan, Shift+Tab, read-only exploration, Ctrl+G plan editing), resume conversations (--continue, --resume, /resume picker, session naming, --from-pr), notification hooks (Notification event, permission_prompt/idle_prompt/auth_success/elicitation_dialog matchers), unix-style usage (pipe in/out, --output-format, build script linting), common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration). Load when discussing Claude Code best practices, effective prompting, context management, session management, CLAUDE.md tips, Plan Mode, verification strategies, parallel sessions, worktrees, fan-out patterns, common workflows, debugging workflows, testing workflows, PR creation, codebase exploration, refactoring, extended thinking, conversation resuming, notification hooks, non-interactive mode, or how to get the most out of Claude Code.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, effective usage patterns, and step-by-step common workflows.

## Quick Reference

### Core Principle: Manage Context

Claude's context window is the most important resource to manage. Performance degrades as context fills. Track usage with a custom status line and apply these strategies:

| Action | When to use |
|:-------|:------------|
| `/clear` | Between unrelated tasks, or after 2+ failed corrections |
| `/compact <focus>` | Preserve specific context while freeing space (e.g., `/compact Focus on the API changes`) |
| `/rewind` or `Esc+Esc` | Restore previous conversation/code state, or summarize from a checkpoint |
| `/btw` | Quick questions that should not enter conversation history |
| Subagents | Delegate research/investigation to keep main context clean |

### Verification Strategies

Providing Claude a way to verify its own work is the single highest-leverage practice.

| Strategy | Example prompt |
|:---------|:--------------|
| Tests | "write a validateEmail function... run the tests after implementing" |
| Screenshots | "[paste screenshot] implement this design. take a screenshot and compare to the original" |
| Root-cause fixing | "the build fails with this error: [paste]. fix it, verify the build succeeds, address the root cause" |
| Claude in Chrome | Use the Chrome extension for UI verification and iteration |

### Planning Workflow

Use Plan Mode (`Shift+Tab` to toggle) for multi-step or unfamiliar changes. Skip it for small, clear-scope tasks.

| Phase | Mode | Action |
|:------|:-----|:-------|
| Explore | Plan Mode | Read files and ask questions without changes |
| Plan | Plan Mode | Create detailed implementation plan. `Ctrl+G` to edit in text editor |
| Implement | Normal Mode | Code against the plan, write and run tests |
| Commit | Normal Mode | Commit with a descriptive message, open a PR |

Start Plan Mode: `Shift+Tab` during session, `--permission-mode plan` at startup, or configure as default in `.claude/settings.json` (`"defaultMode": "plan"`).

### Effective Prompting

| Technique | Before | After |
|:----------|:-------|:------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks" |
| Point to sources | "why is this API weird?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference patterns | "add a calendar widget" | "look at how existing widgets work on the home page. HotDogWidget.php is a good example. follow the pattern..." |
| Describe symptoms | "fix the login bug" | "users report login fails after session timeout. check src/auth/, especially token refresh. write a failing test, then fix" |

Rich content methods: `@file` references, paste images, give URLs, pipe data with `cat file | claude`, or let Claude fetch context itself.

### CLAUDE.md Configuration

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Things Claude can figure out from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Branch naming, PR conventions | Frequently changing information |
| Architectural decisions, environment quirks | Long explanations or tutorials |
| Common gotchas or non-obvious behaviors | Self-evident practices |

Generate a starter file with `/init`. Keep it concise -- if Claude ignores rules, the file is probably too long. Use emphasis ("IMPORTANT", "YOU MUST") for critical rules. Import files with `@path/to/file` syntax.

Placement locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project root, checked in), parent directories (monorepos), child directories (loaded on demand).

### Environment Setup Checklist

| Setup | Command / Path | Purpose |
|:------|:---------------|:--------|
| CLAUDE.md | `/init` | Persistent project context |
| Permissions | `/permissions` | Allowlist safe commands |
| Sandboxing | `/sandbox` | OS-level isolation |
| CLI tools | Install `gh`, `aws`, etc. | Context-efficient external service access |
| MCP servers | `claude mcp add` | Connect Notion, Figma, databases, etc. |
| Hooks | `.claude/settings.json` | Deterministic actions (lint after edit, block writes) |
| Skills | `.claude/skills/<name>/SKILL.md` | Domain knowledge, reusable workflows |
| Subagents | `.claude/agents/<name>.md` | Specialized isolated assistants |
| Plugins | `/plugin` | Community/Anthropic extensions |

### Session Management

| Action | Shortcut / Command |
|:-------|:-------------------|
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc+Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Resume latest session | `claude --continue` |
| Pick a session | `claude --resume` |
| Resume from PR | `claude --from-pr 123` |
| Name a session | `/rename auth-refactor` or `claude -n auth-refactor` |
| Switch mid-session | `/resume` |

Session picker shortcuts: arrows to navigate, `Enter` to select, `P` to preview, `R` to rename, `/` to search, `A` to toggle all projects, `B` to filter by branch.

### Extended Thinking

Enabled by default. Opus 4.6 and Sonnet 4.6 use adaptive reasoning controlled by effort level.

| Control | Method |
|:--------|:-------|
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in prompt |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` |
| Limit budget | `MAX_THINKING_TOKENS` env var (set to 0 to disable) |

View thinking with `Ctrl+O` (verbose mode). Disable adaptive reasoning with `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

### Parallel Sessions & Fan-Out

| Pattern | Description |
|:--------|:------------|
| Desktop app | Multiple local sessions, each with its own worktree |
| Claude Code on the web | Isolated cloud VMs |
| Agent teams | Automated coordination with shared tasks and messaging |
| Writer/Reviewer | Session A implements, Session B reviews with fresh context |
| Fan-out | Loop `claude -p` per file with `--allowedTools` scoping for batch migrations |
| Git worktrees | `claude --worktree feature-auth` for isolated parallel work |

Worktrees are created at `<repo>/.claude/worktrees/<name>`. Auto-cleanup when no changes; prompted on exit when changes exist. Subagents support `isolation: worktree` in frontmatter.

### Non-Interactive Mode

```
claude -p "prompt"                          # One-off query
claude -p "prompt" --output-format json     # Structured output
claude -p "prompt" --output-format stream-json  # Streaming
cat file | claude -p "analyze this"         # Pipe input
```

Use in CI pipelines, pre-commit hooks, build scripts, and data processing pipelines.

### Common Workflows

| Workflow | Key steps |
|:---------|:----------|
| Codebase overview | "give me an overview of this codebase" then drill into architecture, data models, auth |
| Find relevant code | "find the files that handle user authentication" then trace execution flow |
| Fix bugs | Share error, ask for fix recommendations, apply fix, verify |
| Refactor | Find deprecated usage, get recommendations, apply safely, run tests |
| Write tests | Identify untested code, generate scaffold, add edge cases, run and fix |
| Create PRs | Summarize changes, "create a pr", refine description |
| Documentation | Find undocumented code, generate docs, review and enhance |
| Work with images | Drag/drop, paste (Ctrl+V), or provide path; analyze, get code suggestions |
| @ file references | `@src/utils/auth.js` for files, `@src/components` for directories, `@github:repos/owner/repo/issues` for MCP |

### Notification Hooks

Set up desktop notifications when Claude finishes or needs input via the `Notification` hook event:

| Matcher | Fires when |
|:--------|:-----------|
| `permission_prompt` | Claude needs tool approval |
| `idle_prompt` | Claude is done, waiting for next prompt |
| `auth_success` | Authentication completes |
| `elicitation_dialog` | Claude is asking a question |

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen sink session (mixing unrelated tasks) | `/clear` between tasks |
| Repeated corrections (2+ failed fixes) | `/clear` and rewrite prompt with lessons learned |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks if needed |
| Trust-then-verify gap (no verification) | Always provide tests, scripts, or screenshots |
| Infinite exploration (unscoped investigation) | Scope narrowly or delegate to subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices](references/claude-code-best-practices.md) -- context management strategies, verification patterns (tests, screenshots, root cause), explore-plan-implement-commit workflow, Plan Mode usage, effective prompting techniques (scoping, sources, patterns, symptoms), rich content methods (@file, images, URLs, pipes), CLAUDE.md configuration (format, what to include/exclude, emphasis tuning, @imports, placement locations), permissions and sandboxing, CLI tools, MCP servers, hooks, skills, subagents, plugins, communication patterns (codebase questions, interview-driven specs), session management (Esc/rewind/undo/clear, context compaction, /btw, subagent delegation, checkpoints, --continue/--resume), non-interactive mode (claude -p, output formats), parallel sessions (desktop, web, agent teams, Writer/Reviewer pattern), fan-out patterns (batch processing, --allowedTools), common failure patterns, developing intuition
- [Common workflows](references/claude-code-common-workflows.md) -- codebase exploration (overview, find relevant code), bug fixing (share error, recommendations, apply and verify), refactoring (find deprecated, modernize, test), subagents (view/use/create specialized agents), Plan Mode (toggle with Shift+Tab, --permission-mode plan, Ctrl+G plan editing, configure as default), testing (identify gaps, generate scaffolds, edge cases, run and fix), PR creation (summarize, create, refine), documentation (find gaps, generate, review), working with images (drag/paste/path, analysis, code suggestions), @ file and directory references, MCP resources, extended thinking (adaptive reasoning, effort level, ultrathink, Option+T toggle, MAX_THINKING_TOKENS, verbose mode), resume conversations (--continue, --resume, /resume picker, session naming, --from-pr), git worktrees (--worktree flag, subagent isolation, cleanup, manual management, non-git VCS hooks), notification hooks (Notification event, platform-specific commands, matchers), unix-style usage (pipe in/out, output formats, build script integration), Claude self-documentation queries

## Sources

- Best practices: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
