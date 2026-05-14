---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically and on the web — headless/non-interactive CLI mode with -p flag, bare mode, structured output, streaming, auto-approved tools, and Claude Code on the web including cloud environments, setup scripts, network access, GitHub integration, session management, and teleport.
user-invocable: false
---

# Headless and Cloud (Web) Documentation

This skill provides the complete official documentation for running Claude Code programmatically (headless/non-interactive mode) and as a cloud-hosted web service.

## Quick Reference

### Headless / Non-interactive Mode (`-p`)

Run Claude non-interactively with the `-p` (or `--print`) flag:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

**Recommended: use `--bare` for CI/scripts** (skips hooks, skills, plugins, MCP, CLAUDE.md):

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

`--bare` is the recommended mode for scripted calls and will become the default for `-p` in a future release.

### Bare Mode: What to Pass Explicitly

| To load                 | Use                                                     |
| :---------------------- | :------------------------------------------------------ |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings                | `--settings <file-or-json>`                             |
| MCP servers             | `--mcp-config <file-or-json>`                           |
| Custom agents           | `--agents <json>`                                       |
| A plugin                | `--plugin-dir <path>`, `--plugin-url <url>`             |

Auth in bare mode: use `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`. Bedrock/Vertex/Foundry use their usual provider credentials.

### Output Formats

| Format        | Description                                              |
| :------------ | :------------------------------------------------------- |
| `text`        | Plain text (default)                                     |
| `json`        | Structured JSON with `result`, `session_id`, metadata   |
| `stream-json` | Newline-delimited JSON for real-time streaming           |

```bash
claude -p "Summarize this project" --output-format json
claude -p "Extract function names from auth.py" --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

Use `jq -r '.result'` to extract text; `jq '.structured_output'` for schema output.

### Streaming

```bash
claude -p "Explain recursion" --output-format stream-json --verbose --include-partial-messages
```

**`system/api_retry` event fields:**

| Field            | Type            | Description                                                      |
| :--------------- | :-------------- | :--------------------------------------------------------------- |
| `type`           | `"system"`      | Message type                                                     |
| `subtype`        | `"api_retry"`   | Retry event identifier                                           |
| `attempt`        | integer         | Current attempt (starts at 1)                                    |
| `max_retries`    | integer         | Total retries permitted                                          |
| `retry_delay_ms` | integer         | Milliseconds until next attempt                                  |
| `error_status`   | integer or null | HTTP status code, or null for connection errors                  |
| `error`          | string          | Error category (e.g. `rate_limit`, `server_error`, `unknown`)   |
| `uuid`           | string          | Unique event identifier                                          |
| `session_id`     | string          | Session the event belongs to                                     |

**`system/init` event plugin fields:**

| Field           | Type  | Description                                                                 |
| :-------------- | :---- | :-------------------------------------------------------------------------- |
| `plugins`       | array | Loaded plugins, each with `name` and `path`                                 |
| `plugin_errors` | array | Load-time errors with `plugin`, `type`, `message`; absent when no errors    |

**`system/plugin_install` event fields** (when `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set):

| Field        | Type                                                     | Description                                     |
| :----------- | :------------------------------------------------------- | :---------------------------------------------- |
| `subtype`    | `"plugin_install"`                                       | Install event identifier                        |
| `status`     | `"started"`, `"installed"`, `"failed"`, `"completed"`   | Install stage                                   |
| `name`       | string, optional                                         | Marketplace name (on `installed` and `failed`)  |
| `error`      | string, optional                                         | Failure message (on `failed`)                   |

### Auto-Approve Tools

```bash
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"
claude -p "Apply lint fixes" --permission-mode acceptEdits
```

Permission modes for `-p`: `dontAsk` (deny unallowed tools) or `acceptEdits` (auto-approve file writes and common filesystem commands).

### Continue Conversations

```bash
claude -p "Review codebase for performance issues"
claude -p "Now focus on database queries" --continue
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue review" --resume "$session_id"
```

### Pipe and Script Integration

```bash
cat build-error.txt | claude -p 'explain the root cause' > output.txt
```

stdin is capped at 10 MB (as of v2.1.128); use file paths for larger inputs.

---

## Claude Code on the Web

### Key Concepts

| Concept | Details |
| :--- | :--- |
| **URL** | [claude.ai/code](https://claude.ai/code) |
| **Infrastructure** | Anthropic-managed VMs; sessions persist after closing browser |
| **GitHub access** | Required for most workflows; or bundle local repo via `--remote` |
| **Teleport** | Pull cloud sessions into local terminal with `--teleport` |

### GitHub Authentication Options

| Method           | How                                                                 | Best for                          |
| :--------------- | :------------------------------------------------------------------ | :-------------------------------- |
| **GitHub App**   | Install Claude GitHub App during web onboarding                     | Browser setup; want Auto-fix PRs  |
| **`/web-setup`** | Run in CLI to sync local `gh` token to Claude account               | Devs already using `gh` CLI       |

Either method gives cloud sessions access to any repo the connected GitHub account can see. GitHub App is required for Auto-fix (PR webhooks). Disable `/web-setup` for teams via admin toggle at `claude.ai/admin-settings/claude-code`. Not available with Zero Data Retention.

### Cloud Environment: What's Available

| Item | Available | Why |
| :--- | :--- | :--- |
| Repo's `CLAUDE.md`, `.claude/settings.json` hooks, `.mcp.json` | Yes | Part of the clone |
| `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Yes | Part of the clone |
| Plugins declared in `.claude/settings.json` | Yes | Installed at session start |
| User `~/.claude/CLAUDE.md` | No | Lives on local machine |
| Plugins only in user settings | No | User-scoped; use repo settings instead |
| Static API tokens / credentials | No | No secrets store yet |
| Interactive auth (AWS SSO, etc.) | No | Requires browser login |

### Pre-installed Tools in Cloud Sessions

| Category    | Included                                                                             |
| :---------- | :----------------------------------------------------------------------------------- |
| Python      | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff                              |
| Node.js     | 20/21/22 via nvm, npm, yarn, pnpm, bun*, eslint, prettier, chromedriver              |
| Ruby        | 3.1, 3.2, 3.3 with gem, bundler, rbenv                                               |
| PHP         | 8.4 with Composer                                                                    |
| Java        | OpenJDK 21 with Maven and Gradle                                                     |
| Go          | Latest stable with module support                                                    |
| Rust        | rustc and cargo                                                                      |
| C/C++       | GCC, Clang, cmake, ninja, conan                                                      |
| Docker      | docker, dockerd, docker compose                                                      |
| Databases   | PostgreSQL 16, Redis 7.0 (not running by default)                                   |
| Utilities   | git, jq, yq, ripgrep, tmux, vim, nano                                               |

*Bun has known proxy compatibility issues for package fetching.

Resource limits: ~4 vCPUs, 16 GB RAM, 30 GB disk. Run `check-tools` inside a cloud session for exact versions.

### Setup Scripts vs. SessionStart Hooks

|               | Setup scripts                             | SessionStart hooks                               |
| :------------ | :---------------------------------------- | :----------------------------------------------- |
| Attached to   | Cloud environment                         | Repository                                       |
| Configured in | Cloud environment UI                      | `.claude/settings.json` in repo                  |
| Runs          | Before Claude Code launches (cached)      | After Claude Code launches, every session        |
| Scope         | Cloud only                                | Local and cloud                                  |

**Setup script tips:**
- Scripts run as root on Ubuntu 24.04
- Keep total runtime under ~5 minutes for environment caching
- Non-zero exit blocks session start; append `|| true` for non-critical commands
- Run independent installs in parallel: `cmd1 & cmd2 & wait`
- Environment cache lasts ~7 days, rebuilt on script or network changes

**Cloud-only SessionStart hook pattern:**
```bash
#!/bin/bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi
npm install
pip install -r requirements.txt
```

### Network Access Levels

| Level    | Outbound connections                              |
| :------- | :------------------------------------------------ |
| None     | No outbound access                                |
| Trusted  | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| Full     | Any domain                                        |
| Custom   | Your allowlist, optionally including Trusted defaults |

Use `*.` for wildcard subdomain matching in custom allowlists. GitHub operations always go through a separate dedicated proxy independent of this setting.

### Session Environment Variable

```bash
echo "https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}"
```

Use `CLAUDE_CODE_REMOTE_SESSION_ID` to link PR bodies or commit messages back to the session that created them.

### Web ↔ Terminal Session Handoff

**Terminal to web:**
```bash
claude --remote "Fix the auth bug in src/auth/login.ts"
```
Clones current directory's GitHub remote at current branch (push first if you have local commits). Creates a new cloud session.

**Run tasks in parallel:**
```bash
claude --remote "Fix the flaky test in auth.spec.ts"
claude --remote "Update the API documentation"
```

**Bundled local repo** (no GitHub): set `CCR_FORCE_BUNDLE=1` or runs automatically when GitHub isn't connected. Limits: git repo with at least one commit, under 100 MB, untracked files not included.

**Web to terminal (teleport):**
```bash
claude --teleport              # interactive session picker
claude --teleport <session-id> # direct resume
```
Or from inside a session: `/teleport` (alias `/tp`). Also available from `/tasks` (press `t`) or web interface "Open in CLI".

**Teleport requirements:**
| Requirement     | Details                                              |
| :-------------- | :--------------------------------------------------- |
| Clean git state | No uncommitted changes (prompts to stash if needed)  |
| Correct repo    | Must be run from the same repo (not a fork)          |
| Branch pushed   | Cloud branch must exist on remote                    |
| Same account    | Must be authenticated to the same claude.ai account  |

Teleport requires claude.ai subscription auth. Run `/login` if using API key auth.

### Auto-fix Pull Requests

Requires Claude GitHub App installed on the repository.

Enable via: **CI status bar → Auto-fix** (web), `/autofix-pr` (terminal), mobile app, or paste PR URL and ask Claude to auto-fix.

Claude responds to CI failures and review comments:
- **Clear fixes**: makes change, pushes, explains in session
- **Ambiguous**: asks before acting
- **Duplicate/no-action**: notes and moves on

Claude replies to review threads under your username, labeled as coming from Claude Code. Warning: can trigger comment-activated automations (Atlantis, Terraform Cloud, etc.).

### Session URL Pre-fill Parameters

| Parameter      | Description                                               |
| :------------- | :-------------------------------------------------------- |
| `prompt` / `q` | Prefill prompt text                                       |
| `prompt_url`   | URL to fetch prompt from (ignored if `prompt` is set)    |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs             |
| `environment`  | Environment name or ID to preselect                       |

Example: `https://claude.ai/code?prompt=Fix%20login%20bug&repositories=acme/webapp`

### Context Management in Cloud Sessions

| Command    | Works | Notes                                              |
| :--------- | :---- | :------------------------------------------------- |
| `/compact` | Yes   | Accepts optional focus: `/compact keep test output` |
| `/context` | Yes   | Shows current context window contents              |
| `/clear`   | No    | Start a new session from the sidebar instead       |

Auto-compaction triggers at ~95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70`. Adjust effective window with `CLAUDE_CODE_AUTO_COMPACT_WINDOW`.

Enable agent teams in cloud: add `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to environment variables.

### Sharing Sessions

| Account type        | Visibility options            | Notes                                          |
| :------------------ | :---------------------------- | :--------------------------------------------- |
| Enterprise / Team   | Private, Team                 | Repo access verification enabled by default    |
| Max / Pro           | Private, Public               | Repo access verification off by default        |

Configure sharing settings (name visibility, repo access requirement) at Settings → Claude Code → Sharing settings.

### Limitations

- Rate limits shared with all Claude usage in your account
- Repository handoff (web → local) requires same account authentication
- GitHub required for push; GitLab/Bitbucket can only receive bundles, not push back
- GitHub Enterprise Server supported on Team and Enterprise plans
- Organization IP allowlisting breaks cloud sessions (call the Anthropic API from Anthropic infrastructure, not your network)

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — headless mode, `-p` flag, bare mode, output formats, streaming, tool approval, conversation continuity
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environments, setup scripts, network access, GitHub auth, session management, auto-fix PRs, teleport
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart walkthrough: connect GitHub, create environment, submit task, review diff, create PR

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
