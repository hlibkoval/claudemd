---
name: getting-started
description: Reference documentation for getting started with Claude Code — installation (native, Homebrew, WinGet), system requirements, authentication (Claude.ai, Console, Bedrock, Vertex, Foundry), quickstart walkthrough, the agentic loop, built-in tools, sessions, context window management, permission modes, and tips for working effectively.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, authenticating, and beginning to use Claude Code, plus an explanation of how the agentic loop works under the hood.

## Quick Reference

### Installation Methods

| Method                  | Command                                          | Auto-updates? |
|:------------------------|:-------------------------------------------------|:--------------|
| Native (macOS/Linux/WSL)| `curl -fsSL https://claude.ai/install.sh \| bash`| Yes           |
| Native (Win PowerShell) | `irm https://claude.ai/install.ps1 \| iex`      | Yes           |
| Native (Win CMD)        | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew                | `brew install --cask claude-code`                | No (`brew upgrade claude-code`) |
| WinGet                  | `winget install Anthropic.ClaudeCode`            | No (`winget upgrade Anthropic.ClaudeCode`) |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). Verify with `claude --version` or `claude doctor`.

### System Requirements

| Requirement   | Details                                                              |
|:--------------|:---------------------------------------------------------------------|
| OS            | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM           | 4 GB+                                                                |
| Network       | Internet connection required                                         |
| Shell         | Bash, Zsh, PowerShell, or CMD                                        |

### Authentication Options

| Account type                 | How to log in                                              |
|:-----------------------------|:-----------------------------------------------------------|
| Claude Pro / Max             | Run `claude`, follow browser prompt                        |
| Claude Teams / Enterprise    | Same browser flow; admin invites first                     |
| Claude Console (API billing) | Browser flow; admin invites + assigns Claude Code or Developer role |
| Amazon Bedrock               | Set env vars, no browser login needed                      |
| Google Vertex AI             | Set env vars, no browser login needed                      |
| Microsoft Foundry            | Set env vars, no browser login needed                      |

Credentials stored in macOS Keychain (macOS) or credentials file. Use `/logout` to re-authenticate, `/login` to switch accounts.

### Essential CLI Commands

| Command             | Description                                |
|:--------------------|:-------------------------------------------|
| `claude`            | Start interactive session                  |
| `claude "task"`     | Run a one-time task                        |
| `claude -p "query"` | Run query, print result, exit             |
| `claude -c`         | Continue most recent conversation          |
| `claude -r`         | Resume a previous conversation             |
| `claude commit`     | Create a git commit                        |
| `claude update`     | Manually apply latest update               |
| `claude doctor`     | Diagnose installation issues               |
| `/clear`            | Clear conversation history                 |
| `/help`             | Show available commands                    |
| `/model`            | Switch model during session                |
| `/context`          | Show context window usage                  |
| `/compact [focus]`  | Compact context, optionally with a focus   |

### The Agentic Loop

Claude Code works in three phases: **gather context** -> **take action** -> **verify results**, repeating until the task is complete. You can interrupt at any point to steer.

**Built-in tool categories:**

| Category            | Capabilities                                                     |
|:--------------------|:-----------------------------------------------------------------|
| File operations     | Read, edit, create, rename files                                 |
| Search              | Find files by pattern, search content with regex                 |
| Execution           | Run shell commands, tests, git, start servers                    |
| Web                 | Search the web, fetch documentation                              |
| Code intelligence   | Type errors, go-to-definition, find references (via plugins)     |

### Permission Modes (Shift+Tab to cycle)

| Mode                | Behavior                                               |
|:--------------------|:-------------------------------------------------------|
| Default             | Asks before file edits and shell commands              |
| Auto-accept edits   | Edits files freely, still asks for commands            |
| Plan mode           | Read-only tools only, creates a plan for approval      |

### Session Management

| Action         | Command / Flag                    | Notes                                  |
|:---------------|:----------------------------------|:---------------------------------------|
| Continue last  | `claude -c` or `claude --continue`| Appends to existing session            |
| Resume any     | `claude -r` or `claude --resume`  | Pick from session list                 |
| Fork session   | `claude --continue --fork-session`| New ID, preserves history to that point|

Sessions are independent; each starts with a fresh context window. Use CLAUDE.md for persistent instructions across sessions.

### Update Channels

| Channel    | Setting value | Behavior                                          |
|:-----------|:--------------|:--------------------------------------------------|
| `latest`   | `"latest"`    | New features as soon as released (default)        |
| `stable`   | `"stable"`    | ~1 week delay, skips releases with regressions    |

Configure via `/config` or `"autoUpdatesChannel"` in settings.json. Disable auto-updates with `"DISABLE_AUTOUPDATER": "1"` in `env`.

### Uninstall

| Method   | Command                                                              |
|:---------|:---------------------------------------------------------------------|
| Native   | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude`          |
| Homebrew | `brew uninstall --cask claude-code`                                  |
| WinGet   | `winget uninstall Anthropic.ClaudeCode`                              |
| Config   | `rm -rf ~/.claude ~/.claude.json` (deletes all settings and history) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- product overview, available surfaces, capabilities, and integration points
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough, essential commands, and beginner tips
- [Advanced Setup](references/claude-code-setup.md) -- system requirements, platform-specific installation, version pinning, release channels, uninstallation
- [Authentication](references/claude-code-authentication.md) -- login methods, team setup (Teams/Enterprise, Console, cloud providers), credential management
- [How Claude Code Works](references/claude-code-how-it-works.md) -- agentic loop architecture, built-in tools, sessions, context window, permission modes, effectiveness tips

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
