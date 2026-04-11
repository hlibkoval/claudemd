---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — user-defined shell commands, HTTP endpoints, or LLM prompts that execute at specific points in Claude Code's lifecycle. Covers the full hook event catalog (SessionStart, PreToolUse, PostToolUse, PermissionRequest, Stop, SessionEnd, and many more), JSON input/output schemas, matcher patterns, exit codes, decision control, configuration locations, prompt-based and agent-based hooks, HTTP hooks, async hooks, and MCP tool hooks. Use this skill when setting up, debugging, or explaining hooks — whether configuring Notification alerts, auto-formatting on edit, blocking sensitive file writes, re-injecting context after compaction, auditing configuration changes, auto-approving permission prompts, or wiring hooks into plugins, skills, and subagents.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### What hooks are

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over behavior — use them to enforce project rules, automate repetitive tasks, and integrate with existing tools. For judgment-based decisions, use prompt-based or agent-based hooks.

### Hook events (full catalog)

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it |
| `PreToolUse` | Before a tool call executes. Can block it |
| `PermissionRequest` | When a permission dialog appears |
| `PermissionDenied` | Tool call denied by auto-mode classifier. `{retry: true}` lets the model retry |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `Notification` | When Claude Code sends a notification |
| `SubagentStart` / `SubagentStop` | When a subagent is spawned / finishes |
| `TaskCreated` / `TaskCompleted` | Task is being created / marked complete |
| `Stop` | Claude finishes responding |
| `StopFailure` | Turn ends due to an API error (output ignored) |
| `TeammateIdle` | Agent team teammate about to go idle |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` loaded into context |
| `ConfigChange` | Configuration file changes during a session |
| `CwdChanged` | Working directory changes (e.g. after `cd`) |
| `FileChanged` | Watched file changes on disk |
| `WorktreeCreate` / `WorktreeRemove` | Worktree being created / removed |
| `PreCompact` / `PostCompact` | Before / after context compaction |
| `Elicitation` / `ElicitationResult` | MCP server requests user input / user responds |
| `SessionEnd` | Session terminates |

### Hook handler types

| `type` | Purpose |
| :--- | :--- |
| `"command"` | Run a shell command (most common). Input via stdin, output via stdout/stderr/exit code. Fields: `command`, `async`, `shell` ("bash" or "powershell") |
| `"http"` | POST event JSON to a URL. Fields: `url`, `headers`, `allowedEnvVars`. Non-2xx / timeouts are non-blocking |
| `"prompt"` | Single-turn LLM evaluation. Fields: `prompt` (use `$ARGUMENTS` placeholder), `model`. Model returns `{"ok": true/false, "reason": "..."}` |
| `"agent"` | Multi-turn subagent with tool access (Read, Grep, Glob). Same response format as prompt hooks. Default timeout 60s, up to 50 tool-use turns |

Common handler fields: `type` (required), `if` (permission-rule filter for tool events), `timeout` (defaults: 600s command, 30s prompt, 60s agent), `statusMessage`, `once` (skills only).

### Configuration shape

Hooks live under the `hooks` key in a settings file. Structure is three levels: event name -> matcher group -> array of handlers.

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

### Matcher patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all — fires on every occurrence |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list (e.g. `Bash`, `Edit\|Write`) |
| Any other character | JavaScript regular expression (e.g. `^Notebook`, `mcp__memory__.*`) |

What each event matches against:

- Tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`): tool name
- `SessionStart`: `startup`, `resume`, `clear`, `compact`
- `SessionEnd`: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other`
- `Notification`: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`
- `SubagentStart` / `SubagentStop`: agent type (`Bash`, `Explore`, `Plan`, custom names)
- `PreCompact` / `PostCompact`: `manual`, `auto`
- `ConfigChange`: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`
- `StopFailure`: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown`
- `InstructionsLoaded`: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact`
- `Elicitation` / `ElicitationResult`: MCP server name
- `FileChanged`: pipe-separated literal filenames (not regex)
- No-matcher events: `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`

**MCP tool matching**: MCP tools appear as `mcp__<server>__<tool>`. To match all tools from a server, use a regex like `mcp__memory__.*` (the `.*` is required to force regex evaluation).

**The `if` field**: tool events accept a per-handler `if` using permission-rule syntax (`"Bash(git *)"`, `"Edit(*.ts)"`) so the process only spawns on a match. Requires v2.1.85+. Adding `if` to a non-tool event prevents the hook from running.

### Hook locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (committed) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled) |
| Skill or subagent frontmatter | While component active | Yes (in file) |

Use `/hooks` to browse configured hooks (read-only). Set `"disableAllHooks": true` to disable all at once (respects managed-settings hierarchy). Enterprise admins can set `allowManagedHooksOnly` to block user/project/plugin hooks.

### Path environment variables

- `$CLAUDE_PROJECT_DIR` — project root (quote to handle spaces)
- `${CLAUDE_PLUGIN_ROOT}` — plugin's install directory (changes on update)
- `${CLAUDE_PLUGIN_DATA}` — plugin's persistent data directory
- `$CLAUDE_CODE_REMOTE` — set to `"true"` in remote web environments
- `$CLAUDE_ENV_FILE` — file to persist env vars (available in `SessionStart`, `CwdChanged`, `FileChanged`)

### Common input fields (JSON on stdin)

All events receive: `session_id`, `transcript_path`, `cwd`, `hook_event_name`, and for most events `permission_mode` (`default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`). When running with `--agent` or inside a subagent, also `agent_id` and `agent_type`. Tool events add `tool_name` and `tool_input`.

### Exit code behavior

- **Exit 0**: action proceeds. stdout is parsed as JSON for structured control. For `UserPromptSubmit` and `SessionStart`, stdout is added as context for Claude.
- **Exit 2**: blocking error. stderr is fed back to Claude as feedback. JSON in stdout is ignored.
- **Any other exit code**: non-blocking error. Transcript shows `<hook name> hook error` + first stderr line; full stderr goes to debug log.

**Warning**: exit code 1 does **not** block — only exit 2 does (except `WorktreeCreate`, where any non-zero aborts). Don't mix exit 2 with JSON output.

#### Exit 2 by event

Can block: `PreToolUse`, `PermissionRequest`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `ConfigChange` (except `policy_settings`), `Elicitation`, `ElicitationResult`, `WorktreeCreate`.

Cannot block (stderr shown to Claude or user only): `PostToolUse`, `PostToolUseFailure`, `PermissionDenied`, `Notification`, `SubagentStart`, `SessionStart`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PreCompact`, `PostCompact`, `WorktreeRemove`, `InstructionsLoaded`, `StopFailure`.

### JSON output (structured control)

Exit 0 and print a JSON object to stdout. Universal fields:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | `false` stops Claude entirely. Overrides event-specific decisions |
| `stopReason` | none | Message shown to user when `continue: false` |
| `suppressOutput` | `false` | Omit stdout from debug log |
| `systemMessage` | none | Warning shown to user |

Context injection (`additionalContext`, `systemMessage`, plain stdout) is capped at 10,000 characters; larger output is saved to a file and replaced with a preview.

#### Decision control patterns

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit 2 or `continue: false` | stderr feedback, or stop teammate entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`/`defer`), `permissionDecisionReason` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), optional `updatedInput`, `updatedPermissions` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` to let model retry |
| `WorktreeCreate` | path return | stdout path (command) or `hookSpecificOutput.worktreePath` (http) |
| `Elicitation` / `ElicitationResult` | `hookSpecificOutput` | `action` (`accept`/`decline`/`cancel`), `content` |
| Others (logging/cleanup only) | None | No decision control |

**PreToolUse notes**: `"allow"` skips the interactive prompt but does not override deny/ask permission rules; managed-settings denies always win. `"defer"` is only available in `-p` headless mode.

**UserPromptSubmit**: use `additionalContext` to inject text into Claude's context (not `decision`).

### Multiple hooks

When several matching hooks fire, they run in parallel. Identical command hooks are deduplicated by command string; HTTP hooks by URL. For decisions, Claude Code picks the most restrictive: `deny` beats `ask` beats `allow`, and `additionalContext` from every hook is concatenated.

### Hooks in skills and subagents

Define hooks in skill/agent YAML frontmatter under a `hooks:` key using the same schema. All events are supported. For subagents, `Stop` auto-converts to `SubagentStop`. Use `once: true` in skills to remove the hook after first run.

```yaml
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

### Common patterns from the guide

- **Desktop notification on idle**: `Notification` hook running `osascript` / `notify-send` / PowerShell MessageBox.
- **Auto-format after edits**: `PostToolUse` with `matcher: "Edit|Write"` piping `jq -r '.tool_input.file_path'` to prettier.
- **Block protected files**: `PreToolUse` script checking file_path against a patterns list, exiting 2 to block.
- **Re-inject context after compaction**: `SessionStart` with `matcher: "compact"` echoing project reminders.
- **Audit config changes**: `ConfigChange` hook appending to a JSON log.
- **Reactive env vars**: `CwdChanged` or `FileChanged` writing `direnv export bash` to `CLAUDE_ENV_FILE`.
- **Auto-approve ExitPlanMode**: `PermissionRequest` with a narrow matcher returning `behavior: "allow"`. Keep matchers narrow — `.*` or empty would auto-approve everything.

### Prompt-based hooks

`type: "prompt"` sends your prompt + input JSON to a Claude model (Haiku by default) for a yes/no decision. Use when the hook input alone is enough to decide.

### Agent-based hooks

`type: "agent"` spawns a subagent that can inspect files and run commands to verify conditions. Use when verification needs to check codebase state. 60s default timeout, up to 50 tool turns.

### HTTP hooks

`type: "http"` POSTs event JSON to a URL. Response body uses the same JSON output schema. HTTP status alone cannot block — you must return 2xx with a decision-bearing JSON body. Header env-var interpolation (`$VAR_NAME`, `${VAR_NAME}`) only works for names listed in `allowedEnvVars`.

### Debugging and troubleshooting

- Run Claude Code with `--debug` to see full hook stdout/stderr.
- Use `/hooks` to verify configured hooks.
- stdout must contain only JSON (shell profiles printing text can break JSON parsing).
- Common pitfall: using exit 1 to block (doesn't work — use exit 2).
- Hooks run with Claude Code's environment and in the current directory.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks (guide)](references/claude-code-hooks-guide.md) — quickstart walkthrough with common use cases: notifications, auto-format, block protected files, re-inject context, audit, reactive env, auto-approve. Covers prompt/agent/HTTP hooks and troubleshooting.
- [Hooks reference](references/claude-code-hooks-reference.md) — complete reference for every event, matcher table, handler fields, JSON input/output schemas, exit codes, decision control, async hooks, MCP tool hooks, and schema details for all event types.

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
