---
name: headless
description: Reference documentation for running Claude Code programmatically via CLI (`claude -p`) and on the web (claude.ai/code) — covers structured output, streaming, tool auto-approval, session continuation, cloud environments, network access, teleporting sessions, and CI/CD patterns.
user-invocable: false
---

# Headless & Cloud Execution

This skill covers two modes of non-interactive Claude Code execution: the CLI (`claude -p`, formerly "headless mode") and Claude Code on the web (cloud sessions via claude.ai/code).

## CLI (`claude -p`) Quick Reference

Pass `-p` (or `--print`) to run Claude Code non-interactively. All [CLI flags](references/claude-code-headless.md) work with `-p`.

### Output Formats

| Format          | Flag                              | Description                                    |
|:----------------|:----------------------------------|:-----------------------------------------------|
| Plain text      | `--output-format text` (default)  | Raw text response                              |
| JSON            | `--output-format json`            | Structured JSON with `result`, `session_id`    |
| Streaming JSON  | `--output-format stream-json`     | Newline-delimited JSON events in real time      |

#### Structured Output with JSON Schema

```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

Result is in `structured_output` field. Use `jq -r '.result'` to extract text, `jq '.structured_output'` for schema output.

#### Streaming Text Deltas

```bash
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### Auto-Approve Tools

Use `--allowedTools` with [permission rule syntax](references/claude-code-headless.md):

```bash
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"
```

Prefix matching with trailing ` *` (space-asterisk): `Bash(git diff *)` allows any command starting with `git diff`.

### Continue / Resume Conversations

| Pattern                       | Flag                          |
|:------------------------------|:------------------------------|
| Continue most recent session  | `--continue`                  |
| Resume a specific session     | `--resume <session_id>`       |

Capture session ID for later resumption:

```bash
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Customize System Prompt

| Flag                       | Effect                                  |
|:---------------------------|:----------------------------------------|
| `--append-system-prompt`   | Add instructions, keep default behavior |
| `--system-prompt`          | Fully replace the default prompt        |

```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

### Common Patterns

| Task            | Command                                                                                      |
|:----------------|:---------------------------------------------------------------------------------------------|
| Ask about code  | `claude -p "What does the auth module do?"`                                                  |
| Auto-commit     | `claude -p "Create a commit" --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"` |
| Code review     | `gh pr diff "$1" \| claude -p --append-system-prompt "Review for security issues" --output-format json` |

> **Note:** User-invoked skills (`/commit`, etc.) and built-in commands are only available in interactive mode. With `-p`, describe the task directly.

---

## Claude Code on the Web

Run Claude Code tasks asynchronously on Anthropic-managed cloud VMs at [claude.ai/code](https://claude.ai/code). Currently in **research preview**.

### Availability

Pro, Max, Team, and Enterprise users (Enterprise requires premium or Chat + Claude Code seats).

### How It Works

1. Repository is cloned to an isolated VM (default branch; specify another in the prompt)
2. Environment is prepared; hooks run (including SessionStart)
3. Network access configured per environment settings
4. Claude executes the task, writing code, running tests, iterating
5. Changes are pushed to a branch; you create a PR from the UI

### Moving Between Web and Terminal

| Direction           | Method                                                                 |
|:--------------------|:-----------------------------------------------------------------------|
| Terminal to web     | Prefix message with `&` in interactive mode, or `claude --remote "prompt"` |
| Web to terminal     | `/teleport` (or `/tp`), `claude --teleport`, `/tasks` then press `t`  |

#### Terminal to Web Tips

- **Plan locally, execute remotely:** Use `claude --permission-mode plan` to collaborate on strategy, then `& Execute the plan` to run in the cloud.
- **Parallel tasks:** Each `&` creates an independent web session. Monitor all with `/tasks`.

#### Teleport Requirements

| Requirement        | Details                                                        |
|:-------------------|:---------------------------------------------------------------|
| Clean git state    | No uncommitted changes (prompted to stash if needed)           |
| Correct repository | Must be same repo, not a fork                                  |
| Branch available   | Web session branch must be pushed to remote                    |
| Same account       | Same Claude.ai account as the web session                      |

### Cloud Environment

**Default image** includes: Python 3.x, Node.js LTS, Ruby 3.3.6, PHP 8.4, Java (OpenJDK), Go, Rust, C++ (GCC/Clang), PostgreSQL 16, Redis 7.0. Run `check-tools` to see versions.

#### Dependency Management

Use SessionStart hooks since custom images are not yet supported:

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

Guard against local execution with `if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then exit 0; fi`.

Persist env vars by writing to `$CLAUDE_ENV_FILE`.

### Network Access

| Level    | Description                                              |
|:---------|:---------------------------------------------------------|
| Limited  | Default. Allowlisted domains only (package registries, GitHub, cloud platforms, etc.) |
| Full     | Unrestricted internet access                             |
| None     | No internet (Anthropic API still reachable)              |

All traffic goes through a security proxy. GitHub operations use a dedicated proxy with scoped credentials; git push is restricted to the current branch.

**Proxy limitations:** Some tools (e.g., Bun) do not work correctly through the proxy.

### Security

- Each session runs in an isolated VM
- Git credentials and signing keys are never inside the sandbox
- Authentication handled via scoped credentials through a secure proxy

### Session Sharing

| Account type        | Visibility options     | Repo access check     |
|:--------------------|:-----------------------|:----------------------|
| Enterprise / Teams  | Private, Team          | Enabled by default    |
| Max / Pro           | Private, Public        | Opt-in via Settings   |

## Full Documentation

- [CLI / Headless Reference](references/claude-code-headless.md) -- `claude -p` usage, output formats, streaming, tool approval, session continuation, system prompt customization
- [Cloud / Web Reference](references/claude-code-on-the-web.md) -- web sessions, teleporting, cloud environments, network allowlists, security model, dependency management

## Sources

- CLI / Headless: https://code.claude.com/docs/en/headless.md
- Cloud / Web: https://code.claude.com/docs/en/cloud.md
