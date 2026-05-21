---
name: headless-doc
description: Complete official documentation for running Claude Code non-interactively and on the web — headless/programmatic mode (claude -p, --bare, --output-format, streaming, tool approval, session continuation), Claude Code on the web (cloud environments, setup scripts, network access, teleport/remote, auto-fix PRs, session sharing), the web quickstart (GitHub connection, environment creation, task submission, review workflow), and session management (resume, naming, picker, branching, export).
user-invocable: false
---

# Headless, Web & Session Documentation

This skill provides the complete official documentation for running Claude Code non-interactively, using Claude Code on the web, and managing sessions.

## Quick Reference

### Headless / Programmatic Mode (`claude -p`)

| Flag | Purpose |
| :--- | :--- |
| `-p <prompt>` / `--print` | Run non-interactively; print response and exit |
| `--bare` | Skip hooks, plugins, MCP, skills, CLAUDE.md; fastest for CI |
| `--output-format text\|json\|stream-json` | Response format (default: `text`) |
| `--json-schema <schema>` | Enforce structured output (returned in `structured_output` field) |
| `--include-partial-messages` | Emit tokens as they arrive (use with `stream-json`) |
| `--allowedTools <list>` | Pre-approve specific tools (comma-separated, supports prefix `*`) |
| `--permission-mode <mode>` | `dontAsk` or `acceptEdits` baseline for session |
| `--continue` | Resume most recent conversation |
| `--resume <id\|name>` | Resume specific conversation by session ID or name |
| `--append-system-prompt <text>` | Add instructions atop the default system prompt |
| `--system-prompt <text>` | Fully replace the default system prompt |
| `--no-session-persistence` | Suppress transcript writes in non-interactive mode |

#### Bare Mode Context Flags

| To load | Flag |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

In bare mode, authentication must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON. OAuth and keychain reads are skipped.

#### Output Formats

| Format | Description |
| :--- | :--- |
| `text` | Plain text (default) |
| `json` | `{ result, session_id, total_cost_usd, ... }` |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

Piped stdin is capped at 10 MB (v2.1.128+); use a file reference for larger inputs.

#### stream-json: `system/api_retry` Event Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Identifies a retry event |
| `attempt` | integer | Current attempt number (1-based) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code or null for connection errors |
| `error` | string | Error category (e.g. `rate_limit`, `server_error`) |

#### stream-json: `system/init` Plugin Fields

| Field | Description |
| :--- | :--- |
| `plugins` | Plugins that loaded (each with `name` and `path`) |
| `plugin_errors` | Load-time errors (each with `plugin`, `type`, `message`); omitted when empty |

#### Common `-p` Patterns

```bash
# Pipe data
cat build-error.txt | claude -p 'explain the root cause' > output.txt

# Get JSON with cost metadata
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Structured output
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}'

# Auto-approve tools
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"

# Scoped tool approval (prefix matching — note space before *)
claude -p "Commit staged changes" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"

# Continue a conversation
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue the review" --resume "$session_id"
```

---

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist across tab closes and can be monitored from the mobile app.

#### GitHub Authentication Options

| Method | How | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Authorize during web onboarding | Browser setup; teams wanting Auto-fix |
| **`/web-setup`** | Run in CLI to sync local `gh` token | Developers already using `gh` CLI |

#### What's Available in Cloud Sessions

| Item | Available | Why |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md` | Yes | Part of the clone |
| `.claude/settings.json` hooks | Yes | Part of the clone |
| `.mcp.json` MCP servers | Yes | Part of the clone |
| `.claude/skills/`, `.claude/agents/` | Yes | Part of the clone |
| Plugins in `.claude/settings.json` | Yes | Installed from marketplace at session start |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| MCP servers added with `claude mcp add` | No | Written to local user config |
| Static API tokens / credentials | No | No dedicated secrets store yet |
| Interactive auth (e.g. AWS SSO) | No | Requires browser-based login |

#### Pre-installed Runtimes & Tools

| Category | What's included |
| :--- | :--- |
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun*, eslint, prettier |
| Ruby | 3.1–3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

\* Bun has known proxy compatibility issues for package fetching.

Run `check-tools` in a cloud session for exact versions.

#### Resource Limits

| Resource | Limit |
| :--- | :--- |
| vCPUs | ~4 |
| RAM | ~16 GB |
| Disk | ~30 GB |

#### Network Access Levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including the defaults |

GitHub operations always use a separate authenticated proxy, independent of this setting.

#### Setup Scripts vs SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | The cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in your repo |
| Runs | Before Claude Code launches, when no cached environment exists | After Claude Code launches, on every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Setup scripts run as root on Ubuntu 24.04. The result is cached (filesystem snapshot) so subsequent sessions skip re-installation. Cache rebuilds when the script changes or after ~7 days.

#### Environment Variables

One `KEY=value` pair per line in `.env` format. Do not wrap values in quotes.

#### Moving Tasks Between Terminal and Cloud

| Action | Command |
| :--- | :--- |
| Start a cloud session from terminal | `claude --remote "task description"` |
| Check progress of cloud sessions | `/tasks` in the CLI |
| Pull a cloud session to terminal | `claude --teleport` (picker) or `claude --teleport <session-id>` |
| Transfer from within a session | `/teleport` or `/tp` |
| Link a session transcript URL | `echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"` |

`--remote` clones from GitHub at the current branch — push local commits first. Set `CCR_FORCE_BUNDLE=1` to send a local bundle instead of cloning from GitHub.

#### Teleport Requirements

| Requirement | Details |
| :--- | :--- |
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be the same repo, not a fork |
| Branch pushed | Cloud branch must exist on the remote |
| Same account | Must be authenticated to the same claude.ai account |

`--teleport` requires claude.ai subscription auth (not API key/Bedrock/Vertex). Run `/login` if needed.

#### Auto-fix Pull Requests

Auto-fix monitors a PR for CI failures and review comments, then pushes fixes automatically. Requires the Claude GitHub App installed on the repository.

| Trigger | How |
| :--- | :--- |
| PRs created in Claude Code on the web | Open CI status bar → **Auto-fix** |
| From terminal (on PR branch) | `/autofix-pr` |
| From mobile app | Tell Claude to auto-fix the PR |
| Any existing PR | Paste PR URL into a session and ask Claude to auto-fix |

Auto-fix is per-PR. Claude replies to review comment threads using your GitHub account, labeled as coming from Claude Code.

#### Context Management in Cloud Sessions

| Command | Available | Notes |
| :--- | :--- | :--- |
| `/compact [instructions]` | Yes | Summarizes conversation; accepts focus instructions |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

Use `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `70`) to compact earlier than the default ~95%.

#### Session Management (Web)

| Action | How |
| :--- | :--- |
| Share (Team/Enterprise) | Toggle **Private** → **Team** visibility |
| Share (Max/Pro) | Toggle **Private** → **Public** visibility |
| Archive | Hover session in sidebar → archive icon |
| Delete | Filter archived → hover → delete icon, or session menu → **Delete** |

---

### Session Management (CLI)

#### Resume a Session

| Command | What it does |
| :--- | :--- |
| `claude --continue` | Resumes most recent session in current directory |
| `claude --resume` | Opens interactive session picker |
| `claude --resume <name>` | Resumes named session directly |
| `claude --from-pr <number>` | Resumes session linked to that pull request |
| `/resume` | Switches to a different session from inside a running session |

Sessions created with `claude -p` or the Agent SDK don't appear in the picker, but can be resumed by session ID.

#### Name Sessions

| When | How |
| :--- | :--- |
| At startup | `claude -n <name>` |
| During a session | `/rename <name>` |
| From session picker | Highlight + `Ctrl+R` |
| On plan accept | Automatically named from plan content if not already named |

#### Session Picker Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `↑` / `↓` | Navigate |
| `→` / `←` | Expand/collapse grouped (forked) sessions |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename session |
| `/` or printable char | Enter search / filter |
| `Ctrl+A` | Show sessions from all projects on this machine |
| `Ctrl+W` | Show sessions from all worktrees of current repo |
| `Ctrl+B` | Filter to sessions on current git branch |
| `Esc` | Exit picker or search mode |

#### Branch a Session

```bash
/branch try-streaming-approach        # from inside a session
claude --continue --fork-session      # from command line
```

Original session is unchanged. Permissions granted "for this session" do not carry to the fork.

#### Export & Storage

- Transcripts: `~/.claude/projects/<project>/<session-id>.jsonl`
- Change storage root: set `CLAUDE_CONFIG_DIR`
- Retention: 30 days by default; change with `cleanupPeriodDays` setting
- Suppress writes: set `CLAUDE_CODE_SKIP_PROMPT_HISTORY`, or use `--no-session-persistence` in non-interactive mode
- Export to clipboard/file: `/export [filename]`

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `claude -p`, `--bare` mode, output formats, streaming events, tool approval, session continuation
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — GitHub auth options, cloud environment, setup scripts, network access, teleport/remote, session sharing, auto-fix PRs, security
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — GitHub connection, environment creation, starting tasks, reviewing diffs, PR creation, troubleshooting setup
- [Manage sessions](references/claude-code-sessions.md) — resume, naming, session picker, branching, context management, export and transcript storage

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
