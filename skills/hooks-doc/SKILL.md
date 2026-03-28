---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- covering hook lifecycle events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), configuration schema (hook locations in settings files/plugins/skills/agents, matcher patterns with regex filtering, hook handler fields for command/http/prompt/agent types, common fields type/if/timeout/statusMessage/once, command hook fields command/async/shell, HTTP hook fields url/headers/allowedEnvVars, prompt and agent hook fields prompt/model), hook input and output (common input fields session_id/transcript_path/cwd/permission_mode/hook_event_name/agent_id/agent_type, exit code semantics 0/2/other, exit code 2 blocking behavior per event, HTTP response handling, JSON output fields continue/stopReason/suppressOutput/systemMessage, decision control patterns top-level-decision/hookSpecificOutput/permissionDecision/path-return), tool input schemas (Bash/Write/Edit/Read/Glob/Grep/WebFetch/WebSearch/Agent/AskUserQuestion), PreToolUse decision control (permissionDecision allow/deny/ask, updatedInput, additionalContext), PermissionRequest decision control (behavior allow/deny, updatedInput, updatedPermissions with addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories, permission_suggestions), PostToolUse decision control (decision block, additionalContext, updatedMCPToolOutput), Stop/SubagentStop decision control (decision block, reason), environment variables (CLAUDE_PROJECT_DIR, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, CLAUDE_ENV_FILE for SessionStart/CwdChanged/FileChanged, CLAUDE_CODE_REMOTE), async hooks (background execution, systemMessage/additionalContext delivery on next turn), prompt-based hooks (type prompt, ok/reason response schema, model selection, single-turn LLM evaluation), agent-based hooks (type agent, multi-turn tool access with Read/Grep/Glob, 50-turn limit), MCP tool matching (mcp__server__tool naming pattern, regex matchers), hooks in skills and agents (frontmatter definition, once field, lifecycle scoping), /hooks menu (read-only browser, source labels User/Project/Local/Plugin/Session/Built-in), disableAllHooks setting, allowManagedHooksOnly enterprise control, security considerations (full user permissions, input validation, path quoting), Windows PowerShell support (shell powershell field), debug hooks (claude --debug, Ctrl+O verbose mode), common automation patterns (notifications, auto-format code, block protected files, re-inject context after compaction, audit config changes, reload environment on directory/file change, auto-approve permission prompts), troubleshooting (hook not firing, hook error, JSON validation failed from shell profile echo, stop hook infinite loop with stop_hook_active check, /hooks shows no hooks). Load when discussing Claude Code hooks, hook events, hook lifecycle, hook configuration, PreToolUse, PostToolUse, PermissionRequest, SessionStart, Stop, SubagentStop, UserPromptSubmit, Notification, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, InstructionsLoaded, Elicitation, StopFailure, TeammateIdle, TaskCreated, TaskCompleted, PreCompact, PostCompact, SessionEnd, hook matchers, hook handlers, command hooks, HTTP hooks, prompt hooks, agent hooks, async hooks, hook input/output, exit codes, JSON output, decision control, permissionDecision, updatedInput, updatedPermissions, CLAUDE_ENV_FILE, hook security, disableAllHooks, /hooks menu, hook troubleshooting, auto-format hooks, notification hooks, file protection hooks, compaction hooks, or any hooks-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- covering the hooks guide (setup, common patterns, prompt/agent/HTTP hooks) and the hooks reference (full event schemas, JSON I/O, decision control, async hooks).

## Quick Reference

### Hook Events Summary

| Event | When it fires | Can block? | Matcher filters |
|:------|:-------------|:-----------|:----------------|
| `SessionStart` | Session begins/resumes | No | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptSubmit` | User submits a prompt | Yes | No matcher support |
| `PreToolUse` | Before tool call executes | Yes | Tool name: `Bash`, `Edit`, `Write`, `mcp__.*` |
| `PermissionRequest` | Permission dialog appears | Yes | Tool name (same as PreToolUse) |
| `PostToolUse` | After tool call succeeds | No (feedback only) | Tool name |
| `PostToolUseFailure` | After tool call fails | No | Tool name |
| `Notification` | Notification sent | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type: `Bash`, `Explore`, `Plan`, custom names |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `TaskCreated` | Task being created | Yes | No matcher support |
| `TaskCompleted` | Task being completed | Yes | No matcher support |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `StopFailure` | Turn ends due to API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Teammate about to go idle | Yes | No matcher support |
| `ConfigChange` | Config file changes | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | No | No matcher support |
| `FileChanged` | Watched file changes on disk | No | Filename basename: `.envrc`, `.env` |
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
| `command` | Run a shell command (stdin JSON, exit codes) | 600s |
| `http` | POST event JSON to a URL endpoint | 600s |
| `prompt` | Single-turn LLM evaluation (ok/reason response) | 30s |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob) | 60s |

### Hook Configuration Locations

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
            "command": "your-script.sh",
            "if": "Bash(git *)",
            "timeout": 30,
            "async": true,
            "statusMessage": "Running check...",
            "once": true,
            "shell": "powershell"
          }
        ]
      }
    ]
  }
}
```

### Common Handler Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax filter, e.g. `"Bash(git *)"`, `"Edit(*.ts)"`. Tool events only |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message |
| `once` | No | If true, runs only once per session (skills only) |

### Command Hook Additional Fields

| Field | Description |
|:------|:------------|
| `command` | Shell command to execute |
| `async` | If true, runs in background without blocking |
| `shell` | `"bash"` (default) or `"powershell"` (Windows) |

### HTTP Hook Additional Fields

| Field | Description |
|:------|:------------|
| `url` | URL to POST to |
| `headers` | Key-value headers; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | List of env var names allowed in header interpolation |

### Prompt/Agent Hook Additional Fields

| Field | Description |
|:------|:------------|
| `prompt` | Prompt text; use `$ARGUMENTS` for hook input JSON placeholder |
| `model` | Model to use (defaults to fast model) |

### Exit Code Semantics

| Exit code | Effect |
|:----------|:-------|
| **0** | Success. stdout parsed for JSON output |
| **2** | Blocking error. stderr fed back to Claude. Blocks the action on supporting events |
| **Other** | Non-blocking error. stderr logged in verbose mode. Execution continues |

### JSON Output Fields (on exit 0)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If false, stops Claude entirely |
| `stopReason` | none | Message shown to user when continue is false |
| `suppressOutput` | `false` | If true, hides stdout from verbose output |
| `systemMessage` | none | Warning shown to user |
| `decision` | none | `"block"` for PostToolUse, Stop, SubagentStop, UserPromptSubmit, ConfigChange |
| `reason` | none | Explanation when decision is block |

### Decision Control Patterns by Event

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| TeammateIdle, TaskCreated, TaskCompleted | Exit code or `continue: false` | Exit 2 blocks with stderr feedback; JSON `continue: false` stops teammate |
| WorktreeCreate | Path return | Command: print path on stdout; HTTP: `hookSpecificOutput.worktreePath` |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |

### Common Input Fields (all events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using --agent or inside subagent) |

### Environment Variables for Hook Scripts

| Variable | Description |
|:---------|:------------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart, CwdChanged, FileChanged only) |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

### Prompt/Agent Hook Response Schema

```json
{
  "ok": true,
  "reason": "Explanation (required when ok is false)"
}
```

### MCP Tool Naming Pattern

MCP tools follow `mcp__<server>__<tool>`, e.g.:
- `mcp__memory__create_entities`
- `mcp__github__search_repositories`

Match with regex: `mcp__memory__.*`, `mcp__.*__write.*`

### Key Settings

| Setting | Description |
|:--------|:------------|
| `disableAllHooks: true` | Temporarily disable all hooks |
| `allowManagedHooksOnly` | Enterprise: block user/project/plugin hooks |

### Troubleshooting Quick Reference

| Issue | Fix |
|:------|:----|
| Hook not firing | Check `/hooks` menu, verify matcher case-sensitivity, confirm correct event type |
| Hook error in output | Test script manually: `echo '{"tool_name":"Bash"}' \| ./hook.sh` |
| JSON validation failed | Wrap shell profile echo statements in `if [[ $- == *i* ]]` check |
| Stop hook infinite loop | Check `stop_hook_active` field and exit 0 if true |
| `/hooks` shows nothing | Validate JSON syntax, confirm file location, restart session |
| PermissionRequest not firing in `-p` mode | Use PreToolUse hooks instead for non-interactive mode |

### Debug Hooks

- Run `claude --debug` for full execution details
- Toggle verbose mode with `Ctrl+O` to see hook output in transcript

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) -- Full event schemas, JSON input/output formats, configuration schema, matcher patterns, decision control, async hooks, HTTP hooks, prompt hooks, agent hooks, MCP tool hooks, security considerations
- [Hooks Guide](references/claude-code-hooks-guide.md) -- Getting started, common automation patterns (notifications, auto-format, file protection, compaction context, config auditing, env reload, auto-approve), prompt-based hooks, agent-based hooks, HTTP hooks, troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
