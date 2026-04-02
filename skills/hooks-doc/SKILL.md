---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- lifecycle events, configuration schema, hook types (command, HTTP, prompt, agent), JSON input/output formats, exit codes, async hooks, matcher patterns, decision control, environment variables, and practical examples. Covers all 25 hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PermissionDenied, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook locations (user, project, local, managed, plugin, skill/agent frontmatter), matcher patterns per event, hook handler fields (type, if, timeout, statusMessage, once, command, async, shell, url, headers, allowedEnvVars, prompt, model), PreToolUse decision control (allow/deny/ask/defer, updatedInput, additionalContext), PermissionRequest decision control (behavior, updatedInput, updatedPermissions, message, interrupt), permission update entries (addRules, replaceRules, removeRules, setMode, addDirectories, removeDirectories), PostToolUse decision control (block, additionalContext, updatedMCPToolOutput), Stop/SubagentStop decision control (block with reason), exit code behavior per event, JSON output fields (continue, stopReason, suppressOutput, systemMessage), CLAUDE_ENV_FILE for environment persistence, async hooks, prompt-based hooks (ok/reason response), agent-based hooks (multi-turn verification), HTTP hooks (POST with response handling), security considerations, Windows PowerShell support, disableAllHooks, allowManagedHooksOnly, /hooks menu, and common troubleshooting patterns. Load when discussing hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, SessionStart hooks, hook configuration, hook matchers, hook input/output, async hooks, prompt hooks, agent hooks, HTTP hooks, CLAUDE_ENV_FILE, hook decision control, permissionDecision, updatedInput, updatedPermissions, disableAllHooks, /hooks command, hook troubleshooting, or any hooks-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- user-defined commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? | Matcher filters |
|:------|:-------------|:-----------|:----------------|
| `SessionStart` | Session begins/resumes | No | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | User submits prompt | Yes | No matcher support |
| `PreToolUse` | Before tool executes | Yes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `PermissionRequest` | Permission dialog appears | Yes | Tool name |
| `PermissionDenied` | Auto mode denies tool | No | Tool name |
| `PostToolUse` | After tool succeeds | No | Tool name |
| `PostToolUseFailure` | After tool fails | No | Tool name |
| `Notification` | Notification sent | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type (`Bash`, `Explore`, `Plan`, custom) |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `TaskCreated` | Task being created | Yes | No matcher support |
| `TaskCompleted` | Task being completed | Yes | No matcher support |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `StopFailure` | Turn ends from API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Teammate about to idle | Yes | No matcher support |
| `InstructionsLoaded` | CLAUDE.md/rules loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | Config file changes | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | No | No matcher support |
| `FileChanged` | Watched file changes | No | Filename basename (`.envrc`, `.env`) |
| `WorktreeCreate` | Worktree being created | Yes | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before compaction | No | `manual`, `auto` |
| `PostCompact` | After compaction | No | `manual`, `auto` |
| `Elicitation` | MCP requests user input | Yes | MCP server name |
| `ElicitationResult` | After user responds to elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default Timeout |
|:-----|:-----------|:----------------|
| `command` | Run a shell command (stdin JSON, exit code + stdout) | 600s |
| `http` | POST JSON to a URL, response body for results | 600s |
| `prompt` | Single-turn LLM evaluation (ok/reason response) | 30s |
| `agent` | Multi-turn subagent with tool access (ok/reason response) | 60s |

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

### Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh",
            "if": "Bash(git *)",
            "timeout": 30,
            "async": false,
            "statusMessage": "Running check...",
            "once": false,
            "shell": "bash"
          }
        ]
      }
    ]
  }
}
```

### Common Hook Handler Fields

| Field | Required | Description |
|:------|:---------|:-----------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax filter (tool events only), e.g. `"Bash(git *)"` |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message |
| `once` | No | If `true`, runs only once per session (skills only) |

**Command-specific:** `command` (required), `async`, `shell` (`"bash"` or `"powershell"`)

**HTTP-specific:** `url` (required), `headers`, `allowedEnvVars`

**Prompt/Agent-specific:** `prompt` (required, use `$ARGUMENTS` for input JSON), `model`

### Exit Codes

| Code | Meaning | Effect |
|:-----|:--------|:-------|
| 0 | Success | Action proceeds; stdout parsed for JSON output |
| 2 | Blocking error | Action blocked; stderr fed to Claude as feedback |
| Other | Non-blocking error | Action proceeds; stderr shown in verbose mode |

### JSON Output Fields (stdout on exit 0)

| Field | Default | Description |
|:------|:--------|:-----------|
| `continue` | `true` | If `false`, Claude stops entirely |
| `stopReason` | -- | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from verbose output |
| `systemMessage` | -- | Warning message shown to user |
| `decision` | -- | `"block"` for PostToolUse, Stop, SubagentStop, UserPromptSubmit, ConfigChange |
| `reason` | -- | Explanation when `decision` is `"block"` |
| `additionalContext` | -- | String added to Claude's context |

### Common Input Fields (JSON on stdin)

| Field | Description |
|:------|:-----------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | (subagent only) Unique subagent identifier |
| `agent_type` | (agent/subagent only) Agent name |

### PreToolUse Decision Control

| Field | Description |
|:------|:-----------|
| `permissionDecision` | `"allow"` (skip prompt), `"deny"` (block), `"ask"` (show prompt), `"defer"` (headless only) |
| `permissionDecisionReason` | Reason string (shown to user for allow/ask, to Claude for deny) |
| `updatedInput` | Replaces tool input before execution |
| `additionalContext` | String added to Claude's context |

Precedence when multiple hooks return: `deny` > `defer` > `ask` > `allow`

### PermissionRequest Decision Control

| Field | Description |
|:------|:-----------|
| `decision.behavior` | `"allow"` or `"deny"` |
| `decision.updatedInput` | (allow only) Modify tool input |
| `decision.updatedPermissions` | (allow only) Array of permission update entries |
| `decision.message` | (deny only) Reason for Claude |
| `decision.interrupt` | (deny only) If `true`, stops Claude |

### Permission Update Entry Types

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules`, `behavior`, `destination` | Add permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replace rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Remove matching rules |
| `setMode` | `mode`, `destination` | Change permission mode |
| `addDirectories` | `directories`, `destination` | Add working directories |
| `removeDirectories` | `directories`, `destination` | Remove working directories |

Destinations: `session`, `localSettings`, `projectSettings`, `userSettings`

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_PROJECT_DIR` | Project root directory |
| `CLAUDE_PLUGIN_ROOT` | Plugin installation directory |
| `CLAUDE_PLUGIN_DATA` | Plugin persistent data directory |
| `CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart, CwdChanged, FileChanged only) |
| `CLAUDE_CODE_REMOTE` | `"true"` in remote web environments |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd timeout override (default 1500ms) |
| `CLAUDE_CODE_DEBUG_LOG_LEVEL` | Set to `verbose` for detailed hook matching logs |

### Prompt/Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

### HTTP Hook Response Handling

- **2xx empty body**: success, action proceeds
- **2xx plain text**: success, text added as context
- **2xx JSON body**: parsed using same JSON output schema
- **Non-2xx / connection failure / timeout**: non-blocking error, action continues

### Async Hooks

Set `"async": true` on command hooks to run in the background. Async hooks cannot block or return decisions. Output delivered on next conversation turn via `systemMessage` or `additionalContext`.

### Disabling Hooks

- `"disableAllHooks": true` in settings to disable all hooks
- `allowManagedHooksOnly` (enterprise) blocks user, project, and plugin hooks
- Managed `disableAllHooks` overrides user-level setting

### Supported Hook Types per Event

**All four types** (command, http, prompt, agent): PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Stop, SubagentStop, TaskCreated, TaskCompleted, UserPromptSubmit

**Command and HTTP only**: ConfigChange, CwdChanged, Elicitation, ElicitationResult, FileChanged, InstructionsLoaded, Notification, PermissionDenied, PostCompact, PreCompact, SessionEnd, StopFailure, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove

**Command only**: SessionStart

### Troubleshooting

| Problem | Solution |
|:--------|:--------|
| Hook not firing | Check `/hooks` menu; verify matcher is case-sensitive and matches tool name |
| JSON validation failed | Shell profile `echo` statements corrupt stdout; wrap in `if [[ $- == *i* ]]` |
| Stop hook runs forever | Check `stop_hook_active` field and exit 0 if `true` |
| PermissionRequest not firing in headless | Use `PreToolUse` instead (`-p` mode skips permission dialogs) |
| Debug hook execution | `claude --debug` or `Ctrl+O` for verbose mode |

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) -- Full event schemas, JSON input/output formats, decision control, async hooks, HTTP hooks, prompt/agent hooks, security considerations
- [Automate Workflows with Hooks](references/claude-code-hooks-guide.md) -- Getting started guide with practical examples for notifications, auto-formatting, file protection, context re-injection, and more

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Automate Workflows with Hooks: https://code.claude.com/docs/en/hooks-guide.md
