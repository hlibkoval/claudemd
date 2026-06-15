---
name: getting-started-doc
description: Getting started with Claude Code — overview, quickstart, installation, authentication, how it works, platforms, goal command, glossary, and team rollout resources.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code, including installation, authentication, core concepts, platform options, the `/goal` command, a glossary of terms, and team rollout resources.

## Quick Reference

### Installation

| Method | Command |
|---|---|
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | See setup doc for signed repo configuration |
| dnf (Fedora/RHEL) | See setup doc for signed repo configuration |
| apk (Alpine) | See setup doc for signed repo configuration |

Native installs auto-update. Homebrew, WinGet, and Linux package manager installs require manual upgrades.

### System Requirements

- **OS**: macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **Hardware**: 4 GB+ RAM, x64 or ARM64
- **Shell**: Bash, Zsh, PowerShell, or CMD
- **Network**: Internet required

### Authentication — Account Types and Precedence

Auth is chosen in this order (first match wins):

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (bearer token for LLM gateway/proxy)
3. `ANTHROPIC_API_KEY` env var (direct Anthropic API key)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` env var (long-lived token from `claude setup-token`)
6. Subscription OAuth from `/login` (default for Claude Pro/Max/Team/Enterprise)

Credential storage: macOS Keychain; Linux `~/.claude/.credentials.json` (mode 0600); Windows `%USERPROFILE%\.claude\.credentials.json`.

To generate a long-lived CI token: `claude setup-token` — set result as `CLAUDE_CODE_OAUTH_TOKEN`.

### Key Shell Commands

| Command | What it does |
|---|---|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task and stay in session |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Verify installation |
| `claude doctor` | Diagnose installation and config |
| `claude update` | Update immediately without waiting for auto-update |
| `claude setup-token` | Generate a long-lived OAuth token for CI |

### Key Session Commands

| Command | What it does |
|---|---|
| `/help` | Show available commands |
| `/clear` | Reset context window |
| `/login` | Switch accounts or re-authenticate |
| `/logout` | Log out |
| `/model` | Switch model mid-session |
| `/init` | Generate CLAUDE.md for the project |
| `/resume` | Pick a previous session |
| `/rewind` | Restore to an earlier checkpoint |
| `/compact` | Summarize conversation to free context |
| `/exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop

Claude works through three phases for every task:

1. **Gather context** — reads files, searches code, runs exploration commands
2. **Take action** — edits files, runs commands, calls tools
3. **Verify results** — runs tests, checks output, course-corrects

These phases repeat until the task is done. You can interrupt at any point by pressing `Esc`.

### Built-in Tool Categories

| Category | What Claude can do |
|---|---|
| File operations | Read files, edit code, create files, rename and reorganize |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump to definitions, find references (requires plugin) |

### Permission Modes (Shift+Tab to cycle)

| Mode | Behavior |
|---|---|
| Default | Asks before file edits and shell commands |
| Auto-accept edits | Edits files and common filesystem commands without asking; still asks for other commands |
| Plan mode | Explores and proposes a plan without editing source files |
| Auto | Background safety classifier evaluates actions; research preview |

### Update Configuration

| Setting | Values | Effect |
|---|---|---|
| `autoUpdatesChannel` | `"latest"` (default) or `"stable"` | Controls which release stream auto-updates follow |
| `minimumVersion` | e.g. `"2.1.100"` | Sets a floor version; auto-updates refuse to go below it |
| `DISABLE_AUTOUPDATER` | `"1"` | Stops background update check; manual `claude update` still works |
| `DISABLE_UPDATES` | `"1"` | Blocks all updates including manual |

### Platforms at a Glance

| Platform | Best for | Key features |
|---|---|---|
| CLI | Terminal workflows, scripting, CI | Full feature set, Agent SDK, third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, Dispatch, computer use (Pro/Max) |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing, terminal session |
| Web | Long-running cloud tasks | Anthropic-managed, continues after disconnect |
| Mobile | Starting/monitoring away from desk | Cloud sessions or Remote Control into local session |

### The `/goal` Command

Set a completion condition and Claude works across turns until it is met. After each turn, a fast model checks whether the condition holds.

```
/goal all tests in test/auth pass and the lint step is clean
```

| Command | Effect |
|---|---|
| `/goal <condition>` | Set (or replace) active goal; starts a turn immediately |
| `/goal` (no args) | Show status: condition, turns, tokens, last evaluator reason |
| `/goal clear` | Remove active goal before it is met |

Writing effective conditions: state one measurable end state, describe how Claude should prove it (e.g., "`npm test` exits 0"), and add constraints that must hold throughout. Optionally add a turn/time bound like "or stop after 20 turns."

Conditions can be up to 4,000 characters. The evaluator uses the configured small fast model (defaults to Haiku) and only reads what Claude surfaced in the conversation — it does not run commands independently.

Requires Claude Code v2.1.139+. Unavailable when `disableAllHooks` or `allowManagedHooksOnly` is set.

### Glossary — Core Terms

| Term | Definition |
|---|---|
| Agentic loop | Gather context → take action → verify results → repeat |
| Agentic harness | Tools, context management, and execution environment around the model |
| Auto memory | Notes Claude writes for itself, stored per repo under `~/.claude/projects/` |
| CLAUDE.md | Persistent markdown instructions loaded every session as a user message |
| Checkpoint | Snapshot before every file edit; press `Esc` twice or `/rewind` to restore |
| Compaction | Automatic summarization when context window fills up; `/compact` to trigger manually |
| Context window | Working memory: conversation, files, command outputs, CLAUDE.md, skills |
| Hook | User-defined handler that fires at a specific lifecycle point |
| MCP | Model Context Protocol — open standard for connecting Claude to external services |
| Non-interactive mode | `-p` flag: single prompt, exits; formerly "headless mode" |
| Permission mode | Baseline approval behavior; cycle with `Shift+Tab` |
| Plan mode | Permission mode where Claude proposes changes before touching any file |
| Plugin | Bundle of skills, hooks, subagents, and MCP servers as one installable unit |
| Skill | SKILL.md file with instructions or workflows; invoke with `/skill-name` |
| Subagent | Specialized assistant with its own context window, delegated a task |
| Surface | Any place you access Claude Code (CLI, VS Code, Desktop, web…) |
| Teleport | `/teleport` — pulls a cloud session into your local terminal |
| Turn | One complete Claude response; Stop hooks fire at the end of each turn |
| Verification loop | Giving Claude a check (test, build) it can run to confirm work is done |
| Worktree isolation | `-w` flag — runs Claude in a separate git worktree to isolate changes |

### Team Rollout Quick Reference

**Pre-launch checklist**: `#claude-code` channel created, install command tested, security/data-handling link ready, one concrete first task chosen, named channel owner for 48 hours, exec sponsor lined up.

**Recommended first prompts for new users**:
- "The test in [file] is flaky, figure out why and fix it"
- "Walk me through how [module] works"
- "Look at my working diff and tell me what's risky before I push"

**Champion habits** (each ~15–20 min/week total):
- Post wins and prompts with a screenshot + one-line context
- Answer questions publicly in a shared channel
- Run a weekly "What did Claude help you with?" thread

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, installation methods, what you can do, surfaces comparison table
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step guide: install, log in, first session, first code change, Git usage, essential commands
- [Advanced setup](references/claude-code-setup.md) — System requirements, Windows/WSL setup, Linux package managers, npm install, binary integrity verification, update configuration, uninstallation
- [Authentication](references/claude-code-authentication.md) — Account types, team setup (Teams/Enterprise/Console/cloud providers), credential management, auth precedence, long-lived tokens for CI
- [How Claude Code works](references/claude-code-how-it-works.md) — Agentic loop, built-in tools, what Claude can access, execution environments, sessions, context window management, checkpoints, permission modes
- [Platforms and integrations](references/claude-code-platforms.md) — Platform comparison (CLI/Desktop/VS Code/JetBrains/web/mobile), integrations (Chrome/GitHub Actions/GitLab/Slack/Code Review), remote access options
- [Goal command](references/claude-code-goal.md) — `/goal` usage, writing effective conditions, status/clear commands, how the evaluator works, comparison with `/loop` and Stop hooks
- [Glossary](references/claude-code-glossary.md) — Definitions for all Claude Code terms with links to depth pages; deprecated/renamed terms table
- [Champion kit](references/claude-code-champion-kit.md) — Playbook for engineers advocating Claude Code internally: sharing, answering questions, 30-day adoption plan, handling common concerns
- [Communications kit](references/claude-code-communications-kit.md) — Launch announcements (email/Slack), exec sponsor variant, pilot variant, drip-campaign tips, FAQ responses, prompt templates for admins rolling out to a team

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Goal command: https://code.claude.com/docs/en/goal.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
