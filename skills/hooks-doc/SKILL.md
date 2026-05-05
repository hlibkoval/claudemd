---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events and their lifecycle, configuration schema, matcher patterns, hook types (command/HTTP/MCP/prompt/agent), JSON input/output formats, exit codes, decision control per event, async hooks, security considerations, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<pattern>",
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

Three nesting levels: **hook event** → **matcher group** (with `matcher`) → **hook handlers** (array of `hooks`).

### Hook Locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

Use `/hooks` in Claude Code to browse configured hooks. Set `"disableAllHooks": true` to disable all hooks temporarily.

### All Hook Events

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `-p --init/--maintenance` | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | Slash command expands into prompt | Yes |
| `PreToolUse` | Before tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PermissionDenied` | Auto mode classifier denies tool | No (retry only) |
| `PostToolUse` | After tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After tool call fails | No |
| `PostToolBatch` | After full batch of parallel tool calls | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task created via TaskCreate | Yes |
| `TaskCompleted` | Task marked as completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No |
| `ConfigChange` | Configuration file changes | Yes (except policy) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (replaces default) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Matcher Patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

What the matcher filters per event:

| Event(s) | Filters on |
| :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart`, `SessionEnd`, `PreCompact`, `PostCompact` | Session/compaction trigger/reason |
| `Notification` | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, etc. |
| `SubagentStart`, `SubagentStop` | Agent type: `general-purpose`, `Explore`, `Plan`, custom names |
| `ConfigChange` | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, etc. |
| `InstructionsLoaded` | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | Command/skill name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `FileChanged` | Literal filenames to watch (split on `\|`, not regex) |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support |

#### MCP Tool Naming

MCP tools follow `mcp__<server>__<tool>` pattern. Use `mcp__memory__.*` (not `mcp__memory`) to match all tools from a server — the `.*` is required.

### Hook Handler Types

| Type | Description |
| :--- | :--- |
| `"command"` | Run a shell command. stdin=JSON input, exit code controls behavior |
| `"http"` | POST JSON to a URL. Response body uses same JSON output format |
| `"mcp_tool"` | Call a tool on an already-connected MCP server |
| `"prompt"` | Single-turn LLM evaluation returning `{"ok": true/false}` |
| `"agent"` | Multi-turn subagent with tool access (experimental) |

### Common Hook Handler Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax to filter: `"Bash(git *)"`, `"Edit(*.ts)"`. Only on tool events |
| `timeout` | No | Seconds before cancel. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs once per session (skill frontmatter only) |

### Command Hook Additional Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | Shell command to execute |
| `async` | No | `true` = run in background without blocking |
| `asyncRewake` | No | `true` = background, wakes Claude on exit code 2 |
| `shell` | No | `"bash"` (default) or `"powershell"` |

### HTTP Hook Additional Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `url` | Yes | URL to POST to |
| `headers` | No | HTTP headers. Values support `$VAR` interpolation for `allowedEnvVars` |
| `allowedEnvVars` | No | Env vars allowed in header value interpolation |

### MCP Tool Hook Additional Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `server` | Yes | Name of connected MCP server |
| `tool` | Yes | Tool name on that server |
| `input` | No | Tool arguments. String values support `${path}` substitution from hook input |

### Exit Code Behavior

| Exit code | Meaning |
| :--- | :--- |
| 0 | Success. Stdout parsed for JSON output |
| 2 | Blocking error. Stderr fed back as feedback. Action blocked (if event supports it) |
| Other | Non-blocking error. Execution continues. First line of stderr shown in transcript |

**Critical**: use `exit 2` not `exit 1` to block actions. Exit 1 is non-blocking.

**Exception**: `WorktreeCreate` — any non-zero exit aborts creation.

### Exit Code 2 Effect Per Event

| Event | Effect of exit 2 |
| :--- | :--- |
| `PreToolUse` | Blocks tool call |
| `PermissionRequest` | Denies permission |
| `UserPromptSubmit` | Blocks prompt, erases it |
| `UserPromptExpansion` | Blocks expansion |
| `Stop`, `SubagentStop` | Prevents stopping, continues |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Blocks action, stderr fed back |
| `ConfigChange` | Blocks config change (except policy) |
| `PostToolBatch` | Stops agentic loop |
| `PreCompact` | Blocks compaction |
| `Elicitation` | Denies elicitation |
| `ElicitationResult` | Blocks response (action becomes decline) |
| `WorktreeCreate` | Any non-zero fails creation |
| `PostToolUse`, `PostToolUseFailure` | Shows stderr to Claude (action already ran) |
| `Notification`, `SubagentStart`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `WorktreeRemove` | Shows stderr to user only |
| `StopFailure`, `PermissionDenied`, `InstructionsLoaded` | Ignored |

### JSON Output Fields (Universal)

Exit 0 and print JSON to stdout for structured control. Do NOT mix: JSON is only processed on exit 0.

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | `false` = stop Claude entirely after hook |
| `stopReason` | none | Message shown to user when `continue: false` |
| `suppressOutput` | `false` | `true` = omit stdout from debug log |
| `systemMessage` | none | Warning shown to user |

### Decision Control Per Event

| Event(s) | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | Exit 2 feeds stderr back; JSON `continue: false` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` to tell model it may retry |
| `WorktreeCreate` | path return | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### PreToolUse Decision Values

`permissionDecision` precedence when multiple hooks return different values: `deny` > `defer` > `ask` > `allow`.

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skips permission prompt (deny/ask rules still apply) |
| `"deny"` | Cancels tool call, `permissionDecisionReason` shown to Claude |
| `"ask"` | Shows permission prompt to user |
| `"defer"` | Pauses in `-p` mode for Agent SDK to collect input and resume |

### additionalContext Field

Pass a string from your hook into Claude's context window via `hookSpecificOutput.additionalContext`. Capped at 10,000 characters. Supported by: `SessionStart`, `Setup`, `SubagentStart`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`.

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Present when hook fires inside a subagent |
| `agent_type` | Present when using `--agent` or inside a subagent |

### Environment Variables in Hooks

| Variable | Available in | Description |
| :--- | :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | All command hooks | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hooks | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` | Write `export` statements to persist env vars for Bash commands |
| `$CLAUDE_CODE_REMOTE` | Command hooks | `"true"` in remote web environments |

### Prompt-Based Hooks Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

Events supporting all 5 types (command/http/mcp_tool/prompt/agent): `PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `UserPromptExpansion`, `UserPromptSubmit`.

Events supporting command/http/mcp_tool only (not prompt/agent): `ConfigChange`, `CwdChanged`, `Elicitation`, `ElicitationResult`, `FileChanged`, `InstructionsLoaded`, `Notification`, `PermissionDenied`, `PostCompact`, `PreCompact`, `SessionEnd`, `StopFailure`, `SubagentStart`, `TeammateIdle`, `WorktreeCreate`, `WorktreeRemove`.

`SessionStart` and `Setup`: command and mcp_tool only.

### PermissionRequest: updatedPermissions Entry Types

| `type` | Fields | Effect |
| :--- | :--- | :--- |
| `addRules` | `rules`, `behavior`, `destination` | Adds permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules |
| `setMode` | `mode`, `destination` | Changes permission mode |
| `addDirectories` | `directories`, `destination` | Adds working directories |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

`destination` values: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Troubleshooting

| Problem | Cause / Fix |
| :--- | :--- |
| Hook not firing | Check `/hooks` menu; verify matcher is case-sensitive; `PermissionRequest` doesn't fire in `-p` mode |
| "hook error" in transcript | Script exited non-zero unexpectedly; test manually with `echo '{"tool_name":"Bash",...}' \| ./hook.sh` |
| No hooks in `/hooks` menu | Invalid JSON (no trailing commas/comments); wrong file location; restart session |
| Stop hook infinite loop | Check `stop_hook_active` field in input and `exit 0` if `true` |
| JSON validation failed | Shell profile has unconditional `echo` — wrap in `if [[ $- == *i* ]]; then ... fi` |

**Debug**: `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`. Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher details.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — practical guide: setup walkthrough, common use cases (notifications, formatting, blocking, context injection, environment management, permission auto-approval), how hooks work, prompt/agent/HTTP hook types, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete technical specification: full event schemas, all JSON input/output formats, exit code behavior per event, async hooks, MCP tool hooks, security considerations, debug techniques

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
