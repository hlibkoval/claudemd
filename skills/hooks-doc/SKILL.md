---
name: hooks-doc
description: Complete documentation for Claude Code hooks — lifecycle events (SessionStart, PreToolUse, PostToolUse, Stop, Notification, ConfigChange, etc.), configuration schema, matchers, exit codes, JSON input/output, decision control, command/HTTP/prompt/agent hook types, async hooks, environment variables (CLAUDE_ENV_FILE, CLAUDE_PROJECT_DIR), and security best practices. Load when discussing hook configuration, automation, tool interception, or workflow customization.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute at specific points in Claude Code's lifecycle. They provide deterministic control over behavior — format files after edits, block commands, send notifications, inject context, and more.

### Hook Events

| Event | When it fires | Can block? | Matcher filters |
|:------|:-------------|:-----------|:----------------|
| `SessionStart` | Session begins/resumes | No | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | User submits prompt | Yes | (no matcher) |
| `PreToolUse` | Before tool executes | Yes | tool name: `Bash`, `Edit`, `Write`, `Read`, `mcp__.*` |
| `PermissionRequest` | Permission dialog shown | Yes | tool name |
| `PostToolUse` | After tool succeeds | No | tool name |
| `PostToolUseFailure` | After tool fails | No | tool name |
| `Notification` | Notification sent | No | `permission_prompt`, `idle_prompt`, `auth_success` |
| `SubagentStart` | Subagent spawned | No | agent type: `Bash`, `Explore`, `Plan`, custom |
| `SubagentStop` | Subagent finishes | Yes | agent type |
| `Stop` | Claude finishes responding | Yes | (no matcher) |
| `TeammateIdle` | Teammate about to go idle | Yes | (no matcher) |
| `TaskCompleted` | Task marked completed | Yes | (no matcher) |
| `ConfigChange` | Config file changes | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes | (no matcher) |
| `WorktreeRemove` | Worktree being removed | No | (no matcher) |
| `PreCompact` | Before compaction | No | `manual`, `auto` |
| `SessionEnd` | Session terminates | No | `clear`, `logout`, `prompt_input_exit`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:-----------|:---------------|
| `command` | Shell command; receives JSON on stdin | 600s |
| `http` | POST to URL; JSON as request body | 30s |
| `prompt` | Single-turn LLM evaluation (Haiku default) | 30s |
| `agent` | Multi-turn subagent with tool access | 60s |

### Handler Fields (Common)

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message |
| `once` | No | If `true`, runs once per session then removed (skills only) |

### Command Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `command` | Yes | Shell command to execute |
| `async` | No | If `true`, runs in background without blocking |

### HTTP Hook Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `url` | Yes | URL to POST to |
| `headers` | No | Key-value pairs; supports `$VAR_NAME` interpolation |
| `allowedEnvVars` | No | Env vars allowed in header interpolation |

### Exit Code Behavior

| Exit code | Effect |
|:----------|:-------|
| `0` | Action proceeds; stdout parsed for JSON output |
| `2` | Action blocked; stderr fed back to Claude as error |
| Other | Non-blocking error; stderr shown in verbose mode |

### Decision Control by Event

| Events | Decision pattern | Key fields |
|:-------|:----------------|:-----------|
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (`allow` / `deny` / `ask`), `permissionDecisionReason` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (`allow` / `deny`) |
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code only | Exit 2 blocks; stderr is feedback |
| WorktreeCreate | stdout path | Print absolute path to created worktree |

### Common JSON Input Fields

| Field | Description |
|:------|:-----------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `dontAsk`, `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown when `continue` is `false` |
| `suppressOutput` | `false` | Hide stdout from verbose mode |
| `systemMessage` | none | Warning message shown to user |

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes, committable |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Environment Variables

| Variable | Available in | Description |
|:---------|:------------|:------------|
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin root directory |
| `$CLAUDE_ENV_FILE` | SessionStart only | File path for persisting env vars |
| `$CLAUDE_CODE_REMOTE` | All hooks | `"true"` in remote web environments |

### Prompt/Agent Hook Response

```json
{ "ok": true }
{ "ok": false, "reason": "Explanation fed back to Claude" }
```

### Events Supporting All Hook Types

`command`, `http`, `prompt`, `agent`: PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Stop, SubagentStop, TaskCompleted, UserPromptSubmit.

Command-only events: SessionStart, SessionEnd, Notification, SubagentStart, ConfigChange, TeammateIdle, PreCompact, WorktreeCreate, WorktreeRemove.

### Key Configuration Pattern

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex>",
        "hooks": [
          { "type": "command", "command": "your-script.sh" }
        ]
      }
    ]
  }
}
```

Use `"disableAllHooks": true` in settings to temporarily disable all hooks.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- guide with common use cases, setup walkthrough, and ready-to-use configuration examples
- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas, JSON input/output formats, exit codes, async hooks, HTTP hooks, prompt/agent hooks, MCP tool hooks, and security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
