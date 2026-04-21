---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events, configuration schema, JSON input/output formats, exit codes, matcher patterns, decision control, async hooks, HTTP hooks, prompt hooks, agent hooks, and security considerations.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over behavior — ensuring actions always happen rather than relying on the model to choose.

### Hook event reference

| Event                | When it fires                                                               | Can block? |
| :------------------- | :-------------------------------------------------------------------------- | :--------- |
| `SessionStart`       | Session begins or resumes                                                   | No         |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` file loaded into context                  | No         |
| `UserPromptSubmit`   | User submits a prompt, before Claude processes it                           | Yes        |
| `PreToolUse`         | Before a tool call executes                                                 | Yes        |
| `PermissionRequest`  | Permission dialog is about to appear                                        | Yes        |
| `PermissionDenied`   | Auto mode classifier denies a tool call                                     | No (retry) |
| `PostToolUse`        | After a tool call succeeds                                                  | No (feedback) |
| `PostToolUseFailure` | After a tool call fails                                                     | No (feedback) |
| `Notification`       | Claude Code sends a notification                                            | No         |
| `SubagentStart`      | Subagent is spawned                                                         | No         |
| `SubagentStop`       | Subagent finishes                                                           | Yes        |
| `TaskCreated`        | Task being created via `TaskCreate`                                         | Yes        |
| `TaskCompleted`      | Task being marked completed                                                 | Yes        |
| `Stop`               | Claude finishes responding                                                  | Yes        |
| `StopFailure`        | Turn ends due to API error (output/exit code ignored)                       | No         |
| `TeammateIdle`       | Agent team teammate is about to go idle                                     | Yes        |
| `ConfigChange`       | Configuration file changes during a session                                 | Yes (except policy) |
| `CwdChanged`         | Working directory changes                                                   | No         |
| `FileChanged`        | Watched file changes on disk                                                | No         |
| `PreCompact`         | Before context compaction                                                   | Yes        |
| `PostCompact`        | After context compaction completes                                          | No         |
| `WorktreeCreate`     | Worktree is being created (replaces default git behavior)                   | Yes        |
| `WorktreeRemove`     | Worktree is being removed                                                   | No         |
| `Elicitation`        | MCP server requests user input during a tool call                           | Yes        |
| `ElicitationResult`  | After user responds to MCP elicitation, before response sent to server      | Yes        |
| `SessionEnd`         | Session terminates                                                          | No         |

### Configuration structure

Hooks live in a `hooks` object inside a settings file. Three levels of nesting:

1. **Hook event** — lifecycle point (e.g. `PreToolUse`)
2. **Matcher group** — filter when it fires (e.g. `"Edit|Write"`)
3. **Hook handlers** — what runs (command, HTTP, prompt, or agent)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

### Hook locations (scope)

| Location                           | Scope                 | Shareable                         |
| :--------------------------------- | :-------------------- | :-------------------------------- |
| `~/.claude/settings.json`          | All projects          | No, local to your machine         |
| `.claude/settings.json`            | Single project        | Yes, committable to repo          |
| `.claude/settings.local.json`      | Single project        | No, gitignored                    |
| Managed policy settings            | Organization-wide     | Yes, admin-controlled             |
| Plugin `hooks/hooks.json`          | When plugin enabled   | Yes, bundled with plugin          |
| Skill or agent frontmatter         | While component active| Yes, defined in component file    |

Use `/hooks` in Claude Code to browse all configured hooks. Set `"disableAllHooks": true` in settings to disable all hooks temporarily.

### Matcher patterns

| Matcher value                              | Evaluated as                           | Example                              |
| :----------------------------------------- | :------------------------------------- | :----------------------------------- |
| `"*"`, `""`, or omitted                    | Match all                              | fires on every event occurrence      |
| Only letters, digits, `_`, and `\|`        | Exact string or `\|`-separated list    | `Edit\|Write` matches either exactly |
| Contains any other character               | JavaScript regular expression          | `mcp__memory__.*` matches all tools  |

What the matcher filters, by event:

| Events                                                                           | Matcher filters                    | Example values                                                 |
| :------------------------------------------------------------------------------- | :--------------------------------- | :------------------------------------------------------------- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name             | `Bash`, `Edit\|Write`, `mcp__.*`                               |
| `SessionStart`                                                                   | how session started                | `startup`, `resume`, `clear`, `compact`                        |
| `SessionEnd`                                                                     | why session ended                  | `clear`, `resume`, `logout`, `prompt_input_exit`, `other`      |
| `Notification`                                                                   | notification type                  | `permission_prompt`, `idle_prompt`, `auth_success`             |
| `SubagentStart`, `SubagentStop`                                                  | agent type                         | `Bash`, `Explore`, `Plan`, custom names                        |
| `PreCompact`, `PostCompact`                                                      | compaction trigger                 | `manual`, `auto`                                               |
| `ConfigChange`                                                                   | config source                      | `user_settings`, `project_settings`, `skills`                  |
| `StopFailure`                                                                    | error type                         | `rate_limit`, `authentication_failed`, `server_error`          |
| `InstructionsLoaded`                                                             | load reason                        | `session_start`, `nested_traversal`, `path_glob_match`         |
| `FileChanged`                                                                    | literal filenames to watch         | `.envrc\|.env`                                                 |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | fires on every occurrence |

### The `if` field (fine-grained filtering, v2.1.85+)

Per-handler filter using permission rule syntax. Hook only spawns when the tool call matches:

```json
{
  "type": "command",
  "if": "Bash(git *)",
  "command": "/path/to/check-git-policy.sh"
}
```

Only works on tool events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`.

### Hook handler types

| Type        | Description                                                          | Timeout default |
| :---------- | :------------------------------------------------------------------- | :-------------- |
| `"command"` | Runs a shell command. Input via stdin, output via exit code + stdout | 600s            |
| `"http"`    | POSTs event JSON to a URL. Results via response body                 | 30s             |
| `"prompt"`  | Single LLM call (Haiku by default). Returns `{"ok": true/false}`    | 30s             |
| `"agent"`   | Spawns subagent with tools (experimental). Returns `{"ok": true/false}` | 60s          |

Common fields for all handler types:

| Field           | Description                                                                                  |
| :-------------- | :------------------------------------------------------------------------------------------- |
| `type`          | `"command"`, `"http"`, `"prompt"`, or `"agent"`                                              |
| `if`            | Permission rule to filter when this handler runs (tool events only)                          |
| `timeout`       | Seconds before canceling                                                                     |
| `statusMessage` | Custom spinner message while hook runs                                                       |
| `once`          | If `true`, runs once per session then removed (skill/agent frontmatter only)                 |

Command hook additional fields:

| Field         | Description                                                                                    |
| :------------ | :--------------------------------------------------------------------------------------------- |
| `command`     | Shell command to execute                                                                       |
| `async`       | If `true`, runs in background without blocking                                                 |
| `asyncRewake` | If `true`, runs in background and wakes Claude on exit code 2. Implies `async`                 |
| `shell`       | `"bash"` (default) or `"powershell"` (Windows)                                                |

HTTP hook additional fields:

| Field            | Description                                                                                  |
| :--------------- | :------------------------------------------------------------------------------------------- |
| `url`            | URL to POST to                                                                               |
| `headers`        | Additional headers. Values support `$VAR_NAME` interpolation if listed in `allowedEnvVars`  |
| `allowedEnvVars` | Env var names allowed for header interpolation                                               |

### Exit codes

| Exit code   | Meaning                                                                           |
| :---------- | :-------------------------------------------------------------------------------- |
| `0`         | Success. JSON output is processed. stdout added to context for SessionStart/UserPromptSubmit |
| `2`         | Blocking error. stderr fed back as feedback. JSON is ignored                      |
| Any other   | Non-blocking error. Execution continues. stderr shown as notice in transcript     |

**Important**: Only exit code 2 blocks — exit code 1 is treated as non-blocking. Exception: `WorktreeCreate` fails on any non-zero exit code.

### JSON output (structured control)

Use exit 0 and print a JSON object to stdout for finer-grained control. Universal fields:

| Field            | Default | Description                                                                                        |
| :--------------- | :------ | :------------------------------------------------------------------------------------------------- |
| `continue`       | `true`  | If `false`, Claude stops entirely. Takes precedence over event-specific decision fields            |
| `stopReason`     | none    | Shown to user when `continue` is `false`                                                           |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log                                                             |
| `systemMessage`  | none    | Warning message shown to user                                                                      |

### Decision control by event

| Events                                                                                       | Pattern               | Key fields                                                                           |
| :------------------------------------------------------------------------------------------- | :-------------------- | :----------------------------------------------------------------------------------- |
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason`                                   |
| `PreToolUse`                                                                                 | `hookSpecificOutput`  | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest`                                                                          | `hookSpecificOutput`  | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied`                                                                           | `hookSpecificOutput`  | `retry: true` to tell model it may retry                                             |
| `WorktreeCreate`                                                                             | path return           | Command hook prints path to stdout; HTTP returns `hookSpecificOutput.worktreePath`   |
| `Elicitation`                                                                                | `hookSpecificOutput`  | `action` (accept/decline/cancel), `content`                                          |
| `ElicitationResult`                                                                          | `hookSpecificOutput`  | `action` (accept/decline/cancel), `content`                                          |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted`                                               | Exit code or `continue: false` | Exit 2 = feedback + keep working; `{"continue": false}` = stop entirely    |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | No decision control; used for side effects |

### PreToolUse `permissionDecision` values

| Value     | Effect                                                                                  |
| :-------- | :-------------------------------------------------------------------------------------- |
| `"allow"` | Skips permission prompt. Deny/ask rules still apply                                     |
| `"deny"`  | Cancels tool call. `permissionDecisionReason` shown to Claude                           |
| `"ask"`   | Shows permission prompt to user. `permissionDecisionReason` shown to user               |
| `"defer"` | Non-interactive mode only (`-p`). Exits with `stop_reason: "tool_deferred"` for resume  |

When multiple PreToolUse hooks return different decisions, precedence: `deny` > `defer` > `ask` > `allow`.

### Common input fields (all events)

| Field             | Description                                                                      |
| :---------------- | :------------------------------------------------------------------------------- |
| `session_id`      | Current session identifier                                                       |
| `transcript_path` | Path to conversation JSON                                                        |
| `cwd`             | Current working directory                                                        |
| `permission_mode` | Current permission mode (not present on all events)                              |
| `hook_event_name` | Name of the event that fired                                                     |
| `agent_id`        | Subagent identifier (present when hook fires inside a subagent)                  |
| `agent_type`      | Agent name (present when using `--agent` or inside a subagent)                   |

### Environment variables for scripts

| Variable              | Description                                                    |
| :-------------------- | :------------------------------------------------------------- |
| `$CLAUDE_PROJECT_DIR` | Project root directory                                         |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory                              |
| `${CLAUDE_PLUGIN_DATA}` | Plugin's persistent data directory                           |
| `$CLAUDE_ENV_FILE`    | File path for persisting env vars (SessionStart, CwdChanged, FileChanged only) |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments                     |

### Key event-specific notes

**SessionStart**: stdout added to Claude's context. Only `type: "command"` hooks supported. Write `export VAR=value` lines to `$CLAUDE_ENV_FILE` to persist env vars across Bash commands.

**UserPromptSubmit**: Can add `additionalContext` (discreet) or plain stdout (visible). Can set `sessionTitle` to rename the session.

**PreToolUse tool names**: `Bash`, `Edit`, `Write`, `Read`, `Glob`, `Grep`, `Agent`, `WebFetch`, `WebSearch`, `AskUserQuestion`, `ExitPlanMode`, plus MCP tools as `mcp__<server>__<tool>`.

**Stop**: Check `stop_hook_active` field in input — if `true`, your hook already triggered a continuation; exit 0 to allow stopping and prevent infinite loops.

**FileChanged**: Matcher serves dual role — splits on `|` to build the watch list of literal filenames, then filters which groups run when a file changes.

**CwdChanged / FileChanged**: Can return `watchPaths` array to dynamically update which files are watched.

**WorktreeCreate**: Replaces default git behavior entirely. Hook must print the new worktree path to stdout.

**SessionEnd**: Default timeout 1.5s (auto-raised to highest per-hook timeout, up to 60s). Override with `CLAUDE_CODE_SESSION_END_HOOKS_TIMEOUT_MS`.

### Prompt and agent hooks

Events supporting all four types (`command`, `http`, `prompt`, `agent`): `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `UserPromptSubmit`.

`SessionStart` supports `command` only. All other events support `command` and `http` but not `prompt` or `agent`.

Prompt/agent hooks return: `{"ok": true}` to allow, `{"ok": false, "reason": "..."}` to block.

Use `$ARGUMENTS` in the `prompt` field as a placeholder for hook input JSON.

### Async hooks

Set `"async": true` on a `command` hook to run it in the background without blocking Claude. Async hooks cannot block actions or return decisions — the triggering action has already proceeded. Output (`systemMessage`, `additionalContext`) is delivered on the next conversation turn. Use `asyncRewake: true` to wake Claude immediately when the background process exits with code 2.

### Security best practices

- Validate and sanitize all input data — never trust blindly
- Always quote shell variables: `"$VAR"` not `$VAR`
- Block path traversal: check for `..` in file paths
- Use absolute paths for scripts, using `"$CLAUDE_PROJECT_DIR"`
- Skip sensitive files: avoid `.env`, `.git/`, keys, etc.
- `PreToolUse` hooks fire before permission-mode checks — a `deny` blocks even in `bypassPermissions` mode
- A hook returning `"allow"` does not override deny rules from settings

### Debugging

Start with `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`. Or run `/debug` mid-session. Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher details. Toggle `Ctrl+O` in the transcript view for per-hook summaries.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide with common use-case examples: notifications, auto-formatting, blocking edits, re-injecting context after compaction, auditing config changes, reloading env on directory change, and auto-approving permission prompts
- [Hooks reference](references/claude-code-hooks-reference.md) — complete event schemas, configuration schema, JSON input/output formats, exit codes, async hooks, HTTP hooks, prompt hooks, agent hooks, MCP tool matching, security considerations, and debug instructions

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
