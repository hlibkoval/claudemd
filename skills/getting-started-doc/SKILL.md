---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup, authentication, how it works (agentic loop, tools, sessions), platforms and integrations, glossary, and team adoption kits.
user-invocable: false
---

# Getting Started with Claude Code Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### Installation Commands

| Platform | Method | Command |
| :--- | :--- | :--- |
| macOS / Linux / WSL | Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | Native (recommended) | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | Native | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| macOS / Linux | Homebrew (stable) | `brew install --cask claude-code` |
| macOS / Linux | Homebrew (latest) | `brew install --cask claude-code@latest` |
| Windows | WinGet | `winget install Anthropic.ClaudeCode` |
| Any | npm | `npm install -g @anthropic-ai/claude-code` |
| Debian / Ubuntu | apt | See setup doc — signed repo at `downloads.claude.ai` |
| Fedora / RHEL | dnf | See setup doc — signed repo at `downloads.claude.ai` |
| Alpine | apk | Requires `libgcc libstdc++ ripgrep` + `USE_BUILTIN_RIPGREP=0` |

Native installs auto-update. Homebrew, WinGet, and Linux package managers require manual upgrades.

### System Requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD. Git for Windows recommended on native Windows. |
| Network | Internet connection required |

### Authentication Methods (precedence order)

| Priority | Method | Notes |
| :--- | :--- | :--- |
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `_VERTEX`, `_FOUNDRY`) | For AWS/GCP/Azure |
| 2 | `ANTHROPIC_AUTH_TOKEN` | Bearer token, use with LLM gateways/proxies |
| 3 | `ANTHROPIC_API_KEY` | Direct Anthropic API key from Console |
| 4 | `apiKeyHelper` script | Dynamic/rotating credentials |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` | Long-lived token from `claude setup-token` for CI |
| 6 | Subscription OAuth (`/login`) | Default for Pro / Max / Team / Enterprise |

Plans required: Pro, Max, Team, Enterprise, or Console API. Free plan does not include Claude Code.

### Key CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive single query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Manually apply latest update |
| `claude --version` | Show installed version |
| `claude doctor` | Diagnose installation issues |
| `claude setup-token` | Generate a long-lived OAuth token for CI |

### In-session Commands

| Command | What it does |
| :--- | :--- |
| `/help` | Show available commands |
| `/clear` | Clear conversation history (start new session) |
| `/login` / `/logout` | Switch or remove authentication |
| `/model` | Change model mid-session |
| `/init` | Generate CLAUDE.md from your project |
| `/resume` | Pick a previous session to continue |
| `/compact` | Manually trigger context compaction |
| `/context` | Show what is using context space |
| `/plan` | Enter plan mode (read-only exploration) |
| `Shift+Tab` | Cycle permission modes |
| `Esc Esc` | Rewind to a previous checkpoint |

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and common filesystem commands without asking |
| Plan mode | Read-only tools only; proposes a plan before any edits |
| Auto mode | Background classifier reviews each action (research preview; Max/Team/Enterprise/API) |

### The Agentic Loop (How Claude Code Works)

Three phases repeat until done:
1. **Gather context** — read files, search, understand the codebase
2. **Take action** — edit files, run commands, call tools
3. **Verify results** — run tests, check output, adjust

### Built-in Tool Categories

| Category | Capabilities |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, definitions, references (requires plugins) |

### Platforms and Surfaces

| Surface | Best for |
| :--- | :--- |
| CLI (Terminal) | Full feature set, scripting, Agent SDK, remote servers |
| Desktop app | Visual diff review, parallel sessions, computer use |
| VS Code extension | Inline diffs, integrated terminal, no context-switching |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm — diff viewer, selection sharing |
| Web (claude.ai/code) | Long-running cloud tasks that continue when offline |
| Mobile | Starting/monitoring cloud tasks or Remote Control of local sessions |

### Session Management

| Concept | Details |
| :--- | :--- |
| Sessions | Tied to current directory; independent context windows |
| Resume | `claude -c` (latest) or `claude -r` (picker) |
| Fork | `--fork-session` or `/branch` — copies history into new session ID |
| Checkpoints | Automatic per-edit snapshots; rewind with `Esc Esc` or `/rewind` |
| Context window | Filled by conversation, files, CLAUDE.md, auto memory, skills |
| Compaction | Auto-summarizes when context fills; CLAUDE.md survives and reloads |

### Update / Uninstall Commands

| Method | Upgrade | Uninstall |
| :--- | :--- | :--- |
| Native (macOS/Linux) | `claude update` | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew stable | `brew upgrade claude-code` | `brew uninstall --cask claude-code` |
| Homebrew latest | `brew upgrade claude-code@latest` | `brew uninstall --cask claude-code@latest` |
| WinGet | `winget upgrade Anthropic.ClaudeCode` | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` | `npm uninstall -g @anthropic-ai/claude-code` |
| apt | `sudo apt update && sudo apt upgrade claude-code` | `sudo apt remove claude-code` |
| dnf | `sudo dnf upgrade claude-code` | `sudo dnf remove claude-code` |
| apk | `apk update && apk upgrade claude-code` | `apk del claude-code` |

### Release Channel Settings

```json
{
  "autoUpdatesChannel": "stable",
  "minimumVersion": "2.1.100"
}
```

`"latest"` (default) or `"stable"` (roughly one week behind, skips regressions).

### Glossary: Key Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeating until done |
| Agentic harness | Tools + context management + execution environment that wraps the model |
| CLAUDE.md | Markdown file of persistent instructions loaded every session |
| Auto memory | Notes Claude writes per-repo in `~/.claude/projects/`; first 200 lines load at start |
| Checkpoint | Per-edit file snapshot; rewind with `Esc Esc` |
| Compaction | Auto-summarization when context fills; CLAUDE.md and auto memory survive |
| Skill | SKILL.md file adding instructions or workflow to Claude's toolkit |
| Hook | Shell command / HTTP / MCP tool / prompt that fires at lifecycle events |
| MCP | Model Context Protocol — open standard for connecting Claude to external services |
| Subagent | Specialized Claude agent with its own context window and tool access |
| Plan mode | Read-only permission mode; Claude proposes before editing |
| Auto mode | Background classifier approves/blocks actions (research preview) |
| Bare mode | `--bare` flag; skips auto-discovery of hooks, skills, MCP, CLAUDE.md |
| Non-interactive mode | `-p` / `--print`; single prompt then exits (formerly "headless mode") |
| Surface | Any interface: CLI, Desktop, VS Code, JetBrains, Web, Mobile |
| Session | Conversation tied to a directory, stored under `~/.claude/projects/` |
| Worktree isolation | `-w` flag; runs Claude in a separate git worktree to avoid file conflicts |
| Remote Control | Drive a local CLI session from a browser or mobile device |
| Dispatch | Phone-initiated task routing that spawns a Desktop session |
| Teleport | `/teleport` pulls a cloud session into local terminal |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — product overview, installation configurator, what you can do, surfaces summary
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, login, explore, edit, git, tips
- [Advanced Setup](references/claude-code-setup.md) — system requirements, platform-specific install, updates, channels, uninstall, binary verification
- [Authentication](references/claude-code-authentication.md) — login methods, team setup (Teams/Enterprise/Console/cloud providers), credential management, CI tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — agentic loop, models, tools, sessions, context window, permissions, effective usage tips
- [Platforms and Integrations](references/claude-code-platforms.md) — surface comparison table, integrations (Chrome, GitHub Actions, GitLab, Slack), remote/away-from-terminal options
- [Champion Kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code adoption internally
- [Communications Kit](references/claude-code-communications-kit.md) — launch announcements, drip campaigns, FAQ responses for org rollouts
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms with links to depth pages

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
- Glossary: https://code.claude.com/docs/en/glossary.md
