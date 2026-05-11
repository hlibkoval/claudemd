---
name: agent-teams-doc
description: Complete official documentation for Claude Code agent teams — enabling and starting teams, display modes, task assignment, teammate communication, plan approval, hooks, architecture, subagent definitions, permissions, token costs, best practices, troubleshooting, and limitations.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

### Enable Agent Teams

Agent teams are **experimental and disabled by default**. Requires Claude Code v2.1.32+.

Enable via `settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Architecture Components

| Component     | Role                                                                                       |
| :------------ | :----------------------------------------------------------------------------------------- |
| **Team lead** | The main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks                            |
| **Task list** | Shared list of work items that teammates claim and complete                                |
| **Mailbox**   | Messaging system for direct communication between agents                                   |

### Storage Locations

| Resource     | Path                                       |
| :----------- | :----------------------------------------- |
| Team config  | `~/.claude/teams/{team-name}/config.json`  |
| Task list    | `~/.claude/tasks/{team-name}/`             |

Do not hand-edit team config — it is overwritten on each state update.

### Display Modes

| Mode           | Description                                                          | Requirement                  |
| :------------- | :------------------------------------------------------------------- | :--------------------------- |
| `auto`         | Uses split panes if inside tmux, in-process otherwise (default)      | None                         |
| `in-process`   | All teammates run inside the main terminal; use Shift+Down to cycle  | None                         |
| `tmux`         | Each teammate gets its own split pane                                | tmux or iTerm2 with `it2`    |

Set in `~/.claude/settings.json`:
```json
{ "teammateMode": "in-process" }
```

Or as a CLI flag:
```bash
claude --teammate-mode in-process
```

### Keyboard Controls (In-Process Mode)

| Key           | Action                                             |
| :------------ | :------------------------------------------------- |
| Shift+Down    | Cycle through teammates                            |
| Enter         | View a teammate's session                          |
| Escape        | Interrupt a teammate's current turn                |
| Ctrl+T        | Toggle the shared task list                        |

### Task States

Tasks have three states: **pending**, **in progress**, and **completed**. Tasks can declare dependencies; a task with unresolved dependencies cannot be claimed until dependencies complete. Task claiming uses file locking to prevent race conditions.

### Hook Events for Agent Teams

| Event            | When it fires                                          | Exit code 2 effect                              |
| :--------------- | :----------------------------------------------------- | :---------------------------------------------- |
| `TeammateIdle`   | A teammate is about to go idle                         | Send feedback and keep the teammate working     |
| `TaskCreated`    | A task is being created                                | Prevent creation and send feedback              |
| `TaskCompleted`  | A task is being marked complete                        | Prevent completion and send feedback            |

### Agent Teams vs. Subagents

|                   | Subagents                                        | Agent teams                                         |
| :---------------- | :----------------------------------------------- | :-------------------------------------------------- |
| **Context**       | Own context window; results return to the caller | Own context window; fully independent               |
| **Communication** | Report results back to the main agent only       | Teammates message each other directly               |
| **Coordination**  | Main agent manages all work                      | Shared task list with self-coordination             |
| **Best for**      | Focused tasks where only the result matters      | Complex work requiring discussion and collaboration |
| **Token cost**    | Lower: results summarized back to main context   | Higher: each teammate is a separate Claude instance |

### Best Use Cases

| Task type                        | Why agent teams help                                            |
| :------------------------------- | :-------------------------------------------------------------- |
| Research and review              | Multiple teammates investigate different aspects simultaneously  |
| New modules or features          | Each teammate owns a separate piece without conflicts           |
| Debugging with competing theories| Teammates test theories in parallel and converge faster         |
| Cross-layer changes              | Frontend, backend, and tests each owned by a different teammate |

### Permissions

- Teammates start with the **lead's permission settings**
- If lead runs with `--dangerously-skip-permissions`, all teammates do too
- Per-teammate modes can be changed after spawning, but not set at spawn time

### Subagent Definitions as Teammate Types

Reference a subagent type when spawning a teammate:
```text
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

- Honors the definition's `tools` allowlist and `model`
- Definition body appended to system prompt (not a replacement)
- Team coordination tools (`SendMessage`, task tools) are always available
- `skills` and `mcpServers` frontmatter fields are **not** applied for teammates

### Team Size Guidelines

- Start with **3–5 teammates** for most workflows
- Aim for **5–6 tasks per teammate** to keep everyone productive
- Scale up only when work genuinely benefits from simultaneous parallelism
- Token costs scale linearly with active teammates

### Limitations

| Limitation                       | Detail                                                                              |
| :------------------------------- | :---------------------------------------------------------------------------------- |
| No session resumption            | `/resume` and `/rewind` do not restore in-process teammates                         |
| Task status lag                  | Teammates sometimes fail to mark tasks completed; update manually if stuck          |
| Slow shutdown                    | Teammates finish their current request before stopping                              |
| One team at a time               | A lead can only manage one team; clean up before creating another                   |
| No nested teams                  | Teammates cannot spawn their own teams or teammates                                 |
| Lead is fixed                    | Cannot promote a teammate or transfer leadership                                     |
| Split panes limited              | Not supported in VS Code integrated terminal, Windows Terminal, or Ghostty          |

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — Full guide to enabling, starting, controlling, and troubleshooting agent teams, including architecture, display modes, hooks, best practices, and use case examples

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
