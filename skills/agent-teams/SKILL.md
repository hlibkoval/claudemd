---
name: Agent Teams
description: Reference documentation for orchestrating teams of Claude Code sessions with shared task lists, inter-agent messaging, and centralized coordination. Use when creating multi-agent teams, configuring display modes, assigning tasks, setting up plan approval, using delegate mode, or troubleshooting team coordination.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

Agent teams coordinate multiple Claude Code instances working together. One session acts as the team lead, spawning teammates that work independently in their own context windows. Teammates communicate directly with each other via a shared messaging system and coordinate through a shared task list.

**Status:** Experimental, disabled by default.

### Enable Agent Teams

Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `1` in your environment or settings.json:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs Subagents

| Aspect              | Subagents                                    | Agent Teams                                         |
|:--------------------|:---------------------------------------------|:----------------------------------------------------|
| **Context**         | Own window; results return to caller         | Own window; fully independent                       |
| **Communication**   | Report back to main agent only               | Teammates message each other directly               |
| **Coordination**    | Main agent manages all work                  | Shared task list with self-coordination              |
| **Best for**        | Focused tasks where only the result matters  | Complex work requiring discussion and collaboration |
| **Token cost**      | Lower: results summarized back               | Higher: each teammate is a separate instance        |

Use subagents for quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### Architecture

| Component       | Role                                                                  |
|:----------------|:----------------------------------------------------------------------|
| **Team lead**   | Main session that creates the team, spawns teammates, coordinates     |
| **Teammates**   | Separate Claude Code instances working on assigned tasks              |
| **Task list**   | Shared work items that teammates claim and complete                   |
| **Mailbox**     | Messaging system for inter-agent communication                       |

Storage locations:
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Display Modes

| Mode            | Setting            | Description                                              |
|:----------------|:-------------------|:---------------------------------------------------------|
| **Auto**        | `"auto"` (default) | Split panes if inside tmux, in-process otherwise         |
| **In-process**  | `"in-process"`     | All teammates in main terminal; Shift+Up/Down to select  |
| **Split panes** | `"tmux"`           | Each teammate in own pane; requires tmux or iTerm2       |

Configure in settings.json:
```json
{ "teammateMode": "in-process" }
```

Or per-session: `claude --teammate-mode in-process`

### Starting a Team

Tell Claude to create a team in natural language. Claude spawns teammates and coordinates based on your prompt:

```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
```

### Key Controls

| Action                  | How                                                                    |
|:------------------------|:-----------------------------------------------------------------------|
| Select teammate         | Shift+Up/Down (in-process mode)                                        |
| View teammate session   | Enter on selected teammate                                             |
| Interrupt teammate      | Escape while viewing                                                   |
| Toggle task list        | Ctrl+T                                                                 |
| Enable delegate mode    | Shift+Tab (restricts lead to coordination-only)                        |
| Direct message          | Click pane (split) or Shift+Up/Down then type (in-process)             |

### Task Management

Tasks have three states: **pending**, **in progress**, **completed**. Tasks can depend on other tasks -- blocked tasks cannot be claimed until dependencies complete. Teammates self-claim unassigned tasks or receive assignments from the lead. File locking prevents race conditions.

### Plan Approval

Require teammates to plan before implementing:

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

The teammate works in read-only plan mode until the lead approves. Rejected plans get feedback for revision. Influence approval criteria in your prompt (e.g., "only approve plans that include test coverage").

### Quality Gate Hooks

| Hook              | Trigger                          | Exit code 2 behavior                |
|:------------------|:---------------------------------|:-------------------------------------|
| `TeammateIdle`    | Teammate about to go idle        | Sends feedback, keeps teammate working |
| `TaskCompleted`   | Task being marked complete       | Prevents completion, sends feedback    |

### Best Practices

- **Context**: Include task-specific details in spawn prompts; teammates do not inherit the lead's conversation history
- **Task sizing**: Self-contained units producing clear deliverables (function, test file, review)
- **File conflicts**: Break work so each teammate owns different files
- **Monitoring**: Check in regularly; redirect approaches that are not working
- **Start simple**: Begin with research/review tasks before parallel implementation

### Permissions

Teammates inherit the lead's permission settings at spawn time. Individual modes can be changed after spawning but not at spawn time. If the lead uses `--dangerously-skip-permissions`, all teammates do too.

### Limitations

- No session resumption for in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag; teammates may not mark tasks complete
- One team per session; clean up before starting a new one
- No nested teams; only the lead can manage the team
- Lead is fixed for the team's lifetime
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty

### Cleanup

Ask the lead to clean up when done. Shut down all teammates first, then:

```
Clean up the team
```

For orphaned tmux sessions: `tmux ls` then `tmux kill-session -t <session-name>`

## Full Documentation

For the complete official documentation with all examples and advanced patterns, see:

- [Claude Code Agent Teams](references/claude-code-agent-teams.md) -- complete documentation including architecture, use cases, best practices, and troubleshooting

## Sources

- Claude Code Agent Teams: https://code.claude.com/docs/en/agent-teams.md
