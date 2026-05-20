---
name: headless-doc
user-invocable: false
---

# Headless / Claude Code on the Web Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (headless/programmatic mode via `claude -p`) and using Claude Code on the web (cloud sessions at claude.ai/code).

## Quick Reference

### Headless / programmatic mode (`claude -p`)

| Flag | Purpose |
| :--- | :--- |
| `-p` / `--print` | Run non-interactively; print response and exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md — recommended for CI |
| `--output-format text\|json\|stream-json` | Control response format (default: `text`) |
| `--json-schema <schema>` | Return structured output conforming to a JSON Schema (placed in `structured_output` field) |
| `--verbose --include-partial-messages` | Stream tokens as they arrive with `stream-json` |
| `--allowedTools <list>` | Auto-approve specific tools (e.g. `"Read,Edit,Bash"`) |
| `--permission-mode <mode>` | `acceptEdits` or `dontAsk` baseline for the session |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Resume a specific conversation |
| `--append-system-prompt <text>` | Add instructions while keeping Claude's default system prompt |
| `--append-system-prompt-file <path>` | Same but reads from a file |
| `--system-prompt <text>` | Fully replace the default system prompt |
| `--settings <file-or-json>` | Load settings from a file or inline JSON |
| `--mcp-config <file-or-json>` | Load MCP servers |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin from a local directory |
| `--plugin-url <url>` | Load a plugin from a marketplace URL |

#### Output format shapes

| Format | `result` field | Extra fields |
| :--- | :--- | :--- |
| `text` | Plain text on stdout | — |
| `json` | Text response string | `session_id`, `total_cost_usd`, per-model cost breakdown |
| `json` + `--json-schema` | — | `structured_output` (schema-conforming object), `session_id`, usage |
| `stream-json` | Newline-delimited JSON events | Use `--verbose --include-partial-messages` for token streaming |

#### Bare mode context loading

When `--bare` is used, Claude only has access to what you pass explicitly:

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

Auth in bare mode: must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON. OAuth/keychain reads are skipped.

#### Stdin and pipe limits

- Piped stdin is capped at **10 MB** (as of v2.1.128). Exceed it → non-zero exit. Use a file path instead.
- `--output-format json` includes `total_cost_usd` per invocation.

#### `stream-json` retry events (`system/api_retry`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `"system"` | message type |
| `subtype` | `"api_retry"` | identifies this event |
| `attempt` | integer | current attempt, starting at 1 |
| `max_retries` | integer | total retries permitted |
| `retry_delay_ms` | integer | ms until next attempt |
| `error_status` | integer or null | HTTP status, or null for connection errors |
| `error` | string | category: `authentication_failed`, `rate_limit`, `server_error`, etc. |

#### `system/init` event (first stream event)

| Field | Type | Description |
| :--- | :--- | :--- |
| `plugins` | array | successfully loaded plugins (name, path) |
| `plugin_errors` | array | load-time errors (plugin, type, message); key omitted when none |

Set `CLAUDE_CODE_SYNC_PLUGIN_INSTALL=1` to emit `system/plugin_install` events before the first turn.

### Claude Code on the web (cloud sessions)

#### Ways to run Claude Code — comparison

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| **Code runs on** | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| **You chat from** | claude.ai or mobile | claude.ai or mobile | Your terminal | Desktop UI |
| **Uses local config** | No, repo only | Yes | Yes | Yes for local, No for cloud |
| **Requires GitHub** | Yes (or bundle via `--remote`) | No | No | Only for cloud sessions |
| **Persists if disconnected** | Yes | While terminal open | No | Depends |
| **Permission modes** | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends |

#### GitHub authentication options

| Method | How | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install via browser onboarding at claude.ai/code | Teams; required for Auto-fix PR |
| **`/web-setup`** | Run in CLI — syncs local `gh` token to Claude account | Developers already using `gh` CLI |

#### Cloud environment: what's available

| Item | Available | Why |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start from marketplace |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| Plugins only in user settings | No | Declare in repo's `.claude/settings.json` instead |
| MCP servers added with `claude mcp add` | No | Declare in `.mcp.json` instead |
| Static API tokens / credentials | No | No secrets store yet; use env vars (visible to env editors) |
| Interactive auth (AWS SSO, etc.) | No | Not supported |

#### Pre-installed tools in cloud sessions

| Category | Included |
| :--- | :--- |
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun*, eslint, prettier, chromedriver |
| Ruby | 3.1–3.3, gem, bundler, rbenv |
| PHP | 8.4, Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

*Bun has known proxy compatibility issues for package fetching.

Run `check-tools` inside a cloud session for exact versions.

#### Network access levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** | Default allowlist: package registries, GitHub, cloud SDKs |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including defaults |

Use `*.` prefix for wildcard subdomain matching in Custom mode. GitHub operations always go through a separate dedicated proxy regardless of this setting.

#### Resource limits (approximate, may change)

- 4 vCPUs, 16 GB RAM, 30 GB disk

#### Setup scripts vs. SessionStart hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches (cached) | After Claude launch, every session including resumed |
| Scope | Cloud only | Local and cloud |

Setup script tips: keep total runtime under ~5 minutes (enables environment caching); run independent installs in parallel with `&` and `wait`; append `|| true` to non-critical commands.

Check `CLAUDE_CODE_REMOTE=true` in hooks to skip local execution. Persist env vars for subsequent Bash commands by writing to `$CLAUDE_ENV_FILE`.

#### Terminal ↔ web session handoff

| Action | Command |
| :--- | :--- |
| Start a new cloud session from terminal | `claude --remote "task description"` |
| Pull a cloud session to terminal (interactive picker) | `claude --teleport` |
| Pull a specific cloud session | `claude --teleport <session-id>` |
| Pick from background sessions | `/tasks` then press `t` |
| Check progress of background sessions | `/tasks` in CLI |
| Set default environment for `--remote` | `/remote-env` in CLI |

`--remote` clones from GitHub at the current branch — push local commits first. Force bundle upload (no GitHub needed): `CCR_FORCE_BUNDLE=1 claude --remote "..."`.

Teleport requirements: clean git state, correct repository (not a fork), branch must be pushed to remote, same claude.ai account.

#### Session URL from inside cloud session

```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

#### Auto-fix pull requests

Requires the Claude GitHub App installed on the repository. Enable via:
- Web: open CI status bar → **Auto-fix**
- Terminal: `/autofix-pr` on the PR's branch
- Mobile: tell Claude "watch this PR and fix CI failures or review comments"
- Any session: paste PR URL and ask Claude to auto-fix it

Claude pushes clear fixes automatically; asks before acting on ambiguous or architectural changes. Replies on review threads appear under your GitHub username, labeled as coming from Claude Code.

#### Context management in cloud sessions

| Command | Works | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Optional focus: `/compact keep the test output` |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from sidebar instead |

Auto-compaction triggers at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=<pct>`. Adjust effective window for compaction with `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

#### Pre-fill session URL parameters

| Parameter | Description |
| :--- | :--- |
| `prompt` (alias `q`) | Prefill prompt text |
| `prompt_url` | URL to fetch prompt from (must allow CORS); ignored if `prompt` is set |
| `repositories` (alias `repo`) | Comma-separated `owner/repo` slugs to preselect |
| `environment` | Name or ID of environment to preselect |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — Headless mode via `claude -p`: basic usage, bare mode, piping, structured output, streaming, tool approval, system prompt customization, conversation continuation
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Full reference for cloud sessions: GitHub auth, cloud environment, setup scripts, network access, session handoff (`--remote`, `--teleport`), auto-fix PRs, security, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — Quickstart walkthrough: connecting GitHub, creating environments, submitting tasks, reviewing diffs, creating PRs, troubleshooting setup

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
