---
name: getting-started-doc
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: overview, quickstart, setup, authentication, how it works, platforms, glossary, and team rollout resources.

## Quick Reference

### Installation

| Method | Command |
|:-------|:--------|
| macOS / Linux / WSL (native) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell (native) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | Add signed repo, then `sudo apt install claude-code` |
| dnf (Fedora/RHEL) | Add signed repo, then `sudo dnf install claude-code` |
| apk (Alpine) | Add signed repo, then `apk add claude-code` |

Native installations auto-update in the background. Homebrew, WinGet, and Linux package managers require manual upgrades. Verify install: `claude --version`. Full diagnostics: `claude doctor`.

### System Requirements

| Item | Requirement |
|:-----|:------------|
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD |

### Authentication Methods (Precedence Order)

| Priority | Method | Notes |
|:---------|:-------|:------|
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`) | Amazon Bedrock, Google Vertex AI, Microsoft Foundry |
| 2 | `ANTHROPIC_AUTH_TOKEN` | Bearer token; use for LLM gateways/proxies |
| 3 | `ANTHROPIC_API_KEY` | Direct Anthropic API key; takes precedence over subscription |
| 4 | `apiKeyHelper` script | Dynamic/rotating credentials |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` | Long-lived token from `claude setup-token`; for CI |
| 6 | Subscription OAuth (`/login`) | Default for Pro/Max/Team/Enterprise users |

Credentials stored: macOS Keychain, Linux `~/.claude/.credentials.json` (mode 0600), Windows `%USERPROFILE%\.claude\.credentials.json`. Log in: run `claude`. Re-authenticate: `/logout` then `/login`.

### Generate a Long-Lived Token (CI/Scripts)

```bash
claude setup-token
export CLAUDE_CODE_OAUTH_TOKEN=<token>
```

Requires Pro, Max, Team, or Enterprise plan. Token is inference-only; does not support Remote Control.

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit (non-interactive) |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Show installed version |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Apply update immediately |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` / `/logout` | Authenticate / de-authenticate |
| `/model` | Switch model mid-session |
| `/context` | See what is using context window space |
| `/compact` | Manually trigger context compaction |
| `/init` | Generate a CLAUDE.md for the project |
| `/goal <condition>` | Keep working until condition is met (v2.1.139+) |
| `exit` or Ctrl+D | Exit Claude Code |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|:-----|:---------|
| Default | Asks before file edits and shell commands |
| Auto-accept edits (`acceptEdits`) | File edits and common filesystem commands flow through; asks for other commands |
| Plan | Read-only tools only; proposes a plan for approval before any edits |
| Auto | Background classifier reviews each action; research preview |

### The Agentic Loop

Three phases repeat until the task is done: **gather context** → **take action** → **verify results**. Each tool use returns information that feeds the next step. You can interrupt at any point.

### Built-in Tool Categories

| Category | Capabilities |
|:---------|:------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Shell commands, tests, git, servers |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, go-to-definition, find references (requires plugin) |

### What Claude Can Access

- Files in your project directory (and elsewhere with permission)
- Any terminal command you could run
- Git state (branch, changes, history)
- Your `CLAUDE.md` (persistent project instructions)
- Auto memory (`MEMORY.md`, first 200 lines / 25 KB per session)
- Configured MCP servers, skills, subagents, and Claude in Chrome

### Context Window Management

| Mechanism | How it helps |
|:----------|:------------|
| `CLAUDE.md` | Persistent instructions; survives compaction; reloaded from disk |
| Auto memory | Claude-written notes; survives compaction |
| `/compact [focus on ...]` | Manual compaction with optional focus |
| `disable-model-invocation: true` on skills | Keeps skill descriptions out of context until you invoke |
| Subagents | Run in their own isolated context; return only a summary |
| `/context` | Inspect context usage |

### Session Management

| Action | How |
|:-------|:----|
| Resume last session | `claude -c` or `claude --continue` |
| Pick a session to resume | `claude -r` or `claude --resume` |
| Fork a session | `--fork-session` or `/branch` |
| Undo file changes | Press `Esc` twice, or `/rewind` |
| Parallel sessions | Use git worktrees (`claude -w`) |

Sessions are stored under `~/.claude/projects/` as JSONL. Each session is independent with its own context window.

### `/goal` — Run Until a Condition Is Met

| Action | Command |
|:-------|:--------|
| Set goal | `/goal <condition>` |
| Check status | `/goal` (no args) |
| Clear goal | `/goal clear` |
| Run non-interactively | `claude -p "/goal <condition>"` |

After each turn, a small fast model (default: Haiku) evaluates the condition against the conversation transcript. Requires hooks to be enabled. Works with auto mode for fully unattended runs.

### Platforms Comparison

| Platform | Best for | CLI-only features |
|:---------|:---------|:-----------------|
| CLI | Terminal workflows, scripting, remote servers | Agent SDK, computer use (macOS), all third-party providers |
| Desktop | Visual review, parallel sessions, managed setup | Diff viewer, Dispatch, computer use (Pro/Max) |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal |
| JetBrains | IntelliJ, PyCharm, WebStorm, other JetBrains IDEs | Diff viewer, selection sharing |
| Web | Long-running cloud tasks, no local setup needed | Continues after disconnect |
| Mobile | Starting/monitoring tasks away from computer | Remote Control, Dispatch to Desktop |

Configuration, project memory, and MCP servers are shared across all local surfaces.

### Remote Access Options

| Option | How Claude runs | Best for |
|:-------|:----------------|:---------|
| Dispatch | Your machine (Desktop) | Phone → Desktop task delegation |
| Remote Control | Your machine (CLI or VS Code) | Steering in-progress work from another device |
| Channels | Your machine (CLI) | React to Telegram, Discord, or custom webhook events |
| Slack | Anthropic cloud | PRs from team chat with `@Claude` mentions |
| Scheduled tasks | CLI, Desktop, or cloud | Recurring automation |

### Key Glossary Terms

| Term | Definition |
|:-----|:-----------|
| Agentic loop | Gather context → take action → verify results, repeating until done |
| Agentic harness | Claude Code itself: the tools, context management, and execution environment around the model |
| CLAUDE.md | Your hand-written persistent instructions; loaded as a user message each session |
| Auto memory | Claude-written notes from corrections/preferences; stored per repo under `~/.claude/projects/` |
| Compaction | Automatic summarization when context window approaches its limit |
| Checkpoint | Per-prompt file snapshot; press Esc twice or `/rewind` to restore |
| Skill | A `SKILL.md` file with instructions or workflows; invocable as `/skill-name` |
| Hook | Shell command / HTTP / MCP / LLM prompt that fires at fixed lifecycle points |
| MCP | Model Context Protocol; connects Claude to external services and data |
| Subagent | Isolated context window for a delegated task; returns only a summary |
| Plan mode | Read-only exploration; Claude proposes changes before touching files |
| Bare mode | `--bare` flag; skips all auto-discovery for reproducible CI runs |
| Non-interactive mode | `-p` flag; executes one prompt and exits |
| Teleport | `/teleport` pulls a cloud session into your local terminal |
| Verification loop | Giving Claude a runnable check so it iterates until the check passes |

### Update Management

| Setting | Effect |
|:--------|:-------|
| `autoUpdatesChannel: "latest"` | Default; new features as soon as released |
| `autoUpdatesChannel: "stable"` | ~1 week old; skips releases with major regressions |
| `DISABLE_AUTOUPDATER: "1"` | Stops background check; `claude update` still works |
| `DISABLE_UPDATES` | Blocks all update paths including manual |
| `minimumVersion: "x.y.z"` | Floor version; prevents downgrade below this value |
| `claude update` | Apply update immediately |

### Uninstallation

| Method | Command |
|:-------|:--------|
| Native (macOS/Linux/WSL) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Homebrew | `brew uninstall --cask claude-code` |
| WinGet | `winget uninstall Anthropic.ClaudeCode` |
| npm | `npm uninstall -g @anthropic-ai/claude-code` |
| Remove config/data | `rm -rf ~/.claude ~/.claude.json` (also remove `.claude/` and `.mcp.json` from project dirs) |

### Team Rollout Checklist (Admins)

- Create `#claude-code` channel and link it in announcement
- Test install command on a machine in your environment
- Prepare security/data-handling link (`/en/data-usage` or internal equivalent)
- Choose one concrete first task from your actual codebase
- Name an owner for the channel for the first 48 hours
- Consider an executive sponsor for the announcement

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, all surfaces, and "what you can do" capability overview
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step first session: install, log in, ask questions, make edits, use git
- [Advanced setup](references/claude-code-setup.md) — System requirements, platform-specific install, updates, version management, uninstallation
- [Authentication](references/claude-code-authentication.md) — Login, account types, team setup, credential management, long-lived tokens, precedence order
- [How Claude Code works](references/claude-code-how-it-works.md) — Agentic loop, built-in tools, sessions, context window, checkpoints, permission modes, working effectively
- [Platforms and integrations](references/claude-code-platforms.md) — Platform comparison table, integrations (Chrome, GitHub Actions, Slack, etc.), remote access options
- [Keep Claude working toward a goal](references/claude-code-goal.md) — `/goal` command: set conditions, evaluation, status, `/loop` vs Stop hook comparison
- [Champion kit](references/claude-code-champion-kit.md) — Playbook for engineers driving internal adoption: sharing techniques, answering questions, 30-day plan
- [Communications kit](references/claude-code-communications-kit.md) — Launch announcements, drip-campaign tips, FAQ responses for org-wide rollouts
- [Glossary](references/claude-code-glossary.md) — Definitions for all Claude Code terms: agentic loop, compaction, hooks, subagents, MCP, and more

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Keep Claude working toward a goal: https://code.claude.com/docs/en/goal.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
- Glossary: https://code.claude.com/docs/en/glossary.md
