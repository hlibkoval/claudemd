---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, configuration schema, JSON input/output formats, exit codes, matcher patterns, command/HTTP/MCP/prompt/agent hook types, async hooks, decision control, and security considerations.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control — ensuring certain actions always happen rather than relying on the model to choose to run them.

### Hook lifecycle events

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | When a session begins or resumes | No |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | When a user-typed slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes |
| `PermissionDenied` | When auto mode classifier denies a tool call | No |
| `PostToolUse` | After a tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | No (feedback only) |
| `PostToolBatch` | After a full batch of parallel tool calls resolves | Yes |
| `Notification` | When Claude Code sends a notification | No |
| `SubagentStart` | When a subagent is spawned | No |
| `SubagentStop` | When a subagent finishes | Yes |
| `TaskCreated` | When a task is being created via `TaskCreate` | Yes |
| `TaskCompleted` | When a task is being marked as completed | Yes |
| `Stop` | When Claude finishes responding | Yes |
| `StopFailure` | When the turn ends due to an API error | No |
| `TeammateIdle` | When an agent team teammate is about to go idle | Yes |
| `InstructionsLoaded` | When a CLAUDE.md or rules file is loaded | No |
| `ConfigChange` | When a configuration file changes | Yes |
| `CwdChanged` | When the working directory changes | No |
| `FileChanged` | When a watched file changes on disk | No |
| `WorktreeCreate` | When a worktree is being created | Yes |
| `WorktreeRemove` | When a worktree is being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | When an MCP server requests user input | Yes |
| `ElicitationResult` | After a user responds to an MCP elicitation | Yes |
| `SessionEnd` | When a session terminates | No |

### Hook locations and scope

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes, commit to repo |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes, bundled with plugin |
| Skill or agent frontmatter | While the component is active | Yes, in component file |

### Hook handler types

| Type | Description | Supports async |
| :--- | :--- | :--- |
| `command` | Run a shell command | Yes |
| `http` | POST event data to a URL | No |
| `mcp_tool` | Call a tool on a connected MCP server | No |
| `prompt` | Single-turn LLM evaluation | No |
| `agent` | Multi-turn LLM with tool access (experimental) | No |

### Common handler fields (all types)

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `command`, `http`, `mcp_tool`, `prompt`, or `agent` |
| `if` | No | Permission rule syntax to filter on tool name + args: `"Bash(git *)"`, `"Edit(*.ts)"`. Tool events only |
| `timeout` | No | Seconds before canceling. Default: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | No | Custom spinner message while the hook runs |
| `once` | No | Run once per session then remove (skill frontmatter only) |

### Command hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | Shell command to execute |
| `async` | No | Run in background without blocking |
| `asyncRewake` | No | Background, but wakes Claude on exit 2. Implies `async` |
| `shell` | No | `"bash"` (default) or `"powershell"` |

### HTTP hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `url` | Yes | URL to POST to |
| `headers` | No | Key-value pairs; support `$VAR_NAME` interpolation |
| `allowedEnvVars` | No | List of env var names that may be interpolated into headers |

### MCP tool hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `server` | Yes | Name of a connected MCP server |
| `tool` | Yes | Tool name on that server |
| `input` | No | Arguments; support `${path}` substitution from hook JSON input |

### Prompt / agent hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `prompt` | Yes | Prompt text. Use `$ARGUMENTS` as placeholder for the hook input JSON |
| `model` | No | Model for evaluation. Defaults to a fast model |

### Exit code behavior

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success. Claude Code parses stdout for JSON output |
| `2` | Blocking error. Stderr fed to Claude as feedback (or shown to user). Blocks action where supported |
| Other | Non-blocking error. Transcript shows a notice; execution continues |

For `WorktreeCreate`, **any** non-zero exit code causes worktree creation to fail.

### JSON output fields (universal)

Exit 0 and print a JSON object to stdout for structured control:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops processing entirely. Takes precedence over event-specific decisions |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Omits stdout from the debug log |
| `systemMessage` | none | Warning message shown to the user |

### Decision control by event

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr; `{"continue": false, "stopReason": "..."}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells the model it may retry |
| `WorktreeCreate` | path return | Command hook prints path on stdout; HTTP hook returns `hookSpecificOutput.worktreePath` |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### Matcher patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `""`, `"*"`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or pipe-separated list |
| Contains any other character | JavaScript regular expression |

**What each event matches on:**

| Events | Matches on |
| :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | Session source: `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | Exit reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart`, `SubagentStop` | Agent type: `Bash`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | Trigger: `manual`, `auto` |
| `ConfigChange` | Source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | Error type: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | Load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `FileChanged` | Literal filenames to watch (not regex): `.envrc\|.env` |
| `UserPromptExpansion` | Command name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support — always fires |

MCP tool names follow the pattern `mcp__<server>__<tool>`. To match all tools from a server: `mcp__memory__.*`. The `.*` suffix is required (plain `mcp__memory` is an exact match and won't hit any tool).

### PreToolUse `permissionDecision` values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skips the interactive permission prompt (deny/ask rules still apply) |
| `"deny"` | Cancels the tool call; reason shown to Claude |
| `"ask"` | Shows the permission dialog to the user |
| `"defer"` | Non-interactive mode only (`-p`): exits with `stop_reason: "tool_deferred"` so calling process can collect input and resume |

When multiple PreToolUse hooks return different decisions, precedence is: `deny` > `defer` > `ask` > `allow`.

### Common input fields (all events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when the hook was invoked |
| `permission_mode` | Current mode: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Unique subagent ID (when hook fires inside a subagent) |
| `agent_type` | Subagent name (when using `--agent` or inside a subagent) |

### Environment variables in hooks

| Variable | Available in | Description |
| :--- | :--- | :--- |
| `CLAUDE_PROJECT_DIR` | All command hooks | Project root directory |
| `CLAUDE_PLUGIN_ROOT` | Plugin hooks | Plugin installation directory |
| `CLAUDE_PLUGIN_DATA` | Plugin hooks | Plugin persistent data directory |
| `CLAUDE_ENV_FILE` | `SessionStart`, `CwdChanged`, `FileChanged` | File path to write `export` statements that persist into subsequent Bash commands |

### Prompt and agent hook response schema

```json
{ "ok": true }
```
```json
{ "ok": false, "reason": "Explanation shown to Claude" }
```

`ok: false` blocks the action and feeds the `reason` back to Claude.

### Permission update entries (`updatedPermissions`)

| `type` | Effect |
| :--- | :--- |
| `addRules` | Adds permission rules (`rules`, `behavior`, `destination`) |
| `replaceRules` | Replaces all rules of the given `behavior` |
| `removeRules` | Removes matching rules |
| `setMode` | Changes permission mode (`mode`, `destination`) |
| `addDirectories` | Adds working directories |
| `removeDirectories` | Removes working directories |

`destination` values: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Hook type support by event

Events that support all five types (`command`, `http`, `mcp_tool`, `prompt`, `agent`):
`PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `UserPromptExpansion`, `UserPromptSubmit`

Events that support `command`, `http`, and `mcp_tool` only (not `prompt` or `agent`):
`ConfigChange`, `CwdChanged`, `Elicitation`, `ElicitationResult`, `FileChanged`, `InstructionsLoaded`, `Notification`, `PermissionDenied`, `PostCompact`, `PreCompact`, `SessionEnd`, `StopFailure`, `SubagentStart`, `TeammateIdle`, `WorktreeCreate`, `WorktreeRemove`

`SessionStart` supports `command` and `mcp_tool` only (no `http`, `prompt`, or `agent`).

### Security best practices

- Validate and sanitize all input data — never trust blindly
- Always quote shell variables: `"$VAR"` not `$VAR`
- Block path traversal: check for `..` in file paths
- Use absolute paths; use `"$CLAUDE_PROJECT_DIR"` for the project root
- Skip sensitive files: `.env`, `.git/`, keys, etc.
- Command hooks run with your full system user permissions

### Troubleshooting quick reference

| Symptom | Fix |
| :--- | :--- |
| Hook not firing | Check `/hooks` menu; verify matcher is case-correct; `PermissionRequest` doesn't fire with `-p`, use `PreToolUse` instead |
| Hook error in transcript | Test with `echo '...' \| ./my-hook.sh`; check for missing `jq`; ensure script is executable (`chmod +x`) |
| JSON validation failed | Shell profile may print text on startup — wrap echoes in `if [[ $- == *i* ]]; then ... fi` |
| Stop hook loops forever | Parse `stop_hook_active` field and `exit 0` if it's `true` |
| Settings not picked up | Check for invalid JSON (no trailing commas); verify file location; restart session if file watcher missed the change |

Debug: start with `claude --debug-file /tmp/claude.log` then tail that file.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — practical guide covering common use cases: desktop notifications, auto-formatting, file protection, context re-injection after compaction, config auditing, environment reloading with direnv, auto-approving permission prompts, prompt/agent/HTTP hook types, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete reference covering all event schemas, JSON input/output formats, exit codes, async hooks, MCP tool hooks, prompt hooks, agent hooks, decision control tables, per-event decision fields, and security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
