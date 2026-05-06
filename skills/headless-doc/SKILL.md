---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (headless/non-interactive mode), Claude Code on the web, and the web quickstart — covering the -p flag, --bare mode, output formats, streaming, tool approval, session continuity, cloud environment setup, GitHub authentication, network access, setup scripts, teleport/remote workflows, auto-fix pull requests, and session management.
user-invocable: false
---

# Headless and Claude Code on the Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`-p` flag), and for using Claude Code on the web (cloud sessions).

## Quick Reference

### Programmatic CLI (`-p` / `--print`)

Run Claude non-interactively by adding `-p` to any `claude` command:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

> Note: The CLI was previously called "headless mode." The `-p` flag and all CLI options work the same way.

#### Key CLI Flags for Non-Interactive Use

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Non-interactive mode; required for all programmatic use |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, memory, CLAUDE.md. Recommended for CI/scripts |
| `--output-format text\|json\|stream-json` | Control response format (default: `text`) |
| `--json-schema <schema>` | Enforce structured output schema; result in `structured_output` field |
| `--allowedTools <tools>` | Auto-approve specific tools (e.g. `"Bash,Read,Edit"`) |
| `--permission-mode <mode>` | Set a baseline permission mode (`dontAsk`, `acceptEdits`, etc.) |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Resume a specific conversation by ID |
| `--append-system-prompt <text>` | Add instructions while keeping default system prompt |
| `--system-prompt <text>` | Fully replace the default system prompt |
| `--append-system-prompt-file <file>` | Load system prompt additions from a file |
| `--settings <file-or-json>` | Load settings from file or inline JSON |
| `--mcp-config <file-or-json>` | Load MCP server configuration |
| `--agents <json>` | Define custom agents |
| `--plugin-dir <path>` | Load a plugin from a directory |

#### `--bare` Mode

- Skips OAuth and keychain reads; requires `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`
- Provides Bash, file read, and file edit tools by default
- Will become the default for `-p` in a future release
- Recommended for reproducible CI runs

#### Output Formats

| Format | Description |
| :--- | :--- |
| `text` | Plain text (default) |
| `json` | Structured JSON with `result`, `session_id`, `total_cost_usd`, and cost breakdown |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

With `--output-format json` and `--json-schema`, structured output lands in the `structured_output` field.

#### Streaming Events

Use `--output-format stream-json --verbose --include-partial-messages` to stream tokens.

Key stream event types:

| Event type | Description |
| :--- | :--- |
| `system/init` | First event; reports model, tools, MCP servers, plugins loaded |
| `system/api_retry` | Emitted before a retry on transryable errors |
| `system/plugin_install` | Plugin install progress (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set) |

`system/init` includes `plugins` (loaded) and `plugin_errors` (load failures) arrays. Use `plugin_errors` to fail CI when a plugin did not load.

`system/api_retry` fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` (category string), `uuid`, `session_id`.

#### `--allowedTools` Syntax

Uses permission rule syntax. Trailing ` *` enables prefix matching:

```bash
--allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"
```

The space before `*` matters: `Bash(git diff *)` matches `git diff <anything>`, while `Bash(git diff*)` would also match `git diff-index`.

#### Stdin / Stdout Patterns

- Piped stdin is capped at 10 MB (as of v2.1.128); larger inputs should be written to a file
- Pipe data in and redirect out like any shell tool: `cat file.txt | claude -p "..." > out.txt`
- Use `jq -r '.result'` to extract text from JSON output

#### Continue / Resume Conversations

```bash
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue" --resume "$session_id"
```

---

### Claude Code on the Web (Cloud Sessions)

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist when you close your browser and can be monitored from the Claude mobile app.

#### Comparison: Ways to Run Claude Code

| | On the web | Remote Control | Terminal CLI | Desktop |
| :--- | :--- | :--- | :--- | :--- |
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| You chat from | claude.ai / mobile | claude.ai / mobile | Terminal | Desktop UI |
| Uses local config | No, repo only | Yes | Yes | Yes for local, no for cloud |
| Requires GitHub | Yes (or bundle) | No | No | Only for cloud sessions |
| Keeps running if disconnected | Yes | While terminal stays open | No | Depends on session type |
| Permission modes | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends on session type |

#### GitHub Authentication Options

| Method | How it works | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install Claude GitHub App; access scoped per repo | Teams wanting explicit per-repo authorization |
| **`/web-setup`** | Syncs local `gh` CLI token to your Claude account | Individual devs who already use `gh` |

The GitHub App is required for Auto-fix (receives PR webhooks). Zero Data Retention organizations cannot use `/web-setup`.

#### What's Available in Cloud Sessions

| Item | Available | Why |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start from marketplace |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| Plugins enabled only in user settings | No | User-scoped; move to repo settings |
| MCP servers added with `claude mcp add` | No | Local user config; use `.mcp.json` instead |
| Static API tokens/credentials | No | No secrets store yet |
| Interactive auth (AWS SSO, etc.) | No | Not supported in cloud |

#### Pre-installed Tools in Cloud Sessions

| Category | Included |
| :--- | :--- |
| Python | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun, eslint, prettier, chromedriver |
| Ruby | 3.1, 3.2, 3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable with module support |
| Rust | rustc and cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

Run `check-tools` inside a cloud session to see exact versions.

#### Resource Limits (Approximate)

- 4 vCPUs, 16 GB RAM, 30 GB disk

#### Network Access Levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including defaults |

GitHub operations use a separate GitHub proxy independent of this setting. All traffic goes through an HTTP/HTTPS security proxy.

Use `*.` prefix for wildcard subdomain matching in Custom allowlists.

#### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | The cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches, when no cached environment exists | After Claude Code launches, on every session including resumed |
| Scope | Cloud environments only | Both local and cloud |

- Setup scripts run as root on Ubuntu 24.04; exit non-zero blocks session start
- Keep setup scripts under ~5 minutes to enable environment caching
- Use `CLAUDE_CODE_REMOTE=true` in SessionStart hooks to skip local execution
- Write persistent env vars for subsequent Bash commands to `$CLAUDE_ENV_FILE`
- Bun has known proxy compatibility issues for package fetching

#### Environment Caching

After a setup script completes, Anthropic snapshots the filesystem. Later sessions start from that snapshot (files only, not running processes). Cache rebuilds when the setup script or allowed hosts change, or after ~7 days.

#### Moving Tasks Between Web and Terminal

**Terminal to web** — start a cloud session from CLI:
```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```
- Clones your current directory's GitHub remote at your current branch (push first if you have local commits)
- Set `CCR_FORCE_BUNDLE=1` to force local bundle upload instead of GitHub clone
- Run parallel tasks by calling `--remote` multiple times; monitor with `/tasks`

**Web to terminal** — teleport a cloud session into your terminal:
- `claude --teleport` — interactive session picker
- `claude --teleport <session-id>` — resume specific session
- `/teleport` or `/tp` inside a CLI session — same picker without restart
- `/tasks` then press `t` — teleport from task list

Teleport requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account. Teleport requires claude.ai subscription (not API key / Bedrock / Vertex).

#### Pre-fill Sessions via URL Parameters

| Parameter | Description |
| :--- | :--- |
| `prompt` (alias: `q`) | Prefill prompt text |
| `prompt_url` | URL to fetch prompt from (ignored when `prompt` is set) |
| `repositories` (alias: `repo`) | Comma-separated `owner/repo` slugs |
| `environment` | Name or ID of the environment to preselect |

#### Session Management Commands

| Command | Works in cloud | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Summarizes conversation; accepts optional focus instructions |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

Auto-compaction triggers at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` env var (e.g. `70` for 70%). Adjust effective window size with `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

#### Auto-fix Pull Requests

Requires the Claude GitHub App installed on your repository. Claude watches a PR and automatically responds to CI failures and review comments.

Enable via:
- PRs created in Claude Code on the web: select **Auto-fix** in the CI status bar
- From terminal: run `/autofix-pr` while on the PR's branch
- From mobile app: tell Claude to auto-fix the PR
- Any existing PR: paste the PR URL into a session and ask Claude to auto-fix it

Claude replies to review threads under your GitHub username, labeled as coming from Claude Code. Caution: comment-triggered automation (Atlantis, Terraform Cloud, etc.) can be triggered by these replies.

#### Session Sharing

| Account type | Visibility options | Notes |
| :--- | :--- | :--- |
| Enterprise / Team | Private, Team | Team = visible to org members; repo access verification on by default |
| Max / Pro | Private, Public | Public = any logged-in claude.ai user; repo access verification off by default |

#### Useful Environment Variables in Cloud Sessions

| Variable | Description |
| :--- | :--- |
| `CLAUDE_CODE_REMOTE` | Set to `true` in cloud sessions |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | Current session ID; use to construct `https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID}` |
| `CLAUDE_ENV_FILE` | Write `KEY=value` lines here to persist env vars for subsequent Bash commands |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Override auto-compaction threshold (default ~95%) |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Adjust effective window size for compaction calculations |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Set to `1` to enable agent teams (off by default) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `-p` flag, `--bare` mode, output formats, streaming events, tool approval, system prompt flags, session continuity
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — GitHub auth options, cloud environment, installed tools, setup scripts, environment caching, network access, moving tasks between web and terminal, session management, auto-fix pull requests, security and isolation, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart walkthrough: connect GitHub, create an environment, start a task, pre-fill sessions, review and iterate, troubleshoot setup

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
