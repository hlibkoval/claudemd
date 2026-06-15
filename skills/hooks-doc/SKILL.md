---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, configuration schema, JSON input/output formats, exit codes, matchers, async hooks, HTTP hooks, prompt hooks, MCP tool hooks, and agent hooks. Use when working with hooks in settings files, skills, plugins, or subagent frontmatter.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook lifecycle events

| Event                 | Cadence        | Can block? | When it fires                                                    |
| :-------------------- | :------------- | :--------- | :--------------------------------------------------------------- |
| `SessionStart`        | Per session    | No         | Session begins or resumes                                        |
| `Setup`               | Explicit only  | No         | `--init-only` or `--init`/`--maintenance` with `-p`             |
| `UserPromptSubmit`    | Per turn       | Yes        | User submits a prompt, before Claude processes it                |
| `UserPromptExpansion` | Per turn       | Yes        | A slash command expands into a prompt                            |
| `PreToolUse`          | Per tool call  | Yes        | Before a tool call executes                                      |
| `PermissionRequest`   | Per dialog     | Yes        | Permission dialog is about to appear                             |
| `PermissionDenied`    | Per denial     | No         | Auto-mode classifier denies a tool call                          |
| `PostToolUse`         | Per tool call  | No         | After a tool call succeeds                                       |
| `PostToolUseFailure`  | Per tool call  | No         | After a tool call fails                                          |
| `PostToolBatch`       | Per batch      | Yes        | After all parallel tool calls resolve, before next model call    |
| `MessageDisplay`      | Per batch      | No         | While assistant message text streams to screen                   |
| `Stop`                | Per turn       | Yes        | Claude finishes responding                                       |
| `StopFailure`         | Per turn       | No         | Turn ends due to API error                                       |
| `SubagentStart`       | Per subagent   | No         | Subagent spawned via Agent tool                                  |
| `SubagentStop`        | Per subagent   | Yes        | Subagent finishes                                                |
| `TaskCreated`         | Per task       | Yes        | Task being created via TaskCreate                                |
| `TaskCompleted`       | Per task       | Yes        | Task being marked as completed                                   |
| `TeammateIdle`        | Per teammate   | Yes        | Agent team teammate about to go idle                             |
| `InstructionsLoaded`  | Async          | No         | CLAUDE.md or rules file loaded into context                      |
| `ConfigChange`        | Async          | Yes        | Configuration file changes during a session                      |
| `CwdChanged`          | Async          | No         | Working directory changes                                        |
| `FileChanged`         | Async          | No         | Watched file changes on disk                                     |
| `WorktreeCreate`      | Per worktree   | Yes        | Worktree being created; hook output sets the path                |
| `WorktreeRemove`      | Per worktree   | No         | Worktree being removed                                           |
| `PreCompact`          | Per compaction | Yes        | Before context compaction                                        |
| `PostCompact`         | Per compaction | No         | After context compaction completes                               |
| `Elicitation`         | Per elicit     | Yes        | MCP server requests user input                                   |
| `ElicitationResult`   | Per elicit     | Yes        | User responds to MCP elicitation                                 |
| `Notification`        | Async          | No         | Claude Code sends a notification                                 |
| `SessionEnd`          | Per session    | No         | Session terminates                                               |

### Hook handler types

| Type        | Field       | Description                                                    | Default timeout |
| :---------- | :---------- | :------------------------------------------------------------- | :-------------- |
| `command`   | `command`   | Shell command; receives JSON on stdin                          | 600s (30s for UserPromptSubmit, 10s for MessageDisplay) |
| `http`      | `url`       | POST event JSON to an HTTP endpoint                            | 600s            |
| `mcp_tool`  | `server`, `tool` | Call a tool on a connected MCP server                    | 600s            |
| `prompt`    | `prompt`    | Single-turn LLM evaluation; returns `ok`/`reason` JSON        | 30s             |
| `agent`     | `prompt`    | Subagent with tool access; returns `ok`/`reason` JSON (experimental) | 60s      |

### Common handler fields (all types)

| Field           | Description                                                                              |
| :-------------- | :--------------------------------------------------------------------------------------- |
| `type`          | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"`                           |
| `if`            | Permission rule syntax to filter by tool name and arguments, e.g. `"Bash(git *)"`. Tool events only |
| `timeout`       | Seconds before canceling                                                                 |
| `statusMessage` | Custom spinner message while hook runs                                                   |
| `once`          | `true` = run once per session then remove. Only honored in skill frontmatter             |

### Hook locations (scope)

| Location                                     | Scope                          | Shareable |
| :------------------------------------------- | :----------------------------- | :-------- |
| `~/.claude/settings.json`                    | All your projects              | No        |
| `.claude/settings.json`                      | Single project                 | Yes       |
| `.claude/settings.local.json`                | Single project                 | No        |
| Managed policy settings                      | Organization-wide              | Yes       |
| Plugin `hooks/hooks.json`                    | When plugin is enabled         | Yes       |
| Skill or subagent frontmatter `hooks:` field | While component is active      | Yes       |

### Matcher patterns

| Matcher value                         | Evaluated as                                                          |
| :------------------------------------ | :-------------------------------------------------------------------- |
| `"*"`, `""`, or omitted              | Match all                                                             |
| Only letters, digits, `_`, and `\|`  | Exact string or pipe-separated list (e.g. `Edit\|Write`)              |
| Contains any other character          | JavaScript regular expression (e.g. `mcp__memory__.*`)               |

What each event type matches against:

| Events                                                                    | Matcher filters                   | Example values                                                              |
| :------------------------------------------------------------------------ | :-------------------------------- | :-------------------------------------------------------------------------- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name         | `Bash`, `Edit\|Write`, `mcp__.*`                                           |
| `SessionStart`                                                            | session start reason              | `startup`, `resume`, `clear`, `compact`                                     |
| `Setup`                                                                   | CLI flag                          | `init`, `maintenance`                                                       |
| `SessionEnd`                                                              | end reason                        | `clear`, `resume`, `logout`, `prompt_input_exit`, `other`                   |
| `Notification`                                                            | notification type                 | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_*`         |
| `SubagentStart`, `SubagentStop`                                           | agent type                        | `general-purpose`, `Explore`, `Plan`, custom agent names                    |
| `PreCompact`, `PostCompact`                                               | trigger                           | `manual`, `auto`                                                            |
| `ConfigChange`                                                            | config source                     | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure`                                                             | error type                        | `rate_limit`, `overloaded`, `authentication_failed`, `server_error`, etc.   |
| `InstructionsLoaded`                                                      | load reason                       | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion`                                                     | command name                      | your skill or command names                                                 |
| `Elicitation`, `ElicitationResult`                                        | MCP server name                   | your configured MCP server names                                            |
| `FileChanged`                                                             | literal filenames (pipe-separated) | `.envrc\|.env`                                                             |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | no matcher | always fires |

MCP tools follow the `mcp__<server>__<tool>` naming pattern. Match an entire server with `mcp__memory__.*` (the `.*` suffix is required).

### Exit codes (command hooks)

| Exit code | Meaning                                                                              |
| :-------- | :----------------------------------------------------------------------------------- |
| 0         | Success. JSON on stdout is parsed for decision fields                                |
| 2         | Blocking error. Stderr fed to Claude or user as feedback. JSON ignored               |
| Other     | Non-blocking error. Transcript shows `<hook name> hook error`. Execution continues   |

For `WorktreeCreate`, any non-zero exit code aborts worktree creation.

### JSON output fields (universal)

| Field              | Default | Description                                                                                  |
| :----------------- | :------ | :------------------------------------------------------------------------------------------- |
| `continue`         | `true`  | `false` stops Claude entirely after the hook runs                                            |
| `stopReason`       | none    | Message shown to user when `continue` is `false`                                             |
| `suppressOutput`   | `false` | Hides hook stdout from transcript (still in debug log)                                       |
| `systemMessage`    | none    | Warning message shown to the user                                                            |
| `terminalSequence` | none    | Terminal escape sequence Claude Code emits on your behalf (OSC 0/1/2/9/99/777 and BEL only) |

### Decision control by event

| Events                                                                                              | Pattern                  | Key fields                                                                            |
| :-------------------------------------------------------------------------------------------------- | :----------------------- | :------------------------------------------------------------------------------------ |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse`                                                                                        | `hookSpecificOutput`     | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest`                                                                                 | `hookSpecificOutput`     | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied`                                                                                  | `hookSpecificOutput`     | `retry: true` to let model retry the denied call                                     |
| `WorktreeCreate`                                                                                    | Path return              | Command hook prints path on stdout; HTTP hook returns `hookSpecificOutput.worktreePath` |
| `Elicitation`                                                                                       | `hookSpecificOutput`     | `action` (accept/decline/cancel), `content`                                          |
| `ElicitationResult`                                                                                 | `hookSpecificOutput`     | `action`, `content` (override)                                                       |
| `MessageDisplay`                                                                                    | `hookSpecificOutput`     | `displayContent` replaces displayed text; transcript and model see original          |
| `SessionStart`, `Setup`, `SubagentStart`                                                            | Context only             | `additionalContext`; `SessionStart` also accepts `initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | No decision control; side effects only |

### `additionalContext` delivery timing

| Events                                                              | When Claude receives the context                          |
| :------------------------------------------------------------------ | :-------------------------------------------------------- |
| `SessionStart`, `Setup`, `SubagentStart`                            | Start of conversation, before first prompt               |
| `UserPromptSubmit`, `UserPromptExpansion`                           | Alongside the submitted prompt                           |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`  | Next to the tool result                                  |
| `Stop`, `SubagentStop`                                              | End of turn; conversation continues so Claude can act    |

### Common input fields (all events)

| Field             | Description                                                     |
| :---------------- | :-------------------------------------------------------------- |
| `session_id`      | Current session identifier                                      |
| `transcript_path` | Path to conversation JSON                                       |
| `cwd`             | Working directory when hook was invoked                         |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `effort`          | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, or `"max"` |
| `hook_event_name` | Name of the event that fired                                    |

### Path placeholders

| Placeholder             | Value                                                                     |
| :---------------------- | :------------------------------------------------------------------------ |
| `${CLAUDE_PROJECT_DIR}` | Project root directory                                                    |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on plugin update)                  |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (survives plugin updates)                |

Use exec form (`"args": []`) when a `command` references a path placeholder to avoid shell quoting issues.

### `CLAUDE_ENV_FILE`

Available to `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export VAR=value` statements to this path (append with `>>`) to persist environment variables into all subsequent Bash commands for the session.

### PreToolUse `permissionDecision` values

| Value     | Effect                                                                        |
| :-------- | :---------------------------------------------------------------------------- |
| `"allow"` | Skip permission prompt. Deny/ask rules still evaluated                        |
| `"deny"`  | Cancel tool call; reason shown to Claude                                      |
| `"ask"`   | Show permission prompt to user with source label                              |
| `"defer"` | Exit with `stop_reason: "tool_deferred"` so calling process can collect input (non-interactive `-p` only) |

Multiple hooks: `deny` > `defer` > `ask` > `allow`.

### PermissionRequest `updatedPermissions` entry types

| `type`              | Fields                               | Effect                                  |
| :------------------ | :----------------------------------- | :-------------------------------------- |
| `addRules`          | `rules`, `behavior`, `destination`   | Add permission rules                    |
| `replaceRules`      | `rules`, `behavior`, `destination`   | Replace all rules of given behavior     |
| `removeRules`       | `rules`, `behavior`, `destination`   | Remove matching rules                   |
| `setMode`           | `mode`, `destination`                | Change permission mode                  |
| `addDirectories`    | `directories`, `destination`         | Add working directories                 |
| `removeDirectories` | `directories`, `destination`         | Remove working directories              |

`destination` options: `session`, `localSettings`, `projectSettings`, `userSettings`.

### Hooks in skills and agents (frontmatter)

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
```

For subagents, `Stop` hooks are auto-converted to `SubagentStop`. All hook events are supported.

### Key limits and notes

- JSON output strings capped at 10,000 characters (excess saved to file)
- Multiple hooks matching same event run in parallel; results merged (most restrictive `PreToolUse` decision wins)
- Stop hook blocked more than 8 consecutive times triggers auto-override; check `stop_hook_active` field
- `PostToolUse` hooks cannot undo actions; use `PreToolUse` to intercept before execution
- `PermissionRequest` does not fire in non-interactive mode (`-p`); use `PreToolUse` instead
- Command hooks run without a controlling terminal; use `terminalSequence` field instead of writing to `/dev/tty`
- `disableAllHooks: true` in settings disables all hooks except those in managed policy settings

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) — Full event schemas, JSON input/output formats, all hook types, exit codes, async hooks, HTTP hooks, MCP tool hooks, prompt hooks, agent hooks, and per-event decision control
- [Automate actions with hooks](references/claude-code-hooks-guide.md) — Practical guide with common automation patterns, setup walkthrough, troubleshooting, and ready-to-use configuration examples

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate actions with hooks: https://code.claude.com/docs/en/hooks-guide.md
