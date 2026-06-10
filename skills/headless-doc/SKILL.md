---
name: headless-doc
description: Complete official documentation for running Claude Code non-interactively (headless/programmatic mode with `claude -p`), Claude Code on the web (cloud sessions, environments, setup scripts, network access, teleport), the web quickstart, and session management (resume, naming, branching, export). Use when the user asks about scripted/CI usage, piping data to Claude, structured output, cloud sessions, --remote, --teleport, session picker, or conversation branching.
metadata:
  user-invocable: "false"
---

# Headless, Web, and Session Documentation

This skill provides the complete official documentation for running Claude Code programmatically, using Claude Code on the web, and managing sessions.

## Quick Reference

### Non-Interactive Mode (`claude -p`)

| Flag | Purpose |
|------|---------|
| `-p` / `--print` | Run non-interactively; required for all headless usage |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for CI) |
| `--allowedTools` | Auto-approve specific tools (e.g. `"Bash,Read,Edit"`) |
| `--permission-mode` | Set baseline: `dontAsk`, `acceptEdits`, `plan`, etc. |
| `--output-format` | `text` (default), `json`, `stream-json` |
| `--json-schema` | Return structured output conforming to a JSON Schema (with `--output-format json`) |
| `--verbose` | Include extra detail in output |
| `--include-partial-messages` | Stream tokens as generated (use with `stream-json`) |
| `--append-system-prompt` | Append instructions to the default system prompt |
| `--append-system-prompt-file` | Same, from a file |
| `--system-prompt` | Fully replace the default system prompt |
| `--continue` | Resume the most recent conversation |
| `--resume <id>` | Resume a specific session by ID |
| `--settings <file-or-json>` | Load settings from a file or inline JSON |
| `--mcp-config <file-or-json>` | Load MCP servers |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a local plugin |
| `--plugin-url <url>` | Load a marketplace plugin |

**Stdin cap:** 10 MB (v2.1.128+). Larger inputs should be written to a file.

**Output format fields (`--output-format json`):**
- `result` — plain-text answer
- `session_id` — session ID
- `total_cost_usd` — cost of the invocation
- `structured_output` — present when `--json-schema` is used

**`stream-json` retry event fields (`system/api_retry`):**

| Field | Type | Description |
|-------|------|-------------|
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code or null |
| `error` | string | One of: `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `rate_limit`, `overloaded`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown` |

**`system/init` plugin fields:**

| Field | Description |
|-------|-------------|
| `plugins` | Array of loaded plugins, each with `name` and `path` |
| `plugin_errors` | Array of load errors, each with `plugin`, `type`, `message` |

**Permission rule syntax for `--allowedTools`:** `Bash(git diff *)` — the space before `*` matters (enables prefix matching, not substring matching).

---

### Claude Code on the Web

**Cloud session overview:**
- Runs in an Anthropic-managed VM; persists when browser is closed
- Accessible from claude.ai/code and the Claude mobile app
- Each session clones a fresh copy of the repository

**GitHub authentication options:**

| Method | How | Best for |
|--------|-----|---------|
| GitHub App | Install during web onboarding | Browser setup; Auto-fix PRs |
| `/web-setup` | Syncs local `gh` CLI token | Developers who already use `gh` |

**What's available in cloud sessions:**

| Item | Available | Why |
|------|-----------|-----|
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start |
| `~/.claude/` user config, user-scoped plugins/skills | No | Machine-local only |
| Static API tokens / secrets | No | No dedicated secrets store |
| Interactive auth (AWS SSO, etc.) | No | Requires browser login |

**Pre-installed runtimes and tools:**

| Category | Included |
|----------|---------|
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun¹, eslint, prettier, chromedriver |
| Ruby | 3.1–3.3, gem, bundler, rbenv |
| PHP | 8.4, Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not started by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues for package fetching.

**Resource limits (approximate):** 4 vCPUs, 16 GB RAM, 30 GB disk.

**Useful env vars in cloud sessions:**
- `CLAUDE_CODE_REMOTE` — set to `true` in cloud sessions (use in hooks to skip local runs)
- `CLAUDE_CODE_REMOTE_SESSION_ID` — current session ID with `cse_` prefix

**Network access levels:**

| Level | Outbound connections |
|-------|---------------------|
| None | No outbound access |
| Trusted | Allowlisted domains (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist, optionally including defaults |

GitHub operations always go through a separate GitHub proxy regardless of network level.

**Setup scripts vs. SessionStart hooks:**

| | Setup scripts | SessionStart hooks |
|--|--------------|-------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches (cached) | After Claude Code launches, every session |
| Scope | Cloud only | Both local and cloud |

**Environment caching:** Setup script runs once; result is snapshotted and reused. Expires after ~7 days or when the script/network settings change.

**Move tasks between web and terminal:**

| Direction | Command/Method |
|-----------|---------------|
| Terminal → Web | `claude --remote "task description"` |
| Web → Terminal | `claude --teleport` (picker) or `claude --teleport <session-id>` |
| Inside session | `/teleport` or `/tp` |
| From `/tasks` | Press `t` to teleport into a listed session |

`--remote` clones from GitHub at your current branch — push local commits first. Set `CCR_FORCE_BUNDLE=1` to bundle and upload the local repo instead of cloning from GitHub.

**Auto-fix pull requests:** Requires the Claude GitHub App. Turn on per-PR via the CI status bar, `/autofix-pr` CLI command, mobile app, or by pasting the PR URL into a session. Claude pushes fixes for clear CI failures/review comments, asks before acting on ambiguous requests.

**Session context commands in cloud:**

| Command | Works | Notes |
|---------|-------|-------|
| `/compact [instructions]` | Yes | Summarizes conversation |
| `/context` | Yes | Shows context window contents |
| `/clear` | No | Start a new session from the sidebar |

---

### Session Management (CLI)

**Resume entry points:**

| Command | What it does |
|---------|-------------|
| `claude --continue` | Resumes the most recent session in the current directory |
| `claude --resume` | Opens the session picker |
| `claude --resume <name>` | Resumes named session directly |
| `claude --from-pr <number>` | Resumes the session linked to that PR |
| `/resume` | Switches sessions from inside an active session |

Sessions from `claude -p` / Agent SDK don't appear in the picker but can be resumed by ID.

**Session naming:**

| When | How |
|------|-----|
| At startup | `claude -n auth-refactor` |
| During session | `/rename auth-refactor` |
| From session picker | Highlight + `Ctrl+R` |

**Session picker keyboard shortcuts:**

| Shortcut | Action |
|----------|--------|
| `↑` / `↓` | Navigate |
| `→` / `←` | Expand/collapse forked session groups |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable char | Enter search / filter mode |
| `Ctrl+A` | Toggle all projects on this machine |
| `Ctrl+W` | Toggle all worktrees of current repo |
| `Ctrl+B` | Filter to current git branch |
| `Esc` | Exit picker or search mode |

**Branching sessions:**
- `/branch [name]` — forks current conversation, original stays intact
- `claude --continue --fork-session` — fork from CLI
- Permissions approved with "allow for this session" do NOT carry over to the fork

**Session transcript storage:**
- Path: `~/.claude/projects/<project>/<session-id>.jsonl`
- Override with `CLAUDE_CONFIG_DIR` env var
- Default retention: 30 days (change with `cleanupPeriodDays` setting)
- Suppress writes: `CLAUDE_CODE_SKIP_PROMPT_HISTORY` (interactive) or `--no-session-persistence` (headless)
- Export: `/export` copies to clipboard or writes to a file

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — non-interactive mode, `claude -p`, bare mode, piping, structured output, streaming, tool approval
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environments, setup scripts, network access, teleport, auto-fix PRs, session sharing
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart guide: connect GitHub, create environment, submit first task, review diff, create PR
- [Manage sessions](references/claude-code-sessions.md) — resume, naming, session picker, branching, export, transcript storage

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
