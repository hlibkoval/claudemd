---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, hook types (command/HTTP/MCP/prompt/agent), matcher patterns, JSON input/output schemas, exit codes, decision control, async hooks, and security considerations.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Configuration Structure

Hooks are defined in settings JSON files under a `hooks` key:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell command>"
          }
        ]
      }
    ]
  }
}
```

### Hook Settings Locations

| Location                                        | Scope                 | Shareable |
| :---------------------------------------------- | :-------------------- | :-------- |
| `~/.claude/settings.json`                        | All your projects     | No        |
| `.claude/settings.json`                          | Single project        | Yes       |
| `.claude/settings.local.json`                    | Single project        | No        |
| Managed policy settings                          | Organization-wide     | Yes       |
| Plugin `hooks/hooks.json`                        | When plugin enabled   | Yes       |
| Skill or agent frontmatter                       | While component active | Yes      |

Manage and inspect with `/hooks` (read-only browser). Disable all hooks: `"disableAllHooks": true` in settings.

### All Hook Events

| Event                 | When it fires                                                         | Can block? |
| :-------------------- | :-------------------------------------------------------------------- | :--------- |
| `SessionStart`        | Session begins or resumes                                             | No         |
| `Setup`               | `--init-only`, `--init -p`, or `--maintenance -p`                    | No         |
| `UserPromptSubmit`    | User submits a prompt, before Claude processes it                     | Yes        |
| `UserPromptExpansion` | Slash command expands into a prompt, before reaching Claude           | Yes        |
| `PreToolUse`          | Before a tool call executes                                           | Yes        |
| `PermissionRequest`   | Permission dialog is about to appear                                  | Yes        |
| `PermissionDenied`    | Tool call denied by auto mode classifier                              | No         |
| `PostToolUse`         | After a tool call succeeds                                            | No*        |
| `PostToolUseFailure`  | After a tool call fails                                               | No*        |
| `PostToolBatch`       | After a full batch of parallel tool calls, before next model call     | Yes        |
| `Stop`                | Claude finishes responding                                            | Yes        |
| `StopFailure`         | Turn ends due to API error                                            | No         |
| `SubagentStart`       | Subagent is spawned                                                   | No         |
| `SubagentStop`        | Subagent finishes                                                     | Yes        |
| `TaskCreated`         | Task is being created via `TaskCreate`                                | Yes        |
| `TaskCompleted`       | Task is being marked as completed                                     | Yes        |
| `TeammateIdle`        | Agent team teammate is about to go idle                               | Yes        |
| `InstructionsLoaded`  | CLAUDE.md or `.claude/rules/*.md` loaded into context                 | No         |
| `ConfigChange`        | Configuration file changes during a session                           | Yes        |
| `CwdChanged`          | Working directory changes                                             | No         |
| `FileChanged`         | Watched file changes on disk                                          | No         |
| `WorktreeCreate`      | Worktree being created (replaces default git behavior)                | Yes        |
| `WorktreeRemove`      | Worktree being removed                                                | No         |
| `PreCompact`          | Before context compaction                                             | Yes        |
| `PostCompact`         | After context compaction                                              | No         |
| `Notification`        | Claude Code sends a notification                                      | No         |
| `Elicitation`         | MCP server requests user input                                        | Yes        |
| `ElicitationResult`   | User responds to MCP elicitation, before response sent                | Yes        |
| `SessionEnd`          | Session terminates                                                    | No         |

\* `PostToolUse`/`PostToolUseFailure`: exit 2 shows stderr to Claude but cannot undo the tool.

### Hook Types

| Type        | Field `type` | Description                                              | Default timeout |
| :---------- | :----------- | :------------------------------------------------------- | :-------------- |
| Command     | `"command"`  | Runs a shell command; stdin/stdout/exit code protocol    | 600s            |
| HTTP        | `"http"`     | POSTs event JSON to a URL; response body = output        | 30s             |
| MCP tool    | `"mcp_tool"` | Calls a tool on an already-connected MCP server          | 600s            |
| Prompt      | `"prompt"`   | Single-turn LLM evaluation returning `{ok, reason}`      | 30s             |
| Agent       | `"agent"`    | Multi-turn subagent with tool access (experimental)      | 60s             |

### Common Hook Handler Fields

| Field           | Required | Description                                                                     |
| :-------------- | :------- | :------------------------------------------------------------------------------ |
| `type`          | yes      | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"`                  |
| `if`            | no       | Permission rule syntax filter (e.g., `"Bash(git *)"`, `"Edit(*.ts)"`)          |
| `timeout`       | no       | Override default timeout in seconds                                             |
| `statusMessage` | no       | Custom spinner message while hook runs                                          |
| `once`          | no       | Run once per session (skill frontmatter hooks only)                             |

### Command Hook Fields

| Field         | Required | Description                                                              |
| :------------ | :------- | :----------------------------------------------------------------------- |
| `command`     | yes      | Shell command (shell form) or executable (exec form with `args`)         |
| `args`        | no       | Argument vector; when present, spawns executable directly (exec form)    |
| `async`       | no       | If `true`, runs in background without blocking                           |
| `asyncRewake` | no       | Background; wakes Claude on exit 2; implies `async`                      |
| `shell`       | no       | `"bash"` (default) or `"powershell"` (ignored when `args` is set)       |

### HTTP Hook Fields

| Field            | Required | Description                                                                          |
| :--------------- | :------- | :----------------------------------------------------------------------------------- |
| `url`            | yes      | URL to POST the event JSON to                                                        |
| `headers`        | no       | Additional headers; values support `$VAR` / `${VAR}` env var interpolation          |
| `allowedEnvVars` | no       | Which env vars may be interpolated into headers (required for interpolation to work) |

### MCP Tool Hook Fields

| Field    | Required | Description                                                                               |
| :------- | :------- | :---------------------------------------------------------------------------------------- |
| `server` | yes      | Name of an already-connected MCP server                                                   |
| `tool`   | yes      | Tool name on that server                                                                  |
| `input`  | no       | Tool arguments; string values support `${path}` substitution from the hook's JSON input   |

### Prompt / Agent Hook Fields

| Field    | Required | Description                                                                       |
| :------- | :------- | :-------------------------------------------------------------------------------- |
| `prompt` | yes      | Prompt text sent to the model; use `$ARGUMENTS` as placeholder for hook input JSON |
| `model`  | no       | Model to use; defaults to a fast model                                            |

### Exit Codes (Command Hooks)

| Exit code | Meaning                                                                            |
| :-------- | :--------------------------------------------------------------------------------- |
| 0         | Success; JSON from stdout is processed; stdout added to context on some events     |
| 2         | Blocking error; stderr fed to Claude or user; blocks the action where supported    |
| Other     | Non-blocking error; transcript shows `<hook name> hook error`; execution continues |

`WorktreeCreate` is the exception: any non-zero exit code aborts creation.

### JSON Output Fields (exit 0)

| Field            | Default | Description                                                                   |
| :--------------- | :------ | :---------------------------------------------------------------------------- |
| `continue`       | `true`  | If `false`, Claude stops entirely regardless of event                         |
| `stopReason`     | none    | Message shown to user when `continue` is `false`                              |
| `suppressOutput` | `false` | Omit stdout from debug log                                                    |
| `systemMessage`  | none    | Warning message shown to the user                                             |

### Decision Control Summary

| Events                                                                                                              | Pattern                   | Key fields                                           |
| :------------------------------------------------------------------------------------------------------------------ | :------------------------ | :--------------------------------------------------- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse`                                                                                                        | `hookSpecificOutput`      | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest`                                                                                                 | `hookSpecificOutput`      | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied`                                                                                                  | `hookSpecificOutput`      | `retry: true` lets model retry the denied call       |
| `WorktreeCreate`                                                                                                    | stdout path               | Print worktree path to stdout; HTTP: `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult`                                                                                  | `hookSpecificOutput`      | `action` (accept/decline/cancel), `content`          |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted`                                                                      | exit 2 or `continue:false`| Exit 2 blocks; `continue: false` stops the teammate  |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only                           |

### Matcher Patterns

| Matcher value                         | Evaluated as                                              |
| :------------------------------------ | :-------------------------------------------------------- |
| `""`, `"*"`, or omitted               | Match all (fire on every occurrence)                      |
| Letters, digits, `_`, and `\|` only   | Exact string or `\|`-separated list of exact strings      |
| Any other character                   | JavaScript regular expression                             |

`FileChanged` builds a watch list from literal filenames only (no regex evaluation).

#### What each event matches on

| Event(s)                                                                                     | Matcher filters                       | Example values                                                                      |
| :------------------------------------------------------------------------------------------- | :------------------------------------ | :---------------------------------------------------------------------------------- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`  | tool name                             | `Bash`, `Edit\|Write`, `mcp__memory__.*`                                            |
| `SessionStart`                                                                               | session source                        | `startup`, `resume`, `clear`, `compact`                                             |
| `Setup`                                                                                      | CLI flag                              | `init`, `maintenance`                                                               |
| `SessionEnd`                                                                                 | end reason                            | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification`                                                                               | notification type                     | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop`                                                              | agent type                            | `general-purpose`, `Explore`, `Plan`, custom names                                  |
| `PreCompact`, `PostCompact`                                                                  | trigger                               | `manual`, `auto`                                                                    |
| `ConfigChange`                                                                               | config source                         | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`  |
| `StopFailure`                                                                                | error type                            | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, etc.        |
| `InstructionsLoaded`                                                                         | load reason                           | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact`        |
| `Elicitation`, `ElicitationResult`                                                           | MCP server name                       | your configured server names                                                        |
| `FileChanged`                                                                                | literal filenames to watch            | `.envrc\|.env`                                                                      |
| `UserPromptExpansion`                                                                        | command name                          | skill or command names                                                              |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher | always fires |

MCP tool names follow `mcp__<server>__<tool>` pattern. Use `mcp__memory__.*` to match all tools from a server. Plain `mcp__memory` (no `.*`) matches nothing.

### Common Input Fields (all events)

| Field             | Description                                                                    |
| :---------------- | :----------------------------------------------------------------------------- |
| `session_id`      | Current session identifier                                                     |
| `transcript_path` | Path to conversation JSON                                                      |
| `cwd`             | Current working directory when the hook fires                                  |
| `permission_mode` | Current permission mode (not all events include this)                          |
| `effort`          | `{level: "low"\|"medium"\|"high"\|"xhigh"\|"max"}` (tool-context events only) |
| `hook_event_name` | Name of the event that fired                                                   |
| `agent_id`        | Subagent identifier (only inside a subagent)                                   |
| `agent_type`      | Agent name (only with `--agent` or inside a subagent)                          |

### Path Placeholders

| Placeholder             | Resolves to                                           |
| :---------------------- | :---------------------------------------------------- |
| `${CLAUDE_PROJECT_DIR}` | Project root                                          |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on update)     |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (survives updates)   |

Use exec form (`args: []`) with path placeholders to avoid shell quoting issues.

### `CLAUDE_ENV_FILE` (Persist Environment Variables)

Available in `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to the file path stored in `$CLAUDE_ENV_FILE`; those variables become available in all subsequent Bash commands for the session.

```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

### `additionalContext` Output Field

Inject a string into Claude's context from any hook via `hookSpecificOutput.additionalContext`. Available on: `SessionStart`, `Setup`, `SubagentStart`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`. Capped at 10,000 characters; overflow saved to a file with a path reference.

### Combining Multiple Hooks

- All matching hooks run in parallel; identical commands are deduplicated.
- One hook returning `deny` does not stop sibling hooks from executing.
- For `PreToolUse` permission decisions: `deny` > `defer` > `ask` > `allow`.
- `additionalContext` from all hooks is combined and passed to Claude.

### Async Hooks

Set `async: true` to run a command hook in the background without blocking the lifecycle event. Set `asyncRewake: true` to additionally wake Claude with a system reminder when the hook exits with code 2.

### Prompt-based Hooks

`type: "prompt"` hooks send the event data and your prompt to a Claude model (Haiku by default) for a yes/no decision:

- `"ok": true` — action proceeds
- `"ok": false` — see per-event behavior:
  - `Stop`, `SubagentStop`: reason fed back to Claude (Claude keeps working)
  - `PreToolUse`: tool call denied; reason shown to Claude
  - `PostToolUse`, `PostToolBatch`, `UserPromptSubmit`, `UserPromptExpansion`: turn ends; reason shown in chat

### Hooks in Skill / Agent Frontmatter

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
```

All events supported. In subagents, `Stop` hooks auto-convert to `SubagentStop`.

### Hooks and Permissions

- `PreToolUse` hooks fire before any permission-mode check.
- A hook returning `deny` blocks the tool even in `bypassPermissions` mode.
- A hook returning `allow` does not override deny rules from settings.

### Troubleshooting

| Symptom                          | Fix                                                                                    |
| :------------------------------- | :------------------------------------------------------------------------------------- |
| Hook not firing                  | Check `/hooks`, verify matcher case, check event type, avoid `PermissionRequest` in `-p` mode |
| Hook error in transcript         | Test with `echo '{"tool_name":"Bash",...}' \| ./my-hook.sh`; use absolute paths or exec form |
| `/hooks` shows nothing           | Validate JSON (no trailing commas), check file location, restart session               |
| Stop hook loops forever          | Check `stop_hook_active` field in stdin; exit 0 if `true`                              |
| JSON validation failed           | Shell profile echoes text; wrap echo statements with `if [[ $- == *i* ]]; then`        |

Debug: use `ctrl+O` for transcript view, or `claude --debug-file /tmp/claude.log` for full logs.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — setup walkthrough, common use-case examples, hook type overview, prompt/agent hooks, HTTP hooks, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, exit codes, decision control, async hooks, MCP tool hooks, and security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
