---
name: hooks-doc
description: Reference documentation for Claude Code hooks -- lifecycle hook events, configuration schema, matchers, JSON input/output formats, exit codes, decision control, command hooks, HTTP hooks, prompt-based hooks, agent-based hooks, async hooks, environment variables, MCP tool matching, and security best practices.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute at specific points in Claude Code's lifecycle. They provide deterministic control over behavior -- format code after edits, block dangerous commands, send notifications, inject context, and more.

### Hook Events

| Event              | When it fires                                          | Can block? | Matcher filters      |
|:-------------------|:-------------------------------------------------------|:-----------|:---------------------|
| `SessionStart`     | Session begins or resumes                              | No         | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | User submits a prompt                                  | Yes        | (none)               |
| `PreToolUse`       | Before a tool call executes                            | Yes        | tool name            |
| `PermissionRequest`| Permission dialog appears                              | Yes        | tool name            |
| `PostToolUse`      | After a tool call succeeds                             | No         | tool name            |
| `PostToolUseFailure`| After a tool call fails                               | No         | tool name            |
| `Notification`     | Claude sends a notification                            | No         | notification type    |
| `SubagentStart`    | Subagent spawned                                       | No         | agent type           |
| `SubagentStop`     | Subagent finishes                                      | Yes        | agent type           |
| `Stop`             | Claude finishes responding                             | Yes        | (none)               |
| `TeammateIdle`     | Agent team teammate about to go idle                   | Yes        | (none)               |
| `TaskCompleted`    | Task being marked as completed                         | Yes        | (none)               |
| `ConfigChange`     | Configuration file changes                             | Yes        | config source        |
| `WorktreeCreate`   | Worktree being created                                 | Yes        | (none)               |
| `WorktreeRemove`   | Worktree being removed                                 | No         | (none)               |
| `PreCompact`       | Before context compaction                              | No         | `manual`, `auto`     |
| `SessionEnd`       | Session terminates                                     | No         | exit reason          |

### Hook Handler Types

| Type      | Description                                        | Default timeout |
|:----------|:---------------------------------------------------|:----------------|
| `command` | Shell command; receives JSON on stdin               | 600s            |
| `http`    | HTTP POST to a URL; JSON in request body            | 30s             |
| `prompt`  | Single-turn LLM evaluation; returns `ok`/`reason`   | 30s             |
| `agent`   | Multi-turn subagent with tool access; returns `ok`/`reason` | 60s   |

### Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "regex-pattern",
        "hooks": [
          { "type": "command", "command": "your-script.sh" }
        ]
      }
    ]
  }
}
```

### Hook Locations

| Location                          | Scope                  | Shareable?  |
|:----------------------------------|:-----------------------|:------------|
| `~/.claude/settings.json`        | All your projects      | No          |
| `.claude/settings.json`          | Single project         | Yes (VCS)   |
| `.claude/settings.local.json`    | Single project         | No          |
| Managed policy settings           | Organization-wide      | Yes (admin) |
| Plugin `hooks/hooks.json`        | When plugin is enabled | Yes         |
| Skill/agent frontmatter           | While component active | Yes         |

### Exit Code Behavior

| Exit code | Effect                                                              |
|:----------|:--------------------------------------------------------------------|
| 0         | Success; stdout parsed for JSON output                              |
| 2         | Blocking error; stderr fed back to Claude (blocks action if event supports it) |
| Other     | Non-blocking error; stderr logged in verbose mode                   |

### Decision Control by Event

| Events                                                          | Pattern              | Key fields                                            |
|:----------------------------------------------------------------|:---------------------|:------------------------------------------------------|
| `UserPromptSubmit`, `PostToolUse`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason`               |
| `TeammateIdle`, `TaskCompleted`                                 | Exit code only       | Exit 2 blocks; stderr as feedback                     |
| `PreToolUse`                                                    | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| `PermissionRequest`                                             | `hookSpecificOutput` | `decision.behavior` (allow/deny)                      |
| `WorktreeCreate`                                                | stdout path          | Hook prints absolute path to created worktree         |

### Common Input Fields (JSON on stdin)

| Field             | Description                          |
|:------------------|:-------------------------------------|
| `session_id`      | Current session identifier           |
| `transcript_path` | Path to conversation JSON            |
| `cwd`             | Working directory                    |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the event that fired         |

### Universal JSON Output Fields

| Field            | Default | Description                                               |
|:-----------------|:--------|:----------------------------------------------------------|
| `continue`       | `true`  | `false` stops Claude entirely                             |
| `stopReason`     | --      | Message shown to user when `continue` is `false`          |
| `suppressOutput` | `false` | `true` hides stdout from verbose mode                     |
| `systemMessage`  | --      | Warning message shown to the user                         |

### Environment Variables

| Variable               | Available in     | Description                              |
|:-----------------------|:-----------------|:-----------------------------------------|
| `$CLAUDE_PROJECT_DIR`  | All hooks        | Project root directory                   |
| `${CLAUDE_PLUGIN_ROOT}`| Plugin hooks     | Plugin root directory                    |
| `$CLAUDE_ENV_FILE`     | SessionStart     | File path for persisting env vars        |
| `$CLAUDE_CODE_REMOTE`  | All hooks        | `"true"` in remote web environments      |

### Async Hooks

Add `"async": true` to a command hook to run it in the background. Claude continues immediately; output is delivered on the next conversation turn via `systemMessage` or `additionalContext`. Async hooks cannot block actions.

### Prompt/Agent Hook Response Schema

```json
{ "ok": true }
{ "ok": false, "reason": "Explanation shown to Claude" }
```

### Quick Examples

**Auto-format after edits** (PostToolUse):
```json
{ "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }] }
```

**Block protected files** (PreToolUse): exit 2 with stderr message from a script that checks `tool_input.file_path`.

**Desktop notifications** (Notification): `osascript -e 'display notification ...'` (macOS) or `notify-send` (Linux).

**Re-inject context after compaction** (SessionStart, matcher: `compact`): echo critical reminders to stdout.

**Verify tasks complete before stopping** (Stop): use `type: "prompt"` or `type: "agent"` hook.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- quickstart walkthrough, common use cases, prompt-based and agent-based hooks, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas, JSON input/output formats, exit codes, decision control, async hooks, HTTP hooks, MCP tool matching, security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
