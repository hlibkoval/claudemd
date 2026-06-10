---
name: best-practices-doc
description: Best practices, common workflows, and advanced patterns for Claude Code including context management, parallel sessions, ultraplan, ultrareview, dynamic workflows, and large codebase setup.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, advanced features (ultraplan, ultrareview, dynamic workflows), and large codebase configuration.

## Quick Reference

### Core Constraint: Context Window

Context fills fast and performance degrades as it fills. Every file read, command output, and message consumes tokens. Managing context is the most important optimization.

| Signal | Action |
|---|---|
| Claude forgetting earlier instructions | Context is too full — `/clear` and start fresh |
| Corrected Claude 2+ times on same issue | `/clear` and write a more specific prompt |
| Exploring unfamiliar code | Use subagents so file reads stay out of main context |
| Unrelated tasks in one session | `/clear` between each task |

### Explore → Plan → Implement → Commit

| Phase | Mode | What to do |
|---|---|---|
| Explore | Plan mode (`Shift+Tab`) | Read files, answer questions, no edits |
| Plan | Plan mode | Ask for detailed implementation plan; `Ctrl+G` opens it in editor |
| Implement | Default mode | Code with verification (tests, build, lint) |
| Commit | Default mode | `git commit` with descriptive message, open PR |

Skip planning when: the diff fits in one sentence, fixing a typo, or the scope is completely clear.

### Prompting — Before vs. After

| Vague | Specific |
|---|---|
| "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| "fix the login bug" | "users report login fails after session timeout. check auth flow in src/auth/, write a failing test, then fix it" |
| "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot and compare. list differences and fix them" |

### Providing Context

- **`@file`** — include a file before responding
- **Paste images** — copy/paste or drag-and-drop screenshots/mockups
- **Pipe data** — `cat error.log | claude`
- **URLs** — give docs or API references; use `/permissions` to allowlist domains
- **Let Claude fetch** — "use `gh issue view` to get the issue, then fix it"

### Verification Strategies

| Approach | Setup | Use when |
|---|---|---|
| In-prompt check | Ask Claude to run tests/build in same message | Any task |
| `/goal` condition | Set a check; evaluator re-runs after every turn | Long sessions |
| Stop hook | Script blocks turn from ending until check passes | Unattended runs |
| Subagent reviewer | Fresh context reviews the diff, reports gaps | After substantial changes |

Always ask for evidence (test output, command result, screenshot) rather than assertions.

### Session Management

| Command / Action | Effect |
|---|---|
| `Esc` | Stop Claude mid-action, preserve context |
| `Esc Esc` or `/rewind` | Open checkpoint menu: restore conversation, code, or both |
| `/clear` | Reset context window entirely |
| `/compact <instructions>` | Compact with custom focus |
| `/btw` | Side question — answer shown in overlay, never enters context |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Choose from session list |
| `/rename` | Name the current session |

### CLAUDE.md — What to Include vs. Exclude

| Include | Exclude |
|---|---|
| Bash commands Claude can't guess | Things Claude figures out from reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks and required env vars | File-by-file codebase descriptions |
| Common gotchas and non-obvious behaviors | Self-evident practices like "write clean code" |

Import other files: `@path/to/file` syntax inside CLAUDE.md.

CLAUDE.md locations: `~/.claude/CLAUDE.md` (all sessions), `./CLAUDE.md` (project, commit to git), `./CLAUDE.local.md` (personal, gitignore it), parent/child directories (loaded on demand).

### Parallel & Automated Execution

| Pattern | How |
|---|---|
| Non-interactive / CI | `claude -p "prompt"` |
| Structured output | `--output-format json` or `--output-format stream-json --verbose` |
| Parallel worktrees | `claude --worktree <name>` in separate terminals |
| Fan-out over files | Loop calling `claude -p` with `--allowedTools` to scope permissions |
| Unattended with safety | `claude --permission-mode auto -p "..."` |
| Writer/Reviewer split | Session A implements; Session B reviews diff in fresh context |

### Common Failure Patterns

| Pattern | Fix |
|---|---|
| Kitchen sink session (unrelated tasks piling up) | `/clear` between tasks |
| Correcting over and over | After 2 failures, `/clear` and write a better prompt |
| Over-specified CLAUDE.md (rules get ignored) | Ruthlessly prune; convert always-true rules to hooks |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration filling context | Scope narrowly or use subagents |

---

### Ultraplan — Cloud-Based Planning

Launch from CLI:
- `/ultraplan <prompt>` — command form
- Include the word `ultraplan` in any prompt
- After a local plan: choose "No, refine with Ultraplan on Claude Code on the web"

| CLI Status | Meaning |
|---|---|
| `◇ ultraplan` | Drafting in the cloud |
| `◇ ultraplan needs your input` | Claude has a clarifying question; open the session link |
| `◆ ultraplan ready` | Ready to review in browser |

Review options in browser: inline comments on sections, emoji reactions, outline sidebar.

Execution choices: "Approve and start coding" (runs on web) or "Approve and teleport back to terminal" (runs locally with three sub-options: implement here, start new session, cancel/save to file).

Requires: Claude Code on the web account, GitHub repository. Not available on Bedrock/Vertex/Foundry.

---

### Ultrareview — Deep Cloud Code Review

| Command | What it reviews |
|---|---|
| `/code-review ultra` | Diff between current branch and default branch (including uncommitted changes) |
| `/code-review ultra 1234` | GitHub PR by number |
| `claude ultrareview` | Non-interactive / CI mode |
| `claude ultrareview 1234` | PR in CI mode |
| `claude ultrareview origin/main` | Diff against specific base branch |

| Plan | Free runs | After free runs |
|---|---|---|
| Pro / Max | 3 (one-time) | ~$5–$20 per run as usage credits |
| Team / Enterprise | 0 | ~$5–$20 per run as usage credits |

Duration: ~5–10 minutes. Runs in background; use `/tasks` to track. Each finding is independently verified by the agent fleet.

Non-interactive flags: `--json` (raw bugs.json), `--timeout <minutes>` (default 30).

`/review` vs `/code-review ultra`:

| | `/review` | `/code-review ultra` |
|---|---|---|
| Runs | Locally | Remote cloud sandbox |
| Depth | Single pass | Multi-agent with independent verification |
| Duration | Seconds to minutes | 5–10 minutes |
| Cost | Normal usage | Free runs then ~$5–$20 |
| Use when | Quick feedback while iterating | Pre-merge on substantial changes |

---

### Dynamic Workflows — Orchestrating Many Subagents

Trigger: include `ultracode` keyword in prompt, say "use a workflow", or run `/effort ultracode` for session-wide automatic orchestration.

Bundled workflow: `/deep-research <question>` — fans out web searches, cross-checks sources, returns a cited report.

| Feature | Value |
|---|---|
| Max concurrent agents | 16 (fewer on limited CPU) |
| Max agents per run | 1,000 |
| Intermediate results | In script variables, not Claude's context |
| Resume | Within the same session; fresh run if Claude Code exits |

`/workflows` — list and manage runs. Progress view keys:

| Key | Action |
|---|---|
| `↑` / `↓` | Select phase or agent |
| `Enter` / `→` | Drill into phase or agent |
| `Esc` | Back out one level |
| `p` | Pause / resume run |
| `x` | Stop selected agent or whole workflow |
| `r` | Restart selected running agent |
| `s` | Save run's script as a named command |

Save location: `.claude/workflows/` (project, shared) or `~/.claude/workflows/` (personal). Saved workflows appear as `/<name>` in autocomplete.

Disable: toggle in `/config`, set `"disableWorkflows": true` in settings.json, or `CLAUDE_CODE_DISABLE_WORKFLOWS=1`.

Approval prompt behavior:

| Permission mode | When prompted |
|---|---|
| Default / accept edits | Every run (unless "don't ask again" selected) |
| Auto | First launch only |
| Bypass / `claude -p` / Agent SDK | Never |

---

### Large Codebase & Monorepo Settings

| Goal | Setting / Approach |
|---|---|
| Load only relevant conventions | Per-directory CLAUDE.md files |
| Exclude other teams' CLAUDE.md files | `claudeMdExcludes` in settings (glob patterns, start with `**/`) |
| Block reads of build artifacts / vendored code | `Read` deny rules in `permissions.deny` |
| Symbol navigation without file scanning | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktree checkout | `worktree.sparsePaths` in settings.json |
| Access sibling packages | `additionalDirectories` in settings.json, or `--add-dir` at launch |
| Load CLAUDE.md from `--add-dir` directories | Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |
| Avoid duplicating node_modules across worktrees | `worktree.symlinkDirectories` |
| Per-area on-demand skills | `.claude/skills/` inside each subdirectory |

Starting directory determines which project settings and CLAUDE.md files load — project settings in `.claude/settings.json` are not inherited from parent directories.

`additionalDirectories` vs `--add-dir`:

| | `additionalDirectories` | `--add-dir` |
|---|---|---|
| Loads CLAUDE.md and rules | Never | Only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |
| Loads skills | Never | Yes |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — Context management, prompting patterns, CLAUDE.md, sessions, parallel execution, and common failure modes
- [Common workflows](references/claude-code-common-workflows.md) — Step-by-step recipes for exploring codebases, debugging, refactoring, tests, PRs, images, and scheduled tasks
- [Ultraplan](references/claude-code-ultraplan.md) — Cloud-based planning: launch from CLI, review in browser, execute on web or back in terminal
- [Ultrareview](references/claude-code-ultrareview.md) — Multi-agent cloud code review: commands, pricing, non-interactive mode, and comparison with local review
- [Dynamic workflows](references/claude-code-workflows.md) — Orchestrate subagents at scale with scripts; ultracode keyword, bundled `/deep-research`, run management
- [Monorepos and large codebases](references/claude-code-large-codebases.md) — Per-directory CLAUDE.md, claudeMdExcludes, Read deny rules, code intelligence, sparse worktrees, additionalDirectories, per-directory skills

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Dynamic workflows: https://code.claude.com/docs/en/workflows.md
- Monorepos and large codebases: https://code.claude.com/docs/en/large-codebases.md
