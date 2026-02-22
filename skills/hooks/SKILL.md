---
name: hooks
description: Reference documentation for Claude Code hooks — automating workflows with shell commands, prompt-based hooks, and agent-based hooks that run at lifecycle events. Covers hook events, matchers, JSON input/output, exit codes, decision control, async hooks, MCP tool hooks, environment variables, and configuration in settings files, plugins, skills, and agents.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over behavior -- format code after edits, block dangerous commands, send notifications, inject context, and more.

### Hook Events

| Event                | When it fires                                         | Can block? | Matcher filters        |
|:---------------------|:------------------------------------------------------|:-----------|:-----------------------|
| `SessionStart`       | Session begins or resumes                             | No         | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit`   | User submits a prompt, before processing              | Yes        | (none)                 |
| `PreToolUse`         | Before a tool call executes                           | Yes        | tool name              |
| `PermissionRequest`  | Permission dialog appears                             | Yes        | tool name              |
| `PostToolUse`        | After a tool call succeeds                            | No         | tool name              |
| `PostToolUseFailure` | After a tool call fails                               | No         | tool name              |
| `Notification`       | Claude sends a notification                           | No         | notification type      |
| `SubagentStart`      | Subagent is spawned                                   | No         | agent type             |
| `SubagentStop`       | Subagent finishes                                     | Yes        | agent type             |
| `Stop`               | Claude finishes responding                            | Yes        | (none)                 |
| `TeammateIdle`       | Agent team teammate about to go idle                  | Yes        | (none)                 |
| `TaskCompleted`      | Task being marked as completed                        | Yes        | (none)                 |
| `ConfigChange`       | Configuration file changes during session             | Yes        | config source          |
| `WorktreeCreate`     | Worktree being created                                | Yes        | (none)                 |
| `WorktreeRemove`     | Worktree being removed                                | No         | (none)                 |
| `PreCompact`         | Before context compaction                             | No         | `manual`, `auto`       |
| `SessionEnd`         | Session terminates                                    | No         | exit reason            |

### Hook Types

| Type        | Field      | Description                                              | Default timeout |
|:------------|:-----------|:---------------------------------------------------------|:----------------|
| `command`   | `command`  | Shell command; receives JSON on stdin                    | 600s            |
| `prompt`    | `prompt`   | Single-turn LLM evaluation; returns `ok`/`reason` JSON  | 30s             |
| `agent`     | `prompt`   | Multi-turn subagent with tool access; returns `ok`/`reason` | 60s         |

### Hook Handler Fields

| Field           | Required | Applies to        | Description                                        |
|:----------------|:---------|:------------------|:---------------------------------------------------|
| `type`          | Yes      | All               | `"command"`, `"prompt"`, or `"agent"`              |
| `command`       | Yes      | command            | Shell command to execute                           |
| `prompt`        | Yes      | prompt, agent      | Prompt text (`$ARGUMENTS` = hook input JSON)       |
| `timeout`       | No       | All               | Seconds before canceling                           |
| `async`         | No       | command            | `true` = run in background without blocking        |
| `model`         | No       | prompt, agent      | Model override (defaults to a fast model)          |
| `statusMessage` | No       | All               | Custom spinner message while hook runs             |
| `once`          | No       | All (skills only)  | `true` = run once per session then remove          |

### Exit Codes

| Exit code | Meaning            | Effect                                                    |
|:----------|:-------------------|:----------------------------------------------------------|
| `0`       | Success            | Action proceeds; stdout parsed for JSON output            |
| `2`       | Block              | Action blocked; stderr fed back to Claude as error        |
| Other     | Non-blocking error | Action proceeds; stderr logged in verbose mode            |

### Decision Control Patterns

| Events                                                                    | Pattern              | Key fields                                          |
|:--------------------------------------------------------------------------|:---------------------|:----------------------------------------------------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason`     |
| `TeammateIdle`, `TaskCompleted`                                           | Exit code only       | Exit 2 blocks; stderr is feedback                   |
| `PreToolUse`                                                              | `hookSpecificOutput` | `permissionDecision`: `allow` / `deny` / `ask`     |
| `PermissionRequest`                                                       | `hookSpecificOutput` | `decision.behavior`: `allow` / `deny`              |
| `WorktreeCreate`                                                          | stdout path          | Print absolute path; non-zero exit fails creation   |

### Common Input Fields (stdin JSON)

| Field             | Description                            |
|:------------------|:---------------------------------------|
| `session_id`      | Current session identifier             |
| `transcript_path` | Path to conversation JSON              |
| `cwd`             | Working directory when hook was invoked|
| `permission_mode` | Current permission mode                |
| `hook_event_name` | Name of the event that fired           |

### Hook Locations

| Location                          | Scope                    | Shareable?                 |
|:----------------------------------|:-------------------------|:---------------------------|
| `~/.claude/settings.json`         | All your projects        | No                         |
| `.claude/settings.json`           | Single project           | Yes, commit to repo        |
| `.claude/settings.local.json`     | Single project           | No, gitignored             |
| Managed policy settings           | Organization-wide        | Yes, admin-controlled      |
| Plugin `hooks/hooks.json`         | When plugin is enabled   | Yes, bundled with plugin   |
| Skill/agent frontmatter           | While component is active| Yes, defined in component  |

### Environment Variables

| Variable              | Available in     | Description                                    |
|:----------------------|:-----------------|:-----------------------------------------------|
| `$CLAUDE_PROJECT_DIR` | All hooks        | Project root directory                         |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks  | Plugin root directory                          |
| `$CLAUDE_ENV_FILE`    | SessionStart only| File path to persist env vars for Bash commands|
| `$CLAUDE_CODE_REMOTE` | All hooks        | `"true"` in remote web environments            |

### Configuration Example

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

### Matcher Patterns

Matchers are regex strings. Use `"*"`, `""`, or omit entirely to match all. Tool events match on `tool_name`. MCP tools follow the pattern `mcp__<server>__<tool>`.

### Disabling Hooks

Set `"disableAllHooks": true` in settings or use the toggle in the `/hooks` menu. Use `/hooks` to interactively add, view, and delete hooks.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate Workflows with Hooks](references/claude-code-hooks-guide.md) -- guide with common use cases, step-by-step setup, notification/formatting/protection examples, prompt-based and agent-based hooks
- [Hooks Reference](references/claude-code-hooks-reference.md) -- full event schemas, JSON input/output formats, exit codes, decision control, async hooks, MCP tool hooks, security considerations

## Sources

- Automate Workflows with Hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks Reference: https://code.claude.com/docs/en/hooks.md
