---
name: agent-teams
description: Reference documentation for Claude Code agent teams — coordinating multiple Claude Code sessions in parallel with a shared task list, inter-agent messaging, display modes, hooks, and best practices. Use when setting up agent teams, comparing agent teams to subagents, configuring teammate display modes, assigning tasks, enforcing quality gates, or troubleshooting team coordination.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for orchestrating teams of Claude Code sessions.

## Quick Reference

Agent teams coordinate multiple Claude Code instances. One session acts as the team lead; teammates work independently and communicate directly with each other via a shared task list and mailbox.

> Agent teams are **experimental** and disabled by default.

### Enable Agent Teams

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs. Subagents

| | Subagents | Agent Teams |
|:--|:--|:--|
| **Context** | Own window; results return to caller | Own window; fully independent |
| **Communication** | Report back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower | Higher — each teammate is a separate Claude instance |

### Architecture

| Component | Role |
|:----------|:-----|
| **Team lead** | Main session that creates the team, spawns teammates, coordinates work |
| **Teammates** | Separate Claude Code instances that claim and complete tasks |
| **Task list** | Shared work items with pending / in-progress / completed states |
| **Mailbox** | Messaging system for direct inter-agent communication |

Storage locations:
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Display Modes

| Mode | How to set | Requirements |
|:-----|:-----------|:-------------|
| `auto` (default) | — | Uses split panes inside tmux, in-process otherwise |
| `in-process` | `teammateMode: "in-process"` in settings, or `--teammate-mode in-process` flag | Any terminal |
| `tmux` (split panes) | `teammateMode: "tmux"` | tmux or iTerm2 with `it2` CLI |

- **In-process navigation**: Shift+Down cycles teammates; Enter views a session; Escape interrupts; Ctrl+T toggles task list.
- **Split-pane mode**: not supported in VS Code integrated terminal, Windows Terminal, or Ghostty.

### Task States

Tasks have three states: **pending**, **in progress**, **completed**. Tasks with unresolved dependencies cannot be claimed until those dependencies complete. File locking prevents race conditions when multiple teammates claim simultaneously.

### Quality Gate Hooks

| Hook | Trigger | Exit code 2 effect |
|:-----|:--------|:-------------------|
| `TeammateIdle` | Teammate about to go idle | Send feedback, keep teammate working |
| `TaskCompleted` | Task being marked complete | Prevent completion, send feedback |

### Teammate Messaging

- **message**: send to one specific teammate
- **broadcast**: send to all teammates simultaneously (use sparingly — costs scale with team size)

### Permissions

Teammates inherit the lead's permission settings at spawn time. Per-teammate modes can be changed after spawning but cannot be set at spawn time. If the lead uses `--dangerously-skip-permissions`, all teammates do too.

### Limitations

- No session resumption for in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag — teammates may not mark tasks complete, blocking dependents
- Shutdown can be slow — teammates finish their current request first
- One team per session; clean up before starting a new one
- No nested teams — teammates cannot spawn their own teams
- Lead is fixed — cannot be promoted or transferred

### Best Practices

- Give spawn prompts enough task-specific context (teammates do not inherit the lead's conversation history)
- Size tasks to produce a clear deliverable — aim for 5-6 tasks per teammate
- Break work so each teammate owns different files (avoid same-file edits)
- Start with research/review tasks before attempting parallel implementation
- Monitor and steer; do not let a team run unattended too long
- Always clean up using the lead (`ask the lead to clean up`), not a teammate

### Cleanup

```
Clean up the team
```

The lead checks for active teammates and fails if any are still running — shut them down first.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent Teams](references/claude-code-agent-teams.md) — full guide including architecture, display modes, task coordination, hooks, use case examples, troubleshooting, and limitations

## Sources

- Agent Teams: https://code.claude.com/docs/en/agent-teams.md
