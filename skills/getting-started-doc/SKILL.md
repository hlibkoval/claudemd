---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview of all surfaces (terminal, VS Code, JetBrains, desktop app, web, Slack), installation methods (native installer, Homebrew, WinGet, npm), system requirements, platform-specific setup (macOS, Windows, WSL, Alpine Linux), authentication (Claude.ai, Console, Bedrock, Vertex AI, Foundry), team setup (Teams, Enterprise, Console SSO), credential management, quickstart walkthrough (first session, first code change, Git workflows, bug fixing, refactoring, testing), essential CLI commands, update channels (latest, stable), auto-updates, uninstallation, the agentic loop architecture (models, tools, context gathering, action, verification), built-in tool categories (file ops, search, execution, web, code intelligence), session management (resume, fork, context window, compaction), permission modes (default, auto-accept edits, plan mode), checkpoints, and tips for working effectively. Load when discussing installation, setup, getting started, first steps, authentication, login, updating, uninstalling, how Claude Code works, the agentic loop, sessions, or permission modes.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and getting started with Claude Code, including how the agentic loop works under the hood.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PS) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No |

### System Requirements

| Requirement | Details |
|:------------|:--------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Windows extra | Git for Windows required |

### Available Surfaces

| Surface | Description |
|:--------|:------------|
| Terminal CLI | Full-featured CLI; `claude` command |
| VS Code / Cursor | Extension with inline diffs, @-mentions, plan review |
| JetBrains IDEs | Plugin with interactive diff viewing and selection context |
| Desktop app | Standalone app with visual diff review, multiple sessions, scheduled tasks |
| Web | Browser-based at claude.ai/code; no local setup |
| Slack | Mention @Claude with a bug report, get a PR back |
| CI/CD | GitHub Actions, GitLab CI/CD for automated review and triage |

### Authentication Options

| Account type | Login method |
|:-------------|:-------------|
| Claude Pro / Max | Browser login via `claude` or `/login` |
| Claude for Teams / Enterprise | Browser login with team-invited account |
| Claude Console | Browser login with Console credentials |
| Amazon Bedrock | Environment variables (no browser login) |
| Google Vertex AI | Environment variables (no browser login) |
| Microsoft Foundry | Environment variables (no browser login) |

Credentials are stored in the macOS Keychain (on macOS). Use `/logout` to re-authenticate. Custom credential scripts supported via `apiKeyHelper` setting.

### Team Setup

| Plan | Best for | Setup |
|:-----|:---------|:------|
| Claude for Teams | Smaller teams | Self-service; invite from admin dashboard |
| Claude for Enterprise | Large orgs | SSO, domain capture, role-based permissions, managed policies |
| Claude Console | API-based billing | Invite users with "Claude Code" or "Developer" role |
| Cloud providers | Enterprise cloud | Distribute env vars and cloud credential instructions |

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Check installed version |
| `claude doctor` | Diagnose installation and configuration issues |
| `claude update` | Apply update immediately |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out and re-authenticate |
| `/model` | Switch model during a session |
| `/context` | See what is using context space |

### Update Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week behind, skips releases with major regressions |

Configure via `/config` or `"autoUpdatesChannel": "stable"` in settings.json. Disable auto-updates with `"env": {"DISABLE_AUTOUPDATER": "1"}` in settings.

### The Agentic Loop

Claude Code works through three blended phases: **gather context** (search files, read code), **take action** (edit files, run commands), and **verify results** (run tests, check output). The loop repeats until the task is complete; you can interrupt at any point.

The loop is powered by **models** (reasoning) and **tools** (acting):

| Tool category | What Claude can do |
|:--------------|:-------------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump to definitions, find references (requires plugins) |

### Session Management

| Action | Command |
|:-------|:--------|
| Resume last session | `claude --continue` or `claude -c` |
| Resume a specific session | `claude --resume` or `claude -r` |
| Fork session (new branch of conversation) | `claude --continue --fork-session` |
| Check context usage | `/context` |
| Manual compaction | `/compact [focus]` |

Sessions are independent -- each new session starts with a fresh context window. Persistent instructions belong in CLAUDE.md; auto memory carries learnings across sessions automatically.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files without asking; still asks for commands |
| Plan mode | Read-only tools only; creates a plan for approval |

### Checkpoints

Every file edit is snapshotted before changes. Press `Esc` twice to rewind to a previous state. Checkpoints are local to the session and separate from git. They only cover file changes, not remote actions (databases, APIs, deployments).

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force` and `Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | `rm -rf ~/.claude ~/.claude.json` (removes settings, state, and session history) |

### Windows Setup

Two options: **Native Windows with Git Bash** (install Git for Windows, then run native installer) or **WSL** (both WSL 1 and WSL 2 supported; WSL 2 supports sandboxing). If Claude Code cannot find Git Bash, set `CLAUDE_CODE_GIT_BASH_PATH` in settings.

### Alpine / musl-Based Distributions

Install `libgcc`, `libstdc++`, `ripgrep`, then set `USE_BUILTIN_RIPGREP=0` in settings.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, all surfaces (terminal, VS Code, JetBrains, desktop, web), capabilities (automation, features, commits/PRs, MCP, customization, agent teams, CLI scripting), integration matrix
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough, first code change, Git operations, bug fixing, refactoring, testing, documentation updates, essential commands, pro tips
- [Advanced setup](references/claude-code-setup.md) -- system requirements, platform-specific installation (Windows, WSL, Alpine), native/Homebrew/WinGet/npm install methods, verification, update channels, auto-updates, version pinning, npm migration, binary integrity, uninstallation
- [Authentication](references/claude-code-authentication.md) -- login flow, account types, team setup (Teams, Enterprise, Console, cloud providers), credential management, apiKeyHelper
- [How Claude Code works](references/claude-code-how-it-works.md) -- the agentic loop, models, built-in tools, what Claude can access, execution environments, session management (resume, fork, context window, compaction), checkpoints, permission modes, tips for effective use

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
