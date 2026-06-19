---
name: headless-doc
user-invocable: false
---

# Headless, Web, and Sessions Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (`claude -p`), using Claude Code on the web (Anthropic-managed cloud sessions), and managing sessions (resume, branch, export).

## Quick Reference

### Non-Interactive Mode (`claude -p`)

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Run non-interactively with a prompt; print response and exit |
| `--bare` | Skip hooks, skills, plugins, MCP, auto-memory, CLAUDE.md; use `ANTHROPIC_API_KEY`; recommended for CI |
| `--output-format text` | Plain text output (default) |
| `--output-format json` | Structured JSON: `result`, `session_id`, `total_cost_usd`, per-model cost breakdown |
| `--output-format stream-json` | Newline-delimited JSON for real-time streaming |
| `--json-schema '<schema>'` | Return structured output conforming to schema; result in `structured_output` field |
| `--verbose --include-partial-messages` | Stream tokens as generated (use with `stream-json`) |
| `--allowedTools "Read,Edit,Bash"` | Auto-approve listed tools without prompting |
| `--permission-mode acceptEdits` | Auto-approve file writes and common FS commands |
| `--permission-mode dontAsk` | Deny anything not in `permissions.allow` or read-only set |
| `--append-system-prompt` | Add instructions on top of default system prompt |
| `--system-prompt` | Fully replace the default system prompt |
| `--continue` | Resume most recent conversation |
| `--resume <id\|name>` | Resume a specific session by ID or name |
| `--no-session-persistence` | Suppress transcript writes in non-interactive mode |
| `--settings <file-or-json>` | Load settings (required for auth in `--bare` mode) |
| `--mcp-config <file-or-json>` | Load MCP servers explicitly |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin from local path |
| `--plugin-url <url>` | Load a plugin from URL |
| `--append-system-prompt-file` | Load system prompt additions from a file |

Stdin is read in non-interactive mode (capped at 10 MB). Pipe data in; redirect output like any shell tool. Background Bash tasks started during `-p` runs are terminated ~5 seconds after the final result is returned and stdin closes.

### Output Format: `stream-json` Events

| Event type | Subtype | Description |
| :--- | :--- | :--- |
| `system` | `init` | First event; reports model, tools, MCP servers, loaded plugins (`plugins`, `plugin_errors`) |
| `system` | `plugin_install` | Emitted when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set; status: `started`, `installed`, `failed`, `completed` |
| `system` | `api_retry` | Emitted before an API retry; fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error`, `uuid`, `session_id` |
| `stream_event` | — | Contains delta events; filter on `.event.delta.type == "text_delta"` for text tokens |

`error` field values in `api_retry`: `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `rate_limit`, `overloaded`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown`

### Cloud Sessions (Claude Code on the Web)

Access at [claude.ai/code](https://claude.ai/code). Sessions run on Anthropic-managed VMs; persist across browser closes; monitored from CLI or mobile app.

#### GitHub Authentication Methods

| Method | How | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install from browser onboarding | Teams wanting Auto-fix PR |
| **`/web-setup`** | Run inside Claude Code CLI | Developers already using `gh` CLI |

#### What Carries Over to Cloud Sessions

| Item | Available | Why |
| :--- | :--- | :--- |
| Repo `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/` | Yes | Part of the clone |
| Repo `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md`, skills, agents, commands | No | Lives on your machine |
| Plugins only in user `~/.claude/settings.json` | No | User-scoped settings not in repo |
| MCP servers added with `claude mcp add` | No | Writes to local user config |
| Static API tokens / credentials | No | No secrets store yet |
| Interactive auth (e.g., AWS SSO) | No | Requires browser login |

#### Pre-Installed Tools in Cloud Sessions

| Category | Included |
| :--- | :--- |
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun (proxy issues), eslint, prettier |
| Ruby | 3.1/3.2/3.3, gem, bundler, rbenv |
| PHP | 8.4, Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default — ask Claude to start) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

Run `check-tools` inside a cloud session for exact versions.

#### Cloud Session Resource Limits

- 4 vCPUs, 16 GB RAM, 30 GB disk (approximate; subject to change)

#### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches; skipped when cache is valid | After Claude Code launches; every session including resumed |
| Scope | Cloud only | Local and cloud |

Environment cache: setup script runs once; filesystem is snapshotted and reused for subsequent sessions. Cache expires after ~7 days or when setup script/allowed hosts change. Use `CLAUDE_CODE_REMOTE=true` in SessionStart hooks to skip local execution.

#### Network Access Levels

| Level | Outbound |
| :--- | :--- |
| None | No outbound access |
| Trusted | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist, optionally including defaults |

GitHub operations use a dedicated proxy regardless of access level. All outbound traffic passes through a security proxy (abuse prevention, rate limiting, content filtering, DNS audit trail). MCP connector traffic routes through Anthropic servers; no need to add connector hosts to the allowlist.

#### Moving Tasks Between Web and Terminal

| Action | Command |
| :--- | :--- |
| Start a cloud session from terminal | `claude --remote "prompt"` |
| Check progress of cloud tasks | `/tasks` in CLI |
| Pull a cloud session into terminal | `claude --teleport` or `claude --teleport <session-id>` |
| Switch to cloud session from inside CLI | `/teleport` or `/tp` |
| Force local-bundle upload (no GitHub) | `CCR_FORCE_BUNDLE=1 claude --remote "prompt"` |

`--remote` clones your current branch from GitHub; push local commits first. Bundle fallback activates when GitHub is unavailable; repository must be a git repo with at least one commit and under 100 MB.

Teleport requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account. Teleport requires claude.ai subscription auth — run `/login` if using API key.

#### Auto-Fix Pull Requests

Requires Claude GitHub App installed on the repository. Enable via:
- PRs created on the web: CI status bar → Auto-fix
- Terminal: `/autofix-pr` on the PR branch
- Mobile app: tell Claude to auto-fix the PR
- Any PR: paste the PR URL and ask Claude to auto-fix

Claude reacts to CI failures and review comments; posts replies under your GitHub username labeled "Claude Code". Disable when comment-triggered automation (Atlantis, Terraform Cloud) could trigger infrastructure deployments.

#### Pre-Fill Cloud Sessions via URL

| Parameter | Description |
| :--- | :--- |
| `prompt` / `q` | Prefill the prompt input |
| `prompt_url` | URL to fetch prompt text from (for long prompts) |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs to preselect |
| `environment` | Name or ID of the environment to preselect |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

### Session Management (CLI)

#### Resume Entry Points

| Command | What it does |
| :--- | :--- |
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open interactive session picker |
| `claude --resume <name\|id>` | Resume named or ID-referenced session directly |
| `claude --from-pr <number>` | Resume session linked to a pull request |
| `/resume` | Switch sessions from inside an active session |

Sessions created with `claude -p` or Agent SDK do not appear in the picker but are resumable by session ID. Session lookup is scoped to the current project directory and its git worktrees.

#### Session Picker Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand / collapse grouped sessions |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable char | Enter search / filter mode (paste a PR URL to find its session) |
| `Ctrl+A` | Widen to all projects on machine |
| `Ctrl+W` | Widen to all worktrees of current repo |
| `Ctrl+B` | Filter to current git branch |
| `Esc` | Exit picker or search mode |

#### Naming Sessions

| When | How |
| :--- | :--- |
| At startup | `claude -n <name>` |
| During a session | `/rename <name>` |
| From session picker | Highlight session, press `Ctrl+R` |
| On plan accept | Named automatically from plan content (plan mode) |

#### Branching Sessions

```
/branch try-streaming-approach
```

Or from CLI: `claude --continue --fork-session`

Branching copies the conversation so far and switches into the copy; original is unchanged in the picker. Forked sessions group under the root session in the picker (press `→` to expand).

#### Context Management Commands

| Command | Effect |
| :--- | :--- |
| `/clear` | Empty the context window; prior conversation saved and resumable |
| `/compact [instructions]` | Summarize history, optionally focused on specified content |
| `/context` | Show what is currently in the context window |
| `/export [filename]` | Copy conversation to clipboard or write to file |

#### Session Storage

Transcripts stored as JSONL at `~/.claude/projects/<project>/<session-id>.jsonl`. Default retention: 30 days (change with `cleanupPeriodDays` setting). Override directory with `CLAUDE_CONFIG_DIR`. Suppress transcript writes with `CLAUDE_CODE_SKIP_PROMPT_HISTORY` (interactive) or `--no-session-persistence` (non-interactive).

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — Non-interactive `-p` mode, `--bare`, output formats, streaming, piping, auto-approving tools, continuing conversations
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Cloud environments, setup scripts, network access, GitHub auth, `--remote`/`--teleport`, sessions, auto-fix PRs
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — Quickstart: connect GitHub, create an environment, submit a task, review and iterate, troubleshooting
- [Manage sessions](references/claude-code-sessions.md) — Resume, name, branch, session picker, export, transcript storage

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
