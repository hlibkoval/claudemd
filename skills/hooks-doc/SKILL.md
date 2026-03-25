---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- automating workflows with shell commands, HTTP endpoints, LLM prompts, and agent-based verifiers that run at specific lifecycle points. Covers all 21 hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), four hook types (command, http, prompt, agent), hook configuration schema (matcher groups, hook handler fields, common fields like type/timeout/statusMessage/once, command fields like command/async, HTTP fields like url/headers/allowedEnvVars, prompt and agent fields like prompt/model), hook input/output format (common input fields session_id/transcript_path/cwd/permission_mode/hook_event_name, agent_id/agent_type for subagents, exit code semantics 0/2/other, JSON output with continue/stopReason/suppressOutput/systemMessage, decision control patterns per event), matcher patterns (regex filtering by tool name, session source, notification type, agent type, config source, error type, load reason, MCP server name), hook locations and scopes (user settings, project settings, local settings, managed policy, plugin hooks.json, skill/agent frontmatter), environment variables ($CLAUDE_PROJECT_DIR, ${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}, CLAUDE_ENV_FILE for SessionStart, $CLAUDE_CODE_REMOTE), async hooks (background execution with async:true, non-blocking, results delivered next turn), PreToolUse tool input schemas (Bash command/description/timeout/run_in_background, Write file_path/content, Edit file_path/old_string/new_string/replace_all, Read file_path/offset/limit, Glob pattern/path, Grep pattern/path/glob/output_mode, WebFetch url/prompt, WebSearch query/allowed_domains/blocked_domains, Agent prompt/description/subagent_type/model), PreToolUse decision control (permissionDecision allow/deny/ask, permissionDecisionReason, updatedInput, additionalContext), PermissionRequest decision control (behavior allow/deny, updatedInput, updatedPermissions with addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories, permission_suggestions, destination session/localSettings/projectSettings/userSettings), PostToolUse decision control (decision block, reason, additionalContext, updatedMCPToolOutput), Stop/SubagentStop decision control (decision block, reason), exit code 2 behavior per event (which events can block), prompt-based hooks (single-turn LLM evaluation, ok/reason response schema, $ARGUMENTS placeholder, model selection), agent-based hooks (multi-turn verification with tool access, up to 50 turns, same ok/reason schema), HTTP hooks (POST request body, response handling 2xx/non-2xx, env var interpolation in headers), SessionStart specifics (source startup/resume/clear/compact, additionalContext output, CLAUDE_ENV_FILE for persisting env vars), ConfigChange specifics (source user_settings/project_settings/local_settings/policy_settings/skills, blocking except policy_settings), WorktreeCreate/WorktreeRemove (custom VCS support, stdout path output), compaction hooks (PreCompact/PostCompact with manual/auto trigger), MCP tool matching (mcp__server__tool naming pattern), hooks in skills and agents (frontmatter definition, lifecycle scoping), /hooks menu (read-only browser, source labels User/Project/Local/Plugin/Session/Built-in), disableAllHooks setting, security considerations (full user permissions, input validation, quoting variables, path traversal), debugging (claude --debug, Ctrl+O verbose mode), common troubleshooting (hook not firing, hook errors, /hooks empty, Stop hook loops, JSON validation failures from shell profile echo statements). Load this skill whenever discussing Claude Code hooks, hook events, hook configuration, automating Claude Code workflows, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, hook matchers, hook input/output, exit codes for hooks, blocking tool calls, auto-approving permissions, prompt-based hooks, agent-based hooks, HTTP hooks, async hooks, SessionStart hooks, SessionEnd hooks, ConfigChange hooks, WorktreeCreate, WorktreeRemove, hook lifecycle, /hooks command, disableAllHooks, CLAUDE_ENV_FILE, hook security, hook debugging, hook troubleshooting, SubagentStart, SubagentStop, TeammateIdle, TaskCompleted, InstructionsLoaded, Notification hooks, Elicitation hooks, PreCompact, PostCompact, StopFailure, or any hook-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- shell commands, HTTP endpoints, LLM prompts, and agent verifiers that run automatically at specific lifecycle points.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? | Matcher field |
|:------|:-------------|:-----------|:--------------|
| `SessionStart` | Session begins or resumes | No | source: `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptSubmit` | User submits prompt, before processing | Yes | no matcher support |
| `PreToolUse` | Before tool call executes | Yes | tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `PermissionRequest` | Permission dialog about to show | Yes | tool name (same as PreToolUse) |
| `PostToolUse` | After tool call succeeds | No (feedback only) | tool name |
| `PostToolUseFailure` | After tool call fails | No (feedback only) | tool name |
| `Notification` | Claude sends notification | No | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | agent type: `Bash`, `Explore`, `Plan`, custom names |
| `SubagentStop` | Subagent finishes | Yes | agent type |
| `Stop` | Claude finishes responding | Yes | no matcher support |
| `StopFailure` | Turn ends due to API error | No | error: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Agent team teammate about to idle | Yes | no matcher support |
| `TaskCompleted` | Task being marked completed | Yes | no matcher support |
| `ConfigChange` | Config file changes during session | Yes (except policy) | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes (non-zero exit fails) | no matcher support |
| `WorktreeRemove` | Worktree being removed | No | no matcher support |
| `PreCompact` | Before context compaction | No | trigger: `manual`, `auto` |
| `PostCompact` | After context compaction | No | trigger: `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Supported events |
|:-----|:-----------|:-----------------|
| `command` | Run a shell command | All events |
| `http` | POST to an HTTP endpoint | PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Stop, SubagentStop, TaskCompleted, UserPromptSubmit |
| `prompt` | Single-turn LLM evaluation (Haiku default) | PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Stop, SubagentStop, TaskCompleted, UserPromptSubmit |
| `agent` | Multi-turn subagent with tool access (up to 50 turns) | Same as prompt |

### Hook Handler Fields

**Common fields (all types)**:

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `timeout` | no | Seconds before canceling. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs only once per session then removed (skills only) |

**Command-specific**: `command` (required), `async` (optional, runs in background)

**HTTP-specific**: `url` (required), `headers` (optional, supports `$VAR_NAME` interpolation), `allowedEnvVars` (optional, list of env vars allowed in headers)

**Prompt/Agent-specific**: `prompt` (required, use `$ARGUMENTS` for hook input JSON), `model` (optional)

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
            "command": "your-script.sh"
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
| `.claude/settings.json` | Single project | Yes (committable) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent YAML frontmatter | While component active | Yes |

### Exit Code Semantics

| Exit code | Meaning | Behavior |
|:----------|:--------|:---------|
| **0** | Success | Action proceeds; stdout parsed for JSON output |
| **2** | Blocking error | Action blocked; stderr fed back to Claude |
| **Other** | Non-blocking error | Action proceeds; stderr shown in verbose mode only |

For `UserPromptSubmit` and `SessionStart`, stdout on exit 0 is added as context Claude can see. For all other events, stdout is only visible in verbose mode (`Ctrl+O`) unless it contains JSON output.

### JSON Output Fields (exit 0)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | `false` stops Claude entirely (overrides all other decisions) |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hides stdout from verbose mode |
| `systemMessage` | none | Warning shown to user |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code 2 or `continue: false` | stderr feedback or `stopReason` |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message` |
| WorktreeCreate | stdout path | Print absolute path to created worktree |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |

### Common Input Fields (all events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook was invoked |
| `permission_mode` | Current mode: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (only in subagent context) |
| `agent_type` | Agent name (only with `--agent` or inside subagent) |

### PreToolUse Tool Input Schemas

**Bash**: `command` (string), `description` (string, optional), `timeout` (number, optional), `run_in_background` (boolean)

**Write**: `file_path` (string), `content` (string)

**Edit**: `file_path` (string), `old_string` (string), `new_string` (string), `replace_all` (boolean)

**Read**: `file_path` (string), `offset` (number, optional), `limit` (number, optional)

**Glob**: `pattern` (string), `path` (string, optional)

**Grep**: `pattern` (string), `path` (string, optional), `glob` (string, optional), `output_mode` (string, optional), `-i` (boolean), `multiline` (boolean)

**WebFetch**: `url` (string), `prompt` (string)

**WebSearch**: `query` (string), `allowed_domains` (array, optional), `blocked_domains` (array, optional)

**Agent**: `prompt` (string), `description` (string), `subagent_type` (string), `model` (string, optional)

**MCP tools**: Named `mcp__<server>__<tool>`, match with regex like `mcp__github__.*`

### PermissionRequest updatedPermissions Entries

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules [{toolName, ruleContent?}]`, `behavior` (allow/deny/ask), `destination` | Add permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replace all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Remove matching rules |
| `setMode` | `mode` (default/acceptEdits/dontAsk/bypassPermissions/plan), `destination` | Change permission mode |
| `addDirectories` | `directories` (path array), `destination` | Add working directories |
| `removeDirectories` | `directories`, `destination` | Remove working directories |

Destination values: `session` (in-memory only), `localSettings`, `projectSettings`, `userSettings`

### Environment Variables

| Variable | Description |
|:---------|:------------|
| `$CLAUDE_PROJECT_DIR` | Project root (wrap in quotes for paths with spaces) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin install directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart hooks only) |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

### Prompt/Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

### HTTP Response Handling

| Response | Equivalent |
|:---------|:-----------|
| 2xx + empty body | exit 0, no output |
| 2xx + plain text body | exit 0, text as context |
| 2xx + JSON body | exit 0 + JSON output |
| Non-2xx or connection failure | Non-blocking error, execution continues |

HTTP hooks cannot block via status codes alone; use 2xx + JSON `decision: "block"` or `hookSpecificOutput` with deny fields.

### Async Hooks

Add `"async": true` to command hooks to run in background. Only `type: "command"` supports this. Async hooks cannot block or return decisions. Results delivered via `systemMessage` or `additionalContext` on the next conversation turn. Completion notifications suppressed by default (enable with `Ctrl+O` or `--verbose`).

### Hooks in Skills and Agents

Define hooks in YAML frontmatter (same format as settings-based hooks). Scoped to the component's lifetime and cleaned up when it finishes. All events supported. For subagents, `Stop` hooks are automatically converted to `SubagentStop`.

### Key Behaviors

- All matching hooks run in parallel; identical handlers are deduplicated
- Matcher is a regex: `Edit|Write` matches either, `mcp__.*` matches all MCP tools
- `disableAllHooks: true` in settings disables all hooks (managed hooks can only be disabled by managed settings)
- `/hooks` command opens read-only browser for configured hooks
- `claude --debug` shows hook execution details; `Ctrl+O` toggles verbose mode
- SessionEnd hooks have 1.5s default timeout (override with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`)
- Stop hooks: check `stop_hook_active` field to prevent infinite loops
- Shell profile `echo` statements can break JSON parsing; wrap in `if [[ $- == *i* ]]` check

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- complete technical reference for all 21 hook events with full JSON input schemas and decision control options; configuration schema (matcher groups, hook handler fields for command/http/prompt/agent types); JSON output format (universal fields, top-level decision, hookSpecificOutput); exit code semantics per event; PreToolUse tool input schemas for all built-in tools; PermissionRequest updatedPermissions and permission_suggestions; MCP tool matching patterns; hook handler deduplication; reference scripts by path; hooks in skills and agents; the /hooks menu; disabling hooks; common input fields; HTTP response handling; prompt-based and agent-based hook configuration and response schema; async hooks; security considerations and best practices; debugging with --debug and verbose mode
- [Hooks guide](references/claude-code-hooks-guide.md) -- practical guide to getting started with hooks; setting up your first hook (step-by-step); common automation patterns (desktop notifications, auto-formatting with Prettier, blocking edits to protected files, re-injecting context after compaction, auditing config changes, auto-approving permission prompts with PermissionRequest); how hooks work (event lifecycle, input/output, exit codes, structured JSON output); filtering with matchers (per-event matcher tables, MCP tool matching, regex examples); configure hook location (scope comparison table); prompt-based hooks; agent-based hooks; HTTP hooks; limitations and troubleshooting (hook not firing, hook errors, /hooks empty, Stop hook loops, JSON validation failures, debug techniques)

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Hooks guide: https://code.claude.com/docs/en/hooks-guide.md
