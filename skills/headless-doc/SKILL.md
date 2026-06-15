---
name: headless-doc
user-invocable: false
---

# Headless & Web Sessions Documentation

This skill provides the complete official documentation for running Claude Code non-interactively (`claude -p`), Claude Code on the web (cloud sessions), session management (resume, branch, name), and the web quickstart guide.

## Quick Reference

### Non-Interactive Mode (`claude -p`)

Run Claude non-interactively by passing `-p` (or `--print`) with your prompt:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

**Key flags:**

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Run non-interactively; required for all headless use |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, CLAUDE.md; recommended for CI |
| `--output-format` | `text` (default), `json`, or `stream-json` |
| `--json-schema` | JSON Schema for structured output (use with `--output-format json`) |
| `--allowedTools` | Auto-approve named tools without prompting |
| `--permission-mode` | `dontAsk` or `acceptEdits` for baseline permissions |
| `--append-system-prompt` | Add instructions while keeping default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific session by ID |
| `--include-partial-messages` | Include partial tokens in `stream-json` output |
| `--verbose` | Enable verbose output (required for streaming token events) |
| `--no-session-persistence` | Suppress transcript writes in non-interactive mode |

**`--bare` mode context loading** (bare skips everything not explicitly passed):

| To load | Use |
| :--- | :--- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

Authentication in bare mode: must use `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON; OAuth/keychain not available.

**Output formats:**

| Format | Returns |
| :--- | :--- |
| `text` | Plain text response |
| `json` | `{ result, session_id, total_cost_usd, ... }` |
| `stream-json` | Newline-delimited JSON events |

**Structured output example:**
```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
# Result in: .structured_output
```

**`stream-json` retry event fields (`system/api_retry`):**

| Field | Description |
| :--- | :--- |
| `attempt` | Current attempt number (starting at 1) |
| `max_retries` | Total retries permitted |
| `retry_delay_ms` | Milliseconds until next attempt |
| `error_status` | HTTP status code or `null` for connection errors |
| `error` | Category: `authentication_failed`, `rate_limit`, `overloaded`, `server_error`, etc. |

**`system/init` event** (first event in stream): reports session metadata including `plugins` (array of loaded plugins with `name` and `path`) and `plugin_errors` (load-time errors). Use `plugin_errors` to fail CI when a plugin did not load.

**`system/plugin_install` events** (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set):

| Field | Values | Description |
| :--- | :--- | :--- |
| `status` | `started`, `installed`, `failed`, `completed` | `started`/`completed` bracket the overall install |
| `name` | string (optional) | Marketplace name, present on `installed` and `failed` |
| `error` | string (optional) | Failure message, present on `failed` |

**Permission mode shortcuts:**
- `dontAsk`: denies anything not in `permissions.allow` rules or read-only command set
- `acceptEdits`: lets Claude write files without prompting; also auto-approves `mkdir`, `touch`, `mv`, `cp`

**Piped stdin cap:** 10 MB (as of v2.1.128). Larger inputs must be written to a file.

**Background tasks:** a background Bash task started during `claude -p` is terminated ~5 seconds after Claude returns its final result and stdin closes.

**Note:** User-invoked skills and custom commands work in `-p` mode — include `/skill-name` in the prompt string. Interactive built-in commands (`/config`, `/login`) are not available.

---

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist when you close your browser; monitor from the Claude mobile app.

**GitHub authentication options:**

| Method | How | Best for |
| :--- | :--- | :--- |
| **GitHub App** | Authorize the Claude GitHub App during web onboarding | Browser onboarding; teams wanting Auto-fix |
| **`/web-setup`** | Run `/web-setup` in terminal to sync local `gh` CLI token | Developers already using `gh` |

**What's available in cloud sessions:**

| Config | Available | Reason |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/rules/` | Yes | Part of the clone |
| Repo's `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start |
| Your `~/.claude/CLAUDE.md`, `~/.claude/skills/`, etc. | No | Lives on your machine |
| MCP servers added with `claude mcp add` | No | Writes to local user config |
| Static API tokens / credentials | No | No dedicated secrets store yet |
| Interactive auth (e.g., AWS SSO) | No | Not supported |

**Pre-installed runtimes (cloud VMs):**

| Category | Included |
| :--- | :--- |
| Python | 3.x, pip, poetry, uv, black, mypy, pytest, ruff |
| Node.js | 20/21/22 via nvm, npm, yarn, pnpm, bun¹, eslint, prettier |
| Ruby | 3.1/3.2/3.3, gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Docker | docker, dockerd, docker compose |
| Databases | PostgreSQL 16, Redis 7.0 (not running by default) |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

¹ Bun has known proxy compatibility issues for package fetching.

**Resource limits (approximate, may change):**
- 4 vCPUs, 16 GB RAM, 30 GB disk

**Session ID env var:** `CLAUDE_CODE_REMOTE_SESSION_ID` (prefix `cse_`). Build transcript URL:
```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

**Network access levels:**

| Level | Outbound |
| :--- | :--- |
| **None** | No outbound access |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full** | Any domain |
| **Custom** | Your own allowlist, optionally including defaults |

GitHub operations always go through a separate dedicated proxy regardless of network level.

**Setup scripts vs. SessionStart hooks:**

| | Setup scripts | SessionStart hooks |
| :--- | :--- | :--- |
| Attached to | Cloud environment | Your repository |
| Configured in | Cloud environment UI | `.claude/settings.json` in repo |
| Runs | Before Claude Code launches (when no cached env) | After Claude Code launches, on every session including resumed |
| Scope | Cloud only | Local and cloud |

Setup script caching: Anthropic snapshots the filesystem after first run; subsequent sessions start from the snapshot. Cache rebuilds on setup script/network host changes, or after ~7 days.

**Cloud-only SessionStart hook pattern:**
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup|resume",
      "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/install_pkgs.sh" }]
    }]
  }
}
```
Check `CLAUDE_CODE_REMOTE=true` to skip local execution in the hook script.

**Move sessions between terminal and web:**

| Direction | Command | Notes |
| :--- | :--- | :--- |
| Terminal → web | `claude --remote "task description"` | Creates new cloud session; push local commits first (VM clones from GitHub) |
| Terminal → web (no GitHub) | `CCR_FORCE_BUNDLE=1 claude --remote "..."` | Bundles local repo and uploads it; must be under 100 MB |
| Web → terminal | `claude --teleport` or `claude --teleport <session-id>` | Requires clean git state, correct repo, branch pushed to remote, same account |
| Inside session | `/teleport` or `/tp` | Opens session picker |
| Via tasks list | `/tasks` then `t` | Teleport from background session list |

**Teleport requirements:** clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account.

**Teleport unavailable when:** authenticated via API key, Bedrock, Vertex AI, or Microsoft Foundry (run `/login` to switch to claude.ai auth).

**Auto-fix pull requests:** Claude monitors a PR for CI failures and review comments and pushes fixes automatically. Requires the Claude GitHub App installed on the repository. Activate with: CI status bar → Auto-fix, `/autofix-pr` in terminal on PR branch, or by asking Claude in a session.

**Context management commands in cloud sessions:**

| Command | Works in cloud | Notes |
| :--- | :--- | :--- |
| `/compact [instructions]` | Yes | Summarizes conversation to free context |
| `/context` | Yes | Shows current context window contents |
| `/clear` | No | Start a new session from the sidebar instead |

**Share sessions:** Enterprise/Team use Private/Team visibility; Max/Pro use Private/Public visibility.

**Limitations:**
- Rate limits shared with all other Claude/Claude Code usage in your account
- Repository authentication must match between web and local
- GitHub required for cloning and PR creation (GitLab/Bitbucket can use bundle mode but can't push back)
- Organization IP allowlists block cloud sessions (contact Anthropic support to exempt)

---

### Session Management (CLI)

**Resume a session:**

| Command | What it does |
| :--- | :--- |
| `claude --continue` | Resumes most recent session in current directory |
| `claude --resume` | Opens interactive session picker |
| `claude --resume <name>` | Resumes named session directly |
| `claude --from-pr <number>` | Resumes session linked to that pull request |
| `/resume` | Switches to a different session from inside an active one |

Sessions created with `claude -p` or the Agent SDK don't appear in the session picker, but can be resumed by session ID from the directory where they were started.

**Session picker scope controls:**

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+W` | Widen to all worktrees of the current repo |
| `Ctrl+A` | Widen to all projects on this machine |
| `Ctrl+B` | Filter to current git branch |
| `Ctrl+R` | Rename highlighted session |
| `/` or printable char | Enter search mode (paste PR URL to find session) |
| `Space` | Preview session content |

**Name sessions:**

| When | How |
| :--- | :--- |
| At startup | `claude -n auth-refactor` |
| During a session | `/rename auth-refactor` |
| From session picker | Highlight + `Ctrl+R` |
| On plan accept | Auto-named from plan content (if not already named) |

**Branch a session** (creates a copy to try a different approach):
- Inside a session: `/branch <optional-name>`
- From command line: `claude --continue --fork-session`

Permissions approved with "allow for this session" do not carry over to the new branch.

**Manage context:**
- `/clear`: start fresh (prior conversation is saved and resumable)
- `/compact [instructions]`: replace history with a summary
- `/context`: show what is consuming context

**Session data location:** `~/.claude/projects/<project>/<session-id>.jsonl`

Default retention: 30 days (change with `cleanupPeriodDays` in settings). To suppress transcript writes: set `CLAUDE_CODE_SKIP_PROMPT_HISTORY`, or use `--no-session-persistence` in non-interactive mode. Run `/export` to copy or save the conversation as plain text.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `claude -p`, `--bare` mode, output formats, streaming, auto-approve tools, system prompt flags, conversation continuation
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Cloud environments, GitHub auth, setup scripts, network access, teleport, auto-fix PRs, security and isolation
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — Quickstart: connect GitHub, create environment, submit tasks, review diffs, create PRs
- [Manage sessions](references/claude-code-sessions.md) — Resume, name, branch, export, and locate sessions; session picker keyboard shortcuts

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
