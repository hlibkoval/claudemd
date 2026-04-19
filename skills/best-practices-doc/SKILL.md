---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices — prompting patterns, context management, environment setup, common workflows, Plan Mode, parallel sessions, ultraplan, and ultrareview.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, ultraplan, and ultrareview.

## Quick Reference

### Core principle

Claude's **context window** is the most important resource to manage. Performance degrades as context fills. Use `/clear` between unrelated tasks, `/compact` to summarize, and subagents for research that reads many files.

### High-leverage practices

| Practice | Why it matters |
| :--- | :--- |
| **Give Claude a way to verify its work** | Tests, screenshots, or expected outputs let Claude self-correct. Single highest-leverage thing you can do. |
| **Explore, plan, then code** | Separate research (Plan Mode) from implementation to avoid solving the wrong problem. |
| **Provide specific context** | Reference files with `@`, paste images, give URLs, pipe data with `cat file \| claude`. |
| **Course-correct early** | `Esc` to stop, `Esc+Esc` or `/rewind` to restore state, `/clear` after two failed corrections. |
| **Use subagents for investigation** | Keeps research out of your main context. Subagents explore and report back summaries. |

### Prompting patterns

| Strategy | Weak prompt | Strong prompt |
| :--- | :--- | :--- |
| Verification criteria | "implement email validation" | "write validateEmail, test with these cases, run tests after" |
| Scope the task | "add tests for foo.py" | "test foo.py covering logged-out edge case, avoid mocks" |
| Point to sources | "why is this API weird?" | "look through git history and summarize how the API evolved" |
| Reference patterns | "add a calendar widget" | "follow the pattern in HotDogWidget.php, build a calendar widget" |
| Describe symptoms | "fix the login bug" | "login fails after timeout, check src/auth/ token refresh, write a failing test" |

### Environment setup checklist

| Setup | How |
| :--- | :--- |
| **CLAUDE.md** | `/init` to generate, then prune. Keep under 200 lines. Check into git. |
| **Permissions** | Auto mode, allowlists (`/permissions`), or `/sandbox` for OS isolation. |
| **CLI tools** | Install `gh`, `aws`, `gcloud`, etc. Claude uses them efficiently. |
| **MCP servers** | `claude mcp add` for Notion, Figma, databases, etc. |
| **Hooks** | Deterministic actions (lint after edit, block writes to migrations). |
| **Skills** | Domain knowledge in `.claude/skills/<name>/SKILL.md`. |
| **Subagents** | Specialized assistants in `.claude/agents/<name>.md`. |
| **Plugins** | `/plugin` to browse marketplace. Install code intelligence for typed languages. |

### Session management

| Action | Command/key |
| :--- | :--- |
| Stop mid-action | `Esc` |
| Rewind to checkpoint | `Esc+Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Clear context | `/clear` |
| Compact context | `/compact` or `/compact Focus on API changes` |
| Partial compact | `Esc+Esc` then **Summarize from here** |
| Side question (no context cost) | `/btw` |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` |
| Name a session | `claude -n auth-refactor` or `/rename auth-refactor` |

### Plan Mode

Enter with `Shift+Tab` (cycle modes) or start with `claude --permission-mode plan`. Claude analyzes code read-only and proposes a plan. Press `Ctrl+G` to edit the plan in your text editor. When the plan is accepted, Claude auto-names the session.

Set as default:

```json
{ "permissions": { "defaultMode": "plan" } }
```

### Common workflows at a glance

| Workflow | Key prompts |
| :--- | :--- |
| **Explore codebase** | "give me an overview", "explain architecture", "trace the login flow" |
| **Fix bugs** | Share error, ask for fix suggestions, apply and verify |
| **Refactor** | "find deprecated usage", "refactor to ES2024, maintain behavior", run tests |
| **Write tests** | "find untested functions", "add edge-case tests", "run and fix failures" |
| **Create PRs** | "create a pr" (auto-links session; resume later with `claude --from-pr N`) |
| **Documentation** | "find undocumented functions", "add JSDoc", "verify standards" |
| **Images** | Drag/drop, paste, or give path. Use for errors, designs, diagrams. |
| **File references** | `@src/utils/auth.js` includes file content; `@src/components` lists directory |

### Scaling and automation

| Pattern | How |
| :--- | :--- |
| **Non-interactive mode** | `claude -p "prompt"` for CI, scripts, hooks. Use `--output-format json` or `stream-json`. |
| **Parallel sessions** | Desktop app, Claude Code on the web, or agent teams. |
| **Writer/Reviewer** | Session A implements, Session B reviews with fresh context. |
| **Fan out** | Loop `claude -p` over a file list with `--allowedTools` to scope permissions. |
| **Auto mode** | `claude --permission-mode auto -p "fix all lint errors"` — classifier handles approvals. |
| **Scheduled tasks** | Routines (cloud), desktop scheduled tasks, GitHub Actions, or `/loop`. |
| **Pipe in/out** | `cat error.log \| claude -p "explain" > output.txt` |

### Extended thinking

Enabled by default. Adjust depth with `/effort` or `CLAUDE_CODE_EFFORT_LEVEL` env var. Include "ultrathink" in a prompt for deeper reasoning on that turn. Toggle with `Option+T` / `Alt+T`. View reasoning with `Ctrl+O` (verbose mode).

### Ultraplan

Launch with `/ultraplan <prompt>` or include "ultraplan" in a prompt. Hands planning to a Claude Code on the web session in plan mode while your terminal stays free. Review the plan in your browser with inline comments and emoji reactions. Execute on the web (opens a PR) or send back to your terminal.

| CLI status | Meaning |
| :--- | :--- |
| `ultraplan` | Drafting the plan |
| `ultraplan needs your input` | Clarifying question in browser |
| `ultraplan ready` | Ready for review |

Requires Claude Code on the web account and GitHub repo. Not available on Bedrock, Vertex AI, or Foundry.

### Ultrareview

Run `/ultrareview` (branch diff) or `/ultrareview 1234` (PR). Launches a fleet of reviewer agents in a remote sandbox. Every finding is independently reproduced and verified. Takes 5-10 minutes. Track with `/tasks`.

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| **Runs** | Locally | Remote sandbox |
| **Depth** | Single-pass | Multi-agent with verification |
| **Duration** | Seconds-minutes | 5-10 minutes |
| **Cost** | Normal usage | 3 free runs, then ~$5-$20 per review (extra usage) |
| **Best for** | Quick iteration feedback | Pre-merge confidence |

Requires Claude.ai auth. Not available on Bedrock, Vertex AI, Foundry, or with Zero Data Retention.

### Common failure patterns

| Anti-pattern | Fix |
| :--- | :--- |
| Kitchen-sink session (unrelated tasks) | `/clear` between tasks |
| Repeated corrections (3+ attempts) | `/clear`, write a better prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks |
| Trust-then-verify gap | Always provide verification |
| Infinite exploration | Scope narrowly or use subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — tips and patterns for getting the most out of Claude Code: verification, planning, prompting, environment setup (CLAUDE.md, permissions, CLI tools, MCP, hooks, skills, subagents, plugins), communication, session management (context, checkpoints, resume), scaling (non-interactive mode, parallel sessions, fan-out, auto mode), extended thinking, and common failure patterns.
- [Common Workflows](references/claude-code-common-workflows.md) — step-by-step guides for exploring codebases, fixing bugs, refactoring, using subagents, Plan Mode, writing tests, creating PRs, handling documentation, working with images, file references, extended thinking, resuming sessions, git worktrees, notifications, Unix-style usage, and scheduled tasks.
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launch ultraplan from the CLI, review and revise plans in the browser with inline comments, and choose to execute on the web or send back to terminal.
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — run a deep multi-agent code review in a remote sandbox, pricing and free runs, tracking running reviews, and comparison with `/review`.

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
