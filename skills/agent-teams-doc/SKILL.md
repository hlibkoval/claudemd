---
name: agent-teams-doc
description: Complete documentation for Claude Code agent teams -- orchestrating multiple Claude Code sessions working together as a coordinated team. Covers enabling agent teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS), team architecture (lead, teammates, task list, mailbox), display modes (in-process, split panes, tmux, iTerm2), teammate spawning and configuration (--teammate-mode, teammateMode), subagent definitions for teammates (tools allowlist, model, system prompt), task management (pending, in progress, completed, dependencies, self-claim, file locking), inter-agent communication (message, broadcast, idle notifications), plan approval workflow (read-only plan mode, approve/reject), permissions inheritance, context and communication model, team lifecycle (create, coordinate, shut down, clean up), quality gate hooks (TeammateIdle, TaskCreated, TaskCompleted), comparing agent teams vs subagents (context, communication, coordination, token cost), team configuration storage (~/.claude/teams/, ~/.claude/tasks/), use case examples (parallel code review, competing hypotheses debugging), best practices (context, team size 3-5, task sizing 5-6 per teammate, avoiding file conflicts, monitoring), troubleshooting (teammates not appearing, permission prompts, orphaned tmux sessions), and current limitations (no session resumption, one team per session, no nested teams, fixed lead, split panes require tmux/iTerm2). Load when discussing agent teams, team lead, teammates, teammate mode, team coordination, task list, shared tasks, team messaging, broadcast, agent team architecture, team cleanup, team shutdown, plan approval, TeammateIdle hook, TaskCreated hook, TaskCompleted hook, subagents vs agent teams, parallel work coordination, tmux split panes, teammate spawning, team size, CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, or any agent-teams-related topic for Claude Code.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams -- coordinating multiple Claude Code instances working together, with shared tasks, inter-agent messaging, and centralized management.

## Quick Reference

### Enable Agent Teams

Agent teams are **experimental** and disabled by default. Requires Claude Code v2.1.32+.

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Set in `settings.json` or as a shell environment variable.

### Agent Teams vs Subagents

| | Subagents | Agent Teams |
|:--|:----------|:------------|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

Use subagents for quick, focused workers. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### Architecture Components

| Component | Role |
|:----------|:-----|
| **Team lead** | Main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

### Storage Locations

| Resource | Path |
|:---------|:-----|
| Team config | `~/.claude/teams/{team-name}/config.json` |
| Task list | `~/.claude/tasks/{team-name}/` |

Team config is auto-generated and auto-updated -- do not edit by hand. Use subagent definitions for reusable teammate roles instead.

### Display Modes

| Mode | Description | Requirements |
|:-----|:-----------|:-------------|
| `in-process` | All teammates in main terminal; Shift+Down to cycle | Any terminal |
| `tmux` / split panes | Each teammate in own pane; click to interact | tmux or iTerm2 with `it2` CLI |
| `auto` (default) | Split panes if inside tmux, in-process otherwise | -- |

Configure via `~/.claude.json`:

```json
{
  "teammateMode": "in-process"
}
```

Or per-session: `claude --teammate-mode in-process`

### Task States and Dependencies

| State | Description |
|:------|:-----------|
| **Pending** | Not yet started; blocked if dependencies unresolved |
| **In progress** | Claimed by a teammate |
| **Completed** | Done; unblocks dependent tasks automatically |

Task claiming uses file locking to prevent race conditions. Teammates can self-claim the next unassigned, unblocked task after finishing one.

### In-Process Mode Controls

| Key | Action |
|:----|:-------|
| Shift+Down | Cycle through teammates (wraps to lead after last) |
| Enter | View a teammate's session |
| Escape | Interrupt teammate's current turn |
| Ctrl+T | Toggle the task list |

### Communication

| Method | Description |
|:-------|:-----------|
| **message** | Send to one specific teammate by name |
| **broadcast** | Send to all teammates simultaneously (use sparingly -- costs scale with team size) |
| **Idle notifications** | Automatic notification to lead when teammate finishes |
| **Automatic delivery** | Messages delivered without polling |

### Plan Approval Workflow

1. Spawn teammate with plan approval required
2. Teammate works in read-only plan mode
3. Teammate sends plan approval request to lead
4. Lead reviews and approves or rejects with feedback
5. If rejected, teammate revises and resubmits
6. Once approved, teammate exits plan mode and implements

The lead makes approval decisions autonomously. Influence judgment via prompt criteria (e.g., "only approve plans that include test coverage").

### Subagent Definitions for Teammates

Reference a subagent type by name when spawning:

- Teammate honors the definition's `tools` allowlist and `model`
- Definition body appended to teammate's system prompt (not replacing it)
- Team coordination tools (`SendMessage`, task tools) always available regardless of `tools` restrictions
- `skills` and `mcpServers` frontmatter fields are **not** applied to teammates

### Permissions

- Teammates inherit the lead's permission settings at spawn
- If lead uses `--dangerously-skip-permissions`, all teammates do too
- Individual teammate modes can be changed after spawning
- Per-teammate modes cannot be set at spawn time

### Quality Gate Hooks

| Hook | When it fires | Exit code 2 effect |
|:-----|:-------------|:-------------------|
| `TeammateIdle` | Teammate about to go idle | Send feedback, keep teammate working |
| `TaskCreated` | Task being created | Prevent creation, send feedback |
| `TaskCompleted` | Task being marked complete | Prevent completion, send feedback |

### Team Lifecycle

1. **Create**: ask Claude to create a team (or Claude proposes one); Claude won't create without approval
2. **Coordinate**: lead creates tasks, spawns teammates, assigns work
3. **Work**: teammates claim tasks, communicate, complete work
4. **Shut down teammates**: ask lead to request teammate shutdown (teammate can approve/reject)
5. **Clean up**: ask lead to clean up -- fails if active teammates remain; always use the lead for cleanup

### Best Practices

| Area | Guidance |
|:-----|:--------|
| **Team size** | Start with 3-5 teammates; token costs and coordination overhead scale linearly |
| **Tasks per teammate** | 5-6 tasks each keeps everyone productive |
| **Task sizing** | Self-contained units producing clear deliverables (function, test file, review) |
| **Context** | Include task-specific details in spawn prompt; teammates don't inherit lead's conversation history |
| **File conflicts** | Break work so each teammate owns different files; two teammates editing the same file causes overwrites |
| **Monitoring** | Check in on progress; redirect approaches that aren't working |
| **Starting out** | Begin with research/review tasks (PRs, library research, bug investigation) before parallel implementation |

### Troubleshooting

| Problem | Solution |
|:--------|:--------|
| Teammates not appearing | Press Shift+Down (may be running but not visible); verify task complexity warrants a team |
| Split panes not working | Check `which tmux`; for iTerm2, verify `it2` CLI and Python API enabled |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Check output via Shift+Down or click pane; give additional instructions or spawn replacement |
| Lead shuts down early | Tell lead to keep going or wait for teammates to finish |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |

### Limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` do not restore them)
- Task status can lag (teammates may not mark tasks completed; check manually)
- Shutdown can be slow (teammates finish current request before stopping)
- One team per session; clean up before starting a new one
- No nested teams (teammates cannot spawn their own teams)
- Lead is fixed for the team's lifetime; cannot transfer leadership
- Permissions set at spawn; per-teammate modes only changeable after spawn
- Split panes require tmux or iTerm2 (not supported in VS Code terminal, Windows Terminal, or Ghostty)

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate Teams of Claude Code Sessions](references/claude-code-agent-teams.md) -- Full guide covering team architecture, display modes, task management, communication, plan approval, subagent definitions, permissions, use case examples, best practices, troubleshooting, and limitations

## Sources

- Orchestrate Teams of Claude Code Sessions: https://code.claude.com/docs/en/agent-teams.md
