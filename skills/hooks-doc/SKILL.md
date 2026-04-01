---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- lifecycle events, configuration schema, JSON input/output formats, exit codes, matcher patterns, decision control (PreToolUse allow/deny/ask, PermissionRequest allow/deny, Stop/PostToolUse block, WorktreeCreate path return), hook types (command, http, prompt, agent), async hooks, hook handler fields (type, if, timeout, statusMessage, once, command, async, shell, url, headers, allowedEnvVars, prompt, model), environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, CLAUDE_ENV_FILE, CLAUDE_CODE_REMOTE), hook locations (user/project/local/managed/plugin/skill frontmatter), common use cases (notifications, auto-format, file protection, context re-injection after compaction, config auditing, direnv/CwdChanged/FileChanged, auto-approve PermissionRequest), prompt-based hooks (ok/reason response), agent-based hooks (multi-turn verification), MCP tool matching (mcp__server__tool), permission update entries (addRules, replaceRules, removeRules, setMode, addDirectories, removeDirectories), security best practices, Windows PowerShell support, and troubleshooting. Load when discussing hooks, PreToolUse, PostToolUse, PermissionRequest, SessionStart, Stop, Notification, SubagentStart, SubagentStop, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, UserPromptSubmit, StopFailure, TeammateIdle, TaskCreated, TaskCompleted, InstructionsLoaded, SessionEnd, hook events, hook matchers, exit code 2, CLAUDE_ENV_FILE, async hooks, prompt hooks, agent hooks, HTTP hooks, or any hook automation topic.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- lifecycle events, configuration, input/output formats, and all hook types.

## Quick Reference

### Hook Events Summary

| Event | When it fires | Can block? | Matcher filters |
|:------|:-------------|:-----------|:----------------|
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | Prompt submitted, before processing | Yes | No matcher support |
| `PreToolUse` | Before a tool call executes | Yes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `PermissionRequest` | Permission dialog appears | Yes | Tool name |
| `PostToolUse` | After a tool call succeeds | No | Tool name |
| `PostToolUseFailure` | After a tool call fails | No | Tool name |
| `Notification` | Claude sends a notification | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type (`Bash`, `Explore`, `Plan`, custom) |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `TaskCreated` | Task being created | Yes | No matcher support |
| `TaskCompleted` | Task being marked completed | Yes | No matcher support |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `StopFailure` | Turn ends due to API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Teammate about to go idle | Yes | No matcher support |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | Config file changes during session | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | No | No matcher support |
| `FileChanged` | Watched file changes on disk | No | Filename basename (`.envrc`, `.env`) |
| `WorktreeCreate` | Worktree being created | Yes | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before context compaction | No | `manual`, `auto` |
| `PostCompact` | After context compaction | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | After user responds to elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:-----------|:----------------|
| `command` | Run a shell command (stdin JSON, stdout/stderr/exit code output) | 600s |
| `http` | POST event JSON to a URL, response body for results | 600s |
| `prompt` | Single-turn LLM evaluation returning `{ok, reason}` | 30s |
| `agent` | Multi-turn subagent with tool access returning `{ok, reason}` | 60s |

### Hook Handler Fields

**Common fields (all types):**

| Field | Required | Description |
|:------|:---------|:-----------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax filter (tool events only), e.g. `"Bash(git *)"` |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs only once per session (skills only) |

**Command-specific:** `command` (required), `async` (bool), `shell` (`"bash"` or `"powershell"`)

**HTTP-specific:** `url` (required), `headers` (key-value), `allowedEnvVars` (array of env var names for header interpolation)

**Prompt/Agent-specific:** `prompt` (required, use `$ARGUMENTS` for hook input), `model` (optional)

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

### Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex pattern>",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "path/to/script.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Exit Code Behavior

| Exit code | Meaning |
|:----------|:--------|
| `0` | Success -- action proceeds. Stdout parsed for JSON output |
| `2` | Blocking error -- action blocked. Stderr fed back to Claude |
| Other | Non-blocking error -- execution continues. Stderr in verbose mode |

### Common JSON Input Fields

| Field | Description |
|:------|:-----------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | Current permission mode (not all events) |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (subagent context only) |
| `agent_type` | Agent name (subagent or --agent context only) |

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:-----------|
| `continue` | `true` | If `false`, Claude stops entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from verbose mode |
| `systemMessage` | none | Warning shown to the user |

### Decision Control by Event

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr feedback; JSON `continue: false` stops teammate |
| `WorktreeCreate` | Path return | Command: print path on stdout; HTTP: `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| Notification, SessionEnd, PreCompact, PostCompact, InstructionsLoaded, StopFailure, CwdChanged, FileChanged, WorktreeRemove | None | Side effects only (logging, cleanup) |

### Permission Update Entries (PermissionRequest)

| `type` | Effect |
|:-------|:-------|
| `addRules` | Adds permission rules (`rules`, `behavior`: allow/deny/ask, `destination`) |
| `replaceRules` | Replaces all rules of given `behavior` at `destination` |
| `removeRules` | Removes matching rules |
| `setMode` | Changes permission mode (`default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`) |
| `addDirectories` | Adds working directories |
| `removeDirectories` | Removes working directories |

**Destination values:** `session`, `localSettings`, `projectSettings`, `userSettings`

### Environment Variables

| Variable | Available in | Description |
|:---------|:------------|:-----------|
| `CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `CLAUDE_PLUGIN_ROOT` | Plugin hooks | Plugin installation directory |
| `CLAUDE_PLUGIN_DATA` | Plugin hooks | Plugin persistent data directory |
| `CLAUDE_ENV_FILE` | SessionStart, CwdChanged, FileChanged | File path for persisting env vars to Bash commands |
| `CLAUDE_CODE_REMOTE` | All hooks | `"true"` in remote web environments |

### Event-Specific Hook Type Support

**All four types (command, http, prompt, agent):** PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Stop, SubagentStop, UserPromptSubmit, TaskCreated, TaskCompleted

**Command and http only:** ConfigChange, CwdChanged, Elicitation, ElicitationResult, FileChanged, InstructionsLoaded, Notification, PostCompact, PreCompact, SessionEnd, StopFailure, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove

**Command only:** SessionStart

### Prompt/Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

### Key Tool Input Schemas (PreToolUse)

| Tool | Key fields |
|:-----|:-----------|
| `Bash` | `command`, `description`, `timeout`, `run_in_background` |
| `Write` | `file_path`, `content` |
| `Edit` | `file_path`, `old_string`, `new_string`, `replace_all` |
| `Read` | `file_path`, `offset`, `limit` |
| `Glob` | `pattern`, `path` |
| `Grep` | `pattern`, `path`, `glob`, `output_mode`, `-i`, `multiline` |
| `WebFetch` | `url`, `prompt` |
| `WebSearch` | `query`, `allowed_domains`, `blocked_domains` |
| `Agent` | `prompt`, `description`, `subagent_type`, `model` |
| `AskUserQuestion` | `questions`, `answers` |

### MCP Tool Matching

MCP tools follow the pattern `mcp__<server>__<tool>`. Use regex matchers:
- `mcp__memory__.*` -- all tools from memory server
- `mcp__.*__write.*` -- any write tool from any server

### Async Hooks

Set `"async": true` on command hooks to run in the background. Async hooks cannot block or return decisions. Output delivered on next conversation turn via `systemMessage` or `additionalContext`.

### Troubleshooting

| Issue | Fix |
|:------|:----|
| Hook not firing | Check `/hooks` menu; verify matcher is case-sensitive and matches tool name exactly |
| Stop hook infinite loop | Check `stop_hook_active` field in input and exit 0 if `true` |
| JSON validation failed | Shell profile `echo` statements interfere; wrap in `if [[ $- == *i* ]]` check |
| `/hooks` shows no hooks | Verify JSON syntax (no trailing commas); confirm correct settings file location |
| Hook error in output | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./hook.sh` |
| PermissionRequest not firing in `-p` mode | Use `PreToolUse` instead for non-interactive mode |

### Security

- Command hooks run with full user permissions
- Always validate/sanitize inputs and quote shell variables
- Block path traversal (check for `..`)
- Use absolute paths with `$CLAUDE_PROJECT_DIR`
- Skip sensitive files (`.env`, `.git/`, keys)
- PreToolUse `deny` overrides even `bypassPermissions` mode; `allow` does not bypass deny rules

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) -- Full event schemas, JSON input/output formats, configuration details, async hooks, HTTP hooks, prompt/agent hooks, MCP tool hooks, decision control, security considerations
- [Hooks Guide](references/claude-code-hooks-guide.md) -- Getting started walkthrough, common use cases (notifications, auto-format, file protection, compaction context, config auditing, direnv, auto-approve), prompt-based hooks, agent-based hooks, HTTP hooks, troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
