---
name: agent-teams-doc
description: Complete official documentation for Claude Code agent teams — enabling teams, starting and controlling teams, display modes, task assignment, subagent definitions as teammates, context sharing, hooks, best practices, troubleshooting, and known limitations.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

Agent teams let you coordinate multiple Claude Code instances working together. One session acts as the **team lead**; the rest are **teammates** that work independently in their own context windows and communicate directly with each other through a shared task list and mailbox. This is an experimental feature disabled by default.

### Enable agent teams

Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your environment or in `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Requires Claude Code v2.1.32 or later.

### Agent teams vs subagents

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
| **Team lead** | Main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

### Storage locations

| Resource | Path |
| :--- | :--- |
| Team config | `~/.claude/teams/{team-name}/config.json` |
| Task list | `~/.claude/tasks/{team-name}/` |

Do not hand-edit the team config — it is overwritten on each state update.

### Display modes

| Mode | Description | Requirements |
| :--- | :--- | :--- |
| `"auto"` (default) | Split panes if inside tmux, in-process otherwise | — |
| `"in-process"` | All teammates run inside your main terminal | Any terminal |
| `"tmux"` | Each teammate gets its own pane | tmux or iTerm2 |

Configure via `teammateMode` in `~/.claude/settings.json` or `--teammate-mode` CLI flag.

### Task states and dependency

Tasks have three states: **pending**, **in progress**, and **completed**. A pending task with unresolved dependencies cannot be claimed until those dependencies complete. Task claiming uses file locking to prevent race conditions.

### Hooks for quality gates

| Hook | Trigger | Exit 2 effect |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate is about to go idle | Send feedback and keep teammate working |
| `TaskCreated` | A task is being created | Prevent creation and send feedback |
| `TaskCompleted` | A task is being marked complete | Prevent completion and send feedback |

### Permissions

Teammates start with the lead's permission settings. If the lead uses `--dangerously-skip-permissions`, all teammates do too. Per-teammate permission modes can be changed after spawning, but not at spawn time.

### Using subagent definitions as teammates

Reference a subagent by name when asking Claude to spawn a teammate:

```text
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

The teammate honors the definition's `tools` allowlist and `model`. The definition body is appended to the teammate's system prompt. Team coordination tools (`SendMessage`, task tools) are always available regardless of `tools` restrictions.

Note: `skills` and `mcpServers` frontmatter fields are not applied when a definition runs as a teammate — those are loaded from project/user settings instead.

### Keyboard shortcuts (in-process mode)

| Key | Action |
| :--- | :--- |
| Shift+Down | Cycle through teammates |
| Enter | View a teammate's session |
| Escape | Interrupt current turn |
| Ctrl+T | Toggle the task list |

### Best practices summary

- **Team size**: start with 3–5 teammates; scale only when parallelism genuinely helps
- **Task sizing**: aim for self-contained units (a function, a test file, a review); 5–6 tasks per teammate keeps everyone productive
- **Context**: include task-specific details in the spawn prompt — teammates don't inherit the lead's conversation history
- **File conflicts**: ensure each teammate owns a different set of files
- **Cleanup**: always ask the lead (not a teammate) to clean up; shut down all teammates first
- **Monitoring**: check in on progress and redirect as needed rather than letting teams run unattended

### Limitations (experimental)

| Limitation | Detail |
| :--- | :--- |
| No session resumption | `/resume` and `/rewind` do not restore in-process teammates |
| Task status lag | Teammates sometimes fail to mark tasks complete; update manually if stuck |
| Slow shutdown | Teammates finish their current request before shutting down |
| One team per session | A lead can only manage one team at a time |
| No nested teams | Teammates cannot spawn their own teams or teammates |
| Fixed lead | The session that creates the team is lead for its lifetime |
| Permissions at spawn | All teammates start with lead's permission mode |
| Split-pane limits | Not supported in VS Code integrated terminal, Windows Terminal, or Ghostty |

### Troubleshooting

| Issue | Fix |
| :--- | :--- |
| Teammates not appearing | Press Shift+Down to check; verify tmux is installed (`which tmux`) |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Give additional instructions or spawn replacement |
| Lead shuts down early | Tell it to keep going; ask it to wait for teammates before proceeding |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <session-name>` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — full guide covering when to use agent teams, comparing with subagents, enabling the feature, starting a team, display modes, task assignment, plan approval, direct teammate messaging, subagent definitions as teammates, context and communication, token usage, use case examples, best practices, troubleshooting, and known limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
