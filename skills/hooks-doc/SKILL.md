---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — all hook events (SessionStart, PreToolUse, PostToolUse, PermissionRequest, Stop, and 25+ more), hook types (command, http, mcp_tool, prompt, agent), configuration schema (matcher patterns, if field, exec/shell form, path placeholders), JSON input/output formats, exit codes, decision control (allow/deny/ask/defer), async hooks, background hooks, terminal sequences, additionalContext, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### What Hooks Are

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over Claude's behavior — ensuring certain actions always happen regardless of LLM decisions.

### Hook Event Reference

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` / `--init` / `--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | A slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes |
| `PermissionDenied` | Tool call denied by auto mode classifier | No (but can set `retry: true`) |
| `PostToolUse` | After a tool call succeeds | No (but can inject feedback) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls | Yes |
| `Notification` | When Claude sends a notification | No |
| `SubagentStart` | When a subagent is spawned | No |
| `SubagentStop` | When a subagent finishes | Yes |
| `TaskCreated` | When a task is created via `TaskCreate` | Yes |
| `TaskCompleted` | When a task is marked as completed | Yes |
| `Stop` | When Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | An agent team teammate is about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `ConfigChange` | A configuration file changes during a session | Yes |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | A watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created (replaces default git behavior) | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Types

| Type | How it works | Use for |
| :--- | :--- | :--- |
| `command` | Runs a shell command; stdin = JSON input, stdout/exit code = output | Most use cases |
| `http` | POSTs JSON to a URL; response body = output | Shared audit services, cloud functions |
| `mcp_tool` | Calls a tool on a connected MCP server | Reusing MCP server logic |
| `prompt` | Single-turn LLM call (Haiku by default); returns `{"ok": true/false, "reason": "..."}` | Judgment-based decisions |
| `agent` | Spawns a subagent with tool access; same `ok`/`reason` format | Verifying file/codebase state |

### Configuration Schema

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolName|OtherTool",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh",
            "if": "Bash(git *)",
            "timeout": 30,
            "async": false
          }
        ]
      }
    ]
  }
}
```

### Matcher Patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `""`, `"*"`, or omitted | Match all occurrences |
| Only letters, digits, `_`, and `\|` | Exact string or pipe-separated list of exact strings |
| Contains any other character | JavaScript regular expression |

Each event matches on a specific field:

| Events | What the matcher filters | Example values |
| :--- | :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | How the session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag | `init`, `maintenance` |
| `SessionEnd` | Why it ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | Agent type | `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | What triggered it | `manual`, `auto` |
| `ConfigChange` | Config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | Error type | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, etc. |
| `InstructionsLoaded` | Load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | Your configured MCP server names |
| `FileChanged` | Literal filenames (not regex) | `.envrc\|.env` |
| `UserPromptExpansion` | Command name | Skill or command names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support | Always fires |

### The `if` Field (Fine-Grained Filtering)

The `if` field uses permission rule syntax to filter on tool name AND arguments — only available on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`). Requires v2.1.85+.

```json
{ "type": "command", "if": "Bash(git *)", "command": "check-git-policy.sh" }
```

Compound Bash commands are checked subcommand-by-subcommand; hook fires if any subcommand matches. Adding `if` to non-tool events prevents the hook from running.

### Hook Locations (Scope)

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes (in component file) |

### Common Hook Handler Fields

| Field | Description |
| :--- | :--- |
| `type` | `command`, `http`, `mcp_tool`, `prompt`, or `agent` |
| `if` | Permission rule syntax filter (tool events only) |
| `timeout` | Seconds before canceling. Defaults: 600 for command/http/mcp_tool (30 for UserPromptSubmit), 30 for prompt, 60 for agent |
| `statusMessage` | Custom spinner message while hook runs |
| `once` | If `true`, runs once per session (skill frontmatter only, ignored in settings) |

### Command Hook Fields

| Field | Description |
| :--- | :--- |
| `command` | Shell command (shell form) or executable path (exec form when `args` is present) |
| `args` | Argument list; triggers exec form — no shell, each element is one exact argument |
| `async` | If `true`, runs in background without blocking |
| `asyncRewake` | If `true`, runs in background and wakes Claude on exit code 2 (implies `async`) |
| `shell` | `"bash"` (default) or `"powershell"` (shell form only) |

### Path Placeholders

| Placeholder | Resolves to |
| :--- | :--- |
| `${CLAUDE_PROJECT_DIR}` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Use exec form (`args: []`) with path placeholders to avoid shell quoting issues with spaces.

### Exit Codes

| Code | Meaning |
| :--- | :--- |
| `0` | No objection; Claude Code reads stdout for JSON output |
| `2` | Blocking error; stderr text fed back as feedback; JSON is ignored |
| Any other | Non-blocking error; transcript shows hook error notice; execution continues |

Note: Only exit code 2 blocks. Exit code 1 is non-blocking (execution proceeds). Exception: `WorktreeCreate` — any non-zero exit code fails worktree creation.

### JSON Output Fields (Universal)

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hides hook stdout from transcript (still in debug log) |
| `systemMessage` | none | Warning message shown to the user |
| `terminalSequence` | none | Terminal escape sequence to emit (OSC 0/1/2/9/99/777, BEL); requires v2.1.141+ |

Output strings (`additionalContext`, `systemMessage`, stdout) are capped at 10,000 characters; larger values are saved to a file.

### Decision Control by Event

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | Exit 2 = block with stderr; `{"continue": false, "stopReason": "..."}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells the model it may retry |
| `WorktreeCreate` | Path return | Command hook prints worktree path on stdout |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `additionalContext`, `watchPaths` (SessionStart only), `initialUserMessage` (SessionStart only) |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only (logging, cleanup) |

### PreToolUse `permissionDecision` Values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skips interactive prompt (deny and ask rules still apply) |
| `"deny"` | Cancels tool call; `permissionDecisionReason` shown to Claude |
| `"ask"` | Shows permission prompt; `permissionDecisionReason` shown to user |
| `"defer"` | Exits process (`-p` mode only) with `stop_reason: "tool_deferred"` for SDK wrapper to handle |

When multiple PreToolUse hooks return decisions, precedence is: `deny` > `defer` > `ask` > `allow`.

### `additionalContext` — Injecting Context for Claude

Return inside `hookSpecificOutput` alongside `hookEventName`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts and run bun generate instead."
  }
}
```

Where it appears: beginning of conversation for `SessionStart`/`Setup`/`SubagentStart`; alongside the submitted prompt for `UserPromptSubmit`/`UserPromptExpansion`; next to tool result for `PreToolUse`/`PostToolUse`/`PostToolUseFailure`/`PostToolBatch`.

### `CLAUDE_ENV_FILE` — Persisting Environment Variables

Available to `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to this file path; they become available in all subsequent Bash commands for the session. Use `>>` to preserve variables set by other hooks.

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook is invoked |
| `permission_mode` | Current permission mode (`default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`) |
| `hook_event_name` | Name of the event that fired |
| `effort` | Object with `level` field (`low`, `medium`, `high`, `xhigh`, `max`) — tool-use events only |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Subagent type name (when inside a subagent) |

`SessionStart` additionally receives `source` and `model`. Only `SessionStart` receives `model`.

### Key Limitations

- PreToolUse hooks fire before any permission-mode check — a `deny` blocks even in `bypassPermissions` mode. `"allow"` cannot override deny rules from settings.
- `PermissionRequest` hooks do not fire in non-interactive mode (`-p`). Use `PreToolUse` for automated permission decisions.
- `Stop` hooks fire whenever Claude finishes responding (not just task completion), not on user interrupts.
- When multiple `PreToolUse` hooks return `updatedInput`, last-to-finish wins (parallel execution, non-deterministic order).
- `PostToolUse` hooks cannot undo already-executed actions.
- Command hooks have no controlling terminal; to emit escape sequences, use `terminalSequence` in JSON output.
- Stop hook block cap: after 8 consecutive blocks without progress, Claude is allowed to stop. Check `stop_hook_active` field in input to detect this.

### Debugging

- `/hooks` — read-only browser showing all configured hooks grouped by event, with source file and full details.
- `ctrl+O` — transcript view showing one-line hook summary per hook that fired.
- `claude --debug-file /tmp/claude.log` — writes full execution details (matched hooks, exit codes, stdout, stderr) to a log file.
- `disableAllHooks: true` in settings — disables all non-managed hooks without removing them.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — setup walkthrough, common automation patterns, hook lifecycle overview, filtering, prompt/agent/HTTP hooks, limitations and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, all hook handler fields, exit code behavior per event, decision control, async hooks, MCP tool hooks, terminal sequences

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
