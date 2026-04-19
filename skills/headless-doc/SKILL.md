---
name: headless-doc
description: Complete official documentation for running Claude Code programmatically (CLI headless mode with -p) and Claude Code on the web — cloud sessions, setup scripts, network access, environments, teleport, auto-fix PRs, and the web quickstart.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`claude -p`) and using Claude Code on the web (cloud sessions at claude.ai/code).

## Quick Reference

### CLI headless mode (`claude -p`)

Pass `-p` (or `--print`) to run Claude Code non-interactively. All CLI options work with `-p`. The Agent SDK provides the same capabilities via Python and TypeScript packages.

| Flag / option                | Purpose                                                  |
| :--------------------------- | :------------------------------------------------------- |
| `-p "prompt"`                | Run non-interactively, print result, exit                |
| `--bare`                     | Skip hooks, skills, plugins, MCP, CLAUDE.md for faster startup |
| `--output-format text`      | Plain text (default)                                     |
| `--output-format json`      | JSON with `result`, `session_id`, metadata               |
| `--output-format stream-json` | Newline-delimited JSON for real-time streaming         |
| `--json-schema '{...}'`     | Structured output conforming to a JSON Schema (use with `--output-format json`; result in `structured_output`) |
| `--allowedTools "Bash,Read,Edit"` | Auto-approve listed tools without prompting        |
| `--permission-mode <mode>`  | Set baseline permission mode (`dontAsk`, `acceptEdits`)  |
| `--continue`                | Continue the most recent conversation                    |
| `--resume <session-id>`     | Continue a specific conversation by session ID           |
| `--append-system-prompt "..."` | Add instructions while keeping default system prompt  |
| `--system-prompt "..."`     | Fully replace the default system prompt                  |
| `--settings <file-or-json>` | Load settings from file or inline JSON (bare mode)       |
| `--mcp-config <file-or-json>` | Load MCP servers (bare mode)                           |
| `--agents <json>`           | Load custom agents (bare mode)                           |
| `--plugin-dir <path>`       | Load a plugin directory (bare mode)                      |

`--bare` is the recommended mode for scripted and SDK calls. It skips OAuth and keychain reads; authenticate via `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings`.

#### Common patterns

```bash
# Create a commit with scoped tool access
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"

# Pipe input and get JSON output
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json

# Continue a conversation
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

#### Streaming events

Use `--output-format stream-json --verbose --include-partial-messages` for real-time token streaming. Key event types:

| Event subtype       | Description                                              |
| :------------------ | :------------------------------------------------------- |
| `api_retry`         | Retryable API error; fields: `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, `error` |
| `init`              | Session metadata: model, tools, MCP servers, `plugins`, `plugin_errors` |
| `plugin_install`    | Marketplace plugin install progress (`started`, `installed`, `failed`, `completed`) |

### Claude Code on the web

Cloud sessions run on Anthropic-managed VMs at [claude.ai/code](https://claude.ai/code). Sessions persist across devices (browser, mobile, CLI).

#### GitHub authentication

| Method          | How                                                       | Best for                               |
| :-------------- | :-------------------------------------------------------- | :------------------------------------- |
| **GitHub App**  | Install during web onboarding; scoped per repository      | Teams wanting explicit per-repo access |
| **`/web-setup`** | Syncs local `gh` CLI token to Claude account             | Individual devs who already use `gh`   |

The GitHub App is required for Auto-fix. ZDR organizations cannot use `/web-setup`.

#### Cloud environment resources

| Resource | Limit     |
| :------- | :-------- |
| vCPUs    | 4         |
| RAM      | 16 GB     |
| Disk     | 30 GB     |

#### Pre-installed tools

| Category      | Included                                                                            |
| :------------ | :---------------------------------------------------------------------------------- |
| **Python**    | 3.x, pip, poetry, uv, black, mypy, pytest, ruff                                    |
| **Node.js**   | 20/21/22 via nvm, npm, yarn, pnpm, bun, eslint, prettier, chromedriver             |
| **Ruby**      | 3.1/3.2/3.3, gem, bundler, rbenv                                                   |
| **PHP**       | 8.4, Composer                                                                       |
| **Java**      | OpenJDK 21, Maven, Gradle                                                           |
| **Go**        | latest stable                                                                       |
| **Rust**      | rustc, cargo                                                                        |
| **C/C++**     | GCC, Clang, cmake, ninja, conan                                                     |
| **Docker**    | docker, dockerd, docker compose                                                     |
| **Databases** | PostgreSQL 16, Redis 7.0 (not running by default)                                   |
| **Utilities** | git, jq, yq, ripgrep, tmux, vim, nano                                               |

#### What carries over to cloud sessions

Committed repo files (CLAUDE.md, `.claude/settings.json`, `.mcp.json`, `.claude/rules/`, skills, agents, commands) and plugins declared in `.claude/settings.json` are available. User-scoped config (`~/.claude/`), MCP servers added via `claude mcp add`, static credentials, and interactive auth (AWS SSO) are **not** available.

#### Network access levels

| Level       | Outbound connections                                           |
| :---------- | :------------------------------------------------------------- |
| **None**    | No outbound access                                             |
| **Trusted** | Allowlisted domains only (package registries, GitHub, cloud SDKs) |
| **Full**    | Any domain                                                     |
| **Custom**  | Your own allowlist, optionally including the defaults          |

GitHub operations always go through a separate dedicated proxy regardless of network level.

#### Setup scripts vs SessionStart hooks

|                | Setup scripts                              | SessionStart hooks                          |
| :------------- | :----------------------------------------- | :------------------------------------------ |
| **Attached to** | Cloud environment                         | Repository (`.claude/settings.json`)        |
| **Runs**       | Before Claude Code launches; cached        | After launch; every session including resumed |
| **Scope**      | Cloud environments only                    | Both local and cloud                        |

Setup script output is cached (snapshot reused for ~7 days). Services/containers started by the script do not persist -- start them per session. Use `CLAUDE_CODE_REMOTE` env var to detect cloud sessions in hooks.

#### Environment configuration

Manage environments from the web UI or terminal (`/remote-env`). Environment variables use `.env` format (no quotes around values). Fields: name, network access level, environment variables, setup script.

#### Moving sessions between web and terminal

| Direction       | Method                                                        |
| :-------------- | :------------------------------------------------------------ |
| Terminal to web | `claude --remote "prompt"` -- creates a new cloud session     |
| Web to terminal | `claude --teleport` or `/teleport` (`/tp`) or `/tasks` then `t` |

`--remote` clones from GitHub (push local commits first). For repos without GitHub, it bundles and uploads the local repo (under 100 MB; untracked files excluded).

Teleport requirements: clean git state, correct repository (not a fork), branch pushed to remote, same claude.ai account. Requires claude.ai subscription auth (not API key/Bedrock/Vertex).

#### Auto-fix pull requests

Turn on auto-fix to have Claude watch a PR for CI failures and review comments:

- **Web**: open CI status bar, select Auto-fix
- **Terminal**: `/autofix-pr` on the PR's branch
- **Mobile/any session**: paste PR URL and tell Claude to auto-fix

Requires the Claude GitHub App. Claude pushes fixes for clear issues, asks about ambiguous ones, and skips duplicates. Replies to PR comment threads are posted under your GitHub username (labeled as from Claude Code).

#### Session management

| Action   | How                                                                       |
| :------- | :------------------------------------------------------------------------ |
| Share    | Toggle visibility: Private/Team (Enterprise/Team) or Private/Public (Max/Pro) |
| Archive  | Hover session in sidebar, select archive icon                              |
| Delete   | Filter archived, select delete; or session menu > Delete                  |

Context commands: `/compact` (works), `/context` (works), `/clear` (not available -- start a new session instead).

#### Pre-fill session URLs

| Parameter      | Description                                        |
| :------------- | :------------------------------------------------- |
| `prompt` / `q` | Prompt text to prefill                            |
| `prompt_url`   | URL to fetch prompt from (ignored if `prompt` set) |
| `repositories` / `repo` | Comma-separated `owner/repo` slugs       |
| `environment`  | Environment name or ID                             |

Example: `https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp`

#### Environment variable: `CLAUDE_CODE_REMOTE_SESSION_ID`

Available inside cloud sessions. Use to link artifacts (PR bodies, commit messages) back to the session transcript at `https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID}`.

### Web quickstart summary

1. Visit [claude.ai/code](https://claude.ai/code) and sign in
2. Install the Claude GitHub App (grant access to repositories)
3. Create an environment (name, network access, env vars, setup script)
4. Select a repo + branch, choose permission mode (Auto accept edits or Plan), describe the task
5. Review diff, leave inline comments, create PR when ready
6. Optionally turn on Auto-fix to monitor the PR

Alternative: run `/web-setup` from the Claude Code CLI to sync your `gh` token and create a default environment without opening a browser.

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) — CLI headless mode (`claude -p`), bare mode, structured output, streaming, auto-approve tools, continuing conversations, and system prompt customization.
- [Use Claude Code on the web](references/claude-code-on-the-web.md) — full reference for cloud sessions including GitHub authentication, environment configuration, setup scripts, caching, network access levels, allowed domains, teleport, session management, auto-fix PRs, security/isolation, and troubleshooting.
- [Get started with Claude Code on the web](references/claude-code-web-quickstart.md) — quickstart guide for connecting GitHub, creating an environment, submitting tasks, reviewing diffs, pre-filling session URLs, and troubleshooting setup.

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Use Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
- Get started with Claude Code on the web: https://code.claude.com/docs/en/web-quickstart.md
