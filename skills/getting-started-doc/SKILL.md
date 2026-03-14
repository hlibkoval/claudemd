---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview (installation across Terminal/VS Code/Desktop/Web/JetBrains, capabilities summary, surface comparison table), quickstart (step-by-step first session walkthrough, first code change, git workflows, essential CLI commands, beginner tips), advanced setup (system requirements per OS, platform-specific installation with Native/Homebrew/WinGet, Windows setup with Git Bash/WSL, Alpine/musl dependencies, auto-updates and release channels latest/stable, specific version installation, npm-to-native migration, binary integrity and code signing, uninstallation per method, config file removal), authentication (login flow with browser prompt, account types Pro/Max/Teams/Enterprise/Console/cloud providers, team setup for Teams/Enterprise/Console/Bedrock/Vertex/Foundry, credential management with macOS Keychain, apiKeyHelper with refresh intervals), and how Claude Code works (agentic loop gather-context/take-action/verify-results, models Sonnet/Opus and /model switching, tool categories file-ops/search/execution/web/code-intelligence, what Claude can access project/terminal/git/CLAUDE.md/auto-memory/extensions, execution environments local/cloud/remote-control, sessions resume/fork/context-window, checkpoints and permissions, tips for effective use be-specific/verify/explore-first/delegate). Load when discussing Claude Code installation, getting started, quickstart, first session, setup, system requirements, authentication, login, credential management, how Claude Code works, the agentic loop, built-in tools, sessions, context window, checkpoints, permission modes, plan mode, working effectively with Claude Code, or beginner guidance.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: overview, quickstart, advanced setup, authentication, and how Claude Code works.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |

Windows requires [Git for Windows](https://git-scm.com/downloads/win).

### System Requirements

| Component | Requirement |
|:----------|:------------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |

### Available Surfaces

| Surface | Description |
|:--------|:------------|
| Terminal CLI | Full-featured CLI, `claude` command |
| VS Code | Extension with inline diffs, @-mentions, plan review |
| JetBrains | Plugin for IntelliJ, PyCharm, WebStorm, etc. |
| Desktop app | Standalone app for macOS and Windows |
| Web | Browser-based at [claude.ai/code](https://claude.ai/code), no local setup |
| Slack | Route coding requests from team chat |
| CI/CD | GitHub Actions, GitLab CI/CD |

### Authentication

| Account Type | How to Authenticate |
|:-------------|:-------------------|
| Claude Pro/Max | Log in with Claude.ai account via browser prompt |
| Teams/Enterprise | Log in with team-admin-invited Claude.ai account |
| Claude Console | Log in with Console credentials (admin must invite first) |
| Amazon Bedrock | Set environment variables, no browser login needed |
| Google Vertex AI | Set environment variables, no browser login needed |
| Microsoft Foundry | Set environment variables, no browser login needed |

Login: run `claude`, follow browser prompt on first launch. Re-authenticate: `/logout` then `/login`.

Credentials stored in macOS Keychain (on macOS). Custom credential scripts via `apiKeyHelper` setting with configurable refresh via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

### Essential CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Check installed version |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Manually apply updates |

### The Agentic Loop

Claude Code works through three blending phases: **gather context** (search files, read code), **take action** (edit files, run commands), and **verify results** (run tests, check output). The loop repeats until the task is complete. You can interrupt at any point to steer.

### Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Shell commands, servers, tests, git |
| Web | Web search, fetch documentation |
| Code intelligence | Type errors, go-to-definition, find references (via plugins) |

### What Claude Can Access

When you run `claude` in a directory, Claude has access to: your project files, your terminal (any command you could run), git state, CLAUDE.md instructions, auto memory (first 200 lines of MEMORY.md), and configured extensions (MCP servers, skills, subagents).

### Sessions

| Feature | Detail |
|:--------|:-------|
| Resume | `claude --continue` or `claude --resume` to pick up where you left off |
| Fork | `claude --continue --fork-session` to branch without affecting original |
| Context window | Holds conversation, files, outputs, CLAUDE.md, skills; auto-compacts when full |
| `/context` | See what is using context space |
| `/compact` | Manually compact with optional focus |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files without asking, still asks for commands |
| Plan mode | Read-only tools only, creates an approvable plan |

### Updates and Release Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week delay, skips releases with major regressions |

Configure via `/config` or `autoUpdatesChannel` in settings.json. Disable auto-updates with `DISABLE_AUTOUPDATER: "1"` in settings env.

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | Remove `claude.exe` and `~\.local\share\claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm (deprecated) | `npm uninstall -g @anthropic-ai/claude-code` |
| Config files | Remove `~/.claude`, `~/.claude.json`, and project `.claude/` + `.mcp.json` |

### Tips for Effective Use

- **Be specific upfront**: reference files, mention constraints, point to patterns
- **Give verification targets**: include test cases or expected output so Claude can check its work
- **Explore before implementing**: use plan mode to analyze first, then implement
- **Delegate, don't dictate**: give context and direction, let Claude figure out details
- **Iterate conversationally**: refine through back-and-forth rather than crafting perfect prompts
- **Use `/init`** to create a CLAUDE.md, **`/doctor`** to diagnose issues, **`/agents`** for subagent setup

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, installation across all surfaces (Terminal/VS Code/Desktop/Web/JetBrains), capabilities (automation, features, bugs, commits/PRs, MCP integrations, CLAUDE.md customization, agent teams, CLI piping/scripting, cross-surface workflows), surface comparison table, next steps
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session (install, login, start session, first question, first code change, git operations, bug fixes/features, refactoring/tests/docs/review), essential commands table, pro tips for beginners (be specific, step-by-step instructions, explore first, keyboard shortcuts)
- [Advanced setup](references/claude-code-setup.md) -- system requirements per OS, platform-specific installation (Native/Homebrew/WinGet), Windows setup (Git Bash/WSL), Alpine/musl dependencies, verification with claude doctor, auto-updates and release channels (latest/stable), disable auto-updates, manual update, specific version installation, npm deprecation and migration, binary integrity and code signing, uninstallation per method, config file removal
- [Authentication](references/claude-code-authentication.md) -- login flow (browser prompt, /login /logout), account types (Pro/Max/Teams/Enterprise/Console/cloud providers), team setup for Teams/Enterprise/Console/Bedrock/Vertex/Foundry, credential management (macOS Keychain, apiKeyHelper, refresh intervals)
- [How Claude Code works](references/claude-code-how-it-works.md) -- the agentic loop (gather context/take action/verify results), models (Sonnet/Opus, /model switching), tool categories (file ops/search/execution/web/code intelligence), extending with skills/MCP/hooks/subagents, what Claude can access, execution environments (local/cloud/remote control), interfaces, sessions (resume/fork, context window, compaction, /context, /compact), checkpoints and undo, permission modes (default/auto-accept/plan), tips for effective use (be specific, verify, explore first, delegate)

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
