---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (CLI -p flag / headless mode), Claude Code on the web (cloud sessions, environments, network access, teleport), and the web quickstart guide.
user-invocable: false
---

# Headless / Web Documentation

This skill provides the complete official documentation for running Claude Code non-interactively via the CLI, and for using Claude Code on the web (cloud sessions).

## Quick Reference

### Run Claude Code Programmatically (CLI `-p` flag)

The `-p` / `--print` flag runs Claude Code non-interactively. Formerly called "headless mode."

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

**Add `--bare` for CI/scripts** — skips hooks, skills, plugins, MCP servers, CLAUDE.md, and OAuth/keychain reads. Requires `ANTHROPIC_API_KEY`. Recommended for reproducible scripted runs and will become the default for `-p` in a future release.

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

**Bare mode: loading context explicitly**

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

**Output formats**

| Format | Description |
| :--- | :--- |
| `text` (default) | Plain text output |
| `json` | Structured JSON: `result`, `session_id`, metadata; `structured_output` when `--json-schema` is used |
| `stream-json` | Newline-delimited JSON for real-time streaming |

```bash
# JSON output
claude -p "Summarize this project" --output-format json

# Schema-constrained structured output
claude -p "Extract the main function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'

# Streaming with jq to display text tokens
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

**`system/api_retry` stream event fields**

| Field | Type | Description |
| :--- | :--- | :--- |
| `attempt` | integer | Current attempt number (starts at 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status, or null for connection errors |
| `error` | string | `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |

**`system/init` stream event** — first event; reports model, tools, MCP servers, loaded plugins. Fields: `plugins` (loaded), `plugin_errors` (load failures with `plugin`, `type`, `message`).

**`system/plugin_install` stream event** (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set)

| `status` | Meaning |
| :--- | :--- |
| `started` | Install process beginning |
| `installed` | Individual marketplace installed |
| `failed` | Individual marketplace failed (`error` field present) |
| `completed` | All installs done |

**Permission control**

```bash
# Allow specific tools
claude -p "Run the test suite and fix any failures" --allowedTools "Bash,Read,Edit"

# Permission modes
claude -p "Apply the lint fixes" --permission-mode acceptEdits
```

| Permission mode | Behavior |
| :--- | :--- |
| `dontAsk` | Denies anything not in `permissions.allow` or the read-only set |
| `acceptEdits` | Auto-approves file writes plus common filesystem commands (`mkdir`, `touch`, `mv`, `cp`) |

**Continue / resume conversations**

```bash
# Continue most recent conversation
claude -p "Now focus on the database queries" --continue

# Resume a specific session by ID
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

**Tool permission rule syntax** — trailing ` *` enables prefix matching (space before `*` matters):

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

---

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist even if you close your browser and are monitored from the Claude mobile app.

**GitHub authentication options**

| Method | How it works | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install Claude GitHub App on specific repos during onboarding | Teams wanting explicit per-repo authorization |
| **`/web-setup`** | Syncs local `gh` CLI token to Claude account | Developers who already use `gh` |

GitHub App is required for Auto-fix (receives PR webhooks). `/web-setup` can be disabled by Team/Enterprise admins. Organizations with Zero Data Retention cannot use `/web-setup`.

**What's available in cloud sessions**

| Resource | Available | Why |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md` | Yes | Part of the clone |
| Repo's `.claude/settings.json` hooks | Yes | Part of the clone |
| Repo's `.mcp.json` MCP servers | Yes | Part of the clone |
| Repo's `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins in `.claude/settings.json` | Yes | Installed at session start from marketplace |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| Plugins only in user settings | No | Use repo's `.claude/settings.json` instead |
| MCP servers added with `claude mcp add` | No | Use `.mcp.json` instead |
| Static API tokens / credentials | No | No dedicated secrets store yet |
| Interactive auth (AWS SSO, etc.) | No | Not supported |

**Pre-installed tools (cloud VMs)**

| Category | Included |
| :--- | :--- |
| Python | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun, eslint, prettier, chromedriver |
| Ruby | 3.1, 3.2, 3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven and Gradle |
| Go | Latest stable with module support |
| Rust | rustc and cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (pre-installed, not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

Run `check-tools` in a cloud session for exact versions (cloud only).

**Resource limits (approximate, may change)**

- 4 vCPUs, 16 GB RAM, 30 GB disk

**Environment variables** — use `.env` format, no quoting:

```
NODE_ENV=development
LOG_LEVEL=debug
DATABASE_URL=postgres://localhost:5432/myapp
```

**Session self-identification** — `CLAUDE_CODE_REMOTE_SESSION_ID` env var contains the session ID:

```bash
echo "https://claude.ai/${CLAUDE_CODE_REMOTE_SESSION_ID}"
```

**Network access levels**

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound network access |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including defaults |

GitHub operations always use a separate dedicated proxy independent of this setting.

**Setup scripts vs. SessionStart hooks**

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches (cached) | After Claude Code launches, every session including resumed |
| Scope | Cloud only | Local and cloud |

Setup script output is cached — runs once, then filesystem snapshot reused (~7 day expiry or when script/network config changes).

To skip hook execution locally, check `CLAUDE_CODE_REMOTE` env var:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi
```

**Move tasks between web and terminal**

```bash
# Terminal → web: start a cloud session from CLI
claude --remote "Fix the authentication bug in src/auth/login.ts"

# Force bundle local repo without GitHub
CCR_FORCE_BUNDLE=1 claude --remote "Run the test suite and fix any failures"

# Web → terminal: interactive session picker
claude --teleport

# Web → terminal: direct session ID
claude --teleport <session-id>

# Inside existing session
/teleport   # or /tp
```

`--teleport` requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account.

**Context management in cloud sessions**

| Command | Works | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Accepts optional focus instructions |
| `/context` | Yes | Shows current context window |
| `/clear` | No | Start a new session from the sidebar instead |

Auto-compaction env vars: `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (default ~95%), `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

**Auto-fix pull requests** — requires Claude GitHub App installed. Ways to enable:

- PRs created in Claude Code on the web: open CI status bar → **Auto-fix**
- From terminal: run `/autofix-pr` on the PR's branch
- From mobile app: tell Claude to auto-fix the PR
- Any existing PR: paste the PR URL and ask Claude to auto-fix

---

### Web Quickstart

**Compare ways to run Claude Code**

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| Uses local config | No, repo only | Yes | Yes | Yes for local, no for cloud |
| Requires GitHub | Yes (or bundle via `--remote`) | No | No | Only for cloud sessions |
| Keeps running if disconnected | Yes | While terminal stays open | No | Depends |

**Pre-fill session URL parameters**

| Parameter | Description |
| :--- | :--- |
| `prompt` / `q` | Prompt text to prefill |
| `prompt_url` | URL to fetch prompt from (for long prompts) |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs |
| `environment` | Name or ID of environment to preselect |

```
https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp
```

**Permission modes available in cloud sessions:** Auto accept edits, Plan (not Ask, Auto, or Bypass).

**Bundled local repo limits:** must be a git repo with at least one commit; under 100 MB; untracked files not included; can't push back without GitHub auth.

**Troubleshooting quick reference**

| Issue | Fix |
| :--- | :--- |
| No repos after connecting GitHub | Check Settings → Applications → Claude → Configure on github.com |
| `/web-setup` returns "Unknown command" | Run inside `claude` CLI, not your shell; also try `claude update` then `/login` |
| "Could not create a cloud environment" | Run `/web-setup` or visit claude.ai/code to create one manually |
| Setup script failed | Add `set -x` to debug; append `\|\| true` for non-critical commands |
| Session keeps running after closing tab | By design; archive or delete from sidebar |
| `--teleport` unavailable | Run `/login` to authenticate via claude.ai subscription |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `-p` flag, `--bare` mode, output formats, streaming events, tool auto-approval, system prompt customization, and conversation continuation
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environment configuration, installed tools, setup scripts, network access levels and default allowlist, terminal-to-web and web-to-terminal session handoff, session management, auto-fix pull requests, security isolation, and limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — GitHub App setup, connecting from terminal, starting tasks, pre-filling sessions, reviewing diffs, inline comments, and troubleshooting

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
