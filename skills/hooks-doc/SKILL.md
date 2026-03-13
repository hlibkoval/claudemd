---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, SessionEnd), hook types (command, http, prompt, agent), configuration schema (matcher patterns, handler fields, hook locations), JSON input/output formats, exit codes (0=allow, 2=block), structured JSON decisions (permissionDecision, decision, hookSpecificOutput), async hooks, HTTP hooks, prompt-based hooks, agent-based hooks, MCP tool matching, environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_ENV_FILE), security best practices, the /hooks interactive menu, hooks in skills and agents frontmatter, common patterns (auto-format, block edits, notifications, re-inject context after compaction, audit config changes). Load when discussing Claude Code hooks, hook events, hook configuration, PreToolUse, PostToolUse, Stop hooks, hook matchers, hook permissions, automating workflows with hooks, prompt hooks, agent hooks, or extending Claude Code with lifecycle automation.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over Claude Code's behavior.

### Hook Events

| Event | When it fires | Can block? | Matcher filters |
|:------|:-------------|:-----------|:----------------|
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | User submits a prompt | Yes | No matcher support |
| `PreToolUse` | Before a tool call executes | Yes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `PermissionRequest` | Permission dialog appears | Yes | Tool name |
| `PostToolUse` | After a tool call succeeds | No | Tool name |
| `PostToolUseFailure` | After a tool call fails | No | Tool name |
| `Notification` | Claude sends a notification | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type (`Bash`, `Explore`, `Plan`, custom) |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `TeammateIdle` | Agent team teammate going idle | Yes | No matcher support |
| `TaskCompleted` | Task being marked as completed | Yes | No matcher support |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | No matcher support |
| `ConfigChange` | Config file changes during session | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before context compaction | No | `manual`, `auto` |
| `SessionEnd` | Session terminates | No | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:-----------|:----------------|
| `command` | Run a shell command. Input via stdin, output via exit code + stdout/stderr | 600s |
| `http` | POST event data to a URL. Response body uses same JSON format as command hooks | 30s |
| `prompt` | Single-turn LLM evaluation. Returns `{ "ok": true/false, "reason": "..." }` | 30s |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob). Same response format as prompt | 60s |

Events supporting all four types: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `TaskCompleted`. All other events support only `command`.

### Configuration Structure

```json
{
  "hooks": {
    "<HookEvent>": [
      {
        "matcher": "<regex pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh",
            "timeout": 600,
            "async": false,
            "statusMessage": "Running hook..."
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
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes, committable |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Common Handler Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs only once per session (skills only) |

**Command-specific**: `command` (shell command), `async` (run in background)

**HTTP-specific**: `url`, `headers` (supports `$VAR_NAME` interpolation), `allowedEnvVars`

**Prompt/Agent-specific**: `prompt` (use `$ARGUMENTS` for hook input JSON), `model`

### Common Input Fields (JSON on stdin)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent ID (only in subagent context) |
| `agent_type` | Agent name (only with `--agent` or inside subagent) |

### Exit Code Behavior

| Exit code | Effect |
|:----------|:-------|
| **0** | Action proceeds. Stdout parsed for JSON output. For `UserPromptSubmit`/`SessionStart`, stdout added as context |
| **2** | Blocking error. Stderr fed back to Claude. Effect depends on event (blocks tool call, rejects prompt, etc.) |
| **Other** | Non-blocking error. Stderr shown in verbose mode only. Execution continues |

### Decision Control by Event

| Events | Decision pattern | Key fields |
|:-------|:----------------|:-----------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr feedback; JSON `{"continue": false}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), `updatedInput`, `updatedPermissions`, `message` |
| `WorktreeCreate` | stdout path | Hook prints absolute path to created worktree |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PreCompact`, `InstructionsLoaded` | None | Side-effect only (logging, cleanup) |

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from verbose mode |
| `systemMessage` | none | Warning message shown to user |

### Environment Variables

| Variable | Description |
|:---------|:------------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin root directory |
| `$CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart only) |
| `$CLAUDE_CODE_REMOTE` | `"true"` in remote web environments |

### MCP Tool Matching

MCP tools follow the pattern `mcp__<server>__<tool>`. Match with regex:
- `mcp__memory__.*` -- all tools from memory server
- `mcp__.*__write.*` -- any write tool from any server

### Async Hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately. Output delivered on the next conversation turn via `systemMessage` or `additionalContext`. Cannot block or control actions.

### Prompt/Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

`ok: true` allows the action; `ok: false` blocks it and feeds `reason` back to Claude.

### Key Patterns

- **Auto-format after edits**: `PostToolUse` + matcher `Edit|Write` + formatter command
- **Block edits to protected files**: `PreToolUse` + matcher `Edit|Write` + exit 2 or `permissionDecision: "deny"`
- **Desktop notifications**: `Notification` + platform-specific notification command
- **Re-inject context after compaction**: `SessionStart` + matcher `compact` + echo context to stdout
- **Audit config changes**: `ConfigChange` + logging command
- **Verify tests before stopping**: `Stop` + prompt/agent hook checking completion

### Disabling Hooks

Set `"disableAllHooks": true` in settings or use the toggle in the `/hooks` menu. Managed settings hooks cannot be disabled by user/project settings.

### Debugging

- Toggle verbose mode with `Ctrl+O` to see hook output in transcript
- Run `claude --debug` for full execution details

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas, configuration schema, JSON input/output formats, exit codes, decision control, async hooks, HTTP hooks, prompt-based hooks, agent-based hooks, MCP tool matching, hooks in skills/agents, security considerations, debugging
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- getting started with /hooks menu, common patterns (notifications, auto-format, block edits, re-inject context, audit config), how hooks work, matchers, hook locations, prompt-based hooks, agent-based hooks, HTTP hooks, limitations, troubleshooting

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
