---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup, authentication, how it works (agentic loop, tools, sessions), platforms and integrations, glossary, and team adoption resources (champion kit, communications kit).
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

Claude Code is an agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with development tools. It runs in the terminal, IDE extensions, desktop app, and browser.

### Installation

| Method | Command |
| :--- | :--- |
| macOS / Linux / WSL (native) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell (native) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Linux package managers (apt, dnf, apk) are also supported for Debian, Fedora/RHEL, and Alpine.

Native installs auto-update in the background. Homebrew, WinGet, and package manager installs require manual upgrades.

### System requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13+, Windows 10 1809+/Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Network | Internet required |
| Shell | Bash, Zsh, PowerShell, or CMD |

### Authentication precedence

Claude Code picks credentials in this order:

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (bearer token, for LLM gateways)
3. `ANTHROPIC_API_KEY` env var (direct Anthropic API key)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` env var (long-lived token from `claude setup-token`)
6. Subscription OAuth credentials from `/login` (default for Pro/Max/Team/Enterprise)

Credentials are stored in macOS Keychain (macOS) or `~/.claude/.credentials.json` (Linux/Windows).

### Essential CLI commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive single query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude --bare` | Skip all auto-discovery (hooks, skills, MCP, CLAUDE.md) |
| `claude update` | Manually update to latest version |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `claude doctor` | Diagnose installation and configuration |
| `/clear` | Clear conversation history (start new session) |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/help` | Show available commands |
| `/init` | Generate CLAUDE.md from project structure |
| `/model` | Switch model mid-session |
| `/compact` | Manually compact context |
| `/context` | Show what is using context space |
| `/rewind` | Roll back to an earlier conversation point |
| `Shift+Tab` | Cycle permission modes |
| `Esc Esc` | Rewind/interrupt |

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Asks before file edits and shell commands |
| `acceptEdits` | Edits files and common filesystem commands without prompting; still asks for other commands |
| `plan` | Read-only tools only; presents a plan for approval before any edits |
| `auto` | Background classifier evaluates every action (research preview, Max/Team/Enterprise/API) |

Cycle with `Shift+Tab` in the terminal.

### The agentic loop

For every task, Claude works through three phases that blend together:
1. **Gather context** — read files, search codebase, check git state
2. **Take action** — edit files, run commands, call tools
3. **Verify results** — run tests, check output, course-correct

| Tool category | What Claude can do |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Run shell commands, tests, git operations |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, definitions, references (requires LSP plugin) |

### Platforms

| Platform | Best for |
| :--- | :--- |
| CLI (Terminal) | Full feature set, scripting, Agent SDK, third-party providers |
| Desktop app | Visual diff review, parallel sessions, computer use (Pro/Max) |
| VS Code extension | Inline diffs, integrated editor workflow |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm, and other JetBrains IDEs |
| Web (claude.ai/code) | Cloud sessions that keep running when you disconnect |
| Mobile | Starting/monitoring tasks; Dispatch to Desktop (Pro/Max) |

All surfaces share the same engine, CLAUDE.md, settings, and MCP servers.

### Sessions

- Each session is tied to a directory with its own context window.
- Sessions are stored under `~/.claude/projects/` as JSONL files.
- Resume with `claude -c` (most recent) or `claude -r` (pick from list).
- Fork a session without affecting the original: `claude --continue --fork-session`.
- Each new session starts with a fresh context window; persistent knowledge goes in CLAUDE.md or auto memory.

### Key glossary terms

| Term | Meaning |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeating until done |
| CLAUDE.md | Markdown file of persistent instructions loaded at every session start |
| Auto memory | Notes Claude writes for itself (stored in `~/.claude/projects/` per repo) |
| Compaction | Automatic summarization when context window fills up |
| Checkpoint | Automatic file snapshot before each edit; revert with Esc Esc or `/rewind` |
| Skill | SKILL.md file of instructions/workflows Claude loads automatically or on `/skill-name` |
| Hook | User-defined handler that fires at lifecycle points (PreToolUse, PostToolUse, Stop, etc.) |
| MCP | Model Context Protocol — connects Claude to external services |
| Subagent | Specialized agent with its own context window for delegated tasks |
| Plan mode | Read-only research phase; Claude proposes changes before executing |
| Bare mode | `--bare` flag — skips all auto-discovery for reproducible CI behavior |
| Remote Control | Drive a local session from a phone or browser via claude.ai |
| Teleport | `/teleport` pulls a cloud session into the local terminal |

### Team adoption quick reference

**Champion kit essentials:**

| Technique | How to apply |
| :--- | :--- |
| Provide context | Use `@file` or `@directory/` references, or paste error output directly |
| Review before edit | Press `Shift+Tab` to enter plan mode; approve before anything is touched |
| Teach your repo | Run `/init` to generate CLAUDE.md with conventions and build commands |
| Reuse workflows | Save `.claude/skills/<name>/SKILL.md` to create a `/name` team command |
| Recover from wrong output | Paste the failing test or stack trace back rather than rephrasing |

**Common concerns:**

| Concern | Response |
| :--- | :--- |
| "It hallucinated" | Likely a context problem — add `@file` references and run `/init` |
| "I don't trust it on production code" | Use plan mode; nothing is applied without your review, same as a PR diff |
| "Where does my code go?" | CLI talks directly to Anthropic API; under Enterprise, code is not used for training |
| "Is setup worth it?" | Install takes ~2 minutes; run `/init` once and you're set |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, all surfaces, installation, capabilities, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, log in, explore a codebase, make changes, use git
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific install, version management, release channels, uninstallation
- [Authentication](references/claude-code-authentication.md) — login methods, team and enterprise setup, credential management, long-lived tokens for CI
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, sessions, context window, checkpoints, permission modes, effective prompting tips
- [Platforms and integrations](references/claude-code-platforms.md) — CLI, Desktop, VS Code, JetBrains, Web, Mobile, Chrome, GitHub Actions, GitLab, Slack, Code Review, Remote Control
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers driving team adoption: what to share, how to answer questions, 30-day rollout plan
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, drip campaign tips, FAQ responses, and prompt templates for org rollout
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terminology with links to in-depth docs

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
- Glossary: https://code.claude.com/docs/en/glossary.md
