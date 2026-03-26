---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- user-defined shell commands, HTTP endpoints, LLM prompts, and agent verifiers that execute at specific lifecycle points. Covers all 24 hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), four hook types (command with shell/async/timeout, http with url/headers/allowedEnvVars, prompt with LLM evaluation returning ok/reason, agent with multi-turn subagent verification), configuration schema (event > matcher group > hook handler nesting, matcher regex patterns per event, common fields type/timeout/statusMessage/once), hook locations (user ~/.claude/settings.json, project .claude/settings.json, local .claude/settings.local.json, managed policy, plugin hooks/hooks.json, skill/agent frontmatter), input/output (common input fields session_id/transcript_path/cwd/permission_mode/hook_event_name, agent_id/agent_type for subagents, exit codes 0/2/other, JSON output with continue/stopReason/suppressOutput/systemMessage, decision control patterns per event), PreToolUse tool input schemas (Bash command/description/timeout/run_in_background, Write file_path/content, Edit file_path/old_string/new_string/replace_all, Read file_path/offset/limit, Glob pattern/path, Grep pattern/path/glob/output_mode, WebFetch url/prompt, WebSearch query/allowed_domains/blocked_domains, Agent prompt/description/subagent_type/model), PreToolUse decision control (permissionDecision allow/deny/ask, updatedInput, additionalContext), PermissionRequest decision control (behavior allow/deny, updatedInput, updatedPermissions with addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories, permission_suggestions input), PostToolUse decision control (decision block, reason, additionalContext, updatedMCPToolOutput), Stop/SubagentStop decision control (decision block, reason, stop_hook_active loop prevention), ConfigChange decision control (decision block, reason, policy_settings immune), environment persistence (CLAUDE_ENV_FILE for SessionStart/CwdChanged/FileChanged), async hooks (async true on command hooks, background execution, systemMessage delivery on next turn), MCP tool matching (mcp__server__tool naming, regex patterns), worktree hooks (WorktreeCreate returns path, WorktreeRemove cleanup), prompt hooks (type prompt, $ARGUMENTS placeholder, ok/reason response, model selection, 30s default timeout), agent hooks (type agent, multi-turn tool access Read/Grep/Glob, 50 turn limit, 60s default timeout), security considerations (full user permissions, input validation, quote variables, absolute paths), disableAllHooks setting, /hooks menu (read-only browser, source labels User/Project/Local/Plugin/Session/Built-in), Windows PowerShell (shell powershell field, pwsh.exe auto-detect), debug mode (claude --debug, Ctrl+O verbose), SessionEnd timeout (1.5s default, CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS override), allowManagedHooksOnly enterprise setting. Load when discussing hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, Stop hook, SessionStart hook, UserPromptSubmit, Notification hook, SubagentStart, SubagentStop, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation hook, ElicitationResult, SessionEnd, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, hook matchers, hook configuration, hook input, hook output, exit codes, JSON hook output, decision control, permissionDecision, async hooks, prompt hooks, agent hooks, HTTP hooks, hook types, CLAUDE_ENV_FILE, disableAllHooks, /hooks command, hook security, auto-format hook, notification hook, block edits hook, auto-approve hook, hook lifecycle, hook troubleshooting, or any hooks-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- user-defined shell commands, HTTP endpoints, LLM prompts, and agent verifiers that run automatically at specific points in Claude Code's lifecycle.

## Quick Reference

Hooks provide deterministic control over Claude Code's behavior by executing code at lifecycle points like file edits, tool calls, session events, and permission prompts. They are defined in JSON settings files and support four handler types.

### Hook Types

| Type | Field | Description | Default Timeout |
|:-----|:------|:------------|:----------------|
| `command` | `command` | Shell command; receives JSON on stdin, returns exit code + stdout | 600s |
| `http` | `url` | POST to URL; same JSON as body, response body for output | 600s |
| `prompt` | `prompt` | Single-turn LLM evaluation; returns `{ok, reason}` | 30s |
| `agent` | `prompt` | Multi-turn subagent with tool access (Read, Grep, Glob); returns `{ok, reason}` | 60s |

### All Hook Events

| Event | When it fires | Matcher filters | Can block? |
|:------|:--------------|:----------------|:-----------|
| `SessionStart` | Session begins/resumes | `startup`, `resume`, `clear`, `compact` | No |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` | No |
| `UserPromptSubmit` | User submits prompt | No matcher support | Yes |
| `PreToolUse` | Before tool executes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) | Yes |
| `PermissionRequest` | Permission dialog appears | Tool name | Yes |
| `PostToolUse` | After tool succeeds | Tool name | No (feedback only) |
| `PostToolUseFailure` | After tool fails | Tool name | No (feedback only) |
| `Notification` | Notification sent | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` | No |
| `SubagentStart` | Subagent spawned | Agent type (`Bash`, `Explore`, `Plan`, custom) | No |
| `SubagentStop` | Subagent finishes | Agent type | Yes |
| `Stop` | Claude finishes responding | No matcher support | Yes |
| `StopFailure` | Turn ends due to API error | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` | No |
| `TeammateIdle` | Teammate about to go idle | No matcher support | Yes |
| `TaskCompleted` | Task marked completed | No matcher support | Yes |
| `ConfigChange` | Config file changes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | Yes (except policy) |
| `CwdChanged` | Working directory changes | No matcher support | No |
| `FileChanged` | Watched file changes | Filename basename (`.envrc`, `.env`) | No |
| `WorktreeCreate` | Worktree being created | No matcher support | Yes (failure = blocked) |
| `WorktreeRemove` | Worktree being removed | No matcher support | No |
| `PreCompact` | Before compaction | `manual`, `auto` | No |
| `PostCompact` | After compaction | `manual`, `auto` | No |
| `Elicitation` | MCP server requests input | MCP server name | Yes |
| `ElicitationResult` | User responds to elicitation | MCP server name | Yes |
| `SessionEnd` | Session terminates | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | No |

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
            "timeout": 30,
            "async": false,
            "statusMessage": "Running hook..."
          }
        ]
      }
    ]
  }
}
```

Three nesting levels: event name > matcher group (regex filter) > hook handlers (run in parallel).

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled) |
| Skill/agent frontmatter | While component active | Yes (in component file) |

### Common Input Fields (JSON on stdin)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (when inside a subagent) |
| `agent_type` | Agent name (when using `--agent` or inside a subagent) |

### Exit Code Behavior

| Exit Code | Effect |
|:----------|:-------|
| **0** | Action proceeds; stdout parsed for JSON output |
| **2** | Action blocked; stderr fed to Claude as error |
| **Other** | Non-blocking error; stderr logged in verbose mode |

### JSON Output Fields (stdout on exit 0)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is false |
| `suppressOutput` | `false` | Hides stdout from verbose output |
| `systemMessage` | none | Warning shown to user |

### Decision Control Patterns by Event

| Events | Pattern | Key Fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code or `continue: false` | Exit 2 with stderr, or JSON `{"continue": false}` |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions` |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| WorktreeCreate | Path return | stdout (command) or `hookSpecificOutput.worktreePath` (HTTP) |

### PreToolUse Tool Input Schemas

| Tool | Key Fields |
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
| MCP tools | `mcp__<server>__<tool>` naming; match with `mcp__server__.*` regex |

### PermissionRequest updatedPermissions Types

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules [{toolName, ruleContent?}]`, `behavior` (allow/deny/ask), `destination` | Adds permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules |
| `setMode` | `mode` (default/acceptEdits/dontAsk/bypassPermissions/plan), `destination` | Changes permission mode |
| `addDirectories` | `directories`, `destination` | Adds working directories |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

Destination values: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Environment Variable Persistence

`CLAUDE_ENV_FILE` is available in `SessionStart`, `CwdChanged`, and `FileChanged` hooks. Write `export VAR=value` lines to persist variables for subsequent Bash commands:

```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

### Handler-Specific Fields

**Command hooks:** `command` (required), `async` (boolean), `shell` (`"bash"` default or `"powershell"`)

**HTTP hooks:** `url` (required), `headers` (key-value, supports `$VAR` interpolation), `allowedEnvVars` (list of allowed env var names)

**Prompt/Agent hooks:** `prompt` (required, use `$ARGUMENTS` for input JSON), `model` (optional, defaults to fast model)

### Key Settings

| Setting | Effect |
|:--------|:-------|
| `disableAllHooks: true` | Disables all hooks (respects managed hierarchy) |
| `allowManagedHooksOnly` | Enterprise: blocks user/project/plugin hooks |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd timeout override (default 1.5s) |

### Prompt/Agent Hook Support

Events supporting all four types (command, http, prompt, agent): `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `PreToolUse`, `Stop`, `SubagentStop`, `TaskCompleted`, `UserPromptSubmit`.

`SessionStart` supports only `command` hooks. All other events support `command` and `http` only.

### Async Hooks

Set `"async": true` on command hooks to run in background. Claude continues immediately. Output delivered on next conversation turn via `systemMessage` or `additionalContext`. Cannot block or return decisions.

### Debugging

- `/hooks` menu: read-only browser showing all configured hooks by event, with source labels (User/Project/Local/Plugin/Session/Built-in)
- `claude --debug`: full hook execution details
- `Ctrl+O`: toggle verbose mode to see hook output in transcript
- Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh; echo $?`

### Common Patterns

- **Auto-format after edits:** `PostToolUse` + matcher `Edit|Write` + prettier command
- **Block protected files:** `PreToolUse` + matcher `Edit|Write` + check file path + exit 2
- **Desktop notifications:** `Notification` + `osascript`/`notify-send`/PowerShell
- **Re-inject context after compaction:** `SessionStart` + matcher `compact` + echo context
- **Auto-approve specific prompts:** `PermissionRequest` + matcher + `decision.behavior: "allow"`
- **Prevent infinite Stop loops:** Check `stop_hook_active` field in Stop hook input
- **Environment reload on cd:** `CwdChanged` + `direnv export bash >> "$CLAUDE_ENV_FILE"`
- **Audit config changes:** `ConfigChange` + log to file

### Path Reference Variables

| Variable | Purpose |
|:---------|:--------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- Full event schemas, JSON input/output formats, exit codes, configuration schema (event > matcher group > hook handler nesting), all 24 hook events with input schemas and decision control options, common input fields (session_id, transcript_path, cwd, permission_mode, hook_event_name, agent_id, agent_type), PreToolUse tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), PreToolUse decision control (permissionDecision allow/deny/ask, updatedInput, additionalContext), PermissionRequest decision control (behavior allow/deny, updatedInput, updatedPermissions with addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories, permission_suggestions, destination session/localSettings/projectSettings/userSettings), PostToolUse decision control (decision block, reason, additionalContext, updatedMCPToolOutput), Stop/SubagentStop decision control (decision block, reason, stop_hook_active), exit code 2 behavior per event, JSON output fields (continue, stopReason, suppressOutput, systemMessage), HTTP response handling, MCP tool matching (mcp__server__tool naming, regex patterns), hook handler fields (command with async/shell, http with url/headers/allowedEnvVars, prompt/agent with prompt/$ARGUMENTS/model), hook locations, matcher patterns per event, hooks in skills and agents (frontmatter, once field, Stop-to-SubagentStop conversion), /hooks menu, disableAllHooks, CLAUDE_ENV_FILE persistence, async hooks (background execution, systemMessage delivery), prompt-based hooks (type prompt, ok/reason response, $ARGUMENTS, event support), agent-based hooks (type agent, multi-turn tool access, 50 turn limit), WorktreeCreate/WorktreeRemove for non-git VCS, security considerations, Windows PowerShell (shell powershell), debug mode (claude --debug, Ctrl+O), SessionEnd timeout (CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS)
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- Practical guide with examples for common hook patterns: desktop notifications (macOS/Linux/Windows), auto-format code after edits (Prettier with PostToolUse), block edits to protected files (PreToolUse exit 2), re-inject context after compaction (SessionStart compact matcher), audit configuration changes (ConfigChange logging), reload environment on directory change (CwdChanged with direnv and CLAUDE_ENV_FILE), watch files for changes (FileChanged with .envrc/.env matcher), auto-approve specific permission prompts (PermissionRequest with ExitPlanMode, setMode for acceptEdits), hook lifecycle overview, event table with matchers, hook input/output basics (stdin JSON, exit codes, structured JSON output), matcher filtering (regex on tool name/session source/notification type/config source), hook location scopes, prompt-based hooks (type prompt for judgment decisions, ok/reason response, Stop hook example), agent-based hooks (type agent for file inspection and test verification), HTTP hooks (type http with POST, headers with env var interpolation, allowedEnvVars, response body for decisions), limitations and troubleshooting (hook not firing, hook error in output, /hooks shows no hooks, Stop hook infinite loop with stop_hook_active, JSON validation failed due to shell profile echo, debug techniques with Ctrl+O and --debug)

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
