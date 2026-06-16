---
name: headless-doc
description: Complete official documentation for Claude Code non-interactive (headless) mode, Claude Code on the web, the web quickstart, and session management. Use when working with `claude -p`, `--bare`, `--output-format`, `--remote`, `--teleport`, cloud environments, setup scripts, network access, session resumption, branching, and transcript storage.
user-invocable: false
---

# Headless, Web, and Sessions Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (`claude -p`), using Claude Code on the web (cloud sessions), and managing sessions.

## Quick Reference

### Non-interactive mode (`claude -p`)

| Flag | Description |
| :--- | :--- |
| `-p <prompt>` / `--print <prompt>` | Run non-interactively and print the result |
| `--bare` | Skip hooks, skills, plugins, MCP, memory, and CLAUDE.md; require `ANTHROPIC_API_KEY` |
| `--allowedTools <list>` | Auto-approve named tools (comma-separated, supports permission rule syntax) |
| `--permission-mode <mode>` | `dontAsk` (deny unlisted), `acceptEdits` (allow file writes + common fs commands) |
| `--output-format <fmt>` | `text` (default), `json`, or `stream-json` |
| `--json-schema <schema>` | Return structured output conforming to a JSON Schema (use with `--output-format json`) |
| `--verbose` | Emit richer events; required for streaming text deltas |
| `--include-partial-messages` | Include partial streaming tokens in `stream-json` output |
| `--append-system-prompt <text>` | Add instructions to Claude's system prompt |
| `--append-system-prompt-file <path>` | Same, from a file |
| `--system-prompt <text>` | Fully replace the default system prompt |
| `--continue` | Resume the most recent session |
| `--resume <id>` | Resume a specific session by ID |
| `--no-session-persistence` | Suppress transcript writes in non-interactive mode |
| `--settings <file-or-json>` | Load settings (required for auth in `--bare`) |
| `--mcp-config <file-or-json>` | Load MCP servers (use in `--bare` to add servers explicitly) |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin for this invocation |
| `--plugin-url <url>` | Fetch and load a plugin `.zip` for this invocation |

**Recommended**: add `--bare` for CI/scripts so local config doesn't bleed in. `--bare` will become the default for `-p` in a future release.

**Stdin cap**: piped stdin is capped at 10 MB (as of v2.1.128). For larger input, write to a file and reference the path.

**Background tasks**: background Bash tasks started during `-p` are terminated ~5 seconds after Claude returns its final result and stdin closes.

### `--output-format json` response fields

| Field | Description |
| :--- | :--- |
| `result` | Plain-text response |
| `session_id` | Session identifier (use with `--resume`) |
| `total_cost_usd` | Cost for this invocation |
| `structured_output` | Present when `--json-schema` is used |

### `stream-json` event types (selected)

| Type / subtype | When emitted |
| :--- | :--- |
| `system` / `init` | First event; includes model, tools, plugins, plugin errors |
| `system` / `api_retry` | Before each retry on retryable errors |
| `system` / `plugin_install` | While marketplace plugins install (requires `CLAUDE_CODE_SYNC_PLUGIN_INSTALL`) |
| `stream_event` with `delta.type == "text_delta"` | Streaming text tokens |

### `system/api_retry` event fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `attempt` | integer | Current attempt, starting at 1 |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status, or `null` for connection errors |
| `error` | string | `authentication_failed`, `rate_limit`, `overloaded`, `server_error`, etc. |

### Common `-p` patterns

```bash
# Pipe and redirect
cat build-error.txt | claude -p 'explain the root cause' > output.txt

# Structured output with jq
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Schema-constrained output
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'

# Streaming text tokens
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'

# Continue a conversation
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

---

### Claude Code on the web — overview

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist across devices and browser closes; monitor them from the Claude mobile app.

**Comparison of run surfaces**

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| Uses local config | No (repo only) | Yes | Yes | Yes for local; no for cloud |
| Requires GitHub | Yes (or bundle via `--remote`) | No | No | Only for cloud sessions |
| Keeps running if disconnected | Yes | While terminal stays open | No | Depends |
| Permission modes | Accept edits, Plan, Auto | Ask, Auto accept edits, Plan | All modes | Depends |

### GitHub authentication options

| Method | How | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install during web onboarding at claude.ai/code | Browser onboarding; Auto-fix PR feature |
| **`/web-setup`** | Run in CLI to sync local `gh` token to Claude account | Developers already using `gh` CLI |

Either method grants access to any repo the connected GitHub account can see. GitHub App installation is required only for Auto-fix (PR webhooks).

### What carries over to cloud sessions

| Item | Available | Why |
| :--- | :--- | :--- |
| `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/` | Yes | Part of the repo clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed from marketplace at session start |
| `~/.claude/` files (CLAUDE.md, skills, agents) | No | Lives on your machine |
| Plugins enabled only in user settings | No | Commit to repo's `.claude/settings.json` instead |
| Static API tokens / credentials | No | No dedicated secrets store yet; use env vars |
| Interactive auth (AWS SSO, etc.) | No | Requires browser login |

### Pre-installed tools in cloud sessions

| Category | Included |
| :--- | :--- |
| Python | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun¹, eslint, prettier, chromedriver |
| Ruby | 3.1–3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven and Gradle |
| Go | Latest stable |
| Rust | rustc and cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues for package fetching.

Resource ceilings: ~4 vCPUs, 16 GB RAM, 30 GB disk.

### Network access levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** | Default allowlist (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including defaults |

GitHub operations use a separate proxy regardless of this setting. All outbound traffic passes through a security proxy for abuse prevention and content filtering.

### Setup scripts vs. SessionStart hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in your repo |
| Runs | Before Claude Code launches (only when no cached env) | After Claude launches, on every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Setup script tips:
- Scripts run as root on Ubuntu 24.04
- Total runtime must be under ~5 minutes to build the environment cache
- Run independent installs in parallel with `&` and `wait`
- Cache captures files, not running processes

Use `CLAUDE_CODE_REMOTE=true` env var in a SessionStart hook to skip local execution:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
npm install
```

### Environment variables useful in cloud sessions

| Variable | Description |
| :--- | :--- |
| `CLAUDE_CODE_REMOTE` | Set to `true` in cloud sessions |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | Session ID (uses `cse_` prefix; transcript URL uses `session_` prefix) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Trigger auto-compaction earlier (e.g. `70` for 70% capacity) |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Set to `1` to enable agent teams (off by default) |

### Moving tasks between web and terminal

**Terminal to web** (`--remote`): creates a new cloud session cloning your current repo's GitHub remote at the current branch. Push local commits first.

```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```

Options:
- `CCR_FORCE_BUNDLE=1` — force local bundle upload even when GitHub is configured
- Bundle limits: git repo required, under 100 MB, untracked files excluded

**Web to terminal** (`--teleport`): pulls a cloud session and its branch into your terminal.

```bash
claude --teleport              # interactive session picker
claude --teleport <session-id> # resume specific session
```

Teleport requirements: clean git working directory, correct repository, branch pushed to remote, same claude.ai account.

**`--teleport` vs `--resume`**: `--resume` reopens local history; `--teleport` pulls cloud sessions.

### Auto-fix pull requests

Requires the Claude GitHub App installed on the repository. When enabled, Claude monitors CI failures and review comments and pushes fixes automatically.

| Turn-on method | How |
| :--- | :--- |
| PRs created in web | Open CI status bar → select **Auto-fix** |
| From terminal | Run `/autofix-pr` on the PR branch |
| From mobile app | Tell Claude to watch and auto-fix the PR |
| Any existing PR | Paste PR URL into a session and ask Claude |

Auto-fix is per-PR. PR comment replies appear under your username but are labeled as coming from Claude Code.

---

### Session management (CLI)

| Entry point | What it does |
| :--- | :--- |
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open the interactive session picker |
| `claude --resume <name-or-id>` | Resume by name or session ID directly |
| `claude --from-pr <number>` | Resume the session linked to a pull request |
| `/resume` | Switch to another session from inside an active session |
| `-n <name>` / `claude -n auth-refactor` | Name a session at startup |
| `/rename <name>` | Rename the current session |

Sessions from `claude -p` or the Agent SDK do not appear in the picker, but can be resumed by ID.

### Session picker keyboard shortcuts

| Shortcut | Action |
| :--- | :--- |
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand/collapse grouped sessions |
| `Enter` | Resume highlighted session |
| `Space` / `Ctrl+V` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable char | Enter search / filter mode |
| `Ctrl+A` | Widen to all projects on this machine |
| `Ctrl+W` | Widen to all worktrees of current repository |
| `Ctrl+B` | Filter to current git branch |
| `Esc` | Exit picker or search mode |

### Session scope for picker and `--resume`

Session lookup is scoped to the current project directory and its git worktrees. From v2.1.169, `/cd` relocates a session to the new directory's project storage.

### Branching a session

```text
/branch try-streaming-approach
```

Or from the command line:

```bash
claude --continue --fork-session
```

Original session is unchanged and remains in the picker. Permissions approved with "allow for this session" do not carry over to the branch.

### Context management commands

| Command | Effect |
| :--- | :--- |
| `/clear` | Start fresh context; previous conversation saved and resumable |
| `/compact [instructions]` | Replace history with a focused summary |
| `/context` | Show what is currently consuming context window |

### Transcript storage

- Stored as JSONL at `~/.claude/projects/<project>/<session-id>.jsonl`
- Removed after 30 days by default (configure with `cleanupPeriodDays`)
- Override location with `CLAUDE_CONFIG_DIR`
- Suppress writes with `CLAUDE_CODE_SKIP_PROMPT_HISTORY` or `--no-session-persistence`
- Export current session: `/export` (clipboard or file)

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `claude -p`, `--bare` mode, output formats, streaming, auto-approve tools, piping, system prompts, continue/resume in non-interactive mode
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Cloud environments, GitHub auth, installed tools, setup scripts, network access levels, `--remote`/`--teleport`, session management, Auto-fix PRs, security and isolation, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — One-time setup, connecting GitHub, creating an environment, submitting tasks, pre-filling sessions via URL params, reviewing diffs, inline comments, creating PRs, troubleshooting
- [Manage sessions](references/claude-code-sessions.md) — Resume, name, branch, and switch between sessions; session picker; transcript export; context management within a session

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
