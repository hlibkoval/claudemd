---
name: headless-doc
description: Complete documentation for running Claude Code programmatically (headless mode / Agent SDK CLI) and Claude Code on the web (cloud sessions). Covers the -p/--print flag for non-interactive CLI usage, --bare mode for CI/scripts (skips hooks/skills/plugins/MCP/CLAUDE.md auto-discovery), --output-format (text, json, stream-json) with --json-schema for structured output, --allowedTools with permission rule syntax for auto-approving tools, --continue/--resume for multi-turn conversations, --append-system-prompt/--system-prompt for prompt customization, streaming with --verbose --include-partial-messages and system/api_retry events. Also covers Claude Code on the web (cloud sessions on claude.ai/code) -- GitHub integration, environment setup (default image with pre-installed languages/runtimes/databases, setup scripts, SessionStart hooks), network access levels (limited with default allowed domains, full, none), security proxy and GitHub proxy, diff view for reviewing changes, auto-fix for PRs (CI failures, review comments), --remote flag to start web sessions from terminal, --teleport/teleport command to pull web sessions into terminal, session sharing (Team/Public visibility, repository access verification), session management (archiving, deleting), and security isolation (isolated VMs, credential protection, branch restrictions). Load when discussing claude -p, headless mode, Agent SDK CLI, running Claude Code programmatically, non-interactive mode, --print flag, --bare mode, CI/CD scripting with Claude Code, structured output from Claude Code, --output-format json, --json-schema, stream-json, --allowedTools, --continue/--resume conversations, --append-system-prompt, Claude Code on the web, cloud sessions, claude.ai/code, --remote, --teleport, /teleport, /tp, web sessions, setup scripts, cloud environment, auto-fix PRs, diff view, session sharing, network access configuration, allowed domains, security proxy, or any topic related to programmatic/headless/web usage of Claude Code.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`claude -p`) and for using Claude Code on the web (cloud sessions).

## Quick Reference

### CLI Programmatic Usage (`claude -p`)

The `-p` (or `--print`) flag runs Claude Code non-interactively. All CLI options work with it.

| Flag | Purpose |
|:-----|:--------|
| `-p "prompt"` / `--print "prompt"` | Run non-interactively, print response |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP servers, auto memory, CLAUDE.md |
| `--output-format text\|json\|stream-json` | Control response format |
| `--json-schema '{...}'` | Constrain output to a JSON Schema (use with `--output-format json`) |
| `--allowedTools "Tool1,Tool2"` | Auto-approve specific tools without prompting |
| `--continue` | Continue most recent conversation |
| `--resume <session-id>` | Continue a specific conversation |
| `--append-system-prompt "..."` | Add instructions while keeping default behavior |
| `--append-system-prompt-file <path>` | Same, but from a file |
| `--system-prompt "..."` | Fully replace the default system prompt |
| `--settings <file-or-json>` | Load settings from file or inline JSON |
| `--mcp-config <file-or-json>` | Load MCP server config |
| `--agents <json>` | Load custom agents |
| `--plugin-dir <path>` | Load a plugin directory |
| `--verbose` | Include detailed event information in streaming |
| `--include-partial-messages` | Emit tokens as they are generated (streaming) |

### Bare Mode

`--bare` reduces startup time by skipping all auto-discovery. Recommended for CI and scripts -- only flags you pass explicitly take effect.

Authentication in bare mode: requires `ANTHROPIC_API_KEY` or an `apiKeyHelper` in the JSON passed to `--settings` (skips OAuth and keychain reads). Bedrock, Vertex, and Foundry use their usual provider credentials.

Bare mode still provides access to Bash, file read, and file edit tools.

Context loading in bare mode:

| To load | Use |
|:--------|:----|
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings | `--settings <file-or-json>` |
| MCP servers | `--mcp-config <file-or-json>` |
| Custom agents | `--agents <json>` |
| A plugin directory | `--plugin-dir <path>` |

### Output Formats

| Format | Description |
|:-------|:------------|
| `text` (default) | Plain text output |
| `json` | Structured JSON with `result`, `session_id`, and metadata |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

With `--output-format json` and `--json-schema`, structured output appears in the `structured_output` field.

### Streaming Events

Use `--output-format stream-json --verbose --include-partial-messages` for token-by-token streaming. Each line is a JSON event.

**API retry event** (`system/api_retry`):

| Field | Type | Description |
|:------|:-----|:------------|
| `type` | `"system"` | Message type |
| `subtype` | `"api_retry"` | Retry event identifier |
| `attempt` | integer | Current attempt number (from 1) |
| `max_retries` | integer | Total retries permitted |
| `retry_delay_ms` | integer | Milliseconds until next attempt |
| `error_status` | integer or null | HTTP status code, or null for connection errors |
| `error` | string | Category: `authentication_failed`, `billing_error`, `rate_limit`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |

### Tool Auto-Approval

`--allowedTools` uses permission rule syntax. Trailing ` *` enables prefix matching (the space before `*` is important):

- `Bash(git diff *)` -- allows any command starting with `git diff`
- `Bash(git diff*)` without the space would also match `git diff-index`

User-invoked skills and built-in commands are only available in interactive mode, not with `-p`.

### Multi-Turn Conversations

```
# First request
claude -p "Review this codebase for performance issues"

# Continue most recent conversation
claude -p "Now focus on the database queries" --continue

# Capture session ID for specific resume
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

---

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs. Available to Pro, Max, Team, and Enterprise users at [claude.ai/code](https://claude.ai/code).

**Getting started:** Connect GitHub account -> install Claude GitHub App -> select environment -> submit task -> review changes in diff view -> create PR.

### Web Session Workflow

| Step | What happens |
|:-----|:-------------|
| Repository cloning | Repo cloned to an Anthropic-managed VM (default branch) |
| Environment setup | Setup script runs if configured |
| Network configuration | Internet access configured per environment settings |
| Task execution | Claude analyzes code, makes changes, runs tests |
| Completion | Branch pushed to remote, ready for PR creation |

### Moving Between Web and Terminal

**Terminal to web** (`--remote`):

```
claude --remote "Fix the authentication bug in src/auth/login.ts"
```

Creates a new web session. Monitor with `/tasks`, or interact on claude.ai or the Claude mobile app.

**Web to terminal** (teleport):

| Method | Usage |
|:-------|:------|
| `/teleport` or `/tp` | Interactive picker of web sessions from within Claude Code |
| `claude --teleport` | Interactive session picker from command line |
| `claude --teleport <session-id>` | Resume specific session directly |
| `/tasks` then press `t` | Teleport from task list |
| "Open in CLI" button | Copy command from web interface |

**Teleport requirements:**

| Requirement | Details |
|:------------|:--------|
| Clean git state | No uncommitted changes (prompted to stash if needed) |
| Correct repository | Must be in a checkout of the same repository (not a fork) |
| Branch available | Web session branch must have been pushed to remote |
| Same account | Must be authenticated to the same Claude.ai account |

Session handoff is one-way: web to terminal only. `--remote` creates a new web session, it does not push an existing terminal session.

### Environment Selection

Use `/remote-env` to choose which environment to use for `--remote` sessions.

### Auto-Fix PRs

Claude watches a PR and automatically responds to CI failures and review comments.

**Enable auto-fix:**

| Context | How to enable |
|:--------|:-------------|
| PRs created in Claude Code on the web | Open CI status bar, select Auto-fix |
| Mobile app | Tell Claude to auto-fix the PR |
| Any existing PR | Paste PR URL into a session, tell Claude to auto-fix |

**Response behavior:**

| Scenario | Action |
|:---------|:-------|
| Clear fix | Claude pushes the change and explains in session |
| Ambiguous request | Claude asks before acting |
| Duplicate/no-action event | Claude notes it and moves on |

Claude may reply to review comment threads on GitHub using your account (labeled as from Claude Code).

### Cloud Environment

**Default image includes:**

| Category | Pre-installed |
|:---------|:-------------|
| Languages | Python 3.x, Node.js LTS, Ruby 3.1/3.2/3.3, PHP 8.4, Java (OpenJDK), Go, Rust, C++ (GCC/Clang) |
| Package managers | pip, poetry, npm, yarn, pnpm, bun, gem, bundler, Maven, Gradle, cargo |
| Databases | PostgreSQL 16, Redis 7.0 |

Run `check-tools` to see what is available.

### Setup Scripts

Bash scripts that run when a new session starts, before Claude Code launches. Configured per-environment in the cloud UI. Run as root on Ubuntu 24.04.

- Only run on new sessions (skipped on resume)
- Non-zero exit fails the session (use `|| true` for non-critical commands)
- Need network access for package installs (default "Limited" access includes common registries)

**Setup scripts vs SessionStart hooks:**

| | Setup scripts | SessionStart hooks |
|:-|:-------------|:-------------------|
| Attached to | Cloud environment | Repository (`.claude/settings.json`) |
| Runs | Before Claude Code, new sessions only | After Claude Code, every session (including resumed) |
| Scope | Cloud only | Both local and cloud |

To skip local execution in a SessionStart hook, check `CLAUDE_CODE_REMOTE` environment variable.

### Network Access

| Level | Behavior |
|:------|:---------|
| Limited (default) | Allowlisted domains only |
| Full | Unrestricted internet access |
| None | No internet (Anthropic API still reachable) |

Default allowed domains include: Anthropic services, GitHub/GitLab/Bitbucket, container registries (Docker, GCR, GHCR, ECR), cloud platforms (AWS, GCP, Azure), package registries for JS/Python/Ruby/Rust/Go/JVM/PHP/.NET/Dart/Elixir/Perl and more, Linux distribution repos, Kubernetes, HashiCorp, and development tool platforms.

All outbound traffic passes through a security proxy for abuse prevention.

### Session Sharing

| Account type | Visibility options | Repo access verification |
|:-------------|:-------------------|:------------------------|
| Enterprise/Teams | Private, Team | On by default |
| Max/Pro | Private, Public | Off by default (configurable in Settings) |

### Session Management

- **Archive**: hover over session in sidebar, click archive icon
- **Delete**: filter for archived sessions then click delete, or use session dropdown menu (permanent, cannot be undone)

### Security

- Each session runs in an isolated Anthropic-managed VM
- Network access controls (configurable)
- Credentials never inside the sandbox (secure proxy with scoped credentials)
- Git push restricted to current working branch

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- CLI usage with `-p`/`--print` flag, `--bare` mode for CI/scripts (skips auto-discovery, requires explicit flags for context), output formats (text, json, stream-json with streaming events and api_retry), `--json-schema` for structured output, `--allowedTools` with permission rule syntax and prefix matching, creating commits, customizing system prompts (`--append-system-prompt`, `--system-prompt`), continuing conversations (`--continue`, `--resume`), Agent SDK links for Python/TypeScript
- [Claude Code on the web](references/claude-code-on-the-web.md) -- cloud sessions on claude.ai/code, getting started with GitHub integration, diff view for reviewing changes, auto-fix PRs (CI failures and review comments), moving between web and terminal (`--remote`, `--teleport`, `/teleport`, `/tp`, `/tasks`), session sharing (Team/Public visibility, repository access verification), scheduling recurring tasks, cloud environment (default image with languages/runtimes/databases, `check-tools`, setup scripts vs SessionStart hooks, dependency management with `CLAUDE_CODE_REMOTE` guard), network access levels (limited/full/none, default allowed domains by category, security proxy, GitHub proxy), security and isolation (isolated VMs, credential protection, branch restrictions), session management (archiving, deleting), limitations (GitHub only, same-account requirement for teleport)

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
