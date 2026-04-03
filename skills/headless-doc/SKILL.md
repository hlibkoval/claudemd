---
name: headless-doc
description: Complete documentation for running Claude Code programmatically (Agent SDK CLI) and Claude Code on the web (cloud sessions). Covers the -p/--print flag, --bare mode, --output-format (text, json, stream-json), --json-schema for structured output, --allowedTools with permission rule syntax, --continue/--resume for conversation chaining, --append-system-prompt, streaming with stream-json and api_retry events, --remote for launching web sessions from terminal, --teleport for pulling web sessions to terminal, /web-setup, /remote-env, /tasks, /teleport (/tp), cloud environment configuration, setup scripts vs SessionStart hooks, network access levels (limited, full, none), default allowed domains, GitHub proxy and security proxy, auto-fix for pull requests, diff view, session sharing (private/team/public), archiving and deleting sessions, scheduled recurring tasks, environment variables in .env format, dependency management limitations, security and isolation, and pricing/rate limits. Load when discussing headless mode, -p flag, programmatic Claude Code, Agent SDK CLI, structured output, stream-json, bare mode, claude --remote, cloud sessions, web sessions, teleport, /web-setup, setup scripts, cloud environment, network access, allowed domains, auto-fix PR, diff view, session sharing, or any topic related to running Claude Code non-interactively or on the web.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`-p` flag / Agent SDK) and running Claude Code on the web (cloud sessions).

## Quick Reference

### CLI Programmatic Mode (`-p`)

| Flag | Description |
|:-----|:-----------|
| `-p` / `--print` | Run non-interactively, print response |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for scripts) |
| `--output-format text` | Plain text output (default) |
| `--output-format json` | Structured JSON with `result`, `session_id`, metadata |
| `--output-format stream-json` | Newline-delimited JSON for real-time streaming |
| `--json-schema '<schema>'` | Constrain output to a JSON Schema (use with `--output-format json`); result in `structured_output` field |
| `--allowedTools "Tool1,Tool2"` | Auto-approve specific tools without prompting |
| `--continue` | Continue the most recent conversation |
| `--resume <session_id>` | Continue a specific conversation by session ID |
| `--append-system-prompt` | Add instructions while keeping default behavior |
| `--system-prompt` | Fully replace the default system prompt |
| `--verbose` | Enable verbose output (useful with streaming) |
| `--include-partial-messages` | Stream tokens as they are generated |

### Bare Mode Context Flags

| To load | Flag |
|:--------|:-----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

Bare mode skips OAuth/keychain reads. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`.

### Streaming Event: `system/api_retry`

| Field | Type | Description |
|:------|:-----|:-----------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Identifies retry event |
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer / null | HTTP status code or null |
| `error` | string | Category: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |

### Common CLI Patterns

```bash
# Structured JSON output
claude -p "Summarize this project" --output-format json

# Structured output with schema
claude -p "Extract functions" --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}'

# Auto-approve tools
claude -p "Fix tests" --allowedTools "Bash,Read,Edit"

# Create a commit (prefix matching with space+asterisk)
claude -p "Create a commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"

# Continue conversation
claude -p "Follow up" --continue

# Resume specific session
session_id=$(claude -p "Start" --output-format json | jq -r '.session_id')
claude -p "Continue" --resume "$session_id"

# Stream text deltas
claude -p "Write a poem" --output-format stream-json --verbose \
  --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### Claude Code on the Web

| Feature | Description |
|:--------|:-----------|
| **Availability** | Pro, Max, Team, Enterprise (premium/Chat+Code seats) |
| **Setup (browser)** | Visit claude.ai/code, connect GitHub, install Claude GitHub App |
| **Setup (terminal)** | Run `/web-setup` inside Claude Code (uses `gh` CLI credentials) |
| **Platform** | GitHub only (including GitHub Enterprise Server for Team/Enterprise) |
| **Mobile** | Available on iOS and Android Claude apps |

### Web Session Lifecycle

1. Repository cloned to Anthropic-managed VM
2. Setup script runs (if configured)
3. Network access configured per environment settings
4. Claude executes task (write code, run tests, iterate)
5. Changes pushed to branch, ready for PR creation

### Terminal-to-Web and Web-to-Terminal

| Direction | Command | Description |
|:----------|:--------|:-----------|
| Terminal to web | `claude --remote "prompt"` | Creates a new web session for current repo |
| Web to terminal | `/teleport` or `/tp` | Interactive picker of web sessions |
| Web to terminal | `claude --teleport` | Interactive picker from command line |
| Web to terminal | `claude --teleport <session-id>` | Resume specific session |
| Check progress | `/tasks` | View background sessions (press `t` to teleport) |
| Choose environment | `/remote-env` | Select default cloud environment for `--remote` |

Session handoff is one-way: web to terminal only. `--remote` creates a new web session.

### Teleport Requirements

| Requirement | Details |
|:------------|:--------|
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be same repo, not a fork |
| Branch available | Web session branch must be pushed to remote |
| Same account | Must be authenticated to same Claude.ai account |

### Auto-fix Pull Requests

Requires Claude GitHub App. Claude watches PRs and automatically responds to CI failures and review comments.

| Scenario | Claude's action |
|:---------|:---------------|
| Clear fix | Makes change, pushes, explains in session |
| Ambiguous request | Asks you before acting |
| Duplicate/no-action | Notes in session, moves on |

Claude replies to review threads using your GitHub account (labeled as from Claude Code).

### Cloud Environment

**Default image includes:** Python 3.x, Node.js LTS, Ruby 3.1/3.2/3.3, PHP 8.4, Java (OpenJDK), Go, Rust, C++ (GCC/Clang), PostgreSQL 16, Redis 7.0

**Run `check-tools`** to see what is pre-installed.

### Setup Scripts vs SessionStart Hooks

| | Setup Scripts | SessionStart Hooks |
|:--|:-------------|:-------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code, new sessions only | After Claude Code, every session (including resumed) |
| Scope | Cloud only | Local and cloud |

### Network Access Levels

| Level | Behavior |
|:------|:---------|
| **Limited** (default) | Allowlisted domains only (package registries, GitHub, cloud platforms, etc.) |
| **Full** | Unrestricted internet access |
| **None** | No internet (Anthropic API still reachable) |

### Session Sharing

| Account type | Visibility options | Notes |
|:-------------|:-------------------|:------|
| Enterprise/Team | Private, Team | Team = visible to org members; repo access verified by default |
| Max/Pro | Private, Public | Public = visible to any claude.ai user; check for sensitive content |

### Session Management

- **Archive**: hover session in sidebar, click archive icon (hidden from default list, viewable via filter)
- **Delete**: filter archived sessions and click delete, or use session dropdown menu (permanent, cannot be undone)

### Security

- Isolated VMs per session
- GitHub operations via dedicated proxy with scoped credentials
- Git push restricted to current working branch
- HTTP/HTTPS security proxy for all outbound traffic
- Credentials never inside sandbox

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) -- CLI `-p` flag, bare mode, structured output, streaming, tool auto-approval, conversation chaining, system prompt customization
- [Claude Code on the Web](references/claude-code-on-the-web.md) -- Cloud sessions, setup, auto-fix PRs, teleport, remote sessions, cloud environment, setup scripts, network access, allowed domains, security, session sharing

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
