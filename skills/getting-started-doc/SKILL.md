---
name: getting-started-doc
description: Complete getting started documentation for Claude Code — overview of capabilities, installation on all platforms (macOS, Linux, Windows, WSL, Homebrew, WinGet, npm), system requirements, quickstart walkthrough, authentication setup (Claude.ai, Console, Teams, Enterprise, Bedrock, Vertex AI, Foundry), credential management, the agentic loop architecture, built-in tools, sessions, checkpoints, and tips for working effectively.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, authenticating, and getting started with Claude Code, plus how the agentic loop works under the hood.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PS) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No |

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **OS** | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Windows** | Git for Windows required |

### Authentication Options

| Account type | How to log in |
|:-------------|:-------------|
| Claude Pro / Max | Run `claude`, follow browser prompts |
| Claude Teams / Enterprise | Same browser flow, org-managed account |
| Claude Console | Browser flow with Console credentials |
| Amazon Bedrock | Set env vars, no browser login |
| Google Vertex AI | Set env vars, no browser login |
| Microsoft Foundry | Set env vars, no browser login |

Credentials stored in macOS Keychain (macOS) or equivalent. Use `/login` to switch accounts, `/logout` to re-authenticate. Custom credential scripts via `apiKeyHelper` setting.

### Essential CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Print-mode: run query and exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Check installed version |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Manual update |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |

### Interfaces

| Surface | Best for |
|:--------|:---------|
| Terminal CLI | Full-featured, all workflows |
| VS Code / Cursor | Inline diffs, @-mentions, plan review |
| JetBrains IDEs | Interactive diffs, selection context |
| Desktop app | Visual diff review, multiple sessions |
| Web (claude.ai/code) | No local setup, long-running tasks |
| Slack | Route bug reports to pull requests |
| GitHub Actions / GitLab CI | Automated PR review, issue triage |

### The Agentic Loop

Claude Code works in three blended phases:

1. **Gather context** -- read files, search code, run commands to understand
2. **Take action** -- edit files, run builds, create branches
3. **Verify results** -- run tests, check output, iterate if needed

Built-in tool categories:

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Shell commands, servers, tests, git |
| Web | Search the web, fetch docs |
| Code intelligence | Type errors, jump to definition (via LSP plugins) |

### Sessions and Context

- Each session is independent (fresh context window)
- Sessions are saved locally, enabling resume and fork
- `claude --continue` resumes; `--fork-session` branches off
- Context fills with conversation, files, CLAUDE.md, skills
- `/context` shows usage; `/compact` frees space
- Persistent knowledge via CLAUDE.md and auto memory

### Permission Modes (`Shift+Tab` to cycle)

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before edits and commands |
| Auto-accept edits | Edits without asking; asks for commands |
| Plan mode | Read-only tools only; creates a plan for approval |

### Update Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features immediately |
| `stable` | ~1 week delay, skips regressions |

Set via `/config` or `"autoUpdatesChannel": "stable"` in settings.json. Disable auto-updates with `DISABLE_AUTOUPDATER=1` env var.

### Uninstall

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | `rm -rf ~/.claude && rm ~/.claude.json` |

### Tips for Working Effectively

- **Be specific**: reference files, mention constraints, point to patterns
- **Give verification criteria**: test cases, expected output, screenshots
- **Explore first**: use plan mode for complex problems before implementing
- **Delegate, don't dictate**: describe the goal, let Claude figure out the steps
- **Interrupt anytime**: type corrections mid-task to steer Claude

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, installation for all surfaces, capabilities, and next steps
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough, essential commands, and beginner tips
- [Advanced setup](references/claude-code-setup.md) -- system requirements, platform-specific installation, version management, release channels, and uninstallation
- [Authentication](references/claude-code-authentication.md) -- login flow, team setup (Teams, Enterprise, Console, cloud providers), and credential management
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop architecture, models, tools, sessions, checkpoints, permissions, and effective usage tips

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
