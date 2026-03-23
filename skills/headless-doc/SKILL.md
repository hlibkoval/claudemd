---
name: headless-doc
description: Complete documentation for running Claude Code programmatically via the Agent SDK CLI (`claude -p`) and Claude Code on the web (cloud sessions at claude.ai/code). Covers non-interactive mode with `-p` flag, `--bare` mode for CI/scripts (skips hooks/skills/plugins/MCP/CLAUDE.md autodiscovery, requires ANTHROPIC_API_KEY), output formats (`--output-format text/json/stream-json`, `--json-schema` for structured output, `--verbose --include-partial-messages` for streaming with `stream_event` and `text_delta`), `--allowedTools` with permission rule syntax and prefix matching (`Bash(git diff *)`), `--continue` and `--resume` for multi-turn conversations, `--append-system-prompt` and `--system-prompt` for prompt customization, `system/api_retry` retry events (attempt, max_retries, retry_delay_ms, error_status, error category). Also covers Claude Code on the web (research preview) -- cloud sessions on Anthropic-managed VMs for Pro/Max/Team/Enterprise users, GitHub integration, repository cloning, environment setup with setup scripts (bash, runs as root on Ubuntu 24.04, before Claude Code launches, new sessions only), diff view for reviewing changes before PR creation, session sharing (Private/Team for Enterprise/Teams, Private/Public for Max/Pro, repository access verification), `--remote` flag to start web sessions from terminal, `/teleport` and `--teleport` to pull web sessions into terminal (requires clean git state, correct repo, same account), `/tasks` for monitoring background sessions, `/remote-env` for environment selection, cloud environment configuration (default universal image with Python/Node.js/Ruby/PHP/Java/Go/Rust/C++, PostgreSQL 16, Redis 7.0, `check-tools` command), network access levels (Limited with allowlisted domains, No internet, Full internet), GitHub proxy with scoped credentials, security proxy for HTTP/HTTPS traffic, setup scripts vs SessionStart hooks comparison, dependency management with setup scripts and SessionStart hooks (`CLAUDE_CODE_REMOTE` env var check, `CLAUDE_ENV_FILE` for persisting env vars), default allowed domains list (Anthropic, GitHub/GitLab/Bitbucket, Docker registries, cloud platforms AWS/GCP/Azure, package managers for JS/Python/Ruby/Rust/Go/JVM/PHP/.NET/Dart/Elixir/Perl/iOS/Haskell/Swift, Ubuntu repos, dev tools Kubernetes/HashiCorp/Anaconda/Apache, monitoring Sentry/Datadog/Statsig, CDN/mirrors, schema registries, MCP), session management (archiving, deleting), security and isolation (isolated VMs, network controls, credential protection via proxy), pricing shares rate limits with all Claude usage. Load when discussing headless mode, claude -p, non-interactive mode, programmatic Claude Code, Agent SDK CLI, bare mode, structured output, json schema output, stream-json, streaming responses, auto-approve tools, allowedTools, continue conversations, resume sessions, system prompt customization, Claude Code on the web, cloud sessions, remote sessions, --remote flag, teleport sessions, /teleport, web to terminal, setup scripts, cloud environment, network access, allowed domains, security proxy, GitHub proxy, session sharing, diff view, environment configuration, dependency management in cloud, CLAUDE_CODE_REMOTE, check-tools, universal image, or running Claude Code in CI/CD pipelines.
user-invocable: false
---

# Headless Mode & Cloud Sessions Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`claude -p`) and running cloud sessions through Claude Code on the web.

## Quick Reference

### CLI Non-Interactive Mode (`claude -p`)

Pass `-p` (or `--print`) to run Claude Code non-interactively. All CLI options work with `-p`.

| Flag | Purpose |
|:-----|:--------|
| `-p "prompt"` | Run non-interactively, print response |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for CI) |
| `--output-format text\|json\|stream-json` | Control response format |
| `--json-schema '{...}'` | Constrain output to a JSON Schema (use with `--output-format json`) |
| `--allowedTools "Bash,Read,Edit"` | Auto-approve specific tools without prompting |
| `--continue` | Continue most recent conversation |
| `--resume <session_id>` | Resume a specific conversation |
| `--append-system-prompt "..."` | Add instructions while keeping defaults |
| `--system-prompt "..."` | Fully replace the default system prompt |
| `--verbose --include-partial-messages` | Enable token-level streaming (with `stream-json`) |

### Bare Mode

`--bare` reduces startup time by skipping all auto-discovery. Only explicitly passed flags take effect. Authentication must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in `--settings`. Bedrock, Vertex, and Foundry use their usual provider credentials.

| To load in bare mode | Use |
|:---------------------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

### Output Formats

| Format | Description |
|:-------|:------------|
| `text` | Plain text (default) |
| `json` | Structured JSON with `result`, `session_id`, metadata; `structured_output` field when `--json-schema` used |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

Filter streaming text deltas with jq: `select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text`

### Auto-Approve Tools

`--allowedTools` uses permission rule syntax. The trailing ` *` enables prefix matching (space before `*` is important).

```
--allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"
```

### Retry Events (stream-json)

When an API request fails with a retryable error, a `system/api_retry` event is emitted:

| Field | Description |
|:------|:------------|
| `attempt` | Current attempt number (starting at 1) |
| `max_retries` | Total retries permitted |
| `retry_delay_ms` | Milliseconds until next attempt |
| `error_status` | HTTP status code or `null` for connection errors |
| `error` | Category: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |

### Multi-Turn Conversations

```bash
# First request
claude -p "Review this codebase for performance issues"

# Continue most recent
claude -p "Now focus on the database queries" --continue

# Capture and resume specific session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

---

## Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs. Available in research preview for Pro, Max, Team, and Enterprise users.

### Getting Started

1. Visit claude.ai/code
2. Connect GitHub account
3. Install Claude GitHub app in repositories
4. Select default environment
5. Submit coding task
6. Review changes in diff view, iterate, create PR

### Web-Terminal Session Handoff

| Direction | Method |
|:----------|:-------|
| Terminal to web | `claude --remote "prompt"` |
| Web to terminal | `/teleport` (or `/tp`) interactive picker |
| Web to terminal (CLI) | `claude --teleport` or `claude --teleport <session-id>` |
| From /tasks | Run `/tasks`, press `t` to teleport |
| From web UI | Click "Open in CLI", paste command |
| Select remote env | `/remote-env` to choose environment for `--remote` |

Session handoff is one-way: you can pull web sessions into your terminal, but cannot push an existing terminal session to the web. `--remote` creates a new web session.

### Teleport Requirements

| Requirement | Details |
|:------------|:--------|
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be same repo checkout, not a fork |
| Branch available | Web session branch must be pushed to remote |
| Same account | Must be authenticated to the same Claude.ai account |

### Cloud Environment

**Default universal image includes:**

| Category | Available |
|:---------|:----------|
| Languages | Python 3.x (pip, poetry), Node.js LTS (npm, yarn, pnpm, bun), Ruby 3.1/3.2/3.3 (rbenv), PHP 8.4, Java (OpenJDK, Maven, Gradle), Go, Rust (cargo), C++ (GCC, Clang) |
| Databases | PostgreSQL 16, Redis 7.0 |
| Check installed tools | Run `check-tools` in a cloud session |

### Setup Scripts

Bash scripts that run when a new cloud session starts, before Claude Code launches. Run as root on Ubuntu 24.04.

| Behavior | Details |
|:---------|:--------|
| When they run | New sessions only (skipped on resume) |
| Failure handling | Non-zero exit fails session start; use `|| true` for non-critical commands |
| Network requirement | Need network access to reach package registries |

### Setup Scripts vs SessionStart Hooks

| | Setup scripts | SessionStart hooks |
|:--|:--------------|:-------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches, new sessions only | After Claude Code launches, every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Use `CLAUDE_CODE_REMOTE` env var to conditionally skip local execution in SessionStart hooks.

### Network Access Levels

| Level | Description |
|:------|:------------|
| **Limited** (default) | Access to allowlisted domains only |
| **No internet** | No outbound access (Anthropic API still reachable) |
| **Full internet** | Unrestricted outbound access |

### Default Allowed Domains (Limited mode)

| Category | Domains |
|:---------|:--------|
| Anthropic | api.anthropic.com, statsig.anthropic.com, platform.claude.com, code.claude.com, claude.ai |
| Version control | github.com, api.github.com, gitlab.com, bitbucket.org (and subdomains) |
| Container registries | Docker Hub, GCR, GHCR, MCR, ECR |
| Cloud platforms | GCP, Azure, AWS, Oracle (and subdomains) |
| JS/Node | registry.npmjs.org, yarnpkg.com |
| Python | pypi.org, files.pythonhosted.org |
| Ruby | rubygems.org, ruby-lang.org |
| Rust | crates.io, rustup.rs, static.rust-lang.org |
| Go | proxy.golang.org, sum.golang.org, pkg.go.dev |
| JVM | repo.maven.org, gradle.org, spring.io |
| Other languages | packagist.org (PHP), nuget.org (.NET), pub.dev (Dart), hex.pm (Elixir), cpan.org (Perl), cocoapods.org (iOS), hackage.haskell.org, swift.org |
| Linux | archive.ubuntu.com, ppa.launchpad.net |
| Dev tools | dl.k8s.io, releases.hashicorp.com, repo.anaconda.com, nodejs.org |
| Monitoring | sentry.io, datadoghq.com, statsig.com |
| Schema | json-schema.org, json.schemastore.org |
| MCP | *.modelcontextprotocol.io |

### Security

| Feature | Description |
|:--------|:------------|
| Isolated VMs | Each session runs in its own Anthropic-managed VM |
| Network controls | Configurable access levels with domain allowlisting |
| Credential protection | Git credentials and signing keys never inside sandbox; authentication via secure proxy with scoped credentials |
| GitHub proxy | All git operations go through a dedicated proxy; push restricted to current working branch |
| Security proxy | All outbound HTTP/HTTPS traffic passes through a security proxy for abuse prevention |

### Session Sharing

| Account type | Visibility options | Notes |
|:-------------|:-------------------|:------|
| Enterprise / Teams | Private, Team | Team = visible to org members; repo access verification enabled by default |
| Max / Pro | Private, Public | Public = visible to any logged-in claude.ai user; check for sensitive content before sharing |

### Session Management

- **Archive**: hover over session in sidebar, click archive icon (hidden from default list, viewable via filter)
- **Delete**: filter for archived sessions then click delete, or open session menu and select Delete (permanent, cannot be undone)

### Limitations

- Repository authentication requires same account for web-to-local handoff
- Only GitHub repositories supported (no GitLab or other platforms for cloud sessions)
- Pricing shares rate limits with all other Claude and Claude Code usage

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- Agent SDK CLI usage with `-p` flag, `--bare` mode for CI/scripts (skips hooks/skills/plugins/MCP/CLAUDE.md, requires ANTHROPIC_API_KEY, recommended for scripted calls), output formats (`text`/`json`/`stream-json`, `--json-schema` for structured output, jq extraction), streaming responses with `--verbose --include-partial-messages` and `text_delta` filtering, `system/api_retry` retry events (attempt, max_retries, retry_delay_ms, error_status, error categories), `--allowedTools` with permission rule syntax and prefix matching (`Bash(git diff *)`), commit creation example, `--append-system-prompt` and `--system-prompt` for prompt customization, `--continue` and `--resume` for multi-turn conversations with session ID capture
- [Claude Code on the web](references/claude-code-on-the-web.md) -- cloud sessions on Anthropic-managed VMs (research preview for Pro/Max/Team/Enterprise), GitHub integration and repository cloning, diff view for reviewing changes before PR creation, `--remote` flag to start web sessions from terminal, `/teleport` and `--teleport` for web-to-terminal handoff (clean git state, correct repo, same account requirements), `/tasks` for monitoring, `/remote-env` for environment selection, plan-locally-execute-remotely pattern, parallel remote tasks, session sharing (Private/Team for Enterprise/Teams with repo access verification, Private/Public for Max/Pro), session archiving and deletion, cloud environment (universal image with Python/Node.js/Ruby/PHP/Java/Go/Rust/C++, PostgreSQL 16, Redis 7.0, `check-tools` command), setup scripts (bash, root on Ubuntu 24.04, new sessions only, non-zero exit fails start), setup scripts vs SessionStart hooks comparison, dependency management (setup scripts, SessionStart hooks with `CLAUDE_CODE_REMOTE` check, `CLAUDE_ENV_FILE` for persisting env vars, proxy compatibility caveats including Bun), network access levels (Limited/No internet/Full), default allowed domains (Anthropic, version control, container registries, cloud platforms, package managers for JS/Python/Ruby/Rust/Go/JVM/PHP/.NET/Dart/Elixir/Perl/iOS/Haskell/Swift, Linux repos, dev tools, monitoring, schema registries, MCP), GitHub proxy with scoped credentials, security proxy for HTTP/HTTPS, isolated VMs, credential protection, security best practices

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
