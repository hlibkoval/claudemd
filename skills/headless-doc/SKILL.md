---
name: headless-doc
description: Complete documentation for running Claude Code non-interactively (the `-p`/`--print` CLI "headless" mode) and for Claude Code on the web (cloud sessions at claude.ai/code). Covers bare mode, structured and streaming output, auto-approval flags, session continuation, GitHub connection, cloud environments, setup scripts, network access levels, `--remote`/`--teleport`, auto-fix PRs, and cloud session limits.
user-invocable: false
---

# Headless & Claude Code on the Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically (the `-p` "headless" CLI mode) and for Claude Code on the web (cloud sessions on Anthropic-managed VMs).

## Quick Reference

### Headless mode (`claude -p`)

Run Claude Code non-interactively by passing a prompt with `-p` / `--print`. All CLI options work with `-p`. The CLI was previously called "headless mode."

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

For programmatic control with structured outputs, approval callbacks, and message objects, use the Python or TypeScript Agent SDK packages instead.

### Key `-p` flags

| Flag | Purpose |
|------|---------|
| `-p` / `--print` | Run non-interactively with the given prompt |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, auto-memory, and CLAUDE.md. Recommended for CI/scripts. Will become default for `-p` in a future release |
| `--output-format` | `text` (default), `json`, or `stream-json` |
| `--json-schema` | With `--output-format json`, constrains output to a JSON Schema. Result appears in the `structured_output` field |
| `--verbose` | Required with `stream-json` for streaming events |
| `--include-partial-messages` | Stream token-level deltas with `stream-json` |
| `--allowedTools` | Pre-approve tools without prompting (uses permission rule syntax) |
| `--permission-mode` | Session-wide baseline, e.g. `acceptEdits`, `dontAsk`, `plan` |
| `--append-system-prompt` / `--append-system-prompt-file` | Add to Claude Code's default system prompt |
| `--system-prompt` | Fully replace the default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific conversation by ID |
| `--settings <file-or-json>` | Load settings in bare mode |
| `--mcp-config <file-or-json>` | Load MCP servers in bare mode |
| `--agents <json>` | Load custom agents in bare mode |
| `--plugin-dir <path>` | Load a plugin directory in bare mode |

### Bare mode notes

- Bare mode skips OAuth and keychain reads. Auth must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in `--settings` JSON. Bedrock, Vertex, and Foundry use their own provider credentials.
- In bare mode Claude has access to Bash, file read, and file edit tools by default. Pass any additional context explicitly.
- User-invoked skills like `/commit` and built-in slash commands are only available in interactive mode. In `-p` mode, describe the task in the prompt instead.

### Output formats

| Format | Description |
|--------|-------------|
| `text` | Plain text output (default) |
| `json` | Structured JSON with `result`, `session_id`, usage, and metadata. With `--json-schema`, conforming output is in `structured_output` |
| `stream-json` | Newline-delimited JSON events for real-time streaming (requires `--verbose`) |

### `system/api_retry` event (stream-json)

Emitted when an API request fails with a retryable error before Claude Code retries.

| Field | Type | Description |
|-------|------|-------------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Identifies the retry event |
| `attempt` | integer | Current attempt number, starting at 1 |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |
| `uuid` | string | Unique event identifier |
| `session_id` | string | Session the event belongs to |

### Common `-p` patterns

```bash
# Structured JSON output
claude -p "Summarize this project" --output-format json | jq -r '.result'

# JSON with schema constraint
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'

# Streaming text deltas
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'

# Auto-approve specific tools (permission rule syntax with prefix matching)
claude -p "Commit staged changes" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"

# Session-wide permission baseline
claude -p "Apply lint fixes" --permission-mode acceptEdits

# Continue conversations
claude -p "Review this codebase" --continue
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

Note on `--allowedTools` syntax: `Bash(git diff *)` uses prefix matching. The space before `*` matters: `Bash(git diff*)` (no space) would also match `git diff-index`.

## Claude Code on the web

Runs Claude Code on an Anthropic-managed cloud VM at [claude.ai/code](https://claude.ai/code) or in the Claude mobile app. A GitHub repository is cloned into an isolated VM; Claude makes changes and pushes a branch for review. Sessions persist across devices.

Research preview for Pro, Max, Team, and Enterprise users with premium or Chat + Claude Code seats. Zero Data Retention orgs cannot use cloud session features.

### Session lifecycle

1. **Clone and prepare** - repo cloned to VM, setup script runs
2. **Configure network** - based on environment access level
3. **Work** - Claude analyzes, edits, runs tests; you can watch/steer or step away
4. **Push branch** - Claude pushes when it reaches a stopping point; the session stays live for review, PR creation, and follow-ups

### Ways to run Claude Code

|  | On the web | Remote Control | Terminal CLI | Desktop app |
|---|---|---|---|---|
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Local or cloud VM |
| You chat from | claude.ai / mobile | claude.ai / mobile | Terminal | Desktop UI |
| Uses local config | No, repo only | Yes | Yes | Yes local, no cloud |
| Requires GitHub | Yes (or `--remote` bundle) | No | No | Cloud only |
| Keeps running if disconnected | Yes | While terminal open | No | Depends |
| Permission modes | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends |
| Network access | Configurable | Your machine | Your machine | Depends |

### GitHub authentication options

| Method | How it works | Best for |
|--------|--------------|----------|
| GitHub App | Install the Claude GitHub App per repository via web onboarding | Teams wanting explicit per-repo auth |
| `/web-setup` | Run in Claude Code CLI to sync local `gh` CLI token to your Claude account | Developers already using `gh` |

The GitHub App is required for Auto-fix (uses webhooks). Team/Enterprise admins can disable `/web-setup` via the **Quick web setup** toggle at `claude.ai/admin-settings/claude-code`.

### What's available in cloud sessions

| | Available | Why |
|---|---|---|
| Repo `CLAUDE.md` | Yes | Part of the clone |
| Repo `.claude/settings.json` hooks | Yes | Part of the clone |
| Repo `.mcp.json` MCP servers | Yes | Part of the clone |
| Repo `.claude/rules/` | Yes | Part of the clone |
| Repo `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start from the marketplace |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| Plugins enabled only in user settings | No | Declare in the repo's `.claude/settings.json` instead |
| MCP servers added with `claude mcp add` | No | Declare in repo's `.mcp.json` instead |
| Static API tokens and credentials | No | No dedicated secrets store yet |
| Interactive auth like AWS SSO | No | Requires browser-based login |

### Pre-installed tools in cloud sessions

| Category | Included |
|----------|----------|
| Python | 3.x with pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun, eslint, prettier, chromedriver |
| Ruby | 3.1, 3.2, 3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven and Gradle |
| Go | Latest stable with module support |
| Rust | rustc and cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

Ask Claude to run `check-tools` in a cloud session for exact versions. `gh` CLI is NOT pre-installed; install via setup script and provide `GH_TOKEN`.

### Resource limits (approximate)

- 4 vCPUs
- 16 GB RAM
- 30 GB disk

### Network access levels

| Level | Outbound connections |
|-------|---------------------|
| None | No outbound access |
| Trusted | Allowlisted domains only: package registries, GitHub, cloud SDKs (default) |
| Full | Any domain |
| Custom | Your own allowlist, optionally including defaults |

GitHub operations use a separate proxy independent of the access level. All outbound traffic passes through a security proxy. Bun has known proxy compatibility issues for package fetching. The Trusted allowlist covers anthropic services, GitHub/GitLab/Bitbucket, container registries, cloud platforms (GCP/Azure/AWS/Oracle), npm/PyPI/RubyGems/crates.io/Go/Maven/Gradle/NuGet/pub.dev/hex.pm/CPAN/cocoapods/haskell/swift, Ubuntu/NixOS, k8s, HashiCorp, Anaconda, Apache, Eclipse, Node.js, Apple/Android developer sites, sentry, datadog, honeycomb, Model Context Protocol, JSON Schema, and more.

Custom allowlists support `*.` wildcard subdomain matching. Check **Also include default list of common package managers** to keep Trusted defaults alongside custom entries.

### Setup scripts vs SessionStart hooks

| | Setup scripts | SessionStart hooks |
|---|---|---|
| Attached to | The cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches, on NEW sessions only | After Claude Code launches, on every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Setup scripts run as root on Ubuntu 24.04. If a setup script exits non-zero, the session fails to start; append `|| true` to non-critical commands. The `CLAUDE_CODE_REMOTE=true` env var is set in cloud sessions so hooks can skip local execution. Persist env vars for subsequent Bash commands by writing to `$CLAUDE_ENV_FILE`.

### Move tasks between web and terminal

| Flag/command | Direction | Purpose |
|--------------|-----------|---------|
| `claude --remote "..."` | Terminal to web | Create a new cloud session from the current repo at the current branch. Single repo at a time. Runs in background while you work locally |
| `/tasks` | Both | Monitor background cloud sessions from the CLI |
| `claude --teleport` / `claude --teleport <id>` | Web to terminal | Interactive picker or direct resume of a cloud session; fetches and checks out the branch |
| `/teleport` or `/tp` | Web to terminal | Same as `--teleport` but inside an existing CLI session |
| `--remote-control` | Unrelated | Exposes a LOCAL CLI session for monitoring from the web. See Remote Control docs |

`--remote` without GitHub auth falls back to bundling the local repo (full history, tracked files; <100 MB, with fallbacks). Force bundle with `CCR_FORCE_BUNDLE=1`. Bundled sessions cannot push back without GitHub auth. `--teleport` requires claude.ai subscription auth, clean git state, correct repo (not a fork), and that the cloud branch has been pushed to the remote. `--teleport` differs from `--resume`: `--resume` reopens local history only, `--teleport` pulls a cloud session with its branch.

Session handoff from CLI is one-way: `--teleport` pulls web to terminal, but there's no CLI push from terminal to web. The Desktop app's "Continue in" menu can send a local session to the web.

### Context management in cloud sessions

| Command | Works | Notes |
|---------|-------|-------|
| `/compact` | Yes | Summarizes to free context; accepts focus instructions |
| `/context` | Yes | Shows what's in the context window |
| `/clear` | No | Start a new session from the sidebar |

Interactive commands like `/model` or `/config` are not available in cloud sessions. Use `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to trigger auto-compaction earlier. Subagents work the same as locally. Agent teams are off by default; enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

### Sharing sessions

- **Enterprise / Team**: Private or Team (visible to org members). Repo access verification on by default. Claude in Slack sessions default to Team visibility.
- **Max / Pro**: Private or Public (any claude.ai user). Repo access verification OFF by default - check for sensitive content first.

Configure at **Settings > Claude Code > Sharing settings**.

### Auto-fix pull requests

Requires the Claude GitHub App. Claude subscribes to PR events (CI failures, review comments) and responds:

- **Clear fixes**: makes the change, pushes, explains in the session
- **Ambiguous requests**: asks before acting
- **Duplicates / no-op**: notes and moves on

Claude replies to review comment threads under your GitHub username but labeled as coming from Claude Code. Enable via:
- **PRs from the web**: CI status bar > **Auto-fix**
- **From terminal**: run `/autofix-pr` on the PR branch
- **From mobile**: tell Claude to auto-fix the PR
- **Any existing PR**: paste the URL and ask Claude to auto-fix

Warning: if your repo uses comment-triggered automation (Atlantis, Terraform Cloud, custom GitHub Actions on `issue_comment`), auto-fix replies can trigger those workflows.

### Security and isolation

- Isolated Anthropic-managed VMs per session
- Network access restricted by default (Claude can still reach the Anthropic API even with network disabled)
- Sensitive credentials (git, signing keys) never enter the sandbox; handled via a secure proxy with scoped credentials
- Code is analyzed and modified in isolated VMs before PR creation

### Limitations

- Rate limits are shared with all Claude/Claude Code usage on the account (parallel tasks consume proportionately more); no separate VM compute charge
- Move sessions web-to-local only when authenticated to the same account
- Repo cloning and PR creation require GitHub. GitHub Enterprise Server is supported for Team/Enterprise. GitLab, Bitbucket, and other non-GitHub repos can be sent via local bundle but cannot push back
- Custom environment images and snapshots are not yet supported

### Troubleshooting highlights

- **No repos after connecting**: check GitHub App repo access at Settings > Applications > Claude > Configure
- **"Not available for the selected organization"**: Enterprise admin must enable
- **`/web-setup` returns "Unknown command"**: run inside the Claude Code CLI, not the shell; requires CLI v2.1.80+ and claude.ai subscription auth (not API key / third-party provider)
- **"No cloud environment available" for `--remote`**: run `/web-setup` in the CLI or create an environment at claude.ai/code
- **Setup script failed**: add `set -x`, append `|| true` to non-critical commands; check that registries are in the network access level

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) - The `-p` CLI (formerly "headless mode"), bare mode, output formats, streaming, auto-approval, system prompts, conversation continuation
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) - Connecting GitHub, creating a cloud environment, submitting tasks, reviewing diffs, creating PRs, troubleshooting setup
- [Use Claude Code on the web](references/claude-code-on-the-web.md) - Full reference: environments, installed tools, setup scripts, network access, `--remote`/`--teleport`, auto-fix PRs, session management, security, limits

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
