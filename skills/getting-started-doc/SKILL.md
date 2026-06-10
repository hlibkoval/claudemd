---
name: getting-started-doc
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code, including installation, authentication, how the tool works, available platforms, and key concepts.

## Quick Reference

### Installation

| Method | Command |
|--------|---------|
| macOS / Linux / WSL (native) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell (native) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Linux package managers (apt, dnf, apk) are also supported with signed repositories.

**Verify:** `claude --version` or `claude doctor`

### System Requirements

| Item | Requirement |
|------|-------------|
| OS | macOS 13+, Windows 10 1809+/Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Network | Internet required |
| Shell | Bash, Zsh, PowerShell, or CMD |

### Authentication Methods (in precedence order)

| Priority | Method | When to use |
|----------|--------|-------------|
| 1 | `CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` / `CLAUDE_CODE_USE_FOUNDRY` env vars | Enterprise cloud providers |
| 2 | `ANTHROPIC_AUTH_TOKEN` env var | LLM gateway / proxy with bearer tokens |
| 3 | `ANTHROPIC_API_KEY` env var | Direct Anthropic API key from Console |
| 4 | `apiKeyHelper` script | Dynamic / rotating credentials |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` env var | CI pipelines (generated via `claude setup-token`) |
| 6 | Subscription OAuth from `/login` | Default for Pro, Max, Team, Enterprise |

**Credential storage:** macOS Keychain; Linux `~/.claude/.credentials.json` (mode 0600); Windows `%USERPROFILE%\.claude\.credentials.json`.

**Team setup options:** Claude for Teams, Claude for Enterprise (SSO/compliance), Claude Console, or cloud providers (Bedrock, Vertex AI, Microsoft Foundry).

### Essential CLI Commands

| Command | Description |
|---------|-------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Apply an update immediately |
| `claude doctor` | Diagnose installation issues |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `/help` | Show available commands |
| `/login` / `/logout` | Switch accounts |
| `/clear` | Clear conversation history |
| `/model` | Switch model mid-session |
| `/context` | See what is using context space |
| `/compact` | Manually trigger context compaction |
| `/resume` | Resume or fork a previous session |
| `/init` | Generate a CLAUDE.md for the current project |
| `/goal <condition>` | Set a completion condition (v2.1.139+) |

### The Agentic Loop

Claude works through three phases for every task:

1. **Gather context** — reads files, searches the codebase, loads CLAUDE.md and auto memory
2. **Take action** — edits files, runs commands, calls external tools
3. **Verify results** — runs tests, checks output, course-corrects

The loop repeats until the task is done. You can interrupt at any point with `Esc`.

### Built-in Tool Categories

| Category | What Claude can do |
|----------|--------------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump to definitions, find references (requires plugins) |

### Permission Modes (`Shift+Tab` to cycle)

| Mode | Behavior |
|------|----------|
| Default | Claude asks before file edits and shell commands |
| Auto-accept edits | File edits and common filesystem commands flow through; other commands still prompt |
| Plan mode | Claude proposes a plan without editing source files |
| Auto mode | Background safety classifier approves most actions (research preview) |

### Execution Environments

| Environment | Where code runs | Use case |
|-------------|----------------|----------|
| Local | Your machine | Default; full access to files, tools, environment |
| Cloud | Anthropic-managed VMs | Long-running tasks; continues when you disconnect |
| Remote Control | Your machine, controlled from browser | Web UI with local execution |

### Platforms at a Glance

| Platform | Best for |
|----------|---------|
| CLI | Terminal workflows, scripting, full feature set |
| Desktop | Visual diff review, parallel sessions, Dispatch |
| VS Code | Inline diffs, editor integration |
| JetBrains | IntelliJ, PyCharm, WebStorm integration |
| Web | Long-running cloud tasks, no local setup |
| Mobile | Starting/monitoring tasks remotely |

### `/goal` Command

Sets a completion condition; Claude keeps working across turns until a separate evaluator model confirms the condition is met.

```
/goal all tests in test/auth pass and the lint step is clean
/goal                   # check status
/goal clear             # remove the active goal
```

An effective condition has: one measurable end state, a stated check Claude can run, and any constraints. Conditions up to 4,000 characters. Requires v2.1.139+; only works in trusted workspaces.

### Key Concepts

| Term | Definition |
|------|-----------|
| CLAUDE.md | Persistent instruction file loaded every session; put conventions, build commands, architecture notes here |
| Auto memory | Notes Claude writes for itself per repo under `~/.claude/projects/`; survives compaction |
| Session | A conversation tied to a directory with its own context window; stored in `~/.claude/projects/` |
| Compaction | Automatic summarization when context window fills; CLAUDE.md and auto memory survive it |
| Checkpoint | File snapshot before each edit; press `Esc` twice or `/rewind` to restore |
| Skill | SKILL.md file with instructions/workflow Claude can invoke via `/skill-name` |
| Hook | Shell command / script fired automatically at lifecycle points (before tool run, after edit, etc.) |
| MCP | Model Context Protocol; open standard for connecting Claude to external services |
| Subagent | Specialized assistant with own context window; delegated tasks don't bloat main context |
| Plugin | Bundle of skills, hooks, subagents, and MCP servers as an installable unit |

### Uninstall

| Method | Command |
|--------|---------|
| Native (macOS/Linux/WSL) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config files | `rm -rf ~/.claude && rm ~/.claude.json` (warning: deletes all settings and history) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — what Claude Code is, how to get started, available surfaces and integrations
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session walkthrough, essential commands, beginner tips
- [Advanced Setup](references/claude-code-setup.md) — system requirements, install methods, update channels, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — login flow, team auth setup, credential management, long-lived tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, sessions, context window, permissions
- [Platforms and Integrations](references/claude-code-platforms.md) — choosing a platform, connecting tools, remote access options
- [Goal](references/claude-code-goal.md) — `/goal` command reference: set completion conditions, evaluation mechanics
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terminology
- [Champion Kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally
- [Communications Kit](references/claude-code-communications-kit.md) — launch announcements, drip-campaign messages, FAQ responses for org rollout

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Goal: https://code.claude.com/docs/en/goal.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
