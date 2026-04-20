---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, installation, quickstart walkthrough, advanced setup, authentication, how the agentic loop works, and platform comparison.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for installing, configuring, and understanding Claude Code.

## Quick Reference

### Installation methods

| Method                     | Command / action                                                   | Auto-updates | Notes                                           |
| :------------------------- | :----------------------------------------------------------------- | :----------- | :---------------------------------------------- |
| **Native (macOS/Linux/WSL)** | `curl -fsSL https://claude.ai/install.sh \| bash`               | Yes          | Recommended                                     |
| **Native (Windows PS)**    | `irm https://claude.ai/install.ps1 \| iex`                       | Yes          | Requires Git for Windows                        |
| **Native (Windows CMD)**   | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes | Requires Git for Windows            |
| **Homebrew**               | `brew install --cask claude-code`                                  | No           | `claude-code` = stable; `claude-code@latest` = latest |
| **WinGet**                 | `winget install Anthropic.ClaudeCode`                              | No           | Manual: `winget upgrade Anthropic.ClaudeCode`   |
| **npm**                    | `npm install -g @anthropic-ai/claude-code`                         | No           | Requires Node.js 18+; do NOT use `sudo`         |
| **Desktop app**            | Download from [claude.com/download](https://claude.com/download)   | Yes          | macOS and Windows; no terminal needed            |
| **VS Code**                | Search "Claude Code" in Extensions or `code --install-extension anthropic.claude-code` | Yes | Also works in Cursor                 |
| **JetBrains**              | Install from JetBrains Marketplace                                 | Yes          | IntelliJ, PyCharm, WebStorm, etc.               |

### System requirements

| Requirement     | Minimum                                                                              |
| :-------------- | :----------------------------------------------------------------------------------- |
| **OS**          | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+              |
| **Hardware**    | 4 GB RAM, x64 or ARM64                                                               |
| **Network**     | Internet connection required                                                         |
| **Shell**       | Bash, Zsh, PowerShell, or CMD                                                        |
| **Windows**     | Native requires Git for Windows; WSL does not                                        |

### Authentication options

| Account type                            | How to log in                                                    |
| :-------------------------------------- | :--------------------------------------------------------------- |
| **Claude Pro / Max**                    | Browser OAuth via `claude` command                               |
| **Claude for Teams / Enterprise**       | Browser OAuth; admin invites members first                       |
| **Claude Console**                      | Browser OAuth; admin assigns Claude Code or Developer role       |
| **Amazon Bedrock**                      | Set `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials (no browser)   |
| **Google Vertex AI**                    | Set `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials (no browser)   |
| **Microsoft Foundry**                   | Set `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials (no browser) |

### Authentication precedence

When multiple credentials are present, Claude Code uses the first match:

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `_VERTEX`, `_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (bearer token for LLM gateways)
3. `ANTHROPIC_API_KEY` (direct API key from Console)
4. `apiKeyHelper` script (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`)
6. Subscription OAuth from `/login` (default for Pro/Max/Team/Enterprise)

### Credential storage

- **macOS**: encrypted macOS Keychain
- **Linux**: `~/.claude/.credentials.json` (mode `0600`)
- **Windows**: `~/.claude/.credentials.json` (inherits user profile ACLs)
- Custom location: set `$CLAUDE_CONFIG_DIR`

### Essential CLI commands

| Command             | What it does                                          |
| :------------------ | :---------------------------------------------------- |
| `claude`            | Start interactive session                             |
| `claude "task"`     | Run a one-time task                                   |
| `claude -p "query"` | Run query non-interactively, then exit               |
| `claude -c`         | Continue most recent conversation                     |
| `claude -r`         | Resume a previous conversation                        |
| `claude --version`  | Show installed version                                |
| `claude update`     | Apply update immediately                              |
| `claude doctor`     | Diagnose installation and configuration               |
| `/login`            | Log in or switch accounts                             |
| `/logout`           | Log out                                               |
| `/help`             | Show available commands                               |
| `/clear`            | Clear conversation history                            |

### Release channels and updates

| Setting                  | Values                       | Effect                                                       |
| :----------------------- | :--------------------------- | :----------------------------------------------------------- |
| `autoUpdatesChannel`     | `"latest"` (default), `"stable"` | Latest ships immediately; stable is ~1 week behind          |
| `minimumVersion`         | e.g. `"2.1.100"`            | Prevents auto-update from downgrading below this version     |
| `DISABLE_AUTOUPDATER`    | `"1"` in `env`              | Disables background auto-updates entirely                    |

### The agentic loop

Claude Code works through three blended phases: **gather context**, **take action**, **verify results**. It chains tool calls, course-corrects, and loops until the task is complete. You can interrupt at any point.

### Built-in tool categories

| Category              | What Claude can do                                                     |
| :-------------------- | :--------------------------------------------------------------------- |
| **File operations**   | Read, edit, create, rename, reorganize files                           |
| **Search**            | Find files by pattern, search content with regex                       |
| **Execution**         | Run shell commands, start servers, run tests, use git                  |
| **Web**               | Search the web, fetch docs, look up error messages                     |
| **Code intelligence** | Type errors, jump to definition, find references (via plugins)         |

### Permission modes (Shift+Tab to cycle)

| Mode                 | Behavior                                                                |
| :------------------- | :---------------------------------------------------------------------- |
| **Default**          | Asks before file edits and shell commands                               |
| **Auto-accept edits** | Edits files freely; still asks for non-filesystem commands             |
| **Plan mode**        | Read-only tools only; creates a plan for approval                       |
| **Auto mode**        | Evaluates all actions with background safety checks (research preview)  |

### Platforms at a glance

| Platform       | Best for                                                    | Unique features                                                |
| :------------- | :---------------------------------------------------------- | :------------------------------------------------------------- |
| **CLI**        | Terminal workflows, scripting, remote servers               | Full feature set, Agent SDK, computer use (macOS)              |
| **Desktop**    | Visual review, parallel sessions                            | Diff viewer, app preview, Dispatch                             |
| **VS Code**    | Editing without leaving your IDE                            | Inline diffs, integrated terminal                              |
| **JetBrains**  | IntelliJ, PyCharm, WebStorm users                           | Diff viewer, selection sharing                                 |
| **Web**        | Long-running tasks, work from anywhere                      | Runs in Anthropic cloud, continues after disconnect            |
| **Mobile**     | Starting/monitoring tasks away from computer                | Cloud sessions, Remote Control, Dispatch                       |

### Integrations

| Integration      | What it does                                                      |
| :--------------- | :---------------------------------------------------------------- |
| **Chrome**       | Controls your browser for testing web apps                        |
| **GitHub Actions** | Runs Claude in CI for PR reviews and issue triage               |
| **GitLab CI/CD** | Same as GitHub Actions for GitLab                                |
| **Code Review**  | Automatic review on every PR                                      |
| **Slack**        | Responds to `@Claude` mentions; turns bug reports into PRs        |
| **MCP servers**  | Connect to Linear, Notion, Google Drive, custom APIs, etc.        |

### Windows setup options

| Option         | Requires                | Sandboxing     | When to use                        |
| :------------- | :---------------------- | :------------- | :--------------------------------- |
| Native Windows | Git for Windows         | Not supported  | Windows-native projects and tools  |
| WSL 2          | WSL 2 enabled           | Supported      | Linux toolchains or sandboxing     |
| WSL 1          | WSL 1 enabled           | Not supported  | If WSL 2 is unavailable            |

### Uninstall

| Method    | Command                                                                                    |
| :-------- | :----------------------------------------------------------------------------------------- |
| Native    | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude`                                |
| Homebrew  | `brew uninstall --cask claude-code`                                                        |
| WinGet    | `winget uninstall Anthropic.ClaudeCode`                                                    |
| npm       | `npm uninstall -g @anthropic-ai/claude-code`                                               |
| Config    | `rm -rf ~/.claude && rm ~/.claude.json` (deletes all settings and session history)         |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — product overview, installation options across all surfaces, what you can do (automate tasks, build features, create commits, connect tools via MCP, customize with skills/hooks), platform comparison table, and next steps.
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session walkthrough: install, log in, ask questions, make code changes, use git, fix bugs, write tests, and essential commands reference.
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific installation (Windows native vs WSL, Alpine/musl), release channels, auto-updates, version pinning, npm install, binary integrity verification (GPG manifest signatures, platform code signing), and uninstallation.
- [Authentication](references/claude-code-authentication.md) — login flow, account types, team setup (Teams/Enterprise, Console, cloud providers), credential storage, authentication precedence, `apiKeyHelper` for dynamic credentials, and `claude setup-token` for CI/long-lived tokens.
- [How Claude Code works](references/claude-code-how-it-works.md) — the agentic loop (gather context, take action, verify results), models and tool categories, what Claude can access in a session, execution environments and interfaces, session management (resume, fork, context window, compaction), checkpoints, and permission modes.
- [Platforms and integrations](references/claude-code-platforms.md) — comparison of CLI, Desktop, VS Code, JetBrains, Web, and Mobile; integration guides for Chrome, GitHub Actions, GitLab CI/CD, Code Review, and Slack; remote access options (Dispatch, Remote Control, Channels, scheduled tasks).

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
