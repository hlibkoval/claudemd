---
name: best-practices-doc
description: Best practices, common workflows, and ultraplan documentation for Claude Code. Covers context management, verification, Plan Mode, prompt patterns, CLAUDE.md tuning, session management, parallel sessions, fan-out automation, common failure patterns, and everyday recipes for debugging, refactoring, testing, PRs, worktrees, images, piping, scheduling, and cloud planning with /ultraplan.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and the ultraplan feature.

## Quick Reference

### Core principle: manage context aggressively

Claude's context window is the fundamental constraint. Performance degrades as it fills. Most best practices exist to protect context.

### The four-phase workflow

| Phase | Mode | What to do |
| --- | --- | --- |
| **Explore** | Plan Mode | Read files and ask questions without editing |
| **Plan** | Plan Mode | Ask Claude for a detailed implementation plan (Ctrl+G edits it) |
| **Implement** | Normal Mode | Execute the plan, verify against it |
| **Commit** | Normal Mode | Descriptive commit message and PR |

Skip planning when the diff fits in one sentence (typos, log lines, renames).

### High-leverage prompt patterns

| Strategy | Do this |
| --- | --- |
| **Give Claude a way to verify** | Include tests, screenshots, expected outputs, lint/build commands |
| **Scope the task** | Name the file, the scenario, the test preferences |
| **Point to sources** | "look through git history of X and summarize" |
| **Reference patterns** | "follow the pattern in HotDogWidget.php" |
| **Describe symptoms** | Symptom + likely location + what "fixed" looks like |
| **Address root causes** | "fix it and verify... don't suppress the error" |
| **Let Claude interview you** | "interview me using the AskUserQuestion tool... write a spec to SPEC.md" |

### Rich input methods

- `@path/to/file` references a file (adds its CLAUDE.md to context too)
- Paste images directly (copy/paste or drag-drop)
- Give URLs; allowlist frequent domains via `/permissions`
- Pipe data: `cat error.log | claude`
- Tell Claude to fetch what it needs via Bash, MCP, or file reads

### CLAUDE.md tuning

Run `/init` to generate a starter. Keep it short. For each line ask: *"Would removing this cause mistakes?"* If not, cut it.

| Include | Exclude |
| --- | --- |
| Bash commands Claude can't guess | Things Claude can read from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branches, PRs) | Frequently-changing info |
| Architectural decisions | Long tutorials |
| Env quirks (required env vars) | File-by-file descriptions |
| Non-obvious gotchas | "Write clean code" platitudes |

Use "IMPORTANT" / "YOU MUST" emphasis for critical rules. Import other files with `@path/to/import`. Locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (team, checked in), `./CLAUDE.local.md` (personal, gitignored), parent/child dirs (monorepo-friendly).

### Permission reduction (three options)

- **Auto mode**: classifier reviews commands, blocks only risky ones (`--permission-mode auto`)
- **Permission allowlists**: via `/permissions` for safe tools like `npm run lint`
- **Sandboxing**: OS-level isolation via `/sandbox`

### Extensibility primitives

| Primitive | Use when |
| --- | --- |
| **CLAUDE.md** | Advisory context loaded every session |
| **Skills** (`.claude/skills/<name>/SKILL.md`) | Domain knowledge or workflows loaded on demand |
| **Hooks** (`.claude/settings.json`) | Deterministic actions that must run every time |
| **Subagents** (`.claude/agents/`) | Isolated context for focused tasks |
| **MCP servers** (`claude mcp add`) | External tool integration (Notion, Figma, DBs) |
| **Plugins** (`/plugin`) | Bundled skills + hooks + subagents + MCP from community |
| **CLI tools** (`gh`, `aws`, `gcloud`) | Context-efficient external service access |

### Session management

| Action | How |
| --- | --- |
| Stop Claude mid-action | `Esc` |
| Rewind conversation/code | `Esc+Esc` or `/rewind` |
| Undo last changes | "undo that" |
| Reset context between tasks | `/clear` |
| Manual compaction | `/compact <instructions>` |
| Ephemeral side question | `/btw` (overlay, no context cost) |
| Continue most recent session | `claude --continue` |
| Pick a session to resume | `claude --resume` |
| Name a session | `claude -n <name>` or `/rename` |
| Resume by PR | `claude --from-pr <number>` |

If you've corrected Claude twice on the same issue, `/clear` and rewrite the prompt. Fresh session with better prompt beats a long session with accumulated corrections.

### Scaling with parallel sessions

| Option | Where |
| --- | --- |
| Desktop app sessions | Local, each in its own worktree |
| Claude Code on the web | Anthropic cloud VMs |
| Agent teams | Coordinated multi-session with shared tasks |
| `claude --worktree <name>` | Isolated CLI worktree at `.claude/worktrees/<name>` |

**Writer/Reviewer pattern**: one session writes, another (fresh context, unbiased) reviews.

**Fan out across files**: generate task list, loop with `claude -p "..." --allowedTools "..."`.

### Non-interactive mode (`-p`)

```bash
claude -p "Explain what this project does"
claude -p "List all API endpoints" --output-format json
claude -p "Analyze this log file" --output-format stream-json
claude --permission-mode auto -p "fix all lint errors"
```

Output formats: `text` (default), `json` (full message array with cost/duration), `stream-json` (real-time per message).

### Plan Mode

- Toggle with **Shift+Tab** (cycles Normal -> Auto-Accept -> Plan)
- Start in Plan Mode: `claude --permission-mode plan`
- Headless plan: `claude --permission-mode plan -p "..."`
- Ctrl+G opens plan in your editor for direct edits
- Default via `.claude/settings.json`: `"permissions": { "defaultMode": "plan" }`
- Best for multi-file changes, code exploration, iterative direction-setting

### Extended thinking (adaptive reasoning)

| Control | How |
| --- | --- |
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` |
| One-off deep reasoning | Include `ultrathink` in prompt (sets effort high for that turn) |
| Toggle thinking | `Option+T` (mac) / `Alt+T` (win/linux) |
| Global default | `/config` (saves `alwaysThinkingEnabled`) |
| Token cap | `MAX_THINKING_TOKENS` env var (only `0` applies on Opus/Sonnet 4.6 unless adaptive is disabled) |
| View thinking | `Ctrl+O` toggles verbose mode |

Note: "think", "think hard", "think more" are plain prompt text - they do NOT allocate thinking tokens. Use `ultrathink` or effort levels instead.

### Git worktrees

```bash
claude --worktree feature-auth    # creates .claude/worktrees/feature-auth
claude --worktree                 # auto-named like "bright-running-fox"
claude -w bugfix-123              # short form
```

Worktrees branch from `origin/HEAD`. Re-sync with `git remote set-head origin -a`. Customize via [WorktreeCreate hook](/en/hooks#worktreecreate). Copy gitignored files (like `.env`) via a `.worktreeinclude` file at the repo root (gitignore syntax, only gitignored matches are copied). Add `.claude/worktrees/` to `.gitignore`.

Subagents can isolate into worktrees via `isolation: worktree` in frontmatter.

### Notification hook (get pinged when Claude needs you)

Add a `Notification` hook in `~/.claude/settings.json` that shells out to `osascript` (macOS), `notify-send` (Linux), or PowerShell `MessageBox` (Windows). Narrow with `matcher`: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`.

### Scheduling options

| Option | Runs on | Best for |
| --- | --- | --- |
| Cloud scheduled tasks | Anthropic infra | Runs even when your machine is off |
| Desktop scheduled tasks | Your desktop app | Needs local files/tools |
| GitHub Actions | CI | Repo-event-driven or cron |
| `/loop` | Current CLI session | Quick polling; cancelled on exit |

### Common failure patterns

| Pattern | Fix |
| --- | --- |
| **Kitchen sink session** (unrelated tasks accumulated) | `/clear` between unrelated tasks |
| **Correcting over and over** | After 2 failed corrections, `/clear` and rewrite prompt |
| **Over-specified CLAUDE.md** | Prune ruthlessly; convert rules to hooks |
| **Trust-then-verify gap** (plausible but wrong code) | Always provide tests/scripts/screenshots |
| **Infinite exploration** | Scope narrowly, or delegate to subagents |

### Common workflow recipes

- **Codebase onboarding**: "give me an overview" -> "explain the main architecture" -> "how is X handled?"
- **Bug fixing**: share the error + repro command + stack trace
- **Refactoring**: identify -> recommend -> apply -> test in small increments
- **Testing**: find untested code -> scaffold -> add edge cases -> run and fix
- **PRs**: "summarize my changes" -> "create a pr" -> "enhance the description"
- **Documentation**: find undocumented -> generate -> review -> verify against standards
- **Images**: drag/drop, ctrl+v (not cmd+v), or provide a path
- **Unix utility**: `cat error.txt | claude -p 'explain root cause' > out.txt`
- **Ask Claude about itself**: "how does Claude Code handle permissions?" (built-in docs access)

### Ultraplan (research preview, v2.1.91+)

Hands a planning task from your local CLI to a Claude Code on the web session in Plan Mode. Requires Claude Code on the web + a GitHub repo; not available on Bedrock/Vertex/Foundry.

**Launch**:
- `/ultraplan <prompt>`
- Include the word `ultraplan` in any prompt
- When a local plan finishes, choose "No, refine with Ultraplan on Claude Code on the web"

**CLI status indicators**:

| Indicator | Meaning |
| --- | --- |
| `◇ ultraplan` | Drafting in the cloud |
| `◇ ultraplan needs your input` | Clarifying question waiting in browser |
| `◆ ultraplan ready` | Plan ready to review |

Run `/tasks` to open the session detail view (link, activity, stop action). Remote Control disconnects when ultraplan starts (shared interface).

**Review in browser**: inline comments on highlighted passages, emoji reactions, outline sidebar. Iterate as needed.

**Execute options**:
- **Approve Claude's plan and start coding**: runs in the same cloud session, opens PR when done
- **Approve plan and teleport back to terminal**: archives cloud session, returns to waiting CLI with a dialog offering **Implement here**, **Start new session** (prints `claude --resume` for the old one), or **Cancel** (saves plan to a file)

### Develop intuition

The patterns are starting points, not rules. Sometimes let context accumulate (deep in one problem). Sometimes skip planning (exploratory). Sometimes be vague (to see how Claude interprets). Notice what works and adjust.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) - Context management, Plan Mode workflow, CLAUDE.md tuning, permissions, session management, parallel sessions, fan-out, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) - Step-by-step recipes for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, tests, PRs, docs, images, `@` references, extended thinking, resuming sessions, git worktrees, notification hooks, Unix-style usage, scheduling
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) - Cloud-based planning handoff from CLI to Claude Code on the web, review in browser, execute on web or teleport back to terminal

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
