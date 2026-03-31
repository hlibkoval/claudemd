---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- lifecycle events, configuration schema, JSON input/output formats, exit codes, matchers, decision control, async hooks, HTTP hooks, prompt hooks, agent hooks, and MCP tool hooks. Covers all hook events (SessionStart with startup/resume/clear/compact matchers, UserPromptSubmit prompt validation, PreToolUse with allow/deny/ask permissionDecision and updatedInput, PermissionRequest with behavior allow/deny and updatedPermissions and permission update entries addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories with destination session/localSettings/projectSettings/userSettings, PostToolUse with decision block and updatedMCPToolOutput, PostToolUseFailure with additionalContext, Notification with permission_prompt/idle_prompt/auth_success/elicitation_dialog matchers, SubagentStart with agent type matchers, SubagentStop with last_assistant_message, TaskCreated with task_id/task_subject/task_description/teammate_name/team_name, TaskCompleted with completion criteria enforcement, Stop with stop_hook_active and last_assistant_message, StopFailure with rate_limit/authentication_failed/billing_error/invalid_request/server_error/max_output_tokens/unknown error types, TeammateIdle with teammate_name/team_name, InstructionsLoaded with file_path/memory_type/load_reason/globs/trigger_file_path/parent_file_path, ConfigChange with user_settings/project_settings/local_settings/policy_settings/skills matchers, CwdChanged with old_cwd/new_cwd and CLAUDE_ENV_FILE and watchPaths, FileChanged with file_path/event and matcher-based filename watching, WorktreeCreate returning worktree path for non-git VCS, WorktreeRemove cleanup, PreCompact/PostCompact with manual/auto triggers and compact_summary, Elicitation with form/URL modes and accept/decline/cancel actions, ElicitationResult response override, SessionEnd with clear/resume/logout/prompt_input_exit/bypass_permissions_disabled/other reasons), configuration locations (user ~/.claude/settings.json, project .claude/settings.json, local .claude/settings.local.json, managed policy, plugin hooks/hooks.json, skill/agent frontmatter), three-level nesting (event > matcher group > hook handler), hook handler types (command with shell/async/command fields, HTTP with url/headers/allowedEnvVars and env var interpolation, prompt with $ARGUMENTS placeholder and ok/reason response, agent with multi-turn tool access and 50-turn limit), common fields (type, if with permission rule syntax for tool argument filtering, timeout defaults 600/30/60, statusMessage, once for skills), matcher patterns (regex filtering by tool name/session source/notification type/agent type/config source/error type/load reason/MCP server name/filename, pipe alternation, MCP tool naming mcp__server__tool), hook input (common fields session_id/transcript_path/cwd/permission_mode/hook_event_name, agent fields agent_id/agent_type), exit code semantics (0 success with JSON parsing, 2 blocking error with stderr feedback, other non-blocking), JSON output (continue/stopReason/suppressOutput/systemMessage, decision/reason for blocking events, hookSpecificOutput with hookEventName), decision control patterns (top-level decision block for UserPromptSubmit/PostToolUse/Stop/SubagentStop/ConfigChange, hookSpecificOutput for PreToolUse/PermissionRequest/Elicitation/ElicitationResult, exit code for TeammateIdle/TaskCreated/TaskCompleted, path return for WorktreeCreate), CLAUDE_ENV_FILE for persisting environment variables (available in SessionStart/CwdChanged/FileChanged), reference scripts with $CLAUDE_PROJECT_DIR/${CLAUDE_PLUGIN_ROOT}/${CLAUDE_PLUGIN_DATA}, /hooks menu (read-only browser showing all hooks by event with source labels User/Project/Local/Plugin/Session/Built-in), disableAllHooks setting (respects managed settings hierarchy), hooks in skills and agents (frontmatter YAML format, scoped to component lifecycle, Stop converted to SubagentStop for agents, once field), async hooks (background execution with async:true, systemMessage/additionalContext delivery on next turn, command-only, no decision control), HTTP response handling (2xx empty/text/JSON, non-2xx non-blocking, connection failure non-blocking, blocking requires 2xx with JSON decision), tool input schemas (Bash command/description/timeout/run_in_background, Write file_path/content, Edit file_path/old_string/new_string/replace_all, Read file_path/offset/limit, Glob pattern/path, Grep pattern/path/glob/output_mode, WebFetch url/prompt, WebSearch query/allowed_domains/blocked_domains, Agent prompt/description/subagent_type/model, AskUserQuestion questions/answers), Windows PowerShell support (shell:powershell, auto-detects pwsh.exe/powershell.exe), debugging (claude --debug, CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose, Ctrl+O verbose mode), security considerations (full user permissions, input validation, shell variable quoting, path traversal checks, absolute paths), SessionEnd timeout (1.5s default, CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS override), allowManagedHooksOnly enterprise setting, common troubleshooting (hook not firing, hook error, /hooks shows nothing, stop hook infinite loop, JSON validation failed from shell profile echo, debug techniques). Load when discussing Claude Code hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, SessionStart, Stop, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, TeammateIdle, StopFailure, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, InstructionsLoaded, UserPromptSubmit, SessionEnd, hook configuration, hook matchers, hook handlers, exit codes, JSON hook output, decision control, permissionDecision, async hooks, HTTP hooks, prompt hooks, agent hooks, CLAUDE_ENV_FILE, /hooks menu, disableAllHooks, hook security, MCP tool hooks, hook troubleshooting, hooks in skills, hooks in agents, hooks in plugins, hook frontmatter, or any hooks-related topic for Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- user-defined shell commands, HTTP endpoints, LLM prompts, and agent verifiers that execute automatically at specific points in Claude Code's lifecycle.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? | Matcher filters |
|:------|:--------------|:-----------|:----------------|
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | Prompt submitted, before processing | Yes | No matcher support |
| `PreToolUse` | Before tool call executes | Yes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `PermissionRequest` | Permission dialog about to appear | Yes | Tool name |
| `PostToolUse` | After tool call succeeds | No (feedback only) | Tool name |
| `PostToolUseFailure` | After tool call fails | No (feedback only) | Tool name |
| `Notification` | Claude sends a notification | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type (`Bash`, `Explore`, `Plan`, custom) |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `TaskCreated` | Task being created | Yes | No matcher support |
| `TaskCompleted` | Task being marked completed | Yes | No matcher support |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `StopFailure` | Turn ends due to API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Teammate about to go idle | Yes | No matcher support |
| `InstructionsLoaded` | CLAUDE.md or rule file loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | Config file changes during session | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | No | No matcher support |
| `FileChanged` | Watched file changes on disk | No | Filename basename (`.envrc`, `.env`) |
| `WorktreeCreate` | Worktree being created | Yes (failure = fail) | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before compaction | No | `manual`, `auto` |
| `PostCompact` | After compaction completes | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | After user responds to elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Configuration Structure

Hooks use three levels of nesting in settings JSON:

```
hooks.<EventName>[].matcher   -- regex to filter when the group fires
hooks.<EventName>[].hooks[]   -- array of hook handlers to run
```

### Hook Handler Types

| Type | Field | Description | Default timeout |
|:-----|:------|:------------|:----------------|
| `command` | `command` | Shell command, receives JSON on stdin | 600s |
| `http` | `url` | POST endpoint, receives JSON as body | 600s |
| `prompt` | `prompt` | Single-turn LLM evaluation, returns `{ok, reason}` | 30s |
| `agent` | `prompt` | Multi-turn subagent with tool access (up to 50 turns), returns `{ok, reason}` | 60s |

### Common Handler Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax filter (e.g., `"Bash(git *)"`, `"Edit(*.ts)"`). Tool events only |
| `timeout` | No | Seconds before canceling |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs only once per session (skills only) |

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled) |
| Skill/agent YAML frontmatter | While component active | Yes |

### Exit Code Semantics

| Exit code | Meaning | Behavior |
|:----------|:--------|:---------|
| `0` | Success | Action proceeds; stdout parsed for JSON |
| `2` | Blocking error | Action blocked; stderr fed to Claude as feedback |
| Other | Non-blocking error | Action proceeds; stderr shown in verbose mode |

### JSON Output Fields (exit 0)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely |
| `stopReason` | -- | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from verbose mode |
| `systemMessage` | -- | Warning message shown to user |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks with stderr; JSON `continue: false` stops teammate |
| `WorktreeCreate` | Path return | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (`accept`/`decline`/`cancel`), `content` |

### Common Input Fields

Every hook event receives these fields as JSON (stdin for commands, POST body for HTTP):

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | Current permission mode (not all events) |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (subagent context only) |
| `agent_type` | Agent name (subagent or --agent context only) |

### CLAUDE_ENV_FILE

Available in `SessionStart`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to persist environment variables for subsequent Bash commands:

```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

### Script Path Variables

| Variable | Description |
|:---------|:------------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

### MCP Tool Matching

MCP tools follow `mcp__<server>__<tool>` naming. Match with regex:
- `mcp__memory__.*` -- all tools from the memory server
- `mcp__.*__write.*` -- any write tool from any server

### The `if` Field

Filters individual handlers by tool name and arguments using permission rule syntax. Only on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`).

Examples: `"Bash(git *)"` matches only git commands; `"Edit(*.ts)"` matches only TypeScript edits.

### Async Hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately. Results delivered via `systemMessage`/`additionalContext` on the next conversation turn. Cannot block or return decisions.

### Prompt/Agent Hook Response

Both prompt and agent hooks return the same JSON:

```json
{ "ok": true }
```
```json
{ "ok": false, "reason": "Explanation shown to Claude" }
```

### Hook Type Support by Event

**All four types** (command, http, prompt, agent): PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, UserPromptSubmit, Stop, SubagentStop, TaskCreated, TaskCompleted.

**Command and HTTP only**: ConfigChange, CwdChanged, Elicitation, ElicitationResult, FileChanged, InstructionsLoaded, Notification, PostCompact, PreCompact, SessionEnd, StopFailure, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove.

**Command only**: SessionStart.

### Hooks in Skills and Agents (Frontmatter)

```yaml
---
name: my-skill
description: Skill with hooks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
---
```

Scoped to component lifetime. For agents, `Stop` hooks are auto-converted to `SubagentStop`.

### PermissionRequest updatedPermissions Entries

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules`, `behavior`, `destination` | Adds permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules |
| `setMode` | `mode`, `destination` | Changes permission mode |
| `addDirectories` | `directories`, `destination` | Adds working directories |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

Destinations: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Disabling Hooks

Set `"disableAllHooks": true` in settings to disable all hooks. Respects managed settings hierarchy (user/project/local cannot disable managed hooks).

### Debugging

- `/hooks` -- read-only browser for all configured hooks
- `Ctrl+O` -- toggle verbose mode to see hook output
- `claude --debug` -- full execution details
- `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` -- granular matcher details

### Key Limitations

- Command hooks communicate through stdout/stderr/exit codes only
- `PostToolUse` hooks cannot undo actions (tool already ran)
- `PermissionRequest` hooks do not fire in non-interactive mode (`-p`); use `PreToolUse` instead
- `Stop` hooks fire whenever Claude finishes responding, not only at task completion; do not fire on user interrupts
- SessionEnd hooks default to 1.5s timeout (override with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`)
- HTTP hooks cannot block via status codes alone; must return 2xx with JSON decision fields

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- Full event schemas, configuration schema (three-level nesting with event/matcher/handler), hook locations (user/project/local/managed/plugin/skill-agent frontmatter), matcher patterns (regex by tool name/session source/notification type/agent type/config source/error type/load reason/MCP server/filename), hook handler types (command with shell/async fields, HTTP with url/headers/allowedEnvVars and env var interpolation, prompt with $ARGUMENTS and ok/reason response, agent with multi-turn tool access), common handler fields (type/if/timeout/statusMessage/once), tool input schemas (Bash/Write/Edit/Read/Glob/Grep/WebFetch/WebSearch/Agent/AskUserQuestion), exit code semantics, JSON output fields (continue/stopReason/suppressOutput/systemMessage), decision control per event (top-level decision, hookSpecificOutput for PreToolUse/PermissionRequest, path return for WorktreeCreate, action/content for Elicitation/ElicitationResult), all hook event sections with input schemas and decision control (SessionStart with CLAUDE_ENV_FILE, InstructionsLoaded with load_reason/memory_type, UserPromptSubmit with additionalContext, PreToolUse with permissionDecision allow/deny/ask and updatedInput, PermissionRequest with behavior/updatedInput/updatedPermissions/permission update entries, PostToolUse with updatedMCPToolOutput, PostToolUseFailure, Notification, SubagentStart/SubagentStop, TaskCreated/TaskCompleted, Stop with stop_hook_active, StopFailure with error types, TeammateIdle, ConfigChange with source/blocking, CwdChanged with watchPaths/CLAUDE_ENV_FILE, FileChanged with watchPaths/CLAUDE_ENV_FILE, WorktreeCreate/WorktreeRemove for non-git VCS, PreCompact/PostCompact with trigger/custom_instructions/compact_summary, Elicitation form/URL modes, ElicitationResult override, SessionEnd with reason/timeout), prompt hooks (Haiku default, $ARGUMENTS placeholder, ok/reason response), agent hooks (50-turn limit, tool access), async hooks (background execution, systemMessage delivery, command-only), HTTP response handling (2xx/non-2xx/connection failure), reference script paths ($CLAUDE_PROJECT_DIR/${CLAUDE_PLUGIN_ROOT}/${CLAUDE_PLUGIN_DATA}), hooks in skills and agents (frontmatter YAML, scoped lifecycle, Stop to SubagentStop conversion, once field), /hooks menu (read-only browser with source labels), disableAllHooks setting, MCP tool matching (mcp__server__tool pattern), if field with permission rule syntax, Windows PowerShell (shell:powershell), security considerations (full user permissions, input validation, quoting, path traversal), debugging (claude --debug, verbose mode, CLAUDE_CODE_DEBUG_LOG_LEVEL), allowManagedHooksOnly enterprise setting

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- Quickstart guide with step-by-step setup, common automation patterns (desktop notifications on macOS/Linux/Windows, auto-format with Prettier after edits, block edits to protected files with script, re-inject context after compaction, audit configuration changes, reload environment with direnv on CwdChanged/FileChanged, auto-approve specific permission prompts with PermissionRequest hooks and updatedPermissions/setMode), hook input/output walkthrough (reading JSON from stdin, exit code semantics, structured JSON output with decision patterns), filter hooks with matchers (regex patterns, per-event matcher fields, MCP tool matching mcp__server__tool), if field for tool argument filtering with permission rule syntax, configure hook location (scope table), prompt-based hooks (type:prompt, ok/reason response, Haiku default, multi-criteria Stop example), agent-based hooks (type:agent, multi-turn with tool access, test verification example), HTTP hooks (type:http, POST with headers, env var interpolation with allowedEnvVars, response handling), limitations and troubleshooting (hook not firing, hook error, /hooks shows nothing, stop hook infinite loop with stop_hook_active check, JSON validation failed from shell profile echo, debug techniques with Ctrl+O and claude --debug)

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
