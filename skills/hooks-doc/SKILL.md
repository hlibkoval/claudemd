---
name: hooks-doc
user-invocable: false
description: >
  Complete official documentation for Claude Code hooks: lifecycle events,
  configuration schema, JSON input/output formats, exit codes, matcher patterns,
  command/HTTP/MCP/prompt/agent hook types, decision control per event, async
  hooks, and troubleshooting. Use when asked about hooks, PreToolUse, PostToolUse,
  SessionStart, Stop hooks, blocking tool calls, auto-formatting, notifications,
  permission automation, or any lifecycle event configuration.
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Configuration Structure

Hooks are defined in JSON settings files as a three-level hierarchy:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<pattern>",
        "hooks": [
          { "type": "command", "command": "<shell command>" }
        ]
      }
    ]
  }
}
```

### Hook Locations

| File                                                     | Scope                         | Shareable                         |
|:---------------------------------------------------------|:------------------------------|:----------------------------------|
| `~/.claude/settings.json`                                | All your projects             | No, local to your machine         |
| `.claude/settings.json`                                  | Single project                | Yes, committable to repo          |
| `.claude/settings.local.json`                            | Single project                | No, gitignored                    |
| Managed policy settings                                  | Organization-wide             | Yes, admin-controlled             |
| Plugin `hooks/hooks.json`                                | When plugin is enabled        | Yes, bundled with plugin          |
| Skill or agent frontmatter                               | While component is active     | Yes, defined in component file    |

### Hook Events

| Event                 | When it fires                                                              | Can block? |
|:----------------------|:---------------------------------------------------------------------------|:-----------|
| `SessionStart`        | Session begins or resumes                                                  | No         |
| `Setup`               | `--init-only` or `-p --init/--maintenance`                                 | No         |
| `UserPromptSubmit`    | User submits a prompt, before Claude processes it                          | Yes        |
| `UserPromptExpansion` | Slash command expands into a prompt                                        | Yes        |
| `PreToolUse`          | Before a tool call executes                                                | Yes        |
| `PermissionRequest`   | Permission dialog is about to appear                                       | Yes        |
| `PermissionDenied`    | Tool call denied by auto mode classifier                                   | No         |
| `PostToolUse`         | After a tool call succeeds                                                 | No         |
| `PostToolUseFailure`  | After a tool call fails                                                    | No         |
| `PostToolBatch`       | After a full batch of parallel tool calls resolves                         | Yes        |
| `Notification`        | Claude Code sends a notification                                           | No         |
| `MessageDisplay`      | While assistant message text streams to screen                             | No         |
| `SubagentStart`       | Subagent is spawned                                                        | No         |
| `SubagentStop`        | Subagent finishes                                                          | Yes        |
| `TaskCreated`         | Task being created via TaskCreate                                          | Yes        |
| `TaskCompleted`       | Task being marked completed                                                | Yes        |
| `Stop`                | Claude finishes responding                                                 | Yes        |
| `StopFailure`         | Turn ends due to API error                                                 | No         |
| `TeammateIdle`        | Agent team teammate about to go idle                                       | Yes        |
| `InstructionsLoaded`  | CLAUDE.md or rules file loaded into context                                | No         |
| `ConfigChange`        | Configuration file changes during session                                  | Yes        |
| `CwdChanged`          | Working directory changes                                                  | No         |
| `FileChanged`         | Watched file changes on disk (matcher = filenames to watch)                | No         |
| `WorktreeCreate`      | Worktree being created                                                     | Yes        |
| `WorktreeRemove`      | Worktree being removed                                                     | No         |
| `PreCompact`          | Before context compaction                                                  | Yes        |
| `PostCompact`         | After context compaction                                                   | No         |
| `Elicitation`         | MCP server requests user input                                             | Yes        |
| `ElicitationResult`   | User responds to MCP elicitation                                           | Yes        |
| `SessionEnd`          | Session terminates                                                         | No         |

### Hook Types

| Type        | Field(s)                      | Description                                                             |
|:------------|:------------------------------|:------------------------------------------------------------------------|
| `command`   | `command`, optional `args`    | Run a shell command. stdin = JSON, stdout/stderr = output               |
| `http`      | `url`, `headers`, `allowedEnvVars` | POST event JSON to an HTTP endpoint                                |
| `mcp_tool`  | `server`, `tool`, `input`     | Call a tool on a connected MCP server                                   |
| `prompt`    | `prompt`, optional `model`    | Single-turn LLM evaluation, returns `{"ok": true/false, "reason": "…"}` |
| `agent`     | `prompt`, optional `model`    | Subagent with tool access, experimental                                 |

### Common Hook Handler Fields

| Field           | Description                                                                                                    |
|:----------------|:---------------------------------------------------------------------------------------------------------------|
| `type`          | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"`                                                  |
| `if`            | Permission rule syntax to filter by tool + args, e.g. `"Bash(git *)"`. Only for tool events                   |
| `timeout`       | Seconds before canceling. Defaults: 600 (command/http/mcp_tool), 30 (prompt), 60 (agent)                      |
| `statusMessage` | Custom spinner message while hook runs                                                                          |
| `once`          | If `true`, runs once per session then removed. Only honored in skill frontmatter                               |

### Command Hook Extra Fields

| Field         | Description                                                                                          |
|:--------------|:-----------------------------------------------------------------------------------------------------|
| `command`     | Shell command string (shell form) or executable path (exec form when `args` is set)                  |
| `args`        | When present, spawns `command` directly with no shell — each element is one arg verbatim             |
| `async`       | Run in background without blocking                                                                   |
| `asyncRewake` | Run in background, wake Claude on exit code 2 with stderr as system reminder                        |
| `shell`       | `"bash"` (default) or `"powershell"`                                                                 |

### Matcher Patterns

| Matcher value                        | Evaluated as                            |
|:-------------------------------------|:----------------------------------------|
| `"*"`, `""`, or omitted              | Match all                               |
| Only letters, digits, `_`, and `\|`  | Exact string or pipe-separated list     |
| Contains any other character         | JavaScript regular expression           |

Each event type matches on a different field:

| Event(s)                                                                                                    | What matcher filters          | Example values                                                      |
|:------------------------------------------------------------------------------------------------------------|:------------------------------|:--------------------------------------------------------------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`                  | tool name                     | `Bash`, `Edit\|Write`, `mcp__.*`                                    |
| `SessionStart`                                                                                              | session source                | `startup`, `resume`, `clear`, `compact`                             |
| `Setup`                                                                                                     | CLI flag                      | `init`, `maintenance`                                               |
| `SessionEnd`                                                                                                | end reason                    | `clear`, `resume`, `logout`, `prompt_input_exit`, `other`           |
| `Notification`                                                                                              | notification type             | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_*` |
| `SubagentStart`, `SubagentStop`                                                                             | agent type                    | `general-purpose`, `Explore`, `Plan`, or custom agent names         |
| `PreCompact`, `PostCompact`                                                                                 | compaction trigger            | `manual`, `auto`                                                    |
| `ConfigChange`                                                                                              | config source                 | `user_settings`, `project_settings`, `local_settings`, `skills`     |
| `StopFailure`                                                                                               | error type                    | `rate_limit`, `overloaded`, `authentication_failed`, etc.           |
| `InstructionsLoaded`                                                                                        | load reason                   | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult`                                                                         | MCP server name               | your configured MCP server names                                    |
| `FileChanged`                                                                                               | literal filenames (watch list)| `.envrc\|.env`                                                      |
| `UserPromptExpansion`                                                                                       | command name                  | your skill or command names                                         |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | no matcher | always fires |

### MCP Tool Naming

MCP tools follow the pattern `mcp__<server>__<tool>`. Use `.*` suffix for regex matching:
- `mcp__memory__.*` — all tools from the `memory` server
- `mcp__.*__write.*` — any write tool from any server

### Exit Codes

| Exit code        | Meaning                                                                              |
|:-----------------|:-------------------------------------------------------------------------------------|
| `0`              | No objection. JSON output processed if present. Normal flow continues                |
| `2`              | Blocking error. Stderr fed to Claude (for blockable events) or shown to user         |
| Any other        | Non-blocking error. Transcript shows a hook error notice; execution continues        |

`WorktreeCreate` is special: any non-zero exit code fails worktree creation.

### JSON Output Fields (Universal)

Your hook can exit 0 and print a JSON object to stdout for structured control:

| Field              | Default | Description                                                              |
|:-------------------|:--------|:-------------------------------------------------------------------------|
| `continue`         | `true`  | If `false`, Claude stops processing entirely                             |
| `stopReason`       | none    | Message shown to user when `continue` is `false`                        |
| `suppressOutput`   | `false` | If `true`, hides hook stdout from transcript                            |
| `systemMessage`    | none    | Warning message shown to user                                           |
| `terminalSequence` | none    | Terminal escape sequence for Claude Code to emit (OSC 0/1/2/9/99/777, BEL). Available v2.1.141+ |

### Decision Control by Event

| Event(s)                                                                                                | Pattern                  | Key fields                                                              |
|:--------------------------------------------------------------------------------------------------------|:-------------------------|:------------------------------------------------------------------------|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse`                                                                                            | `hookSpecificOutput`     | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest`                                                                                     | `hookSpecificOutput`     | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied`                                                                                      | `hookSpecificOutput`     | `retry: true` to allow model to retry                                   |
| `WorktreeCreate`                                                                                        | path return              | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`/`ElicitationResult`                                                                       | `hookSpecificOutput`     | `action` (accept/decline/cancel), `content`                             |
| `MessageDisplay`                                                                                        | `hookSpecificOutput`     | `displayContent` replaces rendered text (transcript unchanged)          |
| `SessionStart`, `Setup`, `SubagentStart`                                                               | Context only             | `additionalContext`. SessionStart also: `initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only, no decision control |

### PreToolUse permissionDecision Values

| Value    | Effect                                                                           |
|:---------|:---------------------------------------------------------------------------------|
| `allow`  | Skips interactive permission prompt. Deny/ask rules still evaluated              |
| `deny`   | Cancels tool call; reason shown to Claude                                        |
| `ask`    | Shows permission prompt to user                                                  |
| `defer`  | Exits process with `stop_reason: "tool_deferred"` for SDK callers. `-p` mode only |

When multiple PreToolUse hooks return different decisions: `deny` > `defer` > `ask` > `allow`.

### Common Input Fields (All Events)

| Field             | Description                                                                 |
|:------------------|:----------------------------------------------------------------------------|
| `session_id`      | Current session identifier                                                  |
| `transcript_path` | Path to conversation JSON                                                   |
| `cwd`             | Current working directory                                                   |
| `permission_mode` | Active permission mode (not all events)                                     |
| `effort`          | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `hook_event_name` | Name of the event that fired                                                |

### Path Placeholders for Scripts

| Placeholder              | Resolves to                                            |
|:-------------------------|:-------------------------------------------------------|
| `${CLAUDE_PROJECT_DIR}`  | Project root directory                                 |
| `${CLAUDE_PLUGIN_ROOT}`  | Plugin installation directory                          |
| `${CLAUDE_PLUGIN_DATA}`  | Plugin persistent data directory                       |

Use exec form (`"args": []`) with path placeholders to avoid quoting issues with spaces.

### additionalContext

Return inside `hookSpecificOutput` alongside `hookEventName`. Claude reads it as a system reminder injected at the point the hook fired. Use factual statements ("The deployment target is production"), not imperative instructions, to avoid prompt-injection defenses.

### CLAUDE_ENV_FILE

Available to `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to this file to persist environment variables for all subsequent Bash commands in the session. Use append (`>>`) to preserve variables set by other hooks.

### Hooks in Skill/Agent Frontmatter

```yaml
---
name: my-skill
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
---
```

All hook events are supported. For subagents, `Stop` hooks auto-convert to `SubagentStop`.

### Timeouts

| Hook type                            | Default timeout          | Notes                                                        |
|:-------------------------------------|:-------------------------|:-------------------------------------------------------------|
| `command`, `http`, `mcp_tool`        | 600 seconds              | `UserPromptSubmit` lowers to 30s; `MessageDisplay` lowers to 10s |
| `prompt`                             | 30 seconds               |                                                              |
| `agent`                              | 60 seconds               |                                                              |

Override per hook with the `timeout` field (in seconds).

### Troubleshooting

- **Hook not firing**: run `/hooks` to verify it appears; check matcher is case-correct; verify event type
- **Hook error in transcript**: test with `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh`; use absolute paths or `${CLAUDE_PROJECT_DIR}`; check script is executable (`chmod +x`)
- **Stop hook loops**: check `stop_hook_active` field in input and exit 0 if `true`; raise cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`
- **JSON validation failed**: shell profile may echo text on startup; wrap echoes in `if [[ $- == *i* ]]; then … fi`
- **Debug**: use `Ctrl+O` for transcript view; start with `claude --debug-file /tmp/claude.log` for full logs

### Disable Hooks

Set `"disableAllHooks": true` in a settings file. Managed hooks are exempt unless `disableAllHooks` is also in managed settings.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate actions with hooks](references/claude-code-hooks-guide.md) — Getting started guide with common patterns: notifications, auto-format, file protection, context injection, config auditing, environment reloading, and auto-approve
- [Hooks reference](references/claude-code-hooks-reference.md) — Full event schemas, all JSON input/output formats, exec/shell form, async hooks, HTTP/MCP/prompt/agent hook fields, per-event decision control, and complete hook lifecycle

## Sources

- Automate actions with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
