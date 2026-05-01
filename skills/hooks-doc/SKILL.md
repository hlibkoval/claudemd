---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — all hook events with input/output schemas, configuration format, matcher patterns, decision control (allow/deny/block/defer), exit codes, JSON output fields, command/HTTP/MCP tool/prompt/agent hook types, async hooks, environment variables, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific lifecycle points in Claude Code. They provide deterministic control over Claude Code's behavior.

### Hook event lifecycle

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` / `--init` / `--maintenance` with `-p` | No |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` file loaded | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | User-typed command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes |
| `PermissionDenied` | Tool call denied by auto mode classifier | No (use `retry: true`) |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After all parallel tool calls finish, before next model call | Yes |
| `Notification` | When Claude Code sends a notification | No |
| `SubagentStart` | When a subagent is spawned | No |
| `SubagentStop` | When a subagent finishes | Yes |
| `TaskCreated` | Task being created via `TaskCreate` | Yes |
| `TaskCompleted` | Task being marked completed | Yes |
| `Stop` | When Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `ConfigChange` | Configuration file changes during a session | Yes |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk (matcher = filenames) | No |
| `WorktreeCreate` | Worktree being created (replaces default git behavior) | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input during a tool call | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Configuration format

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

Three nesting levels: **hook event** (lifecycle point) > **matcher group** (filter) > **hook handler** (command/http/etc that runs).

### Hook locations (scope)

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes (in component file) |

Disable all hooks: `"disableAllHooks": true` in settings. View configured hooks: `/hooks` (read-only).

### Matcher patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

What each event matches on:

| Event | What the matcher filters | Example values |
| :--- | :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | which CLI flag triggered setup | `init`, `maintenance` |
| `SessionEnd` | why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | what triggered compaction | `manual`, `auto` |
| `ConfigChange` | configuration source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | your configured MCP server names |
| `FileChanged` | literal filenames to watch | `.envrc\|.env` |
| `UserPromptExpansion` | command name | your skill or command names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires |

**MCP tool naming:** `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from a server. A plain `mcp__memory` matches nothing (exact string, no tool has that exact name).

### The `if` field (per-handler filtering)

Requires Claude Code v2.1.85+. Uses permission rule syntax to filter by tool name and arguments together. Only valid on tool events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`. On other events a hook with `if` set never runs.

```json
{
  "type": "command",
  "if": "Bash(git *)",
  "command": "./.claude/hooks/check-git-policy.sh"
}
```

For compound commands like `npm test && git push`, Claude Code evaluates each subcommand and fires if any matches.

### Hook handler fields

#### Common fields (all types)

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax filter (tool events only) |
| `timeout` | No | Seconds before canceling. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs once per session then removed. Only honored in skill frontmatter |

#### Command hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | Shell command to execute |
| `async` | No | If `true`, runs in background without blocking |
| `asyncRewake` | No | If `true`, runs in background and wakes Claude on exit code 2. Implies `async` |
| `shell` | No | `"bash"` (default) or `"powershell"` |

#### HTTP hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `url` | Yes | URL to POST event data to |
| `headers` | No | Additional HTTP headers; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | No | Env var names allowed to be interpolated into headers |

HTTP hooks POST the same JSON as command hooks receive on stdin. Non-2xx responses, timeouts, and connection failures are non-blocking errors (execution continues). To block, return a 2xx with appropriate JSON decision fields.

#### MCP tool hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `server` | Yes | Name of a configured, already-connected MCP server |
| `tool` | Yes | Name of the tool to call |
| `input` | No | Arguments; string values support `${path}` substitution from hook JSON input |

#### Prompt and agent hook fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `prompt` | Yes | Prompt text; use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | No | Model to use (defaults to a fast model) |

Prompt hooks return `{"ok": true}` or `{"ok": false, "reason": "..."}`. Agent hooks spawn a subagent with tool access (up to 50 tool-use turns).

### Hook input (stdin / POST body)

Common fields every event receives:

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook was invoked |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | (subagent only) Unique identifier for the subagent |
| `agent_type` | (subagent only) Agent name |

`PreToolUse` example input:
```json
{
  "session_id": "abc123",
  "cwd": "/home/user/my-project",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "npm test" }
}
```

### Exit codes

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success. Claude Code parses stdout for JSON output |
| `2` | Blocking error. Stderr is fed back to Claude (or shown to user for non-blockable events) |
| Other | Non-blocking error. Transcript shows hook error notice; execution continues |

Exit code 2 behavior: only blockable events are actually blocked. For non-blockable events (e.g. `SessionStart`, `Notification`, `PostToolUse`), exit 2 shows stderr to the user and execution continues anyway.

**Important:** `WorktreeCreate` blocks on any non-zero exit code, not just 2.

### JSON output

Exit 0 + JSON stdout = structured control. Do not mix with exit 2 (JSON is ignored on exit 2).

Universal JSON fields:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` (not shown to Claude) |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | none | Warning message shown to the user |

Context injection field (inside `hookSpecificOutput`):

| Field | Description |
| :--- | :--- |
| `additionalContext` | String injected into Claude's context window at the point the hook fired |

Context injection capped at 10,000 characters. Exceeding the limit saves to a file and passes Claude a path + preview.

### Decision control by event

| Events | Decision pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | Exit 2 blocks with stderr feedback |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), optional `updatedPermissions` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells model it may retry |
| `WorktreeCreate` | Path return | Command hook prints worktree path on stdout; HTTP hook returns `hookSpecificOutput.worktreePath` |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` (form field values) |
| `ElicitationResult` | `hookSpecificOutput` | `action`, `content` (override response) |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only (logging, cleanup) |

`PreToolUse` permission decision values:
- `"allow"` — skip interactive prompt (deny/ask rules in settings still apply)
- `"deny"` — cancel tool call and send reason to Claude
- `"ask"` — show permission prompt to user as normal
- `"defer"` — non-interactive mode only; exit and preserve tool call for Agent SDK wrapper

### Environment variables for hook scripts

| Variable | Description |
| :--- | :--- |
| `CLAUDE_PROJECT_DIR` | Project root. Use with quotes: `"$CLAUDE_PROJECT_DIR"` |
| `CLAUDE_ENV_FILE` | File path for persisting env vars to subsequent Bash commands. Available for `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` |
| `CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments; unset in local CLI |
| `CLAUDE_PLUGIN_ROOT` | Plugin installation directory (for plugin hooks) |
| `CLAUDE_PLUGIN_DATA` | Plugin persistent data directory (survives updates) |

### Hooks in skills and agents

Define hooks in YAML frontmatter (scoped to component lifetime):

```yaml
---
name: secure-operations
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

For subagents, `Stop` hooks are automatically converted to `SubagentStop`.

### Hooks and permission modes

- `PreToolUse` hooks fire before any permission-mode check
- A hook returning `permissionDecision: "deny"` blocks even in `bypassPermissions` mode
- A hook returning `"allow"` does not override deny rules from settings
- Hooks can tighten restrictions but not loosen them past what permission rules allow

### Stop hook infinite loop prevention

Check `stop_hook_active` in input to avoid loops:

```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

### JSON validation failed

Shell profile `echo` statements get prepended to hook stdout and break JSON parsing. Fix:

```bash
# In ~/.zshrc or ~/.bashrc
if [[ $- == *i* ]]; then
  echo "Shell ready"
fi
```

### Debug techniques

- `/hooks` — browse all configured hooks (read-only, shows source file and details)
- `Ctrl+O` — transcript view showing one-line hook summaries
- `claude --debug-file /tmp/claude.log` — write full execution details to a known path
- `/debug` — enable logging mid-session and find log path

### Common troubleshooting

| Issue | Check |
| :--- | :--- |
| Hook not firing | `/hooks` confirms it's there; matcher is case-sensitive; `PermissionRequest` doesn't fire in `-p` mode |
| Hook error in transcript | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./my-hook.sh` |
| Script not running at all | `chmod +x ./my-hook.sh` |
| Command not found | Use absolute paths or `$CLAUDE_PROJECT_DIR` |
| `/hooks` shows nothing | Validate JSON (no trailing commas or comments); check file location |

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide, common automation patterns (notifications, formatting, file protection, context injection, environment reloading, permission auto-approval), hook types overview, prompt-based hooks, agent-based hooks, HTTP hooks, limitations, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete technical reference: all event schemas, configuration format, matcher patterns, `if` field, all hook handler types, common input fields, exit codes, JSON output fields, `additionalContext`, decision control tables, per-event decision patterns, all individual event schemas and decision control details, async hooks, security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
