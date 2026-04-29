---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, and advanced cloud planning and review features — effective prompting, context management, CLAUDE.md authoring, parallel sessions, worktrees, Plan Mode, ultraplan, and ultrareview.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, ultraplan, and ultrareview.

## Quick Reference

### Core constraint: the context window

Performance degrades as the context window fills. Every file read, command output, and message consumes context. Actively manage context throughout every session.

| Signal | Action |
| :--- | :--- |
| Claude repeating mistakes | `/clear` and rewrite the prompt with what you learned |
| Unrelated tasks piling up | `/clear` between tasks |
| Deep investigation needed | Use subagents so reads don't consume main context |
| Approaching limits | `/compact <instructions>` or `Esc+Esc → Summarize from here` |

---

### Verification strategies

Providing a way for Claude to check its own work is the single highest-leverage improvement you can make.

| Type | Example prompt pattern |
| :--- | :--- |
| Test suite | "implement X. run tests after. fix any failures." |
| Visual UI | "[paste screenshot] implement this design. take a screenshot of the result and compare." |
| Build check | "fix this error: [paste error]. verify the build succeeds. don't suppress the error." |
| Linter/script | "run `npm run lint` and fix all reported issues." |

---

### Explore → Plan → Implement → Commit workflow

Use Plan Mode (`Shift+Tab` twice, or `--permission-mode plan`) to separate read-only exploration from execution.

| Phase | Mode | What to do |
| :--- | :--- | :--- |
| Explore | Plan Mode | Ask Claude to read files and understand context |
| Plan | Plan Mode | Ask for a detailed implementation plan; press `Ctrl+G` to edit it |
| Implement | Normal Mode | Ask Claude to code and run tests against the plan |
| Commit | Normal Mode | Ask Claude to commit with a descriptive message and open a PR |

Skip planning for small, obvious changes (typo fixes, log lines, single-file renames).

---

### Effective prompting

| Strategy | Vague | Specific |
| :--- | :--- | :--- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "why is this API weird?" | "look through ExecutionFactory's git history and summarize how its API came to be" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php as a pattern. implement a calendar widget with month/year pagination. no new libraries." |
| Describe symptoms | "fix the login bug" | "users report login fails after session timeout. check src/auth/, especially token refresh. write a failing test then fix it." |

**Rich context shortcuts:**
- `@path/to/file` — include a file before responding
- Drag/paste images directly into the prompt
- `cat error.log | claude` — pipe data in
- Give Claude URLs and allow the domain with `/permissions`

---

### CLAUDE.md authoring

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude infers from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Branch naming and PR conventions | Information that changes frequently |
| Architectural decisions specific to the project | Long explanations or tutorials |
| Developer environment quirks, required env vars | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices ("write clean code") |

CLAUDE.md placement:
- `~/.claude/CLAUDE.md` — all sessions
- `./CLAUDE.md` — project root, check into git
- `./CLAUDE.local.md` — personal overrides, add to `.gitignore`
- Parent/child directories — loaded automatically when working in those directories

Import other files with `@path/to/file` syntax inside CLAUDE.md.

If Claude ignores rules, the file is too long — prune aggressively. Use `IMPORTANT:` or `YOU MUST` to emphasize critical rules.

---

### Session management commands

| Command / Key | Effect |
| :--- | :--- |
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc Esc` / `/rewind` | Open rewind menu: restore conversation, code, or both to any checkpoint |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact history with custom instructions |
| `/btw` | Side question — answer shown in overlay, never enters context |
| `/rename <name>` | Name the current session |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Pick from recent sessions |
| `claude -n <name>` | Start session with a name |
| `claude --from-pr 123` | Resume the session linked to a PR |

Session picker keyboard shortcuts (`/resume`):

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Navigate sessions |
| `Space` | Preview session |
| `Ctrl+R` | Rename highlighted session |
| `Ctrl+A` | Show all projects |
| `Ctrl+W` | Show all worktrees |
| `Ctrl+B` | Filter by current branch |

---

### Automation and scaling

**Non-interactive mode:**

```bash
claude -p "prompt"                                # plain text output
claude -p "prompt" --output-format json           # JSON with metadata
claude -p "prompt" --output-format stream-json    # streaming JSON
```

**Fan-out batch pattern:**

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

**Auto mode (unattended, with safety classifier):**

```bash
claude --permission-mode auto -p "fix all lint errors"
```

**Parallel session options:**

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Desktop app | Local machine | Visual management of multiple local sessions |
| Claude Code on the web | Anthropic cloud | Isolated VMs, no local resources |
| Agent teams | Automated coordination | Shared tasks, messaging, team lead |

**Writer/Reviewer pattern:** Session A writes the code; Session B reviews it with fresh context. Then Session A addresses the feedback.

---

### Git worktrees for parallel isolation

```bash
claude --worktree feature-auth   # creates .claude/worktrees/feature-auth/ on a new branch
claude --worktree                 # auto-generates a name
claude --worktree bugfix-123
```

Worktrees branch from `origin/HEAD`. Re-sync with: `git remote set-head origin -a`

Copy gitignored files (`.env`, etc.) to worktrees by listing them in `.worktreeinclude` at the project root.

Cleanup: worktrees with no changes are removed automatically on exit; worktrees with changes prompt you to keep or remove.

Add `.claude/worktrees/` to `.gitignore`.

Subagent worktrees: add `isolation: worktree` to a subagent's frontmatter, or ask Claude to "use worktrees for your agents."

---

### Scheduled and recurring tasks

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Routines | Anthropic-managed infra | Tasks that run when your machine is off |
| Desktop scheduled tasks | Your machine via desktop app | Tasks needing local files or tools |
| GitHub Actions | CI pipeline | Repo events or cron schedules |
| `/loop` | Current CLI session | Quick polling while a session is open |

---

### Ultraplan (cloud planning, research preview)

Requires Claude Code v2.1.91+. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

Launch from CLI:
- `/ultraplan <prompt>` — command form
- Include "ultraplan" anywhere in a normal prompt
- From a local plan approval dialog, choose **No, refine with Ultraplan**

Status indicators in CLI:

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is drafting the plan in the cloud |
| `◇ ultraplan needs your input` | Claude has a question — open the session link |
| `◆ ultraplan ready` | Plan is ready to review in the browser |

Browser review tools: inline comments on sections, emoji reactions, outline sidebar.

Execution choices after approval:
- **Approve and start coding** — implement in the same cloud session, then create a PR
- **Approve and teleport back to terminal** — send the plan back to your local session (3 choices: implement here, start new session, or save to file)

---

### Ultrareview (cloud code review, research preview)

Requires Claude Code v2.1.86+. Not available on Bedrock, Vertex AI, Microsoft Foundry, or orgs with Zero Data Retention.

```text
/ultrareview           # review current branch vs default branch
/ultrareview 1234      # review a GitHub PR by number
```

```bash
claude ultrareview           # non-interactive / CI
claude ultrareview 1234
claude ultrareview origin/main
```

CLI flags for non-interactive mode:

| Flag | Description |
| :--- | :--- |
| `--json` | Print raw `bugs.json` instead of formatted findings |
| `--timeout <minutes>` | Max wait time (default: 30) |

Pricing:

| Plan | Free runs | After free runs |
| :--- | :--- | :--- |
| Pro / Max | 3 free (expires May 5 2026) | ~$5–$20 per review as extra usage |
| Team / Enterprise | None | ~$5–$20 per review as extra usage |

Use `/tasks` to track running reviews and see findings. Findings include file location + explanation — ask Claude to fix them directly.

**`/review` vs `/ultrareview`:**

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | Locally | Remotely in cloud sandbox |
| Depth | Single-pass | Multi-agent fleet with independent verification |
| Duration | Seconds to minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 extra usage |
| Best for | Fast feedback while iterating | Pre-merge confidence on substantial changes |

---

### Common failure patterns to avoid

| Pattern | Fix |
| :--- | :--- |
| Kitchen sink session (unrelated tasks piling up) | `/clear` between tasks |
| Correcting the same mistake repeatedly | After 2 failures, `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md (rules get lost) | Prune ruthlessly; convert covered behaviors to hooks |
| Trust-then-verify gap (no success criteria) | Always provide tests, scripts, or screenshots for verification |
| Infinite exploration (reads fill context) | Scope investigations narrowly or delegate to subagents |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — context window management, verification strategies, explore/plan/implement workflow, prompting patterns, CLAUDE.md authoring, permissions, hooks, skills, subagents, plugins, session management, parallel sessions, non-interactive mode, fan-out patterns, and common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step guides for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, testing, pull requests, documentation, images, @ references, extended thinking, session resumption, git worktrees, desktop notifications, unix-style usage, scheduled tasks, and output formats
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching ultraplan from CLI, status indicators, browser review UI (inline comments, reactions, outline), executing on the web vs teleporting back to terminal, requirements and limitations
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — running ultrareview interactively and non-interactively, PR mode, pricing and free runs, tracking reviews with `/tasks`, non-interactive CLI flags, and comparison with `/review`

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
