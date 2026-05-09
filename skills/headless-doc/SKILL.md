---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically — the -p/--print flag (formerly "headless mode"), bare mode, output formats, streaming, tool approval, and Claude Code on the web (cloud sessions, environments, setup scripts, network access, web-to-terminal handoff).
user-invocable: false
---

# Headless / Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`-p` flag), and for using Claude Code on the web (cloud sessions).

## Quick Reference

### Non-interactive CLI (`-p` / `--print`)

The `-p` (or `--print`) flag runs Claude non-interactively. Previously called "headless mode."

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

**Key flags:**

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Run non-interactively; required for all CLI scripting |
| `--bare` | Skip hooks, skills, plugins, MCP, CLAUDE.md, auto-memory — use for reproducible CI runs |
| `--allowedTools` | Auto-approve specific tools (uses [permission rule syntax](/en/settings#permission-rule-syntax)) |
| `--permission-mode` | Set baseline: `dontAsk`, `acceptEdits`, `plan` |
| `--output-format` | `text` (default), `json`, or `stream-json` |
| `--json-schema` | JSON Schema for structured output (use with `--output-format json`) |
| `--include-partial-messages` | Stream partial tokens with `stream-json` |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Resume a specific conversation |
| `--append-system-prompt` | Add instructions without replacing the default system prompt |
| `--system-prompt` | Fully replace the default system prompt |

**Bare mode context flags** (when `--bare` is set, pass context explicitly):

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

Bare mode requires `ANTHROPIC_API_KEY` for authentication (skips OAuth/keychain).

### Output formats

| Format | Description |
| :--- | :--- |
| `text` | Plain text (default) |
| `json` | JSON with `result`, `session_id`, `total_cost_usd`, cost breakdown |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

Structured output: combine `--output-format json` with `--json-schema '{"type":"object",...}'`; result is in the `structured_output` field.

**stdin cap**: piped stdin is capped at 10 MB (since v2.1.128); use a file path for larger inputs.

### Streaming events (`stream-json`)

Use `--output-format stream-json --verbose --include-partial-messages`.

**`system/api_retry` event fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `"system"` | message type |
| `subtype` | `"api_retry"` | retry event identifier |
| `attempt` | integer | current attempt (starts at 1) |
| `max_retries` | integer | total retries permitted |
| `retry_delay_ms` | integer | ms until next attempt |
| `error_status` | integer or null | HTTP status code |
| `error` | string | `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |

**`system/init` event** — first event in the stream; reports model, tools, MCP servers, loaded plugins:

| Field | Type | Description |
| :--- | :--- | :--- |
| `plugins` | array | plugins loaded successfully, each with `name` and `path` |
| `plugin_errors` | array | load-time errors with `plugin`, `type`, `message`; omitted when empty |

**`system/plugin_install` event** (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set):

| Field | Type | Description |
| :--- | :--- | :--- |
| `status` | string | `started`, `installed`, `failed`, or `completed` |
| `name` | string (optional) | marketplace name (on `installed`/`failed`) |
| `error` | string (optional) | failure message (on `failed`) |

### Auto-approve tools

```bash
claude -p "Run the test suite and fix any failures" \
  --allowedTools "Bash,Read,Edit"
```

Permission modes: `dontAsk` denies anything not in allow rules or read-only set; `acceptEdits` lets Claude write files and auto-approves common filesystem commands (`mkdir`, `touch`, `mv`, `cp`).

Prefix matching example — `Bash(git diff *)` allows any command starting with `git diff ` (space before `*` matters):

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

### Continue conversations

```bash
# Continue the most recent session
claude -p "Now focus on database queries" --continue

# Capture session ID and resume later
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

---

### Claude Code on the web — Overview

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist when you close the browser and can be monitored from the Claude mobile app.

**Comparison table:**

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| Uses local config | No, repo only | Yes | Yes | Yes for local, no for cloud |
| Keeps running if disconnected | Yes | While terminal stays open | No | Depends |
| Permission modes | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends |

### GitHub authentication for cloud sessions

| Method | How | Best for |
| :--- | :--- | :--- |
| GitHub App | Install Claude GitHub App during web onboarding | Teams wanting per-repo authorization |
| `/web-setup` | Sync local `gh` CLI token to Claude account | Developers already using `gh` |

The GitHub App is required for Auto-fix (PR webhooks).

### Cloud environment

**What's available in cloud sessions (from the repo clone):**

| Item | Available | Why |
| :--- | :--- | :--- |
| Repo `CLAUDE.md` | Yes | Part of clone |
| `.claude/settings.json` hooks | Yes | Part of clone |
| `.mcp.json` MCP servers | Yes | Part of clone |
| `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of clone |
| Plugins in `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| Plugins in user settings | No | User-scoped settings not available |
| MCP servers added with `claude mcp add` | No | Written to local user config |
| Static API tokens / credentials | No | No dedicated secrets store yet |

**Pre-installed tools by category:**

| Category | Included |
| :--- | :--- |
| Python | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun, eslint, prettier, chromedriver |
| Ruby | 3.1, 3.2, 3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven, Gradle |
| Go | latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

**Resource limits:** 4 vCPUs, 16 GB RAM, 30 GB disk.

**Session URL from within a session:**
```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

### Setup scripts vs. SessionStart hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches, when no cached env | After Claude Code launches, every session including resumed |
| Scope | Cloud only | Both local and cloud |

Setup scripts run as root on Ubuntu 24.04. Cache is rebuilt after ~7 days or when script/network settings change.

**Skip in local sessions** using `CLAUDE_CODE_REMOTE`:
```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

### Network access levels

| Level | Outbound connections |
| :--- | :--- |
| None | No outbound access |
| Trusted | Allowlisted domains: package registries, GitHub, cloud SDKs |
| Full | Any domain |
| Custom | Your own allowlist, optionally with Trusted defaults |

GitHub operations always use a separate GitHub proxy (independent of this setting).

### Move tasks between web and terminal

**Terminal to web:**
```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```
- Creates a new cloud session on claude.ai; clones from GitHub at current branch
- Push local commits first; `--remote` clones from GitHub, not your machine
- Parallel tasks: each `--remote` call creates an independent session
- Local bundle fallback (no GitHub): auto-activates; force with `CCR_FORCE_BUNDLE=1`

Bundle limits: must be a git repo, under 100 MB; untracked files not included.

**Web to terminal (teleport):**
```bash
claude --teleport              # interactive picker
claude --teleport <session-id> # resume specific session
```
Also: `/teleport` (or `/tp`) inside an existing CLI session, or `/tasks` then press `t`.

Teleport requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account.

### Auto-fix pull requests

Requires the Claude GitHub App. Turn on via:
- Web UI: open CI status bar → **Auto-fix**
- Terminal: run `/autofix-pr` while on the PR branch
- Mobile app or any session: paste the PR URL and ask Claude to auto-fix

Claude acts on CI failures and review comments: confident fixes are pushed automatically; ambiguous requests prompt you first. Replies to review threads are posted under your GitHub username but labeled as Claude Code.

### Context management in cloud sessions

| Command | Works | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Accepts optional focus instructions |
| `/context` | Yes | Shows current context window |
| `/clear` | No | Start a new session from the sidebar |

Auto-compaction env vars: `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (default ~95%), `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

Agent teams: off by default; enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `-p` flag, bare mode, output formats, streaming events, tool approval, conversation continuation
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — environments, setup scripts, network access, GitHub auth, teleport, auto-fix, session management, security, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart: connect GitHub, create an environment, submit a task, review and iterate

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
