---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically via the CLI (-p flag / headless mode), Claude Code on the web (cloud sessions), and the web quickstart — covering bare mode, structured output, streaming, tool approval, session continuity, cloud environments, network access, setup scripts, web-to-terminal teleport, and auto-fix PR workflows.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically (CLI `-p` flag) and using Claude Code on the web (cloud sessions).

## Quick Reference

### CLI programmatic mode (`-p` / headless)

The `-p` (or `--print`) flag runs Claude Code non-interactively. The CLI was formerly called "headless mode."

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

#### Key `-p` flags

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Run non-interactively; print result and exit |
| `--bare` | Skip hooks, skills, plugins, MCP, CLAUDE.md, auto memory — same result on every machine |
| `--output-format text\|json\|stream-json` | Control response format (default: `text`) |
| `--json-schema '<schema>'` | Return structured output conforming to JSON Schema (use with `--output-format json`) |
| `--include-partial-messages` | Emit partial tokens when streaming |
| `--verbose` | Show additional event info (needed for streaming) |
| `--allowedTools "<tools>"` | Auto-approve listed tools without prompting |
| `--permission-mode <mode>` | Set baseline mode: `dontAsk` or `acceptEdits` |
| `--continue` | Continue most recent conversation |
| `--resume <session-id>` | Continue a specific session by ID |
| `--append-system-prompt "<text>"` | Add instructions to Claude's system prompt |
| `--append-system-prompt-file <path>` | Load system prompt additions from a file |
| `--system-prompt "<text>"` | Fully replace the default system prompt |
| `--settings <file-or-json>` | Load settings from a file or inline JSON |
| `--mcp-config <file-or-json>` | Load MCP servers |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin |

#### `--bare` mode

Skips OAuth and keychain reads. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`. Recommended for CI/scripts; will become the default for `-p` in a future release.

#### Output formats

| Format | Description |
| :--- | :--- |
| `text` | Plain text (default) |
| `json` | JSON object with `result`, `session_id`, metadata; `structured_output` field when `--json-schema` is used |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

#### Common patterns

```bash
# Structured JSON output
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Structured output with schema
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}' \
  | jq '.structured_output'

# Streaming tokens
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'

# Scoped tool approval (prefix matching — space before * is required)
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"

# Continue a conversation, capturing session ID
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

#### `stream-json` system events

| Event subtype | Key fields | Purpose |
| :--- | :--- | :--- |
| `system/init` | `plugins`, `plugin_errors` | Session metadata; use `plugin_errors` to fail CI on bad plugin load |
| `system/api_retry` | `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` | Retry progress; `error` values: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `system/plugin_install` | `status` (`started`/`installed`/`failed`/`completed`), `name`, `error` | Plugin marketplace install progress (requires `CLAUDE_CODE_SYNC_PLUGIN_INSTALL`) |

---

### Claude Code on the web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist even when the browser is closed and can be monitored from the Claude mobile app.

#### Ways to run Claude Code (comparison)

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| **Code runs on** | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| **Chat from** | claude.ai or mobile | claude.ai or mobile | Your terminal | Desktop UI |
| **Uses local config** | No (repo only) | Yes | Yes | Yes (local) / No (cloud) |
| **Requires GitHub** | Yes (or bundle via `--remote`) | No | No | Only for cloud sessions |
| **Persists if disconnected** | Yes | While terminal open | No | Depends |
| **Permission modes** | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends |

#### GitHub authentication options

| Method | How it works | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install Claude GitHub App on specific repos during web onboarding | Teams wanting per-repo authorization |
| **`/web-setup`** | Run `/web-setup` in terminal to sync local `gh` CLI token | Individual developers who already use `gh` |

The GitHub App is required for **Auto-fix** (receives PR webhooks). Zero Data Retention orgs cannot use `/web-setup`.

#### Cloud environment — what's available

| Item | Available | Notes |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start from marketplace |
| User `~/.claude/CLAUDE.md`, user-scoped plugins | No | Lives on your machine |
| MCP servers added with `claude mcp add` | No | Write to local config; use `.mcp.json` instead |
| Static API tokens / credentials | No | No secrets store yet; use env vars (visible to environment editors) |
| Interactive auth (AWS SSO, etc.) | No | Not supported |

#### Pre-installed tools (cloud VM)

| Category | Tools |
| :--- | :--- |
| Python | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun (proxy issues), eslint, prettier, chromedriver |
| Ruby | 3.1/3.2/3.3, gem, bundler, rbenv |
| PHP | 8.4 + Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

Resource limits: ~4 vCPUs, 16 GB RAM, 30 GB disk.

#### Network access levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** (default) | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist; optionally include Trusted defaults |

GitHub operations use a separate proxy independent of this setting. All other outbound traffic passes through an HTTP/HTTPS security proxy.

#### Setup scripts vs. SessionStart hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches (cached; skipped on subsequent sessions) | After Claude Code launches, every session including resumed |
| Scope | Cloud only | Both local and cloud |

Setup script caches after first run (~7-day expiry). Rebuilds when you change the script or allowed hosts.

To detect cloud sessions in a SessionStart hook:
```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

#### Moving tasks between web and terminal

| Action | Command | Notes |
| :--- | :--- | :--- |
| Start cloud session from terminal | `claude --remote "task description"` | Clones current repo's GitHub remote at current branch; push local commits first |
| Force bundle upload (no GitHub) | `CCR_FORCE_BUNDLE=1 claude --remote "..."` | Bundles repo (<100 MB); untracked files not included |
| Pull cloud session to terminal | `claude --teleport` or `claude --teleport <session-id>` | Requires clean git state, correct repo, branch pushed, same account |
| Inside existing session | `/teleport` or `/tp` | Opens session picker without restarting Claude Code |
| Check background sessions | `/tasks` then press `t` | Teleport into a session from the task list |

`--teleport` is distinct from `--resume`: `--resume` reopens local history; `--teleport` pulls a cloud session and its branch.

Teleport requires claude.ai subscription auth. If using API key / Bedrock / Vertex / Foundry, run `/login` first.

#### Auto-fix pull requests

Claude watches a PR and automatically responds to CI failures and review comments. Requires the Claude GitHub App installed on the repository.

| How to enable | Method |
| :--- | :--- |
| PR created in Claude Code on the web | Open CI status bar → **Auto-fix** |
| From terminal | `/autofix-pr` on the PR's branch |
| From mobile app | Tell Claude to "auto-fix the PR" |
| Any existing PR | Paste PR URL into a session and ask Claude to auto-fix it |

Claude replies to review threads under your GitHub username, labeled as "Claude Code." Beware of comment-triggered automation (Atlantis, Terraform Cloud) that may be triggered by these replies.

#### Session management

| Task | How |
| :--- | :--- |
| Review changes | Select diff indicator (e.g., `+42 -18`) to open diff view; leave inline comments |
| Create PR | Select **Create PR** in diff view (full, draft, or GitHub compose) |
| Share (Enterprise/Team) | Toggle **Private** / **Team** visibility |
| Share (Max/Pro) | Toggle **Private** / **Public** visibility |
| Archive session | Hover session in sidebar → archive icon |
| Delete session | Archive first, then select delete icon; or session menu → **Delete** |

Context management commands in cloud sessions:

| Command | Works in cloud | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Accepts optional focus instructions |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

#### Web session URL pre-fill parameters

| Parameter | Description |
| :--- | :--- |
| `prompt` (alias `q`) | Prefill prompt text |
| `prompt_url` | URL to fetch prompt from (ignored when `prompt` is set) |
| `repositories` (alias `repo`) | Comma-separated `owner/repo` slugs |
| `environment` | Environment name or ID |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

#### Key environment variables

| Variable | Effect |
| :--- | :--- |
| `CLAUDE_CODE_REMOTE` | Set to `true` in cloud sessions |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | Current cloud session ID (use to construct session URL) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Compact at this % context capacity instead of default ~95% |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Override effective window size for compaction calculations |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Set to `1` to enable agent teams in cloud sessions |
| `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` | Emit `plugin_install` stream events during marketplace installs |

#### Troubleshooting

| Issue | Fix |
| :--- | :--- |
| Session creation failed | Check [status.claude.com](https://status.claude.com); retry; verify GitHub repo access |
| `--teleport` unavailable | Run `/login` to sign in via claude.ai subscription |
| Environment expired | Reopen session from claude.ai/code to provision fresh environment |
| No repos after connecting GitHub | Go to GitHub Settings → Applications → Claude → Configure; add repo |
| `/web-setup` returns "Unknown command" | Run inside `claude`, not shell; or run `claude update` then `/login` |
| Setup script failed | Add `set -x` to debug; append `|| true` to non-critical commands |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — CLI `-p` flag usage, bare mode, structured output, streaming, tool approval, system prompt customization, and conversation continuity
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environment configuration, installed tools, setup scripts, network access, GitHub auth, teleport, auto-fix PRs, session management, security, and limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart walkthrough: connecting GitHub, creating an environment, submitting tasks, reviewing diffs, and creating PRs

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
