---
name: agent-teams-doc
description: Complete documentation for Claude Code agent teams — orchestrating multiple Claude Code sessions working in parallel with shared task lists, inter-agent messaging, and centralized management. Covers enabling teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS), team architecture (lead, teammates, task list, mailbox), display modes (in-process, split panes via tmux/iTerm2), spawning teammates with model overrides, plan approval workflows, direct teammate messaging, task assignment and self-claiming, shutdown and cleanup, quality gate hooks (TeammateIdle, TaskCompleted), permissions inheritance, context and communication model, token cost considerations, comparison with subagents, troubleshooting (orphaned tmux sessions, permission prompts, stopped teammates), and known limitations. Load when discussing agent teams, multi-agent coordination, parallel Claude Code sessions, teammate spawning, team leads, shared task lists, inter-agent messaging, TeammateIdle hooks, TaskCompleted hooks, teammateMode settings, or split-pane mode.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for orchestrating teams of Claude Code sessions.

## Quick Reference

Agent teams let you coordinate multiple Claude Code instances working together. One session acts as the team lead, spawning and coordinating teammates. Teammates work independently in their own context windows and communicate directly with each other.

**Experimental:** disabled by default. Requires Claude Code v2.1.32+.

### Enable Agent Teams

Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `1` in your environment or in settings.json:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs Subagents

| Aspect | Subagents | Agent teams |
|:-------|:----------|:------------|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

Use subagents for quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### Architecture

| Component | Role |
|:----------|:-----|
| **Team lead** | Main session that creates the team, spawns teammates, coordinates work |
| **Teammates** | Separate Claude Code instances working on assigned tasks |
| **Task list** | Shared work items that teammates claim and complete |
| **Mailbox** | Messaging system for inter-agent communication |

**Storage locations:**

| Resource | Path |
|:---------|:-----|
| Team config | `~/.claude/teams/{team-name}/config.json` |
| Task list | `~/.claude/tasks/{team-name}/` |

The team config contains a `members` array with each teammate's name, agent ID, and agent type.

### Display Modes

| Mode | Description | Requirements |
|:-----|:------------|:-------------|
| **In-process** (default fallback) | All teammates in main terminal; Shift+Down to cycle | Any terminal |
| **Split panes** | Each teammate gets its own pane | tmux or iTerm2 with `it2` CLI |
| **Auto** (default) | Split panes if inside tmux, in-process otherwise | -- |

Configure via settings.json (`teammateMode`) or CLI flag (`--teammate-mode`):

```json
{
  "teammateMode": "in-process"
}
```

```bash
claude --teammate-mode in-process
```

### In-Process Mode Controls

| Key | Action |
|:----|:-------|
| Shift+Down | Cycle through teammates |
| Enter | View a teammate's session |
| Escape | Interrupt a teammate's current turn |
| Ctrl+T | Toggle the task list |

### Task States and Coordination

Tasks have three states: **pending**, **in progress**, and **completed**. Tasks can depend on other tasks; pending tasks with unresolved dependencies cannot be claimed until dependencies complete. Task claiming uses file locking to prevent race conditions.

Assignment modes:
- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: after finishing a task, a teammate picks up the next unassigned, unblocked task

### Plan Approval Workflow

Teammates can be required to plan before implementing. The teammate works in read-only plan mode until the lead approves:

1. Teammate finishes planning and sends a plan approval request
2. Lead reviews and approves or rejects with feedback
3. If rejected, teammate revises and resubmits
4. Once approved, teammate exits plan mode and begins implementation

The lead makes approval decisions autonomously. Influence judgment via prompt criteria (e.g., "only approve plans that include test coverage").

### Quality Gate Hooks

| Hook | Trigger | Exit code 2 behavior |
|:-----|:--------|:---------------------|
| `TeammateIdle` | Teammate is about to go idle | Send feedback, keep teammate working |
| `TaskCompleted` | Task is being marked complete | Prevent completion, send feedback |

### Permissions

Teammates start with the lead's permission settings. If the lead uses `--dangerously-skip-permissions`, all teammates do too. Individual teammate modes can be changed after spawning, but per-teammate modes cannot be set at spawn time.

### Context and Communication

Each teammate loads the same project context as a regular session (CLAUDE.md, MCP servers, skills) plus the spawn prompt from the lead. The lead's conversation history does not carry over.

**Communication mechanisms:**
- **Automatic message delivery**: messages delivered automatically to recipients
- **Idle notifications**: teammates notify the lead when they finish
- **Shared task list**: all agents see task status and claim available work
- **message**: send to one specific teammate
- **broadcast**: send to all teammates (use sparingly; costs scale with team size)

### Token Usage

Token usage scales linearly with the number of active teammates. Each teammate has its own context window. Best value for research, review, and new feature work. For routine tasks, a single session is more cost-effective.

### Best Practices

| Practice | Guidance |
|:---------|:---------|
| **Team size** | Start with 3-5 teammates; scale up only when genuinely needed |
| **Tasks per teammate** | Aim for 5-6 tasks per teammate |
| **Task sizing** | Self-contained units producing a clear deliverable (function, test file, review) |
| **File ownership** | Each teammate owns different files; avoid two teammates editing the same file |
| **Context** | Include task-specific details in the spawn prompt (teammates do not inherit lead history) |
| **Monitoring** | Check in on progress; redirect approaches that are not working |
| **Starting out** | Begin with research/review tasks before attempting parallel implementation |

### Cleanup

Always use the lead to clean up. Shut down all teammates first, then:

```text
Clean up the team
```

Teammates should not run cleanup (their team context may not resolve correctly).

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Teammates not appearing | Shift+Down to cycle; check task complexity; verify tmux/iTerm2 installation |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Message them directly with instructions, or spawn a replacement |
| Lead shuts down early | Tell it to keep going or wait for teammates to finish |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |

### Known Limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag (teammates may fail to mark tasks complete)
- Shutdown can be slow (teammates finish current request before exiting)
- One team per session; clean up before starting a new one
- No nested teams (teammates cannot spawn their own teams)
- Lead is fixed for the team's lifetime
- Permissions set at spawn time for all teammates
- Split panes require tmux or iTerm2 (not supported in VS Code terminal, Windows Terminal, or Ghostty)

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) -- enabling agent teams, when to use teams vs subagents, starting a team, display modes (in-process, split panes, tmux, iTerm2), specifying teammates and models, plan approval, direct teammate messaging, task assignment and self-claiming, shutdown and cleanup, quality gate hooks (TeammateIdle, TaskCompleted), architecture, permissions, context and communication, token usage, use case examples (parallel code review, competing hypotheses), best practices, troubleshooting, limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
