---
name: headless-doc
description: Complete documentation for running Claude Code programmatically (headless mode / Agent SDK CLI) and Claude Code on the web (cloud sessions). Covers the -p/--print flag for non-interactive CLI usage, --bare mode (skips hooks/skills/plugins/MCP/CLAUDE.md for fast CI scripts), output formats (text/json/stream-json with --output-format, --json-schema for structured output, stream-json event types including system/api_retry), --allowedTools with permission rule syntax (prefix matching with trailing space-star), --append-system-prompt and --system-prompt flags, --continue and --resume for multi-turn conversations, session ID capture from JSON output. Claude Code on the web -- cloud sessions via claude.ai/code (research preview for Pro/Max/Team/Enterprise), GitHub integration (connect GitHub account, install Claude GitHub App), diff view for reviewing changes, auto-fix for pull requests (watches CI failures and review comments, pushes fixes automatically, replies using your GitHub account labeled as Claude Code), --remote flag (start web sessions from terminal, plan mode then remote execution, parallel remote tasks), teleport (--teleport and /teleport and /tp to pull web sessions to terminal, requirements: clean git state, correct repo, branch available, same account), /tasks for monitoring, /web-setup for GitHub connection via gh CLI, /remote-env for selecting default environment, session sharing (Enterprise/Teams: Private/Team visibility with repo access verification; Max/Pro: Private/Public visibility), session management (archiving, deleting), cloud environment (universal image with Python/Node.js/Ruby/PHP/Java/Go/Rust/C++ and PostgreSQL 16/Redis 7.0, check-tools command), setup scripts (bash scripts running as root on Ubuntu 24.04 before Claude Code launches, exit non-zero blocks session, || true for non-critical commands), setup scripts vs SessionStart hooks (scripts: cloud environment UI, new sessions only, cloud only; hooks: .claude/settings.json, every session, both local and cloud), dependency management (setup scripts or SessionStart hooks, CLAUDE_CODE_REMOTE env var check, CLAUDE_ENV_FILE for persisting env vars), network access levels (limited default with allowlisted domains, no internet, full internet), GitHub proxy (scoped credentials, push restricted to current branch), security proxy (HTTP/HTTPS for all outbound traffic), default allowed domains (Anthropic services, version control, container registries, cloud platforms, package managers for JS/Python/Ruby/Rust/Go/JVM/PHP/.NET/Dart/Elixir/Perl/iOS/Haskell/Swift, Linux distributions, dev tools, monitoring, CDN, schema registries, MCP), security and isolation (isolated VMs, credential protection via proxy), schedule recurring tasks on the web, limitations (GitHub only, self-hosted GitHub Enterprise Server for Teams/Enterprise). Load when discussing Claude Code headless mode, claude -p, --print flag, Agent SDK CLI, programmatic Claude Code, non-interactive mode, --bare mode, CI/CD scripts with Claude Code, --output-format, stream-json, --json-schema, structured output, --allowedTools, auto-approve tools, --continue/--resume conversations, Claude Code on the web, cloud sessions, claude.ai/code, --remote flag, remote tasks, teleport sessions, /teleport, /tp, /tasks, /web-setup, /remote-env, auto-fix pull requests, diff view, cloud environment, setup scripts, SessionStart hooks vs setup scripts, network access levels, allowed domains, GitHub proxy, security proxy, session sharing, CLAUDE_CODE_REMOTE, CLAUDE_ENV_FILE, check-tools, or any topic about running Claude Code non-interactively or in cloud sessions.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically (the Agent SDK CLI, formerly called "headless mode") and running Claude Code on the web as cloud sessions.

## Quick Reference

### Programmatic CLI Usage (Agent SDK CLI)

| Flag | Purpose |
|:-----|:--------|
| `-p` / `--print` | Run non-interactively, print response and exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for CI) |
| `--output-format text\|json\|stream-json` | Control response format |
| `--json-schema '<schema>'` | Return structured output conforming to a JSON Schema (use with `--output-format json`) |
| `--allowedTools "Tool1,Tool2"` | Auto-approve specific tools without prompting |
| `--append-system-prompt "..."` | Add instructions while keeping default behavior |
| `--system-prompt "..."` | Fully replace the default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific conversation by session ID |
| `--verbose` | Include verbose event data (useful with stream-json) |
| `--include-partial-messages` | Stream tokens as generated (with stream-json) |

### Bare Mode Context Loading

In bare mode, Claude has access to Bash, file read, and file edit tools. Pass any additional context explicitly:

| To load | Use |
|:--------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

Bare mode skips OAuth and keychain reads. Authentication must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in `--settings`. Bedrock, Vertex, and Foundry use their usual provider credentials.

### Output Formats

| Format | Description |
|:-------|:------------|
| `text` (default) | Plain text response |
| `json` | Structured JSON with `result`, `session_id`, metadata; `structured_output` field when `--json-schema` is used |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

**Capture session ID for multi-turn:**

```
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Stream Event: api_retry

When streaming, retryable API errors emit a `system/api_retry` event:

| Field | Type | Description |
|:------|:-----|:------------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Identifies retry event |
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | Category: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |

### --allowedTools Permission Syntax

Uses permission rule syntax. Trailing ` *` (space then asterisk) enables prefix matching:

| Pattern | Allows |
|:--------|:-------|
| `Bash` | All Bash commands |
| `Bash(git diff *)` | Commands starting with `git diff ` |
| `Read,Edit` | File read and edit tools |

The space before `*` matters: `Bash(git diff*)` would also match `git diff-index`.

User-invoked skills and built-in commands are not available in `-p` mode. Describe the task directly.

### Common Patterns

**Create a commit:**

```
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

**Security review of a PR diff:**

```
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

**Filter streaming text with jq:**

```
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

---

### Claude Code on the Web

| Feature | Detail |
|:--------|:-------|
| **URL** | [claude.ai/code](https://claude.ai/code) |
| **Availability** | Research preview: Pro, Max, Team, Enterprise users |
| **Platform** | GitHub repositories only (includes self-hosted GitHub Enterprise Server for Teams/Enterprise) |
| **Mobile** | iOS and Android Claude apps for kicking off tasks and monitoring |

### Getting Started (Web)

| Method | Steps |
|:-------|:------|
| **Browser** | Visit claude.ai/code, connect GitHub, install Claude GitHub App, select environment, submit task |
| **Terminal** | Run `/web-setup` inside Claude Code (syncs `gh auth token`, creates default environment, opens claude.ai/code) |

### Moving Tasks Between Web and Terminal

| Direction | How |
|:----------|:----|
| **Terminal to web** | `claude --remote "task description"` (creates new web session) |
| **Web to terminal** | `/teleport` or `/tp` (interactive picker), `claude --teleport` or `claude --teleport <session-id>`, press `t` in `/tasks`, or "Open in CLI" from web UI |
| **Monitor** | `/tasks` in Claude Code, or claude.ai, or Claude mobile app |

Session handoff is one-way: web sessions can be pulled to terminal, but terminal sessions cannot be pushed to web. `--remote` always creates a new session.

### Teleport Requirements

| Requirement | Detail |
|:------------|:-------|
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be same repo, not a fork |
| Branch available | Web session branch must be pushed to remote |
| Same account | Must be authenticated to the same Claude.ai account |

### Auto-Fix Pull Requests

Watches a PR and responds to CI failures and review comments. Requires the Claude GitHub App installed on the repository.

| Trigger | Enable auto-fix via |
|:--------|:--------------------|
| PRs from web | Open CI status bar, select Auto-fix |
| Mobile app | Tell Claude to auto-fix the PR |
| Any existing PR | Paste PR URL into session, ask Claude to auto-fix |

Claude's behavior: pushes clear fixes, asks about ambiguous requests, notes duplicates and no-action events. Replies posted to GitHub appear under your username but are labeled as from Claude Code.

### Session Sharing

| Account type | Visibility options | Repo access verification |
|:-------------|:-------------------|:-------------------------|
| Enterprise / Teams | Private, Team | Enabled by default |
| Max / Pro | Private, Public | Not enabled by default (configurable in Settings) |

### Cloud Environment

**Pre-installed languages:** Python 3.x (pip, poetry), Node.js LTS (npm, yarn, pnpm, bun), Ruby 3.1.6/3.2.6/3.3.6 (rbenv), PHP 8.4.14, Java (OpenJDK, Maven, Gradle), Go, Rust (cargo), C++ (GCC, Clang)

**Databases:** PostgreSQL 16, Redis 7.0

**Check installed tools:** Run `check-tools` in a cloud session.

### Setup Scripts vs SessionStart Hooks

| | Setup scripts | SessionStart hooks |
|:--|:--------------|:-------------------|
| **Attached to** | Cloud environment | Repository (.claude/settings.json) |
| **Runs** | Before Claude Code launches, new sessions only | After Claude Code launches, every session (including resumed) |
| **Scope** | Cloud environments only | Both local and cloud |

Use setup scripts for cloud-specific tooling. Use SessionStart hooks for dependency installation that should also run locally. Check `CLAUDE_CODE_REMOTE` env var to skip local execution in hooks.

### Network Access Levels

| Level | Behavior |
|:------|:---------|
| **Limited** (default) | Allowlisted domains only (package registries, cloud platforms, version control, etc.) |
| **No internet** | No outbound access (Anthropic API still allowed) |
| **Full internet** | Unrestricted outbound access |

All outbound traffic passes through a security proxy (HTTP/HTTPS). GitHub operations use a dedicated proxy with scoped credentials (push restricted to current working branch).

### Key Environment Variables (Cloud)

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_REMOTE` | Set to `"true"` in remote environments (use in hooks to skip local execution) |
| `CLAUDE_ENV_FILE` | Path to file where SessionStart hooks can persist env vars for subsequent Bash commands |

### Scheduling and Management

| Command / Feature | Purpose |
|:------------------|:--------|
| `/tasks` | Monitor background/remote sessions |
| `/web-setup` | Connect GitHub via gh CLI credentials |
| `/remote-env` | Select default cloud environment for --remote |
| Schedule recurring tasks | See web-scheduled-tasks documentation |
| Archive sessions | Hover in sidebar, click archive icon |
| Delete sessions | Filter for archived, then delete; or session menu dropdown |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- Agent SDK CLI with -p/--print flag, --bare mode for CI, output formats (text/json/stream-json), --json-schema for structured output, stream-json events and api_retry, --allowedTools with permission rule syntax and prefix matching, --append-system-prompt and --system-prompt, --continue and --resume for multi-turn conversations, session ID capture, common patterns (commits, PR reviews, streaming with jq)
- [Claude Code on the web](references/claude-code-on-the-web.md) -- Cloud sessions via claude.ai/code (Pro/Max/Team/Enterprise), GitHub integration and Claude GitHub App, diff view for reviewing changes, auto-fix for pull requests (CI failures and review comments), --remote flag for terminal-to-web tasks, teleport for web-to-terminal (--teleport, /teleport, /tp, /tasks), session sharing (Enterprise/Teams vs Max/Pro visibility), cloud environment (universal image with pre-installed languages and databases, check-tools), setup scripts vs SessionStart hooks, dependency management (CLAUDE_CODE_REMOTE, CLAUDE_ENV_FILE), network access levels (limited/none/full with allowlisted domains), GitHub proxy and security proxy, security and isolation (isolated VMs, credential protection), session management (archive, delete), scheduling recurring tasks, limitations (GitHub only)

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
