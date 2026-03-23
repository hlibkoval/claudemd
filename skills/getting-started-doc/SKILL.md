---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code -- installation (native installer for macOS/Linux/Windows/WSL, Homebrew, WinGet, npm deprecated), system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+, 4GB RAM, Bash/Zsh/PowerShell/CMD), platform setup (Windows with Git Bash, WSL 1/WSL 2, Alpine musl/libgcc/libstdc++/ripgrep), authentication (Claude Pro/Max/Teams/Enterprise OAuth login, Console API credentials with Claude Code role, Amazon Bedrock/Google Vertex AI/Microsoft Foundry cloud providers, ANTHROPIC_API_KEY with interactive approval and /config toggle, ANTHROPIC_AUTH_TOKEN for LLM gateways, apiKeyHelper script with TTL and slow helper notice, credential precedence chain, credential storage in macOS Keychain or ~/.claude/.credentials.json, apiKeyHelper/ANTHROPIC_API_KEY/ANTHROPIC_AUTH_TOKEN terminal-only scope, /status to check active method), available surfaces (Terminal CLI, VS Code extension, JetBrains plugin, Desktop app, Web at claude.ai/code, Slack, GitHub Actions, GitLab CI/CD, Chrome, Remote Control, Channels for Telegram/Discord/webhooks, iOS app), quickstart walkthrough (first session, ask questions, make code changes, use Git, fix bugs, add features, refactor, write tests, update docs), essential CLI commands (claude, claude "task", claude -p, claude -c, claude -r, claude commit, /clear, /help, exit), updates (auto-update background, stable/latest release channels, autoUpdatesChannel setting, DISABLE_AUTOUPDATER, claude update, brew upgrade, winget upgrade), uninstallation (native binary removal, Homebrew uninstall, WinGet uninstall, npm uninstall, config file cleanup), how Claude Code works (agentic loop with gather-context/take-action/verify-results phases, models with Sonnet/Opus and /model switching, built-in tool categories -- file operations/search/execution/web/code intelligence, tool chaining, what Claude can access -- project files/terminal/git state/CLAUDE.md/auto memory/extensions, execution environments -- local/cloud/remote control, sessions -- independent fresh context/branch switching/resume with --continue and --resume and --fork-session/context window management with /context and /compact and /btw, checkpoints for undoing file changes with Esc+Esc, permission modes -- default/auto-accept edits/plan mode with Shift+Tab, .claude/settings.json allowlists), working effectively (ask Claude for help, conversational iteration, interrupt and steer, be specific upfront, give verification targets, explore before implementing with Plan Mode, delegate don't dictate), binary integrity (SHA256 checksums, macOS/Windows code signing), version pinning (install specific version, stable channel), npm-to-native migration. Load when discussing Claude Code installation, setup, getting started, quickstart, first session, authentication, login, credential management, system requirements, platform support, Windows setup, WSL, Alpine Linux, auto-updates, release channels, uninstallation, how Claude Code works, agentic loop, built-in tools, context window, sessions, checkpoints, permission modes, plan mode, available surfaces, VS Code extension, JetBrains plugin, Desktop app, web interface, CLI commands, beginner tips, or working effectively with Claude Code.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, setting up, and understanding Claude Code -- from system requirements and authentication through the agentic architecture and tips for working effectively.

## Quick Reference

Claude Code is an agentic coding tool that reads your codebase, edits files, runs commands, and integrates with your development tools. It is available in the terminal, IDE extensions, a desktop app, and the browser.

### Installation

| Method | Command | Auto-updates |
|:-------|:--------|:-------------|
| Native (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` (macOS/Linux/WSL) | Yes |
| Native (Windows PS) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |

After installing, start Claude Code in any project:

```bash
cd your-project
claude
```

### System Requirements

| Requirement | Details |
|:------------|:--------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| RAM | 4 GB+ |
| Network | Internet required |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Windows dep | Git for Windows required |

**Alpine/musl note:** Install `libgcc`, `libstdc++`, `ripgrep` and set `USE_BUILTIN_RIPGREP=0` in settings.

### Available Surfaces

| Surface | Description |
|:--------|:------------|
| Terminal CLI | Full-featured CLI, the primary interface |
| VS Code / Cursor | Extension with inline diffs, @-mentions, plan review |
| JetBrains IDEs | Plugin for IntelliJ, PyCharm, WebStorm, etc. |
| Desktop app | Standalone app for macOS and Windows |
| Web | Browser-based at claude.ai/code, no local setup |
| Slack | Route bug reports to pull requests |
| GitHub Actions | Automate PR reviews and issue triage in CI |
| GitLab CI/CD | CI/CD integration |
| Chrome | Debug live web applications |
| Remote Control | Continue local sessions from phone or another device |
| Channels | Push events from Telegram, Discord, webhooks |

### Authentication

| Account type | How to log in |
|:-------------|:-------------|
| Claude Pro / Max | Run `claude`, log in via browser with Claude.ai account |
| Claude for Teams / Enterprise | Log in with team-invited Claude.ai account |
| Claude Console (API) | Log in with Console credentials; admin must invite first |
| Amazon Bedrock | Set env vars before running `claude`; no browser login |
| Google Vertex AI | Set env vars before running `claude`; no browser login |
| Microsoft Foundry | Set env vars before running `claude`; no browser login |

**Credential precedence** (highest to lowest):
1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (Bearer header, for LLM gateways)
3. `ANTHROPIC_API_KEY` env var (X-Api-Key header, direct API access; prompted to approve in interactive mode, auto-used in `-p` mode)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. Subscription OAuth from `/login` (default for Pro/Max/Teams/Enterprise)

**Credential storage:** macOS Keychain (encrypted); Linux/Windows in `~/.claude/.credentials.json` (mode 0600 on Linux). Override location with `$CLAUDE_CONFIG_DIR`.

**Scope note:** `apiKeyHelper`, `ANTHROPIC_API_KEY`, and `ANTHROPIC_AUTH_TOKEN` apply to terminal CLI sessions only. Desktop and remote sessions use OAuth exclusively. Use `/status` to check which auth method is active.

**Team setup options:** Claude for Teams (self-service), Claude for Enterprise (SSO, domain capture, managed policies), Console with bulk invite or SSO, cloud providers with distributed env vars.

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude commit` | Create a Git commit |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/model` | Switch models |
| `exit` or `Ctrl+C` | Exit Claude Code |

### Updates & Version Management

| Setting | Effect |
|:--------|:-------|
| `autoUpdatesChannel: "latest"` | Receive new features immediately (default) |
| `autoUpdatesChannel: "stable"` | Use a version ~1 week old, skipping regressions |
| `DISABLE_AUTOUPDATER: "1"` | Disable background auto-updates |
| `claude update` | Apply update immediately |

Install a specific version: `curl -fsSL https://claude.ai/install.sh \| bash -s 1.0.58`

Install stable channel: `curl -fsSL https://claude.ai/install.sh \| bash -s stable`

### How Claude Code Works

**The agentic loop:** Claude works through three blended phases -- gather context, take action, verify results. It chains tool uses together, course-correcting along the way. You can interrupt at any point to steer.

**Built-in tool categories:**

| Category | Capabilities |
|:---------|:-------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump to definitions, find references (via plugins) |

**What Claude can access:** project files, terminal commands, git state, CLAUDE.md instructions, auto memory, configured extensions (MCP servers, skills, subagents, plugins).

**Execution environments:**

| Environment | Where code runs | Use case |
|:------------|:----------------|:---------|
| Local | Your machine | Default; full access to files and tools |
| Cloud | Anthropic-managed VMs | Offload tasks, work on repos you don't have locally |
| Remote Control | Your machine, controlled from browser | Web UI while keeping everything local |

### Sessions

Sessions are independent -- each starts with a fresh context window. Claude persists learnings across sessions via auto memory and CLAUDE.md.

| Action | How |
|:-------|:----|
| Resume most recent | `claude --continue` or `claude -c` |
| Resume by name | `claude --resume` or `claude -r` |
| Fork a session | `claude --continue --fork-session` |
| See context usage | `/context` |
| Compact context | `/compact <focus>` |
| Side question | `/btw` |

### Safety & Permissions

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits without asking, still asks for commands |
| Plan mode | Read-only tools only, creates a plan for approval |

Toggle modes with `Shift+Tab`. Allow trusted commands in `.claude/settings.json`.

**Checkpoints:** Every file edit is reversible. Press `Esc` twice to rewind. Checkpoints are local to the session, separate from git.

### Working Effectively

| Tip | Details |
|:----|:--------|
| Be specific upfront | Reference files, mention constraints, point to patterns |
| Give verification targets | Provide test cases, screenshots, or expected outputs |
| Explore before implementing | Use Plan Mode to analyze first, then implement |
| Delegate, don't dictate | Give context and direction, let Claude figure out the details |
| Iterate conversationally | Start with what you want, then refine through follow-ups |
| Interrupt and steer | Type a correction and press Enter at any time |

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Config cleanup | `rm -rf ~/.claude && rm ~/.claude.json` (also `.claude/` and `.mcp.json` in project) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) -- product overview, installation commands for all surfaces (Terminal with native/Homebrew/WinGet, VS Code/Cursor extension, Desktop app for macOS/Windows, Web at claude.ai/code, JetBrains plugin), what you can do (automate tedious tasks, build features and fix bugs, create commits and PRs, connect tools with MCP, customize with CLAUDE.md/skills/hooks, run agent teams and build custom agents, pipe/script/automate with CLI, work from anywhere with Remote Control/web/desktop/Slack), integration table (Remote Control, Channels for Telegram/Discord/webhooks, Web/iOS, GitHub Actions, GitLab CI/CD, Code Review, Slack, Chrome, Agent SDK), next steps links
- [Quickstart](references/claude-code-quickstart.md) -- step-by-step first session walkthrough (install, log in, start session, ask questions about codebase, make code changes with approval flow, use Git conversationally, fix bugs and add features, refactor/test/document/review), essential commands table (claude, claude "task", claude -p, claude -c, claude -r, claude commit, /clear, /help, exit), pro tips (be specific, use step-by-step instructions, let Claude explore first, keyboard shortcuts with ? and Tab and arrow keys and / for commands)
- [Advanced setup](references/claude-code-setup.md) -- system requirements (OS versions, RAM, network, shell, location), platform-specific setup (Windows with Git Bash or WSL, CLAUDE_CODE_GIT_BASH_PATH setting, Alpine with libgcc/libstdc++/ripgrep and USE_BUILTIN_RIPGREP), verify installation (claude --version, claude doctor), authentication overview, auto-updates (background updates, stable/latest release channels with autoUpdatesChannel, /config and managed settings for enterprise, DISABLE_AUTOUPDATER, claude update, Homebrew/WinGet manual updates), advanced installation (specific version pinning, stable channel install, npm deprecation, npm-to-native migration, npm install with Node.js 18+), binary integrity (SHA256 checksums in manifest.json, macOS signing by Anthropic PBC with Apple notarization, Windows signing), uninstallation (native/Homebrew/WinGet/npm removal, config file cleanup for ~/.claude and ~/.claude.json and .claude/ and .mcp.json)
- [Authentication](references/claude-code-authentication.md) -- login flow (browser-based, press c to copy URL), account types (Pro/Max subscription, Teams/Enterprise, Console with API billing, cloud providers with env vars), team setup (Teams self-service vs Enterprise with SSO/domain capture/managed policies, Console authentication with bulk invite/SSO and Claude Code/Developer roles, cloud provider setup with Bedrock/Vertex/Foundry), credential management (macOS Keychain storage, Linux/Windows file storage with mode 0600, $CLAUDE_CONFIG_DIR override, apiKeyHelper with CLAUDE_CODE_API_KEY_HELPER_TTL_MS refresh, slow helper notice at 10s, terminal CLI scope for apiKeyHelper/ANTHROPIC_API_KEY/ANTHROPIC_AUTH_TOKEN), authentication precedence (cloud provider > ANTHROPIC_AUTH_TOKEN > ANTHROPIC_API_KEY with interactive approval and /config toggle > apiKeyHelper > subscription OAuth, ANTHROPIC_API_KEY precedence over subscription can cause failures with unset fallback, /status to check active method), Web sessions use subscription credentials exclusively
- [How Claude Code works](references/claude-code-how-it-works.md) -- agentic loop (gather context / take action / verify results phases, interrupt at any point), models (Sonnet for most tasks, Opus for complex reasoning, /model to switch), tools (file operations, search, execution, web, code intelligence as five categories, tool chaining example), extending with skills/MCP/hooks/subagents, what Claude can access (project files, terminal, git state, CLAUDE.md, auto memory, extensions), execution environments (local/cloud/remote control), interfaces (terminal, desktop, IDE, web, Slack, CI/CD), sessions (independent with fresh context, branch switching, resume with --continue/--resume/--fork-session, context window with /context and /compact and auto memory, compaction behavior and CLAUDE.md Compact Instructions, skills load on demand, subagents get separate context), safety (checkpoints with Esc+Esc rewind, permission modes with Shift+Tab toggle -- default/auto-accept/plan, .claude/settings.json allowlists), working effectively (ask Claude for help, /init and /agents and /doctor, conversational iteration, interrupt and steer, be specific, give verification targets, explore before implementing, delegate don't dictate)

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
