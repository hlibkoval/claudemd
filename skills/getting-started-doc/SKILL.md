---
name: getting-started-doc
description: Complete getting-started documentation for Claude Code -- product overview, installation on macOS/Linux/Windows, quickstart walkthrough, system requirements, authentication and login (Pro/Max/Teams/Enterprise/Console/Bedrock/Vertex/Foundry), credential management, updates, uninstallation, the agentic loop, built-in tools, sessions, context window, checkpoints, and working effectively with Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No |

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

### Authentication Options

| Account type | How to log in |
|:-------------|:-------------|
| Claude Pro / Max | Run `claude`, follow browser prompts |
| Claude for Teams / Enterprise | Log in with team account |
| Claude Console | Log in with Console credentials (admin must invite first) |
| Amazon Bedrock | Set env vars before running `claude` (no browser login) |
| Google Vertex AI | Set env vars before running `claude` (no browser login) |
| Microsoft Foundry | Set env vars before running `claude` (no browser login) |

Credentials stored in macOS Keychain (macOS) or system credential store. Use `/logout` to re-authenticate, `/login` to switch accounts.

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive print mode, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude update` | Update to latest version |
| `claude doctor` | Diagnose installation issues |
| `claude --version` | Show installed version |

### The Agentic Loop

Claude Code works through three phases: **gather context** -> **take action** -> **verify results**. These repeat until the task is complete. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git, build tools |
| Web | Search the web, fetch docs, look up errors |
| Code intelligence | Type errors, go-to-definition, find references (via LSP plugins) |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files freely, still asks for commands |
| Plan mode | Read-only tools only; creates a plan for approval |

### Update Channels

| Channel | Behavior |
|:--------|:---------|
| `"latest"` (default) | Receive new features immediately |
| `"stable"` | ~1 week delay, skips releases with major regressions |

Configure via `/config` or in settings.json: `{"autoUpdatesChannel": "stable"}`. Disable auto-updates: `{"env": {"DISABLE_AUTOUPDATER": "1"}}`.

### Sessions

- Each session starts with a fresh context window (no prior conversation history)
- Sessions are tied to your current directory
- Use `claude --continue` to resume, `claude --continue --fork-session` to branch off
- Persistent knowledge goes in CLAUDE.md or auto-memory, not conversation history
- Run `/context` to see what is using space; `/compact` to free context

### Checkpoints

Every file edit is reversible. Press `Esc` twice to rewind to a previous state. Checkpoints are local to your session, separate from git. Remote actions (databases, APIs, deployments) cannot be checkpointed.

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | `rm -rf ~/.claude && rm ~/.claude.json` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- product overview, installation options across all surfaces (Terminal, VS Code, JetBrains, Desktop, Web), capabilities, and integration points
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough, essential commands, Git usage, bug fixing, and beginner tips
- [Advanced Setup](references/claude-code-setup.md) -- system requirements, platform-specific installation, Windows setup, Alpine Linux, version pinning, release channels, auto-updates, npm migration, binary integrity, and uninstallation
- [Authentication](references/claude-code-authentication.md) -- login flow, team/enterprise setup, Console authentication, cloud provider auth, and credential management
- [How Claude Code Works](references/claude-code-how-it-works.md) -- the agentic loop, models, built-in tools, execution environments, sessions, context window management, checkpoints, permissions, and tips for working effectively

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
