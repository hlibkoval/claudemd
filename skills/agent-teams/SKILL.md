---
name: agent-teams
description: Reference documentation for Claude Code agent teams — orchestrating multiple Claude Code sessions working in parallel with shared task lists, inter-agent messaging, and centralized coordination. Use when creating agent teams, configuring teammates, choosing display modes, assigning tasks, enabling split panes, comparing agent teams vs subagents, or troubleshooting team coordination.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

Agent teams coordinate multiple Claude Code instances working together. One session acts as the **team lead**, spawning **teammates** that work independently in their own context windows and communicate directly with each other via a shared **mailbox** and **task list**.

**Experimental feature** — enable via settings or environment variable:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs Subagents

| Aspect              | Subagents                                    | Agent Teams                                       |
|:--------------------|:---------------------------------------------|:--------------------------------------------------|
| **Context**         | Own context; results return to caller        | Own context; fully independent                    |
| **Communication**   | Report results back to main agent only       | Teammates message each other directly             |
| **Coordination**    | Main agent manages all work                  | Shared task list with self-coordination           |
| **Best for**        | Focused tasks where only the result matters  | Complex work requiring discussion and collaboration |
| **Token cost**      | Lower: results summarized back               | Higher: each teammate is a separate instance      |

### Architecture Components

| Component       | Role                                                                  |
|:----------------|:----------------------------------------------------------------------|
| **Team lead**   | Main session that creates, spawns, and coordinates the team           |
| **Teammates**   | Separate Claude Code instances working on assigned tasks              |
| **Task list**   | Shared work items with states: pending, in progress, completed        |
| **Mailbox**     | Messaging system for direct inter-agent communication                 |

### Storage Locations

| Data          | Path                                    |
|:--------------|:----------------------------------------|
| Team config   | `~/.claude/teams/{team-name}/config.json` |
| Task list     | `~/.claude/tasks/{team-name}/`          |

### Display Modes

| Mode           | Setting value   | Description                                              |
|:---------------|:----------------|:---------------------------------------------------------|
| Auto (default) | `"auto"`        | Split panes if inside tmux, in-process otherwise         |
| In-process     | `"in-process"`  | All teammates in main terminal; Shift+Up/Down to select  |
| Split panes    | `"tmux"`        | Each teammate in own pane; requires tmux or iTerm2       |

Configure in settings or via CLI flag:

```json
{ "teammateMode": "in-process" }
```

```bash
claude --teammate-mode in-process
```

### In-Process Mode Controls

| Key           | Action                                  |
|:--------------|:----------------------------------------|
| Shift+Up/Down | Select a teammate                       |
| Enter         | View a teammate's session               |
| Escape        | Interrupt teammate's current turn       |
| Ctrl+T        | Toggle the task list                    |

### Task States and Dependencies

Tasks have three states: **pending**, **in progress**, and **completed**. Tasks can depend on other tasks — a pending task with unresolved dependencies cannot be claimed until those dependencies are completed. File locking prevents race conditions on concurrent claims.

### Quality Gate Hooks

| Hook Event       | When it fires                        | Exit code 2 behavior                    |
|:-----------------|:-------------------------------------|:-----------------------------------------|
| `TeammateIdle`   | Teammate about to go idle            | Sends feedback, keeps teammate working   |
| `TaskCompleted`  | Task being marked as completed       | Prevents completion, sends feedback      |

### Best Use Cases

- **Research and review**: parallel investigation of different problem aspects
- **New modules/features**: teammates each own separate pieces
- **Debugging with competing hypotheses**: test different theories simultaneously
- **Cross-layer coordination**: frontend, backend, tests owned by different teammates

### Key Limitations

- No session resumption with in-process teammates ( `/resume` and `/rewind` do not restore them)
- One team per session; no nested teams
- Lead is fixed for the team's lifetime
- All teammates start with the lead's permission mode
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty
- Task status can lag; teammates may fail to mark tasks completed
- Shutdown can be slow (teammates finish current tool call first)

### Permissions

Teammates inherit the lead's permission settings at spawn time. Individual modes can be changed after spawning but not at spawn time.

### Context Inheritance

Teammates load project context (CLAUDE.md, MCP servers, skills) but do **not** inherit the lead's conversation history. Include task-specific details in the spawn prompt.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent Teams](references/claude-code-agent-teams.md) — complete documentation including enabling teams, display modes, task coordination, architecture, use case examples, best practices, troubleshooting, and limitations

## Sources

- Agent Teams: https://code.claude.com/docs/en/agent-teams.md
