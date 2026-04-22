---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, system requirements and installation, authentication, how the agentic loop works, and available platforms and integrations.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What is Claude Code?

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. It is available as a CLI, Desktop app, VS Code extension, JetBrains plugin, and web interface.

### System requirements

| Requirement | Details |
| :---------- | :------ |
| **macOS** | 13.0+ |
| **Windows** | 10 1809+ or Windows Server 2019+ |
| **Linux** | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **Hardware** | 4 GB+ RAM, x64 or ARM64 |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Windows (native)** | Requires Git for Windows; WSL does not |

### Install commands

| Method | Command |
| :----- | :------ |
| macOS / Linux / WSL | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Native installs auto-update. Homebrew and WinGet do not — run `brew upgrade claude-code` or `winget upgrade Anthropic.ClaudeCode` manually.

### Verify and update

```bash
claude --version
claude doctor      # diagnose installation issues
claude update      # apply update immediately
```

### Uninstall (native install)

**macOS / Linux / WSL:**
```bash
rm -f ~/.local/bin/claude
rm -rf ~/.local/share/claude
```

**Windows PowerShell:**
```powershell
Remove-Item -Path "$env:USERPROFILE\.local\bin\claude.exe" -Force
Remove-Item -Path "$env:USERPROFILE\.local\share\claude" -Recurse -Force
```

### Auto-update settings

| Setting key | Values | Description |
| :---------- | :----- | :---------- |
| `autoUpdatesChannel` | `"latest"` (default), `"stable"` | Release channel; stable is ~1 week behind |
| `minimumVersion` | version string, e.g. `"2.1.100"` | Refuse to downgrade below this version |
| `env.DISABLE_AUTOUPDATER` | `"1"` | Disable auto-updates entirely |

### Alpine Linux setup

```bash
apk add libgcc libstdc++ ripgrep
```
Then set `USE_BUILTIN_RIPGREP` to `"0"` in `settings.json`.

### First session

```bash
cd your-project
claude
```

Log in on first launch. Use `/login` to switch accounts, `/logout` to sign out.

### Essential CLI commands

| Command | What it does |
| :------ | :----------- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude --continue --fork-session` | Fork a session from its current state |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/model` | Switch model mid-session |
| `/compact` | Summarize context to free space |
| `/context` | Show what is using context space |
| `/login` / `/logout` | Manage authentication |
| `exit` or Ctrl+D | Exit Claude Code |

### Authentication methods and precedence

| Priority | Method | When to use |
| :------- | :----- | :---------- |
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, etc.) | Bedrock / Vertex / Foundry |
| 2 | `ANTHROPIC_AUTH_TOKEN` | LLM gateway / proxy with bearer tokens |
| 3 | `ANTHROPIC_API_KEY` | Direct Anthropic API key |
| 4 | `apiKeyHelper` script | Dynamic / rotating credentials |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` | CI pipelines (from `claude setup-token`) |
| 6 | Subscription OAuth (default `/login`) | Pro, Max, Team, Enterprise |

**Credential storage:** macOS Keychain; Linux/Windows: `~/.claude/.credentials.json` (mode 0600 on Linux).

Generate a long-lived CI token with `claude setup-token` (valid one year; sets `CLAUDE_CODE_OAUTH_TOKEN`).

### Account types

| Account | Access |
| :------ | :----- |
| Claude Pro / Max | Direct subscription — recommended for individuals |
| Claude for Teams | Collaboration features, centralized billing |
| Claude for Enterprise | SSO, domain capture, managed policy settings |
| Claude Console | API-based billing with pre-paid credits |
| Amazon Bedrock / Google Vertex AI / Microsoft Foundry | Cloud-provider auth; no browser login required |

### The agentic loop

Claude works through three repeating phases: **gather context → take action → verify results**.

Built-in tool categories:

| Category | What Claude can do |
| :------- | :----------------- |
| File operations | Read, edit, create, rename, reorganize files |
| Search | Find files by pattern, search with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, diagnostics, definitions, references (requires IDE plugin) |

### Permission modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :------- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and common filesystem commands without asking |
| Plan mode | Read-only exploration; produces a plan for approval |
| Auto | Background safety evaluation; research preview |

### Session management

| Concept | Detail |
| :------ | :----- |
| Sessions are independent | Each new session starts with a fresh context window |
| Resuming | `claude --continue` or `claude --resume` restores history; session-scoped permissions reset |
| Forking | `claude --continue --fork-session` branches from current state without altering the original |
| Files | Saved under `~/.claude/projects/` as JSONL |
| Checkpoints | File snapshot before every edit; press `Esc` twice to rewind |
| Context limit | Claude auto-compacts; add a "Compact Instructions" section to CLAUDE.md to control what is preserved |

### Platforms at a glance

| Platform | Best for | Key differentiator |
| :------- | :------- | :----------------- |
| CLI | Terminal workflows, scripting, CI | Full feature set; Agent SDK; third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| VS Code | Editor-integrated work | Inline diffs, @-mentions, checkpoints |
| JetBrains | IntelliJ / PyCharm / WebStorm | Diff viewer, selection sharing |
| Web | Long-running or offline tasks | Anthropic-managed cloud; keeps running after disconnect |
| Mobile | Starting and monitoring from phone | Cloud sessions or Remote Control into local session |

### Remote and async work

| Option | Trigger | Claude runs on |
| :----- | :------ | :------------- |
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | `claude remote-control` | Your machine (CLI or VS Code) |
| Channels | Push from Telegram, Discord, webhooks | Your machine (CLI) |
| Slack | Mention `@Claude` in a channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### Binary integrity verification

GPG signing key fingerprint: `31DD DE24 DDFA B679 F42D  7BD2 BAA9 29FF 1A7E CACE`

Platform code signatures: macOS — signed by "Anthropic PBC" and notarized; Windows — signed by "Anthropic, PBC"; Linux — manifest signature only.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, installation configurator, surfaces, what you can do, and next steps.
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, log in, explore a codebase, make code changes, use git, and essential commands.
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific install details (Windows, Alpine), version management, binary integrity verification, and uninstallation.
- [Authentication](references/claude-code-authentication.md) — login flow, team and enterprise setup, cloud-provider auth, credential storage, precedence order, and long-lived CI tokens.
- [How Claude Code works](references/claude-code-how-it-works.md) — the agentic loop, built-in tool categories, what Claude can access, session management, context window, checkpoints, permission modes, and tips for effective use.
- [Platforms and integrations](references/claude-code-platforms.md) — comparison of all surfaces (CLI, Desktop, VS Code, JetBrains, web, mobile), tool integrations (Chrome, GitHub Actions, GitLab, Code Review, Slack), and remote/async options.

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
