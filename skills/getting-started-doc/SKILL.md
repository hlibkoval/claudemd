---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup, authentication, how the agentic loop works, platforms and integrations, the /goal command, glossary of terms, and team adoption resources (champion kit and communications kit).
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### What Claude Code Is

Claude Code is an agentic coding tool that reads your codebase, edits files, runs commands, and integrates with development tools. Available as a terminal CLI, VS Code/JetBrains extension, desktop app, and web surface.

### Installation

| Method | Command | Auto-updates |
| :--- | :--- | :--- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Homebrew (stable) | `brew install --cask claude-code` | No (run `brew upgrade claude-code`) |
| Homebrew (latest) | `brew install --cask claude-code@latest` | No |
| WinGet | `winget install Anthropic.ClaudeCode` | No |
| npm | `npm install -g @anthropic-ai/claude-code` | No |
| apt/dnf/apk | See setup reference | No |

After installation: `claude --version` to verify, `claude doctor` for a full check.

### System Requirements

- **OS:** macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
- **Hardware:** 4 GB+ RAM, x64 or ARM64
- **Shell:** Bash, Zsh, PowerShell, or CMD (Git for Windows recommended on native Windows)

### Authentication — Account Types and Precedence

| Priority | Method | Notes |
| :--- | :--- | :--- |
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, etc.) | Bedrock, Vertex AI, Microsoft Foundry |
| 2 | `ANTHROPIC_AUTH_TOKEN` | Bearer token, for LLM gateways/proxies |
| 3 | `ANTHROPIC_API_KEY` | Direct API key from Claude Console |
| 4 | `apiKeyHelper` script | Dynamic/rotating credentials |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` | Long-lived token from `claude setup-token` |
| 6 | Subscription OAuth (default) | Claude Pro, Max, Team, Enterprise via `/login` |

- Free Claude.ai plan does not include Claude Code access.
- macOS: credentials stored in Keychain. Linux: `~/.claude/.credentials.json` (mode 0600). Windows: `%USERPROFILE%\.claude\.credentials.json`.
- `claude setup-token` generates a one-year OAuth token for CI/scripts (requires Pro/Max/Team/Enterprise).

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude update` | Manually apply latest update |
| `claude doctor` | Diagnose installation issues |
| `/clear` | Clear conversation history |
| `/login` / `/logout` | Switch accounts |
| `/help` | Show available commands |
| `/model` | Switch model mid-session |
| `/init` | Generate CLAUDE.md from repo |
| `Shift+Tab` | Cycle permission modes |

### Agentic Loop — Three Phases

1. **Gather context** — read files, search codebase, understand structure
2. **Take action** — edit files, run commands, make changes
3. **Verify results** — run tests, check output, course-correct

### Built-in Tool Categories

| Category | What Claude can do |
| :--- | :--- |
| **File operations** | Read, edit, create, rename files |
| **Search** | Find files by pattern, regex content search |
| **Execution** | Shell commands, tests, git, servers |
| **Web** | Search web, fetch docs |
| **Code intelligence** | Type errors, jump to definition (requires LSP plugin) |

### Permission Modes (cycle with `Shift+Tab`)

| Mode | Behavior |
| :--- | :--- |
| `default` | Asks before file edits and shell commands |
| `acceptEdits` | Edits files + common filesystem commands without asking |
| `plan` | Read-only exploration; proposes changes for approval |
| `auto` | Background classifier approves actions (research preview) |

### Context Window Management

- Sessions save history to `~/.claude/projects/` as JSONL
- Auto-compaction clears old tool outputs, then summarizes conversation
- Persistent instructions go in `CLAUDE.md` — survives compaction
- Run `/compact [focus on X]` to trigger manually
- Run `/context` to see what's using space
- Press `Esc` twice (or `/rewind`) to rewind to a previous checkpoint

### Sessions

- Each session has its own independent context window tied to a directory
- `claude --continue` / `claude -c` — resume most recent
- `claude --resume` / `claude -r` — pick from list
- `--fork-session` or `/branch` — copy history to a new session ID
- Sessions across branches: use git worktrees (`-w` flag) for true isolation
- Auto memory saved to `~/.claude/projects/` per git repo (first 200 lines / 25 KB of MEMORY.md loads each session)

### Platforms

| Platform | Best for |
| :--- | :--- |
| CLI | Terminal workflows, scripting, Agent SDK, third-party providers |
| Desktop | Visual diff review, parallel sessions, computer use, Dispatch |
| VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | Diff viewer, selection sharing in IntelliJ/PyCharm/WebStorm |
| Web | Long-running cloud tasks that continue when you disconnect |
| Mobile | Monitoring/starting tasks away from desk via Remote Control or Dispatch |

### The `/goal` Command

Sets a completion condition; Claude keeps working across turns until a separate evaluator confirms it is met.

```text
/goal all tests in test/auth pass and the lint step is clean
```

- One goal active per session; new `/goal` replaces the old one
- `/goal` with no argument — check status (turns, tokens, last evaluator reason)
- `/goal clear` — remove active goal
- Evaluator uses a small fast model (default: Haiku); billed separately
- Works in non-interactive mode: `claude -p "/goal <condition>"`
- Requires trusted workspace (hooks must be enabled)

### Autonomous Workflow Comparison

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Evaluator confirms condition met |
| `/loop` | Time interval elapses | You stop it, or Claude decides done |
| Stop hook | Previous turn finishes | Your script/prompt decides |

### Update Management

| Setting | Effect |
| :--- | :--- |
| `autoUpdatesChannel: "latest"` (default) | Receive new features immediately |
| `autoUpdatesChannel: "stable"` | ~1 week delay, skips regressions |
| `minimumVersion: "2.1.100"` | Floor; auto-updates won't go below this |
| `DISABLE_AUTOUPDATER: "1"` | Stop background check (manual `claude update` still works) |
| `DISABLE_UPDATES` | Block all update paths |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| **Agentic loop** | gather context → take action → verify results, repeated |
| **Agentic harness** | Claude Code's tools, context management, execution env around the model |
| **CLAUDE.md** | Persistent project instructions loaded at every session start |
| **Auto memory** | Notes Claude writes for itself; stored per git repo in `~/.claude/projects/` |
| **Compaction** | Auto-summarization when context window approaches its limit |
| **Checkpoint** | Restore point before each file edit; revert with `Esc`+`Esc` or `/rewind` |
| **Session** | Conversation tied to a directory with its own context window |
| **Subagent** | Delegated task with its own fresh context window |
| **Skill** | `SKILL.md` file that adds a workflow or knowledge to Claude's toolkit |
| **Hook** | User-defined handler that fires at lifecycle points |
| **MCP** | Model Context Protocol — connects Claude to external services |
| **Surface** | Any place Claude Code runs: CLI, VS Code, JetBrains, Desktop, web |
| **Worktree isolation** | Separate git worktree (`-w`) for parallel agents |
| **Bare mode** | `--bare` — skips hooks/skills/plugins/memory for reproducible CI runs |
| **Non-interactive mode** | `-p` / `--print` — single prompt, exit, no conversation |
| **Remote Control** | Drive a local session from browser or mobile via claude.ai |

### Team Adoption Quick-Reference

**For champions (engineers promoting usage):**

| Technique | How |
| :--- | :--- |
| Provide context | Use `@file` or `@directory/` references, or paste error/log output directly |
| Review before edit | `Shift+Tab` → plan mode — see proposed changes before execution |
| Teach repo conventions | Run `/init` to generate `CLAUDE.md`; add conventions, test commands |
| Reuse workflows | Create `.claude/skills/<name>/SKILL.md` for team-shared slash commands |
| Long task notifications | Configure a Stop hook for desktop notifications when tasks finish |
| Recover from bad output | Paste the failing test or stack trace back — don't just rephrase |

**Answering common concerns:**

| Concern | Response |
| :--- | :--- |
| "I'm faster without it" | Try it on work you avoid: legacy files, unfamiliar services, test scaffolding |
| "I don't trust AI on production code" | Plan mode + normal diff review = nothing applied without inspection |
| "Setup isn't worth it" | Install takes ~2 minutes; `/init` once is sufficient to start |
| "It hallucinated" | Usually a context problem — add `@`-references and the actual error output |
| "Where does my code go?" | CLI talks directly to Anthropic API; under Enterprise plan, code/prompts not used for training |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — what Claude Code is, surfaces, capabilities, next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, login, explore, edit, git, fix bugs
- [Advanced setup](references/claude-code-setup.md) — system requirements, platform-specific install, Linux package managers, npm, updates, uninstall
- [Authentication](references/claude-code-authentication.md) — login, team auth (Teams/Enterprise/Console/cloud providers), credential management, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, tools, sessions, context window, checkpoints, permissions, effective usage tips
- [Platforms and integrations](references/claude-code-platforms.md) — all surfaces compared, integrations (Chrome, CI/CD, Slack), remote access options
- [/goal command](references/claude-code-goal.md) — set completion conditions, compare autonomous workflow approaches, evaluation mechanics
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms with links to in-depth pages
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers promoting team adoption: sharing, answering questions, 30-day plan
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, drip campaign tips, FAQ responses for org-wide rollouts

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and integrations: https://code.claude.com/docs/en/platforms.md
- /goal command: https://code.claude.com/docs/en/goal.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion kit: https://code.claude.com/docs/en/champion-kit.md
- Communications kit: https://code.claude.com/docs/en/communications-kit.md
