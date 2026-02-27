---
name: agent-teams
description: Complete documentation for Claude Code agent teams — coordinating multiple Claude Code instances working in parallel, with shared task lists, inter-agent messaging, and team lead/teammate architecture. Load when discussing parallel Claude sessions, multi-agent coordination, teammate spawning, or task delegation across sessions.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

Agent teams are **experimental** and disabled by default. Enable with:

```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

### Agent Teams vs Subagents

| | Subagents | Agent Teams |
|:--|:--|:--|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only result matters | Complex work requiring inter-agent discussion |
| **Token cost** | Lower | Higher (each teammate is a separate Claude instance) |

### Architecture Components

| Component | Role |
|:--|:--|
| **Team lead** | Main session that creates the team, spawns teammates, coordinates |
| **Teammates** | Separate Claude Code instances that claim and complete tasks |
| **Task list** | Shared work items; teammates self-claim unblocked tasks |
| **Mailbox** | Messaging system for direct agent-to-agent communication |

Storage locations: `~/.claude/teams/{team-name}/config.json` and `~/.claude/tasks/{team-name}/`

### Display Modes

| Mode | Description | Config value |
|:--|:--|:--|
| `auto` (default) | Split panes if in tmux, in-process otherwise | `"auto"` |
| In-process | All teammates in main terminal; Shift+Down to cycle | `"in-process"` |
| Split panes | Each teammate in its own pane; requires tmux or iTerm2 | `"tmux"` |

Set in `settings.json` as `"teammateMode"`, or override per session: `claude --teammate-mode in-process`

### Keyboard Shortcuts (In-Process Mode)

| Key | Action |
|:--|:--|
| Shift+Down | Cycle through active teammates |
| Enter | View a teammate's session |
| Escape | Interrupt current turn |
| Ctrl+T | Toggle task list |

### Relevant Hooks

| Hook | Trigger | Exit 2 effect |
|:--|:--|:--|
| `TeammateIdle` | Teammate about to go idle | Sends feedback; keeps teammate working |
| `TaskCompleted` | Task being marked complete | Prevents completion; sends feedback |

### Best Practices

- **Team size**: 3-5 teammates for most workflows; 5-6 tasks per teammate
- **Task granularity**: self-contained units producing a clear deliverable (function, test file, review)
- **Context**: include task-specific details in spawn prompt — teammates do not inherit lead's history
- **File conflicts**: ensure each teammate owns distinct files
- **Cleanup**: always use the lead to clean up; teammates cannot safely run cleanup

### Known Limitations

- No `/resume` or `/rewind` for in-process teammates
- Task status can lag (stuck tasks may need manual nudge)
- One team per lead session; no nested teams
- Teammates cannot promote to lead or spawn sub-teams
- All teammates inherit lead's permission mode at spawn time
- Split panes require tmux or iTerm2 (not VS Code terminal, Windows Terminal, or Ghostty)

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent Teams](references/claude-code-agent-teams.md) — full guide covering setup, architecture, display modes, task coordination, hooks, use cases, best practices, and troubleshooting

## Sources

- Agent Teams: https://code.claude.com/docs/en/agent-teams.md
