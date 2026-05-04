---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, prompt injection protections, sandboxing (filesystem/network isolation), dev containers, enterprise network configuration (proxy, CA, mTLS), data usage policies, zero data retention, and legal/compliance.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, data privacy, network configuration, sandboxing, dev containers, and legal compliance.

## Quick Reference

### Security Architecture

| Layer | Mechanism | Notes |
| :--- | :--- | :--- |
| Permissions | Read-only by default; explicit approval for writes/commands | See `/permissions` command |
| Sandboxing | OS-level filesystem + network isolation (Seatbelt/bubblewrap) | Enable with `/sandbox` |
| Write scope | Only current working dir and subdirs | Cannot write to parent dirs |
| Prompt injection | Input sanitization, context-aware analysis, command blocklist | `curl`/`wget` blocked by default |
| Credentials | Encrypted storage for API keys and tokens | |
| MCP servers | Trust verification required on first use | |

### Sandbox Quick Setup

Enable sandboxing:
```
/sandbox
```

Linux/WSL2 prerequisites:
```bash
# Ubuntu/Debian
sudo apt-get install bubblewrap socat
# Fedora
sudo dnf install bubblewrap socat
```

Platform support: macOS (Seatbelt), Linux (bubblewrap), WSL2 (bubblewrap). WSL1 not supported.

### Sandbox Modes

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without prompts; non-sandboxable commands fall back to normal flow |
| Regular permissions | All commands go through normal permission flow even when sandboxed |

### Sandbox Settings (settings.json)

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "/tmp/build"],
      "denyWrite": ["/etc"],
      "denyRead": ["~/"],
      "allowRead": ["."]
    },
    "network": {
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

Path prefix conventions for sandbox filesystem rules:

| Prefix | Resolves to |
| :--- | :--- |
| `/path` | Absolute from filesystem root |
| `~/path` | Relative to home directory |
| `./path` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

Array fields (`allowWrite`, `denyWrite`, `denyRead`, `allowRead`) are **merged** across all settings scopes — not replaced.

### Sandbox Security Limitations

- Built-in proxy checks hostname only, does not inspect TLS — broad domains (e.g., `github.com`) may allow domain fronting
- `allowUnixSockets` can inadvertently grant access to powerful services (e.g., `/var/run/docker.sock`)
- Overly broad write permissions can enable privilege escalation via PATH or shell config files
- Linux `enableWeakerNestedSandbox` mode weakens isolation (for Docker-inside-Docker only)

### Dev Container Quick Setup

`.devcontainer/devcontainer.json`:
```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

Persist `~/.claude` across rebuilds:
```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

Enforce org policy via managed settings (highest precedence):
```dockerfile
RUN mkdir -p /etc/claude-code
COPY managed-settings.json /etc/claude-code/managed-settings.json
```

Run without permission prompts (non-root user required):
```
--dangerously-skip-permissions
```

To prevent engineers from using this flag, set `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

### Enterprise Network Configuration

Proxy environment variables (also configurable in `settings.json`):
```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,example.com"
```

Custom CA and mTLS:
```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="passphrase"
```

CA certificate store (`bundled,system` by default):
```bash
export CLAUDE_CODE_CERT_STORE=bundled   # Mozilla CA only
export CLAUDE_CODE_CERT_STORE=system    # OS trust store only
```

Required network allowlist:

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads; native installer/updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension |

Note: When using Bedrock/Vertex/Foundry, model traffic goes to those providers instead of `api.anthropic.com`. WebFetch still calls `api.anthropic.com` for its domain safety check unless `skipWebFetchPreflight: true` is set.

### Data Usage and Training

| Account type | Training policy | Retention |
| :--- | :--- | :--- |
| Consumer (Free/Pro/Max) — training on | Data used for model improvement | 5-year retention |
| Consumer (Free/Pro/Max) — training off | Not used | 30-day retention; toggle at [claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls) |
| Commercial (Team/Enterprise/API) | Not used unless opted in | 30-day standard |
| Commercial + Zero Data Retention | Not retained after response | No server-side persistence |

Local session transcripts stored in `~/.claude/projects/` for 30 days (configurable via `cleanupPeriodDays`).

### Telemetry and Opt-out

| Service | Default (Anthropic API) | Opt-out env var |
| :--- | :--- | :--- |
| Statsig (metrics) | On | `DISABLE_TELEMETRY=1` |
| Sentry (errors) | On | `DISABLE_ERROR_REPORTING=1` |
| `/feedback` reports | On | `DISABLE_FEEDBACK_COMMAND=1` |
| Session quality surveys | On | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| WebFetch domain safety check | On (all providers) | `skipWebFetchPreflight: true` in settings |
| All non-essential traffic | — | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` |

Statsig, Sentry, and `/feedback` are **off by default** for Bedrock, Vertex, and Foundry.

Encryption: all telemetry encrypted in transit (TLS) and at rest (AES-256).

Encryption at rest by provider:

| Provider | Encryption at rest |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR available for no persistence |
| Amazon Bedrock | AES-256 with AWS-managed keys; CMEK via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | AES-256 via Anthropic infrastructure |

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only. Prompts and responses are not stored after the response is returned.

Features disabled under ZDR:
- Claude Code on the Web
- Remote sessions from Desktop app
- Feedback submission (`/feedback`)

ZDR does not cover: chat on claude.ai, Cowork sessions, Claude Code Analytics (usage metadata still collected), user/seat management data, third-party integrations.

ZDR is per-organization — each new org requires separate enablement by Anthropic account team.

### Cloud Execution Security

- Isolated VMs per session (Anthropic-managed)
- GitHub credentials proxied — never enter sandbox
- All outbound traffic through security proxy (audit logging)
- Git push restricted to current working branch
- Automatic cleanup after session
- All operations audit-logged

Remote Control sessions use local execution (not cloud VMs); same data flows as local Claude Code over TLS.

### Prompt Injection Protections

- Permission system requires explicit approval for sensitive operations
- `curl`/`wget` blocked by default (fetch-from-web commands)
- Web fetch uses isolated context window (separate from main context)
- First-time codebase and new MCP servers require trust verification (disabled with `-p` flag)
- Command injection detection: suspicious commands require manual approval even if allowlisted
- Fail-closed matching: unmatched commands default to requiring approval

**Best practices with untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external web services
5. Report suspicious behavior with `/feedback`

### Team Security Best Practices

- Use [managed settings](/en/settings#settings-files) to enforce organizational standards
- Share permission configurations through version control
- Monitor usage with OpenTelemetry metrics
- Audit/block settings changes with `ConfigChange` hooks
- Report vulnerabilities via [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new)

### Legal and Compliance

| Topic | Details |
| :--- | :--- |
| Commercial users | [Commercial Terms of Service](https://www.anthropic.com/legal/commercial-terms) |
| Consumer users | [Consumer Terms of Service](https://www.anthropic.com/legal/consumer-terms) |
| Healthcare (HIPAA/BAA) | BAA extends to Claude Code when ZDR is active for the org |
| Trust Center | Certifications (SOC 2 Type 2, ISO 27001): [trust.anthropic.com](https://trust.anthropic.com) |
| Authentication | OAuth for subscription plan users only; developers must use API keys |

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection protections, MCP security, cloud execution security, and security best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, OS-level enforcement, sandbox modes, settings configuration, security limitations, and advanced proxy usage
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in a dev container, persisting auth across rebuilds, enforcing org policy, restricting network egress, and running without permission prompts
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate store, custom CA, mTLS authentication, and network access requirements
- [Data usage](references/claude-code-data-usage.md) — training policies, data retention by account type, telemetry services, opt-out env vars, and WebFetch domain safety check
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, features disabled under ZDR, requesting ZDR for Enterprise
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, commercial agreements, healthcare BAA, acceptable use policy, authentication restrictions

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
