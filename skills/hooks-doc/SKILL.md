---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks: automating actions at lifecycle points, hook events and matchers, input/output formats, command/HTTP/MCP/prompt/agent hook types, async hooks, and decision control.

## Quick Reference

### Hook Events Reference

| Event | When it fires | Can block? | Matcher field |
|:------|:-------------|:-----------|:--------------|
| `SessionStart` | Session begins or resumes | No | session source (`startup`, `resume`, `clear`, `compact`) |
| `Setup` | `--init-only` / `-p --init` / `-p --maintenance` | No | CLI flag (`init`, `maintenance`) |
| `UserPromptSubmit` | User submits a prompt | Yes | none (fires on all) |
| `UserPromptExpansion` | Slash command expands to prompt | Yes | command name |
| `PreToolUse` | Before tool call executes | Yes | tool name |
| `PermissionRequest` | Permission dialog is about to appear | Yes | tool name |
| `PermissionDenied` | Auto mode classifier denies a tool call | No | tool name |
| `PostToolUse` | After tool call succeeds | No (feedback only) | tool name |
| `PostToolUseFailure` | After tool call fails | No (feedback only) | tool name |
| `PostToolBatch` | After full parallel tool batch resolves | Yes | none |
| `Notification` | Claude Code sends a notification | No | notification type |
| `MessageDisplay` | Assistant message text streams to screen | No | none |
| `SubagentStart` | Subagent is spawned | No | agent type |
| `SubagentStop` | Subagent finishes | Yes | agent type |
| `TaskCreated` | Task created via TaskCreate | Yes | none |
| `TaskCompleted` | Task marked as completed | Yes | none |
| `Stop` | Claude finishes responding | Yes | none |
| `StopFailure` | Turn ends due to API error | No | error type |
| `TeammateIdle` | Agent team teammate about to go idle | Yes | none |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No | load reason |
| `ConfigChange` | Configuration file changes during session | Yes (except policy) | config source |
| `CwdChanged` | Working directory changes | No | none |
| `FileChanged` | Watched file changes on disk | No | literal filenames (watch list) |
| `WorktreeCreate` | Worktree being created | Yes (path return) | none |
| `WorktreeRemove` | Worktree being removed | No | none |
| `PreCompact` | Before context compaction | Yes | `manual` / `auto` |
| `PostCompact` | After context compaction completes | No | `manual` / `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | exit reason |

### Matcher Pattern Rules

| Matcher value | Evaluated as |
|:-------------|:-------------|
| `"*"`, `""`, or omitted | Match all (fires on every occurrence) |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list of exact strings |
| Contains any other character | JavaScript regular expression |

MCP tool naming: `mcp__<server>__<tool>` — e.g. `mcp__memory__create_entities`. Use `mcp__memory__.*` to match all tools from a server (`.*` suffix is required).

### Hook Handler Types

| Type | Description | Supports async? |
|:-----|:------------|:----------------|
| `command` | Shell command; stdin=JSON, stdout/stderr/exit code = result | Yes |
| `http` | POST event JSON to URL; result from response body | No |
| `mcp_tool` | Call a tool on a connected MCP server | No |
| `prompt` | Single-turn LLM evaluation (Haiku by default); returns `{ok, reason}` | No |
| `agent` | Multi-turn subagent with tool access; returns `{ok, reason}` | No |

Events that support all five types: `PermissionDenied`, `PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `TeammateIdle`, `UserPromptExpansion`, `UserPromptSubmit`.

`SessionStart` and `Setup` support `command` and `mcp_tool` only. All other events support `command`, `http`, and `mcp_tool` but not `prompt` or `agent`.

### Common Handler Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax to filter by tool name + args, e.g. `"Bash(git *)"`. Tool events only |
| `timeout` | No | Seconds before canceling. Defaults: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent |
| `statusMessage` | No | Custom spinner message shown while hook runs |
| `once` | No | If `true`, runs once per session then is removed (skill/agent frontmatter only) |

### Command Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `command` | Yes | Shell command string (shell form) or executable (exec form when `args` present) |
| `args` | No | Argument list; enables exec form (no shell, paths need no quoting) |
| `async` | No | If `true`, runs in background without blocking |
| `asyncRewake` | No | Background + wakes Claude on exit code 2 with stderr as reminder |
| `shell` | No | `"bash"` (default) or `"powershell"` (Windows) |

### HTTP Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `url` | Yes | URL for POST request |
| `headers` | No | Additional headers; values support `$VAR` interpolation |
| `allowedEnvVars` | No | Env vars allowed to be interpolated into headers |

### MCP Tool Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `server` | Yes | Name of a connected MCP server |
| `tool` | Yes | Tool name on that server |
| `input` | No | Arguments; string values support `${path}` substitution from hook input |

### Exit Code Behavior

| Exit code | Meaning |
|:----------|:--------|
| 0 | No objection; Claude Code parses stdout for JSON output |
| 2 | Blocking signal — blocks action for blockable events; shows stderr to user for non-blockable events |
| Any other | Non-blocking error; transcript shows `<hook name> hook error` + first stderr line |

**Only exit code 2 blocks.** Exit code 1 is non-blocking. Exception: `WorktreeCreate` fails on any non-zero exit.

### JSON Output Fields (Universal)

Return JSON on stdout with exit 0 for structured control. Do not mix exit 2 with JSON — JSON is ignored on exit 2.

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely regardless of event |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hides hook stdout from transcript (still in debug log) |
| `systemMessage` | none | Warning message shown to user |
| `terminalSequence` | none | Terminal escape sequence Claude Code emits on your behalf (OSC 0/1/2/9/99/777, BEL only) |

### Decision Control by Event

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | stderr feedback or `stopReason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells model it may retry |
| `WorktreeCreate` | Path return | Command prints path to stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` override |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` replaces text on screen only |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `additionalContext`; SessionStart also: `initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side-effects only |

### PreToolUse permissionDecision Values

| Value | Effect |
|:------|:-------|
| `"allow"` | Skip interactive permission prompt (deny/ask rules still apply) |
| `"deny"` | Cancel tool call; `permissionDecisionReason` shown to Claude |
| `"ask"` | Show permission prompt to user (with source label) |
| `"defer"` | Exit gracefully for Agent SDK to collect input and resume (non-interactive `-p` only) |

When multiple PreToolUse hooks return different decisions: `deny` > `defer` > `ask` > `allow`.

### Common Input Fields (All Events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook was invoked |
| `permission_mode` | Current permission mode: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions` |
| `effort` | Object with `level` field: `low`, `medium`, `high`, `xhigh`, or `max` |
| `hook_event_name` | Name of the event that fired |

### Hook Locations and Scope

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes, committable |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes, bundled with plugin |
| Skill or agent frontmatter | While component is active | Yes, defined in component file |

Set `"disableAllHooks": true` in settings to disable all hooks. Managed hooks only disabled by managed-level setting.

### Path Placeholders

| Placeholder | Description |
|:-----------|:------------|
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Use exec form (`args` field) with path placeholders to avoid shell quoting issues.

### Environment Variables Available to Hooks

| Variable | Available in |
|:---------|:-------------|
| `CLAUDE_ENV_FILE` | `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` — write `export VAR=value` lines to persist env vars for Bash tool |
| `CLAUDE_EFFORT` | Events with effort context (`PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`) |

### Prompt and Agent Hook Response Schema

```json
{ "ok": true }           // allow
{ "ok": false, "reason": "..." }  // block (reason used as feedback to Claude)
```

What `ok: false` does per event:
- `Stop`, `SubagentStop`: reason fed to Claude as next instruction (continues working)
- `PreToolUse`: tool call denied; reason returned as tool error
- `PostToolUse`: turn ends with reason as warning (set `continueOnBlock: true` to continue instead)
- `PostToolBatch`, `UserPromptSubmit`, `UserPromptExpansion`: turn ends with warning
- `PostToolUseFailure`, `TaskCreated`, `TaskCompleted`: reason returned as tool error
- `TeammateIdle`: teammate stops with warning (set `continueOnBlock: true` to keep working)
- `PermissionRequest`, `PermissionDenied`: `ok: false` has no effect for prompt/agent hooks

### Async Hooks

Add `"async": true` to a `command` hook to run it in the background without blocking Claude. Async hooks cannot return decisions; only `additionalContext` and `systemMessage` from JSON output are processed when the background process exits.

`asyncRewake: true` — background hook that wakes Claude on exit code 2 (implies `async`).

### Stop Hook Block Cap

Claude Code overrides a Stop hook after 8 consecutive blocks. Check `stop_hook_active` in input and exit 0 to let Claude stop:

```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

Raise the cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` env var.

### Debugging Hooks

- `/hooks` — browse all configured hooks (read-only)
- `claude --debug-file /tmp/claude.log` — write debug log to known path
- `Ctrl+O` — toggle transcript view showing hook summaries
- `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` — more granular matcher/query details

### Common Troubleshooting

| Issue | Cause | Fix |
|:------|:------|:----|
| Hook not firing | Wrong event type or case-sensitive matcher mismatch | Check `/hooks`, verify matcher is exact and correctly cased |
| Hook error in output | Script exits non-zero unexpectedly | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./hook.sh` |
| JSON validation failed | Shell profile prints text on startup (contaminating stdout) | Wrap profile echo statements in `if [[ $- == *i* ]]; then ... fi` |
| `/hooks` shows nothing | Invalid JSON or wrong file path | Validate JSON, confirm `.claude/settings.json` or `~/.claude/settings.json` |
| Stop hook hits block cap | Hook never exits; `stop_hook_active` not checked | Parse `stop_hook_active` and `exit 0` when true |
| `PermissionRequest` not firing in `-p` mode | Not supported in non-interactive mode | Use `PreToolUse` hooks instead |

### Security Notes

- Command hooks run with your full user permissions — review before using
- Always quote shell variables: `"$VAR"` not `$VAR`
- Use absolute paths; prefer exec form for plugin scripts
- Block path traversal: check for `..` in file paths
- PreToolUse hooks fire before permission-mode checks; `permissionDecision: "deny"` blocks even in `bypassPermissions` mode
- A hook returning `"allow"` cannot override deny rules from settings

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate actions with hooks](references/claude-code-hooks-guide.md) — quickstart guide, common automation patterns, hook types overview, matchers, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete event schemas, JSON input/output formats, all hook handler fields, async hooks, security considerations

## Sources

- Automate actions with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
