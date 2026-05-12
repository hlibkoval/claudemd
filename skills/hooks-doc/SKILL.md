---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events and lifecycle, configuration schema, matcher patterns, hook handler types (command, HTTP, MCP tool, prompt, agent), JSON input/output formats, exit codes, decision control, async hooks, and per-event schemas.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Lifecycle Events

| Event                 | When it fires                                                                 | Can block? |
| :-------------------- | :---------------------------------------------------------------------------- | :--------- |
| `SessionStart`        | Session begins or resumes                                                     | No         |
| `Setup`               | `--init-only` or `--init`/`--maintenance` in `-p` mode                       | No         |
| `UserPromptSubmit`    | User submits a prompt, before Claude processes it                             | Yes        |
| `UserPromptExpansion` | User-typed command expands into a prompt                                      | Yes        |
| `PreToolUse`          | Before a tool call executes                                                   | Yes        |
| `PermissionRequest`   | When a permission dialog appears                                              | Yes        |
| `PermissionDenied`    | Tool call denied by auto mode classifier                                      | No         |
| `PostToolUse`         | After a tool call succeeds                                                    | No         |
| `PostToolUseFailure`  | After a tool call fails                                                       | No         |
| `PostToolBatch`       | After a full batch of parallel tool calls resolves                            | Yes        |
| `Notification`        | When Claude Code sends a notification                                         | No         |
| `SubagentStart`       | When a subagent is spawned                                                    | No         |
| `SubagentStop`        | When a subagent finishes                                                      | Yes        |
| `TaskCreated`         | When a task is being created via `TaskCreate`                                 | Yes        |
| `TaskCompleted`       | When a task is being marked as completed                                      | Yes        |
| `Stop`                | When Claude finishes responding                                               | Yes        |
| `StopFailure`         | When the turn ends due to an API error                                        | No         |
| `TeammateIdle`        | When an agent team teammate is about to go idle                               | Yes        |
| `InstructionsLoaded`  | When a CLAUDE.md or `.claude/rules/*.md` file is loaded into context          | No         |
| `ConfigChange`        | When a configuration file changes during a session                            | Yes        |
| `CwdChanged`          | When the working directory changes                                            | No         |
| `FileChanged`         | When a watched file changes on disk (matcher specifies filenames to watch)    | No         |
| `WorktreeCreate`      | When a worktree is being created                                              | Yes        |
| `WorktreeRemove`      | When a worktree is being removed                                              | No         |
| `PreCompact`          | Before context compaction                                                     | Yes        |
| `PostCompact`         | After context compaction completes                                            | No         |
| `Elicitation`         | When an MCP server requests user input during a tool call                     | Yes        |
| `ElicitationResult`   | After a user responds to an MCP elicitation                                   | Yes        |
| `SessionEnd`          | When a session terminates                                                     | No         |

### Hook Configuration Structure

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/script.sh"
          }
        ]
      }
    ]
  }
}
```

Three nesting levels: **hook event** → **matcher group** → **hook handler**.

### Hook Locations

| Location                                               | Scope                         | Shareable                         |
| :----------------------------------------------------- | :---------------------------- | :-------------------------------- |
| `~/.claude/settings.json`                              | All your projects             | No, local to your machine         |
| `.claude/settings.json`                                | Single project                | Yes, can be committed to the repo |
| `.claude/settings.local.json`                          | Single project                | No, gitignored                    |
| Managed policy settings                                | Organization-wide             | Yes, admin-controlled             |
| Plugin `hooks/hooks.json`                              | When plugin is enabled        | Yes, bundled with the plugin      |
| Skill or agent frontmatter                             | While the component is active | Yes, defined in the component file|

Disable all hooks: `"disableAllHooks": true` in settings. View configured hooks with `/hooks`.

### Matcher Patterns

| Matcher value                       | Evaluated as                                          |
| :---------------------------------- | :---------------------------------------------------- |
| `"*"`, `""`, or omitted             | Match all (fires on every occurrence)                 |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list of exact strings  |
| Contains any other character        | JavaScript regular expression                         |

**What each event matches on:**

| Event                                                                              | Matcher filters                    | Example values                                                                 |
| :--------------------------------------------------------------------------------- | :--------------------------------- | :----------------------------------------------------------------------------- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name                 | `Bash`, `Edit\|Write`, `mcp__.*`                                               |
| `SessionStart`                                                                     | how the session started            | `startup`, `resume`, `clear`, `compact`                                        |
| `Setup`                                                                            | CLI flag that triggered setup      | `init`, `maintenance`                                                          |
| `SessionEnd`                                                                       | why the session ended              | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification`                                                                     | notification type                  | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop`                                                    | agent type                         | `general-purpose`, `Explore`, `Plan`, or custom names                          |
| `PreCompact`, `PostCompact`                                                        | what triggered compaction          | `manual`, `auto`                                                               |
| `ConfigChange`                                                                     | configuration source               | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure`                                                                      | error type                         | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `unknown` |
| `InstructionsLoaded`                                                               | load reason                        | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact`  |
| `Elicitation`, `ElicitationResult`                                                 | MCP server name                    | your configured MCP server names                                               |
| `FileChanged`                                                                      | literal filenames to watch         | `.envrc\|.env`                                                                  |
| `UserPromptExpansion`                                                              | command name                       | your skill or command names                                                    |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires |

MCP tools follow the naming pattern `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from a server.

### `if` Field (Fine-grained Filtering)

Available in Claude Code v2.1.85+. Uses [permission rule syntax](/en/permissions) to filter by tool name and arguments together. Only works on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`).

```json
{
  "type": "command",
  "if": "Bash(git *)",
  "command": ".claude/hooks/check-git-policy.sh"
}
```

### Hook Handler Types

| Type        | Description                                                                  |
| :---------- | :--------------------------------------------------------------------------- |
| `command`   | Run a shell command. Input via stdin, output via stdout/stderr/exit code      |
| `http`      | POST event JSON to a URL; response body uses same JSON format as command hooks |
| `mcp_tool`  | Call a tool on an already-connected MCP server                               |
| `prompt`    | Single-turn LLM evaluation returning `{"ok": true/false, "reason": "..."}`   |
| `agent`     | Multi-turn subagent with tool access (experimental); same response format    |

### Common Handler Fields

| Field           | Required | Description                                                                     |
| :-------------- | :------- | :------------------------------------------------------------------------------ |
| `type`          | Yes      | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"`                  |
| `if`            | No       | Permission rule syntax filter (tool events only)                                |
| `timeout`       | No       | Seconds before canceling. Defaults: 600 (command), 30 (prompt), 60 (agent)     |
| `statusMessage` | No       | Custom spinner message while the hook runs                                      |
| `once`          | No       | If `true`, runs once per session then removed (skill frontmatter only)          |

**Command-specific fields:**

| Field         | Required | Description                                                                     |
| :------------ | :------- | :------------------------------------------------------------------------------ |
| `command`     | Yes      | Shell command (shell form) or executable path (exec form when `args` present)   |
| `args`        | No       | Argument list — enables exec form (no shell, each element passed verbatim)      |
| `async`       | No       | If `true`, runs in background without blocking                                  |
| `asyncRewake` | No       | If `true`, runs in background and wakes Claude on exit code 2                   |
| `shell`       | No       | `"bash"` (default) or `"powershell"`; ignored when `args` is set               |

**HTTP-specific fields:**

| Field            | Required | Description                                                                     |
| :--------------- | :------- | :------------------------------------------------------------------------------ |
| `url`            | Yes      | URL to POST to                                                                  |
| `headers`        | No       | Key-value pairs; values support `$VAR_NAME` env var interpolation               |
| `allowedEnvVars` | No       | List of env var names allowed to be interpolated into headers                   |

**MCP tool–specific fields:**

| Field    | Required | Description                                                                                |
| :------- | :------- | :----------------------------------------------------------------------------------------- |
| `server` | Yes      | Name of a connected MCP server                                                             |
| `tool`   | Yes      | Tool name on that server                                                                   |
| `input`  | No       | Arguments; string values support `${path}` substitution from hook JSON input               |

**Prompt/agent-specific fields:**

| Field    | Required | Description                                                                                |
| :------- | :------- | :----------------------------------------------------------------------------------------- |
| `prompt` | Yes      | Prompt text; use `$ARGUMENTS` as placeholder for hook input JSON                           |
| `model`  | No       | Model to use for evaluation; defaults to a fast model                                      |

### Path Placeholders

| Placeholder             | Resolves to                                          |
| :---------------------- | :--------------------------------------------------- |
| `${CLAUDE_PROJECT_DIR}` | Project root directory                               |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on update)    |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (survives updates)  |

Use exec form (`args: []`) with path placeholders to avoid quoting issues.

### Exit Codes

| Exit code    | Meaning                                                                                                            |
| :----------- | :----------------------------------------------------------------------------------------------------------------- |
| `0`          | Success. Stdout is parsed for JSON output. `SessionStart`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion` also add stdout to Claude's context |
| `2`          | Blocking error. Stderr is fed back to Claude (or shown to user). See per-event blocking behavior below            |
| Any other    | Non-blocking error. Transcript shows `<hook name> hook error`. Execution continues                                 |

**Note:** `WorktreeCreate` is the exception — any non-zero exit code aborts worktree creation.

### JSON Output Fields (Universal)

Exit 0 and print JSON for structured control instead of just exit codes:

| Field            | Default | Description                                                                          |
| :--------------- | :------ | :----------------------------------------------------------------------------------- |
| `continue`       | `true`  | If `false`, Claude stops entirely. Takes precedence over event-specific decisions    |
| `stopReason`     | none    | Message shown to user when `continue` is `false`                                     |
| `suppressOutput` | `false` | If `true`, omits stdout from the debug log                                           |
| `systemMessage`  | none    | Warning message shown to the user                                                    |

Context output is capped at 10,000 characters; larger output is saved to a file.

### Decision Control by Event

| Events                                                                                          | Pattern                        | Key fields                                                       |
| :---------------------------------------------------------------------------------------------- | :----------------------------- | :--------------------------------------------------------------- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted`                                                  | Exit code 2 or `continue: false` | Exit 2 blocks; `continue: false` stops teammate entirely        |
| `PreToolUse`                                                                                    | `hookSpecificOutput`           | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, optional `updatedInput` |
| `PermissionRequest`                                                                             | `hookSpecificOutput`           | `decision.behavior` (allow/deny), optional `updatedPermissions`  |
| `PermissionDenied`                                                                              | `hookSpecificOutput`           | `retry: true` to let the model retry                             |
| `WorktreeCreate`                                                                                | path return                    | Command hook prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`                                                                                   | `hookSpecificOutput`           | `action` (accept/decline/cancel), `content`                      |
| `ElicitationResult`                                                                             | `hookSpecificOutput`           | `action`, `content` (override)                                   |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side-effects only; no decision control |

**`PreToolUse` permissionDecision values:**

| Value   | Effect                                                                                         |
| :------ | :--------------------------------------------------------------------------------------------- |
| `allow` | Skip interactive permission prompt (deny/ask rules still apply)                               |
| `deny`  | Cancel the tool call; reason is returned to Claude                                             |
| `ask`   | Show the permission prompt to the user as normal                                               |
| `defer` | Non-interactive (`-p`) only: exit with tool call preserved for Agent SDK wrapper to resume     |

### `additionalContext` Field

Available on: `SessionStart`, `Setup`, `SubagentStart`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts and run `bun generate` instead."
  }
}
```

### `CLAUDE_ENV_FILE`

Available in `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to persist environment variables into subsequent Bash commands for the session.

```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

### Stop Hook Loop Prevention

Parse `stop_hook_active` from stdin; exit 0 early if it's `true`:

```bash
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

### Common Patterns

**Auto-format after edits:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }]
      }
    ]
  }
}
```

**Block tool calls (exit 2):**
```bash
echo "Blocked: reason" >&2
exit 2
```

**Block via JSON (more control):**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Database writes are not allowed"
  }
}
```

**Re-inject context after compaction:**
```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "compact", "hooks": [{ "type": "command", "command": "echo 'Reminder: use Bun, not npm.'" }] }
    ]
  }
}
```

**Auto-approve permission prompt:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": { "behavior": "allow" }
  }
}
```

### Troubleshooting

| Symptom                                  | Fix                                                                                          |
| :--------------------------------------- | :------------------------------------------------------------------------------------------- |
| Hook not firing                          | Check `/hooks` menu; verify matcher case-sensitivity; confirm correct event type             |
| "Hook error" in transcript               | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./my-hook.sh`  |
| "command not found"                      | Use absolute paths or `${CLAUDE_PROJECT_DIR}`; use exec form (`args: []`) to avoid quoting  |
| Hook not appearing in `/hooks`           | Verify JSON is valid (no trailing commas); confirm settings file location                    |
| Stop hook causes infinite loop           | Check `stop_hook_active` field and exit 0 early when `true`                                  |
| JSON validation failed                   | Shell profile echoing output; wrap echo statements with `if [[ $- == *i* ]]`                |
| `PermissionRequest` hook not firing      | These don't fire in non-interactive mode (`-p`); use `PreToolUse` instead                    |

Debug: run `claude --debug-file /tmp/claude.log` and tail the log for full hook execution details including exit codes, stdout, and stderr.

### Hooks and Permission Modes

- `PreToolUse` hooks fire before permission-mode checks — a `deny` blocks even in `bypassPermissions` mode
- An `allow` from a hook does not bypass deny rules from settings
- Hooks can tighten restrictions but not loosen them past what permission rules allow

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart, common use cases (notifications, formatting, blocking, context injection, auto-approve), hook types, matchers, JSON output, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, configuration schema, JSON input/output formats, exit codes, async hooks, HTTP hooks, MCP tool hooks, prompt hooks, agent hooks, per-event decision control

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
