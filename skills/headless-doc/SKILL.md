---
name: headless-doc
description: Complete official documentation for Claude Code headless/programmatic CLI mode and Claude Code on the web — covering `-p` flag usage, output formats, bare mode, permission modes, cloud sandbox environments, setup scripts, network access, and moving sessions between web and terminal.
user-invocable: false
---

# Headless Mode Documentation

This skill provides the complete official documentation for running Claude Code programmatically (headless / `-p` mode) and using Claude Code on the web via Anthropic's cloud sandbox.

## Quick Reference

### Headless CLI (`claude -p`)

Run Claude Code non-interactively. Built-in slash commands and user-invoked skills are not available in `-p` mode — describe the task instead.

| Flag | Purpose |
|---|---|
| `-p "prompt"` / `--print` | Run non-interactively, print response, exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, memory, CLAUDE.md (recommended for CI/SDK) |
| `--output-format <fmt>` | `text` (default), `json`, `stream-json` |
| `--json-schema '<schema>'` | Constrain output to JSON Schema (populates `structured_output` field) |
| `--verbose` | Required with `stream-json`; useful during development |
| `--include-partial-messages` | Stream token-by-token deltas |
| `--allowedTools "Tool,Bash(git diff *)"` | Pre-approve tools using permission-rule syntax |
| `--permission-mode <mode>` | Set session-wide permission baseline |
| `--append-system-prompt` / `--append-system-prompt-file` | Add to default system prompt |
| `--system-prompt` | Replace default system prompt |
| `--settings <file-or-json>` | Provide settings in bare mode |
| `--mcp-config <file-or-json>` | Provide MCP servers in bare mode |
| `--agents <json>` | Provide custom agents in bare mode |
| `--plugin-dir <path>` | Load a plugin directory |
| `--continue` | Continue most recent conversation |
| `--resume <session_id>` | Resume a specific session |

### Output formats

| Format | Structure |
|---|---|
| `text` | Plain text response (default) |
| `json` | Single JSON object: `result`, `session_id`, usage metadata, `structured_output` if `--json-schema` used |
| `stream-json` | Newline-delimited JSON events as they occur |

Parse with `jq`, e.g. extract the result via `jq -r '.result'` or filter text deltas with `jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'`.

### `system/api_retry` event fields

| Field | Meaning |
|---|---|
| `type` / `subtype` | `"system"` / `"api_retry"` |
| `attempt` / `max_retries` | Current attempt and ceiling |
| `retry_delay_ms` | ms until next attempt |
| `error_status` | HTTP status, or `null` for connection errors |
| `error` | `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |
| `uuid`, `session_id` | Event and session identifiers |

### Permission modes for headless runs

| Mode | Behavior |
|---|---|
| `default` | Normal prompting (will abort in `-p` with no user) |
| `plan` | Read-only planning, no edits |
| `auto` | Classifier approves/blocks; aborts after repeated blocks in `-p` |
| `acceptEdits` | Auto-approves writes and common FS commands (`mkdir`, `touch`, `mv`, `cp`); other shell/network still need allowlist |
| `dontAsk` | Denies anything not in `permissions.allow` (locked-down CI) |
| `bypassPermissions` | Skips checks (not on web) |

### Bare mode specifics

Bare mode skips OAuth and keychain reads. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON. Bedrock/Vertex/Foundry use their usual provider credentials. In bare mode Claude has Bash, file read, and file edit tools — pass anything else explicitly.

### Claude Code on the web — at a glance

Research preview at [claude.ai/code](https://claude.ai/code) for Pro, Max, Team, and Enterprise premium/chat+code seats. Each session runs in a fresh Anthropic-managed VM with your repo cloned.

| Feature | Supported |
|---|---|
| Repo `CLAUDE.md`, `.claude/settings.json` hooks, `.mcp.json`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/`, `.claude/rules/` | Yes (part of clone) |
| Plugins declared in repo `.claude/settings.json` | Yes |
| User `~/.claude/CLAUDE.md`, user-scoped plugins, `claude mcp add` entries | No |
| Static API tokens, AWS SSO / interactive auth | No (no secrets store yet) |
| Built-in GitHub tools (issues, PRs, diffs, comments) | Yes, via GitHub proxy |
| `gh` CLI | Not pre-installed; install in setup script + set `GH_TOKEN` |
| `/compact`, `/context` | Yes |
| `/clear`, `/model`, `/config` | No |
| Permission modes | Auto accept edits, Plan only |
| Zero Data Retention orgs | Cannot use cloud sessions |

### GitHub auth options

| Method | How | Best for |
|---|---|---|
| GitHub App | Install on specific repos during web onboarding | Per-repo authorization for teams |
| `/web-setup` | Syncs local `gh` CLI token to Claude account | Individuals using `gh` |

GitHub App is required for Auto-fix PRs (webhook delivery).

### Resource limits (cloud VM)

| Resource | Approximate ceiling |
|---|---|
| vCPUs | 4 |
| RAM | 16 GB |
| Disk | 30 GB |

Pre-installed: Python 3.x (pip, poetry, uv, black, mypy, pytest, ruff), Node.js 20/21/22 via nvm (npm, yarn, pnpm, bun, eslint, prettier, chromedriver), Ruby 3.1/3.2/3.3, PHP 8.4 + Composer, OpenJDK 21 + Maven/Gradle, Go, Rust, GCC/Clang/cmake/ninja/conan, Docker + compose, PostgreSQL 16, Redis 7.0, git, jq, yq, ripgrep, tmux, vim, nano. Run `check-tools` for exact versions.

### Network access levels

| Level | Outbound |
|---|---|
| None | Blocked |
| Trusted (default) | Allowlisted package registries, GitHub, cloud SDKs |
| Full | Any domain |
| Custom | Your allowlist (one per line, `*.` wildcard), optionally plus defaults |

GitHub ops go through a separate proxy that scopes credentials and restricts `git push` to the current branch.

### Setup scripts vs. SessionStart hooks

|   | Setup script | SessionStart hook |
|---|---|---|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches, new sessions only | After Claude Code launches, every session including resumed |
| Scope | Cloud only | Local and cloud |

Setup scripts run as root on Ubuntu 24.04. Non-zero exit blocks the session — append `|| true` to non-critical commands. Use `$CLAUDE_CODE_REMOTE == "true"` in a SessionStart hook to skip local execution.

### Session handoff between web and terminal

| Command | Effect |
|---|---|
| `claude --remote "prompt"` | Start new cloud session for current repo's GitHub remote at current branch |
| `CCR_FORCE_BUNDLE=1 claude --remote ...` | Force local-repo bundle upload instead of GitHub clone (under 100 MB; tracked files only) |
| `claude --teleport` | Interactive picker to pull a cloud session to the terminal |
| `claude --teleport <session-id>` | Pull specific cloud session |
| `/teleport` or `/tp` | Teleport from inside an existing CLI session |
| `/tasks` then `t` | Teleport from the task list |
| Open in CLI (web) | Copy command from web UI |

Teleport requires clean git state, correct repo (not a fork), branch pushed to remote, and same claude.ai account. Handoff is one-way from the CLI: `--teleport` pulls cloud to local, but there's no push-local-to-web flag (the Desktop app offers Continue in).

### Session visibility

| Account type | Options |
|---|---|
| Enterprise / Team | Private, Team (verifies repo access by default) |
| Max / Pro | Private, Public (any logged-in claude.ai user) |

### Pre-fill URL parameters

| Parameter | Purpose |
|---|---|
| `prompt` (alias `q`) | Prefill prompt text |
| `prompt_url` | URL to fetch prompt from (CORS-allowed); ignored if `prompt` is set |
| `repositories` (alias `repo`) | Comma-separated `owner/repo` slugs |
| `environment` | Name or ID of cloud environment |

URL-encode values.

### Auto-fix pull requests

| Trigger | Action |
|---|---|
| PR created in Claude Code on the web | Open CI status bar, select Auto-fix |
| Terminal on PR branch | Run `/autofix-pr` |
| Mobile app | Tell Claude to auto-fix the PR |
| Any existing PR | Paste PR URL into a session |

Requires the Claude GitHub App. Claude replies to review threads under your GitHub username, labeled as coming from Claude Code. Warning: comment-triggered automations (Atlantis, Terraform Cloud, custom Actions on `issue_comment`) can fire from Claude's replies.

### Web quickstart steps

1. Visit [claude.ai/code](https://claude.ai/code) and sign in.
2. Install the Claude GitHub App and grant repo access (create an empty repo first for new projects).
3. Create an environment (Name, Network access, Environment variables in `.env` format without quotes, Setup script). Defaults work for a first project.
4. Alternative terminal setup: `gh auth login`, then `/login` in Claude Code, then `/web-setup`.
5. Select repository + branch, choose permission mode (Auto accept edits or Plan), describe task, submit.
6. Review diff, leave inline comments (queued with next message), select Create PR.

### Key environment variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Auth for bare mode / SDK |
| `CLAUDE_CODE_REMOTE` | `"true"` inside cloud sessions |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | Cloud session ID (link back with `https://claude.ai/code/$CLAUDE_CODE_REMOTE_SESSION_ID`) |
| `CLAUDE_PROJECT_DIR` | Repo root, used in hook commands |
| `CLAUDE_ENV_FILE` | Write `KEY=value` lines to persist env for subsequent Bash commands |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Trigger auto-compact earlier (e.g. `70`) |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Effective window size for compaction calculations |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | Enable agent teams in cloud |
| `GH_TOKEN` | Picked up automatically by `gh` in cloud sessions |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically (headless)](references/claude-code-headless.md) — The `-p` CLI: bare mode, output formats (text/json/stream-json), JSON Schema output, streaming deltas, `system/api_retry` events, `--allowedTools` and permission modes, `--append-system-prompt`, and `--continue`/`--resume`.
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Cloud environments: GitHub auth (App vs `/web-setup`), what carries over from the repo, installed tools, resource limits, setup scripts vs SessionStart hooks, network access levels and the full default-allowed-domains list, security proxies, `--remote` and `--teleport`, session management, auto-fix PRs, security isolation, and limitations.
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — First-time setup: connect GitHub, create an environment, submit a task, review diff and create a PR; includes a comparison table for web vs Remote Control vs Terminal vs Desktop, pre-fill URL params, and troubleshooting.

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
