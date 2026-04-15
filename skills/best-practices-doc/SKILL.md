---
name: best-practices-doc
description: Official Claude Code best practices, common workflow recipes, and the ultraplan cloud planning feature - covering context management, plan mode, prompting, sessions, parallel work, and step-by-step guides for everyday development tasks.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and the ultraplan feature.

## Quick Reference

### Core principle: protect the context window

Claude's context window holds the entire conversation, file reads, and command outputs. Performance degrades as it fills, so context is the fundamental resource to manage. Most best practices follow from this constraint.

### Top best practices

| Practice | Why it matters |
| --- | --- |
| Give Claude a way to verify its work (tests, screenshots, expected outputs) | Highest-leverage thing you can do; without it Claude may produce plausible-looking but broken code |
| Explore -> Plan -> Implement -> Commit | Use Plan Mode to separate research from execution and avoid solving the wrong problem |
| Provide specific context | Reference files with `@`, point to example patterns, scope tasks tightly |
| Write a concise CLAUDE.md | Persistent context Claude can't infer from code; ruthlessly prune bloat |
| Course-correct early | Esc to interrupt, Esc+Esc or `/rewind` to checkpoint, `/clear` between unrelated tasks |
| Use subagents for investigation | They run in separate context windows and report summaries back |
| Configure permissions | Auto mode, allowlists, or sandboxing reduce approval fatigue |

### The four-phase workflow

1. **Explore** — Plan Mode, read files and answer questions, no edits
2. **Plan** — Ask Claude for a detailed implementation plan (Ctrl+G to edit in your editor)
3. **Implement** — Switch to Normal Mode, code against the plan, run tests
4. **Commit** — Descriptive message and PR

Skip planning when the diff is one sentence (typo fixes, log lines, renames).

### Session management cheatsheet

| Action | Command / shortcut |
| --- | --- |
| Stop Claude mid-action | Esc |
| Open rewind menu (restore conversation/code) | Esc Esc or `/rewind` |
| Reset context entirely | `/clear` |
| Compact with focus | `/compact <instructions>` |
| Side question without polluting context | `/btw` |
| Resume most recent conversation | `claude --continue` |
| Pick from recent sessions | `claude --resume` |
| Resume by name | `claude --resume <name>` |
| Resume PR-linked session | `claude --from-pr <number>` |
| Name a session | `claude -n <name>` or `/rename` |

### CLAUDE.md guidance

| Include | Exclude |
| --- | --- |
| Bash commands Claude can't guess | Things Claude can read from code |
| Code style rules that differ from defaults | Standard language conventions |
| Test runners and testing instructions | Detailed API docs (link instead) |
| Repo etiquette (branch names, PR rules) | Frequently-changing info |
| Architectural decisions | Long tutorials |
| Env quirks and required env vars | File-by-file descriptions |
| Common gotchas | Self-evident "write clean code" |

CLAUDE.md locations: `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project, checked in), `./CLAUDE.local.md` (personal, gitignored), parent dirs (monorepos), child dirs (loaded on demand). Imports use `@path/to/file` syntax.

### Plan Mode

| How to enter | Notes |
| --- | --- |
| Shift+Tab (cycle through modes) | First press = auto-accept, second = plan |
| `claude --permission-mode plan` | Start a session in Plan Mode |
| `claude --permission-mode plan -p "..."` | Headless plan-only run |
| `"defaultMode": "plan"` in `.claude/settings.json` | Make Plan Mode the default |
| Ctrl+G | Open current plan in your text editor |

### Headless and scripting

```bash
claude -p "Explain this project"
claude -p "List endpoints" --output-format json
claude -p "Analyze log" --output-format stream-json
claude --permission-mode auto -p "fix all lint errors"
```

Output formats: `text` (default), `json` (full conversation log), `stream-json` (real-time per-message JSON).

### Parallel sessions

| Method | Use case |
| --- | --- |
| Desktop app sessions | Visual local management, isolated worktrees |
| Claude Code on the web | Anthropic-managed cloud VMs |
| Agent teams | Coordinated multi-session workflows with shared tasks |
| Git worktrees (`claude --worktree <name>`) | Isolated branch+dir for parallel CLI work |

Worktrees live at `<repo>/.claude/worktrees/<name>` and branch from `origin/HEAD`. Add `.worktreeinclude` to copy gitignored files (`.env`, etc.) into new worktrees. Subagent worktrees can be enabled with `isolation: worktree` in agent frontmatter.

### Fan-out pattern

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

Test on a few files first, then scale. Use `--allowedTools` to scope permissions for unattended runs.

### Scheduled tasks comparison

| Option | Where it runs | Best for |
| --- | --- | --- |
| Routines | Anthropic cloud | Tasks that run when computer is off; can trigger on API/GitHub events |
| Desktop scheduled tasks | Local desktop app | Tasks needing local files or uncommitted changes |
| GitHub Actions | CI pipeline | Repo events, cron schedules in workflow config |
| `/loop` | Current CLI session | Quick polling while a session is open; cancelled on exit |

### Common failure patterns

- **Kitchen sink session** -> `/clear` between unrelated tasks
- **Correcting over and over** -> after two failed corrections, `/clear` and write a better prompt
- **Over-specified CLAUDE.md** -> ruthlessly prune; convert rules to hooks if possible
- **Trust-then-verify gap** -> always provide verification (tests, scripts, screenshots)
- **Infinite exploration** -> scope investigations or delegate to subagents

### Common workflow recipes

| Workflow | Key steps |
| --- | --- |
| Codebase overview | `cd` into project, `claude`, ask broad then narrow questions |
| Find code | "find files that handle X" -> "trace the flow from front-end to DB" |
| Fix bug | Share error/stack trace -> ask for fixes -> apply -> verify |
| Refactor | Identify legacy -> get recommendations -> apply -> run tests |
| Add tests | Find untested code -> scaffold -> add edge cases -> run |
| Create PR | "summarize my changes" -> "create a pr" -> refine description |
| Documentation | Find undocumented -> generate -> review/enhance -> verify standards |
| Work with images | Drag/drop or paste (ctrl+v, not cmd+v) -> ask Claude to analyze |
| Reference files | `@path/to/file`, `@dir`, `@server:resource` for MCP |

### Extended thinking

Enabled by default. Toggle/configure with:

| Scope | How |
| --- | --- |
| Effort level (Opus/Sonnet 4.6 adaptive) | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` |
| One-off high effort | Include `ultrathink` keyword in prompt |
| Toggle for session | Option+T (macOS) / Alt+T (Win/Linux) |
| Global default | `/config` (saved as `alwaysThinkingEnabled`) |
| Limit token budget | `MAX_THINKING_TOKENS` env var |

Press Ctrl+O to view thinking process in verbose mode. Phrases like "think hard" are NOT special - they're just regular prompt text.

### Notification hook quick example (macOS)

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

Matcher values: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`.

### Ultraplan (cloud planning)

Hands a planning task from the local CLI to a Claude Code on the web session running in plan mode. Requires Claude Code v2.1.91+ and a Claude Code on the web account with a GitHub repo. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

| Launch method | How |
| --- | --- |
| Slash command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` in any normal prompt |
| From a local plan | Choose "No, refine with Ultraplan" in the plan approval dialog |

| Status indicator | Meaning |
| --- | --- |
| `ultraplan` | Researching your codebase and drafting |
| `ultraplan needs your input` | Open the session link to answer a question |
| `ultraplan ready` | Plan ready to review in browser |

Review in browser with inline comments, emoji reactions, and outline sidebar. When approved, choose:

- **Approve and start coding** — execute on the web, opens a PR
- **Approve and teleport back to terminal** — implement locally; choose "Implement here", "Start new session", or "Cancel" (saves plan to file)

Use `/tasks` and select the ultraplan entry to view session link, agent activity, and a Stop action.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — patterns for managing context, prompting, planning, sessions, parallel work, and avoiding common failure modes
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step recipes for codebase exploration, debugging, refactoring, testing, PRs, images, worktrees, scheduling, and Unix-style usage
- [Ultraplan](references/claude-code-ultraplan.md) — research-preview feature that drafts plans on Claude Code on the web while your terminal stays free, then executes on the web or back in your terminal

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
