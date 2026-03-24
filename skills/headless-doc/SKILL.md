---
name: headless-doc
description: Complete documentation for Claude Code headless/programmatic usage and Claude Code on the web -- Agent SDK CLI mode (claude -p flag, --bare mode for CI/scripts, --output-format text/json/stream-json, --json-schema for structured output, --allowedTools with permission rule syntax prefix matching, --continue/--resume for conversation continuity, --append-system-prompt/--system-prompt for prompt customization, --verbose --include-partial-messages for streaming, stream-json event types system/api_retry with attempt/max_retries/retry_delay_ms/error_status/error fields, jq filtering for text deltas and result extraction, Bash(git diff *) prefix matching with space-before-asterisk convention), bare mode context loading flags (--append-system-prompt-file, --settings, --mcp-config, --agents, --plugin-dir), bare mode authentication (ANTHROPIC_API_KEY or apiKeyHelper in --settings JSON, Bedrock/Vertex/Foundry provider credentials), Claude Code on the web (research preview for Pro/Max/Team/Enterprise, claude.ai/code web interface, GitHub account connection, GitHub App installation, environment selector, diff view for reviewing changes before PR, session management archive/delete, --remote flag for terminal-to-web handoff, --teleport/teleport command/tp for web-to-terminal handoff with clean-git-state/correct-repository/branch-available/same-account requirements, /tasks for monitoring background sessions, /remote-env for default environment selection, session sharing Private/Team for Enterprise-Teams and Private/Public for Max-Pro with repository access verification toggle, recurring task scheduling via web-scheduled-tasks), cloud environment (universal image with Python/Node.js/Ruby/PHP/Java/Go/Rust/C++ and PostgreSQL 16/Redis 7.0, check-tools command, setup scripts as root on Ubuntu 24.04 running before Claude Code launches on new sessions only, setup scripts vs SessionStart hooks scope/timing/configuration differences, dependency management via setup scripts or SessionStart hooks with CLAUDE_CODE_REMOTE check and CLAUDE_ENV_FILE for persisting env vars), network access and security (GitHub proxy with scoped credentials restricting push to current branch, HTTP/HTTPS security proxy for abuse prevention, Limited/No internet/Full access levels, default allowed domains for Anthropic/GitHub/GitLab/Bitbucket/Docker/cloud platforms/npm/PyPI/RubyGems/crates.io/Go/JVM/Packagist/NuGet/pub.dev/hex.pm/CPAN/CocoaPods/Haskell/Swift/Ubuntu/Kubernetes/HashiCorp/Anaconda/Apache/Eclipse/Node.js/Statsig/Sentry/Datadog/SourceForge/JSON Schema/MCP, wildcard subdomain matching), security and isolation (isolated VMs, credential protection via proxy, network access controls), pricing shares account rate limits, GitHub-only platform restriction. Load when discussing headless mode, claude -p, programmatic usage, Agent SDK CLI, --bare mode, --output-format json, stream-json, structured output, --json-schema, --allowedTools in scripts, --continue, --resume, conversation continuity in CLI, --append-system-prompt, system prompt customization in headless, Claude Code on the web, claude.ai/code, --remote flag, --teleport, /teleport, /tp, /tasks, web sessions, cloud sessions, remote sessions, diff view, session sharing, /remote-env, cloud environment, setup scripts, check-tools, universal image, network access levels, allowed domains, security proxy, GitHub proxy, isolated VMs, CI/CD scripting with claude -p, or any non-interactive Claude Code usage.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`claude -p`) and using Claude Code on the web for asynchronous cloud-based tasks.

## Quick Reference

### CLI Programmatic Mode (`claude -p`)

Pass `-p` (or `--print`) to run Claude Code non-interactively. All CLI options work with `-p`.

| Flag | Purpose |
|:-----|:--------|
| `-p "prompt"` | Run non-interactively, print response, exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for CI/scripts) |
| `--output-format text\|json\|stream-json` | Control response format |
| `--json-schema '{...}'` | Enforce structured output (use with `--output-format json`) |
| `--allowedTools "Tool1,Tool2"` | Auto-approve specified tools |
| `--continue` | Continue most recent conversation |
| `--resume <session-id>` | Continue a specific conversation |
| `--append-system-prompt "..."` | Add to default system prompt |
| `--system-prompt "..."` | Fully replace default system prompt |
| `--append-system-prompt-file <path>` | Load system prompt addition from file |
| `--verbose --include-partial-messages` | Enable token-level streaming with `stream-json` |

### Bare Mode Context Loading

When using `--bare`, only explicitly passed flags take effect:

| To load | Flag |
|:--------|:-----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

Authentication in bare mode: `ANTHROPIC_API_KEY` env var or `apiKeyHelper` in `--settings` JSON. Bedrock, Vertex, and Foundry use their usual provider credentials.

### Output Formats

| Format | Description | Key fields |
|:-------|:------------|:-----------|
| `text` | Plain text (default) | Raw response text |
| `json` | Structured JSON with metadata | `result` (text), `session_id`, `structured_output` (with `--json-schema`) |
| `stream-json` | Newline-delimited JSON events | Event objects with `type`, `event` fields |

### Streaming Event: `system/api_retry`

Emitted when an API request fails with a retryable error:

| Field | Type | Description |
|:------|:-----|:------------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Retry event identifier |
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | Category: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |

### `--allowedTools` Permission Rule Syntax

Uses permission rule syntax with prefix matching. The space before `*` is important:

| Pattern | Matches |
|:--------|:--------|
| `Bash` | All Bash commands |
| `Bash(git diff *)` | Commands starting with `git diff ` |
| `Read,Edit` | Read and Edit tools |
| `mcp__github__*` | All tools from github MCP server |

Note: `Bash(git diff*)` without the space would also match `git diff-index`.

### Claude Code on the Web

**Availability:** Research preview for Pro, Max, Team, and Enterprise users.

**Getting started:** Visit claude.ai/code, connect GitHub, install Claude GitHub App, select environment, submit task.

**Session lifecycle:**
1. Repository cloned to Anthropic-managed VM
2. Setup script runs (if configured)
3. Network access configured per environment settings
4. Claude executes task (write code, run tests, check work)
5. Changes pushed to branch, ready for PR creation

### Terminal-to-Web and Web-to-Terminal

| Direction | Method | Description |
|:----------|:-------|:------------|
| Terminal to web | `claude --remote "prompt"` | Creates new web session; monitor via `/tasks` |
| Web to terminal | `/teleport` or `/tp` | Interactive picker of web sessions |
| Web to terminal | `claude --teleport` | Interactive picker from CLI |
| Web to terminal | `claude --teleport <session-id>` | Resume specific session |
| Web to terminal | `/tasks` then press `t` | Teleport from task list |

**Teleport requirements:**

| Requirement | Details |
|:------------|:--------|
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be in checkout of same repo (not a fork) |
| Branch available | Branch must be pushed to remote |
| Same account | Same Claude.ai account as web session |

Session handoff is one-way: web-to-terminal only. `--remote` creates a new web session (does not push an existing terminal session).

### Session Sharing

| Account type | Visibility options | Repository access verification |
|:-------------|:-------------------|:-------------------------------|
| Enterprise / Teams | Private, Team (org members) | Enabled by default |
| Max / Pro | Private, Public (any logged-in claude.ai user) | Disabled by default (enable in Settings > Claude Code > Sharing settings) |

### Cloud Environment

**Default image (Ubuntu 24.04):**

| Category | Pre-installed |
|:---------|:--------------|
| Languages | Python 3.x (pip, poetry), Node.js LTS (npm, yarn, pnpm, bun), Ruby 3.1/3.2/3.3 (rbenv), PHP 8.4, Java (OpenJDK, Maven, Gradle), Go, Rust (cargo), C++ (GCC, Clang) |
| Databases | PostgreSQL 16, Redis 7.0 |
| Check tools | Run `check-tools` to see all installed versions |

### Setup Scripts

Bash scripts that run as root before Claude Code launches on new sessions only. Configure in cloud environment settings UI.

| Property | Setup scripts | SessionStart hooks |
|:---------|:--------------|:-------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code, new sessions only | After Claude Code, every session (including resumed) |
| Scope | Cloud environments only | Both local and cloud |

Non-zero exit fails session start. Append `|| true` to non-critical commands.

### Network Access Levels

| Level | Behavior |
|:------|:---------|
| Limited (default) | Allowlisted domains only (package registries, cloud platforms, VCS hosts) |
| No internet | No outbound access (Anthropic API still reachable) |
| Full | Unrestricted outbound access |

**Default allowed domain categories (Limited mode):** Anthropic services, GitHub/GitLab/Bitbucket, Docker registries, cloud platforms (GCP, Azure, AWS, Oracle), package managers (npm, PyPI, RubyGems, crates.io, Go proxy, Maven/Gradle, Packagist, NuGet, pub.dev, hex.pm, CPAN, CocoaPods, Haskell/Hackage, Swift), Ubuntu repositories, dev tools (Kubernetes, HashiCorp, Anaconda, Apache, Eclipse, Node.js), monitoring (Statsig, Sentry, Datadog), CDN/mirrors, JSON Schema, MCP.

### Security

| Feature | Details |
|:--------|:--------|
| Isolation | Each session in a separate Anthropic-managed VM |
| Git credentials | Never inside sandbox; authentication via secure proxy with scoped credentials |
| Push restriction | Git push limited to current working branch |
| Network proxy | All outbound traffic passes through HTTP/HTTPS security proxy |

### Limitations

- GitHub only (no GitLab or other platforms for web sessions)
- Session transfer requires same account authentication
- Bun has known proxy compatibility issues in remote environments

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- Agent SDK CLI mode via claude -p, --bare mode for CI/scripts (skips hooks/skills/plugins/MCP/CLAUDE.md), bare mode context loading flags (--append-system-prompt-file, --settings, --mcp-config, --agents, --plugin-dir), bare mode authentication (ANTHROPIC_API_KEY or apiKeyHelper), output formats (text/json/stream-json), --json-schema for structured output with structured_output field, streaming with --verbose --include-partial-messages, system/api_retry event fields (attempt, max_retries, retry_delay_ms, error_status, error), jq filtering examples, --allowedTools with permission rule syntax and prefix matching (space-before-asterisk), Bash(git diff *) and Bash(git commit *) patterns, --continue and --resume for conversation continuity, --append-system-prompt and --system-prompt for prompt customization, create-a-commit example, skills and built-in commands unavailable in -p mode
- [Claude Code on the web](references/claude-code-on-the-web.md) -- research preview for Pro/Max/Team/Enterprise, claude.ai/code web interface, GitHub account connection and GitHub App installation, environment selector with setup scripts, diff view for reviewing changes before PR creation, --remote flag for terminal-to-web session handoff, --teleport and /teleport (/tp) for web-to-terminal with requirements (clean git state, correct repository, branch available, same account), /tasks for monitoring, /remote-env for default environment, session sharing (Private/Team for Enterprise-Teams, Private/Public for Max-Pro, repository access verification), recurring task scheduling, session management (archive/delete), cloud environment universal image (Python/Node.js/Ruby/PHP/Java/Go/Rust/C++, PostgreSQL 16, Redis 7.0, check-tools command), setup scripts (root on Ubuntu 24.04, new sessions only, vs SessionStart hooks), dependency management with CLAUDE_CODE_REMOTE check and CLAUDE_ENV_FILE, network access levels (Limited/No internet/Full), default allowed domains (package registries, cloud platforms, VCS, dev tools, monitoring), GitHub proxy with scoped credentials and branch push restriction, HTTP/HTTPS security proxy, isolated VM security, pricing and rate limits, GitHub-only limitation

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
