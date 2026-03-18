---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview (install methods for Terminal/VS Code/Desktop/Web/JetBrains, capabilities summary, surface comparison table), quickstart (step-by-step first session walkthrough, install native/Homebrew/WinGet, login with Pro/Max/Teams/Enterprise/Console/cloud providers, first question, first code change, Git operations, bug fixing, refactoring, tests, essential CLI commands table, pro tips), advanced setup (system requirements by OS, Windows setup Git Bash/WSL, Alpine/musl dependencies, verify installation with claude doctor, release channels latest/stable, auto-update config, disable auto-updates, install specific version, npm migration, binary integrity/code signing, uninstall by method, remove config files), authentication (login flow, account types Pro/Max/Teams/Enterprise/Console/cloud, team setup for Teams/Enterprise/Console/Bedrock/Vertex/Foundry, credential management storage locations macOS Keychain/Linux/Windows, apiKeyHelper with TTL and slow helper notice, authentication precedence order cloud>ANTHROPIC_AUTH_TOKEN>ANTHROPIC_API_KEY>apiKeyHelper>OAuth, credential conflicts), how Claude Code works (agentic loop gather/act/verify, models Sonnet/Opus and /model switching, tool categories file-ops/search/execution/web/code-intelligence, extending with skills/MCP/hooks/subagents, what Claude can access project/terminal/git/CLAUDE.md/auto-memory/extensions, execution environments local/cloud/remote-control, interfaces terminal/desktop/IDE/web/slack/CI, sessions independence/branches/resume/fork/fork-session flag, context window management compaction/skills-on-demand/subagent-isolation, checkpoints undo/revert file edits, permission modes default/auto-accept/plan with Shift+Tab, working effectively ask-for-help//init//agents//doctor/be-conversational/interrupt-and-steer/be-specific/verify-against-tests/explore-before-implementing/delegate-dont-dictate). Load when discussing Claude Code installation, getting started, quickstart, first session, system requirements, login, authentication, account types, credential management, apiKeyHelper, auth precedence, team setup, how Claude Code works, agentic loop, built-in tools, tool categories, what Claude can access, execution environments, sessions, resume session, fork session, context window, compaction, checkpoints, undo changes, permission modes, Shift+Tab, plan mode, auto-accept, working effectively with Claude Code, /init, /doctor, /agents, release channels, auto-updates, update Claude Code, uninstall Claude Code, npm migration, Windows setup, Git Bash, WSL setup, Alpine Linux, or any introductory Claude Code topic.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code -- overview, quickstart, advanced setup, authentication, and how Claude Code works.

## Quick Reference

### Installation

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PS) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). After install: `cd your-project && claude`.

### System Requirements

| Requirement | Details |
|:------------|:--------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Network | Internet required |

Alpine/musl distributions need `libgcc`, `libstdc++`, `ripgrep` and `USE_BUILTIN_RIPGREP=0`.

### Available Surfaces

| Surface | How to start |
|:--------|:-------------|
| Terminal CLI | `claude` in any project directory |
| VS Code / Cursor | Install "Claude Code" extension, open via Command Palette |
| Desktop app | Download from [claude.ai](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect), open Code tab |
| Web | [claude.ai/code](https://claude.ai/code) -- no local setup needed |
| JetBrains | Install plugin from JetBrains Marketplace, restart IDE |

### Authentication

| Account type | How to log in |
|:-------------|:-------------|
| Claude Pro/Max | `claude` then follow browser prompts |
| Claude Teams/Enterprise | Log in with team-invited Claude.ai account |
| Claude Console | Log in with Console credentials (admin must invite first) |
| Amazon Bedrock | Set env vars before running `claude` (no browser login) |
| Google Vertex AI | Set env vars before running `claude` (no browser login) |
| Microsoft Foundry | Set env vars before running `claude` (no browser login) |

Switch accounts with `/login`. Log out with `/logout`. Check active method with `/status`.

#### Authentication Precedence

When multiple credentials are present, Claude Code uses them in this order:

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` / `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (Bearer token, for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` env var (X-Api-Key header, direct API access)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. Subscription OAuth credentials from `/login` (default for Pro/Max/Teams/Enterprise)

#### Credential Storage

- **macOS**: encrypted macOS Keychain
- **Linux**: `~/.claude/.credentials.json` (mode `0600`), or `$CLAUDE_CONFIG_DIR`
- **Windows**: `~/.claude/.credentials.json` (inherits user profile ACLs)

`apiKeyHelper` setting runs a shell script returning an API key. Default refresh: 5 minutes or on HTTP 401. Custom TTL via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

### Team Setup Options

| Method | Best for |
|:-------|:---------|
| Claude for Teams | Smaller teams, self-service with admin tools |
| Claude for Enterprise | SSO, domain capture, role-based permissions, compliance API, managed policies |
| Claude Console | API-based billing; invite users with Claude Code or Developer role |
| Cloud providers | Bedrock, Vertex AI, or Foundry for enterprise cloud deployments |

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `claude --version` | Check installed version |
| `claude doctor` | Diagnose installation and configuration |
| `claude update` | Apply update immediately |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/status` | Check active auth method |

### How Claude Code Works

Claude Code uses an **agentic loop**: gather context, take action, verify results -- repeating until the task is complete. You can interrupt at any point to steer.

#### Tool Categories

| Category | What Claude can do |
|:---------|:-------------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation, look up errors |
| Code intelligence | Type errors/warnings, jump to definitions, find references (requires plugins) |

#### What Claude Can Access

When you run `claude` in a directory, it has access to: your project files, your terminal (any command you could run), your git state, CLAUDE.md instructions, auto memory, and configured extensions (MCP servers, skills, subagents, Chrome).

### Sessions

- Sessions are independent -- each starts with a fresh context window
- Resume with `claude --continue` or `claude --resume`
- Fork with `claude --continue --fork-session` (new session, preserved history)
- Persistent knowledge goes in CLAUDE.md or auto memory, not conversation history
- Parallel sessions via git worktrees for separate directories per branch

### Context Window

Context holds conversation, file contents, command outputs, CLAUDE.md, skills, and system instructions. When it fills up, Claude compacts automatically (clears older tool outputs, summarizes conversation). Run `/context` to check usage, `/compact` with a focus to control what is preserved.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files without asking, still asks for commands |
| Plan mode | Read-only tools only, creates a plan for approval |

Allow trusted commands in `.claude/settings.json` to skip per-command approval.

### Checkpoints

Every file edit is reversible. Press `Esc` twice to rewind to a previous state. Checkpoints are local to the session and separate from git. They only cover file changes, not actions affecting remote systems.

### Updates & Release Channels

| Channel | Behavior |
|:--------|:---------|
| `latest` (default) | New features as soon as released |
| `stable` | ~1 week old, skips releases with major regressions |

Configure via `/config` or `autoUpdatesChannel` in settings.json. Disable auto-updates by setting `DISABLE_AUTOUPDATER=1` in settings env.

### Uninstall

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows) | Remove `%USERPROFILE%\.local\bin\claude.exe` and `%USERPROFILE%\.local\share\claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |

Remove config: delete `~/.claude`, `~/.claude.json`, and project-level `.claude/` and `.mcp.json`.

### Working Effectively

- **Ask Claude for help**: "how do I set up hooks?", `/init`, `/doctor`, `/agents`
- **Be conversational**: start with what you want, then refine iteratively
- **Interrupt and steer**: type a correction mid-task and press Enter
- **Be specific upfront**: reference files, mention constraints, point to patterns
- **Give verification targets**: include test cases, expected outputs, screenshots
- **Explore before implementing**: use plan mode to analyze first, then implement
- **Delegate, dont dictate**: give context and direction, trust Claude with details

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- install methods (Terminal native/Homebrew/WinGet, VS Code extension, Desktop app macOS/Windows, Web at claude.ai/code, JetBrains plugin), capability descriptions (automate tedious tasks, build features/fix bugs, commits/PRs, MCP tool connections, customization with CLAUDE.md/skills/hooks, agent teams/Agent SDK, CLI piping/scripting/automation, work from anywhere with Remote Control/web/iOS/Desktop/Slack), surface comparison table (Remote Control, Web/iOS, GitHub Actions, GitLab CI/CD, Code Review, Slack, Chrome, Agent SDK), next steps links
- [Quickstart](references/claude-code-quickstart.md) -- prerequisites, step-by-step walkthrough (install, login with account types, start first session, first question exploring codebase, first code change with approval flow, Git operations commit/branch/merge, bug fixing and feature implementation, other workflows refactor/tests/docs/review), essential commands table, pro tips (be specific, step-by-step instructions, let Claude explore first, keyboard shortcuts), getting help (/help, Discord)
- [Advanced setup](references/claude-code-setup.md) -- system requirements (OS versions, RAM, network, shell, location), install methods with platform tabs, Windows setup (Git Bash with CLAUDE_CODE_GIT_BASH_PATH, WSL 1/2 with sandboxing note), Alpine/musl dependencies (libgcc libstdc++ ripgrep, USE_BUILTIN_RIPGREP), verify installation (--version, claude doctor), authenticate (account types, Console workspace), auto-updates behavior, release channels (latest/stable, autoUpdatesChannel setting, managed settings for enterprise), disable auto-updates (DISABLE_AUTOUPDATER), manual update (claude update), install specific version (native installer with version/channel args), deprecated npm installation (migration steps, Node.js 18+ requirement, no sudo warning), binary integrity (SHA256 checksums, code signing macOS/Windows), uninstall by method (native/Homebrew/WinGet/npm), remove configuration files
- [Authentication](references/claude-code-authentication.md) -- login flow (browser prompt, manual URL copy with press c), account types (Pro/Max, Teams/Enterprise, Console, cloud providers), logout (/logout), team setup (Teams vs Enterprise features, Console with bulk invite/SSO/roles Claude Code and Developer, cloud provider distribution), credential management (storage locations macOS Keychain/Linux/Windows, supported auth types, apiKeyHelper with TTL and slow helper notice, CLAUDE_CODE_API_KEY_HELPER_TTL_MS), authentication precedence (cloud providers > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth, conflict resolution, Web always uses subscription)
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop (gather context/take action/verify results, interrupting and steering), models (Sonnet/Opus tradeoffs, /model and --model switching), tools (five categories file-ops/search/execution/web/code-intelligence, tool chaining example, extending with skills/MCP/hooks/subagents), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local/cloud/remote-control), interfaces (terminal/desktop/IDE/web/remote-control/Slack/CI), sessions (independent context, branch awareness, resume with --continue/--resume, fork with --fork-session, same session in multiple terminals), context window (what fills it, compaction behavior, /context and /compact, Compact Instructions in CLAUDE.md, skills on-demand loading, subagent isolation, MCP context cost), checkpoints (undo file edits, Esc twice, limitations for remote actions), permission modes (Shift+Tab cycling, default/auto-accept/plan, .claude/settings.json allowlists), working effectively (ask Claude for help /init /agents /doctor, conversational iteration, interrupt and steer, be specific upfront, give verification targets, explore before implementing with plan mode, delegate dont dictate)

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
