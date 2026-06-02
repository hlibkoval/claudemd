---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices — context management, verification strategies, prompting, CLAUDE.md authoring, session control, parallelism, large codebase configuration, ultraplan, ultrareview, and dynamic workflows.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, large-codebase configuration, ultraplan, ultrareview, and dynamic workflows.

## Quick Reference

### Core Constraint: Context Window

Everything in the conversation — messages, file reads, command output — consumes context. Performance degrades as it fills. Most best practices flow from this single constraint.

### Give Claude a Verification Signal

| Approach | When |
| :--- | :--- |
| Ask Claude to run tests or build and iterate in the same prompt | Simple, any task |
| `/goal` condition — evaluator re-checks after every turn | Longer unattended runs |
| `Stop` hook — script blocks the turn until check passes (max 8 blocks) | Deterministic gate |
| Verification subagent with fresh context | Independent second opinion |

Always ask Claude to show evidence (test output, screenshots) rather than asserting success.

### Explore → Plan → Code Workflow

1. **Explore** — enter plan mode (`Shift+Tab` or `--permission-mode plan`); Claude reads files without editing.
2. **Plan** — ask for a detailed implementation plan; press `Ctrl+G` to edit the plan in your editor.
3. **Implement** — exit plan mode; Claude codes against the plan and runs tests.
4. **Commit** — ask Claude to commit and open a PR.

Skip planning for single-file changes you can describe in one sentence.

### Prompting Tips

| Strategy | Instead of | Try |
| :--- | :--- | :--- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case; avoid mocks" |
| Point to sources | "why does ExecutionFactory have a weird API?" | "look through ExecutionFactory's git history and summarize how its API came to be" |
| Reference existing patterns | "add a calendar widget" | "look at HotDogWidget.php to understand patterns, then implement a calendar widget the same way" |
| Describe the symptom | "fix the login bug" | "users report login fails after session timeout; check src/auth/ token refresh; write a failing test then fix it" |

Rich context methods: `@file` references, paste images directly, give URLs, pipe data with `cat error.log | claude`.

### Writing an Effective CLAUDE.md

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to the project | Long explanations or tutorials |
| Developer environment quirks / required env vars | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

CLAUDE.md locations (all merge; broadest → most specific):

| Location | Scope |
| :--- | :--- |
| `~/.claude/CLAUDE.md` | All sessions |
| `./CLAUDE.md` | Project (check into git) |
| `./CLAUDE.local.md` | Personal project notes (gitignore) |
| Parent directories | Monorepo root conventions |
| Child directories | Loaded on demand when Claude reads files there |

Import additional files with `@path/to/file` syntax inside CLAUDE.md.

Keep it short — if removing a line wouldn't cause Claude to make mistakes, cut it. Add emphasis (`IMPORTANT`, `YOU MUST`) for rules that must stick.

### Permission Modes

| Mode | Best for |
| :--- | :--- |
| Default | Normal interactive work with approval prompts |
| Plan mode (`--permission-mode plan`) | Review changes before they touch disk |
| Auto mode (`--permission-mode auto`) | Unattended runs; classifier blocks risky actions |
| Allowlists (`/permissions`) | Permit specific safe commands permanently |
| Sandboxing | OS-level isolation for untrusted tasks |

### Extending Claude Code

| Tool | When |
| :--- | :--- |
| CLI tools (`gh`, `aws`, `gcloud`) | Most context-efficient way to hit external services |
| MCP servers (`claude mcp add`) | Notion, Figma, databases, monitoring |
| Hooks | Deterministic side effects (lint, format, block writes) |
| Skills | Domain knowledge and reusable workflows loaded on demand |
| Subagents (`.claude/agents/`) | Isolated tasks with restricted tools and fresh context |
| Plugins (`/plugin`) | Bundled skills + hooks + MCP from the marketplace |

### Session Management

| Action | Command / Key |
| :--- | :--- |
| Stop Claude mid-action | `Esc` |
| Rewind conversation and code | `Esc Esc` or `/rewind` |
| Reset context between tasks | `/clear` |
| Compact with focus | `/compact Focus on the API changes` |
| Side question (no history) | `/btw <question>` |
| Resume most recent session | `claude --continue` |
| Pick session to resume | `claude --resume` or `/resume` |
| Resume a PR-linked session | `claude --from-pr <number>` |
| Name current session | `/rename` |

Run `/clear` after two failed corrections on the same issue — start fresh with a better prompt.

### Using Subagents for Investigation

Delegate research with "use subagents to investigate X". Subagents explore in separate context windows and report back summaries, keeping your main conversation clean.

### Common Failure Patterns

| Pattern | Fix |
| :--- | :--- |
| Kitchen-sink session (unrelated tasks mixed) | `/clear` between unrelated tasks |
| Correcting the same issue repeatedly | After two failures, `/clear` and write a sharper prompt |
| Over-specified CLAUDE.md (rules get lost) | Ruthlessly prune; convert to hooks what needs guaranteeing |
| Trust-then-verify gap (no test/screenshot) | Always supply a verification check |
| Infinite exploration (Claude reads hundreds of files) | Scope narrowly or delegate to a subagent |

### Parallelism and Automation

| Approach | Use when |
| :--- | :--- |
| `claude -p "prompt"` | CI, scripts, pre-commit hooks |
| `--output-format json` / `stream-json` | Parsing results programmatically |
| Worktrees (`claude --worktree <name>`) | Parallel sessions without colliding edits |
| Agent teams | Automated multi-session coordination |
| Looping `claude -p` with `--allowedTools` | Large migrations across many files |
| `--permission-mode auto` with `-p` | Uninterrupted non-interactive runs |
| Writer/Reviewer pattern (two sessions) | Fresh-context code review |

### Scheduling Tasks

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Routines | Anthropic-managed infrastructure | Tasks that should run even when your computer is off; can trigger on API calls or GitHub events |
| Desktop scheduled tasks | Your machine, via desktop app | Tasks needing local file access or uncommitted changes |
| GitHub Actions | CI pipeline | Tasks tied to repo events (opened PRs) or cron schedules |
| `/loop` | Current CLI session | Quick polling while the session is open |

For autonomous scheduled tasks: be explicit about what success looks like and what to do with results. The task can't ask clarifying questions.

### Common Workflow Recipes

| Task | Prompt pattern |
| :--- | :--- |
| Codebase overview | "give me an overview of this codebase" → "explain the main architecture patterns" |
| Fix a bug | Share the error, ask for fix recommendations, apply the fix, verify |
| Refactor code | Identify legacy code, get recommendations, apply changes, run tests |
| Write tests | Find untested code, generate scaffolding, add edge cases, run and fix |
| Create a PR | "create a pr for my changes"; when created with `gh pr create`, use `claude --from-pr <number>` to return |
| Add documentation | Find undocumented code, generate docs, review and enhance |
| Resume a session | `claude --continue` (most recent) or `claude --resume` (picker) |
| Run in parallel | `claude --worktree feature-auth` in separate terminals |
| Pipe into scripts | `git log --oneline -20 \| claude -p "summarize these recent commits"` |

### Large Codebase / Monorepo Settings

| Goal | Setting / Mechanism |
| :--- | :--- |
| Load only relevant conventions | Per-directory `CLAUDE.md` files (load at launch or on demand) |
| Skip other teams' CLAUDE.md files | `claudeMdExcludes` in `.claude/settings.local.json` |
| Block reads of build output and vendored code | `Read` deny rules in `permissions.deny` |
| Fast symbol navigation without file scans | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Lightweight worktrees | `worktree.sparsePaths` in `.claude/settings.json` |
| Avoid duplicating `node_modules` | `worktree.symlinkDirectories` |
| Access sibling packages | `additionalDirectories` (settings) or `--add-dir` (runtime) |
| Load CLAUDE.md from `--add-dir` directories | Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` env var |
| Per-area skills that load on demand | `.claude/skills/` inside each subdirectory |
| Recommend plugins at session start | `SessionStart` hook that reads launch directory and prints recommendations |

**Per-directory CLAUDE.md vs. path-scoped rules:**

| Approach | File location | Loads when | Use when |
| :--- | :--- | :--- | :--- |
| Per-directory `CLAUDE.md` | Inside the directory, alongside code | At launch or on demand when Claude reads a file there | Directory owners maintain own conventions |
| Path-scoped rule in `.claude/rules/` | Central `.claude/` at repo root | When Claude works with files matching the rule's `paths:` glob | Conventions in one place, or rule applies to scattered paths |

Start Claude from a subdirectory to scope CLAUDE.md loading and file access to that area. Project settings in `.claude/settings.json` load only from the starting directory — not inherited from parents.

When skills grow large across many directories, discover usage with the `skill_activated` event in OpenTelemetry logs (`OTEL_LOG_TOOL_DETAILS=1`).

### Ultraplan (Cloud Planning)

Launch with `/ultraplan <prompt>` or include the word `ultraplan` anywhere in a prompt, or choose **Refine with Ultraplan** from a local plan dialog.

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Open the session link to answer a question |
| `◆ ultraplan ready` | Plan is ready to review in your browser |

Browser review: inline comments on sections, emoji reactions, outline sidebar. On approval, choose **Execute on the web** or **Teleport back to terminal** (Implement here / Start new session / Cancel to file).

Requires a Claude Code on the web account and a GitHub repository. Not available on Bedrock, Vertex AI, or Foundry.

### Ultrareview (Cloud Code Review)

```text
/code-review ultra          # review current branch vs. default branch
/code-review ultra 1234     # review PR #1234
```

Non-interactive (CI/scripts):
```bash
claude ultrareview
claude ultrareview 1234
claude ultrareview origin/main
```

| | `/review` | `/code-review ultra` |
| :--- | :--- | :--- |
| Runs | locally | remotely in cloud sandbox |
| Depth | single-pass | multi-agent fleet with independent verification |
| Duration | seconds to a few minutes | 5 – 10 minutes |
| Cost | normal usage | 3 free runs, then ~$5–$20 per run as usage credits |
| Best for | fast feedback while iterating | pre-merge confidence on substantial changes |

Flags for non-interactive: `--json` (raw bugs.json), `--timeout <minutes>` (default 30). Exit codes: 0 = success, 1 = failure/timeout, 130 = Ctrl-C.

### Dynamic Workflows

Trigger: include the word `workflow` in a prompt, run `/effort ultracode`, or invoke a saved workflow command.

```text
Run a workflow to audit every API endpoint under src/routes/ for missing auth checks
```

Built-in workflow: `/deep-research <question>` — fans out web searches, cross-checks sources, returns a cited report.

| | Subagents | Skills | Agent teams | Workflows |
| :--- | :--- | :--- | :--- | :--- |
| Who decides next step | Claude, turn by turn | Claude following prompt | Lead agent | The script |
| Scale | A few per turn | Same | Handful of peers | Dozens to hundreds of agents |
| Intermediate results | Claude's context | Claude's context | Shared task list | Script variables |
| Repeatable | Worker definition | Instructions | Team definition | The orchestration itself |

Save a run for reuse: run `/workflows`, select the run, press `s`. Saved workflows appear as `/name` commands in autocomplete.

Manage runs with `/workflows`: Up/Down to select, Enter to drill in, `p` pause/resume, `x` stop, `r` restart agent, `s` save script.

Limits: up to 16 concurrent agents, 1,000 agents total per run. No mid-run user input except permission prompts.

Disable: toggle in `/config`, `"disableWorkflows": true` in `settings.json`, or `CLAUDE_CODE_DISABLE_WORKFLOWS=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, verification, explore-plan-code, prompting, CLAUDE.md authoring, permissions, session management, parallelism, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — prompt recipes for exploring code, fixing bugs, refactoring, tests, PRs, documentation, scheduling, piping Claude into scripts
- [Monorepos and large codebases](references/claude-code-large-codebases.md) — layered CLAUDE.md, claudeMdExcludes, Read deny rules, code intelligence plugins, sparse worktrees, additionalDirectories, per-directory skills, path-scoped rules
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching, status indicators, browser review and commenting, executing on the web vs. teleporting back to terminal
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — /code-review ultra, PR mode, pricing and free runs, non-interactive subcommand, comparison to /review
- [Dynamic workflows](references/claude-code-workflows.md) — when to use workflows vs. subagents/skills/agent teams, /deep-research, writing and saving workflows, approval flow, /workflows manager, limits and costs

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Monorepos and large codebases: https://code.claude.com/docs/en/large-codebases.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Dynamic workflows: https://code.claude.com/docs/en/workflows.md
