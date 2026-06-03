---
name: headless-doc
user-invocable: false
---

# Headless & Cloud Sessions Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (`claude -p`), using Claude Code on the web (cloud sessions), and managing sessions across surfaces.

## Quick Reference

### Non-Interactive Mode (`claude -p`)

| Flag | Description |
|:-----|:------------|
| `-p <prompt>` / `--print <prompt>` | Run non-interactively; print response and exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md. Recommended for CI/scripts |
| `--output-format text\|json\|stream-json` | Response format. Default: `text` |
| `--json-schema <schema>` | Enforce a JSON Schema on the response (use with `--output-format json`) |
| `--include-partial-messages` | Include partial streaming messages (use with `stream-json`) |
| `--verbose` | Include full event stream (use with `stream-json`) |
| `--allowedTools <list>` | Pre-approve tools without prompting. Supports permission rule syntax |
| `--permission-mode <mode>` | Set permission mode: `acceptEdits`, `dontAsk`, etc. |
| `--append-system-prompt <text>` | Add to system prompt while keeping defaults |
| `--system-prompt <text>` | Fully replace default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <id\|name>` | Resume a specific session by ID or name |
| `--no-session-persistence` | Suppress transcript writes in non-interactive mode |

**Stdin cap**: piped stdin is capped at 10 MB (since v2.1.128). Use a file path for larger inputs.

**Bare mode context**: in bare mode, only pass context explicitly via `--append-system-prompt`, `--settings`, `--mcp-config`, `--agents`, `--plugin-dir`, or `--plugin-url`. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`.

### Output Formats

| Format | Description |
|:-------|:------------|
| `text` | Plain text response (default) |
| `json` | JSON object with `result`, `session_id`, `total_cost_usd`, per-model cost breakdown |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

With `--json-schema`, structured output appears in the `structured_output` field of the JSON response.

### Streaming Event Types

| Event type | Description |
|:-----------|:------------|
| `system/init` | First event; reports model, tools, MCP servers, loaded plugins, `plugin_errors` |
| `system/api_retry` | Emitted before a retry on retryable API errors |
| `system/plugin_install` | Plugin install progress (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set) |

**`system/api_retry` fields**: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` (category string), `uuid`, `session_id`.

**`system/init` plugin fields**: `plugins` (loaded, each with `name`/`path`), `plugin_errors` (load failures, each with `plugin`, `type`, `message`).

### `--allowedTools` Permission Rule Syntax

`Bash(git diff *)` — trailing ` *` (space + asterisk) enables prefix matching. Without the space, `Bash(git diff*)` would also match `git diff-index`.

### Session Management (CLI)

| Command | Action |
|:--------|:-------|
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open interactive session picker |
| `claude --resume <name\|id>` | Resume named or ID'd session directly |
| `claude --from-pr <number>` | Resume session linked to that PR |
| `claude -n <name>` | Start session with a name |
| `/resume [name]` | Switch sessions from inside an active session |
| `/rename <name>` | Rename current session |
| `/branch [name]` | Fork session; original remains intact |
| `/export [file]` | Copy or save conversation as plain text |
| `--fork-session` | Combined with `--continue`/`--resume`; creates a branch |

**Session picker keyboard shortcuts**:

| Shortcut | Action |
|:---------|:-------|
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand/collapse groups |
| `Enter` | Resume highlighted session |
| `Space` / `Ctrl+V` | Preview session content |
| `Ctrl+R` | Rename session |
| `/` or printable char | Search / filter |
| `Ctrl+A` | All projects on machine (toggle) |
| `Ctrl+W` | All worktrees of current repo (toggle) |
| `Ctrl+B` | Filter to current git branch (toggle) |
| `Esc` | Exit picker or search |

**Transcript storage**: `~/.claude/projects/<project>/<session-id>.jsonl`. Configurable with `CLAUDE_CONFIG_DIR`. Removed after 30 days by default (`cleanupPeriodDays` setting). `-p`-mode sessions don't appear in the picker but are resumable by session ID.

### Claude Code on the Web (Cloud Sessions)

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist when the browser is closed and can be monitored from the Claude mobile app.

**What's available in cloud sessions**:

| Item | Available | Notes |
|:-----|:----------|:------|
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed from marketplace at session start |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| Plugins enabled only in user settings | No | Declare in repo's `.claude/settings.json` |
| MCP servers added with `claude mcp add` | No | Declare in `.mcp.json` instead |
| Static API tokens / credentials | No | No dedicated secrets store yet |
| Interactive auth (AWS SSO, etc.) | No | Not supported |

**Cloud resource limits** (approximate, may change): 4 vCPUs, 16 GB RAM, 30 GB disk.

**Pre-installed runtimes and tools**:

| Category | Included |
|:---------|:---------|
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun¹, eslint, prettier, chromedriver |
| Ruby | 3.1–3.3 with gem, bundler, rbenv |
| PHP | 8.4 + Composer |
| Java | OpenJDK 21 + Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues for package fetching.

Run `check-tools` in a cloud session to get exact versions.

### GitHub Authentication for Cloud Sessions

| Method | How | Best for |
|:-------|:----|:---------|
| GitHub App | Install via browser onboarding at claude.ai/code | Browser setup; enables Auto-fix |
| `/web-setup` | Run in Claude Code CLI to sync local `gh` token | Developers already using `gh` CLI |

The GitHub App is required for Auto-fix (PR webhooks). `/web-setup` is disabled for Zero Data Retention orgs. Admins can disable it at `claude.ai/admin-settings/claude-code`.

### Network Access Levels (Cloud)

| Level | Outbound connections |
|:------|:--------------------|
| None | No outbound network access |
| Trusted | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist (optionally including Trusted defaults) |

Use `*.` for wildcard subdomain matching in custom allowlists. GitHub operations always use a dedicated proxy regardless of this setting.

### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
|:--|:-------------|:-------------------|
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches; benefits from caching | After launch, on every session including resume |
| Scope | Cloud only | Both local and cloud |

Setup script tips: run as root on Ubuntu 24.04; keep under ~5 minutes for environment caching; run independent installs in parallel with `&` and `wait`; append `|| true` to non-critical commands.

**Environment caching**: after the setup script runs once, Anthropic snapshots the filesystem. Subsequent sessions start from the snapshot (no re-run). Cache rebuilds when the script or allowed network hosts change, or after ~7 days. Resuming an existing session never re-runs the script.

To detect cloud sessions in a SessionStart hook, check `CLAUDE_CODE_REMOTE=true`.

### Moving Sessions Between Web and Terminal

| Direction | Command | Notes |
|:----------|:--------|:------|
| Terminal → web | `claude --remote "<task>"` | Creates new cloud session; pushes current branch first |
| Web → terminal | `claude --teleport` | Interactive picker of cloud sessions |
| Web → terminal (specific) | `claude --teleport <session-id>` | Direct resume |
| Inside session | `/teleport` or `/tp` | Opens same picker without restarting |
| `/tasks` list | press `t` | Teleport from background session list |

`--remote` bundles and uploads the repo automatically if no GitHub remote is detected (or `CCR_FORCE_BUNDLE=1`). Bundle limits: git repo with at least one commit, under 100 MB, untracked files excluded.

**Teleport requirements**: clean git working directory, correct repository, branch pushed to remote, same claude.ai account. Requires claude.ai subscription (not API key auth).

### Auto-fix Pull Requests

When enabled, Claude monitors a PR for CI failures and review comments and pushes fixes automatically. Requires the Claude GitHub App installed on the repository.

Ways to enable:
- PRs created in web: open CI status bar → **Auto-fix**
- From terminal: run `/autofix-pr` on the PR's branch
- Mobile app: tell Claude to "auto-fix the PR"
- Any PR: paste the PR URL into a session and ask Claude to auto-fix it

Claude behavior: clear fixes are pushed automatically; ambiguous requests prompt you; duplicate/no-action events are noted. Claude may reply to review comment threads under your GitHub username, labeled as Claude Code. Be aware of comment-triggered automation (Atlantis, Terraform Cloud, etc.) before enabling.

### Cloud Session Context Management

| Command | Works in cloud | Notes |
|:--------|:--------------|:------|
| `/compact [instructions]` | Yes | Summarizes conversation; accepts focus hint |
| `/context` | Yes | Shows context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

Auto-compaction threshold: configurable with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `70` for 70%). Window size for calculations: `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

### Pre-fill Cloud Sessions via URL

Append query parameters to `https://claude.ai/code`:

| Parameter | Alias | Description |
|:----------|:------|:------------|
| `prompt` | `q` | Prefill prompt text |
| `prompt_url` | — | URL to fetch prompt from (if `prompt` not set; must allow CORS) |
| `repositories` | `repo` | Comma-separated `owner/repo` slugs to preselect |
| `environment` | — | Environment name or ID to preselect |

### Important Environment Variables

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_REMOTE` | Set to `true` in cloud sessions; use in hooks/scripts to detect cloud |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | Cloud session ID (prefix `cse_`). Transcript URL: replace `cse_` with `session_` |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Trigger auto-compaction at this % of context capacity (default ~95%) |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Override context window size for compaction calculations |
| `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` | Emit `plugin_install` stream events during marketplace plugin installs |
| `CCR_FORCE_BUNDLE` | Set to `1` to force bundle upload even when GitHub is connected |
| `CLAUDE_CONFIG_DIR` | Override directory for transcript storage (default `~/.claude`) |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Suppress all transcript writes |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `claude -p`, `--bare` mode, output formats, streaming events, tool approval, system prompts, continuing conversations
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environment setup, installed tools, setup scripts, network access, moving sessions between web and terminal, auto-fix PRs, security and isolation
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart: connect GitHub, create environment, start a task, review and iterate, troubleshoot setup
- [Manage sessions](references/claude-code-sessions.md) — resume, name, branch, and export sessions; session picker keyboard reference; transcript storage

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
