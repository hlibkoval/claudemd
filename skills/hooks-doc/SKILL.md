---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook lifecycle events, configuration schema, matcher patterns, JSON input/output formats, exit codes, decision control per event, async/HTTP/MCP/prompt/agent hook types, common automation patterns, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over Claude Code's behavior.

### Hook configuration structure

Hooks are defined in JSON settings files under a top-level `"hooks"` key:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "prettier --write ..." }
        ]
      }
    ]
  }
}
```

Three levels of nesting: **hook event** (lifecycle point) → **matcher group** (filter) → **hook handler** (the command/URL/prompt that runs).

### Hook event lifecycle

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | With `--init-only` or `--init`/`--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | When user submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | When a slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes |
| `PermissionDenied` | When a tool call is denied by auto mode classifier | No |
| `PostToolUse` | After a tool call succeeds | No (stderr shown to Claude) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls, before next model call | Yes |
| `Notification` | When Claude Code sends a notification | No |
| `SubagentStart` | When a subagent is spawned | No |
| `SubagentStop` | When a subagent finishes | Yes |
| `TaskCreated` | When a task is being created via `TaskCreate` | Yes |
| `TaskCompleted` | When a task is being marked as completed | Yes |
| `Stop` | When Claude finishes responding | Yes |
| `StopFailure` | When the turn ends due to an API error | No |
| `TeammateIdle` | When an agent team teammate is about to go idle | Yes |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded | No |
| `ConfigChange` | When a configuration file changes during a session | Yes (except `policy_settings`) |
| `CwdChanged` | When the working directory changes | No |
| `FileChanged` | When a watched file changes on disk | No |
| `WorktreeCreate` | When a worktree is being created (replaces default git behavior) | Yes |
| `WorktreeRemove` | When a worktree is being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | When an MCP server requests user input during a tool call | Yes |
| `ElicitationResult` | After a user responds to an MCP elicitation | Yes |
| `SessionEnd` | When a session terminates | No |

### Hook configuration locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No, local to your machine |
| `.claude/settings.json` | Single project | Yes, can be committed to the repo |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes, bundled with the plugin |
| Skill or agent frontmatter | While the skill or agent is active | Yes, defined in the component file |

Run `/hooks` in Claude Code to browse all configured hooks. Set `"disableAllHooks": true` to temporarily disable all hooks.

### Hook handler types

| Type | Description |
| :--- | :--- |
| `command` | Run a shell command. Receives event JSON on stdin. |
| `http` | POST event data to a URL. Returns results via HTTP response body. |
| `mcp_tool` | Call a tool on an already-connected MCP server. |
| `prompt` | Single-turn LLM evaluation (Haiku by default). Returns `{"ok": true/false, "reason": "..."}`. |
| `agent` | Multi-turn subagent that can use tools. Experimental. |

### Common handler fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax to filter (e.g. `"Bash(git *)"`, `"Edit(*.ts)"`). Tool events only. |
| `timeout` | No | Seconds before canceling. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs once per session then is removed. Only honored in skill frontmatter. |

Additional fields for `command` hooks: `command` (required), `async`, `asyncRewake`, `shell` (`"bash"` or `"powershell"`).

Additional fields for `http` hooks: `url` (required), `headers`, `allowedEnvVars`.

Additional fields for `mcp_tool` hooks: `server` (required), `tool` (required), `input` (with `${path}` substitution).

Additional fields for `prompt`/`agent` hooks: `prompt` (required, use `$ARGUMENTS` as placeholder), `model`.

### Matcher patterns

The `matcher` field filters when hooks fire:

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or pipe-separated list |
| Contains any other character | JavaScript regular expression |

What each event type matches on:

| Event | What the matcher filters | Example values |
| :--- | :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how the session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | which CLI flag triggered setup | `init`, `maintenance` |
| `SessionEnd` | why the session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | what triggered compaction | `manual`, `auto` |
| `ConfigChange` | configuration source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | your configured MCP server names |
| `FileChanged` | literal filenames to watch | `.envrc\|.env` |
| `UserPromptExpansion` | command name | your skill or command names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires on every occurrence |

MCP tool naming convention: `mcp__<server>__<tool>`. Use regex matchers like `mcp__memory__.*` for all tools from a server.

### Exit codes

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success. Claude Code parses stdout for JSON output fields. For `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart`, stdout is added as context for Claude. |
| `2` | Blocking error. Stderr text is fed back to Claude or shown to the user. Effect depends on the event. |
| Other non-zero | Non-blocking error. Execution continues. Transcript shows a hook error notice with first line of stderr. |

**Warning**: Only exit code 2 blocks actions. Exit code 1 is treated as non-blocking. For `WorktreeCreate`, any non-zero exit code aborts creation.

### JSON output fields

Exit 0 and print JSON to stdout for finer-grained control:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops processing entirely. Takes precedence over event-specific decisions. |
| `stopReason` | none | Message shown to user when `continue` is `false`. Not shown to Claude. |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log. |
| `systemMessage` | none | Warning message shown to the user. |

`additionalContext` (inside `hookSpecificOutput`) passes a string into Claude's context window. Capped at 10,000 characters.

### Decision control per event

| Events | Decision pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | Exit 2 blocks with stderr; JSON `{"continue": false}` stops the session |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`/`defer`), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells the model it may retry the denied tool call |
| `WorktreeCreate` | path return | Command hook prints path on stdout |
| `Elicitation` | `hookSpecificOutput` | `action` (`accept`/`decline`/`cancel`), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action`, `content` (overrides user response) |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | No decision control. Used for side effects. |

**PreToolUse precedence** when multiple hooks return different decisions: `deny` > `defer` > `ask` > `allow`.

**Permission rules still apply**: a hook returning `permissionDecision: "allow"` skips the interactive prompt but does not override deny rules from settings.

### Common input fields (all events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory when the hook is invoked |
| `permission_mode` | Current permission mode (not all events include this) |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when running inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside a subagent) |

### Path reference variables

| Variable | Description |
| :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | The project root. Wrap in quotes to handle paths with spaces. |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory. Changes on each plugin update. |
| `${CLAUDE_PLUGIN_DATA}` | Plugin's persistent data directory. Survives plugin updates. |
| `$CLAUDE_ENV_FILE` | File path for persisting environment variables to subsequent Bash commands. Available in `SessionStart`, `Setup`, `CwdChanged`, `FileChanged`. |

### Common automation patterns

**Auto-format after edits** (PostToolUse with Edit|Write matcher):
```json
{ "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }] }
```

**Block edits to protected files** (PreToolUse, exit 2):
```bash
FILE_PATH=$(cat | jq -r '.tool_input.file_path // empty')
[[ "$FILE_PATH" == *".env"* ]] && echo "Blocked" >&2 && exit 2
```

**Re-inject context after compaction** (SessionStart with `compact` matcher):
```json
{ "matcher": "compact", "hooks": [{ "type": "command", "command": "echo 'Reminder: use Bun, not npm.'" }] }
```

**Desktop notification** (Notification event):
```json
{ "type": "command", "command": "osascript -e 'display notification \"Claude needs attention\" with title \"Claude Code\"'" }
```

**Auto-approve a specific tool** (PermissionRequest with ExitPlanMode matcher):
```json
{ "type": "command", "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\", \"decision\": {\"behavior\": \"allow\"}}}'" }
```

**Reload direnv on directory change** (CwdChanged):
```json
{ "type": "command", "command": "direnv export bash > \"$CLAUDE_ENV_FILE\"" }
```

**Prevent infinite Stop hook loop**: check `stop_hook_active` field in input; exit 0 immediately if `true`.

### Hooks in skills and agents

Define hooks in YAML frontmatter to scope them to a component's lifetime:

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

### Troubleshooting

| Problem | Check |
| :--- | :--- |
| Hook not firing | Run `/hooks` to confirm it appears; check matcher is case-sensitive; verify you're using the right event type |
| "hook error" in transcript | Script exited non-zero unexpectedly; test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./my-hook.sh` |
| `/hooks` shows no hooks | Validate JSON (no trailing commas/comments); confirm file is at correct location; restart session if file watcher missed it |
| Stop hook runs forever | Check `stop_hook_active` field in input; exit 0 if `true` |
| JSON validation failed | Shell profile has unconditional `echo` — wrap in `if [[ $- == *i* ]]; then ... fi` |
| `command not found` | Use absolute paths or `$CLAUDE_PROJECT_DIR` |
| Hook async behavior | Set `"async": true` on command hooks to run in background without blocking. Use `"asyncRewake": true` to also wake Claude on exit code 2. |

**Debug**: Run `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`. Or use `/debug` mid-session. Toggle transcript view with `Ctrl+O`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks guide](references/claude-code-hooks-guide.md) — quickstart, common automation patterns (notifications, formatting, file protection, context injection, auto-approval), how hooks work, prompt-based hooks, agent-based hooks, HTTP hooks, limitations, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete technical reference: hook lifecycle diagram, full configuration schema, all handler type fields, common input fields, exit code behavior per event, JSON output format, decision control per event, every hook event's input schema and decision options, async hooks, security considerations

## Sources

- Hooks guide: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
