---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, ultraplan (cloud-based planning), and ultrareview (multi-agent cloud code review) — covering context management, prompting patterns, session management, parallel workflows, automation, and pre-merge review tooling.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, ultraplan, and ultrareview.

## Quick Reference

### Core Constraint: Context Window

The context window is the most important resource to manage. Performance degrades as it fills. Every file read, message, and command output consumes context.

| Tool | Purpose |
| :--- | :--- |
| `/clear` | Reset context between unrelated tasks |
| `/compact <instructions>` | Compact with guidance on what to keep |
| `/btw` | Ask a side question without adding it to context history |
| `Esc + Esc` / `/rewind` | Open rewind menu — restore or summarize from a checkpoint |
| Subagents | Delegate research so exploration doesn't consume main context |

### Verify Your Work — Highest Leverage Practice

| Strategy | Instead of... | Try... |
| :--- | :--- | :--- |
| Provide test cases | "implement a validateEmail function" | "write validateEmail. test cases: user@example.com → true, invalid → false. run tests after." |
| Visual verification | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot, compare to original, fix differences" |
| Root cause fix | "the build is failing" | "build fails with [error]. fix it and verify the build succeeds. address root cause, don't suppress" |

### Explore → Plan → Implement → Commit Workflow

| Phase | Mode | What to do |
| :--- | :--- | :--- |
| **Explore** | Plan mode | Read files, understand code, no edits |
| **Plan** | Plan mode | Ask for implementation plan; `Ctrl+G` opens it in editor |
| **Implement** | Default mode | Code against the plan; run tests and fix failures |
| **Commit** | Default mode | Commit with descriptive message; open PR |

Use plan mode for: multi-file changes, unfamiliar code, or uncertain approach. Skip it for trivial one-sentence changes.

### Prompting Patterns

| Strategy | Vague | Specific |
| :--- | :--- | :--- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the logged-out edge case. avoid mocks." |
| Point to source | "why is ExecutionFactory weird?" | "look through ExecutionFactory's git history and summarize how its API came to be" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php as the pattern. implement a calendar widget using existing libraries only." |
| Describe symptom | "fix the login bug" | "login fails after session timeout. check src/auth/ token refresh. write a failing test then fix it." |

### Rich Context Input

- **`@file`** — reference files directly; Claude reads before responding
- **Paste images** — drag/drop or Ctrl+V screenshots and mockups
- **URLs** — give documentation/API reference links; allowlist with `/permissions`
- **Pipe data** — `cat error.log | claude` sends file contents directly
- **Let Claude fetch** — tell Claude to pull context via Bash, MCP, or file reads

### CLAUDE.md Guidelines

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything inferrable from reading the code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |

CLAUDE.md locations: `~/.claude/CLAUDE.md` (all sessions), `./CLAUDE.md` (project, checked into git), `./CLAUDE.local.md` (personal, gitignored), parent and child directories.

Import other files with `@path/to/file` syntax inside CLAUDE.md.

### Environment Setup

| Feature | How to configure |
| :--- | :--- |
| CLAUDE.md | Run `/init` to generate starter; refine over time |
| Permissions | Auto mode, allowlists via `/permissions`, or `/sandbox` for OS isolation |
| CLI tools | Install `gh`, `aws`, `gcloud`, etc.; Claude knows how to use them |
| MCP servers | `claude mcp add` to connect Notion, Figma, databases, etc. |
| Hooks | Write deterministic scripts that fire at specific workflow points |
| Skills | Add `.claude/skills/<name>/SKILL.md` for domain knowledge / workflows |
| Subagents | Add `.claude/agents/<name>.md` for specialized isolated task delegation |
| Plugins | `/plugin` to browse marketplace; bundles all of the above |

### Session Management

| Action | Command |
| :--- | :--- |
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc + Esc` or `/rewind` |
| Undo Claude's changes | "Undo that" |
| Clear context | `/clear` |
| Resume most recent | `claude --continue` |
| Choose a session | `claude --resume` or `/resume` |
| Rename session | `/rename` |

Checkpoints: every prompt creates a snapshot. Restore conversation only, code only, or both. Persist across terminal closes.

### Parallel and Automation Patterns

| Pattern | How |
| :--- | :--- |
| Non-interactive (CI/scripts) | `claude -p "prompt"` — add `--output-format json` or `stream-json` |
| Parallel worktrees | `claude --worktree <name>` — isolated git checkouts per session |
| Auto mode (unattended) | `claude --permission-mode auto -p "..."` — classifier blocks risky commands |
| Fan-out migration | Loop `claude -p` per file with `--allowedTools` to restrict scope |
| Writer/Reviewer | Session A implements; Session B reviews from a fresh context |

### Common Failure Patterns

| Anti-pattern | Fix |
| :--- | :--- |
| Kitchen sink session (mixing unrelated tasks) | `/clear` between tasks |
| Correcting the same mistake repeatedly | After 2 failures: `/clear` and write a better initial prompt |
| Bloated CLAUDE.md (rules getting lost) | Ruthlessly prune — if Claude does it without the rule, delete it |
| Shipping unverified code | Always provide tests, scripts, or screenshots for verification |
| Infinite exploration filling context | Scope investigations narrowly or delegate to a subagent |

### Common Workflows — Quick Recipes

| Task | Key prompts |
| :--- | :--- |
| Understand new codebase | "give me an overview" → "explain the main architecture" → "how is auth handled?" |
| Fix a bug | Share error + reproduction steps → "suggest fixes" → "apply the fix" |
| Refactor | "find deprecated API usage" → "suggest refactor" → "refactor maintaining same behavior" → "run tests" |
| Write tests | "find untested functions in X" → "add tests" → "add edge case tests" → "run and fix" |
| Create a PR | "summarize changes" → "create a pr" → "enhance PR description" |
| Document code | "find functions without JSDoc" → "add JSDoc comments" → "check docs follow project standards" |
| Schedule a task | Choose: Routines (cloud), Desktop scheduled tasks (local), GitHub Actions (CI), or `/loop` (current session) |

Worktrees: `claude --worktree <name>` for isolated parallel sessions without edit collisions.

Plan before editing: `claude --permission-mode plan` or `Shift+Tab` to toggle plan mode mid-session.

Pipe into scripts: `git log --oneline -20 | claude -p "summarize these commits"`

### Ultraplan — Cloud-Based Planning

Ultraplan hands a planning task to a Claude Code on the web session. Your terminal stays free while the plan is drafted remotely. Requires Claude Code on the web account and a GitHub repository. Not available on Bedrock, Vertex AI, or Foundry.

**Launch from CLI:**

```
/ultraplan migrate the auth service from sessions to JWTs
```

Or include the word `ultraplan` in any prompt, or choose "Refine with Ultraplan" from a local plan approval dialog.

**Status indicators:**

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Drafting in progress |
| `◇ ultraplan needs your input` | Open session link to answer a clarifying question |
| `◆ ultraplan ready` | Plan ready to review in browser |

**Review in browser:** inline comments on sections, emoji reactions, outline sidebar. Iterate until satisfied.

**Execution options:**
- **Approve and start coding** — implements on the web; review diff and create PR from browser
- **Approve and teleport to terminal** — sends plan back; choose: Implement here / Start new session / Cancel (saves to file)

Use `/tasks` to track running ultraplan sessions or stop them.

### Ultrareview — Multi-Agent Cloud Code Review

Ultrareview launches a fleet of reviewer agents in a remote sandbox. Every finding is independently reproduced and verified. Runs entirely remotely — terminal stays free. Requires Claude.ai authentication (not API key only). Not available on Bedrock, Vertex AI, Foundry, or orgs with Zero Data Retention.

**Run from CLI:**

```
/ultrareview          # review diff between current branch and default branch
/ultrareview 1234     # review a specific GitHub PR
```

**Pricing:**

| Plan | Free runs | After free runs |
| :--- | :--- | :--- |
| Pro / Max | 3 (one-time, non-refreshing) | Extra usage, ~$5–$20 per review |
| Team / Enterprise | 0 | Extra usage, ~$5–$20 per review |

Extra usage must be enabled before paid reviews. Run `/extra-usage` to check/change.

**Non-interactive (CI):**

```bash
claude ultrareview           # review branch vs default
claude ultrareview 1234      # review a PR
claude ultrareview origin/main  # review vs specific base
```

Flags: `--json` (raw bugs.json output), `--timeout <minutes>` (default 30). Exit codes: 0 = success, 1 = failure/timeout, 130 = Ctrl-C.

**Ultrareview vs /review:**

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | Locally | Remotely in cloud sandbox |
| Depth | Single-pass | Multi-agent with independent verification |
| Duration | Seconds to minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 extra usage |
| Best for | Fast feedback while iterating | Pre-merge confidence on substantial changes |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, verification strategies, CLAUDE.md setup, skills, hooks, subagents, session management, parallel sessions, automation
- [Common workflows](references/claude-code-common-workflows.md) — step-by-step recipes for exploring codebases, fixing bugs, refactoring, testing, PRs, documentation, images, file references, scheduling, and piping
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching, status indicators, browser review interface, execution options
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — multi-agent review, pricing, non-interactive CLI subcommand, comparison with /review

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
