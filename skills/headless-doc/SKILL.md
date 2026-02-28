---
name: headless-doc
description: Reference documentation for running Claude Code programmatically — the Agent SDK CLI (`claude -p`), structured output, streaming, auto-approving tools, session continuation, system prompt customization, and Claude Code on the web (cloud sessions, --remote flag, teleport, diff view, environment configuration, network access controls, and allowed domains). Load when discussing headless mode, print mode, CI/CD scripting, programmatic usage, cloud sessions, or remote execution.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI and using Claude Code on the web for cloud-based sessions.

## Quick Reference

### Agent SDK CLI (Print Mode)

Run Claude Code non-interactively with `-p` (or `--print`). All CLI flags work with `-p`.

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

### Output Formats

| Format | Flag | Description |
|:-------|:-----|:------------|
| Plain text | `--output-format text` | Default; plain text response |
| JSON | `--output-format json` | Structured JSON with `result`, `session_id`, metadata |
| Stream JSON | `--output-format stream-json` | Newline-delimited JSON events for real-time streaming |

For validated JSON output matching a specific schema, combine `--output-format json` with `--json-schema '<schema>'`. Result appears in `structured_output` field.

### Streaming Tokens

```bash
claude -p "prompt" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### Auto-Approve Tools

```bash
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"
```

Uses permission rule syntax. Trailing ` *` enables prefix matching (e.g., `Bash(git diff *)` allows any command starting with `git diff`). The space before `*` is important.

### Continue / Resume Conversations

| Pattern | Command |
|:--------|:--------|
| Continue most recent | `claude -p "follow-up" --continue` |
| Resume by session ID | `claude -p "follow-up" --resume "$session_id"` |
| Capture session ID | `session_id=$(claude -p "start" --output-format json \| jq -r '.session_id')` |

### System Prompt Customization (Print Mode)

| Flag | Behavior |
|:-----|:---------|
| `--append-system-prompt` | Add instructions while keeping defaults |
| `--system-prompt` | Fully replace default system prompt |
| `--system-prompt-file` | Replace with file contents (print mode only) |
| `--append-system-prompt-file` | Append file contents (print mode only) |

### Claude Code on the Web

Cloud-based Claude Code sessions at [claude.ai/code](https://claude.ai/code). Available to Pro, Max, Team, and Enterprise users (research preview).

#### Terminal-to-Web (`--remote`)

```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```

Creates a new cloud session. Monitor with `/tasks` or interact via claude.ai / mobile app.

Parallel tasks: each `--remote` call creates an independent session.

#### Web-to-Terminal (Teleport)

| Method | Command |
|:-------|:--------|
| Interactive picker | `/teleport` or `/tp` inside Claude Code |
| CLI flag | `claude --teleport` or `claude --teleport <session-id>` |
| From tasks | `/tasks` then press `t` |
| From web | Click "Open in CLI" |

Teleport requirements: clean git state, correct repository, branch pushed to remote, same account.

#### Environment Selection

Select default environment for `--remote`: `/remote-env`

#### Network Access Levels

| Level | Behavior |
|:------|:---------|
| Limited (default) | Access to allowlisted domains only |
| Full | Unrestricted internet |
| None | No internet (Anthropic API still accessible) |

#### Dependency Management

Use SessionStart hooks in `.claude/settings.json` to install packages. Check `CLAUDE_CODE_REMOTE` env var to skip local execution. Requires network access ("Limited" or "Full").

#### Session Sharing

| Account type | Visibility options |
|:-------------|:------------------|
| Enterprise / Teams | Private, Team (org-visible, repo access verified by default) |
| Max / Pro | Private, Public (any logged-in claude.ai user) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- Agent SDK CLI usage, structured output, streaming, auto-approving tools, conversation continuation, system prompt flags
- [Claude Code on the web](references/claude-code-on-the-web.md) -- cloud sessions, --remote flag, teleport, diff view, environment configuration, dependency management, network access, security, allowed domains

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
