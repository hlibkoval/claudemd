---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- overview of all surfaces (Terminal CLI, VS Code, JetBrains, Desktop app, Web, Slack, Chrome), installation methods (native install via curl/irm/winget/Homebrew, system requirements, Windows setup with Git Bash/WSL, Alpine/musl dependencies, npm migration), authentication (Claude Pro/Max/Teams/Enterprise login, Console setup with roles, cloud provider auth via Bedrock/Vertex/Foundry, credential management with apiKeyHelper and keychain storage, auth precedence order, ANTHROPIC_API_KEY/ANTHROPIC_AUTH_TOKEN), quickstart walkthrough (first session, exploring codebase, making edits, Git operations, debugging, refactoring, writing tests), essential CLI commands (claude, claude -p, claude -c, claude -r, claude commit, /clear, /help), how Claude Code works (agentic loop phases: gather context/take action/verify results, models and tool categories: file ops/search/execution/web/code intelligence, extending with skills/MCP/hooks/subagents), sessions (resume/fork with --continue/--fork-session, context window management, /compact, /context, checkpoints for undo), permission modes (default/auto-accept edits/plan mode, Shift+Tab cycling), update channels (latest/stable, autoUpdatesChannel, DISABLE_AUTOUPDATER), uninstallation, verification (claude --version, claude doctor), release channels, binary integrity/code signing, pro tips (be specific, step-by-step instructions, let Claude explore first, give verification targets, delegate don't dictate). Load when discussing how to install Claude Code, getting started, first session, quickstart, authentication login, system requirements, Windows setup, update channels, uninstallation, credential management, apiKeyHelper, agentic loop, how Claude Code works, tool categories, sessions resume fork, context window, permission modes, plan mode, auto-accept, checkpoints, claude doctor, release channels, native install, Homebrew, WinGet, npm migration, or Claude Code overview.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, authenticating, and getting started with Claude Code across all surfaces.

## Quick Reference

### Surfaces

Claude Code runs everywhere. All surfaces share the same engine, CLAUDE.md files, settings, and MCP servers.

| Surface | Description |
|:--------|:------------|
| **Terminal CLI** | Full-featured CLI for file edits, commands, and project management |
| **VS Code / Cursor** | Extension with inline diffs, @-mentions, plan review |
| **JetBrains** | Plugin for IntelliJ, PyCharm, WebStorm with interactive diffs |
| **Desktop app** | Standalone app with visual diff review, scheduled tasks, cloud sessions |
| **Web** | Browser-based at claude.ai/code, no local setup required |
| **Slack** | Mention @Claude with a bug report, get a PR back |
| **Chrome** | Debug live web applications |
| **CI/CD** | GitHub Actions, GitLab CI/CD for automated review and triage |

### Installation Methods

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| **Native (recommended)** | macOS/Linux/WSL: `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| **Native (Windows PS)** | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| **Native (Windows CMD)** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| **Homebrew** | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| **WinGet** | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| **npm (deprecated)** | `npm install -g @anthropic-ai/claude-code` | No |

Windows requires [Git for Windows](https://git-scm.com/downloads/win). WSL 1 and 2 are both supported (WSL 2 supports sandboxing).

### System Requirements

| Requirement | Minimum |
|:------------|:--------|
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Server 2019+ |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **RAM** | 4 GB+ |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

Alpine/musl-based distros need `libgcc`, `libstdc++`, `ripgrep` and `USE_BUILTIN_RIPGREP=0`.

### Authentication

| Account type | How to log in |
|:-------------|:--------------|
| **Claude Pro / Max** | Run `claude`, follow browser prompts |
| **Claude Teams / Enterprise** | Run `claude`, log in with team-invited account |
| **Claude Console** | Admin invites users with Claude Code or Developer role; users log in with Console credentials |
| **Cloud providers** | Set environment variables for Bedrock/Vertex/Foundry before running `claude`; no browser login needed |

To switch accounts: `/login`. To log out: `/logout`. Check active auth method: `/status`.

#### Authentication Precedence

When multiple credentials are present, Claude Code selects in this order:

1. Cloud provider credentials (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (Bearer token for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` env var (X-Api-Key header for direct API access)
4. `apiKeyHelper` script output (dynamic/rotating credentials from a vault)
5. Subscription OAuth credentials from `/login` (default for Pro/Max/Teams/Enterprise)

#### Credential Storage

| Platform | Location |
|:---------|:---------|
| macOS | Encrypted macOS Keychain |
| Linux / Windows | `~/.claude/.credentials.json` (or `$CLAUDE_CONFIG_DIR`); Linux uses mode `0600` |

`apiKeyHelper` is called after 5 minutes or on HTTP 401. Set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for custom refresh intervals.

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/init` | Generate a starting CLAUDE.md |
| `/model` | Switch model during a session |
| `/context` | See what is using context space |
| `claude doctor` | Diagnose installation/configuration issues |

### The Agentic Loop

Claude Code works through three blended phases: **gather context** (search, read files), **take action** (edit, run commands), and **verify results** (run tests, check output). It chains tool calls, course-correcting at each step.

#### Built-in Tool Categories

| Category | Capabilities |
|:---------|:-------------|
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, search content with regex |
| **Execution** | Shell commands, servers, tests, git |
| **Web** | Search the web, fetch documentation |
| **Code intelligence** | Type errors/warnings, jump to definition, find references (requires code intelligence plugins) |

Extensions: [Skills](/en/skills) for workflows, [MCP](/en/mcp) for external services, [Hooks](/en/hooks) for automation, [Subagents](/en/sub-agents) for parallel work.

### Sessions

| Action | Command |
|:-------|:--------|
| Resume last session | `claude --continue` or `claude -c` |
| Resume any session | `claude --resume` or `claude -r` |
| Fork session (new branch from current conversation) | `claude --continue --fork-session` |

Sessions are independent -- each starts with a fresh context window. Persistent knowledge uses auto memory and CLAUDE.md. Session-scoped permissions are not restored on resume.

#### Context Window Management

Context holds conversation history, file contents, command outputs, CLAUDE.md, skills, and system instructions. When full, Claude compacts automatically (older tool outputs first, then conversation summary). Put persistent rules in CLAUDE.md. Run `/compact` with a focus to control what is preserved. Run `/context` to inspect usage.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
|:-----|:---------|
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | Edits files without asking; still asks for commands |
| **Plan mode** | Read-only tools only; creates a plan for approval |

Allow specific trusted commands in `.claude/settings.json` (e.g., `npm test`, `git status`).

### Checkpoints

Every file edit is reversible. Press `Esc` twice to rewind, or ask Claude to undo. Checkpoints are local to the session, separate from git. Remote actions (databases, APIs, deployments) cannot be checkpointed.

### Update Channels

| Channel | Behavior |
|:--------|:---------|
| `"latest"` (default) | New features as soon as released |
| `"stable"` | ~1 week delayed, skipping major regressions |

Configure via `/config` or settings:

```json
{ "autoUpdatesChannel": "stable" }
```

Disable auto-updates: set `DISABLE_AUTOUPDATER` to `"1"` in settings env.

Manual update: `claude update`.

### Verification and Diagnostics

- `claude --version` -- confirm installation
- `claude doctor` -- detailed check of installation and configuration

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Native (Windows PS) | `Remove-Item "$env:USERPROFILE\.local\bin\claude.exe" -Force; Remove-Item "$env:USERPROFILE\.local\share\claude" -Recurse -Force` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |

Remove config files: delete `~/.claude`, `~/.claude.json`, and project-level `.claude`/`.mcp.json`.

### Pro Tips

- **Be specific upfront**: reference files, mention constraints, point to patterns
- **Give verification targets**: include test cases, expected output, or screenshots
- **Explore before implementing**: use plan mode to analyze, then implement
- **Break complex tasks into steps**: numbered step-by-step instructions
- **Delegate, don't dictate**: describe what you want, let Claude figure out the how

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- all surfaces (Terminal, VS Code, JetBrains, Desktop, Web, Slack, Chrome), installation commands per surface, what you can do (automate tasks, build features, fix bugs, create commits/PRs, connect tools via MCP, customize with CLAUDE.md/skills/hooks, run agent teams, pipe/script/automate with CLI, work from anywhere with remote control/teleport/desktop handoff), use Claude Code everywhere table (remote control, web/iOS, GitHub Actions/GitLab CI, code review, Slack, Chrome, Agent SDK), next steps links
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough (install, log in, start session, ask first question, make first code change, use Git, fix bugs/add features, refactor/test/document/review), essential CLI commands table, pro tips for beginners (be specific, step-by-step instructions, let Claude explore, shortcuts), getting help (Discord, /help)
- [Advanced setup](references/claude-code-setup.md) -- system requirements (OS versions, RAM, network, shell), installation methods (native/Homebrew/WinGet), Windows setup (Git Bash, WSL 1/2, CLAUDE_CODE_GIT_BASH_PATH), Alpine/musl dependencies, verification (claude --version, claude doctor), authentication overview, update management (auto-updates, release channels latest/stable, autoUpdatesChannel, DISABLE_AUTOUPDATER, manual update), install specific version, npm migration, binary integrity/code signing, uninstallation per method, config file removal
- [Authentication](references/claude-code-authentication.md) -- logging in (browser flow, /login, /logout), account types (Pro/Max, Teams/Enterprise, Console, cloud providers), team setup (Teams/Enterprise subscription, Console with SSO and roles, cloud provider distribution), credential management (storage locations per OS, apiKeyHelper with TTL, slow helper notice), authentication precedence (cloud providers > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY > apiKeyHelper > OAuth), Claude Code on the Web always uses subscription credentials
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop (gather context, take action, verify results), models (Sonnet/Opus, /model switching), tool categories (file operations, search, execution, web, code intelligence), what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local, cloud, remote control), interfaces, sessions (resume/fork with --continue/--fork-session, context window, compaction, /compact, /context, skills on-demand loading, subagent context isolation), checkpoints (Esc to rewind, local to session), permission modes (default/auto-accept/plan, Shift+Tab), effective usage tips (ask Claude for help, /init /agents /doctor, be specific, give verification targets, explore before implementing, delegate don't dictate)

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
