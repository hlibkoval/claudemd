---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code — overview, installation, quickstart walkthrough, advanced setup (system requirements, platform-specific install, updates, uninstallation), authentication (login, team setup, Console, cloud providers, credential management), and how Claude Code works (agentic loop, models, tools, sessions, context window, checkpoints, permissions, working effectively). Load when discussing installation, setup, first-time usage, login, authentication, account types, system requirements, the agentic loop, how Claude Code operates, sessions, context management, or onboarding new users.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: overview, installation, quickstart, advanced setup, authentication, and how Claude Code works.

## Quick Reference

Claude Code is an agentic coding tool that reads your codebase, edits files, runs commands, and integrates with development tools. Available in terminal, IDE, desktop app, and browser.

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade`) |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |

After install: `cd your-project && claude`

### System Requirements

| Requirement | Details |
|:------------|:--------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Network | Internet required |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Windows extra | Git for Windows required |

### Available Interfaces

| Interface | Description |
|:----------|:------------|
| Terminal CLI | Full-featured CLI (`claude`) |
| VS Code | Extension with inline diffs, @-mentions, plan review |
| JetBrains | Plugin for IntelliJ, PyCharm, WebStorm, etc. |
| Desktop app | Standalone app for macOS and Windows |
| Web | Browser-based at claude.ai/code, no local setup |
| Slack | Route tasks from team chat with @Claude |

### Authentication

| Account type | How to log in |
|:-------------|:-------------|
| Claude Pro/Max | Run `claude`, follow browser prompt |
| Claude Teams/Enterprise | Log in with team-invited Claude.ai account |
| Claude Console | Log in with Console credentials (admin must invite first) |
| Amazon Bedrock | Set environment variables, no browser login |
| Google Vertex AI | Set environment variables, no browser login |
| Microsoft Foundry | Set environment variables, no browser login |

Log out and re-authenticate: `/logout`. Switch accounts: `/login`.

**Credential storage**: macOS uses encrypted Keychain. Custom credential scripts via `apiKeyHelper` setting. Refresh interval configurable with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

### Team Authentication Setup

| Method | Best for |
|:-------|:---------|
| Claude for Teams | Self-service, smaller teams |
| Claude for Enterprise | SSO, domain capture, role-based permissions, managed policies |
| Claude Console | API-based billing; roles: `Claude Code` or `Developer` |
| Cloud providers | Bedrock, Vertex AI, Foundry with distributed env vars |

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Check installed version |
| `claude doctor` | Diagnose installation/config issues |
| `claude update` | Manually apply updates |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out |

### The Agentic Loop

Claude Code works through three phases: **gather context** -> **take action** -> **verify results**. These phases blend together and repeat until the task is complete. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Shell commands, servers, tests, git |
| Web | Search the web, fetch docs, look up errors |
| Code intelligence | Type errors, jump to definition, find references (via plugins) |

### Session Management

| Feature | Details |
|:--------|:--------|
| Resume | `claude --continue` or `claude --resume` |
| Fork | `claude --continue --fork-session` (new ID, preserves history) |
| Context window | Holds conversation, files, commands, CLAUDE.md, skills, system instructions |
| Auto-compaction | Old tool outputs cleared first, then conversation summarized |
| Check context usage | `/context` command |
| Focus compaction | `/compact focus on the API changes` |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits without asking, still asks for commands |
| Plan mode | Read-only tools only, creates reviewable plan |

### Update Management

| Setting | Value | Effect |
|:--------|:------|:-------|
| `autoUpdatesChannel` | `"latest"` (default) | New features immediately |
| `autoUpdatesChannel` | `"stable"` | ~1 week delayed, skips regressions |
| `DISABLE_AUTOUPDATER` | `"1"` in env | Disable all auto-updates |

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm (deprecated) | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | `rm -rf ~/.claude && rm ~/.claude.json` |

### Working Effectively

- **Be specific upfront**: reference files, mention constraints, point to patterns
- **Give verification targets**: include test cases, expected outputs, screenshots
- **Explore before implementing**: use plan mode to analyze first, then implement
- **Delegate, don't dictate**: provide context and direction, let Claude figure out details
- **Iterate conversationally**: refine through follow-up messages, interrupt if off track

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, installation for all interfaces (Terminal, VS Code, JetBrains, Desktop, Web), capabilities, use cases, next steps
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough: install, log in, explore codebase, make changes, use Git, fix bugs, refactor, write tests, essential commands, tips
- [Advanced setup](references/claude-code-setup.md) -- system requirements, platform-specific installation (Windows, Alpine), verification, authentication, auto-updates, release channels, version pinning, npm migration, binary integrity, uninstallation
- [Authentication](references/claude-code-authentication.md) -- login flow, account types, team setup (Teams, Enterprise, Console, cloud providers), credential management, apiKeyHelper
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop, models, tools, what Claude can access, execution environments, interfaces, sessions, context window management, checkpoints, permissions, working effectively

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
