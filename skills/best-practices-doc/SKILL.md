---
name: best-practices-doc
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, large codebase configuration, dynamic workflows, ultraplan, and ultrareview.

## Quick Reference

### Core Best Practices Summary

| Practice | Key Rule |
| :--- | :--- |
| **Verify work** | Give Claude a runnable check (tests, build, script, screenshot) so the loop closes automatically |
| **Explore → Plan → Code** | Use plan mode to separate research from implementation before touching any files |
| **Specific prompts** | Reference exact files, name constraints, point to patterns — the more precise, the fewer corrections |
| **Manage context** | `/clear` between unrelated tasks; use `/compact` to summarize; context fills fast and degrades performance |
| **Course-correct early** | `Esc` to stop, `Esc Esc` / `/rewind` to checkpoint-restore, `/clear` after two failed corrections |
| **Subagents for research** | Delegate file exploration to subagents — they run in a separate context so reads don't fill yours |
| **Automate with non-interactive** | `claude -p "prompt"` for CI / scripts; `--output-format stream-json --verbose` for structured output |

### Verification Strategies

| Method | Setup effort | When to use |
| :--- | :--- | :--- |
| In-prompt check | None | One-off task; ask Claude to run and iterate in the same message |
| `/goal` condition | Low | Evaluator re-checks after every turn until the condition holds |
| `Stop` hook | Medium | Deterministic gate; runs a script and blocks turn-end until it passes (8-block cap) |
| Verification subagent | Medium | Fresh context reviews output independently; avoids self-grading bias |

### Explore → Plan → Implement Workflow

1. Enter plan mode (`Shift+Tab` or `--permission-mode plan`) — Claude reads, does not edit
2. Ask Claude to create a detailed implementation plan; `Ctrl+G` to open and edit it
3. Exit plan mode and implement — Claude codes against its plan, runs tests, fixes failures
4. Commit with a descriptive message and open a PR

### CLAUDE.md Quick Rules

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Things Claude infers from code |
| Code style that differs from defaults | Standard conventions already known |
| Test runner instructions | Detailed API docs (link instead) |
| Repo etiquette (branch/PR conventions) | Info that changes frequently |
| Non-obvious dev environment quirks | File-by-file codebase descriptions |

- Place at `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project, commit to git), `./CLAUDE.local.md` (personal, gitignored), or subdirectories
- Import other files with `@path/to/file` syntax
- Keep short — bloated files cause important rules to be ignored
- Emphasize critical rules with "IMPORTANT" or "YOU MUST"

### Permission Reduction Options

| Method | Description |
| :--- | :--- |
| Auto mode (`--permission-mode auto`) | Classifier reviews commands; blocks only scope escalation, unknown infra, hostile-content actions |
| Permission allowlists (`/permissions`) | Permit specific safe tools like `npm run lint` or `git commit` |
| Sandboxing (`/sandbox`) | OS-level isolation restricts filesystem and network access |

### Context Management Commands

| Command | Effect |
| :--- | :--- |
| `/clear` | Reset context window entirely |
| `/compact <instructions>` | Summarize and compress conversation with custom focus |
| `Esc Esc` or `/rewind` | Open rewind menu — restore conversation, code, or both from any checkpoint |
| `/btw` | Ask a side question in a dismissible overlay; never enters conversation history |
| `claude --continue` | Resume the most recent session in current directory |
| `claude --resume` | Choose from a list of saved sessions |

### Parallel and Scale Patterns

| Pattern | How |
| :--- | :--- |
| Worktrees | `claude --worktree <name>` — isolated git checkout per session, no edit collisions |
| Writer/Reviewer | Session A implements; Session B reviews diff in fresh context |
| Fan-out script | Loop `claude -p "..."` over a file list; `--allowedTools` to scope permissions |
| Auto mode unattended | `claude --permission-mode auto -p "..."` — classifier handles approvals, aborts on repeated blocks |
| Non-interactive | `claude -p "prompt" --output-format json` — pipe into scripts or CI |

### Common Failure Patterns to Avoid

| Failure | Fix |
| :--- | :--- |
| Kitchen-sink session (mixing unrelated tasks) | `/clear` between tasks |
| Correcting the same mistake repeatedly | After two corrections, `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md (rules get lost) | Ruthlessly prune; convert redundant rules to hooks |
| Trust-then-verify gap (no check given) | Always provide runnable verification — tests, scripts, or screenshots |
| Infinite exploration (reading hundreds of files) | Scope investigations narrowly or use subagents |

### Common Workflows (Prompt Recipes)

| Task | Key prompts |
| :--- | :--- |
| Codebase overview | `"give me an overview of this codebase"` → `"explain the main architecture patterns"` |
| Fix bugs | Share error + reproduction steps → `"suggest fixes"` → `"apply fix and run tests"` |
| Refactor | `"find deprecated API usage"` → `"suggest refactoring"` → `"refactor and run tests"` |
| Write tests | `"find untested functions in X"` → `"add tests for edge cases"` → `"run and fix failures"` |
| Create PR | `"summarize changes"` → `"create a pr"` → `"enhance description"` |
| Schedule tasks | Routines (cloud), desktop scheduled tasks (local), GitHub Actions (CI), `/loop` (current session) |

### Dynamic Workflows

Dynamic workflows are JavaScript scripts that orchestrate many subagents (up to 1,000 agents, 16 concurrent). They run in the background; your session stays responsive.

| Trigger | How |
| :--- | :--- |
| Keyword in prompt | Include `ultracode` in your message, or say "use a workflow" |
| Session-wide | `/effort ultracode` — Claude plans a workflow for every substantive task |
| Saved command | Press `s` in `/workflows` view to save a run as a reusable `/<name>` command |
| Bundled command | `/deep-research <question>` — fans out web searches, cross-checks, returns cited report |

Manage runs with `/workflows`: arrow keys to select, Enter/→ to drill in, `p` to pause/resume, `x` to stop, `r` to restart an agent.

### Ultraplan

Ultraplan hands a planning task to a cloud session in plan mode. Your terminal stays free.

| Status indicator | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is researching and drafting the plan |
| `◇ ultraplan needs your input` | Clarifying question — open the session link |
| `◆ ultraplan ready` | Plan is ready to review in your browser |

Launch with `/ultraplan <prompt>`, or include the word `ultraplan` in a normal prompt. Review in the browser with inline comments and emoji reactions. On approval, choose **Execute on the web** or **Approve plan and teleport back to terminal**.

Not available on Amazon Bedrock, Google Cloud Vertex AI, or Microsoft Foundry. Requires a GitHub repository and Claude Code on the web account.

### Ultrareview (`/code-review ultra`)

Deep multi-agent code review running in a remote cloud sandbox. Reports only independently verified bugs.

| Comparison | `/review` | `/code-review ultra` |
| :--- | :--- | :--- |
| Runs | Locally in your session | Remotely in cloud sandbox |
| Depth | Single-pass | Multi-agent fleet with independent verification |
| Duration | Seconds to minutes | 5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 per review as usage credits |
| Best for | Quick feedback while iterating | Pre-merge confidence on substantial changes |

```
/code-review ultra          # reviews branch diff vs default branch
/code-review ultra 1234     # reviews GitHub PR #1234
claude ultrareview          # non-interactive, blocks until done, exits 0/1
```

Pro and Max: 3 free runs, then usage credits. Team and Enterprise: usage credits from the start. Not available on Bedrock, Vertex AI, Foundry, or with Zero Data Retention.

### Large Codebases and Monorepos

| Goal | Setting / Approach |
| :--- | :--- |
| Per-directory instructions | Per-directory `CLAUDE.md` files (loaded on demand) |
| Exclude irrelevant CLAUDE.md files | `claudeMdExcludes` in `.claude/settings.local.json` (glob patterns) |
| Block reads of generated/vendored code | `Read` deny rules in `permissions.deny` |
| Fast symbol lookup instead of file scanning | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktree checkout | `worktree.sparsePaths` in `.claude/settings.json` |
| Grant sibling package access | `additionalDirectories` in `.claude/settings.json` or `--add-dir` at launch |
| Per-subsystem skills | `.claude/skills/` inside each subdirectory |

Start Claude from a **subdirectory** when work is scoped to one package (loads only that package's CLAUDE.md plus ancestors). Start from **repository root** when the task spans packages (loads all CLAUDE.md files on demand as files are read).

Cross-package changes: give Claude the full change in one session; save the plan to a file before editing so it survives context compaction.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — Core patterns: verification, explore/plan/code, prompting, CLAUDE.md, permissions, session management, scaling, and common failures
- [Common workflows](references/claude-code-common-workflows.md) — Prompt recipes for everyday tasks: codebase exploration, bug fixes, refactoring, tests, PRs, documentation, images, scheduling, and piping into scripts
- [Dynamic workflows](references/claude-code-workflows.md) — Orchestrating many subagents from a script; bundled `/deep-research`; saving, managing, and resuming runs; ultracode keyword and effort level
- [Ultraplan](references/claude-code-ultraplan.md) — Cloud-based planning: launching, reviewing in browser with inline comments, approving to execute on web or teleport back to terminal
- [Ultrareview (find bugs)](references/claude-code-ultrareview.md) — Multi-agent pre-merge code review in a remote sandbox; pricing, non-interactive `claude ultrareview` subcommand, comparison with local `/review`
- [Large codebases and monorepos](references/claude-code-large-codebases.md) — Per-directory CLAUDE.md, claudeMdExcludes, Read deny rules, code intelligence plugins, sparse worktrees, additionalDirectories, per-directory skills

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Dynamic workflows: https://code.claude.com/docs/en/workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Large codebases and monorepos: https://code.claude.com/docs/en/large-codebases.md
