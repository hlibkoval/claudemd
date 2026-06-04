---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks: configuration, event schemas, JSON input/output formats, hook types, decision control, and common automation patterns.

## Quick Reference

### Hook Lifecycle Events

| Event | When it fires | Supports blocking |
|:------|:-------------|:-----------------|
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `-p --init/--maintenance` | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | Slash command expands to a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog is about to appear | Yes (allow/deny) |
| `PermissionDenied` | Auto-mode classifier denies a call | No (retry only) |
| `PostToolUse` | After a tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | No (feedback only) |
| `PostToolBatch` | After all parallel tool calls resolve | Yes (stop loop) |
| `MessageDisplay` | While assistant message text streams | No (replace only) |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task is being created via `TaskCreate` | Yes |
| `TaskCompleted` | Task is being marked completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md/rules file loaded | No |
| `ConfigChange` | Config file changes during session | Yes (except `policy_settings`) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree is being created | Yes (must return path) |
| `WorktreeRemove` | Worktree is being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SessionEnd` | Session terminates | No |

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes |
| `.claude/settings.local.json` | Single project | No |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Hook Types

| Type | Description | Default timeout |
|:-----|:------------|:----------------|
| `command` | Run a shell command; receives JSON on stdin | 600s (30s for `UserPromptSubmit`, 10s for `MessageDisplay`) |
| `http` | POST event JSON to a URL | 600s |
| `mcp_tool` | Call a tool on a connected MCP server | 600s |
| `prompt` | Single-turn LLM evaluation returning `{"ok": true/false}` | 30s |
| `agent` | Multi-turn subagent with tool access (experimental) | 60s |

### Hook Handler Common Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax to filter by tool name+args, e.g. `"Bash(git *)"`. Only valid on tool events |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs once per session then removed (skill frontmatter only) |

### Matcher Patterns

| Matcher value | Evaluated as |
|:-------------|:-------------|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

Each event matches on a different field. Tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`) match on **tool name**.

| Event | Matcher filters |
|:------|:---------------|
| `SessionStart` | `startup`, `resume`, `clear`, `compact` |
| `Setup` | `init`, `maintenance` |
| `SessionEnd` | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart/Stop` | Agent type: `general-purpose`, `Explore`, `Plan`, or custom name |
| `PreCompact/PostCompact` | `manual`, `auto` |
| `ConfigChange` | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | `rate_limit`, `overloaded`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | Command/skill name |
| `Elicitation/ElicitationResult` | MCP server name |
| `FileChanged` | Literal filenames (pipe-separated), **not** regex |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | No matcher support |

### MCP Tool Naming

MCP tools follow `mcp__<server>__<tool>` naming. To match all tools from a server, append `.*` (e.g. `mcp__memory__.*`). Without `.*`, a name like `mcp__memory` is treated as an exact string and matches nothing.

### Common Input Fields (all events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `effort` | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, or `"max"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Unique subagent identifier (subagent hooks only) |
| `agent_type` | Agent name (subagent hooks only) |

### Exit Codes (command hooks)

| Exit code | Meaning |
|:----------|:--------|
| 0 | Success. JSON output on stdout is processed |
| 2 | Blocking error. Stderr is fed back to Claude. For most events, prevents the action |
| Other | Non-blocking error. Shows `<hook name> hook error` notice; execution continues |

**Important:** Exit code 1 is non-blocking. Use exit 2 to enforce policy. Exception: `WorktreeCreate` treats any non-zero exit as failure.

### JSON Output Fields (all hooks)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from transcript |
| `systemMessage` | none | Warning shown to the user |
| `terminalSequence` | none | Terminal escape sequence emitted by Claude Code (OSC 0/1/2/9/99/777 and BEL only) |

### Decision Control by Event

| Events | Decision pattern | Key fields |
|:-------|:----------------|:-----------|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr; `{"continue": false, "stopReason": "..."}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` lets model retry |
| `WorktreeCreate` | Path return | Command: print path on stdout; HTTP: return `hookSpecificOutput.worktreePath` |
| `Elicitation/ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` replaces text on screen only |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `hookSpecificOutput.additionalContext` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### `additionalContext` — Where It Injects

| Events | Injection point |
|:-------|:---------------|
| `SessionStart`, `Setup`, `SubagentStart` | Before first prompt |
| `UserPromptSubmit`, `UserPromptExpansion` | Alongside submitted prompt |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch` | Next to tool result |

### Path Placeholders

| Placeholder | Description |
|:------------|:------------|
| `${CLAUDE_PROJECT_DIR}` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Use exec form (add `"args": []`) to pass paths without shell quoting issues.

### Exec Form vs Shell Form

| | Exec form (`args` present) | Shell form (`args` absent) |
|:-|:--------------------------|:--------------------------|
| Execution | Direct spawn, no shell | Passed to `sh -c` (or Git Bash/PowerShell on Windows) |
| Quoting | Each `args` element is one verbatim argument | Shell tokenization applies |
| Path placeholders | Substituted directly | Wrap in double quotes |
| Use when | Referencing path placeholders | Need pipes, `&&`, redirects |

### SessionStart-Specific Output Fields

| Field | Description |
|:------|:------------|
| `additionalContext` | Context added before first prompt |
| `initialUserMessage` | First user message in non-interactive mode |
| `sessionTitle` | Sets session title (startup/resume only) |
| `watchPaths` | Array of absolute paths for `FileChanged` events |
| `reloadSkills` | If `true`, re-scans skill directories after hooks complete |

### CLAUDE_ENV_FILE

Available on `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export VAR=value` lines (append with `>>`) to persist env vars into all subsequent Bash commands.

### PreToolUse `permissionDecision` Values

| Value | Effect |
|:------|:-------|
| `"allow"` | Skip permission prompt (deny/ask rules still apply) |
| `"deny"` | Cancel tool call; reason shown to Claude |
| `"ask"` | Show permission prompt to user |
| `"defer"` | Pause and exit (`-p` mode only); process can resume with answer |

When multiple PreToolUse hooks return conflicting decisions: `deny` > `defer` > `ask` > `allow`.

### PermissionRequest `updatedPermissions` Entry Types

| `type` | Effect |
|:-------|:-------|
| `addRules` | Add permission rules (`rules`, `behavior`, `destination`) |
| `replaceRules` | Replace all rules of given behavior at destination |
| `removeRules` | Remove matching rules |
| `setMode` | Change permission mode (`default`, `auto`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`) |
| `addDirectories` | Add working directories |
| `removeDirectories` | Remove working directories |

`destination`: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Stop Hook Block Cap

Claude Code overrides a Stop hook after 8 consecutive blocks. Check `stop_hook_active` from the JSON input and exit early if `true` to avoid hitting the cap. Override with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

### HTTP Hook Response Handling

| Response | Effect |
|:---------|:-------|
| 2xx + empty body | Success, no output |
| 2xx + plain text | Text added as context |
| 2xx + JSON body | Parsed like command-hook JSON output |
| Non-2xx, timeout, connection failure | Non-blocking error, execution continues |

Unlike command hooks, HTTP hooks **cannot** signal blocking via status code alone — must return 2xx + JSON with the appropriate decision fields.

### Prompt-Based Hook Response Format

```json
{"ok": true}
```
or
```json
{"ok": false, "reason": "what needs to happen"}
```

When `ok` is `false`: `Stop`/`SubagentStop` feed `reason` back to Claude; `PreToolUse` denies the call with the reason; `PostToolUse`/`PostToolBatch`/`UserPromptSubmit`/`UserPromptExpansion` end the turn with a warning.

### Troubleshooting

| Symptom | Check |
|:--------|:------|
| Hook not firing | Run `/hooks` to confirm it appears; verify matcher is case-correct; `PermissionRequest` doesn't fire in `-p` mode |
| "hook error" in transcript | Test with `echo '{"tool_name":"Bash",...}' \| ./hook.sh`; use absolute paths or `${CLAUDE_PROJECT_DIR}` |
| No hooks in `/hooks` menu | Validate JSON (no trailing commas/comments); confirm settings file location |
| Stop hook hits block cap | Check `stop_hook_active` field and exit 0 if true |
| JSON validation failed | Shell profile printing on startup pollutes stdout — guard with `if [[ $- == *i* ]]` |
| Hook can't write to terminal | Use `terminalSequence` JSON field instead of `/dev/tty` |

Type `/hooks` to browse all configured hooks. The menu is read-only; edit settings JSON directly to change hooks.

Disable all hooks: set `"disableAllHooks": true` in settings. Managed hooks cannot be disabled from user/project settings.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) — Event schemas, configuration schema, JSON input/output formats, exit codes, async hooks, HTTP hooks, prompt hooks, MCP tool hooks, and all hook events with decision control details
- [Automate Actions with Hooks](references/claude-code-hooks-guide.md) — Getting started, common use cases, examples (notifications, auto-format, protected files, context injection, environment reload, auto-approval), prompt/agent/HTTP hook types, and troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Automate Actions with Hooks: https://code.claude.com/docs/en/hooks-guide.md
