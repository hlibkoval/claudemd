---
name: hooks-doc
description: Complete documentation for Claude Code hooks — lifecycle events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, prompt, agent), configuration schema (matcher groups, handler fields, hook locations), JSON input/output format, exit code semantics (0 allow, 2 block), decision control patterns (top-level decision, hookSpecificOutput, permissionDecision, PermissionRequest behavior/updatedPermissions, exit-code-only), matcher patterns per event, common input fields (session_id, cwd, transcript_path, permission_mode, hook_event_name, agent_id, agent_type), environment variables ($CLAUDE_PROJECT_DIR, $CLAUDE_PLUGIN_ROOT, $CLAUDE_PLUGIN_DATA, $CLAUDE_ENV_FILE, $CLAUDE_CODE_REMOTE), tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), async hooks, HTTP hooks (url, headers, allowedEnvVars), prompt-based hooks (prompt, model, ok/reason response), agent-based hooks (multi-turn tool access), hooks in skills and agents (frontmatter), permission update entries (addRules, replaceRules, removeRules, setMode, addDirectories, removeDirectories), MCP tool matching (mcp__server__tool pattern), /hooks menu, disableAllHooks, common use cases (notifications, auto-format, file protection, context re-injection after compaction, config auditing, auto-approve permission prompts), troubleshooting (hook not firing, error in output, JSON validation, stop hook loops), security considerations, debugging with --debug and Ctrl+O verbose mode. Load when discussing Claude Code hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, SessionStart, SessionEnd, hook matchers, hook configuration, auto-format on edit, block file edits, notification hooks, prompt-based hooks, agent-based hooks, HTTP hooks, async hooks, hook input/output, exit codes in hooks, decision control, permissionDecision, hookSpecificOutput, permission update entries, ConfigChange, WorktreeCreate, WorktreeRemove, TeammateIdle, TaskCompleted, InstructionsLoaded, SubagentStart, SubagentStop, StopFailure, Elicitation hooks, ElicitationResult, MCP tool hooks, CLAUDE_ENV_FILE, disableAllHooks, /hooks menu, hook debugging, hook security, or automating Claude Code workflows with hooks.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute at specific points in Claude Code's lifecycle. They provide deterministic control over behavior, ensuring certain actions always happen rather than relying on the LLM to choose to run them.

### Hook Events

| Event | When it fires | Can block? | Matcher filters |
|:------|:--------------|:-----------|:----------------|
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptSubmit` | User submits a prompt | Yes | no matcher support |
| `PreToolUse` | Before a tool call executes | Yes | tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `PermissionRequest` | Permission dialog appears | Yes | tool name |
| `PostToolUse` | After a tool call succeeds | No (feedback only) | tool name |
| `PostToolUseFailure` | After a tool call fails | No (feedback only) | tool name |
| `Notification` | Notification sent | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | agent type (`Bash`, `Explore`, `Plan`, custom) |
| `SubagentStop` | Subagent finishes | Yes | agent type |
| `Stop` | Claude finishes responding | Yes | no matcher support |
| `StopFailure` | Turn ends due to API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Agent team teammate going idle | Yes | no matcher support |
| `TaskCompleted` | Task being marked completed | Yes | no matcher support |
| `ConfigChange` | Config file changes | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes (non-zero exit fails) | no matcher support |
| `WorktreeRemove` | Worktree being removed | No | no matcher support |
| `PreCompact` | Before compaction | No | `manual`, `auto` |
| `PostCompact` | After compaction | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | User responds to elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:------------|:----------------|
| `command` | Run a shell command; input on stdin, output via exit code + stdout/stderr | 600s |
| `http` | POST event JSON to a URL; response body uses same JSON output format | 600s |
| `prompt` | Single-turn LLM evaluation; returns `{ok, reason}` decision | 30s |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob); returns `{ok, reason}` | 60s |

Events supporting all four types: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `Stop`, `SubagentStop`, `TaskCompleted`, `UserPromptSubmit`. All other events support `command` only.

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
            "command": "my-script.sh",
            "timeout": 30,
            "async": false,
            "statusMessage": "Running check...",
            "once": false
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
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill/agent frontmatter | While component active | Yes |

### Handler Fields

**Common fields** (all types): `type` (required), `timeout`, `statusMessage`, `once` (skills only)

**Command hooks**: `command` (required), `async`

**HTTP hooks**: `url` (required), `headers`, `allowedEnvVars`

**Prompt/agent hooks**: `prompt` (required), `model`

### Exit Code Semantics (Command Hooks)

| Exit code | Effect |
|:----------|:-------|
| 0 | Allow; stdout parsed for JSON output; for `UserPromptSubmit`/`SessionStart`, stdout added as context |
| 2 | Block (where supported); stderr fed to Claude as error feedback |
| Other | Non-blocking error; stderr shown in verbose mode only |

### Common Input Fields (JSON on stdin)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside a subagent) |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code or `continue: false` | Exit 2 blocks; JSON `{"continue": false}` stops entirely |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| WorktreeCreate | stdout path | Print absolute path to created worktree |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hide stdout from verbose mode |
| `systemMessage` | none | Warning shown to user |

### Permission Update Entries (PermissionRequest)

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules`, `behavior`, `destination` | Add permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replace all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Remove matching rules |
| `setMode` | `mode`, `destination` | Change permission mode |
| `addDirectories` | `directories`, `destination` | Add working directories |
| `removeDirectories` | `directories`, `destination` | Remove working directories |

Destinations: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`

### Environment Variables

| Variable | Available in | Description |
|:---------|:-------------|:------------|
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `$CLAUDE_PLUGIN_ROOT` | Plugin hooks | Plugin installation directory |
| `$CLAUDE_PLUGIN_DATA` | Plugin hooks | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | SessionStart only | File path to persist env vars for subsequent Bash commands |
| `$CLAUDE_CODE_REMOTE` | All hooks | `"true"` in remote web environments |

### MCP Tool Matching

MCP tools follow `mcp__<server>__<tool>` naming. Match with regex patterns:
- `mcp__memory__.*` -- all tools from memory server
- `mcp__.*__write.*` -- any write tool from any server

### Prompt/Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

### Async Hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately. Results delivered on next conversation turn via `systemMessage` or `additionalContext`. Cannot block or return decisions.

### Disable Hooks

Set `"disableAllHooks": true` in settings. Managed settings hierarchy applies: user/project/local settings cannot disable managed hooks.

### Debugging

- `/hooks` menu: read-only browser for all configured hooks
- `Ctrl+O`: toggle verbose mode to see hook output in transcript
- `claude --debug`: full execution details including matched hooks and exit codes

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Hook not firing | Check `/hooks` for correct event; verify matcher is case-sensitive match; check event type timing |
| Hook error in output | Test script manually with piped JSON; check `jq` installed; ensure script is executable |
| `/hooks` shows nothing | Validate JSON syntax; confirm settings file location; restart session if file watcher missed change |
| Stop hook runs forever | Check `stop_hook_active` field in input and exit early if `true` |
| JSON validation failed | Wrap `echo` statements in shell profile with interactive check (`[[ $- == *i* ]]`) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas and JSON input/output formats for all 21 hook events, configuration schema (hook events, matcher groups, handler fields for command/http/prompt/agent types), hook lifecycle and resolution flow, common input fields, exit code semantics (0/2/other) with per-event behavior table, JSON output fields (continue, stopReason, suppressOutput, systemMessage), decision control patterns per event (top-level decision, hookSpecificOutput for PreToolUse/PermissionRequest/Elicitation), permission update entries (addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories with destinations), tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), MCP tool matching patterns, hook locations and scope, matcher patterns per event, hooks in skills and agents (frontmatter), /hooks menu, disableAllHooks, prompt-based hooks (configuration, response schema, event support), agent-based hooks (multi-turn tool access, configuration), async hooks (background execution, limitations), HTTP hooks (url, headers, allowedEnvVars, response handling), environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, CLAUDE_ENV_FILE, CLAUDE_CODE_REMOTE), security considerations, debugging with --debug and verbose mode
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- getting started walkthrough (first hook setup, /hooks verification, testing), common use cases with ready-to-use config blocks (desktop notifications on macOS/Linux/Windows, auto-format with Prettier on PostToolUse, block edits to protected files with PreToolUse, re-inject context after compaction with SessionStart compact matcher, audit config changes with ConfigChange, auto-approve ExitPlanMode with PermissionRequest including setMode for updatedPermissions), how hooks work (event lifecycle table, hook types overview, input/output via stdin/stdout/stderr/exit codes, structured JSON output, matcher filtering with per-event table), hook location/scope matrix, prompt-based hooks (LLM yes/no decisions, Stop hook example), agent-based hooks (multi-turn verification, test suite example), HTTP hooks (POST to endpoint, header env var interpolation, response handling), limitations and troubleshooting (hook not firing, hook errors, missing hooks in menu, infinite Stop loops, JSON validation issues, debug techniques with Ctrl+O and --debug)

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
