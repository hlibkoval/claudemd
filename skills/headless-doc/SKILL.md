---
name: headless-doc
description: Complete official Claude Code documentation for non-interactive (headless) CLI usage with `claude -p`, plus Claude Code on the web — running cloud sessions from claude.ai/code, cloud environment configuration, setup scripts, and network access.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code non-interactively from the CLI (`claude -p`) and for running Claude Code in the cloud via claude.ai/code.

## Quick Reference

### Headless mode basics

Add `-p` (or `--print`) to `claude` to run non-interactively. Was previously called "headless mode"; the CLI naming changed but flags are unchanged.

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

### Key CLI flags for `-p`

| Flag | Purpose |
|---|---|
| `-p` / `--print` | Run non-interactively, print result, exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for CI/SDK) |
| `--output-format` | `text` (default), `json`, or `stream-json` |
| `--json-schema` | JSON Schema for structured output (with `--output-format json`) |
| `--verbose` | Required with `stream-json` |
| `--include-partial-messages` | Stream tokens as they're generated |
| `--allowedTools` | Comma-separated tool list to auto-approve, supports `Bash(git diff *)` rule syntax |
| `--permission-mode` | Session-wide mode: `dontAsk`, `acceptEdits`, etc. |
| `--append-system-prompt` / `--append-system-prompt-file` | Add to default system prompt |
| `--system-prompt` | Replace default system prompt entirely |
| `--continue` | Continue most recent conversation |
| `--resume <session-id>` | Continue specific session |
| `--settings` | Pass settings file or JSON |
| `--mcp-config` | Pass MCP server config |
| `--agents` | Pass custom agents JSON |
| `--plugin-dir` | Load a plugin directory |

### Output formats

| Format | Description |
|---|---|
| `text` | Plain text result (default) |
| `json` | Single JSON object with `result`, `session_id`, usage, plus `structured_output` when `--json-schema` is set |
| `stream-json` | Newline-delimited JSON events; use with `--verbose --include-partial-messages` |

### Bare mode notes

`--bare` skips hooks, skills, plugins, MCP servers, auto memory, CLAUDE.md, OAuth, and keychain reads. Only flags you pass take effect. Anthropic auth must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in `--settings` JSON. Bedrock/Vertex/Foundry use their normal provider credentials. Recommended for CI; will become the `-p` default in a future release.

### `system/api_retry` event fields (stream-json)

| Field | Type | Notes |
|---|---|---|
| `type` | `"system"` | |
| `subtype` | `"api_retry"` | |
| `attempt` | int | starting at 1 |
| `max_retries` | int | total retries permitted |
| `retry_delay_ms` | int | ms until next attempt |
| `error_status` | int or null | HTTP status, or null for connection errors |
| `error` | string | `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `uuid`, `session_id` | string | |

### Claude Code on the web

Submit tasks at [claude.ai/code](https://claude.ai/code). Each task runs in an Anthropic-managed Ubuntu 24.04 VM with the repo cloned, then pushes a branch to GitHub for review. Sessions persist across devices and survive disconnects.

| Aspect | Web sessions |
|---|---|
| Code runs on | Anthropic cloud VM |
| Chat from | claude.ai or mobile app |
| Local config available | No, repo only |
| Requires GitHub | Yes (or `--remote` to bundle a local repo) |
| Permission modes | Auto accept edits, Plan |
| Network | Configurable per environment |

### Web setup paths

| Method | How |
|---|---|
| Browser onboarding | Visit claude.ai/code, install Claude GitHub App per-repo |
| `/web-setup` | Run inside `claude` CLI; syncs local `gh` token, creates default environment |

GitHub App is required for Auto-fix PRs. ZDR-enabled orgs cannot use cloud sessions.

### Cloud environment fields

| Field | Description |
|---|---|
| Name | Display label |
| Network access | `None`, `Trusted` (default; allowlisted package registries + GitHub + cloud SDKs), `Full`, `Custom` (with allowlist + optional defaults toggle) |
| Environment variables | `.env` format, `KEY=value`, no quotes; visible to environment editors |
| Setup script | Bash script run as root before Claude Code launches; only on new sessions, not resumes |

### What carries into cloud sessions

| Carried over | Not carried over |
|---|---|
| Repo `CLAUDE.md` | User `~/.claude/CLAUDE.md` |
| Repo `.claude/settings.json` hooks | User-scoped `enabledPlugins` |
| Repo `.mcp.json` | `claude mcp add` (writes to user config) |
| Repo `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Static API tokens / interactive auth (AWS SSO) |
| Plugins declared in repo settings (installed at session start from marketplace) | |

### Pre-installed cloud tools (highlights)

Python 3.x (pip, poetry, uv, black, mypy, pytest, ruff); Node 20/21/22 via nvm (npm, yarn, pnpm, bun, eslint, prettier); Ruby 3.1-3.3; PHP 8.4 + Composer; OpenJDK 21 (Maven, Gradle); Go; Rust; GCC/Clang/cmake/ninja/conan; Docker + compose; PostgreSQL 16 and Redis 7.0 (not auto-started); git, jq, yq, ripgrep, tmux, vim, nano. The `gh` CLI is NOT pre-installed. Run `check-tools` (cloud only) for exact versions.

### Resource limits

Approximate per session: 4 vCPUs, 16 GB RAM, 30 GB disk.

### Setup scripts vs. SessionStart hooks

| | Setup scripts | SessionStart hooks |
|---|---|---|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code, new sessions only | After Claude Code, every session including resumes |
| Scope | Cloud only | Local + cloud |

In cloud sessions, set `CLAUDE_CODE_REMOTE=true`; check it in hooks to skip local execution. Only repo-committed hooks run in the cloud (not user-level `~/.claude/settings.json`).

### Network proxies

All outbound traffic passes through a security proxy (rate limiting, content filtering). GitHub operations use a separate GitHub proxy that rewrites scoped credentials to your real token and restricts pushes to the current working branch. Bun has known proxy compatibility issues for package fetching.

### Useful related commands

| Command | Purpose |
|---|---|
| `/web-setup` | Sync `gh` token, create default cloud environment |
| `/remote-env` | View / set default environment for `--remote` |
| `--remote` | Start a cloud session from your terminal |
| `--teleport` | Move a session between web and terminal |
| `/mobile` | Show QR code for the Claude mobile app |
| `/schedule` | Set up routines (recurring cloud tasks) |

Note: User-invoked skills like `/commit` and built-in slash commands are interactive-mode only. In `-p`, describe the task instead.

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — Using `claude -p` from the CLI: bare mode, output formats (`text`/`json`/`stream-json`), JSON Schema structured output, streaming events, `--allowedTools`, permission modes, system prompt overrides, and continuing/resuming conversations.
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Full reference for cloud sessions: GitHub authentication, the cloud environment, installed tools, setup scripts vs SessionStart hooks, network access levels and proxies, moving sessions with `--remote` / `--teleport`, auto-fix PRs, security isolation, and limits.
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — Quickstart for connecting GitHub, creating a cloud environment, submitting and reviewing tasks, comparison of web vs. Remote Control vs. Terminal vs. Desktop, and troubleshooting setup.

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
