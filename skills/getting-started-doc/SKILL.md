---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview, installation, quickstart walkthrough, authentication, how the agentic loop works, and platform/integration options. Covers installation methods (native installer, Homebrew, WinGet, npm), system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4GB RAM), Windows setup (Git Bash, WSL, PowerShell), authentication methods (Claude Pro/Max/Team/Enterprise, Console, Bedrock, Vertex AI, Foundry), authentication precedence (cloud provider > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth), credential storage (macOS Keychain, Linux/Windows ~/.claude/.credentials.json), the agentic loop (gather context, take action, verify results), built-in tool categories (file operations, search, execution, web, code intelligence), session management (resume, fork, context window, compaction), checkpoints and undo, permission modes (default, auto-accept edits, plan, auto), update channels (latest, stable), release channel configuration, auto-updates, manual updates, version pinning, binary integrity verification (GPG-signed manifest, platform code signatures), uninstallation, platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integration options (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack), remote access (Dispatch, Remote Control, Channels, scheduled tasks), quickstart steps (install, login, explore codebase, edit code, git operations, fix bugs, write tests), essential CLI commands, and tips for working effectively. Load when discussing getting started, installation, setup, quickstart, authentication, login, how Claude Code works, agentic loop, platforms, integrations, system requirements, updating, uninstalling, credential management, session management, checkpoints, permission modes, or any introductory topic for Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- installation, authentication, the agentic loop, quickstart walkthrough, and platform options.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
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

### Authentication Methods and Precedence

Authentication is checked in this order (first match wins):

| Priority | Method | How to configure |
|:---------|:-------|:-----------------|
| 1 | Cloud provider (Bedrock/Vertex/Foundry) | Set `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, or `CLAUDE_CODE_USE_FOUNDRY` |
| 2 | `ANTHROPIC_AUTH_TOKEN` env var | Sent as `Authorization: Bearer` header (for LLM gateways/proxies) |
| 3 | `ANTHROPIC_API_KEY` env var | Sent as `X-Api-Key` header (direct API access) |
| 4 | `apiKeyHelper` script | Dynamic/rotating credentials from a vault |
| 5 | Subscription OAuth (`/login`) | Default for Pro, Max, Team, Enterprise users |

### Account Types

| Account | Access |
|:--------|:-------|
| Claude Pro / Max | Log in with Claude.ai account |
| Claude for Teams | Team admin invites members; centralized billing |
| Claude for Enterprise | SSO, domain capture, role-based permissions, managed policies |
| Claude Console | API-based billing; assign "Claude Code" or "Developer" role |
| Amazon Bedrock | Set env vars; no browser login needed |
| Google Vertex AI | Set env vars; no browser login needed |
| Microsoft Foundry | Set env vars; no browser login needed |

### Credential Storage

| Platform | Location |
|:---------|:---------|
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode `0600`) |
| Windows | `~/.claude/.credentials.json` (user profile ACLs) |
| Custom | Set `$CLAUDE_CONFIG_DIR` to override |

### Quickstart Steps

1. **Install** -- run the native installer for your platform
2. **Log in** -- run `claude` and follow browser prompts (or set env vars for cloud providers)
3. **Start a session** -- `cd your-project && claude`
4. **Explore** -- ask "what does this project do?" or "explain the folder structure"
5. **Edit code** -- ask Claude to make changes; approve proposed edits
6. **Use Git** -- "commit my changes with a descriptive message", "create a new branch"
7. **Fix bugs / add features** -- describe the problem in natural language
8. **Write tests, refactor, review** -- delegate like a colleague

### Essential CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --continue --fork-session` | Fork a session (new ID, same history) |
| `claude --version` | Check installed version |
| `claude update` | Manually apply update |
| `claude doctor` | Diagnose installation/config issues |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out and re-authenticate |
| `/model` | Switch model during a session |
| `/context` | See what is using context window space |
| `/compact` | Manually trigger context compaction |

### The Agentic Loop

Claude Code works in three blended phases: **gather context** (search files, read code), **take action** (edit files, run commands), and **verify results** (run tests, check output). The loop chains dozens of actions, course-correcting along the way. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename, reorganize files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation, look up errors |
| Code intelligence | Type errors, jump to definition, find references (requires LSP plugins) |

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files without asking; still asks for commands |
| Plan mode | Read-only tools only; creates a plan for approval |
| Auto mode | Evaluates all actions with background safety checks (research preview) |

Cycle through modes with `Shift+Tab`.

### Session Management

| Feature | How |
|:--------|:----|
| Resume last session | `claude --continue` or `claude -c` |
| Resume specific session | `claude --resume` or `claude -r` |
| Fork a session | `claude --continue --fork-session` |
| View context usage | `/context` |
| Manual compaction | `/compact [focus]` |
| Persistent instructions | Add to `CLAUDE.md` (not lost on compaction) |
| Auto memory | Learnings saved across sessions automatically |

### Update Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week behind, skips releases with major regressions |

Configure via `/config` or in `settings.json`:

```json
{
  "autoUpdatesChannel": "stable"
}
```

Disable auto-updates:

```json
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

### Platforms

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use (macOS), third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| VS Code | In-editor workflow | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| Web | Long-running/offline tasks | Anthropic-managed cloud, continues after disconnect |

### Integrations

| Integration | Use case |
|:------------|:---------|
| Chrome | Test web apps, automate browser tasks |
| GitHub Actions | CI-driven PR reviews, issue triage |
| GitLab CI/CD | CI-driven automation on GitLab |
| Code Review | Automatic review on every PR |
| Slack | Turn bug reports into PRs from team chat |
| MCP servers | Connect Linear, Notion, Google Drive, custom APIs |

### Remote Access Options

| Method | Trigger | Runs on |
|:-------|:--------|:--------|
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | Drive from claude.ai/code or mobile | Your machine (CLI/VS Code) |
| Channels | Push events from Telegram, Discord, webhooks | Your machine (CLI) |
| Slack | Mention @Claude in a channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux/WSL) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force` and `Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | Remove `~/.claude`, `~/.claude.json`, `.claude/`, `.mcp.json` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- Product overview, installation entry points for all surfaces, feature highlights, and links to all integrations
- [Quickstart](references/claude-code-quickstart.md) -- Step-by-step walkthrough from installation through first code change, git operations, and common workflows
- [Advanced Setup](references/claude-code-setup.md) -- System requirements, platform-specific installation, Windows setup, Alpine/musl, version pinning, npm migration, binary integrity verification, and uninstallation
- [Authentication](references/claude-code-authentication.md) -- Login flow, team setup (Teams/Enterprise, Console, cloud providers), credential management, authentication precedence
- [How Claude Code Works](references/claude-code-how-it-works.md) -- Agentic loop architecture, models, built-in tools, session management, context window, checkpoints, permissions, and tips for working effectively
- [Platforms and Integrations](references/claude-code-platforms.md) -- Platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integrations (Chrome, GitHub Actions, GitLab, Slack, Code Review), and remote access options

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
