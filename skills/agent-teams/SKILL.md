---
name: agent-teams
description: Reference documentation for Claude Code agent teams — orchestrating multiple Claude Code sessions working in parallel with shared task lists, inter-agent messaging, team creation, teammate coordination, display modes, plan approval, hooks (TeammateIdle, TaskCompleted), shutdown, cleanup, and comparison with subagents.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for coordinating teams of Claude Code sessions.

## Quick Reference

Agent teams let you coordinate multiple Claude Code instances working together. One session acts as the team lead, spawning and coordinating teammates that each work independently in their own context window. Teammates communicate directly with each other via messaging and share a task list.

**Experimental feature** -- enable by setting `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `1` in your environment or settings.json:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs Subagents

| Aspect              | Subagents                                        | Agent Teams                                         |
|:--------------------|:-------------------------------------------------|:----------------------------------------------------|
| **Context**         | Own context window; results return to caller     | Own context window; fully independent               |
| **Communication**   | Report results back to main agent only           | Teammates message each other directly               |
| **Coordination**    | Main agent manages all work                      | Shared task list with self-coordination             |
| **Best for**        | Focused tasks where only the result matters      | Complex work requiring discussion and collaboration |
| **Token cost**      | Lower: results summarized back to main context   | Higher: each teammate is a separate Claude instance |

Use subagents for quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate independently.

### Architecture

| Component       | Role                                                                                    |
|:----------------|:----------------------------------------------------------------------------------------|
| **Team lead**   | Main session that creates the team, spawns teammates, and coordinates work              |
| **Teammates**   | Separate Claude Code instances that work on assigned tasks                               |
| **Task list**   | Shared list of work items that teammates claim and complete                              |
| **Mailbox**     | Messaging system for direct communication between agents                                |

Storage locations:

| Data          | Path                                        |
|:--------------|:--------------------------------------------|
| Team config   | `~/.claude/teams/{team-name}/config.json`   |
| Task list     | `~/.claude/tasks/{team-name}/`              |

### Display Modes

| Mode            | Setting value   | Behavior                                                        | Requirements       |
|:----------------|:----------------|:----------------------------------------------------------------|:-------------------|
| In-process      | `"in-process"`  | All teammates in main terminal; Shift+Down to cycle             | None               |
| Split panes     | `"tmux"`        | Each teammate in its own pane; click to interact                | tmux or iTerm2     |
| Auto (default)  | `"auto"`        | Split panes if inside tmux, otherwise in-process                | --                 |

Configure in settings.json with `"teammateMode"` or pass `--teammate-mode` flag.

### In-Process Mode Controls

| Key           | Action                                   |
|:--------------|:-----------------------------------------|
| Shift+Down    | Cycle through teammates                  |
| Enter         | View a teammate's session                |
| Escape        | Interrupt a teammate's current turn      |
| Ctrl+T        | Toggle the task list                     |

### Task States

| State         | Description                                                    |
|:--------------|:---------------------------------------------------------------|
| Pending       | Not yet started; may be blocked by dependencies                |
| In progress   | Claimed by a teammate and actively being worked on             |
| Completed     | Finished; unblocks dependent tasks automatically               |

Task claiming uses file locking to prevent race conditions.

### Best Use Cases

- **Research and review**: multiple teammates investigate different aspects simultaneously
- **New modules or features**: each teammate owns a separate piece
- **Debugging with competing hypotheses**: teammates test different theories in parallel
- **Cross-layer coordination**: frontend, backend, and tests each owned by different teammates

### Team Lifecycle Hooks

| Hook Event       | When it fires                        | Exit code 2 effect                      |
|:-----------------|:-------------------------------------|:----------------------------------------|
| `TeammateIdle`   | Teammate is about to go idle         | Sends feedback, keeps teammate working  |
| `TaskCompleted`  | Task is being marked complete        | Prevents completion, sends feedback     |

### Best Practices

- **Team size**: start with 3-5 teammates; 5-6 tasks per teammate is optimal
- **Context**: include task-specific details in spawn prompts (teammates do not inherit lead's conversation history)
- **File conflicts**: break work so each teammate owns different files
- **Task sizing**: self-contained units that produce a clear deliverable (function, test file, review)
- **Waiting**: tell the lead to wait for teammates if it starts implementing instead of delegating

### Limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` do not restore them)
- One team per session; clean up before starting a new one
- No nested teams; teammates cannot spawn their own teams
- Lead is fixed for the team's lifetime
- Permissions set at spawn; all teammates start with the lead's permission mode
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate Teams of Claude Code Sessions](references/claude-code-agent-teams.md) -- enabling agent teams, starting and controlling teams, display modes, task coordination, plan approval, hooks, architecture, use cases, best practices, troubleshooting, and limitations

## Sources

- Orchestrate Teams of Claude Code Sessions: https://code.claude.com/docs/en/agent-teams.md
