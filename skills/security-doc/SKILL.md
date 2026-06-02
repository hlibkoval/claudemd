---
name: security-doc
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security: the core security model, sandboxed Bash tool, sandbox environments, dev containers, network configuration, data usage, zero data retention, legal compliance, and the security-guidance plugin.

## Quick Reference

### Core Security Architecture

| Layer | What it controls | Applies to |
|:------|:----------------|:-----------|
| Permission rules | Which tools can run and whether you're prompted | All tools (Bash, Read, Edit, WebFetch, MCP) |
| Sandboxed Bash tool | Filesystem and network access of Bash commands | Bash commands and child processes only |
| Sandbox runtime (`@anthropic-ai/sandbox-runtime`) | Entire Claude Code process including MCP servers and hooks | Everything in the session |
| Dev container / custom container | Full development environment | All tools, network, host filesystem |
| Virtual machine | Full OS-level isolation | Complete separation from host |
| Cloud execution (Claude Code on the web) | Anthropic-managed VM per session | No local setup required |

### Permission-Based Architecture

- Default: read-only. Write/execute requires explicit approval.
- `/sandbox` enables the sandboxed Bash tool (macOS: Seatbelt; Linux/WSL2: bubblewrap + socat).
- `--dangerously-skip-permissions` removes all per-action review — always run inside a container, VM, or sandbox runtime.
- Auto mode uses a classifier to review actions; not an isolation boundary.
- Protected paths: removing `/` or home directory still prompts even with `--dangerously-skip-permissions`.

### Sandboxed Bash Tool

| Setting | Default | Notes |
|:--------|:--------|:------|
| `sandbox.enabled` | `false` | Enable via `/sandbox` or settings |
| `sandbox.failIfUnavailable` | `false` | Set `true` to hard-fail if sandbox cannot start |
| `sandbox.allowUnsandboxedCommands` | `true` | Set `false` for strict mode (no escape hatch) |
| `sandbox.filesystem.allowWrite` | `[]` | Extra writable paths (merged across scopes) |
| `sandbox.filesystem.denyWrite` | `[]` | Block write to specific paths |
| `sandbox.filesystem.denyRead` | `[]` | Block read from specific paths |
| `sandbox.filesystem.allowRead` | `[]` | Re-allow reads within a denyRead region |
| `sandbox.allowedDomains` | none | Pre-allowed network domains (avoids prompts) |
| `sandbox.deniedDomains` | none | Blocked domains even within a wildcard allow |
| `sandbox.allowManagedDomainsOnly` | `false` | Locks network to managed-settings domains only |
| `sandbox.allowManagedReadPathsOnly` | `false` | Locks read allowlist to managed-settings only |
| `sandbox.excludedCommands` | `[]` | Commands that always run outside the sandbox |
| `sandbox.allowUnixSockets` | `false` | Allow Unix socket access (use with caution) |
| `sandbox.network.httpProxyPort` | — | Custom proxy port for HTTP |
| `sandbox.network.socksProxyPort` | — | Custom proxy port for SOCKS |
| `sandbox.enableWeakerNestedSandbox` | `false` | For unprivileged containers; weakens isolation |
| `sandbox.enableWeakerNetworkIsolation` | `false` | For MITM proxy + HTTPS; weakens network isolation |

**Filesystem defaults:** read everywhere (except blocked paths); write only in working directory.
**Network defaults:** no pre-allowed domains; prompts on each new domain.

**Modes:**
- **Auto-allow**: sandboxed commands run without prompting; unsandboxed fallback goes through regular permission flow.
- **Regular permissions**: all Bash commands prompt even when sandboxed.

**Platform support:** macOS, Linux, WSL2. Native Windows not supported.

**Linux/WSL2 setup:**
```bash
sudo apt-get install bubblewrap socat   # Ubuntu/Debian
sudo dnf install bubblewrap socat       # Fedora
```

**Managed settings enforcement example:**
```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false
  }
}
```

### Sandbox Environments Comparison

| Approach | What is isolated | Requires Docker | Setup effort |
|:---------|:----------------|:----------------|:-------------|
| Sandboxed Bash tool | Bash commands and child processes | No | Minimal (macOS) / Low (Linux/WSL2) |
| Sandbox runtime | Entire Claude Code process | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium–High |
| Virtual machine | Full OS | No | High |
| Claude Code on the web | Full OS, Anthropic-hosted | No | None |

**Choosing an approach:**

| Goal | Use |
|:-----|:----|
| Reduce prompts during everyday work | Sandboxed Bash tool (`/sandbox`) |
| Unattended `--dangerously-skip-permissions` | Dev container, container/VM, or sandbox runtime |
| Isolate MCP servers + hooks without Docker | Sandbox runtime |
| Work on untrusted repository | Dedicated VM or Claude Code on the web |
| Standardize across a team | Dev container committed to repository |

### Dev Container Setup

Install via the [Claude Code Dev Container Feature](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code):

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

**Persist auth across rebuilds** (mount a named volume at `~/.claude`):
```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

**Enforce organization policy** (highest-precedence managed settings on Linux):
Place `managed-settings.json` at `/etc/claude-code/managed-settings.json` via Dockerfile.

**Disable telemetry and auto-update** in `containerEnv`:
```json
"containerEnv": {
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
  "DISABLE_AUTOUPDATER": "1"
}
```

**Run without prompts:** use `--dangerously-skip-permissions` (non-root only); pair with network egress restrictions.

### Network Configuration

**Proxy environment variables:**
| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass list (space- or comma-separated, or `*`) |

Note: SOCKS proxies are not supported.

**CA certificates:**
| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_CERT_STORE` | `bundled`, `system`, or `bundled,system` (default) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA PEM |

**mTLS:**
| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate PEM |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key PEM |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Optional passphrase for encrypted key |

**Required network allowlist:**

| URL | Required for |
|:----|:-------------|
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads and auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension |
| `raw.githubusercontent.com` | Changelog feed and release notes |

When using Bedrock/Vertex/Foundry, model traffic routes to those providers instead of `api.anthropic.com`. WebFetch still calls `api.anthropic.com` for its domain safety check unless `skipWebFetchPreflight: true` is set.

### Data Usage and Telemetry

**Training policies:**
- Consumer (Free/Pro/Max): data used for training when opt-in is on (changeable at claude.ai/settings/data-privacy-controls)
- Commercial (Team/Enterprise/API): Anthropic does not train on your data unless explicitly opted in (e.g., Developer Partner Program)

**Data retention:**
| Account type | Retention | Notes |
|:-------------|:----------|:------|
| Consumer (training on) | 5 years | Model development |
| Consumer (training off) | 30 days | |
| Commercial standard | 30 days | |
| Commercial ZDR | Not retained | Enterprise only, per-org enablement |
| Local session transcripts | 30 days | `~/.claude/projects/`; adjust with `cleanupPeriodDays` |
| `/feedback` transcripts | 5 years | |
| Session quality survey transcripts | Up to 6 months | Only when you select "Yes" |

**Telemetry opt-out environment variables:**
| Variable | Effect |
|:---------|:-------|
| `DISABLE_TELEMETRY=1` | Disable operational metrics (Anthropic) |
| `DISABLE_ERROR_REPORTING=1` | Disable Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable all non-essential traffic at once |
| `DO_NOT_TRACK=1` | Also disables survey |
| `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL=1` | Re-enable survey for OTel-only capture |

**Encryption in transit:** TLS 1.2+. **At rest by provider:**
| Provider | Encryption |
|:---------|:-----------|
| Anthropic API | AES-256 disk encryption |
| Amazon Bedrock | AES-256 (AWS-managed or CMEK via AWS KMS) |
| Google Cloud Vertex AI | Google-managed keys (CMEK available) |
| Microsoft Foundry | AES-256 (routes to Anthropic infrastructure) |

**Default service behavior by provider:**
- Metrics, Sentry, `/feedback`: on by default for Claude API; off for Bedrock/Vertex/Foundry/AWS.
- Session quality surveys and WebFetch domain safety check: on by default for all providers.

**WebFetch domain safety check:** sends only the hostname (not full URL) to `api.anthropic.com` before fetching; cached 5 minutes per hostname. Disable with `skipWebFetchPreflight: true`.

### Zero Data Retention (ZDR)

- Available for Claude Code on Claude for Enterprise only.
- Enabled per-organization by Anthropic account team.
- Covers Claude Code inference calls; does not cover chat on claude.ai, Cowork, analytics, user management, or third-party integrations.

**Features disabled under ZDR:**
| Feature | Reason |
|:--------|:-------|
| Claude Code on the web | Requires server-side session storage |
| Remote sessions from Desktop | Requires persistent session data |
| Feedback submission (`/feedback`) | Sends conversation data to Anthropic |

Policy violation data may be retained up to 2 years even under ZDR.

### Security Guidance Plugin

Installed via: `/plugin install security-guidance@claude-plugins-official`

**Three review layers:**

| Layer | Trigger | Cost | Depth |
|:------|:--------|:-----|:------|
| Per-edit pattern check | Every file write | None (no model call) | Regex/substring match |
| End-of-turn review | After each Claude turn | Model usage | Full diff of all changes in the turn (up to 30 files) |
| Commit/push review | `git commit` or `git push` via Bash tool | Model usage (agentic) | Reads surrounding code; capped at 20/rolling hour |

**Built-in pattern categories:** dynamic code execution (`eval`, `new Function`, `os.system`), unsafe deserialization (`pickle`), DOM injection (`dangerouslySetInnerHTML`, `.innerHTML`), workflow files (`.github/workflows/`).

**Custom rules:**
- Model-backed guidance: `.claude/claude-security-guidance.md` (plain language; additive only)
- Per-edit patterns: `.claude/security-patterns.yaml` or `.claude/security-patterns.json`

**Pattern YAML fields:**
| Field | Description |
|:------|:------------|
| `rule_name` | Identifier in warnings |
| `reminder` | Warning text (max 1 KB) |
| `regex` | Python regex |
| `substrings` | Literal match list (alternative to `regex`) |
| `paths` | Glob filter (full path; prefix with `**/`) |
| `exclude_paths` | Glob exclusion filter |

**Disable layers:**
| Variable | Effect |
|:---------|:-------|
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit/push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable plugin entirely |

Default review model: Claude Opus 4.7. Override with `SECURITY_REVIEW_MODEL` (end-of-turn) and `SG_AGENTIC_MODEL` (commit review).

Logs: `~/.claude/security/log.txt`

### Prompt Injection Protections

- Permission system requires approval for sensitive operations.
- Command blocklist: `curl`, `wget` blocked by default.
- WebFetch uses an isolated context window.
- Command injection detection: suspicious commands require manual approval even if previously allowlisted.
- Fail-closed: unmatched commands default to requiring approval.
- Trust verification required on first run and for new MCP servers (disabled with `-p` non-interactive flag, except for `--worktree`).

### Legal and Compliance

- Commercial users: governed by [Commercial Terms](https://www.anthropic.com/legal/commercial-terms).
- Consumer users (Free/Pro/Max): governed by [Consumer Terms](https://www.anthropic.com/legal/consumer-terms).
- **Healthcare (BAA):** extends to Claude Code when organization has ZDR enabled.
- **OAuth authentication:** for subscription plan purchasers only. Developers building products must use API keys.
- Security vulnerabilities: report via [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new).
- Compliance artifacts (SOC 2 Type 2, ISO 27001, etc.): [Anthropic Trust Center](https://trust.anthropic.com).

### Cloud Execution Security (Claude Code on the web)

- Isolated Anthropic-managed VM per session.
- GitHub credentials handled through a secure proxy (never enter the sandbox).
- Network traffic routed through a security proxy for audit logging.
- Branch restrictions: `git push` restricted to current working branch.
- Audit logging and automatic cleanup on session completion.

### Security Best Practices

1. Review all suggested changes before approval.
2. Use project-specific permission settings for sensitive repos.
3. Use dev containers for additional isolation.
4. Regularly audit permissions with `/permissions`.
5. Deliver organization policy via managed settings.
6. Monitor Claude Code usage via OpenTelemetry metrics.
7. Audit settings changes with `ConfigChange` hooks.
8. Do not mount host secrets (`~/.ssh`, cloud credentials) into dev containers; prefer short-lived tokens.
9. Add `~/.aws`, `~/.ssh` to `denyRead` in sandbox settings (readable by default).
10. Avoid piping untrusted content directly to Claude.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Core security model, permission-based architecture, prompt injection protections, MCP security, cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — Complete sandboxed Bash tool configuration: modes, filesystem/network isolation, OS-level enforcement, organization policy, troubleshooting, limitations
- [Sandbox Environments](references/claude-code-sandbox-environments.md) — Compare all isolation approaches (sandboxed Bash, sandbox runtime, dev containers, custom containers, VMs, cloud), choose by goal, enforce org-wide
- [Development Containers](references/claude-code-devcontainer.md) — Install Claude Code in dev containers, persist auth, enforce organization policy, restrict network egress, run without permission prompts, reference container
- [Enterprise Network Configuration](references/claude-code-network-config.md) — Proxy setup, CA certificate configuration, mTLS, full network allowlist, GitHub Enterprise considerations
- [Data Usage](references/claude-code-data-usage.md) — Training policies, data retention by account type, telemetry services, opt-out env vars, encryption at rest, WebFetch domain safety check
- [Zero Data Retention](references/claude-code-zero-data-retention.md) — ZDR scope, what is and isn't covered, features disabled under ZDR, data retention for policy violations, how to request ZDR
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — License terms, commercial agreements, healthcare BAA, authentication policy, security vulnerability reporting
- [Security Guidance Plugin](references/claude-code-security-guidance.md) — In-session vulnerability detection plugin: per-edit pattern check, end-of-turn review, commit review, custom rules, cost, disable/uninstall

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Sandbox Environments: https://code.claude.com/docs/en/sandbox-environments.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Security Guidance Plugin: https://code.claude.com/docs/en/security-guidance.md
