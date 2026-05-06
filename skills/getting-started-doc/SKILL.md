---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup, authentication, how the agentic loop works, platform/surface comparison, glossary, and team rollout resources (champion kit and communications kit).
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code, from installation through understanding the agentic loop and rolling out to a team.

## Quick Reference

### Install Claude Code

| Platform | Command |
| :--- | :--- |
| macOS / Linux / WSL (recommended) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew | `brew install --cask claude-code` (does not auto-update) |
| WinGet | `winget install Anthropic.ClaudeCode` (does not auto-update) |
| npm | `npm install -g @anthropic-ai/claude-code` |
| Linux package managers | apt, dnf, or apk — see setup doc for signed repo instructions |

Native installs auto-update in the background. Homebrew/WinGet/package-manager installs require manual upgrade.

### System Requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13.0+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |

### Start Claude Code

```bash
cd your-project
claude              # Interactive session
claude "task"       # One-off task, then exit
claude -p "query"   # Non-interactive query, then exit
claude -c           # Continue most recent session
claude -r           # Resume a previous session
```

### Essential In-Session Commands

| Command | What it does |
| :--- | :--- |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out |
| `/init` | Generate CLAUDE.md from your project |
| `/clear` | Reset context window |
| `/compact` | Summarize context (optionally: `/compact focus on X`) |
| `/context` | Show what is using context space |
| `/model` | Switch model mid-session |
| `/plan` | Enter plan mode (read-only analysis) |
| `/rewind` | Restore code/conversation to a checkpoint |
| `/resume` | Pick a past session to continue |
| `Shift+Tab` | Cycle permission modes |
| `Esc + Esc` | Open rewind/checkpoint menu |
| `exit` or Ctrl+D | Quit |

### Authentication

| Account type | How to log in |
| :--- | :--- |
| Claude Pro / Max | Browser OAuth via `claude` on first run |
| Claude for Teams / Enterprise | Browser OAuth with team-admin-invited account |
| Claude Console | Browser OAuth with Console credentials |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK=1` + AWS env vars; no browser login |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX=1` + GCP env vars; no browser login |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY=1` + Azure env vars; no browser login |

**Authentication precedence (highest to lowest):**
1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `_VERTEX`, `_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — bearer token for LLM gateways/proxies
3. `ANTHROPIC_API_KEY` — direct Anthropic API key
4. `apiKeyHelper` script — dynamic/rotating credentials
5. `CLAUDE_CODE_OAUTH_TOKEN` — long-lived token for CI (generate with `claude setup-token`)
6. Subscription OAuth from `/login` — default for Pro/Max/Teams/Enterprise

**Credential storage:**
- macOS: encrypted macOS Keychain
- Linux: `~/.claude/.credentials.json` (mode 0600)
- Windows: `%USERPROFILE%\.claude\.credentials.json`

### The Agentic Loop

Claude works in three repeating phases for every task:

```
Gather context → Take action → Verify results → (repeat)
```

You can interrupt at any point to steer. Each tool use returns information that informs the next step.

**Built-in tool categories:**

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search the web, fetch documentation |
| Code intelligence | See type errors, jump to definitions (requires IDE plugin) |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and common filesystem commands without asking |
| Plan mode | Read-only analysis; proposes changes for your approval |
| Auto mode | Background classifier approves/blocks actions (research preview) |

### Surfaces / Platforms

| Surface | Best for |
| :--- | :--- |
| CLI (Terminal) | Full feature set, scripting, remote servers, Agent SDK |
| Desktop app | Visual diff review, parallel sessions, computer use |
| VS Code | Inline diffs, integrated terminal, file context in editor |
| JetBrains | Diff viewer, selection sharing, terminal session in IDE |
| Web (claude.ai/code) | Long-running cloud tasks that continue when offline |
| Mobile (Claude app) | Monitoring and starting tasks away from your computer |

Integrations: Chrome, GitHub Actions, GitLab CI/CD, Code Review (auto PR review), Slack.

### Update and Uninstall

| Action | Command |
| :--- | :--- |
| Update (native) | `claude update` (or auto-updates in background) |
| Update (Homebrew) | `brew upgrade claude-code` |
| Update (WinGet) | `winget upgrade Anthropic.ClaudeCode` |
| Configure update channel | `/config` → Auto-update channel, or `{"autoUpdatesChannel": "stable"}` in settings.json |
| Disable auto-update | `{"env": {"DISABLE_AUTOUPDATER": "1"}}` in settings.json |
| Uninstall (native, macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Uninstall (Homebrew) | `brew uninstall --cask claude-code` |
| Uninstall (WinGet) | `winget uninstall Anthropic.ClaudeCode` |
| Remove config/settings | `rm -rf ~/.claude && rm ~/.claude.json` |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| **Agentic loop** | Gather context → take action → verify results, repeating until task is done |
| **Agentic harness** | Tools, context management, and execution environment that make a model into an agent |
| **CLAUDE.md** | Markdown file of persistent instructions you write, loaded every session |
| **Auto memory** | Notes Claude writes for itself (MEMORY.md) stored per git repo |
| **Checkpoint** | Automatic snapshot before each edit; restore with `Esc+Esc` or `/rewind` |
| **Compaction** | Automatic summarization when context window fills up |
| **Skill** | SKILL.md file containing instructions/workflows; invoked with `/name` |
| **Hook** | Shell command/MCP tool that fires automatically at lifecycle points |
| **MCP** | Model Context Protocol — open standard for connecting Claude to external services |
| **Subagent** | Specialized agent with its own context window for delegated tasks |
| **Plan mode** | Read-only mode; Claude proposes changes for approval before touching files |
| **Session** | A conversation tied to your current directory with its own context window |
| **Surface** | Any place you access Claude Code (CLI, VS Code, Desktop, Web, etc.) |
| **Bare mode** | `--bare` flag that skips auto-discovery of hooks/skills/plugins/MCP for reproducible CI |
| **Non-interactive mode** | `-p` flag: single prompt, then exit; used for CI/scripts/piping |
| **Remote Control** | Continue a local session from your phone or browser via claude.ai |
| **Teleport** | `/teleport` — pull a cloud session into your local terminal |
| **Worktree isolation** | Run Claude in a separate git worktree so parallel agents don't collide |

### Team Rollout Quick Reference

**Pre-launch checklist:**
- `#claude-code` channel created
- Install command tested on your environment
- Data/security link ready (https://code.claude.com/docs/en/data-usage)
- One concrete first task chosen (e.g., "fix the flaky test in auth_test.go")
- Named channel owner for first 48 hours
- Executive sponsor lined up to send/co-sign announcement

**Model selection:**

| Model | Best for |
| :--- | :--- |
| Opus | Large refactors, complex debugging, architecture decisions |
| Sonnet | Everyday feature work, bugs, tests, reviews (recommended default) |
| Haiku | Quick questions, formatting, mechanical edits |

**Starter prompts for new users:**

| Task | Prompt |
| :--- | :--- |
| Fix a bug | "the tests in [file] are failing, figure out why and fix it" |
| Understand code | "walk me through how [module] works, then tell me where the entry point is" |
| Safe refactor | "refactor [module] to [goal], use plan mode so I can review first" |
| Write tests | "write tests for [file] that cover the edge cases around [scenario]" |
| Review before commit | "look at my working diff and tell me what looks risky" |
| Open a PR | "fix [issue], write a conventional commit, and open a PR with a summary" |

**Champion role — core behaviors:**

| Behavior | Time/week |
| :--- | :--- |
| Post wins and prompts with screenshots | ~15 min |
| Answer questions publicly in a shared channel | ~20 min |
| Host weekly show-and-tell thread | ~5 min |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, all surfaces, installation configurator, capabilities overview, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step: install, log in, first session, first question, first code change, git, bug fixes, essential commands
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific install (Windows/WSL/Alpine), update channels, version pinning, Linux package managers, npm, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — login flow, team setup (Teams/Enterprise/Console/cloud providers), credential storage, auth precedence, long-lived tokens for CI
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, built-in tools, what Claude can access, execution environments, session management, context window, checkpoints, permission modes, effective use tips
- [Platforms and integrations](references/claude-code-platforms.md) — surface comparison table, integrations (Chrome, GitHub Actions, GitLab, Code Review, Slack), remote access options (Dispatch, Remote Control, Channels, scheduled tasks)
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms: agentic loop, auto memory, bare mode, checkpoint, CLAUDE.md, compaction, context window, hooks, MCP, permissions, plugins, sessions, skills, subagents, teleport, worktrees, and more
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally: sharing discoveries, answering questions, 30-day rollout plan, handling skepticism
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements (email and Slack templates), executive sponsor variant, pilot group variant, drip campaign tips-and-tricks messages, FAQ responses

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
