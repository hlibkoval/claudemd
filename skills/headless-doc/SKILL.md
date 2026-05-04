---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically and in the cloud — the Agent SDK CLI (-p flag), bare mode, structured output, streaming, auto-approving tools, continuing conversations, and Claude Code on the web (cloud sessions, environments, setup scripts, network access, teleport, auto-fix PRs).
user-invocable: false
---

# Headless and Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the Agent SDK CLI and using Claude Code on the web (cloud sessions).

## Quick Reference

### Run Claude Code Non-Interactively

```bash
# Basic non-interactive call
claude -p "What does the auth module do?"

# Bare mode (recommended for CI/scripts — skips auto-discovery of hooks, plugins, MCP, CLAUDE.md)
claude --bare -p "Summarize this file" --allowedTools "Read"

# Pipe data in, redirect response out
cat build-error.txt | claude -p "explain the root cause" > output.txt
```

The `-p` / `--print` flag runs Claude non-interactively. `--bare` skips all local config discovery and requires `ANTHROPIC_API_KEY` for auth (no OAuth/keychain reads). `--bare` will become the default for `-p` in a future release.

### Bare Mode Context Flags

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

### Output Formats

| Flag | Behavior |
| :--- | :--- |
| `--output-format text` | Plain text (default) |
| `--output-format json` | JSON with `result`, `session_id`, cost metadata |
| `--output-format stream-json` | Newline-delimited JSON events for real-time streaming |

```bash
# JSON output, extract result with jq
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Structured output conforming to a schema
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}' \
  | jq '.structured_output'

# Streaming — filter text deltas
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### stream-json System Events

| Event subtype | Key fields | Purpose |
| :--- | :--- | :--- |
| `system/init` | `plugins`, `plugin_errors` | Session metadata; use `plugin_errors` to fail CI on bad plugin loads |
| `system/api_retry` | `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` | Retry progress |
| `system/plugin_install` | `status` (`started`/`installed`/`failed`/`completed`), `name`, `error` | Plugin install events (requires `CLAUDE_CODE_SYNC_PLUGIN_INSTALL`) |

### Auto-Approve Tools and Permission Modes

```bash
# Allow specific tools
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"

# Permission modes
claude -p "Apply lint fixes" --permission-mode acceptEdits
# acceptEdits: auto-approves file writes + mkdir/touch/mv/cp; other shell still needs allowedTools
# dontAsk: denies anything not in permissions.allow or read-only command set

# Scoped Bash permissions (trailing " *" = prefix match)
claude -p "Create a commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

### Continue and Resume Conversations

```bash
# Continue most recent conversation
claude -p "Review for performance issues"
claude -p "Focus on database queries" --continue
claude -p "Generate a summary" --continue

# Resume a specific session by ID
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Customize the System Prompt

```bash
# Append instructions (keeps Claude Code defaults)
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json

# Fully replace the system prompt: use --system-prompt (see CLI reference)
```

---

### Claude Code on the Web — Cloud Sessions

Sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist across devices; monitor from the Claude mobile app.

#### Start a Cloud Session from the Terminal

```bash
# Create a new cloud session for the current repo
claude --remote "Fix the authentication bug in src/auth/login.ts"

# Check progress of background sessions
/tasks

# Force bundle upload (no GitHub required)
CCR_FORCE_BUNDLE=1 claude --remote "Run the test suite and fix any failures"
```

`--remote` clones your current branch from GitHub; push local commits first. Sessions for repos without GitHub are automatically bundled (100 MB limit; untracked files not included).

#### Teleport a Cloud Session to Your Terminal

```bash
# Interactive session picker
claude --teleport

# Resume a specific cloud session
claude --teleport <session-id>

# From inside a running session
/teleport   # or /tp

# From /tasks: press t to teleport
```

Teleport requirements: clean working directory, same repo (not a fork), branch pushed to remote, same claude.ai account.

#### GitHub Authentication for Cloud Sessions

| Method | How it works | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install Claude App on specific repos during web onboarding | Teams needing per-repo authorization |
| **`/web-setup`** | Syncs local `gh` CLI token to Claude account | Individuals already using `gh` |

GitHub App is required for Auto-fix PRs. Admins can disable `/web-setup` at claude.ai/admin-settings/claude-code.

#### Cloud Environment Configuration

| Action | How |
| :--- | :--- |
| Add environment | Web UI: select current environment → Add environment |
| Edit environment | Web UI: settings icon next to environment name |
| Set default for `--remote` | `/remote-env` in terminal |

Environment variables use `.env` format (`KEY=value`, no quotes around values).

#### Installed Tools in Cloud Sessions

| Category | Included |
| :--- | :--- |
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun, eslint, prettier |
| Ruby | 3.1/3.2/3.3, gem, bundler, rbenv |
| PHP | 8.4, Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

Resource limits: ~4 vCPUs, 16 GB RAM, 30 GB disk.

#### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches; cached after first run | After Claude Code launches, every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Setup scripts are cached after first run; cache rebuilt when script or network hosts change, or after ~7 days. Use `CLAUDE_CODE_REMOTE=true` in SessionStart hooks to skip local execution.

#### Network Access Levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound network |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist (`*.` for wildcard); optionally include Trusted defaults |

GitHub operations use a separate secure proxy independent of this setting.

#### Auto-Fix Pull Requests

Enable auto-fix so Claude monitors a PR and responds to CI failures and review comments automatically:

```bash
# From terminal (on the PR's branch)
/autofix-pr
```

Or enable from the web CI status bar, mobile app, or by pasting the PR URL into a session. Requires the Claude GitHub App installed on the repository.

#### Session Management Commands in Cloud

| Command | Works | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Summarizes conversation; accepts focus instructions |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

Link a session's transcript using `CLAUDE_CODE_REMOTE_SESSION_ID` env var: `https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID}`

#### Pre-fill Sessions via URL Parameters

| Parameter | Description |
| :--- | :--- |
| `prompt` (alias `q`) | Prefill the input box |
| `prompt_url` | URL to fetch long prompt text from |
| `repositories` (alias `repo`) | Comma-separated `owner/repo` slugs |
| `environment` | Environment name or ID |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — Agent SDK CLI (`-p` flag), bare mode, piping data, structured output, streaming with `stream-json`, auto-approving tools, permission modes, creating commits, customizing system prompts, and continuing conversations
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environment setup, installed tools, setup scripts, environment caching, SessionStart hooks, network access levels, GitHub/security proxies, default allowed domains, moving tasks between web and terminal (`--remote`, `--teleport`), session management, auto-fix PRs, security/isolation, and limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart walkthrough: connecting GitHub, creating environments, starting tasks, reviewing diffs, leaving inline comments, creating PRs, and troubleshooting setup

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
