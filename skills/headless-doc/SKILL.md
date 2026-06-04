---
name: headless-doc
user-invocable: false
---

# Headless & Cloud Sessions Documentation

This skill provides the complete official documentation for running Claude Code programmatically (non-interactive / `-p` mode), using Claude Code on the web (cloud sessions), and managing sessions (resume, branch, export, context).

## Quick Reference

### Non-Interactive Mode (`claude -p`)

Run Claude Code without interaction by passing `-p` (or `--print`) with a prompt:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

Add `--bare` to skip auto-discovery of hooks, skills, plugins, MCP servers, CLAUDE.md, and auto memory. Recommended for CI and scripted calls:

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

In bare mode, only flags you pass explicitly take effect. Auth must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in `--settings`.

**Bare mode context loading options:**

| To load | Use |
|:--------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

### Output Formats

| Flag | Output |
|:-----|:-------|
| `--output-format text` | Plain text (default) |
| `--output-format json` | Structured JSON with `result`, `session_id`, cost metadata |
| `--output-format stream-json` | Newline-delimited JSON for real-time streaming |
| `--json-schema '<schema>'` | With `--output-format json` — enforces a JSON Schema; result in `structured_output` field |

Piped stdin is capped at 10 MB. Use `--verbose` and `--include-partial-messages` with `stream-json` to receive tokens as generated.

### Permission Modes in `-p`

| Mode | Behavior |
|:-----|:---------|
| `--allowedTools "Bash,Read,Edit"` | Approve specific tools without prompting |
| `--permission-mode acceptEdits` | Claude writes files freely; common filesystem commands auto-approved |
| `--permission-mode dontAsk` | Denies anything not in `permissions.allow` or the read-only command set |

### Continue / Resume Conversations

| Flag | Effect |
|:-----|:-------|
| `--continue` | Resume the most recent session |
| `--resume <session-id>` | Resume a specific session by ID |

### stream-json API Retry Event Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Identifies a retry event |
| `attempt` | integer | Current attempt (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | Category: `authentication_failed`, `billing_error`, `rate_limit`, `overloaded`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, or `unknown` |
| `uuid` | string | Unique event identifier |
| `session_id` | string | Session the event belongs to |

### system/init Event Plugin Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `plugins` | array | Successfully loaded plugins (each with `name` and `path`) |
| `plugin_errors` | array | Load-time errors (each with `plugin`, `type`, `message`); omitted when empty |

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist even when you close the browser; monitor from the Claude mobile app.

**What's available in cloud sessions:**

| Config | Available | Why |
|:-------|:----------|:----|
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/` | Yes | Part of the clone |
| Plugins in `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md`, user-scoped plugins | No | Lives on your machine |
| MCP servers added with `claude mcp add` | No | Writes to local user config |
| Static API tokens / secrets | No | No dedicated secrets store yet |
| Interactive auth like AWS SSO | No | Not supported |

**Pre-installed tools (partial list):**

| Category | Included |
|:---------|:---------|
| Python | Python 3.x, pip, poetry, uv, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, eslint, prettier |
| Ruby | 3.1–3.3 with gem, bundler, rbenv |
| Go | Latest stable |
| Rust | rustc, cargo |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux |

Run `check-tools` in a cloud session for exact versions.

**Resource limits (approximate, may change):** 4 vCPUs, 16 GB RAM, 30 GB disk.

### Network Access Levels

| Level | Outbound connections |
|:------|:---------------------|
| **None** | No outbound network access |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including defaults |

GitHub operations always use a dedicated proxy independent of this setting.

### GitHub Authentication for Cloud Sessions

| Method | How | Best for |
|:-------|:----|:---------|
| GitHub App | Authorize during web onboarding | Browser onboarding; teams wanting Auto-fix |
| `/web-setup` | Run in terminal to sync local `gh` token | Individual developers who already use `gh` |

### Move Tasks Between Web and Terminal

| Direction | How |
|:----------|:----|
| Terminal → Web | `claude --remote "Task description"` — creates a new cloud session on claude.ai |
| Web → Terminal | `claude --teleport` (interactive picker) or `claude --teleport <session-id>` |
| Inside session | `/teleport` (alias `/tp`) to switch to a cloud session; `/tasks` then `t` to teleport |

`--remote` clones your current directory's GitHub remote at your current branch. Push local commits first. For repos not on GitHub, Claude bundles and uploads the local repo automatically (limit: 100 MB).

**Teleport requirements:**

| Requirement | Detail |
|:------------|:-------|
| Clean git state | No uncommitted changes (prompts to stash) |
| Correct repository | Must run from the same repo (not a fork) |
| Branch available | Branch must have been pushed to remote |
| Same account | Must be authenticated to the same claude.ai account |

### Auto-fix Pull Requests

Claude can monitor a PR and automatically respond to CI failures and review comments. Requires the Claude GitHub App installed on the repository.

**Enable auto-fix:**
- PRs from Claude Code on the web: open CI status bar → select **Auto-fix**
- From terminal: run `/autofix-pr` while on the PR's branch
- From mobile app: tell Claude to auto-fix the PR
- Any existing PR: paste the PR URL and ask Claude to auto-fix it

### Setup Scripts vs. SessionStart Hooks

|  | Setup scripts | SessionStart hooks |
|--|:-------------|:-------------------|
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches (when no cache available) | After Claude Code launches, on every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Setup script cache is rebuilt when the script changes or after ~7 days. Keep scripts under ~5 minutes total.

Use `CLAUDE_CODE_REMOTE=true` env var (set automatically in cloud sessions) in a SessionStart hook to skip local execution:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

### Session Management (CLI)

| Command | Effect |
|:--------|:-------|
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open interactive session picker |
| `claude --resume <name>` | Resume named session directly |
| `claude --from-pr <number>` | Resume session linked to that PR |
| `/resume` | Switch to different conversation from inside active session |
| `claude -n <name>` | Start new session with a name |
| `/rename <name>` | Rename current session |
| `/branch [name]` | Fork current session to try a different approach |
| `claude --continue --fork-session` | Combine resume + branch from command line |

**Session picker keyboard shortcuts:**

| Shortcut | Action |
|:---------|:-------|
| `↑` / `↓` | Navigate sessions |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable char | Search / filter |
| `Ctrl+A` | Widen to all projects on machine |
| `Ctrl+W` | Widen to all worktrees of current repo |
| `Ctrl+B` | Filter to current git branch |

### Session Data & Export

- Transcripts stored at `~/.claude/projects/<project>/<session-id>.jsonl`
- Change location with `CLAUDE_CONFIG_DIR` env var
- Default retention: 30 days (change with `cleanupPeriodDays` setting)
- `/export` — copy conversation to clipboard or write to file
- Suppress transcript writes: set `CLAUDE_CODE_SKIP_PROMPT_HISTORY`, or use `--no-session-persistence` in non-interactive mode

### Context Management Within a Session

| Command | Effect |
|:--------|:-------|
| `/clear` | Start fresh context (conversation saved and resumable) |
| `/compact [instructions]` | Replace history with a focused summary |
| `/context` | Show current context window contents |

Auto-compaction triggers at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `70` for 70%).

### Pre-fill Web Sessions via URL

| Parameter | Description |
|:----------|:------------|
| `prompt` (alias `q`) | Prompt text to prefill |
| `prompt_url` | URL to fetch prompt from (ignored if `prompt` set) |
| `repositories` (alias `repo`) | Comma-separated `owner/repo` slugs to preselect |
| `environment` | Name or ID of environment to preselect |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

### Session Sharing (Cloud)

| Plan | Visibility options |
|:-----|:-------------------|
| Enterprise / Team | Private or Team (visible to org members; repo access verified by default) |
| Max / Pro | Private or Public (visible to any logged-in claude.ai user) |

### Cloud-Session Limitations

- Rate limits shared with all Claude and Claude Code usage in your account
- Only GitHub supported for session handoff; GitLab/Bitbucket repos can be bundled but cannot push back
- Organization IP allowlists block cloud sessions (contact Anthropic support to exempt)
- No dedicated secrets store; env vars visible to anyone who can edit the environment

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) — `-p` / headless mode, `--bare`, piping stdin, output formats, streaming, tool auto-approval, system prompt flags, continue/resume
- [Use Claude Code on the Web](references/claude-code-on-the-web.md) — Cloud environments, setup scripts, network access, GitHub auth, moving sessions with `--remote` and `--teleport`, auto-fix PRs, session management, security, limitations
- [Get Started with Claude Code on the Web](references/claude-code-web-quickstart.md) — One-time setup, connecting GitHub, starting tasks, reviewing diffs, inline comments, creating PRs, troubleshooting
- [Manage Sessions](references/claude-code-sessions.md) — Resume, name, branch, export, and navigate sessions; session picker shortcuts; transcript storage; context management

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get Started with Claude Code on the Web: https://code.claude.com/docs/en/web-quickstart.md
- Manage Sessions: https://code.claude.com/docs/en/sessions.md
