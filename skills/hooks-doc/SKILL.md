---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, configuration schema, JSON input/output formats, exit codes, matcher patterns, command/HTTP/prompt/agent hook types, decision control, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific lifecycle points in Claude Code. They provide deterministic control over Claude's behavior — enforcing rules, automating tasks, and integrating with external tools.

### Hook event summary

| Event | When it fires | Can block? |
| :---- | :------------ | :--------- |
| `SessionStart` | Session begins or resumes | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | A slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes |
| `PermissionDenied` | Tool call denied by auto mode classifier | No (JSON retry only) |
| `PostToolUse` | After a tool call succeeds | No (shows stderr to Claude) |
| `PostToolUseFailure` | After a tool call fails | No (shows stderr to Claude) |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No (ignored) |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `TaskCreated` | Task being created via `TaskCreate` | Yes |
| `TaskCompleted` | Task being marked as completed | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `ConfigChange` | Configuration file changes during a session | Yes (except policy_settings) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `Notification` | Claude Code sends a notification | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero exit) |
| `WorktreeRemove` | Worktree being removed | No |
| `SessionEnd` | Session terminates | No |

### Configuration structure

Hooks are defined in JSON settings files under a `hooks` key. Three nesting levels:

1. **Hook event** — which lifecycle point to respond to (e.g. `PreToolUse`)
2. **Matcher group** — filters when it fires (e.g. tool name pattern)
3. **Hook handler** — the command, URL, prompt, or agent that runs

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

### Hook location and scope

| Location | Scope | Shareable |
| :------- | :---- | :-------- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill or agent frontmatter | While component is active | Yes |

Use `/hooks` in Claude Code to browse all configured hooks (read-only). Disable all hooks at once with `"disableAllHooks": true` in settings.

### Matcher patterns

| Matcher value | Evaluated as |
| :------------ | :----------- |
| `"*"`, `""`, or omitted | Match all occurrences |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

What each event type matches on:

| Events | Matcher field |
| :----- | :------------ |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `SessionStart` | Session source (`startup`, `resume`, `clear`, `compact`) |
| `SessionEnd` | Exit reason (`clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other`) |
| `Notification` | Type (`permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`) |
| `SubagentStart`, `SubagentStop` | Agent type (`Bash`, `Explore`, `Plan`, or custom) |
| `PreCompact`, `PostCompact` | Trigger (`manual`, `auto`) |
| `ConfigChange` | Source (`user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`) |
| `StopFailure` | Error type (`rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown`) |
| `InstructionsLoaded` | Load reason (`session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact`) |
| `FileChanged` | Literal filenames to watch (e.g. `.envrc\|.env`) |
| `UserPromptExpansion` | Command name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support — always fires |

**MCP tool naming:** `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from a server. `.*` is required — `mcp__memory` alone is treated as an exact string and matches nothing.

### The `if` field (fine-grained filtering)

Requires Claude Code v2.1.85+. Filters at the individual handler level using permission rule syntax (`"Bash(git *)"`, `"Edit(*.ts)"`). Only works on tool events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`.

```json
{
  "type": "command",
  "if": "Bash(git *)",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-git-policy.sh"
}
```

### Hook handler types and fields

**Common fields (all types):**

| Field | Required | Description |
| :---- | :------- | :---------- |
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax to filter when this hook spawns |
| `timeout` | No | Seconds before canceling (default: 600 command, 30 prompt, 60 agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs once per session then removed (skill frontmatter only) |

**Command hook additional fields:**

| Field | Required | Description |
| :---- | :------- | :---------- |
| `command` | Yes | Shell command to execute |
| `async` | No | If `true`, runs in background without blocking |
| `asyncRewake` | No | Runs in background; wakes Claude on exit 2 |
| `shell` | No | `"bash"` (default) or `"powershell"` |

**HTTP hook additional fields:**

| Field | Required | Description |
| :---- | :------- | :---------- |
| `url` | Yes | URL for POST request |
| `headers` | No | Key-value headers; supports `$VAR_NAME` interpolation |
| `allowedEnvVars` | No | Env var names that may be interpolated into headers |

**Prompt and agent hook additional fields:**

| Field | Required | Description |
| :---- | :------- | :---------- |
| `prompt` | Yes | Prompt text; use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | No | Model to use (defaults to a fast model) |

### Exit codes

| Exit code | Meaning |
| :-------- | :------ |
| `0` | Success; Claude Code parses stdout for JSON output |
| `2` | Blocking error; stderr is fed to Claude as feedback (see table above for per-event effect) |
| Any other | Non-blocking error; execution continues; first line of stderr shown in transcript |

**Important:** Use `exit 2` to block, not `exit 1`. Exit 1 is non-blocking. Exception: `WorktreeCreate` aborts on any non-zero exit code.

### JSON output (exit 0 only)

Universal fields available in all hook JSON output:

| Field | Default | Description |
| :---- | :------ | :---------- |
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | none | Warning message shown to the user |

### Decision control by event

| Events | Pattern | Key fields |
| :----- | :------ | :--------- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr feedback |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` to let model retry |
| `WorktreeCreate` | Path return | Command hook prints path on stdout; failure or missing path fails creation |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

**PreToolUse `permissionDecision` values:**
- `"allow"` — skip interactive permission prompt (deny/ask rules still evaluated)
- `"deny"` — cancel the tool call, send reason to Claude
- `"ask"` — show permission prompt to user
- `"defer"` — exit with tool call preserved for Agent SDK wrapper to resume (non-interactive `-p` mode only; requires v2.1.89+)

When multiple PreToolUse hooks return different decisions, precedence: `deny` > `defer` > `ask` > `allow`.

### Common input fields (all events)

| Field | Description |
| :---- | :---------- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook is invoked |
| `permission_mode` | Current mode (`default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`) |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (subagent context only) |
| `agent_type` | Agent name (subagent context only) |

### Environment variables for hook scripts

| Variable | Available in | Description |
| :------- | :----------- | :---------- |
| `CLAUDE_PROJECT_DIR` | All command hooks | Project root; wrap in quotes for paths with spaces |
| `CLAUDE_ENV_FILE` | `SessionStart`, `CwdChanged`, `FileChanged` | Write `export VAR=value` lines here to persist env vars for Bash commands |
| `CLAUDE_CODE_REMOTE` | All command hooks | Set to `"true"` in remote web environments |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hook scripts | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hook scripts | Plugin persistent data directory |

### Hook types: prompt and agent

**Prompt hooks** (`type: "prompt"`) — single-turn LLM evaluation. Model returns:
- `{"ok": true}` — action proceeds
- `{"ok": false, "reason": "..."}` — action blocked; reason fed back to Claude

**Agent hooks** (`type: "agent"`) — spawns a subagent that can read files, search code, and use tools. Same `ok`/`reason` format. Default timeout 60s, up to 50 tool-use turns. Experimental — prefer command hooks for production.

Use prompt hooks when input data alone is sufficient to decide. Use agent hooks when you need to verify against actual codebase state.

### HTTP hooks

HTTP hooks POST the same JSON a command hook would receive on stdin. The endpoint returns a JSON response body using the same output format. HTTP status codes alone cannot block actions — return a 2xx with the appropriate decision JSON to block.

Response handling:
- 2xx empty body: success (equivalent to exit 0 with no output)
- 2xx plain text: success, added as context
- 2xx JSON body: success, parsed with same schema as command output
- Non-2xx / connection failure / timeout: non-blocking error, execution continues

### Stop hook infinite loop prevention

Parse `stop_hook_active` from the JSON input and exit early if `true`:

```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
# rest of hook logic
```

### Shell profile interference with JSON output

If `~/.zshrc` or `~/.bashrc` has unconditional `echo` statements, they prepend text to the hook's JSON output and cause parse failures. Fix by wrapping them in an interactive-shell check:

```bash
if [[ $- == *i* ]]; then
  echo "Shell ready"
fi
```

### Common automations

| Use case | Event | Matcher | Notes |
| :------- | :---- | :------ | :---- |
| Desktop notification when Claude waits | `Notification` | `""` | `osascript` (macOS), `notify-send` (Linux) |
| Auto-format after edits | `PostToolUse` | `Edit\|Write` | Extract `tool_input.file_path` with `jq` |
| Block edits to protected files | `PreToolUse` | `Edit\|Write` | Exit 2 with reason on path match |
| Re-inject context after compaction | `SessionStart` | `compact` | Stdout added to Claude's context |
| Audit config changes | `ConfigChange` | `""` | Log to file; exit 2 to block |
| Reload env with direnv | `CwdChanged` | — | Write to `$CLAUDE_ENV_FILE` |
| Auto-approve specific permissions | `PermissionRequest` | tool name | Return JSON with `behavior: "allow"` |
| Enforce tests before stopping | `Stop` | — | Check `stop_hook_active`; return `decision: "block"` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide with common use cases, step-by-step examples, hook types, matchers, configuration locations, prompt/agent/HTTP hooks, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete event schemas, JSON input/output formats, exit codes, decision control fields, async hooks, per-event input examples, `PreToolUse` tool input schemas, `PermissionRequest` permission update entries, and `WorktreeCreate` path return

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
