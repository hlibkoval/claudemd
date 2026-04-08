---
name: getting-started-doc
description: Complete getting-started documentation for Claude Code -- installation, setup, quickstart, authentication, architecture, and platform overview. Covers native installation (curl, Homebrew, WinGet), Windows setup (Git Bash, WSL, PowerShell tool), system requirements (OS, RAM, shell, location), verification (claude --version, claude doctor), authentication methods (Pro/Max subscription, Teams/Enterprise, Console, cloud providers), authentication precedence (cloud credentials > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth), credential storage (macOS Keychain, ~/.claude/.credentials.json), team setup (Teams, Enterprise, Console roles, SSO), update management (auto-updates, release channels latest/stable, autoUpdatesChannel, DISABLE_AUTOUPDATER, claude update), version pinning (specific version, stable channel install), npm-to-native migration, binary integrity verification (GPG manifest signatures, platform code signing), uninstallation (native, Homebrew, WinGet, npm, config cleanup), quickstart walkthrough (first session, codebase exploration, code changes, git operations, bug fixes, testing), essential CLI commands (claude, claude -p, claude -c, claude -r), the agentic loop (gather context, take action, verify results), built-in tool categories (file operations, search, execution, web, code intelligence), session management (resume, fork, context window, compaction, /context, /compact), execution environments (local, cloud, remote control), permission modes (default, auto-accept edits, plan mode, auto mode), checkpoints and undo (Esc twice, file snapshots), platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integrations (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack, MCP), remote access (Dispatch, Remote Control, Channels, scheduled tasks), and best practices for effective prompting (be specific, give verification targets, explore before implementing, delegate). Load when discussing Claude Code installation, setup, getting started, quickstart, first session, authentication, login, account types, subscription, system requirements, how Claude Code works, agentic loop, built-in tools, platforms, integrations, credential management, apiKeyHelper, auto-updates, release channels, uninstall, checkpoints, permission modes, session management, context window, or any getting-started topic for Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code -- from first install to productive daily use.

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
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ (requires Git for Windows) |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Location** | Anthropic supported countries |

### Verification

```bash
claude --version       # Check installed version
claude doctor          # Detailed installation and config check
```

### Authentication Methods

| Account type | Login method |
|:-------------|:-------------|
| Claude Pro / Max | Browser login with Claude.ai account |
| Claude for Teams / Enterprise | Browser login with team-invited Claude.ai account |
| Claude Console | Browser login with Console credentials (admin must invite first) |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK` + AWS credentials (no browser login) |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX` + GCP credentials (no browser login) |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY` + Azure credentials (no browser login) |

The free Claude.ai plan does not include Claude Code access.

### Authentication Precedence

When multiple credentials are present, Claude Code chooses in this order:

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` environment variable (Bearer header, for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` environment variable (X-Api-Key header, for direct API access)
4. `apiKeyHelper` script output (for dynamic/rotating credentials)
5. Subscription OAuth credentials from `/login` (default for Pro/Max/Team/Enterprise)

### Credential Storage

| Platform | Location |
|:---------|:---------|
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode 0600) |
| Windows | `~/.claude/.credentials.json` (inherits user profile ACLs) |

Override with `$CLAUDE_CONFIG_DIR`. The `apiKeyHelper` setting runs a script returning an API key (5-min refresh, or on 401).

### Console Team Setup (Roles)

| Role | Capabilities |
|:-----|:-------------|
| Claude Code | Can only create Claude Code API keys |
| Developer | Can create any kind of API key |

### Update Management

| Setting | Value | Effect |
|:--------|:------|:-------|
| `autoUpdatesChannel` | `"latest"` (default) | New features immediately |
| `autoUpdatesChannel` | `"stable"` | ~1 week delay, skips regressions |
| `DISABLE_AUTOUPDATER` | `"1"` (in settings `env`) | Disable auto-updates entirely |
| `claude update` | -- | Apply update immediately |

Install a specific channel: `curl -fsSL https://claude.ai/install.sh | bash -s stable`
Install a specific version: `curl -fsSL https://claude.ai/install.sh | bash -s 2.1.89`

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out and re-authenticate |
| `/model` | Switch model during session |
| `/init` | Create a CLAUDE.md for your project |
| `/doctor` | Diagnose installation issues |
| `/context` | See what is using context space |
| `/compact` | Manually trigger context compaction |
| `Ctrl+D` or `exit` | Exit Claude Code |

### The Agentic Loop

Claude Code works through three blended phases: **gather context** (search, read files), **take action** (edit code, run commands), and **verify results** (run tests, check output). The loop repeats until the task is complete, course-correcting along the way. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename, reorganize files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up errors |
| **Code intelligence** | Type errors/warnings, jump to definitions, find references (requires plugins) |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Auto-edits files, still asks for commands |
| Plan mode | Read-only tools only, creates a plan for approval |
| Auto mode | Background safety checks evaluate all actions (research preview) |

Specific commands can be pre-approved in `.claude/settings.json`.

### Session Management

| Action | Command |
|:-------|:--------|
| Resume latest session | `claude --continue` |
| Pick a session to resume | `claude --resume` |
| Fork a session (branch off) | `claude --continue --fork-session` |

Sessions are independent (no shared history). Persistent state uses CLAUDE.md and auto memory. Session data stored in `~/.claude/projects/`.

### Context Window Management

- Claude compacts automatically when context fills up
- Older tool outputs cleared first, then conversation summarized
- Put persistent rules in CLAUDE.md, not conversation history
- Use `/compact focus on X` to guide compaction
- Skills load on demand; subagents get their own context

### Execution Environments

| Environment | Where code runs | Use case |
|:------------|:---------------|:---------|
| Local | Your machine | Default, full file/tool access |
| Cloud | Anthropic-managed VMs | Offload tasks, remote repos |
| Remote Control | Your machine, controlled via browser | Web UI with local execution |

### Platform Comparison

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use (macOS) |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, Dispatch |
| VS Code | Editor-integrated coding | Inline diffs, integrated terminal |
| JetBrains | IntelliJ/PyCharm/WebStorm workflows | Diff viewer, selection sharing |
| Web | Long-running/offline tasks | Cloud execution, continues after disconnect |

All surfaces share the same engine, CLAUDE.md files, settings, and MCP servers.

### Integrations

| Integration | Purpose |
|:------------|:--------|
| Chrome | Control browser with logged-in sessions |
| GitHub Actions | CI pipeline automation (PR reviews, issue triage) |
| GitLab CI/CD | CI-driven automation on GitLab |
| Code Review | Automatic review on every PR |
| Slack | `@Claude` mentions turn bug reports into PRs |
| MCP servers | Connect to Linear, Notion, Google Drive, custom APIs |

### Remote Access Options

| Method | Trigger | Runs on |
|:-------|:--------|:--------|
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | Drive from claude.ai/code or mobile | Your machine (CLI/VS Code) |
| Channels | Push events from chat apps/webhooks | Your machine (CLI) |
| Slack | `@Claude` mention in team channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### Windows Setup Notes

- **Git Bash required**: Install Git for Windows, then run the install command
- **Custom Git Bash path**: Set `CLAUDE_CODE_GIT_BASH_PATH` in settings.json `env`
- **PowerShell tool**: Available as opt-in preview (see tools-reference)
- **WSL**: Both WSL 1 and WSL 2 supported; WSL 2 supports sandboxing

### Alpine Linux / musl Setup

```bash
apk add libgcc libstdc++ ripgrep
```

Then set `USE_BUILTIN_RIPGREP` to `"0"` in settings.json `env`.

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | `Remove-Item ~/.local/bin/claude.exe; Remove-Item ~/.local/share/claude -Recurse` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | Remove `~/.claude`, `~/.claude.json`, `.claude/`, `.mcp.json` |

### npm-to-Native Migration

```bash
curl -fsSL https://claude.ai/install.sh | bash   # Install native
npm uninstall -g @anthropic-ai/claude-code         # Remove npm version
```

### Binary Integrity Verification

Each release publishes a GPG-signed `manifest.json` with SHA256 checksums. Verify with:

```bash
# Import the public key
curl -fsSL https://downloads.claude.ai/keys/claude-code.asc | gpg --import
# Verify fingerprint: 31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE

# Download and verify manifest
gpg --verify manifest.json.sig manifest.json

# Check binary checksum
sha256sum claude   # Linux
shasum -a 256 claude   # macOS
```

Platform code signatures: macOS (Anthropic PBC, Apple notarized), Windows (Anthropic, PBC).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- Product overview, capabilities, installation entry points, and platform comparison
- [Quickstart](references/claude-code-quickstart.md) -- Step-by-step first session walkthrough: install, login, explore, edit, commit
- [Advanced Setup](references/claude-code-setup.md) -- System requirements, platform-specific installation, updates, version pinning, binary verification, and uninstallation
- [Authentication](references/claude-code-authentication.md) -- Login methods, team setup (Teams/Enterprise/Console/cloud providers), credential storage, and auth precedence
- [How Claude Code Works](references/claude-code-how-it-works.md) -- The agentic loop, built-in tools, session management, context window, permissions, and effective usage tips
- [Platforms and Integrations](references/claude-code-platforms.md) -- Platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integrations, and remote access options

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
