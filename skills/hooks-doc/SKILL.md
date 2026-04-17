---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — shell commands, HTTP endpoints, LLM prompts, and agent verifiers that run automatically at lifecycle points to format code, block actions, send notifications, inject context, and enforce project rules.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined handlers that execute at specific points in Claude Code's lifecycle. They provide deterministic control so certain actions always happen rather than relying on the LLM to choose. Four hook types are available: `command` (shell), `http` (POST to a URL), `prompt` (single-turn LLM evaluation), and `agent` (multi-turn subagent with tool access).

### Hook events

| Event | When it fires | Matcher filters on | Can block? |
| :--- | :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | `startup`, `resume`, `clear`, `compact` | No |
| `UserPromptSubmit` | User submits a prompt | no matcher support | Yes (exit 2 or `decision: "block"`) |
| `PreToolUse` | Before a tool call executes | tool name (`Bash`, `Edit\|Write`, `mcp__.*`) | Yes (`permissionDecision: "deny"`) |
| `PermissionRequest` | Permission dialog about to show | tool name | Yes (`decision.behavior: "deny"`) |
| `PermissionDenied` | Auto-mode classifier denies a tool call | tool name | No (use `retry: true`) |
| `PostToolUse` | After a tool call succeeds | tool name | No (tool already ran) |
| `PostToolUseFailure` | After a tool call fails | tool name | No |
| `Notification` | Claude sends a notification | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` | No |
| `SubagentStart` | Subagent spawned | agent type | No |
| `SubagentStop` | Subagent finishes | agent type | Yes |
| `TaskCreated` | Task created via TaskCreate | no matcher support | Yes (exit 2) |
| `TaskCompleted` | Task marked completed | no matcher support | Yes (exit 2) |
| `Stop` | Claude finishes responding | no matcher support | Yes (`decision: "block"`) |
| `StopFailure` | Turn ends due to API error | error type (`rate_limit`, `server_error`, ...) | No |
| `TeammateIdle` | Agent team teammate about to idle | no matcher support | Yes (exit 2) |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | load reason (`session_start`, `path_glob_match`, ...) | No |
| `ConfigChange` | Config file changes during session | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | Yes (except `policy_settings`) |
| `CwdChanged` | Working directory changes | no matcher support | No |
| `FileChanged` | Watched file changes on disk | literal filenames (`.envrc\|.env`) | No |
| `WorktreeCreate` | Worktree being created | no matcher support | Yes (any non-zero exit) |
| `WorktreeRemove` | Worktree being removed | no matcher support | No |
| `PreCompact` | Before context compaction | `manual`, `auto` | Yes |
| `PostCompact` | After compaction completes | `manual`, `auto` | No |
| `Elicitation` | MCP server requests user input | MCP server name | Yes |
| `ElicitationResult` | After user responds to MCP elicitation | MCP server name | Yes |
| `SessionEnd` | Session terminates | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | No |

### Configuration structure

Hooks go in a `hooks` key inside a settings file. Three levels of nesting:

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

### Hook handler fields

**Common fields** (all types):

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax filter (e.g. `"Bash(git *)"`, `"Edit(*.ts)"`). Tool events only |
| `timeout` | no | Seconds. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | no | Custom spinner text while hook runs |
| `once` | no | If `true`, runs only once per session then removed. Skills only |

**Command-specific**: `command` (required), `async`, `asyncRewake`, `shell` (`"bash"` or `"powershell"`)

**HTTP-specific**: `url` (required), `headers`, `allowedEnvVars`

**Prompt/Agent-specific**: `prompt` (required), `model`

### Hook locations (scope)

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (committed) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Exit codes

| Exit code | Meaning |
| :--- | :--- |
| **0** | Success; stdout parsed for JSON. For `UserPromptSubmit`/`SessionStart`, stdout added as context |
| **2** | Blocking error; stderr fed back to Claude. Blocks the action for events that support it |
| **Other** | Non-blocking error; first line of stderr shown in transcript |

### Matcher patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters/digits/`_`/`\|` | Exact string or pipe-separated list |
| Contains other characters | JavaScript regex |

### Decision control patterns

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange, PreCompact | Top-level `decision` | `decision: "block"`, `reason` |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message` |
| PermissionDenied | `hookSpecificOutput` | `retry: true` to allow model to retry |
| TeammateIdle, TaskCreated, TaskCompleted | Exit code or `continue: false` | Exit 2 blocks with stderr feedback |
| WorktreeCreate | Path return | stdout (command) or `hookSpecificOutput.worktreePath` (HTTP) |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |

### Universal JSON output fields

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Omits stdout from debug log |
| `systemMessage` | none | Warning message shown to user |

### Environment variables

| Variable | Available in | Purpose |
| :--- | :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root path |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hooks | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | SessionStart, CwdChanged, FileChanged | Write `export` statements to persist env vars |
| `$CLAUDE_CODE_REMOTE` | All hooks | `"true"` in remote web environments |

### Prompt and agent hooks

Prompt (`type: "prompt"`) and agent (`type: "agent"`) hooks use an LLM to evaluate decisions instead of a shell command. The model returns `{"ok": true}` to allow or `{"ok": false, "reason": "..."}` to block. Agent hooks can additionally use tools (Read, Grep, Glob) across up to 50 turns. Use `$ARGUMENTS` in the prompt to inject hook input JSON.

Supported by: PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, UserPromptSubmit, Stop, SubagentStop, TaskCreated, TaskCompleted.

### Async hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately. Output delivered on the next conversation turn. Cannot block actions. Set `"asyncRewake": true` to wake Claude on exit code 2.

### Common recipes

| Use case | Event | Matcher | Hook type |
| :--- | :--- | :--- | :--- |
| Desktop notifications | `Notification` | `""` | command |
| Auto-format after edits | `PostToolUse` | `Edit\|Write` | command |
| Block protected files | `PreToolUse` | `Edit\|Write` | command |
| Re-inject context after compaction | `SessionStart` | `compact` | command |
| Audit config changes | `ConfigChange` | `""` | command |
| Reload env on directory change | `CwdChanged` | (none) | command |
| Auto-approve permission prompts | `PermissionRequest` | tool name | command |
| Verify tasks complete before stop | `Stop` | (none) | prompt/agent |

### Key rules

- PreToolUse hooks fire **before** any permission-mode check. A hook returning `deny` blocks even in `bypassPermissions` mode.
- A hook returning `allow` does **not** bypass deny rules from settings. Hooks tighten but cannot loosen restrictions.
- When multiple hooks match, each returns its own result. Most restrictive wins (`deny` > `defer` > `ask` > `allow`).
- When multiple PreToolUse hooks return `updatedInput`, the last to finish wins (non-deterministic).
- Stop hooks: check `stop_hook_active` to avoid infinite loops.
- `PermissionRequest` hooks do **not** fire in non-interactive mode (`-p`). Use `PreToolUse` instead.
- Hook output injected into context is capped at 10,000 characters.
- Disable all hooks: set `"disableAllHooks": true` in settings.
- Debug: `claude --debug-file /tmp/claude.log` or `/debug` mid-session. Transcript view (`Ctrl+O`) shows one-line summaries.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas, JSON input/output formats, exit codes, matcher patterns, decision control, async hooks, HTTP hooks, prompt-based hooks, agent-based hooks, MCP tool hooks, security considerations, and debugging.
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- getting started guide with step-by-step setup, common automation recipes (notifications, formatting, file protection, context re-injection, config auditing, environment reload, auto-approval), hook types overview, matcher examples, prompt and agent hooks, HTTP hooks, and troubleshooting.

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
