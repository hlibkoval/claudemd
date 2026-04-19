---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, installation, quickstart, setup, authentication, how it works, and supported platforms and integrations.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

Claude Code is an agentic coding assistant that runs in your terminal, IDE, desktop app, and browser. It reads your codebase, edits files, runs commands, and integrates with your development tools.

### Installation

| Method | Command | Auto-updates |
| :----- | :------ | :----------- |
| **Native (macOS/Linux/WSL)** | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native (Windows PowerShell)** | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native (Windows CMD)** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew (stable)** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **Homebrew (latest)** | `brew install --cask claude-code@latest` | No (`brew upgrade claude-code@latest`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **npm** | `npm install -g @anthropic-ai/claude-code` | No |

Native Windows setups require [Git for Windows](https://git-scm.com/downloads/win). WSL setups do not.

### System requirements

- **OS**: macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **Hardware**: 4 GB+ RAM, x64 or ARM64
- **Network**: internet connection required
- **Shell**: Bash, Zsh, PowerShell, or CMD

### Platforms

| Platform | Best for | Key features |
| :------- | :------- | :----------- |
| **Terminal CLI** | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, headless mode, third-party providers |
| **Desktop app** | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| **VS Code** | In-editor workflows | Inline diffs, integrated terminal, file context |
| **JetBrains** | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| **Web** | Long-running tasks, cloud sessions | Runs on Anthropic cloud, continues after disconnect |
| **Mobile** | Monitoring and starting tasks on the go | Cloud sessions, Remote Control, Dispatch |

### Authentication methods

| Account type | How to authenticate |
| :----------- | :------------------ |
| **Claude Pro / Max** | Browser login via `claude` or `/login` |
| **Claude Teams / Enterprise** | Browser login with team account |
| **Claude Console** | Browser login with Console credentials |
| **Amazon Bedrock** | Set env vars, no browser login needed |
| **Google Vertex AI** | Set env vars, no browser login needed |
| **Microsoft Foundry** | Set env vars, no browser login needed |

Authentication precedence (highest to lowest): cloud provider env vars, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_API_KEY`, `apiKeyHelper` script, `CLAUDE_CODE_OAUTH_TOKEN`, subscription OAuth (`/login`).

Credentials are stored in macOS Keychain (macOS) or `~/.claude/.credentials.json` (Linux/Windows).

### Essential CLI commands

| Command | What it does |
| :------ | :----------- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run query, print result, exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Show installed version |
| `claude update` | Update manually |
| `claude doctor` | Diagnose installation issues |
| `/login` | Log in or switch accounts |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |

### The agentic loop

Claude Code works in three blended phases: **gather context** (search, read files), **take action** (edit, run commands), and **verify results** (run tests, check output). It chains dozens of tool uses together, course-correcting along the way. You can interrupt at any point to steer.

### Built-in tool categories

| Category | What Claude can do |
| :------- | :----------------- |
| **File operations** | Read files, edit code, create new files, rename and reorganize |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up error messages |
| **Code intelligence** | See type errors, jump to definitions, find references |

### What Claude can access

When you run `claude` in a directory, it has access to: your project files, your terminal (any command you could run), your git state, your CLAUDE.md, auto memory, and configured extensions (MCP servers, skills, subagents).

### Permission modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :------- |
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files freely, asks for other commands |
| **Plan mode** | Read-only tools, creates a plan for approval |
| **Auto mode** | Evaluates all actions with background safety checks (research preview) |

### Update management

| Setting | Effect |
| :------ | :----- |
| `autoUpdatesChannel: "latest"` (default) | Receive new features immediately |
| `autoUpdatesChannel: "stable"` | Use a version ~1 week old, skipping regressions |
| `minimumVersion: "2.1.100"` | Floor version; prevents downgrade |
| `DISABLE_AUTOUPDATER: "1"` (env) | Disable auto-updates entirely |

### Integrations

| Integration | What it does |
| :---------- | :----------- |
| **Chrome** | Controls your browser for testing web apps |
| **GitHub Actions** | Runs Claude in CI for PR reviews, issue triage |
| **GitLab CI/CD** | Same as GitHub Actions for GitLab |
| **Code Review** | Automatic review on every PR |
| **Slack** | Responds to @Claude mentions, turns bug reports into PRs |

### Working effectively with Claude Code

- **Be specific upfront** — reference files, mention constraints, point to patterns
- **Give verifiable goals** — include test cases, expected output, or screenshots
- **Explore before implementing** — use plan mode for complex problems
- **Delegate, don't dictate** — describe what you want, let Claude figure out how
- **Iterate conversationally** — refine through back-and-forth, interrupt when needed

### Uninstall

| Method | Command |
| :----- | :------ |
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config files | `rm -rf ~/.claude && rm ~/.claude.json` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — product overview, installation configurator, what you can do (features, git, MCP, hooks, skills, agent teams, CLI piping, scheduled tasks), platform comparison table, and next steps.
- [Quickstart](references/claude-code-quickstart.md) — step-by-step guide from installation through first question, first code change, git operations, bug fixing, refactoring, testing, and essential commands.
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific installation (Windows native vs WSL, Alpine/musl), verification, release channels, auto-updates, version pinning, npm install, binary integrity and code signing, and uninstallation.
- [Authentication](references/claude-code-authentication.md) — login flow, account types, team setup (Teams/Enterprise, Console, cloud providers), credential management (storage, precedence, apiKeyHelper, refresh), and generating long-lived OAuth tokens for CI.
- [How Claude Code works](references/claude-code-how-it-works.md) — the agentic loop (gather/act/verify), models and tool categories, what Claude can access, execution environments (local/cloud/Remote Control), sessions (resuming, forking, context window, compaction), checkpoints, permission modes, and tips for working effectively.
- [Platforms and integrations](references/claude-code-platforms.md) — platform comparison (CLI, Desktop, VS Code, JetBrains, web, mobile), integrations (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack), remote access options (Dispatch, Remote Control, Channels, scheduled tasks), and related resources.

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
