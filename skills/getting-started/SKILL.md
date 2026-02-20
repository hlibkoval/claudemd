---
name: getting-started
description: Reference documentation for getting started with Claude Code — installation, setup, quickstart, authentication, system requirements, the agentic loop, built-in tools, sessions, permissions, and tips for working effectively. Use when installing Claude Code, setting up authentication, understanding how the agentic loop works, managing sessions, or learning best practices for prompting.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code.

## Quick Reference

### Installation

| Method               | Command / Action                                    | Auto-updates |
|:---------------------|:----------------------------------------------------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash`  | Yes          |
| Homebrew             | `brew install --cask claude-code`                   | No           |
| WinGet               | `winget install Anthropic.ClaudeCode`               | No           |
| Windows PowerShell   | `irm https://claude.ai/install.ps1 \| iex`         | Yes          |
| NPM (deprecated)     | `npm install -g @anthropic-ai/claude-code`          | No           |

After installation: `cd your-project && claude`

### System Requirements

- **OS**: macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **RAM**: 4 GB+
- **Network**: Internet connection required
- **Shell**: Bash or Zsh recommended
- **Windows**: Requires Git Bash or WSL

### Authentication Methods

| Method                        | Best for                  | Setup                                   |
|:------------------------------|:--------------------------|:----------------------------------------|
| Claude Pro / Max              | Individuals               | Subscribe, then `claude` and log in     |
| Claude Teams / Enterprise     | Organizations             | Admin invites members, SSO available    |
| Claude Console (API)          | API-based billing         | Console account + OAuth                 |
| Amazon Bedrock                | AWS infrastructure        | Environment variables                   |
| Google Vertex AI              | GCP infrastructure        | Environment variables                   |
| Microsoft Foundry             | Azure infrastructure      | Environment variables                   |

Credentials stored in macOS Keychain (macOS) or credentials file. Custom credential scripts via `apiKeyHelper` setting.

### Essential CLI Commands

| Command             | Description                              |
|:---------------------|:-----------------------------------------|
| `claude`            | Start interactive session                |
| `claude "task"`     | Run a one-time task                      |
| `claude -p "query"` | Run query, print result, exit            |
| `claude -c`         | Continue most recent conversation        |
| `claude -r`         | Resume a previous conversation           |
| `claude commit`     | Create a Git commit                      |
| `claude update`     | Manually update Claude Code              |
| `claude doctor`     | Diagnose installation issues             |
| `/help`             | Show available commands (in session)     |
| `/login`            | Switch accounts (in session)             |
| `/model`            | Switch model (in session)                |
| `/context`          | Show context window usage (in session)   |

### The Agentic Loop

Claude Code works in three phases: **gather context** -> **take action** -> **verify results**, repeating until the task is complete. You can interrupt at any point.

### Built-in Tool Categories

| Category              | Capabilities                                               |
|:----------------------|:-----------------------------------------------------------|
| File operations       | Read, edit, create, rename files                           |
| Search                | Find files by pattern, search content with regex           |
| Execution             | Shell commands, builds, tests, git                         |
| Web                   | Search the web, fetch documentation                        |
| Code intelligence     | Type errors, jump to definition, find references (plugins) |

### Permission Modes (Shift+Tab to cycle)

| Mode                | Behavior                                               |
|:--------------------|:-------------------------------------------------------|
| Default             | Asks before file edits and shell commands              |
| Auto-accept edits   | Edits files without asking, still asks for commands    |
| Plan mode           | Read-only tools only, creates a plan for approval      |

### Session Management

- Sessions are saved locally and tied to the current directory
- `claude --continue` / `claude -c` resumes the most recent session
- `claude --resume` / `claude -r` lets you pick a previous session
- `claude --continue --fork-session` branches from a session without affecting it
- Each session has an independent context window
- Use `/compact` to manage context when it fills up

### Release Channels

| Channel    | Description                                        |
|:-----------|:---------------------------------------------------|
| `latest`   | New features as soon as released (default)         |
| `stable`   | ~1 week old, skips releases with major regressions |

Configure via `/config` or `"autoUpdatesChannel": "stable"` in settings.json.

### Uninstall

| Method   | Command                                                 |
|:---------|:--------------------------------------------------------|
| Native   | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code`                     |
| WinGet   | `winget uninstall Anthropic.ClaudeCode`                 |
| NPM      | `npm uninstall -g @anthropic-ai/claude-code`            |

Config cleanup: `rm -rf ~/.claude && rm ~/.claude.json`

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — product overview, installation options across all surfaces (terminal, VS Code, desktop, web, JetBrains), and capabilities summary
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session walkthrough, essential commands, and beginner tips
- [Setup](references/claude-code-setup.md) — system requirements, installation methods, platform-specific setup, updates, release channels, and uninstallation
- [Authentication](references/claude-code-authentication.md) — authentication methods for individuals and teams, credential management, Console setup, and cloud provider auth
- [How Claude Code Works](references/claude-code-how-it-works.md) — the agentic loop, built-in tools, context window management, sessions, checkpoints, permissions, and effectiveness tips

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
