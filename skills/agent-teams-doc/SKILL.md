---
name: agent-teams-doc
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances working together with shared tasks, inter-agent messaging, and centralized team management.

## Quick Reference

### Enable Agent Teams

Agent teams are **disabled by default** and experimental. Enable via `settings.json` or environment:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Requires Claude Code v2.1.32 or later (`claude --version`).

### Architecture Components

| Component     | Role                                                                                 |
| :------------ | :----------------------------------------------------------------------------------- |
| **Team lead** | Main Claude Code session — creates team, spawns teammates, coordinates work          |
| **Teammates** | Separate Claude Code instances, each with their own context window and assigned tasks |
| **Task list** | Shared work items that teammates claim and complete; supports dependencies            |
| **Mailbox**   | Messaging system for direct communication between agents                             |

Storage (auto-managed, removed on cleanup):
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Subagents vs. Agent Teams

| Feature           | Subagents                                        | Agent Teams                                         |
| :---------------- | :----------------------------------------------- | :-------------------------------------------------- |
| **Context**       | Own context window; results return to caller     | Own context window; fully independent               |
| **Communication** | Report results back to main agent only           | Teammates message each other directly               |
| **Coordination**  | Main agent manages all work                      | Shared task list with self-coordination             |
| **Best for**      | Focused tasks where only the result matters      | Complex work requiring discussion and collaboration |
| **Token cost**    | Lower: results summarized back to main context   | Higher: each teammate is a separate Claude instance |

### Display Modes

| Mode           | Description                                                         | Setting value  |
| :------------- | :------------------------------------------------------------------ | :------------- |
| `"in-process"` | All teammates run in main terminal; Shift+Down to cycle             | `"in-process"` |
| `"tmux"`       | Each teammate in its own split pane (requires tmux or iTerm2)       | `"tmux"`       |
| `"auto"`       | Uses split panes if already in tmux/iTerm2, otherwise in-process    | `"auto"` (default) |

Configure in `~/.claude/settings.json`:
```json
{ "teammateMode": "in-process" }
```
Or per-session: `claude --teammate-mode in-process`

### Key Controls (In-Process Mode)

| Action                     | Key / Command          |
| :------------------------- | :--------------------- |
| Cycle through teammates    | Shift+Down             |
| Toggle task list           | Ctrl+T                 |
| Interrupt teammate's turn  | Escape (after Enter)   |
| Send message to teammate   | Type after cycling to them |

### Task States & Lifecycle

Tasks have three states: **pending** → **in progress** → **completed**. Tasks can depend on other tasks; blocked tasks cannot be claimed until dependencies complete. File locking prevents race conditions when multiple teammates claim simultaneously.

### Hooks for Quality Gates

| Hook              | Trigger                                 | Exit code 2 effect                              |
| :---------------- | :-------------------------------------- | :---------------------------------------------- |
| `TeammateIdle`    | Teammate about to go idle               | Send feedback, keep teammate working            |
| `TaskCreated`     | Task being created                      | Prevent creation, send feedback                 |
| `TaskCompleted`   | Task being marked complete              | Prevent completion, send feedback               |

### Permissions

- Teammates start with the lead's permission settings
- If lead runs `--dangerously-skip-permissions`, all teammates do too
- Per-teammate modes can be changed after spawning, but not set at spawn time

### Using Subagent Definitions for Teammates

Reference a subagent type by name when spawning:
```
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```
- Honors the definition's `tools` allowlist and `model`
- Definition body appended to teammate's system prompt (not replaced)
- Team coordination tools (`SendMessage`, task tools) always available even when `tools` restricts others
- Note: `skills` and `mcpServers` frontmatter fields in subagent definitions are NOT applied to teammates — teammates load those from project/user settings

### Best Practices Summary

| Practice                   | Guidance                                                                             |
| :------------------------- | :----------------------------------------------------------------------------------- |
| Team size                  | Start with 3–5 teammates; scale only when genuinely beneficial                       |
| Task sizing                | Self-contained units producing a clear deliverable; 5–6 tasks per teammate           |
| Context                    | Include task-specific details in spawn prompt — teammates don't inherit lead history |
| File conflicts             | Break work so each teammate owns different files                                     |
| Token costs                | Each teammate has its own context window; costs scale linearly with team size        |
| Starting out               | Begin with research/review tasks before parallel implementation                      |

### Best Use Cases

- Research and review: investigate different aspects simultaneously
- New modules or features: teammates own separate pieces
- Debugging with competing hypotheses: parallel theory testing
- Cross-layer changes: frontend, backend, and tests each owned by a different teammate

### Known Limitations (Experimental)

- No session resumption for in-process teammates (`/resume` and `/rewind` don't restore them)
- Task status can lag — teammates may fail to mark tasks complete, blocking dependents
- Shutdown can be slow (finishes current request/tool call first)
- One team at a time per lead
- No nested teams — only the lead can spawn teammates
- Lead is fixed for team lifetime — cannot transfer leadership
- Split panes require tmux or iTerm2 (not supported in VS Code terminal, Windows Terminal, Ghostty)

### Cleanup

```
Clean up the team
```
Always use the lead to clean up (not teammates). Fails if active teammates remain — shut them down first.

To kill orphaned tmux sessions:
```bash
tmux ls
tmux kill-session -t <session-name>
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — Full guide to enabling, starting, controlling, and troubleshooting agent teams

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
