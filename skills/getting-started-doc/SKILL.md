---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview of capabilities, quickstart walkthrough, system requirements and all installation methods, authentication and credential management, the agentic loop and built-in tools, session management, context window handling, and platform/integration comparison.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. It is available in the terminal, IDEs, desktop app, and browser.

### Installation

| Platform | Method | Command |
| :--- | :--- | :--- |
| macOS / Linux / WSL | Native (recommended, auto-updates) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | Native (recommended, auto-updates) | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | Native | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| macOS | Homebrew stable (no auto-update) | `brew install --cask claude-code` |
| macOS | Homebrew latest (no auto-update) | `brew install --cask claude-code@latest` |
| Any | WinGet (no auto-update) | `winget install Anthropic.ClaudeCode` |
| Any | npm (Node 18+) | `npm install -g @anthropic-ai/claude-code` |
| Debian/Ubuntu | apt (no auto-update) | Add signed repo, then `sudo apt install claude-code` |
| Fedora/RHEL | dnf (no auto-update) | Add signed repo, then `sudo dnf install claude-code` |
| Alpine | apk (no auto-update) | Add signed repo, then `apk add claude-code` |

Native installs auto-update in the background. Homebrew, WinGet, and Linux package manager installs require manual upgrades. Do NOT use `sudo npm install -g`.

### System requirements

| Component | Requirement |
| :--- | :--- |
| OS | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD (native Windows requires Git for Windows) |
| Network | Internet connection required |

### Quickstart steps

1. Install Claude Code (see table above)
2. `cd your-project && claude`
3. Log in on first launch — browser opens automatically; press `c` to copy the URL if it does not
4. Ask questions or give tasks in plain language

### Essential CLI commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation |
| `claude --continue --fork-session` | Fork a session to try a different approach |
| `claude --model <name>` | Start with a specific model |
| `claude --version` | Show installed version |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Apply update immediately |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/clear` | Clear conversation history |
| `/compact` | Summarize context to free space |
| `/context` | Show what is consuming context |
| `/help` | Show available commands |
| `/model` | Switch model mid-session |
| `/init` | Create a CLAUDE.md for your project |
| `exit` or Ctrl+D | Exit Claude Code |

### Authentication precedence (highest wins)

| Priority | Method | When to use |
| :--- | :--- | :--- |
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`) | AWS Bedrock, Google Vertex AI, Microsoft Foundry |
| 2 | `ANTHROPIC_AUTH_TOKEN` env var | LLM gateways / proxies (bearer token) |
| 3 | `ANTHROPIC_API_KEY` env var | Direct Anthropic API with Console key |
| 4 | `apiKeyHelper` script | Dynamic / rotating credentials |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` env var | CI pipelines (`claude setup-token` generates this) |
| 6 | Subscription OAuth from `/login` | Default for Pro, Max, Team, Enterprise |

Credentials are stored in the macOS Keychain (macOS) or `~/.claude/.credentials.json` (Linux/Windows, mode 0600 on Linux).

### Account types for teams

| Type | Notes |
| :--- | :--- |
| Claude Pro / Max | Individual subscription |
| Claude for Teams | Self-service, admin tools, centralized billing |
| Claude for Enterprise | Adds SSO, domain capture, RBAC, compliance API, managed policy |
| Claude Console | API billing; users need Console invite; assign Claude Code or Developer role |
| Bedrock / Vertex / Foundry | Set provider env vars; no browser login needed |

### Version / update management

| Setting / env | Purpose |
| :--- | :--- |
| `"autoUpdatesChannel": "latest"` | Receive updates immediately (default) |
| `"autoUpdatesChannel": "stable"` | ~1 week behind; skips major regressions |
| `"minimumVersion": "2.x.y"` | Floor; prevents downgrading below this build |
| `DISABLE_AUTOUPDATER=1` | Stop background checks (manual `claude update` still works) |
| `DISABLE_UPDATES` | Block all update paths including manual |

### The agentic loop

Claude Code operates in three phases that blend and repeat until the task is done:

1. **Gather context** — reads files, searches codebase, understands current state
2. **Take action** — edits files, runs commands, calls tools
3. **Verify results** — runs tests, checks output, course-corrects

Each tool call feeds new information back into the loop. You can interrupt at any point to steer Claude.

### Built-in tool categories

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read, edit, create, rename, reorganize files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | See type errors, jump to definitions, find references (requires code intelligence plugins) |

### Permission modes (Shift+Tab to cycle)

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and common filesystem commands without asking |
| Plan mode | Read-only tools only; creates a plan for your approval |
| Auto mode | Claude evaluates all actions with background safety checks (research preview) |

Every file edit is checkpointed before it happens — press Esc twice to rewind to any previous state.

### Session management

- Sessions are saved locally to `~/.claude/projects/` as JSONL files
- Each session starts with a fresh context window — use CLAUDE.md and auto memory for persistence
- `/resume` picker shows sessions for the current worktree; keyboard shortcuts widen the scope
- `--fork-session` branches the conversation without affecting the original
- Multiple terminals resuming the same session interleave messages — use `--fork-session` for parallel work

### Context window tips

- Put persistent rules in `CLAUDE.md` — they survive `/compact`
- Run `/compact focus on <area>` to control what is preserved during compaction
- Use subagents for long tasks — they run in a fresh, isolated context
- Run `/context` to see what is consuming space; `/mcp` for per-server MCP costs
- MCP tool definitions are deferred by default — only names load at startup

### Platforms at a glance

| Platform | Best for | Notable features |
| :--- | :--- | :--- |
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, computer use, Dispatch from mobile |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm, etc. | Diff viewer, selection sharing |
| Web | Long-running cloud tasks, offline continuation | Keeps running after you disconnect |
| Mobile (iOS/Android) | Starting and monitoring tasks remotely | Remote Control, Dispatch to Desktop (Pro/Max) |

CLAUDE.md files, settings, and MCP servers are shared across all local surfaces.

### Integrations

| Integration | What it does |
| :--- | :--- |
| Chrome | Controls browser with your logged-in sessions |
| GitHub Actions | Runs Claude in CI pipeline for PR reviews and issue triage |
| GitLab CI/CD | Same for GitLab |
| Code Review | Reviews every PR automatically |
| Slack | Turns `@Claude` mentions into pull requests |
| MCP servers | Connect to Linear, Notion, Google Drive, custom APIs, etc. |

### Work when away from terminal

| Option | Claude runs on | Best for |
| :--- | :--- | :--- |
| Dispatch | Your machine (Desktop) | Delegating tasks from your phone, minimal setup |
| Remote Control | Your machine (CLI or VS Code) | Steering in-progress work from another device |
| Channels | Your machine (CLI) | Reacting to events from Telegram, Discord, or webhooks |
| Slack | Anthropic cloud | PRs and code review from team chat |
| Scheduled tasks | CLI, Desktop, or cloud | Recurring automation (daily reviews, overnight CI analysis) |

### Uninstall

| Method | Command |
| :--- | :--- |
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config files | `rm -rf ~/.claude && rm ~/.claude.json` (deletes all settings and history) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — what Claude Code is, all surfaces, capabilities, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step walkthrough of your first session in the terminal
- [Advanced Setup](references/claude-code-setup.md) — system requirements, all install methods, version management, binary verification, and uninstall
- [Authentication](references/claude-code-authentication.md) — login flows, team authentication, credential storage, precedence, and long-lived tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — the agentic loop, built-in tools, sessions, context management, checkpoints, permissions, and effective prompting tips
- [Platforms and Integrations](references/claude-code-platforms.md) — platform comparison table, integrations, and remote-access options

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
