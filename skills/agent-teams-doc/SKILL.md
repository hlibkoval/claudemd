---
name: agent-teams-doc
description: Complete documentation for Claude Code agent teams -- coordinating multiple Claude Code instances working together (experimental feature), enabling via CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, team architecture (lead, teammates, task list, mailbox), display modes (in-process with Shift+Down cycling, split panes via tmux/iTerm2, teammateMode setting), spawning teammates with model selection, plan approval workflow, direct teammate messaging, shared task list (pending/in-progress/completed, dependencies, file-locked claiming), teammate shutdown and team cleanup, quality gate hooks (TeammateIdle, TaskCompleted), comparison with subagents (context, communication, coordination, token cost tradeoffs), permissions inheritance, context and communication (automatic message delivery, idle notifications, broadcast), use cases (parallel code review, competing hypothesis debugging, cross-layer coordination), best practices (context in spawn prompts, team sizing 3-5, task sizing 5-6 per teammate, avoiding file conflicts, monitoring), troubleshooting (teammates not appearing, permission prompts, orphaned tmux sessions), and current limitations (no session resumption, no nested teams, one team per session, fixed lead). Load when discussing agent teams, multi-agent coordination, parallel Claude Code sessions working together, teammate spawning, team task lists, or the CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS setting.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for orchestrating teams of Claude Code sessions that coordinate work through shared task lists and direct messaging.

## Quick Reference

Agent teams let you coordinate multiple Claude Code instances working together. One session acts as the team lead, coordinating work, assigning tasks, and synthesizing results. Teammates work independently, each in its own context window, and communicate directly with each other. Agent teams are experimental and must be enabled explicitly.

### Enable Agent Teams

Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `1` in your environment or settings.json:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Architecture

| Component | Role |
|:----------|:-----|
| **Team lead** | Main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

Storage locations:
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Agent Teams vs Subagents

| | Subagents | Agent teams |
|:--|:----------|:------------|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

Use subagents for quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### Display Modes

| Mode | Setting value | How it works | Requirements |
|:-----|:--------------|:-------------|:-------------|
| In-process | `"in-process"` | All teammates in main terminal; Shift+Down to cycle | Any terminal |
| Split panes | `"tmux"` | Each teammate in its own pane; click to interact | tmux or iTerm2 with `it2` CLI |
| Auto (default) | `"auto"` | Split panes if already in tmux, in-process otherwise | -- |

Configure via settings.json (`"teammateMode": "in-process"`) or CLI flag (`--teammate-mode in-process`).

### In-Process Mode Controls

| Key | Action |
|:----|:-------|
| Shift+Down | Cycle through teammates (wraps back to lead after last) |
| Enter | View a teammate's session |
| Escape | Interrupt a teammate's current turn |
| Ctrl+T | Toggle the task list |

### Task States and Coordination

Tasks have three states: **pending**, **in progress**, and **completed**. Tasks can depend on other tasks; blocked tasks cannot be claimed until dependencies complete. Task claiming uses file locking to prevent race conditions.

Assignment modes:
- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: after finishing, a teammate picks up the next unassigned, unblocked task

### Plan Approval Workflow

Require teammates to plan before implementing for complex or risky tasks. The teammate works in read-only plan mode until the lead approves. If rejected, the teammate revises and resubmits. Influence approval criteria in the prompt (e.g., "only approve plans that include test coverage").

### Quality Gate Hooks

| Hook | Trigger | Exit code 2 behavior |
|:-----|:--------|:---------------------|
| `TeammateIdle` | Teammate is about to go idle | Sends feedback, keeps teammate working |
| `TaskCompleted` | Task is being marked complete | Prevents completion, sends feedback |

### Permissions

Teammates start with the lead's permission settings. If the lead uses `--dangerously-skip-permissions`, all teammates do too. Individual modes can be changed after spawning, but not at spawn time.

### Context and Communication

Teammates load the same project context as a regular session (CLAUDE.md, MCP servers, skills) plus the spawn prompt. The lead's conversation history does not carry over.

| Communication type | Description |
|:-------------------|:------------|
| **message** | Send to one specific teammate |
| **broadcast** | Send to all teammates (use sparingly; costs scale with team size) |
| **Automatic delivery** | Messages delivered automatically to recipients |
| **Idle notifications** | Teammates notify the lead automatically when finished |

### Teammate Shutdown and Cleanup

Shut down individual teammates by asking the lead. The teammate can approve (exits gracefully) or reject with an explanation. To clean up the entire team, ask the lead to "clean up the team" -- this removes shared resources. Always shut down all teammates before cleanup, and always use the lead for cleanup.

### Best Practices

| Area | Guidance |
|:-----|:---------|
| Team size | Start with 3-5 teammates; scale up only when work genuinely benefits |
| Tasks per teammate | 5-6 tasks keeps everyone productive without excessive context switching |
| Spawn context | Include task-specific details in the spawn prompt (teammates don't inherit lead's history) |
| Task sizing | Self-contained units with clear deliverables; not too small (coordination overhead) or too large (risk of wasted effort) |
| File conflicts | Break work so each teammate owns different files; avoid two teammates editing the same file |
| Monitoring | Check in on progress; redirect approaches that aren't working |
| Lead behavior | If the lead starts implementing instead of delegating, tell it to wait for teammates |

### Best Use Cases

- **Research and review**: investigate different aspects simultaneously
- **New modules or features**: each teammate owns a separate piece
- **Debugging with competing hypotheses**: test different theories in parallel
- **Cross-layer coordination**: frontend, backend, and tests each owned by a different teammate

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Teammates not appearing | Press Shift+Down (in-process mode); verify task warrants a team; check tmux installation for split panes |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Message them directly with additional instructions or spawn replacements |
| Lead shuts down early | Tell it to keep going or wait for teammates to finish |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |

### Current Limitations

- No session resumption for in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag; teammates sometimes fail to mark tasks completed
- Shutdown can be slow (teammates finish current request first)
- One team per session; clean up before starting a new one
- No nested teams; only the lead can manage the team
- Lead is fixed for the team's lifetime
- Permissions set at spawn for all teammates
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) -- enabling agent teams, architecture (lead, teammates, task list, mailbox), display modes (in-process, split panes, tmux/iTerm2), spawning teammates with model selection, plan approval workflow, direct messaging, task assignment and claiming, shutdown and cleanup, quality gate hooks, subagent comparison, permissions, context and communication, token usage, use case examples, best practices, troubleshooting, limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
