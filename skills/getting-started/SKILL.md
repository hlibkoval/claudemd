---
name: getting-started
description: Reference documentation for getting started with Claude Code — installation methods, system requirements, authentication options, quickstart walkthrough, the agentic loop architecture, built-in tools, sessions, context management, checkpoints, and effective usage tips. Covers overview, setup, quickstart, authentication, and how Claude Code works.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, configuring, and understanding Claude Code.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Homebrew | `brew install --cask claude-code` | No |
| WinGet | `winget install Anthropic.ClaudeCode` | No |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No |

After install, run `claude doctor` to verify your setup.

### System Requirements

| Requirement | Minimum |
|:------------|:--------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ (Git Bash or WSL) |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Network | Internet connection required |
| Shell | Bash or Zsh recommended |

Alpine/musl-based distros need `libgcc`, `libstdc++`, and `ripgrep` installed separately.

### Authentication Options

| Method | Best for | How |
|:-------|:---------|:----|
| Claude Pro/Max | Individuals | Subscribe at claude.com/pricing, log in via OAuth |
| Claude Teams/Enterprise | Organizations | Centralized billing, team management, SSO |
| Claude Console | API-based billing | OAuth with Console account, auto-created workspace |
| Amazon Bedrock | Enterprise cloud | Environment variables, cloud credentials |
| Google Vertex AI | Enterprise cloud | Environment variables, cloud credentials |
| Microsoft Foundry | Enterprise cloud | Environment variables, cloud credentials |

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Print-mode: run query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude update` | Update Claude Code manually |
| `claude doctor` | Check installation and diagnose issues |

### In-Session Commands

| Command | Description |
|:--------|:------------|
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/model` | Switch model during session |
| `/clear` | Clear conversation history |
| `/compact` | Compact context (optional focus arg) |
| `/context` | Show what is using context space |
| `/init` | Create a CLAUDE.md for your project |
| `/doctor` | Diagnose common issues |
| `/agents` | Reload subagent definitions |

### Release Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week behind latest, skips regressions |

Configure via `/config` or in settings.json: `"autoUpdatesChannel": "stable"`. Disable auto-updates with `DISABLE_AUTOUPDATER=1`.

### The Agentic Loop

Claude Code works in three phases: **gather context** (search, read files), **take action** (edit, run commands), and **verify results** (run tests, check output). These phases repeat until the task is complete. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Shell commands, builds, tests, git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, go-to-definition, find references (via plugins) |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files without asking, still asks for commands |
| Plan mode | Read-only tools only, creates plan for approval |

### Session Management

| Flag | Behavior |
|:-----|:---------|
| `--continue` | Resume most recent session in current directory |
| `--resume` | Pick a previous session to resume |
| `--fork-session` | Branch off a session without affecting original |

Sessions are directory-scoped and independent. Each new session starts with a fresh context window. Use CLAUDE.md for persistent instructions across sessions.

### Credential Storage

- macOS: encrypted macOS Keychain
- Custom: `apiKeyHelper` setting runs a shell script returning an API key
- Refresh: every 5 min or on HTTP 401 (customize with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`)

### Uninstall

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | Remove `~/.claude`, `~/.claude.json`, `.claude/`, `.mcp.json` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- product overview, installation entry points, feature highlights, available environments
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough, essential commands, beginner tips
- [Setup](references/claude-code-setup.md) -- system requirements, platform-specific setup, installation methods, versioning, updates, uninstall
- [Authentication](references/claude-code-authentication.md) -- authentication methods for individuals, teams, and cloud providers, credential management
- [How Claude Code Works](references/claude-code-how-it-works.md) -- agentic loop, models, tools, sessions, context window, checkpoints, permissions, effective usage tips

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
