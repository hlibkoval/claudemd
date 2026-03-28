---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- covering context window management (context fills fast, /clear between tasks, /compact with instructions, /btw for side questions, subagents for investigation, auto compaction), verification strategies (tests, screenshots, expected outputs, Claude in Chrome extension, root cause debugging), explore-plan-implement workflow (Plan Mode with Shift+Tab or --permission-mode plan, Ctrl+G to edit plan, four phases explore/plan/implement/commit, when to skip planning), prompt specificity (scope tasks, point to sources, reference existing patterns, describe symptoms, @ file references, paste images, pipe data, give URLs, /permissions for domains), CLAUDE.md conventions (concise human-readable, /init to generate, what to include vs exclude, emphasis for adherence, @ imports, placement hierarchy home/project/parent/child, prune regularly), environment configuration (permissions with auto mode/allowlists/sandboxing, CLI tools like gh/aws/gcloud, MCP servers with claude mcp add, hooks for deterministic actions, skills in .claude/skills/, custom subagents in .claude/agents/, plugins from /plugin marketplace), communication patterns (codebase questions for onboarding, interview mode with AskUserQuestion tool, spec generation), session management (Esc to stop, Esc+Esc or /rewind for checkpoints, /clear for context reset, course-correct early, /compact for selective summarization, subagents for context-preserving research, checkpoint restore conversation/code/both, --continue and --resume for session persistence, /rename for session naming), scaling and automation (non-interactive mode with claude -p, --output-format text/json/stream-json, parallel sessions via desktop app/web/agent teams, writer-reviewer pattern, fan-out with --allowedTools, auto mode with --permission-mode auto, git worktrees with --worktree/-w for isolation, .worktreeinclude for gitignored files, subagent worktrees with isolation: worktree), common workflows (codebase overview, find relevant code, fix bugs, refactor code, specialized subagents with /agents, Plan Mode for safe analysis with Shift+Tab toggle and --permission-mode plan and Ctrl+G editor, work with tests, create pull requests with gh pr create and --from-pr, documentation generation, image analysis with drag-drop/paste/path, @ file and directory references, extended thinking with adaptive reasoning and effort levels and ultrathink keyword and Option+T/Alt+T toggle and MAX_THINKING_TOKENS, resume sessions with --continue/--resume/--from-pr and /resume picker with keyboard shortcuts, git worktrees for parallel sessions, desktop notifications with Notification hook, unix-style utility with pipe in/out and --output-format, scheduled tasks with cloud/desktop/GitHub Actions//loop, Claude self-documentation), and common failure patterns (kitchen sink session, repeated corrections, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration). Load when discussing Claude Code best practices, effective prompting for Claude Code, context window management, session management, CLAUDE.md writing tips, Plan Mode usage, parallel Claude sessions, non-interactive mode, scaling Claude Code, common workflows, debugging workflows, testing workflows, PR creation, code refactoring, codebase exploration, git worktrees, extended thinking, or any topic about getting the most out of Claude Code.
user-invocable: false
---

# Best Practices and Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common workflows -- covering effective prompting, context management, environment configuration, session management, scaling patterns, and step-by-step workflow recipes.

## Quick Reference

### Core Principle: Manage Your Context Window

The context window is the most important resource. Performance degrades as it fills. Most best practices stem from this constraint.

| Action | When to use |
|:-------|:------------|
| `/clear` | Between unrelated tasks to reset context |
| `/compact <instructions>` | To selectively summarize and free context (e.g., `/compact Focus on the API changes`) |
| `/btw` | Quick side questions that stay out of conversation history |
| Subagents | Delegate research/investigation to preserve main context |
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc + Esc` or `/rewind` | Restore to a previous checkpoint (conversation, code, or both) |

### The Four-Phase Workflow

1. **Explore** -- Plan Mode (`Shift+Tab` or `--permission-mode plan`). Read files, ask questions, no changes.
2. **Plan** -- Ask Claude to create a detailed plan. Press `Ctrl+G` to edit the plan in your text editor.
3. **Implement** -- Switch to Normal Mode. Code against the plan. Run tests.
4. **Commit** -- Ask Claude to commit and create a PR.

Skip planning when the change is small enough to describe in one sentence.

### Prompt Quality Patterns

| Strategy | Weak prompt | Strong prompt |
|:---------|:------------|:--------------|
| **Verification** | "implement email validation" | "write validateEmail, test cases: user@example.com=true, invalid=false, user@.com=false. run the tests" |
| **Scope** | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks" |
| **Source pointers** | "why is this API weird?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| **Existing patterns** | "add a calendar widget" | "look at how widgets are implemented on the home page. HotDogWidget.php is a good example. follow the pattern" |
| **Symptom + location** | "fix the login bug" | "login fails after session timeout. check src/auth/, especially token refresh. write a failing test, then fix it" |

### Providing Rich Context

| Method | Usage |
|:-------|:------|
| `@file.ts` | Reference a file directly in your prompt |
| Paste images | Copy/paste or drag-and-drop into the prompt |
| URLs | Give documentation/API URLs. Use `/permissions` to allowlist domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to pull context via Bash, MCP, or file reads |

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude cannot guess | Anything Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Frequently changing information |
| Architectural decisions specific to project | Long explanations or tutorials |
| Dev environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

**Placement hierarchy:** `~/.claude/CLAUDE.md` (global) > `./CLAUDE.md` (project root, check into git) > parent directories (monorepo) > child directories (on demand).

Use `@path/to/file` imports inside CLAUDE.md. Run `/init` to generate a starter file.

### Environment Configuration

| Feature | Purpose | Setup |
|:--------|:--------|:------|
| **Auto mode** | Classifier-based permission approval | `--permission-mode auto` or `Shift+Tab` |
| **Permission allowlists** | Permit specific safe tools | `/permissions` |
| **Sandboxing** | OS-level filesystem/network isolation | `/sandbox` |
| **CLI tools** | Context-efficient external service access | Install `gh`, `aws`, `gcloud`, `sentry-cli`, etc. |
| **MCP servers** | Connect Notion, Figma, databases, etc. | `claude mcp add` |
| **Hooks** | Deterministic actions at workflow points | `.claude/settings.json` or `/hooks` |
| **Skills** | Domain knowledge and reusable workflows | `.claude/skills/<name>/SKILL.md` |
| **Subagents** | Isolated task delegation with own tools | `.claude/agents/<name>.md` |
| **Plugins** | Bundled skills/hooks/agents/MCP from community | `/plugin` marketplace |

### Session Management

| Command | Purpose |
|:--------|:--------|
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Pick from recent sessions |
| `claude --resume <name>` | Resume a named session |
| `claude --from-pr 123` | Resume session linked to a PR |
| `/rename <name>` | Name the current session |
| `/resume` | Switch to a different conversation mid-session |
| `/rewind` | Open checkpoint restore menu |
| `/clear` | Reset context entirely |
| `/compact` | Summarize and compress context |

### Scaling and Automation

| Pattern | How |
|:--------|:----|
| **Non-interactive** | `claude -p "prompt"` with `--output-format text\|json\|stream-json` |
| **Parallel sessions** | Desktop app, Claude Code on the web, or agent teams |
| **Writer/Reviewer** | Session A implements, Session B reviews with fresh context |
| **Fan-out** | Loop `claude -p` over file list with `--allowedTools` to scope permissions |
| **Auto mode** | `claude --permission-mode auto -p "fix all lint errors"` |
| **Git worktrees** | `claude --worktree <name>` for isolated parallel workspaces |

### Git Worktrees

```bash
claude --worktree feature-auth    # Named worktree at .claude/worktrees/feature-auth/
claude --worktree                 # Auto-generated name
claude -w bugfix-123              # Short flag
```

Worktrees branch from `origin/HEAD`. Re-sync with `git remote set-head origin -a`. Add `.claude/worktrees/` to `.gitignore`. Use `.worktreeinclude` to copy gitignored files (`.env`, etc.) into worktrees.

Subagent worktrees: set `isolation: worktree` in agent frontmatter. Auto-cleaned when subagent finishes without changes.

### Extended Thinking

| Control | Method |
|:--------|:-------|
| **Effort level** | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| **ultrathink** | Include "ultrathink" in prompt for one-off high effort |
| **Toggle** | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| **Global default** | `/config` to toggle thinking mode |
| **Token limit** | `MAX_THINKING_TOKENS` env var |

View thinking with `Ctrl+O` (verbose mode). Opus 4.6 and Sonnet 4.6 use adaptive reasoning based on effort level.

### Common Workflow Recipes

| Workflow | Key prompts / commands |
|:---------|:----------------------|
| **Codebase overview** | "give me an overview of this codebase", then drill into architecture, data models, auth |
| **Find code** | "find the files that handle user authentication", "trace the login process from front-end to database" |
| **Fix bugs** | Share error, ask for fix suggestions, apply and verify |
| **Refactor** | Find deprecated usage, get recommendations, apply, run tests |
| **Subagents** | `/agents` to view/create, "use the code-reviewer subagent to check the auth module" |
| **Tests** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **Pull requests** | "create a pr" (auto-links session; resume with `--from-pr`) |
| **Documentation** | Find undocumented code, generate JSDoc/docstrings, review |
| **Images** | Drag-drop, paste (`Ctrl+V`), or give path. Analyze screenshots, mockups, diagrams |
| **Notifications** | Add `Notification` hook in `~/.claude/settings.json` for desktop alerts |
| **Scheduled tasks** | Cloud (claude.ai/code), desktop app, GitHub Actions, or `/loop` |
| **Unix utility** | `cat file \| claude -p "prompt" > output.txt`, add to package.json scripts |

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| **Kitchen sink session** (mixing unrelated tasks) | `/clear` between tasks |
| **Repeated corrections** (same mistake 3+ times) | `/clear` and write a better initial prompt |
| **Over-specified CLAUDE.md** (rules get lost) | Prune ruthlessly; convert to hooks if mandatory |
| **Trust-then-verify gap** (no validation) | Always provide tests, scripts, or screenshots |
| **Infinite exploration** (unscoped investigation) | Scope narrowly or delegate to subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) -- Context window management (why it matters, tracking usage), verification strategies (tests, screenshots, root cause debugging, Chrome extension), explore-plan-implement-commit workflow (Plan Mode phases, when to skip planning, Ctrl+G editor), prompt specificity (scope tasks, point to sources, reference patterns, describe symptoms), providing rich content (@ references, images, URLs, piping, /permissions), CLAUDE.md conventions (format, what to include/exclude, emphasis, @ imports, placement hierarchy, /init, pruning), environment configuration (permissions with auto mode/allowlists/sandboxing, CLI tools, MCP servers, hooks, skills, subagents, plugins), communication patterns (codebase questions, interview mode with AskUserQuestion, spec generation), session management (Esc/Esc+Esc//rewind, /clear, course-correct early, context compaction, /btw side questions, subagents for investigation, checkpointing, --continue/--resume session resumption, /rename), scaling and automation (non-interactive claude -p with output formats, parallel sessions via desktop/web/agent teams, writer-reviewer pattern, fan-out with --allowedTools, auto mode), and common failure patterns (kitchen sink, repeated corrections, over-specified CLAUDE.md, trust-verify gap, infinite exploration)
- [Common Workflows](references/claude-code-common-workflows.md) -- Understand new codebases (overview, find relevant code), fix bugs (share error, suggest fixes, apply), refactor code (find deprecated usage, apply modern patterns, verify), specialized subagents (/agents, automatic delegation, custom subagents), Plan Mode for safe analysis (when to use, Shift+Tab toggle, --permission-mode plan, Ctrl+G editor, configure as default), work with tests (find untested code, generate scaffolding, edge cases, run), create pull requests (summarize, create, --from-pr resume), handle documentation (find undocumented code, generate, verify), work with images (drag-drop/paste/path, analyze screenshots/mockups), @ file and directory references (single file, directory listing, MCP resources), extended thinking (adaptive reasoning, effort level, ultrathink, Option+T/Alt+T toggle, /config, MAX_THINKING_TOKENS, verbose mode with Ctrl+O), resume previous conversations (--continue/--resume/--from-pr, /resume picker, session naming, keyboard shortcuts), git worktrees for parallel sessions (--worktree/-w, subagent worktrees, cleanup, .worktreeinclude, manual management, non-git VCS hooks), desktop notifications (Notification hook, matchers permission_prompt/idle_prompt/auth_success/elicitation_dialog), unix-style utility (build script linting, pipe in/out, --output-format text/json/stream-json), scheduled tasks (cloud/desktop/GitHub Actions//loop), and asking Claude about its capabilities

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
