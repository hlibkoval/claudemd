---
name: headless-doc
description: Complete documentation for running Claude Code programmatically (Agent SDK CLI) and Claude Code on the web. Covers the -p flag for non-interactive execution, --bare mode for CI/scripts, --output-format (text, json, stream-json), --json-schema for structured output, --allowedTools for auto-approving tools, --permission-mode, --continue and --resume for conversation continuity, --append-system-prompt, streaming with stream-json and api_retry events, Claude Code on the web (cloud sessions, --remote flag, --teleport, /teleport, /tasks), auto-fix for pull requests, cloud environment configuration, setup scripts vs SessionStart hooks, network access levels (limited, full, none), default allowed domains, security proxy, GitHub proxy, diff view, session sharing, session management (archive, delete), /web-setup, /remote-env, dependency management, environment variables, and security isolation. Load when discussing headless mode, -p flag, --print flag, claude -p, non-interactive mode, programmatic usage, Agent SDK CLI, --bare mode, structured output, --json-schema, --output-format json, stream-json, streaming responses, --allowedTools, auto-approve tools, --permission-mode, --continue, --resume, session continuation, Claude Code on the web, cloud sessions, --remote, --teleport, teleport, /tasks, auto-fix, setup scripts, cloud environment, network access, allowed domains, security proxy, web sessions, or any headless/web-related topic for Claude Code.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`claude -p`) and using Claude Code on the web for asynchronous cloud-based tasks.

## Quick Reference

### CLI Programmatic Mode (`claude -p`)

| Flag | Description |
|:-----|:-----------|
| `-p` / `--print` | Run non-interactively (required for programmatic use) |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for CI) |
| `--output-format <fmt>` | `text` (default), `json`, `stream-json` |
| `--json-schema <schema>` | Constrain output to a JSON Schema (use with `--output-format json`) |
| `--allowedTools <tools>` | Auto-approve specific tools (comma-separated) |
| `--permission-mode <mode>` | `dontAsk`, `acceptEdits`, `plan`, etc. |
| `--continue` | Continue most recent conversation |
| `--resume <session_id>` | Continue a specific conversation |
| `--append-system-prompt <text>` | Add instructions to default system prompt |
| `--append-system-prompt-file <path>` | Add instructions from file |
| `--system-prompt <text>` | Fully replace the default system prompt |
| `--settings <file-or-json>` | Load settings file or inline JSON |
| `--mcp-config <file-or-json>` | Load MCP server config |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin directory |

### Bare Mode Context Loading

| To load | Use |
|:--------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

Bare mode skips OAuth and keychain reads. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON.

### Output Formats

| Format | Description |
|:-------|:-----------|
| `text` | Plain text (default) |
| `json` | Structured JSON with `result`, `session_id`, metadata; `structured_output` field when using `--json-schema` |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

For streaming, combine `--output-format stream-json` with `--verbose` and `--include-partial-messages`.

### Stream Event: api_retry

| Field | Type | Description |
|:------|:-----|:-----------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Retry event identifier |
| `attempt` | integer | Current attempt number (starting at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |

### Common Patterns

**Create a commit:**
```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

**Pipe input for review:**
```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

**Extract structured data:**
```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

**Capture session ID for multi-turn:**
```bash
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### allowedTools Syntax

Uses permission rule syntax. Trailing ` *` enables prefix matching (e.g., `Bash(git diff *)` matches any command starting with `git diff`). The space before `*` matters: `Bash(git diff*)` would also match `git diff-index`.

### Claude Code on the Web

| Feature | Description |
|:--------|:-----------|
| **Availability** | Pro, Max, Team, Enterprise (research preview) |
| **Platform** | GitHub-hosted repos only (incl. GitHub Enterprise Server for Team/Enterprise) |
| **Setup (browser)** | Visit claude.ai/code, connect GitHub, install Claude GitHub App |
| **Setup (terminal)** | Run `/web-setup` inside Claude Code (uses `gh` CLI credentials) |

### Web Session Commands

| Command / Flag | Description |
|:---------------|:-----------|
| `claude --remote "<task>"` | Start a new web session from terminal |
| `claude --teleport` | Interactive picker to resume a web session locally |
| `claude --teleport <session-id>` | Resume a specific web session locally |
| `/teleport` (or `/tp`) | Resume a web session from inside Claude Code |
| `/tasks` | View background sessions (press `t` to teleport) |
| `/web-setup` | Connect GitHub and configure web environment |
| `/remote-env` | Select default cloud environment for `--remote` |

### Teleport Requirements

| Requirement | Details |
|:------------|:--------|
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be same repo checkout, not a fork |
| Branch available | Web session branch must be pushed to remote |
| Same account | Same Claude.ai account as the web session |

### Auto-fix Pull Requests

Requires the Claude GitHub App installed on the repository. Claude watches a PR and automatically responds to CI failures and review comments.

| Behavior | When |
|:---------|:-----|
| Pushes a fix | Confident fix, no conflict with earlier instructions |
| Asks before acting | Ambiguous request or architecturally significant change |
| Notes and moves on | Duplicate or no-action event |

Claude replies to review threads using your GitHub account (labeled as from Claude Code).

### Cloud Environment

**Default image includes:** Python 3.x (pip, poetry), Node.js LTS (npm, yarn, pnpm, bun), Ruby 3.1/3.2/3.3, PHP 8.4, Java (Maven, Gradle), Go, Rust, C++ (GCC, Clang), PostgreSQL 16, Redis 7.0.

Run `check-tools` inside a cloud session to see installed versions.

### Setup Scripts vs SessionStart Hooks

| | Setup scripts | SessionStart hooks |
|:--|:-------------|:-------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches, new sessions only | After Claude Code launches, every session (incl. resumed) |
| Scope | Cloud environments only | Both local and cloud |

### Network Access Levels

| Level | Behavior |
|:------|:---------|
| Limited (default) | Allowlisted domains only (package registries, GitHub, cloud platforms, etc.) |
| Full | Unrestricted internet access |
| None | No internet (Anthropic API still accessible) |

### Default Allowed Domain Categories (Limited Mode)

| Category | Examples |
|:---------|:--------|
| Anthropic Services | api.anthropic.com, claude.ai, code.claude.com |
| Version Control | github.com, gitlab.com, bitbucket.org |
| Container Registries | registry-1.docker.io, ghcr.io, public.ecr.aws |
| Cloud Platforms | googleapis.com, amazonaws.com, azure.com |
| JS/Node | registry.npmjs.org, yarnpkg.com |
| Python | pypi.org, files.pythonhosted.org |
| Ruby | rubygems.org, ruby-lang.org |
| Rust | crates.io, rustup.rs |
| Go | proxy.golang.org, pkg.go.dev |
| JVM | repo.maven.org, services.gradle.org |
| Other Languages | packagist.org, nuget.org, pub.dev, hex.pm, cocoapods.org |
| Linux | archive.ubuntu.com, ppa.launchpad.net |
| Dev Tools | dl.k8s.io, releases.hashicorp.com, nodejs.org |

### Session Sharing Visibility

| Account type | Options | Notes |
|:-------------|:--------|:------|
| Enterprise / Team | Private, Team | Team = visible to org members; repo access verified by default |
| Max / Pro | Private, Public | Public = any logged-in claude.ai user; verify content before sharing |

### Security

- Each session runs in an isolated, Anthropic-managed VM
- Git credentials handled through a secure proxy with scoped credentials (never inside sandbox)
- Git push restricted to the current working branch
- Network proxy filters all outbound HTTP/HTTPS traffic

### Environment Variables (Web)

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_REMOTE` | `"true"` in remote web environments |
| `CLAUDE_ENV_FILE` | File path for persisting env vars in SessionStart hooks |

### Dependency Management Limitations (Web)

- SessionStart hooks run in both local and remote (check `CLAUDE_CODE_REMOTE` to scope)
- Requires network access for package registries
- All outbound traffic passes through a security proxy (some package managers like Bun may not work)
- Hooks run on every session start/resume, adding latency

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) -- CLI `-p` flag, bare mode, structured output, streaming, auto-approve tools, system prompt customization, conversation continuation
- [Claude Code on the Web](references/claude-code-on-the-web.md) -- Cloud sessions, setup, --remote, --teleport, auto-fix PRs, diff view, cloud environment, setup scripts, network access, allowed domains, security

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
