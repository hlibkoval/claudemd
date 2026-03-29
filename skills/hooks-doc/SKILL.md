---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- lifecycle events, configuration schema, JSON input/output formats, exit codes, matchers, decision control, async hooks, HTTP hooks, prompt hooks, agent hooks, MCP tool hooks, environment variables, and security considerations. Covers all 25 hook events (SessionStart with startup/resume/clear/compact matchers, UserPromptSubmit, PreToolUse with permissionDecision allow/deny/ask and updatedInput, PermissionRequest with decision behavior allow/deny and updatedPermissions with addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories, PostToolUse with decision block and updatedMCPToolOutput, PostToolUseFailure, Notification with permission_prompt/idle_prompt/auth_success/elicitation_dialog matchers, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop with stop_hook_active and decision block, StopFailure with rate_limit/authentication_failed/billing_error/invalid_request/server_error/max_output_tokens/unknown matchers, TeammateIdle, InstructionsLoaded with session_start/nested_traversal/path_glob_match/include/compact matchers, ConfigChange with user_settings/project_settings/local_settings/policy_settings/skills matchers, CwdChanged with CLAUDE_ENV_FILE, FileChanged with filename matchers and CLAUDE_ENV_FILE, WorktreeCreate with worktree path return, WorktreeRemove, PreCompact with manual/auto matchers, PostCompact with compact_summary, Elicitation with MCP server matchers and accept/decline/cancel actions, ElicitationResult, SessionEnd with clear/resume/logout/prompt_input_exit/bypass_permissions_disabled/other matchers). Hook handler types: command (shell with async support and powershell shell option), http (POST with headers and allowedEnvVars), prompt (single-turn LLM evaluation with ok/reason response), agent (multi-turn subagent verification with tool access). Common handler fields: type, if (permission rule syntax for tool events), timeout, statusMessage, once. Common input fields: session_id, transcript_path, cwd, permission_mode, hook_event_name, agent_id, agent_type. JSON output fields: continue, stopReason, suppressOutput, systemMessage. Hook locations: ~/.claude/settings.json (user), .claude/settings.json (project), .claude/settings.local.json (local), managed policy, plugin hooks/hooks.json, skill/agent frontmatter. Exit codes: 0 success, 2 blocking error, other non-blocking error. Script paths: $CLAUDE_PROJECT_DIR, ${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}. Matcher patterns are regex strings filtering by tool name, session source, notification type, agent type, config source, error type, load reason, MCP server name, or filename. /hooks menu for browsing configured hooks. disableAllHooks setting. allowManagedHooksOnly enterprise setting. CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS for SessionEnd timeout. CLAUDE_ENV_FILE for persisting environment variables. Load when discussing Claude Code hooks, hook events, hook configuration, hook lifecycle, PreToolUse hooks, PostToolUse hooks, Stop hooks, PermissionRequest hooks, SessionStart hooks, hook matchers, hook decision control, hook JSON input/output, exit code 2, async hooks, HTTP hooks, prompt hooks, agent hooks, hook types, CLAUDE_ENV_FILE, WorktreeCreate hooks, FileChanged hooks, CwdChanged hooks, ConfigChange hooks, Notification hooks, SubagentStart/Stop hooks, TaskCreated/TaskCompleted hooks, TeammateIdle hooks, Elicitation hooks, PreCompact/PostCompact hooks, InstructionsLoaded hooks, SessionEnd hooks, StopFailure hooks, hook security, /hooks command, disableAllHooks, hook locations, hook handler fields, permissionDecision, updatedPermissions, updatedInput, additionalContext, watchPaths, hook troubleshooting, hook debugging, MCP tool hooks, or any hooks-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- covering lifecycle events, configuration, JSON input/output, and all hook types.

## Quick Reference

### Hook Events Summary

| Event | When it fires | Can block? | Matcher filters |
|:------|:-------------|:-----------|:----------------|
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptSubmit` | User submits prompt, before processing | Yes | No matcher support |
| `PreToolUse` | Before tool call executes | Yes | Tool name: `Bash`, `Edit`, `Write`, `Read`, `mcp__.*` |
| `PermissionRequest` | Permission dialog appears | Yes | Tool name |
| `PostToolUse` | After tool call succeeds | No | Tool name |
| `PostToolUseFailure` | After tool call fails | No | Tool name |
| `Notification` | Notification sent | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type: `Bash`, `Explore`, `Plan`, custom names |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `TaskCreated` | Task being created | Yes | No matcher support |
| `TaskCompleted` | Task being completed | Yes | No matcher support |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `StopFailure` | Turn ends due to API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Teammate about to go idle | Yes | No matcher support |
| `ConfigChange` | Config file changes | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | No | No matcher support |
| `FileChanged` | Watched file changes on disk | No | Filename basename: `.envrc`, `.env`, etc. |
| `WorktreeCreate` | Worktree being created | Yes | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before compaction | No | `manual`, `auto` |
| `PostCompact` | After compaction completes | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Handler Types

| Type | Description | Key fields | Default timeout |
|:-----|:-----------|:-----------|:---------------|
| `command` | Shell command | `command`, `async`, `shell` | 600s |
| `http` | HTTP POST to URL | `url`, `headers`, `allowedEnvVars` | 600s |
| `prompt` | Single-turn LLM evaluation | `prompt`, `model` | 30s |
| `agent` | Multi-turn subagent verification | `prompt`, `model` | 60s |

**Common handler fields:** `type` (required), `if` (permission rule syntax, tool events only), `timeout`, `statusMessage`, `once` (skills only)

### Hook Type Support by Event

**All four types** (command, http, prompt, agent): `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `TaskCreated`, `TaskCompleted`

**Command and http only:** `ConfigChange`, `CwdChanged`, `Elicitation`, `ElicitationResult`, `FileChanged`, `InstructionsLoaded`, `Notification`, `PostCompact`, `PreCompact`, `SessionEnd`, `StopFailure`, `SubagentStart`, `TeammateIdle`, `WorktreeCreate`, `WorktreeRemove`

**Command only:** `SessionStart`

### Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex>",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "path/to/script.sh",
            "timeout": 30,
            "statusMessage": "Running check...",
            "async": true
          }
        ]
      }
    ]
  }
}
```

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

### Exit Codes

| Exit code | Meaning | Behavior |
|:----------|:--------|:---------|
| `0` | Success | Action proceeds. Stdout parsed for JSON output |
| `2` | Blocking error | Action blocked (if event supports it). Stderr fed to Claude |
| Other | Non-blocking error | Action proceeds. Stderr shown in verbose mode |

### Common Input Fields (JSON on stdin)

| Field | Description |
|:------|:-----------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside a subagent) |

### JSON Output Fields

| Field | Default | Description |
|:------|:--------|:-----------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown when `continue` is `false` |
| `suppressOutput` | `false` | Hides stdout from verbose mode |
| `systemMessage` | none | Warning shown to user |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr feedback |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `WorktreeCreate` | Path return | stdout (command) or `hookSpecificOutput.worktreePath` (http) |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| Prompt/agent hooks | `ok` response | `ok: true/false`, `reason` |

### Permission Update Entry Types (PermissionRequest)

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules`, `behavior`, `destination` | Adds permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules |
| `setMode` | `mode`, `destination` | Changes permission mode |
| `addDirectories` | `directories`, `destination` | Adds working directories |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

**Destinations:** `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`

### Environment Variables for Scripts

| Variable | Purpose |
|:---------|:--------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart, CwdChanged, FileChanged only) |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

### Key Settings

| Setting | Description |
|:--------|:-----------|
| `disableAllHooks` | Set `true` to disable all hooks. Managed hooks exempt unless set at managed level |
| `allowManagedHooksOnly` | Enterprise: blocks user, project, and plugin hooks |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd timeout (default 1500ms) |

### Async Hooks

Set `"async": true` on command hooks to run in background. Async hooks cannot block or return decisions. Output delivered on next conversation turn via `systemMessage` or `additionalContext`.

### HTTP Hooks

- 2xx empty body = success
- 2xx plain text = success, text added as context
- 2xx JSON body = parsed as standard JSON output
- Non-2xx or connection failure = non-blocking error
- Cannot block via status code alone; return JSON with decision fields

### Prompt/Agent Hook Response Format

```json
{
  "ok": true,
  "reason": "Required when ok is false"
}
```

### Troubleshooting

| Issue | Solution |
|:------|:---------|
| Hook not firing | Check `/hooks` menu, verify matcher case-sensitivity, confirm correct event type |
| Hook error in output | Test script manually: `echo '{"tool_name":"Bash"}' \| ./hook.sh` |
| JSON validation failed | Wrap shell profile `echo` statements in `[[ $- == *i* ]]` check |
| Stop hook runs forever | Check `stop_hook_active` field and exit early if `true` |
| `/hooks` shows no hooks | Verify JSON syntax, check settings file location |

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) -- Full hook lifecycle, configuration schema (hook events, matcher patterns with regex, hook handler fields for command/http/prompt/agent types, common fields type/if/timeout/statusMessage/once, command fields command/async/shell, HTTP fields url/headers/allowedEnvVars, prompt/agent fields prompt/model), hook locations (user/project/local/managed/plugin/skill-agent frontmatter), reference scripts by path ($CLAUDE_PROJECT_DIR/${CLAUDE_PLUGIN_ROOT}/${CLAUDE_PLUGIN_DATA}), hooks in skills and agents, /hooks menu, disable or remove hooks (disableAllHooks), hook input and output (common input fields session_id/transcript_path/cwd/permission_mode/hook_event_name/agent_id/agent_type, exit codes 0/2/other, HTTP response handling, JSON output fields continue/stopReason/suppressOutput/systemMessage, decision control patterns per event), all 25 hook event schemas with input fields and decision control (SessionStart with source/model/additionalContext/CLAUDE_ENV_FILE, InstructionsLoaded with file_path/memory_type/load_reason/globs/trigger_file_path/parent_file_path, UserPromptSubmit with prompt/decision block/additionalContext, PreToolUse with tool_name/tool_input per tool type Bash/Write/Edit/Read/Glob/Grep/WebFetch/WebSearch/Agent/AskUserQuestion and permissionDecision allow/deny/ask with updatedInput, PermissionRequest with permission_suggestions and decision behavior allow/deny with updatedInput/updatedPermissions/message/interrupt, permission update entries addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories with destinations, PostToolUse with tool_response and decision block/updatedMCPToolOutput, PostToolUseFailure with error/is_interrupt, Notification with message/title/notification_type, SubagentStart with agent_id/agent_type, SubagentStop with stop_hook_active/agent_transcript_path/last_assistant_message, TaskCreated with task_id/task_subject/task_description/teammate_name/team_name, TaskCompleted same fields, Stop with stop_hook_active/last_assistant_message and decision block, StopFailure with error/error_details/last_assistant_message, TeammateIdle with teammate_name/team_name, ConfigChange with source/file_path and decision block, CwdChanged with old_cwd/new_cwd and watchPaths output, FileChanged with file_path/event and watchPaths output, WorktreeCreate with name and worktreePath return, WorktreeRemove with worktree_path, PreCompact with trigger/custom_instructions, PostCompact with trigger/compact_summary, Elicitation with mcp_server_name/message/mode/url/requested_schema and action accept/decline/cancel, ElicitationResult with action/content override, SessionEnd with reason and CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS), prompt-based hooks (how they work, configuration with $ARGUMENTS, response schema ok/reason, event support matrix), agent-based hooks (multi-turn tool access, 50-turn limit, same response schema), async hooks (async true on command hooks, background execution, systemMessage/additionalContext delivery, limitations), security considerations (full user permissions, input validation, quote variables, block path traversal, absolute paths), Windows PowerShell (shell powershell option, pwsh.exe auto-detection), debug hooks (--debug flag, Ctrl+O verbose mode, debug output format)
- [Automate Workflows with Hooks (Guide)](references/claude-code-hooks-guide.md) -- Getting started walkthrough (first hook setup with Notification, /hooks menu verification, testing), common automation patterns (desktop notifications on macOS/Linux/Windows, auto-format with Prettier on PostToolUse Edit/Write, block edits to protected files with exit code 2, re-inject context after compaction with SessionStart compact matcher, audit configuration changes with ConfigChange, reload environment with CwdChanged and FileChanged using direnv and CLAUDE_ENV_FILE, auto-approve permission prompts with PermissionRequest hooks and updatedPermissions setMode), how hooks work (event table, hook types command/http/prompt/agent, reading input from stdin, hook output with exit codes and structured JSON, decision patterns per event, filter with matchers including tool name regex and MCP tool naming mcp__server__tool, if field with permission rule syntax Bash(git *) Edit(*.ts), configure hook location table), prompt-based hooks (LLM evaluation with ok/reason JSON, Stop hook example, model field), agent-based hooks (multi-turn verification with file reading, Stop hook test verification example), HTTP hooks (POST event data, headers with env var interpolation, allowedEnvVars, response format), limitations and troubleshooting (stdout/stderr/exit code communication, 10-minute default timeout, PostToolUse cannot undo, PermissionRequest not in non-interactive mode, Stop fires on every response not just task completion, hook not firing checklist, hook error debugging with manual pipe test, /hooks shows no hooks troubleshooting, stop hook infinite loop fix with stop_hook_active, JSON validation failed from shell profile echo, debug techniques with Ctrl+O and --debug)

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Automate Workflows with Hooks (Guide): https://code.claude.com/docs/en/hooks-guide.md
