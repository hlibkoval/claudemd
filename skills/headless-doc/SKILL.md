---
name: headless-doc
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (headless/programmatic mode via `claude -p`), Claude Code on the web (cloud sessions at claude.ai/code), and session management.

## Quick Reference

### Non-Interactive Mode (`claude -p`)

Pass `-p` (or `--print`) with a prompt to run Claude non-interactively. All CLI options work with `-p`.

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

Add `--bare` to skip auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md. Recommended for CI/scripts:

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

In bare mode, pass context explicitly:

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

Bare mode requires `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` for Anthropic auth (no OAuth/keychain). `--bare` will become the default for `-p` in a future release.

### Output Formats

| Format | Flag | Description |
| :--- | :--- | :--- |
| `text` | `--output-format text` | Default plain text output |
| `json` | `--output-format json` | Structured JSON with `result`, `session_id`, `total_cost_usd`, metadata |
| `stream-json` | `--output-format stream-json` | Newline-delimited JSON events for real-time streaming |

Use `--json-schema` with `--output-format json` to get schema-conforming output in the `structured_output` field.

Use `--output-format stream-json --verbose --include-partial-messages` to receive tokens as they're generated.

### Permission Modes in `-p`

| Flag | Effect |
| :--- | :--- |
| `--allowedTools "Bash,Read,Edit"` | Auto-approve specific tools; uses permission rule syntax (`Bash(git diff *)` for prefix matching) |
| `--permission-mode dontAsk` | Deny anything not in `permissions.allow` or the read-only command set |
| `--permission-mode acceptEdits` | Write files without prompting; auto-approves common filesystem commands |

### Conversation Continuity

| Flag | Effect |
| :--- | :--- |
| `--continue` | Resume the most recent conversation in the current directory |
| `--resume <session-id>` | Resume a specific conversation by session ID |

Capture session ID from JSON output: `session_id=$(claude -p "..." --output-format json | jq -r '.session_id')`

Session lookup is scoped to the current project directory and its git worktrees.

### Background Tasks in `-p`

- Background Bash processes are terminated ~5 seconds after Claude returns its final result and stdin closes.
- Background subagents wait for completion (part of final output), capped at 10 minutes by default (v2.1.182+).
- Adjust cap with `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS`; set to `0` for no limit.

### Streaming Event Types (`stream-json`)

**`system/api_retry`** — emitted before retrying a failed API call:

| Field | Type | Description |
| :--- | :--- | :--- |
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or `null` for connection errors |
| `error` | string | Error category: `authentication_failed`, `billing_error`, `rate_limit`, `overloaded`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, or `unknown` |

**`system/init`** — first event; reports session metadata including model, tools, MCP servers, loaded plugins:

| Field | Type | Description |
| :--- | :--- | :--- |
| `plugins` | array | Plugins that loaded successfully (each has `name` and `path`) |
| `plugin_errors` | array | Plugin load-time errors (each has `plugin`, `type`, `message`) |

**`system/plugin_install`** — emitted when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set, before first turn:

| Field | Type | Description |
| :--- | :--- | :--- |
| `status` | string | `"started"`, `"installed"`, `"failed"`, or `"completed"` |
| `name` | string, optional | Marketplace name (on `installed` and `failed`) |
| `error` | string, optional | Failure message (on `failed`) |

### Stdin Limit

Piped stdin is capped at 10MB (v2.1.128+). For larger inputs, write to a file and reference the path in the prompt instead.

### Skills and Config in `-p`

User-invocable skills and custom commands work in `-p` mode: include `/skill-name` in the prompt string. Built-in commands that open an interactive dialog (e.g. `/login`) are not available. To change a setting from `-p`, pass `key=value` to `/config` (e.g. `/config thinking=false`).

---

### Session Management (CLI)

| Entry point | What it does |
| :--- | :--- |
| `claude --continue` | Resume the most recent session in the current directory |
| `claude --resume` | Open the interactive session picker |
| `claude --resume <name>` | Resume the named session directly |
| `claude --from-pr <number>` | Resume the session linked to that pull request |
| `/resume` | Switch to a different conversation from inside an active session |

Sessions created with `claude -p` or the Agent SDK do not appear in the session picker, but can be resumed by passing their session ID to `claude --resume <session-id>` from the originating directory.

**Session naming:**

| When | How |
| :--- | :--- |
| At startup | `claude -n auth-refactor` |
| During a session | `/rename auth-refactor` |
| From session picker | Highlight a session and press `Ctrl+R` |
| On plan accept | Auto-named from plan content if no name set |

**Session picker keyboard shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `↑` / `↓` | Navigate between sessions |
| `→` / `←` | Expand or collapse grouped sessions |
| `Enter` | Resume the highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename the highlighted session |
| `/` | Enter search mode |
| `Ctrl+A` | Show sessions from all projects on this machine |
| `Ctrl+W` | Show sessions from all worktrees of the current repository |
| `Ctrl+B` | Filter to sessions from the current git branch |
| `Esc` | Exit picker or search mode |

**Branching sessions:**

Use `/branch [name]` inside a session or `--fork-session` combined with `--continue` / `--resume` to create a copy of the conversation. The original remains intact in the session picker.

**Session storage:** transcripts are stored as JSONL at `~/.claude/projects/<project>/<session-id>.jsonl`. Set `CLAUDE_CONFIG_DIR` to change the base directory. Files are removed after 30 days by default (configurable with `cleanupPeriodDays`). Use `--no-session-persistence` (non-interactive) or `CLAUDE_CODE_SKIP_PROMPT_HISTORY` to suppress transcript writes.

**In-session context commands:**

| Command | Effect |
| :--- | :--- |
| `/clear` | Start fresh with empty context (previous conversation is saved and resumable) |
| `/compact [instructions]` | Replace history with a summary |
| `/context` | Show what is currently consuming context |
| `/export` | Copy conversation to clipboard or save as plain-text file |

---

### Claude Code on the Web

Cloud sessions run at [claude.ai/code](https://claude.ai/code) on Anthropic-managed VMs. Sessions persist if you close the browser and can be monitored from the Claude mobile app.

**Comparison: ways to run Claude Code:**

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| Uses local config | No, repo only | Yes | Yes | Yes for local, no for cloud |
| Requires GitHub | Yes (or bundle via `--remote`) | No | No | Only for cloud sessions |
| Keeps running if disconnected | Yes | While terminal open | No | Depends on session type |

**What's available in cloud sessions:**

| Resource | Available | Why |
| :--- | :--- | :--- |
| Repo `CLAUDE.md` | Yes | Part of the clone |
| `.claude/settings.json` hooks | Yes | Part of the clone |
| `.mcp.json` MCP servers | Yes | Part of the clone |
| `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins in `.claude/settings.json` | Yes | Installed at session start from marketplace |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| User `~/.claude/skills/` etc. | No | Lives on your machine |
| MCP servers added with `claude mcp add` | No | Writes to local user config |
| Static API tokens / credentials | No | No dedicated secrets store yet |
| Interactive auth (e.g. AWS SSO) | No | Requires browser-based login |

**Cloud VM pre-installed tools:**

| Category | Included |
| :--- | :--- |
| Python | 3.x with pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun¹, eslint, prettier |
| Ruby | 3.1, 3.2, 3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven and Gradle |
| Go | Latest stable with module support |
| Rust | rustc and cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues for package fetching.

PostgreSQL and Redis are pre-installed but not running by default. Ask Claude to run `service postgresql start` / `service redis-server start` per session.

**Resource limits (approximate, may change):** 4 vCPUs, 16 GB RAM, 30 GB disk.

**Session URL:** Read `CLAUDE_CODE_REMOTE_SESSION_ID` env var in cloud sessions. Convert to transcript URL:
```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```
Commits Claude creates include a `Claude-Session: <url>` git trailer and PR bodies include the session URL (v2.1.179+). Disable with `attribution.sessionUrl: false` in settings (v2.1.182+).

### GitHub Authentication (Web)

| Method | How | Best for |
| :--- | :--- | :--- |
| GitHub App | Authorize Claude GitHub App during web onboarding | Browser onboarding; teams wanting Auto-fix |
| `/web-setup` | Run in terminal to sync local `gh` CLI token | Individual developers already using `gh` |

GitHub App is required for Auto-fix (PR webhooks). `/web-setup` is disabled for organizations with Zero Data Retention enabled.

### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | The cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in your repo |
| Runs | Before Claude Code launches, when no cached environment is available | After Claude Code launches, on every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Setup scripts run as root on Ubuntu 24.04. The result is cached (filesystem snapshot); the script is skipped for subsequent sessions. Cache rebuilds when setup script or allowed network hosts change, or after ~7 days.

Check `CLAUDE_CODE_REMOTE=true` in SessionStart hooks to skip local execution:
```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

### Network Access Levels

| Level | Outbound connections |
| :--- | :--- |
| None | No outbound network access |
| Trusted | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist, optionally including the Trusted defaults |

GitHub operations use a separate GitHub proxy independent of this setting. All outbound traffic passes through an HTTP/HTTPS security proxy.

### Moving Tasks Between Web and Terminal

**Terminal to web** — start a cloud session from CLI:
```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```
Push local commits first; the VM clones from GitHub. Use `/tasks` to check progress.

Send local repos without GitHub: bundles are created automatically when GitHub isn't available. Force with `CCR_FORCE_BUNDLE=1`. Bundle limits: must be a git repo with at least one commit; under 100 MB; untracked files not included.

**Web to terminal** — pull a cloud session into your terminal:

| Method | How |
| :--- | :--- |
| `claude --teleport` | Interactive session picker |
| `claude --teleport <session-id>` | Teleport directly to a specific session |
| `/teleport` (or `/tp`) | From inside an existing CLI session |
| `/tasks` then `t` | From the background sessions list |
| Web interface | Select "Open in CLI" to copy a command |

Teleport requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account. Requires claude.ai subscription auth (not API key).

`--teleport` differs from `--resume`: teleport pulls a cloud session and its branch; resume reopens local history.

### Auto-Fix Pull Requests

Claude can watch a PR and automatically respond to CI failures and review comments. Requires the Claude GitHub App installed on the repository.

Enable auto-fix:
- PRs created in web: open the CI status bar and select "Auto-fix"
- From terminal: run `/autofix-pr` while on the PR's branch
- From mobile app: tell Claude to auto-fix the PR
- Any existing PR: paste the PR URL into a session and instruct Claude

Claude responds with: clear fixes (pushed automatically), ambiguous requests (asks before acting), or no-action events (noted in session).

### Environment Management (Web)

| Action | How |
| :--- | :--- |
| Add environment | Select current environment → Add environment |
| Edit environment | Click cloud icon → hover environment → settings icon |
| Archive environment | Open environment for editing → Archive |
| Set default for `--remote` | Run `/remote-env` in terminal |

Environment variables use `.env` format (one `KEY=value` per line, no quotes around values).

### Context Management in Cloud Sessions

| Command | Works | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Accepts optional focus instructions |
| `/context` | Yes | Shows context window contents |
| `/clear` | No | Start new session from sidebar instead |

Auto-compaction triggers near capacity. Override threshold with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g. `70` for 70%). Change effective window size with `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

### Web Quickstart — Pre-fill Sessions

Add query parameters to `https://claude.ai/code` to pre-fill a new session:

| Parameter | Description |
| :--- | :--- |
| `prompt` (or `q`) | Prompt text to prefill |
| `prompt_url` | URL to fetch prompt from (ignored when `prompt` is set) |
| `repositories` (or `repo`) | Comma-separated `owner/repo` slugs |
| `environment` | Name or ID of the environment to preselect |

### Web Limitations

- Rate limits shared with all other Claude and Claude Code usage on the account
- Repository cloning and PR creation require GitHub (GHES supported for Team/Enterprise)
- GitLab, Bitbucket, and other non-GitHub repos can be sent as local bundles but cannot push back
- Organization IP allowlisting blocks cloud sessions (contact Anthropic support for exemption)
- `/model`, `/config`, and other commands that open interactive pickers are not available in cloud sessions

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — Non-interactive `-p` mode, `--bare` flag, piping data, structured output, streaming events, tool auto-approval, system prompt flags, session continuity
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — GitHub auth, cloud environment config, installed tools, setup scripts, network access levels, moving tasks between web and terminal, auto-fix PRs, session sharing/archiving/deletion, security and isolation, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — Quickstart walkthrough, how sessions run, comparison of run modes, GitHub App setup, `/web-setup`, submitting tasks, pre-filling sessions, reviewing diffs, creating PRs, troubleshooting setup
- [Manage sessions](references/claude-code-sessions.md) — Resume flags, session picker, naming sessions, branching sessions, context commands, transcript export and storage

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
