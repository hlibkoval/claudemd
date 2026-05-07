---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (headless/CLI mode) and using Claude Code on the web — the -p flag, bare mode, output formats, streaming, tool approval, session continuation, cloud environments, setup scripts, network access, teleport, auto-fix PRs, and web quickstart.
user-invocable: false
---

# Headless / Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI and for using Claude Code on the web.

## Quick Reference

### CLI Non-Interactive Mode (`-p`)

The `-p` (or `--print`) flag runs Claude non-interactively. All [CLI options](/en/cli-reference) work with it.

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

**Bare mode** (`--bare`) — skips auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md. Recommended for CI/scripts. Will become the default for `-p` in a future release.

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

Bare mode context flags:

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

In bare mode, authentication must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` in `--settings` JSON.

### Output Formats

| Format | Description |
| :--- | :--- |
| `text` | Plain text (default) |
| `json` | Structured JSON with `result`, `session_id`, cost metadata |
| `stream-json` | Newline-delimited JSON for real-time streaming |

**Structured output with schema:**
```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
# Result in .structured_output field
```

**Streaming with jq:**
```bash
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### Stream Events

**`system/api_retry` fields:** `type`, `subtype`, `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error`, `uuid`, `session_id`

**Error categories:** `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown`

**`system/init` plugin fields:**

| Field | Description |
| :--- | :--- |
| `plugins` | Plugins that loaded successfully (each with `name` and `path`) |
| `plugin_errors` | Load-time errors (each with `plugin`, `type`, `message`) |

**`system/plugin_install` fields (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set):** `type`, `subtype`, `status` (`started`/`installed`/`failed`/`completed`), `name`, `error`, `uuid`, `session_id`

### Tool Approval

```bash
# List specific tools
claude -p "Run the test suite and fix any failures" --allowedTools "Bash,Read,Edit"

# Permission modes
claude -p "Apply the lint fixes" --permission-mode acceptEdits
```

**Permission modes:** `dontAsk` (deny anything not in `permissions.allow` or read-only set), `acceptEdits` (write files + common filesystem commands without prompting).

**Allowlist with prefix matching (space before `*` required):**
```bash
claude -p "Create a commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

### Continue Conversations

```bash
claude -p "Review this codebase for performance issues"
claude -p "Now focus on the database queries" --continue
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Piped Input

Stdin is capped at 10 MB (as of v2.1.128):
```bash
cat build-error.txt | claude -p 'explain the root cause' > output.txt
```

---

### Claude Code on the Web — Overview

Sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist across browser closes and can be monitored from the Claude mobile app.

**Best for:** parallel tasks, repos you don't have locally, well-defined tasks that don't need frequent steering, code exploration.

**GitHub authentication methods:**

| Method | How it works | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Install Claude GitHub App per-repo during web onboarding | Teams wanting explicit per-repo authorization |
| **`/web-setup`** | Syncs local `gh` CLI token to Claude account | Individual devs who already use `gh` |

GitHub App is required for Auto-fix (receives PR webhooks).

**Session flow:** Clone repo → Run setup script → Configure network → Claude works → Pushes branch → You review/PR.

### Cloud Environment — Installed Tools

| Category | Included |
| :--- | :--- |
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20, 21, 22 (nvm), npm, yarn, pnpm, bun*, eslint, prettier, chromedriver |
| Ruby | 3.1–3.3, gem, bundler, rbenv |
| PHP | 8.4, Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

*Bun has known proxy compatibility issues for package fetching.

Run `check-tools` inside a cloud session for exact versions.

**Resource limits (approximate):** 4 vCPUs, 16 GB RAM, 30 GB disk.

**Session environment variable:** `CLAUDE_CODE_REMOTE_SESSION_ID` — session transcript URL: `https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID}`

### Cloud Environment — What Carries Over

| Item | Available in cloud | Why |
| :--- | :--- | :--- |
| Repo `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start from marketplace |
| User `~/.claude/CLAUDE.md` | No | Lives on your machine |
| User-scoped plugins | No | User settings aren't in repo |
| MCP servers added with `claude mcp add` | No | Written to local user config |
| Static API tokens | No | No dedicated secrets store yet |
| Interactive auth (AWS SSO) | No | Requires browser login |

### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches (cached) | After Claude Code launches, every session |
| Scope | Cloud environments only | Both local and cloud |

**Environment caching:** setup script runs once, then filesystem is snapshotted. Rebuilds when script or network hosts change, or after ~7 days.

**Cloud-only SessionStart hook:**
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

Check `CLAUDE_CODE_REMOTE=true` inside the script to skip local execution.

### Network Access Levels

| Level | Outbound connections |
| :--- | :--- |
| None | No outbound network access |
| Trusted | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist, optionally including the defaults |

Use `*.` for wildcard subdomain matching in custom allowlists.

GitHub operations always go through a separate GitHub proxy (scoped credential, push restricted to current branch).

### Move Tasks Between Web and Terminal

**Terminal to web (`--remote`):**
```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```
Clones current directory's GitHub remote at current branch (push first if you have local commits). Use `/tasks` to check progress.

**Run parallel tasks:**
```bash
claude --remote "Fix the flaky test in auth.spec.ts"
claude --remote "Update the API documentation"
```

**Plan locally, execute remotely:**
```bash
claude --permission-mode plan          # Explore without editing
# Commit plan, then:
claude --remote "Execute the migration plan in docs/migration-plan.md"
```

**Local bundle fallback** (no GitHub, or `CCR_FORCE_BUNDLE=1`): bundles entire repo (max 100 MB) and uploads. Untracked files not included.

**Web to terminal (`--teleport`):**
```bash
claude --teleport              # Interactive session picker
claude --teleport <session-id> # Resume specific session
```
Also: `/teleport` (or `/tp`) inside a running CLI session, `/tasks` then press `t`, or **Open in CLI** from the web UI.

**Teleport requirements:**

| Requirement | Details |
| :--- | :--- |
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be a checkout of the same repo, not a fork |
| Branch available | Branch must have been pushed to remote |
| Same account | Must be authenticated to the same claude.ai account |

Teleport requires claude.ai subscription authentication (not API key or Bedrock/Vertex).

### Session Management

**Context commands in cloud sessions:**

| Command | Works | Notes |
| :--- | :--- | :--- |
| `/compact` | Yes | Optional focus: `/compact keep the test output` |
| `/context` | Yes | Shows current context window |
| `/clear` | No | Start new session from sidebar instead |

Auto-compaction at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70`.

**Session sharing:**
- Enterprise/Team: Private or Team visibility (repo access verification on by default)
- Max/Pro: Private or Public (repo access verification off by default)

### Auto-fix Pull Requests

Requires Claude GitHub App. Claude watches a PR and responds to CI failures and review comments.

**Ways to enable:**
- PRs from Claude Code on the web: **Auto-fix** button in CI status bar
- From terminal: `/autofix-pr` on the PR's branch
- From mobile app: tell Claude to auto-fix the PR
- Any existing PR: paste PR URL and ask Claude to auto-fix

**Claude's response logic:** clear fix → commits and explains; ambiguous → asks you; duplicate/no-action → notes and moves on.

Replies posted under your GitHub account, labeled as coming from Claude Code.

### Web Setup Quick Reference

**One-time browser setup:** visit [claude.ai/code](https://claude.ai/code) → install Claude GitHub App → create environment.

**Terminal setup (`/web-setup`):**
```bash
gh auth login
# Inside claude:
/login
/web-setup
```

**Pre-fill sessions via URL:**
```
https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp
```

Parameters: `prompt` (alias `q`), `prompt_url`, `repositories` (alias `repo`), `environment`.

### Compare Ways to Run Claude Code

| | On the web | Remote Control | Terminal CLI | Desktop app |
| :--- | :--- | :--- | :--- | :--- |
| Code runs on | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| You chat from | claude.ai or mobile | claude.ai or mobile | Your terminal | Desktop UI |
| Uses local config | No, repo only | Yes | Yes | Yes for local, no for cloud |
| Requires GitHub | Yes (or bundle) | No | No | Only for cloud sessions |
| Keeps running if disconnected | Yes | While terminal stays open | No | Depends on session type |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — the `-p` flag, bare mode, output formats, streaming, tool approval, session continuation, and piped input
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environments, GitHub auth, installed tools, setup scripts, network access, `--remote`, `--teleport`, session management, auto-fix PRs, security, and limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — step-by-step first-time setup, starting tasks, reviewing and iterating, and troubleshooting

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
