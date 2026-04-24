---
name: agent-teams-doc
description: Complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances with shared task lists, inter-agent messaging, display modes, plan approval, quality gates via hooks, architecture, and known limitations.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

Agent teams let you coordinate multiple Claude Code instances (teammates) working in parallel. One session acts as the team lead; teammates each have their own context window and can communicate directly with each other. Agent teams are experimental and disabled by default.

### Enable agent teams

Add to `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Requires Claude Code v2.1.32 or later.

### Subagents vs. agent teams

| | Subagents | Agent teams |
| :--- | :--- | :--- |
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

### Architecture components

| Component | Role |
| :--- | :--- |
| **Team lead** | Main Claude Code session; creates team, spawns teammates, coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

Storage locations:
- Team config: `~/.claude/teams/{team-name}/config.json` (auto-generated, do not hand-edit)
- Task list: `~/.claude/tasks/{team-name}/`

### Display modes

| Mode | Description | Requires |
| :--- | :--- | :--- |
| `in-process` (default when not in tmux) | All teammates in your main terminal; Shift+Down to cycle | Any terminal |
| `tmux` / split panes | Each teammate in its own pane; click to interact | tmux or iTerm2 with `it2` CLI |
| `auto` | Split panes if already in tmux, in-process otherwise | — |

Set `teammateMode` in `~/.claude.json` or pass `--teammate-mode in-process` as a flag.

### Task states and claiming

Tasks have three states: pending, in-progress, completed. Tasks can depend on other tasks; a pending task with unresolved dependencies cannot be claimed until dependencies complete. File locking prevents race conditions when multiple teammates try to claim the same task.

- **Lead assigns**: explicitly tell the lead which task to give which teammate
- **Self-claim**: after finishing, a teammate picks up the next unassigned, unblocked task

### In-process mode keyboard shortcuts

| Key | Action |
| :--- | :--- |
| Shift+Down | Cycle through active teammates |
| Enter | View a teammate's session |
| Escape | Interrupt the teammate's current turn |
| Ctrl+T | Toggle the task list |

### Plan approval workflow

1. Spawn teammate with a requirement for plan approval before implementation
2. Teammate works in read-only plan mode until the lead approves
3. Lead reviews and approves or rejects with feedback
4. If rejected, teammate revises and resubmits
5. Once approved, teammate begins implementation

The lead makes approval decisions autonomously; influence its judgment through criteria in the spawn prompt.

### Quality gate hooks

| Hook | Trigger | Exit code 2 effect |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate about to go idle | Send feedback, keep teammate working |
| `TaskCreated` | Task being created | Prevent creation, send feedback |
| `TaskCompleted` | Task being marked complete | Prevent completion, send feedback |

### Subagent definitions as teammate types

Reference a subagent type by name when spawning: `"Spawn a teammate using the security-reviewer agent type..."`. The teammate honors that definition's `tools` allowlist and `model`; the body is appended to the system prompt. Team coordination tools (`SendMessage`, task management) are always available even when `tools` restricts other tools.

Note: `skills` and `mcpServers` frontmatter fields in a subagent definition are NOT applied when running as a teammate. Teammates load skills and MCP servers from project/user settings.

### Permissions

Teammates start with the lead's permission settings. If the lead uses `--dangerously-skip-permissions`, all teammates do too. Per-teammate modes can be changed after spawning but not set at spawn time.

### Best practices summary

| Practice | Guidance |
| :--- | :--- |
| Team size | Start with 3-5 teammates; scale only when genuinely beneficial |
| Tasks per teammate | 5-6 tasks per teammate keeps everyone productive |
| Task size | Self-contained units with clear deliverables (a function, test file, or review) |
| Context | Include task-specific details in spawn prompts; teammates don't inherit lead's history |
| File conflicts | Ensure each teammate owns a different set of files |
| Monitoring | Check in, redirect, and synthesize findings — don't let teams run unattended too long |

### Limitations (experimental)

- No session resumption with in-process teammates (`/resume`, `/rewind` don't restore teammates)
- Task status can lag; teammates sometimes fail to mark tasks completed
- Shutdown can be slow (teammate finishes current request before stopping)
- One team per session; clean up before starting a new one
- No nested teams; only the lead can spawn teammates
- Lead is fixed for the team's lifetime; no leadership transfer
- Split panes not supported in VS Code's integrated terminal, Windows Terminal, or Ghostty

### Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Teammates not appearing | Press Shift+Down; check task complexity; verify tmux in PATH with `which tmux` |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Check output with Shift+Down or pane click; give new instructions or spawn a replacement |
| Lead shuts down early | Tell it to keep going or wait for teammates before proceeding |
| Orphaned tmux sessions | Run `tmux ls` then `tmux kill-session -t <session-name>` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — full guide covering when to use agent teams, comparison with subagents, enabling the feature, starting and controlling teams, display modes, plan approval, task assignment, quality gate hooks, architecture details, context and communication, token usage, use case examples, best practices, troubleshooting, and limitations.

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
