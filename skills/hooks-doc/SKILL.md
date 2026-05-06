---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — all hook events, configuration schema, JSON input/output formats, exit codes, matcher patterns, hook types (command, HTTP, MCP tool, prompt, agent), decision control, async hooks, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | Prompt submitted, before Claude processes it | Yes |
| `UserPromptExpansion` | Slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PermissionDenied` | Tool call denied by auto mode classifier | No |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls resolves | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | A subagent is spawned | No |
| `SubagentStop` | A subagent finishes | Yes |
| `TaskCreated` | Task created via `TaskCreate` | Yes |
| `TaskCompleted` | Task marked as completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` loaded | No |
| `ConfigChange` | Configuration file changes during session | Yes |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | A watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Locations (Scope)

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No, local to your machine |
| `.claude/settings.json` | Single project | Yes, committable to repo |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes, bundled with plugin |
| Skill or agent frontmatter | While component is active | Yes, defined in component file |

### Hook Types

| Type | Description |
| :--- | :--- |
| `command` | Run a shell command; receives JSON on stdin, returns via exit codes/stdout |
| `http` | POST event JSON to an HTTP endpoint; returns results via response body |
| `mcp_tool` | Call a tool on an already-connected MCP server |
| `prompt` | Single-turn LLM evaluation (Haiku by default); returns `{"ok": true/false, "reason": "..."}` |
| `agent` | Multi-turn subagent with tool access; experimental; 60s default timeout, up to 50 turns |

### Common Hook Handler Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax to filter by tool name + args (e.g. `"Bash(git *)"`, `"Edit(*.ts)"`). Only for tool events |
| `timeout` | No | Seconds before canceling. Defaults: 600 command, 30 prompt, 60 agent |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, run once per session then remove (skill frontmatter only) |

#### Command Hook Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | Shell command to execute |
| `async` | No | Run in background without blocking |
| `asyncRewake` | No | Run in background; wake Claude on exit 2 with stderr as reminder |
| `shell` | No | `"bash"` (default) or `"powershell"` |

#### HTTP Hook Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `url` | Yes | URL to POST to |
| `headers` | No | Additional headers; values support `$VAR` interpolation for vars in `allowedEnvVars` |
| `allowedEnvVars` | No | Environment variable names that may be interpolated into header values |

#### MCP Tool Hook Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `server` | Yes | Name of a configured MCP server |
| `tool` | Yes | Tool name on that server |
| `input` | No | Arguments; string values support `${path}` substitution from hook JSON input |

#### Prompt and Agent Hook Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `prompt` | Yes | Prompt text; use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | No | Model to use (defaults to a fast model) |

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook invoked |
| `permission_mode` | Current mode: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions` |
| `hook_event_name` | Event that fired |
| `agent_id` | Subagent unique ID (present inside subagents) |
| `agent_type` | Agent name (present when using `--agent` or inside subagents) |

### Exit Code Behavior

| Exit Code | Meaning |
| :--- | :--- |
| `0` | Success. Claude Code parses stdout for JSON output. Stdout from `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart` is added to Claude's context |
| `2` | Blocking error. stderr is fed back as feedback. Effect depends on event (see table below) |
| Other | Non-blocking error. Execution continues. First line of stderr shown in transcript |

Note: `WorktreeCreate` is the exception — any non-zero exit code aborts worktree creation.

### JSON Output Fields (Universal)

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | none | Warning message shown to the user |

Context capped at 10,000 characters; larger output is saved to a file and replaced with a preview.

### Decision Control by Event

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | stderr message on exit 2; `stopReason` for `continue: false` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), optional `updatedPermissions` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells model it may retry |
| `WorktreeCreate` | Path return | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | No decision control; side effects only |

### Matcher Patterns by Event

| Event | What matcher filters | Example values |
| :--- | :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | How session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag that triggered setup | `init`, `maintenance` |
| `SessionEnd` | Why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | Agent type | `general-purpose`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | What triggered compaction | `manual`, `auto` |
| `ConfigChange` | Configuration source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | Error type | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | Load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | Your configured MCP server names |
| `UserPromptExpansion` | Command name | Skill or command names |
| `FileChanged` | Literal filenames (pipe-separated, not regex) | `.envrc\|.env` |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support | Always fires on every occurrence |

Matcher evaluation: `"*"`, `""`, or omitted = match all. Letters/digits/`_`/`|` only = exact string or pipe-separated list. Any other character = JavaScript regular expression.

### MCP Tool Naming Pattern

```
mcp__<server>__<tool>
```

Examples: `mcp__memory__create_entities`, `mcp__filesystem__read_file`

To match all tools from a server: `mcp__memory__.*` (the `.*` suffix is required).

### Path Reference Variables

| Variable | Points to |
| :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin's persistent data directory |

### Hooks in Skills and Agents (Frontmatter)

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
```

All events supported. In subagents, `Stop` is automatically converted to `SubagentStop`.

### Common Patterns

```json
// Auto-format after edits
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }] }
    ]
  }
}

// Block with exit 2 and stderr feedback
// exit 2 => Claude sees stderr as the reason

// Auto-approve ExitPlanMode
{
  "hooks": {
    "PermissionRequest": [
      { "matcher": "ExitPlanMode", "hooks": [{ "type": "command", "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\", \"decision\": {\"behavior\": \"allow\"}}}'" }] }
    ]
  }
}

// Re-inject context after compaction
{
  "hooks": {
    "SessionStart": [
      { "matcher": "compact", "hooks": [{ "type": "command", "command": "echo 'Key conventions: use Bun, not npm.'" }] }
    ]
  }
}

// Reload direnv on directory change
{
  "hooks": {
    "CwdChanged": [{ "hooks": [{ "type": "command", "command": "direnv export bash > \"$CLAUDE_ENV_FILE\"" }] }]
  }
}
```

### Prevent Stop Hook Infinite Loop

```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Allow Claude to stop
fi
# ... rest of hook logic
```

### Debugging

- `/hooks` menu: browse all configured hooks grouped by event (read-only)
- `Ctrl+O` in transcript: see one-line hook summaries
- `claude --debug-file /tmp/claude.log`: write full execution details to a log file
- `/debug` mid-session: enable logging and find the log path
- `disableAllHooks: true` in settings: disable all hooks at once

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide, common use cases, examples for notifications, auto-format, file protection, context injection, audit logging, environment reload, permission auto-approval, prompt/agent/HTTP hooks, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, configuration schema, JSON input/output formats, exit codes, async hooks, HTTP hooks, MCP tool hooks, prompt and agent hooks, and per-event decision control

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
