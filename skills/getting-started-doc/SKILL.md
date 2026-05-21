---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup (system requirements, installation methods, updates, uninstallation), authentication (account types, credential management, long-lived tokens), how Claude Code works (agentic loop, tools, sessions, context, permissions, checkpoints), platforms and integrations comparison, /goal command for autonomous multi-turn workflows, glossary of core terms, and team adoption resources (champion kit, communications kit).
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code.

## Quick Reference

### Installation

| Method | Command | Notes |
| :--- | :--- | :--- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Auto-updates in background |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Auto-updates in background |
| Homebrew (stable) | `brew install --cask claude-code` | No auto-update; run `brew upgrade claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` | No auto-update; run `brew upgrade claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` | No auto-update; run `winget upgrade Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` | Requires Node 18+; do NOT use `sudo npm install -g` |
| apt (Debian/Ubuntu) | See setup reference | Signed repo; stable or latest channel |
| dnf (Fedora/RHEL) | See setup reference | Signed repo; stable or latest channel |
| apk (Alpine) | See setup reference | Requires `libgcc libstdc++ ripgrep` + `USE_BUILTIN_RIPGREP=0` |

System requirements: macOS 13+, Windows 10 1809+ / Server 2019+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+; 4 GB RAM; x64 or ARM64.

Verify install: `claude --version` or `claude doctor`

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query and exit (non-interactive) |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Apply update immediately |
| `/help` | Show available commands |
| `/login` or `/logout` | Switch accounts |
| `/clear` | Clear conversation history (starts new session) |
| `/init` | Generate CLAUDE.md for your project |
| `/context` | See what is using context window space |
| `/compact` | Manually trigger context compaction |
| `/goal <condition>` | Set a completion condition; Claude works until met |
| `/model` | Switch model mid-session |
| `exit` or Ctrl+D | Exit Claude Code |

### Authentication

Account types accepted (in precedence order when multiple are present):

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` environment variable (bearer token for LLM gateways)
3. `ANTHROPIC_API_KEY` environment variable (direct Anthropic API access)
4. `apiKeyHelper` script output (dynamic/rotating credentials)
5. `CLAUDE_CODE_OAUTH_TOKEN` (long-lived token from `claude setup-token`)
6. Subscription OAuth credentials from `/login` (Claude Pro, Max, Team, Enterprise)

Free Claude.ai plan does not include Claude Code access.

**Long-lived tokens for CI/scripts:** `claude setup-token` generates a one-year OAuth token. Set it as `CLAUDE_CODE_OAUTH_TOKEN`. Not usable in bare mode (`--bare`); use `ANTHROPIC_API_KEY` instead.

**Credential storage:**
- macOS: encrypted macOS Keychain
- Linux: `~/.claude/.credentials.json` (mode 0600)
- Windows: `%USERPROFILE%\.claude\.credentials.json`

### The Agentic Loop

Claude works in three phases that blend together: **gather context → take action → verify results**, repeating until done. Each tool use returns information that informs the next step.

**Built-in tool categories:**

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read files, edit code, create, rename, reorganize |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation, look up errors |
| Code intelligence | Type errors, warnings, definitions, references (requires plugins) |

### Permission Modes

Cycle with `Shift+Tab`:

| Mode | Behavior |
| :--- | :--- |
| Default | Asks before file edits and shell commands |
| Accept edits | Edits files and common filesystem commands without asking; still asks for other commands |
| Plan | Read-only exploration; presents plan for approval before any edit |
| Auto | Background classifier reviews each action; research preview on Max/Team/Enterprise/API |

### Session Management

- Sessions are tied to your current directory; each has its own context window.
- `claude -c` or `claude --continue` resumes most recent session; `claude -r` or `--resume` opens a picker.
- `--fork-session` or `/branch` copies history into a new session ID.
- Transcripts stored in `~/.claude/projects/` as JSONL files.
- Press `Esc` twice to rewind to a previous checkpoint; every file edit is snapshotted before it happens.

### Context Window

Holds conversation history, file contents, command outputs, CLAUDE.md, auto memory, skills, and system instructions. Run `/context` to inspect usage.

When context fills: Claude clears old tool outputs first, then summarizes. Project-root CLAUDE.md and auto memory survive compaction. Add persistent rules to CLAUDE.md — do not rely on conversation history.

Control: `/compact [focus on X]` to compact manually; `Shift+Tab` twice for plan mode to explore without filling context; subagents get their own fresh context.

### /goal — Autonomous Multi-Turn Workflows

Requires Claude Code v2.1.139+. Sets a completion condition; Claude keeps working turn by turn until a separate evaluator model confirms the condition holds.

```
/goal all tests in test/auth pass and the lint step is clean
/goal                    # check status
/goal clear              # cancel active goal
```

**Effective conditions** include one measurable end state, a stated check Claude can demonstrate in the transcript, and constraints that must hold throughout.

Comparison of autonomous approaches:

| Approach | Next turn starts when | Stops when |
| :--- | :--- | :--- |
| `/goal` | Previous turn finishes | Evaluator confirms condition met |
| `/loop` | A time interval elapses | You stop it, or Claude decides done |
| Stop hook | Previous turn finishes | Your own script/prompt decides |

/goal is unavailable when `disableAllHooks` or `allowManagedHooksOnly` is set.

### Platforms Comparison

| Platform | Best for | Notable features |
| :--- | :--- | :--- |
| CLI | Terminal workflows, scripting, remote servers | Full feature set, Agent SDK, computer use (macOS Pro/Max) |
| Desktop | Visual review, parallel sessions | Diff viewer, app preview, Dispatch, computer use (Pro/Max) |
| VS Code | Working inside VS Code | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm | Diff viewer, selection sharing |
| Web | Long-running cloud tasks | Continues after disconnect; Anthropic-managed cloud |
| Mobile | Starting and monitoring tasks remotely | Cloud sessions, Remote Control, Dispatch to Desktop |

Configuration (CLAUDE.md, settings, MCP servers) is shared across local surfaces.

### Integrations

| Integration | Use it for |
| :--- | :--- |
| Chrome | Testing web apps with your logged-in sessions |
| GitHub Actions | Automated PR reviews, issue triage, CI automation |
| GitLab CI/CD | Same as GitHub Actions for GitLab |
| Code Review | Automatic review on every pull request |
| Slack | Route `@Claude` mentions to pull requests |
| MCP servers | Linear, Notion, Google Drive, custom internal APIs |

### Remote / Away-from-Terminal Options

| Option | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | `claude remote-control` | Your machine (CLI or VS Code) |
| Channels | Chat app events (Telegram, Discord) | Your machine (CLI) |
| Slack integration | `@Claude` mention | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud |

### Update Management

| Setting | Effect |
| :--- | :--- |
| `autoUpdatesChannel: "latest"` | Default; new features as released |
| `autoUpdatesChannel: "stable"` | ~1 week behind; skips regressions |
| `minimumVersion: "X.Y.Z"` | Floor for auto-updates; prevents downgrade |
| `DISABLE_AUTOUPDATER: "1"` | Stops background check; `claude update` still works |
| `DISABLE_UPDATES` | Blocks all update paths including manual |
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` | Opt in to auto-update for Homebrew/WinGet |

### Key Glossary Terms

| Term | Definition |
| :--- | :--- |
| Agentic loop | Gather context → take action → verify results; repeats until done |
| Agentic harness | Tools, context management, and execution environment wrapping the model |
| Auto memory | Notes Claude writes for itself; stored in `~/.claude/projects/<project>/memory/` |
| Bare mode | `--bare` flag; skips hooks, skills, plugins, MCP, auto memory, CLAUDE.md |
| Checkpoint | File snapshot before every edit; revert with Esc×2 or `/rewind` |
| CLAUDE.md | Markdown file of persistent instructions you write; loaded every session |
| Compaction | Auto-summarization when context approaches limit; CLAUDE.md survives |
| Context window | Working memory for a session |
| Dispatch | Phone-initiated task router that spawns a Desktop session |
| Hook | Handler executing at a lifecycle point (before tool, after edit, session start, etc.) |
| MCP | Model Context Protocol; connects Claude to external services |
| Permission mode | Baseline approval behavior; cycle with `Shift+Tab` |
| Plan mode | Read-only; Claude proposes changes for approval before touching files |
| Plugin | Bundle of skills, hooks, subagents, and MCP servers as one installable unit |
| Remote Control | Continue a local session from phone or browser; code stays on your machine |
| Rules | Modular instruction files in `.claude/rules/`; can be path-scoped |
| Session | Conversation tied to a directory with its own context window |
| Skill | SKILL.md file with instructions/workflows; invoked with `/name` or auto-loaded |
| Subagent | Specialized agent with its own context; returns summary to main conversation |
| Surface | Any place you access Claude Code (CLI, VS Code, Desktop, web, etc.) |
| Teleport | `/teleport` pulls a cloud session into your local terminal |
| Turn | One complete response from Claude; Stop hooks fire at end of each turn |
| Worktree isolation | `-w` flag; runs Claude in a separate git worktree to avoid conflicts |

### Team Adoption Quick Reference (Champion Kit)

Techniques that move users from first trial to daily use:

| Technique | How |
| :--- | :--- |
| Provide the right context | Use `@file` or `@directory/` references; paste error output directly |
| Review the plan before edits | `Shift+Tab` to enter plan mode |
| Teach it your repository | Run `/init` to generate CLAUDE.md; add conventions and test commands |
| Reuse a workflow | Save a `SKILL.md` in `.claude/skills/<name>/` |
| Stay informed on long tasks | Configure a Stop hook for desktop notifications |
| Recover from wrong results | Paste the failing test or stack trace back; ask Claude to address it |

Responding to common concerns:

| Concern | Response |
| :--- | :--- |
| "I'm faster without it" | True for routine code; leverage is highest on legacy files and unfamiliar services |
| "I don't trust AI on production code" | Plan mode + normal diff review = nothing applied unread, same as a PR |
| "It hallucinated" | Usually a context problem; @-mention relevant files and run `/init` |
| "We don't have time to learn another tool" | It's a terminal command; if no value in first session, set it aside |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — what Claude Code is, surfaces, capabilities summary, and next-steps links
- [Quickstart](references/claude-code-quickstart.md) — step-by-step first session: install, login, ask questions, make changes, use git
- [Advanced setup](references/claude-code-setup.md) — system requirements, all installation methods, Windows/WSL setup, update management, binary verification, uninstallation
- [Authentication](references/claude-code-authentication.md) — account types, team setup (Teams/Enterprise/Console/cloud providers), credential storage, auth precedence, long-lived tokens
- [How Claude Code works](references/claude-code-how-it-works.md) — agentic loop, models, built-in tools, what Claude can access, execution environments, sessions, context window management, checkpoints, permissions
- [Platforms and integrations](references/claude-code-platforms.md) — per-surface comparison, integrations table, remote/away-from-terminal options
- [Keep Claude working toward a goal](references/claude-code-goal.md) — /goal command, writing effective conditions, check/clear/resume, evaluation model, comparison with /loop and Stop hooks
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terms with links to in-depth pages
- [Champion kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally: sharing wins, answering questions, 30-day adoption plan
- [Communications kit](references/claude-code-communications-kit.md) — launch announcements, drip-campaign tips messages, FAQ responses for org rollouts

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
