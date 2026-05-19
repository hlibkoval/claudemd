---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview of what Claude Code is and what it can do, quickstart (install, login, first session, essential commands), advanced setup (system requirements, installation methods, update/uninstall, binary verification), authentication (account types, team setup, credential management, auth precedence, long-lived tokens), how Claude Code works (agentic loop, tools, sessions, context window, checkpoints, permission modes), platforms and integrations (CLI vs Desktop vs VS Code vs JetBrains vs web, remote access options), the /goal command (set completion conditions, evaluation, requirements), glossary of Claude Code terms, and team rollout resources (champion kit, communications kit).
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code, including installation, authentication, how the system works, available platforms, and team rollout resources.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. Available in your terminal, IDE, desktop app, and browser. It is not autocomplete — it reads your whole project and can work across multiple files and tools.

### Install Claude Code

| Platform | Command |
| :--- | :--- |
| macOS / Linux / WSL | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| Linux apt | See setup reference for signed apt/dnf/apk repos |

Native installs auto-update in the background. Homebrew and WinGet do not — run `brew upgrade claude-code` or `winget upgrade Anthropic.ClaudeCode` manually.

### System Requirements

| Requirement | Details |
| :--- | :--- |
| **OS** | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **Hardware** | 4 GB+ RAM, x64 or ARM64 |
| **Network** | Internet required |
| **Shell** | Bash, Zsh, PowerShell, or CMD (Git for Windows recommended on native Windows) |

Verify installation: `claude --version` or `claude doctor`

### Authentication

Run `claude` in your terminal; browser-based login opens on first launch.

| Account type | Notes |
| :--- | :--- |
| Claude Pro / Max / Team / Enterprise | Log in with claude.ai account — recommended |
| Claude Console | API access with pre-paid credits; Console workspace auto-created |
| Amazon Bedrock | Set cloud provider env vars; no browser login needed |
| Google Vertex AI | Set cloud provider env vars; no browser login needed |
| Microsoft Foundry | Set cloud provider env vars; no browser login needed |

**Authentication precedence** (highest → lowest):

1. `CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` / `CLAUDE_CODE_USE_FOUNDRY`
2. `ANTHROPIC_AUTH_TOKEN` (Bearer header)
3. `ANTHROPIC_API_KEY` (X-Api-Key header)
4. `apiKeyHelper` script output
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`)
6. Subscription OAuth credentials from `/login`

**Credential storage:** macOS Keychain; `~/.claude/.credentials.json` (mode 0600) on Linux; `%USERPROFILE%\.claude\.credentials.json` on Windows.

**Long-lived tokens for CI:** Run `claude setup-token` to generate a one-year OAuth token. Set it as `CLAUDE_CODE_OAUTH_TOKEN`. Requires Pro/Max/Team/Enterprise. Not usable with `--bare` mode.

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive: run query, print, exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation (picker) |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Manually update to latest version |
| `claude doctor` | Diagnose installation issues |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `/clear` | Start a new session |
| `/help` | Show available commands |
| `/login` / `/logout` | Switch accounts |
| `/model` | Switch model mid-session |
| `/init` | Generate CLAUDE.md from project structure |
| `/context` | See what's using context window space |
| `/compact` | Manually trigger context compaction |
| `/rewind` | Revert to an earlier checkpoint (Esc Esc) |
| `/goal <condition>` | Set autonomous completion condition |
| `exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop

Claude works in three repeating phases: **gather context → take action → verify results**. Each tool use feeds results back into the next step.

**Built-in tool categories:**

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read files, edit code, create files, rename/reorganize |
| Search | Find files by pattern, regex content search, explore codebases |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch docs, look up error messages |
| Code intelligence | Type errors, definitions, references (requires code intelligence plugin) |

### Permission Modes

Cycle through modes with `Shift+Tab`:

| Mode | Behavior |
| :--- | :--- |
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | File edits and common FS commands flow through; other commands still ask |
| **Plan mode** | Read-only research, then proposes a plan for approval before any edit |
| **Auto mode** | Background classifier reviews actions; research preview on Max/Team/Enterprise/API |

### Sessions and Context

- Sessions are tied to your current directory; each starts with a fresh context window.
- Resume with `claude -c` (most recent) or `claude -r` (picker).
- Fork a session with `--fork-session` or `/branch`.
- Context fills as you work; Claude auto-compacts. Use `/compact focus on X` to guide what's preserved.
- CLAUDE.md and auto memory survive compaction.
- Checkpoints snapshot files before every edit — press Esc twice or run `/rewind` to restore.

### `/goal` — Autonomous Completion

Requires Claude Code v2.1.139+. Sets a condition Claude keeps working toward across turns.

```
/goal all tests in test/auth pass and the lint step is clean
```

| Command | Effect |
| :--- | :--- |
| `/goal <condition>` | Set (or replace) the active goal; starts a turn immediately |
| `/goal` | Check status: condition, turns, tokens, latest evaluator reason |
| `/goal clear` | Remove active goal before condition is met |

After each turn, a small fast model (default: Haiku) checks the condition against the conversation. "No" sends Claude back to work with the reason as guidance.

**Comparison with other autonomous approaches:**

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Model confirms condition is met |
| `/loop` | Time interval elapses | You stop it, or Claude decides done |
| Stop hook | Previous turn finishes | Your own script or prompt decides |

`/goal` requires workspace trust and is unavailable when `disableAllHooks` or `allowManagedHooksOnly` is set.

### Platforms Overview

| Platform | Best for | Distinctive features |
| :--- | :--- | :--- |
| CLI | Terminal workflows, scripting, CI | Full feature set, Agent SDK, computer use (Pro/Max macOS) |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, Dispatch, computer use |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ / PyCharm / WebStorm | Diff viewer, selection sharing, terminal session |
| Web | Long-running tasks, offline continuation | Anthropic-managed cloud, continues after disconnect |
| Mobile | Starting/monitoring while away | Cloud sessions (iOS/Android), Remote Control, Dispatch |

You can mix surfaces on the same project. CLAUDE.md, settings, and MCP servers are shared across local surfaces.

### Remote Access Options

| Option | Claude runs on | Best for |
| :--- | :--- | :--- |
| Dispatch | Your machine (Desktop) | Phone-initiated tasks, minimal setup |
| Remote Control | Your machine (CLI/VS Code) | Steering in-progress work from another device |
| Channels | Your machine (CLI) | Reacting to chat/CI events (Telegram, Discord) |
| Slack | Anthropic cloud | PRs from `@Claude` mentions in team chat |
| Scheduled tasks | CLI, Desktop, or cloud | Recurring automation (daily reviews, nightly CI) |

### Integrations

| Integration | Use for |
| :--- | :--- |
| Chrome | Testing web apps, automating sites with your logged-in sessions |
| GitHub Actions | Automated PR reviews, issue triage, scheduled maintenance |
| GitLab CI/CD | Same as GitHub Actions for GitLab |
| Code Review | Automatic review on every PR |
| Slack | Bug reports → pull requests from team chat |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| **Agentic loop** | Gather context → take action → verify results, repeat |
| **Agentic harness** | The tools, context management, and execution environment around the model |
| **CLAUDE.md** | Markdown file of persistent instructions you write, loaded every session |
| **Auto memory** | Notes Claude writes for itself; stored in `~/.claude/projects/<project>/memory/` |
| **Checkpoint** | Snapshot before each edit; restore with Esc Esc or `/rewind` |
| **Compaction** | Auto-summarization when context window fills; project CLAUDE.md reloads after |
| **Skill** | `SKILL.md` file containing instructions/workflow Claude loads automatically or on `/name` |
| **Subagent** | Specialized agent in its own context window; returns summary to main conversation |
| **Permission mode** | Baseline approval behavior; cycle with Shift+Tab |
| **Plan mode** | Read-only research + proposal before any edits |
| **Auto mode** | Background classifier approves tool calls; research preview |
| **MCP** | Model Context Protocol — connects Claude to external services (Jira, Slack, databases) |
| **Hook** | Shell command/prompt/MCP tool that fires at fixed lifecycle points |
| **Session** | Conversation tied to current directory, with its own context window |
| **Turn** | One complete response from Claude (may include many tool calls) |
| **Surface** | Any interface: CLI, VS Code, JetBrains, Desktop, web |
| **Worktree isolation** | Runs Claude in a separate git worktree (`-w` flag) for parallel agents |
| **Bare mode** | `--bare` flag skips hooks/skills/MCP/CLAUDE.md; for CI/scripts |
| **Non-interactive mode** | `-p` flag; runs a prompt and exits; formerly "headless mode" |
| **Teleport** | `/teleport` pulls a cloud session into your local terminal |
| **Dispatch** | Routes a phone-initiated task to spawn a Desktop session |

### Team Rollout Quick Reference

**Before launch checklist:** Create `#claude-code` channel, test install command, have security/data-handling link ready, choose a concrete first task from your real codebase, name a channel owner for 48 hours, line up an exec sponsor.

**First tasks to recommend to new users:**
- "The test in [file] is flaky. Figure out why and fix it."
- "Walk me through how [module] works, then tell me where the entry point is."
- "Look at my working diff and tell me what looks risky."

**Champion quick-reference techniques:**

| Technique | How |
| :--- | :--- |
| Provide context | Use `@file` or `@directory/` references, or paste error output |
| Review plan first | Press Shift+Tab to enter plan mode |
| Teach it your repo | Run `/init` to generate CLAUDE.md |
| Reuse workflows | Create `.claude/skills/<name>/SKILL.md` |
| Stay informed on long tasks | Configure a Stop hook for desktop notification |
| Recover from bad result | Paste failing test or stack trace back, don't rephrase |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — what Claude Code is, get started across surfaces, what you can do, use Claude Code everywhere
- [Quickstart](references/claude-code-quickstart.md) — install, log in, first session, make a code change, git usage, essential commands, pro tips
- [Advanced setup](references/claude-code-setup.md) — system requirements, installation methods (native/Homebrew/WinGet/Linux packages/npm), Windows setup, update/release channels, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — account types, team setup (Teams/Enterprise/Console/cloud providers), credential management, auth precedence, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, tools, what Claude can access, environments and interfaces, sessions, context window management, checkpoints, permission modes, effective usage tips
- [Platforms and integrations](references/claude-code-platforms.md) — choose a platform, connect tools, remote access options, integrations reference
- [Keep Claude working toward a goal](references/claude-code-goal.md) — `/goal` command, comparison with `/loop` and Stop hooks, writing effective conditions, status/clear/resume, non-interactive use, evaluation model, requirements
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms with links to in-depth docs
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers driving internal adoption: what to share, answering objections, 30-day plan
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, tips-and-tricks drip campaign, FAQ responses, prompt templates for rollout admins

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
