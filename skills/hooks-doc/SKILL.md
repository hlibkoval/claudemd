---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, configuration schema, hook types (command, HTTP, MCP tool, prompt, agent), matchers, the `if` field, JSON input/output, exit codes, decision control, async hooks, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that run automatically at specific points in Claude Code's lifecycle. They provide deterministic control that does not rely on the model choosing to act.

### Hook configuration structure

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

### Hook locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill or agent frontmatter | While component is active | Yes |

Set `"disableAllHooks": true` in settings to disable all hooks at once.

### Hook events

| Event | When it fires | Can block (exit 2)? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `UserPromptSubmit` | Prompt submitted, before Claude processes it | Yes |
| `UserPromptExpansion` | Slash command expands to prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes (denies) |
| `PermissionDenied` | Tool call denied by auto mode classifier | No |
| `PostToolUse` | After a tool call succeeds | No (shows stderr to Claude) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls | Yes (stops agentic loop) |
| `Stop` | When Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task created via `TaskCreate` | Yes (rolls back creation) |
| `TaskCompleted` | Task marked as completed | Yes |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No |
| `ConfigChange` | Configuration file changes during session | Yes (except policy_settings) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes (denies) |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SessionEnd` | Session terminates | No |

### Matcher patterns

The `matcher` field filters when hooks fire:

| Matcher value | Evaluated as |
| :--- | :--- |
| `""`, `"*"`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

What each event matches on:

| Event | Matcher filters |
| :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | Session source: `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | End reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart`, `SubagentStop` | Agent type: `Bash`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | Trigger: `manual`, `auto` |
| `ConfigChange` | Source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | Error type: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | Load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `FileChanged` | Literal filenames to watch, `\|`-separated |
| `UserPromptExpansion` | Command name |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support — always fires |

MCP tools follow the naming pattern `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from a server (the `.*` suffix is required for regex matching).

### The `if` field (v2.1.85+)

Use `if` on individual hook handlers to filter by tool name AND arguments together, beyond what `matcher` can do. Uses permission rule syntax:

```json
{ "type": "command", "if": "Bash(git *)", "command": "..." }
```

Only works on tool events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`. Compound Bash commands (`npm test && git push`) fire the hook if any subcommand matches.

### Hook handler types

| Type | Description |
| :--- | :--- |
| `command` | Run a shell command. Receives event JSON on stdin; communicates via exit codes, stdout, stderr |
| `http` | POST event JSON to a URL; response body uses same JSON format as command hooks |
| `mcp_tool` | Call a tool on an already-connected MCP server |
| `prompt` | Single-turn LLM evaluation; returns `{"ok": true/false, "reason": "..."}` |
| `agent` | Multi-turn subagent with tool access; same response format as prompt; experimental |

### Common hook handler fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax to filter further (tool events only) |
| `timeout` | No | Seconds before canceling. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | `true` runs once per session then removes itself (skill frontmatter only) |

### Command hook fields

| Field | Description |
| :--- | :--- |
| `command` | Shell command to execute |
| `async` | `true` runs in background without blocking |
| `asyncRewake` | `true` runs in background; wakes Claude on exit 2 |
| `shell` | `"bash"` (default) or `"powershell"` |

### HTTP hook fields

| Field | Description |
| :--- | :--- |
| `url` | URL to POST to |
| `headers` | Key-value pairs; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | Env var names allowed to be interpolated into headers |

### MCP tool hook fields

| Field | Description |
| :--- | :--- |
| `server` | Name of a connected MCP server |
| `tool` | Tool name on that server |
| `input` | Arguments; string values support `${path}` substitution from hook JSON input |

### Prompt / agent hook fields

| Field | Description |
| :--- | :--- |
| `prompt` | Prompt text. Use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | Model for evaluation (defaults to a fast model) |

### Exit codes

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success. Claude Code parses stdout for JSON output |
| `2` | Blocking error. Claude Code ignores stdout; feeds stderr to Claude as feedback |
| Any other | Non-blocking error. Transcript shows `<hook name> hook error`; execution continues |

**Important:** Only exit code 2 blocks most events. Exit code 1 is non-blocking. Exception: `WorktreeCreate` fails on any non-zero exit.

### Common input fields

Every hook receives these fields on stdin (or as HTTP POST body):

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when the hook fired |
| `permission_mode` | Current permission mode: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside a subagent) |

### JSON output (exit 0 only)

Print a JSON object to stdout for structured control:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | `true` omits stdout from debug log |
| `systemMessage` | none | Warning shown to the user |

### Decision control by event

| Events | Decision pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | Exit 2 blocks with stderr; JSON `{"continue": false}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision`: `allow`/`deny`/`ask`/`defer`; `permissionDecisionReason` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior`: `allow`/`deny`; optional `updatedPermissions` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` lets model retry the denied tool call |
| `WorktreeCreate` | Path return | Stdout = worktree path; HTTP: `hookSpecificOutput.worktreePath` |
| `Elicitation` | `hookSpecificOutput` | `action`: `accept`/`decline`/`cancel`; `content` for field values |
| `ElicitationResult` | `hookSpecificOutput` | `action`: `accept`/`decline`/`cancel`; `content` to override field values |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side-effects only |

### PreToolUse decision example

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep"
  }
}
```

`PreToolUse` can also return `updatedInput` to rewrite tool arguments before execution. Only one hook should modify the same tool's input (last writer wins since hooks run in parallel).

### PermissionRequest decision example

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedPermissions": [
        { "type": "setMode", "mode": "acceptEdits", "destination": "session" }
      ]
    }
  }
}
```

`allow` skips the interactive prompt but does not override deny rules from settings. `bypassPermissions` mode can only be set if the session was already launched with it available.

### Environment variable path references

| Variable | Points to |
| :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | Project root (wrap in quotes for paths with spaces) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

### Persist environment variables with `CLAUDE_ENV_FILE`

Write shell variable exports to `$CLAUDE_ENV_FILE` from a hook; Claude Code sources this file as a preamble before each Bash command:

```json
{
  "hooks": {
    "CwdChanged": [
      { "hooks": [{ "type": "command", "command": "direnv export bash > \"$CLAUDE_ENV_FILE\"" }] }
    ]
  }
}
```

### Stop hook infinite loop guard

Parse `stop_hook_active` from stdin and exit early if `true`:

```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

### Hooks in skill/agent frontmatter

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
```

For subagents, `Stop` hooks are automatically converted to `SubagentStop`.

### `/hooks` menu

Run `/hooks` in Claude Code to browse all configured hooks read-only. Shows event, matcher, type, source file, and command for each hook. To edit, modify the settings JSON directly or ask Claude.

### Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Hook not firing | Run `/hooks` to verify it appears; check matcher is case-sensitive; `PermissionRequest` hooks don't fire in `-p` non-interactive mode — use `PreToolUse` instead |
| Hook error in transcript | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./my-hook.sh` |
| Script not found | Use absolute paths or `$CLAUDE_PROJECT_DIR`; ensure script is executable: `chmod +x` |
| `/hooks` shows nothing | Verify JSON is valid (no trailing commas or comments); check file location |
| Stop hook loops forever | Guard with `stop_hook_active` check (see above) |
| JSON validation failed | Shell profile may echo on startup — guard with `if [[ $- == *i* ]]; then echo ...; fi` |
| Hook output capped | `additionalContext`, `systemMessage`, and plain stdout are capped at 10,000 chars; excess saved to file |

For full execution details, run `claude --debug-file /tmp/claude.log` and tail the log, or run `/debug` mid-session.

### Security notes

- `PreToolUse` hooks fire before any permission-mode check. A hook returning `deny` blocks even in `bypassPermissions` mode — hooks can tighten restrictions but not loosen them past what permission rules allow.
- HTTP hook header values support `$VAR` interpolation; only vars listed in `allowedEnvVars` are resolved.
- Use `allowManagedHooksOnly` in managed settings to block user, project, and plugin hooks organization-wide.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — getting started, common automation patterns (notifications, formatting, file protection, context re-injection, config auditing, env reloading, auto-approvals), how hooks work, prompt-based hooks, agent-based hooks, HTTP hooks, limitations, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, configuration schema, JSON input/output formats, exit code behavior per event, decision control, async hooks, HTTP hooks, MCP tool hooks, prompt/agent hooks, and every hook event's input/output specification

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
