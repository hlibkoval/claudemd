---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices — context management, prompt strategies, CLAUDE.md setup, permissions, session management, parallel sessions, non-interactive mode, common workflows (debugging, refactoring, tests, PRs), Plan Mode, extended thinking, worktrees, ultraplan, and ultrareview.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common development workflows, ultraplan, and ultrareview.

## Quick Reference

### Core constraint: context window fills fast

LLM performance degrades as context fills. The context window holds every message, file read, and command output. Managing it is the highest-leverage thing you can do.

| Signal | Action |
| :--- | :--- |
| Claude "forgetting" earlier instructions | `/clear` and restart with a tighter prompt |
| Two failed corrections in a row | `/clear`, write a better prompt using what you learned |
| Long unrelated multi-task session | `/clear` between tasks |
| Deep investigation consuming context | Use subagents — they explore in a separate context |

### Highest-leverage best practices

| Practice | Summary |
| :--- | :--- |
| **Give Claude a way to verify its work** | Provide tests, screenshots, or expected outputs so Claude can self-check. Without verification criteria, you become the only feedback loop. |
| **Explore first, then plan, then code** | Use Plan Mode to separate research from implementation. Press `Ctrl+G` to edit the plan before Claude proceeds. |
| **Provide specific context** | Reference specific files with `@`, paste images, give URLs, pipe data. The more precise your instructions, the fewer corrections needed. |
| **Let Claude interview you** | For large features, start with `"I want to build X. Interview me using the AskUserQuestion tool."` Then start a fresh session to execute the spec. |

### Prompt specificity table

| Strategy | Vague | Specific |
| :--- | :--- | :--- |
| Scope the task | `"add tests for foo.py"` | `"write a test for foo.py covering the edge case where the user is logged out. avoid mocks."` |
| Reference existing patterns | `"add a calendar widget"` | `"look at how existing widgets like HotDogWidget.php are implemented. follow that pattern..."` |
| Describe the symptom | `"fix the login bug"` | `"users report login fails after session timeout. check auth flow in src/auth/, write a failing test, then fix it"` |
| Provide verification | `"implement validateEmail"` | `"write validateEmail. test cases: user@example.com=true, invalid=false. run the tests after"` |

### CLAUDE.md quick guide

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude cannot guess | Anything Claude can infer from reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |

- Run `/init` to generate a starter CLAUDE.md from your project structure
- Use `@path/to/file` syntax inside CLAUDE.md to import other files
- Add emphasis (`IMPORTANT`, `YOU MUST`) for critical rules
- Keep it short — bloated CLAUDE.md causes Claude to ignore rules
- Check it in to git; it compounds in value over time

### CLAUDE.md locations

| Location | Scope |
| :--- | :--- |
| `~/.claude/CLAUDE.md` | All Claude sessions for this user |
| `./CLAUDE.md` | Project-wide (check into git) |
| `./CLAUDE.local.md` | Personal project overrides (add to .gitignore) |
| Parent directories | Monorepo — both root and subdirectory files load |
| Child directories | Loaded on demand when Claude works in that directory |

### Session management commands

| Command | Effect |
| :--- | :--- |
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc Esc` or `/rewind` | Open rewind menu to restore conversation/code state |
| `/clear` | Reset context entirely between unrelated tasks |
| `/compact <instructions>` | Compact with custom focus, e.g. `/compact Focus on API changes` |
| `/btw` | Side question — answer appears in overlay, never enters context |
| `/rename` | Give session a descriptive name like `"oauth-migration"` |
| `claude --continue` | Resume most recent conversation |
| `claude --resume` | Select from recent sessions |
| `claude -n <name>` | Start a named session |

### Permission modes

| Mode | How to enable | Best for |
| :--- | :--- | :--- |
| **Normal** | Default | Interactive work with per-action approval |
| **Auto-accept** | `Shift+Tab` once | Routine tasks where you trust the direction |
| **Plan** | `Shift+Tab` twice or `--permission-mode plan` | Safe exploration; Claude reads files but cannot write |
| **Auto** | `--permission-mode auto` | Unattended runs; classifier blocks risky actions |

### Non-interactive / CI usage

```bash
claude -p "your prompt"                          # one-off query
claude -p "prompt" --output-format json          # structured output
claude -p "prompt" --output-format stream-json   # streaming
claude --permission-mode auto -p "fix lint"      # auto mode
```

Fan-out pattern for large migrations:
```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### Plan Mode

| Trigger | How |
| :--- | :--- |
| Interactive toggle | `Shift+Tab` twice from Normal Mode |
| Start session | `claude --permission-mode plan` |
| Headless | `claude --permission-mode plan -p "..."` |
| Set as default | `{"permissions": {"defaultMode": "plan"}}` in `.claude/settings.json` |
| Edit plan before proceeding | `Ctrl+G` opens plan in your text editor |

Best used for: multi-file changes, unfamiliar codebases, or when you want to iterate on direction before any edits happen. Skip planning for small, obvious tasks.

### Git worktrees for parallel sessions

```bash
claude --worktree feature-auth    # new branch + worktree at .claude/worktrees/feature-auth/
claude --worktree                 # auto-generated name
```

- Worktrees branch from `origin/HEAD`; re-sync with `git remote set-head origin -a`
- Add `.claude/worktrees/` to `.gitignore`
- Use `.worktreeinclude` to copy gitignored files (e.g. `.env`) into worktrees
- Auto-cleanup on exit when no changes; prompts when changes exist

### Extended thinking (thinking mode)

| Setting | How |
| :--- | :--- |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux) or `/config` |
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| Keyword boost | Include `ultrathink` in your prompt |
| Cap token budget | `MAX_THINKING_TOKENS` env var |
| View reasoning | `Ctrl+O` to enable verbose mode — thinking appears as gray italic text |

### Scheduled task options

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Routines | Anthropic-managed cloud | Tasks that run even when your computer is off |
| Desktop scheduled tasks | Your machine (desktop app) | Tasks needing local files or uncommitted changes |
| GitHub Actions | CI pipeline | PR events or cron jobs alongside workflow config |
| `/loop` | Current CLI session | Quick polling while a session is open |

### Ultraplan

Launch a planning task from CLI → draft in Claude Code on the web (plan mode) → review in browser → execute on web or send back to terminal.

| Trigger | Command |
| :--- | :--- |
| Command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` anywhere in a prompt |
| From local plan | Choose "No, refine with Ultraplan" in the plan approval dialog |

Status indicators while remote session works:

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Claude has a clarifying question — open the link |
| `◆ ultraplan ready` | Plan is ready to review in browser |

After review, choose: **Execute on the web** (cloud) or **Approve plan and teleport back to terminal** (local). Requires Claude Code on the web account and GitHub remote. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

### Ultrareview

Deep multi-agent code review running in a remote cloud sandbox.

```text
/ultrareview            # review diff between current branch and default branch
/ultrareview 1234       # review a specific GitHub PR
```

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | locally in your session | remotely in cloud sandbox |
| Depth | single-pass | multi-agent fleet with independent verification |
| Duration | seconds to minutes | ~5–10 minutes |
| Cost | normal usage | free runs, then ~$5–$20 per review as extra usage |
| Best for | quick feedback while iterating | pre-merge confidence on substantial changes |

Pricing (as of docs): Pro/Max get 3 free runs through May 5, 2026; after that, billed as extra usage. Team/Enterprise: no free runs, extra usage only. Requires Claude.ai account (not API-key-only). Not available on Bedrock, Vertex AI, or Microsoft Foundry, or with Zero Data Retention.

### Common workflow patterns

**Explore → Plan → Implement → Commit**
1. Enter Plan Mode → `read /src/auth and understand sessions`
2. `I want to add Google OAuth. What files change? Create a plan.` → `Ctrl+G` to edit
3. Switch to Normal Mode → `implement the OAuth flow. run tests and fix failures.`
4. `commit with a descriptive message and open a PR`

**Writer/Reviewer parallel sessions**
- Session A: `Implement a rate limiter for our API endpoints`
- Session B: `Review the rate limiter in @src/middleware/rateLimiter.ts. Look for edge cases and race conditions.`
- Session A: `Here's the review: [output]. Address these issues.`

**Subagent investigation (keeps main context clean)**
```text
Use subagents to investigate how our authentication system handles token
refresh, and whether we have any existing OAuth utilities I should reuse.
```

**Common workflows available:**
- Understand new codebases (broad → narrow questions)
- Fix bugs (share error + stack trace, get suggestions, apply fix)
- Refactor code (identify legacy code, get recommendations, verify with tests)
- Work with tests (find untested code, generate scaffolding, add edge cases)
- Create pull requests (`create a pr` or step-by-step with `gh pr create`)
- Handle documentation (find undocumented code, generate JSDoc, verify standards)
- Work with images (drag/drop or paste; ask Claude to analyze, compare, generate code)
- Use `@file` or `@dir` references to include content inline
- Pipe in data: `cat error.log | claude -p "explain the root cause"`

### Common failure patterns to avoid

| Anti-pattern | Fix |
| :--- | :--- |
| Kitchen sink session — unrelated tasks accumulate | `/clear` between tasks |
| Correcting over and over | After two failures, `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert habit-enforcements to hooks |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) before shipping |
| Infinite exploration — Claude reads hundreds of files | Scope investigations or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — context management, prompt strategies, CLAUDE.md, permissions, session management, parallel sessions, automation, common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step guides for codebase exploration, bug fixing, refactoring, tests, PRs, documentation, images, worktrees, Plan Mode, extended thinking, scheduled tasks, and unix-style usage
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launch, review, revise, and execute plans via Claude Code on the web
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — deep multi-agent code review in a remote cloud sandbox, pricing, comparison with /review

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
