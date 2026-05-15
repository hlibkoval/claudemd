---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (headless/non-interactive mode via -p flag), Claude Code on the web (cloud sessions, environments, setup scripts, network access, teleport), and the web quickstart (connecting GitHub, starting tasks, reviewing PRs).
user-invocable: false
---

# Headless, Cloud, and Web Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (headless mode), using Claude Code on the web (cloud sessions), and getting started with the web interface.

## Quick Reference

### Headless / Non-Interactive Mode (`-p` flag)

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Run non-interactively; print response and exit |
| `--bare` | Skip hooks, skills, plugins, MCP, CLAUDE.md — recommended for CI/scripts |
| `--allowedTools "Read,Edit,Bash"` | Auto-approve specific tools |
| `--permission-mode acceptEdits` | Auto-approve file writes and common FS commands |
| `--permission-mode dontAsk` | Deny anything not in `permissions.allow` or read-only set |
| `--output-format text` | Plain text output (default) |
| `--output-format json` | Structured JSON with `result`, `session_id`, `total_cost_usd` |
| `--output-format stream-json` | Newline-delimited JSON events for streaming |
| `--json-schema '<schema>'` | Constrain JSON output to a schema; result in `structured_output` field |
| `--include-partial-messages` | Include token deltas in stream-json output |
| `--verbose` | Enable verbose event output (required for streaming deltas) |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific conversation by session ID |
| `--append-system-prompt "..."` | Add instructions while keeping default behavior |
| `--append-system-prompt-file <f>` | Same, from a file |
| `--system-prompt "..."` | Fully replace the default system prompt |
| `--settings <file-or-json>` | Load settings (bare mode: use for auth via `apiKeyHelper`) |
| `--mcp-config <file-or-json>` | Load MCP server config |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin from a local directory |
| `--plugin-url <url>` | Load a plugin from a URL |

**Stdin cap:** 10 MB (v2.1.128+). For larger inputs, write to a file and reference the path in the prompt.

**`--bare` skips:** OAuth, keychain reads, hooks, skills, plugins, MCP, CLAUDE.md, auto memory. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`.

**Note:** `--bare` will become the default for `-p` in a future release.

### Output Format Examples

```bash
# Plain text (default)
claude -p "What does the auth module do?"

# JSON with cost metadata
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Structured output with schema
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}' \
  | jq '.structured_output'

# Streaming
claude -p "Explain recursion" --output-format stream-json --verbose --include-partial-messages
```

### Stream Event Types

| Event type/subtype | Description |
| :--- | :--- |
| `system/init` | Session metadata: model, tools, MCP, plugins loaded. Has `plugins` (loaded) and `plugin_errors` arrays. |
| `system/api_retry` | API retry in progress. Fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` |
| `system/plugin_install` | Plugin install progress (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set). `status`: `started`, `installed`, `failed`, `completed` |
| `stream_event` with `delta.type == "text_delta"` | Token delta for streaming text |

### `--allowedTools` Permission Rule Syntax

```bash
# Exact tool
--allowedTools "Read,Edit"

# Prefix matching (space before * is required)
--allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"
```

**Note:** `Bash(git diff*)` without a space also matches `git diff-index`. Use `Bash(git diff *)` for prefix-only.

### Conversation Management

```bash
# Continue most recent
claude -p "Now focus on database queries" --continue

# Resume specific session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Cloud Sessions vs. Other Modes

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| **Code runs on** | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| **Chat from** | claude.ai / mobile | claude.ai / mobile | Terminal | Desktop UI |
| **Local config** | No (repo only) | Yes | Yes | Yes (local) / No (cloud) |
| **Requires GitHub** | Yes (or bundle) | No | No | Only for cloud sessions |
| **Persists if disconnected** | Yes | While terminal open | No | Depends |
| **Permission modes** | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All | Depends |

### Cloud Session: What's Available

| Config item | Available in cloud | Why |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md` | Yes | Part of the clone |
| Repo's `.claude/settings.json` hooks | Yes | Part of the clone |
| Repo's `.mcp.json` | Yes | Part of the clone |
| Repo's `.claude/skills/`, `.claude/agents/` | Yes | Part of the clone |
| Plugins in repo's `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| User-scoped plugins (`~/.claude/settings.json`) | No | Not in repo |
| MCP servers added via `claude mcp add` | No | Written to local user config |
| Static API tokens / secrets | No | No secrets store yet |
| Interactive auth (AWS SSO, etc.) | No | Not supported |

### Cloud Session: Installed Tools

| Category | Included |
| :--- | :--- |
| Python | 3.x with pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun, eslint, prettier, chromedriver |
| Ruby | 3.1, 3.2, 3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21 with Maven and Gradle |
| Go | Latest stable with module support |
| Rust | rustc and cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not started by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

Run `check-tools` in a cloud session for exact versions.

**Resource limits (approximate):** 4 vCPUs, 16 GB RAM, 30 GB disk.

### GitHub Auth for Cloud Sessions

| Method | How | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Authorize via browser onboarding at claude.ai/code | Browser setup; teams needing Auto-fix |
| **`/web-setup`** | Run in Claude Code CLI to sync local `gh` token | Devs already using `gh` CLI |

GitHub App is required for Auto-fix (PR webhooks). Either method grants access to any repo the connected account can see.

### Network Access Levels

| Level | Outbound connections |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** | Default allowlist (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist; optionally include defaults |

GitHub operations always go through a separate dedicated proxy regardless of access level.

### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches (cached after first run) | After Claude Code launches, every session including resumed |
| Scope | Cloud only | Both local and cloud |

**Environment caching:** setup script runs once; Anthropic snapshots the filesystem for future sessions. Cache rebuilt when script changes, allowed hosts change, or after ~7 days.

**Cache contains files, not running processes.** Start services (PostgreSQL, Redis, Docker) per-session or via a SessionStart hook.

**Skip hook in local sessions** by checking `CLAUDE_CODE_REMOTE`:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

### Move Tasks Between Web and Terminal

| Action | Command |
| :--- | :--- |
| Start a cloud session from terminal | `claude --remote "Fix the auth bug"` |
| Parallel cloud tasks | Run multiple `claude --remote` commands |
| Force local bundle (no GitHub) | `CCR_FORCE_BUNDLE=1 claude --remote "..."` |
| Teleport cloud session to terminal | `claude --teleport` (interactive picker) or `claude --teleport <session-id>` |
| Teleport within existing CLI session | `/teleport` or `/tp` |
| View background sessions | `/tasks` (press `t` to teleport) |
| Check session link | `echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"` |

**`--remote` clones from GitHub at your current branch — push local commits first.**

**Teleport requirements:** clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account.

**`--teleport` unavailable?** Requires claude.ai subscription auth. Run `/login` if using API key or Bedrock/Vertex.

### Pre-fill Web Sessions via URL

```text
https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp
```

| Parameter | Description |
| :--- | :--- |
| `prompt` / `q` | Prefill prompt text |
| `prompt_url` | URL to fetch prompt from (ignored if `prompt` set) |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs |
| `environment` | Environment name or ID |

### Auto-fix Pull Requests

Requires the Claude GitHub App installed on the repository.

| How to enable | Method |
| :--- | :--- |
| PR created in Claude Code on the web | Open CI status bar → select Auto-fix |
| From terminal | Run `/autofix-pr` on the PR's branch |
| From mobile app | Tell Claude to auto-fix the PR |
| Any existing PR | Paste PR URL into session and ask Claude to auto-fix |

**How Claude responds:** confident fixes are pushed automatically; ambiguous requests prompt you first; duplicates/no-action events are noted and skipped.

**Warning:** Claude may post replies to GitHub review threads under your username (labeled as Claude Code). This can trigger comment-triggered automation (Atlantis, Terraform Cloud, etc.).

### Context Management in Cloud Sessions

| Command | Available | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Optional focus: `/compact keep the test output` |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start new session from sidebar instead |

Auto-compaction runs at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` in environment variables.

### Cloud Session Troubleshooting

| Issue | Likely cause | Fix |
| :--- | :--- | :--- |
| `Session creation failed` | Capacity or GitHub access | Check status.claude.com; retry; verify GitHub auth |
| `Remote Control session expired` | Short-lived token | Run `/login` locally to refresh |
| `Environment expired` | Idle timeout | Reopen from claude.ai/code |
| Setup script failed | Non-zero exit | Add `set -x`; append `|| true` to non-critical commands |
| Sessions hang during setup | Script exceeds ~5-minute cache build budget | Parallelize with `&` / `wait`; move heavy downloads to SessionStart hook |
| `--teleport` unavailable | Not using claude.ai subscription | Run `/login` |
| Organization IP allowlist | Cloud sessions call Anthropic API from Anthropic infra | Contact Anthropic support to exempt |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `-p` flag, `--bare` mode, output formats, stdin piping, streaming, tool approval, commit workflows, system prompt customization, conversation continuation
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — GitHub auth, cloud environment config, installed tools, setup scripts, environment caching, network access levels, `--remote` and `--teleport`, session management, auto-fix PRs, security and isolation, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — first-time setup, connecting GitHub, creating an environment, submitting tasks, reviewing diffs, inline comments, creating PRs, troubleshooting common setup issues

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
