---
name: headless-doc
description: Complete documentation for running Claude Code programmatically (Agent SDK CLI) and Claude Code on the web — the `-p` flag, structured output formats (text/json/stream-json), `--json-schema` for typed responses, `--allowedTools` with permission rule syntax, `--continue`/`--resume` for multi-turn sessions, `--append-system-prompt`/`--system-prompt` for prompt customization, `--remote` for cloud sessions, `--teleport` for pulling web sessions to terminal, cloud environment setup (default image, setup scripts, network policies, allowed domains), session sharing, diff view, and security isolation. Load when discussing headless mode, `-p` flag, programmatic CLI usage, Agent SDK CLI, `--remote`, cloud sessions, web sessions, teleporting sessions, setup scripts, cloud environments, or non-interactive Claude Code execution.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (`-p` flag / Agent SDK) and for Claude Code on the web (cloud sessions).

## Quick Reference

### Programmatic CLI (`-p` flag)

The `-p` (or `--print`) flag runs Claude Code non-interactively. All CLI options work with `-p`. The Agent SDK also offers Python and TypeScript packages for full programmatic control with structured outputs, tool approval callbacks, and native message objects.

#### Output Formats

| Format | Flag | Description |
|:-------|:-----|:------------|
| `text` | `--output-format text` (default) | Plain text output |
| `json` | `--output-format json` | Structured JSON with `result`, `session_id`, and metadata |
| `stream-json` | `--output-format stream-json` | Newline-delimited JSON for real-time streaming |

Use `--json-schema` with `--output-format json` to get typed structured output in the `structured_output` field.

#### Key Flags for `-p` Mode

| Flag | Purpose |
|:-----|:--------|
| `--allowedTools "Bash,Read,Edit"` | Auto-approve specific tools without prompting |
| `--continue` | Continue the most recent conversation |
| `--resume <session_id>` | Continue a specific conversation by session ID |
| `--append-system-prompt <text>` | Add instructions while keeping default behavior |
| `--system-prompt <text>` | Fully replace the default system prompt |
| `--json-schema '<schema>'` | Enforce structured output conforming to a JSON Schema |
| `--verbose` | Include extra metadata in streaming output |
| `--include-partial-messages` | Stream tokens as they are generated (with `stream-json`) |

#### Allowed Tools Syntax

Uses permission rule syntax. Trailing ` *` enables prefix matching (the space before `*` is important):

```
Bash(git diff *)   -- allows any command starting with "git diff "
Bash(git diff*)    -- would also match "git diff-index" (usually not intended)
```

#### Common Patterns

**Structured output with schema:**
```bash
claude -p "Extract function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

**Multi-turn conversation:**
```bash
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

**Streaming text deltas with jq:**
```bash
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

**Custom system prompt for code review:**
```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

User-invoked skills (e.g. `/commit`) and built-in commands are only available in interactive mode. In `-p` mode, describe the task directly instead.

### Claude Code on the Web

Claude Code on the web runs tasks asynchronously on Anthropic-managed cloud VMs. Available in research preview to Pro, Max, Team, and Enterprise users.

#### Session Lifecycle

1. Repository cloned to an isolated VM
2. Setup script runs (if configured)
3. Network access configured per environment settings
4. Claude executes the task (can be steered via the web interface)
5. Changes pushed to a branch; PR can be created from the diff view

#### Terminal-Web Handoff

| Direction | Command | Notes |
|:----------|:--------|:------|
| Terminal to web | `claude --remote "Fix the bug"` | Creates a new cloud session; monitor via `/tasks` |
| Web to terminal | `claude --teleport` or `/teleport` | Interactive picker of web sessions |
| Web to terminal (specific) | `claude --teleport <session-id>` | Resume a specific session |
| From `/tasks` | Press `t` on a session | Teleport into that session |

Session handoff is one-way: you can pull web sessions into your terminal, but not push existing terminal sessions to the web. `--remote` always creates a new session.

**Teleport requirements:** clean git state (no uncommitted changes), correct repository (not a fork), branch pushed to remote, same Claude.ai account.

#### Plan Locally, Execute Remotely

```bash
claude --permission-mode plan           # read-only exploration
claude --remote "Execute the plan in docs/migration-plan.md"
```

#### Parallel Remote Tasks

Each `--remote` creates an independent cloud session:

```bash
claude --remote "Fix the flaky test in auth.spec.ts"
claude --remote "Update the API documentation"
claude --remote "Refactor the logger to use structured output"
```

#### Environment Selection

Use `/remote-env` to choose which configured environment `--remote` uses.

#### Cloud Environment

**Default image includes:** Python 3.x (pip, poetry), Node.js LTS (npm, yarn, pnpm, bun), Ruby 3.1/3.2/3.3, PHP 8.4, Java (Maven, Gradle), Go, Rust (cargo), C++ (GCC, Clang), PostgreSQL 16, Redis 7.0.

Run `check-tools` inside a cloud session to see all pre-installed tools and versions.

#### Setup Scripts

Bash scripts that run before Claude Code launches on new sessions only. Configured in the environment settings UI. Run as root on Ubuntu 24.04.

| Property | Setup scripts | SessionStart hooks |
|:---------|:-------------|:-------------------|
| Attached to | Cloud environment | Repository (`.claude/settings.json`) |
| Runs | Before Claude Code, new sessions only | After Claude Code, every session (including resumed) |
| Scope | Cloud only | Both local and cloud |

Setup scripts that install packages need network access (at least "Limited").

#### Network Access Levels

| Level | Behavior |
|:------|:---------|
| Limited (default) | Connections allowed to an allowlist of common domains |
| Full | Unrestricted internet access |
| No internet | All outbound blocked (Anthropic API still reachable) |

The default allowlist covers: Anthropic services, GitHub/GitLab/Bitbucket, Docker registries, major cloud platforms (AWS, GCP, Azure), package managers for JS/Python/Ruby/Rust/Go/JVM/PHP/.NET/Dart/Elixir/Perl/Swift/Haskell, Ubuntu repos, Kubernetes, HashiCorp, Conda, Apache, and common CDNs.

All outbound traffic passes through a security proxy. Some package managers (e.g. Bun) may not work correctly with this proxy.

#### Dependency Management

Use setup scripts or SessionStart hooks. SessionStart hooks fire in both local and remote environments; check `$CLAUDE_CODE_REMOTE` to skip local execution. Persist environment variables by writing to `$CLAUDE_ENV_FILE` in SessionStart hooks.

#### Session Sharing

| Account type | Visibility options | Repo access verification |
|:-------------|:-------------------|:------------------------|
| Enterprise / Teams | Private, Team | Enabled by default |
| Max / Pro | Private, Public | Off by default (configurable in Settings) |

#### Security

- Each session runs in an isolated VM
- Git operations go through a dedicated proxy with scoped credentials
- Push restricted to current working branch
- Sensitive credentials are never inside the sandbox

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- `-p` flag basics, structured output (`json`, `stream-json`, `--json-schema`), streaming responses, `--allowedTools` with permission rule syntax, commit creation pattern, system prompt customization, multi-turn conversations (`--continue`, `--resume`), Agent SDK pointers
- [Claude Code on the web](references/claude-code-on-the-web.md) -- cloud session lifecycle, diff view, `--remote` flag, `--teleport` / `/teleport`, parallel tasks, session sharing, cloud environment (default image, languages, databases), setup scripts vs SessionStart hooks, network access levels, default allowed domains, security proxy, dependency management, security and isolation, pricing, limitations

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
