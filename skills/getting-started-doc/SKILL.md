---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, installation, system requirements, authentication, the agentic loop, built-in tools, sessions, permissions, and platform/integration comparison.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### Installation methods

| Method | Command | Auto-updates |
| :----- | :------ | :----------- |
| **Native (macOS/Linux/WSL)** | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native (Windows PS)** | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native (Windows CMD)** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew (stable)** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **Homebrew (latest)** | `brew install --cask claude-code@latest` | No (`brew upgrade claude-code@latest`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |

Native Windows requires [Git for Windows](https://git-scm.com/downloads/win). WSL does not.

### System requirements

| Requirement | Detail |
| :---------- | :----- |
| **OS** | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **Hardware** | 4 GB+ RAM, x64 or ARM64 |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

### Authentication methods (precedence order)

| Priority | Method | Use case |
| :------- | :----- | :------- |
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `_VERTEX`, `_FOUNDRY`) | Bedrock, Vertex AI, or Foundry |
| 2 | `ANTHROPIC_AUTH_TOKEN` env var | LLM gateway / proxy with bearer tokens |
| 3 | `ANTHROPIC_API_KEY` env var | Direct Anthropic API access |
| 4 | `apiKeyHelper` script | Dynamic / rotating credentials from a vault |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` env var | CI pipelines (`claude setup-token`) |
| 6 | Subscription OAuth (`/login`) | Default for Pro, Max, Team, Enterprise |

Credentials stored in macOS Keychain (macOS) or `~/.claude/.credentials.json` (Linux/Windows).

### Essential CLI commands

| Command | What it does |
| :------ | :----------- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Check installed version |
| `claude update` | Manual update |
| `claude doctor` | Diagnose installation issues |

### The agentic loop

Claude Code works through three blended phases: **gather context** (search, read files), **take action** (edit, run commands), and **verify results** (run tests, check output). It chains actions automatically based on what it learns at each step, and you can interrupt at any point.

### Built-in tool categories

| Category | Capabilities |
| :------- | :----------- |
| **File operations** | Read, edit, create, rename, reorganize files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up errors |
| **Code intelligence** | Type errors, jump to definitions, find references (via plugins) |

### Permission modes (cycle with Shift+Tab)

| Mode | Behavior |
| :--- | :------- |
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files without asking; still asks for other commands |
| **Plan mode** | Read-only tools only; creates a plan for approval |
| **Auto mode** | Evaluates all actions with background safety checks (research preview) |

### Sessions

- Each session starts with a fresh context window (no conversation history from prior sessions)
- Sessions saved locally as JSONL under `~/.claude/projects/`
- `claude --continue` resumes the latest session; `claude --resume` lets you pick one
- `claude --continue --fork-session` branches a session without affecting the original
- File checkpoints: every edit is snapshotted and reversible (press Esc twice to rewind)
- Run `/context` to see what is using context space; `/compact` to summarize and reclaim

### Release channels

| Channel | Behavior |
| :------ | :------- |
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week behind, skips releases with major regressions |

Configure via `/config` or `"autoUpdatesChannel"` in settings.json. Pin a floor with `"minimumVersion"`. Disable auto-updates with `DISABLE_AUTOUPDATER=1`.

### Platforms at a glance

| Platform | Best for |
| :------- | :------- |
| **CLI** | Terminal workflows, scripting, remote servers, Agent SDK, third-party providers |
| **Desktop** | Visual diff review, parallel sessions, computer use, Dispatch |
| **VS Code** | Working inside VS Code without switching to terminal |
| **JetBrains** | IntelliJ, PyCharm, WebStorm, other JetBrains IDEs |
| **Web** | Long-running tasks, cloud execution, works when disconnected |
| **Mobile** | Starting/monitoring tasks via iOS/Android app, Remote Control |

Configuration, project memory, and MCP servers are shared across all local surfaces.

### Integrations

| Integration | Purpose |
| :---------- | :------ |
| **Chrome** | Browser automation with logged-in sessions |
| **GitHub Actions** | CI-driven PR reviews, issue triage, automation |
| **GitLab CI/CD** | Same as GitHub Actions for GitLab |
| **Code Review** | Automatic review on every PR |
| **Slack** | `@Claude` mentions in channels produce PRs from bug reports |
| **MCP servers** | Connect external services (Linear, Notion, Google Drive, custom APIs) |

### Working tips

- Be specific upfront: reference files, mention constraints, point to example patterns
- Give Claude something to verify against (test cases, expected output, screenshots)
- Explore before implementing: use plan mode to analyze, then implement
- Delegate, don't dictate: provide context and direction, let Claude figure out the details
- Use `/init` to create a CLAUDE.md; use CLAUDE.md for persistent project instructions

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — What Claude Code is, installation options across Terminal/VS Code/Desktop/Web/JetBrains, what you can do (automate tasks, build features, fix bugs, create commits/PRs, connect tools via MCP, customize with CLAUDE.md/skills/hooks, run agent teams, pipe and script, schedule recurring tasks, work from anywhere), and platform/integration comparison table.
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step guide from install through login, first session, first question, first code change, git operations, bug fixing, common workflows (refactor, tests, docs, code review), essential commands table, and pro tips for beginners.
- [Advanced setup](references/claude-code-setup.md) — System requirements, platform-specific installation (Windows native vs WSL, Alpine/musl), verification with `claude doctor`, authentication overview, auto-updates, release channels, version pinning, minimum version floor, disabling auto-updates, installing specific versions, npm migration, binary integrity and code signing (GPG manifest verification, platform signatures), and uninstallation for all methods.
- [Authentication](references/claude-code-authentication.md) — Login flow, account types (Pro/Max/Teams/Enterprise/Console/cloud providers), team setup (Teams, Enterprise, Console, cloud providers), credential management (storage, auth precedence, `apiKeyHelper`, refresh intervals), and generating long-lived OAuth tokens with `claude setup-token`.
- [How Claude Code works](references/claude-code-how-it-works.md) — The agentic loop (gather context, take action, verify results), models and tool use, built-in tool categories, extending with skills/MCP/hooks/subagents, what Claude can access, execution environments (local/cloud/Remote Control), sessions (resume, fork, context window, compaction), checkpoints, permission modes, and tips for working effectively.
- [Platforms and integrations](references/claude-code-platforms.md) — Comparison of CLI, Desktop, VS Code, JetBrains, Web, and Mobile platforms; integration table (Chrome, GitHub Actions, GitLab CI/CD, Code Review, Slack); remote work options (Dispatch, Remote Control, Channels, Slack, scheduled tasks) with trigger, runtime, and setup details.

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
