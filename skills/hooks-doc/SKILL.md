---
name: hooks-doc
description: Claude Code hooks — hook events (all 27 events, lifecycle, matchers), hook handler types (command/http/prompt/agent), exit codes, JSON input/output, decision control per event, async hooks, CLAUDE_ENV_FILE, troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook handler types

| Type | Field | What it does |
|---|---|---|
| `command` | `command` (required) | Runs a shell command. Receives JSON on stdin; communicates via exit codes, stdout, stderr |
| `http` | `url` (required) | POSTs JSON to an HTTP endpoint; response body uses same JSON format as command hooks |
| `prompt` | `prompt` (required) | Single-turn LLM evaluation returning `{"ok": true/false, "reason": "..."}` |
| `agent` | `prompt` (required) | Spawns a subagent with tool access (experimental). Same ok/reason format; 60s default timeout, up to 50 tool turns |

### Common handler fields (all types)

| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission-rule syntax to filter by tool+args, e.g. `"Bash(git *)"` or `"Edit(*.ts)"`. Only works on tool events |
| `timeout` | no | Seconds. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | no | Custom spinner text while hook runs |
| `once` | no | Run once per session then remove. Only honored in skill/agent frontmatter |

### Command hook extra fields

| Field | Notes |
|---|---|
| `async` | Run in background without blocking |
| `asyncRewake` | Background + wake Claude on exit 2 (implies `async`) |
| `shell` | `"bash"` (default) or `"powershell"` |

### HTTP hook extra fields

| Field | Notes |
|---|---|
| `headers` | Key-value pairs; values support `$VAR` interpolation (only vars listed in `allowedEnvVars`) |
| `allowedEnvVars` | List of env var names allowed in header interpolation |

---

### Hook locations and scope

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (committable) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill / agent frontmatter | While component is active | Yes |

Disable all hooks: `"disableAllHooks": true` in any settings file. Individual hooks cannot be disabled without removing them.

---

### All hook events

| Event | When it fires | Can block? | Matcher field |
|---|---|---|---|
| `SessionStart` | Session begins or resumes | No | `source`: `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | `load_reason`: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptSubmit` | User submits a prompt | Yes | No matcher |
| `UserPromptExpansion` | Slash command expands to prompt | Yes | `command_name` |
| `PreToolUse` | Before tool call executes | Yes | `tool_name` |
| `PermissionRequest` | Permission dialog appears | Yes | `tool_name` |
| `PermissionDenied` | Tool call denied by auto mode | No | `tool_name` |
| `PostToolUse` | After tool call succeeds | No (stderr shown to Claude) | `tool_name` |
| `PostToolUseFailure` | After tool call fails | No (stderr shown to Claude) | `tool_name` |
| `SubagentStart` | Subagent spawned | No | `agent_type` |
| `SubagentStop` | Subagent finishes | Yes | `agent_type` |
| `TaskCreated` | Task created via TaskCreate | Yes | No matcher |
| `TaskCompleted` | Task marked complete | Yes | No matcher |
| `Stop` | Claude finishes responding | Yes | No matcher |
| `StopFailure` | Turn ends via API error (output/exit code ignored) | No | `error_type`: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Agent team teammate about to go idle | Yes | No matcher |
| `ConfigChange` | Config file changes during session | Yes | `source`: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | No | No matcher |
| `FileChanged` | Watched file changes on disk | No | Literal filenames: `.envrc\|.env` |
| `PreCompact` | Before context compaction | Yes | `manual`, `auto` |
| `PostCompact` | After context compaction | No | `manual`, `auto` |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero exit) | No matcher |
| `WorktreeRemove` | Worktree being removed | No | No matcher |
| `Notification` | Claude Code sends a notification | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

---

### Exit codes

| Exit code | Effect |
|---|---|
| `0` | Success. stdout parsed for JSON. For `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`: stdout added to Claude's context |
| `2` | Blocking error. stdout/JSON ignored; stderr fed to Claude as feedback. See "Can block?" column above |
| Any other | Non-blocking error. Execution continues. Transcript shows hook error notice + first line of stderr |

**Warning:** Exit 1 is non-blocking — use exit 2 to enforce policy. Exception: `WorktreeCreate` fails on any non-zero exit.

---

### JSON output fields (exit 0)

| Field | Default | Description |
|---|---|---|
| `continue` | `true` | `false` stops Claude entirely (overrides all event-specific decisions) |
| `stopReason` | none | Message to user when `continue: false`. Not shown to Claude |
| `suppressOutput` | `false` | Omit stdout from debug log |
| `systemMessage` | none | Warning message shown to user |

Context output (`additionalContext`, `systemMessage`, plain stdout) is capped at 10,000 characters.

---

### Decision control by event

| Events | How to block/control |
|---|---|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | `{"decision": "block", "reason": "..."}` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2, or `{"continue": false, "stopReason": "..."}` |
| `PreToolUse` | `hookSpecificOutput.permissionDecision`: `"allow"`, `"deny"`, `"ask"`, or `"defer"` (non-interactive only) |
| `PermissionRequest` | `hookSpecificOutput.decision.behavior`: `"allow"` or `"deny"` |
| `PermissionDenied` | `hookSpecificOutput.retry: true` (tells model it may retry) |
| `WorktreeCreate` | Command hook prints path to stdout; any failure aborts creation |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput.action`: `"accept"`, `"decline"`, or `"cancel"` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | No decision control (side-effects only) |

**PreToolUse note:** `"allow"` skips the interactive prompt but does not override permission deny rules. Deny rules always win over hook approvals.

---

### Matcher patterns

| Matcher value | Evaluated as |
|---|---|
| `""`, `"*"`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list of exact strings |
| Contains any other character | JavaScript regular expression |

MCP tool naming: `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from a server (bare `mcp__memory` matches nothing — exact string, no tool has that name).

---

### Common input fields (all events)

| Field | Description |
|---|---|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSONL |
| `cwd` | Working directory when hook fires |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions` (not all events) |
| `hook_event_name` | Event name that fired |
| `agent_id` | Present inside subagent calls |
| `agent_type` | Agent name when using `--agent` or inside a subagent |

---

### CLAUDE_ENV_FILE — persist environment variables

Available to `SessionStart`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to this path; Claude Code runs the file as a script preamble before each Bash command.

```bash
# Use append (>>) to preserve vars from other hooks
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

Useful pattern: pair `SessionStart` + `CwdChanged` with `direnv export bash > "$CLAUDE_ENV_FILE"` to auto-load per-directory environments.

---

### Stop hook — prevent infinite loops

If your `Stop` hook continues the conversation, check `stop_hook_active` to avoid looping:

```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
# ... rest of hook logic
```

---

### `if` field — filter by tool + arguments

Requires Claude Code v2.1.85+. Uses permission-rule syntax. Only works on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`).

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-git-policy.sh"
          }
        ]
      }
    ]
  }
}
```

For compound commands (`npm test && git push`), each subcommand is evaluated — the hook fires if any subcommand matches. Always fires when the command is too complex to parse.

---

### Path variables for hook scripts

| Variable | Expands to |
|---|---|
| `$CLAUDE_PROJECT_DIR` | Project root (quote to handle spaces) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (survives updates) |

---

### Troubleshooting quick reference

| Symptom | Fix |
|---|---|
| Hook never fires | Run `/hooks` to verify it appears; check matcher is case-correct; verify event type is right; `PermissionRequest` doesn't fire with `-p` (use `PreToolUse` instead) |
| Hook error in transcript | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./my-hook.sh`; use absolute paths or `$CLAUDE_PROJECT_DIR`; `chmod +x` the script |
| `/hooks` shows nothing | Check JSON validity (no trailing commas/comments); verify file location; restart session if file watcher missed it |
| JSON validation failed | Shell profile may be printing to stdout; wrap echo statements: `if [[ $- == *i* ]]; then echo ...; fi` |
| Infinite Stop loop | Parse `stop_hook_active` field and `exit 0` if `true` |

For full execution traces: `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [claude-code-hooks-guide.md](references/claude-code-hooks-guide.md) — Quickstart guide: common use cases, patterns, setup walkthrough, troubleshooting
- [claude-code-hooks-reference.md](references/claude-code-hooks-reference.md) — Full reference: all event schemas, JSON input/output, decision control, async hooks, HTTP hooks, prompt/agent hooks

## Sources

- Hooks guide: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
