---
name: getting-started-doc
description: Complete documentation for getting started with Claude Code — installation, authentication, quickstart walkthrough, how Claude Code works (agentic loop, tools, sessions, context), and the platforms and integrations available (CLI, Desktop, VS Code, JetBrains, Web, mobile, Chrome, Slack, CI/CD). Use when helping users install Claude Code, log in, run their first session, pick an installation method, choose between platforms, understand the agentic loop, manage sessions/context, configure team authentication, or troubleshoot initial setup.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: overview, quickstart, setup/installation, authentication, how it works, and platforms.

## Quick Reference

### Installation methods (Terminal CLI)

| Method | Command | Auto-update? |
| --- | --- | --- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh | bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 | iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew (stable) | `brew install --cask claude-code` | No (`brew upgrade claude-code`) |
| Homebrew (latest) | `brew install --cask claude-code@latest` | No |
| WinGet | `winget install Anthropic.ClaudeCode` | No (`winget upgrade Anthropic.ClaudeCode`) |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No |

Install a specific version or channel: `curl -fsSL https://claude.ai/install.sh | bash -s stable` or `bash -s 2.1.89`.

Verify install: `claude --version`, `claude doctor`.

### System requirements

- **OS**: macOS 13.0+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **Hardware**: 4 GB+ RAM, x64 or ARM64
- **Shell**: Bash, Zsh, PowerShell, or CMD (Windows requires Git for Windows or WSL)
- **Extras**: ripgrep (bundled); Alpine/musl needs `libgcc`, `libstdc++`, `ripgrep` + `USE_BUILTIN_RIPGREP=0`
- **Network**: internet required; see network-config docs

### Platforms / surfaces

| Platform | Best for | Notes |
| --- | --- | --- |
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| Desktop | Visual diff review, parallel sessions, managed setup | Diff viewer, computer use (Pro/Max), Dispatch |
| VS Code / Cursor | Editor-integrated work | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ/PyCharm/WebStorm users | Diff viewer, selection sharing |
| Web (claude.ai/code) | Long-running tasks, offline continuation | Anthropic-managed cloud |
| Mobile (iOS/Android) | Starting/monitoring tasks remotely | Cloud sessions, Remote Control, Dispatch |

Execution environments: **Local** (your machine), **Cloud** (Anthropic VMs), **Remote Control** (local machine driven via browser).

### Authentication

Log in by running `claude`. On first launch opens a browser; if it doesn't, press `c` to copy login URL. Log out with `/logout`.

Account types:
- **Claude Pro / Max**: Claude.ai login
- **Claude for Teams / Enterprise**: Claude.ai account invited by admin
- **Claude Console**: Console credentials (admin assigns **Claude Code** or **Developer** role)
- **Cloud providers**: Amazon Bedrock, Google Vertex AI, Microsoft Foundry (env vars, no browser login)

Free Claude.ai plan does **not** include Claude Code access.

**Credential precedence** (highest first):
1. Cloud provider creds (`CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` / `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (Bearer header, for LLM gateways)
3. `ANTHROPIC_API_KEY` (X-Api-Key header, direct Console API key)
4. `apiKeyHelper` script output (dynamic/rotating creds)
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`)
6. Subscription OAuth from `/login` (default for Pro/Max/Team/Enterprise)

Credential storage: macOS Keychain; Linux/Windows `~/.claude/.credentials.json` (mode 0600 on Linux). Override with `$CLAUDE_CONFIG_DIR`.

Long-lived token for CI: `claude setup-token` (one-year OAuth token, inference-only, cannot establish Remote Control).

### Essential CLI commands

| Command | What it does |
| --- | --- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit (non-interactive) |
| `claude -c` | Continue most recent conversation in current dir |
| `claude -r` | Resume a previous conversation |
| `claude --continue --fork-session` | Branch a session while preserving history |
| `claude update` | Apply an update immediately |
| `claude doctor` | Diagnose installation/config |
| `claude --version` | Show version |
| `claude setup-token` | Generate a long-lived OAuth token |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/init` | Create a CLAUDE.md for the project |
| `/context` | Inspect context window usage |
| `/compact` | Compact the conversation (optional focus arg) |
| `/config` | Open configuration UI |
| `/status` | Show current auth/session state |
| `/logout` | Log out and re-authenticate |

### Key settings

```json
{
  "autoUpdatesChannel": "stable",
  "env": {
    "DISABLE_AUTOUPDATER": "1",
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe",
    "USE_BUILTIN_RIPGREP": "0"
  }
}
```

- `autoUpdatesChannel`: `"latest"` (default) or `"stable"` (~1 week behind)
- `DISABLE_AUTOUPDATER=1`: turn off background auto-updates
- `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`: custom refresh interval for `apiKeyHelper`

### The agentic loop

Three phases that blend together: **gather context → take action → verify results**. Powered by **models** (reasoning) + **tools** (action). You can interrupt at any time to steer.

Built-in tool categories:

| Category | Examples |
| --- | --- |
| File operations | Read, edit, create, rename files |
| Search | Glob, regex/content search, codebase exploration |
| Execution | Shell commands, tests, git, servers |
| Web | Web search, fetch docs, look up errors |
| Code intelligence | Type errors, jump to definition, find references (requires plugins) |

Extend with: **Skills** (workflows), **MCP** (external services), **Hooks** (pre/post automation), **Subagents** (delegated work with fresh context).

### Permission modes (cycle with `Shift+Tab`)

- **Default**: asks before edits and shell commands
- **Auto-accept edits**: edits + common fs commands without asking
- **Plan mode**: read-only tools; produces plan to approve
- **Auto mode**: background safety checks (research preview)

### Sessions, checkpoints, and context

- Sessions saved as JSONL under `~/.claude/projects/`, scoped to the current directory.
- Each session starts with a fresh context window; persist state via CLAUDE.md or auto memory.
- **Checkpoints**: every file edit is reversible — press `Esc` twice to rewind. Local to session, file-only (not remote side effects).
- **Resume**: `claude --continue` or `claude --resume` restores history (but not session-scoped permissions).
- **Fork**: `claude --continue --fork-session` creates a new session ID preserving history.
- **Parallel work**: use git worktrees for parallel sessions in separate directories.
- **Context management**: `/context` to inspect; Claude auto-compacts when full (clears old tool outputs, then summarizes). Put persistent rules in CLAUDE.md; use skills (on-demand load) and subagents (isolated context) to reduce bloat.

### Windows specifics

- Requires Git for Windows (or WSL). Claude uses Git Bash internally.
- Set `CLAUDE_CODE_GIT_BASH_PATH` in settings if Git Bash isn't auto-detected.
- PowerShell tool available as opt-in preview.
- WSL 2 supports sandboxing; WSL 1 does not.

### Uninstall

```bash
# Native (macOS/Linux/WSL)
rm -f ~/.local/bin/claude
rm -rf ~/.local/share/claude

# Homebrew
brew uninstall --cask claude-code        # or claude-code@latest

# WinGet
winget uninstall Anthropic.ClaudeCode

# npm
npm uninstall -g @anthropic-ai/claude-code

# Config/state (destroys all settings, history, MCP servers)
rm -rf ~/.claude ~/.claude.json
rm -rf .claude .mcp.json
```

### Binary verification

Releases publish `manifest.json` (SHA256 per platform) + detached GPG signature (`manifest.json.sig`), signed by Anthropic key fingerprint `31DD DE24 DDFA B679 F42D  7BD2 BAA9 29FF 1A7E CACE`. Available from version `2.1.89` onward. macOS binaries are notarized; Windows binaries are Authenticode-signed.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — product overview, install tabs per surface, capabilities, and where-to-run table
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session, essential commands, pro tips
- [Advanced setup](references/claude-code-setup.md) — system requirements, installation methods, updates, version pinning, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — login flow, team/console/cloud setup, credential management and precedence, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, tools, sessions, context window, checkpoints, permission modes, tips
- [Platforms and integrations](references/claude-code-platforms.md) — choose your surface (CLI/Desktop/IDE/web/mobile), integrations (Chrome, Slack, CI/CD), remote access options

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
