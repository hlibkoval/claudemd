---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- context window management (the fundamental constraint, /clear between tasks, /compact with focus instructions, /btw for side questions, auto-compaction, custom compaction instructions in CLAUDE.md), verification strategies (tests, screenshots, linter checks, Claude in Chrome for UI, address root causes not symptoms), explore-plan-implement workflow (Plan Mode with Shift+Tab toggle, --permission-mode plan, Ctrl+G to edit plan, skip planning for small changes), providing specific context (scope tasks, point to sources, reference existing patterns, describe symptoms, @ file references, paste images, pipe data, give URLs, /permissions for domain allowlists), CLAUDE.md best practices (run /init, keep concise under 200 lines, prune regularly, include vs exclude guidance, @import syntax, file locations -- home/project/parent/child, emphasis for critical rules), permission configuration (/permissions allowlists, sandboxing, --dangerously-skip-permissions only in sandboxed environments), CLI tool integration (gh, aws, gcloud, sentry-cli, learning new CLIs with --help), MCP server connections (claude mcp add, Notion/Figma/database integration), hooks setup (deterministic actions, /hooks menu, eslint after file edit, block writes to folders), skills creation (SKILL.md in .claude/skills/, domain knowledge, repeatable workflows with $ARGUMENTS and disable-model-invocation), custom subagents (.claude/agents/, isolated context, specialized tools and model, security-reviewer example), plugins (/plugin marketplace, code intelligence plugins), communication patterns (codebase questions for onboarding, interview workflow with AskUserQuestion for specs), session management (Esc to stop, Esc+Esc or /rewind for checkpoints, "undo that", /clear for fresh context, course-correct early, two-failure rule -- /clear and rewrite prompt), context management (/clear between tasks, /compact with focus instructions, /rewind summarize-from-here, compaction instructions in CLAUDE.md, /btw for side questions), subagent investigation (separate context for research, post-implementation review), checkpoint system (automatic before changes, restore conversation/code/both, persist across sessions, not a git replacement), session resumption (--continue, --resume, --from-pr, /resume picker, /rename, session naming with -n), automation and scaling (non-interactive mode with claude -p, --output-format text/json/stream-json, parallel sessions with desktop app/web/agent teams, writer-reviewer pattern, fan-out with --allowedTools, piping and unix integration), common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), common workflows (codebase overview, find relevant code, fix bugs, refactor code, subagent usage with /agents, Plan Mode for analysis with Shift+Tab and --permission-mode plan and Ctrl+G, test writing and coverage, PR creation with gh pr create and --from-pr, documentation generation, image analysis with drag-drop/paste/path, @ file and directory references, extended thinking with adaptive reasoning and effort levels and ultrathink keyword and Option+T toggle, resume conversations with --continue/--resume/--from-pr and /resume picker and /rename and session naming, git worktrees with --worktree/-w and .claude/worktrees/ and subagent isolation and cleanup, desktop notifications with Notification hook on macOS/Linux/Windows, unix utility patterns with -p and piping and --output-format, scheduled tasks with cloud/desktop/GitHub Actions//loop options, Claude self-documentation queries). Load when discussing best practices, tips, common workflows, getting started patterns, Plan Mode usage, context management, session management, CLAUDE.md writing tips, verification strategies, parallel sessions, fan-out patterns, non-interactive mode, piping, unix integration, codebase exploration, debugging workflows, refactoring, test workflows, PR creation, git worktrees, extended thinking, effort levels, subagent investigation, checkpoint usage, session resumption, desktop notifications, scheduled tasks, or scaling Claude Code usage.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common workflows -- patterns for effective usage, environment configuration, session management, automation, and step-by-step recipes for everyday development tasks.

## Quick Reference

### The Fundamental Constraint: Context Window

Claude's context window holds your entire conversation, including every message, every file read, and every command output. Performance degrades as context fills. Managing context is the single most important thing to optimize.

| Action | When to use |
|:-------|:------------|
| `/clear` | Between unrelated tasks to reset context entirely |
| `/compact <instructions>` | Mid-session to summarize while preserving key context (e.g., `/compact Focus on the API changes`) |
| `/btw` | Quick questions that should not enter conversation history |
| `Esc + Esc` or `/rewind` then "Summarize from here" | Condense a specific portion of conversation |
| CLAUDE.md compaction instructions | Persist rules like "When compacting, always preserve the full list of modified files" |

### Give Claude a Way to Verify Its Work

This is the single highest-leverage practice. Without verification, you become the only feedback loop.

| Strategy | Example |
|:---------|:--------|
| **Provide test cases** | "Write a validateEmail function. Test cases: user@example.com is true, invalid is false. Run the tests after implementing" |
| **Verify UI visually** | "[paste screenshot] Implement this design. Take a screenshot and compare it to the original. List differences and fix them" |
| **Address root causes** | "The build fails with this error: [paste]. Fix it and verify the build succeeds. Address the root cause, don't suppress the error" |

Use the Claude in Chrome extension for UI verification loops. Invest in rock-solid verification: tests, linters, or Bash commands that check output.

### Explore, Plan, Then Code

| Phase | Mode | Purpose |
|:------|:-----|:--------|
| **Explore** | Plan Mode | Read files, answer questions, no changes |
| **Plan** | Plan Mode | Create detailed implementation plan; press `Ctrl+G` to edit in your editor |
| **Implement** | Normal Mode | Code against the plan, run tests |
| **Commit** | Normal Mode | Commit with descriptive message, open PR |

Toggle Plan Mode with `Shift+Tab` (cycles Normal -> Auto-Accept -> Plan). Start a session in Plan Mode with `--permission-mode plan`. Skip planning when the change is small and obvious.

### Provide Specific Context

| Strategy | What to do |
|:---------|:-----------|
| **Scope tasks** | Specify which file, what scenario, and testing preferences |
| **Point to sources** | Direct Claude to git history, specific files, or docs |
| **Reference patterns** | Point to existing code patterns to follow |
| **Describe symptoms** | Provide the symptom, likely location, and what "fixed" looks like |

Ways to provide rich content:

- `@file.ts` to reference files directly
- Paste or drag-drop images
- Give URLs (use `/permissions` to allowlist domains)
- Pipe data: `cat error.log \| claude`
- Tell Claude to fetch context itself using Bash, MCP, or file reads

### Configure Your Environment

| Setup | How |
|:------|:----|
| **CLAUDE.md** | Run `/init` to generate; keep under 200 lines; include Bash commands, code style, workflow rules; prune regularly |
| **Permissions** | `/permissions` to allowlist safe commands; `/sandbox` for OS-level isolation |
| **CLI tools** | Install `gh`, `aws`, `gcloud`, etc.; Claude uses them for context-efficient external service interaction |
| **MCP servers** | `claude mcp add` to connect Notion, Figma, databases, etc. |
| **Hooks** | Deterministic automation at lifecycle points; `/hooks` to browse; Claude can write hooks for you |
| **Skills** | `SKILL.md` in `.claude/skills/` for domain knowledge and repeatable workflows |
| **Subagents** | `.claude/agents/` for specialized isolated assistants with their own tools and model |
| **Plugins** | `/plugin` to browse the marketplace; code intelligence plugins for typed languages |

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners | Detailed API documentation (link to docs instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

CLAUDE.md locations: home folder (`~/.claude/CLAUDE.md`), project root (`./CLAUDE.md`), parent directories, child directories (loaded on demand). Use `@path/to/import` for additional files. Add emphasis ("IMPORTANT", "YOU MUST") for critical rules.

### Session Management

| Action | How |
|:-------|:----|
| **Stop mid-action** | `Esc` (context preserved, redirect) |
| **Rewind** | `Esc + Esc` or `/rewind` to restore previous state |
| **Undo changes** | "Undo that" |
| **Reset context** | `/clear` between unrelated tasks |
| **Resume last session** | `claude --continue` |
| **Pick a session** | `claude --resume` or `/resume` |
| **Resume from PR** | `claude --from-pr <number>` |
| **Name sessions** | `claude -n auth-refactor` or `/rename` |

**Two-failure rule:** After two failed corrections on the same issue, run `/clear` and start fresh with a better prompt incorporating what you learned.

### Subagent Investigation

Delegate research to subagents to keep your main context clean:

```
Use subagents to investigate how our authentication system handles token
refresh, and whether we have any existing OAuth utilities I should reuse.
```

The subagent explores in a separate context window and reports back a summary. Also use subagents for post-implementation code review.

### Automation and Scaling

| Pattern | How |
|:--------|:----|
| **Non-interactive mode** | `claude -p "prompt"` for CI, scripts, pre-commit hooks |
| **Output formats** | `--output-format text` (default), `json`, `stream-json` |
| **Parallel sessions** | Desktop app, Claude Code on the web, or agent teams |
| **Writer/Reviewer** | Session A implements; Session B reviews with fresh context |
| **Fan-out** | Loop `claude -p` over a file list with `--allowedTools` to scope permissions |
| **Unix piping** | `cat data.txt \| claude -p "summarize" > output.txt` |
| **Scheduled tasks** | Cloud tasks, desktop scheduled tasks, GitHub Actions, or `/loop` |

### Common Workflows Quick Reference

| Workflow | Key steps |
|:---------|:----------|
| **Codebase overview** | "give me an overview of this codebase" then narrow down to architecture, data models, auth |
| **Find relevant code** | "find the files that handle X" then "how do these files work together?" then "trace the flow from A to B" |
| **Fix bugs** | Share error, ask for fix suggestions, apply fix, verify |
| **Refactor** | Identify legacy code, get recommendations, apply changes safely, run tests |
| **Write tests** | Find untested code, generate scaffolding, add edge cases, run and verify |
| **Create PRs** | Summarize changes, `create a pr`, enhance description |
| **Git worktrees** | `claude --worktree feature-auth` for isolated parallel sessions; `.claude/worktrees/` |
| **Extended thinking** | Enabled by default; adjust with `/effort`, `ultrathink` keyword, or `Option+T` toggle |
| **Plan Mode** | `Shift+Tab` to toggle; `--permission-mode plan` to start in it; `Ctrl+G` to edit plan |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| **Kitchen sink session** | `/clear` between unrelated tasks |
| **Repeated corrections** | After two failures, `/clear` and write a better initial prompt |
| **Over-specified CLAUDE.md** | Prune ruthlessly; convert to hooks if Claude already does it correctly |
| **Trust-then-verify gap** | Always provide verification (tests, scripts, screenshots) |
| **Infinite exploration** | Scope investigations narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) -- context window as the fundamental constraint, verification strategies (tests, screenshots, linter checks, Claude in Chrome, root cause analysis), explore-plan-implement workflow (Plan Mode with Shift+Tab, --permission-mode plan, Ctrl+G to edit plan, skip for small changes), providing specific context (scope tasks, point to sources, reference existing patterns, describe symptoms, @ file references, paste images, pipe data, URLs, /permissions), environment configuration (CLAUDE.md with /init and pruning guidelines and include/exclude table and @imports and file locations, permissions with /permissions and sandboxing and --dangerously-skip-permissions, CLI tools like gh/aws/gcloud, MCP servers with claude mcp add, hooks for deterministic actions, skills in .claude/skills/, subagents in .claude/agents/, plugins via /plugin), communication patterns (codebase questions for onboarding, interview workflow with AskUserQuestion for specs), session management (Esc to stop, Esc+Esc and /rewind for checkpoints, "undo that", /clear between tasks, two-failure rule, /compact with focus instructions, /btw for side questions, subagent investigation for clean context, checkpoint system with restore conversation/code/both, session resumption with --continue/--resume/--from-pr and /rename), automation and scaling (non-interactive claude -p with --output-format, parallel sessions via desktop app/web/agent teams, writer-reviewer pattern, fan-out with --allowedTools, unix piping), common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration)
- [Common workflows](references/claude-code-common-workflows.md) -- codebase exploration (overview, find relevant code, code intelligence plugins), bug fixing (share error, suggest fixes, apply and verify), refactoring (identify legacy code, modernize, test increments), subagent usage (/agents, automatic delegation, explicit requests, custom subagents in .claude/agents/), Plan Mode for safe analysis (Shift+Tab toggle, --permission-mode plan, Ctrl+G to edit plan, headless plan queries, configure as default in settings), test workflows (find untested code, generate scaffolding, add edge cases, run and verify), PR creation (summarize, create, enhance description, --from-pr linking), documentation generation (find undocumented code, generate comments, verify standards), image analysis (drag-drop, paste with ctrl+v, file path, screenshots, mockups, diagrams), @ file and directory references (single file, directory listing, MCP resources with @server:resource), extended thinking (adaptive reasoning with effort levels, ultrathink keyword, Option+T/Alt+T toggle, /config, MAX_THINKING_TOKENS, Ctrl+O verbose mode), session resumption (--continue/--resume/--from-pr, /resume picker with keyboard shortcuts, /rename, session naming with -n, forked session grouping), git worktrees (--worktree/-w flag, .claude/worktrees/ location, subagent worktree isolation, automatic cleanup, manual management, non-git VCS hooks), desktop notifications (Notification hook on macOS/Linux/Windows, matcher filtering by permission_prompt/idle_prompt/auth_success/elicitation_dialog), unix utility patterns (-p for non-interactive, piping in/out, --output-format text/json/stream-json, build script integration), scheduled tasks (cloud/desktop/GitHub Actions//loop options, explicit success criteria for autonomous tasks), Claude self-documentation queries

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
