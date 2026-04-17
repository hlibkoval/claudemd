---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, ultraplan (cloud-based planning), and ultrareview (deep multi-agent code review).
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, ultraplan, and ultrareview.

## Quick Reference

### Core principle

Claude's context window is the most important resource to manage. Performance degrades as context fills. Use `/clear` between unrelated tasks, `/compact` to summarize, and subagents to offload research into separate contexts.

### High-leverage patterns

| Pattern | What to do | Why |
| :------ | :--------- | :-- |
| **Give Claude a way to verify** | Provide tests, screenshots, or expected outputs | Single highest-leverage habit; without verification Claude can produce plausible but broken code |
| **Explore, plan, then code** | Use Plan Mode (Shift+Tab) to research and plan before switching to Normal Mode to implement | Prevents solving the wrong problem; skip for trivial changes |
| **Be specific** | Reference files, mention constraints, point to example patterns | Reduces correction cycles |
| **Provide rich content** | Use `@file`, paste images, pipe data, give URLs | More context upfront means fewer misunderstandings |

### Environment setup checklist

| Setup | How |
| :---- | :-- |
| **CLAUDE.md** | Run `/init`; keep under 200 lines; include build commands, code style, workflow rules |
| **Permissions** | Auto mode, allowlists (`/permissions`), or `/sandbox` for OS-level isolation |
| **CLI tools** | Install `gh`, `aws`, `gcloud`, etc.; Claude uses them for context-efficient API access |
| **MCP servers** | `claude mcp add` for Notion, Figma, databases, etc. |
| **Hooks** | Deterministic scripts at specific points in Claude's workflow; `/hooks` to browse |
| **Skills** | `.claude/skills/<name>/SKILL.md` for domain knowledge loaded on demand |
| **Subagents** | `.claude/agents/<name>.md` for isolated, specialized assistants |
| **Plugins** | `/plugin` to browse the marketplace |

### Session management

| Action | Shortcut / command |
| :----- | :----------------- |
| Stop mid-action | `Esc` |
| Rewind (restore conversation/code) | `Esc` + `Esc` or `/rewind` |
| Undo last change | "Undo that" |
| Clear context | `/clear` |
| Compact context | `/compact [focus instructions]` |
| Side question (no context cost) | `/btw` |
| Resume last session | `claude --continue` |
| Pick a session to resume | `claude --resume` |
| Resume by name | `claude --resume <name>` |
| Name a session | `claude -n <name>` or `/rename <name>` |

### Scaling patterns

| Pattern | Command / approach |
| :------ | :----------------- |
| Non-interactive (CI/scripts) | `claude -p "prompt"` with `--output-format text\|json\|stream-json` |
| Parallel sessions | Desktop app, Claude Code on the web, or agent teams |
| Fan out across files | Loop `claude -p` per file; use `--allowedTools` to scope |
| Writer/Reviewer | Session A implements, Session B reviews with fresh context |
| Auto mode (unattended) | `claude --permission-mode auto -p "..."` |
| Scheduled tasks | Routines, desktop scheduled tasks, GitHub Actions, or `/loop` |

### Common failure patterns

| Anti-pattern | Fix |
| :----------- | :-- |
| Kitchen-sink session (mixed topics) | `/clear` between unrelated tasks |
| Repeated corrections (>2) | `/clear` and rewrite the prompt with what you learned |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks if possible |
| Trust-then-verify gap | Always provide tests or scripts; don't ship unverified |
| Infinite exploration | Scope narrowly or delegate to subagents |

### Common workflows at a glance

| Workflow | Key steps |
| :------- | :-------- |
| **Explore a codebase** | Ask broad questions, then narrow; use domain language |
| **Fix bugs** | Share the error, ask for fixes, apply and verify |
| **Refactor** | Identify targets, get recommendations, apply in small increments, run tests |
| **Write tests** | Find untested code, generate scaffolding, add edge cases, run and fix |
| **Create PRs** | Summarize changes, `create a pr`, review before submitting |
| **Plan Mode** | `Shift+Tab` to enter; `Ctrl+G` to edit plan in editor; `--permission-mode plan` from CLI |
| **Git worktrees** | `claude --worktree <name>` for isolated parallel sessions |

### Extended thinking

Extended thinking is enabled by default. Models with adaptive reasoning dynamically allocate thinking tokens based on the effort level.

| Control | How |
| :------ | :-- |
| Effort level | `/effort`, `/model`, or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| `ultrathink` keyword | Include in prompt for deeper reasoning on one turn |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| Global default | `/config` to toggle (`alwaysThinkingEnabled` in settings) |
| Limit budget | `MAX_THINKING_TOKENS` env var |
| View thinking | `Ctrl+O` to toggle verbose mode |

### Ultraplan

Ultraplan hands a planning task from your local CLI to a Claude Code on the web session running in plan mode. The plan drafts in the cloud while your terminal stays free.

| Launch method | How |
| :------------ | :-- |
| Command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` in any prompt |
| From local plan | Choose "No, refine with Ultraplan" at the plan approval dialog |

Status indicators: `ultraplan` (drafting), `ultraplan needs your input` (clarifying question), `ultraplan ready` (review in browser). Use `/tasks` to manage.

Execution options after review: **Approve and start coding** (stays on the web, creates PR) or **Approve and teleport back to terminal** (implement locally). Requires Claude Code on the web account and GitHub repo.

### Ultrareview

Ultrareview is a deep, multi-agent code review that runs in a remote sandbox. Every finding is independently reproduced and verified.

| Aspect | Detail |
| :----- | :----- |
| Launch | `/ultrareview` (current branch vs default) or `/ultrareview <PR#>` |
| Duration | ~5-10 minutes |
| Cost | 3 free runs (one-time, Pro/Max), then ~$5-$20 per review as extra usage |
| Track | `/tasks` to see status, open detail view, or stop |
| Requires | Claude.ai auth; not available on Bedrock/Vertex/Foundry or with ZDR |

Compared to `/review`: ultrareview is deeper (multi-agent fleet with verification), slower (~5-10 min vs seconds), runs remotely, and costs extra usage. Use `/review` while iterating; use `/ultrareview` before merging substantial changes.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) — Tips and patterns for getting the most out of Claude Code: verification, planning, prompting, environment setup (CLAUDE.md, permissions, CLI tools, MCP, hooks, skills, subagents, plugins), communication techniques, session management (context, checkpoints, resume), scaling with parallel sessions and fan-out, common failure patterns, and developing intuition.
- [Common Workflows](references/claude-code-common-workflows.md) — Step-by-step recipes for exploring codebases, fixing bugs, refactoring, using subagents, Plan Mode, writing tests, creating PRs, handling documentation, working with images, referencing files, extended thinking, resuming sessions, git worktrees, notifications, using Claude as a unix utility, scheduling tasks, and asking about capabilities.
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — Launch ultraplan from the CLI, review and revise plans in the browser with inline comments, and choose to execute on the web or teleport back to your terminal.
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — Run `/ultrareview` for deep multi-agent code review in a cloud sandbox, pricing and free runs, tracking running reviews, and how it compares to `/review`.

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
