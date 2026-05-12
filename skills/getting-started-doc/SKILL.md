---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, setup and installation, authentication, how Claude Code works (agentic loop, tools, sessions), platforms and integrations, the /goal command, glossary, champion kit, and communications kit.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with development tools. Available in the terminal CLI, VS Code, JetBrains IDEs, Desktop app, and browser (claude.ai/code).

### Installation

| Method | Command |
| :----- | :------ |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Linux package managers: apt (Debian/Ubuntu), dnf (Fedora/RHEL), apk (Alpine) — see setup reference for signed repo instructions.

Native installs auto-update. Homebrew, WinGet, and Linux package manager installs require manual upgrades.

### System Requirements

| Requirement | Detail |
| :---------- | :----- |
| OS | macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Network | Internet connection required |

### First Run

```bash
cd your-project
claude          # start interactive session (prompts login on first run)
claude --version
claude doctor   # diagnose installation issues
```

### Authentication

| Account Type | How to log in |
| :----------- | :------------ |
| Claude Pro / Max | claude.ai account via browser OAuth |
| Claude for Teams / Enterprise | claude.ai account invited by team admin |
| Claude Console | Console credentials (API-based billing) |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK=1` + provider env vars |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX=1` + provider env vars |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY=1` + provider env vars |

**Authentication precedence** (highest to lowest): cloud provider env vars → `ANTHROPIC_AUTH_TOKEN` → `ANTHROPIC_API_KEY` → `apiKeyHelper` script → `CLAUDE_CODE_OAUTH_TOKEN` → subscription OAuth (`/login`).

**Credential storage:** macOS Keychain; Linux `~/.claude/.credentials.json` (mode 0600); Windows `%USERPROFILE%\.claude\.credentials.json`.

**Long-lived token for CI:** `claude setup-token` → set `CLAUDE_CODE_OAUTH_TOKEN`.

### Key CLI Commands

| Command | Description |
| :------ | :---------- |
| `claude` | Start interactive session |
| `claude "task"` | Run one-time task |
| `claude -p "query"` | Non-interactive query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `/clear` | Start new conversation |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out |
| `/model` | Switch model |
| `/context` | See context window usage |
| `/compact` | Manually compact context |
| `exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop

Claude works through three phases for every task: **gather context → take action → verify results → repeat**. Built-in tool categories:

| Category | Capabilities |
| :------- | :----------- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search web, fetch docs, look up errors |
| Code intelligence | Type errors, definitions, references (requires plugins) |

### Platforms

| Platform | Best for | Notable features |
| :------- | :------- | :--------------- |
| CLI | Terminal workflows, scripting | Full feature set, Agent SDK, third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, Dispatch |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ/PyCharm/WebStorm | Diff viewer, selection sharing |
| Web (claude.ai/code) | Long-running or offline tasks | Anthropic-managed cloud, persists when disconnected |
| Mobile | Starting/monitoring away from desk | Cloud sessions, Remote Control, Dispatch |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :------- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | File edits + common filesystem commands flow through; asks for others |
| Plan mode | Read-only exploration; presents plan for approval before any edits |
| Auto mode | Background safety classifier approves/blocks (research preview) |

### Sessions and Context

- Sessions are saved under `~/.claude/projects/` as JSONL
- Each session has its own independent context window
- Resume with `claude --continue` or `claude --resume`; fork with `--fork-session`
- Context holds: conversation history, file contents, command outputs, CLAUDE.md, auto memory, skills, system instructions
- Auto-compaction triggers near context limit; `/compact [focus]` to trigger manually
- `Esc` twice to rewind to a previous checkpoint (file changes only; not external side effects)

### /goal Command

Set a completion condition; Claude keeps working across turns until met:

```text
/goal all tests in test/auth pass and the lint step is clean
```

| /goal usage | Effect |
| :---------- | :----- |
| `/goal <condition>` | Set/replace active goal; starts working immediately |
| `/goal` | Check status (turns, tokens, last evaluator reason) |
| `/goal clear` | Remove active goal |

Evaluator uses a small fast model (Haiku by default) to check if condition is met after each turn. Goals persist across session resume. Works in non-interactive mode: `claude -p "/goal CHANGELOG.md has an entry for every PR merged this week"`.

### Glossary — Key Terms

| Term | Definition |
| :--- | :---------- |
| Agentic loop | Gather context → take action → verify results cycle |
| Agentic harness | Tools, context management, and execution environment around Claude |
| CLAUDE.md | Markdown file of persistent instructions loaded every session |
| Auto memory | Notes Claude writes itself per git repo, stored in `~/.claude/projects/` |
| Compaction | Auto-summarization when context window fills up |
| Checkpoint | Automatic file snapshot before each Claude edit; rewind with `Esc` twice |
| Session | One conversation tied to your current directory with its own context |
| Skill | SKILL.md file containing instructions/workflow Claude adds to its toolkit |
| Hook | User-defined handler at specific lifecycle points (deterministic) |
| MCP | Model Context Protocol — open standard for connecting to external services |
| Plugin | Bundle of skills, hooks, subagents, MCP servers as an installable unit |
| Subagent | AI assistant with its own context window for delegated tasks |
| Non-interactive mode | `-p` flag: single prompt then exit (formerly "headless mode") |
| Bare mode | `--bare`: skip hooks, skills, plugins, CLAUDE.md — for reproducible CI |
| Teleport | `/teleport` pulls a cloud session into local terminal |
| Remote Control | Drive a local session from browser or mobile via claude.ai |
| Dispatch | Phone-initiated task that spawns a Desktop session |
| Worktree isolation | Run in separate git worktree (`-w`) for parallel agent isolation |

### Update and Uninstall

| Action | Command |
| :----- | :------ |
| Manual update | `claude update` |
| Check version | `claude --version` |
| Uninstall (native, macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Uninstall (Homebrew stable) | `brew uninstall --cask claude-code` |
| Uninstall (npm) | `npm uninstall -g @anthropic-ai/claude-code` |
| Remove all config/history | `rm -rf ~/.claude && rm ~/.claude.json` |

Release channels: `"latest"` (default) or `"stable"` (≈1 week delayed). Configure via `/config` or `autoUpdatesChannel` in settings.json.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — what Claude Code is, surfaces, installation, capabilities, next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session, essential commands, beginner tips
- [Advanced Setup](references/claude-code-setup.md) — system requirements, platform-specific install, updates, release channels, uninstall, binary integrity verification
- [Authentication](references/claude-code-authentication.md) — login, team setup, credential management, authentication precedence, long-lived tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, sessions, context window, checkpoints, permission modes, effective usage tips
- [Platforms and Integrations](references/claude-code-platforms.md) — platform comparison, integrations (Chrome, GitHub Actions, GitLab, Slack, Code Review), remote access options
- [Keep Claude Working Toward a Goal](references/claude-code-goal.md) — /goal command, writing effective conditions, evaluation, non-interactive use
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terminology with links to in-depth docs
- [Champion Kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally: sharing, answering questions, 30-day adoption plan
- [Communications Kit](references/claude-code-communications-kit.md) — launch announcements, drip-campaign tips, FAQ responses for rolling out to an engineering org

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Keep Claude Working Toward a Goal: https://code.claude.com/docs/en/goal.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
