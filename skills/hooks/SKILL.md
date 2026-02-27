---
name: hooks
description: Complete documentation for Claude Code hooks — user-defined shell commands, prompt hooks, and agent hooks that execute automatically at lifecycle events (SessionStart, PreToolUse, PostToolUse, Stop, etc.). Load this when configuring hooks, writing hook scripts, understanding JSON input/output formats, exit codes, matchers, or automating workflows in Claude Code.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are shell commands, LLM prompts, or agents that run automatically at specific points in Claude Code's lifecycle. Configure them in settings files or skill/agent frontmatter.

### Hook Events

| Event                | When it fires                                              | Can block? |
|:---------------------|:-----------------------------------------------------------|:-----------|
| `SessionStart`       | Session begins, resumes, clears, or compacts               | No         |
| `UserPromptSubmit`   | Before Claude processes a submitted prompt                 | Yes        |
| `PreToolUse`         | Before a tool call executes                                | Yes        |
| `PermissionRequest`  | When a permission dialog appears                           | Yes        |
| `PostToolUse`        | After a tool call succeeds                                 | No         |
| `PostToolUseFailure` | After a tool call fails                                    | No         |
| `Notification`       | When Claude Code sends a notification                      | No         |
| `SubagentStart`      | When a subagent is spawned                                 | No         |
| `SubagentStop`       | When a subagent finishes                                   | Yes        |
| `Stop`               | When Claude finishes responding                            | Yes        |
| `TeammateIdle`       | When an agent team teammate is about to go idle            | Yes        |
| `TaskCompleted`      | When a task is being marked as completed                   | Yes        |
| `ConfigChange`       | When a configuration file changes during a session         | Yes        |
| `WorktreeCreate`     | When a worktree is being created                           | Yes        |
| `WorktreeRemove`     | When a worktree is being removed                           | No         |
| `PreCompact`         | Before context compaction                                  | No         |
| `SessionEnd`         | When a session terminates                                  | No         |

### Hook Handler Types

| Type        | Description                                                        | Timeout default |
|:------------|:-------------------------------------------------------------------|:----------------|
| `command`   | Runs a shell command; receives JSON on stdin                       | 600s            |
| `prompt`    | Single-turn LLM evaluation; returns `{"ok": true/false, "reason"}` | 30s             |
| `agent`     | Spawns a subagent with tool access for multi-turn verification     | 60s             |

### Hook Handler Fields

**Common fields (all types):**

| Field           | Required | Description                                                          |
|:----------------|:---------|:---------------------------------------------------------------------|
| `type`          | yes      | `"command"`, `"prompt"`, or `"agent"`                                |
| `timeout`       | no       | Seconds before canceling                                             |
| `statusMessage` | no       | Custom spinner message shown while hook runs                         |
| `once`          | no       | `true` = run only once per session (skills only)                     |

**Command hook extra fields:**

| Field     | Required | Description                                       |
|:----------|:---------|:--------------------------------------------------|
| `command` | yes      | Shell command to execute                          |
| `async`   | no       | `true` = run in background without blocking       |

**Prompt/agent hook extra fields:**

| Field    | Required | Description                                                |
|:---------|:---------|:-----------------------------------------------------------|
| `prompt` | yes      | Prompt text; use `$ARGUMENTS` for hook input JSON          |
| `model`  | no       | Model override (defaults to a fast model)                  |

### Matcher Patterns

| Event(s)                                                  | Matches on              | Example values                                              |
|:----------------------------------------------------------|:------------------------|:------------------------------------------------------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` | tool name  | `Bash`, `Edit\|Write`, `mcp__.*`                          |
| `SessionStart`                                            | session source          | `startup`, `resume`, `clear`, `compact`                     |
| `SessionEnd`                                              | end reason              | `clear`, `logout`, `prompt_input_exit`, `other`             |
| `Notification`                                            | notification type       | `permission_prompt`, `idle_prompt`, `auth_success`          |
| `SubagentStart`, `SubagentStop`                           | agent type              | `Bash`, `Explore`, `Plan`, custom agent names               |
| `PreCompact`                                              | compaction trigger      | `manual`, `auto`                                            |
| `ConfigChange`                                            | config source           | `user_settings`, `project_settings`, `skills`               |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove` | (no matcher) | always fires |

### Exit Codes

| Exit code | Meaning                                                                    |
|:----------|:---------------------------------------------------------------------------|
| `0`       | Success. Stdout parsed as JSON if present. `UserPromptSubmit`/`SessionStart` stdout added to Claude's context |
| `2`       | Blocking error. stderr fed to Claude as feedback. JSON output ignored      |
| Other     | Non-blocking error. stderr shown in verbose mode only. Execution continues |

### JSON Output Fields (exit 0)

| Field            | Description                                                         |
|:-----------------|:--------------------------------------------------------------------|
| `continue`       | `false` = stop Claude entirely                                      |
| `stopReason`     | Message shown to user when `continue` is `false`                    |
| `suppressOutput` | `true` = hide stdout from verbose mode                              |
| `systemMessage`  | Warning message shown to the user                                   |

### Decision Control by Event

| Event(s)                                                                      | Pattern              | Key fields                                                            |
|:------------------------------------------------------------------------------|:---------------------|:----------------------------------------------------------------------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason`                |
| `TeammateIdle`, `TaskCompleted`                                               | Exit code only       | Exit 2 blocks; stderr fed back as feedback                            |
| `PreToolUse`                                                                  | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`), `permissionDecisionReason` |
| `PermissionRequest`                                                           | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`)                                  |
| `WorktreeCreate`                                                              | stdout path          | Print absolute path to created worktree; non-zero exit fails creation |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PreCompact`                  | None                 | Side effects only; no decision control                                |

### Common Input Fields (all events)

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/project/root",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse"
}
```

### Hook Locations

| Location                                              | Scope                    | Shareable |
|:------------------------------------------------------|:-------------------------|:----------|
| `~/.claude/settings.json`                             | All your projects        | No        |
| `.claude/settings.json`                               | Single project           | Yes       |
| `.claude/settings.local.json`                         | Single project           | No        |
| Managed policy settings                               | Organization-wide        | Yes       |
| Plugin `hooks/hooks.json`                             | When plugin is enabled   | Yes       |
| Skill or agent frontmatter `hooks:` key               | While component is active | Yes      |

### Minimal Config Example

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }
        ]
      }
    ]
  }
}
```

### Hooks in Skill Frontmatter

```yaml
---
name: my-skill
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

Use `$CLAUDE_PROJECT_DIR` to reference project-relative scripts. Use `${CLAUDE_PLUGIN_ROOT}` for plugin-bundled scripts.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks Reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, exit codes, async hooks, MCP tool hooks, and all decision control options
- [Hooks Guide](references/claude-code-hooks-guide.md) — practical guide with common automation patterns, setup walkthrough, and troubleshooting

## Sources

- Hooks Reference: https://code.claude.com/docs/en/hooks.md
- Hooks Guide: https://code.claude.com/docs/en/hooks-guide.md
