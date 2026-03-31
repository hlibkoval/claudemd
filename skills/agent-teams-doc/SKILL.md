---
name: agent-teams-doc
description: Complete documentation for Claude Code agent teams -- orchestrating multiple Claude Code sessions working together as a coordinated team with shared task lists, inter-agent messaging, and centralized management. Covers enabling agent teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS env var or settings.json), team architecture (team lead, teammates, shared task list, mailbox messaging system), display modes (in-process with Shift+Down cycling, split panes with tmux or iTerm2, teammateMode auto/in-process/tmux in ~/.claude.json, --teammate-mode flag), starting teams (natural language prompts, Claude proposes or user requests), controlling teams (specifying teammates and models, plan approval before implementation, talking to teammates directly, assigning and claiming tasks with file locking, task states pending/in-progress/completed, task dependencies, shutting down teammates, cleaning up teams), using subagent definitions for teammates (reusing subagent types from any scope as teammate roles), permissions (teammates inherit lead's permission settings), context and communication (own context windows, automatic message delivery, idle notifications, shared task list, message and broadcast), token usage (scales with active teammates), hooks integration (TeammateIdle exit code 2, TaskCreated exit code 2, TaskCompleted exit code 2), comparison with subagents (context/communication/coordination/cost tradeoffs), use case examples (parallel code review, competing hypothesis debugging, cross-layer coordination, research and review), best practices (give teammates enough context, choose appropriate team size 3-5, size tasks appropriately 5-6 per teammate, wait for teammates to finish, start with research/review, avoid file conflicts, monitor and steer), storage locations (~/.claude/teams/{team-name}/config.json, ~/.claude/tasks/{team-name}/), troubleshooting (teammates not appearing, too many permission prompts, teammates stopping on errors, lead shuts down early, orphaned tmux sessions), limitations (no session resumption with in-process teammates, task status lag, slow shutdown, one team per session, no nested teams, fixed lead, permissions set at spawn, split panes require tmux/iTerm2). Load when discussing Claude Code agent teams, team coordination, multi-agent orchestration, teammate spawning, shared task lists, inter-agent messaging, teammateMode, split panes for Claude Code, tmux teams, team lead, TeammateIdle hook, TaskCreated hook, TaskCompleted hook, plan approval, agent team architecture, parallel code review with teams, competing hypothesis debugging, or any agent-teams-related topic for Claude Code.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams -- coordinating multiple Claude Code instances working together as a team with shared tasks, inter-agent messaging, and centralized management.

## Quick Reference

### Enabling Agent Teams

Agent teams are experimental and disabled by default. Enable via environment variable or settings.json:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Requires Claude Code v2.1.32 or later (`claude --version` to check).

### Agent Teams vs Subagents

|                   | Subagents                                        | Agent teams                                         |
|:------------------|:-------------------------------------------------|:----------------------------------------------------|
| **Context**       | Own context window; results return to caller     | Own context window; fully independent               |
| **Communication** | Report results back to main agent only           | Teammates message each other directly               |
| **Coordination**  | Main agent manages all work                      | Shared task list with self-coordination             |
| **Best for**      | Focused tasks where only the result matters      | Complex work requiring discussion and collaboration |
| **Token cost**    | Lower: results summarized back to main context   | Higher: each teammate is a separate Claude instance |

Use subagents for quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### Team Architecture

| Component     | Role                                                                                       |
|:--------------|:-------------------------------------------------------------------------------------------|
| **Team lead** | Main Claude Code session that creates the team, spawns teammates, and coordinates work     |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks                            |
| **Task list** | Shared list of work items that teammates claim and complete                                |
| **Mailbox**   | Messaging system for communication between agents                                          |

**Storage locations:**

| Data | Path |
|:-----|:-----|
| Team config | `~/.claude/teams/{team-name}/config.json` |
| Task list | `~/.claude/tasks/{team-name}/` |

Team config is auto-generated and auto-updated (do not edit by hand). The `members` array in the config holds each teammate's name, agent ID, and agent type. There is no project-level equivalent.

### Display Modes

| Mode | Setting | Behavior | Requirements |
|:-----|:--------|:---------|:-------------|
| **In-process** | `"in-process"` | All teammates in main terminal, Shift+Down to cycle | Any terminal |
| **Split panes** | `"tmux"` | Each teammate in its own pane, click to interact | tmux or iTerm2 |
| **Auto** (default) | `"auto"` | Split panes if inside tmux, in-process otherwise | -- |

Configure in `~/.claude.json`:

```json
{
  "teammateMode": "in-process"
}
```

Or per-session: `claude --teammate-mode in-process`

**Split pane dependencies:**
- **tmux**: install via system package manager; `tmux -CC` in iTerm2 is recommended
- **iTerm2**: install `it2` CLI, enable Python API in Settings > General > Magic

### In-Process Mode Controls

| Action | Key |
|:-------|:----|
| Cycle through teammates | Shift+Down |
| View teammate session | Enter |
| Interrupt teammate's turn | Escape |
| Toggle task list | Ctrl+T |

### Starting a Team

Tell Claude to create an agent team with a natural language description of the task and team structure. Claude creates the team, spawns teammates, and coordinates work. Two ways teams start:

1. **You request a team**: explicitly ask for an agent team
2. **Claude proposes a team**: Claude suggests one if the task benefits from parallel work; you confirm

### Task Management

Tasks have three states: **pending**, **in progress**, **completed**. Tasks can depend on other tasks -- pending tasks with unresolved dependencies cannot be claimed until dependencies complete. Task claiming uses file locking to prevent race conditions.

**Assignment modes:**
- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: teammates pick up the next unassigned, unblocked task on their own

### Plan Approval

Require teammates to plan before implementing (read-only plan mode until approved):

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

The lead reviews and approves or rejects with feedback. Influence approval criteria in your prompt (e.g., "only approve plans that include test coverage").

### Using Subagent Definitions for Teammates

Reference a subagent type from any scope (project, user, plugin, CLI-defined) when spawning a teammate. The teammate inherits that subagent's system prompt, tools, and model:

```
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

### Permissions

Teammates start with the lead's permission settings (including `--dangerously-skip-permissions`). Individual teammate modes can be changed after spawning but not at spawn time.

### Context and Communication

Each teammate has its own context window. On spawn, teammates load project context (CLAUDE.md, MCP servers, skills) plus the spawn prompt. The lead's conversation history does not carry over.

**Communication mechanisms:**
- **Automatic message delivery**: messages delivered to recipients without polling
- **Idle notifications**: teammates notify the lead when they finish
- **Shared task list**: all agents see task status and claim available work
- **message**: send to one specific teammate
- **broadcast**: send to all teammates (use sparingly, costs scale with team size)

### Hooks Integration

| Hook | Trigger | Exit code 2 effect |
|:-----|:--------|:-------------------|
| `TeammateIdle` | Teammate about to go idle | Send feedback, keep teammate working |
| `TaskCreated` | Task being created | Prevent creation, send feedback |
| `TaskCompleted` | Task being marked complete | Prevent completion, send feedback |

### Best Use Cases

- **Research and review**: investigate different aspects simultaneously
- **New modules or features**: teammates each own separate pieces
- **Debugging with competing hypotheses**: test different theories in parallel
- **Cross-layer coordination**: frontend, backend, and tests each owned by a different teammate

### Team Size Guidelines

- Start with **3-5 teammates** for most workflows
- Aim for **5-6 tasks per teammate** to keep everyone productive
- Token costs scale linearly with number of active teammates
- Three focused teammates often outperform five scattered ones

### Task Sizing

- **Too small**: coordination overhead exceeds the benefit
- **Too large**: teammates work too long without check-ins
- **Right size**: self-contained units producing a clear deliverable (a function, a test file, a review)

### Shutting Down and Cleaning Up

**Shut down a teammate:**
```
Ask the researcher teammate to shut down
```
The teammate can approve (exits gracefully) or reject with an explanation.

**Clean up the team:**
```
Clean up the team
```
Always use the lead to clean up. Shut down all teammates first -- cleanup fails if any are still running.

### Troubleshooting

| Issue | Solution |
|:------|:---------|
| Teammates not appearing | Shift+Down to check in-process mode; verify task complexity warrants a team; check tmux/iTerm2 installation |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Check output via Shift+Down or click pane; give additional instructions or spawn replacement |
| Lead shuts down early | Tell lead to keep going or wait for teammates to finish |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |

### Limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag (teammates may fail to mark tasks completed; check and update manually)
- Shutdown can be slow (teammates finish current request before stopping)
- One team per session (clean up before starting a new one)
- No nested teams (teammates cannot spawn their own teams)
- Lead is fixed for the team's lifetime (cannot promote a teammate)
- Permissions set at spawn (change individually after, not at spawn time)
- Split panes require tmux or iTerm2 (not supported in VS Code terminal, Windows Terminal, or Ghostty)

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) -- Enabling agent teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS), when to use agent teams (research/review, new modules, debugging, cross-layer coordination), comparison with subagents (context/communication/coordination/cost), starting teams (natural language prompts, user requests vs Claude proposals), display modes (in-process with Shift+Down, split panes with tmux/iTerm2, teammateMode auto/in-process/tmux, --teammate-mode flag), specifying teammates and models, plan approval (read-only plan mode, lead reviews/approves/rejects), talking to teammates directly, assigning and claiming tasks (file locking, task states, dependencies), shutting down teammates (graceful approval/rejection), cleaning up teams (lead only, fails if teammates running), hooks integration (TeammateIdle/TaskCreated/TaskCompleted with exit code 2), architecture (team lead, teammates, task list, mailbox, storage paths), using subagent definitions for teammates (inheriting system prompt/tools/model from any scope), permissions (inherit lead's settings, change after spawn), context and communication (own context windows, automatic message delivery, idle notifications, shared task list, message vs broadcast), token usage (scales linearly, cost guidance), use case examples (parallel code review with split criteria, competing hypothesis debugging with adversarial debate), best practices (give context in spawn prompts, team size 3-5, tasks 5-6 per teammate, wait for completion, start with research/review, avoid file conflicts, monitor and steer), troubleshooting (teammates not appearing, permission prompts, error recovery, early lead shutdown, orphaned tmux sessions), limitations (no session resumption, task status lag, slow shutdown, one team per session, no nested teams, fixed lead, spawn-time permissions, terminal requirements)

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
