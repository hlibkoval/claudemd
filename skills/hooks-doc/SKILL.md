---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events, lifecycle, configuration schema, matcher patterns, hook types (command/http/mcp_tool/prompt/agent), JSON input/output formats, exit codes, decision control, async hooks, skill/agent frontmatter hooks, debugging, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Lifecycle Events

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins, resumes, `/clear`, or compaction | No |
| `Setup` | `--init-only`, `--init` or `--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | Prompt submitted, before Claude processes it | Yes |
| `UserPromptExpansion` | Slash command expands before reaching Claude | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog appears | Yes |
| `PermissionDenied` | Tool denied by auto mode classifier | No (but can retry) |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full parallel batch, before next model call | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task being created via `TaskCreate` | Yes |
| `TaskCompleted` | Task being marked completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `ConfigChange` | Configuration file changes during session | Yes |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Configuration Structure

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

Three levels: **hook event** (lifecycle point) → **matcher group** (filter) → **hook handler** (what runs).

### Hook Locations (Scope)

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes, committable |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes, bundled |
| Skill/agent frontmatter | While component is active | Yes |

### Matcher Patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `""`, `"*"`, or omitted | Match all — fires on every occurrence |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list: `Edit\|Write` |
| Contains any other character | JavaScript regular expression: `^Notebook`, `mcp__memory__.*` |

Each event type matches on a different field:

| Event | What matcher filters | Example values |
| :--- | :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag trigger | `init`, `maintenance` |
| `SessionEnd` | why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart` / `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, custom names |
| `PreCompact` / `PostCompact` | what triggered | `manual`, `auto` |
| `ConfigChange` | config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `FileChanged` | literal filenames to watch | `.envrc\|.env` (pipe-separated, not regex) |
| `UserPromptExpansion` | command name | your skill or command names |
| `Elicitation` / `ElicitationResult` | MCP server name | your configured MCP server names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires |

### Hook Types

| Type | Description | Key fields |
| :--- | :--- | :--- |
| `command` | Run a shell command; stdin=JSON input | `command`, `args` (exec form), `async`, `asyncRewake`, `shell` |
| `http` | POST event JSON to a URL | `url`, `headers`, `allowedEnvVars` |
| `mcp_tool` | Call tool on connected MCP server | `server`, `tool`, `input` (supports `${path}` substitution) |
| `prompt` | Single-turn LLM evaluation returning `{ok, reason}` | `prompt`, `model`, `continueOnBlock` |
| `agent` | Multi-turn subagent with tool access (experimental) | `prompt`, `model` |

**Common fields** (all types): `type`, `if`, `timeout`, `statusMessage`, `once` (skill-frontmatter only)

**Default timeouts:** `command`/`http`/`mcp_tool`: 600s (30s for `UserPromptSubmit`); `prompt`: 30s; `agent`: 60s

### Hook Type Support by Event

| Events | Supported types |
| :--- | :--- |
| `SessionStart`, `Setup` | `command`, `mcp_tool` only |
| `PermissionRequest`, `PostToolBatch`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `TaskCreated`, `UserPromptExpansion`, `UserPromptSubmit` | all five types |
| All other events | `command`, `http`, `mcp_tool` only |

### The `if` Field (v2.1.85+)

Filters individual handlers using permission rule syntax. Only evaluated on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`). Adding it to any other event prevents the hook from running.

```json
{
  "type": "command",
  "if": "Bash(git *)",
  "command": "./.claude/hooks/check-git-policy.sh"
}
```

- `"Bash(git *)"` — only when a Bash subcommand matches `git *`
- `"Edit(*.ts)"` — only for TypeScript files
- For compound commands like `npm test && git push`, fires because `git push` matches

### Exec Form vs Shell Form

| Form | When | Behavior |
| :--- | :--- | :--- |
| **Shell form** | `args` omitted | Command passed to `sh -c` (or Git Bash/PowerShell on Windows); supports pipes, `&&`, globs |
| **Exec form** | `args` present | Command resolved as executable, spawned directly with `args` as argument vector; no shell, paths pass through verbatim |

Prefer exec form when using path placeholders (`${CLAUDE_PROJECT_DIR}`) to avoid quoting issues.

### Path Placeholders

| Placeholder | Resolves to |
| :--- | :--- |
| `${CLAUDE_PROJECT_DIR}` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Available as env vars too (e.g., `process.env.CLAUDE_PLUGIN_ROOT`). Plugin hooks also support `${user_config.*}` substitution.

### Exit Codes

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success — action proceeds; JSON output processed; for `UserPromptSubmit`/`UserPromptExpansion`/`SessionStart` stdout added to Claude's context |
| `2` | Blocking error — action blocked; stdout ignored; stderr fed to Claude as error message |
| Other non-zero | Non-blocking error — transcript shows hook error notice with first line of stderr; execution continues |

**Only exit code 2 blocks.** Exit code 1 is non-blocking. Exception: `WorktreeCreate` — any non-zero exit aborts.

### Exit Code 2 Behavior Per Event

| Blocks? | Events |
| :--- | :--- |
| **Yes** | `PreToolUse`, `PermissionRequest`, `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `ConfigChange`, `PostToolBatch`, `PreCompact`, `Elicitation`, `ElicitationResult`, `WorktreeCreate` |
| **No** (shows stderr to user/Claude) | `PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `WorktreeRemove`, `InstructionsLoaded` |
| **Ignored** | `StopFailure`, `PermissionDenied` (use `hookSpecificOutput.retry: true` for retry) |

### JSON Output Fields

Exit 0 and print JSON to stdout for structured control. Never mix JSON with exit 2.

| Field | Description |
| :--- | :--- |
| `continue` | `false` stops Claude entirely after hook runs |
| `stopReason` | Message shown to user when `continue` is `false` |
| `suppressOutput` | `true` omits stdout from debug log |
| `systemMessage` | Warning message shown to user |
| `terminalSequence` | Terminal escape sequence emitted via Claude Code's terminal (OSC 0/1/2/9/99/777, BEL only). Requires v2.1.141. Use instead of writing to `/dev/tty` |

All output strings capped at 10,000 characters.

### Decision Control by Event

| Events | Decision pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | stderr feedback or `stopReason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message` (deny), `interrupt` (deny) |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `WorktreeCreate` | path return | Print path on stdout; HTTP hook returns `hookSpecificOutput.worktreePath` |
| `Elicitation` / `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### PreToolUse Decision Values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skip interactive prompt (deny rules still apply) |
| `"deny"` | Cancel tool call; reason fed to Claude |
| `"ask"` | Show permission prompt to user |
| `"defer"` | Non-interactive mode only (`-p`): exit process with tool call preserved for Agent SDK wrapper (requires v2.1.89) |

When multiple `PreToolUse` hooks return different decisions, precedence is: `deny` > `defer` > `ask` > `allow`.

### PostToolUse Extra Output Fields

| Field | Description |
| :--- | :--- |
| `updatedToolOutput` | Replaces the tool's output before Claude sees it (must match tool's output shape) |
| `updatedMCPToolOutput` | MCP tool output replacement (prefer `updatedToolOutput`) |
| `additionalContext` | String added to Claude's context alongside the tool result |

Note: `updatedToolOutput` only changes what Claude sees; the tool has already run.

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook invoked |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `effort` | Object with `level`: `"low"`, `"medium"`, `"high"`, `"xhigh"`, or `"max"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Present inside subagent calls |
| `agent_type` | Agent name when using `--agent` or inside subagent |

### Key Event-Specific Input Fields

| Event | Extra input fields |
| :--- | :--- |
| `SessionStart` | `source` (startup/resume/clear/compact), `model` |
| `Setup` | `trigger` (init/maintenance) |
| `UserPromptSubmit` | `prompt` |
| `UserPromptExpansion` | `expansion_type`, `command_name`, `command_args`, `command_source`, `prompt` |
| `PreToolUse` / `PostToolUse` | `tool_name`, `tool_input`, `tool_use_id` |
| `PostToolUse` | also `tool_response`, `duration_ms` |
| `PostToolUseFailure` | `tool_name`, `tool_input`, `tool_use_id`, `error`, `is_interrupt`, `duration_ms` |
| `PostToolBatch` | `tool_calls` array |
| `PermissionRequest` | `tool_name`, `tool_input`, `permission_suggestions` |
| `PermissionDenied` | `tool_name`, `tool_input`, `tool_use_id`, `reason` |
| `Stop` / `SubagentStop` | `stop_hook_active`, `last_assistant_message` |
| `StopFailure` | `error`, `error_details`, `last_assistant_message` |
| `SubagentStart` / `SubagentStop` | `agent_id`, `agent_type` |
| `SubagentStop` | also `agent_transcript_path`, `last_assistant_message` |
| `TeammateIdle` / `TaskCreated` / `TaskCompleted` | `teammate_name`, `team_name` |
| `TaskCreated` / `TaskCompleted` | also `task_id`, `task_subject`, `task_description` |
| `InstructionsLoaded` | `file_path`, `memory_type`, `load_reason`, `globs`, `trigger_file_path`, `parent_file_path` |
| `ConfigChange` | `source`, `file_path` |
| `CwdChanged` | `old_cwd`, `new_cwd` |
| `FileChanged` | `file_path`, `event` (change/add/unlink) |
| `WorktreeCreate` | `name` |
| `WorktreeRemove` | `worktree_path` |
| `PreCompact` | `trigger`, `custom_instructions` |
| `PostCompact` | `trigger`, `compact_summary` |
| `SessionEnd` | `reason` |
| `Elicitation` | `mcp_server_name`, `message`, `mode`, `url`, `elicitation_id`, `requested_schema` |
| `ElicitationResult` | `mcp_server_name`, `action`, `mode`, `elicitation_id`, `content` |
| `Notification` | `message`, `title`, `notification_type` |

### `additionalContext` Field

Inject text into Claude's context window from a hook. Return inside `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts instead."
  }
}
```

For `SessionStart`, `UserPromptSubmit`, `UserPromptExpansion`: can also print to stdout directly.

### Environment Variable Persistence (`CLAUDE_ENV_FILE`)

Available in `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to this file to persist env vars into subsequent Bash commands:

```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

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

- Scoped to the component's lifetime; cleaned up when it finishes
- `once: true` runs once per session then removes itself (skill frontmatter only)
- Subagent `Stop` hooks auto-convert to `SubagentStop`

### Async Hooks

| Field | Effect |
| :--- | :--- |
| `async: true` | Runs in background; result ignored (only `type: "command"`) |
| `asyncRewake: true` | Runs in background; exit code 2 wakes Claude immediately with stderr/stdout as reminder; implies `async` |

Async hooks cannot block or return decisions. `additionalContext` is delivered on the next conversation turn.

### PermissionRequest: Permission Update Entries

Used in `updatedPermissions` output and `permission_suggestions` input:

| `type` | Key fields | Effect |
| :--- | :--- | :--- |
| `addRules` | `rules`, `behavior`, `destination` | Adds permission rules (`{toolName, ruleContent?}`) |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces all rules of given behavior at destination |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules |
| `setMode` | `mode`, `destination` | Changes permission mode (`default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`) |
| `addDirectories` | `directories`, `destination` | Adds working directories |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

`destination` values: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`

### MCP Tool Name Pattern

`mcp__<server>__<tool>` — e.g., `mcp__github__search_repositories`

- `mcp__memory__.*` — all tools from `memory` server
- `mcp__.*__write.*` — write tools from any server

### Prompt-Based Hooks

`type: "prompt"` — single LLM call; `type: "agent"` — multi-turn subagent with tools (experimental).

Both return `{ "ok": true/false, "reason": "..." }`. On `ok: false`:
- `Stop` / `SubagentStop`: reason fed back to Claude as next instruction
- `PreToolUse`: tool call denied, reason returned as tool error
- `PostToolUse`: turn ends with warning (set `continueOnBlock: true` to continue instead)
- `PostToolBatch`, `UserPromptSubmit`, and `UserPromptExpansion`: turn ends with warning
- `PostToolUseFailure`, `TaskCreated`, `TaskCompleted`: reason returned as tool error

`prompt` hook extra field: `continueOnBlock` (default `false`) — on block, feeds reason back and continues turn.

### Disable Hooks

- Remove entry from settings JSON to delete
- Set `"disableAllHooks": true` in settings file to temporarily disable all (managed hooks exempt unless managed settings also set it)
- `allowManagedHooksOnly` (enterprise) — blocks user/project/plugin hooks; plugin hooks from managed `enabledPlugins` are exempt

### SessionEnd Timeout

Default 1.5s per hook. Override per hook with `timeout` field; budget auto-raises to highest configured hook timeout (max 60s). Override budget:

```bash
CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=5000 claude
```

### Notification Event Matchers

| Matcher | Fires when |
| :--- | :--- |
| `permission_prompt` | Claude needs tool use approval |
| `idle_prompt` | Claude done, waiting for next prompt |
| `auth_success` | Authentication completes |
| `elicitation_dialog` | MCP server opens elicitation form |
| `elicitation_complete` | Elicitation form submitted or dismissed |
| `elicitation_response` | Elicitation response sent back to server |

### Common Patterns

**Auto-format on edit:**
```json
{
  "hooks": { "PostToolUse": [{ "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }] }] }
}
```

**Block PreToolUse (exit code):**
```bash
echo "Reason for blocking" >&2
exit 2
```

**Block PreToolUse (JSON):**
```json
{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "Not allowed" } }
```

**Auto-approve PermissionRequest:**
```json
{ "hookSpecificOutput": { "hookEventName": "PermissionRequest", "decision": { "behavior": "allow" } } }
```

**Stop hook infinite loop guard:**
```bash
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then exit 0; fi
```

**Re-inject context after compaction:**
```json
{ "hooks": { "SessionStart": [{ "matcher": "compact", "hooks": [{ "type": "command", "command": "echo 'Reminder: use Bun, not npm.'" }] }] } }
```

**Desktop notification via `terminalSequence`:**
```bash
seq=$(printf '\033]777;notify;Claude Code;Needs attention\007')
jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
```

### Troubleshooting

| Issue | Fix |
| :--- | :--- |
| Hook not firing | Run `/hooks` to confirm registration; check matcher case-sensitivity; `PermissionRequest` doesn't fire in `-p` mode |
| Hook error in transcript | Test manually: `echo '{...}' \| ./my-hook.sh`; use absolute paths or `${CLAUDE_PROJECT_DIR}`; `chmod +x` script |
| No hooks in `/hooks` | Validate JSON (no trailing commas); check correct settings file location; restart session if file watcher missed change |
| Stop hook loops forever | Check `stop_hook_active` field and exit 0 if true |
| JSON validation failed | Shell profile prints text on startup — wrap `echo` in `if [[ $- == *i* ]]` check |
| Debug hooks | Run `claude --debug-file /tmp/claude.log`; or run `/debug` mid-session; toggle transcript view with `Ctrl+O`; set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher details |

### Hooks and Permission Modes

- `PreToolUse` hooks fire **before** permission-mode checks — `permissionDecision: "deny"` blocks even in `bypassPermissions` mode
- A hook returning `"allow"` cannot bypass deny rules from settings — hooks tighten restrictions but cannot loosen them past permission rules

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — setup walkthrough, common use cases, hook types overview, troubleshooting guide
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, configuration schema, JSON input/output formats, all hook handler fields, async hooks, decision control tables, per-event details

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
