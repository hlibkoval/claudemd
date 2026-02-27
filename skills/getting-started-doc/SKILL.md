---
name: getting-started-doc
description: Reference documentation for getting started with Claude Code -- installation on macOS, Linux, Windows, and WSL, quickstart walkthrough, authentication (Claude Pro/Max/Teams/Enterprise/Console/cloud providers), credential management, system requirements, updates, uninstallation, the agentic loop, built-in tools, sessions, checkpoints, and permission modes. Use when answering questions about installing, setting up, logging in, or understanding how Claude Code works.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, authenticating, and understanding how Claude Code works.

## Quick Reference

### Installation

| Method            | Command                                               | Auto-updates |
|:------------------|:------------------------------------------------------|:-------------|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes        |
| Native (Win PS)   | `irm https://claude.ai/install.ps1 \| iex`            | Yes          |
| Homebrew          | `brew install --cask claude-code`                     | No           |
| WinGet            | `winget install Anthropic.ClaudeCode`                 | No           |

System requirements: macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4 GB RAM, internet connection. Windows requires Git for Windows.

Verify: `claude --version` or `claude doctor`

### Authentication Account Types

| Account type             | How to log in                                    |
|:-------------------------|:-------------------------------------------------|
| Claude Pro / Max         | Browser OAuth via `claude` on first launch       |
| Claude for Teams / Enterprise | Browser OAuth with team-admin invited account |
| Claude Console           | Console credentials; admin must invite first     |
| Amazon Bedrock           | Set env vars — no browser login needed           |
| Google Vertex AI         | Set env vars — no browser login needed           |
| Microsoft Foundry        | Set env vars — no browser login needed           |

Commands: `/login` to switch accounts, `/logout` to log out.
Credentials stored in macOS Keychain. Custom key script: `apiKeyHelper` setting.

### Essential CLI Commands

| Command               | Description                                             |
|:----------------------|:--------------------------------------------------------|
| `claude`              | Start interactive session                               |
| `claude "task"`       | Run a one-time task                                     |
| `claude -p "query"`   | One-off query, then exit                                |
| `claude -c`           | Continue most recent conversation in current directory  |
| `claude -r`           | Resume a previous conversation                          |
| `claude --continue --fork-session` | Fork current session into a new one        |
| `claude update`       | Apply update immediately                                |
| `claude doctor`       | Diagnose installation issues                            |
| `/help`               | Show available commands                                 |
| `/clear`              | Clear conversation history                              |
| `/init`               | Bootstrap a CLAUDE.md for the project                  |
| `/model`              | Switch model mid-session                                |
| `/context`            | See what is using context window space                  |
| `/compact`            | Compact context (optionally with focus)                 |

### The Agentic Loop

Claude works in three blending phases: **gather context** → **take action** → **verify results**, repeating until done. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category           | What Claude can do                                                          |
|:-------------------|:----------------------------------------------------------------------------|
| File operations    | Read, edit, create, rename files                                            |
| Search             | Find files by pattern, search content with regex                            |
| Execution          | Run shell commands, start servers, run tests, use git                       |
| Web                | Search the web, fetch documentation                                         |
| Code intelligence  | See type errors, jump to definitions (requires code intelligence plugin)    |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode              | Behavior                                                        |
|:------------------|:----------------------------------------------------------------|
| Default           | Asks before file edits and shell commands                       |
| Auto-accept edits | Edits files without asking; still asks for commands             |
| Plan mode         | Read-only tools only; shows plan for approval before execution  |

Every file edit is checkpointed. Press `Esc` twice to rewind to a previous state.

### Update & Release Channels

| Channel    | Behavior                                     | Configure                                     |
|:-----------|:---------------------------------------------|:----------------------------------------------|
| `latest`   | New features immediately (default)           | `"autoUpdatesChannel": "latest"` in settings  |
| `stable`   | Approximately one week behind latest         | `"autoUpdatesChannel": "stable"` in settings  |

Disable auto-updates: set `DISABLE_AUTOUPDATER=1` in the `env` key of settings.json.

### Session Management

- Sessions are directory-scoped and saved locally.
- Each new session starts with a fresh context window (no prior history).
- CLAUDE.md and auto memory persist across sessions.
- `claude --continue` resumes the most recent session; `claude --resume` picks from a list.
- `claude --continue --fork-session` creates a new session branched from the current one.
- Context compacts automatically; put persistent rules in CLAUDE.md.

### Uninstall

| Method    | Command                                              |
|:----------|:-----------------------------------------------------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew  | `brew uninstall --cask claude-code`                  |
| WinGet    | `winget uninstall Anthropic.ClaudeCode`              |
| Config    | `rm -rf ~/.claude ~/.claude.json` (removes all settings and history) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- what Claude Code is, available surfaces, capabilities overview, and next steps
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough, essential commands, and pro tips
- [Advanced Setup](references/claude-code-setup.md) -- system requirements, platform-specific installation, version management, update channels, and uninstallation
- [Authentication](references/claude-code-authentication.md) -- account types, team auth setup (Teams/Enterprise/Console/cloud providers), and credential management
- [How Claude Code Works](references/claude-code-how-it-works.md) -- the agentic loop, built-in tools, session management, context window, checkpoints, and permission modes

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
