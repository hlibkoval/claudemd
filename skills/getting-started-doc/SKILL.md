---
name: getting-started-doc
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code — installation, authentication, quickstart, how the tool works, supported platforms and integrations, team rollout resources, and a full glossary.

## Quick Reference

### Installation Methods

| Method | Command / Action | Auto-updates |
| :--- | :--- | :--- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Homebrew (stable) | `brew install --cask claude-code` | No (manual: `brew upgrade claude-code`) |
| Homebrew (latest) | `brew install --cask claude-code@latest` | No (manual: `brew upgrade claude-code@latest`) |
| WinGet | `winget install Anthropic.ClaudeCode` | No (manual: `winget upgrade Anthropic.ClaudeCode`) |
| npm | `npm install -g @anthropic-ai/claude-code` | No (manual: `npm install -g @anthropic-ai/claude-code@latest`) |
| apt (Debian/Ubuntu) | See setup reference for signed-repo steps | No |
| dnf (Fedora/RHEL) | See setup reference for signed-repo steps | No |
| apk (Alpine Linux) | See setup reference for signed-repo steps | No |

**System requirements:** macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+; 4 GB RAM, x64 or ARM64.

**Verify install:** `claude --version` or `claude doctor`.

### Essential CLI Commands

**Shell commands (run from terminal)**

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive: run query, print result, exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r` | Resume a previous conversation (shows picker) |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Apply update immediately |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `claude doctor` | Diagnose installation and config issues |

**Session commands (typed inside a running session)**

| Command | What it does |
| :--- | :--- |
| `/help` | Show available commands |
| `/clear` | Clear conversation history, start new session |
| `/resume` | Resume or fork a previous session |
| `/login` / `/logout` | Switch accounts or re-authenticate |
| `/init` | Generate CLAUDE.md from your project structure |
| `/model` | Switch models mid-session |
| `/context` | Show what's using context window space |
| `/compact` | Manually trigger context compaction |
| `/plan` | Enter plan mode (review before edit) |
| `/goal <condition>` | Keep Claude working until condition is met |
| `/goal` | Check current goal status |
| `/goal clear` | Clear an active goal |
| `/rewind` | Restore to an earlier checkpoint |
| `/exit` or Ctrl+D | Exit Claude Code |

### Authentication Methods (Precedence Order)

| Priority | Method | When to use |
| :---: | :--- | :--- |
| 1 | Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, etc.) | Amazon Bedrock, Google Vertex AI, Microsoft Foundry |
| 2 | `ANTHROPIC_AUTH_TOKEN` | LLM gateway / proxy with bearer tokens |
| 3 | `ANTHROPIC_API_KEY` | Direct Anthropic API access |
| 4 | `apiKeyHelper` script | Dynamic/rotating credentials from a vault |
| 5 | `CLAUDE_CODE_OAUTH_TOKEN` | CI pipelines (generated via `claude setup-token`) |
| 6 | Subscription OAuth (from `/login`) | Default for Pro, Max, Team, Enterprise |

**Credential storage:** macOS Keychain; `~/.claude/.credentials.json` (Linux, mode 0600); `%USERPROFILE%\.claude\.credentials.json` (Windows).

### Supported Account Types

| Account | Notes |
| :--- | :--- |
| Claude Pro / Max | Individual subscription at claude.com/pricing |
| Claude for Teams | Self-service, centralized billing, admin tools |
| Claude for Enterprise | Adds SSO, domain capture, role-based permissions, managed policy |
| Claude Console | API-based billing; assign "Claude Code" or "Developer" roles |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### The Agentic Loop

Claude works through three phases per task: **gather context → take action → verify results**, repeating until done. Each tool use feeds into the next step.

**Built-in tool categories**

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, definitions, references (requires plugins) |

### Permission Modes (cycle with Shift+Tab)

| Mode | Behavior |
| :--- | :--- |
| `default` | Asks before file edits and shell commands |
| `acceptEdits` | File edits and common filesystem commands flow without asking; other commands still prompt |
| `plan` | Explores and proposes a plan; no source file edits until approved |
| `auto` | Background safety classifier approves most actions (research preview) |

### Platforms

| Platform | Best for | Key extras |
| :--- | :--- | :--- |
| CLI (Terminal) | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use (macOS Pro/Max) |
| Desktop app | Visual review, parallel sessions | Diff viewer, Dispatch, computer use |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm, etc. | Diff viewer, selection sharing |
| Web (claude.ai/code) | Long-running tasks, offline continuation | Anthropic-managed cloud, continues after disconnect |
| Mobile (iOS/Android) | Starting/monitoring tasks away from desk | Cloud sessions, Remote Control, Dispatch |

**Integrations:** Chrome (browser automation), GitHub Actions, GitLab CI/CD, Code Review (auto PR review), Slack (`@Claude` mentions).

**Remote access options**

| Option | How it works |
| :--- | :--- |
| Remote Control | Drive a local session from browser or phone |
| Dispatch | Message a task from mobile, Desktop session spawns |
| Channels | Push events from Telegram/Discord/iMessage into a session |
| Scheduled tasks | `/loop` (in-session), Desktop scheduled tasks, or cloud Routines |

### Update & Release Channels

| Channel | Description | Set via |
| :--- | :--- | :--- |
| `latest` (default) | Every release as it ships | `"autoUpdatesChannel": "latest"` in settings.json |
| `stable` | ~1 week behind, skips regressions | `"autoUpdatesChannel": "stable"` in settings.json |

Use `minimumVersion` in settings.json to pin a version floor. Disable auto-updates with `"DISABLE_AUTOUPDATER": "1"` in `env`.

### `/goal` Command

`/goal` requires Claude Code v2.1.139+. It wraps a session-scoped Stop hook: after each turn, a small fast model checks the condition; if not met, Claude continues automatically.

| Usage | Effect |
| :--- | :--- |
| `/goal <condition>` | Set a goal; starts working immediately |
| `/goal` | Show status (condition, turns, tokens, evaluator reason) |
| `/goal clear` | Remove active goal before condition is met |

**Writing effective conditions:** state one measurable end state, a check Claude can run (e.g., "`npm test` exits 0"), and any constraints. Conditions up to 4,000 characters. Goals survive `--resume` but reset turn count.

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeated until done |
| Agentic harness | The tools, context management, and execution layer around the Claude model |
| CLAUDE.md | Markdown file of persistent project instructions loaded every session |
| Auto memory | Notes Claude writes for itself, stored per-repo under `~/.claude/projects/` |
| Compaction | Auto-summarization when context window fills; CLAUDE.md and auto memory survive |
| Checkpoint | Per-prompt restore point; press Esc twice or `/rewind` to revert |
| Skill | `SKILL.md` file adding instructions or a workflow Claude can invoke |
| Hook | Handler (command/HTTP/MCP/prompt/agent) that fires at lifecycle points |
| Subagent | Specialized agent in its own context window with delegated task |
| Plugin | Bundle of skills, hooks, subagents, and MCP servers as an installable unit |
| Session | A conversation tied to a directory with its own context window |
| Turn | One complete Claude response, including all tool calls within it |
| Plan mode | Permission mode: Claude proposes changes before editing any source file |
| Verification loop | A check Claude runs after each attempt to confirm work is actually done |
| Non-interactive mode | `-p` flag: runs a single prompt and exits (formerly "headless mode") |
| Bare mode | `--bare`: skips hooks, skills, plugins, MCP, auto memory, CLAUDE.md |
| Teleport | `/teleport` pulls a cloud session into your local terminal |
| Surface | Any access point: CLI, VS Code, JetBrains, Desktop, or claude.ai |
| Managed settings | Org-wide settings enforced at OS-level paths; users cannot override |
| Settings layers | Precedence: managed policy > CLI args > `.local.json` > project > user |

### Team Rollout Quick Reference

**Pre-launch checklist (from Communications Kit)**
- `#claude-code` channel created and linked in announcement
- Install command tested in your environment (proxy/firewall check)
- Security/data-handling link ready ([data-usage](/en/data-usage), [security](/en/security))
- One concrete first task from your own codebase chosen
- Named owner for the channel for the first 48 hours
- Executive sponsor lined up to send or co-sign

**Champion role behaviors:** share discoveries publicly, answer questions with actual prompts used, establish lightweight recurring habits (weekly show-and-tell, `#claude-code` channel).

**High-leverage starter prompts**

| Task | Prompt template |
| :--- | :--- |
| Fix a bug | "the tests in [file] are failing, figure out why and fix it" |
| Understand code | "walk me through how [module] works, then tell me where the entry point is" |
| Safe refactor | "refactor [module] to [goal], use plan mode so I can review first" |
| Write tests | "write tests for [file] that cover the edge cases around [scenario]" |
| Review before commit | "look at my working diff and tell me what looks risky" |
| Open a PR | "fix [issue], write a conventional commit, and open a PR with a summary" |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, all interfaces, and what you can do with it
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step walkthrough of your first session
- [Advanced Setup](references/claude-code-setup.md) — System requirements, installation methods, updates, uninstallation, binary integrity
- [Authentication](references/claude-code-authentication.md) — Account types, team setup, credential management, long-lived tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — Agentic loop, built-in tools, sessions, checkpoints, permissions, working effectively
- [Platforms and Integrations](references/claude-code-platforms.md) — Platform comparison, integrations, remote access options
- [Keep Claude Working Toward a Goal](references/claude-code-goal.md) — The `/goal` command, evaluation mechanics, non-interactive use
- [Champion Kit](references/claude-code-champion-kit.md) — Playbook for engineers driving internal adoption
- [Communications Kit](references/claude-code-communications-kit.md) — Launch announcements, drip campaigns, FAQ responses for org rollouts
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
