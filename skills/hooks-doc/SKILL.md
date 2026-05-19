---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — all hook events (SessionStart through SessionEnd), hook handler types (command, HTTP, MCP tool, prompt, agent), JSON input/output formats, exit codes, decision control, matcher patterns, async hooks, background hooks, security considerations, and common automation patterns.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Configuration Structure

Hooks are defined in JSON settings files with three levels of nesting:

1. **Hook event** — the lifecycle point (e.g., `PreToolUse`, `Stop`)
2. **Matcher group** — filter when it fires (e.g., `"matcher": "Edit|Write"`)
3. **Hook handlers** — what runs when matched (command, HTTP, prompt, agent, MCP tool)

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
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No — local to your machine |
| `.claude/settings.json` | Single project | Yes — commit to repo |
| `.claude/settings.local.json` | Single project | No — gitignored |
| Managed policy settings | Organization-wide | Yes — admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes — bundled with plugin |
| Skill or agent frontmatter | While component is active | Yes — defined in component file |

### All Hook Events

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `-p --init`/`--maintenance` | No |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | Slash command expands to prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PermissionDenied` | Auto-mode classifier denies a tool call | No (can set retry) |
| `PostToolUse` | After a tool call succeeds | No (can inject feedback) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After all parallel tool calls resolve | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task being created via `TaskCreate` | Yes |
| `TaskCompleted` | Task being marked as completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `ConfigChange` | Configuration file changes during session | Yes (except policy_settings) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero = fail) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Matcher Patterns

| Event | What the matcher filters | Example values |
| :--- | :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | which CLI flag | `init`, `maintenance` |
| `SessionEnd` | why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | trigger | `manual`, `auto` |
| `ConfigChange` | configuration source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | command name | skill or command names |
| `Elicitation`, `ElicitationResult` | MCP server name | configured MCP server names |
| `FileChanged` | literal filenames to watch (split on `\|`) | `.envrc\|.env` |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires |

Matcher evaluation rules:
- `"*"`, `""`, or omitted: match all
- Only letters/digits/underscore/pipe: exact string or pipe-separated list
- Contains any other character: evaluated as JavaScript regular expression

### Hook Handler Types

| Type | Description | Key fields |
| :--- | :--- | :--- |
| `command` | Run a shell command | `command`, `args` (exec form), `async`, `asyncRewake`, `shell` |
| `http` | POST event data to a URL | `url`, `headers`, `allowedEnvVars` |
| `mcp_tool` | Call a tool on an MCP server | `server`, `tool`, `input` |
| `prompt` | Single-turn LLM evaluation (Haiku by default) | `prompt`, `model`, `continueOnBlock` |
| `agent` | Multi-turn subagent with tool access (experimental) | `prompt`, `model`, `timeout` |

### Common Handler Fields (all types)

| Field | Description |
| :--- | :--- |
| `type` | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | Permission rule syntax filter: `"Bash(git *)"`, `"Edit(*.ts)"`. Only on tool events |
| `timeout` | Seconds before canceling. Defaults: 600 (command/http/mcp_tool), 30 (prompt), 60 (agent). `UserPromptSubmit` lowers to 30 |
| `statusMessage` | Custom spinner message while hook runs |
| `once` | If `true`, runs once per session then removed (skill frontmatter only) |

### Exit Codes

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success — JSON output (if any) is processed |
| `2` | Blocking error — stderr fed to Claude as feedback; blocks action if event supports it |
| Any other | Non-blocking error — transcript shows `<hook name> hook error`; execution continues |

**Important**: Only exit code 2 blocks (not exit code 1). `WorktreeCreate` is the exception: any non-zero exit fails creation.

### JSON Output Fields (universal)

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops entirely regardless of event |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | none | Warning shown to the user |
| `terminalSequence` | none | Terminal escape sequence (OSC 0/1/2/9/99/777 or BEL) emitted on your behalf (v2.1.141+) |

### Decision Control by Event

| Events | Decision pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `WorktreeCreate` | Path return | Command hook prints path on stdout; HTTP hook returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr feedback |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### PreToolUse Decision Values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skips interactive permission prompt. Deny/ask rules still evaluated |
| `"deny"` | Cancels tool call; `permissionDecisionReason` sent to Claude |
| `"ask"` | Shows permission prompt to user |
| `"defer"` | Exits process with `stop_reason: "tool_deferred"` for `-p` mode integrations (v2.1.89+) |

When multiple PreToolUse hooks conflict: `deny` > `defer` > `ask` > `allow`.

### Context Injection (additionalContext)

Return `additionalContext` inside `hookSpecificOutput` to inject text into Claude's context:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts instead."
  }
}
```

Where it appears depends on the event: SessionStart/Setup/SubagentStart inject before the first prompt; PreToolUse/PostToolUse inject next to the tool result; UserPromptSubmit injects alongside the prompt.

### Path Placeholders

| Placeholder | Resolves to |
| :--- | :--- |
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Prefer exec form (`"args": []`) for hooks referencing path placeholders — each `args` element passes as one argument with no shell tokenization.

### Exec Form vs Shell Form

| Form | When | Use when |
| :--- | :--- | :--- |
| Shell form | `args` is absent | Need pipes, `&&`, redirects, globs |
| Exec form | `args` is present | Referencing path placeholders; avoiding quoting issues |

### Environment Variables Available to Hooks

| Variable | Available in |
| :--- | :--- |
| `CLAUDE_ENV_FILE` | `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` — write `export VAR=value` to persist env vars to Bash commands |
| `CLAUDE_PROJECT_DIR` | All command hooks |
| `CLAUDE_PLUGIN_ROOT` | Command hooks in plugins |
| `CLAUDE_PLUGIN_DATA` | Command hooks in plugins |
| `CLAUDE_EFFORT` | Hooks within tool-use context (PreToolUse, PostToolUse, Stop, SubagentStop) |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

### Async Hooks

Set `"async": true` on a command hook to run in the background while Claude continues:

- Only `type: "command"` supports `async`
- Cannot block or control Claude's behavior (action already completed)
- Results (including `additionalContext`) delivered on next conversation turn
- `asyncRewake: true` wakes Claude when background hook exits with code 2

### Hook Types Supported per Event

All 5 types (`command`, `http`, `mcp_tool`, `prompt`, `agent`):
`PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `UserPromptExpansion`, `UserPromptSubmit`

Only `command`, `http`, `mcp_tool`:
`ConfigChange`, `CwdChanged`, `Elicitation`, `ElicitationResult`, `FileChanged`, `InstructionsLoaded`, `Notification`, `PermissionDenied`, `PostCompact`, `PreCompact`, `SessionEnd`, `StopFailure`, `SubagentStart`, `TeammateIdle`, `WorktreeCreate`, `WorktreeRemove`

Only `command` and `mcp_tool`:
`SessionStart`, `Setup`

### Prompt/Agent Hook Response Schema

```json
{ "ok": true }
```
or
```json
{ "ok": false, "reason": "Explanation" }
```

On `ok: false`: Stop/SubagentStop feed reason back to Claude; PreToolUse denies with reason as tool error; PostToolUse ends turn (or feeds back with `continueOnBlock: true`); PostToolBatch/UserPromptSubmit/UserPromptExpansion end turn.

### Hooks in Skills and Agents (Frontmatter)

```yaml
---
name: secure-operations
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

For subagents, `Stop` hooks are auto-converted to `SubagentStop`. The `once: true` field (on handlers) is honored only in skill frontmatter.

### Common Use Cases

| Goal | Event | Hook type |
| :--- | :--- | :--- |
| Desktop notification when Claude needs input | `Notification` | `command` (osascript/notify-send/PowerShell) |
| Auto-format code after edits | `PostToolUse` with `Edit\|Write` matcher | `command` (prettier, eslint) |
| Block edits to protected files | `PreToolUse` with `Edit\|Write` matcher | `command` (exit 2) |
| Re-inject context after compaction | `SessionStart` with `compact` matcher | `command` |
| Audit configuration changes | `ConfigChange` | `command` |
| Reload direnv on directory change | `CwdChanged` + `FileChanged` | `command` writing to `CLAUDE_ENV_FILE` |
| Auto-approve specific permission prompts | `PermissionRequest` | `command` (JSON with `behavior: "allow"`) |
| Enforce task criteria | `TaskCompleted` | `command` or `prompt` |
| LLM-based completion check | `Stop` | `prompt` or `agent` |
| Log all Bash commands | `PostToolUse` with `Bash` matcher | `command` |
| Watch for file changes | `FileChanged` | `command` |
| Custom worktree creation (non-git VCS) | `WorktreeCreate` | `command` (print path on stdout) |

### Debugging Hooks

- `/hooks` — read-only browser showing all configured hooks grouped by event, with source file info
- `Ctrl+O` — transcript view with one-line hook summaries
- `claude --debug-file /tmp/claude.log` — full execution details (exit codes, stdout, stderr)
- `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` — additional matcher details

### Stop Hook: Avoiding the Block Cap

Claude Code overrides a Stop hook after 8 consecutive blocks. Check `stop_hook_active` to avoid infinite loops:

```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

Override the cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

### Security Notes

- Command hooks run with your full user permissions
- Always quote shell variables: use `"$VAR"` not `$VAR`
- Validate and sanitize inputs; check for `..` in file paths
- Use absolute paths for scripts
- Avoid `.env`, `.git/`, keys in hook scope
- `allowManagedHooksOnly` in managed settings blocks user/project/plugin hooks
- PreToolUse hooks fire before permission-mode checks — `deny` blocks even in `bypassPermissions` mode
- A hook returning `"allow"` does not override deny rules from settings

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide, common use cases, how hooks work, prompt-based hooks, agent hooks, HTTP hooks, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, exit codes, async hooks, all hook handler types, security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
