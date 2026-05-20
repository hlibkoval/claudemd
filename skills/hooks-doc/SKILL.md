---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook types

| Type         | Description                                                                 |
| :----------- | :-------------------------------------------------------------------------- |
| `command`    | Run a shell command. Communicates via stdin/stdout/stderr and exit codes     |
| `http`       | POST event data to a URL. Results come back in the HTTP response body       |
| `mcp_tool`   | Call a tool on a connected MCP server                                       |
| `prompt`     | Single-turn LLM evaluation returning `{"ok": true/false, "reason": "..."}` |
| `agent`      | Multi-turn subagent with tool access (experimental)                         |

### Hook events (lifecycle order)

| Event                  | Fires when                                                            | Can block? | Matcher field           |
| :--------------------- | :-------------------------------------------------------------------- | :--------- | :---------------------- |
| `SessionStart`         | Session begins or resumes                                             | No         | source                  |
| `Setup`                | `--init-only` / `-p --init` / `-p --maintenance`                     | No         | trigger                 |
| `InstructionsLoaded`   | CLAUDE.md or rules file loaded into context                           | No         | load_reason             |
| `UserPromptSubmit`     | User submits a prompt, before Claude processes it                     | Yes        | (none)                  |
| `UserPromptExpansion`  | Slash command expands into a prompt                                   | Yes        | command_name            |
| `PreToolUse`           | Before a tool call executes                                           | Yes        | tool_name               |
| `PermissionRequest`    | Permission dialog about to appear                                     | Yes        | tool_name               |
| `PermissionDenied`     | Auto mode classifier denies a tool call                               | No         | tool_name               |
| `PostToolUse`          | After a tool call succeeds                                            | No*        | tool_name               |
| `PostToolUseFailure`   | After a tool call fails                                               | No*        | tool_name               |
| `PostToolBatch`        | After all parallel tool calls in a batch resolve                      | Yes        | (none)                  |
| `Notification`         | Claude Code sends a notification                                      | No         | notification_type       |
| `SubagentStart`        | Subagent is spawned                                                   | No         | agent_type              |
| `SubagentStop`         | Subagent finishes                                                     | Yes        | agent_type              |
| `TaskCreated`          | Task created via TaskCreate tool                                      | Yes        | (none)                  |
| `TaskCompleted`        | Task marked as completed                                              | Yes        | (none)                  |
| `Stop`                 | Claude finishes responding                                            | Yes        | (none)                  |
| `StopFailure`          | Turn ends due to API error                                            | No         | error_type              |
| `TeammateIdle`         | Agent team teammate about to go idle                                  | Yes        | (none)                  |
| `PreCompact`           | Before context compaction                                             | Yes        | trigger                 |
| `PostCompact`          | After context compaction completes                                    | No         | trigger                 |
| `Elicitation`          | MCP server requests user input                                        | Yes        | MCP server name         |
| `ElicitationResult`    | User responds to MCP elicitation                                      | Yes        | MCP server name         |
| `ConfigChange`         | Configuration file changes during session                             | Yes        | config source           |
| `CwdChanged`           | Working directory changes                                             | No         | (none)                  |
| `FileChanged`          | Watched file changes on disk                                          | No         | filename(s) to watch    |
| `WorktreeCreate`       | Worktree being created                                                | Yes        | (none)                  |
| `WorktreeRemove`       | Worktree being removed                                                | No         | (none)                  |
| `SessionEnd`           | Session terminates                                                    | No         | end_reason              |

\* `PostToolUse` exit 2 shows stderr to Claude; `PostToolBatch` exit 2 stops the agentic loop.

### Matcher patterns

| Matcher value                           | Evaluated as                                          |
| :-------------------------------------- | :---------------------------------------------------- |
| `""`, `"*"`, or omitted                 | Match all                                             |
| Letters, digits, `_`, `\|` only         | Exact string or pipe-separated list of exact strings  |
| Contains any other character            | JavaScript regular expression                         |

MCP tools follow `mcp__<server>__<tool>` naming. Use `mcp__memory__.*` to match all tools from a server.

### Exit code behavior

| Exit code      | Meaning                                                                 |
| :------------- | :---------------------------------------------------------------------- |
| `0`            | Success. Stdout is parsed for JSON output. `SessionStart`/`UserPromptSubmit`/`UserPromptExpansion` stdout added to Claude's context |
| `2`            | Blocking error. Stderr fed to Claude as feedback (or blocks action). JSON is ignored |
| Any other      | Non-blocking error. Transcript shows hook error notice; execution continues |

For `WorktreeCreate`, any non-zero exit code fails worktree creation.

### Common hook handler fields

| Field           | Required | Description                                                                       |
| :-------------- | :------- | :-------------------------------------------------------------------------------- |
| `type`          | yes      | `command`, `http`, `mcp_tool`, `prompt`, or `agent`                               |
| `if`            | no       | Permission rule syntax filter, e.g. `"Bash(git *)"`. Tool events only             |
| `timeout`       | no       | Seconds before canceling. Defaults: 600 (`command`/`http`/`mcp_tool`), 30 (`prompt`), 60 (`agent`) |
| `statusMessage` | no       | Custom spinner message while hook runs                                            |
| `once`          | no       | If true, runs once per session (skill frontmatter only)                           |

### Command hook fields

| Field         | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| `command`     | Shell command (shell form) or executable to spawn (exec form when `args` set) |
| `args`        | Argument list. When present, enables exec form (no shell tokenization)       |
| `async`       | If true, runs in background without blocking                                 |
| `asyncRewake` | If true, runs in background and wakes Claude on exit code 2                  |
| `shell`       | `"bash"` (default) or `"powershell"` (shell form only)                       |

### HTTP hook fields

| Field            | Description                                                                  |
| :--------------- | :--------------------------------------------------------------------------- |
| `url`            | URL to POST to                                                               |
| `headers`        | Key-value headers. Values support `$VAR_NAME` interpolation                  |
| `allowedEnvVars` | Env vars allowed to be interpolated in headers                               |

### MCP tool hook fields

| Field    | Description                                                                  |
| :------- | :--------------------------------------------------------------------------- |
| `server` | Name of a configured, already-connected MCP server                           |
| `tool`   | Name of the tool to call                                                     |
| `input`  | Arguments. String values support `${path}` substitution from JSON input      |

### JSON output fields (all hook types)

| Field              | Description                                                                   |
| :----------------- | :---------------------------------------------------------------------------- |
| `continue`         | If `false`, Claude stops entirely. Takes precedence over event-specific fields |
| `stopReason`       | Shown to user when `continue` is `false`                                      |
| `suppressOutput`   | If `true`, omits stdout from debug log                                        |
| `systemMessage`    | Warning message shown to the user                                             |
| `terminalSequence` | Terminal escape sequence emitted on Claude's behalf (OSC 0/1/2/9/99/777, BEL) |

### Decision control by event

| Event(s)                                                                                                       | Pattern               | Key fields                                                                        |
| :------------------------------------------------------------------------------------------------------------- | :-------------------- | :-------------------------------------------------------------------------------- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason`                                                     |
| `PreToolUse`                                                                                                   | `hookSpecificOutput`  | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest`                                                                                            | `hookSpecificOutput`  | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message` |
| `PermissionDenied`                                                                                             | `hookSpecificOutput`  | `retry: true` to allow model retry                                                |
| `WorktreeCreate`                                                                                               | path return           | Command prints worktree path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`/`ElicitationResult`                                                                              | `hookSpecificOutput`  | `action` (accept/decline/cancel), `content`                                       |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted`                                                                 | Exit code or `continue: false` | Exit 2 blocks; JSON `{"continue": false, "stopReason": "..."}` stops entirely |

### Path placeholders

| Placeholder            | Resolves to                                                                  |
| :--------------------- | :--------------------------------------------------------------------------- |
| `${CLAUDE_PROJECT_DIR}` | Project root directory                                                      |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on plugin update)                    |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (survives plugin updates)                  |

Use exec form (`args` present) when referencing path placeholders to avoid quoting issues.

### Hook locations and scope

| File                                    | Scope              | Shareable                             |
| :-------------------------------------- | :----------------- | :------------------------------------ |
| `~/.claude/settings.json`               | All projects       | No — machine-local                    |
| `.claude/settings.json`                 | Single project     | Yes — can be committed                |
| `.claude/settings.local.json`           | Single project     | No — gitignored                       |
| Managed policy settings                 | Organization-wide  | Yes — admin-controlled                |
| Plugin `hooks/hooks.json`               | When plugin active | Yes — bundled with plugin             |
| Skill or agent frontmatter              | While active       | Yes — in the component file           |

Disable all hooks temporarily with `"disableAllHooks": true` in a settings file. Remove a hook by deleting it from the JSON.

### Common input fields (all events)

| Field             | Description                                      |
| :---------------- | :----------------------------------------------- |
| `session_id`      | Current session identifier                       |
| `transcript_path` | Path to conversation JSON                        |
| `cwd`             | Working directory when hook is invoked           |
| `permission_mode` | Active permission mode (not on all events)       |
| `hook_event_name` | Name of the event that fired                     |
| `effort`          | Object with `level` field for turn effort level  |

### `additionalContext` — inject text into Claude's context

Return `additionalContext` in `hookSpecificOutput` to inject text as a system reminder. Supported by: `SessionStart`, `Setup`, `SubagentStart`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`.

### `CLAUDE_ENV_FILE` — persist environment variables

Available to `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export VAR=value` lines to persist variables for all subsequent Bash commands in the session.

### Common patterns

**Auto-format after edits:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"}]
      }
    ]
  }
}
```

**Block edits to protected files** — use `PreToolUse` with `Exit 2` from a script that checks `tool_input.file_path`.

**Re-inject context after compaction:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [{"type": "command", "command": "echo 'Reminder: use Bun, not npm.'"}]
      }
    ]
  }
}
```

**Desktop notification (Linux):**
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "notify-send 'Claude Code' 'Needs your attention'"}]
      }
    ]
  }
}
```

**Auto-approve a permission prompt** — `PermissionRequest` hook returning `hookSpecificOutput.decision.behavior: "allow"`.

**Stop hook block cap** — after 8 consecutive blocks Claude overrides the Stop hook. Check `stop_hook_active` from stdin and exit 0 early if it is `true`. Raise the cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

### Troubleshooting

| Symptom                          | Fix                                                                                           |
| :------------------------------- | :-------------------------------------------------------------------------------------------- |
| Hook not firing                  | Run `/hooks` to confirm it appears; check matcher case; verify event type is correct          |
| Hook error in transcript         | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./my-hook.sh`   |
| `/hooks` shows nothing           | Validate JSON (no trailing commas); confirm file location; restart session to force reload    |
| Stop hook hits block cap         | Read `stop_hook_active` from stdin, exit 0 if true                                           |
| JSON validation failed           | Wrap `echo` in profile with `if [[ $- == *i* ]]; then ... fi` to suppress interactive output |

Debug: start Claude with `claude --debug-file /tmp/claude.log`, or run `/debug` mid-session.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Guide](references/claude-code-hooks-guide.md) — practical walkthrough with setup examples, common patterns, and troubleshooting
- [Hooks Reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, all hook handler fields, and advanced features

## Sources

- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
- Hooks Reference: https://code.claude.com/docs/en/hooks.md
