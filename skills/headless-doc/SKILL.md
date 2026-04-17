---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (CLI -p flag, bare mode, structured output, streaming, auto-approve tools) and Claude Code on the web (cloud environments, setup scripts, network access, teleport, auto-fix PRs).
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI and using Claude Code on the web.

## Quick Reference

### CLI programmatic mode (`claude -p`)

Run Claude Code non-interactively by passing `-p` (or `--print`) with a prompt. All CLI flags work with `-p`.

| Flag / Option | Purpose |
| :--- | :--- |
| `-p "prompt"` | Run non-interactively, print result to stdout |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md; recommended for CI |
| `--output-format text` | Plain text output (default) |
| `--output-format json` | JSON with `result`, `session_id`, and metadata |
| `--output-format stream-json` | Newline-delimited JSON for real-time streaming |
| `--json-schema '{...}'` | Constrain JSON output to a schema; result in `structured_output` field |
| `--allowedTools "Bash,Read,Edit"` | Auto-approve specific tools without prompting |
| `--permission-mode dontAsk` | Deny anything not in `permissions.allow` or the read-only set |
| `--permission-mode acceptEdits` | Auto-approve file writes and common filesystem commands |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific conversation by session ID |
| `--append-system-prompt "..."` | Add instructions while keeping default system prompt |
| `--system-prompt "..."` | Fully replace the default system prompt |

#### Bare mode context flags

In `--bare` mode, pass context explicitly:

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

Auth in bare mode: use `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`. Bedrock, Vertex, Foundry use their usual credentials.

#### Streaming events

With `--output-format stream-json --verbose --include-partial-messages`:

| Event | Key fields |
| :--- | :--- |
| `system/init` | `plugins`, `plugin_errors`, model, tools, MCP servers |
| `system/api_retry` | `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` |
| `system/plugin_install` | `status` (`started`/`installed`/`failed`/`completed`), `name`, `error` |
| Text delta | `type: "stream_event"`, `event.delta.type: "text_delta"`, `event.delta.text` |

`plugin_install` events appear when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set.

#### Tool auto-approval patterns

`--allowedTools` uses permission rule syntax. Trailing ` *` enables prefix matching:

```text
Bash(git diff *)    -- any command starting with "git diff "
Bash(git diff*)     -- also matches "git diff-index" (no space before *)
```

### Claude Code on the web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Available for Pro, Max, Team, and Enterprise (premium/Chat+Claude Code seats).

#### GitHub authentication

| Method | How | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install on specific repos during onboarding | Teams wanting per-repo authorization |
| **`/web-setup`** | Sync local `gh` CLI token to Claude account | Devs already using `gh` |

Auto-fix requires the GitHub App (needs PR webhooks). ZDR orgs cannot use `/web-setup`.

#### Cloud environment resources

- 4 vCPUs, 16 GB RAM, 30 GB disk
- Ubuntu 24.04 base
- Pre-installed: Python 3.x, Node.js 20/21/22, Ruby 3.1-3.3, PHP 8.4, Java 21, Go, Rust, C/C++, Docker, PostgreSQL 16, Redis 7.0, git, jq, ripgrep, tmux

#### What is available in cloud sessions

Available: repo CLAUDE.md, `.claude/settings.json` hooks, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/`, plugins declared in project settings.

NOT available: user `~/.claude/CLAUDE.md`, user-scoped plugins, `claude mcp add` servers, static API tokens, interactive auth (AWS SSO).

#### Setup scripts vs SessionStart hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Repository (`.claude/settings.json`) |
| Runs | Before launch, when no cached env exists | After launch, every session including resumed |
| Scope | Cloud only | Both local and cloud |
| Cached | Yes (filesystem snapshot, ~7 day expiry) | No |

Use `CLAUDE_CODE_REMOTE=true` env var to conditionally skip hooks locally.

#### Network access levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** (default) | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including defaults |

GitHub operations always go through a dedicated proxy (independent of network level).

#### Moving between web and terminal

| Direction | How |
| :--- | :--- |
| Terminal to web | `claude --remote "prompt"` (clones from GitHub, push local commits first) |
| Web to terminal | `claude --teleport`, `/teleport` (or `/tp`), `/tasks` then press `t`, or "Open in CLI" from web UI |

`--remote` creates cloud sessions. `--teleport` pulls a cloud session (with its branch) into your terminal.

Teleport requirements: clean git state, correct repo (not a fork), branch pushed to remote, same claude.ai account.

#### Bundle local repos without GitHub

`claude --remote` from a non-GitHub repo bundles and uploads automatically. Force with `CCR_FORCE_BUNDLE=1`. Limits: must be a git repo, under 100 MB, untracked files excluded.

#### Auto-fix pull requests

Enable via CI status bar ("Auto-fix"), `/autofix-pr` from terminal, mobile app, or paste PR URL. Requires the Claude GitHub App.

Claude responds to CI failures and review comments: pushes clear fixes, asks before ambiguous changes, skips duplicates. Replies posted using your GitHub account but labeled as from Claude Code.

Warning: Claude can trigger comment-based automation (Atlantis, Terraform Cloud, etc.) by replying on your behalf.

#### Session management

| Action | How |
| :--- | :--- |
| Share (Enterprise/Team) | Toggle Private / Team visibility |
| Share (Max/Pro) | Toggle Private / Public visibility |
| Archive | Hover in sidebar, select archive icon |
| Delete | Filter archived, hover and delete; or session menu > Delete |
| Pre-fill new session | URL params: `prompt`, `prompt_url`, `repositories` (or `repo`), `environment` |

#### Environment variables

Set `CLAUDE_CODE_REMOTE_SESSION_ID` is available in cloud sessions for constructing transcript links:
`https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID}`

#### Cloud session commands

| Command | Works in cloud | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Summarizes conversation; accepts focus instructions |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

Auto-compaction tuning: `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (default ~95%), `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- CLI `-p` flag, bare mode, structured output, streaming (including `stream-json` events and `jq` recipes), auto-approve tools, creating commits, customizing the system prompt, and continuing conversations.
- [Use Claude Code on the web](references/claude-code-on-the-web.md) -- Cloud environment details, GitHub auth options, installed tools, setup scripts and caching, SessionStart hooks, network access levels and domain allowlists, moving sessions between web and terminal (`--remote`, `--teleport`), session management (sharing, archiving, deleting), auto-fix pull requests, security and isolation, resource limits, and troubleshooting.
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) -- Quickstart for connecting GitHub, creating an environment, submitting a task, pre-filling sessions via URL parameters, reviewing diffs, leaving inline comments, creating PRs, and troubleshooting setup issues.

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
