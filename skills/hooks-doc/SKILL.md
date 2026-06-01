---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks — user-defined shell commands, HTTP endpoints, and LLM prompts that execute automatically at specific lifecycle points.

## Quick Reference

### Hook Configuration Structure

Hooks live in a settings JSON file under a `"hooks"` key. Three levels of nesting: event name → matcher group → hook handler(s).

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }
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
| Skill or agent frontmatter | While component active | Yes |

Use `/hooks` in Claude Code to browse all configured hooks grouped by event. Set `"disableAllHooks": true` in a settings file to temporarily disable all hooks (does not affect managed hooks unless set at the managed level).

---

### Hook Events

| Event | When it fires | Can block? |
|:------|:-------------|:-----------|
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` / `--init` / `--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | Slash command expands | Yes |
| `PreToolUse` | Before a tool call | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PermissionDenied` | Tool denied by auto-mode classifier | No (use JSON `retry: true`) |
| `PostToolUse` | After tool succeeds | No (but sends feedback) |
| `PostToolUseFailure` | After tool fails | No |
| `PostToolBatch` | After parallel tool batch resolves | Yes |
| `Notification` | Claude Code sends a notification | No |
| `MessageDisplay` | Assistant message streams to screen | No |
| `SubagentStart` | Subagent spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task created via TaskCreate | Yes |
| `TaskCompleted` | Task marked complete | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No |
| `ConfigChange` | Config file changes during session | Yes (except `policy_settings`) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero exit) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

---

### Hook Handler Types

| Type | Description |
|:-----|:------------|
| `"command"` | Shell command. Receives JSON on stdin, communicates via exit code + stdout/stderr |
| `"http"` | POST event JSON to a URL. Communicates via HTTP response body |
| `"mcp_tool"` | Call a tool on a connected MCP server |
| `"prompt"` | Single-turn LLM call (Haiku by default) returning `{"ok": true/false, "reason": "..."}` |
| `"agent"` | Multi-turn subagent with tool access. Experimental. Same `ok/reason` format as prompt |

#### Common Handler Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter by tool+args, e.g. `"Bash(git *)"`. Tool events only |
| `timeout` | no | Seconds. Defaults: 600 for command/http/mcp_tool (30 for UserPromptSubmit); 30 for prompt; 60 for agent |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | Run once per session then remove (skill frontmatter only) |

#### Command Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `command` | yes | Shell command string (shell form) or executable (exec form when `args` present) |
| `args` | no | Argument list — enables exec form (no shell, no tokenization) |
| `async` | no | Run in background without blocking |
| `asyncRewake` | no | Background; wakes Claude on exit 2. Implies `async` |
| `shell` | no | `"bash"` (default) or `"powershell"`. Ignored in exec form |

#### HTTP Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `url` | yes | POST endpoint URL |
| `headers` | no | Key-value headers. Values support `$VAR`/`${VAR}` interpolation for vars in `allowedEnvVars` |
| `allowedEnvVars` | no | Vars allowed to be interpolated into headers |

#### MCP Tool Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `server` | yes | Name of connected MCP server |
| `tool` | yes | Tool name on that server |
| `input` | no | Tool arguments. String values support `${path}` substitution from hook JSON input |

#### Prompt/Agent Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `prompt` | yes | Prompt text. Use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | no | Model to use. Defaults to a fast model |

---

### Matcher Patterns

The `matcher` field filters when a hook group fires.

| Matcher value | Evaluated as |
|:--------------|:-------------|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list |
| Contains any other character | JavaScript regular expression |

| Event | What matcher filters | Example values |
|:------|:--------------------|:---------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | which CLI flag | `init`, `maintenance` |
| `SessionEnd` | why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, or custom name |
| `PreCompact`, `PostCompact` | what triggered | `manual`, `auto` |
| `ConfigChange` | config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | command name | skill or command names |
| `Elicitation`, `ElicitationResult` | MCP server name | configured MCP server names |
| `FileChanged` | literal filenames (pipe-separated, not regex) | `.envrc\|.env` |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | no matcher support | always fires |

MCP tools follow the naming pattern `mcp__<server>__<tool>`. To match all tools from a server, use `mcp__memory__.*` (the `.*` suffix is required — a plain name like `mcp__memory` is treated as an exact string and matches nothing).

Use the `if` field on individual handlers to filter further by tool name + arguments together (uses permission rule syntax). Only valid on tool events.

---

### Exit Codes and JSON Output

**Exit 0** — success. Stdout is parsed for JSON output. For `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart`, plain stdout is added to Claude's context.

**Exit 2** — blocking error. Stdout ignored. Stderr fed to Claude (or shown to user for non-blocking events). See the events table above for which events can block.

**Any other exit code** — non-blocking error. Transcript shows a hook error notice; full stderr goes to the debug log. Exception: `WorktreeCreate` aborts on any non-zero exit.

#### JSON Output Fields (all events)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely. Takes precedence over all decision fields |
| `stopReason` | none | Shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hide hook stdout from transcript |
| `systemMessage` | none | Warning shown to the user |
| `terminalSequence` | none | Terminal escape sequence for Claude Code to emit. Restricted to OSC 0/1/2/9/99/777 and BEL. Requires v2.1.141+ |

#### Decision Control by Event

| Events | Decision pattern | Key fields |
|:-------|:----------------|:-----------|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit 2 or `continue: false` | Exit 2 blocks with stderr; `{"continue": false}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` to let model retry |
| `WorktreeCreate` | path return | Print worktree path to stdout; failure aborts creation |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` replaces on-screen text only |
| `SessionStart`, `Setup`, `SubagentStart` | context only | `additionalContext`; SessionStart also accepts `initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills` |
| Others | none | Side-effects only (logging, cleanup) |

`PreToolUse` precedence when multiple hooks conflict: `deny` > `defer` > `ask` > `allow`.

#### `additionalContext` Field

Return inside `hookSpecificOutput` alongside `hookEventName`. Injected as a system reminder into Claude's context. Capped at 10,000 characters (overflow saved to file). Write as factual statements, not imperative commands.

#### `CLAUDE_ENV_FILE`

Available to `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export KEY=value` statements to this path to persist env vars for subsequent Bash commands.

---

### Path Placeholders in Commands

| Placeholder | Resolves to |
|:------------|:------------|
| `${CLAUDE_PROJECT_DIR}` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Prefer exec form (set `"args": []`) when using path placeholders — each element passes through without shell tokenization, so paths with spaces need no quoting.

---

### Common Patterns

**Auto-format after edits:**
```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }] }
    ]
  }
}
```

**Block edits to protected files** — `PreToolUse` hook on `Edit|Write`, exit 2 with reason to stderr.

**Re-inject context after compaction** — `SessionStart` with `matcher: "compact"`, stdout added to context.

**Desktop notification** — `Notification` hook; use `terminalSequence` in JSON output or a platform command.

**Auto-approve a permission prompt** — `PermissionRequest` hook returns `{"hookSpecificOutput": {"hookEventName": "PermissionRequest", "decision": {"behavior": "allow"}}}`.

**Stop hook guard** (prevent infinite loop): parse `stop_hook_active` from stdin and exit 0 if `true`.

**Reload direnv on directory change** — pair `SessionStart` + `CwdChanged` hooks writing `direnv export bash > "$CLAUDE_ENV_FILE"`.

---

### Troubleshooting

| Symptom | Check |
|:--------|:------|
| Hook not firing | `/hooks` menu — confirm event/matcher; matchers are case-sensitive; `PermissionRequest` doesn't fire in `-p` mode |
| Hook error in transcript | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./hook.sh`; use absolute paths or exec form; `chmod +x` the script |
| `/hooks` shows nothing | JSON valid? Correct file path? Restart session if file-watcher missed the change |
| Stop hook hits block cap (8 consecutive blocks) | Check `stop_hook_active` in input; raise cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` |
| JSON validation failed | Shell profile printing on startup — guard with `if [[ $- == *i* ]]; then echo ...; fi` |
| Debug | `claude --debug-file /tmp/claude.log`; or `/debug` mid-session; transcript view with `Ctrl+O` |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate Workflows with Hooks (Guide)](references/claude-code-hooks-guide.md) — quickstart, common use cases, how hooks work, prompt/agent/HTTP hooks, troubleshooting
- [Hooks Reference](references/claude-code-hooks-reference.md) — full event schemas, all JSON input/output fields, configuration schema, async hooks, MCP tool hooks, every hook event in detail

## Sources

- Automate Workflows with Hooks (Guide): https://code.claude.com/docs/en/hooks-guide.md
- Hooks Reference: https://code.claude.com/docs/en/hooks.md
