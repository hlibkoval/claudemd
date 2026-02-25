---
name: headless
description: Reference documentation for running Claude Code programmatically (headless / CLI mode with -p flag) and Claude Code on the web (cloud sessions). Covers structured output, streaming, auto-approving tools, session continuation, system prompt customization, web session lifecycle, teleport, diff review, cloud environments, network policies, and allowed domains.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI and for Claude Code on the web (cloud sessions).

## Quick Reference

### CLI Mode (`-p` flag)

Pass `-p` (or `--print`) to run Claude Code non-interactively. All CLI options work with `-p`.

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

#### Output Formats

| Format          | Flag                                | Description                                |
|:----------------|:------------------------------------|:-------------------------------------------|
| `text`          | `--output-format text` (default)    | Plain text output                          |
| `json`          | `--output-format json`              | Structured JSON with `result`, `session_id`, metadata |
| `stream-json`   | `--output-format stream-json`       | Newline-delimited JSON for real-time streaming |

Use `--json-schema` with `--output-format json` for schema-constrained output (result in `structured_output` field).

#### Common Patterns

| Task                    | Command                                                                                  |
|:------------------------|:-----------------------------------------------------------------------------------------|
| Auto-approve tools      | `--allowedTools "Bash,Read,Edit"`                                                        |
| Create a commit         | `--allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"` |
| Append system prompt    | `--append-system-prompt "You are a security engineer."`                                  |
| Replace system prompt   | `--system-prompt "Custom prompt here"`                                                   |
| Continue last session   | `--continue`                                                                             |
| Resume specific session | `--resume <session_id>`                                                                  |
| Stream tokens           | `--output-format stream-json --verbose --include-partial-messages`                       |

#### Extracting Results with jq

```bash
# Text result from JSON output
claude -p "Summarize this project" --output-format json | jq -r '.result'

# Structured output
claude -p "Extract functions" --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}' \
  | jq '.structured_output'

# Stream text deltas
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

Note: User-invoked skills (e.g. `/commit`) and built-in commands are only available in interactive mode. In `-p` mode, describe the task directly.

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs. Available to Pro, Max, Team, and Enterprise users.

#### Getting Started

1. Visit [claude.ai/code](https://claude.ai/code)
2. Connect GitHub account
3. Install Claude GitHub app in repositories
4. Select default environment
5. Submit task, review diff, create PR

#### Terminal-to-Web (`&` prefix)

```
& Fix the authentication bug in src/auth/login.ts
```

Or from the command line:

```bash
claude --remote "Fix the authentication bug in src/auth/login.ts"
```

Use `/tasks` to monitor. Each `&` command creates an independent parallel session.

#### Web-to-Terminal (Teleport)

| Method             | Command / Action                                         |
|:-------------------|:---------------------------------------------------------|
| Interactive picker | `/teleport` or `/tp` inside Claude Code                  |
| CLI                | `claude --teleport` or `claude --teleport <session-id>`  |
| From `/tasks`      | Press `t` to teleport into a session                     |
| Web UI             | Click "Open in CLI", paste command                       |

**Teleport requirements:** clean git state, correct repository (not a fork), branch pushed to remote, same Claude.ai account.

#### Cloud Environment

**Pre-installed:** Python 3.x, Node.js LTS, Ruby 3.3.6, PHP 8.4, Java (OpenJDK), Go, Rust, C++ (GCC/Clang). Databases: PostgreSQL 16, Redis 7.0. Run ` ` `check-tools` ` ` to see versions.

#### Network Access Levels

| Level     | Behavior                                          |
|:----------|:--------------------------------------------------|
| No internet | No outbound access (Anthropic API still reachable) |
| Limited   | Default allowlist of common domains                |
| Full      | Unrestricted internet access                       |

#### Dependency Management

Use SessionStart hooks to install packages (no custom images yet):

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/install_pkgs.sh"
      }]
    }]
  }
}
```

Guard with `if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi` to skip local environments.

#### Session Sharing

| Account type       | Visibility options  | Repo access verification |
|:-------------------|:--------------------|:-------------------------|
| Enterprise / Teams | Private, Team       | Enabled by default       |
| Max / Pro          | Private, Public     | Opt-in via settings      |

#### Security

- Isolated VMs per session
- GitHub operations through scoped credential proxy (push restricted to current branch)
- All outbound traffic through HTTP/HTTPS security proxy
- Git credentials never inside sandbox

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) -- CLI `-p` mode, structured output, streaming, tool auto-approval, session continuation, system prompt customization
- [Claude Code on the Web](references/claude-code-on-the-web.md) -- cloud sessions, teleport, diff review, environment configuration, network policies, allowed domains, security, sharing

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
