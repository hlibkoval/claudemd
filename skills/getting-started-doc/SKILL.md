---
name: getting-started-doc
description: Complete official documentation for getting started with Claude Code — overview, quickstart, advanced setup, authentication, how it works (agentic loop, tools, sessions), platforms and integrations, glossary, and team adoption kits.
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code, including installation, authentication, core architecture, platforms, and team adoption resources.

## Quick Reference

### Installation

| Platform | Command |
| :--- | :--- |
| macOS / Linux / WSL (native) | `curl -fsSL https://claude.ai/install.sh | bash` |
| Windows PowerShell (native) | `irm https://claude.ai/install.ps1 | iex` |
| Windows CMD (native) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| Homebrew | `brew install --cask claude-code` (stable) or `brew install --cask claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` |
| apt (Debian/Ubuntu) | `sudo apt install claude-code` (after adding the signed repo) |
| dnf (Fedora/RHEL) | `sudo dnf install claude-code` (after adding the signed repo) |
| apk (Alpine) | `apk add claude-code` (after adding the signed repo) |

Native installations auto-update in the background. Homebrew, WinGet, and Linux package manager installs require manual upgrades.

**Verify installation:**
```bash
claude --version
claude doctor
```

**After installing:**
```bash
cd your-project
claude
# Log in on first use; credentials are stored after that
```

---

### System Requirements

| Requirement | Detail |
| :--- | :--- |
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Network | Internet connection required |
| Shell | Bash, Zsh, PowerShell, or CMD |

---

### Authentication

**Account types accepted:**

| Type | How to log in |
| :--- | :--- |
| Claude Pro / Max subscription | `claude` → browser login |
| Claude for Teams or Enterprise | `claude` → browser login with team account |
| Claude Console (API) | `claude` → browser login with Console credentials |
| Amazon Bedrock | Set `CLAUDE_CODE_USE_BEDROCK` + AWS credentials before running `claude` |
| Google Vertex AI | Set `CLAUDE_CODE_USE_VERTEX` + GCP credentials before running `claude` |
| Microsoft Foundry | Set `CLAUDE_CODE_USE_FOUNDRY` + Azure credentials before running `claude` |

**Authentication precedence (highest first):**

1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY`)
2. `ANTHROPIC_AUTH_TOKEN` — bearer token for LLM gateways/proxies
3. `ANTHROPIC_API_KEY` — direct Anthropic API key
4. `apiKeyHelper` script output — dynamic/rotating credentials
5. `CLAUDE_CODE_OAUTH_TOKEN` — long-lived token from `claude setup-token` (for CI)
6. Subscription OAuth credentials from `/login` (default for most users)

**Credential storage:** macOS Keychain; Linux/Windows `~/.claude/.credentials.json`.

**Long-lived token for CI:**
```bash
claude setup-token
export CLAUDE_CODE_OAUTH_TOKEN=your-token
```

---

### Essential CLI Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Start interactive mode |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Non-interactive query (exits after) |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude update` | Manually trigger an update |
| `claude doctor` | Diagnose installation issues |
| `/login` | Switch accounts |
| `/logout` | Log out |
| `/clear` | Start a new session |
| `/help` | Show available commands |
| `/init` | Generate a CLAUDE.md for your project |
| `/model` | Switch models mid-session |
| `/compact` | Manually compact context |
| `/context` | Show what's using context space |
| `/plan` | Enter plan mode (read-only, proposes changes) |
| `exit` or Ctrl+D | Exit Claude Code |

---

### Permission Modes

Cycle through modes with **Shift+Tab**:

| Mode | Behavior |
| :--- | :--- |
| `default` | Asks before file edits and shell commands |
| `acceptEdits` | Auto-accepts file edits and common filesystem commands (`mkdir`, `mv`, etc.); still asks for other shell commands |
| `plan` | Read-only tools only; proposes a plan for approval before execution |
| `auto` | Background classifier evaluates all actions (research preview, Max/Team/Enterprise/API) |

---

### The Agentic Loop

Claude works through three phases for every task:

1. **Gather context** — reads files, searches code, understands the project
2. **Take action** — edits files, runs commands, creates commits
3. **Verify results** — runs tests, checks output, course-corrects

**Built-in tool categories:**

| Category | What Claude can do |
| :--- | :--- |
| File operations | Read files, edit code, create and rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, start servers, run tests, use git |
| Web | Search the web, fetch documentation, look up errors |
| Code intelligence | Type errors, definitions, references (requires plugins) |

---

### Sessions

- Each session is tied to a directory with its own context window
- Saved as JSONL under `~/.claude/projects/`
- File snapshots (checkpoints) taken before every edit — press Esc twice or `/rewind` to restore
- **Resume:** `claude --continue` or `claude --resume` (same session ID, history restored, session-scoped permissions reset)
- **Fork:** `claude --continue --fork-session` (new ID, history preserved, original unchanged)
- **Parallel sessions:** use git worktrees (`claude -w`)

**Context management:**
- `/context` — inspect what's loaded
- `/compact [focus]` — manually summarize
- Auto-compaction fires near the limit; CLAUDE.md and auto memory survive and reload

---

### Update Management

| Setting | Effect |
| :--- | :--- |
| `"autoUpdatesChannel": "latest"` | Receive updates as soon as they ship (default) |
| `"autoUpdatesChannel": "stable"` | Receive versions ~1 week old, skipping major regressions |
| `"minimumVersion": "X.Y.Z"` | Enforce a minimum version floor |
| `DISABLE_AUTOUPDATER=1` | Stop background checks (manual `claude update` still works) |
| `DISABLE_UPDATES=1` | Block all update paths |

---

### Platforms

| Platform | Best for | Key extras |
| :--- | :--- | :--- |
| CLI | Terminal, scripting, remote servers | Full feature set, Agent SDK, third-party providers |
| Desktop | Visual review, parallel sessions | Diff viewer, Dispatch, computer use (Pro/Max) |
| VS Code | Editor-integrated workflow | Inline diffs, integrated terminal, file context |
| JetBrains | IntelliJ, PyCharm, WebStorm, etc. | Diff viewer, selection sharing |
| Web | Long-running tasks, no local setup | Anthropic-managed cloud, persists after disconnect |
| Mobile | Starting/monitoring tasks away from desk | Cloud sessions via Claude app, Remote Control, Dispatch |

**Remote access options:**

| Option | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Dispatch | Message from Claude mobile app | Your machine (Desktop) |
| Remote Control | Drive from claude.ai or mobile | Your machine (CLI or VS Code) |
| Channels | Telegram, Discord, iMessage, or webhooks | Your machine (CLI) |
| Slack | `@Claude` in a channel | Anthropic cloud |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud (Routines) |

---

### Glossary of Key Terms

| Term | Definition |
| :--- | :--- |
| **Agentic loop** | The gather→act→verify cycle Claude runs for every task |
| **Agentic harness** | Claude Code itself — the tool layer that turns the model into a coding agent |
| **CLAUDE.md** | Persistent instructions you write, loaded at the start of every session |
| **Auto memory** | Notes Claude writes for itself (stored in `~/.claude/projects/`), Claude's counterpart to CLAUDE.md |
| **Checkpoint** | Automatic file snapshot before each edit; press Esc twice or `/rewind` to restore |
| **Compaction** | Automatic summarization when the context window fills up |
| **Context window** | The working memory for a session: conversation, files, CLAUDE.md, skills, system prompt |
| **Session** | A conversation tied to a directory, saved as JSONL under `~/.claude/projects/` |
| **Skill** | A SKILL.md file adding instructions or workflows; invoked with `/name` |
| **Subagent** | Specialized agent with its own context window, used for delegated tasks |
| **MCP** | Model Context Protocol — open standard for connecting Claude to external services |
| **Hook** | Shell command or handler that fires automatically at lifecycle points |
| **Plugin** | Bundle of skills, hooks, subagents, and MCP servers installed as a unit |
| **Plan mode** | Read-only permission mode that proposes changes before touching files |
| **Auto mode** | Background classifier approves actions (research preview) |
| **Bare mode** | `--bare` flag — skips hooks, skills, CLAUDE.md, MCP; for reproducible CI runs |
| **Teleport** | `/teleport` pulls a cloud session into your local terminal |
| **Remote Control** | Drive a local session from your browser or phone via claude.ai |
| **Surface** | Any place you access Claude Code (CLI, VS Code, Desktop, Web, JetBrains) |
| **Worktree isolation** | `-w` flag — runs Claude in a separate git worktree to prevent parallel agents from conflicting |

---

### Team Adoption Quick Reference

**Champion behaviors:**

| Behavior | What it looks like | Time per week |
| :--- | :--- | :--- |
| Share discoveries | Post prompts and screenshots in engineering channels | ~15 min |
| Answer publicly | Reply with the actual prompt used, not a description | ~20 min |
| Grow the circle | Weekly show-and-tell thread, pin Quickstart in `#claude-code` | ~5 min |

**Most useful starter prompts:**

| Task | Prompt |
| :--- | :--- |
| Fix a bug | "the tests in [file] are failing, figure out why and fix it" |
| Understand code | "walk me through how [module] works, then tell me where the entry point is" |
| Safe refactor | "refactor [module] to [goal], use plan mode so I can review first" |
| Write tests | "write tests for [file] that cover the edge cases around [scenario]" |
| Review before commit | "look at my working diff and tell me what looks risky" |
| Open a PR | "fix [issue], write a conventional commit, and open a PR with a summary" |

**Model selection:**

| Model | Best for |
| :--- | :--- |
| Opus | Large refactors, complex debugging, architecture decisions, high-stakes changes |
| Sonnet | Everyday feature work, bug fixes, tests, documentation, code review (recommended default) |
| Haiku | Quick questions, formatting, mechanical edits, rapid iteration |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Overview](references/claude-code-overview.md) — what Claude Code is, installation options across all surfaces, capability overview, and next steps
- [Quickstart](references/claude-code-quickstart.md) — step-by-step guide from install through first code change, Git usage, essential commands, and pro tips
- [Advanced Setup](references/claude-code-setup.md) — system requirements, platform-specific installation (Windows native/WSL, Alpine), Linux package managers, version management (channels, pinning, auto-update), binary verification, and uninstallation
- [Authentication](references/claude-code-authentication.md) — individual and team login methods, Console setup, cloud provider auth, credential storage, authentication precedence, and long-lived tokens for CI
- [How Claude Code Works](references/claude-code-how-it-works.md) — the agentic loop, models, built-in tools, sessions, context window management, checkpoints, permission modes, and effective usage tips
- [Platforms and Integrations](references/claude-code-platforms.md) — comparison of CLI, Desktop, VS Code, JetBrains, Web, and Mobile; integrations (Chrome, GitHub Actions, GitLab, Code Review, Slack); remote access options
- [Glossary](references/claude-code-glossary.md) — definitions for all Claude Code terminology with links to in-depth docs
- [Champion Kit](references/claude-code-champion-kit.md) — playbook for engineers advocating Claude Code internally: sharing discoveries, answering questions, 30-day adoption plan, handling concerns
- [Communications Kit](references/claude-code-communications-kit.md) — launch announcements, tips-and-tricks drip campaign messages, and FAQ responses for rolling out to an engineering organization

## Sources

- Claude Code Overview: https://code.claude.com/docs/en/overview.md
- Quickstart: https://code.claude.com/docs/en/quickstart.md
- Advanced Setup: https://code.claude.com/docs/en/setup.md
- Authentication: https://code.claude.com/docs/en/authentication.md
- How Claude Code Works: https://code.claude.com/docs/en/how-claude-code-works.md
- Platforms and Integrations: https://code.claude.com/docs/en/platforms.md
- Glossary: https://code.claude.com/docs/en/glossary.md
- Champion Kit: https://code.claude.com/docs/en/champion-kit.md
- Communications Kit: https://code.claude.com/docs/en/communications-kit.md
