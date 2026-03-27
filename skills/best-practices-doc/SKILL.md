---
name: best-practices-doc
description: Complete documentation for Claude Code best practices and common workflows -- effective prompting, context management, environment configuration, session management, parallel execution, and step-by-step guides for debugging, refactoring, testing, PRs, worktrees, scheduling, and automation. Covers context window management (/clear, /compact, /rewind, /btw, auto compaction, summarize-from-here), CLAUDE.md configuration (placement hierarchy, @imports, /init, pruning strategy, emphasis tuning), Plan Mode (Shift+Tab toggle, --permission-mode plan, Ctrl+G plan editing, session naming from plan), prompt engineering (scoping tasks, referencing files with @, pasting images, piping data, URL permissions, providing verification criteria, visual verification with Chrome extension, root cause instructions), environment setup (permissions and auto mode, CLI tools like gh/aws/gcloud, MCP servers, hooks, skills, subagents, plugins), session management (Esc/Esc+Esc/rewind, /clear between tasks, /compact with focus instructions, --continue/--resume/--from-pr, /rename, session picker shortcuts), subagent delegation (separate context windows, investigation and review patterns, worktree isolation), fan-out patterns (claude -p in loops, --allowedTools scoping, --output-format text/json/stream-json), non-interactive mode (CI pipelines, pre-commit hooks, scripts), scheduled tasks (cloud/desktop/GitHub Actions//loop options), desktop notifications (Notification hook event, platform-specific commands, matcher narrowing), git worktrees (--worktree flag, .worktreeinclude for gitignored files, subagent worktrees with isolation: worktree, worktree cleanup, manual management, non-git VCS hooks), extended thinking (adaptive reasoning on Opus 4.6/Sonnet 4.6, effort level, ultrathink keyword, Option+T/Alt+T toggle, MAX_THINKING_TOKENS, verbose mode Ctrl+O), common failure patterns (kitchen sink session, over-correction, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration), and common workflow recipes (codebase exploration, bug fixing, refactoring, testing, PRs, documentation, images, file references, Unix-style piping, output format control, session resumption). Load when discussing Claude Code best practices, effective prompting, workflow patterns, context management, session tips, CLAUDE.md writing, Plan Mode, worktrees, parallel sessions, fan-out, non-interactive mode, scheduled tasks, CI integration, extended thinking, or common Claude Code workflows.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and common development workflows.

## Quick Reference

### Core Principle: Context Window Management

Claude's context window is the most important resource to manage. Performance degrades as it fills. Track usage with a custom status line, and use these techniques:

| Technique | When to use |
|:----------|:------------|
| `/clear` | Between unrelated tasks -- reset context entirely |
| `/compact <instructions>` | Mid-session to summarize and free space (e.g., `/compact Focus on the API changes`) |
| `Esc + Esc` or `/rewind` then **Summarize from here** | Condense messages from a selected checkpoint forward |
| `/btw` | Quick side questions that never enter conversation history |
| Subagents | Delegate research to a separate context window |
| Auto compaction | Triggers automatically near context limits -- customize what to preserve in CLAUDE.md |

### Effective Prompting Patterns

| Strategy | Weak prompt | Strong prompt |
|:---------|:------------|:--------------|
| **Provide verification** | "implement email validation" | "write validateEmail, test with user@example.com (true), invalid (false), user@.com (false). run tests after implementing" |
| **Scope the task** | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks" |
| **Reference patterns** | "add a calendar widget" | "look at HotDogWidget.php for the pattern. follow it to implement a calendar widget with month selection and year pagination" |
| **Describe symptoms** | "fix the login bug" | "login fails after session timeout. check auth flow in src/auth/, especially token refresh. write a failing test, then fix it" |
| **Point to sources** | "why does ExecutionFactory have a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |

### Rich Content Input

| Method | Usage |
|:-------|:------|
| `@` file reference | `Explain the logic in @src/utils/auth.js` |
| Paste images | Copy/paste or drag and drop into the prompt |
| URLs | Give doc/API URLs; use `/permissions` to allowlist domains |
| Pipe data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to pull context via Bash, MCP, or file reads |

### Explore-Plan-Implement-Commit Workflow

1. **Explore** (Plan Mode): read files, understand the codebase without changes
2. **Plan** (Plan Mode): create a detailed implementation plan; press `Ctrl+G` to edit the plan in your editor
3. **Implement** (Normal Mode): code against the plan, run tests, fix failures
4. **Commit** (Normal Mode): commit with a descriptive message, open a PR

Skip planning for small, clear-scope tasks (typo fixes, single-line changes). Use it when uncertain about approach, touching multiple files, or unfamiliar with the code.

### Plan Mode

| Action | How |
|:-------|:----|
| Toggle during session | `Shift+Tab` (cycles Normal -> Auto-Accept -> Plan) |
| Start new session in Plan Mode | `claude --permission-mode plan` |
| Headless query in Plan Mode | `claude --permission-mode plan -p "analyze the auth system"` |
| Edit plan in editor | `Ctrl+G` |
| Set as default | `"permissions": { "defaultMode": "plan" }` in `.claude/settings.json` |

### CLAUDE.md Configuration

**Placement hierarchy** (all loaded automatically when relevant):

| Location | Scope |
|:---------|:------|
| `~/.claude/CLAUDE.md` | All sessions (personal) |
| `./CLAUDE.md` (project root) | Team-shared (check into git) |
| Parent directories | Monorepo root + nested dirs |
| Child directories | Loaded on demand when working in that directory |

**What to include vs exclude:**

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions, preferred runners | Detailed API docs (link instead) |
| Branch naming, PR conventions | Frequently changing information |
| Architectural decisions, gotchas | File-by-file codebase descriptions |
| Required env vars | Self-evident practices |

**Imports:** Use `@path/to/file` syntax to import other files into CLAUDE.md.

Run `/init` to generate a starter file. Add emphasis ("IMPORTANT", "YOU MUST") for critical rules. Prune regularly -- if Claude ignores rules, the file is likely too long.

### Environment Setup Checklist

| Setup | How |
|:------|:----|
| Permissions | `/permissions` to allowlist commands, or use auto mode (`--permission-mode auto`) |
| CLI tools | Install `gh`, `aws`, `gcloud`, etc.; Claude uses them for external services |
| MCP servers | `claude mcp add` to connect Notion, Figma, databases, etc. |
| Hooks | `/hooks` to browse; Claude can write hooks (e.g., "write a hook that runs eslint after every file edit") |
| Skills | Add `SKILL.md` files in `.claude/skills/` for domain knowledge |
| Subagents | Define in `.claude/agents/` with specialized tools and instructions |
| Plugins | `/plugin` to browse marketplace; install code intelligence plugins for typed languages |

### Session Management

| Action | Command |
|:-------|:--------|
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc + Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Reset context | `/clear` |
| Resume most recent | `claude --continue` |
| Pick a session | `claude --resume` |
| Resume by name | `claude --resume auth-refactor` |
| Resume from PR | `claude --from-pr 123` |
| Name a session | `/rename auth-refactor` or `claude -n auth-refactor` |

**Session picker shortcuts** (`/resume` or `claude --resume`):

| Key | Action |
|:----|:-------|
| `P` | Preview session |
| `R` | Rename session |
| `/` | Search/filter |
| `A` | Toggle current directory / all projects |
| `B` | Filter to current git branch |

### Course Correction Rules

- After 2 failed corrections in one session: `/clear` and write a better initial prompt
- Use `/clear` between unrelated tasks
- For investigation: scope narrowly or use subagents
- Checkpoints persist across sessions; close terminal and rewind later

### Parallel Execution

| Approach | Best for |
|:---------|:---------|
| **Desktop app** | Multiple local sessions with isolated worktrees |
| **Claude Code on the web** | Cloud VMs on Anthropic infrastructure |
| **Agent teams** | Automated coordination with shared tasks and messaging |
| **Writer/Reviewer pattern** | One session implements, another reviews with fresh context |

### Git Worktrees

| Action | Command |
|:-------|:--------|
| Start Claude in a named worktree | `claude --worktree feature-auth` |
| Auto-generated name | `claude --worktree` |
| Subagent worktrees | `isolation: worktree` in agent frontmatter |
| Copy gitignored files | Add `.worktreeinclude` to project root (`.gitignore` syntax) |

Worktrees are created at `<repo>/.claude/worktrees/<name>` with branch `worktree-<name>`. Cleanup is automatic when no changes exist; Claude prompts to keep or remove when changes are present. Add `.claude/worktrees/` to `.gitignore`. For non-git VCS, configure WorktreeCreate/WorktreeRemove hooks.

### Fan-Out Pattern

```
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

Test on 2-3 files first, then run at scale. Use `--allowedTools` to scope what Claude can do unattended. Add `--verbose` for debugging, remove in production.

### Non-Interactive Mode

| Usage | Command |
|:------|:--------|
| One-off query | `claude -p "Explain what this project does"` |
| JSON output | `claude -p "List all API endpoints" --output-format json` |
| Streaming JSON | `claude -p "Analyze this log file" --output-format stream-json` |
| Auto mode (no prompts) | `claude --permission-mode auto -p "fix all lint errors"` |
| Pipeline integration | `claude -p "<prompt>" --output-format json \| your_command` |

### Scheduled Tasks

| Option | Where it runs | Best for |
|:-------|:-------------|:---------|
| Cloud scheduled tasks | Anthropic infrastructure | Tasks that run when your machine is off |
| Desktop scheduled tasks | Local machine via desktop app | Tasks needing local files/tools |
| GitHub Actions | CI pipeline | Repo events, cron schedules |
| `/loop` | Current CLI session | Quick polling while session is open |

### Extended Thinking

Enabled by default. Opus 4.6 and Sonnet 4.6 use adaptive reasoning -- dynamically allocating thinking tokens based on effort level.

| Control | How |
|:--------|:----|
| Adjust effort | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in your prompt |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` to toggle thinking mode |
| Limit budget | `MAX_THINKING_TOKENS` env var (on Opus 4.6/Sonnet 4.6 only `0` applies unless adaptive reasoning is disabled) |
| View reasoning | `Ctrl+O` for verbose mode (gray italic text) |

### Desktop Notifications

Add a `Notification` hook to `~/.claude/settings.json`:

**macOS:** `osascript -e 'display notification "Claude Code needs your attention" with title "Claude Code"'`
**Linux:** `notify-send 'Claude Code' 'Claude Code needs your attention'`

**Matcher options:** `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` (empty string matches all).

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| **Kitchen sink session** -- mixing unrelated tasks | `/clear` between tasks |
| **Over-correction** -- repeated failed fixes | After 2 failures, `/clear` and rewrite the prompt |
| **Over-specified CLAUDE.md** -- rules get lost in noise | Prune ruthlessly; convert working defaults to hooks |
| **Trust-then-verify gap** -- plausible but broken code | Always provide verification (tests, scripts, screenshots) |
| **Infinite exploration** -- Claude reads hundreds of files | Scope narrowly or use subagents |

### Common Workflow Recipes

| Workflow | Key prompts |
|:---------|:------------|
| **Codebase overview** | "give me an overview of this codebase" then narrow down |
| **Find relevant code** | "find the files that handle user authentication" |
| **Bug fixing** | Share the error, ask for fix recommendations, apply and verify |
| **Refactoring** | Find deprecated usage, get recommendations, apply safely, run tests |
| **Testing** | Find untested code, generate scaffolding, add edge cases, run and verify |
| **Pull requests** | Summarize changes, "create a pr", enhance description |
| **Documentation** | Find undocumented code, generate docs, verify standards |
| **Images** | Drag/drop or paste images; analyze screenshots, mockups, diagrams |
| **Subagents** | "use subagents to investigate X" or "/agents" to create custom ones |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) -- context window management, verification-first development (tests, screenshots, Chrome extension), explore-plan-implement-commit workflow (Plan Mode, Ctrl+G plan editing), effective prompting (scoping tasks, referencing sources, pointing to patterns, describing symptoms), rich content input (@ file references, images, URLs, piping, MCP), CLAUDE.md configuration (placement hierarchy, @imports, /init, include/exclude guidance, emphasis tuning, pruning), permission configuration (auto mode, allowlists, sandboxing), CLI tools (gh, aws, gcloud, sentry-cli, learning new tools), MCP servers, hooks, skills, subagents, plugins, communication patterns (codebase questions, interview-driven development with AskUserQuestion), session management (Esc, rewind, /clear, /compact, /btw, subagent delegation, checkpoints, --continue/--resume), parallel sessions (desktop app, web, agent teams, writer/reviewer pattern), fan-out (claude -p loops, --allowedTools, --output-format), auto mode for unattended execution, common failure patterns, developing intuition
- [Common Workflows](references/claude-code-common-workflows.md) -- step-by-step guides for codebase exploration (overview, finding relevant code), bug fixing (share error, get recommendations, apply fix), refactoring (find deprecated usage, modernize, verify), subagent usage (/agents, automatic delegation, explicit requests, custom creation), Plan Mode (Shift+Tab toggle, --permission-mode plan, headless queries, Ctrl+G, plan-based session naming, default mode config), testing (find untested code, generate scaffolding, edge cases, run and verify), pull requests (summarize, create, enhance), documentation (find undocumented code, generate, review, verify), images (drag/drop, paste, analyze, code from mockups), file and directory references (@ syntax, MCP resources), extended thinking (adaptive reasoning, effort level, ultrathink, Option+T/Alt+T toggle, MAX_THINKING_TOKENS, verbose mode, adaptive vs fixed budget), session resumption (--continue, --resume, --from-pr, /rename, session picker with P/R/A/B shortcuts), git worktrees (--worktree flag, .worktreeinclude, subagent worktrees, cleanup, manual management, non-git VCS hooks), desktop notifications (Notification hook, platform commands, matcher options), Unix-style usage (build script integration, piping, output format control), scheduled tasks (cloud/desktop/GitHub Actions//loop), asking Claude about its capabilities

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
