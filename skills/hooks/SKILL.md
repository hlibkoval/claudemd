---
name: hooks
description: Reference documentation for Claude Code hooks — shell commands, LLM prompts, or agents that run automatically at lifecycle events. Covers hook events (PreToolUse, PostToolUse, Stop, SessionStart, etc.), matchers, JSON input/output, decision control, async hooks, prompt-based hooks, agent-based hooks, MCP tool hooks, and configuration.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks — user-defined automations that execute at specific points in Claude Code's lifecycle.

## Quick Reference

Hooks are shell commands, LLM prompts, or agents that run automatically when Claude Code edits files, executes tools, starts/stops sessions, or needs input. They provide deterministic control over behavior.

### Hook Events

| Event                | When it fires                              | Can block? |
|:---------------------|:-------------------------------------------|:-----------|
| `SessionStart`       | Session begins or resumes                  | No         |
| `UserPromptSubmit`   | User submits a prompt                      | Yes        |
| `PreToolUse`         | Before a tool call executes                | Yes        |
| `PermissionRequest`  | Permission dialog appears                  | Yes        |
| `PostToolUse`        | After a tool call succeeds                 | No         |
| `PostToolUseFailure` | After a tool call fails                    | No         |
| `Notification`       | Claude sends a notification                | No         |
| `SubagentStart`      | Subagent is spawned                        | No         |
| `SubagentStop`       | Subagent finishes                          | Yes        |
| `Stop`               | Claude finishes responding                 | Yes        |
| `TeammateIdle`       | Agent team teammate about to go idle       | Yes        |
| `TaskCompleted`      | Task marked as completed                   | Yes        |
| `ConfigChange`       | Configuration file changes during session  | Yes        |
| `PreCompact`         | Before context compaction                  | No         |
| `SessionEnd`         | Session terminates                         | No         |

### Hook Types

| Type      | Description                                         | Default timeout |
|:----------|:----------------------------------------------------|:----------------|
| `command` | Run a shell command (stdin JSON, exit codes)         | 600s            |
| `prompt`  | Single-turn LLM evaluation (returns `ok`/`reason`)  | 30s             |
| `agent`   | Multi-turn subagent with tool access                 | 60s             |

### Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex>",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh",
            "timeout": 30,
            "async": false
          }
        ]
      }
    ]
  }
}
```

### Hook Locations

| Location                              | Scope                    | Shareable |
|:--------------------------------------|:-------------------------|:----------|
| `~/.claude/settings.json`             | All your projects        | No        |
| `.claude/settings.json`               | Single project           | Yes       |
| `.claude/settings.local.json`         | Single project           | No        |
| Managed policy settings               | Organization-wide        | Yes       |
| Plugin `hooks/hooks.json`             | When plugin is enabled   | Yes       |
| Skill/agent frontmatter               | While component is active| Yes       |

### Matcher Patterns

| Event                                                       | Matches on             | Example values                                                   |
|:------------------------------------------------------------|:-----------------------|:-----------------------------------------------------------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` | tool name    | `Bash`, `Edit\|Write`, `mcp__.*`                                 |
| `SessionStart`                                              | session source         | `startup`, `resume`, `clear`, `compact`                          |
| `SessionEnd`                                                | exit reason            | `clear`, `logout`, `prompt_input_exit`, `other`                  |
| `Notification`                                              | notification type      | `permission_prompt`, `idle_prompt`, `auth_success`               |
| `SubagentStart`, `SubagentStop`                             | agent type             | `Bash`, `Explore`, `Plan`, custom names                          |
| `PreCompact`                                                | trigger                | `manual`, `auto`                                                 |
| `ConfigChange`                                              | config source          | `user_settings`, `project_settings`, `local_settings`, `skills`  |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted` | no matcher support     | always fires                                                     |

### Exit Codes

| Code    | Meaning                                                       |
|:--------|:--------------------------------------------------------------|
| `0`     | Success — action proceeds; stdout parsed for JSON output      |
| `2`     | Blocking error — action blocked; stderr fed back to Claude    |
| Other   | Non-blocking error — stderr shown in verbose mode, continues  |

### Decision Control Patterns

| Events                                                                       | Pattern              | Key fields                                                     |
|:-----------------------------------------------------------------------------|:---------------------|:---------------------------------------------------------------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason`                  |
| `PreToolUse`                                                                 | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| `PermissionRequest`                                                          | `hookSpecificOutput` | `decision.behavior` (allow/deny)                               |
| `TeammateIdle`, `TaskCompleted`                                              | Exit code only       | Exit 2 blocks; stderr is feedback                              |

### Common Input Fields (stdin JSON)

| Field             | Description                          |
|:------------------|:-------------------------------------|
| `session_id`      | Current session identifier           |
| `transcript_path` | Path to conversation JSON            |
| `cwd`             | Current working directory            |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the event that fired         |

### Universal JSON Output Fields

| Field            | Default | Description                                                  |
|:-----------------|:--------|:-------------------------------------------------------------|
| `continue`       | `true`  | `false` stops Claude entirely (overrides event decisions)    |
| `stopReason`     | none    | Message shown to user when `continue` is `false`             |
| `suppressOutput` | `false` | `true` hides stdout from verbose mode                        |
| `systemMessage`  | none    | Warning message shown to user                                |

### Environment Variables

| Variable               | Available in    | Description                                    |
|:-----------------------|:----------------|:-----------------------------------------------|
| `$CLAUDE_PROJECT_DIR`  | All hooks       | Project root directory                         |
| `${CLAUDE_PLUGIN_ROOT}`| Plugin hooks    | Plugin root directory                          |
| `$CLAUDE_ENV_FILE`     | SessionStart    | File path for persisting env vars for session  |
| `$CLAUDE_CODE_REMOTE`  | All hooks       | `"true"` in remote web environments            |

### Prompt/Agent Hook Response

```json
{ "ok": true }
{ "ok": false, "reason": "Explanation for blocking" }
```

### Async Hooks

Add `"async": true` to command hooks to run in background. Async hooks cannot block actions; results delivered on next conversation turn via `systemMessage` or `additionalContext`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, configuration, decision control, async hooks, prompt-based hooks, agent-based hooks, and MCP tool hooks
- [Hooks Guide](references/claude-code-hooks-guide.md) — quickstart walkthrough, common automation patterns (notifications, auto-formatting, file protection, context re-injection), troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
