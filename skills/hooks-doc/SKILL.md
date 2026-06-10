---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks — user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific lifecycle points in a Claude Code session.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? |
| :---- | :------------ | :--------- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | Slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog is about to appear | Yes |
| `PermissionDenied` | Auto-mode classifier denies a tool call | No (retry only) |
| `PostToolUse` | After a tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After all parallel tool calls in a batch resolve | Yes |
| `Notification` | Claude Code sends a notification | No |
| `MessageDisplay` | Assistant message text streams to screen | No (replace only) |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task being created via `TaskCreate` | Yes |
| `TaskCompleted` | Task being marked as completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `ConfigChange` | Configuration file changes during session | Yes (except policy) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (abort) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Types

| Type | Description | Async? |
| :--- | :---------- | :----- |
| `command` | Runs a shell command; communicates via stdin/stdout/stderr/exit codes | Yes (`async: true`) |
| `http` | POSTs event data to a URL; communicates via HTTP response body | No |
| `mcp_tool` | Calls a tool on a connected MCP server | No |
| `prompt` | Single-turn LLM evaluation; returns `{"ok": true/false}` | No |
| `agent` | Multi-turn subagent with tool access; returns `{"ok": true/false}` (experimental) | No |

### Basic Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<tool-name-or-regex>",
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
| :------- | :---- | :-------- |
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes |
| `.claude/settings.local.json` | Single project | No |
| Managed policy settings | Organization-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

### Exit Code Behavior (Command Hooks)

| Exit code | Meaning |
| :-------- | :------ |
| `0` | No decision; stdout parsed as JSON if present |
| `2` | Blocking error; stderr shown as reason/feedback |
| Any other | Non-blocking error; transcript shows hook error notice |

> For most events, only exit 2 blocks. Exit 1 is a non-blocking error. Exception: `WorktreeCreate` — any non-zero exit fails creation.

### Matcher Rules

| Matcher value | Evaluated as |
| :------------ | :----------- |
| `""`, `"*"`, or omitted | Match all occurrences |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated exact list |
| Contains any other character | JavaScript regular expression |

Each event type matches on a different field (tool name, session source, notification type, etc.). Events with no matcher support (`Stop`, `PostToolBatch`, `CwdChanged`, etc.) always fire on every occurrence.

### The `if` Field (Fine-grained Hook Filtering)

Available on tool events only (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`). Uses permission rule syntax, e.g. `"Bash(git *)"` or `"Edit(*.ts)"`. The hook only spawns when the tool call matches.

```json
{
  "type": "command",
  "if": "Bash(git *)",
  "command": "./check-git-policy.sh"
}
```

### Common Input Fields (All Events)

| Field | Description |
| :---- | :---------- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook invoked |
| `permission_mode` | Current permission mode |
| `effort` | Active effort level object |
| `hook_event_name` | Name of the event that fired |

### JSON Output Fields (All Events)

| Field | Default | Description |
| :---- | :------ | :---------- |
| `continue` | `true` | If `false`, Claude stops entirely |
| `stopReason` | none | Message shown to user when `continue: false` |
| `suppressOutput` | `false` | Hides hook stdout from transcript |
| `systemMessage` | none | Warning shown to the user |
| `terminalSequence` | none | Terminal escape sequence (OSC 0/1/2/9/99/777, BEL) emitted by Claude Code on your behalf |

### Decision Control by Event

| Events | Pattern | Key fields |
| :----- | :------ | :--------- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `WorktreeCreate` | Path return | Command hook prints path on stdout |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action`, `content` override |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` replaces rendered text |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `additionalContext`, plus `SessionStart` also accepts `initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills` |

### `additionalContext` Delivery

Return `additionalContext` inside `hookSpecificOutput` to inject a string into Claude's context window as a system reminder. Phrasing should be factual statements (e.g., "The deployment target is production") rather than imperative instructions to avoid prompt-injection defenses.

### PreToolUse `permissionDecision` Values

| Value | Effect |
| :---- | :----- |
| `"allow"` | Skips interactive prompt (deny/ask rules still apply) |
| `"deny"` | Cancels tool call; reason shown to Claude |
| `"ask"` | Shows permission prompt to user |
| `"defer"` | Exits process with `stop_reason: "tool_deferred"` (non-interactive `-p` mode only) |

### Command Hook Extra Fields

| Field | Description |
| :---- | :---------- |
| `args` | Argument list for exec form (no shell, path placeholders passed verbatim) |
| `async` | If `true`, runs in background without blocking |
| `asyncRewake` | If `true`, async hook that wakes Claude on exit code 2 |
| `shell` | `"bash"` (default) or `"powershell"` |

### Path Placeholders

| Placeholder | Resolves to |
| :---------- | :---------- |
| `${CLAUDE_PROJECT_DIR}` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

### Environment Variables for Hooks

| Variable | Available in | Description |
| :------- | :----------- | :---------- |
| `CLAUDE_ENV_FILE` | `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` | Write `export` statements here to persist env vars into Bash commands |
| `CLAUDE_EFFORT` | Tool-use context events | Active effort level |
| `CLAUDE_CODE_REMOTE` | All | Set to `"true"` in remote web environments |

### Timeout Defaults

| Hook type | Default timeout |
| :-------- | :-------------- |
| `command`, `http`, `mcp_tool` | 600 s (10 min); `UserPromptSubmit` lowers to 30 s; `MessageDisplay` lowers to 10 s |
| `prompt` | 30 s |
| `agent` | 60 s |

### Async Hooks (Background Execution)

Set `"async": true` on `type: "command"` hooks. The hook runs in the background; Claude continues immediately. Decision fields (e.g. `permissionDecision`) have no effect. Use `asyncRewake: true` to have the hook wake Claude when it exits with code 2.

### Prompt-Based Hooks

Set `"type": "prompt"` with a `prompt` field. Use `$ARGUMENTS` as a placeholder for hook input JSON. The model returns `{"ok": true}` or `{"ok": false, "reason": "..."}`. Use `continueOnBlock: true` to feed the reason back to Claude instead of ending the turn.

### Agent-Based Hooks (Experimental)

Set `"type": "agent"` with a `prompt` field. A subagent spawns with up to 50 tool-use turns, inspects files/code, then returns the same `{"ok": true/false}` decision. Default timeout: 60 s.

### HTTP Hooks

Set `"type": "http"` with a `url` field. Event JSON is POSTed as the request body. The response body uses the same JSON output schema as command hooks. Non-2xx responses and connection failures are non-blocking errors. Header values support `$VAR_NAME` interpolation via `allowedEnvVars`.

### MCP Tool Hooks

Set `"type": "mcp_tool"` with `server` and `tool` fields. The tool's text output is treated like command-hook stdout. Use `input` with `${path}` substitution for event JSON fields.

### Hooks in Skills/Agents

Define hooks in YAML frontmatter under a `hooks:` key, same format as settings-based hooks. Scoped to the component's lifetime; `Stop` hooks in subagents are auto-converted to `SubagentStop`.

### Stop Hook Loop Protection

The `stop_hook_active` input field is `true` when Claude is already continuing due to a Stop hook. Claude Code overrides the hook after 8 consecutive blocks. Check this field early:

```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

### Dynamic Content Injection (SessionStart)

Anything a `SessionStart` hook prints to stdout is added as context for Claude. The special JSON output fields `initialUserMessage`, `sessionTitle`, `watchPaths`, and `reloadSkills` extend this further.

### FileChanged Dual Role of Matcher

For `FileChanged`, the `matcher` field both registers which filenames to watch (split on `|`, treated as literal filenames) and filters which hook groups fire when a change occurs. Regex is not useful for the watch-list role.

### Security Best Practices

- Always quote shell variables: use `"$VAR"` not `$VAR`
- Validate and sanitize all hook inputs
- Block path traversal: check for `..` in file paths
- Use absolute paths for scripts
- Skip sensitive files (`.env`, `.git/`, keys)
- Command hooks run with your full user permissions

### Debugging

- Use `/hooks` in Claude Code to browse configured hooks (read-only)
- Toggle transcript view with `Ctrl+O` for per-hook summaries
- Start with `claude --debug-file /tmp/claude.log` for full execution details
- Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for detailed matcher logging

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) — Full event schemas, JSON input/output formats, all hook types, async hooks, security, and debugging
- [Automate Actions with Hooks Guide](references/claude-code-hooks-guide.md) — Common use cases, getting started walkthrough, and troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Automate Actions with Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
