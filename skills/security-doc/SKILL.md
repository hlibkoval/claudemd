---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, prompt injection protections, sandboxing (filesystem and network isolation), dev containers, enterprise network configuration (proxy, mTLS, CA certs), data usage policies, zero data retention, and legal/compliance.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, data handling, and compliance.

## Quick Reference

### Security Architecture

| Layer | Mechanism | Notes |
| :---- | :-------- | :---- |
| Permissions | Explicit approval per action | Configurable allowlists per user/project/org |
| Write access | Confined to working directory and subfolders | Reads outside are allowed |
| Accept Edits mode | Auto-approves file edits + safe FS commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) | Other bash still prompts |
| Sandboxing | OS-level filesystem + network isolation | macOS: Seatbelt; Linux/WSL2: bubblewrap |
| Dev containers | Isolated Docker environment | Optional egress firewall, policy enforcement |
| MCP trust | First-run verification required | Disabled with `-p` flag (non-interactive) |
| Prompt injection | Command blocklist, input sanitization, isolated web fetch context | `curl`/`wget` blocked by default |

### Sandboxing Quick Setup

```bash
# Enable sandboxing interactively
/sandbox

# Linux/WSL2 prerequisites
sudo apt-get install bubblewrap socat   # Ubuntu/Debian
sudo dnf install bubblewrap socat       # Fedora

# Ubuntu 24.04+: AppArmor profile required
sudo tee /etc/apparmor.d/bwrap > /dev/null <<'EOF'
abi <abi/4.0>,
include <tunables/global>
profile bwrap /usr/bin/bwrap flags=(unconfined) {
  userns,
  include if exists <local/bwrap>
}
EOF
sudo systemctl reload apparmor
```

### Sandbox Modes

| Mode | Behavior |
| :--- | :------- |
| Auto-allow | Sandboxed commands run without approval; unsafe commands fall back to normal flow |
| Regular permissions | All commands go through standard approval flow even when sandboxed |

### Sandbox Filesystem Settings (`settings.json`)

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "/tmp/build"],
      "denyWrite": ["~/sensitive"],
      "denyRead": ["~/"],
      "allowRead": ["."]
    },
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false
  }
}
```

Path prefix rules: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-relative (in project settings) or `~/.claude`-relative (in user settings). Arrays from all settings scopes are **merged**, not replaced.

### Sandbox Network Settings

```json
{
  "sandbox": {
    "network": {
      "allowedDomains": ["api.example.com"],
      "deniedDomains": ["untrusted.com"],
      "allowManagedDomainsOnly": true,
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

### Sandbox Security Limitations

- Built-in proxy does not perform TLS inspection — broad domains (e.g., `github.com`) can enable domain fronting
- `allowUnixSockets` granting `/var/run/docker.sock` effectively grants host access
- Overly broad `allowWrite` can enable privilege escalation via shell config files
- `enableWeakerNestedSandbox` (Docker-inside-Docker) considerably weakens isolation

### What Sandbox Does Not Cover

| Tool | Boundary |
| :--- | :------- |
| Read, Edit, Write (built-in file tools) | Permission system, not sandbox |
| Computer use | Runs on actual desktop with per-app prompts |

### Dev Container Quick Setup

```json
// .devcontainer/devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  },
  "mounts": [
    "source=claude-code-config,target=/home/node/.claude,type=volume"
  ],
  "containerEnv": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

Managed policy (highest precedence, overrides user/project settings): copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` in your Dockerfile.

Skip-permissions flag: `--dangerously-skip-permissions` (non-root only). Rejected by root. Pair with network egress restrictions.

### Enterprise Network Configuration

```bash
# Proxy
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,example.com,.example.com"  # or * to bypass all

# CA certificates
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem

# Certificate store (default: bundled,system)
export CLAUDE_CODE_CERT_STORE=bundled    # Mozilla CA only
export CLAUDE_CODE_CERT_STORE=system    # OS trust store only

# mTLS client certificates
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="passphrase"
```

Note: Claude Code does not support SOCKS proxies.

### Required Network Allowlist

| URL | Required for |
| :-- | :----------- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads; native installer/auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed, release notes, plugin marketplace |

### Telemetry Opt-Out Environment Variables

| Variable | Effect |
| :------- | :----- |
| `DISABLE_TELEMETRY=1` | Disable operational metrics to Anthropic |
| `DISABLE_ERROR_REPORTING=1` | Disable Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | Disable `/feedback` command data upload |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential traffic at once |
| `DO_NOT_TRACK` / `DISABLE_TELEMETRY` | Also disables feedback surveys |

### Default Telemetry by Provider

| Service | Claude API | Vertex / Bedrock / Foundry |
| :------ | :--------- | :------------------------- |
| Anthropic metrics | On (opt-out: `DISABLE_TELEMETRY=1`) | Off by default |
| Sentry errors | On (opt-out: `DISABLE_ERROR_REPORTING=1`) | Off by default |
| `/feedback` reports | On (opt-out: `DISABLE_FEEDBACK_COMMAND=1`) | Off by default |
| Session quality surveys | On (all providers) | On (all providers) |
| WebFetch domain safety check | On (all providers) | On (all providers) |

WebFetch domain safety check: sends only the hostname to `api.anthropic.com` before fetching; results cached 5 minutes per hostname. Disable with `skipWebFetchPreflight: true` in settings.

### Data Retention

| Account type | Retention |
| :----------- | :-------- |
| Consumer (allows model training) | 5 years |
| Consumer (opts out of model training) | 30 days |
| Commercial (Team/Enterprise/API) standard | 30 days |
| Commercial with ZDR | No server-side retention after response |
| Local session transcripts | 30 days (adjust: `cleanupPeriodDays`); stored in `~/.claude/projects/` |
| `/feedback` transcripts | 5 years |
| Transcript shared via session quality follow-up | Up to 6 months |

### Data Training Policy

| Account type | Training use |
| :----------- | :----------- |
| Consumer (Free/Pro/Max) — training on | Used to improve future models |
| Consumer — training off | Not used; change at claude.ai/settings/data-privacy-controls |
| Commercial (Team/Enterprise/API) | Not used unless opted in (e.g., Developer Partner Program) |

### Encryption at Rest by Provider

| Provider | Encryption |
| :------- | :--------- |
| Anthropic API | AES-256 disk encryption; ZDR available for no server-side persistence |
| Amazon Bedrock | AES-256, AWS-managed keys; CMEK via AWS KMS available |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | Routes to Anthropic infrastructure with AES-256 |

### Zero Data Retention (ZDR)

- Available for Claude Code on Claude for Enterprise (not Bedrock/Vertex/Foundry)
- Enabled per-organization by Anthropic account team
- Covers: Claude Code inference calls
- Does NOT cover: claude.ai chat, Cowork, Analytics metadata, user/seat management, third-party integrations
- Features disabled under ZDR: Claude Code on the Web, Remote sessions from Desktop, `/feedback` command
- Policy violations: Anthropic may retain data up to 2 years

### Legal / Compliance

| Topic | Details |
| :---- | :------- |
| Consumer license | Consumer Terms of Service (Free/Pro/Max) |
| Commercial license | Commercial Terms (Team/Enterprise/API) |
| Healthcare (BAA) | Auto-extends to Claude Code when BAA + ZDR are active on the organization |
| OAuth authentication | For Claude subscription plan users only (Free/Pro/Max/Team/Enterprise) |
| API key authentication | Required for developers building products with the Agent SDK |
| Security vulnerability reporting | HackerOne program |

### Security Best Practices

- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Use dev containers for additional isolation
- Audit permissions with `/permissions`
- Use managed settings to enforce org standards
- Monitor with OpenTelemetry metrics
- Audit/block config changes with `ConfigChange` hooks
- Report suspicious behavior with `/feedback`
- Report vulnerabilities via HackerOne (do not disclose publicly first)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Permission architecture, prompt injection protections, MCP/IDE/cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — Filesystem and network isolation, OS-level enforcement, sandbox modes, configuration, limitations
- [Development Containers](references/claude-code-devcontainer.md) — Installing Claude Code in dev containers, persisting auth, org policy enforcement, network egress restriction, skip-permissions mode
- [Enterprise Network Configuration](references/claude-code-network-config.md) — Proxy setup, CA certificates, mTLS, network allowlist requirements
- [Data Usage](references/claude-code-data-usage.md) — Training policies, data retention, telemetry services, WebFetch domain safety check, provider-specific defaults
- [Zero Data Retention](references/claude-code-zero-data-retention.md) — ZDR scope, covered/excluded features, disabled features, how to request
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — License agreements, BAA/healthcare compliance, acceptable use, authentication restrictions

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
