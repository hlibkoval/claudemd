---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview (installation on all platforms with native/Homebrew/WinGet, VS Code extension, Desktop app, Web, JetBrains plugin, what you can do, use Claude Code everywhere table), quickstart (prerequisites, install steps, login, first session, first question, first code change, Git with Claude Code, bug fixes, common workflows, essential commands table, pro tips for beginners), advanced setup (system requirements for macOS/Windows/Linux/Alpine, Windows setup with Git Bash and WSL, verify installation with claude doctor, authenticate with subscription/Console/cloud providers, auto-updates with latest/stable channels and DISABLE_AUTOUPDATER, manual updates, install specific version, npm migration, binary integrity and code signing, uninstall for native/Homebrew/WinGet/npm, remove configuration files), authentication (login flow, account types Pro/Max/Teams/Enterprise/Console/cloud, team setup for Teams/Enterprise/Console/Bedrock/Vertex/Foundry, credential management with macOS Keychain and .credentials.json and apiKeyHelper and CLAUDE_CODE_API_KEY_HELPER_TTL_MS, authentication precedence order), how Claude Code works (agentic loop with gather-context/take-action/verify-results phases, models with Sonnet/Opus and /model switching, tools in five categories file-operations/search/execution/web/code-intelligence, extending with skills/MCP/hooks/subagents, what Claude can access including project/terminal/git/CLAUDE.md/auto-memory/extensions, execution environments local/cloud/remote-control, interfaces, sessions with resume/fork/context-window/compaction/skills-and-subagents-for-context, checkpoints for undo, permission modes Default/Auto-accept/Plan with Shift+Tab, working effectively tips). Load when discussing how to install Claude Code, getting started, quickstart, setup, system requirements, authentication, login, credential management, apiKeyHelper, how Claude Code works, agentic loop, tools, context window, sessions, checkpoints, permission modes, or Claude Code overview.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code, from first install through the agentic architecture.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (recommended)** | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **Windows PowerShell** | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Windows CMD** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **npm (deprecated)** | `npm install -g @anthropic-ai/claude-code` | No |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). Verify installation with `claude --version` or `claude doctor`.

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

Alpine/musl-based distros need `libgcc`, `libstdc++`, `ripgrep` and `USE_BUILTIN_RIPGREP=0`.

### Available Environments

| Environment | Description |
|:------------|:------------|
| **Terminal CLI** | Full-featured CLI; `cd your-project && claude` |
| **VS Code** | Extension with inline diffs, @-mentions, plan review |
| **JetBrains** | Plugin for IntelliJ, PyCharm, WebStorm, etc. |
| **Desktop app** | Standalone app for macOS and Windows |
| **Web** | Browser-based at claude.ai/code, no local setup |
| **Slack** | Route bug reports to pull requests |
| **GitHub Actions / GitLab CI** | Automate PR reviews and issue triage |

### Authentication

| Account type | How to authenticate |
|:-------------|:--------------------|
| **Claude Pro/Max** | Run `claude`, follow browser login |
| **Claude Teams/Enterprise** | Log in with team-invited Claude.ai account |
| **Claude Console** | Log in with Console credentials (admin must invite first) |
| **Amazon Bedrock** | Set env vars, no browser login needed |
| **Google Vertex AI** | Set env vars, no browser login needed |
| **Microsoft Foundry** | Set env vars, no browser login needed |

Use `/login` to switch accounts. Use `/logout` to re-authenticate.

### Authentication Precedence

When multiple credentials are present, Claude Code selects in this order:

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (bearer token for LLM gateways)
3. `ANTHROPIC_API_KEY` env var (direct API key)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. Subscription OAuth from `/login` (default for Pro/Max/Teams/Enterprise)

### Credential Storage

| Platform | Location |
|:---------|:---------|
| **macOS** | Encrypted macOS Keychain |
| **Linux** | `~/.claude/.credentials.json` (mode 0600) |
| **Windows** | `~/.claude/.credentials.json` (user profile ACLs) |

Custom location via `$CLAUDE_CONFIG_DIR`. Dynamic credentials via `apiKeyHelper` setting (refreshes after 5 min or on 401; set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for custom interval).

### Update & Release Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week behind, skips releases with major regressions |

Configure via `/config` or `"autoUpdatesChannel": "stable"` in settings.json. Disable auto-updates with `"DISABLE_AUTOUPDATER": "1"` in `env` settings. Force manual update with `claude update`.

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run query, print result, exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `exit` or `Ctrl+C` | Exit Claude Code |

### The Agentic Loop

Claude Code works through three blended phases:

1. **Gather context** -- search files, read code, understand the codebase
2. **Take action** -- edit files, run commands, make changes
3. **Verify results** -- run tests, check output, confirm the fix works

The loop repeats until the task is complete. You can interrupt at any point to steer Claude in a different direction.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up errors |
| **Code intelligence** | Type errors, jump to definitions, find references (requires plugins) |

Extend with skills, MCP servers, hooks, and subagents.

### What Claude Can Access

When you run `claude` in a directory, it has access to: your project files, your terminal (any command you could run), git state, CLAUDE.md files, auto memory (first 200 lines of MEMORY.md), and configured extensions (MCP, skills, subagents, Chrome).

### Sessions

| Concept | Details |
|:--------|:--------|
| **Independence** | Each session starts with a fresh context window |
| **Persistence** | Conversations saved locally; file snapshots before edits |
| **Resume** | `claude --continue` or `claude --resume` to pick up where you left off |
| **Fork** | `claude --continue --fork-session` to branch off without affecting original |
| **Context window** | Holds conversation, file contents, CLAUDE.md, skills, system instructions |
| **Compaction** | Automatic when context fills; put persistent rules in CLAUDE.md |

Run `/context` to see what is using space. Use `/compact <focus>` for targeted compaction.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files freely, still asks for commands |
| **Plan mode** | Read-only tools only, creates a plan for approval |

Allow specific commands in `.claude/settings.json` to skip repeated prompts.

### Uninstallation

| Method | Command |
|:-------|:--------|
| **Native (macOS/Linux)** | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| **Native (Windows)** | Remove `%USERPROFILE%\.local\bin\claude.exe` and `%USERPROFILE%\.local\share\claude` |
| **Homebrew** | `brew uninstall --cask claude-code` |
| **WinGet** | `winget uninstall Anthropic.ClaudeCode` |
| **npm** | `npm uninstall -g @anthropic-ai/claude-code` |

Remove config files: `rm -rf ~/.claude && rm ~/.claude.json` (and `.claude/` + `.mcp.json` in project dirs).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- installation for all environments (Terminal with native/Homebrew/WinGet, VS Code extension, Desktop app for macOS/Windows, Web at claude.ai/code, JetBrains plugin), what you can do (automate tedious tasks, build features, fix bugs, create commits and PRs, connect tools with MCP, customize with CLAUDE.md/skills/hooks, run agent teams, pipe/script/automate with CLI, work from anywhere with Remote Control/web/desktop/Slack), use Claude Code everywhere table (Remote Control, Channels, Web/iOS, GitHub Actions, GitLab CI/CD, Code Review, Slack, Chrome, Agent SDK), next steps links
- [Quickstart](references/claude-code-quickstart.md) -- prerequisites, step-by-step installation, login with Pro/Max/Teams/Enterprise/Console/cloud providers, first session, first question (codebase exploration), first code change (approval flow), Git operations (status, commit, branch, merge conflicts), bug fixing and feature implementation, common workflows (refactor, tests, documentation, code review), essential commands table, pro tips (be specific, step-by-step instructions, let Claude explore first, keyboard shortcuts)
- [Advanced setup](references/claude-code-setup.md) -- system requirements (OS versions, RAM, network, shell, supported countries), platform setup (Windows with Git Bash or WSL, Alpine/musl with libgcc/libstdc++/ripgrep), verify installation (claude --version, claude doctor), authenticate (subscription types, Console setup), auto-updates (latest/stable channels, autoUpdatesChannel setting, DISABLE_AUTOUPDATER, manual update with claude update), install specific version (native installer with version/channel args), deprecated npm installation (migration to native, Node.js 18+ requirement), binary integrity and code signing (SHA256 checksums, macOS/Windows signatures), uninstall for all methods, remove configuration files
- [Authentication](references/claude-code-authentication.md) -- login flow (browser prompt, /login, /logout), account types (Pro/Max, Teams/Enterprise, Console, cloud providers), team setup (Teams vs Enterprise features, Console authentication with SSO and roles, cloud provider authentication with Bedrock/Vertex/Foundry), credential management (macOS Keychain, Linux/Windows .credentials.json, apiKeyHelper script with TTL and slow helper notice, terminal-only scope), authentication precedence (cloud providers > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth, API key approval in interactive/non-interactive mode, troubleshooting precedence conflicts)
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop (gather context, take action, verify results, interrupt and steer), models (Sonnet/Opus tradeoffs, /model switching, claude --model), tools (five categories: file operations, search, execution, web, code intelligence; extending with skills/MCP/hooks/subagents), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local, cloud, remote control), interfaces (terminal, desktop, IDE, web, Slack, CI/CD), sessions (independence, persistence, resume/fork with --continue/--resume/--fork-session, context window management, compaction, /context, /compact, skills and subagents for context control), safety (checkpoints for undo with Esc+Esc, permission modes Default/Auto-accept/Plan with Shift+Tab, .claude/settings.json allowlists), working effectively (ask Claude for help, /init, /agents, /doctor, conversational iteration, interrupt and steer, be specific upfront, give verification targets, explore before implementing, delegate don't dictate)

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
