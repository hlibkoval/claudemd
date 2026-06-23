---
name: agent-teams-doc
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances working together, with shared tasks, inter-agent messaging, and centralized management.

## Quick Reference

### Enable Agent Teams

Agent teams are disabled by default. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` in settings or the environment:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Subagents vs Agent Teams

|                   | Subagents                                        | Agent teams                                         |
| :---------------- | :----------------------------------------------- | :-------------------------------------------------- |
| **Context**       | Own context window; results return to the caller | Own context window; fully independent               |
| **Communication** | Report results back to the main agent only       | Teammates message each other directly               |
| **Coordination**  | Main agent manages all work                      | Shared task list with self-coordination             |
| **Best for**      | Focused tasks where only the result matters      | Complex work requiring discussion and collaboration |
| **Token cost**    | Lower: results summarized back to main context   | Higher: each teammate is a separate Claude instance |

### Architecture Components

| Component     | Role                                                                    |
| :------------ | :---------------------------------------------------------------------- |
| **Team lead** | The main Claude Code session that spawns teammates and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks         |
| **Task list** | Shared list of work items that teammates claim and complete             |
| **Mailbox**   | Messaging system for communication between agents                       |

### Display Modes

| Mode          | Description                                                         | Requires              |
| :------------ | :------------------------------------------------------------------ | :-------------------- |
| `"in-process"` | All teammates run inside your main terminal (default since v2.1.179) | Any terminal         |
| `"auto"`      | Split panes when inside tmux/iTerm2, falls back to in-process       | tmux or iTerm2        |
| `"tmux"`      | Split-pane mode, auto-detects tmux or iTerm2                        | tmux or iTerm2        |
| `"iterm2"`    | iTerm2 native split panes explicitly (v2.1.186+)                    | `it2` CLI + Python API |

Set via `~/.claude/settings.json`:
```json
{ "teammateMode": "auto" }
```
Or per session: `claude --teammate-mode auto`

### Task States and Coordination

- Tasks have three states: **pending**, **in progress**, **completed**
- Tasks can depend on other tasks; blocked tasks cannot be claimed until dependencies complete
- **Lead assigns**: tell the lead which task to give to which teammate
- **Self-claim**: a teammate picks up the next unassigned, unblocked task on its own
- Task claiming uses file locking to prevent race conditions

### Storage Paths

| Path | Contents |
| :--- | :--- |
| `~/.claude/teams/{team-name}/config.json` | Runtime state (session IDs, pane IDs) — do not hand-edit |
| `~/.claude/tasks/{team-name}/` | Task list — persists across session resumes |

Team name is `session-` + first 8 characters of the session ID. Team config directory is removed on session end; task directory persists (governed by `cleanupPeriodDays`).

### In-Process Mode Controls

| Key | Action |
| :-- | :----- |
| Up/Down arrows | Select a teammate in the agent panel |
| Enter | Open selected teammate's transcript; type to message directly |
| Escape | Interrupt the selected teammate's current turn |
| `x` on selected | Stop the selected teammate |
| Ctrl+T | Toggle the task list |

Idle teammate rows hide after 30 seconds and reappear on the next turn (v2.1.181+).

### Hooks for Quality Gates

| Hook | When | How to block |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate about to go idle | Exit code 2 — sends feedback, keeps teammate working |
| `TaskCreated` | Task being created | Exit code 2 — prevents creation, sends feedback |
| `TaskCompleted` | Task being marked complete | Exit code 2 — prevents completion, sends feedback |

### Permissions

- Teammates start with the lead's permission settings
- If the lead uses `--dangerously-skip-permissions`, all teammates do too
- Individual teammate modes can be changed after spawning, but not at spawn time

### Using Subagent Definitions as Teammates

Reference a subagent type by name when asking Claude to spawn:

```
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

- Teammate honors the definition's `tools` allowlist and `model`
- Definition body appends to the teammate's system prompt (does not replace it)
- Team coordination tools (`SendMessage`, task management) are always available even when `tools` restricts others
- `skills` and `mcpServers` frontmatter fields are not applied when running as a teammate

### Best Practices

| Practice | Guidance |
| :--- | :--- |
| **Team size** | Start with 3–5 teammates; 5–6 tasks per teammate keeps everyone productive |
| **Task sizing** | Self-contained units with a clear deliverable (function, test file, review) |
| **Context** | Include task-specific details in the spawn prompt; teammates don't inherit lead's history |
| **File conflicts** | Assign each teammate a different set of files to avoid overwrites |
| **Lead patience** | Tell the lead "wait for your teammates to complete their tasks before proceeding" if it starts implementing itself |
| **First use** | Start with research/review tasks before parallel implementation |

### Limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` don't restore teammates)
- Task status can lag; teammates may not always mark tasks complete
- Shutdown can be slow (teammate finishes its current request first)
- One team per session; no additional named teams or shared teams across sessions
- No nested teams; only the lead can spawn or manage teammates
- Lead is fixed for the session lifetime; no leadership transfer
- Split panes not supported in VS Code integrated terminal, Windows Terminal, or Ghostty

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — Full coverage: enabling, architecture, display modes, task coordination, hooks, permissions, best practices, troubleshooting, limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
