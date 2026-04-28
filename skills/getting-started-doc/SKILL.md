---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup, authentication, how the agentic loop works, and platforms/integrations comparison.
user-invocable: false
---

# Getting Started with Claude Code Documentation

This skill provides the complete official documentation for installing, authenticating, and understanding Claude Code.

## Quick Reference

### Install Claude Code

| Method | Command |
| :--- | :--- |
| **macOS / Linux / WSL (recommended)** | `curl -fsSL https://claude.ai/install.sh \| bash` |
| **Windows PowerShell** | `irm https://claude.ai/install.ps1 \| iex` |
| **Windows CMD** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| **Homebrew (stable)** | `brew install --cask claude-code` |
| **Homebrew (latest)** | `brew install --cask claude-code@latest` |
| **WinGet** | `winget install Anthropic.ClaudeCode` |
| **npm** | `npm install -g @anthropic-ai/claude-code` |
| **apt (Debian/Ubuntu)** | See setup doc — signed apt repo at `downloads.claude.ai` |
| **dnf (Fedora/RHEL)** | See setup doc — signed dnf repo at `downloads.claude.ai` |
| **apk (Alpine)** | See setup doc — signed apk repo at `downloads.claude.ai` |

Native installs auto-update. Homebrew, WinGet, and package manager installs require manual upgrades.

### System requirements

| Requirement | Details |
| :--- | :--- |
| **OS** | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **Hardware** | 4 GB+ RAM, x64 or ARM64 |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

### Authentication — account types

| Account type | How to log in | Notes |
| :--- | :--- | :--- |
| Claude Pro / Max | `/login` → browser OAuth | Recommended for individuals |
| Claude for Teams / Enterprise | `/login` → browser OAuth | Centralized billing, SSO (Enterprise) |
| Claude Console | `/login` → Console credentials | API-based billing, per-user roles |
| Amazon Bedrock | Set env vars, no browser login | See Bedrock setup guide |
| Google Vertex AI | Set env vars, no browser login | See Vertex setup guide |
| Microsoft Foundry | Set env vars, no browser login | See Foundry setup guide |

### Authentication precedence (highest wins)

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — bearer token for LLM gateways
3. `ANTHROPIC_API_KEY` — direct Anthropic API key
4. `apiKeyHelper` script — dynamic/rotating credentials
5. `CLAUDE_CODE_OAUTH_TOKEN` — long-lived token from `claude setup-token` (CI use)
6. Subscription OAuth from `/login` — default for Pro/Max/Team/Enterprise

### Credential storage

| Platform | Location |
| :--- | :--- |
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode 0600) |
| Windows | `~/.claude/.credentials.json` (user profile ACL) |

### Key CLI commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task and exit |
| `claude -p "query"` | Single query, then exit (non-interactive) |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation (picker) |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Apply available update immediately |
| `claude --version` | Show installed version |
| `claude doctor` | Diagnose installation issues |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `/login` | Switch accounts |
| `/logout` | Log out |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/model` | Switch model mid-session |
| `/context` | Show what is using context window space |
| `/compact` | Summarize conversation to reclaim context |
| `/init` | Create a CLAUDE.md for the project |

### The agentic loop

Claude works through three phases, blending them as needed:

1. **Gather context** — read files, search codebase, understand the task
2. **Take action** — edit files, run commands, use tools
3. **Verify results** — run tests, check outputs, course-correct

Built-in tool categories:

| Category | What Claude can do |
| :--- | :--- |
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, regex content search |
| **Execution** | Run shell commands, tests, git operations |
| **Web** | Search the web, fetch documentation |
| **Code intelligence** | Type errors, definitions, references (requires plugin) |

### Permission modes (Shift+Tab to cycle)

| Mode | Behavior |
| :--- | :--- |
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files and common filesystem commands without asking |
| **Plan mode** | Read-only tools only; creates a plan for approval |
| **Auto mode** | Evaluates all actions with background safety checks (research preview) |

### Sessions

- Sessions are saved as JSONL in `~/.claude/projects/`
- Each session starts with a fresh context window
- Resume: `claude --continue` (most recent) or `claude --resume` (picker)
- Fork: `claude --continue --fork-session` — new session ID, same history
- Context fills up: Claude auto-compacts; add persistent rules to CLAUDE.md

### Update management

| Setting | Effect |
| :--- | :--- |
| `autoUpdatesChannel: "latest"` | New features as soon as released (default) |
| `autoUpdatesChannel: "stable"` | ~1 week behind; skips releases with major regressions |
| `minimumVersion: "X.Y.Z"` | Floor: auto-update won't go below this version |
| `DISABLE_AUTOUPDATER: "1"` | Stop background check (manual `claude update` still works) |
| `DISABLE_UPDATES` | Block all update paths including manual |

### Platforms comparison

| Platform | Best for | Notable features |
| :--- | :--- | :--- |
| **CLI** | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| **Desktop** | Visual review, parallel sessions | Diff viewer, computer use (Pro/Max), Dispatch |
| **VS Code** | Working inside VS Code | Inline diffs, integrated terminal, file context |
| **JetBrains** | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing |
| **Web** | Long-running or offline tasks | Anthropic-managed cloud, continues when disconnected |
| **Mobile** | Starting/monitoring tasks remotely | Cloud sessions, Remote Control, Dispatch to Desktop |

### Remote work options

| Option | Trigger | Claude runs on | Best for |
| :--- | :--- | :--- | :--- |
| **Dispatch** | Message from Claude mobile app | Your machine (Desktop) | Delegating while away |
| **Remote Control** | Drive from browser/phone | Your machine (CLI or VS Code) | Steering in-progress work |
| **Channels** | Push from Telegram, Discord, webhooks | Your machine (CLI) | Reacting to external events |
| **Slack** | `@Claude` mention in channel | Anthropic cloud | PRs from team chat |
| **Scheduled tasks** | Set a schedule | CLI, Desktop, or cloud | Recurring automation |

### Uninstall

| Install method | Uninstall command |
| :--- | :--- |
| Native (macOS/Linux/WSL) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | Remove `~\.local\bin\claude.exe` and `~\.local\share\claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| apt | `sudo apt remove claude-code` |
| dnf | `sudo dnf remove claude-code` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |

To also remove settings and history: delete `~/.claude` and `~/.claude.json` (and `.claude/` and `.mcp.json` from each project).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — what Claude Code is, surfaces, capabilities, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step guide from install to first code change, with essential commands and tips
- [Advanced Setup](references/claude-code-setup.md) — system requirements, all install methods, update management, binary verification, and uninstall
- [Authentication](references/claude-code-authentication.md) — login flow, team setup, credential storage, auth precedence, and long-lived tokens for CI
- [How Claude Code Works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, sessions, context management, checkpoints, and permission modes
- [Platforms and Integrations](references/claude-code-platforms.md) — comparison of all surfaces (CLI, Desktop, VS Code, JetBrains, web, mobile) and integrations (Chrome, GitHub Actions, Slack, etc.)

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
