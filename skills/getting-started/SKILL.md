---
name: getting-started
description: Reference documentation for getting started with Claude Code — overview, installation, setup, authentication, quickstart walkthrough, and how the agentic loop works. Use when installing Claude Code, configuring authentication, understanding system requirements, learning how Claude Code works, or onboarding new users.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code.

## Quick Reference

### Installation

| Method                 | Command / Action                                          | Auto-updates |
|:-----------------------|:----------------------------------------------------------|:-------------|
| **Native** (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash`       | Yes          |
| **Homebrew**           | `brew install --cask claude-code`                         | No           |
| **WinGet**             | `winget install Anthropic.ClaudeCode`                     | No           |
| **Windows PowerShell** | `irm https://claude.ai/install.ps1 \| iex`               | Yes          |
| **Windows CMD**        | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |

After installing: `cd your-project && claude`

### System Requirements

| Requirement       | Details                                                |
|:------------------|:-------------------------------------------------------|
| **OS**            | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM**           | 4 GB+                                                  |
| **Network**       | Internet connection required                           |
| **Shell**         | Bash or Zsh recommended                                |
| **Windows**       | Git Bash required (native) or WSL                      |

### Authentication Options

| Method                         | Best for                         |
|:-------------------------------|:---------------------------------|
| **Claude Pro/Max**             | Individual developers            |
| **Claude Teams/Enterprise**    | Organizations (centralized billing, SSO) |
| **Claude Console**             | API-based billing                |
| **Amazon Bedrock**             | Enterprise cloud (AWS)           |
| **Google Vertex AI**           | Enterprise cloud (GCP)           |
| **Microsoft Foundry**          | Enterprise cloud (Azure)         |

Credentials stored in macOS Keychain. Custom key scripts via `apiKeyHelper` setting. Refresh interval configurable with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

### Essential CLI Commands

| Command              | Description                                |
|:---------------------|:-------------------------------------------|
| `claude`             | Start interactive session                  |
| `claude "task"`      | Run a one-time task                        |
| `claude -p "query"`  | Run one-off query, then exit               |
| `claude -c`          | Continue most recent conversation          |
| `claude -r`          | Resume a previous conversation             |
| `claude commit`      | Create a Git commit                        |
| `claude update`      | Update Claude Code                         |
| `claude doctor`      | Check installation health                  |
| `/help`              | Show available commands (in-session)       |
| `/login`             | Switch accounts (in-session)               |
| `/init`              | Bootstrap a CLAUDE.md for the project      |
| `/model`             | Switch model during session                |

### How Claude Code Works

Claude Code is an agentic assistant with a three-phase loop: **gather context** -> **take action** -> **verify results**. It repeats until the task is complete, and you can interrupt at any point.

**Built-in tool categories:**

| Category              | Capabilities                                              |
|:----------------------|:----------------------------------------------------------|
| **File operations**   | Read, edit, create, rename files                          |
| **Search**            | Find files by pattern, search content with regex          |
| **Execution**         | Shell commands, servers, tests, git                       |
| **Web**               | Search the web, fetch docs, look up errors                |
| **Code intelligence** | Type errors, jump to definition, find references (via plugins) |

### Permission Modes (Shift+Tab)

| Mode                  | Behavior                                                  |
|:----------------------|:----------------------------------------------------------|
| **Default**           | Asks before file edits and shell commands                 |
| **Auto-accept edits** | Edits files without asking, still asks for commands       |
| **Plan mode**         | Read-only tools only, creates a plan for approval         |

### Session Management

- **Continue**: `claude --continue` (same session ID, appends messages)
- **Resume**: `claude --resume` (pick from recent sessions)
- **Fork**: `claude --continue --fork-session` (new ID, preserves history)
- **Context**: `/context` to see context window usage; `/compact` to summarize

### Release Channels

| Channel    | Setting value | Behavior                                   |
|:-----------|:--------------|:-------------------------------------------|
| **Latest** | `"latest"`    | New features immediately (default)         |
| **Stable** | `"stable"`    | ~1 week delay, skips regressions           |

Configure via `/config` or `"autoUpdatesChannel"` in settings.json. Disable auto-updates with `DISABLE_AUTOUPDATER=1`.

### Uninstall

```bash
# Native (macOS/Linux)
rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude

# Homebrew
brew uninstall --cask claude-code

# Config cleanup (optional — deletes all settings and history)
rm -rf ~/.claude ~/.claude.json
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — product overview, installation across all surfaces, capabilities, and integration points
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session walkthrough with examples
- [Setup](references/claude-code-setup.md) — system requirements, installation methods, platform-specific setup, updates, and uninstallation
- [Authentication](references/claude-code-authentication.md) — authentication methods for individuals, teams, and cloud providers; credential management
- [How Claude Code Works](references/claude-code-how-it-works.md) — the agentic loop, built-in tools, sessions, context window, checkpoints, and effective usage tips

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
