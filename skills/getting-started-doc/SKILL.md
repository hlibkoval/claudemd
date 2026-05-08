---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview of capabilities and surfaces, quickstart guide, advanced setup and installation options, authentication methods, how the agentic loop works, platforms and integrations comparison, glossary of core terms, and resources for team champions and org-wide rollouts.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What Claude Code Is

Claude Code is an agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with development tools. Available in the terminal (CLI), VS Code, JetBrains, desktop app, and browser.

### Install

| Method | Command |
| :--- | :--- |
| macOS / Linux / WSL (native) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell (native) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | `sudo apt install claude-code` (after adding repo) |
| dnf (Fedora/RHEL) | `sudo dnf install claude-code` (after adding repo) |
| apk (Alpine) | `apk add claude-code` (after adding repo) |

Native installs auto-update. Homebrew, WinGet, and package-manager installs require manual upgrade.

### System Requirements

| Requirement | Details |
| :--- | :--- |
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Ubuntu | 20.04+ |
| Debian | 10+ |
| Alpine | 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Network | Internet required; see network config for enterprise allowlists |

### Windows Setup Options

| Option | Sandboxing | When to use |
| :--- | :--- | :--- |
| Native Windows (Git Bash) | Not supported | Windows-native projects and tools |
| WSL 2 | Supported | Linux toolchains or sandboxed command execution |
| WSL 1 | Not supported | If WSL 2 is unavailable |

### Authentication Methods and Precedence

Claude Code picks credentials in this order:

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — bearer token for LLM gateways/proxies
3. `ANTHROPIC_API_KEY` — direct Anthropic API key
4. `apiKeyHelper` script output — dynamic/rotating credentials
5. `CLAUDE_CODE_OAUTH_TOKEN` — long-lived token from `claude setup-token` (CI use)
6. Subscription OAuth from `/login` — default for Pro/Max/Team/Enterprise

**Team auth options:** Claude for Teams/Enterprise (recommended), Claude Console, Amazon Bedrock, Google Vertex AI, Microsoft Foundry.

**Credential storage by OS:**
- macOS: encrypted Keychain
- Linux: `~/.claude/.credentials.json` (mode `0600`)
- Windows: `%USERPROFILE%\.claude\.credentials.json`

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Verify installation |
| `claude doctor` | Diagnose installation and config issues |
| `claude update` | Apply update immediately |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `/login` | Log in or switch accounts |
| `/logout` | Log out |
| `/clear` | Reset conversation context |
| `/help` | Show available commands |
| `exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop

Every task cycles through three phases: **gather context → take action → verify results**, repeating until done. Each tool use returns information that informs the next step. You can interrupt at any point to steer.

**Built-in tool categories:**

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read, edit, create, rename, reorganize files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git, build tools |
| Web | Search the web, fetch documentation, look up errors |
| Code intelligence | Type errors, jump to definitions, find references (requires plugin) |

### Platforms Comparison

| Platform | Best for | Notable features |
| :--- | :--- | :--- |
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use (macOS) |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, Dispatch, computer use |
| VS Code | Editor-integrated work | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ/PyCharm/WebStorm | Diff viewer, selection sharing, terminal session |
| Web | Long-running or offline tasks | Anthropic-managed cloud, runs after disconnect |
| Mobile | Tasks while away from desk | Cloud sessions via Claude app, Remote Control, Dispatch |

### Key Integrations

| Integration | Use it for |
| :--- | :--- |
| Chrome | Testing web apps, browser automation with your logged-in sessions |
| GitHub Actions | Automated PR reviews, issue triage, scheduled CI tasks |
| GitLab CI/CD | Same as GitHub Actions for GitLab |
| Code Review | Automatic review on every pull request |
| Slack | Route bug reports from team chat to pull requests |

### Working Remotely / Away From Terminal

| Option | Claude runs on | Best for |
| :--- | :--- | :--- |
| Dispatch | Your machine (Desktop) | Delegating from phone, minimal setup |
| Remote Control | Your machine (CLI or VS Code) | Steering in-progress sessions from another device |
| Channels | Your machine (CLI) | Reacting to Telegram/Discord/custom events |
| Slack | Anthropic cloud | PRs and reviews from team chat |
| Scheduled tasks | CLI / Desktop / cloud | Recurring automation |

### Update Management

| Setting | Purpose |
| :--- | :--- |
| `autoUpdatesChannel: "latest"` | Default; updates as soon as released |
| `autoUpdatesChannel: "stable"` | ~1 week behind; skips major regressions |
| `minimumVersion: "2.x.y"` | Floor for auto-updates; prevents downgrade |
| `DISABLE_AUTOUPDATER=1` | Stop background checks (manual `claude update` still works) |
| `DISABLE_UPDATES` | Block all update paths including manual |
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` | Enable auto-update for Homebrew/WinGet installs |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeating until done |
| Agentic harness | Tools + context management + execution environment that turns a model into a coding agent |
| CLAUDE.md | Persistent project instructions loaded at session start; survives compaction |
| Auto memory | Notes Claude writes for itself per-repo; first 200 lines / 25 KB of `MEMORY.md` load each session |
| Compaction | Automatic summarization when context window fills; CLAUDE.md and auto memory survive |
| Checkpoint | Automatic file snapshot before each edit; `Esc` twice or `/rewind` to restore |
| Plan mode | Read-only exploration; proposes changes before any edits (`Shift+Tab`) |
| Permission mode | Baseline approval behavior; cycle with `Shift+Tab` |
| Skill | `SKILL.md` file adding instructions or workflows; invoked with `/name` |
| Hook | Shell command / MCP tool / LLM prompt that fires at fixed lifecycle points |
| MCP | Open standard for connecting Claude to external services (Slack, Jira, databases, etc.) |
| Subagent | Runs in its own context window with delegated task; returns summary to main session |
| Session | Conversation tied to a directory; resume with `claude -c`, fork with `--fork-session` |
| Surface | Any place you access Claude Code (CLI, VS Code, Desktop, web, etc.) |
| Remote Control | Continue a local session from phone/browser via claude.ai |
| Teleport | `/teleport` pulls a cloud session into your local terminal |
| Bare mode | `--bare` skips hooks, skills, plugins, MCP, memory, CLAUDE.md (for CI) |
| Non-interactive mode | `-p` flag; single prompt, then exit; formerly "headless mode" |

### Team Rollout Checklist (Comms Kit)

Before sending a launch announcement, verify:

- `#claude-code` channel created and linked
- Install command tested on at least one machine in your environment
- Security/data-handling link ready (`/en/data-usage` or internal equivalent)
- One concrete first task chosen from your own codebase
- Named owner for the channel for the first 48 hours
- C-suite sponsor lined up to send or co-sign

### Champion Quick-Reference

| Technique | How to apply |
| :--- | :--- |
| Right context | Use `@file` or `@directory/` references, or paste error/log output directly |
| Review before edit | `Shift+Tab` to enter plan mode; approve proposed changes before execution |
| Teach it your repo | Run `/init` to generate `CLAUDE.md`, then add conventions and test commands |
| Reuse a workflow | Save a `SKILL.md` in `.claude/skills/<name>/` to create a `/name` skill |
| Long task notifications | Configure a Stop hook for desktop notifications |
| Recover from wrong output | Paste the failing test or stack trace back; don't just rephrase the request |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — what Claude Code is, installation quick-start, capabilities, surfaces, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, log in, ask questions, make changes, use git
- [Advanced Setup](references/claude-code-setup.md) — system requirements, Windows/Alpine setup, verify install, update management, Linux package managers, npm install, binary integrity verification, uninstall
- [Authentication](references/claude-code-authentication.md) — login flow, team auth options, credential storage, authentication precedence, long-lived tokens for CI
- [How Claude Code Works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, what Claude can access, execution environments, session management, context window, checkpoints, permission modes, working effectively
- [Platforms and Integrations](references/claude-code-platforms.md) — comparison of CLI/Desktop/VS Code/JetBrains/Web/Mobile, integrations (Chrome, GitHub, GitLab, Slack), remote access options
- [Glossary](references/claude-code-glossary.md) — definitions for all core Claude Code terms with links to in-depth pages
- [Champion Kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally: sharing wins, answering questions, 30-day adoption plan, handling concerns
- [Communications Kit](references/claude-code-communications-kit.md) — launch announcements, drip-campaign tips, FAQ responses, prompt templates for org-wide rollouts

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
