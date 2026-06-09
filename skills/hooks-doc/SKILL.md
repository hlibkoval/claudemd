---
name: hooks-doc
user-invocable: false
description: Complete official documentation for Claude Code hooks — lifecycle events, configuration schema, all hook types, JSON input/output formats, exit codes, async hooks, prompt/agent/HTTP/MCP tool hooks, and per-event decision control.
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks: lifecycle events, configuration schema, hook types, JSON input/output formats, exit codes, async hooks, prompt hooks, agent hooks, HTTP hooks, MCP tool hooks, and per-event decision control.

## Quick Reference

### Hook Lifecycle Events

| Event | When it fires | Can block? |
|:------|:-------------|:-----------|
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `--init`/`--maintenance` with `-p` | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | Slash command expands before reaching Claude | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog is about to appear | Yes |
| `PermissionDenied` | Auto-mode classifier denies a tool call | No (can set retry) |
| `PostToolUse` | After a tool call succeeds | No (can send feedback) |
| `PostToolUseFailure` | After a tool call fails | No (can send feedback) |
| `PostToolBatch` | After full batch of parallel tool calls resolves | Yes (stops agentic loop) |
| `MessageDisplay` | While assistant message text streams | No |
| `SubagentStart` | When a subagent is spawned | No |
| `SubagentStop` | When a subagent finishes | Yes |
| `TaskCreated` | Task being created via TaskCreate | Yes |
| `TaskCompleted` | Task being marked completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `ConfigChange` | Configuration file changes during session | Yes (except policy_settings) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | A watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero exits fail creation) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Configuration Structure

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolName",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/script.sh"
          }
        ]
      }
    ]
  }
}
```

Three levels of nesting: **hook event** (lifecycle point) → **matcher group** (filter) → **hook handler** (command/http/mcp_tool/prompt/agent).

### Hook Locations (Scope)

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Matcher Patterns

| Matcher value | Evaluated as |
|:-------------|:-------------|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or pipe-separated list |
| Contains any other character | JavaScript regular expression |

**What each event matches on:**

| Event | Matcher filters |
|:------|:---------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name |
| `SessionStart` | how session started: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag: `init`, `maintenance` |
| `SessionEnd` | exit reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type: `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | trigger: `manual`, `auto` |
| `ConfigChange` | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `FileChanged` | literal filenames to watch (split on `\|`, not regex) |
| `InstructionsLoaded` | load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | command name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `StopFailure` | error type: `rate_limit`, `overloaded`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown` |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | no matcher support |

**MCP tool naming:** `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from the `memory` server (the `.*` is required — `mcp__memory` alone matches nothing).

### Hook Handler Types

| Type | Description |
|:-----|:------------|
| `command` | Run a shell command; input via stdin, output via stdout/exit code |
| `http` | POST event JSON to a URL; response body is the output |
| `mcp_tool` | Call a tool on an already-connected MCP server |
| `prompt` | Single-turn LLM evaluation; returns `{"ok": true/false}` |
| `agent` | Multi-turn subagent with tool access; returns `{"ok": true/false}` (experimental) |

### Common Handler Fields (All Types)

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter by tool name + args (tool events only): e.g. `"Bash(git *)"`, `"Edit(*.ts)"` |
| `timeout` | no | Seconds before canceling. Defaults: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs once per session (skill frontmatter only) |

### Command Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `command` | yes | Shell command (shell form) or executable (exec form when `args` is set) |
| `args` | no | Argument list; triggers exec form (no shell, no quoting issues) |
| `async` | no | If `true`, runs in background without blocking |
| `asyncRewake` | no | If `true`, async + wakes Claude on exit code 2 |
| `shell` | no | `"bash"` (default) or `"powershell"` |

**Shell form vs. exec form:** When `args` is present, `command` is spawned directly (exec form — no shell, no quoting needed). When `args` is absent, `command` is passed to `sh -c` / Git Bash (shell form — supports pipes, `&&`, etc.).

### HTTP Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `url` | yes | URL to POST to |
| `headers` | no | Additional HTTP headers; values support `$VAR`/`${VAR}` interpolation |
| `allowedEnvVars` | no | Required to enable env var interpolation in headers |

### MCP Tool Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `server` | yes | Name of a configured (connected) MCP server |
| `tool` | yes | Tool name on that server |
| `input` | no | Tool arguments; string values support `${path}` substitution from hook JSON input |

### Prompt / Agent Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `prompt` | yes | Prompt text; use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | no | Model to use; defaults to a fast model |
| `continueOnBlock` | no | When `ok: false`, feed reason back to Claude and continue (prompt hooks only, default `false`) |

**Events supporting `prompt` and `agent` types:** `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `PermissionRequest`, `PermissionDenied`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `UserPromptSubmit`, `UserPromptExpansion`.

`SessionStart` and `Setup` support only `command` and `mcp_tool`.

### Path Placeholders

| Placeholder | Resolves to |
|:-----------|:-----------|
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin's persistent data directory |

Prefer exec form (`args: []`) when using path placeholders to avoid shell quoting issues.

### Exit Code Behavior

| Exit code | Meaning |
|:----------|:--------|
| `0` | Success; JSON output in stdout is processed |
| `2` | Blocking error; stderr is fed back to Claude (or shown to user). Effect is event-specific |
| Any other | Non-blocking error; transcript shows one-line notice from stderr; execution continues |

**Exception:** `WorktreeCreate` — any non-zero exit code fails worktree creation.

Only exit code 0 causes JSON output to be processed. If you exit 2, all JSON is ignored.

### JSON Output Fields (Universal)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely (overrides all event-specific decisions) |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides hook stdout from transcript (still in debug log) |
| `systemMessage` | none | Warning message shown to the user |
| `terminalSequence` | none | Terminal escape sequence Claude Code emits (OSC 0/1/2/9/99/777 and BEL only; requires v2.1.141+) |

### Decision Control by Event

| Events | Decision pattern | Key fields |
|:-------|:----------------|:-----------|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | Exit 2 blocks; `{"continue": false, "stopReason": "..."}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells model it may retry |
| `WorktreeCreate` | Path return | Command hook prints path on stdout; HTTP hook returns `hookSpecificOutput.worktreePath` |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` replaces on-screen text (transcript/Claude unaffected) |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `hookSpecificOutput.additionalContext`; no blocking |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### `PreToolUse` Permission Decisions

| `permissionDecision` | Effect |
|:--------------------|:-------|
| `"allow"` | Skips permission prompt (deny/ask rules still apply) |
| `"deny"` | Cancels tool call; reason shown to Claude |
| `"ask"` | Shows permission dialog to user |
| `"defer"` | Exits process with `stop_reason: "tool_deferred"` (non-interactive `-p` mode only; requires v2.1.89+) |

Precedence when multiple PreToolUse hooks return different decisions: `deny` > `defer` > `ask` > `allow`.

### `PostToolUse` Extra Output Fields

| Field | Description |
|:------|:------------|
| `additionalContext` | String added to Claude's context alongside the tool result |
| `updatedToolOutput` | Replaces the tool's output before it is sent to Claude (must match tool's output shape) |
| `updatedMCPToolOutput` | Replaces the output for MCP tools only (prefer `updatedToolOutput`) |

### `additionalContext` — Injecting Context for Claude

Return inside `hookSpecificOutput` with `hookEventName` set:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts instead."
  }
}
```

Injected as a system reminder at the point the hook fired. Write as factual statements, not imperative instructions, to avoid prompt-injection defenses.

### Common Input Fields (All Events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook fires |
| `permission_mode` | Current permission mode (most events) |
| `hook_event_name` | Name of the event |
| `effort` | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` (tool/stop events) |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside a subagent) |

### `SessionStart` Special Output Fields

| Field | Description |
|:------|:------------|
| `additionalContext` | Added to Claude's context before first prompt |
| `initialUserMessage` | First user message for non-interactive mode |
| `sessionTitle` | Sets session title (startup/resume only) |
| `watchPaths` | Array of absolute paths to watch for `FileChanged` |
| `reloadSkills` | If `true`, re-scans skill directories after SessionStart hooks complete |

`CLAUDE_ENV_FILE` (environment variable): write `export VAR=value` lines here to persist env vars into subsequent Bash commands. Available in `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks.

### `UserPromptSubmit` Special Output Fields

| Field | Description |
|:------|:------------|
| `decision` | `"block"` prevents prompt processing and erases the prompt |
| `reason` | Shown to user when `decision` is `"block"` |
| `additionalContext` | String added to Claude's context alongside the prompt |
| `sessionTitle` | Sets session title based on prompt content |
| `suppressOriginalPrompt` | If `true` with `decision: "block"`, omits original prompt text from block message |

### `Stop` / `SubagentStop` Input Fields

| Field | Description |
|:------|:------------|
| `stop_hook_active` | `true` when Claude is already continuing due to a stop hook — check to avoid infinite loops |
| `last_assistant_message` | Text of Claude's final response (no need to parse transcript) |
| `background_tasks` | Array of in-flight background task descriptors (v2.1.145+) |
| `session_crons` | Array of session-scoped scheduled wakeup descriptors (v2.1.145+) |

**Stop decision control:** Use `decision: "block"` with `reason` to block (reason shown as error). Use `hookSpecificOutput.additionalContext` for non-error guidance that keeps conversation going — shown as "Stop hook feedback" rather than a hook error.

### `PermissionRequest` — Permission Update Entries

Use `updatedPermissions` output to modify rules or mode. Each entry has a `type` and `destination`:

| `type` | Effect |
|:-------|:-------|
| `addRules` | Adds permission rules (`rules`, `behavior`, `destination`) |
| `replaceRules` | Replaces all rules of given behavior at destination |
| `removeRules` | Removes matching rules |
| `setMode` | Changes permission mode (`default`, `auto`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`) |
| `addDirectories` | Adds working directories |
| `removeDirectories` | Removes working directories |

| `destination` | Writes to |
|:-------------|:----------|
| `session` | In-memory only |
| `localSettings` | `.claude/settings.local.json` |
| `projectSettings` | `.claude/settings.json` |
| `userSettings` | `~/.claude/settings.json` |

### `MessageDisplay` Input and Output

Input fields: `turn_id`, `message_id`, `index` (zero-based batch number), `final` (true on last batch), `delta` (new lines since prior batch).

Output: return `hookSpecificOutput.displayContent` to replace `delta` on screen. Does not affect transcript or what Claude sees. Default timeout is 10 seconds.

### Async Hooks

Add `"async": true` to a `command` hook to run it in the background. Claude continues immediately. Decision fields (`permissionDecision`, `decision`, `continue`) are ignored. Use `asyncRewake: true` to have Claude react when an async hook exits with code 2.

### Prompt-Based Hooks Response Format

```json
{ "ok": true }
{ "ok": false, "reason": "what should happen instead" }
```

`ok: false` behavior varies by event: `Stop`/`SubagentStop` → feeds reason back; `PreToolUse` → denies with reason; `PostToolUse` → ends turn with warning (or continues if `continueOnBlock: true`); others similar.

### Stop Hook Loop Protection

`stop_hook_active` input field is `true` when Claude is already continuing due to a Stop hook. Check it to avoid infinite loops. Claude overrides Stop hooks after 8 consecutive blocks. Override the cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

The `/goal` command is a built-in shortcut for a session-scoped prompt-based Stop hook. Use it when you want Claude to keep working until a condition holds without writing hook configuration.

### Disable Hooks

- Remove individual hooks: delete their entry from settings JSON
- Disable all hooks temporarily: set `"disableAllHooks": true` in settings
- No way to disable a single hook while keeping it configured

### Troubleshooting

| Symptom | Fix |
|:--------|:----|
| Hook not firing | Run `/hooks` to confirm it appears; check case-sensitive matcher; verify event type |
| Hook error in transcript | Test manually: `echo '{"tool_name":"Bash",...}' \| ./hook.sh`; check `echo $?` |
| JSON validation failed | Shell profile printing text to stdout — wrap echo statements: `if [[ $- == *i* ]]; then echo ...; fi` |
| Stop hook hits block cap | Check `stop_hook_active` input field and `exit 0` when `true` |
| PermissionRequest not firing | Does not fire in non-interactive `-p` mode — use `PreToolUse` instead |

Debug log: `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`. Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher details.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) — Complete event schemas, JSON input/output formats, all hook types, async hooks, security considerations
- [Automate actions with hooks](references/claude-code-hooks-guide.md) — Practical guide with common automation patterns, troubleshooting, prompt/agent/HTTP hooks

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate actions with hooks: https://code.claude.com/docs/en/hooks-guide.md
