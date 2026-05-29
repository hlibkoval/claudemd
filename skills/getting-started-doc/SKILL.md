---
name: getting-started-doc
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: overview, installation, quickstart, authentication, how it works, platforms, the `/goal` command, and team adoption resources.

## Quick Reference

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Homebrew (stable) | `brew install --cask claude-code` | No (manual: `brew upgrade claude-code`) |
| Homebrew (latest) | `brew install --cask claude-code@latest` | No (manual: `brew upgrade claude-code@latest`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (manual: `winget upgrade Anthropic.ClaudeCode`) |
| npm | `npm install -g @anthropic-ai/claude-code` | No (manual: `npm install -g @anthropic-ai/claude-code@latest`) |
| apt (Debian/Ubuntu) | See setup reference | No (manual: `sudo apt update && sudo apt upgrade claude-code`) |
| dnf (Fedora/RHEL) | See setup reference | No (manual: `sudo dnf upgrade claude-code`) |
| apk (Alpine) | See setup reference | No (manual: `apk update && apk upgrade claude-code`) |

### System Requirements

| Requirement | Details |
|:------------|:--------|
| OS | macOS 13.0+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |

### Authentication Methods (Precedence Order)

| Priority | Method | How |
|:---------|:-------|:----|
| 1 | Cloud provider | `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, or `CLAUDE_CODE_USE_FOUNDRY` env var |
| 2 | `ANTHROPIC_AUTH_TOKEN` | Sent as `Authorization: Bearer` header |
| 3 | `ANTHROPIC_API_KEY` | Sent as `X-Api-Key` header |
| 4 | `apiKeyHelper` script | Dynamic/rotating credentials from a vault |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` | Long-lived token from `claude setup-token` |
| 6 | Subscription OAuth | Default for Pro, Max, Team, Enterprise users |

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query and exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Check installed version |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Apply update immediately |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `/login` | Re-authenticate inside a session |
| `/logout` | Log out inside a session |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `exit` or Ctrl+D | Exit Claude Code |

### Update / Release Channel Settings

| Setting | Values | How to set |
|:--------|:-------|:-----------|
| `autoUpdatesChannel` | `"latest"` (default), `"stable"` | `/config` or `settings.json` |
| `minimumVersion` | version string e.g. `"2.1.100"` | `settings.json` |
| `DISABLE_AUTOUPDATER` | `"1"` to disable background checks | `env` key in `settings.json` |
| `DISABLE_UPDATES` | set to block all update paths | env var |

### Where to Run Claude Code

| Platform | Best for | Key features |
|:---------|:---------|:-------------|
| CLI | Terminal workflows, scripting | Full feature set, Agent SDK, third-party providers |
| Desktop app | Visual review, parallel sessions | Diff viewer, app preview, Dispatch |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing |
| Web (claude.ai/code) | Long-running tasks, offline continuation | Anthropic-managed cloud |
| Mobile | Starting/monitoring tasks away from desk | Cloud sessions, Remote Control, Dispatch |

### How Claude Works: The Agentic Loop

Claude cycles through three phases for every task:

1. **Gather context** — read files, search codebase, understand the state
2. **Take action** — edit files, run commands, call tools
3. **Verify results** — run tests, check output, course-correct

### Built-in Tool Categories

| Category | What Claude can do |
|:---------|:------------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | See type errors, jump to definitions, find references (requires plugin) |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and common filesystem commands without asking |
| Plan mode | Read-only exploration; presents plan for approval before execution |
| Auto mode | Background safety checks evaluate all actions (research preview) |

### Credential Storage Locations

| Platform | Location |
|:---------|:---------|
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode `0600`) |
| Windows | `%USERPROFILE%\.claude\.credentials.json` |

### `/goal` Command Quick Reference

Set a completion condition — Claude keeps working across turns until a separate evaluator model confirms it is met.

| Usage | Command |
|:------|:--------|
| Set a goal | `/goal all tests in test/auth pass and lint is clean` |
| Check status | `/goal` (no arguments) |
| Clear before completion | `/goal clear` |
| Non-interactive | `claude -p "/goal CHANGELOG.md has an entry for every PR merged this week"` |

Effective conditions include one measurable end state, a stated check Claude can run, and any constraints that matter. Conditions can be up to 4,000 characters.

Requires Claude Code v2.1.139+. Unavailable when `disableAllHooks` or `allowManagedHooksOnly` is set.

### Glossary: Core Terms

| Term | Definition |
|:-----|:-----------|
| Agentic loop | Gather context → take action → verify results cycle |
| CLAUDE.md | Markdown file of persistent per-project instructions loaded every session |
| Auto memory | Notes Claude writes for itself, stored at `~/.claude/projects/` |
| Compaction | Automatic summarization when context window fills |
| Checkpoint | Snapshot before each edit; press Esc twice or `/rewind` to restore |
| Skill | SKILL.md file with instructions Claude loads or you invoke with `/name` |
| Hook | Shell command, HTTP endpoint, or prompt that fires at lifecycle points |
| MCP | Model Context Protocol — connects Claude to external tools/services |
| Session | Conversation tied to a directory with its own context window |
| Subagent | Specialist running in its own context window, delegated a task |
| Non-interactive mode | `claude -p` — single prompt, no conversation, used in CI |
| Bare mode | `--bare` — skips auto-discovery of hooks, skills, MCP, CLAUDE.md |
| Plan mode | Read-only mode; proposes changes for approval before executing |
| Permission rule | Allow/ask/deny entry for a tool invocation pattern in `settings.json` |
| Settings layers | managed policy > CLI args > local settings > project settings > user settings |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, surfaces, installation summary, and capabilities
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step first session: install, log in, explore a codebase, make changes, use git
- [Advanced Setup](references/claude-code-setup.md) — System requirements, all install methods, Windows/Alpine details, update channels, version pinning, binary integrity, uninstallation
- [Authentication](references/claude-code-authentication.md) — Login, team auth (Teams/Enterprise/Console/cloud providers), credential management, precedence, long-lived tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — Agentic loop, built-in tools, sessions, context window management, checkpoints, permission modes
- [Platforms and Integrations](references/claude-code-platforms.md) — Compare CLI/Desktop/VS Code/JetBrains/Web/mobile; integrations table; remote-work options
- [Keep Claude Working Toward a Goal](references/claude-code-goal.md) — `/goal` command: set completion conditions, check status, compare to `/loop` and Stop hooks
- [Glossary](references/claude-code-glossary.md) — Definitions for all Claude Code terminology with links to in-depth docs
- [Champion Kit](references/claude-code-champion-kit.md) — Playbook for engineers advocating Claude Code internally: sharing wins, answering questions, 30-day adoption plan
- [Communications Kit](references/claude-code-communications-kit.md) — Launch announcements, drip-campaign messages, FAQ responses, and prompt templates for team rollouts

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Keep Claude Working Toward a Goal: https://code.claude.com/docs/en/goal.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
