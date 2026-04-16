---
name: getting-started-doc
description: Complete official getting-started documentation for Claude Code — what it is, install/setup, authentication precedence, the agentic loop, session model, and the platforms and surfaces on which it runs.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official onboarding documentation for Claude Code: the overview, quickstart, installation and setup, authentication, how the agentic loop works, and the platforms and integrations it supports.

## Quick Reference

### What Claude Code is

Claude Code is an agentic coding tool that reads your codebase, edits files, runs commands, and integrates with your development tools. It runs in the terminal, a desktop app, VS Code, JetBrains IDEs, the web, and mobile. The same engine powers every surface; CLAUDE.md files, settings, and MCP servers are shared across them.

### Install methods

| Method | Command | Auto-update |
|---|---|---|
| Native (macOS, Linux, WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew (stable) | `brew install --cask claude-code` | No — run `brew upgrade claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` | No |
| WinGet | `winget install Anthropic.ClaudeCode` | No — run `winget upgrade Anthropic.ClaudeCode` |
| npm (deprecated) | `npm install -g @anthropic-ai/claude-code` | No; requires Node.js 18+ |
| VS Code | Install `anthropic.claude-code` from the Marketplace | Handled by VS Code |
| JetBrains | Install from JetBrains Marketplace | Handled by IDE |
| Desktop | Download from claude.com/download | Built-in |

Install a specific channel or version by appending it: `curl -fsSL https://claude.ai/install.sh | bash -s stable` or `bash -s 2.1.89`. On Windows: `& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable`.

### System requirements

- **OS**: macOS 13.0+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **Hardware**: 4 GB+ RAM, x64 or ARM64
- **Shell**: Bash, Zsh, PowerShell, or CMD. Native Windows needs Git for Windows; WSL does not.
- **Network**: internet connection required
- **Alpine / musl**: install `libgcc`, `libstdc++`, `ripgrep`, and set `USE_BUILTIN_RIPGREP=0`

### Windows setup options

| Option | Requires | Sandboxing | When to use |
|---|---|---|---|
| Native Windows | Git for Windows | Not supported | Windows-native projects |
| WSL 2 | WSL 2 enabled | Supported | Linux toolchains or sandboxed commands |
| WSL 1 | WSL 1 enabled | Not supported | Fallback when WSL 2 unavailable |

If Claude Code can't locate Git Bash on Windows, set `CLAUDE_CODE_GIT_BASH_PATH` in `settings.json` under `env`.

### First-run commands

```bash
cd your-project
claude                 # start interactive session, prompts login on first run
claude --version       # verify install
claude doctor          # detailed install + configuration check
claude update          # apply updates immediately (native installs)
```

### Update and uninstall

- **Release channels**: set `autoUpdatesChannel` to `"latest"` (default) or `"stable"` in `settings.json`, or use `/config` to change. Homebrew chooses by cask name instead.
- **Disable auto-updates**: set `env.DISABLE_AUTOUPDATER` to `"1"` in `settings.json`.
- **Uninstall native (macOS/Linux/WSL)**: `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude`
- **Remove config**: `rm -rf ~/.claude ~/.claude.json` and project-local `.claude/` plus `.mcp.json`.

### Binary verification

Every release publishes `manifest.json` (SHA256 for each platform) and a detached GPG signature. Import the release key from `https://downloads.claude.ai/keys/claude-code.asc` — fingerprint `31DD DE24 DDFA B679 F42D  7BD2 BAA9 29FF 1A7E CACE` — then `gpg --verify manifest.json.sig manifest.json`. macOS binaries are notarized by Apple (signed "Anthropic PBC"); Windows binaries are Authenticode-signed; Linux relies on the manifest signature. Manifest signatures exist from `2.1.89` onward.

### Authentication

Claude Code requires a Pro, Max, Team, Enterprise, or Console account (free Claude.ai plans are not eligible), or a cloud provider. Run `claude` and follow the browser prompt; use `/logout` to sign out.

Team options: Claude for Teams (self-serve), Claude for Enterprise (SSO, domain capture, managed policies), Claude Console (API-based billing with Claude Code or Developer roles), or Amazon Bedrock / Google Vertex AI / Microsoft Foundry.

#### Credential precedence (highest to lowest)

1. Cloud provider (`CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` / `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (sent as `Authorization: Bearer`, for LLM gateways)
3. `ANTHROPIC_API_KEY` (sent as `X-Api-Key`; approval prompt in interactive mode, always used with `-p`)
4. `apiKeyHelper` script output (refreshed after 5 min or on HTTP 401; tune with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`)
5. `CLAUDE_CODE_OAUTH_TOKEN` (one-year token from `claude setup-token`; inference only, no Remote Control)
6. Subscription OAuth credentials from `/login` (default)

Notes: `apiKeyHelper` and API key env vars apply only to terminal CLI sessions — Desktop and remote sessions use OAuth only. Claude Code on the Web always uses subscription OAuth; env keys in the sandbox do not override. Bare mode (`--bare`) does not read `CLAUDE_CODE_OAUTH_TOKEN`. If a subscription login fails unexpectedly, check whether `ANTHROPIC_API_KEY` is set and shadowing it.

#### Credential storage

- macOS: encrypted Keychain
- Linux: `~/.claude/.credentials.json` (mode `0600`), or under `$CLAUDE_CONFIG_DIR`
- Windows: same path, inheriting profile ACLs

### The agentic loop

Three blended phases run until a task is complete: **gather context**, **take action**, **verify results**. Powered by a model (choose with `/model` or `claude --model <name>`) plus tools. Built-in tool categories:

| Category | Capabilities |
|---|---|
| File operations | Read, edit, create, rename, reorganize |
| Search | Glob, regex content search, exploration |
| Execution | Shell commands, servers, tests, git |
| Web | Search, fetch docs, look up errors |
| Code intelligence | Type errors, jump-to-definition, find references (via code intelligence plugins) |

Extensions on top of the loop: skills, MCP, hooks, and subagents. See the [Extend Claude Code overview](/en/features-overview).

### Sessions

- Saved as plaintext JSONL under `~/.claude/projects/`
- Tied to the current directory; each session starts with a fresh context window
- `claude --continue` / `claude --resume` resumes the same session ID; session-scoped permissions are not restored
- `claude --continue --fork-session` creates a new session ID while preserving history up to that point
- Run parallel sessions via git worktrees (separate directories)
- Resuming the same session from multiple terminals interleaves writes; prefer `--fork-session` for parallel work

### Context management

Context holds conversation history, files, command outputs, CLAUDE.md, auto memory, loaded skills, and system instructions. Auto-compaction kicks in as the window fills (older tool outputs first, then summarization). Persistent rules belong in CLAUDE.md. Useful commands and tactics:

- `/context` — see what is using space
- `/compact [focus]` — compact with a focus area
- `/mcp` — per-server token cost
- Add a "Compact Instructions" section to CLAUDE.md to preserve specific content
- Skills load on demand; set `disable-model-invocation: true` to keep descriptions out of context
- Subagents get a fresh context window and return only a summary

### Safety: checkpoints and permissions

- **Checkpoints**: every file edit is reversible. Press `Esc` twice to rewind. Checkpoints are local and cover file changes only — not remote side effects.
- **Permission modes** (cycle with `Shift+Tab`):
  - **Default** — ask before edits and shell commands
  - **Auto-accept edits** — edits and basic FS commands run without prompting
  - **Plan mode** — read-only tools only, produces a plan to approve
  - **Auto mode** — background safety checks on all actions (research preview)
- Pre-allow specific commands in `.claude/settings.json`

### Essential CLI commands

| Command | Purpose |
|---|---|
| `claude` | Start interactive mode |
| `claude "task"` | One-shot task |
| `claude -p "query"` | Non-interactive query, then exit |
| `claude -c` | Continue most recent conversation in the current dir |
| `claude -r` | Resume a previous conversation (picker) |
| `claude --continue --fork-session` | Branch off a new session from history |
| `claude setup-token` | Generate a long-lived OAuth token |
| `/clear` | Clear conversation history |
| `/help` | List commands |
| `/init` | Generate a CLAUDE.md for the project |
| `/agents` | Configure custom subagents |
| `/doctor` | Diagnose install issues |
| `/config` | Open configuration UI |
| `/login` / `/logout` | Re-authenticate |
| `/status` | Show active auth method |

### Platforms at a glance

| Platform | Best for | Notable |
|---|---|---|
| CLI | Terminal workflows, scripting, remote servers | Full feature set; Agent SDK and third-party providers are CLI-only; computer use on macOS Pro/Max |
| Desktop | Visual review, parallel sessions, managed setup | Diff viewer, app preview, Dispatch, computer use |
| VS Code | Editor-native work | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ/PyCharm/WebStorm family | Diff viewer, selection sharing |
| Web (claude.ai/code) | Long-running or offline-continuing tasks | Runs on Anthropic-managed VMs |
| Mobile (iOS/Android) | Starting/monitoring away from desktop | Cloud sessions, Remote Control, Dispatch |

### Integrations

| Integration | What it does |
|---|---|
| Chrome | Controls browser with your logged-in sessions |
| GitHub Actions | Runs Claude in CI |
| GitLab CI/CD | CI on GitLab |
| Code Review | Automatic PR review |
| Slack | Responds to `@Claude` mentions |
| MCP servers / connectors | Bring in Linear, Notion, Google Drive, custom APIs |

### Working when away from the terminal

| Option | Trigger | Runs on | Setup |
|---|---|---|---|
| Dispatch | Mobile app message | Your Desktop | Pair mobile app with Desktop |
| Remote Control | claude.ai/code or mobile | Your machine | `claude remote-control` |
| Channels | Chat-app or webhook events | Your CLI | Install a channel plugin or build your own |
| Slack | `@Claude` mention | Anthropic cloud | Install the Slack app with web enabled |
| Scheduled tasks / Routines | Time-based | CLI, Desktop, or cloud | Pick a frequency |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — What Claude Code is, install configurator, what you can do with it, and the list of surfaces and integrations.
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step first session: install, log in, ask the first question, make a change, use git, fix a bug, essential commands, and beginner tips.
- [Advanced setup](references/claude-code-setup.md) — System requirements, platform-specific installation, Windows/WSL/Alpine notes, release channels, auto-update controls, version pinning, binary verification, and uninstall.
- [Authentication](references/claude-code-authentication.md) — Log-in flow, team and Console setup, cloud provider auth, credential storage, precedence order, and long-lived OAuth tokens for CI.
- [How Claude Code works](references/claude-code-how-it-works.md) — The agentic loop, built-in tools, what Claude can access, sessions, context management, checkpoints and permissions, and tips for working effectively.
- [Platforms and integrations](references/claude-code-platforms.md) — Comparison of CLI, Desktop, VS Code, JetBrains, web, mobile, and integrations like Chrome, Slack, and CI/CD; options for working away from the terminal.

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
