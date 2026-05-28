---
name: headless-doc
user-invocable: false
---

# Headless / Non-Interactive & Web Sessions Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (`claude -p`), Claude Code on the web, and session management.

## Quick Reference

### Non-Interactive (Headless) Mode

Run Claude Code without interaction by passing `-p` (or `--print`) with a prompt:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

#### Key Flags for `-p` Mode

| Flag | Description |
|:-----|:------------|
| `-p` / `--print` | Run non-interactively; print response and exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md (recommended for CI) |
| `--output-format <fmt>` | `text` (default), `json`, or `stream-json` |
| `--json-schema <schema>` | JSON Schema for structured output (use with `--output-format json`) |
| `--include-partial-messages` | Emit tokens as generated (use with `stream-json`) |
| `--allowedTools <list>` | Comma-separated tools to auto-approve |
| `--permission-mode <mode>` | `dontAsk`, `acceptEdits`, etc. |
| `--append-system-prompt <text>` | Add instructions to default system prompt |
| `--system-prompt <text>` | Fully replace default system prompt |
| `--append-system-prompt-file <path>` | Load system prompt additions from file |
| `--continue` | Resume most recent conversation |
| `--resume <id>` | Resume a specific session by ID |
| `--no-session-persistence` | Suppress transcript writes |

#### Bare Mode: What It Loads vs. Skips

| To load in bare mode | Use |
|:---------------------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

In bare mode, authentication must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON (no OAuth/keychain).

#### Output Formats

| Format | Description | Key fields |
|:-------|:------------|:-----------|
| `text` | Plain text response | — |
| `json` | Structured payload | `result`, `session_id`, `total_cost_usd`, `structured_output` (with `--json-schema`) |
| `stream-json` | Newline-delimited JSON events | `type`, `event.delta.text` for text tokens |

#### `system/api_retry` Stream Event Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code |
| `error` | string | Category: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown` |

#### `system/init` Stream Event: Plugin Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `plugins` | array | Loaded plugins, each with `name` and `path` |
| `plugin_errors` | array | Load-time errors, each with `plugin`, `type`, `message` |

#### Permission Rule Syntax for `--allowedTools`

Trailing ` *` enables prefix matching. A space before `*` matters: `Bash(git diff *)` matches any command starting with `git diff `, while `Bash(git diff*)` would also match `git diff-index`.

#### Stdin Cap

Piped stdin is capped at 10 MB (as of v2.1.128). For larger inputs, write content to a file and reference the path in the prompt.

---

### Session Management

#### Resume Entry Points

| Command | What it does |
|:--------|:-------------|
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open the interactive session picker |
| `claude --resume <name>` | Resume named session directly |
| `claude --from-pr <number>` | Resume session linked to that pull request |
| `/resume` | Switch to a different conversation from inside a session |

Sessions created with `claude -p` or the Agent SDK do not appear in the session picker, but can be resumed by session ID: `claude --resume <session-id>`.

#### Session Naming

| When | How |
|:-----|:----|
| At startup | `claude -n auth-refactor` |
| During a session | `/rename auth-refactor` |
| From session picker | Highlight a session and press `Ctrl+R` |
| On plan accept | Automatically named from plan content (if not already set) |

#### Session Picker Keyboard Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand or collapse grouped sessions |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable key | Enter search mode |
| `Ctrl+A` | Show sessions from all projects on this machine |
| `Ctrl+W` | Show sessions from all worktrees of current repo |
| `Ctrl+B` | Filter to sessions from current branch |
| `Esc` | Exit picker or search mode |

#### Branching Sessions

```bash
# From inside a session
/branch try-streaming-approach

# From the command line
claude --continue --fork-session
```

Branching creates a copy of the conversation; the original is unchanged. Permissions approved with "allow for this session" do not carry over to the branch.

#### Session Storage

Transcripts stored at `~/.claude/projects/<project>/<session-id>.jsonl`. Override location with `CLAUDE_CONFIG_DIR`. Retention default is 30 days; configurable with `cleanupPeriodDays`.

Use `/export` to copy conversation to clipboard or save as plain text.

---

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist if you close your browser.

#### Comparison: Ways to Run Claude Code

| | On the web | Remote Control | Terminal CLI | Desktop app |
|:--|:-----------|:---------------|:-------------|:------------|
| **Code runs on** | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| **Uses local config** | No, repo only | Yes | Yes | Yes for local, no for cloud |
| **Requires GitHub** | Yes (or bundle) | No | No | Only for cloud sessions |
| **Persists if disconnected** | Yes | While terminal open | No | Depends |
| **Permission modes** | Auto accept edits, Plan | All | All | Depends |

#### GitHub Authentication Options

| Method | Best for |
|:-------|:---------|
| **GitHub App** (browser onboarding) | Teams wanting Auto-fix; PR webhooks |
| **`/web-setup`** (syncs `gh` CLI token) | Individual developers already using `gh` |

#### What's Available in Cloud Sessions

| Config | Available | Why |
|:-------|:----------|:----|
| Repo's `CLAUDE.md` | Yes | Part of the clone |
| Repo's `.claude/settings.json` hooks | Yes | Part of the clone |
| Repo's `.mcp.json` MCP servers | Yes | Part of the clone |
| Repo's `.claude/skills/`, `.claude/agents/` | Yes | Part of the clone |
| Plugins in repo's `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| MCP servers added with `claude mcp add` | No | Written to local user config |
| Static API tokens/credentials | No | No dedicated secrets store yet |
| Interactive auth (e.g. AWS SSO) | No | Not supported |

#### Pre-installed Tools in Cloud Sessions

| Category | Included |
|:---------|:---------|
| **Python** | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| **Node.js** | v20/21/22 via nvm, npm, yarn, pnpm, bun¹, eslint, prettier |
| **Ruby** | 3.1/3.2/3.3, gem, bundler, rbenv |
| **PHP** | 8.4, Composer |
| **Java** | OpenJDK 21, Maven, Gradle |
| **Go** | latest stable |
| **Rust** | rustc, cargo |
| **C/C++** | GCC, Clang, cmake, ninja, conan |
| **Docker** | docker, dockerd, docker compose |
| **Databases** | PostgreSQL 16, Redis 7.0 (not running by default) |
| **Utilities** | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues for package fetching.

Resource limits: ~4 vCPUs, 16 GB RAM, 30 GB disk.

#### Network Access Levels

| Level | Outbound connections |
|:------|:--------------------|
| **None** | No outbound network access |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including the defaults |

#### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
|:-|:-------------|:-------------------|
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches; cached after first run | After Claude Code launches, every session |
| Scope | Cloud only | Both local and cloud |

Setup script tips: keep total runtime under ~5 minutes to allow environment caching. Run independent installs in parallel with `&` and `wait`. Cache stores files, not running processes.

Environment variable to detect cloud context in hooks/scripts: `CLAUDE_CODE_REMOTE=true`.

To persist env vars for subsequent Bash commands in a hook, write to `$CLAUDE_ENV_FILE`.

#### Move Tasks Between Web and Terminal

**Terminal to web** — start a new cloud session:
```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```

**Web to terminal** — pull a cloud session locally:
```bash
claude --teleport                  # interactive picker
claude --teleport <session-id>     # direct
```

Also from inside a CLI session: `/teleport` (or `/tp`), or from `/tasks` press `t`.

`--teleport` requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account.

#### Link Artifacts to Cloud Session

Each cloud session exposes its ID via `CLAUDE_CODE_REMOTE_SESSION_ID` (prefix `cse_`). Build the transcript URL:

```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

#### Session Pre-fill URL Parameters

| Parameter | Description |
|:----------|:------------|
| `prompt` (alias `q`) | Prefill prompt text |
| `prompt_url` | URL to fetch prompt from (ignored if `prompt` is set) |
| `repositories` (alias `repo`) | Comma-separated `owner/repo` slugs |
| `environment` | Environment name or ID |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

#### Auto-fix Pull Requests

Requires the Claude GitHub App installed on the repository. Ways to enable:

- PRs created in Claude Code on the web: open CI status bar → **Auto-fix**
- From terminal: run `/autofix-pr` on the PR's branch
- From the mobile app or any existing PR: paste the PR URL and tell Claude to auto-fix it

Claude posts GitHub replies under your username but labels them as coming from Claude Code.

#### Context Management in Cloud Sessions

| Command | Works | Notes |
|:--------|:------|:------|
| `/compact` | Yes | Optional focus instructions |
| `/context` | Yes | Shows context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

Override auto-compaction threshold with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `70` for 70%).

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically (Headless)](references/claude-code-headless.md) — `claude -p` flags, bare mode, output formats, streaming, stdin piping, auto-approve tools, structured output, and conversation continuity
- [Use Claude Code on the Web](references/claude-code-on-the-web.md) — Cloud environment setup, GitHub auth, installed tools, setup scripts, network access levels, `--remote`/`--teleport`, sessions, auto-fix PRs, and security
- [Get Started with Claude Code on the Web (Quickstart)](references/claude-code-web-quickstart.md) — Step-by-step browser onboarding, `/web-setup` from terminal, task submission, inline diff review, and PR creation
- [Manage Sessions](references/claude-code-sessions.md) — Resume by flag/name/PR, session picker, naming, branching with `/branch`/`--fork-session`, context management, and transcript storage

## Sources

- Run Claude Code Programmatically (Headless): https://code.claude.com/docs/en/headless.md
- Use Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get Started with Claude Code on the Web (Quickstart): https://code.claude.com/docs/en/web-quickstart.md
- Manage Sessions: https://code.claude.com/docs/en/sessions.md
