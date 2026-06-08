---
name: getting-started-doc
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code: overview, quickstart, setup, authentication, how it works, platforms, goal-setting, and the glossary.

## Quick Reference

### Install Claude Code

| Platform | Command |
|:---------|:--------|
| macOS / Linux / WSL | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | Add the signed apt repo, then `sudo apt install claude-code` |
| dnf (Fedora/RHEL) | Add the signed dnf repo, then `sudo dnf install claude-code` |
| apk (Alpine) | Add the signed apk repo, then `apk add claude-code` |

Native installs auto-update. Homebrew, WinGet, and Linux package managers require manual upgrades. Verify with `claude --version`; diagnose with `claude doctor`.

### System Requirements

| Requirement | Details |
|:------------|:--------|
| **OS** | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **Hardware** | 4 GB+ RAM, x64 or ARM64 |
| **Network** | Internet required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |
| **Location** | Anthropic supported countries |

### Authentication Methods (precedence order)

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` (bearer token for LLM gateways/proxies)
3. `ANTHROPIC_API_KEY` (direct Anthropic API key from Console)
4. `apiKeyHelper` script (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`, for CI)
6. Subscription OAuth from `/login` (default for Pro/Max/Team/Enterprise)

Log in with `claude`, log out with `/logout`. For CI pipelines, generate a one-year token with `claude setup-token`.

### Credential Storage

| OS | Location |
|:---|:---------|
| macOS | Encrypted macOS Keychain |
| Linux | `~/.claude/.credentials.json` (mode 0600) |
| Windows | `%USERPROFILE%\.claude\.credentials.json` |

### Essential CLI Commands

| Command | What it does |
|:--------|:-------------|
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | One-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude update` | Apply update immediately |
| `claude doctor` | Diagnose installation issues |
| `/clear` | Clear conversation history |
| `/help` | Show available commands |
| `/login` / `/logout` | Switch accounts |
| `/context` | See what's using context space |
| `exit` or Ctrl+D | Exit Claude Code |

### Surfaces and Interfaces

| Platform | Best for | Key feature |
|:---------|:---------|:------------|
| [CLI](/en/quickstart) | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, scripting |
| [Desktop](/en/desktop) | Visual review, parallel sessions | Diff viewer, Dispatch, computer use |
| [VS Code](/en/vs-code) | Working inside VS Code | Inline diffs, integrated terminal |
| [JetBrains](/en/jetbrains) | IntelliJ, PyCharm, WebStorm, etc. | Diff viewer, selection sharing |
| [Web](/en/claude-code-on-the-web) | Long-running tasks, work offline | Anthropic-managed cloud, persists when disconnected |
| Mobile | Starting/monitoring tasks away from desk | Cloud sessions, Remote Control, Dispatch |

Configuration, CLAUDE.md, and MCP servers are shared across local surfaces.

### Integrations

| Integration | Use it for |
|:------------|:-----------|
| [Chrome](/en/chrome) | Testing web apps, automating sites with your logged-in session |
| [GitHub Actions](/en/github-actions) | Automated PR reviews, issue triage, CI automation |
| [GitLab CI/CD](/en/gitlab-ci-cd) | Same as GitHub Actions for GitLab |
| [Code Review](/en/code-review) | Automatic review on every PR |
| [Slack](/en/slack) | Turning `@Claude` mentions into pull requests |

### The Agentic Loop

Claude works through three blended phases for every task:

1. **Gather context** — read files, search codebase, understand structure
2. **Take action** — edit files, run commands, use tools
3. **Verify results** — run tests, check output, course-correct

| Tool category | What Claude can do |
|:--------------|:------------------|
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, grep content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search web, fetch docs, look up errors |
| Code intelligence | Type errors, jump to definition, find references (with plugins) |

### Permission Modes (cycle with Shift+Tab)

| Mode | Behavior |
|:-----|:---------|
| **Default** | Claude asks before file edits and shell commands |
| **Auto-accept edits** | File edits and common filesystem commands run without asking |
| **Plan mode** | Read-only; Claude proposes a plan before touching anything |
| **Auto mode** | Background safety classifier approves actions (research preview) |

Press `Esc` to stop Claude mid-turn. Every file edit is checkpointed and reversible.

### `/goal` — Keep Claude Working Toward a Condition

Requires Claude Code v2.1.139+. Sets a completion condition; Claude loops until a model confirms the condition is met.

| Command | Description |
|:--------|:------------|
| `/goal <condition>` | Set a goal; starts a turn immediately |
| `/goal` | Check status (turns, tokens, evaluator's last reason) |
| `/goal clear` | Remove an active goal before it's met |

Aliases for `clear`: `stop`, `off`, `reset`, `none`, `cancel`. Goals are restored on `--resume`. Active goal indicator: `◎ /goal active`.

**Writing effective conditions:** include one measurable end state, a stated check ("npm test exits 0"), and constraints. Bound with turn/time clauses like `or stop after 20 turns`. Max 4,000 characters.

Compare approaches for keeping a session running:

| Approach | Next turn starts when | Stops when |
|:---------|:---------------------|:-----------|
| `/goal` | Previous turn finishes | Model confirms condition met |
| `/loop` | Time interval elapses | You stop it, or Claude decides done |
| Stop hook | Previous turn finishes | Your script/prompt decides |

### Key Glossary Terms

| Term | Definition |
|:-----|:-----------|
| **Agentic loop** | Gather context → take action → verify results, repeated until done |
| **Agentic harness** | Claude Code's tools, context mgmt, and execution env around the Claude model |
| **Session** | A conversation tied to a directory; independent context window |
| **Compaction** | Auto-summarization when context fills up; CLAUDE.md survives and reloads |
| **Checkpoint** | Per-edit file snapshot; press `Esc` twice or run `/rewind` to restore |
| **CLAUDE.md** | Markdown file of persistent instructions loaded every session |
| **Auto memory** | Claude-written notes in `~/.claude/projects/<project>/memory/` |
| **Subagent** | Specialized AI in its own context window for delegated tasks |
| **Surface** | Any place you access Claude Code (CLI, VS Code, Desktop, web, etc.) |
| **Bare mode** | `--bare` flag; skips hooks, skills, plugins, MCP, memory — for CI |
| **Turn** | One complete Claude response (may include many tool calls) |
| **Verification loop** | Giving Claude a check to run so it iterates until the check passes |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, how to get started on each surface, and what you can do
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step first session: install, log in, explore, make changes, use git
- [Advanced Setup](references/claude-code-setup.md) — System requirements, platform-specific install, updates, release channels, version pinning, uninstallation
- [Authentication](references/claude-code-authentication.md) — Login methods, team/org setup, credential storage, auth precedence, long-lived tokens for CI
- [How Claude Code Works](references/claude-code-how-it-works.md) — Agentic loop, built-in tools, sessions, context window management, checkpoints, permission modes
- [Platforms and Integrations](references/claude-code-platforms.md) — Compare all surfaces (CLI, Desktop, VS Code, JetBrains, web, mobile) and integrations (Chrome, GitHub, GitLab, Slack)
- [Keep Claude Working Toward a Goal](references/claude-code-goal.md) — `/goal` command: set conditions, check status, evaluation model, requirements
- [Champion Kit](references/claude-code-champion-kit.md) — Resources for rolling out Claude Code in your organization
- [Communications Kit](references/claude-code-communications-kit.md) — Messaging and enablement materials for teams
- [Glossary](references/claude-code-glossary.md) — Definitions for all Claude Code terminology

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Keep Claude Working Toward a Goal: https://code.claude.com/docs/en/goal.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
- Glossary: https://code.claude.com/docs/en/glossary.md
