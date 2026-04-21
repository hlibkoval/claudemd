---
name: best-practices-doc
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and advanced cloud-based planning and review features.

## Quick Reference

### Core constraint: context window management

The context window fills fast — LLM performance degrades as it fills. Every file read, command output, and conversation turn consumes it. Managing context is the highest-leverage skill.

| Symptom | Fix |
| --- | --- |
| Claude ignoring earlier instructions | Context too full; `/clear` and restart with a tighter prompt |
| Repeated corrections not sticking | Run `/clear`, write a better prompt incorporating what you learned |
| Claude forgetting what you asked | Use `/compact <focus>` or `Esc+Esc` / `/rewind` to summarize |

### Verification-first workflow

| Strategy | Weak prompt | Strong prompt |
| --- | --- | --- |
| Provide test cases | "implement email validation" | "write validateEmail — test cases: user@example.com=true, invalid=false. run tests after." |
| Verify UI visually | "make dashboard look better" | "[paste screenshot] implement this design. screenshot result and compare. list differences and fix." |
| Address root cause | "the build is failing" | "build fails with [error]. fix it and verify the build succeeds. don't suppress the error." |

### Explore → Plan → Implement → Commit

1. **Plan Mode** (`Shift+Tab` twice, or `--permission-mode plan`): read-only exploration — Claude reads files without making changes
2. Ask Claude to produce a written implementation plan; press `Ctrl+G` to edit it in your text editor
3. Switch back to Normal Mode; Claude implements against the plan and runs tests
4. Ask Claude to commit with a descriptive message and open a PR

Skip planning for small, clearly scoped changes (one-line fixes, renames).

### Prompting patterns

| Strategy | Example |
| --- | --- |
| Scope the task | "write a test for foo.py covering the logged-out edge case; no mocks" |
| Point to git history | "look through ExecutionFactory's git history and summarize how its API evolved" |
| Reference existing patterns | "look at HotDogWidget.php, follow the same pattern for a new CalendarWidget" |
| Describe symptom + location | "login fails after session timeout — check src/auth/, token refresh; write a failing test, then fix it" |

Rich context: use `@filename` to attach files, paste images directly, pipe data with `cat file | claude`, or give Claude URLs.

### CLAUDE.md guidelines

| Include | Exclude |
| --- | --- |
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Code style rules that differ from defaults | Standard language conventions |
| Test runner commands and preferences | Detailed API docs (link instead) |
| Branch/PR naming conventions | Information that changes frequently |
| Architectural decisions specific to the project | Long tutorials or explanations |
| Required env vars / dev environment quirks | File-by-file codebase descriptions |
| Common non-obvious gotchas | Self-evident practices ("write clean code") |

Keep it short. Bloated CLAUDE.md causes Claude to ignore rules. Use `@path/to/file` imports for supplementary docs. Place at `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project, check into git), or `./CLAUDE.local.md` (personal, gitignore).

### Permission / interruption modes

| Mode | How to enable | Best for |
| --- | --- | --- |
| Normal (default) | — | General use with per-action approvals |
| Auto mode | `--permission-mode auto` or `Shift+Tab` once | Unattended runs; classifier blocks risky actions automatically |
| Plan mode | `--permission-mode plan` or `Shift+Tab` twice | Safe exploration before committing to changes |
| Allowlists | `/permissions` | Permit specific known-safe commands |
| Sandboxing | `/sandbox` | OS-level filesystem/network isolation |

### Session management

| Action | Command |
| --- | --- |
| Stop Claude mid-action | `Esc` |
| Rewind to a checkpoint | `Esc+Esc` or `/rewind` |
| Clear context between tasks | `/clear` |
| Compact with focus | `/compact Focus on the API changes` |
| Ask a side question (no context cost) | `/btw your question` |
| Name a session | `/rename auth-refactor` or `-n auth-refactor` at startup |
| Resume most recent session | `claude --continue` |
| Pick from recent sessions | `claude --resume` |
| Resume by name | `claude --resume auth-refactor` |

### Parallel and non-interactive use

```bash
# Non-interactive one-off
claude -p "explain what this project does"

# Structured output for scripts
claude -p "list all API endpoints" --output-format json

# Fan-out migration loop
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done

# Unattended with safety classifier
claude --permission-mode auto -p "fix all lint errors"
```

### Common workflow recipes

| Task | Key steps |
| --- | --- |
| Understand a new codebase | Ask "give me an overview", then narrow: architecture, data models, auth flow |
| Fix a bug | Share the error + reproduction command; ask for fix options; apply; verify |
| Refactor | Find legacy code; get recommendations; apply in small testable increments; run tests |
| Write tests | Identify untested functions; scaffold; add edge cases; run and fix |
| Create a PR | Summarize changes; `create a pr`; review and refine description |
| Work in parallel (git worktrees) | `claude --worktree feature-name` — isolated branch per session, auto-cleanup |

### Extended thinking

| Config | How |
| --- | --- |
| Adjust effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| `ultrathink` keyword | Include "ultrathink" in your prompt for extra reasoning on that turn |
| Toggle thinking on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux), or `/config` |
| View thinking output | `Ctrl+O` to toggle verbose mode (shown as gray italic text) |
| Limit token budget | `MAX_THINKING_TOKENS` env var (set to `0` to disable) |

### Ultraplan (cloud planning, research preview)

Launches a planning session on Claude Code on the web so your terminal stays free. Requires v2.1.91+, Claude.ai account, and a GitHub repo. Not available on Bedrock/Vertex/Foundry.

| Action | How |
| --- | --- |
| Launch from CLI | `/ultraplan migrate auth to JWTs` or include "ultraplan" anywhere in a prompt |
| Check status | `/tasks` — shows `◇ ultraplan`, `◇ ultraplan needs your input`, or `◆ ultraplan ready` |
| Review in browser | Inline comments, emoji reactions, outline sidebar; iterate until plan looks right |
| Execute on the web | "Approve Claude's plan and start coding" — runs in cloud, then create PR from browser |
| Send back to terminal | "Approve plan and teleport back to terminal" — choose implement here, new session, or save to file |

### Ultrareview (cloud code review, research preview)

Multi-agent deep review running in a remote sandbox. Every finding is independently reproduced. Requires v2.1.86+, Claude.ai account. Not available on Bedrock/Vertex/Foundry or with Zero Data Retention.

| Command | What it reviews |
| --- | --- |
| `/ultrareview` | Diff between current branch and default branch (including uncommitted/staged changes) |
| `/ultrareview 1234` | GitHub PR by number (requires `github.com` remote) |

| Plan | Free runs | After free runs |
| --- | --- | --- |
| Pro / Max | 3 free runs (expire May 5, 2026) | ~$5–$20 per review as extra usage |
| Team / Enterprise | none | ~$5–$20 per review as extra usage |

Takes ~5–10 minutes. Runs in background — use `/tasks` to track or stop. Results appear as a notification with file locations and explanations.

| Feature | `/review` | `/ultrareview` |
| --- | --- | --- |
| Runs | locally | remote cloud sandbox |
| Depth | single-pass | multi-agent with independent verification |
| Duration | seconds to minutes | ~5–10 minutes |
| Cost | normal usage | free runs, then ~$5–$20 extra usage |
| Best for | fast feedback while iterating | pre-merge confidence on substantial changes |

### Common failure patterns to avoid

| Pattern | Fix |
| --- | --- |
| Kitchen-sink session (unrelated tasks mixed) | `/clear` between unrelated tasks |
| Correcting the same issue 3+ times | `/clear`, write a better initial prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert always-needed behaviors to hooks |
| Trust-then-verify gap (no test/screenshot) | Always provide verification criteria before considering done |
| Infinite exploration (no scope) | Scope investigations narrowly, or delegate to a subagent |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — tips and patterns for getting the most out of Claude Code
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step guides for exploring codebases, fixing bugs, refactoring, testing, PRs, and more
- [Ultraplan](references/claude-code-ultraplan.md) — cloud-based planning with browser review and flexible execution
- [Ultrareview](references/claude-code-ultrareview.md) — multi-agent deep code review in a remote cloud sandbox

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
