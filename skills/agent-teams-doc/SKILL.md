---
name: agent-teams-doc
description: Complete official documentation for Claude Code agent teams — enabling and starting teams, display modes, task assignment, teammate communication, subagent definitions, hooks for quality gates, architecture, best practices, troubleshooting, and limitations.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

### Enable Agent Teams

Agent teams are disabled by default. Set in `settings.json` or environment:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Requires Claude Code v2.1.32 or later (`claude --version`).

### Agent Teams vs. Subagents

| | Subagents | Agent teams |
| :--- | :--- | :--- |
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

### Architecture

| Component | Role |
| :--- | :--- |
| **Team lead** | Main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

Storage locations (auto-generated, do not hand-edit):
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### Display Modes

| Mode | Description | Requirements |
| :--- | :--- | :--- |
| `auto` (default) | Split panes inside tmux, in-process otherwise | None |
| `in-process` | All teammates run inside your main terminal | None |
| `tmux` | Each teammate in its own pane; auto-detects tmux or iTerm2 | tmux or iTerm2 with `it2` CLI |

Set in `~/.claude/settings.json`:
```json
{ "teammateMode": "in-process" }
```

Or pass as a flag for a single session:
```bash
claude --teammate-mode in-process
```

### Keyboard Shortcuts (In-process Mode)

| Shortcut | Action |
| :--- | :--- |
| Shift+Down | Cycle through teammates |
| Enter | View a teammate's session |
| Escape | Interrupt teammate's current turn |
| Ctrl+T | Toggle the task list |

### Task States and Dependencies

Tasks have three states: **pending**, **in progress**, **completed**. Tasks can depend on other tasks; a pending task with unresolved dependencies cannot be claimed until those dependencies complete. File locking prevents race conditions when multiple teammates try to claim the same task simultaneously.

### Hooks for Quality Gates

| Hook event | When it fires | Blocking behavior |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate is about to go idle | Exit code 2 sends feedback and keeps teammate working |
| `TaskCreated` | A task is being created | Exit code 2 prevents creation and sends feedback |
| `TaskCompleted` | A task is being marked complete | Exit code 2 prevents completion and sends feedback |

### Permissions

Teammates start with the lead's permission settings. If the lead runs with `--dangerously-skip-permissions`, all teammates do too. Individual teammate modes can be changed after spawning, but not at spawn time.

### Using Subagent Definitions as Teammates

Reference a subagent type by name when asking Claude to spawn a teammate. The teammate honors that definition's `tools` allowlist and `model`, with the definition's body appended to the system prompt. Team coordination tools (`SendMessage`, task tools) are always available even when `tools` restricts other tools.

Note: `skills` and `mcpServers` frontmatter fields in a subagent definition are not applied when running as a teammate — those come from project/user settings instead.

### Best Practices

| Concern | Guidance |
| :--- | :--- |
| **Team size** | Start with 3–5 teammates; scale only when work genuinely benefits from parallelism |
| **Tasks per teammate** | 5–6 tasks per teammate keeps everyone productive without excessive context switching |
| **Task sizing** | Self-contained units with a clear deliverable (a function, test file, or review) |
| **Context** | Include task-specific details in the spawn prompt; teammates don't inherit lead's conversation history |
| **File conflicts** | Break work so each teammate owns a different set of files |
| **Cleanup** | Always use the lead to clean up; run cleanup after shutting down all teammates |

### Best Use Cases

- Research and review across multiple parallel angles
- New modules or features where teammates each own a separate piece
- Debugging with competing hypotheses — teammates test different theories in parallel
- Cross-layer changes spanning frontend, backend, and tests

### Limitations

| Limitation | Detail |
| :--- | :--- |
| No session resumption with in-process teammates | `/resume` and `/rewind` don't restore in-process teammates |
| Task status can lag | Teammates may fail to mark tasks completed, blocking dependent tasks |
| Shutdown can be slow | Teammates finish current request/tool call before shutting down |
| One team at a time | Clean up before creating a new team |
| No nested teams | Teammates cannot spawn their own teams; only the lead manages the team |
| Lead is fixed | Cannot promote a teammate or transfer leadership |
| Split panes require tmux or iTerm2 | Not supported in VS Code integrated terminal, Windows Terminal, or Ghostty |

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Teammates not appearing | Press Shift+Down to check if they're running in-process; verify task complexity warranted a team; confirm tmux is in PATH |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Use Shift+Down or click pane; give additional instructions or spawn a replacement |
| Lead shuts down too early | Tell the lead to keep going and wait for teammates before proceeding |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — enabling teams, starting a team, display modes, task assignment, teammate communication, subagent definitions, hooks, architecture, best practices, use case examples, troubleshooting, and limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
