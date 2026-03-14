---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- user-defined shell commands, HTTP endpoints, LLM prompts, and agent verifiers that execute at specific lifecycle points. Covers hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, prompt, agent), configuration schema (matcher groups, handler fields, timeout, async, once, statusMessage), JSON input/output format (common input fields session_id/cwd/transcript_path/permission_mode/hook_event_name, exit codes 0/2, structured JSON output with decision/continue/hookSpecificOutput), decision control patterns (top-level decision block, hookSpecificOutput permissionDecision allow/deny/ask, PermissionRequest decision behavior allow/deny, updatedInput, updatedPermissions, additionalContext), matcher patterns (tool name regex for PreToolUse/PostToolUse/PermissionRequest, session source for SessionStart, notification type, agent type for SubagentStart/SubagentStop, config source for ConfigChange, compaction trigger for PreCompact/PostCompact, MCP server name for Elicitation/ElicitationResult), hook locations (user settings, project settings, local settings, managed policy, plugin hooks.json, skill/agent frontmatter), PreToolUse tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), async hooks (background execution, systemMessage delivery), prompt-based hooks (LLM evaluation, ok/reason response, $ARGUMENTS placeholder, model selection), agent-based hooks (multi-turn verification with tool access, 50-turn limit), HTTP hooks (POST endpoint, headers with env var interpolation, allowedEnvVars, response body JSON), environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_ENV_FILE for SessionStart, CLAUDE_CODE_REMOTE), /hooks menu (read-only browser, source labels User/Project/Local/Plugin/Session/Built-in), disableAllHooks setting, security considerations, debugging (claude --debug, Ctrl+O verbose mode), hooks in skills and agents (frontmatter-scoped, once field), common patterns (auto-format after edits, block protected files, desktop notifications, re-inject context after compaction, audit config changes, log bash commands, match MCP tools), Stop hook infinite loop prevention (stop_hook_active field), CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS, troubleshooting (hook not firing, JSON validation failed from shell profile echo, hook errors, /hooks shows nothing). Load when discussing Claude Code hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, SessionStart, SessionEnd, hook matchers, hook configuration, hook input/output, exit codes for hooks, blocking tool calls, auto-formatting with hooks, permission hooks, notification hooks, prompt-based hooks, agent-based hooks, HTTP hooks, async hooks, hook lifecycle, CLAUDE_ENV_FILE, disableAllHooks, /hooks command, hook security, hook debugging, hook troubleshooting, SubagentStart, SubagentStop, TeammateIdle, TaskCompleted, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, InstructionsLoaded, hook types command/http/prompt/agent, writing hook scripts, or automating Claude Code workflows with hooks.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- user-defined automation that runs at specific lifecycle points.

## Quick Reference

Hooks are shell commands, HTTP endpoints, LLM prompts, or agent verifiers that execute automatically when Claude Code edits files, runs tools, finishes tasks, or needs input. They provide deterministic control over behavior: format code after edits, block dangerous commands, send notifications, inject context, enforce project rules.

### Hook Events

| Event | When it fires | Can block? | Matcher filters |
|:------|:-------------|:-----------|:----------------|
| `SessionStart` | Session begins/resumes | No | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md / rules file loaded | No | No matcher support |
| `UserPromptSubmit` | User submits prompt | Yes | No matcher support |
| `PreToolUse` | Before tool executes | Yes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `PermissionRequest` | Permission dialog shown | Yes | Tool name |
| `PostToolUse` | After tool succeeds | No | Tool name |
| `PostToolUseFailure` | After tool fails | No | Tool name |
| `Notification` | Notification sent | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type (`Bash`, `Explore`, `Plan`, custom) |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `TeammateIdle` | Agent team teammate about to go idle | Yes | No matcher support |
| `TaskCompleted` | Task marked completed | Yes | No matcher support |
| `ConfigChange` | Config file changes | Yes (except policy) | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes (non-zero exit) | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before compaction | No | `manual`, `auto` |
| `PostCompact` | After compaction | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:-----------|:----------------|
| `command` | Shell command, receives JSON on stdin | 600s |
| `http` | POST to URL, receives JSON as request body | 600s |
| `prompt` | Single-turn LLM evaluation, returns `{ok, reason}` | 30s |
| `agent` | Multi-turn subagent with tool access (up to 50 turns), returns `{ok, reason}` | 60s |

Events supporting all four types: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `TaskCompleted`. All other events support `command` only.

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
            "timeout": 30,
            "async": false,
            "statusMessage": "Running checks..."
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

### Handler Fields

**Common** (all types): `type` (required), `timeout`, `statusMessage`, `once` (skills only, runs once per session)

**Command**: `command` (required), `async` (run in background)

**HTTP**: `url` (required), `headers` (supports `$VAR_NAME` interpolation), `allowedEnvVars`

**Prompt/Agent**: `prompt` (required, use `$ARGUMENTS` for hook input JSON), `model` (defaults to fast model)

### Common Input Fields (stdin JSON)

| Field | Description |
|:------|:-----------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `dontAsk`, `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent ID (present inside subagent calls) |
| `agent_type` | Agent name (present with `--agent` or inside subagents) |

### Exit Code Behavior

| Exit code | Effect |
|:----------|:-------|
| **0** | Action proceeds; stdout parsed for JSON output |
| **2** | Blocking error; stderr fed to Claude as feedback |
| **Other** | Non-blocking error; stderr logged in verbose mode |

For events that cannot block (PostToolUse, Notification, SessionStart, SessionEnd, etc.), exit 2 shows stderr to user/Claude but cannot prevent the action.

### Decision Control Patterns

**Top-level `decision`** (UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange):
```json
{"decision": "block", "reason": "Explanation"}
```

**PreToolUse `hookSpecificOutput`**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Reason text",
    "updatedInput": {"command": "modified-command"},
    "additionalContext": "Extra context for Claude"
  }
}
```

**PermissionRequest `hookSpecificOutput`**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow|deny",
      "updatedInput": {},
      "updatedPermissions": [],
      "message": "Deny reason"
    }
  }
}
```

**Elicitation/ElicitationResult `hookSpecificOutput`**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "Elicitation",
    "action": "accept|decline|cancel",
    "content": {"field": "value"}
  }
}
```

**Universal JSON fields** (all events): `continue` (false stops Claude entirely), `stopReason`, `suppressOutput`, `systemMessage`

### PreToolUse Tool Input Schemas

| Tool | Key fields in `tool_input` |
|:-----|:--------------------------|
| `Bash` | `command`, `description`, `timeout`, `run_in_background` |
| `Write` | `file_path`, `content` |
| `Edit` | `file_path`, `old_string`, `new_string`, `replace_all` |
| `Read` | `file_path`, `offset`, `limit` |
| `Glob` | `pattern`, `path` |
| `Grep` | `pattern`, `path`, `glob`, `output_mode`, `-i`, `multiline` |
| `WebFetch` | `url`, `prompt` |
| `WebSearch` | `query`, `allowed_domains`, `blocked_domains` |
| `Agent` | `prompt`, `description`, `subagent_type`, `model` |

MCP tools follow the naming pattern `mcp__<server>__<tool>` (e.g., `mcp__github__search_repositories`).

### Key Environment Variables

| Variable | Description |
|:---------|:-----------|
| `$CLAUDE_PROJECT_DIR` | Project root; use for portable script paths |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin root directory |
| `$CLAUDE_ENV_FILE` | SessionStart only; write `export` statements to persist env vars for the session |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | Override 1.5s default timeout for SessionEnd hooks |

### Async Hooks

Set `"async": true` on command hooks to run in background. Claude continues immediately. Output delivered on next conversation turn via `systemMessage` or `additionalContext`. Cannot block actions. Only `type: "command"` supports async.

### Prompt/Agent Hook Response

Both prompt and agent hooks return:
```json
{"ok": true}
```
or:
```json
{"ok": false, "reason": "Explanation shown to Claude"}
```

### Stop Hook Loop Prevention

Check `stop_hook_active` in input JSON. If `true`, the hook is running because a previous Stop hook told Claude to continue. Exit 0 to let Claude stop and prevent infinite loops.

### Hooks in Skills and Agents

Define hooks in YAML frontmatter. Scoped to the component's lifetime. All events supported. For subagents, `Stop` hooks auto-convert to `SubagentStop`. The `once` field (skills only) makes a hook run once per session then deactivate.

### Disable and Debug

- `"disableAllHooks": true` in settings disables all hooks (respects managed hierarchy)
- `/hooks` command opens read-only hook browser with source labels
- `claude --debug` for full execution details
- `Ctrl+O` toggles verbose mode to see hook output in transcript
- Direct settings edits require `/hooks` review or session restart to take effect

### Troubleshooting

| Issue | Solution |
|:------|:---------|
| Hook not firing | Check `/hooks` menu; verify matcher is case-sensitive and matches tool name |
| `PermissionRequest` not firing in `-p` mode | Use `PreToolUse` instead |
| Stop hook loops forever | Check `stop_hook_active` field; exit 0 when true |
| JSON validation failed | Wrap `echo` in shell profile with `[[ $- == *i* ]]` interactive check |
| Hook error in output | Test manually: `echo '{"tool_name":"Bash"}' \| ./hook.sh` |
| `/hooks` shows nothing | Restart session or review in `/hooks`; validate JSON syntax |
| Script not running | `chmod +x` the script; use absolute paths or `$CLAUDE_PROJECT_DIR` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas and JSON input/output formats for all 21 hook events, configuration schema (matcher groups, handler fields for command/http/prompt/agent types), decision control patterns per event (top-level decision, hookSpecificOutput, exit code 2 behavior table), PreToolUse tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), MCP tool matching patterns, hook handler fields (common, command, HTTP with env var interpolation, prompt/agent), hook locations and scope, /hooks menu details, disableAllHooks with managed hierarchy, JSON output fields (continue, stopReason, suppressOutput, systemMessage), async hooks (background execution, systemMessage delivery, limitations), prompt-based hooks (LLM evaluation, $ARGUMENTS placeholder, response schema, supported events), agent-based hooks (multi-turn verification, 50-turn limit, tool access), HTTP hooks (POST format, response handling, env var interpolation in headers), environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_ENV_FILE, CLAUDE_CODE_REMOTE), hooks in skills/agents (frontmatter, once field, Stop-to-SubagentStop conversion), security best practices, debug output format
- [Hooks guide](references/claude-code-hooks-guide.md) -- getting started walkthrough (first hook setup, /hooks verification, testing), common automation patterns (desktop notifications on macOS/Linux/Windows, auto-format with Prettier after edits, block edits to protected files with script, re-inject context after compaction, audit configuration changes), how hooks work (event lifecycle, input/output via stdin/stdout/stderr/exit codes, structured JSON output, filter with matchers, configure hook location and scope), prompt-based hooks (LLM evaluation for judgment calls, Stop hook example), agent-based hooks (multi-turn verification with tools, test suite verification), HTTP hooks (POST to endpoint, header env var interpolation, response handling), limitations and troubleshooting (hook not firing, hook errors, /hooks shows nothing, Stop hook infinite loops, JSON validation failed from shell profile, debug techniques with Ctrl+O and --debug)

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Hooks guide: https://code.claude.com/docs/en/hooks-guide.md
