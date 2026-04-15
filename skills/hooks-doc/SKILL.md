---
name: hooks-doc
description: Complete official Claude Code documentation for hooks — lifecycle events, matchers, JSON input/output schemas, decision control, exit codes, and patterns for automating workflows with shell, HTTP, prompt, and agent hooks.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks: user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at points in Claude Code's lifecycle.

## Quick Reference

### Hook events

Events fire at three cadences: per session, per turn, and per tool call (inside the agentic loop).

| Event | Cadence | When it fires |
|---|---|---|
| `SessionStart` | session | New session or resume |
| `SessionEnd` | session | Session terminates |
| `UserPromptSubmit` | turn | User submits a prompt, before processing |
| `Stop` | turn | Claude finishes responding |
| `StopFailure` | turn | Turn ends due to API error (output ignored) |
| `PreToolUse` | tool | Before a tool call (can block) |
| `PostToolUse` | tool | After a tool call succeeds |
| `PostToolUseFailure` | tool | After a tool call fails |
| `PermissionRequest` | tool | A permission dialog appears |
| `PermissionDenied` | tool | Auto-mode classifier denies a tool call |
| `SubagentStart` / `SubagentStop` | task | Subagent is spawned / finishes |
| `TaskCreated` / `TaskCompleted` | task | TaskCreate runs / task marked complete |
| `TeammateIdle` | team | Agent-team teammate is about to go idle |
| `PreCompact` / `PostCompact` | session | Around context compaction |
| `Notification` | async | Claude Code sends a notification |
| `InstructionsLoaded` | async | CLAUDE.md or `.claude/rules/*.md` loaded |
| `ConfigChange` | async | Configuration file changes during a session |
| `CwdChanged` | async | Working directory changes (e.g. after `cd`) |
| `FileChanged` | async | A watched file changes on disk |
| `WorktreeCreate` / `WorktreeRemove` | async | Worktree being created / removed |
| `Elicitation` / `ElicitationResult` | mcp | MCP server requests input / user responds |

### Hook handler types

| Type | Field | Purpose |
|---|---|---|
| `command` | `command` | Shell command; reads JSON from stdin, returns via exit code/stdout |
| `http` | `url` | POST request with JSON body; result via response body |
| `prompt` | `prompt` | Single-turn prompt to a Claude model for yes/no decision |
| `agent` | `prompt` | Subagent that can use tools (Read, Grep, Glob) before deciding |

Common handler fields: `type`, `if` (permission-rule filter, tool events only), `timeout` (defaults: command 600s, prompt 30s, agent 60s), `statusMessage`, `once` (skills only). Command-only: `async`, `asyncRewake`, `shell` (`bash` or `powershell`). HTTP-only: `headers`, `allowedEnvVars`. Prompt/agent-only: `model`.

### Matcher patterns

| Matcher | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Letters/digits/underscores/`\|` only | Exact string, or `\|`-separated exact list |
| Anything else | JavaScript regex |

What each event matches on:

| Events | Matcher target |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name (e.g. `Bash`, `Edit\|Write`, `mcp__memory__.*`) |
| `SessionStart` | how started: `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | why ended: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` / `SubagentStop` | agent type (`Bash`, `Explore`, `Plan`, custom names) |
| `PreCompact` / `PostCompact` | trigger: `manual`, `auto` |
| `ConfigChange` | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `FileChanged` | literal filenames (e.g. `.envrc\|.env`) |
| `StopFailure` | error type: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation` / `ElicitationResult` | MCP server name |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support |

MCP tool names: `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from a server (the `.*` is required).

### Hook locations and scope

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No (local) |
| `.claude/settings.json` | Single project | Yes (committable) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Org-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled) |
| Skill or agent frontmatter | While component active | Yes |

### Exit codes (command hooks)

| Exit code | Meaning |
|---|---|
| `0` | Success. stdout parsed for JSON output |
| `2` | Blocking error. stderr is fed back to Claude |
| Other | Non-blocking error (except `WorktreeCreate`, where any non-zero aborts) |

Exit code 2 effect by event: blocks for `PreToolUse`, `PermissionRequest`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `ConfigChange`, `PreCompact`, `Elicitation`, `ElicitationResult`, `WorktreeCreate`. Non-blocking (stderr shown to Claude or user) for `PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SessionStart`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `WorktreeRemove`, `StopFailure`, `InstructionsLoaded`, `PermissionDenied`.

Stdout from `UserPromptSubmit` and `SessionStart` hooks is added as context Claude can see; for other events, stdout goes only to the debug log.

### JSON output (universal fields)

| Field | Default | Purpose |
|---|---|---|
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Omits stdout from debug log |
| `systemMessage` | none | Warning shown to user |

### Decision control by event

| Events | Pattern | Key fields |
|---|---|---|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision`: `allow` / `deny` / `ask` / `defer`; `permissionDecisionReason`; `updatedInput`; `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior`: `allow` / `deny` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` lets the model retry |
| `WorktreeCreate` | path return | Print path to stdout (or `hookSpecificOutput.worktreePath` for HTTP) |
| `Elicitation` / `ElicitationResult` | `hookSpecificOutput` | `action`: `accept` / `decline` / `cancel`; `content` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | exit code or `continue: false` | Exit 2 blocks; `{"continue": false}` stops entirely |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | none | Side effects only |

PreToolUse hook precedence when multiple return different decisions: `deny` > `defer` > `ask` > `allow`.

### Useful environment variables

| Variable | Purpose |
|---|---|
| `$CLAUDE_PROJECT_DIR` | Project root (quote when paths may contain spaces) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin install dir (changes on plugin update) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data dir |
| `$CLAUDE_CODE_REMOTE` | `"true"` in remote web environments |
| `$CLAUDE_ENV_FILE` | Path to write `export` lines (SessionStart, CwdChanged, FileChanged only) |

### Common config shape

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-rm.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

Three nesting levels: hook event > matcher group (with `matcher`) > inner `hooks` array of handlers.

### Other notes

- `disableAllHooks: true` in settings disables all hooks (except managed-policy hooks set above the level where it's declared).
- The `/hooks` slash command opens a read-only browser of configured hooks.
- Hook stdout injected as context (`additionalContext`, `systemMessage`, plain stdout) is capped at 10,000 characters.
- All matching hooks run in parallel; identical command/URL handlers are deduplicated.
- HTTP hooks cannot signal blocking errors via status codes — they must return a 2xx response with a JSON body containing the appropriate decision fields.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) — Full reference for hook events, configuration schema, JSON input/output, exit codes, async hooks, HTTP hooks, prompt and agent hooks, and MCP tool hooks.
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — Quickstart guide with worked examples: notifications, auto-formatting, blocking edits, re-injecting context after compaction, auditing config changes, reloading env, auto-approving permissions, and prompt/agent-based hooks.

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
