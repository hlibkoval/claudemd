---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, configuration schema, hook handler types (command, HTTP, MCP tool, prompt, agent), input/output formats, exit codes, decision control, async hooks, matchers, the `if` field, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### What Hooks Are

Hooks are user-defined handlers that run automatically at specific points in Claude Code's lifecycle. They provide deterministic control: certain actions always happen rather than relying on the LLM. Hooks can run shell commands, POST to HTTP endpoints, call MCP tools, or send prompts/agents to evaluate conditions.

### Hook Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<filter>",
        "hooks": [
          { "type": "command", "command": "<shell command>" }
        ]
      }
    ]
  }
}
```

Three levels of nesting: **hook event** (lifecycle point) → **matcher group** (filter) → **hook handler** (what runs).

### Hook Locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

Disable all hooks: `"disableAllHooks": true` in settings. Run `/hooks` to browse configured hooks (read-only).

### Hook Events

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | Prompt submitted, before Claude processes it | Yes |
| `UserPromptExpansion` | User-typed command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PermissionDenied` | Tool call denied by auto mode classifier | No (use `retry: true`) |
| `PostToolUse` | After a tool call succeeds | No (shows stderr to Claude) |
| `PostToolUseFailure` | After a tool call fails | No (shows stderr to Claude) |
| `PostToolBatch` | After a full batch of parallel tool calls, before next model call | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task being created via TaskCreate | Yes |
| `TaskCompleted` | Task being marked completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No (ignored) |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No |
| `ConfigChange` | Configuration file changes during session | Yes (except policy_settings) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero exit fails it) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Handler Types

| Type | Description | Blocking capable? |
| :--- | :--- | :--- |
| `command` | Shell command; stdin=JSON input, communicate via exit codes + stdout | Yes |
| `http` | POST JSON to URL; response body uses same JSON output format | Yes (via 2xx + JSON body) |
| `mcp_tool` | Call tool on connected MCP server | Yes (via text output = stdout) |
| `prompt` | Single-turn LLM evaluation; returns `{"ok": true/false}` | Yes |
| `agent` | Multi-turn subagent with tool access; returns `{"ok": true/false}` | Yes |

### Common Handler Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax filter, e.g. `"Bash(git *)"`. Only on tool events. Requires v2.1.85+ |
| `timeout` | no | Seconds before canceling. Default: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | Run once per session, then removed. Only honored in skill frontmatter |

Command-only fields: `command` (required), `async` (background), `asyncRewake` (background, wakes Claude on exit 2), `shell` (`"bash"` or `"powershell"`).

HTTP-only fields: `url` (required), `headers`, `allowedEnvVars` (for env var interpolation in headers).

MCP-tool-only fields: `server` (required), `tool` (required), `input` (args with `${path}` substitution).

Prompt/agent fields: `prompt` (required, use `$ARGUMENTS` for hook input JSON), `model`.

### Matchers

The `matcher` field filters when hooks fire:

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

What each event matches on:

| Event | Matches on | Example values |
| :--- | :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag | `init`, `maintenance` |
| `SessionEnd` | why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | compaction trigger | `manual`, `auto` |
| `ConfigChange` | config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | configured MCP server names |
| `FileChanged` | literal filenames (not regex) | `.envrc\|.env` |
| `UserPromptExpansion` | command name | skill/command names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires |

### Exit Codes (Command Hooks)

| Exit code | Effect |
| :--- | :--- |
| `0` | Allow. JSON on stdout is processed. For `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`: stdout added to Claude's context |
| `2` | Block (if event supports it). stderr fed to Claude as feedback. JSON is ignored |
| Other | Non-blocking error. Transcript shows `<hook name> hook error` + first stderr line. Execution continues |

**Critical:** Only exit 2 blocks. Exit 1 is non-blocking. Exception: `WorktreeCreate` — any non-zero exit fails creation.

### JSON Output (Exit 0 + stdout)

Universal fields:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops entirely. Takes precedence over event-specific decisions |
| `stopReason` | none | Message shown to user when `continue: false`. Not shown to Claude |
| `suppressOutput` | `false` | Omit stdout from debug log |
| `systemMessage` | none | Warning shown to user |

Context injection:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated — edit src/schema.ts instead."
  }
}
```

`additionalContext` is capped at 10,000 characters. Multiple hook values are all passed to Claude.

### Decision Control by Event

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `"decision": "block"`, `"reason": "..."` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr; `{"continue": false, "stopReason": "..."}` also stops |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision`: `allow`/`deny`/`ask`/`defer`; `permissionDecisionReason` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior`: `allow`/`deny`; optional `updatedPermissions`, `updatedInput` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` lets model retry |
| `WorktreeCreate` | path return | Command: print path on stdout; HTTP: `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action`: `accept`/`decline`/`cancel`; `content` for form values |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only; no decision control |

`PreToolUse` `permissionDecision` values:
- `"allow"`: skip interactive prompt (deny rules still apply)
- `"deny"`: cancel tool call, send reason to Claude
- `"ask"`: show permission prompt to user
- `"defer"`: in `-p` mode only — exit and preserve tool call for Agent SDK wrapper

### Path Variables for Hook Scripts

| Variable | Description |
| :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | Project root. Wrap in quotes for paths with spaces |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on updates) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (survives updates) |
| `$CLAUDE_ENV_FILE` | Script preamble run before each Bash command (for env var injection) |

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when `--agent` or inside subagent) |

### Hooks in Skill/Agent Frontmatter

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

For subagents, `Stop` hooks auto-convert to `SubagentStop`.

### Async Hooks

Set `"async": true` on a `command` hook to run in background without blocking Claude:

```json
{
  "type": "command",
  "command": "/path/to/run-tests.sh",
  "async": true,
  "timeout": 300
}
```

- Only `type: "command"` supports `async`
- Cannot block or control decisions — action already proceeded
- `systemMessage` / `additionalContext` from the async hook are delivered on the next turn
- `asyncRewake: true` (implies `async`) — wakes Claude immediately on exit 2

### Prompt-Based Hooks

```json
{
  "type": "prompt",
  "prompt": "Evaluate if tasks are complete: $ARGUMENTS. Return {\"ok\": true} or {\"ok\": false, \"reason\": \"...\"}."
}
```

Response: `{"ok": true}` to allow, `{"ok": false, "reason": "..."}` to block.

For `Stop`/`SubagentStop`: `ok: false` feeds `reason` back to Claude as next instruction.
For all other events: `ok: false` ends the turn and shows `reason` in chat (Claude does not see it).

Supported events (all five types): `PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `UserPromptExpansion`, `UserPromptSubmit`.

`SessionStart` and `Setup` support `command` and `mcp_tool` only.

### Agent-Based Hooks (Experimental)

```json
{
  "type": "agent",
  "prompt": "Verify all unit tests pass. Run the test suite. $ARGUMENTS",
  "timeout": 120
}
```

Up to 50 tool-use turns. Same response format as prompt hooks. Same supported events. Default timeout: 60s.

Use prompt hooks when hook input alone is enough; use agent hooks when you need to inspect actual files or test output.

### HTTP Hooks

```json
{
  "type": "http",
  "url": "http://localhost:8080/hooks/tool-use",
  "headers": { "Authorization": "Bearer $MY_TOKEN" },
  "allowedEnvVars": ["MY_TOKEN"]
}
```

HTTP response handling:
- 2xx empty body: allow
- 2xx plain text: allow, text added as context
- 2xx JSON body: parsed using same JSON output schema
- Non-2xx / timeout / connection failure: non-blocking error, execution continues

To block via HTTP: return 2xx with `{"decision": "block"}` or appropriate `hookSpecificOutput`. HTTP status codes alone cannot block.

### Persist Environment Variables (`CLAUDE_ENV_FILE`)

Write a bash script to `$CLAUDE_ENV_FILE` — Claude Code runs it as a preamble before each Bash command:

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "direnv export bash > \"$CLAUDE_ENV_FILE\"" }] }],
    "CwdChanged":   [{ "hooks": [{ "type": "command", "command": "direnv export bash > \"$CLAUDE_ENV_FILE\"" }] }]
  }
}
```

### Troubleshooting

**Stop hook infinite loop:** Check `stop_hook_active` field in stdin and exit 0 early if `true`.

**JSON validation failed:** Shell profile (`~/.zshrc`) may print text unconditionally — wrap in `if [[ $- == *i* ]]; then` to guard interactive-only output.

**Debug:** Start with `claude --debug-file /tmp/claude.log`, then `tail -f /tmp/claude.log`. Or run `/debug` mid-session. Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher details.

**Hook not firing:** Run `/hooks` to confirm registration. Matchers are case-sensitive. `PermissionRequest` hooks don't fire in `-p` mode — use `PreToolUse` instead.

**Security:** Hooks run with your full user permissions. Always validate and sanitize inputs, quote shell variables (`"$VAR"`), use absolute paths, block path traversal (`..`), skip sensitive files.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide with common use cases: notifications, auto-format, file protection, context re-injection after compaction, audit logging, direnv integration, auto-approve permission prompts, prompt/agent/HTTP hook examples, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, all hook handler field tables, decision control patterns, async hooks, security considerations, Windows PowerShell hooks, and debug techniques

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
