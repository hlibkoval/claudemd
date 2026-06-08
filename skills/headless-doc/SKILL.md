---
name: headless-doc
user-invocable: false
---

# Headless, Web, and Session Documentation

This skill provides the complete official documentation for running Claude Code programmatically (non-interactive / headless mode), using Claude Code on the web (cloud sessions), and managing sessions.

## Quick Reference

### Non-Interactive Mode (`claude -p`)

Run Claude Code without interaction by passing `-p` (or `--print`) with a prompt:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

#### Key Flags

| Flag | Description |
|:-----|:------------|
| `-p <prompt>` | Run non-interactively; print result and exit |
| `--bare` | Skip hooks, skills, plugins, MCP, CLAUDE.md; recommended for CI |
| `--output-format text\|json\|stream-json` | Control output format (default: `text`) |
| `--json-schema <schema>` | Return structured output conforming to schema (use with `--output-format json`) |
| `--allowedTools <list>` | Pre-approve tools; supports permission rule syntax e.g. `Bash(git diff *)` |
| `--permission-mode <mode>` | Set permission baseline: `dontAsk`, `acceptEdits`, etc. |
| `--append-system-prompt <text>` | Add instructions while keeping default system prompt |
| `--append-system-prompt-file <file>` | Same but from a file |
| `--system-prompt <text>` | Fully replace default system prompt |
| `--continue` | Continue most recent conversation |
| `--resume <session-id>` | Continue a specific session by ID |
| `--include-partial-messages` | Emit partial tokens in `stream-json` mode |
| `--verbose` | Include internal events in stream output |
| `--no-session-persistence` | Skip writing transcript files (non-interactive mode only) |

#### `--bare` Mode

Skips OAuth and keychain. Authentication must use `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`. Use for scripts and CI so local config on any machine doesn't affect results.

Explicitly load context with flags when bare:

| To load | Use |
|:--------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin | `--plugin-dir <path>`, `--plugin-url <url>` |

#### Output Formats

| Format | Description |
|:-------|:------------|
| `text` | Plain text result (default) |
| `json` | JSON with `result`, `session_id`, cost breakdown, and optionally `structured_output` |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

Stdin is capped at 10 MB (as of v2.1.128); pass larger content via file path instead.

Background Bash tasks started during a `-p` run are terminated ~5 seconds after Claude returns its final result.

#### `stream-json` Event Types

Key events in stream output:

| Event `type` / `subtype` | Description |
|:--------------------------|:------------|
| `system` / `init` | Session metadata: model, tools, plugins loaded, plugin errors |
| `system` / `api_retry` | Retry in progress; fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` |
| `system` / `plugin_install` | Plugin install progress (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set) |

`api_retry` error categories: `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `rate_limit`, `overloaded`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown`.

---

### Claude Code on the Web (Cloud Sessions)

Runs on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist when you close your browser and can be monitored from the Claude mobile app.

#### Run Modes Comparison

| | On the web | Remote Control | Terminal CLI | Desktop app |
|:-|:-----------|:---------------|:-------------|:------------|
| **Code runs on** | Anthropic cloud VM | Your machine | Your machine | Your machine or cloud VM |
| **Uses local config** | No, repo only | Yes | Yes | Depends |
| **Requires GitHub** | Yes (or local bundle) | No | No | Only for cloud sessions |
| **Persists if disconnected** | Yes | While terminal open | No | Depends |
| **Permission modes** | Auto accept edits, Plan | Ask, Auto accept edits, Plan | All modes | Depends |

#### GitHub Authentication

| Method | Best for |
|:-------|:---------|
| **GitHub App** (browser onboarding) | Teams, Auto-fix PR feature |
| **`/web-setup`** in terminal | Individual devs already using `gh` CLI |

#### What's Available in Cloud Sessions

| Item | Available | Why |
|:-----|:----------|:----|
| `CLAUDE.md`, `.claude/settings.json`, `.mcp.json` | Yes | Part of the repo clone |
| `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the repo clone |
| Plugins in `.claude/settings.json` | Yes | Installed at session start |
| `~/.claude/CLAUDE.md`, user-scope plugins | No | Lives on your machine |
| Static API tokens/secrets | No | No secrets store yet |
| Interactive auth (AWS SSO) | No | Browser-based login unsupported |

#### Pre-installed Runtimes

| Category | Included |
|:---------|:---------|
| Python | 3.x, pip, poetry, uv, pytest, ruff, mypy, black |
| Node.js | 20, 21, 22 via nvm; npm, yarn, pnpm, bun*, eslint, prettier |
| Ruby | 3.1–3.3 with gem, bundler, rbenv |
| PHP | 8.4 with Composer |
| Java | OpenJDK 21, Maven, Gradle |
| Go | Latest stable |
| Rust | rustc, cargo |
| C/C++ | GCC, Clang, cmake, ninja, conan |
| Databases | PostgreSQL 16, Redis 7.0 (not started by default) |
| Docker | docker, dockerd, docker compose |
| Utilities | git, jq, yq, ripgrep, tmux, vim, nano |

*Bun has known proxy compatibility issues for package fetching.

Resource ceilings: ~4 vCPUs, 16 GB RAM, 30 GB disk.

#### Environment Configuration

Environments control network access, environment variables, and the setup script. Manage from the web UI or set the default remote env with `/remote-env` in your terminal.

**Network Access Levels:**

| Level | Outbound connections |
|:------|:--------------------|
| None | No outbound access |
| Trusted | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full | Any domain |
| Custom | Your own allowlist, optionally plus Trusted defaults |

GitHub operations always use a dedicated proxy independent of network access level. Use `*.` prefix for wildcard subdomain matching in custom domain lists.

Environment variables use `.env` format (one `KEY=value` per line, no quotes around values).

#### Setup Scripts vs. SessionStart Hooks

| | Setup scripts | SessionStart hooks |
|:--|:--------------|:-------------------|
| Attached to | Cloud environment | Repository |
| Configured in | Cloud environment UI | `.claude/settings.json` |
| Runs | Before Claude Code launches (cached after first run) | After Claude Code launches, every session including resumed |
| Scope | Cloud only | Both local and cloud |

Setup script cache rebuilds when: script changes, allowed network hosts change, or cache expires (~7 days). Target under ~5 minutes runtime. Run independent installs in parallel with `&` and `wait`.

Use `CLAUDE_CODE_REMOTE=true` env check in SessionStart hooks to skip local execution.

#### Moving Sessions Between Web and Terminal

**Terminal to web:**
```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```
Clones current directory's GitHub remote at current branch — push first if you have local commits.

**Web to terminal (teleport):**
```bash
claude --teleport               # interactive picker
claude --teleport <session-id>  # direct resume
```
Or from inside a session: `/teleport` (alias `/tp`). Also accessible from `/tasks` (press `t`).

Teleport requirements: clean git state, correct repository, branch pushed to remote, same claude.ai account.

**Special env vars in cloud sessions:**

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_REMOTE` | `true` in cloud sessions |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | Session ID (`cse_` prefix); build transcript URL by replacing with `session_` |

#### Running Tasks in Parallel

Each `--remote` invocation creates an independent cloud session. Start multiple for parallel work; monitor with `/tasks` in the CLI.

#### Bundling Local Repos Without GitHub

When no GitHub connection is present, `--remote` bundles and uploads the local repo. Force with `CCR_FORCE_BUNDLE=1`. Limits: must be a git repo with at least one commit, bundle under 100 MB, untracked files excluded.

#### Auto-Fix Pull Requests

Requires the Claude GitHub App. Claude monitors a PR for CI failures and review comments and pushes fixes autonomously. Enable via:
- PRs from Claude Code on the web: CI status bar > **Auto-fix**
- From terminal: `/autofix-pr` on the PR's branch
- Any PR: paste URL into session and ask Claude to auto-fix

Claude posts replies to GitHub review threads under your username, labeled as coming from Claude Code. Be aware this can trigger comment-activated automation (Atlantis, Terraform Cloud, etc.).

#### Session Sharing

| Account type | Visibility options |
|:-------------|:-------------------|
| Enterprise / Team | Private, Team (repo access verification enabled by default) |
| Max / Pro | Private, Public (repo access verification off by default) |

#### Context Management in Cloud Sessions

| Command | Works in cloud | Notes |
|:--------|:---------------|:------|
| `/compact [instructions]` | Yes | Summarizes conversation |
| `/context` | Yes | Shows context window usage |
| `/clear` | No | Start a new session from sidebar instead |

Use `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to trigger auto-compaction earlier (e.g., `70` for 70% threshold).

---

### Session Management (CLI)

Sessions are saved conversations tied to a project directory, stored as JSONL at `~/.claude/projects/<project>/<session-id>.jsonl`.

#### Resuming Sessions

| Command | Action |
|:--------|:-------|
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Open interactive session picker |
| `claude --resume <name>` | Resume named session directly |
| `claude --from-pr <number>` | Resume session linked to that PR |
| `/resume` | Switch to another session from inside active session |

Sessions from `claude -p` or Agent SDK don't appear in the picker but can be resumed by session ID.

#### Session Picker Shortcuts

| Key | Action |
|:----|:-------|
| `↑` / `↓` | Navigate |
| `→` / `←` | Expand / collapse grouped sessions |
| `Enter` | Resume highlighted session |
| `Space` or `Ctrl+V` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or any printable char | Enter search / filter mode |
| `Ctrl+A` | Widen to all projects on this machine (toggle) |
| `Ctrl+W` | Widen to all worktrees of current repo (toggle) |
| `Ctrl+B` | Filter to current git branch (toggle) |
| `Esc` | Exit picker or search mode |

#### Naming Sessions

| When | How |
|:-----|:----|
| At startup | `claude -n <name>` |
| During a session | `/rename <name>` |
| From session picker | Highlight + `Ctrl+R` |
| On plan accept | Named automatically from plan content if not already named |

#### Branching Sessions

From inside a session: `/branch [name]` — creates a copy of the conversation, leaves original intact.

From CLI: `claude --continue --fork-session` or `claude --resume <name> --fork-session`.

Permissions approved with "allow for this session" do not carry over to a branch.

#### Context Commands

| Command | Effect |
|:--------|:-------|
| `/clear` | Start fresh context; previous conversation saved and resumable |
| `/compact [instructions]` | Replace history with a focused summary |
| `/context` | Show current context window usage |
| `/export [filename]` | Copy conversation to clipboard or save as plain-text file |

#### Session Storage

- Location: `~/.claude/projects/<project>/<session-id>.jsonl`
- Custom location: set `CLAUDE_CONFIG_DIR` env var
- Default cleanup: 30 days (change with `cleanupPeriodDays` setting)
- Suppress transcript writes: set `CLAUDE_CODE_SKIP_PROMPT_HISTORY`, or use `--no-session-persistence` in non-interactive mode

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `claude -p`, `--bare`, output formats, streaming events, `--allowedTools`, conversation continuation
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — Cloud environments, setup scripts, network access, `--remote`, `--teleport`, auto-fix PRs, security isolation
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — First-time setup, connect GitHub, start a task, review and iterate, troubleshooting
- [Manage sessions](references/claude-code-sessions.md) — Resume, name, branch, and export sessions; session picker reference

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
- Manage sessions: https://code.claude.com/docs/en/sessions.md
