---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview (installation methods, available surfaces, capabilities), quickstart (step-by-step first session, first code change, git usage, essential CLI commands, beginner tips), advanced setup (system requirements, platform-specific installation for macOS/Windows/Linux/Alpine, native/Homebrew/WinGet/npm install, auto-updates, release channels stable/latest, version pinning, npm migration, binary integrity, uninstallation), authentication (login flow, account types Pro/Max/Teams/Enterprise/Console, team setup, Console roles, cloud provider auth for Bedrock/Vertex/Foundry, credential management and macOS Keychain, apiKeyHelper), how Claude Code works (agentic loop phases gather/act/verify, models Sonnet/Opus, built-in tool categories file/search/execution/web/code-intelligence, extending with skills/MCP/hooks/subagents, what Claude can access, execution environments local/cloud/remote-control, sessions resume/fork/context-window, checkpoints and undo, permission modes default/auto-accept/plan, working effectively tips). Load when discussing Claude Code installation, getting started, first session setup, authentication, login, how the agentic loop works, built-in tools, session management, context window, checkpoints, or onboarding new users to Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates | Notes |
|:-------|:--------|:-------------|:------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes | macOS, Linux, WSL |
| Native (Windows PS) | `irm https://claude.ai/install.ps1 \| iex` | Yes | Requires Git for Windows |
| Homebrew | `brew install --cask claude-code` | No | `brew upgrade claude-code` to update |
| WinGet | `winget install Anthropic.ClaudeCode` | No | `winget upgrade Anthropic.ClaudeCode` to update |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No | Requires Node.js 18+; migrate to native |

After installing: `cd your-project && claude`

### System Requirements

| Requirement | Details |
|:------------|:--------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Windows dep | Git for Windows required |

### Available Surfaces

| Surface | Description |
|:--------|:------------|
| Terminal CLI | Full-featured CLI, the primary interface |
| VS Code / Cursor | Extension with inline diffs, @-mentions, plan review |
| JetBrains IDEs | Plugin with interactive diff viewing and selection context |
| Desktop app | Standalone app for visual diff review, multiple sessions, scheduling |
| Web (claude.ai/code) | Browser-based, no local setup needed |
| Slack | Mention @Claude with a bug report, get a PR back |
| GitHub Actions / GitLab CI | Automate PR reviews and issue triage |

### Authentication

| Account type | How to authenticate |
|:-------------|:--------------------|
| Claude Pro / Max | Run `claude`, log in via browser with Claude.ai account |
| Claude Teams / Enterprise | Log in with team-invited Claude.ai account |
| Claude Console | Log in with Console credentials (admin must invite first) |
| Amazon Bedrock | Set env vars before running `claude`; no browser login |
| Google Vertex AI | Set env vars before running `claude`; no browser login |
| Microsoft Foundry | Set env vars before running `claude`; no browser login |

Credentials stored in macOS Keychain (on macOS). Switch accounts with `/login`, log out with `/logout`.

Console roles: **Claude Code** (can only create Claude Code API keys) or **Developer** (can create any API key).

Custom credential scripts: set `apiKeyHelper` in settings to run a shell script that returns an API key. Refresh after 5 min or on HTTP 401; override with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

### Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a git commit |
| `claude update` | Manually apply an update |
| `claude doctor` | Diagnose installation and configuration issues |
| `claude --version` | Verify installation |
| `/help` | Show available commands in session |
| `/clear` | Clear conversation history |
| `/model` | Switch model during session |
| `/init` | Generate a starting CLAUDE.md |
| `/context` | See what is using context space |

### Update and Release Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | Receive features as soon as released |
| `stable` | ~1 week delay, skips releases with major regressions |

Configure via `/config` or in settings.json: `"autoUpdatesChannel": "stable"`. Disable auto-updates with `"env": { "DISABLE_AUTOUPDATER": "1" }`.

### The Agentic Loop

Claude Code works through three blended phases: **gather context** (search files, read code), **take action** (edit files, run commands), and **verify results** (run tests, check output). These phases repeat until the task is complete. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch docs, look up error messages |
| Code intelligence | Type errors/warnings, jump to definition, find references (requires plugins) |

Extend with: skills (packaged workflows), MCP (external tool connections), hooks (shell automations), subagents (parallel task delegation).

### Sessions

| Feature | Details |
|:--------|:--------|
| Resume | `claude -c` (most recent) or `claude -r` (pick from list) |
| Fork | `claude --continue --fork-session` (new ID, preserves history) |
| Context window | Holds conversation, file contents, command outputs, CLAUDE.md, skills |
| Compaction | Automatic when context fills; older tool outputs cleared first |
| `/compact` | Manual compaction; add focus: `/compact focus on the API changes` |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits without asking; still asks for commands |
| Plan mode | Read-only tools only; creates a plan for approval |

Allow specific commands in `.claude/settings.json` to skip repeated approval.

### Checkpoints

Every file edit is snapshotted before changes. Press `Esc` twice to rewind. Checkpoints are local to the session and separate from git. They cover file changes only -- actions affecting remote systems (databases, APIs, deployments) are not checkpointable.

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows PS) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force` and `Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | Remove `~/.claude`, `~/.claude.json`, `.claude/`, `.mcp.json` |

### Tips for Effective Use

- **Be specific upfront**: reference files, mention constraints, point to example patterns
- **Give verification targets**: include test cases or expected output so Claude can self-check
- **Explore before implementing**: use plan mode to analyze the codebase first for complex problems
- **Delegate, don't dictate**: give context and direction, let Claude figure out the details
- **Iterate conversationally**: start with what you want, then refine through follow-up messages

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, installation entry points for all surfaces (terminal, VS Code, desktop, web, JetBrains), capability showcase, integration matrix
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough, first code change, git operations, essential commands table, beginner tips
- [Advanced setup](references/claude-code-setup.md) -- system requirements, platform-specific installation (Windows/Alpine/WSL), native/Homebrew/WinGet/npm methods, auto-updates, release channels, version pinning, npm migration, binary integrity, uninstallation
- [Authentication](references/claude-code-authentication.md) -- login flow, account types, team setup (Teams/Enterprise/Console), Console roles, cloud provider auth (Bedrock/Vertex/Foundry), credential management
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop architecture, models, built-in tool categories, what Claude can access, execution environments, session management, context window, checkpoints, permission modes, tips for effective use

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
