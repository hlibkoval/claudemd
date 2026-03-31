---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview, installation, quickstart walkthrough, authentication, how Claude Code works, and platform comparison. Covers installation methods (native installer curl/PowerShell/CMD, Homebrew brew install --cask claude-code, WinGet winget install Anthropic.ClaudeCode, deprecated npm), system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4GB RAM, Bash/Zsh/PowerShell/CMD), Windows setup (Git for Windows requirement, Git Bash, WSL 1/2, CLAUDE_CODE_GIT_BASH_PATH, PowerShell tool preview), Alpine/musl setup (libgcc, libstdc++, ripgrep, USE_BUILTIN_RIPGREP), verification (claude --version, claude doctor), authentication (Pro/Max/Teams/Enterprise/Console login, cloud providers Bedrock/Vertex/Foundry, credential storage macOS Keychain vs ~/.claude/.credentials.json, apiKeyHelper, ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, authentication precedence), updates (auto-updates, release channels latest/stable, autoUpdatesChannel setting, DISABLE_AUTOUPDATER, claude update, Homebrew/WinGet manual updates), uninstallation (native/Homebrew/WinGet/npm, config cleanup), team setup (Teams/Enterprise with SSO and central billing, Console with Claude Code/Developer roles, cloud provider distribution), the agentic loop (gather context/take action/verify results, interrupt and steer), models (Sonnet for most tasks, Opus for complex reasoning, /model to switch), tools (file operations, search, execution, web, code intelligence), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), environments (local, cloud, Remote Control), sessions (independent sessions, context window, /context, compaction, /compact, skills load on demand, subagents for isolation), checkpoints (Esc+Esc to rewind, file snapshots), permission modes (Default, Auto-accept edits, Plan mode, Auto mode, Shift+Tab to cycle), effective usage tips (conversational interaction, interrupt and steer, be specific upfront, provide verification, explore before implementing, delegate don't dictate), platform comparison (CLI full features/scripting/Agent SDK, Desktop visual review/parallel sessions/Dispatch, VS Code inline diffs/integrated terminal, JetBrains diff viewer/selection sharing, Web long-running/cloud/offline), integrations (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack), remote work options (Dispatch, Remote Control, Channels, Slack, scheduled tasks), surfaces overview (Terminal, VS Code, JetBrains, Desktop, Web), and next steps. Load when discussing Claude Code installation, getting started, setup, quickstart, authentication, login, how Claude Code works, agentic loop, platform comparison, which surface to use, system requirements, Windows setup, uninstalling Claude Code, updating Claude Code, release channels, team authentication, Console setup, credential management, apiKeyHelper, permission modes, checkpoints, or any introductory or onboarding topic for Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- covering the product overview, installation and setup, quickstart walkthrough, authentication, how the agentic loop works, and platform comparison.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (recommended)** | macOS/Linux/WSL: `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native** | Windows PS: `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native** | Windows CMD: `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **npm (deprecated)** | `npm install -g @anthropic-ai/claude-code` | No |

Then start: `cd your-project && claude`

### System Requirements

| Requirement | Detail |
|:------------|:-------|
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ (requires Git for Windows or WSL) |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Network** | Internet connection required |
| **Location** | Anthropic supported countries |
| **Additional** | ripgrep (usually bundled) |

### Windows Setup

| Option | Detail |
|:-------|:-------|
| **Git Bash (default)** | Install Git for Windows, then run the install command from PowerShell or CMD |
| **Custom Git Bash path** | Set `CLAUDE_CODE_GIT_BASH_PATH` in settings.json `env` |
| **PowerShell tool** | Opt-in preview for native PowerShell execution |
| **WSL** | Both WSL 1 and WSL 2 supported; WSL 2 supports sandboxing |

### Alpine / musl Setup

Install `libgcc`, `libstdc++`, `ripgrep` via the package manager, then set `USE_BUILTIN_RIPGREP=0` in settings.json `env`.

### Verification

```
claude --version     # Check installed version
claude doctor        # Detailed installation and config check
```

### Authentication

| Account type | How to authenticate |
|:-------------|:--------------------|
| **Pro / Max** | Browser login (run `claude`, follow prompts) |
| **Teams / Enterprise** | Browser login with team-invited Claude.ai account |
| **Console** | Browser login with Console credentials (admin must invite first) |
| **Bedrock / Vertex / Foundry** | Set environment variables before running `claude`; no browser login |

Log out with `/logout`. Check active method with `/status`.

### Authentication Precedence

When multiple credentials are present, Claude Code chooses in this order:

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (Bearer token, for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` env var (X-Api-Key header, for direct API access)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. Subscription OAuth from `/login` (default for Pro/Max/Teams/Enterprise)

### Credential Storage

| Platform | Location |
|:---------|:---------|
| **macOS** | Encrypted macOS Keychain |
| **Linux / Windows** | `~/.claude/.credentials.json` (or `$CLAUDE_CONFIG_DIR`); mode `0600` on Linux |

`apiKeyHelper` setting runs a shell script to return an API key. Refresh after 5 min or on HTTP 401. Set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for custom interval.

### Team Setup Options

| Option | Best for |
|:-------|:---------|
| **Claude for Teams** | Smaller teams; self-service, collaboration features, admin tools |
| **Claude for Enterprise** | Larger orgs; SSO, domain capture, role-based permissions, compliance API, managed policy |
| **Console** | API-based billing; invite users with Claude Code or Developer role |
| **Cloud providers** | Bedrock, Vertex, Foundry; distribute env vars and credential instructions |

### Updates and Release Channels

| Setting | Detail |
|:--------|:-------|
| **Auto-updates** | Native installs check on startup and periodically; download in background |
| **`autoUpdatesChannel`** | `"latest"` (default, immediate) or `"stable"` (approximately one week delay) |
| **Disable auto-updates** | `DISABLE_AUTOUPDATER=1` in settings.json `env` |
| **Manual update** | `claude update` |
| **Homebrew** | `brew upgrade claude-code` (run `brew cleanup claude-code` to reclaim space) |
| **WinGet** | `winget upgrade Anthropic.ClaudeCode` |

### Install Specific Version

Pass a version number or channel to the native installer:

- Latest (default): `curl -fsSL https://claude.ai/install.sh \| bash`
- Stable: `curl -fsSL https://claude.ai/install.sh \| bash -s stable`
- Pinned: `curl -fsSL https://claude.ai/install.sh \| bash -s 1.0.58`

### Uninstallation

| Method | Command |
|:-------|:--------|
| **Native (macOS/Linux)** | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| **Native (Windows PS)** | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force; Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| **Homebrew** | `brew uninstall --cask claude-code` |
| **WinGet** | `winget uninstall Anthropic.ClaudeCode` |
| **npm** | `npm uninstall -g @anthropic-ai/claude-code` |
| **Config cleanup** | Remove `~/.claude`, `~/.claude.json`, and project `.claude/`, `.mcp.json` |

### The Agentic Loop

Claude Code works through three blended phases:

1. **Gather context** -- search files, read code, understand the codebase
2. **Take action** -- edit files, run commands, create branches
3. **Verify results** -- run tests, check output, compare against expectations

The loop repeats until the task is complete. You can interrupt at any point to steer.

### Models

| Model | Best for |
|:------|:---------|
| **Sonnet** | Most coding tasks; good balance of speed and quality |
| **Opus** | Complex architectural decisions and deeper reasoning |

Switch with `/model` during a session or `claude --model <name>` at start.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename, reorganize files |
| **Search** | Find files by pattern, search content with regex, explore codebases |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up error messages |
| **Code intelligence** | Type errors, warnings, jump to definitions, find references (requires code intelligence plugins) |

### What Claude Can Access

When you run `claude` in a directory, it gains access to:

- **Project files** in your directory and subdirectories (plus others with permission)
- **Terminal** -- any command you could run
- **Git state** -- current branch, uncommitted changes, recent history
- **CLAUDE.md** -- project-specific instructions
- **Auto memory** -- learnings Claude saves automatically (first 200 lines or 25KB)
- **Extensions** -- MCP servers, skills, subagents, Chrome integration

### Execution Environments

| Environment | Where code runs | Use case |
|:------------|:----------------|:---------|
| **Local** | Your machine | Default; full access to files, tools, environment |
| **Cloud** | Anthropic-managed VMs | Offload tasks, work on repos not available locally |
| **Remote Control** | Your machine, browser UI | Use the web interface while keeping everything local |

### Sessions

- Each session is independent with a fresh context window
- Resume with `claude --continue` or `claude --resume`
- Fork with `claude --continue --fork-session`
- Persistent learnings via auto memory and CLAUDE.md
- Run `/context` to check context usage
- `/compact` to selectively summarize and free context

### Permission Modes

| Mode | Behavior | Toggle |
|:-----|:---------|:-------|
| **Default** | Asks before file edits and shell commands | -- |
| **Auto-accept edits** | Edits files freely, asks for commands | `Shift+Tab` |
| **Plan mode** | Read-only tools, creates a plan for approval | `Shift+Tab` x2 |
| **Auto mode** | Evaluates all actions with safety checks (preview) | `Shift+Tab` x3 |

Allow specific commands in `.claude/settings.json` to skip per-command approval.

### Checkpoints

Before every file edit, Claude snapshots the current contents. Press `Esc` twice to rewind to a previous state. Checkpoints are local to the session and separate from git. Actions with external side effects (databases, APIs, deployments) cannot be checkpointed.

### Working Effectively Tips

| Tip | Detail |
|:----|:-------|
| **Conversational** | Start with what you want, then refine through dialogue |
| **Interrupt** | Type your correction and press Enter at any time to redirect |
| **Be specific** | Reference files, mention constraints, point to patterns |
| **Give verification** | Include test cases, expected outputs, or screenshots |
| **Explore first** | Use Plan Mode to analyze before coding complex changes |
| **Delegate** | Give context and direction; let Claude figure out the details |

### Platform Comparison

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| **CLI** | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use, third-party providers |
| **Desktop** | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| **VS Code** | Working inside VS Code | Inline diffs, integrated terminal, file context |
| **JetBrains** | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| **Web** | Long-running tasks, offline work | Cloud VMs, continues after disconnect |

Configuration, project memory, and MCP servers are shared across local surfaces.

### Integrations

| Integration | Use for |
|:------------|:--------|
| **Chrome** | Testing web apps, filling forms, automating sites without an API |
| **GitHub Actions** | Automated PR reviews, issue triage, scheduled maintenance |
| **GitLab CI/CD** | CI-driven automation on GitLab |
| **Code Review** | Automatic review on every PR |
| **Slack** | Turn bug reports into PRs from team chat |
| **MCP servers** | Connect Linear, Notion, Google Drive, internal APIs |

### Remote Work Options

| Option | Trigger | Runs on |
|:-------|:--------|:--------|
| **Dispatch** | Message from Claude mobile app | Your machine (Desktop) |
| **Remote Control** | Drive session from claude.ai/code or mobile | Your machine (CLI/VS Code) |
| **Channels** | Push events from Telegram, Discord, webhooks | Your machine (CLI) |
| **Slack** | Mention @Claude in a channel | Anthropic cloud |
| **Scheduled tasks** | Cron schedule | CLI, Desktop, or cloud |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) -- Product overview, installation entry points for all surfaces (Terminal, VS Code, Desktop, Web, JetBrains), capabilities summary (automate tasks, build features, git workflows, MCP connections, customization, agent teams, CLI scripting, scheduled tasks, work from anywhere), platform matrix, and next steps
- [Quickstart](references/claude-code-quickstart.md) -- Interactive install configurator with platform/provider selection, step-by-step first session walkthrough
- [Advanced Setup](references/claude-code-setup.md) -- System requirements, platform-specific installation (Windows/Git Bash/WSL/Alpine), verification (claude --version, claude doctor), authentication overview, update management (auto-updates, release channels latest/stable, autoUpdatesChannel, DISABLE_AUTOUPDATER, claude update), version pinning, npm migration, binary integrity and code signing, uninstallation (native/Homebrew/WinGet/npm/config cleanup)
- [Authentication](references/claude-code-authentication.md) -- Login flow (browser prompts, /logout), account types (Pro/Max/Teams/Enterprise/Console/cloud providers), team setup (Teams vs Enterprise, Console with roles, cloud provider credential distribution), credential management (storage locations, apiKeyHelper, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_API_KEY, refresh intervals), authentication precedence order
- [How Claude Code Works](references/claude-code-how-it-works.md) -- Agentic loop architecture (gather/act/verify phases, interrupt and steer), models (Sonnet vs Opus, /model switching), tools (file ops, search, execution, web, code intelligence), what Claude accesses (project, terminal, git, CLAUDE.md, auto memory, extensions), execution environments (local/cloud/Remote Control), sessions (independence, branching, resume/fork, context window, compaction, skills and subagents for context), checkpoints (file snapshots, Esc+Esc rewind), permission modes (Default/Auto-accept/Plan/Auto, Shift+Tab cycling), working effectively tips (conversational, interrupt, specificity, verification, explore first, delegate)
- [Platforms and Integrations](references/claude-code-platforms.md) -- Platform comparison table (CLI/Desktop/VS Code/JetBrains/Web with tradeoffs), tool integrations (Chrome/GitHub Actions/GitLab CI/CD/Code Review/Slack/MCP), remote work options (Dispatch/Remote Control/Channels/Slack/scheduled tasks), related resource links

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
