---
name: hooks
description: Reference documentation for Claude Code hooks — event-driven shell commands, LLM prompts, or agents that run at specific points in Claude Code's lifecycle. Use when creating hooks, configuring hook events, writing hook scripts, understanding hook input/output JSON, exit codes, matchers, async hooks, prompt hooks, agent hooks, or debugging hooks.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, LLM prompts, or agents that execute automatically at specific points in Claude Code's lifecycle.

### Hook Configuration

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/lint.sh",
            "timeout": 600,
            "async": false,
            "statusMessage": "Running linter..."
          }
        ]
      }
    ]
  }
}
```

### Hook Locations

| Location                            | Scope                  | Shareable              |
|:------------------------------------|:-----------------------|:-----------------------|
| `~/.claude/settings.json`           | All your projects      | No                     |
| `.claude/settings.json`             | Single project         | Yes (commit to repo)   |
| `.claude/settings.local.json`       | Single project         | No (gitignored)        |
| Managed policy settings             | Organization-wide      | Yes (admin-controlled) |
| Plugin `hooks/hooks.json`           | When plugin is enabled | Yes (bundled)          |
| Skill/agent frontmatter             | While component active | Yes (in component)     |

### Hook Events

| Event              | Matcher              | Can Block? | When it fires                              |
|:-------------------|:---------------------|:-----------|:-------------------------------------------|
| `SessionStart`     | startup/resume/clear/compact | No  | Session begins or resumes                  |
| `UserPromptSubmit` | (none)               | Yes        | User submits a prompt                      |
| `PreToolUse`       | tool name            | Yes        | Before a tool call executes                |
| `PermissionRequest`| tool name            | Yes        | Permission dialog appears                  |
| `PostToolUse`      | tool name            | No         | After a tool call succeeds                 |
| `PostToolUseFailure`| tool name           | No         | After a tool call fails                    |
| `Notification`     | notification type    | No         | Claude Code sends a notification           |
| `SubagentStart`    | agent type           | No         | A subagent is spawned                      |
| `SubagentStop`     | agent type           | Yes        | A subagent finishes                        |
| `Stop`             | (none)               | Yes        | Claude finishes responding                 |
| `TeammateIdle`     | (none)               | Yes        | Agent team teammate about to go idle       |
| `TaskCompleted`    | (none)               | Yes        | Task being marked as completed             |
| `PreCompact`       | manual/auto          | No         | Before context compaction                  |
| `SessionEnd`       | reason               | No         | Session terminates                         |

### Hook Types

| Type      | Description                                          | Default timeout |
|:----------|:-----------------------------------------------------|:----------------|
| `command` | Shell command, receives JSON on stdin                 | 600s            |
| `prompt`  | Single LLM call, returns `{"ok": bool, "reason": ""}` | 30s           |
| `agent`   | Multi-turn subagent with tools, same response format | 60s             |

### Exit Codes

| Code  | Meaning                                              |
|:------|:-----------------------------------------------------|
| 0     | Success — parse stdout for JSON output               |
| 2     | Blocking error — stderr fed to Claude, action blocked |
| Other | Non-blocking error — stderr shown in verbose mode    |

### Common Input Fields (stdin JSON)

| Field             | Description                    |
|:------------------|:-------------------------------|
| `session_id`      | Current session identifier     |
| `transcript_path` | Path to conversation JSON      |
| `cwd`             | Current working directory      |
| `permission_mode` | Current permission mode        |
| `hook_event_name` | Name of the event that fired   |

### PreToolUse Decision Control

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "reason shown to user/Claude",
    "updatedInput": { "command": "safer-command" },
    "additionalContext": "extra info for Claude"
  }
}
```

### Universal JSON Output Fields

| Field            | Default | Description                                               |
|:-----------------|:--------|:----------------------------------------------------------|
| `continue`       | `true`  | `false` stops Claude entirely                             |
| `stopReason`     | none    | Message shown to user when `continue` is `false`          |
| `suppressOutput` | `false` | `true` hides stdout from verbose mode                     |
| `systemMessage`  | none    | Warning message shown to the user                         |

### Key Environment Variables

| Variable               | Description                                        |
|:-----------------------|:---------------------------------------------------|
| `$CLAUDE_PROJECT_DIR`  | Project root (use in command paths)                |
| `${CLAUDE_PLUGIN_ROOT}`| Plugin root (for plugin hooks)                     |
| `$CLAUDE_ENV_FILE`     | SessionStart only — persist env vars for session   |
| `$CLAUDE_CODE_REMOTE`  | `"true"` in remote web environments                |

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Guide](references/claude-code-hooks-guide.md) — quickstart, practical examples, and common automation patterns
- [Hooks Reference](references/claude-code-hooks-reference.md) — complete technical reference for all events, input/output schemas, exit codes, JSON output, prompt hooks, agent hooks, and async hooks

## Sources

- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
- Hooks Reference: https://code.claude.com/docs/en/hooks.md
