---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview of what it is and what it can do, quickstart guide, installation and setup (all platforms and package managers), authentication methods and credential management, how the agentic loop works, built-in tools and capabilities, session management, platforms and integrations comparison, the /goal command for autonomous multi-turn work, team rollout resources (champion kit and communications kit), and full glossary of Claude Code terminology.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that runs in your terminal, IDE, desktop app, and browser. It reads your codebase, edits files, runs commands, and integrates with development tools. It works across multiple files and tools to complete tasks end-to-end.

### Installation

| Method | Command |
| :--- | :--- |
| macOS / Linux / WSL (native) | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell (native) | `irm https://claude.ai/install.ps1 \| iex` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |

Linux package managers (apt, dnf, apk) are also supported. Native installs auto-update; Homebrew, WinGet, and package manager installs require manual upgrades.

### System Requirements

- **OS**: macOS 13+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **Hardware**: 4 GB+ RAM, x64 or ARM64
- **Network**: internet connection required
- **Shell**: Bash, Zsh, PowerShell, or CMD

### Authentication Options

| Method | When to use | How |
| :--- | :--- | :--- |
| Claude Pro / Max / Teams / Enterprise | Default for individuals and teams | Run `claude`, log in via browser |
| Claude Console | API-based billing, team access control | Log in with Console credentials |
| Amazon Bedrock | Enterprise cloud | Set env vars, no browser login |
| Google Vertex AI | Enterprise cloud | Set env vars, no browser login |
| Microsoft Foundry | Enterprise cloud | Set env vars, no browser login |

### Authentication Precedence (highest to lowest)

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` env var (bearer token for gateways/proxies)
3. `ANTHROPIC_API_KEY` env var (direct API key)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` env var (long-lived token from `claude setup-token`)
6. Subscription OAuth from `/login` (default for Pro/Max/Teams/Enterprise)

### Credential Storage

| Platform | Location |
| :--- | :--- |
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode 0600) |
| Windows | `%USERPROFILE%\.claude\.credentials.json` |

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive: run query then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --version` | Check installed version |
| `claude doctor` | Diagnose installation issues |
| `claude update` | Manually apply a pending update |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `/help` | Show available commands |
| `/clear` | Start a new conversation |
| `/login` | Switch accounts |
| `/logout` | Log out |
| `/init` | Generate CLAUDE.md for your project |
| `/model` | Switch model mid-session |
| `/context` | See what's consuming context |
| `/compact` | Manually trigger context compaction |
| `/resume` | Resume or fork a previous session |

### The Agentic Loop

Claude works through three phases for every task:

1. **Gather context** — search files, read code, understand the project
2. **Take action** — edit files, run commands, make changes
3. **Verify results** — run tests, check output, course-correct

These phases blend together and repeat until the task is done. You can interrupt at any point to steer.

### Built-in Tool Categories

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read files, edit code, create/rename/reorganize files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation, look up errors |
| Code intelligence | Type errors, definitions, references (requires plugins) |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| acceptEdits | File edits and common filesystem commands flow through; still asks for other commands |
| Plan | Read-only tools only; shows a plan for approval before execution |
| Auto | Background classifier evaluates actions (research preview) |

### Session Management

- Each session is tied to your current directory with its own context window
- `claude --continue` / `claude -c` — resume the most recent session
- `claude --resume` / `claude -r` — pick a session to resume
- `--fork-session` / `/branch` — copy history into a new session ID
- Sessions are stored under `~/.claude/projects/` as JSONL files
- Use git worktrees for parallel Claude sessions on different branches

### Context Window

Holds conversation history, file contents, command outputs, CLAUDE.md, auto memory, loaded skills, and system instructions. Claude compacts automatically when approaching the limit; CLAUDE.md and auto memory survive compaction and reload from disk. Run `/context` to inspect usage.

### Platforms and Surfaces

| Platform | Best for |
| :--- | :--- |
| CLI | Terminal workflows, scripting, remote servers, full feature set |
| Desktop | Visual diff review, parallel sessions, managed setup |
| VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | Diff viewer, selection sharing inside IntelliJ/PyCharm/WebStorm |
| Web (claude.ai/code) | Long-running tasks that continue after you disconnect |
| Mobile | Starting and monitoring tasks; Remote Control for local sessions |

Configuration, project memory, and MCP servers are shared across local surfaces.

### Remote Work Options

| Option | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | claude.ai or Claude mobile app | Your machine (CLI or VS Code) |
| Channels | Telegram, Discord, iMessage, or custom webhooks | Your machine (CLI) |
| Slack | `@Claude` mention in a team channel | Anthropic cloud |
| Scheduled tasks / Routines | Set a schedule | CLI, Desktop, or cloud |

### The `/goal` Command

Sets a completion condition; Claude keeps working turn-by-turn until a fast model confirms the condition is met. Requires v2.1.139+.

| Command | Effect |
| :--- | :--- |
| `/goal <condition>` | Set a goal (replaces any active goal); starts a turn immediately |
| `/goal` | Check status: condition, turns, tokens, latest evaluator reason |
| `/goal clear` | Remove the active goal before it's met |

Writing effective conditions: include one measurable end state, how Claude should prove it, and any constraints. Max 4,000 characters. To bound runtime, add `or stop after N turns`.

Requirements: workspace must have trust dialog accepted; `disableAllHooks` and `allowManagedHooksOnly` both block `/goal`.

### Key Concepts Glossary

| Term | Definition |
| :--- | :--- |
| Agentic loop | The gather-context → take-action → verify cycle that repeats until a task is done |
| CLAUDE.md | Markdown file of persistent project instructions; loaded at session start; survives compaction |
| Auto memory | Notes Claude writes for itself per repo under `~/.claude/projects/`; first 200 lines / 25 KB load each session |
| Compaction | Automatic summarization of the conversation when the context window fills; older tool outputs cleared first |
| Checkpoint | File snapshot taken before every edit; press `Esc` twice or run `/rewind` to restore |
| Skill | A SKILL.md file with instructions/workflow Claude loads on demand or when invoked with `/skill-name` |
| Hook | A handler (shell command, HTTP, MCP tool, prompt, or agent) that fires at fixed lifecycle points |
| MCP | Model Context Protocol — open standard for connecting Claude to external services (Jira, Slack, databases, etc.) |
| Subagent | Specialized agent with its own context window that works on a delegated task and returns a summary |
| Session | A conversation tied to a directory; independent context window; storable and resumable |
| Permission rule | Settings entry allowing, asking about, or denying a tool call based on name and argument pattern |
| Plan mode | Permission mode where Claude proposes changes for approval before touching any files |
| Bare mode | `--bare` flag that skips hooks, skills, plugins, MCP, auto memory, and CLAUDE.md for reproducible CI runs |
| Non-interactive mode | `-p` / `--print` flag that runs one prompt and exits; formerly called headless mode |
| Worktree isolation | `-w` flag to run Claude in a separate git worktree so parallel agents don't overwrite each other |

### Version Management

| Setting | Values | Purpose |
| :--- | :--- | :--- |
| `autoUpdatesChannel` | `"latest"` (default), `"stable"` | Control which release channel to follow |
| `minimumVersion` | e.g. `"2.1.100"` | Floor version; auto-updates won't install below this |
| `DISABLE_AUTOUPDATER` | `"1"` | Stop background update checks (manual update still works) |
| `DISABLE_UPDATES` | set in env | Block all update paths including manual |

Configure via `/config` or `settings.json`. Homebrew tracks channels by cask name instead.

### Binary Verification

GPG key fingerprint for release signing: `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`

- macOS: signed by "Anthropic PBC", notarized by Apple — verify with `codesign --verify --verbose ./claude`
- Windows: signed by "Anthropic, PBC" — verify with `Get-AuthenticodeSignature .\claude.exe`
- Linux: verify via signed manifest (`manifest.json` + `manifest.json.sig`), or package manager repo key

### Team Rollout Quick Tips

Champion behaviors that drive adoption:
- Share prompts and screenshots of real wins (not outcomes — reusable techniques)
- Answer questions with the actual prompt you used
- Establish lightweight habits: a `#claude-code` channel, weekly show-and-tell thread

Common concern responses:
- "I don't trust it with my code" → show plan mode (`Shift+Tab`); nothing changes until approved
- "It hallucinated" → usually a context problem; use `@file` references and `/init`
- "Is it secure?" → runs in your terminal, talks directly to Anthropic API, no third-party servers; Enterprise plan excludes code from training

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — what Claude Code is, installation summary, what you can do, use-it-everywhere surface table
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, login, explore, make changes, git operations
- [Advanced setup](references/claude-code-setup.md) — system requirements, all install methods, Windows/WSL setup, version management, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — login flow, team setup options, credential storage, auth precedence, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, tools, session management, context window, checkpoints, permission modes, working tips
- [Platforms and integrations](references/claude-code-platforms.md) — surface comparison table, integrations (Chrome, GitHub Actions, GitLab, Slack, Code Review), remote work options
- [Keep Claude working toward a goal](references/claude-code-goal.md) — `/goal` command, writing effective conditions, how evaluation works, non-interactive use
- [Champion kit](references/claude-code-champion-kit.md) — playbook for internal advocates: what to share, handling questions, 30-day rollout plan, addressing concerns
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, drip campaign tips-and-tricks messages, FAQ responses, prompt templates for teams
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms with links to in-depth pages

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
