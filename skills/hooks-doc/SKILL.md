---
name: hooks-doc
description: Complete documentation for Claude Code hooks — lifecycle events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, prompt, agent), configuration schema (matchers, handler fields, timeout, async, once), JSON input/output formats, exit code semantics (0 allow, 2 block), decision control patterns (top-level decision, hookSpecificOutput, permissionDecision, PermissionRequest decision), structured JSON output fields (continue, stopReason, suppressOutput, systemMessage), matcher patterns per event, hook locations (user/project/local/managed/plugin/skill frontmatter), environment variables ($CLAUDE_PROJECT_DIR, ${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}, $CLAUDE_ENV_FILE), PreToolUse tool input schemas (Bash, Write, Edit, Read, Glob, Grep, WebFetch, WebSearch, Agent), MCP tool matching (mcp__server__tool pattern), PermissionRequest permission updates (addRules, replaceRules, removeRules, setMode, addDirectories, removeDirectories), async hooks (background execution, limitations), prompt-based hooks (LLM evaluation, ok/reason response), agent-based hooks (multi-turn subagent verification), HTTP hooks (POST endpoint, headers, allowedEnvVars, response handling), hooks in skills and agents (frontmatter scoping, once field), the /hooks menu, disableAllHooks, security considerations, debugging (--debug, Ctrl+O verbose mode), common patterns (notifications, auto-format, file protection, context re-injection, config auditing, auto-approve). Load when discussing Claude Code hooks, hook events, PreToolUse, PostToolUse, PermissionRequest, Stop hooks, SessionStart, SessionEnd, hook matchers, hook configuration, hook JSON input/output, exit codes for hooks, blocking tool calls, auto-approving permissions, prompt hooks, agent hooks, HTTP hooks, async hooks, hook scripts, CLAUDE_ENV_FILE, WorktreeCreate, WorktreeRemove, ConfigChange, TeammateIdle, TaskCompleted, InstructionsLoaded, Elicitation, ElicitationResult, PreCompact, PostCompact, SubagentStart, SubagentStop, Notification hooks, MCP tool hooks, hook security, hook debugging, /hooks menu, disableAllHooks, or automating Claude Code workflows with hooks.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, LLM prompts, or subagents that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over behavior — formatting files after edits, blocking commands, sending notifications, injecting context, and more.

### Hook Events

| Event | When it fires | Can block? | Matcher filters |
|:------|:--------------|:-----------|:----------------|
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | No matcher support |
| `UserPromptSubmit` | User submits prompt, before processing | Yes | No matcher support |
| `PreToolUse` | Before tool call executes | Yes | Tool name (`Bash`, `Edit\|Write`, `mcp__.*`) |
| `PermissionRequest` | Permission dialog appears | Yes | Tool name |
| `PostToolUse` | After tool call succeeds | No | Tool name |
| `PostToolUseFailure` | After tool call fails | No | Tool name |
| `Notification` | Claude sends notification | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | Agent type (`Bash`, `Explore`, `Plan`, custom) |
| `SubagentStop` | Subagent finishes | Yes | Agent type |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `TeammateIdle` | Teammate about to go idle | Yes | No matcher support |
| `TaskCompleted` | Task marked as completed | Yes | No matcher support |
| `ConfigChange` | Config file changes | Yes (not policy) | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before compaction | No | `manual`, `auto` |
| `PostCompact` | After compaction completes | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes | MCP server name |
| `ElicitationResult` | After user responds to elicitation | Yes | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:------------|:----------------|
| `command` | Run a shell command (stdin JSON, exit code + stdout/stderr) | 600s |
| `http` | POST event data to a URL, response body for results | 600s |
| `prompt` | Single-turn LLM evaluation, returns `{ok, reason}` | 30s |
| `agent` | Multi-turn subagent with tool access, returns `{ok, reason}` | 60s |

Events supporting all four types: `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `TaskCompleted`, `UserPromptSubmit`. All other events support `command` only.

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All your projects | No |
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
            "timeout": 30,
            "async": false
          }
        ]
      }
    ]
  }
}
```

Three nesting levels: event name, matcher group (regex filter), hook handlers (commands/endpoints/prompts to run).

### Exit Codes (command hooks)

| Exit code | Meaning | Behavior |
|:----------|:--------|:---------|
| `0` | Success | Action proceeds; stdout parsed for JSON output |
| `2` | Blocking error | Action blocked; stderr fed to Claude as feedback |
| Other | Non-blocking error | Action proceeds; stderr shown in verbose mode only |

For `SessionStart` and `UserPromptSubmit`, stdout on exit 0 is added as context for Claude. JSON output is only processed on exit 0.

### JSON Output Fields (stdout on exit 0)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | `false` stops Claude entirely |
| `stopReason` | none | Message shown to user when `continue` is false |
| `suppressOutput` | `false` | `true` hides stdout from verbose mode |
| `systemMessage` | none | Warning message shown to user |

### Decision Control Patterns

| Events | Pattern | Key fields |
|:-------|:--------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code or `continue: false` | Exit 2 blocks with stderr; JSON `continue: false` stops entirely |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions` |
| WorktreeCreate | stdout path | Print absolute path to created worktree |
| Elicitation, ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| WorktreeRemove, Notification, SessionEnd, PreCompact, PostCompact, InstructionsLoaded | None | No decision control (side effects only) |

### Common Input Fields (stdin JSON)

All events receive: `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`. In subagent contexts: also `agent_id`, `agent_type`.

### Handler Fields

**Command hooks:** `command` (required), `async` (optional, background execution)

**HTTP hooks:** `url` (required), `headers` (optional, supports `$VAR` interpolation), `allowedEnvVars` (list of vars to resolve in headers)

**Prompt/agent hooks:** `prompt` (required, use `$ARGUMENTS` for input data), `model` (optional, defaults to fast model)

**Common fields (all types):** `type`, `timeout`, `statusMessage` (custom spinner text), `once` (run only once per session, skills only)

### Environment Variables

| Variable | Available in | Description |
|:---------|:-------------|:------------|
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hooks | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | SessionStart only | File path for persisting env vars to subsequent Bash commands |
| `$CLAUDE_CODE_REMOTE` | All hooks | Set to `"true"` in remote web environments |

### PreToolUse Tool Input Schemas

| Tool | Key input fields |
|:-----|:-----------------|
| `Bash` | `command`, `description`, `timeout`, `run_in_background` |
| `Write` | `file_path`, `content` |
| `Edit` | `file_path`, `old_string`, `new_string`, `replace_all` |
| `Read` | `file_path`, `offset`, `limit` |
| `Glob` | `pattern`, `path` |
| `Grep` | `pattern`, `path`, `glob`, `output_mode`, `-i`, `multiline` |
| `WebFetch` | `url`, `prompt` |
| `WebSearch` | `query`, `allowed_domains`, `blocked_domains` |
| `Agent` | `prompt`, `description`, `subagent_type`, `model` |

MCP tools follow naming pattern `mcp__<server>__<tool>`. Match with regex: `mcp__memory__.*`, `mcp__.*__write.*`.

### PermissionRequest: Permission Update Entries

The `updatedPermissions` output field supports these entry types:

| Type | Fields | Effect |
|:-----|:-------|:-------|
| `addRules` | `rules [{toolName, ruleContent?}]`, `behavior`, `destination` | Add permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replace all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Remove matching rules |
| `setMode` | `mode`, `destination` | Change permission mode (default/acceptEdits/dontAsk/bypassPermissions/plan) |
| `addDirectories` | `directories`, `destination` | Add working directories |
| `removeDirectories` | `directories`, `destination` | Remove working directories |

Destinations: `session` (in-memory), `localSettings`, `projectSettings`, `userSettings`.

### Async Hooks

Set `"async": true` on command hooks to run in the background. Claude continues working immediately. Results delivered on next conversation turn via `systemMessage` or `additionalContext`. Only `type: "command"` supports async. Async hooks cannot block or return decisions.

### Prompt/Agent Hook Response

Both prompt and agent hooks return the same schema:

```json
{ "ok": true }
```

or

```json
{ "ok": false, "reason": "Explanation shown to Claude" }
```

### Useful Settings

- `"disableAllHooks": true` in settings to disable all hooks (managed settings hierarchy applies)
- `/hooks` command to browse all configured hooks (read-only)
- `claude --debug` for hook execution details
- `Ctrl+O` to toggle verbose mode for hook output in transcript

### Common Patterns

**Desktop notifications:** `Notification` event with `osascript` (macOS) / `notify-send` (Linux)

**Auto-format after edits:** `PostToolUse` with `Edit|Write` matcher, run formatter on `tool_input.file_path`

**Block protected files:** `PreToolUse` with `Edit|Write` matcher, check file path against patterns, exit 2 to block

**Re-inject context after compaction:** `SessionStart` with `compact` matcher, echo reminders to stdout

**Auto-approve permissions:** `PermissionRequest` with specific matcher, return `decision.behavior: "allow"`

**Audit config changes:** `ConfigChange` event, log `source` and `file_path`

**Prevent infinite Stop loops:** Check `stop_hook_active` field in Stop/SubagentStop input, exit 0 if true

### Security

- Command hooks run with your full user permissions
- Validate and sanitize inputs; always quote shell variables
- Use absolute paths or `$CLAUDE_PROJECT_DIR` for scripts
- Block path traversal (check for `..` in file paths)
- `SessionEnd` hooks have 1.5s default timeout (override with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`)

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas and JSON input/output formats for all 21 hook events, configuration schema (matchers, handler fields for command/http/prompt/agent types), exit code semantics and decision control patterns per event, PreToolUse tool input schemas (Bash/Write/Edit/Read/Glob/Grep/WebFetch/WebSearch/Agent), MCP tool matching, PermissionRequest permission update entries (addRules/replaceRules/removeRules/setMode/addDirectories/removeDirectories with destinations), PostToolUse updatedMCPToolOutput, async hooks configuration and behavior, prompt-based hooks (LLM evaluation, ok/reason response schema), agent-based hooks (multi-turn subagent verification), HTTP hooks (POST endpoint, headers with env var interpolation, allowedEnvVars, response handling), hooks in skills and agents (frontmatter scoping, once field), /hooks menu sources, disableAllHooks, security considerations, debugging with --debug and verbose mode
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- getting started walkthrough (first hook setup with /hooks verification), common automation patterns (desktop notifications cross-platform, auto-format with Prettier, block edits to protected files with script, re-inject context after compaction, audit configuration changes, auto-approve specific permission prompts with ExitPlanMode example and setMode), how hooks work (event lifecycle, input/output through stdin/stdout/stderr/exit codes, structured JSON output, filter with matchers), hook location scoping (user/project/local/managed/plugin/skill), prompt-based hooks (type: prompt, LLM yes/no decisions, Stop hook example), agent-based hooks (type: agent, multi-turn verification with tool access), HTTP hooks (type: http, POST to endpoint, header env var interpolation), limitations and troubleshooting (hook not firing, hook errors, /hooks shows nothing, Stop hook loops, JSON validation with shell profile interference, debug techniques)

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
