---
name: headless-doc
user-invocable: false
---

# Headless / Programmatic Usage & Claude Code on the Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically (headless / `-p` mode) and for using Claude Code on the web (cloud sessions).

## Quick Reference

### Running Claude Code Programmatically (CLI `-p` mode)

| Flag | Purpose |
|---|---|
| `-p` / `--print` | Run non-interactively; print response and exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md; recommended for CI/scripts |
| `--output-format text\|json\|stream-json` | Control response format |
| `--json-schema '<schema>'` | Return structured output matching a JSON Schema (use with `--output-format json`) |
| `--include-partial-messages` | Stream tokens as generated (use with `stream-json`) |
| `--allowedTools "Read,Edit,Bash"` | Auto-approve specific tools |
| `--permission-mode acceptEdits\|dontAsk` | Set baseline permission mode |
| `--append-system-prompt` | Add instructions without replacing the default prompt |
| `--system-prompt` | Fully replace the default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Resume a specific conversation by session ID |
| `--settings <file-or-json>` | Load settings (required for API key auth in bare mode) |
| `--mcp-config <file-or-json>` | Load MCP servers |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin directory |

**Key behaviors:**
- `--bare` skips OAuth/keychain; use `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` for auth
- `--bare` will become the default for `-p` in a future release
- `--allowedTools` supports permission rule syntax: `Bash(git diff *)` allows commands starting with `git diff ` (space before `*` matters)
- User-invocable skills and built-in commands are only available in interactive mode, not `-p` mode

**Output format JSON fields:**
- `result` — the text response
- `session_id` — session identifier for `--resume`
- `structured_output` — present when `--json-schema` is used

### Stream Event Types (`stream-json`)

| Event type | Subtype | Description |
|---|---|---|
| `system` | `init` | Session metadata: model, tools, plugins loaded, plugin errors |
| `system` | `api_retry` | Retry in progress; fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` |
| `system` | `plugin_install` | Plugin install progress (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set); statuses: `started`, `installed`, `failed`, `completed` |

**`system/init` plugin fields:**
- `plugins` — array of `{name, path}` for successfully loaded plugins
- `plugin_errors` — array of `{plugin, type, message}` for load-time errors (key omitted when empty)

### Claude Code on the Web — Cloud Sessions

**Comparison of run surfaces:**

| | On the web | Remote Control | Terminal CLI | Desktop app |
|---|---|---|---|---|
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| Chat from | claude.ai / mobile | claude.ai / mobile | Terminal | Desktop UI |
| Local config | No (repo only) | Yes | Yes | Yes (local) / No (cloud) |
| Requires GitHub | Yes (or bundle) | No | No | Only for cloud |
| Persists if disconnected | Yes | While terminal open | No | Depends |

**GitHub authentication options:**

| Method | Best for |
|---|---|
| Claude GitHub App | Teams wanting explicit per-repo authorization; required for Auto-fix |
| `/web-setup` (syncs local `gh` token) | Individual developers already using `gh` CLI |

**What's available in cloud sessions:**

| Config | Available | Why |
|---|---|---|
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md`, user-scoped plugins, MCP servers added with `claude mcp add` | No | Lives only on your machine |
| Static API tokens / credentials | No | No secrets store yet |
| Interactive auth (AWS SSO etc.) | No | Requires browser login |

**Pre-installed tools (cloud VMs):**

| Category | Included |
|---|---|
| Python | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun*, eslint, prettier |
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

**Cloud resource limits:** ~4 vCPUs, 16 GB RAM, 30 GB disk.

**Network access levels:**

| Level | Outbound |
|---|---|
| None | Blocked entirely |
| Trusted | Default allowlist (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist, optionally including defaults |

**Setup scripts vs. SessionStart hooks:**

| | Setup scripts | SessionStart hooks |
|---|---|---|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches (cached after first run) | After Claude Code launches, every session |
| Scope | Cloud only | Local and cloud |

- Setup script cache invalidates when you change the script or allowed network hosts, or after ~7 days
- Use `CLAUDE_CODE_REMOTE=true` check in SessionStart hooks to skip local execution

**Terminal ↔ web session handoff:**

| Direction | How |
|---|---|
| Terminal → web | `claude --remote "task"` (creates new cloud session from current repo/branch) |
| Web → terminal | `claude --teleport` (interactive picker) or `claude --teleport <session-id>` |
| Web → terminal (in-session) | `/teleport` or `/tp` inside an existing CLI session |
| Web → terminal (from /tasks) | `/tasks` then press `t` |

**Teleport requirements:** clean git state, correct repo (not a fork), branch pushed to remote, same claude.ai account.

**`--remote` without GitHub:** bundles local repo automatically (up to 100 MB); set `CCR_FORCE_BUNDLE=1` to force bundling even when GitHub is connected.

**Context management in cloud sessions:**

| Command | Available | Notes |
|---|---|---|
| `/compact` | Yes | Optional focus arg: `/compact keep the test output` |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from sidebar instead |

**Auto-compaction env vars:**
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` — compact at custom % (default ~95%)
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` — override effective window size for compaction

**Pre-fill URL parameters for `claude.ai/code`:**

| Parameter | Description |
|---|---|
| `prompt` / `q` | Prefill prompt text |
| `prompt_url` | URL to fetch prompt from (for long prompts) |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs |
| `environment` | Environment name or ID |

**Auto-fix pull requests:** monitors PR for CI failures and review comments; requires Claude GitHub App; enable via CI status bar, `/autofix-pr` CLI command, mobile app, or by pasting a PR URL.

**Session env var:** `CLAUDE_CODE_REMOTE_SESSION_ID` — readable inside the VM to construct a link back to the session transcript.

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) — CLI `-p` mode, `--bare`, output formats, streaming, tool approval, system prompt customization, and conversation continuity
- [Claude Code on the Web](references/claude-code-on-the-web.md) — Cloud environment config, setup scripts, network access, session handoff (`--remote`/`--teleport`), session management, auto-fix PRs, security, and limitations
- [Get Started with Claude Code on the Web](references/claude-code-web-quickstart.md) — Quickstart: connect GitHub, create an environment, submit a task, review and iterate, troubleshoot setup

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get Started with Claude Code on the Web: https://code.claude.com/docs/en/web-quickstart.md
