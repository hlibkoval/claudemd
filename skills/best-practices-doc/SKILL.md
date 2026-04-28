---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices and common workflows — context management, verification strategies, Plan Mode, prompting techniques, CLAUDE.md authoring, permission modes, session management, parallel sessions, non-interactive mode, ultraplan (cloud planning), and ultrareview (cloud code review).
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and advanced cloud features (ultraplan and ultrareview).

## Quick Reference

### Core constraint: context window fills fast

Every file read, message, and command output consumes context. Performance degrades as context fills. Managing context is the highest-leverage skill.

### Best practices summary

| Practice | Key point |
| :--- | :--- |
| **Give Claude a way to verify its work** | Provide tests, expected outputs, or screenshots. Without verification Claude cannot self-correct. |
| **Explore first, then plan, then code** | Use Plan Mode to separate research from implementation. Prevents solving the wrong problem. |
| **Be specific in prompts** | Reference exact files, mention constraints, point to existing patterns. |
| **Write an effective CLAUDE.md** | Short, actionable, human-readable. Run `/init` to generate a starter file. |
| **Configure permissions** | Use auto mode, allowlists, or sandboxing to reduce interruptions. |
| **Use CLI tools** | `gh`, `aws`, `gcloud`, etc. are more context-efficient than API calls. |
| **Connect MCP servers** | `claude mcp add` for Notion, Figma, databases, and other external tools. |
| **Course-correct early** | Press `Esc` to interrupt; `Esc+Esc` or `/rewind` to restore a checkpoint. |
| **Use `/clear` aggressively** | Reset context between unrelated tasks. After two failed corrections, start fresh. |
| **Use subagents for investigation** | Delegate research to keep your main conversation clean. |

---

### Plan Mode

| Method | How |
| :--- | :--- |
| Toggle during session | `Shift+Tab` (cycles: Normal → Auto-Accept → Plan) |
| Start new session in Plan Mode | `claude --permission-mode plan` |
| Headless query in Plan Mode | `claude --permission-mode plan -p "..."` |
| Edit plan in text editor | Press `Ctrl+G` when plan is shown |
| Set as default | `settings.json` → `permissions.defaultMode: "plan"` |

Use Plan Mode for multi-file changes, unfamiliar code, or when uncertain about approach. Skip it for small, clearly-scoped tasks.

---

### Recommended workflow phases

1. **Explore** — Enter Plan Mode; Claude reads files without making changes.
2. **Plan** — Ask Claude for a detailed implementation plan; press `Ctrl+G` to edit it.
3. **Implement** — Switch to Normal Mode; Claude codes and verifies against the plan.
4. **Commit** — Ask Claude to commit with a descriptive message and open a PR.

---

### Providing context effectively

| Strategy | Example |
| :--- | :--- |
| Reference files with `@` | `@src/auth.js` — Claude reads the file before responding |
| Paste images | Drag/drop or `Ctrl+V` screenshots, mockups, diagrams |
| Give URLs | Allowlist domains with `/permissions` for repeated use |
| Pipe in data | `cat error.log \| claude` |
| Let Claude fetch | Tell Claude to use Bash commands or MCP tools for context |

---

### CLAUDE.md authoring guide

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API docs (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices |

- Use `@path/to/file` imports for referenced docs.
- Keep it short: bloated CLAUDE.md causes Claude to ignore rules.
- Add emphasis (`IMPORTANT`, `YOU MUST`) for critical rules.
- Treat CLAUDE.md like code: prune regularly, test by observing behavior.

---

### Session management commands

| Command / Key | Effect |
| :--- | :--- |
| `Esc` | Interrupt Claude mid-action; context preserved |
| `Esc+Esc` or `/rewind` | Open rewind menu: restore conversation, code, or both |
| `/clear` | Reset context entirely |
| `/compact <instructions>` | Compact with custom focus (e.g., `/compact Focus on API changes`) |
| `/btw` | Side question that never enters conversation history |
| `/rename` | Give the session a descriptive name |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Pick from recent sessions |
| `claude --resume <name>` | Resume by name across worktrees |
| `claude --from-pr <number>` | Resume sessions linked to a pull request |

---

### Non-interactive (headless) mode

```
claude -p "your prompt"                        # one-off query
claude -p "..." --output-format json           # structured output
claude -p "..." --output-format stream-json    # streaming JSON
claude -p "..." --permission-mode auto         # auto mode, no prompts
```

Use `--allowedTools "Edit,Bash(git commit *)"` to scope permissions in batch scripts.

---

### Parallel sessions patterns

| Pattern | How |
| :--- | :--- |
| **Writer/Reviewer** | Session A implements; Session B reviews in fresh context |
| **Test-first** | Session A writes tests; Session B writes passing code |
| **Fan-out migration** | Script loops calling `claude -p` per file with `--allowedTools` |
| **Desktop app** | Multi-session visual management, each with isolated worktree |
| **Claude Code on the web** | Remote cloud VMs, isolated environments |
| **Agent teams** | Automated coordination via shared tasks and messaging |

---

### Git worktrees for parallel sessions

```bash
claude --worktree feature-auth      # creates .claude/worktrees/feature-auth/
claude --worktree bugfix-123        # separate worktree, own branch
claude --worktree                   # auto-generates name
```

- Worktrees branch from `origin/HEAD`. Re-sync with `git remote set-head origin -a`.
- Add `.claude/worktrees/` to `.gitignore`.
- Copy gitignored files (`.env`) via `.worktreeinclude` in the project root.
- Cleanup: no changes → auto-removed. Changes → Claude prompts to keep or remove.

---

### Common failure patterns

| Pattern | Symptom | Fix |
| :--- | :--- | :--- |
| Kitchen sink session | Context full of unrelated info | `/clear` between tasks |
| Repeated corrections | Claude keeps making same mistake | After 2 failures, `/clear` and write a better prompt |
| Over-specified CLAUDE.md | Instructions ignored | Prune ruthlessly; convert to hooks if deterministic |
| Trust-then-verify gap | Plausible output that fails edge cases | Always provide tests or scripts |
| Infinite exploration | Context flooded by file reads | Scope narrowly or use subagents |

---

### Ultraplan — cloud planning (research preview)

Requires Claude Code v2.1.91+. Requires Claude Code on the web account and GitHub repository. Not available on Bedrock, Vertex, or Foundry.

| Method | How |
| :--- | :--- |
| Command | `/ultraplan migrate the auth service from sessions to JWTs` |
| Keyword | Include `ultraplan` anywhere in a normal prompt |
| From local plan | Choose "No, refine with Ultraplan on Claude Code on the web" in approval dialog |

**Status indicators while remote session works:**

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Researching codebase, drafting plan |
| `◇ ultraplan needs your input` | Claude has a clarifying question; open session link |
| `◆ ultraplan ready` | Plan ready to review in browser |

**After review, choose execution:**

- **Approve and start coding** → implements in the cloud session; review diff and create PR from web.
- **Approve and teleport back to terminal** → sends plan to your CLI; web session archived.
  - Terminal options: **Implement here**, **Start new session**, or **Cancel** (saves plan to file).

---

### Ultrareview — cloud code review (research preview)

Requires Claude Code v2.1.86+. Not available on Bedrock, Vertex, Foundry, or Zero Data Retention orgs. Requires Claude.ai account (not API-key-only).

| Invocation | What it reviews |
| :--- | :--- |
| `/ultrareview` | Diff between current branch and default branch (including staged/unstaged) |
| `/ultrareview 1234` | GitHub PR #1234 (cloned from GitHub, requires `github.com` remote) |
| `claude ultrareview` | Non-interactive (CI/script); blocks until done, exits 0 on success |
| `claude ultrareview 1234` | Non-interactive, PR mode |
| `claude ultrareview origin/main` | Non-interactive, diff against specific branch |

**Non-interactive flags:**

| Flag | Description |
| :--- | :--- |
| `--json` | Print raw `bugs.json` instead of formatted findings |
| `--timeout <minutes>` | Max wait (default: 30) |

**Ultrareview vs `/review`:**

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | Locally | Remote cloud sandbox |
| Depth | Single-pass | Multi-agent fleet with verification |
| Duration | Seconds to minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 extra usage |
| Best for | Quick feedback while iterating | Pre-merge confidence on substantial changes |

**Pricing (as of April 2026):**

| Plan | Free runs | After free runs |
| :--- | :--- | :--- |
| Pro / Max | 3 runs through May 5, 2026 | Extra usage billing |
| Team / Enterprise | None | Extra usage billing |

Run `/extra-usage` to check or enable extra usage billing before launching a paid review.

---

### Common workflows quick-reference

| Task | Key steps |
| :--- | :--- |
| **Understand new codebase** | Ask for overview → dive into architecture → trace execution flows |
| **Fix a bug** | Share error + reproduction steps → get fix suggestions → apply → verify |
| **Refactor** | Find deprecated usage → get recommendations → apply → run tests |
| **Write tests** | Identify untested code → generate scaffolding → add edge cases → run and fix |
| **Create PR** | Summarize changes → `create a pr` → review and refine description |
| **Write docs** | Find undocumented code → generate docs → review → verify against standards |
| **Schedule tasks** | Use Routines (cloud), Desktop scheduled tasks, GitHub Actions, or `/loop` |
| **Run as linter** | `claude -p "you are a linter..."` in build scripts or CI |
| **Pipe data** | `cat file.txt \| claude -p "summarize"` |

---

### Extended thinking (thinking mode)

| Setting | How |
| :--- | :--- |
| Toggle on/off (session) | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Toggle globally | `/config` |
| View thinking process | `Ctrl+O` (verbose mode — gray italic text) |
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| Limit token budget | `MAX_THINKING_TOKENS` env var (set to `0` to disable) |
| Show full summaries | `showThinkingSummaries: true` in `settings.json` |

- `ultrathink` in a prompt adds an in-context instruction to reason more on that turn; it does not change the effort level setting.
- Models with adaptive reasoning (Opus 4.7) always use adaptive reasoning; `MAX_THINKING_TOKENS` only applies at `0`.

---

### Session picker keyboard shortcuts

| Shortcut | Action |
| :--- | :--- |
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand/collapse grouped sessions |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable char | Enter search mode |
| `Ctrl+A` | Show sessions from all projects |
| `Ctrl+W` | Show sessions from all worktrees |
| `Ctrl+B` | Filter by current git branch |
| `Esc` | Exit picker or search mode |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — context management, verification, Plan Mode, prompting, CLAUDE.md authoring, permissions, CLI tools, MCP, hooks, skills, subagents, session management, parallel sessions, automation, and common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step guides for exploring codebases, fixing bugs, refactoring, testing, PRs, documentation, images, worktrees, extended thinking, notifications, non-interactive mode, and scheduling
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launch, review, revision, and execution options for cloud-based planning
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — multi-agent cloud code review, pricing, non-interactive subcommand, and comparison with local review

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
