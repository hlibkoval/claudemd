---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (headless/non-interactive mode) via the CLI with `-p`, plus Claude Code on the web — cloud sessions, environments, setup scripts, network access, teleporting between web and terminal, auto-fix PRs, and the web quickstart.
user-invocable: false
---

# Headless and Claude Code on the Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`-p` / headless mode) and using Claude Code on the web (cloud sessions).

## Quick Reference

### CLI Non-Interactive Mode (`-p`)

Run Claude non-interactively by passing `-p` (or `--print`) with a prompt:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

Add `--bare` to skip all local config (hooks, MCP servers, CLAUDE.md, plugins). Recommended for CI/scripts:

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

Bare mode requires `ANTHROPIC_API_KEY` (or `apiKeyHelper`) for auth — no OAuth/keychain reads.

### `--bare` Context Flags

| To load                 | Flag                                                    |
| :---------------------- | :------------------------------------------------------ |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings                | `--settings <file-or-json>`                             |
| MCP servers             | `--mcp-config <file-or-json>`                           |
| Custom agents           | `--agents <json>`                                       |
| A plugin                | `--plugin-dir <path>`, `--plugin-url <url>`             |

### Output Formats

| Format        | Description                                                               |
| :------------ | :------------------------------------------------------------------------ |
| `text`        | Default: plain text response                                              |
| `json`        | Structured JSON with `result`, `session_id`, cost metadata               |
| `stream-json` | Newline-delimited JSON events for real-time streaming                     |

Use `--json-schema` with `--output-format json` to get structured output in the `structured_output` field.

### Permission Modes (non-interactive)

| Mode            | Effect                                                                                  |
| :-------------- | :-------------------------------------------------------------------------------------- |
| `dontAsk`       | Denies anything not in `permissions.allow` or the read-only command set                 |
| `acceptEdits`   | Auto-approves file writes plus common filesystem commands (`mkdir`, `touch`, `mv`, `cp`) |

Pass with `--permission-mode <mode>`.

### `--allowedTools` Syntax

Uses permission rule syntax. Trailing ` *` enables prefix matching:

```bash
--allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"
```

The space before `*` matters: `Bash(git diff *)` matches `git diff --stat`; `Bash(git diff*)` would also match `git diff-index`.

### Stdin / Piping

Stdin is capped at 10 MB (as of v2.1.128). For larger inputs, write to a file and reference the path:

```bash
cat build-error.txt | claude -p "Explain the root cause" > output.txt
```

### Continuing Conversations

```bash
claude -p "Start a review"
claude -p "Focus on the database queries" --continue       # most recent session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"   # specific session
```

### Streaming API Retry Events

When a retryable API error occurs, `stream-json` emits a `system/api_retry` event:

| Field            | Type            | Description                               |
| :--------------- | :-------------- | :---------------------------------------- |
| `type`           | `"system"`      | Message type                              |
| `subtype`        | `"api_retry"`   | Identifies retry event                    |
| `attempt`        | integer         | Current attempt (starts at 1)             |
| `max_retries`    | integer         | Total retries permitted                   |
| `retry_delay_ms` | integer         | Milliseconds until next attempt           |
| `error_status`   | integer or null | HTTP status code, or `null` for no response|
| `error`          | string          | Error category (see below)                |
| `uuid`           | string          | Unique event identifier                   |
| `session_id`     | string          | Session the event belongs to              |

Error categories: `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown`.

### `system/init` Event Fields (stream-json)

| Field           | Type  | Description                                              |
| :-------------- | :---- | :------------------------------------------------------- |
| `plugins`       | array | Successfully loaded plugins, each with `name` and `path` |
| `plugin_errors` | array | Load-time errors, each with `plugin`, `type`, `message`  |

---

## Claude Code on the Web — Quick Reference

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist after you close the browser.

### Ways to Run Claude Code

| Surface          | Code runs on          | Uses local config | Requires GitHub            | Persists if disconnected |
| :--------------- | :-------------------- | :---------------- | :------------------------- | :----------------------- |
| Web / cloud      | Anthropic cloud VM    | No (repo only)    | Yes, or bundle via `--remote` | Yes                   |
| Remote Control   | Your machine          | Yes               | No                         | While terminal is open   |
| Terminal CLI     | Your machine          | Yes               | No                         | No                       |
| Desktop app      | Machine or cloud VM   | Yes (local)       | Only for cloud sessions    | Depends                  |

### GitHub Authentication Options

| Method         | How                                                            | Best for                              |
| :------------- | :------------------------------------------------------------- | :------------------------------------ |
| GitHub App     | Authorize during web onboarding                                | Browser onboarding; Auto-fix PRs      |
| `/web-setup`   | Run in terminal to sync local `gh` token to Claude account    | Developers already using `gh` CLI     |

GitHub App required for [Auto-fix](#auto-fix-prs). Zero Data Retention organizations cannot use `/web-setup`.

### What's Available in Cloud Sessions

| Item                                              | Available | Why                                   |
| :------------------------------------------------ | :-------- | :------------------------------------ |
| Repo `CLAUDE.md`, `.claude/settings.json` hooks   | Yes       | Part of the clone                     |
| Repo `.mcp.json` MCP servers                      | Yes       | Part of the clone                     |
| Repo `.claude/skills/`, `.claude/agents/`         | Yes       | Part of the clone                     |
| Plugins declared in repo `.claude/settings.json`  | Yes       | Installed at session start            |
| User `~/.claude/CLAUDE.md`                        | No        | Lives on your machine                 |
| Plugins only in user `~/.claude/settings.json`    | No        | Declare in repo settings instead      |
| MCP servers added with `claude mcp add`           | No        | Declare in `.mcp.json` instead        |
| Static API tokens / credentials                   | No        | No dedicated secrets store yet        |
| Interactive auth (AWS SSO, etc.)                  | No        | Not supported                         |

### Installed Tools in Cloud Sessions

| Category    | Included                                                                          |
| :---------- | :-------------------------------------------------------------------------------- |
| Python      | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff                           |
| Node.js     | 20, 21, 22 (nvm), npm, yarn, pnpm, bun*, eslint, prettier, chromedriver          |
| Ruby        | 3.1, 3.2, 3.3 with gem, bundler, rbenv                                           |
| PHP         | 8.4 with Composer                                                                 |
| Java        | OpenJDK 21, Maven, Gradle                                                         |
| Go          | Latest stable with module support                                                 |
| Rust        | rustc and cargo                                                                   |
| C/C++       | GCC, Clang, cmake, ninja, conan                                                   |
| Docker      | docker, dockerd, docker compose                                                   |
| Databases   | PostgreSQL 16, Redis 7.0 (not running by default)                                 |
| Utilities   | git, jq, yq, ripgrep, tmux, vim, nano                                             |

*Bun has known proxy compatibility issues for package fetching.

Resource limits (approximate): 4 vCPUs, 16 GB RAM, 30 GB disk.

### Environment Configuration

| Action                 | How                                                                                    |
| :--------------------- | :------------------------------------------------------------------------------------- |
| Add environment        | Web UI → environment selector → Add environment                                        |
| Edit environment       | Web UI → cloud icon → hover → settings icon                                            |
| Archive environment    | Edit dialog → Archive                                                                  |
| Set default for `--remote` | Run `/remote-env` in terminal                                                      |

Environment variables use `.env` format (`KEY=value`). Do not wrap values in quotes.

### Setup Scripts vs. SessionStart Hooks

|               | Setup scripts                                          | SessionStart hooks                             |
| :------------ | :----------------------------------------------------- | :--------------------------------------------- |
| Attached to   | Cloud environment                                      | Repository                                     |
| Configured in | Cloud environment UI                                   | `.claude/settings.json` in your repo           |
| Runs          | Before Claude Code launches (cached; skipped on re-use)| After Claude Code launches, every session start|
| Scope         | Cloud only                                             | Both local and cloud                           |

Environment cache is built after the setup script completes and reused until you edit the script/network config, or ~7 days pass.

### Network Access Levels

| Level   | Outbound connections                                               |
| :------ | :----------------------------------------------------------------- |
| None    | No outbound access                                                 |
| Trusted | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full    | Any domain                                                         |
| Custom  | Your own allowlist (optionally including Trusted defaults)         |

GitHub operations use a dedicated proxy independent of this setting. Use `*.` for wildcard subdomain matching in custom allowlists.

### Session Artifact URL

Each cloud session exposes `CLAUDE_CODE_REMOTE_SESSION_ID` (prefixed `cse_`). Build the transcript URL:

```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

### Moving Tasks Between Web and Terminal

**Terminal → Web** (`--remote`): creates a new cloud session from your current repo's GitHub remote at the current branch. Push local commits first.

```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```

For repos without GitHub, `--remote` bundles the local repo (under 100 MB; untracked files excluded). Force bundle with `CCR_FORCE_BUNDLE=1`.

**Web → Terminal** (`--teleport`): pulls a cloud session into your terminal, fetches and checks out its branch.

```bash
claude --teleport                      # interactive picker
claude --teleport <session-id>         # specific session
```

Or use `/teleport` (alias `/tp`) inside an existing CLI session.

**Teleport requirements:**

| Requirement     | Details                                                                       |
| :-------------- | :---------------------------------------------------------------------------- |
| Clean git state | No uncommitted changes (prompts to stash)                                     |
| Correct repo    | Must run from the same repository (not a fork)                                |
| Branch pushed   | Cloud session branch must exist on remote                                     |
| Same account    | Must be authenticated to the same claude.ai account                           |

Teleport requires claude.ai subscription auth. Run `/login` if authenticated via API key or third-party provider.

### Auto-fix Pull Requests

Requires Claude GitHub App installed on the repository.

Turn on auto-fix:
- PRs from Claude Code on the web: open CI status bar → Auto-fix
- From terminal: run `/autofix-pr` while on the PR branch
- Any existing PR: paste the PR URL and tell Claude to auto-fix it

Claude responds to CI failures and review comments by pushing fixes when confident, asking for clarification when ambiguous, or noting no-action events. Replies are posted under your GitHub username, labeled as coming from Claude Code.

Warning: if your repo uses comment-triggered automation (Atlantis, Terraform Cloud), Claude's replies can trigger those workflows.

### Context Management in Cloud Sessions

| Command    | Works | Notes                                                        |
| :--------- | :---- | :----------------------------------------------------------- |
| `/compact` | Yes   | Summarizes conversation; accepts focus instructions          |
| `/context` | Yes   | Shows current context window contents                        |
| `/clear`   | No    | Start a new session from the sidebar instead                 |

Auto-compaction fires at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` env var.

### Session Sharing

| Account type      | Visibility options | Notes                                                                 |
| :---------------- | :----------------- | :-------------------------------------------------------------------- |
| Enterprise / Team | Private, Team      | Team: visible to org members; repo access verification on by default  |
| Max / Pro         | Private, Public    | Public: visible to any logged-in claude.ai user                       |

### Limitations

- Rate limits are shared with all Claude usage on the account
- Repository auth: can only teleport when authenticated to the same account
- Platform: GitHub required for PR creation; GitLab/Bitbucket repos can only be sent as local bundles (no push-back)
- Organization IP allowlist: cloud sessions call Anthropic API from Anthropic infrastructure, not your network — IP allowlisting blocks all cloud sessions

### Web Quickstart — Pre-fill URL Parameters

| Parameter      | Description                                                              |
| :------------- | :----------------------------------------------------------------------- |
| `prompt` / `q` | Prompt text for the input box                                            |
| `prompt_url`   | URL to fetch prompt text from (ignored when `prompt` is set)             |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs to preselect                 |
| `environment`  | Name or ID of the environment to preselect                               |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

### Troubleshooting

| Symptom                              | Fix                                                                              |
| :----------------------------------- | :------------------------------------------------------------------------------- |
| Session creation failed              | Check status.claude.com; retry; verify GitHub repo is reachable                  |
| `Remote Control session has expired` | Run `/login` locally to refresh credentials                                      |
| Environment expired                  | Reopen from claude.ai/code to provision fresh environment with history restored  |
| Setup script failed                  | Add `set -x` to debug; append `\|\| true` to non-critical commands               |
| Sessions hang during setup           | Keep script under ~5 min; run installs in parallel with `&` and `wait`           |
| No repos after connecting GitHub     | Verify connected GitHub account has repo access                                  |
| `/web-setup` returns "Unknown command"| Run it inside Claude Code CLI, not your shell; update CLI if needed             |
| "Could not create cloud environment" | Run `/web-setup` or visit claude.ai/code to create one manually                  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — `-p` flag, `--bare` mode, piping, output formats, structured output, streaming, tool auto-approval, system prompt flags, continuing conversations
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — GitHub auth, cloud environment config, setup scripts, network access, moving tasks between web and terminal, auto-fix PRs, session management, security, limitations
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — one-time setup, connecting GitHub, creating environments, starting tasks, pre-fill URL parameters, reviewing diffs, troubleshooting

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
