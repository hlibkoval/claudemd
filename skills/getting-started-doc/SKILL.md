---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview of what Claude Code is and what it can do, quickstart guide, installation and setup (native, Homebrew, WinGet, npm, Linux package managers), authentication (Pro/Max/Teams/Enterprise/Console/cloud providers, credential management, auth precedence), how Claude Code works (agentic loop, tools, sessions, context window, checkpoints, permission modes), platforms and integrations (CLI, Desktop, VS Code, JetBrains, web, mobile, CI/CD, Slack, Chrome), the /goal command for autonomous multi-turn workflows, key terminology glossary, and champion/communications kits for team rollout.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. It runs in your terminal, IDE, desktop app, and browser, using an **agentic loop** of gather context → take action → verify results.

### Installation

| Method | Command | Notes |
| :--- | :--- | :--- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Auto-updates in background |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Auto-updates in background |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Auto-updates in background |
| Homebrew (stable) | `brew install --cask claude-code` | Manual updates: `brew upgrade claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` | Manual updates: `brew upgrade claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` | Manual updates: `winget upgrade Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` | Do NOT use `sudo npm install -g` |
| apt (Debian/Ubuntu) | See setup reference | GPG key fingerprint: `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE` |
| dnf (Fedora/RHEL) | See setup reference | Same GPG fingerprint |
| apk (Alpine) | See setup reference | sha256 of RSA pub key in setup reference |

**System requirements:** macOS 13+, Windows 10 1809+/Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+; 4 GB RAM; x64 or ARM64; internet connection.

Verify after install: `claude --version` or `claude doctor`

### Account Types

| Account | Notes |
| :--- | :--- |
| Claude Pro / Max | Individual subscription, recommended |
| Claude for Teams / Enterprise | Centralized billing; Enterprise adds SSO, RBAC, managed policies |
| Claude Console | API-based billing; "Claude Code" workspace auto-created on first login |
| Amazon Bedrock / Google Vertex AI / Microsoft Foundry | Set required env vars; no browser login needed |

Free Claude.ai plan does not include Claude Code.

### Authentication Precedence (CLI only)

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — sent as `Authorization: Bearer`
3. `ANTHROPIC_API_KEY` — sent as `X-Api-Key`
4. `apiKeyHelper` script output
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`)
6. Subscription OAuth credentials from `/login`

Credential storage: macOS Keychain; Linux `~/.claude/.credentials.json` (mode 0600); Windows `%USERPROFILE%\.claude\.credentials.json`.

Generate a long-lived CI token (1-year OAuth, inference-only): `claude setup-token` → set `CLAUDE_CODE_OAUTH_TOKEN`.

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Show version |
| `claude update` | Apply update immediately |
| `claude doctor` | Diagnose installation issues |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` / `/logout` | Switch accounts |
| `/model` | Switch model mid-session |
| `/context` | See what is using context space |
| `/compact` | Trigger manual compaction |
| `/init` | Generate CLAUDE.md for project |

### Agentic Loop and Built-in Tools

| Tool category | What Claude can do |
| :--- | :--- |
| File operations | Read files, edit code, create/rename/reorganize |
| Search | Find files by pattern, regex content search, codebase exploration |
| Execution | Shell commands, start servers, run tests, use git |
| Web | Search web, fetch documentation, look up errors |
| Code intelligence | Type errors, definitions, references (requires code intelligence plugins) |

### Permission Modes (cycle with `Shift+Tab`)

| Mode | Behavior |
| :--- | :--- |
| Default | Claude asks before file edits and shell commands |
| Auto-accept edits | File edits and common filesystem commands flow through; other commands still prompt |
| Plan mode | Read-only research then proposes plan for approval before any edits |
| Auto mode | Background classifier reviews each action; research preview |

**Checkpoints:** Every file edit is reversible. Press `Esc` twice or `/rewind` to restore to a previous state.

### Sessions and Context

- Each session is independent with its own context window
- Sessions stored at `~/.claude/projects/` as JSONL
- `claude --continue` or `claude --resume` resumes; `--fork-session` or `/branch` copies into a new session
- **Compaction** auto-summarizes when context fills up; CLAUDE.md and auto memory survive and reload
- Run `/compact focus on <topic>` for directed compaction
- Add "Compact Instructions" section to CLAUDE.md to control what survives

### Platforms Overview

| Platform | Best for |
| :--- | :--- |
| CLI | Terminal workflows, scripting, full feature set, Agent SDK, third-party providers |
| Desktop app | Visual diff review, parallel sessions, computer use (Pro/Max) |
| VS Code | Inline diffs, file context, integrated terminal |
| JetBrains | IntelliJ, PyCharm, WebStorm — diff viewer, selection sharing |
| Web (claude.ai/code) | Cloud sessions that continue after you disconnect |
| Mobile | Start/monitor tasks; Remote Control for local sessions |

| Integration | Purpose |
| :--- | :--- |
| Chrome | Browser automation with your logged-in sessions |
| GitHub Actions | CI-driven automated PR reviews and issue triage |
| GitLab CI/CD | Same for GitLab |
| Code Review | Automatic review on every PR |
| Slack | Mention `@Claude` to turn bug reports into PRs |

### Remote and Scheduled Work

| Option | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Dispatch | Message task from Claude mobile app | Your machine (Desktop) |
| Remote Control | Drive session from browser/mobile | Your machine (CLI or VS Code) |
| Channels | Push events from Telegram, Discord, webhooks | Your machine (CLI) |
| Routines | Schedule | Anthropic cloud |
| Desktop scheduled tasks | Schedule | Your machine |
| `/loop` | Time interval | Current session |

### `/goal` — Autonomous Multi-Turn Workflows

`/goal` sets a completion condition; Claude keeps working across turns until a small fast model (Haiku by default) confirms it is met. Requires v2.1.139+.

| Command | Effect |
| :--- | :--- |
| `/goal <condition>` | Set or replace the active goal; starts a turn immediately |
| `/goal` | Check status (turns, tokens, evaluator reason) |
| `/goal clear` | Remove goal before condition is met (`stop`/`off`/`cancel` also accepted) |

Compare to related autonomous approaches:

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Model confirms condition met |
| `/loop` | Time interval elapses | You stop it or Claude decides done |
| Stop hook | Previous turn finishes | Your script/prompt decides |

**Effective condition checklist:** one measurable end state + a stated check (e.g. "`npm test` exits 0") + constraints that must hold throughout. Max 4,000 characters. To bound runtime, include "or stop after N turns."

`/goal` is unavailable when `disableAllHooks` or `allowManagedHooksOnly` is set.

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeat |
| Agentic harness | Claude Code's tools, context management, and execution environment that turn the model into a coding agent |
| Auto memory | Notes Claude writes for itself per git repo at `~/.claude/projects/`; first 200 lines/25 KB of `MEMORY.md` loads each session |
| CLAUDE.md | Your markdown file of persistent instructions, loaded every session |
| Checkpoint | Per-prompt restore point; `Esc` twice or `/rewind` to roll back |
| Compaction | Auto-summarization when context window fills |
| Session | A conversation tied to a directory with its own context window |
| Turn | One complete Claude response (may include many tool calls) |
| Subagent | Isolated assistant with its own context; returns a summary to the main conversation |
| MCP | Model Context Protocol — connects Claude to external services |
| Skill | A `SKILL.md` workflow file invokable with `/skill-name` |
| Hook | Deterministic handler that fires at a fixed lifecycle point |
| Plan mode | Permission mode where Claude only reads then proposes a plan |
| Non-interactive mode | `-p` / `--print` — one prompt, exits; formerly "headless mode" |
| Worktree isolation | `-w` flag; runs Claude in a separate git worktree branch |
| Managed settings | Org-wide enforced settings users cannot override |
| Bare mode | `--bare` flag; skips hooks, skills, plugins, MCP, CLAUDE.md auto-discovery |

### Update Configuration

| Setting | Effect |
| :--- | :--- |
| `autoUpdatesChannel: "latest"` | Receive updates immediately (default) |
| `autoUpdatesChannel: "stable"` | About one week behind, skips regressions |
| `minimumVersion: "x.y.z"` | Floor version; auto-updates won't downgrade below this |
| `DISABLE_AUTOUPDATER=1` | Stop background checks (manual `claude update` still works) |
| `DISABLE_UPDATES=1` | Block all update paths including manual |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — what Claude Code is, surfaces, capabilities, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session guide, essential commands, beginner tips
- [Advanced setup](references/claude-code-setup.md) — system requirements, all install methods, Windows/WSL/Alpine setup, update management, version pinning, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — login flow, team auth (Teams/Enterprise/Console/cloud), credential storage, auth precedence, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, tools, sessions, context window, compaction, checkpoints, permission modes, effective usage tips
- [Platforms and integrations](references/claude-code-platforms.md) — choosing a surface, integrations table, remote and scheduled work options
- [Keep Claude working toward a goal](references/claude-code-goal.md) — `/goal` command, writing effective conditions, evaluation model, comparison to `/loop` and Stop hooks
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terminology with links to in-depth pages
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers driving internal adoption: what to share, FAQ responses, 30-day rollout plan
- [Communications kit](references/claude-code-communications-kit.md) — copy-ready launch announcements, drip-campaign tips, FAQ one-liners for org-wide rollouts

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Keep Claude working toward a goal: https://code.claude.com/docs/en/goal.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
