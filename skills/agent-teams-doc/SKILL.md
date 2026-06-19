---
name: agent-teams-doc
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances working together, with shared task lists, inter-agent messaging, and centralized management.

## Quick Reference

### Enable Agent Teams

Agent teams are **experimental and disabled by default**. Enable by setting the env var in `settings.json` or your shell:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs. Subagents

| | Subagents | Agent teams |
| :--- | :--- | :--- |
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

Use subagents for quick, focused workers. Use agent teams when teammates need to share findings, challenge each other, and coordinate independently.

### Architecture Components

| Component | Role |
| :--- | :--- |
| **Team lead** | The main Claude Code session that spawns teammates and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

### Storage Paths

| Path | Contents | Persistence |
| :--- | :--- | :--- |
| `~/.claude/teams/{team-name}/config.json` | Runtime state (session IDs, tmux pane IDs) | Removed when session ends |
| `~/.claude/tasks/{team-name}/` | Task list | Persists for resumed sessions; cleaned by `cleanupPeriodDays` |

Team name is `session-` followed by the first 8 characters of the session ID. Do not hand-edit the team config — it is overwritten on each state update.

### Display Modes

| Mode | Description | Requirement |
| :--- | :--- | :--- |
| `"in-process"` | All teammates run inside your main terminal (default as of v2.1.179) | Any terminal |
| `"auto"` | Split panes when inside tmux or iTerm2, otherwise in-process | tmux or iTerm2 |
| `"tmux"` | Split panes, auto-detects tmux vs. iTerm2 | tmux or iTerm2 with `it2` CLI |

Set `teammateMode` in `~/.claude/settings.json` or pass `--teammate-mode <mode>` for a single session.

In-process mode controls (agent panel below prompt input):
- **Up/Down arrows**: select a teammate
- **Enter**: open the selected teammate's transcript and message it directly
- **Escape**: interrupt the selected teammate's current turn
- **x** on a selected teammate: stop it
- **Ctrl+T**: toggle the task list

As of v2.1.181, an idle teammate's row hides after 30 seconds and reappears on its next turn — the teammate stays running and addressable while hidden.

### Task States and Claiming

Tasks have three states: `pending`, `in progress`, and `completed`. Tasks can depend on other tasks; a pending task with unresolved dependencies cannot be claimed until those dependencies are completed.

- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: after finishing a task, a teammate picks up the next unassigned, unblocked task
- File locking prevents race conditions when multiple teammates try to claim the same task simultaneously

### Quality Gate Hooks

| Hook event | When it fires | Can block? |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate about to go idle | Yes — exit code 2 sends feedback and keeps it working |
| `TaskCreated` | Task being created | Yes — exit code 2 prevents creation and sends feedback |
| `TaskCompleted` | Task being marked complete | Yes — exit code 2 prevents completion and sends feedback |

### Permissions

Teammates start with the lead's permission settings. If the lead runs with `--dangerously-skip-permissions`, all teammates do too. Per-teammate modes can be changed after spawning but not set at spawn time.

### Context and Communication

Each teammate starts with the same project context as a regular session (CLAUDE.md, MCP servers, skills) plus the spawn prompt from the lead. The lead's conversation history does not carry over.

- Messages are delivered automatically; the lead does not need to poll
- Idle teammates automatically notify the lead when they stop
- All agents share visibility into the task list
- Teammates can message each other by name; to broadcast, send one message per recipient

### Using Subagent Definitions as Teammates

Reference any subagent type by name when spawning:

```
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

The teammate honors that definition's `tools` allowlist and `model`. Team coordination tools (`SendMessage`, task management) are always available even when `tools` restricts other tools. Note: `skills` and `mcpServers` frontmatter fields from a subagent definition are **not** applied when that definition runs as a teammate.

### Best Practices

| Practice | Guidance |
| :--- | :--- |
| **Team size** | Start with 3-5 teammates; aim for 5-6 tasks per teammate |
| **Task size** | Self-contained units with a clear deliverable (a function, test file, or review) |
| **Context** | Include task-specific details in the spawn prompt; teammates don't inherit lead history |
| **File conflicts** | Break work so each teammate owns a different set of files |
| **Waiting** | Tell the lead "wait for your teammates to complete their tasks before proceeding" if it starts implementing instead of delegating |
| **Getting started** | Begin with research/review tasks (no code writes) to learn coordination dynamics |

### Strongest Use Cases

- **Research and review**: multiple teammates investigate different aspects simultaneously, share and challenge findings
- **New modules or features**: teammates each own a separate piece without stepping on each other
- **Debugging with competing hypotheses**: teammates test different theories in parallel and converge faster
- **Cross-layer coordination**: changes spanning frontend, backend, and tests, each owned by a different teammate

Avoid agent teams for sequential tasks, same-file edits, or work with many dependencies — a single session or subagents are more effective.

### Limitations (Experimental)

| Limitation | Details |
| :--- | :--- |
| **No session resumption with in-process teammates** | `/resume` and `/rewind` do not restore in-process teammates |
| **Task status can lag** | Teammates sometimes fail to mark tasks completed; check and update manually |
| **Slow shutdown** | Teammates finish their current request before shutting down |
| **One team per session** | Can't create additional named teams or share a team across sessions |
| **No nested teams** | Teammates cannot spawn their own teammates |
| **Fixed lead** | The main session is the lead for its lifetime; leadership cannot be transferred |
| **Split panes require tmux or iTerm2** | Not supported in VS Code's integrated terminal, Windows Terminal, or Ghostty |

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Teammates not appearing | Check agent panel (in-process mode); a hidden idle row reappears on next turn; verify task was complex enough to warrant a team |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Select the teammate in agent panel, press Enter, give additional instructions or spawn a replacement |
| Lead shuts down early | Tell it to keep going; instruct it to wait for teammates before proceeding |
| Orphaned tmux sessions | Run `tmux ls` and `tmux kill-session -t <session-name>` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — Enable, start, control, and troubleshoot agent teams; architecture, context, permissions, use case examples, best practices, and limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
