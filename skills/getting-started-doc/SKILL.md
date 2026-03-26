---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview, installation, quickstart, authentication, how it works, and platform options. Covers installation methods (native install via curl/irm recommended with auto-update, Homebrew via brew install --cask claude-code, WinGet via winget install Anthropic.ClaudeCode, deprecated npm), system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4GB+ RAM, internet required, Bash/Zsh/PowerShell/CMD shells), Windows setup (Git for Windows required, PowerShell or CMD launch, Git Bash internally, WSL 1 and 2 supported, CLAUDE_CODE_GIT_BASH_PATH setting), Alpine/musl (libgcc libstdc++ ripgrep packages, USE_BUILTIN_RIPGREP=0), verification (claude --version, claude doctor), authentication (Pro/Max/Teams/Enterprise/Console accounts, cloud providers Bedrock/Vertex/Foundry, OAuth browser login, /logout, credential storage in macOS Keychain or ~/.claude/.credentials.json, apiKeyHelper for dynamic credentials, auth precedence: cloud provider > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth), team setup (Teams self-serve, Enterprise with SSO/domain capture/managed policy, Console with Claude Code or Developer roles, cloud provider config distribution), updates (auto-update background, autoUpdatesChannel latest or stable, DISABLE_AUTOUPDATER=1, claude update manual, brew upgrade/winget upgrade for package managers), release channels (latest default, stable ~1 week delayed), uninstallation (native rm ~/.local/bin/claude and ~/.local/share/claude, Homebrew brew uninstall --cask, WinGet winget uninstall, npm uninstall -g, config cleanup rm -rf ~/.claude), quickstart workflow (install, login, cd project, claude, ask questions, make edits, git operations), essential CLI commands (claude, claude "task", claude -p, claude -c, claude -r, claude commit, /clear, /help), agentic loop (gather context, take action, verify results, interrupt to steer), built-in tools (file operations read/edit/create, search by pattern/regex, execution shell/tests/git, web search/fetch, code intelligence), models (Sonnet for most tasks, Opus for complex reasoning, /model to switch, --model flag), what Claude accesses (project files, terminal commands, git state, CLAUDE.md, auto memory, MCP/skills/subagents), sessions (independent fresh context, local storage, checkpoints for undo, --continue to resume, --fork-session to branch, context window management, /compact, /context), permission modes (Default ask before edits/commands, Auto-accept edits, Plan mode read-only, Auto mode with safety checks, Shift+Tab to cycle), platforms (CLI full-featured terminal, Desktop visual review/parallel sessions/computer use/Dispatch, VS Code inline diffs/terminal, JetBrains diff viewer/selection sharing, Web cloud long-running tasks), integrations (Chrome browser control, GitHub Actions CI, GitLab CI/CD, Code Review auto PR review, Slack @Claude mentions), remote access (Dispatch from mobile, Remote Control from browser, Channels push events, Scheduled tasks recurring), working effectively tips (be specific, give verification criteria, explore before implementing, delegate dont dictate, use plan mode). Load when discussing getting started with Claude Code, installing Claude Code, Claude Code overview, Claude Code quickstart, Claude Code setup, Claude Code authentication, how Claude Code works, agentic loop, Claude Code platforms, Claude Code integrations, system requirements, login, credential management, apiKeyHelper, session management, context window, permission modes, or any introductory Claude Code topic.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- installation, authentication, quickstart walkthrough, how it works, and platform options.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates | Notes |
|:-------|:--------|:-------------|:------|
| **Native** (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes | macOS, Linux, WSL |
| **Native Windows PS** | `irm https://claude.ai/install.ps1 \| iex` | Yes | Requires Git for Windows |
| **Native Windows CMD** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes | Requires Git for Windows |
| **Homebrew** | `brew install --cask claude-code` | No | `brew upgrade claude-code` to update |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No | `winget upgrade Anthropic.ClaudeCode` to update |
| **npm** (deprecated) | `npm install -g @anthropic-ai/claude-code` | No | Requires Node.js 18+; migrate to native |

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ (Git for Windows required) |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Location** | Anthropic supported countries |

### Authentication

| Account type | How to log in |
|:-------------|:--------------|
| **Pro / Max** | Run `claude`, follow browser prompt to log in with Claude.ai account |
| **Teams / Enterprise** | Log in with team-invited Claude.ai account |
| **Console** | Log in with Console credentials (admin must invite first with Claude Code or Developer role) |
| **Bedrock / Vertex / Foundry** | Set env vars before running `claude` (no browser login needed) |

**Auth precedence** (highest to lowest):
1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` / `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (bearer token for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` env var (direct Anthropic API key)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. Subscription OAuth from `/login` (default for Pro/Max/Teams/Enterprise)

**Credential storage**: macOS Keychain (encrypted), Linux/Windows `~/.claude/.credentials.json` (mode 0600 on Linux). Override location with `$CLAUDE_CONFIG_DIR`.

### Essential CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Verify installation |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Manual update |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/model` | Switch model mid-session |
| `/compact` | Compact context window |
| `/context` | See context usage |
| `/init` | Create a CLAUDE.md for the project |

### The Agentic Loop

Claude Code works through three blended phases: **gather context** (search files, read code), **take action** (edit files, run commands), and **verify results** (run tests, check output). The loop adapts to the task -- a question may only need context gathering, while a bug fix cycles through all phases repeatedly. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read files, edit code, create new files, rename and reorganize |
| **Search** | Find files by pattern, search content with regex, explore codebases |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up error messages |
| **Code intelligence** | Type errors/warnings after edits, jump to definitions, find references (requires plugins) |

### Models

| Model | Best for | Switch with |
|:------|:---------|:------------|
| **Sonnet** | Most coding tasks | `/model` or `claude --model sonnet` |
| **Opus** | Complex architectural reasoning | `/model` or `claude --model opus` |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|:-----|:---------|
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files without asking, still asks for commands |
| **Plan mode** | Read-only tools only; creates a plan you approve before execution |
| **Auto mode** | Evaluates all actions with background safety checks (research preview) |

### Session Management

| Feature | Details |
|:--------|:--------|
| **Resume** | `claude --continue` or `claude -c` picks up where you left off |
| **Fork** | `claude --continue --fork-session` branches without affecting original |
| **Checkpoints** | Every file edit is snapshotted; press `Esc` twice to rewind |
| **Context window** | Holds conversation, file contents, command outputs, CLAUDE.md, auto memory; auto-compacts when full |
| **Sessions are independent** | Each new session starts fresh; use CLAUDE.md and auto memory for persistence |

### Update Configuration

| Setting | Values | Purpose |
|:--------|:-------|:--------|
| `autoUpdatesChannel` | `"latest"` (default), `"stable"` | Control release cadence; stable is ~1 week behind |
| `DISABLE_AUTOUPDATER` | `"1"` in `env` settings | Disable background auto-updates entirely |

### Platforms

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| **CLI** | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| **Desktop** | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| **VS Code** | Working inside VS Code | Inline diffs, integrated terminal, file context |
| **JetBrains** | IntelliJ, PyCharm, WebStorm, etc. | Diff viewer, selection sharing, terminal session |
| **Web** | Long-running tasks, offline continuation | Anthropic cloud, continues after disconnect |

### Integrations

| Integration | What it does |
|:------------|:-------------|
| **Chrome** | Controls browser with your logged-in sessions for testing web apps |
| **GitHub Actions** | Runs Claude in CI for automated PR reviews, issue triage |
| **GitLab CI/CD** | Same as GitHub Actions for GitLab |
| **Code Review** | Automatic review on every pull request |
| **Slack** | Responds to `@Claude` mentions, turns bug reports into PRs |

### Remote Access Options

| Method | Trigger | Runs on |
|:-------|:--------|:--------|
| **Dispatch** | Message from Claude mobile app | Your machine (Desktop) |
| **Remote Control** | Drive from browser or mobile | Your machine (CLI/VS Code) |
| **Channels** | Push events from Telegram, Discord, webhooks | Your machine (CLI) |
| **Scheduled tasks** | Set a schedule | CLI, Desktop, or cloud |

### Windows Setup

- Requires [Git for Windows](https://git-scm.com/downloads/win) or WSL
- Launch `claude` from PowerShell, CMD, or Git Bash
- If Git Bash path not found, set `CLAUDE_CODE_GIT_BASH_PATH` in settings.json
- WSL 2 supports sandboxing; WSL 1 does not
- PowerShell native tool available as opt-in preview

### Alpine / musl Setup

Install dependencies before running Claude Code:
```
apk add libgcc libstdc++ ripgrep
```
Set `USE_BUILTIN_RIPGREP` to `"0"` in settings.json `env`.

### Uninstallation

| Method | Command |
|:-------|:--------|
| **Native (macOS/Linux)** | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| **Native (Windows PS)** | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force; Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| **Homebrew** | `brew uninstall --cask claude-code` |
| **WinGet** | `winget uninstall Anthropic.ClaudeCode` |
| **npm** | `npm uninstall -g @anthropic-ai/claude-code` |
| **Config cleanup** | `rm -rf ~/.claude && rm ~/.claude.json` (deletes all settings/history) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- Product overview, installation options across all surfaces (Terminal, VS Code, Desktop, Web, JetBrains), what you can do (automate tasks, build features, fix bugs, create commits/PRs, connect tools via MCP, customize with CLAUDE.md/skills/hooks, run agent teams, pipe/script/automate with CLI, schedule recurring tasks, work from anywhere), platform comparison table, and next steps
- [Quickstart](references/claude-code-quickstart.md) -- Step-by-step first session walkthrough: install, log in, start session, ask questions, make code changes, use Git, fix bugs, add features, refactor, write tests, update docs, code review; essential commands table and pro tips for beginners
- [Advanced setup](references/claude-code-setup.md) -- System requirements, platform-specific installation details (Windows with Git Bash/WSL, Alpine/musl dependencies), verification (claude --version, claude doctor), authentication account types, update management (auto-updates, release channels latest/stable, DISABLE_AUTOUPDATER, manual claude update), advanced options (specific version install, npm migration, binary integrity/code signing), uninstallation for all methods, config file cleanup
- [Authentication](references/claude-code-authentication.md) -- Login flow (browser prompt, account types), team setup (Teams/Enterprise with SSO and managed policy, Console with role assignment, cloud provider config distribution), credential management (macOS Keychain, Linux/Windows file storage, apiKeyHelper for dynamic credentials, CLAUDE_CODE_API_KEY_HELPER_TTL_MS refresh interval, slow helper notice), authentication precedence (cloud provider > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth)
- [How Claude Code works](references/claude-code-how-it-works.md) -- Agentic loop architecture (gather context, take action, verify results), models (Sonnet for most tasks, Opus for complex reasoning, /model to switch), built-in tools (file ops, search, execution, web, code intelligence), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local, cloud, Remote Control), sessions (independent, resume/fork, checkpoints, context window management, /compact, /context), permission modes (Default, Auto-accept edits, Plan mode, Auto mode, Shift+Tab), working effectively tips (be specific, give verification criteria, explore before implementing, delegate)
- [Platforms and integrations](references/claude-code-platforms.md) -- Platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integration table (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack), remote access options (Dispatch, Remote Control, Channels, Scheduled tasks), MCP and connectors for unlisted integrations

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
