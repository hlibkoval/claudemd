---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events, configuration schema, JSON input/output formats, exit codes, matcher patterns, async hooks, HTTP hooks, prompt hooks, agent hooks, MCP tool hooks, and per-event decision control. Use when configuring hooks in settings.json, writing hook scripts, troubleshooting hooks not firing, or looking up specific event schemas.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Configuration Structure

Hooks live in JSON settings files under a `hooks` key. Three levels of nesting:

1. **Hook event** — lifecycle point (e.g. `PreToolUse`, `Stop`)
2. **Matcher group** — object with `matcher` + inner `hooks` array
3. **Hook handler** — object with `type`, `command`/`url`/`prompt`, and options

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "npx prettier --write $(jq -r '.tool_input.file_path')" }
        ]
      }
    ]
  }
}
```

### Hook Locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes, bundled with plugin |
| Skill or agent frontmatter | While component is active | Yes, in component file |

Disable all hooks: `"disableAllHooks": true` in settings. Browse configured hooks: `/hooks`.

### Hook Events (Lifecycle Order)

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `--init`/`--maintenance` with `-p` | No |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | Slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog is shown | Yes |
| `PermissionDenied` | Auto mode classifier denies a tool call | No |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After all parallel tool calls resolve, before next model call | Yes |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task created via `TaskCreate` | Yes |
| `TaskCompleted` | Task marked as completed | Yes |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `Stop` | Claude finishes responding (not on user interrupt) | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Notification` | Claude Code sends a notification | No |
| `ConfigChange` | Configuration file changes during session | Yes (except policy) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created (replaces default git behavior) | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Matcher Patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `""`, `"*"`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regex |

What each event matches on:

| Events | Matcher field |
| :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `SessionStart` | start source: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag: `init`, `maintenance` |
| `SessionEnd` | exit reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type: `general-purpose`, `Explore`, `Plan`, or custom |
| `PreCompact`, `PostCompact` | trigger: `manual`, `auto` |
| `ConfigChange` | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error: `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `UserPromptExpansion` | command name |
| `FileChanged` | literal filenames (`\|`-separated) to watch |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support |

MCP tool naming: `mcp__<server>__<tool>`. Match all tools from a server with `mcp__memory__.*`.

### Hook Handler Fields

**Common fields (all types):**

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter by tool name+args (e.g. `"Bash(git *)"`, `"Edit(*.ts)"`). Tool events only. |
| `timeout` | no | Seconds before cancel. Default: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | Run once per session then remove. Skill frontmatter only. |

**Command hook extra fields:**

| Field | Description |
| :--- | :--- |
| `command` | Shell command to run (required) |
| `async` | If `true`, run in background without blocking Claude |
| `asyncRewake` | If `true`, async + wakes Claude on exit code 2 |
| `shell` | `"bash"` (default) or `"powershell"` |

**HTTP hook extra fields:** `url` (required), `headers`, `allowedEnvVars`

**MCP tool hook extra fields:** `server` (required), `tool` (required), `input`

**Prompt/agent hook extra fields:** `prompt` (required, use `$ARGUMENTS` placeholder), `model`

### Common Input Fields (stdin JSON)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSONL |
| `cwd` | Working directory when hook invoked |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `effort` | Object with `level`: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `agent_id` | Subagent ID (inside subagent calls only) |
| `agent_type` | Agent name (when using `--agent` or inside subagent) |

### Exit Codes

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success. JSON output processed. For `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`: stdout added as context |
| `2` | Blocking error. Stderr sent to Claude as feedback. Effect depends on event (see table below) |
| Other | Non-blocking error. Transcript shows hook error notice; execution continues |

**Exit code 2 blocking behavior by event:**

| Event | Effect |
| :--- | :--- |
| `PreToolUse` | Blocks tool call |
| `PermissionRequest` | Denies permission |
| `UserPromptSubmit` | Blocks prompt, erases it |
| `UserPromptExpansion` | Blocks expansion |
| `Stop` | Prevents Claude from stopping |
| `SubagentStop` | Prevents subagent from stopping |
| `TeammateIdle` | Teammate continues working |
| `TaskCreated` | Rolls back task creation |
| `TaskCompleted` | Prevents task completion |
| `ConfigChange` | Blocks config change (except policy_settings) |
| `PostToolBatch` | Stops agentic loop |
| `PreCompact` | Blocks compaction |
| `Elicitation` | Denies elicitation |
| `ElicitationResult` | Blocks response (becomes decline) |
| `WorktreeCreate` | Any non-zero exit fails creation |
| `PostToolUse`, `PostToolUseFailure` | Shows stderr to Claude (tool already ran) |
| `Notification`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `SubagentStart` | Shows stderr to user only |
| `StopFailure`, `PermissionDenied` | Ignored |

### JSON Output Fields

Exit 0 and print JSON to stdout for structured control:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue: false` |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | none | Warning shown to user |

### Decision Control by Event

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` to tell model it may retry |
| `WorktreeCreate` | path return | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| Others | None | Side effects only (logging, cleanup) |

**PreToolUse permissionDecision values:** `"allow"` (skip prompt), `"deny"` (block + feedback to Claude), `"ask"` (show dialog), `"defer"` (pause for SDK wrapper, `-p` mode only)

**PermissionRequest updatedPermissions entry types:** `addRules`, `replaceRules`, `removeRules`, `setMode`, `addDirectories`, `removeDirectories`. Destinations: `session`, `localSettings`, `projectSettings`, `userSettings`.

### Context Injection (`additionalContext`)

Return inside `hookSpecificOutput` to inject text into Claude's context:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts instead."
  }
}
```

Supported on: `SessionStart`, `Setup`, `SubagentStart`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`. Cap: 10,000 characters.

### Environment Variables in Hooks

| Variable | Available in |
| :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | All hooks — project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks — plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hooks — persistent data directory |
| `$CLAUDE_ENV_FILE` | `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` — write `export VAR=value` lines to persist env vars to Bash |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |
| `$CLAUDE_EFFORT` | Active effort level |

### Async Hooks

Add `"async": true` to run a command hook in the background without blocking. Decision fields (`decision`, `permissionDecision`, `continue`) are ignored — action has already proceeded. Output (`systemMessage`, `additionalContext`) delivered on next conversation turn. Use `asyncRewake: true` to wake Claude when the background process exits with code 2.

### Prompt-Based and Agent-Based Hooks

`type: "prompt"` — single LLM call (Haiku by default). Returns `{"ok": true}` or `{"ok": false, "reason": "..."}`.

`type: "agent"` — spawns subagent with tool access (Read, Grep, Glob, etc.). Same response schema. Default timeout 60s, up to 50 turns. Experimental.

Events supporting all five types: `PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `UserPromptExpansion`, `UserPromptSubmit`.

Events supporting only `command`/`http`/`mcp_tool`: `ConfigChange`, `CwdChanged`, `Elicitation`, `ElicitationResult`, `FileChanged`, `InstructionsLoaded`, `Notification`, `PermissionDenied`, `PostCompact`, `PreCompact`, `SessionEnd`, `StopFailure`, `SubagentStart`, `TeammateIdle`, `WorktreeCreate`, `WorktreeRemove`.

`SessionStart` and `Setup`: only `command` and `mcp_tool`.

### Key Per-Event Notes

- **SessionStart**: stdout added as context. `source` input field: `startup`, `resume`, `clear`, `compact`. Only `command`/`mcp_tool` types.
- **Stop**: check `stop_hook_active` input field to prevent infinite loops. `last_assistant_message` has Claude's final response text.
- **FileChanged**: `matcher` both builds the watch list (literal filenames split on `|`) and filters which groups run. Not a regex watch list.
- **CwdChanged** and **FileChanged**: can return `watchPaths` array to dynamically update file watch list.
- **WorktreeCreate**: replaces default git behavior entirely. Must print worktree path on stdout.
- **SessionEnd**: 1.5s default timeout (max 60s via per-hook `timeout` or `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`).
- **PostToolUse**: `updatedToolOutput` replaces what Claude sees (tool already ran; real side effects unchanged).
- **PermissionDenied**: only fires in auto mode. Use `retry: true` to tell model it may retry.
- **`if` field**: filters individual handlers within a matched group by tool+args. Only on tool events. One rule only — no `&&`/`||`.

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| Hook not firing | Run `/hooks` to verify it appears; check matcher is case-sensitive; verify correct event type |
| `PermissionRequest` hook not firing | Doesn't fire in non-interactive mode (`-p`); use `PreToolUse` instead |
| Infinite Stop loop | Check `stop_hook_active` in input and `exit 0` early when `true` |
| JSON validation failed | Shell profile printing on startup pollutes stdout; wrap profile echos in `if [[ $- == *i* ]]; then` |
| Hook error in transcript | Test manually: `echo '{"tool_name":"Bash",...}' \| ./hook.sh`; use absolute paths |
| Security | Run with full user permissions; validate inputs; quote shell variables; use absolute paths |

Debug: `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`. Or run `/debug` mid-session.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide, common use cases, walkthrough examples, troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete event schemas, JSON input/output formats, all decision control options, async hooks, HTTP hooks, prompt/agent hooks, MCP tool hooks, security

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
