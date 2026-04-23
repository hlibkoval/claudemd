---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, setup and installation, authentication, how the agentic loop works, and available platforms and integrations.
user-invocable: false
---

# Getting Started with Claude Code Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

Claude Code is an AI-powered agentic coding assistant. It reads your codebase, edits files, runs commands, and integrates with your development tools. Available in the terminal, IDE extensions, a desktop app, and the browser.

### Installation

| Platform | Command / Method |
| :--- | :--- |
| macOS / Linux / WSL | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | Add signed repo, then `sudo apt install claude-code` |
| dnf (Fedora/RHEL) | Add signed repo, then `sudo dnf install claude-code` |
| apk (Alpine) | Add signed repo, then `apk add claude-code` |

Native installer installations auto-update in the background. Homebrew, WinGet, and Linux package manager installations require manual upgrades.

### System requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD. Native Windows requires Git for Windows. |
| Network | Internet connection required |

### Authentication

Supported account types (in order of precedence):

| Method | How to configure |
| :--- | :--- |
| Cloud providers (Bedrock, Vertex, Foundry) | Set `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, or `CLAUDE_CODE_USE_FOUNDRY` |
| `ANTHROPIC_AUTH_TOKEN` env var | Bearer token for LLM gateways/proxies |
| `ANTHROPIC_API_KEY` env var | Direct Anthropic API key from the Console |
| `apiKeyHelper` script | Dynamic/rotating credentials from a vault |
| `CLAUDE_CODE_OAUTH_TOKEN` env var | Long-lived token from `claude setup-token` (for CI) |
| Subscription OAuth (`/login`) | Default for Pro, Max, Team, and Enterprise users |

Generate a long-lived CI token: `claude setup-token` (valid one year, scoped to inference only).

Credential storage: macOS Keychain on macOS; `~/.claude/.credentials.json` (mode 0600) on Linux/Windows.

### Essential CLI commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run a one-off query and exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Apply a pending update immediately |
| `claude --version` | Print installed version |
| `claude doctor` | Diagnose installation issues |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `/help` | Show available commands in interactive mode |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/clear` | Clear conversation history |
| `/model` | Switch model mid-session |
| `/context` | Show what is consuming context |
| `/compact` | Manually compact the context window |
| `/init` | Walk through creating a CLAUDE.md |
| `exit` or Ctrl+D | Exit Claude Code |

### The agentic loop

Claude Code works through three phases that blend together: **gather context** → **take action** → **verify results**, then repeats. You can interrupt at any point to steer.

Built-in tool categories:

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read files, edit code, create files, rename and reorganize |
| Search | Find files by pattern, search content with regex, explore codebases |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation, look up errors |
| Code intelligence | Type errors, jump to definitions, find references (requires plugin) |

### Permission modes (cycle with Shift+Tab)

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and runs common filesystem commands without asking |
| Plan mode | Read-only tools only; creates a plan for you to approve |
| Auto mode | Evaluates all actions with background safety checks (research preview) |

### Available surfaces

| Surface | Best for |
| :--- | :--- |
| CLI (Terminal) | Full feature set, scripting, third-party providers, Agent SDK |
| Desktop app | Visual diff review, parallel sessions, computer use (Pro/Max) |
| VS Code extension | Inline diffs, integrated terminal, file context inside VS Code |
| JetBrains plugin | Diff viewer, selection sharing in IntelliJ/PyCharm/WebStorm |
| Web (claude.ai/code) | Cloud sessions that keep running after you disconnect |
| Mobile (iOS/Android) | Start and monitor cloud sessions; Remote Control for local sessions |

### Release channel settings

```json
{
  "autoUpdatesChannel": "stable",
  "minimumVersion": "2.1.100"
}
```

`autoUpdatesChannel` values: `"latest"` (default) or `"stable"` (approx. one week behind). Set `DISABLE_AUTOUPDATER=1` in `env` to disable auto-updates entirely.

### Integrations at a glance

| Integration | Use for |
| :--- | :--- |
| GitHub Actions | Automated PR reviews, issue triage, CI maintenance |
| GitLab CI/CD | Same as GitHub Actions for GitLab |
| Code Review | Automatic review on every pull request |
| Slack | `@Claude` in a channel → get a PR back |
| Chrome | Control your browser for testing and automation |
| Remote Control | Drive a running local session from any browser or phone |
| Channels | Push events from Telegram, Discord, or webhooks into a session |
| Routines | Recurring tasks on Anthropic-managed cloud infrastructure |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, all supported surfaces, available integrations, and what you can do with it
- [Quickstart](references/claude-code-quickstart.md) — step-by-step guide from installation through your first code change, git operations, and common workflows
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific installation, Linux package managers, npm, binary integrity verification, update management, and uninstallation
- [Authentication](references/claude-code-authentication.md) — individual and team authentication, credential management, authentication precedence, and long-lived CI tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — the agentic loop, built-in tools, what Claude can access, session management, context window, checkpoints, and permission modes
- [Platforms and integrations](references/claude-code-platforms.md) — comparison of all surfaces (CLI, Desktop, VS Code, JetBrains, web, mobile), integrations (Chrome, GitHub Actions, GitLab, Code Review, Slack), and remote access options

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
