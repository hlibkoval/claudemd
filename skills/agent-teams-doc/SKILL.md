---
name: agent-teams-doc
description: Complete official documentation for Claude Code agent teams — coordinating multiple Claude Code instances as a team with a lead, teammates, shared task list, and inter-agent messaging. Covers enabling the experimental feature, starting a team, display modes (in-process vs split panes), specifying teammates and models, plan approval, task assignment/claiming, shutdown, cleanup, quality-gate hooks, architecture, subagent definitions as teammates, permissions, context and communication, token usage, use cases, best practices, troubleshooting, and known limitations.
user-invocable: false
---

# Agent Teams Documentation

This skill provides the complete official documentation for Claude Code agent teams.

## Quick Reference

Agent teams coordinate multiple Claude Code instances working together as a team. One session is the **lead** that spawns and coordinates **teammates**, each running in its own independent context window. Teammates communicate directly with each other through a shared **task list** and **mailbox**. Unlike subagents, you can message individual teammates directly without going through the lead.

**Status**: Experimental and disabled by default. Requires Claude Code v2.1.32 or later.

### Enable

Set environment variable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your shell or via `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Agent teams vs subagents

|                   | Subagents                                        | Agent teams                                         |
| :---------------- | :----------------------------------------------- | :-------------------------------------------------- |
| **Context**       | Own context window; results return to the caller | Own context window; fully independent               |
| **Communication** | Report results back to the main agent only       | Teammates message each other directly               |
| **Coordination**  | Main agent manages all work                      | Shared task list with self-coordination             |
| **Best for**      | Focused tasks where only the result matters      | Complex work requiring discussion and collaboration |
| **Token cost**    | Lower: results summarized back to main context   | Higher: each teammate is a separate Claude instance |

### Strongest use cases

- **Research and review** — multiple teammates investigate different aspects simultaneously and challenge each other
- **New modules/features** — each teammate owns a separate piece without stepping on others
- **Debugging with competing hypotheses** — teammates test different theories in parallel
- **Cross-layer coordination** — frontend, backend, and tests each owned by a different teammate

Agent teams add coordination overhead and use significantly more tokens than a single session. For sequential tasks, same-file edits, or tightly coupled work, use a single session or subagents.

### Architecture components

| Component     | Role                                                                                |
| :------------ | :---------------------------------------------------------------------------------- |
| **Team lead** | Main Claude Code session that creates the team, spawns teammates, and coordinates   |
| **Teammates** | Separate Claude Code instances working on assigned tasks                            |
| **Task list** | Shared work items that teammates claim and complete                                 |
| **Mailbox**   | Messaging system for inter-agent communication                                      |

### Storage locations

- **Team config**: `~/.claude/teams/{team-name}/config.json` (auto-generated; do not hand-edit)
- **Task list**: `~/.claude/tasks/{team-name}/`

There is no project-level team config. `members` array in the config lists each teammate's name, agent ID, and type.

### Display modes

| Mode           | Description                                                                                          | Requirements              |
| :------------- | :--------------------------------------------------------------------------------------------------- | :------------------------ |
| **in-process** | All teammates run inside your main terminal. Shift+Down cycles through teammates; type to message.   | Any terminal              |
| **split panes**| Each teammate gets its own pane; click into a pane to interact directly.                             | tmux or iTerm2 with `it2` |
| **auto** (default) | Uses split panes inside a tmux session, otherwise in-process.                                     | -                         |

Override with `teammateMode` in `~/.claude.json` global config, or per-session via flag:

```bash
claude --teammate-mode in-process
```

Accepted values: `"in-process"`, `"tmux"`, `"auto"`. Split-pane mode is not supported in VS Code integrated terminal, Windows Terminal, or Ghostty.

### Task states & coordination

- **States**: pending, in progress, completed
- **Dependencies**: a pending task with unresolved dependencies cannot be claimed until they resolve
- **Assignment**: lead assigns explicitly, or teammates self-claim the next unblocked task
- **Race protection**: task claims use file locking to prevent duplicate claims

### Teammate controls

| Action                | How                                                                                               |
| :-------------------- | :------------------------------------------------------------------------------------------------ |
| Cycle teammates       | Shift+Down (in-process)                                                                           |
| View teammate session | Press Enter on a teammate                                                                         |
| Interrupt turn        | Escape after entering a teammate                                                                  |
| Toggle task list      | Ctrl+T                                                                                            |
| Message one teammate  | `message` tool (in-process: type directly; split-pane: click into the pane)                       |
| Message all teammates | `broadcast` (use sparingly; scales with team size)                                                |
| Shut down teammate    | Ask the lead: "Ask the researcher teammate to shut down" (teammate can accept or reject)          |
| Clean up team         | Ask the lead: "Clean up the team" (fails if teammates are still running; always run from lead)    |

### Plan approval

For risky tasks, require teammates to plan before implementing:

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

The teammate stays in read-only plan mode until the lead approves the plan. Rejected plans are revised and resubmitted. Influence lead judgment with criteria like "only approve plans that include test coverage."

### Quality-gate hooks

Enforce rules via hooks:

- **`TeammateIdle`** — runs when a teammate is about to go idle. Exit 2 to send feedback and keep the teammate working.
- **`TaskCreated`** — runs when a task is being created. Exit 2 to block creation and send feedback.
- **`TaskCompleted`** — runs when a task is being marked complete. Exit 2 to block completion and send feedback.

### Subagent definitions as teammates

Spawn a teammate using an existing [subagent](sub-agents-doc) definition from any scope (project, user, plugin, CLI):

```
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

Behavior when a subagent definition runs as a teammate:

- Honors the definition's `tools` allowlist and `model`
- Definition body is **appended** to system prompt (not replaced)
- Team coordination tools (`SendMessage`, task management) are always available even if `tools` restricts other tools
- `skills` and `mcpServers` frontmatter fields are **not** applied — teammates load skills and MCP servers from project/user settings instead

### Context and communication

- Each teammate has its own context window
- On spawn, teammates load project context (CLAUDE.md, MCP servers, skills) plus the spawn prompt
- Lead conversation history does **not** carry over
- Messages delivered automatically — lead does not poll
- Idle notifications sent to lead automatically when a teammate finishes
- All agents see the shared task list

### Permissions

- Teammates inherit the lead's permission settings at spawn
- If lead runs with `--dangerously-skip-permissions`, teammates do too
- Individual teammate modes can be changed after spawning, not at spawn time
- Pre-approve common operations to reduce interruption from bubbled-up prompts

### Best practices

- **Give teammates enough context** — include task-specific details in the spawn prompt since conversation history is not inherited
- **Team size**: start with 3-5 teammates; aim for 5-6 tasks per teammate
- **Task size**: self-contained units producing a clear deliverable (function, test file, review)
- **Wait for teammates**: tell the lead "wait for your teammates to complete their tasks before proceeding" if it starts doing work itself
- **Start with research and review** — tasks with clear boundaries and no code writing
- **Avoid file conflicts** — break work so each teammate owns a distinct file set
- **Monitor and steer** — check in, redirect, synthesize findings as they arrive

### Example prompts

**Research / multi-angle exploration**:
```
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles: one
teammate on UX, one on technical architecture, one playing devil's advocate.
```

**Parallel PR review**:
```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

**Competing hypotheses (scientific debate)**:
```
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

**Specify count and model**:
```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Troubleshooting

| Problem                           | Fix                                                                                                 |
| :-------------------------------- | :-------------------------------------------------------------------------------------------------- |
| Teammates not appearing           | Press Shift+Down to cycle; confirm task was complex enough; verify `tmux` / `it2` installed         |
| Too many permission prompts       | Pre-approve common operations in permission settings before spawning                                |
| Teammates stopping on errors      | Check output (Shift+Down / click pane); give instructions or spawn a replacement                    |
| Lead shuts down early             | Tell it to keep going, or "wait for your teammates to finish before proceeding"                     |
| Orphaned tmux sessions            | `tmux ls` then `tmux kill-session -t <session-name>`                                                |

### Known limitations (experimental)

- **No session resumption with in-process teammates**: `/resume` and `/rewind` don't restore in-process teammates; spawn new ones after resuming
- **Task status can lag**: teammates may fail to mark tasks complete, blocking dependents; update manually or nudge the teammate
- **Slow shutdown**: teammates finish their current request or tool call before exiting
- **One team per session**: a lead manages one team at a time; clean up before starting a new one
- **No nested teams**: teammates cannot spawn their own teams
- **Lead is fixed**: the session that creates the team is lead for its lifetime — no promotion or transfer
- **Permissions set at spawn**: cannot set per-teammate modes at spawn time
- **Split panes require tmux or iTerm2**: unsupported in VS Code integrated terminal, Windows Terminal, Ghostty

## Full Documentation

For the complete official documentation, see the reference files:

- [Orchestrate teams of Claude Code sessions](references/claude-code-agent-teams.md) — full official guide covering enablement, starting a team, display modes, task coordination, plan approval, hooks, architecture, subagent-as-teammate, permissions, context, token usage, use case examples, best practices, troubleshooting, and limitations

## Sources

- Orchestrate teams of Claude Code sessions: https://code.claude.com/docs/en/agent-teams.md
