---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, installation, authentication, quickstart walkthrough, how the agentic loop works, available platforms and integrations, glossary, champion kit, and communications kit for rollout.
user-invocable: false
---

# Getting Started with Claude Code Documentation

This skill provides the complete official documentation for getting started with Claude Code: what it is, how to install it, how to authenticate, your first session, how it works under the hood, where you can run it, and how to roll it out to a team.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. It is available in the terminal, VS Code, JetBrains IDEs, a desktop app, and the browser.

### Install

| Platform | Command |
| :--- | :--- |
| macOS / Linux / WSL | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Native installs auto-update in the background. Homebrew and WinGet do not — run `brew upgrade claude-code` or `winget upgrade Anthropic.ClaudeCode` manually.

Linux package managers (apt, dnf, apk) are also supported. See the [Advanced setup reference](references/claude-code-setup.md) for signed repo instructions.

### System Requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |

### Start Your First Session

```bash
cd your-project
claude
# Log in on first launch, then start prompting
```

Run `/init` once per repo — Claude reads your project and writes a `CLAUDE.md` with build commands and conventions.

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task and stay in session |
| `claude -p "query"` | Run a one-off query and exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation (picker) |
| `claude --version` | Verify installation |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Apply an update immediately |
| `/init` | Generate a CLAUDE.md for your project |
| `/login` | Switch accounts |
| `/logout` | Log out |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/model` | Switch model mid-session |
| `/compact` | Manually compact context |
| `/context` | Show what is using context space |
| `/rewind` | Roll back to an earlier checkpoint |
| `exit` or Ctrl+D | Exit Claude Code |

### Authentication Methods (Precedence Order)

| Priority | Method | When to use |
| :--- | :--- | :--- |
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, etc.) | Bedrock, Vertex, Foundry |
| 2 | `ANTHROPIC_AUTH_TOKEN` | LLM gateway / bearer token |
| 3 | `ANTHROPIC_API_KEY` | Direct Anthropic API |
| 4 | `apiKeyHelper` script | Dynamic / rotating credentials |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` | CI pipelines (from `claude setup-token`) |
| 6 | Subscription OAuth (`/login`) | Default for Pro, Max, Team, Enterprise |

### Team Authentication Options

| Option | Best for |
| :--- | :--- |
| Claude for Teams | Smaller teams, self-service, centralized billing |
| Claude for Enterprise | SSO, domain capture, managed policy, compliance |
| Claude Console | API-based billing, admin-managed keys |
| Amazon Bedrock | AWS infrastructure |
| Google Vertex AI | GCP infrastructure |
| Microsoft Foundry | Azure infrastructure |

### Credential Storage

| Platform | Location |
| :--- | :--- |
| macOS | Encrypted macOS Keychain |
| Linux / Windows | `~/.claude/.credentials.json` (or `$CLAUDE_CONFIG_DIR`) |

### How the Agentic Loop Works

Claude works through three phases for every task:

1. **Gather context** — reads files, searches code, runs exploration commands
2. **Take action** — edits files, runs shell commands, calls tools
3. **Verify results** — runs tests, checks output, course-corrects

Built-in tool categories:

| Category | Capabilities |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Run shell commands, tests, git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, definitions, references (requires plugin) |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Accept Edits | Edits files and common filesystem commands without asking; still asks for other commands |
| Plan | Read-only exploration, then proposes changes for approval |
| Auto | Background classifier reviews each action (research preview) |

### Surfaces at a Glance

| Surface | Best for |
| :--- | :--- |
| Terminal CLI | Full feature set, scripting, Agent SDK, third-party providers |
| Desktop app | Visual diff review, parallel sessions, computer use, Dispatch |
| VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | Diff viewer, selection sharing, terminal session |
| Web (claude.ai/code) | Cloud sessions that keep running when you disconnect |
| Mobile | Start and monitor tasks; Dispatch to Desktop; Remote Control |

### Integrations

| Integration | Purpose |
| :--- | :--- |
| Chrome | Automate browser tasks with your logged-in sessions |
| GitHub Actions | Automated PR reviews, issue triage, CI-driven maintenance |
| GitLab CI/CD | Same for GitLab |
| Code Review | Automatic review on every pull request |
| Slack | Mention @Claude, get pull requests back |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeated until done |
| Agentic harness | Claude Code's tools, context management, and execution environment |
| CLAUDE.md | Persistent markdown instructions loaded at every session start |
| Auto memory | Notes Claude writes for itself, stored per git repo under `~/.claude/projects/` |
| Compaction | Automatic summarization when the context window fills up |
| Checkpoint | Automatic file snapshot before each edit; restore with Esc+Esc or `/rewind` |
| Plan mode | Permission mode where Claude only reads/searches, then proposes changes |
| Skill | A `SKILL.md` file that packages a workflow or knowledge for Claude |
| Hook | Shell command, HTTP endpoint, or MCP tool that fires at a lifecycle event |
| MCP | Model Context Protocol — open standard for connecting Claude to external tools |
| Subagent | Specialized assistant with its own context window for delegated tasks |
| Session | A conversation tied to a directory, independently stored and resumable |
| Bare mode | `--bare` flag — skips auto-discovery of all local config for reproducible CI runs |

### Update Management

| Setting | Effect |
| :--- | :--- |
| `autoUpdatesChannel: "latest"` | New features immediately (default) |
| `autoUpdatesChannel: "stable"` | ~1 week delay, skips regressions |
| `minimumVersion: "x.y.z"` | Prevents downgrading below a floor version |
| `DISABLE_AUTOUPDATER: "1"` | Stops background check; `claude update` still works |
| `DISABLE_UPDATES` | Blocks all update paths including manual |

### First-Week Champion Habits

| Activity | Effort |
| :--- | :--- |
| Post a prompt + screenshot when you find something useful | ~15 min/week |
| Answer questions in `#claude-code` publicly | ~20 min/week |
| Run a weekly show-and-tell thread | ~5 min/week |
| Pair with one blocked colleague | 0-30 min/week |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, install configurator, available surfaces, what you can do, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, log in, ask questions, make code changes, use git
- [Advanced setup](references/claude-code-setup.md) — system requirements, Windows/WSL setup, Linux package managers, npm install, version management, binary integrity verification, and uninstall instructions
- [Authentication](references/claude-code-authentication.md) — login flow, team auth options (Teams, Enterprise, Console, cloud providers), credential storage, authentication precedence, long-lived tokens for CI
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, tools, what Claude can access, sessions, context window management, permission modes, and effective usage tips
- [Platforms and integrations](references/claude-code-platforms.md) — compare CLI, Desktop, VS Code, JetBrains, web, mobile; integrations (Chrome, GitHub Actions, GitLab, Code Review, Slack); remote access options
- [Glossary](references/claude-code-glossary.md) — definitions for agentic loop, auto memory, bare mode, checkpoint, CLAUDE.md, compaction, context window, hooks, MCP, permission mode, plugin, skill, subagent, session, and more
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally: what to share, how to answer questions, 30-day adoption plan, handling objections
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, drip-campaign tips, FAQ one-liners, and prompt templates for rolling out Claude Code to an engineering org

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
