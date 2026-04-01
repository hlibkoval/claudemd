---
name: headless-doc
description: Complete documentation for Claude Code headless/programmatic mode (Agent SDK CLI) and Claude Code on the web -- CLI `-p` flag (non-interactive mode), `--bare` mode for CI/scripts, `--output-format` (text/json/stream-json), `--json-schema` for structured output, `--allowedTools` with permission rule syntax, `--continue`/`--resume` for conversation continuity, `--append-system-prompt`, streaming with `--verbose --include-partial-messages`, system/api_retry events; Claude Code on the web (cloud sessions), `--remote` flag for terminal-to-web, `/teleport` and `--teleport` for web-to-terminal, `/web-setup` for GitHub connection, `/tasks` for monitoring, diff view, auto-fix PRs (CI failures and review comments), setup scripts vs SessionStart hooks, cloud environment (default image, languages, databases), network access levels (limited/full/none), default allowed domains, security proxy, GitHub proxy with scoped credentials, session sharing (Team/Public visibility), session archiving/deletion, environment variables in .env format, `/remote-env` for environment selection, scheduled tasks. Load when discussing headless mode, programmatic Claude Code, `-p` flag, `--print`, `--bare`, non-interactive CLI, scripted usage, CI pipelines, structured output, stream-json, json-schema, Agent SDK CLI, Claude Code on the web, cloud sessions, remote sessions, `--remote`, teleport, `/teleport`, `/tp`, web setup, `/web-setup`, auto-fix, setup scripts, cloud environment, network access, allowed domains, security proxy, or any headless/web/programmatic topic for Claude Code.
user-invocable: false
---

# Headless Mode & Claude Code on the Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (headless mode / Agent SDK) and using Claude Code on the web with cloud-hosted sessions.

## Quick Reference

### Headless Mode (CLI `-p` Flag)

| Flag | Purpose |
|:-----|:--------|
| `-p` / `--print` | Run non-interactively (headless mode) |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for scripts) |
| `--output-format text` | Plain text output (default) |
| `--output-format json` | Structured JSON with result, session ID, metadata |
| `--output-format stream-json` | Newline-delimited JSON for real-time streaming |
| `--json-schema '{...}'` | Enforce output schema (use with `--output-format json`; result in `structured_output` field) |
| `--allowedTools "Tool1,Tool2"` | Auto-approve tools without prompting |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific conversation by session ID |
| `--append-system-prompt "..."` | Add instructions while keeping default behavior |
| `--system-prompt "..."` | Fully replace the default system prompt |
| `--verbose` | Include verbose output (use with stream-json) |
| `--include-partial-messages` | Stream tokens as they are generated |

### Bare Mode Context Loading

In `--bare` mode, nothing is auto-discovered. Pass context explicitly:

| To load | Flag |
|:--------|:-----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

Bare mode skips OAuth and keychain reads. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in settings JSON. Bedrock, Vertex, and Foundry use their usual provider credentials.

### Common Headless Patterns

**Structured output with schema:**

```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

**Create a commit (with scoped tool permissions):**

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

The `--allowedTools` flag uses permission rule syntax. Trailing ` *` enables prefix matching (the space before `*` is important).

**Stream text deltas:**

```bash
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

**Multi-turn conversation:**

```bash
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Stream Event: API Retry

When streaming, retryable API errors emit a `system/api_retry` event:

| Field | Type | Description |
|:------|:-----|:------------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Identifies retry event |
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | Category: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |

### Claude Code on the Web

| Feature | Details |
|:--------|:--------|
| Availability | Pro, Max, Team, Enterprise (research preview) |
| Platform | GitHub repositories only (including GHES for Teams/Enterprise) |
| Mobile | iOS and Android Claude apps supported |
| Setup (browser) | claude.ai/code > connect GitHub > install Claude GitHub App > select environment |
| Setup (terminal) | `/web-setup` (syncs `gh auth token`, creates default environment) |

### Terminal-to-Web and Web-to-Terminal

| Direction | Command | Notes |
|:----------|:--------|:------|
| Terminal to web | `claude --remote "task description"` | Creates new web session; monitor with `/tasks` |
| Web to terminal (interactive) | `/teleport` or `/tp` | Interactive picker of web sessions |
| Web to terminal (CLI) | `claude --teleport` or `claude --teleport <session-id>` | Direct session resume |
| From /tasks | `/tasks` then press `t` | Teleport into a background session |
| From web UI | "Open in CLI" button | Copies paste-ready command |

**Teleport requirements:**

| Requirement | Details |
|:------------|:--------|
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be in a checkout of the same repo (not a fork) |
| Branch available | Web session branch must be pushed to remote |
| Same account | Must be authenticated to the same Claude.ai account |

Session handoff is one-way: you can pull web sessions into your terminal, but not push terminal sessions to the web. `--remote` creates a *new* web session.

### Auto-Fix Pull Requests

Auto-fix watches a PR and automatically responds to CI failures and review comments. Requires the Claude GitHub App installed on the repository.

**Activation methods:**
- PRs created in Claude Code on the web: open CI status bar, select Auto-fix
- Mobile app: tell Claude to auto-fix the PR
- Any existing PR: paste URL into a session and ask Claude to auto-fix

**Response behavior:**
- Clear fixes: pushes fix and explains in session
- Ambiguous requests: asks before acting
- Duplicate/no-action events: notes in session, moves on

Claude replies to review threads using your GitHub account (labeled as from Claude Code). Be cautious with repos using comment-triggered automation (Atlantis, Terraform Cloud, etc.).

### Session Sharing

| Account Type | Visibility Options | Notes |
|:-------------|:-------------------|:------|
| Enterprise / Teams | Private, Team | Team = visible to org members; repo access verification on by default |
| Max / Pro | Private, Public | Public = visible to any logged-in claude.ai user; check for sensitive content first |

Slack sessions on Teams/Enterprise are automatically shared with Team visibility.

### Cloud Environment

**Default image includes:**

| Category | Available |
|:---------|:---------|
| Python | 3.x with pip, poetry |
| Node.js | Latest LTS with npm, yarn, pnpm, bun |
| Ruby | 3.1.6, 3.2.6, 3.3.6 (default 3.3.6) with rbenv |
| PHP | 8.4.14 |
| Java | OpenJDK with Maven, Gradle |
| Go | Latest stable |
| Rust | Toolchain with cargo |
| C++ | GCC, Clang |
| PostgreSQL | 16 |
| Redis | 7.0 |

Run `check-tools` in a cloud session to see what is pre-installed.

### Setup Scripts vs SessionStart Hooks

|  | Setup Scripts | SessionStart Hooks |
|:--|:-------------|:-------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches, new sessions only | After Claude Code launches, every session (including resumed) |
| Scope | Cloud environments only | Both local and cloud |

Use setup scripts for cloud-specific tooling. Use SessionStart hooks for project setup that runs everywhere. Check `CLAUDE_CODE_REMOTE` env var to conditionally skip local execution in hooks.

### Network Access Levels

| Level | Behavior |
|:------|:---------|
| Limited (default) | Allowlisted domains only (package registries, cloud platforms, VCS hosts) |
| Full | Unrestricted internet access |
| No internet | No outbound access (Anthropic API still reachable) |

Default allowed domain categories: Anthropic services, version control (GitHub/GitLab/Bitbucket), container registries (Docker/GCR/GHCR/ECR), cloud platforms (GCP/Azure/AWS/Oracle), package managers (npm/PyPI/RubyGems/crates.io/Go/Maven/Gradle/Composer/NuGet/pub.dev/Hex/CPAN/CocoaPods/Hackage), Linux distros (Ubuntu/Launchpad), dev tools (Kubernetes/HashiCorp/Anaconda/Apache/Node.js), monitoring (Statsig/Sentry/Datadog), CDN/mirrors (SourceForge/packagecloud), schema (json-schema.org/schemastore), MCP.

### Environment Configuration

- **Add environment:** Select current environment > "Add environment" > specify name, network access, env vars, setup script
- **Update environment:** Select current environment > settings button
- **Select default from terminal:** `/remote-env` (chooses environment for `--remote`)
- **Environment variables:** Specified as key-value pairs in `.env` format

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) -- Agent SDK CLI usage, `-p` flag, `--bare` mode for scripts/CI, output formats (text/json/stream-json), `--json-schema` for structured output, streaming with `--verbose --include-partial-messages`, `system/api_retry` event fields, `--allowedTools` with permission rule syntax, `--continue`/`--resume` for multi-turn conversations, `--append-system-prompt` customization, common patterns (commits, reviews, PR diffs)
- [Claude Code on the Web](references/claude-code-on-the-web.md) -- Cloud-hosted sessions (research preview), setup from browser and terminal (`/web-setup`), `--remote` for terminal-to-web, `/teleport` and `--teleport` for web-to-terminal, auto-fix PRs (CI failures and review comments), diff view, session sharing (Team/Public visibility), session management (archiving/deletion), cloud environment (default image, languages, databases), setup scripts vs SessionStart hooks, dependency management, network access levels (limited/full/none), default allowed domains, security proxy, GitHub proxy, scheduling recurring tasks, security and isolation, pricing and rate limits, limitations

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
