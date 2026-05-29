---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices — prompting patterns, context management, CLAUDE.md authoring, verification, parallel sessions, non-interactive mode, large codebases, ultraplan, ultrareview, and dynamic workflows.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, large-codebase configuration, ultraplan, ultrareview, and dynamic workflows.

## Quick Reference

### Core Principle: Context Window is the Primary Constraint

LLM performance degrades as the context window fills. Manage it aggressively:

| Signal | Action |
| :--- | :--- |
| Unrelated tasks in same session | `/clear` between tasks |
| Two failed corrections on the same issue | `/clear`, write a better initial prompt |
| Long exploratory file reads | Use a subagent — keeps reads out of main context |
| CLAUDE.md too long | Prune ruthlessly; Claude ignores rules buried in noise |

### Explore → Plan → Code → Commit Workflow

| Phase | Mode | Key action |
| :--- | :--- | :--- |
| Explore | Plan mode (`Shift+Tab` or `--permission-mode plan`) | Read files; no edits |
| Plan | Plan mode | `Ctrl+G` to open plan in editor; review before proceeding |
| Implement | Default mode | Code against the plan; run tests inline |
| Commit | Default mode | `commit with a descriptive message and open a PR` |

Skip the plan when the diff fits in one sentence.

### Give Claude a Verifiable Check

| Approach | Setup | When to use |
| :--- | :--- | :--- |
| Inline in prompt | `run the tests after implementing` | Any task today |
| `/goal` condition | Set pass/fail criteria; evaluator re-checks each turn | Unattended sessions |
| Stop hook | Script blocks turn from ending until check passes | Deterministic gate |
| Verification subagent | Fresh model tries to refute the result | High-stakes tasks |

Always ask Claude to show evidence (test output, command result, screenshot), not just assert success.

### Prompting Patterns

| Pattern | Vague | Specific |
| :--- | :--- | :--- |
| Tests | `add tests for foo.py` | `write a test for foo.py covering the logged-out edge case. avoid mocks.` |
| Bug fix | `fix the login bug` | `users report login fails after session timeout. check src/auth/ token refresh. write a failing test, then fix it` |
| New feature | `add a calendar widget` | `look at HotDogWidget.php as a pattern. implement a calendar widget with month select and year pagination` |
| Root cause | `fix the build` | `build fails with [error]. fix it and verify the build succeeds. address the root cause, don't suppress the error` |

### Rich Context Input

- `@path/to/file` — include file contents before Claude responds
- Paste images — drag/drop or `Ctrl+V` for screenshots, mockups, diagrams
- Pipe data — `cat error.log | claude` sends file contents directly
- Give URLs — use `/permissions` to allowlist frequently-used domains

### CLAUDE.md: What to Include vs. Exclude

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude infers from code |
| Code style rules that differ from defaults | Standard language conventions |
| Test runners and testing instructions | Detailed API docs (link instead) |
| Branch naming, PR conventions | Information that changes frequently |
| Developer environment quirks, required env vars | Long explanations or tutorials |
| Common gotchas and non-obvious behaviors | File-by-file codebase descriptions |

- Run `/init` to generate a starter CLAUDE.md
- Import sub-files with `@path/to/file` syntax
- Locations: `~/.claude/CLAUDE.md` (all sessions), `./CLAUDE.md` (project, commit to git), `./CLAUDE.local.md` (personal, gitignored), parent/child directories
- Add emphasis (`IMPORTANT`, `YOU MUST`) for critical rules
- Keep it concise: if removing a line wouldn't cause Claude to make mistakes, cut it

### Session Management Commands

| Command | Effect |
| :--- | :--- |
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc Esc` or `/rewind` | Open rewind menu; restore conversation and/or code to checkpoint |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact with focus guidance |
| `/btw <question>` | Side question — answer appears in overlay, never enters context |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Choose from session list |
| `/rename <name>` | Name the current session |

### Parallel and Automated Sessions

| Approach | Use when |
| :--- | :--- |
| `claude -p "prompt"` | CI, pre-commit hooks, scripts |
| `--output-format stream-json --verbose` | Streaming JSON for programmatic parsing |
| Worktrees (`claude --worktree <name>`) | Parallel isolated git checkouts |
| Writer/Reviewer pattern (two sessions) | Independent code review without bias |
| Fan-out loop (`for file in ...; do claude -p ...`) | Large migrations across many files |
| `--permission-mode auto` | Unattended runs with classifier safety check |

Auto mode aborts on repeated classifier blocks in `-p` mode since there is no user to fall back to.

### Common Failure Patterns

| Anti-pattern | Fix |
| :--- | :--- |
| Kitchen-sink session (mixing unrelated tasks) | `/clear` between tasks |
| Correcting the same mistake repeatedly | After two failures, `/clear` and write a better prompt |
| Over-specified CLAUDE.md | Prune; convert stable behaviors to hooks |
| Trust-then-verify gap (no check) | Always provide a verification mechanism |
| Infinite exploration (unscoped "investigate") | Scope narrowly or delegate to a subagent |

---

### Large Codebases: Settings Reference

| Goal | Setting / approach |
| :--- | :--- |
| Load only relevant conventions | Per-directory `CLAUDE.md` files |
| Exclude other teams' CLAUDE.md files | `claudeMdExcludes` in `.claude/settings.local.json` |
| Block reads of dist/build/vendor | `Read` deny rules in `permissions.deny` |
| Jump to definitions without scanning files | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktrees (faster, smaller checkouts) | `worktree.sparsePaths` in `.claude/settings.json` |
| Avoid duplicating `node_modules` in worktrees | `worktree.symlinkDirectories` |
| Access sibling package without restarting | `additionalDirectories` in settings, or `--add-dir` flag at launch |
| Per-subsystem skills loaded on demand | `.claude/skills/` inside each subdirectory |

`claudeMdExcludes` pattern examples:
- `"**/packages/admin-dashboard/**"` — exclude one package
- `"**/packages/*/CLAUDE.md"` — exclude all package files, keep root

Per-directory CLAUDE.md vs. path-scoped rules:

| Approach | File location | Loads when |
| :--- | :--- | :--- |
| Per-directory `CLAUDE.md` | Inside the directory | At launch (if started there) or on demand when Claude reads a file there |
| Path-scoped rule in `.claude/rules/` | Central `.claude/` at root | When Claude works with a file matching the rule's `paths:` glob |

Starting directory matters: project `.claude/settings.json` loads only from the starting directory; CLAUDE.md files load from starting dir and all parents.

---

### Ultraplan

Launch from the CLI to draft a plan in a cloud Claude Code on the web session while your terminal stays free.

| Launch method | How |
| :--- | :--- |
| Command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` in any prompt |
| From local plan | Choose "Refine with Ultraplan" in the plan approval dialog |

Status indicators shown in CLI prompt:

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Drafting in progress |
| `◇ ultraplan needs your input` | Open the session link to answer a clarifying question |
| `◆ ultraplan ready` | Plan ready to review in browser |

Execution choices after browser review:
- **Approve and start coding** — implements in the same cloud session; create a PR from the web interface
- **Approve and teleport back to terminal** — implement locally; web session is archived
  - Sub-choices: **Implement here**, **Start new session**, **Cancel** (saves plan to file)

Requires Claude Code on the web account and a GitHub repository. Not available on Amazon Bedrock, Google Cloud Vertex AI, or Microsoft Foundry.

---

### Ultrareview (`/code-review ultra`)

Deep, multi-agent code review running remotely in a cloud sandbox.

```text
/code-review ultra          # review diff against default branch
/code-review ultra 1234     # review a GitHub PR by number
```

Non-interactive (CI/scripts):
```bash
claude ultrareview
claude ultrareview 1234
claude ultrareview origin/main
```

| Flag | Description |
| :--- | :--- |
| `--json` | Print raw `bugs.json` payload |
| `--timeout <minutes>` | Max wait time (default 30) |

Pricing:

| Plan | Free runs | After free runs |
| :--- | :--- | :--- |
| Pro / Max | 3 (one-time, non-refreshing) | Usage credits (~$5–$20/review) |
| Team / Enterprise | None | Usage credits (~$5–$20/review) |

`/review` vs. `/code-review ultra`:

| | `/review` | `/code-review ultra` |
| :--- | :--- | :--- |
| Runs | Locally | Remotely in cloud sandbox |
| Depth | Single-pass | Multi-agent with independent verification |
| Duration | Seconds–minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 |
| Best for | Fast feedback while iterating | Pre-merge confidence on substantial changes |

Not available on Bedrock, Vertex AI, Microsoft Foundry, or orgs with Zero Data Retention enabled.

---

### Dynamic Workflows

JavaScript scripts that orchestrate subagents at scale. Claude writes the script; the runtime executes it in the background.

| | Subagents | Skills | Workflows |
| :--- | :--- | :--- | :--- |
| Who decides next step | Claude, turn by turn | Claude, following prompt | The script |
| Intermediate results | Claude's context | Claude's context | Script variables |
| Scale | Few delegated tasks | Same | Dozens–hundreds of agents |
| Interruption | Restarts the turn | Restarts the turn | Resumable in same session |

**Bundled workflow:** `/deep-research <question>` — fans out web searches, cross-checks sources, returns a cited report.

Triggering a workflow:
- Include the word `workflow` anywhere in a prompt
- `/effort ultracode` — Claude plans a workflow for every substantive task in the session
- Run a saved command: `/<saved-workflow-name>`

Save a workflow for reuse: run `/workflows`, select the run, press `s`.

Runtime constraints:

| Constraint | Value |
| :--- | :--- |
| Max concurrent agents | 16 (fewer on limited CPUs) |
| Max agents per run | 1,000 |
| Mid-run user input | Not supported; use permission prompts only |
| Direct filesystem/shell from script | Not allowed; agents do file I/O |

Disable workflows:
- Toggle in `/config`
- `"disableWorkflows": true` in `~/.claude/settings.json`
- `CLAUDE_CODE_DISABLE_WORKFLOWS=1` env var

Requires Claude Code v2.1.154 or later. Available on all paid plans including Bedrock, Vertex AI, and Microsoft Foundry. On Pro, enable from the Dynamic workflows row in `/config`.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, explore/plan/code workflow, prompting patterns, CLAUDE.md authoring, permissions, skills, subagents, parallel sessions, failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — prompt recipes for codebase exploration, bug fixing, refactoring, tests, PRs, documentation, images, scheduled tasks, worktrees, subagent delegation, piping Claude into scripts
- [Set up Claude Code in a monorepo or large codebase](references/claude-code-large-codebases.md) — per-directory CLAUDE.md, claudeMdExcludes, Read deny rules, code intelligence plugins, sparse worktrees, additionalDirectories, per-directory skills, plugin-based centralization
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching ultraplan, reviewing and revising a plan in the browser, executing on the web or teleporting back to terminal
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — running `/code-review ultra`, PR mode, pricing and free runs, tracking a running review, non-interactive `claude ultrareview` subcommand, comparison with `/review`
- [Orchestrate subagents at scale with dynamic workflows](references/claude-code-workflows.md) — when to use workflows, bundled `/deep-research`, asking Claude to write a workflow, ultracode effort level, approval flow, saving workflows, runtime constraints, managing and resuming runs, disabling workflows

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Set up Claude Code in a monorepo or large codebase: https://code.claude.com/docs/en/large-codebases.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Orchestrate subagents at scale with dynamic workflows: https://code.claude.com/docs/en/workflows.md
