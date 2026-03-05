---
name: hooks-doc
description: Complete documentation for Claude Code hooks — lifecycle events, configuration schema, JSON input/output formats, exit codes, matchers, command hooks, HTTP hooks, prompt-based hooks, agent-based hooks, async hooks, MCP tool hooks, decision control patterns, environment variables, security considerations, and troubleshooting. Load when discussing hook configuration, automation, PreToolUse/PostToolUse/Stop events, or the /hooks menu.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over behavior (formatting, blocking, notifications) rather than relying on the LLM to choose actions.

### Hook Types

| Type | Description | Default Timeout |
|:-----|:------------|:----------------|
| `command` | Shell command; receives JSON on stdin, returns via exit code + stdout | 600s |
| `http` | POST JSON to a URL; response body for results | 30s (inferred) |
| `prompt` | Single-turn LLM evaluation; returns `{ok, reason}` | 30s |
| `agent` | Multi-turn subagent with tool access; returns `{ok, reason}` | 60s |

### Hook Events

| Event | When it fires | Matcher filters | Can block? |
|:------|:-------------|:----------------|:-----------|
| `SessionStart` | Session begins/resumes | `startup`, `resume`, `clear`, `compact` | No |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No matcher support | No |
| `UserPromptSubmit` | User submits prompt | No matcher support | Yes |
| `PreToolUse` | Before tool executes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) | Yes |
| `PermissionRequest` | Permission dialog shown | Tool name | Yes |
| `PostToolUse` | After tool succeeds | Tool name | No (feedback only) |
| `PostToolUseFailure` | After tool fails | Tool name | No (feedback only) |
| `Notification` | Notification sent | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` | No |
| `SubagentStart` | Subagent spawned | Agent type (`Bash`, `Explore`, `Plan`, custom) | No |
| `SubagentStop` | Subagent finishes | Agent type | Yes |
| `Stop` | Claude finishes responding | No matcher support | Yes |
| `TeammateIdle` | Agent team teammate going idle | No matcher support | Yes |
| `TaskCompleted` | Task marked completed | No matcher support | Yes |
| `ConfigChange` | Config file changes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | Yes (except `policy_settings`) |
| `WorktreeCreate` | Worktree being created | No matcher support | Yes (non-zero exit fails) |
| `WorktreeRemove` | Worktree being removed | No matcher support | No |
| `PreCompact` | Before compaction | `manual`, `auto` | No |
| `SessionEnd` | Session terminates | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | No |

### Hook Locations (Scope)

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

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

### Exit Code Behavior

| Exit code | Effect |
|:----------|:-------|
| `0` | Action proceeds; stdout parsed for JSON output |
| `2` | Blocking error; stderr fed to Claude as feedback |
| Other | Non-blocking error; stderr logged in verbose mode |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code or `continue: false` | Exit 2 blocks; JSON `{"continue": false}` stops entirely |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`), `permissionDecisionReason`, `updatedInput` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), `updatedInput`, `updatedPermissions` |
| WorktreeCreate | stdout path | Print absolute path to created worktree |
| WorktreeRemove, Notification, SessionEnd, PreCompact, InstructionsLoaded | None | Side effects only |

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hides stdout from verbose mode |
| `systemMessage` | none | Warning shown to user |

### Common Input Fields (all events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the fired event |
| `agent_id` | (subagent only) Unique subagent identifier |
| `agent_type` | (agent/subagent only) Agent name |

### PreToolUse Tool Input Schemas

| Tool | Key `tool_input` fields |
|:-----|:-----------------------|
| Bash | `command`, `description`, `timeout`, `run_in_background` |
| Write | `file_path`, `content` |
| Edit | `file_path`, `old_string`, `new_string`, `replace_all` |
| Read | `file_path`, `offset`, `limit` |
| Glob | `pattern`, `path` |
| Grep | `pattern`, `path`, `glob`, `output_mode`, `-i`, `multiline` |
| WebFetch | `url`, `prompt` |
| WebSearch | `query`, `allowed_domains`, `blocked_domains` |
| Agent | `prompt`, `description`, `subagent_type`, `model` |

### MCP Tool Matching

MCP tools follow the pattern `mcp__<server>__<tool>`. Use regex matchers like `mcp__memory__.*` (all memory server tools) or `mcp__.*__write.*` (write tools from any server).

### Hook Handler Fields

**Common fields** (all types): `type`, `timeout`, `statusMessage`, `once` (skills only)

**Command hooks**: `command`, `async`

**HTTP hooks**: `url`, `headers` (supports `$VAR` interpolation), `allowedEnvVars`

**Prompt/agent hooks**: `prompt` (use `$ARGUMENTS` placeholder), `model`

### Prompt/Agent Hook Response

```json
{
  "ok": true,
  "reason": "Required when ok is false"
}
```

### Hook Type Support by Event

Events supporting all four types (command, http, prompt, agent): `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `Stop`, `SubagentStop`, `TaskCompleted`, `UserPromptSubmit`

Events supporting only `command` hooks: `SessionStart`, `SessionEnd`, `ConfigChange`, `InstructionsLoaded`, `Notification`, `PreCompact`, `SubagentStart`, `TeammateIdle`, `WorktreeCreate`, `WorktreeRemove`

### Environment Variables

| Variable | Available in | Description |
|:---------|:-------------|:------------|
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin root directory |
| `$CLAUDE_ENV_FILE` | SessionStart only | File path to persist env vars for the session |
| `$CLAUDE_CODE_REMOTE` | All hooks | `"true"` in remote web environments |

### Async Hooks

Set `"async": true` on command hooks to run in the background. Async hooks cannot block or return decisions. Output is delivered on the next conversation turn via `systemMessage` or `additionalContext`.

### Key Patterns

- **Notifications**: `Notification` event with platform-specific `osascript`/`notify-send` commands
- **Auto-format**: `PostToolUse` + `Edit|Write` matcher + formatter command
- **Block edits**: `PreToolUse` + `Edit|Write` + exit 2 or `permissionDecision: "deny"`
- **Re-inject context after compaction**: `SessionStart` + `compact` matcher + echo to stdout
- **Audit config changes**: `ConfigChange` + logging command
- **Quality gates**: `Stop` or `TaskCompleted` + prompt/agent hook to verify completeness
- **Prevent infinite Stop loops**: check `stop_hook_active` field and exit 0 if true

### Disabling Hooks

Set `"disableAllHooks": true` in settings or use the toggle in `/hooks` menu. Managed policy hooks can only be disabled at the managed settings level.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas, configuration schema, JSON input/output formats, exit codes, decision control, async hooks, HTTP hooks, prompt hooks, agent hooks, MCP tool hooks, security considerations, and debugging
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- quickstart guide, common use cases (notifications, auto-format, file protection, context re-injection, config auditing), prompt-based hooks, agent-based hooks, HTTP hooks, troubleshooting

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
