---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, setup, authentication, how Claude Code works, platforms, goal-setting, glossary, champion kit, and communications kit.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### Installation

| Method | Command |
| :--- | :--- |
| macOS / Linux / WSL (native) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell (native) | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD (native) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | `sudo apt install claude-code` (after adding signed repo) |
| dnf (Fedora/RHEL) | `sudo dnf install claude-code` (after adding signed repo) |
| apk (Alpine) | `apk add claude-code` (after adding signed repo) |

- Native installs auto-update; Homebrew, WinGet, and package managers require manual upgrades.
- Release signing key fingerprint: `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`
- Verify install: `claude --version` or `claude doctor`

### System Requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13.0+, Windows 10 1809+/Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Network | Internet connection required |

### Authentication

Account types supported:

| Type | How to log in |
| :--- | :--- |
| Claude Pro / Max / Teams / Enterprise | Browser OAuth via `claude` on first launch |
| Claude Console | Console credentials; admin must invite user first |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK` + provider env vars |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX` + provider env vars |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY` + provider env vars |

Authentication precedence (highest first): cloud provider env vars → `ANTHROPIC_AUTH_TOKEN` → `ANTHROPIC_API_KEY` → `apiKeyHelper` script → `CLAUDE_CODE_OAUTH_TOKEN` → subscription OAuth from `/login`.

Credential storage: macOS Keychain / `~/.claude/.credentials.json` (Linux, mode 0600) / `%USERPROFILE%\.claude\.credentials.json` (Windows).

Generate a long-lived CI token (valid 1 year): `claude setup-token` → set `CLAUDE_CODE_OAUTH_TOKEN`.

### Core CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Manually apply a pending update |
| `claude doctor` | Diagnose installation issues |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `/login` | Switch or re-authenticate account |
| `/logout` | Log out of current account |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/init` | Generate CLAUDE.md from current project |
| `/model` | Switch model mid-session |
| `/compact` | Manually trigger context compaction |
| `/context` | See what is using context window space |
| `/plan` | Enter plan mode |
| `/rewind` | Revert conversation and file changes |
| `exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop

Claude works through three phases per task: **gather context → take action → verify results**, repeating until done. Each tool use informs the next step. You can interrupt at any time.

Built-in tool categories:

| Category | Capabilities |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump to definitions (requires plugin) |

### Permission Modes (cycle with Shift+Tab)

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and common filesystem commands without asking; still prompts for other commands |
| Plan mode | Read-only tools only; presents plan for approval before execution |
| Auto mode | Background classifier evaluates actions (research preview; Max, Team, Enterprise, API) |

Every file edit is checkpointed automatically. Press Esc twice or run `/rewind` to restore.

### Available Surfaces / Platforms

| Platform | Best for |
| :--- | :--- |
| CLI | Terminal workflows, scripting, remote servers — full feature set |
| Desktop app | Visual diff review, parallel sessions, computer use (Pro/Max) |
| VS Code | Inline diffs, integrated terminal, file context inside your editor |
| JetBrains | Diff viewer, selection sharing, terminal session inside JetBrains IDEs |
| Web (claude.ai/code) | Long-running tasks, repos you don't have locally, continues offline |
| Mobile | Starting/monitoring tasks; Dispatch to Desktop, Remote Control for local sessions |

Work-away-from-terminal options:

| Option | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | Drive from claude.ai/code or mobile | Your machine (CLI or VS Code) |
| Channels | Push events from Telegram, Discord, etc. | Your machine (CLI) |
| Slack | Mention `@Claude` in a channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### `/goal` — Keep Claude Working Toward a Condition

```
/goal <condition>      # Set a completion condition; starts a turn immediately
/goal                  # Check status (turns, tokens, last evaluator reason)
/goal clear            # Remove active goal before condition is met
```

- Condition evaluated after each turn by a small fast model (Haiku by default); Claude keeps working until "yes".
- Requires project trust and hooks enabled (`disableAllHooks` must not be set).
- Works non-interactively: `claude -p "/goal all tests pass"`
- Goals survive session resume (`--resume` / `--continue`); turn count and timer reset on resume.
- Condition limit: 4,000 characters. Include `or stop after N turns` to bound runtime.

Compare to related autonomous features:

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Model confirms condition met |
| `/loop` | Time interval elapses | You stop it, or Claude decides done |
| Stop hook | Previous turn finishes | Your own script or prompt decides |

### Auto-Update Configuration

| Setting | Effect |
| :--- | :--- |
| `"autoUpdatesChannel": "latest"` (default) | Receive new features immediately |
| `"autoUpdatesChannel": "stable"` | ~1 week delay, skips major-regression releases |
| `"minimumVersion": "X.Y.Z"` | Floor version; auto-updates won't install below this |
| `"env": {"DISABLE_AUTOUPDATER": "1"}` | Stop background auto-update checks |
| `"env": {"DISABLE_UPDATES": "1"}` | Block all update paths including manual |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeating per task |
| CLAUDE.md | Persistent instruction file loaded at session start; survives compaction |
| Auto memory | Notes Claude writes for itself, stored in `~/.claude/projects/`; first 200 lines / 25 KB load per session |
| Compaction | Auto-summarization when context window fills; CLAUDE.md and auto memory survive |
| Session | A conversation tied to a directory, with its own context window |
| Checkpoint | Automatic pre-edit snapshot; press Esc twice or `/rewind` to restore |
| Subagent | Specialized agent in its own context window; returns summary to main session |
| Skill | SKILL.md file with instructions/workflows; invoked by `/skill-name` |
| Hook | Shell/HTTP/MCP/prompt handler that fires at lifecycle events |
| MCP | Model Context Protocol — connects Claude to external tools and services |
| Plan mode | Read-only exploration; presents proposed changes for approval before editing |
| Permission mode | Session-wide baseline for how Claude handles approval prompts |
| Surface | Any interface to Claude Code (CLI, VS Code, Desktop, Web, JetBrains) |
| Bare mode | `--bare` flag; skips hooks, skills, MCP, CLAUDE.md for reproducible CI runs |
| Non-interactive mode | `-p` flag; executes one prompt then exits (formerly "headless mode") |
| Worktree isolation | `-w` flag; runs in separate git worktree so parallel agents don't collide |
| Remote Control | Continue local session from phone or browser via claude.ai |
| Teleport | `/teleport` pulls a cloud session into local terminal |

### Best Practices (Champion / Communications Kit Highlights)

First-use tasks that demonstrate value:
- Fix a flaky test: `"the test in [file] is flaky, figure out why and fix it"`
- Understand unfamiliar code: `"walk me through how [module] works"`
- Safe multi-file change: `"refactor [module] to [goal], use plan mode so I can review first"`
- Git workflow: `"fix [issue], write a conventional commit, and open a PR with a summary"`

Key habits for daily use:
1. Run `/init` once per repo to generate CLAUDE.md with project conventions.
2. Use plan mode (Shift+Tab) for anything touching multiple files.
3. Paste error output back to Claude rather than rephrasing requests.
4. Put persistent rules in CLAUDE.md, not in conversation history.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, surfaces, install methods, and what you can do
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, log in, explore, make edits, use git
- [Advanced setup](references/claude-code-setup.md) — system requirements, install methods, update channels, binary integrity, uninstall
- [Authentication](references/claude-code-authentication.md) — account types, team setup, credential management, auth precedence, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, sessions, context window, checkpoints, permissions
- [Platforms and integrations](references/claude-code-platforms.md) — surface comparison, integrations (Chrome, GitHub Actions, Slack), remote access options
- [Keep Claude working toward a goal](references/claude-code-goal.md) — `/goal` command, condition writing, evaluation, non-interactive use
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms with links to in-depth docs
- [Champion kit](references/claude-code-champion-kit.md) — playbook for internal advocates: sharing wins, answering objections, 30-day rollout
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, drip-campaign tips, FAQ responses for engineering orgs

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Keep Claude working toward a goal: https://code.claude.com/docs/en/goal.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
