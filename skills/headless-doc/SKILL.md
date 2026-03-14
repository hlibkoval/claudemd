---
name: headless-doc
description: Complete documentation for running Claude Code programmatically and on the web -- the Agent SDK CLI (`claude -p` headless mode, non-interactive execution, structured JSON output, stream-json, --json-schema, --output-format, --allowedTools permission rules, --append-system-prompt, --continue/--resume session continuation), Claude Code on the web (cloud sessions on claude.ai/code, GitHub integration, repository cloning, diff view, setup scripts, environment configuration, network access levels, default allowed domains, security proxy, session management, archiving/deleting sessions, session sharing visibility, --remote flag for terminal-to-web, --teleport/teleport for web-to-terminal, /tasks, /remote-env, plan mode, parallel remote tasks, cloud VM default image with pre-installed languages/runtimes/databases, SessionStart hooks vs setup scripts, dependency management, isolated VMs, credential protection, pricing and rate limits). Load when discussing running Claude Code non-interactively, headless mode, programmatic usage, `claude -p`, --print flag, structured output, JSON schema output, streaming responses, auto-approving tools, CI/CD scripting with Claude, system prompt customization, Agent SDK CLI, continuing conversations programmatically, session IDs, Claude Code on the web, cloud sessions, remote sessions, --remote, --teleport, /teleport, /tp, session handoff, web-to-terminal, terminal-to-web, setup scripts for cloud environments, cloud environment configuration, network access policies, allowed domains, security proxy, session sharing, diff view, creating PRs from web, cloud VM image, check-tools, or running parallel tasks on the web.
user-invocable: false
---

# Headless & Web Documentation

This skill provides the complete official documentation for running Claude Code programmatically via the CLI (headless mode / Agent SDK) and using Claude Code on the web (cloud sessions).

## Quick Reference

### Agent SDK CLI (`claude -p`)

Run Claude Code non-interactively by passing `-p` (or `--print`) with a prompt. All CLI options work with `-p`. Previously called "headless mode."

| Flag | Purpose |
|:-----|:--------|
| `-p "prompt"` / `--print "prompt"` | Run non-interactively, print response |
| `--output-format text\|json\|stream-json` | Control response format (default: `text`) |
| `--json-schema '{...}'` | Constrain output to JSON Schema (use with `--output-format json`) |
| `--allowedTools "Tool1,Tool2"` | Auto-approve specific tools without prompting |
| `--append-system-prompt "..."` | Add instructions while keeping defaults |
| `--system-prompt "..."` | Fully replace the default system prompt |
| `--continue` | Continue the most recent conversation |
| `--resume <session-id>` | Continue a specific conversation by session ID |
| `--verbose` | Include verbose event data (useful with `stream-json`) |
| `--include-partial-messages` | Stream tokens as they generate (with `stream-json`) |

#### Output Formats

| Format | Description |
|:-------|:------------|
| `text` | Plain text output (default) |
| `json` | Structured JSON with `result`, `session_id`, metadata; schema output in `structured_output` field |
| `stream-json` | Newline-delimited JSON events for real-time streaming |

#### Tool Auto-Approval Patterns

`--allowedTools` uses permission rule syntax. The trailing ` *` enables prefix matching (space before `*` is important).

| Pattern | Matches |
|:--------|:--------|
| `Bash` | All Bash commands |
| `Bash(git diff *)` | Any command starting with `git diff ` |
| `Read,Edit` | Read and Edit tools |

#### Common CLI Patterns

**Structured JSON output with schema:**
```
claude -p "Extract function names" --output-format json --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}'
```

**Streaming text deltas (with jq):**
```
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

**Capture session ID for multi-turn:**
```
session_id=$(claude -p "Start review" --output-format json | jq -r '.session_id')
claude -p "Continue review" --resume "$session_id"
```

**Create a commit with scoped permissions:**
```
claude -p "Create a commit from staged changes" --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

**PR review pipeline:**
```
gh pr diff "$1" | claude -p --append-system-prompt "You are a security engineer. Review for vulnerabilities." --output-format json
```

User-invoked skills (like `/commit`) and built-in commands are only available in interactive mode. In `-p` mode, describe the task instead.

### Claude Code on the Web

Cloud sessions run on Anthropic-managed VMs. Available to Pro, Max, Team, and Enterprise users. Currently in research preview.

#### Session Lifecycle

1. Repository cloned to an Anthropic-managed VM (default branch; specify a different branch in the prompt)
2. Setup script runs (if configured)
3. Network access configured per environment settings
4. Claude executes the task, writing code, running tests, checking work
5. Changes pushed to a branch for PR creation

#### Terminal-to-Web (`--remote`)

```
claude --remote "Fix the auth bug in src/auth/login.ts"
```

Creates a new web session on claude.ai. Monitor with `/tasks`. Each `--remote` creates an independent session -- run multiple in parallel.

**Plan-then-execute pattern:**
```
claude --permission-mode plan        # Collaborate on approach (read-only)
claude --remote "Execute the plan"   # Send work to cloud
```

Use `/remote-env` to select which environment to use when starting web sessions (if you have multiple configured).

#### Web-to-Terminal (Teleport)

| Method | Usage |
|:-------|:------|
| `/teleport` or `/tp` | Interactive picker from within Claude Code |
| `claude --teleport` | Interactive picker from command line |
| `claude --teleport <session-id>` | Resume specific session directly |
| `/tasks` then press `t` | Teleport from task list |
| Web UI "Open in CLI" | Copy command to paste in terminal |

**Teleport requirements:** clean git state (no uncommitted changes), correct repository (not a fork), branch pushed to remote, same Claude.ai account.

#### Session Sharing

| Account type | Visibility options | Notes |
|:-------------|:-------------------|:------|
| Enterprise / Teams | Private, Team | Team = visible to org members; repo access verification on by default |
| Max / Pro | Private, Public | Public = visible to any logged-in claude.ai user; check for sensitive content before sharing |

#### Diff View

When Claude modifies files, a diff stats indicator (e.g., `+12 -1`) appears. Select it to review changes file-by-file, comment on changes, and iterate before creating a PR.

#### Cloud Environment

**Default image includes:**

| Category | Included |
|:---------|:---------|
| Languages | Python 3.x, Node.js (LTS), Ruby 3.1/3.2/3.3, PHP 8.4, Java (OpenJDK), Go, Rust, C++ (GCC/Clang) |
| Package managers | pip, poetry, npm, yarn, pnpm, bun, gem, bundler, Maven, Gradle, cargo |
| Databases | PostgreSQL 16, Redis 7.0 |
| Discovery | Run `check-tools` to see all pre-installed tools |

**Environment configuration:** Add/update environments from the environment selector UI. Each environment has: name, network access level, environment variables (`.env` format), and a setup script.

#### Setup Scripts

Bash scripts that run before Claude Code launches on new sessions only. Run as root on Ubuntu 24.04.

| | Setup Scripts | SessionStart Hooks |
|:--|:-------------|:-------------------|
| Attached to | Cloud environment | Repository (`.claude/settings.json`) |
| Runs | Before Claude Code, new sessions only | After Claude Code, every session (including resumed) |
| Scope | Cloud only | Both local and cloud |

If a setup script exits non-zero, the session fails to start. Append `|| true` to non-critical commands.

#### Network Access

| Level | Behavior |
|:------|:---------|
| Limited (default) | Allowlisted domains only (package registries, cloud platforms, dev tools) |
| Full | Unrestricted internet access |
| None | No internet (Anthropic API still reachable) |

All outbound traffic passes through a security proxy. Some package managers (e.g., Bun) may not work correctly with the proxy.

Default allowlisted domain categories: Anthropic services, version control (GitHub/GitLab/Bitbucket), container registries, cloud platforms (GCP/Azure/AWS/Oracle), package managers (npm/PyPI/RubyGems/crates.io/Go/Maven/Gradle/Packagist/NuGet/pub.dev/Hex/CPAN/CocoaPods/Haskell/Swift), Linux distros (Ubuntu), development tools (Kubernetes/HashiCorp/Anaconda/Apache/Eclipse/Node.js), monitoring (Statsig/Sentry/Datadog), CDNs, schema registries, and Model Context Protocol.

#### Dependency Management

Use setup scripts for cloud-only dependencies. Use SessionStart hooks for dependencies that should also install locally. Check `CLAUDE_CODE_REMOTE` env var to scope hooks to remote-only.

Persist environment variables for subsequent Bash commands by writing to `$CLAUDE_ENV_FILE` in SessionStart hooks.

#### Security

- Isolated VMs per session
- Git credentials handled through secure proxy with scoped credentials (never inside sandbox)
- Network access controls (configurable per environment)
- Push restricted to current working branch

#### Limitations

- Repository auth: same account for web-to-local session transfer
- GitHub only (no GitLab or other hosts for cloud sessions)
- Rate limits shared with all Claude/Claude Code usage on the account

## Full Documentation

For the complete official documentation, see the reference files:

- [Run Claude Code programmatically](references/claude-code-headless.md) -- Agent SDK CLI overview, basic `-p` usage, structured output (`--output-format json`, `--json-schema`), streaming responses (`stream-json` with `--verbose` and `--include-partial-messages`, jq filtering for text deltas), auto-approving tools (`--allowedTools` with permission rule syntax and prefix matching), creating commits with scoped tool permissions, customizing system prompts (`--append-system-prompt`, `--system-prompt`), continuing conversations (`--continue`, `--resume` with session ID capture), links to full Agent SDK (Python/TypeScript), CLI reference, GitHub Actions, GitLab CI/CD
- [Claude Code on the web](references/claude-code-on-the-web.md) -- cloud session overview and use cases, availability (Pro/Max/Team/Enterprise), getting started with GitHub, session lifecycle (clone, setup, network, execute, PR), diff view for reviewing changes, terminal-to-web (`--remote`, plan-then-execute, parallel tasks), web-to-terminal (`--teleport`, `/teleport`, `/tp`, `/tasks`), teleport requirements, session sharing (visibility levels by account type, repo access verification), managing sessions (archiving, deleting), cloud environment (default image with languages/databases, `check-tools`, language-specific setups), environment configuration (add/update environments, env vars in `.env` format, `/remote-env`), setup scripts (vs SessionStart hooks comparison, root on Ubuntu 24.04), dependency management (setup scripts vs hooks, `CLAUDE_CODE_REMOTE` check, `CLAUDE_ENV_FILE`, known limitations including proxy compatibility), network access levels (limited/full/none), default allowed domains (full list by category), security proxy, GitHub proxy with scoped credentials, security and isolation (isolated VMs, credential protection), pricing and rate limits, platform limitations

## Sources

- Run Claude Code programmatically: https://code.claude.com/docs/en/headless.md
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web.md
