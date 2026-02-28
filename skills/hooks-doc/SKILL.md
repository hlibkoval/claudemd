---
name: hooks-doc
description: Complete documentation for Claude Code hooks — lifecycle events, shell command/HTTP/prompt/agent hook types, matchers, JSON input/output schemas, exit codes, decision control, async hooks, MCP tool hooks, environment variables, and troubleshooting. Load when discussing hook configuration, PreToolUse, PostToolUse, Stop hooks, or automating Claude Code workflows.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined handlers that execute automatically at specific lifecycle points. Four types: `command` (shell), `http` (POST endpoint), `prompt` (single-turn LLM), `agent` (multi-turn subagent with tools).

### Hook Events

| Event | When it fires | Matcher field | Can block? |
|:------|:-------------|:-------------|:----------|
| `SessionStart` | Session begins/resumes | source: `startup`, `resume`, `clear`, `compact` | No |
| `UserPromptSubmit` | User submits prompt | no matcher | Yes |
| `PreToolUse` | Before tool executes | tool name | Yes |
| `PermissionRequest` | Permission dialog shown | tool name | Yes |
| `PostToolUse` | After tool succeeds | tool name | No |
| `PostToolUseFailure` | After tool fails | tool name | No |
| `Notification` | Notification sent | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` | No |
| `SubagentStart` | Subagent spawned | agent type | No |
| `SubagentStop` | Subagent finishes | agent type | Yes |
| `Stop` | Claude finishes responding | no matcher | Yes |
| `TeammateIdle` | Teammate going idle | no matcher | Yes |
| `TaskCompleted` | Task marked complete | no matcher | Yes |
| `ConfigChange` | Config file changes | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | Yes |
| `WorktreeCreate` | Worktree being created | no matcher | Yes |
| `WorktreeRemove` | Worktree being removed | no matcher | No |
| `PreCompact` | Before compaction | trigger: `manual`, `auto` | No |
| `SessionEnd` | Session terminates | reason: `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | No |

### Configuration Structure

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

### Hook Handler Types

| Type | Key fields | Default timeout |
|:-----|:-----------|:---------------|
| `command` | `command`, `async` | 600s |
| `http` | `url`, `headers`, `allowedEnvVars` | 600s |
| `prompt` | `prompt`, `model` | 30s |
| `agent` | `prompt`, `model` | 60s |

Common fields for all types: `type`, `timeout`, `statusMessage`, `once` (skills only).

### Exit Code Behavior

| Exit code | Effect |
|:----------|:-------|
| **0** | Action proceeds; stdout parsed for JSON output |
| **2** | Action blocked; stderr fed to Claude as feedback |
| **Other** | Non-blocking error; stderr logged in verbose mode |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), `updatedInput`, `updatedPermissions` |
| `TeammateIdle`, `TaskCompleted` | Exit code only | Exit 2 blocks; stderr is feedback |
| `WorktreeCreate` | stdout path | Print absolute path to created worktree |

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

### Environment Variables

| Variable | Available in | Description |
|:---------|:------------|:-----------|
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin root directory |
| `$CLAUDE_ENV_FILE` | `SessionStart` only | File path for persisting env vars |
| `$CLAUDE_CODE_REMOTE` | All hooks | `"true"` in remote web environments |

### Common JSON Input Fields (stdin)

All events receive: `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`.

### Universal JSON Output Fields (stdout)

| Field | Default | Description |
|:------|:--------|:-----------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hides stdout from verbose mode |
| `systemMessage` | none | Warning message shown to user |

### Common Patterns

**Auto-format after edits:** `PostToolUse` + matcher `Edit` ` | ` `Write` + command piping `jq -r '.tool_input.file_path'` to formatter.

**Block protected files:** `PreToolUse` + matcher `Edit` ` | ` `Write` + script checking file path, exit 2 to block.

**Re-inject context after compaction:** `SessionStart` + matcher `compact` + echo command.

**Desktop notifications:** `Notification` + platform-native notification command.

**Stop guard (prevent infinite loops):** Check `stop_hook_active` field in `Stop` hook input; exit 0 early if `true`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, configuration schema, exit codes, async hooks, HTTP hooks, prompt/agent hooks, MCP tool hooks, decision control, and security considerations
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart guide with practical examples: notifications, auto-formatting, file protection, context injection, audit logging, prompt/agent hooks, troubleshooting

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
