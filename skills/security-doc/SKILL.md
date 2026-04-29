---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, sandboxing (filesystem and network isolation), dev containers, enterprise network configuration (proxy, CA certs, mTLS), data usage and retention policies, legal and compliance, and zero data retention (ZDR).
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, and compliance topics.

## Quick Reference

### Permission-based architecture

Claude Code uses read-only permissions by default. Additional actions (editing files, running commands) require explicit approval. Write access is restricted to the folder where Claude Code was started and its subfolders.

### Sandboxing

Enable via `/sandbox`. Uses OS-level primitives: Seatbelt (macOS), bubblewrap (Linux/WSL2). WSL1 is not supported.

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without approval; commands needing non-allowed network access fall back to normal permission flow |
| Regular permissions | All commands go through standard permission flow even when sandboxed |

**Sandbox filesystem settings (`sandbox.filesystem.*`):**

| Key | Description |
| :--- | :--- |
| `allowWrite` | Paths subprocess commands can write outside the working directory |
| `denyWrite` | Paths blocked from write access |
| `denyRead` | Paths blocked from read access |
| `allowRead` | Re-allow reading within a `denyRead` region |

Arrays from multiple settings scopes are **merged** (not replaced). Path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root-relative (project settings) or `~/.claude`-relative (user settings).

**Sandbox network settings:**

| Key | Description |
| :--- | :--- |
| `allowedDomains` | Domains Bash commands may reach |
| `deniedDomains` | Blocked domains even if covered by an `allowedDomains` wildcard |
| `allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |
| `httpProxyPort` / `socksProxyPort` | Custom proxy ports for advanced network filtering |
| `allowUnixSockets` | Unix socket paths accessible from sandbox (use carefully; docker.sock grants host access) |
| `excludedCommands` | Commands that always run outside the sandbox |
| `allowUnsandboxedCommands` | Set `false` to disable the `dangerouslyDisableSandbox` escape hatch |
| `failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `enableWeakerNestedSandbox` | Enables sandbox inside Docker without privileged namespaces (weakens security) |

**Sandbox security limitations:** Network filtering does not inspect traffic content; broad domains (e.g. `github.com`) may allow data exfiltration; domain fronting may bypass filtering; `allowUnixSockets` with privileged sockets (docker.sock) grants host access; overly broad `allowWrite` can enable privilege escalation.

**Open source sandbox runtime:** `npx @anthropic-ai/sandbox-runtime <command>`

### Dev containers

Install via the [Claude Code Dev Container Feature](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code):

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

**Key topics:**

| Topic | How |
| :--- | :--- |
| Persist auth across rebuilds | Mount named volume at `~/.claude` (`source=claude-code-config,target=/home/node/.claude,type=volume`) |
| Organization policy | Copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` in Dockerfile |
| Pin CLI version | Install via `npm install -g @anthropic-ai/claude-code@X.Y.Z` + `DISABLE_AUTOUPDATER=1` |
| Restrict network egress | Use `init-firewall.sh` script with `NET_ADMIN` and `NET_RAW` capabilities |
| Skip permission prompts | `--dangerously-skip-permissions` (requires non-root `remoteUser`; pair with egress restrictions) |

**Warning:** `--dangerously-skip-permissions` does not prevent exfiltration of `~/.claude` contents. Only use with trusted repositories.

### Prompt injection protections

- Permission system requires approval for sensitive operations
- Context-aware analysis detects harmful instructions
- `curl` and `wget` blocked by default
- Network requests require user approval
- Web fetch uses isolated context window
- First-time codebase runs and new MCP servers require trust verification
- Suspicious bash commands require manual approval even if allowlisted
- Unmatched commands default to requiring manual approval (fail-closed)

**Best practices:** Review commands before approval; avoid piping untrusted content to Claude; use VMs for external web service interactions; report suspicious behavior with `/feedback`.

**Windows WebDAV warning:** Avoid enabling WebDAV or allowing access to `\\*` paths — deprecated by Microsoft and may bypass the permission system.

### Enterprise network configuration

**Proxy environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Bypass proxy for hosts (space- or comma-separated) |

SOCKS proxies are not supported. Basic auth: include credentials in the URL. For NTLM/Kerberos, use an LLM Gateway.

**CA certificate configuration:**

| Variable / Setting | Purpose |
| :--- | :--- |
| `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem` | Trust a custom enterprise CA |
| `CLAUDE_CODE_CERT_STORE=bundled,system` | Control which CA stores are trusted (default: `bundled,system`) |

Enterprise TLS-inspection proxies (CrowdStrike Falcon, Zscaler) work without extra config when their root cert is in the OS trust store. On the Node.js runtime (not native binary), use `NODE_EXTRA_CA_CERTS` instead.

**mTLS authentication:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads; native installer/auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |

When using Bedrock, Vertex, or Foundry, model traffic goes to those providers instead of `api.anthropic.com`. WebFetch still calls `api.anthropic.com` for its domain safety check unless `skipWebFetchPreflight: true` is set.

### Data usage and retention

**Training policy:**

| Plan | Default training use |
| :--- | :--- |
| Free, Pro, Max (consumer) | On by default; opt out at claude.ai/settings/data-privacy-controls |
| Team, Enterprise, API | Not used for training (unless opted in via Developer Partner Program) |

**Data retention:**

| Account type | Standard retention | Notes |
| :--- | :--- | :--- |
| Consumer (allow training) | 5 years | |
| Consumer (no training) | 30 days | |
| Commercial (Team/Enterprise/API) | 30 days | ZDR available for Enterprise |
| Local session transcripts | 30 days | Stored in `~/.claude/projects/`; adjust with `cleanupPeriodDays` |

**Encryption at rest:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 infrastructure-level disk encryption |
| Amazon Bedrock | AES-256 with AWS-managed keys; CMEK via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | Routes to Anthropic infra; AES-256 |

All data encrypted in transit via TLS 1.2+.

**Telemetry opt-out:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Statsig metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | All non-essential traffic (not WebFetch check) |

Statsig, Sentry, and `/feedback` are off by default for Bedrock, Vertex, and Foundry. Session quality surveys and WebFetch domain safety check run regardless of provider.

**WebFetch domain safety check:** Before fetching, sends only the hostname to `api.anthropic.com` to check against a safety blocklist. Results cached 5 minutes per hostname. Disable with `skipWebFetchPreflight: true` in settings.

### Zero Data Retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only (not Bedrock/Vertex/Foundry).

- Prompts and responses not stored by Anthropic after response is returned
- Enabled per-organization; contact your account team
- Automatically disables: Claude Code on the Web, Remote Desktop sessions, `/feedback`

**What ZDR does not cover:**

| Feature | Status under ZDR |
| :--- | :--- |
| Chat on claude.ai | Standard retention |
| Cowork | Standard retention |
| Claude Code Analytics | Collects metadata (not prompts); contribution metrics unavailable |
| User/seat management | Standard retention |
| Third-party integrations / MCP | Not covered; check those services independently |

Even with ZDR, Anthropic may retain data for legal compliance or usage policy violations (up to 2 years).

### Legal and compliance

- **SOC 2 Type 2** and **ISO 27001** certifications: [Anthropic Trust Center](https://trust.anthropic.com)
- **BAA (HIPAA)**: Automatically extends to Claude Code if organization has executed a BAA and has ZDR enabled
- **Security vulnerability reporting**: [HackerOne program](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new) — do not disclose publicly
- **Terms**: [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) (Team/Enterprise/API) or [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) (Free/Pro/Max)
- **OAuth authentication** is for Anthropic plan subscribers only; third-party developers must use API keys

### Cloud execution security

Sessions in [Claude Code on the web](/en/claude-code-on-the-web) run in isolated Anthropic-managed VMs with:
- Network access limited by default; configurable per domain
- Secure proxy for GitHub credential handling (actual token never enters sandbox)
- Git push restricted to current working branch
- Audit logging for all operations
- Automatic cleanup after session completion

Remote Control sessions run locally; all execution stays on-machine, traffic over TLS.

### Security best practices

| Area | Recommendations |
| :--- | :--- |
| Sensitive code | Review all changes; use project-specific permissions; use dev containers for isolation |
| Team | Use managed settings to enforce org standards; share approved configs via version control; monitor via OpenTelemetry; audit with `ConfigChange` hooks |
| Sandboxing | Start restrictive and expand; combine with IAM policies; test configs; use environment-specific rules |

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, built-in protections, prompt injection safeguards, MCP/IDE/cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — OS-level filesystem and network isolation, sandbox modes, configuration, security benefits and limitations, open source runtime
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth, enforcing org policy, restricting network egress, running without permission prompts
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate store, custom CA, mTLS authentication, network access requirements
- [Data usage](references/claude-code-data-usage.md) — training policy, data retention, encryption, telemetry services, WebFetch domain safety check
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, BAA/healthcare compliance, acceptable use, authentication restrictions, trust and safety
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what is and isn't covered, disabled features, requesting ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
