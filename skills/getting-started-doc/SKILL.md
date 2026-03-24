---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview of all surfaces (Terminal CLI, VS Code, JetBrains, Desktop app, Web), installation methods (native install via curl/irm/winget, Homebrew, WinGet, npm deprecated), system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4 GB+ RAM, Bash/Zsh/PowerShell/CMD), Windows setup (Git for Windows, Git Bash, WSL 1/2), Alpine/musl dependencies (libgcc, libstdc++, ripgrep, USE_BUILTIN_RIPGREP=0), authentication (Claude Pro/Max/Teams/Enterprise OAuth, Console API credentials, Bedrock/Vertex/Foundry cloud providers, ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, apiKeyHelper, credential precedence), credential management (macOS Keychain, Linux/Windows ~/.claude/.credentials.json, CLAUDE_CONFIG_DIR, apiKeyHelper TTL refresh), team setup (Teams/Enterprise subscription, Console SSO and roles, cloud provider env distribution), quickstart walkthrough (install, login, first session, explore codebase, make code changes, use git, fix bugs, refactor, write tests, review), essential CLI commands (claude, claude "task", claude -p, claude -c, claude -r, claude commit, /clear, /help, exit), how Claude Code works (agentic loop: gather context, take action, verify results, models Sonnet/Opus, /model, built-in tool categories: file operations, search, execution, web, code intelligence), sessions (local save, checkpoints, resume with --continue/--resume, fork with --fork-session, context window, compaction, /context, /compact, skills on-demand loading, subagent context isolation), safety (checkpoints for undo, permission modes: default, auto-accept edits, plan mode, Shift+Tab cycling, .claude/settings.json allowed commands), execution environments (local, cloud Anthropic VMs, Remote Control), platforms and integrations (CLI, Desktop with diff viewer/computer use/Dispatch, VS Code inline diffs, JetBrains diff viewer, Web cloud sessions), integrations (Chrome browser control, GitHub Actions, GitLab CI/CD, Code Review, Slack @Claude), remote access (Dispatch from mobile, Remote Control, Channels for Telegram/Discord/webhooks, scheduled tasks cloud/desktop/CLI /loop), capabilities (automate tedious tasks, build features, fix bugs, git commits and PRs, MCP connections, CLAUDE.md customization, skills custom commands, hooks automation, agent teams and Agent SDK, CLI piping/scripting, scheduled recurring tasks, work from anywhere with Remote Control/Dispatch/web/iOS/Slack), update management (auto-updates, autoUpdatesChannel latest/stable, DISABLE_AUTOUPDATER, claude update manual, Homebrew/WinGet manual upgrade), release channels (latest default, stable ~1 week behind), version pinning (install specific version via installer args), binary integrity (SHA256 checksums, macOS code signing by Anthropic PBC, Windows signing), uninstallation (native rm ~/.local/bin/claude and ~/.local/share/claude, Homebrew uninstall, WinGet uninstall, npm uninstall, config cleanup ~/.claude and .claude), npm migration (native installer replaces npm, npm uninstall -g @anthropic-ai/claude-code), tips (be specific, step-by-step instructions, let Claude explore first, keyboard shortcuts ? Tab up-arrow /), pro tips (talk like a colleague, interrupt and steer, verify against test cases, explore before implementing, delegate don't dictate). Load when discussing getting started, installation, setup, quickstart, overview, authentication, login, how Claude Code works, agentic loop, platforms, integrations, system requirements, Windows setup, credential management, team authentication, update management, uninstallation, first session, essential commands, permission modes, checkpoints, sessions, context window, execution environments, or choosing a Claude Code surface.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- overview, installation, authentication, quickstart walkthrough, how the agentic loop works, and platform/integration options.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates? |
|:-------|:--------|:--------------|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PS) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). Native installs auto-update in the background.

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **OS** | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Windows** | Git for Windows required; WSL 1 and 2 supported (WSL 2 supports sandboxing) |
| **Alpine/musl** | Requires `libgcc`, `libstdc++`, `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |

### Authentication Methods

| Method | When to use |
|:-------|:------------|
| **Claude Pro/Max** | Individual subscription via claude.ai |
| **Claude Teams/Enterprise** | Team-managed subscription with admin invite |
| **Claude Console** | API-based billing with pre-paid credits |
| **Amazon Bedrock** | Set `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| **Google Vertex AI** | Set `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| **Microsoft Foundry** | Set `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Authentication Precedence (highest to lowest)

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (Bearer token for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` env var (X-Api-Key header for direct API access)
4. `apiKeyHelper` script output (dynamic/rotating credentials from a vault)
5. Subscription OAuth credentials from `/login` (default for Pro/Max/Teams/Enterprise)

### Credential Storage

| Platform | Location |
|:---------|:---------|
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode 0600) |
| Windows | `~/.claude/.credentials.json` (inherits user profile ACLs) |
| Custom | Set `CLAUDE_CONFIG_DIR` to override the default config directory |

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --model <name>` | Start with a specific model |
| `/model` | Switch model during a session |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out and re-authenticate |
| `/context` | Show what is using context window space |
| `/compact [focus]` | Compress conversation history |
| `Shift+Tab` | Cycle permission modes (default / auto-accept edits / plan) |
| `exit` or `Ctrl+C` | Exit Claude Code |

### The Agentic Loop

Claude Code works through three blended phases on every task:

1. **Gather context** -- search files, read code, understand the codebase
2. **Take action** -- edit files, run commands, create branches
3. **Verify results** -- run tests, check output, iterate if needed

Claude chains dozens of tool calls, course-correcting along the way. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | What Claude can do |
|:---------|:-------------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up errors |
| **Code intelligence** | Type errors/warnings after edits, jump to definitions, find references (requires code intelligence plugins) |

### Session Management

| Feature | How |
|:--------|:----|
| Resume last session | `claude -c` or `claude --continue` |
| Resume any session | `claude -r` or `claude --resume` |
| Fork a session | `claude --continue --fork-session` |
| Context window | Holds conversation, file contents, command outputs, CLAUDE.md, auto memory, skills, system instructions |
| Compaction | Automatic when context fills; older tool outputs cleared first, then conversation summarized |
| Checkpoints | Every file edit is reversible; press `Esc` twice to rewind |

### Permission Modes

| Mode | Behavior | Activate |
|:-----|:---------|:---------|
| **Default** | Asks before file edits and shell commands | Default |
| **Auto-accept edits** | Edits files without asking; still asks for commands | `Shift+Tab` once |
| **Plan mode** | Read-only tools only; creates a plan for approval | `Shift+Tab` twice |

### Platforms

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| VS Code | In-editor coding | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| Web | Long-running/offline tasks | Anthropic-managed cloud, continues after disconnect |

All platforms share the same engine, CLAUDE.md files, settings, and MCP servers.

### Integrations

| Integration | What it does |
|:------------|:-------------|
| Chrome | Controls your browser with logged-in sessions |
| GitHub Actions | Runs Claude in CI for PR reviews, issue triage |
| GitLab CI/CD | Same as GitHub Actions for GitLab |
| Code Review | Reviews every PR automatically |
| Slack | Responds to `@Claude` mentions in channels |
| MCP servers | Connect to Linear, Notion, Google Drive, internal APIs |

### Remote Access Options

| Method | Trigger | Runs on |
|:-------|:--------|:--------|
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | Drive session from claude.ai/code or mobile | Your machine (CLI/VS Code) |
| Channels | Push events from Telegram, Discord, webhooks | Your machine (CLI) |
| Slack | `@Claude` mention in team channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### Update Management

| Setting | Value | Effect |
|:--------|:------|:-------|
| `autoUpdatesChannel` | `"latest"` (default) | Receive updates immediately |
| `autoUpdatesChannel` | `"stable"` | ~1 week behind, skips regressions |
| `env.DISABLE_AUTOUPDATER` | `"1"` | Disable auto-updates entirely |
| Manual update | `claude update` | Apply update immediately |

### Effective Prompting Tips

| Tip | Detail |
|:----|:-------|
| Be specific | Reference files, mention constraints, point to patterns |
| Give verification criteria | Include test cases, expected output, screenshots |
| Explore before implementing | Use plan mode to analyze first, then implement |
| Delegate, don't dictate | Give context and direction; let Claude figure out details |
| Iterate | Correct and refine through conversation; interrupt if off-track |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, all surfaces (Terminal, VS Code, JetBrains, Desktop, Web), installation commands, capabilities (automate tasks, build features, fix bugs, git/PRs, MCP, CLAUDE.md/skills/hooks, agent teams, CLI piping, scheduled tasks, work from anywhere), integration matrix (Remote Control, Channels, Dispatch, Slack, GitHub/GitLab Actions, Code Review, Chrome, Agent SDK)
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough (install, login, start session, ask questions, make code changes, use git, fix bugs, refactor/test/review workflows), essential CLI commands table, pro tips for beginners (be specific, step-by-step instructions, let Claude explore, keyboard shortcuts)
- [Advanced setup](references/claude-code-setup.md) -- system requirements (OS, RAM, network, shell), platform-specific installation (Windows Git Bash/WSL, Alpine musl dependencies), verify installation (claude --version, claude doctor), update management (auto-updates, release channels latest/stable, DISABLE_AUTOUPDATER, claude update), install specific version, npm migration, binary integrity and code signing, uninstallation for all methods, config file cleanup
- [Authentication](references/claude-code-authentication.md) -- login flow, account types (Pro/Max/Teams/Enterprise/Console/cloud providers), team setup (Teams/Enterprise subscription, Console SSO and roles, cloud provider env distribution), credential management (macOS Keychain, Linux/Windows file storage, apiKeyHelper, refresh intervals), authentication precedence (cloud providers > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth)
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop (gather context, take action, verify results), models (Sonnet/Opus, /model switching), built-in tool categories (file ops, search, execution, web, code intelligence), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local, cloud, Remote Control), sessions (local save, checkpoints, resume/fork, context window, compaction), safety (checkpoints for undo, permission modes, Shift+Tab), effective usage tips (interrupt and steer, be specific, verify against tests, explore before implementing, delegate)
- [Platforms and integrations](references/claude-code-platforms.md) -- platform comparison (CLI, Desktop, VS Code, JetBrains, Web), integration matrix (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack, MCP), remote access options (Dispatch, Remote Control, Channels, Slack, scheduled tasks), choosing the right surface

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
