---
name: getting-started
description: Reference documentation for installing, authenticating, and using Claude Code. Covers system requirements, installation methods, authentication options, the agentic loop, built-in tools, session management, and effective usage patterns.
user-invocable: false
---

# Getting Started with Claude Code

Claude Code is an agentic coding tool that reads your codebase, edits files, runs commands, and integrates with your development tools. Available in terminal, IDE, desktop app, and browser.

## Installation

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **OS** | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **Hardware** | 4 GB+ RAM |
| **Network** | Internet connection required |
| **Shell** | Bash or Zsh recommended |

### Install Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (recommended)** | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **Windows PowerShell** | `irm https://claude.ai/install.ps1 \| iex` | Yes |

After installing, start Claude Code in any project:

```bash
cd your-project
claude
```

Run `claude doctor` to check your installation. Run `claude update` to update manually.

### Release Channels

Set via `/config` or `settings.json` (`autoUpdatesChannel`):

- `"latest"` (default) -- new features as soon as released
- `"stable"` -- typically one week behind, skipping releases with regressions

Disable auto-updates: `export DISABLE_AUTOUPDATER=1`

### Windows Setup

- **WSL** (recommended): Both WSL 1 and WSL 2 supported. WSL 2 supports sandboxing.
- **Native Windows**: Requires Git Bash. Set `CLAUDE_CODE_GIT_BASH_PATH` for portable Git installs.

### Alpine / musl-based Distros

Requires `libgcc`, `libstdc++`, and `ripgrep`. Install via package manager, then set `USE_BUILTIN_RIPGREP=0`.

## Authentication

### For Individuals

| Method | Details |
|:-------|:--------|
| **Claude Pro/Max** (recommended) | Subscribe at claude.ai/pricing. Unified subscription for Claude Code + web. |
| **Claude Console** | OAuth via console.anthropic.com. Requires active billing. Auto-creates "Claude Code" workspace. |

### For Teams & Organizations

| Method | Details |
|:-------|:--------|
| **Teams/Enterprise** (recommended) | Centralized billing, team management, SSO (Enterprise). |
| **Console with team billing** | Shared org, invite members, assign roles (Claude Code or Developer). |
| **Cloud providers** | Amazon Bedrock, Google Vertex AI, Microsoft Foundry. |

### Credential Management

- **macOS**: Stored in encrypted Keychain.
- **Custom scripts**: Use `apiKeyHelper` setting to return API key from a shell script.
- **Refresh**: `apiKeyHelper` called after 5 min or on HTTP 401. Override with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

Login: run `claude` (first use) or `/login` to switch accounts.

## Available Environments

| Environment | Key feature |
|:------------|:------------|
| **Terminal CLI** | Full-featured CLI, file editing, commands |
| **VS Code / Cursor** | Inline diffs, @-mentions, plan review |
| **JetBrains** | Interactive diffs, selection context |
| **Desktop app** | Visual diff review, multiple sessions, cloud sessions |
| **Web** | No local setup, long-running tasks, parallel tasks |
| **Slack** | Route bug reports to PRs via @Claude |
| **GitHub Actions / GitLab CI** | Automated PR reviews, issue triage |
| **Chrome** | Debug live web applications |

## How Claude Code Works

### The Agentic Loop

Claude works through three phases: **gather context**, **take action**, **verify results**. It chains tool uses together, course-correcting along the way. You can interrupt at any point to steer.

### Built-in Tools

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Shell commands, servers, tests, git |
| **Web** | Search the web, fetch docs, look up errors |
| **Code intelligence** | Type errors, go to definition, find references (via plugins) |

Extend capabilities with skills, MCP servers, hooks, and subagents.

### Models

Multiple models available. Switch with `/model` or `claude --model <name>`. Sonnet for most tasks; Opus for complex reasoning.

## Sessions

### Key Behaviors

- Conversations saved locally. Each session starts with fresh context.
- Persist learnings across sessions via auto memory and CLAUDE.md.
- Sessions are directory-scoped. Use git worktrees for parallel sessions.

### Resume & Fork

| Flag | Behavior |
|:-----|:---------|
| `claude -c` / `claude --continue` | Continue most recent conversation |
| `claude -r` / `claude --resume` | Pick from previous conversations |
| `claude --continue --fork-session` | Branch off with new session ID, original unchanged |

### Context Window

- Holds conversation, file contents, command outputs, CLAUDE.md, skills, system instructions.
- Auto-compacts when full. Persistent rules belong in CLAUDE.md, not conversation.
- Run `/context` to see usage. Run `/mcp` to check per-server costs.
- Skills load on demand. Subagents get their own isolated context.

## Safety & Permissions

### Checkpoints

Every file edit is snapshotted. Press `Esc` twice to rewind. Only covers local file changes, not remote actions.

### Permission Modes (`Shift+Tab` to cycle)

| Mode | Behavior |
|:-----|:---------|
| **Default** | Asks before edits and commands |
| **Auto-accept edits** | Edits without asking, still asks for commands |
| **Plan mode** | Read-only tools, creates plan for approval |
| **Delegate mode** | Coordinates via agent teammates only |

Allow specific commands in `.claude/settings.json` to skip prompts.

## Essential CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run query, print result, exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a git commit |
| `claude update` | Update Claude Code |
| `claude doctor` | Diagnose installation issues |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/compact [focus]` | Compact context with optional focus |
| `/context` | Show context window usage |
| `/init` | Create CLAUDE.md for your project |
| `/model` | Switch model mid-session |
| `/login` | Switch accounts |

## Tips for Effective Use

1. **Be specific upfront** -- reference files, mention constraints, point to patterns.
2. **Give verification targets** -- include test cases, expected output, or screenshots.
3. **Explore before implementing** -- use plan mode to analyze, then implement.
4. **Delegate, don't dictate** -- give context and direction, let Claude figure out details.
5. **Iterate conversationally** -- correct course mid-session instead of starting over.

## Full Documentation

- [Overview](references/claude-code-overview.md) -- capabilities, environments, and use cases
- [Setup](references/claude-code-setup.md) -- installation, updates, and uninstallation
- [Authentication](references/claude-code-authentication.md) -- auth methods and credential management
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough
- [How It Works](references/claude-code-how-it-works.md) -- agentic loop, tools, sessions, and safety

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- How It Works: https://code.claude.com/docs/en/how-claude-code-works.md
