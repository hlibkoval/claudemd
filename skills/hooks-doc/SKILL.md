---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks — user-defined shell commands, HTTP endpoints, LLM prompts, or agents that execute automatically at specific points in Claude Code's lifecycle.

## Quick Reference

### All Hook Events

| Event | Cadence | When it fires | Can block? |
| :--- | :--- | :--- | :--- |
| `SessionStart` | Per session | Session begins or resumes | No |
| `Setup` | On demand | `--init-only`, `--init`/`--maintenance` with `-p` | No |
| `UserPromptSubmit` | Per turn | User submits a prompt | Yes |
| `UserPromptExpansion` | Per turn | Slash command expands to a prompt | Yes |
| `PreToolUse` | Per tool call | Before a tool call executes | Yes |
| `PermissionRequest` | Per tool call | Before permission dialog is shown | Yes |
| `PermissionDenied` | Per tool call | Auto-mode classifier denies a tool | No (retry only) |
| `PostToolUse` | Per tool call | After a tool call succeeds | No |
| `PostToolUseFailure` | Per tool call | After a tool call fails | No |
| `PostToolBatch` | Per turn | After a full batch of parallel tool calls | Yes |
| `MessageDisplay` | Per message batch | While assistant message text streams | No |
| `SubagentStart` | Per subagent | When a subagent is spawned | No |
| `SubagentStop` | Per subagent | When a subagent finishes | Yes |
| `TaskCreated` | Per task | Task being created via `TaskCreate` | Yes |
| `TaskCompleted` | Per task | Task being marked completed | Yes |
| `Stop` | Per turn | Claude finishes responding | Yes |
| `StopFailure` | Per turn | Turn ends due to API error | No |
| `TeammateIdle` | Per teammate | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | Async | CLAUDE.md or rules file loaded | No |
| `ConfigChange` | Async | Configuration file changes | Yes (not policy) |
| `CwdChanged` | Async | Working directory changes | No |
| `FileChanged` | Async | Watched file changes on disk | No |
| `WorktreeCreate` | On demand | Worktree being created | Yes |
| `WorktreeRemove` | On demand | Worktree being removed | No |
| `PreCompact` | On demand | Before context compaction | Yes |
| `PostCompact` | On demand | After context compaction | No |
| `Elicitation` | Per MCP call | MCP server requests user input | Yes |
| `ElicitationResult` | Per MCP call | After user responds to MCP elicitation | Yes |
| `SessionEnd` | Per session | Session terminates | No |

### Hook Handler Types

| Type | Field | Description |
| :--- | :--- | :--- |
| `command` | `command`, optional `args` | Run a shell command; input via stdin, output via exit code + stdout/stderr |
| `http` | `url`, optional `headers`, `allowedEnvVars` | POST event JSON to an HTTP endpoint |
| `mcp_tool` | `server`, `tool`, optional `input` | Call a tool on an already-connected MCP server |
| `prompt` | `prompt`, optional `model` | Single-turn LLM evaluation returning `{"ok": true/false, "reason": "..."}` |
| `agent` | `prompt`, optional `model`, `timeout` | Spawn a subagent with tool access; returns same `ok`/`reason` schema |

### Common Handler Fields

| Field | Default | Description |
| :--- | :--- | :--- |
| `type` | — | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | — | Permission rule syntax filter for tool events only, e.g. `"Bash(git *)"` or `"Edit(*.ts)"` |
| `timeout` | 600 (cmd/http/mcp), 30 (prompt), 60 (agent) | Seconds before canceling |
| `statusMessage` | — | Custom spinner message while the hook runs |
| `once` | `false` | Run once per session then remove (skill frontmatter only) |

### Command Hook Extra Fields

| Field | Description |
| :--- | :--- |
| `args` | Present → exec form (no shell); absent → shell form (`sh -c`) |
| `async` | Run in background without blocking |
| `asyncRewake` | Background; exit code 2 wakes Claude with stderr as system reminder |
| `shell` | `"bash"` (default) or `"powershell"` |

### Exit Code Semantics

| Code | Meaning |
| :--- | :--- |
| `0` | Success; JSON on stdout is processed; for most events stdout goes to debug log |
| `2` | Blocking error; stdout/JSON ignored; stderr fed to Claude or shown to user |
| Other | Non-blocking error; transcript shows hook error notice + first line of stderr |

### JSON Output Fields (Universal)

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops entirely; takes precedence over event decisions |
| `stopReason` | — | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hide hook stdout from transcript |
| `systemMessage` | — | Warning message shown to the user |
| `terminalSequence` | — | Terminal escape sequence (OSC 0/1/2/9/99/777 or BEL) emitted by Claude Code |

### Decision Control by Event

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | stderr as feedback, or `stopReason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` to tell model it may retry |
| `WorktreeCreate` | Path return | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` replaces rendered text (transcript unchanged) |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `hookSpecificOutput.additionalContext`; `SessionStart` also accepts `initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects and logging only |

### PreToolUse `permissionDecision` Values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skip permission prompt; deny/ask rules still apply |
| `"deny"` | Cancel tool call; reason sent to Claude |
| `"ask"` | Show permission prompt to user |
| `"defer"` | Exit with `stop_reason: "tool_deferred"` for Agent SDK resume (non-interactive only) |

Precedence when multiple hooks return: `deny` > `defer` > `ask` > `allow`.

### Matcher Patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or pipe-separated list |
| Contains any other character | JavaScript regular expression |

Events that match on **tool name**: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`

MCP tool naming: `mcp__<server>__<tool>`. Use `mcp__memory__.*` (regex) to match all tools from a server.

Events with **no matcher support** (always fire): `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay`

### Hook Locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes |
| `.claude/settings.local.json` | Single project | No |
| Managed policy settings | Organization-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill or agent frontmatter | While component active | Yes |

### Path Placeholders

| Placeholder | Resolves to |
| :--- | :--- |
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Use exec form (`args: []`) for hooks that reference path placeholders to avoid shell quoting issues.

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook is invoked |
| `permission_mode` | Current permission mode |
| `effort` | Object with `level` field (low/medium/high/xhigh/max) |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Present when firing inside a subagent |
| `agent_type` | Agent name when using `--agent` or inside a subagent |

### SessionStart-Specific Output Fields

| Field | Description |
| :--- | :--- |
| `additionalContext` | String added to Claude's context before first prompt |
| `initialUserMessage` | First user message in non-interactive (`-p`) mode |
| `sessionTitle` | Sets session title (startup/resume only) |
| `watchPaths` | Array of absolute paths to watch for `FileChanged` events |
| `reloadSkills` | Re-scan skill directories after hooks complete |

`CLAUDE_ENV_FILE` is available in `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks; write `export VAR=value` lines to it to persist env vars into subsequent Bash commands.

### Async Hooks

Add `"async": true` to a command hook to run it in the background without blocking Claude. Only `type: "command"` supports async. Async hooks cannot block or return decisions; `additionalContext` from their output is delivered on the next conversation turn.

`asyncRewake: true` runs async but exits with code 2 to wake Claude immediately even when idle (stderr shown to Claude as a system reminder).

### Stop Hook — Blocking Cap

Stop hooks have an 8-consecutive-block cap. To avoid hitting it, check `stop_hook_active` in the JSON input and `exit 0` when it is `true`. Raise the cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

### Prompt-Based Hook Events

Events that support all five types (command, http, mcp_tool, prompt, agent): `PermissionDenied`, `PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `TeammateIdle`, `UserPromptExpansion`, `UserPromptSubmit`

Events that support command, http, mcp_tool only (not prompt/agent): `ConfigChange`, `CwdChanged`, `Elicitation`, `ElicitationResult`, `FileChanged`, `InstructionsLoaded`, `Notification`, `PostCompact`, `PreCompact`, `SessionEnd`, `StopFailure`, `SubagentStart`, `WorktreeCreate`, `WorktreeRemove`

`SessionStart` and `Setup`: command and mcp_tool only.

Prompt/agent hook response schema: `{"ok": true}` to allow, `{"ok": false, "reason": "..."}` to block. Use `continueOnBlock: true` on prompt hooks to feed the reason back to Claude and keep the turn going instead of ending it.

### Disable Hooks

- Remove a hook: delete its entry from the settings JSON.
- Disable all hooks temporarily: `"disableAllHooks": true` in settings. Managed hooks are unaffected by user/project settings.

### Debug

Start with `claude --debug-file /tmp/claude.log` or run `/debug` mid-session. Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher details.

Troubleshoot with `/hooks` to browse all configured hooks by event, view source file, and inspect details.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) — Full event schemas, configuration schema, JSON input/output formats, exit codes, async hooks, HTTP hooks, prompt hooks, MCP tool hooks, agent hooks
- [Automate actions with hooks](references/claude-code-hooks-guide.md) — Practical guide: setup walkthrough, common automation patterns, troubleshooting

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate actions with hooks: https://code.claude.com/docs/en/hooks-guide.md
