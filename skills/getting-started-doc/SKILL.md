---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- covering the overview (what Claude Code can do, available surfaces and integrations), quickstart (step-by-step first session walkthrough, installation, login, first question, first code change, git operations, essential CLI commands, pro tips), advanced setup (system requirements by OS, installation methods including native/Homebrew/WinGet/npm, Windows setup with Git Bash and WSL, Alpine/musl dependencies, verification with claude doctor, auto-updates with latest/stable channels, DISABLE_AUTOUPDATER, specific version pinning, npm migration, binary integrity with GPG-signed manifests, platform code signatures, uninstallation by method, configuration file removal), authentication (login flow, account types including Pro/Max/Teams/Enterprise/Console/cloud providers, team setup for Teams/Enterprise/Console/Bedrock/Vertex/Foundry, credential management with macOS Keychain and Linux/Windows file storage, apiKeyHelper with TTL and slow-helper notice, authentication precedence order for cloud providers/ANTHROPIC_AUTH_TOKEN/ANTHROPIC_API_KEY/apiKeyHelper/OAuth), how Claude Code works (agentic loop with gather-context/take-action/verify-results phases, models with Sonnet/Opus and /model switching, tool categories for file-ops/search/execution/web/code-intelligence, what Claude can access including project files/terminal/git/CLAUDE.md/auto-memory/extensions, execution environments for local/cloud/remote-control, sessions with checkpoints/resume/fork/context-window, context management with compaction and /context and /compact, permission modes with Shift+Tab cycling through default/auto-accept-edits/plan/auto, tips for working effectively), and platforms and integrations (CLI/Desktop/VS Code/JetBrains/Web comparison, tool integrations for Chrome/GitHub Actions/GitLab CI-CD/Code Review/Slack, remote work options for Dispatch/Remote Control/Channels/Slack/scheduled tasks). Load when discussing Claude Code overview, getting started, installation, setup, quickstart, first session, authentication, login, account types, team setup, credential management, apiKeyHelper, how Claude Code works, agentic loop, tools, context window, sessions, checkpoints, permission modes, platforms comparison, or choosing where to run Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, configuring, and getting started with Claude Code across all platforms.

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
| **Windows** | 10 1809+ or Server 2019+ (requires Git for Windows or WSL) |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

Alpine/musl-based distros additionally require `libgcc`, `libstdc++`, `ripgrep`, and `USE_BUILTIN_RIPGREP=0`.

### Account Types

| Account | How to get it |
|:--------|:-------------|
| Claude Pro or Max | Subscribe at claude.com/pricing |
| Claude for Teams or Enterprise | Admin invites team members |
| Claude Console | Admin invites with Claude Code or Developer role |
| Amazon Bedrock | Set env vars, no browser login needed |
| Google Vertex AI | Set env vars, no browser login needed |
| Microsoft Foundry | Set env vars, no browser login needed |

### Authentication Precedence

When multiple credentials are present, Claude Code chooses in this order:

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` environment variable (sent as `Authorization: Bearer` header)
3. `ANTHROPIC_API_KEY` environment variable (sent as `X-Api-Key` header)
4. `apiKeyHelper` script output (for dynamic/rotating credentials)
5. Subscription OAuth credentials from `/login`

### Credential Storage

| Platform | Location |
|:---------|:---------|
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode 0600) |
| Windows | `~/.claude/.credentials.json` (inherits user profile ACLs) |
| Custom | Set `$CLAUDE_CONFIG_DIR` to override |

`apiKeyHelper` is called after 5 minutes or on HTTP 401. Customize refresh with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`. Applies to terminal CLI only -- Desktop and remote sessions use OAuth exclusively.

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Show installed version |
| `claude doctor` | Diagnose installation and config |
| `claude update` | Apply update immediately |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Log in or switch accounts |
| `/logout` | Log out and re-authenticate |
| `/model` | Switch model during a session |
| `/context` | Show what is using context space |
| `/compact` | Manually compact context (optional focus) |

### The Agentic Loop

Claude Code works through three phases that blend together:

1. **Gather context** -- search files, read code, understand the codebase
2. **Take action** -- edit files, run commands, create new files
3. **Verify results** -- run tests, check output, validate changes

Claude chains dozens of actions, course-correcting along the way. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | What Claude can do |
|:---------|:-------------------|
| **File operations** | Read, edit, create, rename, reorganize files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch docs, look up errors |
| **Code intelligence** | See type errors, jump to definitions, find references (requires plugin) |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|:-----|:---------|
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files without asking, still asks for commands |
| **Plan mode** | Read-only tools only, creates a plan for approval |
| **Auto mode** | Evaluates all actions with background safety checks (research preview) |

### Sessions

| Feature | Details |
|:--------|:--------|
| **Continue** | `claude --continue` or `claude -c` -- picks up where you left off |
| **Resume** | `claude --resume` or `claude -r` -- browse and select a previous session |
| **Fork** | `claude --continue --fork-session` -- branch off without affecting original |
| **Checkpoints** | Every file edit is snapshoted; press `Esc` twice to rewind |
| **Context window** | Run `/context` to see usage; `/compact` to reclaim space |

Sessions are independent -- each new session starts fresh. Use CLAUDE.md for persistent instructions and auto memory for cross-session learnings.

### Update Channels

| Channel | Setting value | Behavior |
|:--------|:-------------|:---------|
| Latest (default) | `"latest"` | New features as soon as released |
| Stable | `"stable"` | ~1 week delay, skips releases with major regressions |

Configure via `/config` or in settings.json: `{ "autoUpdatesChannel": "stable" }`. Disable auto-updates entirely with `{ "env": { "DISABLE_AUTOUPDATER": "1" } }`.

### Platforms Comparison

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use, third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| Web | Long-running tasks, offline work | Anthropic-managed cloud, continues after disconnect |

### Integrations

| Integration | What it does |
|:------------|:-------------|
| Chrome | Controls your browser for testing web apps |
| GitHub Actions | Claude in CI for PR reviews, issue triage |
| GitLab CI/CD | Same as GitHub Actions for GitLab |
| Code Review | Automatic review on every PR |
| Slack | Responds to @Claude mentions in channels |

### Remote Work Options

| Method | Trigger | Runs on |
|:-------|:--------|:--------|
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | Drive from claude.ai/code or mobile | Your machine (CLI/VS Code) |
| Channels | Push events from Telegram, Discord, etc. | Your machine (CLI) |
| Slack | @Claude mention in team channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux/WSL) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force` + `Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config files | Remove `~/.claude`, `~/.claude.json`, `.claude/`, `.mcp.json` |

### Binary Integrity Verification

Each release publishes a `manifest.json` with SHA256 checksums, signed with Anthropic's GPG key (fingerprint: `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`). Available for releases from v2.1.89 onward. macOS binaries are signed by "Anthropic PBC" and notarized by Apple. Windows binaries are signed by "Anthropic, PBC".

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- What Claude Code can do, available surfaces (Terminal, VS Code, Desktop, Web, JetBrains), capabilities (automate tasks, build features, create commits/PRs, MCP connections, custom instructions/skills/hooks, agent teams, CLI scripting, scheduled tasks, remote work), integration table for all platforms
- [Quickstart](references/claude-code-quickstart.md) -- Step-by-step first session walkthrough: install, log in, start a session, ask questions, make code changes, use Git, fix bugs, essential commands table, pro tips for beginners
- [Advanced Setup](references/claude-code-setup.md) -- System requirements, platform-specific installation (native/Homebrew/WinGet/npm), Windows setup (Git Bash, WSL, PowerShell tool), Alpine/musl dependencies, verification (claude --version, claude doctor), auto-updates (latest/stable channels, DISABLE_AUTOUPDATER), specific version pinning, npm migration, binary integrity with GPG-signed manifests, platform code signatures, uninstallation by method, configuration file removal
- [Authentication](references/claude-code-authentication.md) -- Login flow, account types (Pro/Max/Teams/Enterprise/Console/cloud providers), team setup for all account types, credential management (storage locations, apiKeyHelper with TTL, authentication precedence order), Console authentication with role assignment
- [How Claude Code Works](references/claude-code-how-it-works.md) -- Agentic loop (gather context, take action, verify results), models (Sonnet/Opus, /model switching), tool categories (file ops, search, execution, web, code intelligence), what Claude can access, execution environments (local/cloud/remote control), sessions (resume/fork, context window, compaction), checkpoints, permission modes (default/auto-accept/plan/auto), tips for working effectively
- [Platforms and Integrations](references/claude-code-platforms.md) -- Platform comparison (CLI/Desktop/VS Code/JetBrains/Web), tool integrations (Chrome/GitHub Actions/GitLab CI-CD/Code Review/Slack), remote work options (Dispatch/Remote Control/Channels/Slack/scheduled tasks)

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
