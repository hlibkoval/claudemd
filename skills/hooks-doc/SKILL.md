---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- shell commands, HTTP endpoints, LLM prompts, and agent verifiers that execute automatically at lifecycle points. Covers all 25 hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PermissionDenied, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, prompt, agent), configuration schema (matcher groups, handler fields, if condition, async, shell, once, statusMessage, timeout), hook locations (user settings, project settings, local settings, managed policy, plugin hooks.json, skill/agent frontmatter), JSON input/output format (common fields: session_id, transcript_path, cwd, permission_mode, hook_event_name, agent_id, agent_type), exit code semantics (0 allow, 2 block, other non-blocking error), JSON output fields (continue, stopReason, suppressOutput, systemMessage, decision, reason, hookSpecificOutput), decision control per event (PreToolUse permissionDecision allow/deny/ask/defer with updatedInput, PermissionRequest decision.behavior allow/deny with updatedPermissions, PostToolUse/Stop/SubagentStop/ConfigChange top-level decision block, TeammateIdle/TaskCreated/TaskCompleted exit-code-2 or continue:false), matcher patterns per event (tool name, session source, notification type, agent type, config source, filename, error type, load reason, MCP server name), MCP tool matching (mcp__server__tool pattern), if field (permission rule syntax filtering Bash(git *) Edit(*.ts)), environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, CLAUDE_ENV_FILE, CLAUDE_CODE_REMOTE), async hooks (background execution, systemMessage delivery), HTTP hooks (POST body, response handling, headers, allowedEnvVars, env var interpolation), prompt-based hooks (single-turn LLM eval, ok/reason response, model field), agent-based hooks (multi-turn subagent with tools, 50-turn limit), permission update entries (addRules, replaceRules, removeRules, setMode, addDirectories, removeDirectories with destination session/localSettings/projectSettings/userSettings), WorktreeCreate/WorktreeRemove (custom VCS support), CLAUDE_ENV_FILE (SessionStart, CwdChanged, FileChanged), tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent, AskUserQuestion), defer mechanism for non-interactive mode (tool_deferred stop_reason, deferred_tool_use, resume flow), hooks in skills and agents (frontmatter format, Stop converted to SubagentStop, once field), /hooks menu (read-only browser, source labels), disableAllHooks setting, security best practices, Windows PowerShell shell field, debug hooks (--debug-file, CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose), common patterns (notification, auto-format, block edits, re-inject context after compaction, audit config changes, reload environment on directory/file change, auto-approve permissions), and troubleshooting (hook not firing, hook error, stop hook loops, JSON validation failed). Load when discussing hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, SessionStart, SessionEnd, Stop, StopFailure, SubagentStart, SubagentStop, Notification, UserPromptSubmit, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, TeammateIdle, TaskCreated, TaskCompleted, PermissionDenied, InstructionsLoaded, hook configuration, hook matchers, hook types, command hooks, HTTP hooks, prompt hooks, agent hooks, async hooks, hook input, hook output, exit codes, hookSpecificOutput, permissionDecision, CLAUDE_ENV_FILE, /hooks menu, disableAllHooks, hook lifecycle, hook security, auto-format hooks, notification hooks, permission hooks, stop hooks, tool hooks, or any hooks-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- user-defined shell commands, HTTP endpoints, LLM prompts, and agent verifiers that execute automatically at specific points in Claude Code's lifecycle.

## Quick Reference

### Hook Types

| Type | Description | Default Timeout |
|:-----|:-----------|:----------------|
| `command` | Shell command; receives JSON on stdin, returns via exit code + stdout | 600s |
| `http` | POST event JSON to a URL; returns via response body | 600s |
| `prompt` | Single-turn LLM evaluation; returns `{ok, reason}` | 30s |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob); returns `{ok, reason}` | 60s |

### Hook Events

| Event | When it fires | Can block? | Matcher input |
|:------|:-------------|:-----------|:--------------|
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | load reason |
| `UserPromptSubmit` | User submits prompt, before processing | Yes | (none) |
| `PreToolUse` | Before tool call executes | Yes | tool name |
| `PermissionRequest` | Permission dialog about to appear | Yes | tool name |
| `PermissionDenied` | Auto mode classifier denies a tool call | No | tool name |
| `PostToolUse` | After tool call succeeds | No | tool name |
| `PostToolUseFailure` | After tool call fails | No | tool name |
| `Notification` | Claude sends a notification | No | notification type |
| `SubagentStart` | Subagent spawned | No | agent type |
| `SubagentStop` | Subagent finishes | Yes | agent type |
| `TaskCreated` | Task being created via TaskCreate | Yes | (none) |
| `TaskCompleted` | Task being marked complete | Yes | (none) |
| `Stop` | Claude finishes responding | Yes | (none) |
| `StopFailure` | Turn ends due to API error | No | error type |
| `TeammateIdle` | Teammate about to go idle | Yes | (none) |
| `ConfigChange` | Config file changes during session | Yes | config source |
| `CwdChanged` | Working directory changes | No | (none) |
| `FileChanged` | Watched file changes on disk | No | filename (basename) |
| `WorktreeCreate` | Worktree being created | Yes | (none) |
| `WorktreeRemove` | Worktree being removed | No | (none) |
| `PreCompact` | Before context compaction | No | `manual`, `auto` |
| `PostCompact` | After context compaction | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | exit reason |

### Hook Locations (Scope)

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill / agent frontmatter | While component is active | Yes (in component file) |

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
            "command": "your-script.sh",
            "if": "Bash(git *)",
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

Three nesting levels: **hook event** (lifecycle point) > **matcher group** (filter) > **hook handler** (command/http/prompt/agent).

### Common Handler Fields (All Types)

| Field | Required | Description |
|:------|:---------|:-----------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax filter (tool events only), e.g. `"Bash(git *)"`, `"Edit(*.ts)"` |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs only once per session (skills only) |

### Command Hook Fields

| Field | Required | Description |
|:------|:---------|:-----------|
| `command` | Yes | Shell command to execute |
| `async` | No | If `true`, runs in background without blocking |
| `shell` | No | `"bash"` (default) or `"powershell"` (Windows) |

### HTTP Hook Fields

| Field | Required | Description |
|:------|:---------|:-----------|
| `url` | Yes | URL to POST to |
| `headers` | No | Key-value pairs; values support `$VAR` / `${VAR}` interpolation |
| `allowedEnvVars` | No | Env var names allowed for header interpolation |

### Prompt / Agent Hook Fields

| Field | Required | Description |
|:------|:---------|:-----------|
| `prompt` | Yes | Prompt text; `$ARGUMENTS` placeholder for hook input JSON |
| `model` | No | Model for evaluation (default: fast model) |

### Common JSON Input Fields

| Field | Description |
|:------|:-----------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSONL |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent ID (present only inside subagent calls) |
| `agent_type` | Agent name (present with `--agent` or inside subagent) |

### Exit Code Semantics

| Exit code | Meaning |
|:----------|:--------|
| `0` | Success; stdout parsed for JSON output |
| `2` | Blocking error; stderr fed back to Claude; action blocked (for blocking events) |
| Other | Non-blocking error; execution continues; stderr logged |

### JSON Output Fields (on exit 0)

| Field | Default | Description |
|:------|:--------|:-----------|
| `continue` | `true` | If `false`, stops Claude entirely |
| `stopReason` | -- | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | -- | Warning message shown to user |
| `decision` | -- | `"block"` for PostToolUse/Stop/SubagentStop/ConfigChange/UserPromptSubmit |
| `reason` | -- | Explanation when `decision` is `"block"` |
| `hookSpecificOutput` | -- | Nested object with `hookEventName` for event-specific control |

Output injected into context is capped at 10,000 characters.

### Decision Control by Event

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCreated, TaskCompleted | Exit code 2 or `continue: false` | stderr feedback or `stopReason` |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| PermissionDenied | `hookSpecificOutput` | `retry: true` to allow model retry |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| WorktreeCreate | Path return | stdout (command) or `hookSpecificOutput.worktreePath` (http) |
| All other events | None | Side effects only (logging, cleanup) |

PreToolUse precedence when multiple hooks return different decisions: `deny` > `defer` > `ask` > `allow`.

### Matcher Patterns by Event

| Event(s) | Matches on | Example values |
|:---------|:-----------|:---------------|
| PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied | Tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| SessionStart | Session source | `startup`, `resume`, `clear`, `compact` |
| SessionEnd | Exit reason | `clear`, `resume`, `logout`, `prompt_input_exit`, `other` |
| Notification | Notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| SubagentStart, SubagentStop | Agent type | `Bash`, `Explore`, `Plan`, custom names |
| PreCompact, PostCompact | Compaction trigger | `manual`, `auto` |
| ConfigChange | Config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| StopFailure | Error type | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `max_output_tokens`, `unknown` |
| InstructionsLoaded | Load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| Elicitation, ElicitationResult | MCP server name | Your configured MCP server names |
| FileChanged | Filename (basename) | `.envrc`, `.env` |
| UserPromptSubmit, Stop, TeammateIdle, TaskCreated, TaskCompleted, WorktreeCreate, WorktreeRemove, CwdChanged | (no matcher support) | Always fires |

### MCP Tool Matching

MCP tools follow pattern `mcp__<server>__<tool>`. Use regex in matchers:
- `mcp__memory__.*` -- all tools from memory server
- `mcp__.*__write.*` -- any write tool from any server

### Environment Variables

| Variable | Available in | Description |
|:---------|:------------|:-----------|
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hooks | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | SessionStart, CwdChanged, FileChanged | File to write `export` statements for persisting env vars |
| `$CLAUDE_CODE_REMOTE` | All hooks | `"true"` in remote web environments |

### Prompt/Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

- `ok: true` -- action proceeds
- `ok: false` -- action blocked; `reason` fed back to Claude

### Events Supporting Each Hook Type

| Hook types | Events |
|:-----------|:-------|
| command, http, prompt, agent | PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Stop, SubagentStop, TaskCreated, TaskCompleted, UserPromptSubmit |
| command, http only | ConfigChange, CwdChanged, Elicitation, ElicitationResult, FileChanged, InstructionsLoaded, Notification, PermissionDenied, PostCompact, PreCompact, SessionEnd, StopFailure, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove |
| command only | SessionStart |

### Async Hooks

Set `"async": true` on command hooks to run in the background. Async hooks cannot block or return decisions. Output with `systemMessage` or `additionalContext` is delivered on the next conversation turn.

### Permission Update Entries (PermissionRequest hooks)

| `type` | Effect |
|:-------|:-------|
| `addRules` | Add permission rules (`rules`, `behavior`: allow/deny/ask, `destination`) |
| `replaceRules` | Replace all rules of given behavior at destination |
| `removeRules` | Remove matching rules |
| `setMode` | Change permission mode (`default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`) |
| `addDirectories` | Add working directories |
| `removeDirectories` | Remove working directories |

Destinations: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Disable / Remove Hooks

- Remove: delete the entry from the settings JSON file
- Disable all: set `"disableAllHooks": true` in settings (respects managed settings hierarchy)

### /hooks Menu

Type `/hooks` in Claude Code for a read-only browser of all configured hooks. Source labels: `User`, `Project`, `Local`, `Plugin`, `Session`, `Built-in`.

### Key Behaviors

- PreToolUse hooks fire before any permission-mode check; `deny` blocks even in `bypassPermissions` mode
- A hook returning `allow` does not bypass deny rules from settings; hooks can tighten but not loosen restrictions
- When multiple hooks match, they run in parallel; most restrictive decision wins
- Identical handlers are deduplicated (by command string or URL)
- `Stop` hooks: check `stop_hook_active` field to prevent infinite loops
- SessionEnd hooks have a default timeout of 1.5s (override with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`)
- `PermissionRequest` hooks do not fire in non-interactive mode (`-p`); use `PreToolUse` instead
- `WorktreeCreate` hooks replace default git behavior entirely

### Debug Hooks

Start with `claude --debug-file /tmp/claude.log` or use `/debug` mid-session. Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for granular matcher details.

### Security Best Practices

- Validate and sanitize inputs; always quote shell variables (`"$VAR"`)
- Block path traversal; check for `..` in file paths
- Use absolute paths; reference scripts via `"$CLAUDE_PROJECT_DIR"`
- Skip sensitive files (`.env`, `.git/`, keys)

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) -- Full reference for hook events, configuration schema, JSON input/output formats, exit codes, decision control, async hooks, HTTP hooks, prompt hooks, agent hooks, MCP tool hooks, and security considerations
- [Automate Workflows with Hooks](references/claude-code-hooks-guide.md) -- Practical guide with setup walkthrough, common automation patterns (notifications, auto-format, block edits, re-inject context, audit config, reload environment, auto-approve), prompt-based hooks, agent-based hooks, HTTP hooks, and troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Automate Workflows with Hooks: https://code.claude.com/docs/en/hooks-guide.md
