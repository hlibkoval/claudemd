---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, setup, authentication, how the agentic loop works, platforms, glossary, and internal champion and communications kits.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code, including installation, authentication, the agentic loop, available platforms, key terminology, and internal rollout resources.

## Quick Reference

### What Claude Code Is

Claude Code is an AI-powered agentic coding assistant that reads your codebase, edits files, runs commands, and integrates with your development tools. It is available in the terminal (CLI), VS Code, JetBrains, a Desktop app, and the browser. All surfaces share the same underlying engine; CLAUDE.md files, settings, and MCP servers work across all of them.

### Install Claude Code

| Method | Command |
| :--- | :--- |
| **macOS / Linux / WSL (recommended)** | `curl -fsSL https://claude.ai/install.sh \| bash` |
| **Windows PowerShell** | `irm https://claude.ai/install.ps1 \| iex` |
| **Windows CMD** | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| **Homebrew (stable)** | `brew install --cask claude-code` |
| **Homebrew (latest)** | `brew install --cask claude-code@latest` |
| **WinGet** | `winget install Anthropic.ClaudeCode` |
| **npm** | `npm install -g @anthropic-ai/claude-code` |
| **apt (Debian/Ubuntu)** | See setup reference for signed repo setup |
| **dnf (Fedora/RHEL)** | See setup reference for signed repo setup |
| **apk (Alpine)** | See setup reference for signed repo setup |

Native installs auto-update. Homebrew, WinGet, and Linux package manager installs do not — run the corresponding upgrade command manually.

Verify the install: `claude --version` or `claude doctor`.

### System Requirements

| Requirement | Details |
| :--- | :--- |
| **OS** | macOS 13.0+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| **Hardware** | 4 GB+ RAM, x64 or ARM64 |
| **Network** | Internet connection required |
| **Shell** | Bash, Zsh, PowerShell, or CMD |

### Authentication

Run `claude` after installing; a browser window opens on first launch for login. If no browser opens, press `c` to copy the URL. To re-authenticate, type `/logout` then `/login`.

**Account types:**

| Type | Notes |
| :--- | :--- |
| **Claude Pro / Max** | Subscription login via claude.ai |
| **Claude for Teams / Enterprise** | Team admin invites members; centralized billing |
| **Claude Console** | API-key billing; admin invites required |
| **Amazon Bedrock / Google Vertex AI / Microsoft Foundry** | Set env vars before running `claude`; no browser login needed |

**Authentication precedence** (highest to lowest):

1. Cloud provider env var (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — bearer-token for LLM gateways
3. `ANTHROPIC_API_KEY` — direct Anthropic API key
4. `apiKeyHelper` script output — dynamic/rotating credentials
5. `CLAUDE_CODE_OAUTH_TOKEN` — long-lived token from `claude setup-token`
6. Subscription OAuth from `/login` (default for Pro/Max/Teams)

**Credential storage:** macOS Keychain; Linux `~/.claude/.credentials.json` (mode 0600); Windows `%USERPROFILE%\.claude\.credentials.json`.

**Long-lived token for CI:** Run `claude setup-token` to generate a one-year OAuth token. Set as `CLAUDE_CODE_OAUTH_TOKEN`. Requires Pro, Max, Team, or Enterprise plan.

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task and stay in session |
| `claude -p "query"` | Run one-off query, then exit (non-interactive) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation (picker) |
| `claude --version` | Show version |
| `claude doctor` | Diagnose installation and configuration |
| `claude update` | Apply pending update immediately |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `/clear` | Clear conversation history (start new session) |
| `/help` | Show available commands |
| `/login` / `/logout` | Switch accounts |
| `/init` | Generate CLAUDE.md for the current project |
| `/model` | Switch model mid-session |
| `/context` | See what is using context window space |
| `/goal <condition>` | Keep Claude working until a condition is met |
| `exit` or Ctrl+D | Exit Claude Code |

### The Agentic Loop

Every task runs through three phases that blend together: **gather context → take action → verify results → repeat**.

**Built-in tool categories:**

| Category | What Claude can do |
| :--- | :--- |
| **File operations** | Read files, edit code, create, rename, reorganize |
| **Search** | Find files by pattern, regex content search |
| **Execution** | Run shell commands, tests, git |
| **Web** | Search the web, fetch documentation |
| **Code intelligence** | Type errors, jump to definition, find references (requires plugin) |

Claude chooses which tools to use based on what it learns at each step. You can interrupt at any point (press `Esc`) to redirect.

### Permission Modes

Cycle through modes with `Shift+Tab`:

| Mode | Behavior |
| :--- | :--- |
| **Default** | Asks before file edits and shell commands |
| **Auto-accept edits** | File edits and common filesystem commands flow through; other shell commands still prompt |
| **Plan mode** | Read-only tools only; Claude proposes a plan for your approval before any edits |
| **Auto mode** | Background classifier reviews all actions; research preview |

### Platforms and Surfaces

| Platform | Best for |
| :--- | :--- |
| **CLI (Terminal)** | Terminal workflows, scripting, remote servers, full feature set |
| **Desktop app** | Visual diff review, parallel sessions, computer use, Dispatch |
| **VS Code** | Inline diffs, integrated terminal, file context inside the editor |
| **JetBrains** | IntelliJ, PyCharm, WebStorm — diff viewer and selection sharing |
| **Web (claude.ai/code)** | Long-running cloud tasks that continue when you disconnect |
| **Mobile** | Starting/monitoring tasks; Remote Control for local sessions |

**Remote and async options:**

| Option | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Remote Control | You (from browser/phone) | Your machine |
| Dispatch | Claude mobile app | Your machine (Desktop) |
| Channels | Chat app event or webhook | Your machine (CLI) |
| Slack | `@Claude` mention | Anthropic cloud |
| Scheduled tasks / Routines | Schedule | CLI, Desktop, or cloud |

### /goal — Keep Claude Working Toward a Condition

`/goal` (requires v2.1.139+) sets a completion condition; after each turn a small fast model checks whether it is met and keeps Claude working if not.

```text
/goal all tests in test/auth pass and the lint step is clean
```

| Command | Effect |
| :--- | :--- |
| `/goal <condition>` | Set (or replace) active goal; starts a turn immediately |
| `/goal` | Check status, turns, tokens, and last evaluator reason |
| `/goal clear` | Remove active goal before condition is met |

Write conditions that are verifiable from Claude's own output (test results, build exit codes). Include a turn/time bound to cap runtime, e.g. "or stop after 20 turns."

Compare approaches that keep a session running:

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Model confirms condition met |
| `/loop` | Time interval elapses | You stop it, or Claude decides done |
| Stop hook | Previous turn finishes | Your script or prompt decides |

### Key Terminology (Glossary Highlights)

| Term | Definition |
| :--- | :--- |
| **Agentic harness** | Tools, context management, and execution environment that make Claude Code an agent (not just a chat model) |
| **Session** | A conversation tied to your current directory with its own context window |
| **Turn** | One complete response from Claude (may include many tool calls) |
| **Checkpoint** | Automatic file snapshot before each edit; press `Esc` twice or run `/rewind` to restore |
| **Compaction** | Auto-summarization when the context window fills; project CLAUDE.md and auto memory survive it |
| **CLAUDE.md** | Persistent instruction file you write; loaded every session |
| **Auto memory** | Notes Claude writes for itself; stored under `~/.claude/projects/` |
| **Skill** | A `SKILL.md` file containing a workflow Claude loads automatically or you invoke with `/name` |
| **Hook** | Shell command, HTTP endpoint, MCP tool, or prompt that fires at a fixed lifecycle point |
| **Subagent** | Specialized assistant with its own context window, delegated a subtask |
| **MCP** | Model Context Protocol — open standard for connecting Claude to external services |
| **Plan mode** | Permission mode where Claude researches and proposes changes without editing files |
| **Teleport** | `/teleport` pulls a cloud session into your local terminal |
| **Non-interactive mode** | `-p` flag; single prompt, then exit — used in CI and scripts |
| **Bare mode** | `--bare` flag; skips auto-discovery of hooks, skills, plugins, MCP, auto memory, CLAUDE.md |

### Team Rollout Quick Reference

**Champion kit — weekly time budget:**

| Activity | Time |
| :--- | :--- |
| Posting wins/prompts | ~15 min |
| Answering questions publicly | ~20 min |
| Hosting show-and-tell thread | ~5 min |
| Optional pairing | 0–30 min |

**Communications kit — launch checklist:**

- `#claude-code` channel created
- Install command tested in your environment
- Security/data-handling link ready (`/en/data-usage`, `/en/security`)
- One concrete first task chosen (a real file/bug, not a generic example)
- Named channel owner for the first 48 hours
- Executive sponsor lined up

**Starter prompts for new users:**

| Task | Prompt |
| :--- | :--- |
| Fix a bug | "the tests in [file] are failing, figure out why and fix it" |
| Understand code | "walk me through how [module] works, then tell me where the entry point is" |
| Safe refactor | "refactor [module] to [goal], use plan mode so I can review first" |
| Write tests | "write tests for [file] that cover the edge cases around [scenario]" |
| Review before commit | "look at my working diff and tell me what looks risky" |
| Open a PR | "fix [issue], write a conventional commit, and open a PR with a summary" |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — what Claude Code is, surfaces, install commands, and capability overview
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, login, explore, edit, git, essential commands
- [Advanced Setup](references/claude-code-setup.md) — system requirements, platform-specific install, Windows/WSL, Linux package managers, npm, binary verification, updates, uninstall
- [Authentication](references/claude-code-authentication.md) — login, team setup (Teams/Enterprise/Console/cloud providers), credential storage, precedence, long-lived tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — agentic loop, built-in tools, execution environments, sessions, context window, checkpoints, permission modes, tips
- [Goal](references/claude-code-goal.md) — `/goal` command, writing effective conditions, status/clear, non-interactive use, evaluation model
- [Platforms and Integrations](references/claude-code-platforms.md) — surface comparison table, integrations (Chrome, GitHub Actions, GitLab, Slack, Code Review), remote/async options
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms with links to in-depth pages
- [Champion Kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally: sharing discoveries, answering questions, 30-day adoption plan
- [Communications Kit](references/claude-code-communications-kit.md) — launch announcements (email, Slack, exec variant, pilot), drip campaign tips, FAQ responses, starter prompts for admins rolling out to teams

## Sources

- Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Goal: https://code.claude.com/docs/en/goal.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
