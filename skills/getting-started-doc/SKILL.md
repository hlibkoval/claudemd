---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview, installation, quickstart walkthrough, advanced setup, authentication, how the agentic loop works, and platform comparisons. Covers installation methods (native installer, Homebrew, WinGet, npm), install commands for macOS/Linux/WSL/Windows PowerShell/Windows CMD, system requirements (OS, RAM, network, shell), Windows setup (Git Bash, WSL, PowerShell tool), Alpine/musl dependencies, verifying installation (claude --version, claude doctor), authentication methods (Pro/Max/Teams/Enterprise, Console, Bedrock/Vertex/Foundry), authentication precedence (cloud provider > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth), credential storage (macOS Keychain, Linux/Windows credentials.json), team setup (Teams/Enterprise, Console roles, cloud providers), quickstart steps (install, login, first session, explore codebase, make changes, git operations, fix bugs, write tests), essential CLI commands (claude, claude "task", claude -p, claude -c, claude -r, /clear, /help), the agentic loop (gather context, take action, verify results), built-in tool categories (file operations, search, execution, web, code intelligence), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), sessions (independent context, resume with --continue, fork with --fork-session, context window management, compaction, /context), safety mechanisms (checkpoints for undo, permission modes via Shift+Tab -- default/auto-accept edits/plan mode/auto mode), working effectively (be specific, give verification targets, explore before implementing, delegate don't dictate), update methods (auto-update, release channels latest/stable, autoUpdatesChannel setting, DISABLE_AUTOUPDATER, claude update, brew upgrade, winget upgrade), binary integrity (manifest.json with SHA256 checksums, GPG signature verification, platform code signing), uninstallation (native rm, Homebrew, WinGet, npm, config cleanup), platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integrations (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack), remote work options (Dispatch, Remote Control, Channels, Scheduled tasks). Load when discussing Claude Code installation, setup, getting started, quickstart, authentication, login, how Claude Code works, agentic loop, tool categories, sessions, checkpoints, permission modes, platforms, updating Claude Code, uninstalling Claude Code, system requirements, Windows setup, credential management, apiKeyHelper, or any getting-started topic for Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- installation, authentication, first-session walkthrough, core architecture, and platform options.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (macOS/Linux/WSL)** | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native (Windows PowerShell)** | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native (Windows CMD)** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **npm (deprecated)** | `npm install -g @anthropic-ai/claude-code` | No |

After installing, run `claude` in any project directory to start.

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **OS** | macOS 13.0+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Windows** | Git for Windows required |
| **Location** | Anthropic supported countries |

### Authentication Methods

| Account type | How to log in |
|:-------------|:-------------|
| **Claude Pro / Max** | Run `claude`, follow browser prompts |
| **Claude Teams / Enterprise** | Run `claude`, log in with team account |
| **Claude Console** | Run `claude`, log in with Console credentials (admin must invite first) |
| **Amazon Bedrock** | Set `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| **Google Vertex AI** | Set `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| **Microsoft Foundry** | Set `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Authentication Precedence

When multiple credentials are present, Claude Code uses them in this order:

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (Bearer token for LLM gateways)
3. `ANTHROPIC_API_KEY` env var (API key from Console)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. Subscription OAuth credentials from `/login`

### Credential Storage

| Platform | Location |
|:---------|:---------|
| **macOS** | Encrypted macOS Keychain |
| **Linux** | `~/.claude/.credentials.json` (mode `0600`) |
| **Windows** | `~/.claude/.credentials.json` (user profile ACLs) |

Override with `$CLAUDE_CONFIG_DIR`. Custom credential scripts via `apiKeyHelper` setting (refreshes after 5 min or on HTTP 401).

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run query non-interactively, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --continue --fork-session` | Fork a session (new ID, shared history) |
| `claude --model <name>` | Start with a specific model |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/model` | Switch model during a session |
| `/context` | Show context window usage |
| `/compact` | Manually compact context |
| `/init` | Create a CLAUDE.md for your project |
| `/doctor` | Diagnose installation issues |

### The Agentic Loop

Claude Code works through three blended phases:

1. **Gather context** -- search files, read code, understand the problem
2. **Take action** -- edit files, run commands, make changes
3. **Verify results** -- run tests, check output, confirm the fix

The loop repeats until the task is complete. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch docs, look up errors |
| **Code intelligence** | Type errors/warnings, jump to definitions, find references (requires plugins) |

### What Claude Can Access

When you run `claude` in a directory, it has access to:

- **Project files** in your directory and subdirectories
- **Terminal commands** (build tools, git, package managers, scripts)
- **Git state** (branch, uncommitted changes, recent history)
- **CLAUDE.md** (project instructions and conventions)
- **Auto memory** (learnings saved across sessions, first 200 lines or 25KB of MEMORY.md)
- **Extensions** (MCP servers, skills, subagents, Chrome)

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files freely, asks for commands |
| **Plan mode** | Read-only tools only, creates a plan for approval |
| **Auto mode** | Evaluates all actions with background safety checks (research preview) |

### Sessions

- Each session has an independent context window (no history from previous sessions)
- Claude persists learnings across sessions via auto memory
- `claude --continue` resumes the last session; `claude --resume` lets you pick one
- `--fork-session` branches off without affecting the original
- Checkpoints snapshot files before every edit; press `Esc` twice to rewind
- Run `/context` to see what is using space in the context window

### Update and Release Channels

| Channel | Behavior |
|:--------|:---------|
| `"latest"` (default) | New features as soon as released |
| `"stable"` | Version ~1 week old, skipping regressions |

Configure via `/config` or in settings.json:

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

Manual update: `claude update`

### Platform Comparison

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| **CLI** | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use (macOS), third-party providers |
| **Desktop** | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| **VS Code** | Working inside VS Code | Inline diffs, integrated terminal, file context |
| **JetBrains** | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| **Web** | Long-running tasks, offline work | Anthropic-managed cloud, continues after disconnect |

Configuration, project memory, and MCP servers are shared across local surfaces.

### Integrations

| Integration | Use case |
|:------------|:---------|
| **Chrome** | Test web apps, automate browser tasks |
| **GitHub Actions** | Automated PR reviews, issue triage |
| **GitLab CI/CD** | CI-driven automation on GitLab |
| **Code Review** | Automatic review on every PR |
| **Slack** | Bug reports to PRs from team chat |

### Remote Work Options

| Option | Trigger | Runs on |
|:-------|:--------|:--------|
| **Dispatch** | Message from Claude mobile app | Your machine (Desktop) |
| **Remote Control** | Drive from claude.ai/code or mobile | Your machine (CLI/VS Code) |
| **Channels** | Push events from Telegram, Discord, etc. | Your machine (CLI) |
| **Slack** | Mention @Claude in a channel | Anthropic cloud |
| **Scheduled tasks** | Set a schedule | CLI, Desktop, or cloud |

### Windows Setup

| Option | Details |
|:-------|:--------|
| **Native + Git Bash** | Install Git for Windows, then run install command. Set `CLAUDE_CODE_GIT_BASH_PATH` if needed |
| **WSL** | Both WSL 1 and WSL 2 supported. WSL 2 supports sandboxing |
| **PowerShell tool** | Opt-in preview for native PowerShell |

### Uninstall

| Method | Command |
|:-------|:--------|
| **Native (macOS/Linux)** | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| **Homebrew** | `brew uninstall --cask claude-code` |
| **WinGet** | `winget uninstall Anthropic.ClaudeCode` |
| **npm** | `npm uninstall -g @anthropic-ai/claude-code` |
| **Config cleanup** | `rm -rf ~/.claude && rm ~/.claude.json` (also `.claude/` and `.mcp.json` per project) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- Product overview, feature highlights, available surfaces, and next steps
- [Quickstart](references/claude-code-quickstart.md) -- Step-by-step first session walkthrough from install to making changes
- [Advanced Setup](references/claude-code-setup.md) -- System requirements, platform-specific installation, updates, release channels, binary verification, and uninstallation
- [Authentication](references/claude-code-authentication.md) -- Login methods, team setup, credential management, and authentication precedence
- [How Claude Code Works](references/claude-code-how-it-works.md) -- Agentic loop architecture, built-in tools, sessions, context window, checkpoints, and permission modes
- [Platforms and Integrations](references/claude-code-platforms.md) -- Platform comparison, integration catalog, and remote work options

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
