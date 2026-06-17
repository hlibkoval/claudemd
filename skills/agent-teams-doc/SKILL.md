---
name: agent-teams-doc
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances working together with shared tasks, inter-agent messaging, and centralized management.

## Quick Reference

### What Are Agent Teams?

Agent teams let you run multiple Claude Code instances in parallel. One session acts as the **team lead**; the others are **teammates** with their own context windows. Teammates can communicate directly with each other — unlike subagents, which only report back to the caller.

**Status: experimental.** Disabled by default. Enable via `settings.json` or environment variable:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent Teams vs. Subagents

| | Subagents | Agent teams |
| :--- | :--- | :--- |
| **Context** | Own context window; results return to the caller | Own context window; fully independent |
| **Communication** | Report results back to the main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

### Best Use Cases

| Scenario | Why teams help |
| :--- | :--- |
| Research and review | Multiple teammates investigate different aspects simultaneously |
| New modules or features | Each teammate owns a separate piece without overlap |
| Debugging with competing hypotheses | Teammates test different theories in parallel |
| Cross-layer coordination | Frontend, backend, and tests each owned by a different teammate |

**Not ideal for:** sequential tasks, same-file edits, or work with many dependencies — use a single session or subagents instead.

### Architecture Components

| Component | Role |
| :--- | :--- |
| **Team lead** | The main Claude Code session that spawns teammates and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

### Storage Locations

| Path | Contents | Persistence |
| :--- | :--- | :--- |
| `~/.claude/teams/{team-name}/config.json` | Runtime state (session IDs, pane IDs) — do not edit | Removed when session ends |
| `~/.claude/tasks/{team-name}/` | Task list | Persists across sessions (governed by `cleanupPeriodDays`) |

Team name is `session-` followed by the first 8 characters of the session ID.

### Display Modes

| Mode | How to set | Requirements |
| :--- | :--- | :--- |
| `in-process` (default fallback) | `"teammateMode": "in-process"` in `~/.claude/settings.json` or `--teammate-mode in-process` | Any terminal |
| `tmux` (split panes) | `"teammateMode": "tmux"` | tmux or iTerm2 with `it2` CLI and Python API enabled |
| `auto` (default) | omit setting | Uses split panes if inside tmux/iTerm2, otherwise in-process |

### Key Keyboard Shortcuts (in-process mode)

| Key | Action |
| :--- | :--- |
| Shift+Down | Cycle through teammates (wraps back to lead after the last) |
| Enter | View a teammate's session |
| Escape | Interrupt a teammate's current turn |
| Ctrl+T | Toggle the task list |

### Task States and Claiming

Tasks have three states: **pending**, **in progress**, **completed**. Tasks can depend on other tasks — a pending task with unresolved dependencies cannot be claimed until those are done.

- **Lead assigns**: tell the lead which task to give which teammate
- **Self-claim**: a teammate picks up the next unassigned, unblocked task after finishing one
- File locking prevents race conditions when multiple teammates try to claim the same task simultaneously

### Hooks for Quality Gates

| Hook | When it runs | Exit code 2 effect |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate is about to go idle | Send feedback and keep the teammate working |
| `TaskCreated` | Task is being created | Prevent creation and send feedback |
| `TaskCompleted` | Task is being marked complete | Prevent completion and send feedback |

### Permissions

Teammates inherit the lead's permission settings at spawn time. If the lead runs with `--dangerously-skip-permissions`, all teammates do too. Per-teammate modes can be changed after spawning but cannot be set at spawn time.

### Using Subagent Definitions as Teammates

Spawn a teammate from a named subagent type (project, user, plugin, or CLI-defined scope):

```text
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

The definition's `tools` allowlist and `model` are honored. Its body appends to the teammate's system prompt. Team coordination tools (`SendMessage`, task tools) are always available regardless of the `tools` restriction.

Note: `skills` and `mcpServers` frontmatter fields in a subagent definition are **not** applied when running as a teammate — teammates load skills and MCP servers from project/user settings instead.

### Context and Communication

Each teammate loads the same project context as a regular session (CLAUDE.md, MCP servers, skills) plus the spawn prompt. The lead's conversation history does **not** carry over.

- Messages are delivered automatically — the lead does not need to poll
- Teammates notify the lead when they go idle
- All agents share visibility of the task list
- Send to one teammate by name; to reach everyone, send one message per recipient

### Token Costs

Token usage scales linearly with the number of active teammates. Each has its own context window. Use 3–5 teammates for most workflows. Rule of thumb: 5–6 tasks per teammate keeps everyone productive without excessive context switching.

### Best Practices Summary

| Practice | Guidance |
| :--- | :--- |
| Team size | Start with 3–5 teammates; scale only when genuinely beneficial |
| Task sizing | Self-contained units with a clear deliverable (a function, a test file, a review) |
| Context | Include task-specific details in the spawn prompt — teammates don't inherit the lead's history |
| File conflicts | Assign each teammate a distinct set of files to avoid overwrites |
| Monitoring | Check in, redirect as needed; don't let teams run unattended for long |
| Waiting | If the lead starts implementing instead of delegating, tell it to wait for teammates |

### Limitations (Experimental)

- `/resume` and `/rewind` do not restore in-process teammates
- Task status can lag — teammates may not mark tasks complete, blocking dependents
- Shutdown can be slow (waits for current request/tool call to finish)
- One team per session; no cross-session sharing
- No nested teams — only the lead can spawn teammates
- Lead is fixed for the session's lifetime; leadership cannot be transferred
- Split panes not supported in VS Code terminal, Windows Terminal, or Ghostty

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Teammates not appearing | Press Shift+Down to check in-process mode; verify task complexity; check tmux is in PATH (`which tmux`) |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammate stopped on error | Use Shift+Down or click pane to inspect; give instructions directly or spawn a replacement |
| Lead finishes before work is done | Tell it to keep going or wait for teammates |
| Orphaned tmux session | `tmux ls` then `tmux kill-session -t <session-name>` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — Full agent teams reference: setup, display modes, task management, architecture, use case examples, best practices, and limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
