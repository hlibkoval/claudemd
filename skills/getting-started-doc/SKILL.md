---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview, installation, quickstart walkthrough, authentication, how Claude Code works, and platform/integration options. Covers installation methods (native installer curl/irm/winget, Homebrew, npm migration), system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4GB RAM, Bash/Zsh/PowerShell/CMD), Windows setup (Git for Windows, WSL1/WSL2, PowerShell tool preview, CLAUDE_CODE_GIT_BASH_PATH), Alpine/musl dependencies (libgcc, libstdc++, ripgrep, USE_BUILTIN_RIPGREP=0), verification (claude --version, claude doctor), authentication (Pro/Max/Teams/Enterprise/Console login, cloud provider credentials, apiKeyHelper, ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, credential precedence and storage), auto-updates (autoUpdatesChannel latest/stable, DISABLE_AUTOUPDATER, claude update, release channels), uninstallation (native/Homebrew/WinGet/npm, config cleanup), quickstart workflow (install, login, first session, explore codebase, make edits, git operations, debugging, refactoring, testing), the agentic loop (gather context/take action/verify results, models, tools -- file ops/search/execution/web/code intelligence), sessions (resume/fork/context window, compaction, /compact, /context, checkpoints, permission modes), platforms and integrations (CLI, Desktop, VS Code, JetBrains, Web, Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack, Remote Control, Channels, Dispatch, scheduled tasks), essential CLI commands (claude, claude "task", claude -p, claude -c, claude -r, claude commit), and best practices (be specific, give verification targets, explore before implementing, delegate don't dictate). Load when discussing Claude Code installation, getting started, quickstart, first steps, setup, authentication, login, how Claude Code works, the agentic loop, platforms, integrations, system requirements, Windows setup, uninstallation, updating, release channels, session management, context window, checkpoints, permission modes, or introductory Claude Code topics.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- covering installation, authentication, the quickstart walkthrough, how Claude Code works under the hood, and the full range of platforms and integrations.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (recommended)** macOS/Linux/WSL | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native** Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native** Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **npm** (deprecated) | `npm install -g @anthropic-ai/claude-code` | No |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). npm requires Node.js 18+.

### System Requirements

| Component | Requirement |
|:----------|:------------|
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

Alpine/musl distributions additionally need `libgcc`, `libstdc++`, `ripgrep`, and `USE_BUILTIN_RIPGREP=0` in settings.

### Authentication Options

| Account type | How to authenticate |
|:-------------|:--------------------|
| **Pro / Max** | Browser login via `claude` command |
| **Teams / Enterprise** | Browser login with team-invited account |
| **Console** | Browser login with Console credentials (admin must invite first) |
| **Amazon Bedrock** | Set `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| **Google Vertex AI** | Set `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| **Microsoft Foundry** | Set `CLAUDE_CODE_USE_FOUNDRY=1` + Foundry credentials |

The free Claude.ai plan does not include Claude Code access.

### Authentication Precedence

When multiple credentials are present, Claude Code chooses in this order:

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` -- sent as `Authorization: Bearer` header (for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` -- sent as `X-Api-Key` header (for direct Anthropic API access)
4. `apiKeyHelper` script output (for dynamic/rotating credentials)
5. Subscription OAuth credentials from `/login` (default for Pro/Max/Team/Enterprise)

### Credential Storage

| Platform | Location |
|:---------|:---------|
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode `0600`) |
| Windows | `~/.claude/.credentials.json` (inherits user profile ACLs) |

Custom location: set `$CLAUDE_CONFIG_DIR`. Refresh with `apiKeyHelper` (called after 5 min or on 401; tune with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`).

### Team Setup Options

| Option | Best for | Setup |
|:-------|:---------|:------|
| **Claude for Teams** | Smaller teams, self-service | Subscribe, invite members, members install and login |
| **Claude for Enterprise** | Large orgs (SSO, compliance, managed settings) | Contact sales, configure SSO, invite members |
| **Console** | API-based billing | Invite users with Claude Code or Developer role |
| **Cloud providers** | AWS/GCP/Azure-native orgs | Distribute env vars and credential instructions |

### Update and Release Channels

| Setting | Value | Behavior |
|:--------|:------|:---------|
| `autoUpdatesChannel` | `"latest"` (default) | New features as soon as released |
| `autoUpdatesChannel` | `"stable"` | ~1 week delay, skips releases with regressions |
| `DISABLE_AUTOUPDATER` | `"1"` (in `env`) | Disables background auto-updates |

Manual update: `claude update`. Install specific version: pass version number or channel to installer script.

### Essential CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Print mode -- run query then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a git commit |
| `claude --version` | Show installed version |
| `claude doctor` | Diagnose installation and configuration |
| `claude update` | Apply update immediately |
| `/login` | Log in or switch accounts |
| `/logout` | Log out and re-authenticate |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/init` | Create a CLAUDE.md for your project |
| `/model` | Switch models mid-session |
| `/context` | Show context window usage |
| `/compact` | Compact conversation (optional focus) |

### The Agentic Loop

Claude Code works through three blended phases:

1. **Gather context** -- search files, read code, understand the codebase
2. **Take action** -- edit files, run commands, write code
3. **Verify results** -- run tests, check output, confirm the fix

These repeat until the task is complete. You can interrupt at any point to steer Claude in a different direction.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up errors |
| **Code intelligence** | Type errors, jump to definitions, find references (via plugins) |

### Session Management

| Action | Command |
|:-------|:--------|
| Resume last conversation | `claude --continue` or `claude -c` |
| Resume specific conversation | `claude --resume` or `claude -r` |
| Fork a conversation | `claude --continue --fork-session` |
| Check context usage | `/context` |
| Compact conversation | `/compact [focus]` |

Sessions are independent -- each new session starts fresh. Persistent instructions belong in CLAUDE.md. Auto memory saves learnings across sessions automatically.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits without asking, still asks for commands |
| **Plan mode** | Read-only tools only, produces a plan for approval |
| **Auto mode** | Evaluates all actions with background safety checks (research preview) |

Checkpoints: every file edit is reversible -- press `Esc` twice to rewind.

### Platforms

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| **CLI** | Terminal workflows, scripting, servers | Full feature set, Agent SDK, third-party providers |
| **Desktop** | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| **VS Code** | Working inside VS Code | Inline diffs, integrated terminal, file context |
| **JetBrains** | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| **Web** | Long-running/offline tasks | Anthropic-managed cloud, runs after disconnect |

Configuration, project memory, and MCP servers are shared across local surfaces.

### Integrations

| Integration | Purpose |
|:------------|:--------|
| **Chrome** | Control your browser for testing web apps |
| **GitHub Actions** | Automated PR reviews, issue triage in CI |
| **GitLab CI/CD** | CI-driven automation on GitLab |
| **Code Review** | Automatic review on every pull request |
| **Slack** | Respond to @Claude mentions in team channels |
| **Remote Control** | Drive a running session from phone/browser |
| **Channels** | Push events from Telegram, Discord, webhooks |
| **Dispatch** | Message a task from mobile, spawns Desktop session |
| **Scheduled tasks** | Run prompts on a recurring schedule (CLI, Desktop, or cloud) |

### Uninstallation

| Method | Command |
|:-------|:--------|
| **Native** macOS/Linux | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| **Native** Windows | `Remove-Item ~/.local/bin/claude.exe -Force; Remove-Item ~/.local/share/claude -Recurse -Force` |
| **Homebrew** | `brew uninstall --cask claude-code` |
| **WinGet** | `winget uninstall Anthropic.ClaudeCode` |
| **npm** | `npm uninstall -g @anthropic-ai/claude-code` |

Remove config: delete `~/.claude`, `~/.claude.json`, and project-level `.claude`/`.mcp.json`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- Product overview, installation options across all surfaces (Terminal, VS Code, Desktop, Web, JetBrains), key capabilities (automating tedious tasks, building features, fixing bugs, git operations, MCP integrations, custom instructions/skills/hooks, agent teams, CLI scripting, scheduled tasks, multi-device workflows), platform comparison table (Remote Control, Channels, scheduled tasks, GitHub Actions, GitLab CI/CD, Code Review, Slack, Chrome, Agent SDK), and next steps
- [Quickstart](references/claude-code-quickstart.md) -- Step-by-step first session walkthrough: prerequisites, installation, login (Pro/Max/Teams/Enterprise/Console/cloud providers), starting a session, exploring a codebase, making code changes, git operations, debugging, feature implementation, refactoring, testing, documentation updates, essential CLI commands table, and beginner tips
- [Advanced Setup](references/claude-code-setup.md) -- System requirements, platform-specific installation (Windows with Git Bash or WSL, Alpine/musl dependencies), verification (claude --version, claude doctor), authentication overview, auto-updates (release channels latest/stable, DISABLE_AUTOUPDATER, manual update), advanced installation (specific version pinning, npm-to-native migration, binary integrity and code signing), and uninstallation for all methods including config cleanup
- [Authentication](references/claude-code-authentication.md) -- Login flow (browser prompts, fallback URL copy), account types (Pro/Max/Teams/Enterprise/Console/cloud providers), team setup for Teams/Enterprise/Console/cloud providers, credential management (storage locations per platform, apiKeyHelper with TTL, slow helper warning), authentication precedence (cloud provider > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth), and web credential behavior
- [How Claude Code Works](references/claude-code-how-it-works.md) -- The agentic loop (gather context, take action, verify results), models (Sonnet vs Opus, /model switching), tools (file operations, search, execution, web, code intelligence), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local, cloud, Remote Control), interfaces, sessions (resume, fork, context window, compaction, /compact focus, /context, skills on-demand loading, subagent isolation), checkpoints (file edit snapshots, Esc to rewind), permission modes (default, auto-accept edits, plan mode, auto mode), and tips for working effectively (be specific, give verification targets, explore before implementing, delegate don't dictate)
- [Platforms and Integrations](references/claude-code-platforms.md) -- Platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integration overview (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack), remote/away-from-terminal options (Dispatch, Remote Control, Channels, Slack, scheduled tasks), and links to all platform and integration guides

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
