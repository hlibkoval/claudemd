---
name: hooks-doc
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks — user-defined shell commands, HTTP endpoints, LLM prompts, and agents that execute automatically at specific lifecycle points.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? |
|:------|:-------------|:-----------|
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `-p --init`/`--maintenance` | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | Slash command expands before reaching Claude | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog is about to appear | Yes (deny) |
| `PermissionDenied` | Auto mode classifier denies a tool call | No (retry only) |
| `PostToolUse` | After a tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | No (feedback only) |
| `PostToolBatch` | After a full batch of parallel tool calls | Yes (stop loop) |
| `Notification` | Claude Code sends a notification | No |
| `MessageDisplay` | Assistant message streams to screen | No (display replace only) |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task being created via `TaskCreate` | Yes |
| `TaskCompleted` | Task being marked completed | Yes |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `ConfigChange` | Configuration file changes during session | Yes (except policy) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Types

| Type | `type` value | Use case |
|:-----|:-------------|:---------|
| Command | `"command"` | Run a shell command; stdin/stdout/exit codes |
| HTTP | `"http"` | POST event data to a URL |
| MCP tool | `"mcp_tool"` | Call a tool on a connected MCP server |
| Prompt | `"prompt"` | Single-turn LLM evaluation (yes/no decision) |
| Agent | `"agent"` | Multi-turn subagent with tool access (experimental) |

### Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<pattern or empty>",
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
|:---------|:------|:---------|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Matcher Patterns

| Matcher value | Evaluated as |
|:-------------|:-------------|
| `""`, `"*"`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list |
| Contains any other character | JavaScript regex |

What the matcher filters by event:

| Events | Matches on |
|:-------|:----------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `SessionStart` | Session source: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag: `init`, `maintenance` |
| `SessionEnd` | Exit reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | Agent type: `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | Trigger: `manual`, `auto` |
| `ConfigChange` | Source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `FileChanged` | Literal filenames (split on `\|`, not regex) |
| `UserPromptExpansion` | Command name |
| `InstructionsLoaded` | Load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`, `MessageDisplay` | No matcher support |

### Common Hook Handler Fields

| Field | Required | Description |
|:------|:---------|:-----------|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter by tool+args (tool events only): `"Bash(git *)"`, `"Edit(*.ts)"` |
| `timeout` | no | Seconds to cancel. Defaults: 600 (`command`/`http`/`mcp_tool`), 30 (`prompt`), 60 (`agent`). `UserPromptSubmit` lowers to 30 for command/http/mcp_tool |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs once per session then removed (skill frontmatter only) |

### Command Hook Fields

| Field | Description |
|:------|:-----------|
| `command` | Shell command (shell form) or executable path (exec form when `args` is set) |
| `args` | Argument list; triggers exec form (no shell, no tokenization) |
| `async` | If `true`, runs in background without blocking |
| `asyncRewake` | If `true`, async but wakes Claude on exit code 2 |
| `shell` | `"bash"` (default) or `"powershell"` |

**Exec form vs shell form:** Set `args: []` to use exec form (spawns executable directly, no shell). Omit `args` for shell form (uses `sh -c` or Git Bash). Prefer exec form when referencing path placeholders.

### Exit Codes

| Code | Meaning |
|:-----|:--------|
| 0 | No objection; JSON output (if any) is parsed for structured control |
| 2 | Block the action; stderr is fed back to Claude (or shown to user for non-blockable events) |
| Other | Non-blocking error; first line of stderr shown in transcript |

**Note:** Only exit code 2 blocks. Exit code 1 is non-blocking — use `exit 2` to enforce policy.

### JSON Output Fields (Universal)

| Field | Description |
|:------|:-----------|
| `continue` | If `false`, Claude stops entirely (takes precedence over event-specific decisions) |
| `stopReason` | Message shown to user when `continue` is `false` |
| `suppressOutput` | If `true`, hides hook stdout from transcript |
| `systemMessage` | Warning shown to the user |
| `terminalSequence` | Terminal escape sequence for Claude Code to emit (OSC 0/1/2/9/99/777, BEL only; requires v2.1.141+) |

### Decision Control by Event

| Events | Pattern | Key fields |
|:-------|:--------|:----------|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` (tells model it may retry) |
| `WorktreeCreate` | Return path | Command: print path on stdout; HTTP: `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `MessageDisplay` | `hookSpecificOutput` | `displayContent` (replaces display text only) |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `hookSpecificOutput.additionalContext`, plus `SessionStart` supports `initialUserMessage`, `watchPaths`, `sessionTitle`, `reloadSkills` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects / logging only |

### `PreToolUse` Permission Decisions

| Value | Effect |
|:------|:-------|
| `"allow"` | Skip permission prompt (deny/ask rules still evaluated) |
| `"deny"` | Cancel the tool call; reason sent to Claude |
| `"ask"` | Show permission prompt to user |
| `"defer"` | Exit process so Agent SDK wrapper can collect input and resume (non-interactive `-p` only) |

When multiple `PreToolUse` hooks return decisions, precedence: `deny` > `defer` > `ask` > `allow`.

### `additionalContext` — Injecting Context for Claude

Return inside `hookSpecificOutput` alongside `hookEventName`. Delivery timing:

- `SessionStart`, `Setup`, `SubagentStart`: at start of conversation
- `UserPromptSubmit`, `UserPromptExpansion`: alongside submitted prompt
- `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`: next to tool result

Write as factual statements (`"The deployment target is production"`) not system instructions, to avoid prompt-injection defenses.

### Common Input Fields (All Events)

| Field | Description |
|:------|:-----------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `effort` | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"`, `"ultra"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside subagent) |

### Path Placeholders

| Placeholder | Resolves to |
|:-----------|:-----------|
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

### Environment Variables Available in Hooks

| Variable | Available in |
|:---------|:-----------|
| `CLAUDE_ENV_FILE` | `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` — write `export` statements to persist env vars for subsequent Bash commands |
| `CLAUDE_CODE_REMOTE` | All hooks — `"true"` in remote web environments |
| `CLAUDE_EFFORT` | Hooks firing within tool-use context |

### Async Hooks

Set `"async": true` on command hooks to run in background without blocking Claude. Restrictions:
- Only `type: "command"` supports async
- Cannot return decisions (action already proceeded)
- `additionalContext` from `hookSpecificOutput` is delivered on the next turn
- Use `asyncRewake: true` to wake Claude immediately on exit code 2

### Prompt-Based Hooks (`type: "prompt"`)

| Field | Required | Description |
|:------|:---------|:-----------|
| `type` | yes | `"prompt"` |
| `prompt` | yes | Prompt text; use `$ARGUMENTS` as placeholder for hook JSON input |
| `model` | no | Model for evaluation (defaults to fast model) |
| `timeout` | no | Default: 30 seconds |
| `continueOnBlock` | no | On `ok: false`, feed reason to Claude and continue instead of stopping |

Model must return `{"ok": true}` or `{"ok": false, "reason": "..."}`.

### Agent-Based Hooks (`type: "agent"`) — Experimental

Same fields as prompt hooks but spawns a subagent with tool access (Read, Grep, Glob, etc.). Default timeout: 60 seconds, up to 50 tool-use turns. Use when verification requires inspecting actual files or running commands.

### Hooks in Skill/Agent Frontmatter

```yaml
---
name: my-skill
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

Hooks scoped to component lifetime. For subagents, `Stop` auto-converts to `SubagentStop`.

### Stop Hook Block Cap

Claude Code overrides a `Stop` hook after 8 consecutive blocks. Guard against infinite loops:

```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Allow Claude to stop
fi
# ... rest of hook logic
```

Raise the cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

### MCP Tool Matching

MCP tools follow pattern `mcp__<server>__<tool>`. To match all tools from a server, use `mcp__memory__.*` (the `.*` suffix is required — `mcp__memory` alone is treated as an exact string and matches nothing).

### Debugging

- `/hooks` — Browse all configured hooks (read-only)
- `Ctrl+O` — Toggle transcript view showing hook execution summaries
- `claude --debug-file /tmp/claude.log` — Write full hook execution details to file
- `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` — Additional matcher-level debug output

### JSON Validation Troubleshooting

If your shell profile prints text on startup (e.g., `echo "Shell ready"`), it can corrupt hook JSON output. Guard it:

```bash
if [[ $- == *i* ]]; then
  echo "Shell ready"  # Only in interactive shells
fi
```

### SessionEnd Timeout

Default 1.5 seconds. Raise per-hook with `timeout` field (up to 60s budget for settings-file hooks). Override globally: `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=5000 claude`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks (Guide)](references/claude-code-hooks-guide.md) — Setup walkthrough, common use-case examples, hook types overview, matchers, location scopes, prompt/agent/HTTP hooks, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — Full event schemas, JSON input/output formats, decision control tables, all hook handler fields, async hooks, prompt/agent hooks, security considerations

## Sources

- Automate workflows with hooks (Guide): https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
