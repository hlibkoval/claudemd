---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, installation/setup, authentication, how the agentic loop works, and platform/integration options.
user-invocable: false
---

# Getting Started with Claude Code Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What is Claude Code?

Claude Code is an AI-powered agentic coding assistant available in the terminal, IDE extensions, desktop app, and browser. It reads your codebase, edits files, runs commands, and integrates with your development tools.

### Installation

| Method | Command |
| :----- | :------ |
| macOS / Linux / WSL (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Notes:
- Native installs auto-update in background. Homebrew and WinGet do **not** auto-update.
- Native Windows requires [Git for Windows](https://git-scm.com/downloads/win). WSL does not.
- Desktop app download: macOS or Windows from `https://claude.com/download`.

### System Requirements

| Item | Requirement |
| :--- | :---------- |
| OS | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |

### First Session

```bash
cd your-project
claude
# Prompted to log in on first use
```

Use `claude --version` to confirm install. Use `claude doctor` for a full health check.

### Update / Uninstall

| Action | Command |
| :----- | :------ |
| Manual update | `claude update` |
| Uninstall (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Uninstall Homebrew | `brew uninstall --cask claude-code` |
| Uninstall WinGet | `winget uninstall Anthropic.ClaudeCode` |
| Uninstall npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Remove config/settings | `rm -rf ~/.claude && rm ~/.claude.json` |

### Auto-Update Settings (settings.json)

| Key | Values | Effect |
| :-- | :----- | :----- |
| `autoUpdatesChannel` | `"latest"` (default), `"stable"` | Which release channel to follow |
| `minimumVersion` | e.g. `"2.1.100"` | Floor version; won't downgrade below this |
| `env.DISABLE_AUTOUPDATER` | `"1"` | Disable auto-updates entirely |

### Authentication

**Account types supported:**

| Type | Notes |
| :--- | :---- |
| Claude Pro / Max | Log in with claude.ai account |
| Claude for Teams / Enterprise | Log in with invited claude.ai account |
| Claude Console | API-based billing; invite required |
| Amazon Bedrock | Set cloud env vars; no browser login needed |
| Google Vertex AI | Set cloud env vars; no browser login needed |
| Microsoft Foundry | Set cloud env vars; no browser login needed |

**Authentication precedence** (highest to lowest):

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (bearer token for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` (direct Anthropic API)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`)
6. Subscription OAuth from `/login` (default for Pro/Max/Teams/Enterprise)

**Credential storage:** macOS Keychain (macOS); `~/.claude/.credentials.json` mode 0600 (Linux/Windows).

**Long-lived token for CI:**
```bash
claude setup-token
export CLAUDE_CODE_OAUTH_TOKEN=your-token
```

### Key CLI Commands

| Command | What it does |
| :------ | :----------- |
| `claude` | Start interactive session |
| `claude "task"` | Run one-time task |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/context` | Show context window usage |
| `/compact` | Manually compact context |
| `exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop

Claude works through three blended phases for every task:

1. **Gather context** — read files, search code, understand the project
2. **Take action** — edit files, run commands, use tools
3. **Verify results** — run tests, check outputs, course-correct

**Built-in tool categories:**

| Category | Capabilities |
| :------- | :----------- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search web, fetch documentation |
| Code intelligence | Type errors, jump-to-definition, find references (requires plugin) |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :------- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and runs common filesystem commands without asking |
| Plan mode | Read-only tools only; creates a plan for approval |
| Auto mode | Evaluates all actions with background safety checks (research preview) |

### Session Management

| Action | How |
| :----- | :-- |
| Resume last session | `claude --continue` or `claude -c` |
| Pick a session to resume | `claude --resume` or `claude -r` |
| Fork a session | `claude --continue --fork-session` |
| Undo file edits | Press Esc twice (checkpoint rewind) |

Sessions are saved locally as JSONL under `~/.claude/projects/`. Each new session starts with a fresh context window.

### Platform / Surface Comparison

| Platform | Best for | Notable features |
| :------- | :------- | :--------------- |
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal |
| JetBrains | IntelliJ/PyCharm/WebStorm | Diff viewer, selection sharing |
| Web | Long-running / offline tasks | Anthropic-managed cloud, continues after disconnect |
| Mobile | Starting and monitoring tasks remotely | Cloud sessions, Remote Control, Dispatch to Desktop |

### Integrations

| Integration | Use it for |
| :---------- | :--------- |
| Chrome | Browser automation with your logged-in sessions |
| GitHub Actions | Automated PR reviews, issue triage, CI pipelines |
| GitLab CI/CD | Same for GitLab |
| Code Review | Automatic review on every pull request |
| Slack | Turn `@Claude` mentions into pull requests |

### Remote / Away-from-Terminal Options

| Option | Trigger | Runs on |
| :----- | :------ | :------ |
| Dispatch | Message from mobile app | Your machine (Desktop) |
| Remote Control | Drive from browser or mobile | Your machine (CLI or VS Code) |
| Channels | Events from Telegram, Discord, webhooks | Your machine (CLI) |
| Slack | `@Claude` mention in channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### What Claude Can Access

When `claude` runs in a directory:

- Files in your project directory and subdirectories
- Terminal commands (anything you can run from the CLI)
- Git state (branch, uncommitted changes, recent history)
- `CLAUDE.md` — project-specific persistent instructions
- Auto memory (`MEMORY.md`) — learnings saved automatically across sessions
- Extensions: MCP servers, skills, subagents, Claude in Chrome

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — product overview, installation configurator, surfaces, capabilities, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step guide: install, log in, first session, first code change, Git usage, and essential commands
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific install, Windows/WSL setup, Alpine Linux, version management, binary verification, and uninstallation
- [Authentication](references/claude-code-authentication.md) — login flow, team setup (Teams/Enterprise/Console/cloud providers), credential storage, auth precedence, and long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, built-in tools, execution environments, session management, context window, checkpoints, and permission modes
- [Platforms and integrations](references/claude-code-platforms.md) — surface comparison (CLI/Desktop/VS Code/JetBrains/web/mobile), integrations (Chrome/GitHub/GitLab/Slack), and remote-access options

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
