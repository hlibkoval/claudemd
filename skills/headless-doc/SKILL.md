---
name: headless-doc
user-invocable: false
---

# Headless / Web / Sessions Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (headless mode via `claude -p`), using Claude Code on the web (cloud sessions), and managing sessions (resuming, naming, branching, exporting).

## Quick Reference

### Headless / Non-Interactive Mode (`claude -p`)

| Flag | Description |
| :--- | :---------- |
| `-p <prompt>` / `--print <prompt>` | Run non-interactively and print response |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md. Recommended for CI/scripts |
| `--output-format text\|json\|stream-json` | Response format (default: `text`) |
| `--json-schema <schema>` | Enforce a JSON Schema; result in `structured_output` field (requires `--output-format json`) |
| `--include-partial-messages` | Emit tokens as they stream (use with `stream-json`) |
| `--verbose` | Include more detail in stream output |
| `--allowedTools <list>` | Comma-separated tools to auto-approve (supports permission rule syntax) |
| `--permission-mode <mode>` | `dontAsk` or `acceptEdits` baseline for the session |
| `--append-system-prompt <text>` | Append to the default system prompt |
| `--append-system-prompt-file <path>` | Same, from a file |
| `--system-prompt <text>` | Fully replace the default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <id>` | Resume a specific conversation by session ID |
| `--settings <file-or-json>` | Load settings (required for auth in `--bare` mode) |
| `--mcp-config <file-or-json>` | Load MCP servers |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin for this session |
| `--plugin-url <url>` | Load a zipped plugin from URL |
| `--no-session-persistence` | Suppress local transcript writes |

**stdin cap**: piped stdin is capped at 10 MB (as of v2.1.128). Larger inputs should be written to a file and referenced by path.

**Background tasks**: background Bash tasks are terminated ~5 seconds after the final result and stdin closes. Before v2.1.163, a never-exiting background process would hold `-p` open indefinitely.

### Output Format Details

| Format | Description |
| :----- | :---------- |
| `text` | Plain text response (default) |
| `json` | Structured JSON: `result`, `session_id`, `total_cost_usd`, per-model cost breakdown |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

With `--output-format json` and `--json-schema`, structured output appears in the `structured_output` field.

### `stream-json` System Events

#### `system/api_retry`

| Field | Type | Description |
| :---- | :--- | :---------- |
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Event identifier |
| `attempt` | integer | Current attempt (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | Error category (e.g. `rate_limit`, `server_error`, `billing_error`) |
| `uuid` | string | Unique event ID |
| `session_id` | string | Session identifier |

#### `system/init`

| Field | Type | Description |
| :---- | :--- | :---------- |
| `plugins` | array | Successfully loaded plugins (each with `name` and `path`) |
| `plugin_errors` | array | Load-time failures (each with `plugin`, `type`, `message`); key omitted when empty |

Set `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` to receive `system/plugin_install` events before `system/init`.

#### `system/plugin_install`

| Field | Type | Description |
| :---- | :--- | :---------- |
| `type` | `"system"` | Message type |
| `subtype` | `"plugin_install"` | Event identifier |
| `status` | `"started"` \| `"installed"` \| `"failed"` \| `"completed"` | Overall brackets or per-marketplace result |
| `name` | string, optional | Marketplace name (present on `installed` and `failed`) |
| `error` | string, optional | Failure message (present on `failed`) |
| `uuid` | string | Unique event ID |
| `session_id` | string | Session identifier |

### Permission Modes in `-p`

| Mode | Behavior |
| :--- | :------- |
| `dontAsk` | Denies anything not in `permissions.allow` or the read-only command set |
| `acceptEdits` | Lets Claude write files without prompting; auto-approves `mkdir`, `touch`, `mv`, `cp` |

Use `--allowedTools` with permission rule syntax: e.g. `Bash(git diff *)` (space before `*` matters for prefix matching).

### Bare Mode — What Loads Without Extra Flags

| To load | Use |
| :------ | :-- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings / auth | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

In `--bare` mode, Anthropic auth must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in the JSON passed to `--settings`. OAuth/keychain reads are skipped.

---

### Claude Code on the Web (Cloud Sessions)

Cloud sessions run on Anthropic-managed VMs at claude.ai/code. They persist when you close the browser and can be monitored from the Claude mobile app.

#### Availability

In research preview for Pro, Max, Team users, and Enterprise users with premium seats or Chat + Claude Code seats.

#### GitHub Authentication

| Method | How | Best for |
| :----- | :-- | :------- |
| GitHub App | Authorize during web onboarding | Browser setup; enables Auto-fix |
| `/web-setup` | Syncs local `gh` CLI token to Claude account | Developers already using `gh` CLI |

Organizations with Zero Data Retention cannot use `/web-setup` or cloud session features.

#### What's Available in Cloud Sessions

| Resource | Available? | Why |
| :------- | :--------- | :-- |
| Repo's `CLAUDE.md` | Yes | Part of the clone |
| Repo's `.claude/settings.json` hooks | Yes | Part of the clone |
| Repo's `.mcp.json` MCP servers | Yes | Part of the clone |
| Repo's `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md` | No | Local machine only |
| User `~/.claude/skills/`, `~/.claude/agents/` | No | Local machine only |
| Plugins enabled only in user settings | No | Declare in repo `.claude/settings.json` instead |
| MCP servers added with `claude mcp add` | No | Declare in `.mcp.json` instead |
| Static API tokens / credentials | No | No secrets store yet; use env vars |
| Interactive auth (e.g. AWS SSO) | No | Not supported |

#### Pre-installed Tools

| Category | Included |
| :------- | :------- |
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun¹, eslint, prettier, chromedriver |
| Ruby | 3.1, 3.2, 3.3, gem, bundler, rbenv |
| PHP | 8.4, Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not started by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues for package fetching.

Run `check-tools` inside a cloud session to see exact versions.

#### Resource Limits (approximate, may change)

- 4 vCPUs
- 16 GB RAM
- 30 GB disk

#### Cloud Environment Configuration

| Action | How |
| :----- | :-- |
| Add environment | Open selector → **Add environment** |
| Edit environment | Cloud icon → hover environment → settings icon |
| Archive environment | Edit → **Archive** |
| Set default for `--remote` | Run `/remote-env` in terminal |

Environment variables use `.env` format (`KEY=value`). Do not wrap values in quotes.

#### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :- | :------------ | :----------------- |
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches (cached after first run) | After Claude Code launches, every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

**Environment caching**: the filesystem snapshot after the first setup script run is reused for subsequent sessions. Cache rebuilds when setup script or allowed network hosts change, or after ~7 days.

**To skip local execution in a SessionStart hook**, check `CLAUDE_CODE_REMOTE`:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

To persist env vars for subsequent Bash commands, write to `$CLAUDE_ENV_FILE`.

#### Network Access Levels

| Level | Outbound connections |
| :---- | :------------------- |
| None | No outbound network access |
| Trusted | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist (optionally including Trusted defaults) |

GitHub operations always use a separate secure proxy, independent of this setting.

#### Moving Tasks Between Web and Terminal

| Action | Command / Method |
| :----- | :--------------- |
| Start cloud session from terminal | `claude --remote "your task"` |
| Check cloud session progress | `/tasks` in Claude Code CLI |
| Pull cloud session into terminal | `claude --teleport` (picker) or `claude --teleport <session-id>` |
| Pull from inside a session | `/teleport` or `/tp` |
| From `/tasks` | Press `t` to teleport |
| From web | **Open in CLI** button |

`--remote` clones from GitHub at the current branch — push local commits first. Use `CCR_FORCE_BUNDLE=1` to bundle without GitHub. Bundle limits: git repo required, under 100 MB, untracked files not included.

`--teleport` requires the same claude.ai account, a clean git state, and the branch pushed to remote. It is distinct from `--resume` (which only looks at local history).

#### Session Link from Environment Variable

```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

#### Auto-fix Pull Requests

Requires the Claude GitHub App installed on the repository. Monitors the PR for CI failures and review comments, then pushes fixes automatically. Turn on via:

- PRs in Claude Code on the web: open CI status bar → **Auto-fix**
- From terminal: run `/autofix-pr` on the PR's branch
- From mobile app or any session: paste the PR URL and ask Claude to auto-fix it

Claude may reply to review comment threads on GitHub under your username, labeled as coming from Claude Code. This can trigger comment-triggered automation (Atlantis, Terraform Cloud, etc.) — review repo automation before enabling.

#### Context Management in Cloud Sessions

| Command | Available | Notes |
| :------ | :-------- | :---- |
| `/compact [instructions]` | Yes | Summarizes conversation; accepts optional focus |
| `/context` | Yes | Shows current context window usage |
| `/clear` | No | Start a new session from sidebar instead |

Auto-compaction triggers at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=<pct>`. Change effective window size with `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

Agent teams: off by default; enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in environment variables.

#### Session Sharing

| Plan type | Visibility options | Notes |
| :-------- | :----------------- | :---- |
| Enterprise / Team | Private, Team | Repository access verification on by default |
| Max / Pro | Private, Public | Repository access verification off by default |

Adjust sharing settings at Settings > Claude Code > Sharing settings.

#### Troubleshooting Cloud Sessions

| Symptom | Fix |
| :------ | :-- |
| Session creation failed | Check status.claude.com; retry; verify GitHub account access |
| `Remote Control session expired` / `Access denied` | Run `/login` locally; confirm same account |
| Environment expired | Reopen session at claude.ai/code for fresh environment |
| Setup script failed | Add `set -x` to debug; append `|| true` to non-critical commands |
| Sessions hang during setup | Parallelize installs with `&` + `wait`; move large downloads to SessionStart hooks; keep setup script under ~5 minutes |
| Organization IP allowlist blocks sessions | Contact Anthropic support to exempt Anthropic-hosted services |

#### Platform Restrictions

- Requires GitHub for repository cloning and PR creation (GitLab/Bitbucket can only receive local bundles; can't push back)
- Self-hosted GitHub Enterprise Server supported on Team and Enterprise plans
- Cloud sessions call Anthropic API from Anthropic infrastructure — incompatible with org IP allowlisting

---

### Session Management (CLI)

#### Resume Commands

| Command | What it does |
| :------ | :----------- |
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open the session picker |
| `claude --resume <name>` | Resume named session directly |
| `claude --from-pr <number>` | Resume session linked to a pull request |
| `/resume` | Switch sessions from inside an active session |
| `/resume <name>` | Resume named session (reports error if ambiguous) |

Sessions from `claude -p` / Agent SDK don't appear in the picker, but can be resumed with `claude --resume <session-id>` from the same directory.

From v2.1.169: `/cd` relocates a session to a new directory's project storage.

#### Naming Sessions

| When | How |
| :--- | :-- |
| At startup | `claude -n auth-refactor` |
| During a session | `/rename auth-refactor` |
| From session picker | Highlight + `Ctrl+R` |
| On plan accept (plan mode) | Set automatically from plan content |

#### Session Picker Shortcuts

| Shortcut | Action |
| :------- | :----- |
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand/collapse grouped sessions |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable char | Enter search / filter mode |
| `Ctrl+A` | Toggle all projects on this machine |
| `Ctrl+W` | Toggle all worktrees of current repository |
| `Ctrl+B` | Filter to current git branch |
| `Esc` | Exit picker or search mode |

Paste a GitHub, GitLab, or Bitbucket PR/MR URL in search to find the session that created it.

#### Branching Sessions

```text
/branch try-streaming-approach
```

Or from the command line:

```bash
claude --continue --fork-session
```

`/branch` leaves the original intact. Return to the original via its session ID or name. Permissions approved with "allow for this session" do not carry over to a branch.

For checkpoint-based rewind within a single session, see the Checkpointing documentation.

#### Context Management Commands

| Command | Description |
| :------ | :---------- |
| `/clear` | Start fresh; prior conversation saved and resumable |
| `/compact [instructions]` | Summarize history, optionally with focus |
| `/context` | Show context window usage |

#### Session Storage and Export

- Local transcripts: `~/.claude/projects/<project>/<session-id>.jsonl`
- Change location: set `CLAUDE_CONFIG_DIR`
- Default retention: 30 days (change with `cleanupPeriodDays` setting)
- Suppress transcript writes: set `CLAUDE_CODE_SKIP_PROMPT_HISTORY`, or use `--no-session-persistence` in non-interactive mode
- Export: `/export` copies to clipboard or a file

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `claude -p`, `--bare` mode, output formats, streaming, tool approval, system prompt flags, continuing conversations
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — GitHub auth, cloud environment config, setup scripts, network access, moving tasks between web and terminal, auto-fix PRs, security and isolation
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — First-time setup, connecting GitHub, starting tasks, reviewing and iterating on PRs, troubleshooting
- [Manage sessions](references/claude-code-sessions.md) — Resume, name, pick, branch, export sessions; transcript storage

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
