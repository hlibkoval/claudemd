---
name: agent-teams-doc
description: Complete documentation for Claude Code agent teams -- orchestrating multiple Claude Code sessions working together as a coordinated team with shared task lists, inter-agent messaging, and centralized management. Covers enabling agent teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS env var or settings.json), starting teams with natural language prompts, team architecture (team lead, teammates, shared task list, mailbox), display modes (in-process with Shift+Down cycling, split panes with tmux or iTerm2, auto mode, --teammate-mode flag, teammateMode in ~/.claude.json), specifying teammates and models, requiring plan approval before implementation, talking to teammates directly, assigning and claiming tasks (pending/in-progress/completed states, task dependencies, file-locking for race prevention), shutting down teammates, cleaning up teams, quality gate hooks (TeammateIdle, TaskCreated, TaskCompleted with exit code 2 for feedback), comparing agent teams vs subagents (context, communication, coordination, token cost tradeoffs), teammate permissions (inherit from lead, --dangerously-skip-permissions propagation), context and communication (automatic message delivery, idle notifications, shared task list, message vs broadcast), token usage scaling, use case examples (parallel code review with multiple lenses, competing hypothesis investigation with adversarial debate), best practices (giving teammates context in spawn prompts, 3-5 teammates for most workflows, 5-6 tasks per teammate, sizing tasks appropriately, waiting for teammates, starting with research/review, avoiding file conflicts, monitoring and steering), troubleshooting (teammates not appearing, permission prompts, teammates stopping on errors, lead shutting down early, orphaned tmux sessions), limitations (no session resumption with in-process teammates, task status lag, slow shutdown, one team per session, no nested teams, fixed lead, permissions set at spawn, split panes require tmux or iTerm2), and local storage paths (~/.claude/teams/ for team config, ~/.claude/tasks/ for task lists). Load when discussing Claude Code agent teams, team coordination, teammate spawning, team lead, shared task list, inter-agent messaging, mailbox, teammate mode, in-process mode, split pane mode, tmux teams, plan approval, task dependencies, TeammateIdle hook, TaskCreated hook, TaskCompleted hook, CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, agent team architecture, parallel code review with teams, competing hypotheses, team cleanup, teammate shutdown, agent teams vs subagents, teammate permissions, broadcast messages, team token costs, or any agent-team-related topic for Claude Code.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for orchestrating teams of Claude Code sessions -- coordinating multiple independent Claude Code instances with shared task lists, inter-agent messaging, and centralized team management.

## Quick Reference

### Enable Agent Teams

Agent teams are experimental and disabled by default. Requires Claude Code v2.1.32+.

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your shell environment.

### Agent Teams vs Subagents

| | Subagents | Agent Teams |
|:--|:----------|:------------|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

Use subagents for quick focused workers. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### Architecture

| Component | Role |
|:----------|:-----|
| **Team lead** | Main session that creates the team, spawns teammates, coordinates work |
| **Teammates** | Separate Claude Code instances working on assigned tasks |
| **Task list** | Shared work items that teammates claim and complete |
| **Mailbox** | Messaging system for inter-agent communication |

Local storage paths:
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Display Modes

| Mode | Description | Requirements |
|:-----|:------------|:-------------|
| **in-process** | All teammates in main terminal; Shift+Down to cycle | Any terminal |
| **split panes** | Each teammate gets its own pane | tmux or iTerm2 with `it2` CLI |
| **auto** (default) | Split panes if inside tmux, otherwise in-process | -- |

Configure globally in `~/.claude.json`:
```json
{
  "teammateMode": "in-process"
}
```

Or per-session: `claude --teammate-mode in-process`

### In-Process Mode Controls

| Key | Action |
|:----|:-------|
| **Shift+Down** | Cycle through teammates (wraps back to lead) |
| **Enter** | View a teammate's session |
| **Escape** | Interrupt a teammate's current turn |
| **Ctrl+T** | Toggle the task list |

### Task States and Dependencies

Tasks have three states: **pending**, **in progress**, and **completed**. Tasks can depend on other tasks -- blocked tasks cannot be claimed until dependencies are completed. Task claiming uses file locking to prevent race conditions.

Assignment methods:
- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: teammates pick up the next unassigned, unblocked task automatically

### Quality Gate Hooks

| Hook | When it fires | Exit code 2 behavior |
|:-----|:-------------|:---------------------|
| `TeammateIdle` | Teammate is about to go idle | Send feedback, keep teammate working |
| `TaskCreated` | Task is being created | Prevent creation, send feedback |
| `TaskCompleted` | Task is being marked complete | Prevent completion, send feedback |

### Permissions

Teammates inherit the lead's permission settings at spawn. If the lead runs with `--dangerously-skip-permissions`, all teammates do too. Individual teammate modes can be changed after spawning but not at spawn time.

### Communication

- **Automatic delivery**: messages delivered automatically to recipients; lead does not poll
- **Idle notifications**: teammates notify the lead automatically when they finish
- **Shared task list**: all agents see task status and claim available work
- **message**: send to one specific teammate
- **broadcast**: send to all teammates (use sparingly; costs scale with team size)

Teammates load CLAUDE.md, MCP servers, and skills from their working directory but do not inherit the lead's conversation history.

### Best Practices Summary

| Practice | Guideline |
|:---------|:----------|
| **Team size** | Start with 3-5 teammates for most workflows |
| **Tasks per teammate** | 5-6 tasks keeps everyone productive |
| **Task sizing** | Self-contained units with clear deliverables (function, test file, review) |
| **Context** | Include task-specific details in the spawn prompt |
| **Starting out** | Begin with research/review tasks before parallel implementation |
| **File conflicts** | Each teammate should own a different set of files |
| **Monitoring** | Check in, redirect failing approaches, synthesize findings |

### Limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag; teammates may fail to mark tasks complete
- Shutdown can be slow (teammates finish current request first)
- One team per session; clean up before starting a new one
- No nested teams; teammates cannot spawn their own teams
- Lead is fixed for the lifetime of the team
- Permissions set at spawn for all teammates
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) -- enabling agent teams, starting and controlling teams, display modes (in-process and split panes with tmux/iTerm2), specifying teammates and models, plan approval workflow, direct teammate interaction, task assignment and claiming with dependencies, shutdown and cleanup, quality gate hooks (TeammateIdle, TaskCreated, TaskCompleted), architecture (lead, teammates, task list, mailbox), permissions inheritance, context and communication (automatic delivery, idle notifications, message vs broadcast), token usage, use case examples (parallel code review, competing hypothesis investigation), best practices (team size, task sizing, context, file conflicts, monitoring), troubleshooting (missing teammates, permission prompts, error recovery, orphaned tmux sessions), and current limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
