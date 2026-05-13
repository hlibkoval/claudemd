---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, installation, setup, authentication, quickstart, how Claude Code works (agentic loop, tools, sessions, context, permissions), platforms and integrations, glossary, the /goal command, and champion/communications kits for team rollouts.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. Available in the terminal, VS Code, JetBrains IDEs, a desktop app, and the browser at claude.ai/code.

### Installation

| Platform | Install command |
| :--- | :--- |
| macOS / Linux / WSL | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Native installs auto-update. Homebrew, WinGet, and Linux package managers do not; run the corresponding upgrade command manually or set `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1`.

### System Requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Network | Internet required |

### First-Run Quickstart

```bash
cd your-project
claude
# Follow browser prompts to log in
/init    # generates CLAUDE.md with project conventions
```

### Essential CLI Commands

| Command | Purpose |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run one-time task, then exit |
| `claude -p "query"` | Print-mode: single query, no session |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `/clear` | Start a new conversation |
| `/help` | Show available commands |
| `/model` | Switch model mid-session |
| `/init` | Generate CLAUDE.md for the project |
| `/goal <condition>` | Set a completion condition for autonomous work |
| `exit` or Ctrl+D | Exit Claude Code |

### Authentication Methods (Precedence Order)

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — Bearer token for LLM gateways
3. `ANTHROPIC_API_KEY` — Direct Anthropic API key
4. `apiKeyHelper` script — Dynamic/rotating credentials
5. `CLAUDE_CODE_OAUTH_TOKEN` — Long-lived token from `claude setup-token`
6. Subscription OAuth from `/login` — Default for Pro/Max/Team/Enterprise

To generate a CI-friendly long-lived token: `claude setup-token` (one year, scoped to inference only).

### The Agentic Loop

Every task follows three phases that blend together:

1. **Gather context** — read files, search codebase, understand the problem
2. **Take action** — edit files, run commands, create commits
3. **Verify results** — run tests, check outputs, course-correct

### Built-in Tool Categories

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git, build tools |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump to definitions, find references (requires plugin) |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Accept edits | File edits and common filesystem commands flow through; still asks for other commands |
| Plan | Read-only; Claude proposes a plan for approval before touching anything |
| Auto | Background classifier approves actions (research preview; Max/Team/Enterprise/API) |

### Execution Environments

| Environment | Where code runs | Use case |
| :--- | :--- | :--- |
| Local | Your machine | Default; full access to files and tools |
| Cloud | Anthropic-managed VMs | Offload tasks; works on repos you don't have locally |
| Remote Control | Your machine, UI from browser | Use the web UI while keeping everything local |

### Platforms at a Glance

| Platform | Best for |
| :--- | :--- |
| CLI | Terminal workflows, scripting, full feature set, Agent SDK |
| Desktop | Visual diff review, parallel sessions, computer use (Pro/Max) |
| VS Code | Inline diffs, integrated terminal, without leaving the editor |
| JetBrains | IntelliJ, PyCharm, WebStorm — diff viewer, selection sharing |
| Web | Long-running cloud tasks that keep running when you disconnect |
| Mobile (iOS/Android) | Starting tasks and monitoring via the Claude app |

CLAUDE.md, settings, and MCP servers are shared across all local surfaces.

### Session Management

| Action | Command |
| :--- | :--- |
| Continue most recent | `claude -c` or `claude --continue` |
| Resume a past session | `claude -r` or `claude --resume` |
| Fork a session | `--fork-session` or `/branch` |
| Undo changes | Esc+Esc (rewind) or `/rewind` |

Sessions are independent; each starts with a fresh context window. Persistent rules belong in CLAUDE.md, not the conversation.

### `/goal` Command

Set a completion condition; Claude keeps working until a model confirms the condition is met.

```text
/goal all tests in test/auth pass and the lint step is clean
```

| Command | Effect |
| :--- | :--- |
| `/goal <condition>` | Set or replace the active goal |
| `/goal` | Check status (turns, tokens, last evaluator reason) |
| `/goal clear` | Remove the active goal |

Goals use a session-scoped Stop hook. The evaluator model (Haiku by default) checks the condition after each turn. Requires hooks to be enabled and the project trust dialog to be accepted.

### Glossary of Key Terms

| Term | Meaning |
| :--- | :--- |
| Agentic loop | The gather→act→verify cycle Claude runs for every task |
| CLAUDE.md | Markdown file of persistent instructions you write, loaded every session |
| Auto memory | Notes Claude writes for itself; stored in `~/.claude/projects/` |
| Compaction | Automatic summarization when the context window fills up |
| Checkpoint | Automatic snapshot before each file edit; revert with Esc+Esc or `/rewind` |
| Skill | A SKILL.md file of instructions Claude loads automatically or you invoke as `/skill-name` |
| Hook | A user-defined handler that fires at a lifecycle event (PreToolUse, Stop, etc.) |
| Subagent | An AI assistant that runs in its own context window with delegated work |
| MCP | Model Context Protocol — standard for connecting Claude to external services |
| Plan mode | Permission mode where Claude proposes changes before touching any file |
| Non-interactive mode | Single-prompt execution via `-p`; used for CI and scripts |
| Bare mode | `--bare` skips all auto-discovery; use for reproducible CI runs |

### Team Rollout Essentials (Champion / Communications Kit)

**Quick wins to share with engineers:**
- Plan mode (`Shift+Tab`) — shows what files will be touched before anything is changed
- `/init` — generates CLAUDE.md from the project; stops re-explaining conventions
- `@file` or `@directory/` references — brings files into context without pasting
- `/rewind` or Esc+Esc — rolls back file changes and conversation to any earlier point
- Stop hooks — desktop notification when a long task finishes

**Starter prompts for new users:**
- "The test in [file] is flaky, figure out why and fix it"
- "Walk me through how [module] works"
- "Look at my working diff and tell me what looks risky"
- "Refactor [module] to [goal], use plan mode so I can review first"

**Common concerns:**
- "I don't trust it with my code" → plan mode + normal diff review; nothing lands unread
- "Where does my code go?" → runs in your terminal, talks to Anthropic's API; under Enterprise, code/prompts not used for training

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code overview](references/claude-code-overview.md) — what Claude Code is, getting started on each surface, capabilities, next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, login, explore, edit, git, common workflows
- [Advanced setup](references/claude-code-setup.md) — system requirements, Windows/WSL/Alpine setup, version management, Linux package managers, npm, binary verification, uninstallation
- [Authentication](references/claude-code-authentication.md) — login flow, team setup (Teams/Enterprise/Console/cloud providers), credential storage, auth precedence, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, tools, session management, context window, checkpoints, permission modes, working effectively
- [Platforms and integrations](references/claude-code-platforms.md) — platform comparison table, integrations (Chrome, GitHub Actions, GitLab, Slack, Code Review), remote access options
- [Glossary](references/claude-code-glossary.md) — definitions for agentic loop, CLAUDE.md, auto memory, compaction, checkpoint, skill, hook, subagent, MCP, and more
- [Keep Claude working toward a goal](references/claude-code-goal.md) — /goal command, writing effective conditions, status/clear/resume, non-interactive use, evaluation internals
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers driving internal adoption: what to share, how to answer questions, 30-day plan, common concerns
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, tips-and-tricks drip campaign, FAQ responses, prompt templates for rollout admins

## Sources

- Claude Code overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Keep Claude working toward a goal: https://code.claude.com/docs/en/goal.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
