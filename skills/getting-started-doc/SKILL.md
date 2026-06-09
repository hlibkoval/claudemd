---
name: getting-started-doc
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: what it is, how to install and authenticate it, how the agentic loop works, which platforms and integrations are available, and key terminology.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. It works in your terminal, IDE, desktop app, and browser. Unlike inline code assistants that only see the current file, Claude Code sees your whole project and can work across multiple files and tools.

### Installation

| Method | Command | Auto-updates? |
| :--- | :--- | :--- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` | Yes |
| Homebrew stable | `brew install --cask claude-code` | No (run `brew upgrade`) |
| Homebrew latest | `brew install --cask claude-code@latest` | No |
| WinGet | `winget install Anthropic.ClaudeCode` | No |
| npm | `npm install -g @anthropic-ai/claude-code` | No |
| apt (Debian/Ubuntu) | See setup doc | No |
| dnf (Fedora/RHEL) | See setup doc | No |
| apk (Alpine) | See setup doc | No |

**System requirements:** macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+. 4 GB RAM, x64 or ARM64. Internet required.

**Verify install:** `claude --version` or `claude doctor`

### Authentication

| Account type | How to authenticate |
| :--- | :--- |
| Claude Pro / Max / Teams / Enterprise | Run `claude`, follow browser prompts |
| Claude Console (API) | Run `claude`, follow browser prompts |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK=1` + cloud env vars |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX=1` + cloud env vars |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY=1` + cloud env vars |

**Credential precedence (highest to lowest):**
1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` / `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (bearer token for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` (direct Anthropic API key)
4. `apiKeyHelper` script (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`)
6. Subscription OAuth from `/login` (default for Pro/Max/Teams/Enterprise)

**Long-lived token for CI:** `claude setup-token` — generates a one-year OAuth token; set as `CLAUDE_CODE_OAUTH_TOKEN`.

**Credential storage:** macOS Keychain; `~/.claude/.credentials.json` (0600) on Linux; `%USERPROFILE%\.claude\.credentials.json` on Windows.

### The Agentic Loop

Claude works through three phases — **gather context → take action → verify results** — chaining them repeatedly until done. Each tool use returns information that informs the next step.

**Built-in tool categories:**

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read files, edit code, create/rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, definitions, references (requires plugins) |

### Permission Modes

Cycle through modes with `Shift+Tab`:

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| acceptEdits | File edits and common filesystem commands flow through; still asks for other shell commands |
| Plan | Read-only tools only; Claude proposes a plan before executing |
| Auto | Background classifier reviews all actions (research preview) |

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit (non-interactive) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` / `--resume` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude doctor` | Diagnose installation issues |
| `claude setup-token` | Generate a long-lived OAuth token |
| `claude update` | Apply updates immediately |
| `/clear` | Clear conversation history (starts new session) |
| `/help` | Show available commands |
| `/login` | Re-authenticate |
| `/logout` | Log out |
| `/model` | Switch models mid-session |
| `/compact` | Manually trigger context compaction |
| `/context` | See what's using context space |
| `/init` | Generate a CLAUDE.md for the current project |
| `/goal <condition>` | Keep Claude working until condition is met (v2.1.139+) |
| `exit` or Ctrl+D | Exit Claude Code |

### What Claude Can Access

When you run `claude` in a directory, Claude Code accesses:
- Files in your directory and subdirectories (plus others with permission)
- Your terminal (any command you can run from the CLI)
- Your git state (branch, uncommitted changes, recent history)
- Your CLAUDE.md (persistent project instructions)
- Auto memory (learnings Claude saves across sessions, first 200 lines/25KB of MEMORY.md)
- Extensions you configure (MCP servers, skills, subagents, Chrome)

### Platforms and Surfaces

| Platform | Best for | Notes |
| :--- | :--- | :--- |
| CLI (Terminal) | Terminal workflows, scripting, remote servers | Full feature set; Agent SDK, computer use on macOS |
| Desktop app | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch (Pro/Max) |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm, etc. | Diff viewer, selection sharing, terminal |
| Web (claude.ai/code) | Long-running tasks, offline work | Anthropic-managed cloud; keeps running after disconnect |
| Mobile | Starting/monitoring tasks while away | Cloud sessions or Remote Control of local sessions |

### Integrations

| Integration | Use it for |
| :--- | :--- |
| Chrome | Testing web apps, automating browser tasks |
| GitHub Actions | Automated PR reviews, issue triage |
| GitLab CI/CD | CI-driven automation on GitLab |
| Code Review | Automatic review on every PR |
| Slack | `@Claude` mentions → pull requests from team chat |
| MCP servers / connectors | Linear, Notion, Google Drive, custom internal APIs |

### Remote and Away-from-Terminal Options

| Option | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | `claude remote-control` | Your machine (CLI or VS Code) |
| Channels | Push events from Telegram/Discord/custom server | Your machine (CLI) |
| Slack | `@Claude` mention | Anthropic cloud |
| Scheduled tasks (`/loop`, routines, desktop scheduled tasks) | Set schedule | CLI / Desktop / cloud |

### Sessions and Context

- **Sessions are independent.** Each new session starts with a fresh context window.
- **Resume:** `claude -c` (most recent) or `claude -r` (pick from list)
- **Fork:** `--fork-session` or `/branch` — copies history into a new session ID
- **Context:** holds conversation history, file contents, CLAUDE.md, auto memory, loaded skills. Run `/context` to see usage.
- **Compaction:** automatic summarization when context fills; CLAUDE.md and auto memory survive and reload.
- **Checkpoints:** file snapshots before every edit; press `Esc` twice or `/rewind` to restore.

### The `/goal` Command (v2.1.139+)

Set a completion condition and Claude keeps working across turns until the condition is met.

```text
/goal all tests in test/auth pass and the lint step is clean
```

| Command | Effect |
| :--- | :--- |
| `/goal <condition>` | Set or replace active goal; starts a turn immediately |
| `/goal` | Check status (turns, tokens, evaluator reason) |
| `/goal clear` | Remove active goal early |

**Comparison of session-continuation approaches:**

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Model confirms condition is met |
| `/loop` | A time interval elapses | You stop it, or Claude decides done |
| Stop hook | Previous turn finishes | Your script/prompt decides |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Cycle of gather context → take action → verify results, powered by tools |
| Agentic harness | Claude Code itself: tools, context management, execution environment around the model |
| Auto memory | Notes Claude writes for itself (per git repo) at `~/.claude/projects/`; first 200 lines/25KB load at session start |
| CLAUDE.md | Markdown file of persistent instructions you write, loaded every session |
| Checkpoint | File snapshot before each edit; press Esc twice or `/rewind` to restore |
| Compaction | Automatic summarization when context window fills |
| Context window | Working memory: conversation, files, outputs, CLAUDE.md, skills, system instructions |
| Hook | User-defined handler firing at lifecycle points (e.g., PreToolUse, Stop) |
| MCP | Model Context Protocol; standard for connecting Claude to external services |
| Permission mode | Baseline approval behavior: default, acceptEdits, plan, auto |
| Plugin | Bundle of skills/hooks/subagents/MCP servers as an installable unit |
| Remote Control | Drive a local session from phone/browser; code stays on your machine |
| Session | A conversation tied to a directory with its own context window |
| Skill | SKILL.md file with instructions/workflows; invoke with `/skill-name` |
| Subagent | Specialized assistant in its own context window for delegated tasks |
| Surface | Any place you access Claude Code (CLI, VS Code, Desktop, web, etc.) |
| Turn | One complete Claude response (one user message → end of Claude's reply) |
| Worktree isolation | `-w` flag / `isolation: worktree`; runs Claude in a separate git worktree |

### Version Updates

| Channel | Setting | Behavior |
| :--- | :--- | :--- |
| `latest` (default) | `"autoUpdatesChannel": "latest"` | New features as soon as released |
| `stable` | `"autoUpdatesChannel": "stable"` | ~1 week behind, skips major regressions |

Configure via `/config` → Auto-update channel, or in `settings.json`. Disable auto-updates with `DISABLE_AUTOUPDATER=1` (background check only) or `DISABLE_UPDATES` (all update paths).

### Effective Prompting Tips

- **Be specific upfront:** reference specific files, state constraints, point to example patterns
- **Give Claude something to verify against:** test cases, screenshots, expected output
- **Explore before implementing:** use plan mode (`Shift+Tab` twice) to analyze first, then implement
- **Delegate, don't dictate:** give context and direction, let Claude figure out details
- **Recover from wrong results:** paste the failing test or stack trace rather than rephrasing
- **Use `@file` or `@directory/` references** instead of pasting file contents

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, installation quick-start, full capabilities, available surfaces
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step first session: install, log in, explore, make changes, use git
- [Advanced setup](references/claude-code-setup.md) — System requirements, Linux package managers, Windows setup, update channels, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — Account types, team setup, credential management, long-lived tokens, precedence rules
- [How Claude Code works](references/claude-code-how-it-works.md) — Agentic loop, tools, sessions, context window, permissions, effective usage tips
- [Platforms and integrations](references/claude-code-platforms.md) — Platform comparison table, integrations, remote/away-from-terminal options
- [Keep Claude working toward a goal](references/claude-code-goal.md) — The `/goal` command: set conditions, check status, evaluation model, requirements
- [Champion kit](references/claude-code-champion-kit.md) — Playbook for engineers advocating Claude Code internally: sharing, Q&A, 30-day plan
- [Communications kit](references/claude-code-communications-kit.md) — Launch announcements, drip-campaign messages, FAQ responses for org rollouts
- [Glossary](references/claude-code-glossary.md) — Definitions for all Claude Code terminology with links to full coverage

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- Keep Claude working toward a goal: https://code.claude.com/docs/en/goal.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
- Glossary: https://code.claude.com/docs/en/glossary.md
