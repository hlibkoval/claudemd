---
name: getting-started
description: Reference documentation for getting started with Claude Code — installation on macOS/Linux/Windows, authentication methods (Claude.ai, Console, Bedrock, Vertex, Foundry), quickstart workflow, the agentic loop, built-in tools, session management, and permission modes. Use when a user asks how to install, set up, authenticate, or first use Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, authenticating, and getting started with Claude Code.

## Quick Reference

### Installation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew | `brew install --cask claude-code` |
| WinGet | `winget install Anthropic.ClaudeCode` |

Native installs auto-update. Homebrew and WinGet do not — run `brew upgrade claude-code` or `winget upgrade Anthropic.ClaudeCode` manually.

**System requirements**: macOS 13+, Windows 10 1809+ (or Server 2019+), Ubuntu 20.04+, Debian 10+, Alpine 3.19+. Minimum 4 GB RAM. Bash or Zsh recommended.

### First Run

```bash
cd your-project
claude          # starts interactive session; prompts for login on first use
```

Use `claude doctor` to verify your installation.

### Authentication Methods

| Method | Best for | Notes |
|:-------|:---------|:------|
| Claude Pro / Max / Teams / Enterprise | Individuals and teams | Unified subscription; log in with Claude.ai account |
| Claude Console | API/prepaid billing | OAuth flow; "Claude Code" workspace auto-created |
| Amazon Bedrock | Enterprise cloud | Set env vars + cloud credentials |
| Google Vertex AI | Enterprise cloud | Set env vars + cloud credentials |
| Microsoft Foundry | Enterprise cloud | Set env vars + cloud credentials |

Credentials are stored in the macOS Keychain (or equivalent). Use `/login` to switch accounts.

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task and exit |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --continue --fork-session` | Branch from current session |
| `claude update` | Update manually |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/context` | Show context window usage |
| `/compact` | Compact context (optionally with focus) |
| `/model` | Switch model mid-session |
| `exit` or Ctrl+C | Exit |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files without asking; still asks for commands |
| Plan mode | Read-only tools only; produces a plan for approval |

Every file edit is checkpointed. Press `Esc` twice to rewind to a previous state.

### The Agentic Loop

Claude works in three phases — **gather context → take action → verify results** — cycling until the task is complete. You can interrupt at any point.

Built-in tool categories:

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Shell commands, git, tests, build tools |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump-to-definition, find references (requires plugin) |

### Session Management

- Sessions are saved locally; each new session starts with a fresh context window.
- Resume with `claude --continue` or `claude --resume`.
- Fork a session with `--fork-session` to try a different approach without affecting the original.
- CLAUDE.md persists instructions across sessions; prefer it over relying on conversation history.

### Release Channels

| Channel | Setting | Behavior |
|:--------|:--------|:---------|
| `latest` | default | New features as released |
| `stable` | `"autoUpdatesChannel": "stable"` | ~1 week old; skips major regressions |

Set via `/config` or `settings.json`. Disable auto-updates with `DISABLE_AUTOUPDATER=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — what Claude Code is, available surfaces, and use cases
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session walkthrough
- [Setup Guide](references/claude-code-setup.md) — installation, updates, uninstall, platform-specific notes
- [Authentication](references/claude-code-authentication.md) — auth methods, team setup, credential management
- [How Claude Code Works](references/claude-code-how-it-works.md) — agentic loop, tools, sessions, context management, permissions

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Setup Guide: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
