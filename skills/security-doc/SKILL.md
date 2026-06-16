---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, sandboxing, dev containers, network configuration, data usage and retention, legal compliance, zero data retention, sandbox environment comparison, and the security-guidance plugin. Use when working with security controls, isolation boundaries, enterprise network setup, data policies, ZDR, or the in-session vulnerability review plugin.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security.

## Quick Reference

### Security architecture overview

| Layer | What it controls | Configured via |
| :--- | :--- | :--- |
| Permission system | Which tools run and whether prompts appear | `settings.json` permission rules, permission modes |
| Sandboxed Bash tool | Filesystem and network access of Bash commands | `/sandbox`, `sandbox.*` settings keys |
| Dev container / VM | Full process isolation including file tools, MCP, hooks | `.devcontainer/`, Docker, external VM |
| Sandbox runtime | Whole Claude Code process (no Docker required) | `~/.srt-settings.json`, `npx @anthropic-ai/sandbox-runtime` |
| Security guidance plugin | In-session vulnerability review of code Claude writes | `/plugin install security-guidance@claude-plugins-official` |

### Built-in protections (always active)

| Protection | Description |
| :--- | :--- |
| Write scope restriction | Claude Code can only write inside the working directory without explicit permission |
| Accept Edits mode | Auto-approves file edits and safe filesystem commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) in working directory |
| Prompt fatigue mitigation | Allowlisting of safe commands per-user, per-project, or per-org |
| Network command approval | `curl`, `wget`, and similar commands are not auto-approved by default |
| Isolated WebFetch context | Web fetch uses a separate context window to reduce prompt injection risk |
| Trust verification | First-time codebases and new MCP servers require explicit trust |
| Command injection detection | Suspicious commands prompt even if previously allowlisted |
| Fail-closed matching | Unmatched commands default to requiring approval |
| Credential storage | API keys stored in macOS Keychain or protected by file permissions on other platforms |

### Sandbox environments comparison

| Approach | What is isolated | Requires Docker | Setup effort |
| :--- | :--- | :--- | :--- |
| Sandboxed Bash tool | Bash commands and child processes only | No | Minimal (macOS) / Low (Linux/WSL2) |
| Sandbox runtime | Whole Claude Code process (tools, MCP, hooks) | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium–High |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, Anthropic-hosted | No | None (requires subscription + GitHub) |

### Sandboxed Bash tool — key settings

| Setting | Type | Description |
| :--- | :--- | :--- |
| `sandbox.enabled` | boolean | Enable the sandbox |
| `sandbox.failIfUnavailable` | boolean | Hard failure if sandbox cannot start (recommended for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | boolean | Whether commands can fall back outside the sandbox (set `false` for strict mode) |
| `sandbox.filesystem.allowWrite` | array | Additional paths Bash subprocesses may write to |
| `sandbox.filesystem.denyWrite` | array | Paths to block writing |
| `sandbox.filesystem.denyRead` | array | Paths to block reading (note: `~/.aws/credentials`, `~/.ssh/` are readable by default) |
| `sandbox.filesystem.allowRead` | array | Re-allow reading within a `denyRead` region |
| `sandbox.network.allowedDomains` | array | Pre-approved network domains (avoids per-domain prompts) |
| `sandbox.network.deniedDomains` | array | Block specific domains even when a wildcard `allowedDomains` would permit them |
| `sandbox.allowManagedDomainsOnly` | boolean | Managed settings only — block all domains not in managed `allowedDomains` |
| `sandbox.allowManagedReadPathsOnly` | boolean | Managed settings only — ignore user/project `allowRead` entries |
| `sandbox.excludedCommands` | array | Commands that always run outside the sandbox |
| `sandbox.network.httpProxyPort` | number | Custom proxy HTTP port |
| `sandbox.network.socksProxyPort` | number | Custom proxy SOCKS port |
| `sandbox.enableWeakerNestedSandbox` | boolean | Allow sandbox inside Docker (weakens isolation) |
| `sandbox.enableWeakerNetworkIsolation` | boolean | For MITM proxy + custom CA scenarios on macOS |

### Sandbox modes

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without prompting; unsandboxed fallbacks go through normal permission flow |
| Regular permissions | All commands prompt even when sandboxed |

### Sandbox OS support

| Platform | Technology | Notes |
| :--- | :--- | :--- |
| macOS | Seatbelt (built-in) | No install needed |
| Linux | bubblewrap + socat | `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) |
| WSL2 | bubblewrap + socat | Same as Linux; check `wsl -l -v` for WSL version |
| Native Windows | Not supported | Use WSL2 or a container |

### Linux/WSL2 sandbox setup

```bash
# Ubuntu/Debian
sudo apt-get install bubblewrap socat

# Fedora
sudo dnf install bubblewrap socat

# Optional: seccomp filter for Unix socket blocking
npm install -g @anthropic-ai/sandbox-runtime
```

On Ubuntu 24.04+, AppArmor may block bubblewrap user namespaces. Check with `sysctl kernel.apparmor_restrict_unprivileged_userns` and add a profile if the value is `1`.

### Dev container quick setup

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

Persist credentials across rebuilds with a named volume at `~/.claude`:

```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

Run without permission prompts inside a container (non-root user required):

```
--dangerously-skip-permissions
```

Enforce org policy via `/etc/claude-code/managed-settings.json` inside the container (copied from Dockerfile).

### Network access requirements (allowlist for proxies/firewalls)

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console account authentication |
| `downloads.claude.ai` | Plugin downloads, native installer/auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed, release notes, plugin install counts |

### Enterprise network configuration

| Config | Env var / setting | Notes |
| :--- | :--- | :--- |
| HTTPS proxy | `HTTPS_PROXY=https://proxy.example.com:8080` | Recommended |
| HTTP proxy | `HTTP_PROXY=http://proxy.example.com:8080` | Fallback |
| Bypass proxy | `NO_PROXY="localhost,example.com"` | Space or comma separated |
| CA certificate store | `CLAUDE_CODE_CERT_STORE=bundled,system` | Default; accepts `bundled`, `system`, or both |
| Custom CA cert | `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem` | |
| mTLS client cert | `CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem` | |
| mTLS client key | `CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem` | |
| mTLS passphrase | `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="passphrase"` | |

Note: SOCKS proxies are not supported. All env vars can also be set in `settings.json`.

### Data usage and retention

| User type | Training | Retention (default) | Can change? |
| :--- | :--- | :--- | :--- |
| Consumer (Free/Pro/Max) | Opt-in (can disable at claude.ai/settings/data-privacy-controls) | 5 years if training on; 30 days if off | Yes |
| Commercial (Team/Enterprise/API) | No (unless Development Partner Program opt-in) | 30 days | Contact account team |
| ZDR (Enterprise) | No | Not retained (real-time only) | No (always ZDR) |

Feedback via `/feedback`: 5-year retention. Session quality survey: rating only, no transcripts unless you select Yes on the optional follow-up.

### Telemetry opt-outs

| Service | Default (Claude API) | Opt-out |
| :--- | :--- | :--- |
| Anthropic metrics | On | `DISABLE_TELEMETRY=1` |
| Sentry error reporting | On | `DISABLE_ERROR_REPORTING=1` |
| `/feedback` reports | On | `DISABLE_FEEDBACK_COMMAND=1` |
| Session quality surveys | On | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| All non-essential traffic | — | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` |
| WebFetch domain safety check | On (all providers) | `skipWebFetchPreflight: true` in settings |

Bedrock, Vertex, Foundry, and Claude Platform on AWS default metrics and error reporting to **off**.

### Zero data retention (ZDR)

- Available to qualified accounts on Claude for Enterprise only; not included in standard plan
- Covers: Claude Code inference (terminal prompts and responses)
- Does not cover: claude.ai chat, Cowork, Analytics contribution metrics, user/seat management, third-party integrations
- Features disabled under ZDR: Claude Code on the web, cloud sessions from Desktop app, `/feedback` submission
- Model availability: Claude Fable 5 is not available under ZDR; the `best` alias resolves to Opus for ZDR orgs
- Per-org enablement: each new org requires separate activation by Anthropic account team
- To request: contact sales or your Anthropic account team

### Legal and compliance

| Topic | Details |
| :--- | :--- |
| Commercial users | Covered by Commercial Terms of Service |
| Consumer users | Covered by Consumer Terms of Service |
| Healthcare (BAA) | BAA extends to Claude Code when customer has both a BAA and ZDR enabled; ZDR required per org |
| Authentication | OAuth tokens for subscription plan users; API keys for developers building on Claude |
| Third-party providers | Existing commercial agreement (Bedrock/Vertex) applies to Claude Code usage |
| Security reporting | Report via HackerOne (link in reference docs); do not disclose publicly |

### Security guidance plugin — review layers

| Layer | Trigger | Cost | What it catches |
| :--- | :--- | :--- | :--- |
| Per-edit pattern check | Every file write by Claude | None (no model call) | `eval`, `pickle`, `innerHTML`, `.github/workflows/` edits, custom patterns |
| End-of-turn diff review | After each Claude turn | Model usage | Authorization bypass, injection, SSRF, weak crypto, insecure object references |
| Commit/push review | When Claude runs `git commit` or `git push` | Model usage (agentic, capped 20/hr) | Deep review with surrounding code context; reduces false positives |

Install the plugin:

```
/plugin install security-guidance@claude-plugins-official
/reload-plugins
```

To enable in cloud sessions or for everyone on a project, add to `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true
  }
}
```

### Security guidance plugin — extension points

| File | Scope | Purpose |
| :--- | :--- | :--- |
| `.claude/claude-security-guidance.md` | Project | Guidance in plain language for model-backed reviews (up to 8 KB combined) |
| `~/.claude/claude-security-guidance.md` | User | Applies to every project on the machine |
| `.claude/security-patterns.yaml` | Project | Custom regex/substring rules for the per-edit pattern check (up to 50 rules) |

Custom pattern fields: `rule_name`, `reminder` (capped 1 KB), `regex` or `substrings`, optional `paths` and `exclude_paths` (glob, prefix with `**/` for project-relative).

### Security guidance plugin — disable layers

| Env var | Effect |
| :--- | :--- |
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn diff review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit/push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable plugin entirely |
| `SECURITY_REVIEW_MODEL` | Override model for end-of-turn review |
| `SG_AGENTIC_MODEL` | Override model for commit review |

### Prompt injection protections

- Permission system requires approval for sensitive operations
- Context-aware analysis detects potentially harmful instructions
- Input sanitization prevents command injection
- Network commands (`curl`, `wget`) not auto-approved
- WebFetch uses an isolated context window
- First-run trust verification for codebases and MCP servers
- Command injection detection flags suspicious commands even if allowlisted

### Security best practices

**Working with sensitive code**: review all changes before approval; use project-specific permissions; consider dev containers; audit permissions with `/permissions`.

**Team security**: use managed settings to enforce org standards; version-control approved permission configs; monitor with OpenTelemetry; audit or block settings changes with `ConfigChange` hooks.

**Prompt injection**: review suggested commands; avoid piping untrusted content; verify changes to critical files; use VMs for scripts interacting with external services; report suspicious behavior with `/feedback`.

**Cloud sessions (Claude Code on the web)**: isolated VMs per session; network access limited and configurable; Git push restricted to current branch; automatic cleanup on session end.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Permission architecture, prompt injection protections, MCP security, cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — Sandboxed Bash tool: modes, filesystem/network isolation, settings reference, org enforcement, custom proxy, troubleshooting, limitations
- [Development containers](references/claude-code-devcontainer.md) — Installing Claude Code in dev containers, persisting auth, enforcing org policy, network egress restriction, running without prompts, reference container
- [Enterprise network configuration](references/claude-code-network-config.md) — Proxy setup, CA certificates, mTLS, network access requirements, GitHub Enterprise allowlisting
- [Data usage](references/claude-code-data-usage.md) — Training policies, feedback data, session surveys, retention periods, telemetry services, WebFetch domain safety check, data flow diagrams
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — License terms, commercial agreements, healthcare BAA, usage policy, authentication rules, Trust Center
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, covered vs. excluded features, disabled features, model availability, how to request
- [Sandbox environments](references/claude-code-sandbox-environments.md) — Comparing all isolation approaches, choosing by goal, enforcement across an org, how isolation relates to permission modes
- [Security guidance plugin](references/claude-code-security-guidance.md) — In-session vulnerability review: per-edit patterns, end-of-turn and commit reviews, custom rules, usage cost, disabling layers, integration with hooks

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Sandbox environments: https://code.claude.com/docs/en/sandbox-environments.md
- Security guidance plugin: https://code.claude.com/docs/en/security-guidance.md
