---
name: hooks-doc
description: Complete documentation for Claude Code hooks — lifecycle events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, prompt, agent), configuration schema (matcher groups, hook handler fields, timeout, async, once, statusMessage), JSON input/output format (common input fields, exit codes, structured JSON output, decision control), matcher patterns (tool name regex, session source, notification type, config source, MCP tool matching), hook locations (user/project/local settings, managed policy, plugin hooks.json, skill/agent frontmatter), environment variables ($CLAUDE_PROJECT_DIR, ${CLAUDE_PLUGIN_ROOT}, CLAUDE_ENV_FILE), async hooks (background execution, systemMessage delivery), prompt-based hooks (LLM evaluation, ok/reason response), agent-based hooks (multi-turn verification with tool access), HTTP hooks (POST endpoint, header env var interpolation, allowedEnvVars), PermissionRequest decision control (allow/deny, updatedInput, updatedPermissions, permission update entries, setMode, addRules), PreToolUse decision control (permissionDecision allow/deny/ask, updatedInput, additionalContext), PostToolUse decision control (block with reason, updatedMCPToolOutput), Stop/SubagentStop decision control (block to continue), security considerations, debugging (--debug, Ctrl+O verbose mode, /hooks menu). Load when discussing Claude Code hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, hook configuration, hook matchers, hook JSON input, hook output, exit codes, blocking tool calls, auto-approve permissions, auto-format code, notification hooks, session hooks, compaction hooks, worktree hooks, elicitation hooks, config change hooks, teammate idle hooks, task completed hooks, async hooks, prompt hooks, agent hooks, HTTP hooks, hook security, hook debugging, CLAUDE_ENV_FILE, hook locations, plugin hooks, skill hooks, permission update entries, updatedPermissions, setMode, addRules.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute at specific points in Claude Code's lifecycle. They provide deterministic control over behavior -- ensuring certain actions always happen rather than relying on the LLM to choose to run them.

### Hook Events

| Event | When it fires | Can block? | Matcher field |
|:------|:--------------|:-----------|:--------------|
| `SessionStart` | Session begins or resumes | No | source: `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | No matcher support |
| `UserPromptSubmit` | User submits a prompt | Yes | No matcher support |
| `PreToolUse` | Before a tool call executes | Yes | tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `PermissionRequest` | Permission dialog appears | Yes | tool name (same as PreToolUse) |
| `PostToolUse` | After a tool call succeeds | No (already ran) | tool name |
| `PostToolUseFailure` | After a tool call fails | No | tool name |
| `Notification` | Notification sent | No | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | agent type: `Bash`, `Explore`, `Plan`, custom |
| `SubagentStop` | Subagent finishes | Yes | agent type |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `TeammateIdle` | Teammate about to go idle | Yes | No matcher support |
| `TaskCompleted` | Task marked as completed | Yes | No matcher support |
| `ConfigChange` | Config file changes | Yes (except policy) | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes (non-zero exit) | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before compaction | No | trigger: `manual`, `auto` |
| `PostCompact` | After compaction completes | No | trigger: `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | reason: `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:------------|:----------------|
| `command` | Runs a shell command. Input via stdin, output via exit code + stdout/stderr | 600s |
| `http` | POSTs event JSON to a URL. Results via response body | 600s |
| `prompt` | Single-turn LLM evaluation. Returns `{ok, reason}` JSON | 30s |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob). Returns `{ok, reason}` | 60s |

Events supporting all four types: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `Stop`, `SubagentStop`, `TaskCompleted`, `UserPromptSubmit`. All other events support only `command` hooks.

### Hook Handler Fields

**Common fields (all types):**

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs only once per session (skills only) |

**Command-specific:** `command` (shell command), `async` (run in background)

**HTTP-specific:** `url` (POST endpoint), `headers` (key-value, supports `$VAR` interpolation), `allowedEnvVars` (array of env var names to resolve in headers)

**Prompt/Agent-specific:** `prompt` (text, use `$ARGUMENTS` for hook input JSON), `model` (defaults to fast model)

### Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex>",
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
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Exit Code Behavior

| Exit code | Effect |
|:----------|:-------|
| 0 | Action proceeds. Stdout parsed for JSON output. For `UserPromptSubmit`/`SessionStart`, stdout added as context |
| 2 | Blocking error. Stderr fed back as error message. Effect depends on event (blocks tool call, rejects prompt, etc.) |
| Other | Non-blocking error. Stderr logged in verbose mode. Execution continues |

### Common Input Fields (JSON on stdin)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | (subagent only) Unique subagent identifier |
| `agent_type` | (subagent/--agent only) Agent name |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code or `continue: false` | Exit 2 blocks with stderr; JSON `{continue: false, stopReason}` stops entirely |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| WorktreeCreate | stdout path | Print absolute path to created worktree |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` (form values) |

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hides stdout from verbose mode |
| `systemMessage` | none | Warning shown to user |

### Permission Update Entries (PermissionRequest)

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules`, `behavior`, `destination` | Adds permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules |
| `setMode` | `mode`, `destination` | Changes permission mode (`default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`) |
| `addDirectories` | `directories`, `destination` | Adds working directories |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

Destinations: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Environment Variables

| Variable | Description |
|:---------|:------------|
| `$CLAUDE_PROJECT_DIR` | Project root (use in command paths) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin root directory |
| `CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart only) |
| `$CLAUDE_CODE_REMOTE` | `"true"` in remote web environments |

### Async Hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately. Output delivered on next conversation turn via `systemMessage` or `additionalContext`. Cannot block or return decisions. Only `type: "command"` supports async.

### Prompt/Agent Hook Response

Both prompt and agent hooks return the same schema:

```json
{"ok": true}
{"ok": false, "reason": "Explanation shown to Claude"}
```

### MCP Tool Matching

MCP tools follow the pattern `mcp__<server>__<tool>`. Use regex matchers like `mcp__memory__.*` (all tools from memory server) or `mcp__.*__write.*` (any write tool from any server).

### Key Limitations

- Command hooks communicate through stdout/stderr/exit codes only
- `PostToolUse` hooks cannot undo actions (tool already executed)
- `PermissionRequest` hooks do not fire in non-interactive mode (`-p`); use `PreToolUse` instead
- `Stop` hooks fire when Claude finishes responding, not only at task completion; do not fire on user interrupts
- Check `stop_hook_active` in Stop hooks to prevent infinite loops
- SessionEnd hooks have a 1.5s default timeout (override with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`)
- Disable all hooks with `"disableAllHooks": true` in settings

### The /hooks Menu

Type `/hooks` in Claude Code to browse all configured hooks (read-only). Shows events, matchers, handler details, type labels, and source (`User`, `Project`, `Local`, `Plugin`, `Session`, `Built-in`).

### Debugging

- `claude --debug` for execution details (matched hooks, exit codes, output)
- `Ctrl+O` to toggle verbose mode and see hook output in transcript
- Test hooks manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh`

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas (SessionStart, InstructionsLoaded, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, TeammateIdle, TaskCompleted, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), JSON input/output formats for each event, exit code behavior per event, decision control patterns, hook handler fields (command/http/prompt/agent), matcher patterns and MCP tool matching, hook locations and scope, configuration schema, PreToolUse tool input schemas (Bash/Write/Edit/Read/Glob/Grep/WebFetch/WebSearch/Agent), PermissionRequest decision control with updatedPermissions and permission update entries, prompt-based hooks (LLM evaluation, response schema), agent-based hooks (multi-turn verification), HTTP hooks (POST endpoint, header interpolation, response handling), async hooks (background execution, limitations), hooks in skills and agents (frontmatter), the /hooks menu, disabling hooks, environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_ENV_FILE), security considerations, debugging
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- getting started walkthrough, common use cases (desktop notifications, auto-format with Prettier, block edits to protected files, re-inject context after compaction, audit configuration changes, auto-approve specific permission prompts with PermissionRequest), how hooks work (event lifecycle, read input/return output, structured JSON output, filter with matchers, configure hook location), prompt-based hooks (single-turn LLM evaluation, Stop hook example), agent-based hooks (multi-turn verification, test suite example), HTTP hooks (POST to endpoint, header env var interpolation), limitations and troubleshooting (hook not firing, hook error, no hooks configured, Stop hook infinite loop, JSON validation failed from shell profile output, debug techniques)

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
