---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- installation (native installer, Homebrew, WinGet, npm), platform setup (macOS, Linux, Windows, WSL, Alpine), system requirements (OS versions, RAM, shells), authentication (Claude.ai login, Console credentials, Teams/Enterprise SSO, cloud provider env vars, credential management, apiKeyHelper), quickstart walkthrough (first session, exploring a codebase, making edits, git operations, bug fixes, refactoring, tests), essential CLI commands (claude, claude -p, claude -c, claude -r, claude commit), updating (auto-updates, release channels latest/stable, manual update, disable auto-updates), uninstallation (native, Homebrew, WinGet, npm, config cleanup), how Claude Code works (agentic loop, gather-act-verify phases, models, tools, file operations, search, execution, web, code intelligence), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local, cloud, remote control), sessions (resume, fork, context window, compaction, /context, /compact), checkpoints (undo file changes, Esc-Esc rewind), permission modes (default, auto-accept edits, plan mode, Shift+Tab), tips for effective use (be specific, give verification targets, explore before implementing, delegate don't dictate), available interfaces (Terminal, VS Code, JetBrains, Desktop app, Web, Slack, GitHub Actions, GitLab CI/CD). Load when discussing Claude Code installation, setup, getting started, first steps, quickstart, authentication, login, how Claude Code works, the agentic loop, sessions, context window, checkpoints, permission modes, plan mode, system requirements, updating Claude Code, uninstalling Claude Code, or onboarding new users to Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (recommended)** | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native (Windows PS)** | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native (Windows CMD)** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **npm (deprecated)** | `npm install -g @anthropic-ai/claude-code` | No |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). Migrate from npm to native: install native, then `npm uninstall -g @anthropic-ai/claude-code`.

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shells** | Bash, Zsh, PowerShell, CMD |

Alpine/musl requires `libgcc`, `libstdc++`, `ripgrep` and `USE_BUILTIN_RIPGREP=0`.

### Authentication Options

| Account type | How to log in |
|:-------------|:-------------|
| **Claude Pro/Max** | Run `claude`, follow browser prompts |
| **Claude Teams/Enterprise** | Same browser login; admin invites users first |
| **Claude Console** | Browser login with Console credentials; admin assigns Claude Code or Developer role |
| **Amazon Bedrock** | Set `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials (no browser login) |
| **Google Vertex AI** | Set `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials (no browser login) |
| **Microsoft Foundry** | Set `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials (no browser login) |

Credentials stored in macOS Keychain (on macOS). Custom credential scripts via `apiKeyHelper` setting. Refresh interval: 5 min default or `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`. Log out/re-auth: `/logout`.

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude update` | Manually apply update |
| `claude doctor` | Diagnose installation and configuration issues |
| `claude --version` | Show installed version |
| `/help` | Show available commands (inside session) |
| `/login` | Switch accounts (inside session) |
| `/clear` | Clear conversation history |
| `/context` | Show context window usage |
| `/compact [focus]` | Compress conversation, optionally focusing on a topic |
| `/model` | Switch model during session |
| `/init` | Create a CLAUDE.md for your project |

### Update and Release Channels

| Channel | Behavior | Setting |
|:--------|:---------|:--------|
| `latest` (default) | New features as soon as released | `"autoUpdatesChannel": "latest"` |
| `stable` | ~1 week delay, skips major regressions | `"autoUpdatesChannel": "stable"` |
| Disabled | No auto-updates | `"env": {"DISABLE_AUTOUPDATER": "1"}` |

Configure via `/config` or `settings.json`. Install a specific channel: `curl -fsSL https://claude.ai/install.sh \| bash -s stable`. Install a specific version: `bash -s 1.0.58`.

### The Agentic Loop

Claude Code works through three blended phases:

1. **Gather context** -- search files, read code, understand the codebase
2. **Take action** -- edit files, run commands, create branches
3. **Verify results** -- run tests, check output, iterate if needed

The loop adapts to the task. A question may only need phase 1. A bug fix cycles through all three repeatedly. You can interrupt at any point to steer Claude in a different direction.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up errors |
| **Code intelligence** | Type errors/warnings, jump to definitions, find references (requires plugins) |

### What Claude Can Access

When you run `claude` in a directory, it can access:

- **Project files** in the current directory and subdirectories
- **Terminal commands** -- anything you can run from the command line
- **Git state** -- current branch, uncommitted changes, recent history
- **CLAUDE.md** -- project-specific instructions loaded every session
- **Auto memory** -- learnings Claude saves automatically (first 200 lines of MEMORY.md)
- **Extensions** -- MCP servers, skills, subagents, Chrome integration

### Sessions

| Operation | Command | Behavior |
|:----------|:--------|:---------|
| Continue | `claude --continue` or `claude -c` | Append to existing session |
| Resume picker | `claude --resume` or `claude -r` | Choose from past sessions |
| Fork | `claude --continue --fork-session` | New session with copied history |

Sessions are independent (no cross-session conversation history). Sessions are tied to the current directory. Use git worktrees for parallel sessions on different branches.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | File edits | Shell commands |
|:-----|:-----------|:---------------|
| **Default** | Asks permission | Asks permission |
| **Auto-accept edits** | Automatic | Asks permission |
| **Plan mode** | Read-only | Read-only |

Allow specific commands in `.claude/settings.json` to skip per-command approval.

### Checkpoints

Every file edit is reversible. Press `Esc` twice to rewind to a previous state. Checkpoints are local to the session and separate from git. They only cover file changes -- actions affecting remote systems (databases, APIs, deployments) cannot be checkpointed.

### Context Window Management

- Run `/context` to see what is using space
- Run `/compact [focus]` to compress conversation history
- Put persistent rules in CLAUDE.md (not conversation history)
- MCP servers add tool definitions to every request; check costs with `/mcp`
- Skills load on demand; subagents get their own separate context

### Available Interfaces

| Interface | Description |
|:----------|:------------|
| **Terminal CLI** | Full-featured CLI, the primary interface |
| **VS Code** | Extension with inline diffs, @-mentions, plan review |
| **JetBrains** | Plugin for IntelliJ, PyCharm, WebStorm, etc. |
| **Desktop app** | Standalone app for macOS and Windows |
| **Web** | Browser-based at claude.ai/code, no local setup |
| **Remote Control** | Continue local sessions from any browser or phone |
| **Slack** | Route bug reports to pull requests via @Claude |
| **GitHub Actions** | Automate PR reviews and issue triage in CI |
| **GitLab CI/CD** | CI/CD integration for GitLab |

### Uninstallation

| Method | Command |
|:-------|:--------|
| **Native (macOS/Linux)** | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| **Native (Windows)** | Remove `%USERPROFILE%\.local\bin\claude.exe` and `%USERPROFILE%\.local\share\claude` |
| **Homebrew** | `brew uninstall --cask claude-code` |
| **WinGet** | `winget uninstall Anthropic.ClaudeCode` |
| **npm** | `npm uninstall -g @anthropic-ai/claude-code` |
| **Config cleanup** | Remove `~/.claude`, `~/.claude.json`, `.claude/`, `.mcp.json` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, installation entry points for all surfaces (Terminal, VS Code, Desktop, Web, JetBrains), what you can do (automate tasks, build features, fix bugs, git operations, MCP, customization, agent teams, CLI scripting), interface comparison table, next steps
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough (install, log in, start session, explore codebase, make edits, git operations, bug fixes, refactoring, tests, documentation), essential commands table, pro tips for beginners
- [Advanced setup](references/claude-code-setup.md) -- system requirements, platform-specific installation (Windows with Git Bash, WSL, Alpine/musl), verification (claude --version, claude doctor), update management (auto-updates, release channels, disable auto-updates, manual update), advanced installation (specific versions, npm migration, binary integrity), uninstallation per method, config file cleanup
- [Authentication](references/claude-code-authentication.md) -- login flow (browser prompts, account types), team setup (Teams/Enterprise, Console with role assignment, cloud providers), credential management (macOS Keychain, apiKeyHelper, refresh intervals)
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop (gather/act/verify phases), models (Sonnet, Opus, /model switching), built-in tools (file ops, search, execution, web, code intelligence), what Claude can access (project, terminal, git, CLAUDE.md, auto memory, extensions), execution environments (local, cloud, remote control), sessions (resume, fork, context window, compaction), checkpoints, permission modes, tips for effective use

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
