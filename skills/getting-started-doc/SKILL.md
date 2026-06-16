---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup, authentication, how it works (agentic loop, tools, sessions), platforms and integrations, the /goal command, glossary, and rollout resources (champion kit, communications kit). Use when answering questions about installing, logging in, first sessions, platform choices, core concepts, or org-wide adoption.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### Installation methods

| Method | Command / Notes |
| :--- | :--- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` — auto-updates in background |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |
| Native (Windows CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew (stable) | `brew install --cask claude-code` — no auto-update; run `brew upgrade claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` — no auto-update |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | Signed repo at `downloads.claude.ai/claude-code/apt/{stable\|latest}` |
| dnf (Fedora/RHEL) | Signed repo at `downloads.claude.ai/claude-code/rpm/{stable\|latest}` |
| apk (Alpine) | Signed repo at `downloads.claude.ai/claude-code/apk/{stable\|latest}`; requires `libgcc libstdc++ ripgrep` + `USE_BUILTIN_RIPGREP=0` |

### System requirements

| Requirement | Details |
| :--- | :--- |
| OS | macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Network | Internet required; see network-config docs |

### First-run workflow

```text
cd your-project
claude          # starts interactive session; browser login on first use
/init           # generates CLAUDE.md from project structure
```

Verify installation: `claude --version` or `claude doctor`

### Update management

| Setting | Values | Notes |
| :--- | :--- | :--- |
| `autoUpdatesChannel` | `"latest"` (default), `"stable"` | Configure via `/config` or `settings.json` |
| `minimumVersion` | e.g. `"2.1.100"` | Floor for auto-updates; switching to stable prompts for version choice |
| `DISABLE_AUTOUPDATER` | `"1"` | Stops background check; `claude update` still works |
| `DISABLE_UPDATES` | `"1"` | Blocks all update paths including manual |

Manual update: `claude update`

### Authentication account types and precedence

Claude Code resolves credentials in this priority order:

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — bearer token for LLM gateways/proxies
3. `ANTHROPIC_API_KEY` — direct Anthropic API key
4. `apiKeyHelper` script — dynamic/rotating credentials
5. `CLAUDE_CODE_OAUTH_TOKEN` — long-lived token from `claude setup-token` (valid 1 year; for CI)
6. Subscription OAuth from `/login` — default for Pro/Max/Team/Enterprise

Credential storage: macOS Keychain; Linux `~/.claude/.credentials.json` (mode 0600); Windows `%USERPROFILE%\.claude\.credentials.json`.

### Team authentication options

| Option | Best for |
| :--- | :--- |
| Claude for Teams | Self-service; admin tools, centralized billing |
| Claude for Enterprise | SSO, domain capture, RBAC, compliance API, managed policy settings |
| Claude Console | API-based billing; invite users, assign Claude Code or Developer role |
| Amazon Bedrock / Google Vertex AI / Microsoft Foundry | Enterprise cloud providers; set env vars, no browser login |

Generate a long-lived CI token: `claude setup-token` → set `CLAUDE_CODE_OAUTH_TOKEN`

### The agentic loop

Claude works through three phases — **gather context → take action → verify results** — looping until the task is done. Two components power it:

- **Models**: reason and plan. Switch with `/model` or `--model <name>`. Sonnet = everyday tasks; Opus = complex reasoning; Haiku = fast/cheap; Fable 5 = hardest long-running tasks.
- **Tools**: act. Without tools Claude only produces text; with tools it reads files, edits code, runs commands, and calls external services.

| Tool category | Capabilities |
| :--- | :--- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, regex content search |
| Execution | Shell commands, git, tests, build tools |
| Web | Search, fetch docs, look up errors |
| Code intelligence | Type errors, go-to-definition, find references (requires plugin) |

### Permission modes (cycle with Shift+Tab)

| Mode | Behavior |
| :--- | :--- |
| `default` | Asks before file edits and shell commands |
| `acceptEdits` | Auto-approves file edits and common filesystem commands; asks for other shell commands |
| `plan` | Reads and proposes only — no source file edits |
| `auto` | Background classifier approves most actions; research preview |

### Session management

| Command | What it does |
| :--- | :--- |
| `claude` | New interactive session |
| `claude "task"` | One-shot task |
| `claude -p "query"` | Non-interactive, exits after response |
| `claude -c` | Continue most recent conversation |
| `claude -r` / `--resume` | Pick from previous sessions |
| `--fork-session` / `/branch` | Fork session (new ID, history preserved) |
| `/clear` | Start new session |
| `/context` | See context window usage |
| `/compact` | Trigger compaction (optionally with focus) |
| Esc × 2 / `/rewind` | Checkpoint rewind — restores files and conversation |

Sessions are stored as JSONL under `~/.claude/projects/`. Each session has an independent context window. CLAUDE.md and auto memory survive compaction and reload from disk.

### Platforms comparison

| Platform | Best for | Unique features |
| :--- | :--- | :--- |
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use (macOS Pro/Max), third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, computer use, Dispatch |
| VS Code | Editor-integrated workflow | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm, etc. | Diff viewer, selection sharing, terminal session |
| Web (claude.ai/code) | Long-running or offline tasks | Anthropic-managed cloud, continues after disconnect |
| Mobile (iOS/Android) | Remote start/monitor | Cloud sessions, Remote Control, Dispatch to Desktop |

### Remote access options

| Option | Trigger | Claude runs on | Best for |
| :--- | :--- | :--- | :--- |
| Dispatch | Mobile app message | Your machine (Desktop) | Delegating work while away |
| Remote Control | claude.ai or mobile | Your machine (CLI/VS Code) | Steering in-progress work |
| Channels | Chat apps or webhooks | Your machine (CLI) | Reacting to external events |
| Slack | `@Claude` mention | Anthropic cloud | PRs from team chat |
| Scheduled tasks | Schedule | CLI, Desktop, or cloud | Recurring automation |

### The `/goal` command (requires v2.1.139+)

Set a verifiable completion condition; a small fast model checks it after every turn and continues until satisfied.

```text
/goal all tests in test/auth pass and the lint step is clean
/goal                      # check status, turns, tokens spent
/goal clear                # cancel early
```

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Evaluator confirms condition met |
| `/loop` | Time interval elapses | You stop it or Claude decides done |
| Stop hook | Previous turn finishes | Your own script/prompt decides |

Write effective conditions: one measurable end state + a stated check Claude can run + constraints that must hold. Conditions up to 4,000 characters. Works in non-interactive mode: `claude -p "/goal CHANGELOG.md has an entry for every PR merged this week"`.

Requires workspace trust and hooks not disabled (`disableAllHooks` or `allowManagedHooksOnly` block it).

### Core glossary (quick-lookup)

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results, repeating until done |
| Agentic harness | Tools, context management, and execution environment wrapping the model |
| Auto memory | Notes Claude writes for itself in `~/.claude/projects/` (MEMORY.md, 200 lines/25 KB loaded per session) |
| CLAUDE.md | Markdown file of persistent instructions loaded as a user message each session |
| Checkpoint | Snapshot before every file edit; Esc×2 or `/rewind` to restore |
| Compaction | Auto-summarization when context window nears limit; CLAUDE.md and auto memory survive |
| Context window | Working memory: conversation, file contents, outputs, CLAUDE.md, skills, system instructions |
| Hook | User-defined handler that fires at fixed lifecycle points (not at model discretion) |
| MCP | Model Context Protocol — open standard for connecting Claude to external services |
| Non-interactive mode | `-p`/`--print` — single prompt, exits; used for CI and scripting |
| Permission mode | Session-wide approval baseline; cycle with Shift+Tab |
| Plugin | Bundle of skills, hooks, subagents, MCP servers as one installable unit |
| Plan mode | Permission mode where Claude explores and proposes but does not edit source files |
| Remote Control | Drive a local session from browser/phone; code stays on your machine |
| Session | Conversation tied to current directory with its own context window |
| Skill | SKILL.md file of instructions/workflows; loads on demand or on `/name` invocation |
| Subagent | Specialized agent in its own context window; returns summary to main conversation |
| Surface | Any interface (CLI, VS Code, JetBrains, Desktop, web); all share the same engine |
| Teleport | `/teleport` — pulls a cloud session into your local terminal |
| Turn | One complete Claude response (may include many tool calls); Stop hooks fire at turn end |
| Verification loop | Running a check (tests, build) so Claude iterates until it passes; prerequisite for `/goal` |
| Worktree isolation | `-w` flag or `isolation: worktree`; separate git worktree so parallel agents don't conflict |

Deprecated term mappings: "headless mode" → non-interactive mode; "custom commands" → skills; "slash commands" → commands.

### Effective prompting tips

- Be specific upfront: reference files, mention constraints, point to examples
- Give Claude something to verify: test cases, expected output, screenshots
- Explore before implementing: use plan mode for multi-file changes
- Delegate, don't dictate: give context and direction; let Claude figure out the approach
- Iterate conversationally: press Esc to interrupt, or type a correction mid-turn
- Provide context with `@file` or `@directory/` references instead of pasting content

### Team rollout quick checklist (Communications Kit)

Before announcing:
- Create `#claude-code` channel with install command and Quickstart link pinned
- Test install on at least one machine in your environment
- Have a data-usage/security link ready (first question will be "where does my code go?")
- Name a channel owner for the first 48 hours
- Consider an exec sponsor (higher first-week activation)

Champion behaviors (Champion Kit):
- Share prompts and screenshots from real work; short posts outperform long write-ups
- Answer questions publicly so each answer helps everyone watching
- Use `/init` to generate CLAUDE.md so the team stops re-explaining conventions
- Build lightweight habits (weekly show-and-tell thread, dedicated channel) so momentum continues without you

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, installation methods, capabilities, available surfaces, and next steps
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step first session: install, log in, explore a codebase, make code changes, use git, and essential commands
- [Advanced setup](references/claude-code-setup.md) — System requirements, platform-specific installation, version management, update channels, binary integrity verification, and uninstall
- [Authentication](references/claude-code-authentication.md) — Login flow, account types, team setup (Teams/Enterprise/Console/cloud providers), credential storage, precedence, and long-lived CI tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — The agentic loop, built-in tools, what Claude can access, execution environments, session management, context window, checkpoints, and permission modes
- [Platforms and integrations](references/claude-code-platforms.md) — Comparison of CLI, Desktop, VS Code, JetBrains, web, and mobile; integrations (Chrome, GitHub Actions, GitLab, Code Review, Slack); remote access options
- [Keep Claude working toward a goal](references/claude-code-goal.md) — The `/goal` command: setting conditions, checking status, clearing, non-interactive use, evaluation mechanics, and comparison with `/loop` and Stop hooks
- [Glossary](references/claude-code-glossary.md) — Definitions for all Claude Code terms with links to in-depth coverage
- [Champion kit](references/claude-code-champion-kit.md) — Playbook for engineers driving internal adoption: sharing techniques, answering questions, growing a community, and responding to concerns
- [Communications kit](references/claude-code-communications-kit.md) — Launch announcements, drip-campaign messages, FAQ responses, and prompt templates for org-wide rollouts

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
