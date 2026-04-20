---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (CLI -p flag, Agent SDK), Claude Code on the web (cloud sessions, environments, setup scripts, network access, teleport), and the web quickstart.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI and using Claude Code on the web.

## Quick Reference

### Running Claude Code programmatically (`claude -p`)

Pass `-p` (or `--print`) to run Claude non-interactively. All CLI options work with `-p`.

```bash
claude -p "What does the auth module do?"
```

#### Key flags

| Flag                          | Purpose                                                      |
| :---------------------------- | :----------------------------------------------------------- |
| `--bare`                      | Skip hooks, skills, plugins, MCP, auto memory, CLAUDE.md for faster, reproducible runs |
| `--output-format text\|json\|stream-json` | Control response format (default: `text`)       |
| `--json-schema '<schema>'`    | Get structured output conforming to a JSON Schema (use with `--output-format json`) |
| `--allowedTools "Tool1,Tool2"` | Auto-approve specific tools without prompting               |
| `--permission-mode <mode>`    | Set baseline permissions (`dontAsk`, `acceptEdits`, etc.)    |
| `--continue`                  | Continue the most recent conversation                        |
| `--resume <session-id>`       | Continue a specific conversation                             |
| `--append-system-prompt`      | Add instructions while keeping default behavior              |
| `--system-prompt`             | Fully replace the default system prompt                      |

#### Bare mode context loading

In bare mode, Claude has Bash, Read, and Edit tools. Pass context explicitly:

| To load                 | Use                                                     |
| :---------------------- | :------------------------------------------------------ |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file`  |
| Settings                | `--settings <file-or-json>`                              |
| MCP servers             | `--mcp-config <file-or-json>`                            |
| Custom agents           | `--agents <json>`                                        |
| A plugin directory      | `--plugin-dir <path>`                                    |

Bare mode skips OAuth and keychain reads. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`.

#### Output formats

| Format          | Description                                          | Key fields                     |
| :-------------- | :--------------------------------------------------- | :----------------------------- |
| `text`          | Plain text (default)                                 | —                              |
| `json`          | Structured JSON with metadata                        | `result`, `session_id`, `structured_output` |
| `stream-json`   | Newline-delimited JSON for real-time streaming       | Use with `--verbose --include-partial-messages` |

#### Stream event: `system/api_retry`

| Field            | Type            | Description                          |
| :--------------- | :-------------- | :----------------------------------- |
| `attempt`        | integer         | Current attempt number (starts at 1) |
| `max_retries`    | integer         | Total retries permitted              |
| `retry_delay_ms` | integer         | Milliseconds until next attempt      |
| `error_status`   | integer or null | HTTP status code                     |
| `error`          | string          | Error category                       |

#### Stream event: `system/init`

Reports session metadata (model, tools, MCP servers, plugins). First event in stream unless `CLAUDE_CODE_SYNC_PLUGIN_INSTALL` is set.

| Field           | Type  | Description                                   |
| :-------------- | :---- | :-------------------------------------------- |
| `plugins`       | array | Successfully loaded plugins (`name`, `path`)  |
| `plugin_errors` | array | Plugin load-time errors (`plugin`, `type`, `message`) |

#### Common patterns

**Create a commit** (prefix-match with trailing ` *`):
```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

**Security review with custom prompt**:
```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

**Multi-turn conversation**:
```bash
claude -p "Review this codebase for performance issues"
claude -p "Now focus on the database queries" --continue
```

---

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist across devices and continue if you close your browser.

#### GitHub authentication

| Method           | How                                                      | Best for                     |
| :--------------- | :------------------------------------------------------- | :--------------------------- |
| **GitHub App**   | Install during onboarding; scoped per repository         | Teams, explicit per-repo auth |
| **`/web-setup`** | Sync local `gh` CLI token to Claude account              | Devs who already use `gh`    |

The GitHub App is required for Auto-fix. Zero Data Retention orgs cannot use `/web-setup`.

#### What's available in cloud sessions

| Available                                     | Not available                        |
| :-------------------------------------------- | :----------------------------------- |
| Repo CLAUDE.md, .claude/settings.json hooks   | User `~/.claude/CLAUDE.md`           |
| Repo .mcp.json, .claude/rules/               | MCP servers added with `claude mcp add` |
| Repo skills, agents, commands                 | User-scoped `enabledPlugins`         |
| Plugins declared in .claude/settings.json     | Static API tokens / credentials      |
| Built-in GitHub tools (issues, PRs, diffs)    | Interactive auth (AWS SSO, etc.)     |

#### Installed tools (pre-installed in cloud VMs)

| Category      | Included                                                       |
| :------------ | :------------------------------------------------------------- |
| **Python**    | Python 3.x, pip, poetry, uv, black, mypy, pytest, ruff        |
| **Node.js**   | 20/21/22 via nvm, npm, yarn, pnpm, bun, eslint, prettier      |
| **Ruby**      | 3.1/3.2/3.3, gem, bundler, rbenv                               |
| **PHP**       | 8.4, Composer                                                  |
| **Java**      | OpenJDK 21, Maven, Gradle                                      |
| **Go**        | latest stable                                                  |
| **Rust**      | rustc, cargo                                                   |
| **C/C++**     | GCC, Clang, cmake, ninja, conan                                |
| **Docker**    | docker, dockerd, docker compose                                |
| **Databases** | PostgreSQL 16, Redis 7.0 (not running by default)              |
| **Utilities** | git, jq, yq, ripgrep, tmux, vim, nano                         |

Resource limits: 4 vCPUs, 16 GB RAM, 30 GB disk.

#### Network access levels

| Level       | Outbound connections                                           |
| :---------- | :------------------------------------------------------------- |
| **None**    | No outbound network access                                     |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full**    | Any domain                                                     |
| **Custom**  | Your own allowlist, optionally including the defaults           |

GitHub operations use a separate proxy independent of this setting. All outbound traffic passes through a security proxy.

#### Setup scripts vs SessionStart hooks

|               | Setup scripts                         | SessionStart hooks                          |
| :------------ | :------------------------------------ | :------------------------------------------ |
| Attached to   | Cloud environment                     | Repository (`.claude/settings.json`)        |
| Runs          | Before Claude launches; cached        | After Claude launches; every session        |
| Scope         | Cloud only                            | Both local and cloud                        |

Setup scripts are cached after first run (~7 day expiry). SessionStart hooks run every session. Check `CLAUDE_CODE_REMOTE=true` to run hooks only in the cloud.

#### Environment configuration

Manage from the web UI or terminal (`/remote-env`). Environment variables use `.env` format without quotes around values.

#### Move sessions between web and terminal

| Direction      | Method                                                   |
| :------------- | :------------------------------------------------------- |
| Terminal to web | `claude --remote "task description"` (clones from GitHub) |
| Web to terminal | `claude --teleport` or `/teleport` (or `/tp`)            |

`--remote` creates a new cloud session; push local commits first since the VM clones from GitHub. Use `CCR_FORCE_BUNDLE=1` to force bundling a non-GitHub repo (must be under 100 MB).

Teleport requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account.

#### Pre-fill session URLs

| Parameter      | Description                                    |
| :------------- | :--------------------------------------------- |
| `prompt` / `q` | Prompt text to prefill                        |
| `prompt_url`   | URL to fetch prompt text from                  |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs   |
| `environment`  | Name or ID of environment to preselect         |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

#### Auto-fix pull requests

Claude watches a PR and automatically responds to CI failures and review comments. Requires the Claude GitHub App.

Enable via:
- Web: open CI status bar, select **Auto-fix**
- Terminal: `/autofix-pr` while on the PR branch
- Mobile: tell Claude to auto-fix the PR
- Any session: paste PR URL and ask Claude to auto-fix

Claude replies to review threads using your GitHub account, labeled as from Claude Code. Be cautious with comment-triggered automation (Atlantis, Terraform Cloud, etc.).

#### Session management

| Action          | How                                                        |
| :-------------- | :--------------------------------------------------------- |
| Share (Team/Enterprise) | Toggle visibility to **Team** (org-scoped)         |
| Share (Max/Pro) | Toggle visibility to **Public** (any claude.ai user)       |
| Archive         | Hover in sidebar, select archive icon                      |
| Delete          | Filter archived sessions, select delete; or session menu > Delete |

#### Cloud session environment variables

| Variable                          | Purpose                                      |
| :-------------------------------- | :------------------------------------------- |
| `CLAUDE_CODE_REMOTE`              | Set to `true` in cloud sessions              |
| `CLAUDE_CODE_REMOTE_SESSION_ID`   | Session ID; use to build transcript link     |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Compact at custom % (default ~95%)           |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Change effective window size for compaction   |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams in cloud sessions    |

#### Limitations

- Cloud sessions share rate limits with all Claude usage on the account
- Repository auth requires same account for web-to-local handoff
- GitHub required for cloning/PR creation (non-GitHub repos can be bundled but can't push back)
- GitHub Enterprise Server supported for Team and Enterprise plans

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — CLI `-p` flag, bare mode, structured output, streaming, auto-approve tools, commit patterns, system prompt customization, and continuing conversations via the Agent SDK CLI.
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — cloud environments, GitHub auth options, installed tools, setup scripts, environment caching, network access levels and domain allowlists, terminal-to-web and web-to-terminal handoff (`--remote`, `--teleport`), session management, auto-fix PRs, security isolation, and troubleshooting.
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — connect GitHub, create an environment, start a task, pre-fill session URLs, review and iterate workflow, and troubleshooting setup.

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
