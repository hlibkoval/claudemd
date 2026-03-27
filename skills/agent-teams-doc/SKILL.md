---
name: agent-teams-doc
description: Complete documentation for Claude Code agent teams -- coordinating multiple Claude Code instances working together with shared task lists, inter-agent messaging, and centralized management. Covers enabling agent teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS), team architecture (team lead, teammates, shared task list, mailbox), display modes (in-process with Shift+Down cycling, split panes with tmux or iTerm2, teammateMode setting, --teammate-mode flag), starting and controlling teams (natural language task description, specifying teammates and models, plan approval for teammates, direct messaging via Shift+Down or split panes), task coordination (pending/in-progress/completed states, task dependencies, self-claiming, file-lock-based claiming), teammate lifecycle (spawning, shutdown requests, team cleanup), permissions (inherited from lead, --dangerously-skip-permissions propagation), context and communication (automatic message delivery, idle notifications, broadcast vs targeted messages, CLAUDE.md loading), hooks integration (TeammateIdle, TaskCreated, TaskCompleted with exit code 2 for feedback), token usage considerations, comparison with subagents (own context window, direct inter-agent communication vs report-back-only, shared task list vs main-agent-managed), use case examples (parallel code review, competing hypothesis investigation), best practices (context in spawn prompts, 3-5 teammates, 5-6 tasks per teammate, avoiding file conflicts, monitoring and steering), troubleshooting (teammates not appearing, permission prompts, error recovery, lead premature shutdown, orphaned tmux sessions), and current limitations (no session resumption with in-process teammates, task status lag, one team per session, no nested teams, fixed lead, permissions set at spawn, split panes require tmux/iTerm2). Load when discussing Claude Code agent teams, multi-agent coordination, teammate spawning, team lead, shared task lists, inter-agent messaging, parallel work with multiple Claude instances, teammateMode, CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, tmux split panes for Claude, TeammateIdle hook, TaskCreated hook, TaskCompleted hook, subagents vs agent teams comparison, or any agent-team-related topic for Claude Code.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams -- coordinating multiple Claude Code instances working together with shared task lists, inter-agent messaging, and centralized management.

## Quick Reference

### Prerequisites

- Claude Code v2.1.32 or later
- Agent teams are experimental and disabled by default
- Enable via environment variable or settings.json:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs Subagents

| | Subagents | Agent teams |
|:--|:----------|:------------|
| **Context** | Own context window; results return to the caller | Own context window; fully independent |
| **Communication** | Report results back to the main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

Use subagents for quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### Best Use Cases

- **Research and review**: multiple teammates investigate different aspects simultaneously
- **New modules or features**: teammates each own a separate piece without conflicts
- **Debugging with competing hypotheses**: teammates test different theories in parallel
- **Cross-layer coordination**: changes spanning frontend, backend, and tests

Agent teams add coordination overhead and use significantly more tokens. For sequential tasks, same-file edits, or work with many dependencies, a single session or subagents are more effective.

### Architecture

| Component | Role |
|:----------|:-----|
| **Team lead** | The main session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

Storage locations:
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Display Modes

| Mode | Behavior | Requirements |
|:-----|:---------|:-------------|
| **In-process** (default) | All teammates run inside the main terminal; cycle with Shift+Down | Any terminal |
| **Split panes** | Each teammate gets its own pane; click to interact | tmux or iTerm2 |
| **Auto** (default setting) | Uses split panes if already in tmux, otherwise in-process | -- |

Configure via settings.json:

```json
{
  "teammateMode": "in-process"
}
```

Or per-session flag: `claude --teammate-mode in-process`

Split-pane mode is not supported in VS Code's integrated terminal, Windows Terminal, or Ghostty.

### In-Process Mode Controls

| Key | Action |
|:----|:-------|
| Shift+Down | Cycle through teammates (wraps back to lead after last) |
| Enter | View a teammate's session |
| Escape | Interrupt a teammate's current turn |
| Ctrl+T | Toggle the task list |

### Task States and Coordination

Tasks have three states: **pending**, **in progress**, and **completed**. Tasks can depend on other tasks -- a pending task with unresolved dependencies cannot be claimed until those dependencies are completed. Dependencies unblock automatically when completed.

Task claiming uses file locking to prevent race conditions when multiple teammates try to claim the same task.

Assignment methods:
- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: after finishing a task, a teammate picks up the next unassigned, unblocked task

### Teammate Lifecycle

**Spawning** -- tell Claude to create a team in natural language. You can specify the number of teammates, their roles, and which model to use.

**Plan approval** -- require teammates to plan before implementing. The teammate works in read-only plan mode until the lead approves:

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

The lead makes approval decisions autonomously. Influence its judgment with criteria like "only approve plans that include test coverage."

**Shutdown** -- ask the lead to shut down a specific teammate. The teammate can approve or reject (with explanation). Teammates finish their current request before shutting down.

**Cleanup** -- ask the lead to clean up the team. This removes shared resources. All teammates must be shut down first. Always use the lead for cleanup (not teammates).

### Permissions

Teammates inherit the lead's permission settings at spawn time. If the lead uses `--dangerously-skip-permissions`, all teammates do too. You can change individual teammate modes after spawning, but not at spawn time.

### Context and Communication

Teammates load the same project context as a regular session (CLAUDE.md, MCP servers, skills) plus the spawn prompt from the lead. The lead's conversation history does not carry over.

| Communication type | Behavior |
|:-------------------|:---------|
| **message** | Send to one specific teammate |
| **broadcast** | Send to all teammates simultaneously (use sparingly -- costs scale with team size) |
| **Automatic delivery** | Messages delivered automatically to recipients |
| **Idle notifications** | Teammates notify the lead when they stop |

### Hooks Integration

| Hook | When it runs | Exit code 2 effect |
|:-----|:-------------|:-------------------|
| `TeammateIdle` | A teammate is about to go idle | Send feedback, keep teammate working |
| `TaskCreated` | A task is being created | Prevent creation, send feedback |
| `TaskCompleted` | A task is being marked complete | Prevent completion, send feedback |

### Recommended Team Sizing

| Guideline | Recommendation |
|:----------|:---------------|
| Team size | 3-5 teammates for most workflows |
| Tasks per teammate | 5-6 tasks keeps everyone productive |
| Task granularity | Self-contained units producing a clear deliverable (function, test file, review) |

### Troubleshooting Quick Reference

| Issue | Solution |
|:------|:---------|
| Teammates not appearing | Press Shift+Down to cycle; check task complexity; verify tmux if using split panes |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Message them directly with instructions or spawn a replacement |
| Lead shuts down too early | Tell it to wait for teammates to finish before proceeding |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |

### Known Limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag -- teammates sometimes fail to mark tasks completed
- One team per session; clean up before starting a new one
- No nested teams -- only the lead can manage the team
- Lead is fixed for the team's lifetime
- Permissions set at spawn for all teammates
- Split panes require tmux or iTerm2

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent Teams](references/claude-code-agent-teams.md) -- enabling agent teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS), when to use agent teams vs subagents comparison, starting a team with natural language, display modes (in-process vs split panes, teammateMode setting, --teammate-mode flag, tmux and iTerm2 setup), controlling teammates (specifying models, plan approval, direct messaging, task assignment and self-claiming, shutdown and cleanup), hooks integration (TeammateIdle, TaskCreated, TaskCompleted), architecture (team lead, teammates, task list, mailbox, storage locations), permissions inheritance, context and communication (automatic delivery, idle notifications, broadcast vs message), token usage, use case examples (parallel code review, competing hypothesis investigation), best practices (spawn prompt context, team sizing 3-5, task sizing 5-6 per teammate, avoiding file conflicts, monitoring), troubleshooting (teammates not appearing, permission prompts, error recovery, premature lead shutdown, orphaned tmux sessions), limitations (no session resumption, task status lag, one team per session, no nested teams, fixed lead, permissions at spawn, split pane terminal support)

## Sources

- Agent Teams: https://code.claude.com/docs/en/agent-teams.md
