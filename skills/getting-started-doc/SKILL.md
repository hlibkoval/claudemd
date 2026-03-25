---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview (agentic coding tool for terminal/IDE/desktop/browser, installation methods native curl/Homebrew/WinGet, all surfaces Terminal/VS Code/JetBrains/Desktop/Web, capabilities including automating tasks/building features/git operations/MCP connections/custom instructions with skills and hooks/agent teams/CLI scripting/scheduled tasks/cross-device Remote Control and Dispatch and Channels and Slack), quickstart (step-by-step first session walkthrough, install/login/start session/first question/first code change/git operations/bug fixes/common workflows, essential CLI commands claude/claude -p/claude -c/claude -r/claude commit, pro tips for beginners), advanced setup (system requirements macOS 13+/Windows 10 1809+/Ubuntu 20.04+/Debian 10+/Alpine 3.19+, 4 GB RAM, Windows Git Bash/WSL setup, Alpine musl libgcc/libstdc++/ripgrep, verify with claude --version/claude doctor, release channels latest/stable with autoUpdatesChannel, disable auto-updates DISABLE_AUTOUPDATER, install specific versions, npm-to-native migration, binary integrity SHA256/code signing, uninstall per method, remove config files), authentication (login flow via browser, account types Pro/Max/Teams/Enterprise/Console/cloud providers, team setup Claude for Teams/Enterprise/Console/cloud providers, credential management macOS Keychain/Linux credentials.json, apiKeyHelper with TTL and slow-helper notice, authentication precedence cloud > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth, credential conflicts), how Claude Code works (agentic loop gather-context/take-action/verify-results, models Sonnet/Opus with /model switching, tool categories file-operations/search/execution/web/code-intelligence, extending with skills/MCP/hooks/subagents, project access files/terminal/git/CLAUDE.md/auto-memory/extensions, execution environments local/cloud/remote-control, sessions independent with fresh context, resume --continue/fork --fork-session, context window management /context and /compact with focus, context costs of skills and subagents, checkpoints for undo Esc twice, permission modes Default/Auto-accept/Plan/Auto with Shift+Tab, effective usage tips be-specific/give-verification/explore-before-implementing/delegate-dont-dictate), platforms and integrations (CLI/Desktop/VS Code/JetBrains/Web comparison, integrations Chrome/GitHub Actions/GitLab CI-CD/Code Review/Slack, remote work Dispatch/Remote Control/Channels/Slack/Scheduled tasks). Load when discussing getting started with Claude Code, installing Claude Code, Claude Code overview, Claude Code quickstart, first time setup, how to install, system requirements, authentication and login, how Claude Code works, agentic loop, Claude Code tools and capabilities, what Claude Code can do, Claude Code platforms, Claude Code interfaces, session management, context window, permission modes, checkpoints, resume sessions, fork sessions, plan mode, auto mode, /login, /init, claude doctor, release channels, auto-updates, uninstall Claude Code, npm migration, credential management, apiKeyHelper, ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, Claude for Teams setup, Console authentication, cloud provider auth, Windows setup, WSL, Git Bash, Alpine Linux, or any introductory Claude Code topic.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- overview, quickstart walkthrough, installation, authentication, how the agentic loop works, and platform comparison.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (recommended)** | macOS/Linux/WSL: `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native** | Windows PS: `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native** | Windows CMD: `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). Verify with `claude --version` or `claude doctor`.

### System Requirements

| Requirement | Detail |
|:------------|:-------|
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

Alpine and musl-based distributions require `libgcc`, `libstdc++`, `ripgrep` and `USE_BUILTIN_RIPGREP=0`.

### Authentication

**Account types:** Pro, Max, Teams, Enterprise, Console, or cloud providers (Bedrock, Vertex AI, Foundry).

**Login:** Run `claude` and follow the browser prompts. Press `c` to copy the login URL if the browser does not open. Use `/logout` to switch accounts.

**Credential precedence** (highest to lowest):

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` -- sent as `Authorization: Bearer` header (for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` -- sent as `X-Api-Key` header (direct Anthropic API)
4. `apiKeyHelper` script output -- for dynamic/rotating credentials
5. Subscription OAuth from `/login` -- default for Pro/Max/Teams/Enterprise

**Credential storage:** macOS Keychain (encrypted); Linux/Windows `~/.claude/.credentials.json` (mode 0600 on Linux).

**apiKeyHelper:** Configure in settings to run a shell script returning an API key. Refreshes after 5 minutes or on HTTP 401. Set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for custom refresh intervals.

### Team Authentication Setup

| Method | Best for | Setup |
|:-------|:---------|:------|
| **Claude for Teams** | Small-medium teams | Subscribe, invite members from admin dashboard |
| **Claude for Enterprise** | Large orgs (SSO, domain capture, RBAC) | Contact sales, invite members |
| **Console** | API-based billing | Create Console account, invite users with Claude Code or Developer role |
| **Cloud providers** | Orgs using Bedrock/Vertex/Foundry | Follow provider docs, distribute env vars |

### Platforms

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| **CLI** | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| **Desktop** | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| **VS Code** | Working inside VS Code | Inline diffs, integrated terminal, file context |
| **JetBrains** | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing |
| **Web** | Long-running tasks, offline continuation | Cloud-hosted, continues after disconnect |

Configuration, project memory, and MCP servers are shared across local surfaces.

### Integrations

| Integration | What it does |
|:------------|:-------------|
| **Chrome** | Browser automation with logged-in sessions |
| **GitHub Actions** | Automated PR reviews, issue triage in CI |
| **GitLab CI/CD** | CI-driven automation on GitLab |
| **Code Review** | Automatic PR review on every push |
| **Slack** | `@Claude` mentions route to Claude Code sessions |

### Remote Work Options

| Method | Trigger | Runs on |
|:-------|:--------|:--------|
| **Dispatch** | Message from Claude mobile app | Your machine (Desktop) |
| **Remote Control** | Drive from claude.ai/code or mobile app | Your machine (CLI/VS Code) |
| **Channels** | Push events from Telegram, Discord, webhooks | Your machine (CLI) |
| **Slack** | `@Claude` mention in team channels | Anthropic cloud |
| **Scheduled tasks** | Set a schedule | CLI, Desktop, or cloud |

### The Agentic Loop

Claude Code works through three blended phases: **gather context** (search files, read code), **take action** (edit files, run commands), and **verify results** (run tests, check output). These repeat until the task is complete. You can interrupt at any point to steer.

**Tool categories:**

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Shell commands, servers, tests, git |
| **Web** | Web search, fetch docs, look up errors |
| **Code intelligence** | Type errors, jump to definitions, find references (via plugins) |

### Sessions

Sessions are independent -- each starts with a fresh context window. Auto memory and CLAUDE.md carry knowledge across sessions.

| Operation | Command | Behavior |
|:----------|:--------|:---------|
| **Start** | `claude` | New session in current directory |
| **Continue** | `claude --continue` or `claude -c` | Resume most recent session |
| **Resume** | `claude --resume` or `claude -r` | Pick a previous session to resume |
| **Fork** | `claude --continue --fork-session` | Branch off a session with new ID |

Session-scoped permissions do not carry over when resuming or forking.

### Context Window

The context window holds conversation history, file contents, command outputs, CLAUDE.md, auto memory, loaded skills, and system instructions. Run `/context` to see usage.

**When context fills up:** Claude compacts automatically -- clears older tool outputs first, then summarizes. Persistent rules belong in CLAUDE.md. Use `/compact` with a focus (e.g., `/compact focus on API changes`) to control what survives.

**Skills** load on demand; only descriptions appear at session start. **Subagents** get their own isolated context.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | File edits | Shell commands |
|:-----|:-----------|:---------------|
| **Default** | Asks | Asks |
| **Auto-accept edits** | Auto | Asks |
| **Plan mode** | Read-only | Read-only |
| **Auto mode** | Auto (with safety checks) | Auto (with safety checks) |

Allow trusted commands (e.g., `npm test`) in `.claude/settings.json` to skip per-use prompts.

### Checkpoints

Before every file edit, Claude snapshots the current contents. Press `Esc` twice to rewind. Checkpoints are local to the session and separate from git. Actions affecting remote systems (databases, APIs, deployments) cannot be checkpointed.

### Essential CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run query non-interactively, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a git commit |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/init` | Generate a starter CLAUDE.md |
| `/model` | Switch models during a session |
| `/doctor` | Diagnose common issues |

### Update and Release Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | Receive new features immediately |
| `stable` | Use a version approximately one week old, skipping releases with major regressions |

Configure via `/config` > Auto-update channel, or set `autoUpdatesChannel` in settings.json. Disable auto-updates with `DISABLE_AUTOUPDATER: "1"` in settings env. Manual update: `claude update`.

### Uninstall

| Method | Command |
|:-------|:--------|
| **Native (macOS/Linux)** | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| **Native (Windows PS)** | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force; Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| **Homebrew** | `brew uninstall --cask claude-code` |
| **WinGet** | `winget uninstall Anthropic.ClaudeCode` |
| **npm (deprecated)** | `npm uninstall -g @anthropic-ai/claude-code` |

Remove config: `rm -rf ~/.claude ~/.claude.json` (deletes all settings, tool permissions, MCP configs, and session history).

### Tips for Effective Use

| Tip | Detail |
|:----|:-------|
| **Be specific upfront** | Reference files, mention constraints, point to patterns |
| **Give verification targets** | Include test cases, expected outputs, or screenshots |
| **Explore before implementing** | Use plan mode to analyze first, then implement |
| **Delegate, don't dictate** | Provide context and direction; let Claude figure out details |
| **Interrupt and steer** | Type corrections mid-task; Claude adjusts without restarting |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview with all surfaces (Terminal, VS Code, JetBrains, Desktop, Web), installation methods per surface, capability showcase (automate tasks, build features, git operations, MCP connections, custom instructions with skills and hooks, agent teams, CLI scripting and piping, scheduled tasks, cross-device work with Remote Control/Dispatch/Channels/Slack), integration matrix (Remote Control, Channels, Web, scheduled tasks, GitHub Actions, GitLab CI/CD, Code Review, Slack, Chrome, Agent SDK), next steps links
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough (prerequisites, install, login with Pro/Max/Teams/Enterprise/Console/cloud providers, start session, first question about codebase, first code change with approval flow, git operations conversationally, bug fixes and feature implementation, common workflows refactor/tests/docs/review), essential CLI commands table (claude, claude "task", claude -p, claude -c, claude -r, claude commit, /clear, /help), pro tips (be specific, step-by-step instructions, explore first, keyboard shortcuts)
- [Advanced setup](references/claude-code-setup.md) -- system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4 GB RAM, network, shells), installation methods (native curl/PowerShell/CMD, Homebrew, WinGet), Windows setup (Git Bash and WSL options, CLAUDE_CODE_GIT_BASH_PATH), Alpine musl dependencies (libgcc, libstdc++, ripgrep, USE_BUILTIN_RIPGREP), verification (claude --version, claude doctor), auto-updates and release channels (latest/stable, autoUpdatesChannel, DISABLE_AUTOUPDATER), manual update (claude update), install specific version or stable channel, npm-to-native migration, binary integrity (SHA256 checksums, macOS/Windows code signing), uninstall per method, remove configuration files
- [Authentication](references/claude-code-authentication.md) -- login flow (browser prompts, /logout), account types (Pro, Max, Teams, Enterprise, Console, cloud providers), team setup (Claude for Teams self-service, Enterprise with SSO/domain capture/RBAC, Console with bulk invite and SSO and roles, cloud provider distribution), credential management (macOS Keychain, Linux/Windows credentials.json, apiKeyHelper with TTL and slow-helper notice, CLAUDE_CODE_API_KEY_HELPER_TTL_MS), authentication precedence (cloud provider > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth), credential conflicts (API key overriding subscription)
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop (gather context, take action, verify results with tool chaining and course correction), models (Sonnet for most tasks, Opus for complex reasoning, /model and --model switching), tools (file operations, search, execution, web, code intelligence; extending with skills/MCP/hooks/subagents), project access (files, terminal, git state, CLAUDE.md, auto memory, configured extensions), execution environments (local, cloud, remote control), sessions (independent with fresh context, resume with --continue, fork with --fork-session, context window management with /context and /compact, skills load on demand, subagents get isolated context), safety (checkpoints with Esc to rewind, permission modes Default/Auto-accept/Plan/Auto with Shift+Tab, .claude/settings.json allowlists), effective usage tips (ask Claude for help, iterate conversationally, interrupt and steer, be specific, give verification targets, explore before implementing, delegate don't dictate)
- [Platforms and integrations](references/claude-code-platforms.md) -- platform comparison (CLI for terminal/scripting/servers, Desktop for visual review/parallel sessions, VS Code for editor integration, JetBrains for IntelliJ/PyCharm/WebStorm, Web for long-running cloud tasks), integration overview (Chrome browser automation, GitHub Actions CI, GitLab CI/CD, Code Review automatic PR analysis, Slack @Claude mentions), remote work comparison (Dispatch from mobile, Remote Control from browser, Channels from chat apps/webhooks, Slack from team channels, Scheduled tasks on timer), mixing surfaces on same project

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
