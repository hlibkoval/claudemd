---
name: getting-started-doc
user-invocable: false
---

# Getting Started Documentation

This skill provides the complete official documentation for getting started with Claude Code — installation, authentication, the agentic loop, platforms, the `/goal` command, and team rollout resources.

## Quick Reference

### Installation methods

| Method | Command | Auto-updates |
| :----- | :------ | :----------- |
| Native (macOS/Linux/WSL) | `curl -fsSL https://claude.ai/install.sh \| bash` | Yes |
| Native (Windows PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | Yes |
| Homebrew (stable) | `brew install --cask claude-code` | No — run `brew upgrade claude-code` |
| Homebrew (latest) | `brew install --cask claude-code@latest` | No — run `brew upgrade claude-code@latest` |
| WinGet | `winget install Anthropic.ClaudeCode` | No — run `winget upgrade Anthropic.ClaudeCode` |
| npm | `npm install -g @anthropic-ai/claude-code` | No — run `npm install -g @anthropic-ai/claude-code@latest` |
| apt (Debian/Ubuntu) | See setup doc | No |
| dnf (Fedora/RHEL) | See setup doc | No |
| apk (Alpine) | See setup doc | No |

### System requirements

| Requirement | Detail |
| :---------- | :----- |
| macOS | 13.0+ |
| Windows | 10 1809+ or Server 2019+ |
| Linux | Ubuntu 20.04+, Debian 10+, Alpine 3.19+ |
| Hardware | 4 GB+ RAM, x64 or ARM64 |
| Shell | Bash, Zsh, PowerShell, or CMD |
| Network | Internet required |

### First-run commands

```bash
# Install, then start in any project
cd your-project
claude

# Verify installation
claude --version
claude doctor

# One-time setup: generate CLAUDE.md from your project
# (type this inside the claude session)
# /init
```

### Essential shell commands

| Command | What it does |
| :------ | :----------- |
| `claude` | Start interactive session |
| `claude "task"` | Run a one-time task |
| `claude -p "query"` | Run one-off query, then exit |
| `claude -c` | Continue most recent conversation |
| `claude -r` | Resume a previous conversation |
| `claude --model <name>` | Start with a specific model |
| `claude update` | Apply available update immediately |
| `claude setup-token` | Generate a long-lived OAuth token for CI |

### Essential session commands

| Command | What it does |
| :------ | :----------- |
| `/init` | Generate CLAUDE.md for current project |
| `/help` | Show available commands |
| `/login` | Re-authenticate or switch accounts |
| `/logout` | Log out |
| `/model` | Switch model mid-session |
| `/clear` | Start a new conversation |
| `/resume` | Pick a previous session to resume |
| `/context` | See what's consuming context |
| `/compact` | Manually compact context |
| `/goal <condition>` | Set a completion condition (see below) |
| `/exit` or Ctrl+D | Exit Claude Code |

### Authentication options

| Account type | Best for |
| :----------- | :------- |
| Claude Pro / Max | Individual developers |
| Claude for Teams | Small teams with centralized billing |
| Claude for Enterprise | SSO, compliance, managed policies |
| Claude Console | API-based billing, direct key access |
| Amazon Bedrock | Enterprise cloud (AWS) |
| Google Vertex AI | Enterprise cloud (GCP) |
| Microsoft Foundry | Enterprise cloud (Azure) |

**Authentication precedence (highest to lowest):**
1. Cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK`, etc.)
2. `ANTHROPIC_AUTH_TOKEN` env var
3. `ANTHROPIC_API_KEY` env var
4. `apiKeyHelper` script output
5. `CLAUDE_CODE_OAUTH_TOKEN` env var
6. Subscription OAuth credentials from `/login`

**Credential storage locations:**
- macOS: encrypted macOS Keychain
- Linux: `~/.claude/.credentials.json` (mode 0600)
- Windows: `%USERPROFILE%\.claude\.credentials.json`

### The agentic loop

Claude works through three phases on every task:

| Phase | What happens |
| :---- | :----------- |
| Gather context | Read files, search code, understand the problem |
| Take action | Edit files, run commands, call tools |
| Verify results | Run tests, check output, course-correct |

### Built-in tool categories

| Category | What Claude can do |
| :------- | :----------------- |
| File operations | Read, edit, create, rename files |
| Search | Find files by pattern, search content with regex |
| Execution | Run shell commands, tests, git operations |
| Web | Search the web, fetch documentation |
| Code intelligence | Type errors, jump to definitions (requires plugins) |

### Permission modes (cycle with Shift+Tab)

| Mode | Behavior |
| :--- | :------- |
| Default | Asks before file edits and shell commands |
| Auto-accept edits | File edits and common filesystem commands run without asking |
| Plan | Explores and proposes a plan; no source file edits |
| Auto | Background classifier approves most actions (research preview) |

### The `/goal` command

`/goal` sets a completion condition; Claude keeps working across turns until the condition is met.

| Command | Effect |
| :------ | :----- |
| `/goal <condition>` | Set a goal and start working immediately |
| `/goal` | Check status (turns, tokens, evaluator reason) |
| `/goal clear` | Remove the active goal |
| `/goal stop` | Alias for clear |

**When to use `/goal` vs alternatives:**

| Approach | Next turn starts when | Stops when |
| :------- | :-------------------- | :--------- |
| `/goal` | Previous turn finishes | A model confirms the condition is met |
| `/loop` | A time interval elapses | You stop it, or Claude decides work is done |
| Stop hook | Previous turn finishes | Your own script or prompt decides |

**Effective condition ingredients:**
- One measurable end state (test result, build exit code, file count)
- A stated check (how Claude should prove it)
- Constraints that must hold throughout

`/goal` requires Claude Code v2.1.139+. It is unavailable when `disableAllHooks` or `allowManagedHooksOnly` is set.

### Platforms and surfaces

| Platform | Best for |
| :------- | :------- |
| CLI | Terminal workflows, scripting, remote servers |
| Desktop | Visual diff review, parallel sessions |
| VS Code | Inline diffs, editor-integrated workflow |
| JetBrains | IntelliJ, PyCharm, WebStorm workflows |
| Web (claude.ai/code) | Long-running cloud tasks, mobile kick-off |
| Mobile (iOS/Android) | Starting and monitoring tasks away from desk |

### Integrations

| Integration | Use it for |
| :---------- | :--------- |
| Chrome | Automating browser tasks with logged-in sessions |
| GitHub Actions | Automated PR reviews, issue triage |
| GitLab CI/CD | CI-driven automation on GitLab |
| Code Review | Automatic review on every pull request |
| Slack | Turning bug reports into PRs from team chat |
| Remote Control | Driving a local session from phone or browser |

### Key glossary terms

| Term | Definition |
| :--- | :--------- |
| Agentic loop | Gather context → take action → verify results, repeat |
| Agentic harness | Tools + context management + execution environment around the model |
| CLAUDE.md | Markdown file of persistent instructions loaded every session |
| Auto memory | Notes Claude writes for itself; stored per git repo under `~/.claude/projects/` |
| Compaction | Automatic summarization when context window fills; CLAUDE.md survives |
| Session | A conversation tied to a directory with its own context window |
| Turn | One complete Claude response, with any number of tool calls |
| Checkpoint | Restore point before each edit; press Esc twice or run `/rewind` |
| Skill | A SKILL.md file with instructions Claude loads on demand or by `/name` |
| Subagent | Specialized agent with its own context, used for delegated or parallel tasks |
| MCP | Open protocol connecting Claude to external services |
| Plan mode | Permission mode where Claude proposes changes before touching any file |
| Bare mode | `--bare` flag; skips hooks, skills, plugins, MCP for reproducible CI runs |
| Non-interactive mode | `-p` flag; runs one prompt and exits (formerly headless mode) |
| Verification loop | Giving Claude a check it can run (tests, build) to confirm work is done |

### Team rollout essentials

**Champion quick-reference:**

| Technique | How to apply |
| :-------- | :----------- |
| Provide context | Use `@file` or `@directory/` references; paste error output |
| Review before edit | Press Shift+Tab to enter plan mode |
| Teach the repo | Run `/init` to generate CLAUDE.md; add conventions and test commands |
| Reuse workflows | Save a SKILL.md to create a `/name` command the whole team can use |
| Long-task notification | Configure a Stop hook for desktop alerts |
| Recover from errors | Paste the failing test or stack trace back; don't rephrase the request |

**Common FAQ responses:**

| Question | Response |
| :------- | :------- |
| "Where does my code go?" | CLI talks directly to Anthropic's API; no third-party servers |
| "Do I need to configure anything?" | No. Install, run `claude`, then `/init` once per repo |
| "Can it see my whole repo?" | Reads what you give access to; edits and shell commands require approval |
| "How is this different from Copilot?" | Copilot autocompletes lines; Claude Code is an agent that reads files, runs commands, makes multi-file edits |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-overview.md) — What Claude Code is, surfaces, installation summary, and what you can do with it
- [Quickstart](references/claude-code-quickstart.md) — Step-by-step first session walkthrough
- [Advanced Setup](references/claude-code-setup.md) — System requirements, all install methods, updates, release channels, binary verification, uninstall
- [Authentication](references/claude-code-authentication.md) — Account types, team setup, credential management, long-lived tokens
- [How Claude Code Works](references/claude-code-how-it-works.md) — Agentic loop, built-in tools, sessions, context window, checkpoints, permissions, working tips
- [Platforms and Integrations](references/claude-code-platforms.md) — Surface comparison table, integrations, remote-access options
- [Keep Claude Working Toward a Goal](references/claude-code-goal.md) — The `/goal` command, writing effective conditions, status and clear, evaluation model
- [Champion Kit](references/claude-code-champion-kit.md) — Playbook for engineers advocating Claude Code internally
- [Communications Kit](references/claude-code-communications-kit.md) — Launch announcements, drip-campaign messages, FAQ responses for org rollouts
- [Glossary](references/claude-code-glossary.md) — Definitions for all Claude Code terms

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
