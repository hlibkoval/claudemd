---
name: hooks
description: Reference documentation for Claude Code hooks — user-defined shell commands, prompts, and agents that run automatically at lifecycle events (PreToolUse, PostToolUse, Stop, SessionStart, etc.). Use when configuring hooks, writing hook scripts, blocking tool calls, injecting context, setting up async hooks, or understanding hook input/output formats.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are shell commands, LLM prompts, or subagents that run automatically at specific points in Claude Code's lifecycle.

### Hook Events

| Event                | When it fires                                         | Can block? |
|:---------------------|:------------------------------------------------------|:-----------|
| `SessionStart`       | Session begins or resumes                             | No         |
| `UserPromptSubmit`   | Prompt submitted, before Claude processes it          | Yes        |
| `PreToolUse`         | Before a tool call executes                           | Yes        |
| `PermissionRequest`  | When a permission dialog appears                      | Yes        |
| `PostToolUse`        | After a tool call succeeds                            | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails                               | No         |
| `Notification`       | When Claude Code sends a notification                 | No         |
| `SubagentStart`      | When a subagent is spawned                            | No         |
| `SubagentStop`       | When a subagent finishes                              | Yes        |
| `Stop`               | When Claude finishes responding                       | Yes        |
| `TeammateIdle`       | When an agent team teammate is about to go idle       | Yes        |
| `TaskCompleted`      | When a task is being marked as completed              | Yes        |
| `PreCompact`         | Before context compaction                             | No         |
| `SessionEnd`         | When a session terminates                             | No         |

### Configuration Structure

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "/path/to/script.sh" }
        ]
      }
    ]
  }
}
```

Three nesting levels: **hook event** → **matcher group** → **hook handler**.

### Hook Locations

| Location                             | Scope                        | Shareable |
|:-------------------------------------|:-----------------------------|:----------|
| `~/.claude/settings.json`            | All your projects            | No        |
| `.claude/settings.json`              | Single project               | Yes       |
| `.claude/settings.local.json`        | Single project               | No        |
| Managed policy settings              | Organization-wide            | Yes       |
| Plugin `hooks/hooks.json`            | When plugin is enabled       | Yes       |
| Skill / agent frontmatter            | While component is active    | Yes       |

### Matcher Patterns

| Event                                                  | Matches on                | Example values                                              |
|:-------------------------------------------------------|:--------------------------|:------------------------------------------------------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` | tool name | `Bash`, `Edit\|Write`, `mcp__.*`          |
| `SessionStart`                                         | session source            | `startup`, `resume`, `clear`, `compact`                     |
| `SessionEnd`                                           | exit reason               | `clear`, `logout`, `prompt_input_exit`, `other`             |
| `Notification`                                         | notification type         | `permission_prompt`, `idle_prompt`, `auth_success`          |
| `SubagentStart` / `SubagentStop`                       | agent type                | `Bash`, `Explore`, `Plan`, or custom agent names            |
| `PreCompact`                                           | compaction trigger        | `manual`, `auto`                                            |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted` | no matcher        | always fires                                                |

MCP tools match as `mcp__<server>__<tool>` (e.g. `mcp__memory__.*`).

### Hook Handler Fields

| Field           | Types        | Description                                                              |
|:----------------|:-------------|:-------------------------------------------------------------------------|
| `type`          | all          | `"command"`, `"prompt"`, or `"agent"`                                    |
| `command`       | command      | Shell command to execute                                                  |
| `prompt`        | prompt/agent | Prompt text; use `$ARGUMENTS` for hook input JSON                        |
| `model`         | prompt/agent | Model override (defaults to a fast model)                                |
| `async`         | command      | `true` = run in background without blocking                              |
| `timeout`       | all          | Seconds before canceling (default: 600 command, 30 prompt, 60 agent)    |
| `statusMessage` | all          | Custom spinner message while hook runs                                   |
| `once`          | command      | `true` = run once per session then remove (skills only)                  |

### Exit Codes

| Exit code | Meaning                                                                    |
|:----------|:---------------------------------------------------------------------------|
| `0`       | Success — action proceeds; stdout JSON is parsed; `UserPromptSubmit`/`SessionStart` stdout added as Claude context |
| `2`       | Blocking error — stderr fed to Claude as feedback; blocks the action       |
| Other     | Non-blocking error — stderr shown in verbose mode only; action proceeds    |

### JSON Output Fields (exit 0)

| Field            | Description                                                                  |
|:-----------------|:-----------------------------------------------------------------------------|
| `continue`       | `false` = Claude stops entirely                                              |
| `stopReason`     | Message shown to user when `continue: false`                                 |
| `suppressOutput` | `true` = hide stdout from verbose mode                                       |
| `systemMessage`  | Warning shown to the user                                                    |

### Decision Control by Event

| Events                                                            | Pattern              | Key fields                                                        |
|:------------------------------------------------------------------|:---------------------|:------------------------------------------------------------------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop` | Top-level `decision` | `decision: "block"`, `reason`               |
| `TeammateIdle`, `TaskCompleted`                                   | Exit code only       | Exit 2 blocks; stderr is feedback                                 |
| `PreToolUse`                                                      | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| `PermissionRequest`                                               | `hookSpecificOutput` | `decision.behavior` (allow/deny)                                  |

### Common Input Fields (all events)

| Field             | Description                                         |
|:------------------|:----------------------------------------------------|
| `session_id`      | Current session identifier                          |
| `transcript_path` | Path to conversation JSON                           |
| `cwd`             | Working directory when the hook is invoked          |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired                        |

### Prompt / Agent Hook Response Schema

```json
{ "ok": true }
// or
{ "ok": false, "reason": "Explanation fed back to Claude" }
```

### Environment Variables in Hook Commands

| Variable              | Description                                         |
|:----------------------|:----------------------------------------------------|
| `$CLAUDE_PROJECT_DIR` | Project root directory                              |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin root directory (plugin hooks only)         |
| `$CLAUDE_ENV_FILE`    | File to persist env vars for Bash commands (`SessionStart` only) |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments          |

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) — event schemas, JSON input/output formats, decision control, async hooks, prompt/agent hooks, and security
- [Hooks Guide](references/claude-code-hooks-guide.md) — quickstart walkthrough, common automation patterns, troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
