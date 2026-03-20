---
name: hooks-doc
description: Complete documentation for Claude Code hooks — user-defined shell commands, HTTP endpoints, LLM prompts, and agent verifiers that execute at specific lifecycle points. Covers all 21 hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), four hook types (command, http, prompt, agent), configuration schema and locations (user/project/local/managed/plugin/skill frontmatter), matcher patterns and regex filtering, JSON input/output formats, exit code semantics (0 allow, 2 block), decision control patterns (top-level decision, hookSpecificOutput, permissionDecision, PermissionRequest decision.behavior), structured JSON output fields (continue, stopReason, suppressOutput, systemMessage), PreToolUse tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), PermissionRequest updatedPermissions and permission_suggestions, PostToolUse updatedMCPToolOutput, async hooks, CLAUDE_ENV_FILE for persisting environment variables, common input fields (session_id, cwd, transcript_path, permission_mode, hook_event_name, agent_id, agent_type), prompt-based hooks (ok/reason response schema, $ARGUMENTS placeholder, model selection), agent-based hooks (multi-turn verification with tool access), HTTP hooks (url, headers, allowedEnvVars, response handling), hooks in skills and agents via frontmatter, /hooks menu, disableAllHooks, reference scripts by path ($CLAUDE_PROJECT_DIR, $CLAUDE_PLUGIN_ROOT, $CLAUDE_PLUGIN_DATA), security best practices, debug techniques (--debug, Ctrl+O verbose mode), common use cases (desktop notifications, auto-format with Prettier, block protected files, re-inject context after compaction, audit config changes, auto-approve permission prompts), troubleshooting (hook not firing, hook error, /hooks shows nothing, Stop hook loops, JSON validation failed from shell profile echo). Load when discussing hooks, lifecycle hooks, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, hook matchers, hook events, hook configuration, auto-formatting, auto-approval, blocking tool calls, prompt hooks, agent hooks, HTTP hooks, async hooks, hook input/output, exit codes, decision control, CLAUDE_ENV_FILE, ConfigChange, WorktreeCreate, WorktreeRemove, InstructionsLoaded, Elicitation, ElicitationResult, TeammateIdle, TaskCompleted, SessionStart, SessionEnd, StopFailure, SubagentStart, SubagentStop, PreCompact, PostCompact, or automating Claude Code workflows.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- user-defined automation that runs at specific points in Claude Code's lifecycle.

## Quick Reference

Hooks are shell commands, HTTP endpoints, LLM prompts, or agent verifiers that execute automatically when Claude Code edits files, finishes tasks, needs input, or hits other lifecycle events. They provide deterministic control over behavior.

### Hook Types

| Type | Description | Default timeout |
|:-----|:------------|:----------------|
| `command` | Run a shell command; receives JSON on stdin, communicates via exit codes and stdout | 600s |
| `http` | POST event JSON to a URL; results via response body | 600s |
| `prompt` | Single-turn LLM evaluation; returns `{ok, reason}` decision | 30s |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob); returns `{ok, reason}` | 60s |

### Hook Events

| Event | When it fires | Matcher filters | Can block? |
|:------|:--------------|:----------------|:-----------|
| `SessionStart` | Session begins or resumes | `startup`, `resume`, `clear`, `compact` | No |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` loaded | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` | No |
| `UserPromptSubmit` | User submits a prompt | no matcher | Yes |
| `PreToolUse` | Before a tool call executes | tool name (`Bash`, `Edit\|Write`, `mcp__.*`) | Yes |
| `PermissionRequest` | Permission dialog appears | tool name | Yes |
| `PostToolUse` | After a tool call succeeds | tool name | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | tool name | No (feedback only) |
| `Notification` | Claude sends a notification | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` | No |
| `SubagentStart` | Subagent is spawned | agent type (`Bash`, `Explore`, `Plan`, custom) | No |
| `SubagentStop` | Subagent finishes | agent type | Yes |
| `Stop` | Claude finishes responding | no matcher | Yes |
| `StopFailure` | Turn ends due to API error | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` | No |
| `TeammateIdle` | Agent team teammate about to go idle | no matcher | Yes |
| `TaskCompleted` | Task being marked completed | no matcher | Yes |
| `ConfigChange` | Configuration file changes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | Yes (not policy) |
| `WorktreeCreate` | Worktree being created | no matcher | Yes (non-zero exit) |
| `WorktreeRemove` | Worktree being removed | no matcher | No |
| `PreCompact` | Before context compaction | `manual`, `auto` | No |
| `PostCompact` | After compaction completes | `manual`, `auto` | No |
| `Elicitation` | MCP server requests user input | MCP server name | Yes |
| `ElicitationResult` | User responds to MCP elicitation | MCP server name | Yes |
| `SessionEnd` | Session terminates | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | No |

### Configuration Structure

Hooks are defined in settings JSON with three levels of nesting: event, matcher group, hook handlers.

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex pattern>",
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
| `.claude/settings.json` | Single project | Yes (committable) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While component is active | Yes |

### Hook Handler Fields

**Common fields (all types):**

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `timeout` | no | Seconds before canceling |
| `statusMessage` | no | Custom spinner message |
| `once` | no | If true, runs only once per session (skills only) |

**Command-specific:** `command` (shell command), `async` (run in background)

**HTTP-specific:** `url`, `headers` (supports `$VAR_NAME` interpolation), `allowedEnvVars`

**Prompt/agent-specific:** `prompt` (use `$ARGUMENTS` for hook input JSON), `model`

### Common Input Fields (JSON on stdin)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside a subagent) |

### Exit Code Semantics

| Exit code | Effect |
|:----------|:-------|
| **0** | Action proceeds; stdout parsed for JSON output |
| **2** | Action blocked; stderr fed back to Claude as error |
| **Other** | Non-blocking error; stderr logged in verbose mode |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code or `continue: false` | Exit 2 with stderr, or JSON `{"continue": false, "stopReason": "..."}` |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| WorktreeCreate | stdout path | Print absolute path to created worktree |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (`accept`/`decline`/`cancel`), `content` |
| Notification, SessionEnd, PreCompact, PostCompact, InstructionsLoaded, StopFailure, WorktreeRemove | None | No decision control; used for side effects |

### Universal JSON Output Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If false, Claude stops entirely |
| `stopReason` | none | Message shown to user when `continue` is false |
| `suppressOutput` | `false` | If true, hides stdout from verbose mode |
| `systemMessage` | none | Warning message shown to user |

### PreToolUse Tool Input Schemas

Each tool provides different fields in `tool_input`:

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

MCP tools use the naming pattern `mcp__<server>__<tool>` (e.g., `mcp__github__search_repositories`).

### PermissionRequest Permission Updates

The `updatedPermissions` array supports these entry types:

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules`, `behavior`, `destination` | Add permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replace all rules of a behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Remove matching rules |
| `setMode` | `mode`, `destination` | Change permission mode |
| `addDirectories` | `directories`, `destination` | Add working directories |
| `removeDirectories` | `directories`, `destination` | Remove working directories |

Destination values: `session`, `localSettings`, `projectSettings`, `userSettings`.

### Prompt and Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

Events supporting prompt/agent hooks: PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Stop, SubagentStop, TaskCompleted, UserPromptSubmit.

Events supporting only command hooks: ConfigChange, Elicitation, ElicitationResult, InstructionsLoaded, Notification, PostCompact, PreCompact, SessionEnd, SessionStart, StopFailure, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove.

### Async Hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately; results delivered on the next conversation turn via `systemMessage` or `additionalContext`. Async hooks cannot block actions or return decisions. Only `type: "command"` supports async.

### CLAUDE_ENV_FILE

Available in `SessionStart` hooks only. Write `export VAR=value` lines to this file to persist environment variables for all subsequent Bash commands in the session. Use append (`>>`) to preserve variables from other hooks.

### Environment Variables for Script Paths

| Variable | Description |
|:---------|:------------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin's persistent data directory |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

### Debugging

- `claude --debug` for full execution details
- `Ctrl+O` to toggle verbose mode in the transcript
- `/hooks` menu to browse all configured hooks (read-only)
- Set `"disableAllHooks": true` in settings to disable all hooks

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Hook not firing | Run `/hooks` to verify it appears; check matcher is case-sensitive and matches the tool name; verify correct event type |
| Hook error in output | Test script manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./my-hook.sh`; check for missing `jq`; ensure script is executable |
| `/hooks` shows no hooks | Verify JSON is valid (no trailing commas); confirm correct settings file location; restart session if file watcher missed the change |
| Stop hook runs forever | Check `stop_hook_active` field in input and exit early if true |
| JSON validation failed | Shell profile `echo` statements interfere; wrap them in `if [[ $- == *i* ]]` to skip in non-interactive shells |
| PermissionRequest hooks not firing in `-p` mode | Use PreToolUse hooks instead for non-interactive/headless mode |

### SessionEnd Timeout

Default timeout for SessionEnd hooks is 1.5 seconds. Override with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` environment variable (milliseconds).

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas, JSON input/output formats, exit codes, decision control patterns (PreToolUse permissionDecision, PermissionRequest decision.behavior, top-level decision block), hook handler fields (command, http, prompt, agent), matcher patterns and regex filtering, common input fields, PreToolUse tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), PermissionRequest updatedPermissions and permission_suggestions, PostToolUse updatedMCPToolOutput, async hooks, CLAUDE_ENV_FILE, prompt-based hooks ($ARGUMENTS, ok/reason response), agent-based hooks (multi-turn with tool access), HTTP hooks (url, headers, allowedEnvVars, response handling), hooks in skills and agents via frontmatter, /hooks menu, disableAllHooks, reference scripts by path, security considerations, debug techniques
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- getting started walkthrough, common use cases (desktop notifications on macOS/Linux/Windows, auto-format with Prettier, block edits to protected files, re-inject context after compaction, audit configuration changes, auto-approve ExitPlanMode), how hooks work (event lifecycle, input/output, exit codes, structured JSON, matchers), hook locations and scope, prompt-based hooks, agent-based hooks, HTTP hooks, limitations and troubleshooting

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
