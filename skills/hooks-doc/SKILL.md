---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- lifecycle events that run shell commands, HTTP endpoints, LLM prompts, or subagents at key points during a session. Covers all hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, prompt, agent), configuration schema (matcher groups, hook handler fields, timeout, async, once, shell, statusMessage), JSON input/output format (common input fields session_id/cwd/transcript_path/permission_mode/hook_event_name, exit code semantics 0/2/other, structured JSON output with continue/stopReason/suppressOutput/systemMessage), decision control patterns (top-level decision/reason for Stop/PostToolUse/UserPromptSubmit/ConfigChange, hookSpecificOutput with permissionDecision for PreToolUse, hookSpecificOutput with decision.behavior for PermissionRequest, updatedInput, updatedPermissions with addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories and destination session/localSettings/projectSettings/userSettings), matcher patterns per event (tool name for Pre/PostToolUse, source for SessionStart, reason for SessionEnd, notification_type for Notification, agent type for SubagentStart/Stop, config source for ConfigChange, filename for FileChanged, error type for StopFailure, load_reason for InstructionsLoaded, MCP server name for Elicitation/ElicitationResult, compaction trigger for PreCompact/PostCompact), hook locations (user settings, project settings, local settings, managed policy, plugin hooks.json, skill/agent frontmatter), environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, CLAUDE_ENV_FILE, CLAUDE_CODE_REMOTE), async hooks, prompt-based hooks (type prompt with ok/reason response), agent-based hooks (type agent with tool access and 50-turn limit), HTTP hooks (POST with headers/allowedEnvVars, response body JSON), CLAUDE_ENV_FILE for persisting environment variables in SessionStart/CwdChanged/FileChanged, MCP tool matching (mcp__server__tool pattern), permission update entries, Windows PowerShell support, security considerations, debug techniques (claude --debug, Ctrl+O verbose mode, /hooks menu), common use cases (desktop notifications, auto-format after edits, block protected files, re-inject context after compaction, audit config changes, direnv integration, auto-approve permission prompts), and troubleshooting (hook not firing, hook error, /hooks shows nothing, Stop hook infinite loop, JSON validation failed from shell profile echo). Load when discussing Claude Code hooks, hook events, lifecycle hooks, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, SessionStart, SessionEnd, hook configuration, hook matchers, hook input/output, exit codes for hooks, async hooks, prompt hooks, agent hooks, HTTP hooks, CLAUDE_ENV_FILE, permission hooks, auto-approve, auto-format, direnv integration, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, TeammateIdle, TaskCreated, TaskCompleted, StopFailure, SubagentStart, SubagentStop, InstructionsLoaded, PreCompact, PostCompact, Elicitation, ElicitationResult, hook troubleshooting, /hooks menu, hook security, updatedPermissions, permissionDecision, or any hooks-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- shell commands, HTTP endpoints, LLM prompts, or subagents that execute automatically at specific points in Claude Code's lifecycle.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? |
|:------|:-------------|:-----------|
| `SessionStart` | Session begins or resumes | No |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `UserPromptSubmit` | User submits a prompt, before processing | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PostToolUse` | After a tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | No (feedback only) |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task created via TaskCreate | Yes |
| `TaskCompleted` | Task marked as completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `ConfigChange` | Configuration file changes during session | Yes (except policy_settings) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero fails it) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Types

| Type | Description | Default timeout |
|:-----|:------------|:----------------|
| `command` | Run a shell command (stdin JSON, stdout/stderr/exit code) | 600s |
| `http` | POST event data to a URL, response body for results | 600s |
| `prompt` | Single-turn LLM evaluation, returns `{ok, reason}` | 30s |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob), returns `{ok, reason}` | 60s |

Not all events support all types. `SessionStart` supports only `command`. Events like `ConfigChange`, `CwdChanged`, `FileChanged`, `Notification`, `SubagentStart`, `TeammateIdle`, `StopFailure`, `PreCompact`, `PostCompact`, `SessionEnd`, `InstructionsLoaded`, `Elicitation`, `ElicitationResult`, `WorktreeCreate`, `WorktreeRemove` support `command` and `http` only (no `prompt`/`agent`).

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
            "timeout": 600,
            "async": false,
            "shell": "bash",
            "statusMessage": "Running hook...",
            "once": false
          }
        ]
      }
    ]
  }
}
```

### Hook Handler Fields

**Common fields (all types):**

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `timeout` | no | Seconds before canceling |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs only once per session then removed (skills only) |

**Command-specific:** `command` (required), `async` (background execution), `shell` (`"bash"` or `"powershell"`)

**HTTP-specific:** `url` (required), `headers` (key-value pairs with `$VAR` interpolation), `allowedEnvVars` (list of env vars allowed in headers)

**Prompt/Agent-specific:** `prompt` (required, use `$ARGUMENTS` for hook input JSON), `model` (defaults to fast model)

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (committable) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

### Matcher Patterns by Event

| Event | Matches on | Example values |
|:------|:-----------|:---------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | session source | `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | exit reason | `clear`, `resume`, `logout`, `prompt_input_exit`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart`, `SubagentStop` | agent type | `Bash`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | compaction trigger | `manual`, `auto` |
| `ConfigChange` | config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `FileChanged` | filename (basename) | `.envrc`, `.env` |
| `Elicitation`, `ElicitationResult` | MCP server name | your MCP server names |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher | always fires |

### Common Input Fields (all events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | Current permission mode (not all events) |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent ID (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside subagent) |

### Exit Code Semantics

| Exit code | Meaning |
|:----------|:--------|
| **0** | Success -- action proceeds. Stdout parsed for JSON output. For `UserPromptSubmit`/`SessionStart`, stdout added as context |
| **2** | Blocking error -- action blocked. Stderr fed back to Claude as feedback |
| **Other** | Non-blocking error -- action proceeds. Stderr logged in verbose mode only |

### Decision Control Patterns

**Top-level `decision` (UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange):**

```json
{ "decision": "block", "reason": "explanation" }
```

**PreToolUse -- `hookSpecificOutput` with `permissionDecision`:**

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "reason",
    "updatedInput": { "field": "new value" },
    "additionalContext": "extra context for Claude"
  }
}
```

`"allow"` skips the permission prompt but deny/ask rules still apply. `"deny"` blocks the tool call. `"ask"` shows the prompt to the user.

**PermissionRequest -- `hookSpecificOutput` with `decision.behavior`:**

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow|deny",
      "updatedInput": { "command": "modified command" },
      "updatedPermissions": [
        { "type": "addRules", "rules": [{"toolName": "Bash", "ruleContent": "npm test"}], "behavior": "allow", "destination": "localSettings" }
      ],
      "message": "deny reason (deny only)",
      "interrupt": false
    }
  }
}
```

**Permission update entry types:** `addRules`, `replaceRules`, `removeRules`, `setMode`, `addDirectories`, `removeDirectories`

**Destinations:** `session`, `localSettings`, `projectSettings`, `userSettings`

**TaskCreated/TaskCompleted/TeammateIdle:** exit code 2 blocks with stderr feedback, or JSON `{"continue": false, "stopReason": "..."}` stops entirely.

**Prompt/Agent hooks response:** `{"ok": true}` to allow, `{"ok": false, "reason": "..."}` to block.

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely (overrides event-specific decisions) |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from verbose mode |
| `systemMessage` | none | Warning message shown to user |

### Environment Variables for Hooks

| Variable | Description |
|:---------|:------------|
| `CLAUDE_PROJECT_DIR` | Project root directory |
| `CLAUDE_PLUGIN_ROOT` | Plugin installation directory |
| `CLAUDE_PLUGIN_DATA` | Plugin persistent data directory |
| `CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart, CwdChanged, FileChanged only) |
| `CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

Write `export VAR=value` lines to `CLAUDE_ENV_FILE` (append with `>>`) to persist environment variables for subsequent Bash commands in the session.

### MCP Tool Matching

MCP tools use the naming pattern `mcp__<server>__<tool>`. Match with regex:
- `mcp__memory__.*` -- all tools from the memory server
- `mcp__.*__write.*` -- any write tool from any server

### Async Hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately. Results delivered on next conversation turn via `systemMessage` or `additionalContext`. Async hooks cannot block actions or return decisions. Only `type: "command"` supports async.

### Hooks in Skills and Agents

Define hooks in YAML frontmatter. All events supported. For subagents, `Stop` hooks are auto-converted to `SubagentStop`. Hooks are scoped to the component's lifetime.

### Debugging

- `/hooks` menu: browse all configured hooks (read-only)
- `claude --debug`: full execution details
- `Ctrl+O`: toggle verbose mode in transcript
- `disableAllHooks: true` in settings to temporarily disable all hooks

### Common Troubleshooting

| Problem | Fix |
|:--------|:----|
| Hook not firing | Check `/hooks` menu, verify matcher case-sensitivity, confirm correct event type |
| Hook error in output | Test script manually: `echo '{"tool_name":"Bash"}' \| ./hook.sh && echo $?` |
| `/hooks` shows nothing | Validate JSON syntax, check file location, restart session |
| Stop hook infinite loop | Check `stop_hook_active` field and exit early if `true` |
| JSON validation failed | Wrap `echo` in shell profile with `if [[ $- == *i* ]]; then ... fi` |

### Security

Command hooks run with your full user permissions. Best practices: validate inputs, quote shell variables, block path traversal, use absolute paths with `$CLAUDE_PROJECT_DIR`, skip sensitive files.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) -- Full event schemas, JSON input/output format, configuration schema (matcher groups, hook handler fields for command/http/prompt/agent types), decision control patterns per event (PreToolUse permissionDecision allow/deny/ask with updatedInput and additionalContext, PermissionRequest decision.behavior with updatedPermissions and permission update entries addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories, top-level decision block for Stop/PostToolUse/UserPromptSubmit/ConfigChange), exit code semantics (0 success, 2 blocking, other non-blocking), common input fields (session_id, cwd, transcript_path, permission_mode, agent_id, agent_type), per-event input schemas and output fields (SessionStart with source/model/additionalContext/CLAUDE_ENV_FILE, UserPromptSubmit with prompt/additionalContext, PreToolUse with tool_name/tool_input per tool type, PostToolUse with tool_response/updatedMCPToolOutput, PostToolUseFailure with error/is_interrupt, Notification with message/notification_type, SubagentStart/Stop with agent_id/agent_type, TaskCreated/TaskCompleted with task_id/task_subject/teammate_name/team_name, Stop with stop_hook_active/last_assistant_message, StopFailure with error/error_details, TeammateIdle with teammate_name/team_name, ConfigChange with source/file_path, CwdChanged with old_cwd/new_cwd/watchPaths, FileChanged with file_path/event/watchPaths, WorktreeCreate with name and path return, WorktreeRemove with worktree_path, PreCompact with trigger/custom_instructions, PostCompact with trigger/compact_summary, Elicitation with mcp_server_name/message/mode/requested_schema/action/content, ElicitationResult with action/content override, InstructionsLoaded with file_path/memory_type/load_reason/globs/trigger_file_path/parent_file_path, SessionEnd with reason and 1.5s default timeout), hook locations (user/project/local settings, managed policy, plugin hooks.json, skill/agent frontmatter), matcher patterns per event, MCP tool matching (mcp__server__tool pattern), async hooks (background execution, systemMessage delivery), prompt-based hooks (type prompt with ok/reason response schema, $ARGUMENTS placeholder), agent-based hooks (type agent with 50-turn tool access), HTTP hooks (POST with headers/allowedEnvVars, response body JSON, non-2xx non-blocking), hooks in skills and agents (frontmatter, Stop to SubagentStop conversion, once field), reference script paths (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA), Windows PowerShell support (shell powershell field), security considerations, debug techniques (claude --debug, Ctrl+O, /hooks menu)
- [Hooks Guide](references/claude-code-hooks-guide.md) -- Practical guide with setup walkthrough, common use cases (desktop notifications on macOS/Linux/Windows, auto-format with Prettier on PostToolUse Edit/Write, block edits to protected files with PreToolUse exit code 2, re-inject context after compaction with SessionStart compact matcher, audit configuration changes with ConfigChange, direnv integration with CwdChanged and FileChanged and CLAUDE_ENV_FILE, auto-approve ExitPlanMode with PermissionRequest decision behavior allow and updatedPermissions setMode), how hooks work (event lifecycle table, hook types command/http/prompt/agent, read input and return output, hook input JSON, hook output exit codes and structured JSON, filter hooks with matchers, configure hook location), prompt-based hooks (type prompt with ok/reason response, Stop hook example), agent-based hooks (type agent with tool access, Stop hook test verification example), HTTP hooks (type http with url/headers/allowedEnvVars, POST event data, response body JSON), limitations (stdout/stderr/exit code communication, 10-minute default timeout, PostToolUse cannot undo, PermissionRequest not in headless mode, Stop fires on every response), troubleshooting (hook not firing, hook error, /hooks shows nothing, Stop hook infinite loop, JSON validation failed from shell profile, debug with Ctrl+O and claude --debug)

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
