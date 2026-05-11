---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, setup and installation, authentication, how the agentic loop works, platforms and integrations, glossary, champion kit, and communications kit for team rollouts.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code, including installation, authentication, how it works, available platforms, and team adoption resources.

## Quick Reference

### What Claude Code Is

Claude Code is an agentic coding assistant that runs in your terminal, IDE, desktop app, and browser. It reads your codebase, edits files, runs commands, and integrates with your development tools. It works through an **agentic loop**: gather context → take action → verify results → repeat.

### Installation

| Method | Command |
| :--- | :--- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | See reference doc for signed repo setup |
| dnf (Fedora/RHEL) | See reference doc for signed repo setup |
| apk (Alpine) | See reference doc for signed repo setup |

**System requirements:** macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+; 4 GB+ RAM; x64 or ARM64.

**Verify installation:** `claude --version` or `claude doctor`

**Update:** `claude update` (native auto-updates by default; Homebrew/WinGet require manual upgrade)

### Starting Claude Code

```bash
cd your-project
claude                    # Start interactive session
claude "task"             # Run a one-time task
claude -p "query"         # One-off query, then exit
claude -c                 # Continue most recent conversation
claude -r                 # Resume a previous conversation
```

First launch opens a browser for login. Use `/login` to switch accounts later.

### Authentication

| Account Type | How to Log In |
| :--- | :--- |
| Claude Pro / Max | Browser OAuth via `claude` on first launch |
| Claude for Teams / Enterprise | Browser OAuth with team-invited Claude.ai account |
| Claude Console | Browser OAuth with Console credentials |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK=1` + provider env vars |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX=1` + provider env vars |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY=1` + provider env vars |

**Authentication precedence (highest to lowest):**
1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (bearer token for LLM gateways)
3. `ANTHROPIC_API_KEY` (direct Anthropic API key)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token for CI, generated with `claude setup-token`)
6. Subscription OAuth credentials from `/login`

**Credential storage:** macOS Keychain; Linux `~/.claude/.credentials.json` (mode 0600); Windows `%USERPROFILE%\.claude\.credentials.json`.

**CI/headless:** Generate a one-year OAuth token with `claude setup-token`, then set `CLAUDE_CODE_OAUTH_TOKEN`.

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` | Switch accounts |
| `/logout` | Log out |
| `/model` | Switch model mid-session |
| `/init` | Generate CLAUDE.md for your project |
| `/context` | See what's using context window space |
| `/compact` | Summarize conversation to free context |
| `exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop and Built-in Tools

Claude Code works by cycling through: **gather context → take action → verify results → repeat**. Tools are what make it agentic:

| Tool Category | What Claude Can Do |
| :--- | :--- |
| File operations | Read files, edit code, create files, rename and reorganize |
| Search | Find files by pattern, search content with regex, explore codebases |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation, look up error messages |
| Code intelligence | See type errors and warnings, jump to definitions, find references (requires plugin) |

Claude sees your entire project, git state, CLAUDE.md, auto memory, and any MCP/skills/subagents you configure.

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | File edits and common filesystem commands flow through; asks for other commands |
| Plan mode | Read-only research; proposes a plan before any edits |
| Auto | Background classifier reviews each action (research preview) |

### Surfaces / Platforms

| Surface | Best for |
| :--- | :--- |
| CLI (terminal) | Full feature set, scripting, Agent SDK, remote servers |
| Desktop app | Visual diff review, parallel sessions, computer use (Pro/Max) |
| VS Code | Inline diffs, file context, no terminal switch needed |
| JetBrains | IntelliJ, PyCharm, WebStorm with diff viewer and selection sharing |
| Web (claude.ai/code) | Long-running cloud tasks that continue when you disconnect |
| Mobile (iOS/Android) | Starting/monitoring tasks; Remote Control for local sessions |

All surfaces share the same engine, CLAUDE.md, settings, and MCP servers.

### Integrations

| Integration | Use it for |
| :--- | :--- |
| Chrome | Browser automation with your logged-in sessions |
| GitHub Actions | Automated PR reviews, issue triage, scheduled maintenance |
| GitLab CI/CD | Same as GitHub Actions for GitLab |
| Code Review | Automatic review on every pull request |
| Slack | `@Claude` mentions in channels → pull requests |
| MCP servers | Connect Linear, Jira, Notion, Google Drive, custom APIs |

### Session Management

| Action | How |
| :--- | :--- |
| Undo file changes | `Esc` twice or `/rewind` — checkpoints taken before every edit |
| Resume a session | `claude --continue` (most recent) or `claude --resume` (pick from list) |
| Fork a session | `--fork-session` or `/branch` — copy history into a new session ID |
| Clear context | `/clear` — resets context; previous session stays available via `/resume` |
| Parallel sessions | Use git worktrees (separate directories per branch) |

Sessions are stored in `~/.claude/projects/` as JSONL files.

### Update and Uninstall

| Task | Command |
| :--- | :--- |
| Update (manual) | `claude update` |
| Set release channel | `/config` → Auto-update channel, or `"autoUpdatesChannel": "stable"` in settings.json |
| Disable auto-updates | `"env": { "DISABLE_AUTOUPDATER": "1" }` in settings.json |
| Uninstall (native, macOS/Linux) | `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude` |
| Uninstall (Homebrew) | `brew uninstall --cask claude-code` |
| Uninstall (npm) | `npm uninstall -g @anthropic-ai/claude-code` |
| Remove config/history | `rm -rf ~/.claude && rm ~/.claude.json` |

### Key Glossary Terms

| Term | Meaning |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results → repeat |
| Agentic harness | The tools, context management, and execution environment around the Claude model |
| CLAUDE.md | Persistent instruction file loaded every session |
| Auto memory | Notes Claude writes for itself, stored per git repo under `~/.claude/projects/` |
| Compaction | Automatic summarization when the context window fills up |
| Checkpoint | Automatic snapshot of files before each edit; press `Esc` twice to rewind |
| Skill | A SKILL.md file with instructions/workflow Claude loads automatically or on `/name` |
| Hook | Shell command/MCP tool that fires at lifecycle points (PreTool, PostTool, Stop, etc.) |
| MCP | Model Context Protocol — standard for connecting Claude to external services |
| Subagent | Specialized agent with its own context window, returns summary to main session |
| Session | A conversation tied to a directory with its own independent context window |
| Surface | Any place you access Claude Code (CLI, VS Code, Desktop, web, etc.) |
| Plan mode | Permission mode where Claude researches without editing until you approve |
| Sandboxing | OS-level filesystem/network isolation for the Bash tool |
| Remote Control | Continue a local session from phone or browser via claude.ai |
| Teleport | `/teleport` pulls a cloud session into your local terminal |
| Non-interactive mode | `-p` flag — executes one prompt and exits (formerly "headless mode") |

### Team Rollout Quick Reference

**For champions (individual engineers driving adoption):**
- Share prompts and screenshots from your own codebase in engineering channels
- Answer questions publicly so the answer benefits everyone watching
- Create a `#claude-code` channel and start a weekly show-and-tell thread
- Post custom skills and CLAUDE.md snippets your team can reuse

**Prompt templates to share with teammates:**

| Task | Prompt |
| :--- | :--- |
| Fix a bug | "the tests in [file] are failing, figure out why and fix it" |
| Understand code | "walk me through how [module] works, then tell me where the entry point is" |
| Safe refactor | "refactor [module] to [goal], use plan mode so I can review first" |
| Write tests | "write tests for [file] that cover the edge cases around [scenario]" |
| Review before commit | "look at my working diff and tell me what looks risky" |
| Open a PR | "fix [issue], write a conventional commit, and open a PR with a summary" |

**Common concerns and responses:**

| Concern | Response |
| :--- | :--- |
| "I do not trust AI to touch production code." | Plan mode + normal diff review = nothing applied unread, same as any PR |
| "It produced an incorrect result." | Paste the failing test or stack trace back to Claude; provide context with `@file` |
| "It does not understand our codebase conventions." | Run `/init` to generate CLAUDE.md, then add team conventions |
| "Is the setup worth the effort?" | Installation is ~2 minutes; run `/init` once to begin working |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, available surfaces, and what you can do with it
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session guide from install to git workflows
- [Advanced setup](references/claude-code-setup.md) — system requirements, all install methods, Windows/WSL setup, updates, release channels, uninstall
- [Authentication](references/claude-code-authentication.md) — login methods, team setup, credential storage, auth precedence, long-lived tokens for CI
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, sessions, context window, checkpoints, permission modes, and effectiveness tips
- [Platforms and integrations](references/claude-code-platforms.md) — comparison of all surfaces (CLI, Desktop, VS Code, JetBrains, web, mobile) and integrations (Chrome, GitHub Actions, Slack, etc.)
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terminology with links to in-depth pages
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers driving team adoption: what to share, how to answer questions, 30-day rollout plan
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, drip-campaign messages, and FAQ responses for administrators rolling out to an engineering org

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
