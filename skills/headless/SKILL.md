---
name: headless
description: Reference documentation for running Claude Code programmatically via CLI (-p flag), headless mode, structured output, streaming, conversation continuation, and Claude Code on the web -- cloud-based async sessions, remote/teleport workflows, environment configuration, network access levels, allowed domains, and security isolation.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically (headless mode / CLI `-p` flag) and Claude Code on the web (cloud-based async sessions).

## Quick Reference

### CLI Headless Mode (`-p`)

Pass `-p` (or `--print`) to run Claude Code non-interactively. All CLI options work with `-p`.

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

#### Output Formats

| Format          | Flag                      | Description                                           |
|:----------------|:--------------------------|:------------------------------------------------------|
| `text`          | `--output-format text`    | Plain text output (default)                           |
| `json`          | `--output-format json`    | Structured JSON with `result`, `session_id`, metadata |
| `stream-json`   | `--output-format stream-json` | Newline-delimited JSON for real-time streaming     |

For schema-constrained output, combine `--output-format json` with `--json-schema '<schema>'`. The response includes `structured_output` in addition to `result`.

#### Streaming Tokens

```bash
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

#### Common Patterns

| Pattern                 | Command                                                                          |
|:------------------------|:---------------------------------------------------------------------------------|
| Auto-approve tools      | `claude -p "..." --allowedTools "Bash,Read,Edit"`                                |
| Create a commit         | `claude -p "..." --allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"` |
| Custom system prompt    | `claude -p ... --append-system-prompt "You are a security engineer."`            |
| Continue last session   | `claude -p "..." --continue`                                                    |
| Resume specific session | `claude -p "..." --resume "$session_id"`                                         |

The `--allowedTools` flag uses permission rule syntax. Trailing ` *` enables prefix matching (e.g., `Bash(git diff *)` matches any command starting with `git diff`). The space before `*` matters.

User-invoked skills (`/commit`, etc.) and built-in commands are only available in interactive mode. In `-p` mode, describe the task directly.

### Claude Code on the Web

Available in research preview for Pro, Max, Team, and Enterprise users. Runs Claude Code tasks asynchronously on Anthropic-managed cloud VMs.

#### Getting Started

1. Visit [claude.ai/code](https://claude.ai/code)
2. Connect GitHub account and install the Claude GitHub app
3. Select default environment, submit a task
4. Review changes in diff view, iterate, then create a PR

#### Terminal-to-Web (`--remote`)

```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```

Creates a new web session. Monitor with `/tasks`, steer from claude.ai or mobile app. Multiple `--remote` calls run in parallel.

#### Web-to-Terminal (Teleport)

| Method             | How                                                         |
|:-------------------|:------------------------------------------------------------|
| `/teleport` or `/tp` | Interactive picker of web sessions from within Claude Code |
| `--teleport`       | CLI flag; optionally pass a session ID                      |
| `/tasks` then `t`  | From background task list                                   |
| Web UI             | "Open in CLI" button copies a paste-ready command           |

Teleport requirements: clean git state, correct repository (not a fork), branch pushed to remote, same Claude.ai account.

Session handoff is one-way: web sessions can be pulled into terminal, but existing terminal sessions cannot be pushed to web.

#### Cloud Environment

Default image includes: Python, Node.js, Ruby, PHP, Java, Go, Rust, C++, PostgreSQL 16, Redis 7.0. Run `check-tools` to inspect.

#### Environment Configuration

| Setting               | How to configure                                                 |
|:----------------------|:-----------------------------------------------------------------|
| Add environment       | Select current env, then "Add environment"                       |
| Update environment    | Select current env, click settings button                        |
| Select from terminal  | `/remote-env` to choose env for `--remote`                       |
| Environment variables | Key-value pairs in `.env` format                                 |
| Dependencies          | Use SessionStart hooks (check `$CLAUDE_CODE_REMOTE` to scope)   |

#### Network Access Levels

| Level     | Description                                              |
|:----------|:---------------------------------------------------------|
| No internet | No outbound access (Anthropic API still reachable)    |
| Limited   | Default -- only allowlisted domains (package registries, GitHub, cloud platforms, etc.) |
| Full      | Unrestricted internet access                             |

All outbound traffic passes through a security proxy. GitHub operations use a dedicated proxy with scoped credentials. Git push is restricted to the current working branch.

#### Security

- Each session runs in an isolated VM
- Credentials (git tokens, signing keys) are never inside the sandbox
- Network access is limited by default

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) -- CLI `-p` flag, output formats, streaming, auto-approve tools, system prompt customization, conversation continuation, Agent SDK
- [Claude Code on the Web](references/claude-code-on-the-web.md) -- cloud sessions, remote/teleport workflows, diff view, environment configuration, network access levels, allowed domains, dependency management, security isolation

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
