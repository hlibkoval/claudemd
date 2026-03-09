---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code — overview, installation (native/Homebrew/WinGet), system requirements, platform setup (macOS/Linux/Windows/WSL/Alpine), authentication (Claude.ai/Console/Bedrock/Vertex/Foundry), team setup, credential management, quickstart walkthrough, CLI essentials, how the agentic loop works, built-in tools, sessions, checkpoints, permissions, and tips for working effectively. Load when discussing Claude Code installation, setup, first-time configuration, authentication, login, how Claude Code works, the agentic loop, session management, or getting started.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and getting started with Claude Code, plus understanding how it works under the hood.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PS) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). The Desktop app is also available for [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect) and [Windows](https://claude.ai/api/desktop/win32/x64/exe/latest/redirect).

### System Requirements

| Component | Requirement |
|:----------|:------------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |

Alpine/musl distributions additionally require `libgcc`, `libstdc++`, `ripgrep`, and `USE_BUILTIN_RIPGREP=0` in settings.

### Authentication Options

| Account type | Login method |
|:-------------|:-------------|
| Claude Pro/Max subscription | Browser login via `claude` or `/login` |
| Claude for Teams/Enterprise | Browser login with team-invited account |
| Claude Console | Browser login with Console credentials |
| Amazon Bedrock | Set env vars before running `claude`; no browser needed |
| Google Vertex AI | Set env vars before running `claude`; no browser needed |
| Microsoft Foundry | Set env vars before running `claude`; no browser needed |

Credentials are stored in the macOS Keychain (on macOS). Custom credential scripts can be configured via the `apiKeyHelper` setting. Refresh interval defaults to 5 minutes or on HTTP 401; override with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

### Team Authentication Setup

| Method | Best for |
|:-------|:---------|
| Claude for Teams | Self-service plan, smaller teams |
| Claude for Enterprise | SSO, domain capture, role-based permissions, managed policies |
| Console | API-based billing; invite users via Settings > Members > Invite or SSO |
| Cloud providers (Bedrock/Vertex/Foundry) | Distribute env vars and cloud credentials |

Console roles: **Claude Code** (can only create Claude Code API keys) and **Developer** (can create any API key).

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run query, print result, exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Show version |
| `claude doctor` | Check installation and configuration |
| `claude update` | Apply update immediately |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/context` | Show context window usage |
| `/model` | Switch model |
| `/init` | Create a CLAUDE.md for your project |
| `/compact` | Compact conversation context |

### Update & Release Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week behind, skips releases with major regressions |

Configure via `/config` > Auto-update channel, or in settings.json: `"autoUpdatesChannel": "stable"`. Disable auto-updates with `"env": {"DISABLE_AUTOUPDATER": "1"}` in settings.

Install a specific channel: `curl -fsSL https://claude.ai/install.sh \| bash -s stable`
Install a specific version: `curl -fsSL https://claude.ai/install.sh \| bash -s 1.0.58`

### The Agentic Loop

Claude Code works in three phases: **gather context**, **take action**, and **verify results**. These phases blend together as Claude chains tool calls, adapting each step based on what it learned from the previous one. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Shell commands, servers, tests, git |
| Web | Search the web, fetch docs, look up errors |
| Code intelligence | Type errors, jump to definition, find references (via plugins) |

Extend with: [skills](/en/skills), [MCP](/en/mcp), [hooks](/en/hooks), [subagents](/en/sub-agents).

### What Claude Can Access

When you run `claude` in a directory, it can access your project files, terminal (any command you could run), git state, CLAUDE.md instructions, auto memory, and configured extensions (MCP servers, skills, subagents, Chrome).

### Sessions

| Feature | Details |
|:--------|:--------|
| Independence | Each session starts with a fresh context window |
| Persistence | Conversation saved locally; supports resume and fork |
| Resume | `claude --continue` or `claude --resume` |
| Fork | `claude --continue --fork-session` (new ID, keeps history) |
| Branches | Sessions tied to directory; use git worktrees for parallel work |
| Context management | `/context` to check usage; `/compact` to reclaim space |

Context fills with conversation history, file contents, command outputs, CLAUDE.md, loaded skills, and system instructions. When full, Claude compacts automatically, preserving requests and key snippets. Put persistent rules in CLAUDE.md rather than relying on conversation history.

### Permissions & Checkpoints

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits (`Shift+Tab`) | Edits files without asking; still asks for commands |
| Plan mode (`Shift+Tab` x2) | Read-only tools only; creates a plan for approval |

Every file edit is checkpointed. Press `Esc` twice to rewind. Checkpoints are local to the session, separate from git. Remote actions (databases, APIs, deployments) cannot be checkpointed.

### Uninstall

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows PS) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force; Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm (deprecated) | `npm uninstall -g @anthropic-ai/claude-code` |
| Config files | `rm -rf ~/.claude && rm ~/.claude.json` (removes all settings and history) |

### Tips for Working Effectively

- Be specific upfront: reference files, mention constraints, point to patterns
- Give Claude something to verify against: test cases, expected output, screenshots
- Explore before implementing: use plan mode to analyze, then implement
- Delegate, don't dictate: give context and direction, let Claude figure out details
- Iterate conversationally: correct course as you go rather than crafting perfect prompts
- Use `/init` to create a CLAUDE.md with project-specific instructions
- Ask Claude for help: "how do I set up hooks?" works as a prompt

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, available environments (Terminal, VS Code, Desktop, Web, JetBrains), capabilities, surface comparison table
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough: install, login, explore codebase, make edits, use Git, fix bugs, essential commands, beginner tips
- [Advanced setup](references/claude-code-setup.md) -- system requirements, platform-specific installation (Windows/WSL/Alpine), version pinning, release channels, auto-updates, npm migration, binary verification, uninstallation
- [Authentication](references/claude-code-authentication.md) -- login methods, team/enterprise setup, Console authentication, cloud provider auth, credential management, apiKeyHelper
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop architecture, models, built-in tools, what Claude can access, execution environments, sessions, context window management, checkpoints, permissions, effective usage tips

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
