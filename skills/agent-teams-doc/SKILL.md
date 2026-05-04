---
name: agent-teams-doc
description: Complete official documentation for orchestrating teams of Claude Code sessions — enabling agent teams, starting and controlling teams, display modes, task assignment, teammate communication, hooks, architecture, best practices, and limitations.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for orchestrating teams of Claude Code sessions working together in parallel.

## Quick Reference

### Enable Agent Teams

Agent teams are **disabled by default** and require Claude Code v2.1.32+. Enable via `settings.json` or environment:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Subagents vs. Agent Teams

| | Subagents | Agent Teams |
| :--- | :--- | :--- |
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

### Display Modes

| Mode | How to set | Requirements |
| :--- | :--- | :--- |
| `auto` (default) | — | Uses split panes if inside tmux, in-process otherwise |
| `in-process` | `"teammateMode": "in-process"` in `~/.claude/settings.json` | Any terminal |
| `tmux` | `"teammateMode": "tmux"` in `~/.claude/settings.json` | tmux or iTerm2 + `it2` CLI |

Override for a single session:
```bash
claude --teammate-mode in-process
```

**In-process controls:** Shift+Down to cycle teammates, Enter to view session, Escape to interrupt, Ctrl+T to toggle task list.

### Architecture Components

| Component | Role |
| :--- | :--- |
| **Team lead** | Main Claude Code session; creates team, spawns teammates, coordinates work |
| **Teammates** | Separate Claude Code instances; each works on assigned tasks |
| **Task list** | Shared work items that teammates claim and complete (pending / in progress / completed) |
| **Mailbox** | Messaging system for direct inter-agent communication |

**Storage locations:**
- Team config: `~/.claude/teams/{team-name}/config.json` (auto-generated; do not hand-edit)
- Task list: `~/.claude/tasks/{team-name}/`

### Hooks for Quality Gates

| Hook | Trigger | Exit 2 effect |
| :--- | :--- | :--- |
| `TeammateIdle` | Teammate about to go idle | Send feedback, keep teammate working |
| `TaskCreated` | Task being created | Prevent creation, send feedback |
| `TaskCompleted` | Task being marked complete | Prevent completion, send feedback |

### Key Limitations (Experimental)

- No session resumption with in-process teammates (`/resume`, `/rewind` don't restore teammates)
- Task status can lag — teammates may fail to mark tasks completed
- One team per session — clean up before starting another
- No nested teams — teammates cannot spawn their own teams
- Lead is fixed — cannot promote a teammate or transfer leadership
- Permissions set at spawn time from the lead's mode (adjustable per-teammate after spawn)
- Split panes not supported in VS Code integrated terminal, Windows Terminal, or Ghostty

### Best Practices

| Concern | Guidance |
| :--- | :--- |
| **Team size** | Start with 3–5 teammates; scale only when work genuinely benefits from parallelism |
| **Task density** | 5–6 tasks per teammate keeps everyone productive without excessive context switching |
| **Task size** | Self-contained units with a clear deliverable (a function, test file, or review) |
| **File conflicts** | Each teammate should own a different set of files |
| **Context** | Include task-specific details in the spawn prompt — teammates don't inherit lead's history |
| **Coordination** | Check in regularly; don't let teams run unattended for long periods |

### Common Control Prompts

```text
# Start a team
Create an agent team with 3 teammates: one on security, one on performance, one on test coverage.

# Specify models
Create a team with 4 teammates. Use Sonnet for each teammate.

# Require plan approval
Spawn an architect teammate to refactor the auth module. Require plan approval before they make any changes.

# Direct a teammate
Ask the researcher teammate to focus on the authentication module only.

# Shut down a teammate
Ask the researcher teammate to shut down.

# Clean up the team
Clean up the team.

# Wait for teammates
Wait for your teammates to complete their tasks before proceeding.
```

### Subagent Definitions as Teammates

Spawn a teammate using a named [subagent](/en/sub-agents) definition:

```text
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

The teammate honors the definition's `tools` allowlist and `model`; the definition body is appended to the system prompt. Team coordination tools (`SendMessage`, task tools) are always available even when `tools` restricts others.

**Note:** `skills` and `mcpServers` frontmatter fields in subagent definitions are **not** applied to teammates — teammates load these from project/user settings.

### Permissions

Teammates inherit the lead's permission settings at spawn time. If the lead uses `--dangerously-skip-permissions`, all teammates do too. Individual modes can be changed after spawn.

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — enabling agent teams, starting a team, display modes, task assignment, teammate communication, plan approval, hooks, architecture, storage, subagent definitions, permissions, token usage, use case examples, best practices, troubleshooting, and limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
