---
name: agent-teams-doc
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances working together with shared tasks, inter-agent messaging, and centralized management.

## Quick Reference

### Prerequisites

| Requirement | Detail |
| :--- | :--- |
| **Min version** | Claude Code v2.1.32 or later (`claude --version`) |
| **Status** | Experimental, disabled by default |
| **Enable via env var** | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` |
| **Enable via settings.json** | `{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }` |

### Architecture Components

| Component | Role |
| :--- | :--- |
| **Team lead** | The main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

Storage (auto-removed when team is cleaned up):
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Agent Teams vs Subagents

| | Subagents | Agent teams |
| :--- | :--- | :--- |
| **Context** | Own context window; results return to the caller | Own context window; fully independent |
| **Communication** | Report results back to the main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

### When to Use Agent Teams

Best use cases (parallel exploration adds real value):
- **Research and review**: multiple teammates investigate different aspects simultaneously
- **New modules or features**: teammates each own a separate piece without stepping on each other
- **Debugging with competing hypotheses**: teammates test different theories in parallel
- **Cross-layer coordination**: changes spanning frontend, backend, and tests, each owned by a different teammate

Avoid for: sequential tasks, same-file edits, work with many dependencies — use a single session or subagents instead.

### Display Modes

| Mode | How it works | Requirements |
| :--- | :--- | :--- |
| **in-process** | All teammates run inside your main terminal; use Shift+Down to cycle through them | Any terminal |
| **tmux** (split panes) | Each teammate gets its own pane; see everyone's output at once | tmux or iTerm2 |
| **auto** (default) | Uses split panes if already in tmux/iTerm2, in-process otherwise | — |

Set via `~/.claude/settings.json`:
```json
{
  "teammateMode": "in-process"
}
```

Or per-session flag: `claude --teammate-mode in-process`

Split-pane mode requires [tmux](https://github.com/tmux/tmux/wiki) or iTerm2 with the `it2` CLI and Python API enabled. Not supported in VS Code integrated terminal, Windows Terminal, or Ghostty.

### Key Controls (In-Process Mode)

| Action | Control |
| :--- | :--- |
| Cycle through teammates | Shift+Down |
| Send message to current teammate | Type then Enter |
| Interrupt a teammate's current turn | Escape |
| Toggle task list | Ctrl+T |

### Task States and Coordination

Tasks have three states: **pending**, **in progress**, and **completed**. Tasks can depend on other tasks; a pending task with unresolved dependencies cannot be claimed until those are completed.

Claiming methods:
- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: after finishing, a teammate picks up the next unassigned, unblocked task on its own

Task claiming uses file locking to prevent race conditions.

### Teammate Models

Teammates don't inherit the lead's `/model` selection by default. To change the default teammate model, set **Default teammate model** in `/config`. Alternatively, specify models in your spawn prompt:

```text
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Plan Approval

Require teammates to plan before implementing for risky tasks:

```text
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

The teammate works read-only until the lead approves. On rejection, teammate revises and resubmits. The lead makes approval decisions autonomously — give it criteria in your prompt (e.g., "only approve plans that include test coverage").

### Hooks for Quality Gates

| Hook | Trigger | Exit code 2 effect |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate is about to go idle | Send feedback and keep teammate working |
| `TaskCreated` | A task is being created | Prevent creation and send feedback |
| `TaskCompleted` | A task is being marked complete | Prevent completion and send feedback |

### Permissions

Teammates start with the lead's permission settings. If the lead runs with `--dangerously-skip-permissions`, all teammates do too. Per-teammate modes can be changed after spawning, but not at spawn time.

### Context and Communication

Each teammate loads the same project context as a regular session (CLAUDE.md, MCP servers, skills) plus the spawn prompt. The lead's conversation history does not carry over.

Information sharing mechanisms:
- **Automatic message delivery**: messages delivered automatically without polling
- **Idle notifications**: when a teammate stops, it auto-notifies the lead
- **Shared task list**: all agents can see task status and claim available work
- **Direct teammate messaging**: send to one specific teammate by name

### Subagent Definitions as Teammates

Reference a subagent type by name when spawning to reuse predefined roles:

```text
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

The teammate honors that definition's `tools` allowlist and `model`. Team coordination tools (`SendMessage`, task management) are always available even when `tools` restricts others. Note: `skills` and `mcpServers` frontmatter fields from the subagent definition are NOT applied to teammates; those come from project/user settings.

### Shutdown and Cleanup

Shut down a teammate by name:
```text
Ask the researcher teammate to shut down
```

Clean up the whole team when done:
```text
Clean up the team
```

Always use the lead to clean up — teammates should not run cleanup because their team context may not resolve correctly.

### Best Practices

| Practice | Guidance |
| :--- | :--- |
| **Team size** | Start with 3–5 teammates; scale only when work genuinely benefits from parallelism |
| **Tasks per teammate** | 5–6 tasks per teammate keeps everyone productive |
| **Task sizing** | Self-contained units with a clear deliverable (a function, test file, or review) |
| **Give context** | Include task-specific details in spawn prompt — teammates don't inherit lead's history |
| **Avoid file conflicts** | Each teammate should own a different set of files |
| **Monitor** | Check in on progress and redirect approaches that aren't working |
| **Start simple** | Begin with research/review tasks (clear boundaries, no code writing) |

### Common Issues and Fixes

| Issue | Fix |
| :--- | :--- |
| Teammates not appearing | Press Shift+Down to check; verify task complexity; check tmux/iTerm2 setup |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Check their output, then give instructions directly or spawn a replacement |
| Lead shuts down too early | Tell it to keep going or wait for teammates to finish |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |
| Task status lagging | Check if work is actually done; update status manually or tell lead to nudge the teammate |

### Known Limitations (Experimental)

- No session resumption with in-process teammates (`/resume` and `/rewind` don't restore them)
- Task status can lag; dependent tasks may appear stuck
- Shutdown can be slow (teammates finish their current request first)
- One team at a time per lead
- No nested teams (teammates cannot spawn their own teams)
- Lead is fixed for the team's lifetime (no leadership transfer)
- Permissions set at spawn time (change per-teammate mode after spawn only)
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — Full guide: enabling, starting, controlling, architecture, use cases, best practices, troubleshooting, limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
