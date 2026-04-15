---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code, covering the overview, terminal quickstart, installation and setup, authentication for individuals and teams, the agentic loop and how Claude Code works internally, and the platforms and integrations you can run it on.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: what it is, how to install it, how to log in, how the agentic loop works, and where you can run it.

## Quick Reference

### Install (Terminal CLI)

| Method | Command |
| --- | --- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |

Native installs auto-update in the background. Homebrew and WinGet require manual upgrades. Native Windows requires Git for Windows; WSL does not.

### System requirements

- macOS 13.0+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine Linux 3.19+
- 4 GB+ RAM, x64 or ARM64
- Bash, Zsh, PowerShell, or CMD shell
- Internet connection (see network configuration for allowed hosts)

### First run

```bash
cd your-project
claude
```

Other useful commands: `claude --version`, `claude doctor`, `claude update`, `claude --continue`, `claude --resume`, `claude --fork-session`, `claude setup-token`, `claude --teleport`.

### Surfaces / where Claude Code runs

| Surface | Best for |
| --- | --- |
| Terminal CLI | Full feature set, scripting, Agent SDK, third-party providers |
| Desktop app | Visual diff review, parallel sessions, Dispatch, computer use |
| VS Code / Cursor extension | Inline diffs, @-mentions, editor context |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm, etc. |
| Web (claude.ai/code) | Cloud sessions that keep running when you disconnect |
| Mobile (iOS / Android) | Start, monitor, and Dispatch tasks while away |

All surfaces share the same engine, so `CLAUDE.md`, settings, and MCP servers carry over.

### Authentication account types

| Account | How to log in |
| --- | --- |
| Claude Pro / Max | Run `claude`, log in via browser with Claude.ai account |
| Claude for Teams / Enterprise | Same browser flow with team Claude.ai account |
| Claude Console | Browser flow with Console credentials (admin must invite first) |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK=1` plus AWS credentials |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX=1` plus GCP credentials |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY=1` plus Azure credentials |

Use `/logout` to sign out, `/status` to see which credential is active, and `claude setup-token` to generate a one-year `CLAUDE_CODE_OAUTH_TOKEN` for CI.

### Authentication precedence (highest to lowest)

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (sent as `Authorization: Bearer`)
3. `ANTHROPIC_API_KEY` (sent as `X-Api-Key`)
4. `apiKeyHelper` script output
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived OAuth token from `claude setup-token`)
6. Subscription OAuth credentials from `/login`

Credentials live in the macOS Keychain on macOS, or `~/.claude/.credentials.json` (mode 0600) on Linux/Windows. Override with `CLAUDE_CONFIG_DIR`.

### How Claude Code works (the agentic loop)

Three blended phases that repeat until the task is done: **gather context**, **take action**, **verify results**. You can interrupt at any point.

Built-in tool categories:

| Category | Examples |
| --- | --- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Shell commands, tests, builds, git |
| Web | Web search, doc fetching, error lookup |
| Code intelligence | Type errors, jump-to-definition, references (via plugins) |

What Claude Code can access in a session: your project files, terminal, git state, `CLAUDE.md`, auto memory, and any MCP servers / skills / subagents you have configured.

### Execution environments

| Environment | Where code runs | Use case |
| --- | --- | --- |
| Local | Your machine | Default; full access to files and tools |
| Cloud | Anthropic-managed VMs | Long tasks, repos you don't have locally |
| Remote Control | Your machine, driven from a browser | Use the web UI while keeping work local |

### Sessions and context

- Sessions are saved as JSONL under `~/.claude/projects/` and are tied to the directory
- Resume with `claude --continue` or `claude --resume`; branch with `--fork-session`
- Every file edit is checkpointed; press `Esc` twice to rewind
- Permission modes (cycle with `Shift+Tab`): Default, Auto-accept edits, Plan mode, Auto mode
- Use `/context` to inspect context usage, `/compact` to compact, `/model` to switch models

### Verify and update

```bash
claude --version    # confirm install
claude doctor       # diagnose installation
claude update       # apply pending update
```

Configure the auto-update channel (`latest` or `stable`) via `/config` or `autoUpdatesChannel` in `settings.json`. Disable updates by setting `DISABLE_AUTOUPDATER=1` in the `env` block.

### Common integrations and remote access

| Want to... | Use |
| --- | --- |
| Continue a local session from your phone | Remote Control |
| Push events from chat apps or webhooks | Channels |
| Run on a recurring schedule | Routines, Desktop scheduled tasks, or `/loop` |
| Automate PR review and triage | GitHub Actions or GitLab CI/CD |
| Mention Claude in team chat | Slack integration |
| Debug live web apps | Claude in Chrome |
| Build custom agents | Agent SDK |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — What Claude Code is, install entry points for every surface, and what you can do with it.
- [Quickstart](references/claude-code-quickstart.md) — First-run walkthrough: install, log in, and complete your first real task.
- [Advanced setup](references/claude-code-setup.md) — System requirements, platform-specific install (Windows, WSL, Alpine), version pinning, npm migration, binary verification, and uninstall.
- [Authentication](references/claude-code-authentication.md) — Account types, team setup, credential storage, authentication precedence, and long-lived OAuth tokens for CI.
- [How Claude Code works](references/claude-code-how-it-works.md) — The agentic loop, built-in tools, sessions, checkpoints, permission modes, context window, and tips for working effectively.
- [Platforms and integrations](references/claude-code-platforms.md) — Comparison of every place Claude Code runs (CLI, Desktop, VS Code, JetBrains, web, mobile) and the integrations that connect it to your tools.

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
