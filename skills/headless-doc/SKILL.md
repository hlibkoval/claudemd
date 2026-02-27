---
name: headless-doc
description: Reference documentation for running Claude Code non-interactively and in the cloud — the -p/--print flag (formerly "headless mode"), output formats (text, json, stream-json), structured output with JSON schemas, tool auto-approval, session continuation, system prompt customization, and Claude Code on the web (remote cloud execution via --remote, diff view, teleport, cloud environment setup, network access policy).
user-invocable: false
---

# Headless & Cloud Execution Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI and as cloud-based web sessions.

## Quick Reference

### Non-Interactive CLI (`-p` flag)

The `-p` / `--print` flag runs Claude Code non-interactively (formerly called "headless mode"). The underlying Agent SDK powers it.

```bash
# Basic usage
claude -p "What does the auth module do?"

# Structured JSON output
claude -p "Summarize this project" --output-format json

# Structured output with schema
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'

# Streaming output
claude -p "Explain recursion" --output-format stream-json --verbose --include-partial-messages

# Auto-approve tools
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"

# Scoped tool permissions (prefix matching with trailing space + *)
claude -p "Review staged changes and commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"

# Append system prompt
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json

# Continue most recent conversation
claude -p "Follow-up question" --continue

# Resume a specific session
session_id=$(claude -p "Start task" --output-format json | jq -r '.session_id')
claude -p "Continue task" --resume "$session_id"
```

### Output Formats

| Format        | Description                                              |
|:--------------|:---------------------------------------------------------|
| `text`        | Plain text (default)                                     |
| `json`        | JSON with `result`, `session_id`, metadata               |
| `stream-json` | Newline-delimited JSON events for real-time streaming    |

With `--json-schema`, the structured result is in the `structured_output` field of the JSON response.

### Skills and Built-in Commands in `-p` Mode

User-invoked skills (e.g. `/commit`) and built-in commands are only available in interactive mode. In `-p` mode, describe the task in plain language instead.

### Cloud Execution (`--remote`)

```bash
# Start a web session from the terminal
claude --remote "Fix the authentication bug in src/auth/login.ts"

# Run tasks in parallel (each --remote creates an independent session)
claude --remote "Fix the flaky test in auth.spec.ts"
claude --remote "Update the API documentation"

# Plan locally first, then execute remotely
claude --permission-mode plan    # explore + plan only (no writes)
claude --remote "Execute the migration plan in docs/migration-plan.md"

# Monitor background sessions
/tasks
```

### Teleport: Web to Terminal

| Method             | Command / Action                                          |
|:-------------------|:----------------------------------------------------------|
| Interactive picker | `/teleport` or `/tp` inside Claude Code                   |
| CLI picker         | `claude --teleport`                                       |
| Specific session   | `claude --teleport <session-id>`                          |
| From `/tasks`      | Press `t` on a session                                    |
| From web UI        | Click "Open in CLI"                                       |

Teleport requirements: clean git state, correct repo (not a fork), branch pushed to remote, same Claude.ai account.

Note: session handoff is one-way — web sessions can be pulled to terminal, but existing terminal sessions cannot be pushed to the web.

### Cloud Environment

| Language / Tool | Details                                             |
|:----------------|:----------------------------------------------------|
| Python          | 3.x, pip, poetry, common scientific libs            |
| Node.js         | Latest LTS, npm, yarn, pnpm, bun                    |
| Ruby            | 3.1.6 / 3.2.6 / 3.3.6 (default), bundler, rbenv    |
| PHP             | 8.4.14                                              |
| Java            | OpenJDK, Maven, Gradle                              |
| Go              | Latest stable, module support                       |
| Rust            | Cargo toolchain                                     |
| C++             | GCC and Clang                                       |
| PostgreSQL      | 16                                                  |
| Redis           | 7.0                                                 |

Run `check-tools` inside a session to list all pre-installed software.

### Dependency Installation via Hooks

Add a `SessionStart` hook in `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/install_pkgs.sh" }
        ]
      }
    ]
  }
}
```

Guard the script to skip local execution:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi
```

### Network Access Levels

| Level     | Description                                                     |
|:----------|:----------------------------------------------------------------|
| Limited   | Default — allowlisted domains only (npm, PyPI, GitHub, etc.)    |
| Full      | Unrestricted internet access                                    |
| None      | No internet (Anthropic API still allowed)                       |

Configure per environment in the web UI. All outbound traffic passes through a security proxy.

### Session Sharing

| Account type         | Visibility options        | Notes                                         |
|:---------------------|:--------------------------|:----------------------------------------------|
| Enterprise / Teams   | Private, Team             | Repo access verified by default               |
| Pro / Max            | Private, Public           | Repo access verification off by default       |

Settings > Claude Code > Sharing settings controls name visibility and access verification.

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code Programmatically](references/claude-code-headless.md) — `-p` flag, output formats, JSON schema, streaming, tool approval, session continuation, system prompts
- [Claude Code on the Web](references/claude-code-on-the-web.md) — remote cloud sessions, diff view, teleport, cloud environment, dependency management, network policy, security, sharing

## Sources

- Run Claude Code Programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the Web: https://code.claude.com/docs/en/claude-code-on-the-web.md
