---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (CLI -p flag / headless mode), and Claude Code on the web — cloud sessions, environment setup, network access, teleporting between web and terminal, setup scripts, auto-fix pull requests, and the web quickstart.
user-invocable: false
---

# Headless / Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI, and for using Claude Code on the web (cloud sessions).

## Quick Reference

### Programmatic CLI usage (`-p` / headless mode)

The `-p` (or `--print`) flag runs Claude Code non-interactively. The CLI was formerly called "headless mode."

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

#### Key flags for `-p` mode

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Run non-interactively; print response and exit |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md. Recommended for CI. |
| `--output-format text\|json\|stream-json` | Response format (default: `text`) |
| `--json-schema '<schema>'` | Return structured output conforming to schema (use with `--output-format json`) |
| `--verbose` | Include extra metadata in output |
| `--include-partial-messages` | Stream partial tokens (with `stream-json`) |
| `--allowedTools "Bash,Read,Edit"` | Auto-approve listed tools |
| `--permission-mode acceptEdits\|dontAsk` | Set baseline permission mode for the session |
| `--append-system-prompt "..."` | Add instructions to the default system prompt |
| `--system-prompt "..."` | Fully replace the default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Resume a specific conversation |
| `--append-system-prompt-file <file>` | Load system prompt additions from a file |
| `--settings <file-or-json>` | Load settings from file or inline JSON |
| `--mcp-config <file-or-json>` | Load MCP servers |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin directory |

#### `--bare` mode context loading

In bare mode, no auto-discovery occurs. Pass context explicitly:

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

Bare mode skips OAuth and keychain reads. Use `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON for authentication.

#### Output formats

| Format | Description |
| :--- | :--- |
| `text` | Plain text (default) |
| `json` | JSON object with `result`, `session_id`, metadata; `structured_output` if `--json-schema` used |
| `stream-json` | Newline-delimited JSON events; use with `--verbose --include-partial-messages` |

#### `stream-json` system events

**`system/api_retry`** — emitted before a retry on retryable errors:

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `"system"` | message type |
| `subtype` | `"api_retry"` | identifies this as a retry event |
| `attempt` | integer | current attempt number (starts at 1) |
| `max_retries` | integer | total retries permitted |
| `retry_delay_ms` | integer | milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |
| `uuid` | string | unique event identifier |
| `session_id` | string | session the event belongs to |

**`system/init`** — first event in stream; reports model, tools, MCP servers, loaded plugins. Fields `plugins` (loaded) and `plugin_errors` (load-time errors). Set `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` to make `system/plugin_install` events precede it.

**`system/plugin_install`** — emitted while marketplace plugins install (requires `CLAUDE_CODE_SYNC_PLUGIN_INSTALL`):

| Field | Type | Description |
| :--- | :--- | :--- |
| `subtype` | `"plugin_install"` | identifies this event |
| `status` | `"started"`, `"installed"`, `"failed"`, `"completed"` | install lifecycle |
| `name` | string, optional | marketplace name (on `installed`/`failed`) |
| `error` | string, optional | failure message (on `failed`) |

#### Common `-p` patterns

```bash
# Structured output
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Structured output with schema
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}' \
  | jq '.structured_output'

# Streaming tokens
claude -p "Explain recursion" --output-format stream-json --verbose --include-partial-messages

# Auto-approve tools
claude -p "Run the test suite and fix any failures" --allowedTools "Bash,Read,Edit"

# Permission mode
claude -p "Apply the lint fixes" --permission-mode acceptEdits

# Create a commit (prefix-match syntax)
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"

# Custom system prompt via stdin pipe
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json

# Continue conversations
claude -p "Review this codebase for performance issues"
claude -p "Now focus on the database queries" --continue
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

Note: user-invocable skills (like `/commit`) and built-in commands are only available in interactive mode. In `-p` mode, describe the task instead.

---

### Claude Code on the web (cloud sessions)

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist even if you close the browser. Available in research preview for Pro, Max, Team, and qualifying Enterprise users.

#### Ways to run Claude Code — comparison

|  | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| **Code runs on** | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| **You chat from** | claude.ai or mobile app | claude.ai or mobile app | Your terminal | The Desktop UI |
| **Uses your local config** | No, repo only | Yes | Yes | Yes for local, no for cloud |
| **Requires GitHub** | Yes, or bundle via `--remote` | No | No | Only for cloud sessions |
| **Keeps running if you disconnect** | Yes | While terminal stays open | No | Depends on session type |
| **Permission modes** | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends on session type |
| **Network access** | Configurable per environment | Your machine's network | Your machine's network | Depends on session type |

#### Session lifecycle

1. Repository is cloned to an Anthropic-managed VM
2. Setup script runs (if configured)
3. Network access is set per environment level
4. Claude works; you can watch or return when done
5. Claude pushes a branch; session stays live for PR creation and iteration

#### GitHub authentication options

| Method | How it works | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install Claude GitHub App during web onboarding; scoped per repo | Teams wanting explicit per-repo authorization |
| **`/web-setup`** | Run in terminal to sync local `gh` CLI token to Claude account | Individual devs who already use `gh` |

The GitHub App is required for Auto-fix (needs PR webhooks). Team/Enterprise admins can disable `/web-setup` at claude.ai/admin-settings/claude-code.

#### What's available in cloud sessions

| Item | Available | Why |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md` | Yes | Part of the clone |
| Repo's `.claude/settings.json` hooks | Yes | Part of the clone |
| Repo's `.mcp.json` MCP servers | Yes | Part of the clone |
| Repo's `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins in `.claude/settings.json` | Yes | Installed at session start from marketplace |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| Plugins in user settings only | No | Declare in repo `.claude/settings.json` instead |
| MCP servers added with `claude mcp add` | No | Declare in `.mcp.json` instead |
| Static API tokens / credentials | No | No secrets store yet; use env vars with caution |
| Interactive auth (AWS SSO, etc.) | No | Not supported |

#### Pre-installed tools

| Category | Included |
| :--- | :--- |
| Python | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun*, eslint, prettier, chromedriver |
| Ruby | 3.1, 3.2, 3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven and Gradle |
| Go | latest stable with module support |
| Rust | rustc and cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default; ask Claude to start) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

*Bun has known proxy compatibility issues for package fetching.

Run `check-tools` in a cloud session for exact versions (cloud-only command).

#### Resource limits

- 4 vCPUs, 16 GB RAM, 30 GB disk (approximate; may change)

#### Network access levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound network access |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including the Trusted defaults |

GitHub operations go through a dedicated GitHub proxy independent of this setting. Use `*.` for wildcard subdomain matching in custom lists.

#### Setup scripts vs. SessionStart hooks

|  | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | The cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in your repo |
| Runs | Before Claude Code launches (when no cached environment) | After Claude Code launches, every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

Setup script example (install `gh`):

```bash
#!/bin/bash
apt update && apt install -y gh
```

SessionStart hook to run only in cloud:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/install_pkgs.sh" }]
      }
    ]
  }
}
```

Check `CLAUDE_CODE_REMOTE=true` in the script to skip local execution.

#### Environment caching

The setup script runs once; Anthropic snapshots the filesystem after it completes. Later sessions start from the snapshot (files, not running processes). Cache rebuilds when the script or allowed network hosts change, or after ~7 days.

#### Managing environments

| Action | How |
| :--- | :--- |
| Add an environment | Select the current environment to open the selector, then select **Add environment** |
| Edit an environment | Select the settings icon to the right of the environment name |
| Archive an environment | Open it for editing and select **Archive** |
| Set default for `--remote` | Run `/remote-env` in your terminal |

Environment variables use `.env` format (`KEY=value`). Do not wrap values in quotes.

#### Moving sessions between web and terminal

| Direction | How |
| :--- | :--- |
| Terminal → web | `claude --remote "task description"` (clones repo from GitHub at current branch; push local commits first) |
| Web → terminal | `claude --teleport` (interactive picker) or `claude --teleport <session-id>` |
| Inside a session | `/teleport` or `/tp` |
| From `/tasks` | Press `t` to teleport into a background session |
| From web UI | Select **Open in CLI** |

`--teleport` requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account. Requires claude.ai subscription auth (not API key).

Parallel remote tasks: each `--remote` call creates its own session; run multiple to execute in parallel.

Force bundle (no GitHub): `CCR_FORCE_BUNDLE=1 claude --remote "..."` — bundles local repo (under 100 MB, at least one commit, untracked files excluded, can't push back unless GitHub auth also configured).

Session link from within a session: `echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID}"`

#### Planning patterns with cloud sessions

**Plan locally, execute remotely**: run `claude --permission-mode plan` to collaborate on approach, commit and push the plan, then start a cloud session:

```bash
claude --remote "Execute the migration plan in docs/migration-plan.md"
```

**Ultraplan**: draft and review the plan in a web session with [ultraplan](/en/ultraplan), then execute remotely or teleport to terminal.

#### Auto-compaction in cloud sessions

| Env var | Effect |
| :--- | :--- |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` | Compact at 70% capacity (default ~95%) |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Change effective window size for calculations |

#### Context commands in cloud sessions

| Command | Works | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Accepts optional focus instructions |
| `/context` | Yes | Shows current context window |
| `/clear` | No | Start a new session from sidebar instead |

#### Subagents and agent teams

Subagents work the same as locally. Claude can spawn them with the Task tool to offload research or parallel work. Subagents in `.claude/agents/` are picked up automatically. Agent teams are off by default — enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in environment variables.

#### Auto-fix pull requests

Claude monitors a PR and automatically responds to CI failures and review comments. Requires the Claude GitHub App.

Ways to enable:
- PRs created in Claude Code on the web: open the CI status bar and select **Auto-fix**
- From terminal: `/autofix-pr` while on the PR's branch
- From mobile app: tell Claude to auto-fix the PR
- Any PR: paste the PR URL into a session and ask Claude to auto-fix it

Claude pushes clear fixes automatically; asks before acting on ambiguous requests. Replies on GitHub appear under your username but are labeled as coming from Claude Code.

Warning: Claude can trigger comment-based automation (Atlantis, Terraform Cloud, etc.) when replying to PR comments.

#### Web quickstart summary

1. Visit [claude.ai/code](https://claude.ai/code) and sign in
2. Install the Claude GitHub App and grant repo access
3. Create a cloud environment (name, network access, env vars, setup script)
4. Select a repo/branch, choose **Auto accept edits** or **Plan mode**, submit task
5. Review the diff, leave inline comments, create a PR

Pre-fill a session via URL parameters:

| Parameter | Description |
| :--- | :--- |
| `prompt` / `q` | Prompt text to prefill |
| `prompt_url` | URL to fetch prompt from (ignored if `prompt` set) |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs |
| `environment` | Name or ID of environment to preselect |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

Terminal setup alternative: `gh auth login` → `/login` in Claude Code CLI → `/web-setup`

#### Troubleshooting cloud sessions

| Issue | Resolution |
| :--- | :--- |
| `Session creation failed` | Check status.claude.com; retry after a minute; verify GitHub App access |
| `Remote Control session has expired` / `Access denied` | Run `/login` to refresh credentials; confirm same account |
| Environment expired | Reopen session from claude.ai/code to provision fresh environment |
| Setup script failed | Add `set -x` to debug; append `\|\| true` to non-critical commands |
| No repositories appear | Configure GitHub App access at github.com Settings → Applications → Claude |
| `/web-setup` returns "Unknown command" | Run inside `claude`, not the shell; update CLI with `claude update` |
| "Could not create a cloud environment" | Run `/web-setup` or visit claude.ai/code to create one manually |
| Session keeps running after closing tab | By design; archive or delete from sidebar |

#### Limitations

- Rate limits shared with all Claude/Claude Code usage in your account
- Repository cloning requires GitHub (or `--remote` bundle for non-GitHub repos)
- GitHub Enterprise Server supported on Team/Enterprise plans only
- GitLab/Bitbucket repos can be bundled via `--remote` but can't push back
- Organization IP allowlisting blocks cloud sessions (contact Anthropic support to exempt)

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `-p` flag, `--bare` mode, output formats, streaming, tool approval, system prompt flags, continuing conversations
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environments, GitHub auth, installed tools, setup scripts, network access, teleporting between web and terminal, session management, auto-fix pull requests, security and limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — connecting GitHub, creating environments, submitting tasks, reviewing diffs, creating PRs, pre-filling sessions, troubleshooting setup

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
