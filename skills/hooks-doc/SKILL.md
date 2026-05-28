---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Configuration Structure

Hooks are defined in JSON settings files with three levels of nesting:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<filter>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell command>"
          }
        ]
      }
    ]
  }
}
```

### Hook Locations (Scope)

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes |
| `.claude/settings.local.json` | Single project | No |
| Managed policy settings | Organization-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### All Hook Events

| Event | When it fires | Blockable? |
|:------|:--------------|:-----------|
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `-p --init/--maintenance` | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | Slash command expands | Yes |
| `PreToolUse` | Before tool executes | Yes |
| `PermissionRequest` | Permission dialog shown | Yes |
| `PermissionDenied` | Auto-mode classifier denies tool | No (retry only) |
| `PostToolUse` | After tool succeeds | No (feedback only) |
| `PostToolUseFailure` | After tool fails | No |
| `PostToolBatch` | After parallel tool batch resolves | Yes |
| `Notification` | Claude sends a notification | No |
| `MessageDisplay` | Assistant message streams | No |
| `SubagentStart` | Subagent spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task created via TaskCreate | Yes |
| `TaskCompleted` | Task marked completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate goes idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No |
| `ConfigChange` | Config file changes during session | Yes (not policy) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Matcher Patterns by Event

| Event | Matcher filters | Example values |
|:------|:----------------|:---------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | session source | `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag | `init`, `maintenance` |
| `SessionEnd` | exit reason | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | trigger | `manual`, `auto` |
| `ConfigChange` | config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | your server names |
| `FileChanged` | literal filenames (pipe-separated, not regex) | `.envrc\|.env` |
| `UserPromptExpansion` | command name | your skill/command names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | no matcher support | always fires |

Matcher evaluation rules:
- `"*"`, `""`, or omitted: match all
- Only letters, digits, `_`, `|`: exact string or pipe-separated list
- Contains other characters: JavaScript regular expression

### Hook Handler Types

| Type | Description | Async? |
|:-----|:------------|:-------|
| `command` | Run a shell command | Yes (with `async: true`) |
| `http` | POST event data to a URL | No |
| `mcp_tool` | Call a tool on a connected MCP server | No |
| `prompt` | Single-turn LLM evaluation (Haiku by default) | No |
| `agent` | Multi-turn subagent with tool access (experimental) | No |

### Common Hook Handler Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | yes | `command`, `http`, `mcp_tool`, `prompt`, or `agent` |
| `if` | no | Permission rule syntax for tool-call filtering (e.g., `"Bash(git *)"`, `"Edit(*.ts)"`) — only on tool events |
| `timeout` | no | Seconds before canceling (defaults: 600 for command/http/mcp_tool, 30 for prompt, 60 for agent) |
| `statusMessage` | no | Custom spinner message |
| `once` | no | Run once per session (skill frontmatter only) |

### Exit Code Behavior

| Exit code | Meaning |
|:----------|:--------|
| `0` | No decision; normal flow applies. JSON output is processed. |
| `2` | Blocking error. stderr fed to Claude (or shown to user for non-blockable events). JSON ignored. |
| Other | Non-blocking error. Transcript shows `<hook name> hook error` + first line of stderr. |

Note: `WorktreeCreate` is an exception — any non-zero exit code fails worktree creation.

### Universal JSON Output Fields

Return these from any hook with exit code 0:

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely |
| `stopReason` | none | Message to user when `continue: false` |
| `suppressOutput` | `false` | Hide stdout from transcript |
| `systemMessage` | none | Warning shown to user |
| `terminalSequence` | none | Terminal escape sequence (OSC 0/1/2/9/99/777, BEL) — requires v2.1.141+ |

### Decision Control by Event

| Events | Decision pattern | Key fields |
|:-------|:-----------------|:-----------|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `WorktreeCreate` | path return | Print path on stdout (command) or `hookSpecificOutput.worktreePath` (HTTP) |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` (override) |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` (replaces rendered text, not transcript) |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `hookSpecificOutput.additionalContext` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### Common Input Fields (All Events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook invoked |
| `permission_mode` | Current permission mode |
| `effort` | Active effort level object |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Present inside subagent calls |
| `agent_type` | Agent name when using `--agent` or in subagent |

### Path Placeholders

| Placeholder | Resolves to |
|:------------|:------------|
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

### Exec Form vs Shell Form

- **Shell form** (no `args`): `command` passed to `sh -c` (macOS/Linux) or Git Bash (Windows). Supports pipes, `&&`, redirects.
- **Exec form** (`args` present): `command` resolved as executable, `args` as argument vector, no shell tokenization. Prefer for path placeholders.

### Hook Timeouts

| Type | Default | Note |
|:-----|:--------|:-----|
| `command`, `http`, `mcp_tool` | 600s (10 min) | `UserPromptSubmit` lowers to 30s |
| `prompt` | 30s | |
| `agent` | 60s | |
| `SessionEnd` | 1.5s | Raised to highest per-hook timeout, max 60s |

Override per hook with `timeout` field (in seconds).

### Async Hooks

Add `"async": true` to a `command` hook to run in background. Claude continues immediately.
- Cannot block or return decisions
- `additionalContext` is delivered on next conversation turn
- Use `asyncRewake: true` to wake Claude when the async hook exits with code 2

### Prompt-Based and Agent Hooks

**Prompt hooks** (`type: "prompt"`): single LLM call returning `{"ok": true}` or `{"ok": false, "reason": "..."}`.

**Agent hooks** (`type: "agent"`): spawns subagent with tool access (experimental), same response format, longer default timeout (60s), up to 50 tool turns.

Supported by all five hook types: `PermissionDenied`, `PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `TeammateIdle`, `UserPromptExpansion`, `UserPromptSubmit`.

`SessionStart` and `Setup` support `command` and `mcp_tool` only.

Use `$ARGUMENTS` placeholder in `prompt` to inject hook input JSON. Use `continueOnBlock: true` to feed the block reason back to Claude and continue instead of stopping.

### SessionStart-Specific Outputs

| Field | Description |
|:------|:------------|
| `additionalContext` | Text added to Claude's context at session start |
| `initialUserMessage` | First user message (non-interactive mode only) |
| `sessionTitle` | Sets session title (startup and resume only) |
| `watchPaths` | Array of absolute paths to watch for `FileChanged` |
| `reloadSkills` | Re-scan skills after SessionStart hooks complete |

### Environment Variable: CLAUDE_ENV_FILE

Available to `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export VAR=value` lines to persist environment variables for subsequent Bash commands in the session. Use `>>` to append (not overwrite).

### MCP Tool Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `server` | yes | MCP server name (must already be connected) |
| `tool` | yes | Tool name on that server |
| `input` | no | Tool arguments; string values support `${path}` substitution from hook input |

### HTTP Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `url` | yes | URL to POST event data to |
| `headers` | no | Additional headers; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | no | Variables allowed to be interpolated into header values |

HTTP hooks: non-2xx responses and connection failures are non-blocking. Use 2xx with JSON decision body to block.

### Security Best Practices

- Validate and sanitize all inputs
- Always quote shell variables: `"$VAR"` not `$VAR`
- Block path traversal: check for `..` in file paths
- Use absolute paths (use `${CLAUDE_PROJECT_DIR}` in shell form with double quotes)
- Skip sensitive files: `.env`, `.git/`, keys

### Debugging Hooks

- `/hooks` command: read-only browser showing all configured hooks by event
- `Ctrl+O`: transcript view showing one-line hook summaries
- `claude --debug-file /tmp/claude.log`: write full debug log including hook execution details, exit codes, stdout/stderr
- `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose`: additional matcher/query details

### Stop Hook Block Cap

`Stop` hooks blocked 8 consecutive times without progress are overridden. Check `stop_hook_active` in input and exit early if `true`:

```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

Override cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` env var.

### Hooks in Skill/Agent Frontmatter

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
```

All events supported. For subagents, `Stop` hooks are auto-converted to `SubagentStop`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) — Full event schemas, JSON input/output formats, exit codes, async hooks, HTTP hooks, prompt/agent hooks, and MCP tool hooks
- [Automate Workflows with Hooks (Guide)](references/claude-code-hooks-guide.md) — Common use cases, setup walkthrough, and troubleshooting guide

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Automate Workflows with Hooks (Guide): https://code.claude.com/docs/en/hooks-guide.md
