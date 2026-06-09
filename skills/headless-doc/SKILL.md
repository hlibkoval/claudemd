---
name: headless-doc
user-invocable: false
---

# Headless, Web, and Sessions Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (`-p` / headless mode), using Claude Code on the web (cloud sessions), and managing sessions (resume, naming, branching, exporting).

## Quick Reference

### Non-Interactive Mode (`claude -p`)

The `-p` / `--print` flag runs Claude non-interactively. All CLI options work with it.

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

Add `--bare` for scripts and CI to skip auto-discovery of hooks, skills, plugins, MCP servers, CLAUDE.md, and auto memory. Bare mode is the recommended mode for scripted/SDK calls (will become the default for `-p` in a future release) and requires `ANTHROPIC_API_KEY` (no OAuth/keychain).

**Bare mode context flags:**

| To load | Use |
|:--------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

**Output formats (`--output-format`):**

| Format | Description |
|:-------|:------------|
| `text` (default) | Plain text output |
| `json` | Structured JSON with `result`, `session_id`, `total_cost_usd`, and metadata |
| `stream-json` | Newline-delimited JSON for real-time streaming |

Use `--json-schema` with `--output-format json` to get structured output conforming to a JSON Schema; the structured result is in the `structured_output` field.

**`stream-json` `system/api_retry` event fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or `null` for connection errors |
| `error` | string | Error category: `authentication_failed`, `billing_error`, `rate_limit`, `overloaded`, `server_error`, `max_output_tokens`, `unknown`, etc. |
| `uuid` | string | Unique event identifier |
| `session_id` | string | Session the event belongs to |

**`system/init` event plugin fields (first event in the stream):**

| Field | Type | Description |
|:------|:-----|:------------|
| `plugins` | array | Successfully loaded plugins, each with `name` and `path` |
| `plugin_errors` | array | Load-time errors, each with `plugin`, `type`, and `message`; absent when there are no errors |

**`system/plugin_install` event fields** (emitted when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set, before `system/init`):

| Field | Type | Description |
|:------|:-----|:------------|
| `status` | string | `"started"`, `"installed"`, `"failed"`, or `"completed"` |
| `name` | string (optional) | Marketplace name, present on `installed` and `failed` |
| `error` | string (optional) | Failure message, present on `failed` |

**Permission modes with `-p`:**

| Flag/Mode | Effect |
|:----------|:-------|
| `--allowedTools "Bash,Read,Edit"` | Auto-approve specific tools |
| `--permission-mode dontAsk` | Deny anything not in `permissions.allow` or the read-only set |
| `--permission-mode acceptEdits` | Auto-approve file writes and common filesystem commands (other shell/network commands still need explicit approval) |

**Common patterns:**

```bash
# Pipe data through Claude (stdin capped at 10 MB)
cat build-error.txt | claude -p "explain the root cause" > output.txt

# JSON output with jq
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Structured output with schema
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}' \
  | jq '.structured_output'

# Stream tokens in real time
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages

# Commit workflow with prefix-matched tool permissions (space before * is required)
claude -p "Look at staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"

# Continue a conversation
claude -p "Review this codebase for performance issues"
claude -p "Now focus on database queries" --continue

# Resume a specific session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

**Other notes:**
- Piped stdin is capped at 10 MB; reference file paths in prompts for larger inputs.
- Background Bash tasks are terminated ~5 seconds after the final result and stdin closes.
- User-invocable skills and built-in commands are only available in interactive mode; describe the task instead.
- Agent SDK credit note (starting June 15, 2026): `-p` usage on subscription plans draws from a separate monthly Agent SDK credit.

---

### Claude Code on the Web (Cloud Sessions)

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist across devices and can be monitored from the Claude mobile app.

**Compare ways to run Claude Code:**

| | On the web | Remote Control | Terminal CLI | Desktop app |
|:-|:-----------|:---------------|:-------------|:------------|
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| You chat from | claude.ai or mobile | claude.ai or mobile | Terminal | Desktop UI |
| Uses local config | No (repo only) | Yes | Yes | Yes for local; no for cloud |
| Requires GitHub | Yes (or bundle via `--remote`) | No | No | Only for cloud sessions |
| Keeps running if disconnected | Yes | While terminal open | No | Depends on session type |
| Permission modes | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends |
| Network access | Configurable per environment | Your machine | Your machine | Depends |

**GitHub authentication options:**

| Method | How | Best for |
|:-------|:----|:---------|
| GitHub App | Authorize during web onboarding | Browser setup; required for Auto-fix |
| `/web-setup` | Syncs local `gh` CLI token to Claude account | Devs already using `gh` CLI |

**What's available in cloud sessions:**

| Config | Available | Reason |
|:-------|:----------|:-------|
| Repo `CLAUDE.md`, `.claude/settings.json` hooks, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in repo `.claude/settings.json` | Yes | Installed at session start from marketplace |
| `~/.claude/CLAUDE.md`, user-only plugins, `claude mcp add` servers | No | User-scoped, not in repo |
| Static API tokens / credentials | No | No dedicated secrets store yet |
| Interactive auth (AWS SSO, etc.) | No | Requires browser-based login |

**Cloud environment installed tools:**

| Category | Included |
|:---------|:---------|
| Python | 3.x, pip, poetry, uv, pytest, ruff, mypy, black |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun¹, eslint, prettier, chromedriver |
| Ruby | 3.1–3.3, gem, bundler, rbenv |
| PHP | 8.4, Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default — ask Claude or use a SessionStart hook) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues with package fetching. Run `check-tools` (cloud-only command) for exact versions.

**Resource limits:** ~4 vCPUs, 16 GB RAM, 30 GB disk.

**Environment caching:** Setup script runs the first time a session starts in an environment; Anthropic snapshots the filesystem and reuses it for subsequent sessions. Cache rebuilds when the setup script or allowed network hosts change, or after ~7 days.

**Setup scripts vs. SessionStart hooks:**

| | Setup scripts | SessionStart hooks |
|:-|:-------------|:------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude launches; skipped when cache exists | After Claude launches, on every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Use `CLAUDE_CODE_REMOTE=true` in a SessionStart hook to skip execution locally. Write env vars for subsequent Bash commands to `$CLAUDE_ENV_FILE`.

**Network access levels:**

| Level | Outbound connections |
|:------|:--------------------|
| None | No outbound access |
| Trusted (default) | Allowlisted domains: package registries, GitHub, cloud SDKs |
| Full | Any domain |
| Custom | Your own allowlist, optionally including the Trusted defaults |

GitHub operations always use a separate proxy independent of the network access level (scoped credentials, push restricted to current branch).

**Link artifacts back to the session (`CLAUDE_CODE_REMOTE_SESSION_ID`):**

```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

**`--remote` (terminal to web):** Creates a new cloud session for the current repo's GitHub remote at the current branch. Push local commits first (VM clones from GitHub). Use `CCR_FORCE_BUNDLE=1` to bundle the repo directly (also activates automatically when GitHub isn't configured).

Bundle limits: must be a git repo with at least one commit, under 100 MB (falls back to current branch only, then single squashed snapshot); untracked files not included; can't push back without GitHub auth.

**`--teleport` (web to terminal):** Pulls a cloud session and its branch to your terminal. Requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account. Also accessible via `/teleport` or `/tp` inside an active CLI session, from `/tasks` (press `t`), or via the web's "Open in CLI" button.

**Teleport vs. resume:** `--teleport` pulls cloud sessions and checks out their branch; `--resume` reopens local history only and does not list cloud sessions.

**Auto-fix pull requests:** Requires the Claude GitHub App. Toggle per-PR via the CI status bar in the web session, `/autofix-pr` in the terminal (auto-detects open PR via `gh`), via the mobile app, or by pasting a PR URL into a session. Claude responds to CI failures and review comments; replies under your GitHub username, labeled as coming from Claude Code.

Warning: if your repo uses comment-triggered automation (Atlantis, Terraform Cloud, custom `issue_comment` Actions), auto-fix can trigger those workflows.

**Context management in cloud sessions:**

| Command | Available | Notes |
|:--------|:----------|:------|
| `/compact [instructions]` | Yes | Accepts optional focus instructions |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

Auto-compaction runs at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=<percent>`. Change effective window size for compaction calculations with `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

**Pre-fill URL parameters for claude.ai/code:**

| Parameter | Description |
|:----------|:------------|
| `prompt` (alias `q`) | Prefill the input box |
| `prompt_url` | Fetch prompt from URL (ignored when `prompt` is set); URL must allow cross-origin requests |
| `repositories` (alias `repo`) | Comma-separated `owner/repo` slugs |
| `environment` | Environment name or ID |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

**Session sharing visibility:**

| Account type | Options |
|:-------------|:--------|
| Enterprise/Team | Private or Team (visible to org members; repo access verification enabled by default) |
| Max/Pro | Private or Public (visible to any logged-in claude.ai user; repo access verification off by default) |

---

### Session Management (CLI)

Sessions are saved continuously as JSONL to `~/.claude/projects/<project>/<session-id>.jsonl`. Cleanup period defaults to 30 days (`cleanupPeriodDays` setting). Override storage location with `CLAUDE_CONFIG_DIR`. Suppress transcript writes with `CLAUDE_CODE_SKIP_PROMPT_HISTORY` or `--no-session-persistence` in `-p` mode.

**Resume entry points:**

| Command | What it does |
|:--------|:-------------|
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open the interactive session picker |
| `claude --resume <name>` | Resume named session directly |
| `claude --from-pr <number>` | Resume session linked to that PR |
| `/resume` | Switch sessions from inside an active session |

Sessions created with `claude -p` or the Agent SDK do not appear in the picker, but can be resumed by passing their session ID to `claude --resume <session-id>`.

**Session picker keyboard shortcuts:**

| Shortcut | Action |
|:---------|:-------|
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand/collapse grouped (forked) sessions |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or any printable char | Filter/search mode; paste a GitHub/GitLab/Bitbucket PR URL to find the session that created it |
| `Ctrl+A` | Widen to all projects on this machine (press again to return) |
| `Ctrl+W` | Widen to all worktrees of current repo (multi-worktree repos only) |
| `Ctrl+B` | Filter to current git branch |
| `Esc` | Exit picker or search mode |

**Naming sessions:**

| When | How |
|:-----|:----|
| At startup | `claude -n auth-refactor` |
| During a session | `/rename auth-refactor` |
| From session picker | Highlight and press `Ctrl+R` |
| On plan accept | Auto-named from plan content (if no name set) |

Resume by name with `claude --resume <name>` or `/resume <name>`. Name resolution works across worktrees of the current repo.

| Command | Exact match | Ambiguous name |
|:--------|:------------|:---------------|
| `claude --resume <name>` | Resumes directly | Opens picker with name pre-filled |
| `/resume <name>` | Resumes directly | Reports an error; run `/resume` to open picker |

**Branching sessions:** `/branch [name]` inside a session creates a copy and switches to it; original is unchanged. From CLI: `claude --continue --fork-session`. "Allow for this session" permissions do not carry over to the branch. Forked sessions are grouped under their root in the picker (press `→` to expand).

**Context management:**

| Command | Effect |
|:--------|:-------|
| `/clear` | Start fresh; previous conversation is saved and resumable |
| `/compact [instructions]` | Replace history with a focused summary |
| `/context` | Show current context window contents |

**Export:** `/export` copies the conversation to clipboard or writes to a plain-text file. Pass a filename to write directly: `/export transcript.txt`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — Non-interactive `-p` mode: bare mode, piping, structured output, streaming, auto-approve tools, continue/resume
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Full cloud session reference: GitHub auth, environment config, setup scripts, network access, `--remote`/`--teleport`, auto-fix, security, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — Quickstart: connect GitHub, create environment, submit tasks, review diffs, create PRs, troubleshoot setup
- [Manage sessions](references/claude-code-sessions.md) — Session resume, naming, picker navigation, branching, context management, export, and transcript storage

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
