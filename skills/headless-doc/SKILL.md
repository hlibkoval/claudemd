---
name: headless-doc
description: Complete documentation for running Claude Code programmatically (Agent SDK CLI) and Claude Code on the web — using `claude -p` for non-interactive/headless execution with structured output (JSON, stream-JSON, JSON Schema), auto-approving tools (--allowedTools with permission rule syntax), continuing/resuming conversations, customizing system prompts, streaming responses (stream-json, text deltas, api_retry events), and running Claude Code tasks in the cloud via claude.ai/code with GitHub integration, diff review, session management (archiving, deleting, sharing), web-to-terminal handoff (--teleport, /teleport, /tp, /tasks), terminal-to-web handoff (--remote, /remote-env), cloud environment configuration (default image, setup scripts, SessionStart hooks, dependency management, environment variables), network access and security (GitHub proxy, security proxy, access levels, default allowed domains), session sharing (Enterprise/Teams private/team visibility, Max/Pro private/public visibility), and cloud security isolation. Load when discussing headless mode, claude -p, programmatic Claude Code, Agent SDK CLI, non-interactive mode, structured output from Claude Code, --output-format, --json-schema, streaming Claude Code output, auto-approving tools, --allowedTools, continuing conversations with -p, --continue, --resume, --append-system-prompt, Claude Code on the web, cloud sessions, --remote, --teleport, /teleport, /tp, /tasks, remote environments, setup scripts, web session handoff, cloud environment setup, network allowlists, session sharing, or running Claude Code in CI/CD scripts.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI and running Claude Code tasks in the cloud via the web interface.

## Quick Reference

### Programmatic CLI Usage (Agent SDK)

Run Claude Code non-interactively by passing `-p` (or `--print`) with a prompt. All CLI options work with `-p`. The `-p` flag was previously called "headless mode."

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

For Python and TypeScript SDK packages with structured outputs, tool approval callbacks, and native message objects, see the full [Agent SDK documentation](https://platform.claude.com/docs/en/agent-sdk/overview).

### Output Formats

| Format | Flag | Description |
|:-------|:-----|:------------|
| Plain text | `--output-format text` (default) | Plain text response |
| JSON | `--output-format json` | Structured JSON with `result`, `session_id`, and metadata |
| Stream JSON | `--output-format stream-json` | Newline-delimited JSON for real-time streaming |

For schema-constrained output, combine `--output-format json` with `--json-schema`:

```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

The structured result appears in the `structured_output` field of the JSON response.

### Streaming Responses

Use `--output-format stream-json` with `--verbose` and `--include-partial-messages` to receive tokens as generated. Filter for text deltas with jq:

```bash
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

When an API request fails with a retryable error, a `system/api_retry` event is emitted with fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, and `error` (one of: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown`).

### Auto-Approve Tools

Use `--allowedTools` with permission rule syntax. Trailing ` *` enables prefix matching (the space before `*` is important):

```bash
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"
```

```bash
claude -p "Create a commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

Note: user-invoked skills (`/commit`, etc.) and built-in commands are only available in interactive mode. In `-p` mode, describe the task instead.

### Continue Conversations

| Flag | Behavior |
|:-----|:---------|
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific conversation by session ID |

Capture session IDs from JSON output for multi-step workflows:

```bash
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Customize System Prompt

| Flag | Effect |
|:-----|:-------|
| `--append-system-prompt` | Add instructions while keeping default behavior |
| `--system-prompt` | Fully replace the default prompt |

---

### Claude Code on the Web

Run Claude Code tasks asynchronously on Anthropic-managed cloud infrastructure via [claude.ai/code](https://claude.ai/code). Currently in research preview.

**Available to:** Pro, Max, Team, and Enterprise users (Enterprise requires premium seats or Chat + Claude Code seats).

#### Getting Started

1. Visit [claude.ai/code](https://claude.ai/code)
2. Connect your GitHub account and install the Claude GitHub app
3. Select your default environment
4. Submit your coding task
5. Review changes in diff view, iterate with comments, then create a PR

#### Web-Terminal Session Handoff

| Direction | Method | Details |
|:----------|:-------|:--------|
| Terminal to web | `claude --remote "prompt"` | Creates a new cloud session; monitor via `/tasks` or claude.ai |
| Web to terminal | `claude --teleport` | Interactive picker of web sessions |
| Web to terminal | `claude --teleport <session-id>` | Resume a specific web session |
| Web to terminal | `/teleport` or `/tp` | Interactive picker from within Claude Code |
| Web to terminal | `/tasks` then press `t` | Teleport from the tasks list |

Session handoff is one-way: you can pull web sessions into your terminal, but you cannot push an existing terminal session to the web. `--remote` creates a new web session.

**Teleport requirements:** clean git state (no uncommitted changes), correct repository (not a fork), branch pushed to remote, same Claude.ai account.

#### Remote Task Tips

**Plan locally, execute remotely:**

```bash
claude --permission-mode plan        # Read-only exploration
claude --remote "Execute the migration plan in docs/migration-plan.md"
```

**Run tasks in parallel:** each `--remote` creates an independent session:

```bash
claude --remote "Fix the flaky test in auth.spec.ts"
claude --remote "Update the API documentation"
claude --remote "Refactor the logger to use structured output"
```

Select default remote environment with `/remote-env`.

#### Session Sharing

| Account type | Visibility options | Repository access verification |
|:-------------|:-------------------|:-------------------------------|
| Enterprise / Teams | Private, Team | Enabled by default |
| Max / Pro | Private, Public | Not enabled by default (configurable in Settings) |

#### Cloud Environment

**Default image includes:**

| Category | Pre-installed |
|:---------|:-------------|
| Languages | Python 3.x, Node.js LTS, Ruby 3.1/3.2/3.3, PHP 8.4, Java (OpenJDK), Go, Rust, C++ (GCC/Clang) |
| Databases | PostgreSQL 16, Redis 7.0 |
| Tools | pip, poetry, npm, yarn, pnpm, bun, gem, bundler, rbenv, Maven, Gradle, cargo |

Run `check-tools` inside a cloud session to see what is available.

#### Setup Scripts

Bash scripts that run when a new cloud session starts, before Claude Code launches. Run as root on Ubuntu 24.04.

```bash
#!/bin/bash
apt update && apt install -y gh
```

Setup scripts run only on new sessions (skipped on resume). Non-zero exit blocks session start; append `|| true` to non-critical commands.

#### Setup Scripts vs SessionStart Hooks

| | Setup scripts | SessionStart hooks |
|:--|:--------------|:-------------------|
| Attached to | Cloud environment | Repository (`.claude/settings.json`) |
| Runs | Before Claude Code, new sessions only | After Claude Code, every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Use `CLAUDE_CODE_REMOTE` environment variable to scope hook behavior to remote-only:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

#### Network Access Levels

| Level | Behavior |
|:------|:---------|
| Limited (default) | Allowlisted domains only (package registries, GitHub, cloud platforms, Anthropic services) |
| Full | Unrestricted internet access |
| No internet | No outbound access (Anthropic API still accessible) |

All outbound traffic passes through a security proxy. Some tools (e.g., Bun) have known proxy compatibility issues.

#### Session Management

- **Archive**: hover over session in sidebar, click archive icon
- **Delete**: filter for archived sessions then click delete, or use session dropdown menu (permanent, cannot be undone)

#### Security and Isolation

- Each session runs in an isolated, Anthropic-managed VM
- Git credentials handled through a secure proxy with scoped credentials
- Git push restricted to current working branch
- Code analyzed within isolated VMs before PR creation

#### Limitations

- GitHub only (no GitLab or other platforms for cloud sessions)
- Sessions can only move web-to-local when authenticated to the same account
- Rate limits shared with all Claude and Claude Code usage on the account

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- using `claude -p` for non-interactive execution, output formats (text, json, stream-json), JSON Schema constrained output (--json-schema), streaming responses with partial messages, api_retry events, auto-approving tools (--allowedTools with permission rule syntax and prefix matching), creating commits programmatically, customizing system prompts (--append-system-prompt, --system-prompt), continuing conversations (--continue, --resume with session IDs), links to Agent SDK Python/TypeScript packages
- [Claude Code on the web](references/claude-code-on-the-web.md) -- running cloud tasks from claude.ai/code, availability (Pro/Max/Team/Enterprise), getting started workflow, diff view for reviewing changes, terminal-to-web handoff (--remote, parallel tasks, plan-then-execute pattern, /remote-env), web-to-terminal handoff (--teleport, /teleport, /tp, /tasks), teleport requirements, session sharing (Enterprise/Teams team visibility, Max/Pro public visibility, repository access verification), archiving and deleting sessions, cloud environment (default image with languages/databases/tools, check-tools command), environment configuration, setup scripts (bash scripts before launch, vs SessionStart hooks comparison), dependency management (setup scripts, SessionStart hooks, CLAUDE_CODE_REMOTE, CLAUDE_ENV_FILE, proxy compatibility, limitations), network access and security (GitHub proxy, security proxy, access levels, default allowed domains by category), security isolation (isolated VMs, credential protection, scoped git credentials), pricing and rate limits, platform limitations, best practices

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
