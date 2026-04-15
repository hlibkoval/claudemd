---
name: agent-teams-doc
description: Complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances as a team with a shared task list, inter-agent messaging, display modes, and lead/teammate workflows.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

Agent teams let one Claude Code session (the **lead**) spawn and coordinate multiple independent Claude Code sessions (**teammates**) that share a task list and message each other directly. They are **experimental** and require Claude Code v2.1.32 or later.

### Enable agent teams

Set the env var (in shell or `settings.json`):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Subagents vs agent teams

|                   | Subagents                                  | Agent teams                                  |
| :---------------- | :----------------------------------------- | :------------------------------------------- |
| **Context**       | Own context window; results return to caller | Own context window; fully independent       |
| **Communication** | Report back to main agent only             | Teammates message each other directly        |
| **Coordination**  | Main agent manages all work                | Shared task list with self-coordination      |
| **Best for**      | Focused tasks where only the result matters | Complex work needing discussion + collaboration |
| **Token cost**    | Lower (results summarized back)            | Higher (each teammate is a separate instance) |

### Architecture components

| Component     | Role                                                            |
| :------------ | :-------------------------------------------------------------- |
| **Team lead** | Main session that creates the team, spawns teammates, coordinates |
| **Teammates** | Separate Claude Code instances, each working on assigned tasks  |
| **Task list** | Shared list of work items teammates claim and complete          |
| **Mailbox**   | Messaging system for inter-agent communication                  |

Local storage:

- Team config: `~/.claude/teams/{team-name}/config.json` (auto-managed; do not hand-edit)
- Task list: `~/.claude/tasks/{team-name}/`

### Display modes

| Mode          | Behavior                                                | Requirements          |
| :------------ | :------------------------------------------------------ | :-------------------- |
| `in-process`  | All teammates inside main terminal; Shift+Down to cycle | Any terminal          |
| `tmux` (split panes) | Each teammate in its own pane                    | tmux or iTerm2 + it2  |
| `auto` (default) | Split panes if already in tmux, else in-process      | —                     |

Configure globally in `~/.claude.json`:

```json
{ "teammateMode": "in-process" }
```

Or per-session via flag: `claude --teammate-mode in-process`

### Key keybindings (in-process mode)

| Key          | Action                                            |
| :----------- | :------------------------------------------------ |
| `Shift+Down` | Cycle through teammates (wraps back to lead)      |
| `Enter`      | View a teammate's session                         |
| `Escape`     | Interrupt teammate's current turn                 |
| `Ctrl+T`     | Toggle the task list                              |

### Task states and claiming

- States: `pending`, `in progress`, `completed`
- Tasks may have dependencies; blocked tasks cannot be claimed until dependencies complete
- Claiming uses file locking to prevent races
- **Lead assigns** tasks explicitly OR teammates **self-claim** the next unblocked task

### Messaging

- `message`: send to one specific teammate
- `broadcast`: send to all teammates (use sparingly — costs scale with team size)
- Lead assigns each teammate a name at spawn; reference them by name in later prompts

### Plan approval

For risky tasks, require teammates to plan in read-only mode before implementing. The lead reviews and either approves or rejects with feedback. Lead approval is autonomous — give criteria in your prompt (e.g. "only approve plans that include test coverage").

### Subagent definitions as teammates

Spawn a teammate using a [subagent](https://code.claude.com/docs/en/sub-agents) type from any scope (project, user, plugin, CLI). Honors the subagent's `tools` allowlist and `model`; its body is appended to the teammate's system prompt. **Note**: the `skills` and `mcpServers` frontmatter fields in a subagent definition are NOT applied when running as a teammate — teammates load skills/MCP servers from project and user settings instead.

### Hooks for quality gates

| Hook            | Fires when                              | Exit code 2 effect                  |
| :-------------- | :-------------------------------------- | :---------------------------------- |
| `TeammateIdle`  | Teammate is about to go idle            | Sends feedback, keeps teammate working |
| `TaskCreated`   | A task is being created                 | Prevents creation, sends feedback   |
| `TaskCompleted` | A task is being marked complete         | Prevents completion, sends feedback |

### Permissions

Teammates start with the lead's permission settings. If the lead runs with `--dangerously-skip-permissions`, all teammates do too. You can change individual teammate modes after spawning, but cannot set per-teammate modes at spawn time.

### Cleanup

Always run cleanup from the lead (not a teammate). Shut down all teammates first, then ask the lead to "clean up the team". Cleanup fails if any teammates are still running.

### Best practices (summary)

- Start with **3-5 teammates** for most workflows; aim for 5-6 tasks per teammate
- Give teammates task-specific context in the spawn prompt (they don't inherit the lead's history, but they do load `CLAUDE.md`, MCP servers, and skills)
- Avoid file conflicts: each teammate owns a different set of files
- Start with research/review tasks before parallel implementation
- Tell the lead "wait for your teammates to complete their tasks before proceeding" if it starts doing work itself
- Monitor and steer rather than letting teams run unattended

### Known limitations

- No session resumption with in-process teammates (`/resume` and `/rewind` don't restore them)
- Task status can lag (teammates may forget to mark tasks complete)
- Shutdown can be slow (current request/tool call must finish)
- One team per session; no nested teams; lead is fixed for team lifetime
- Permissions set at spawn time only
- Split panes require tmux or iTerm2 (not supported in VS Code integrated terminal, Windows Terminal, or Ghostty)

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — full guide covering when to use agent teams, enabling them, starting/controlling/cleaning up a team, display modes, plan approval, subagent definitions as teammates, architecture, token usage, use case examples, best practices, troubleshooting, and limitations.

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
