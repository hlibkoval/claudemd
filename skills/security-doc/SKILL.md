---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, prompt injection protections, sandboxing (filesystem and network isolation, modes, OS primitives, configuration), dev containers (setup, policy enforcement, network egress, reference container), enterprise network configuration (proxies, CA certificates, mTLS, required domain allowlist), data usage and retention policies (training policy, ZDR, telemetry opt-outs), legal and compliance (BAA, acceptable use, authentication rules), and zero data retention (scope, disabled features, enablement).
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data handling, network configuration, and compliance.

## Quick Reference

### Security Architecture Layers

| Layer | What it covers | Key controls |
| :--- | :--- | :--- |
| **Permission system** | Which tools Claude can use; evaluated before any tool runs | Allowlist/denylist rules, accept-edits mode, auto mode |
| **Sandboxing** | OS-level filesystem + network isolation for Bash commands | `/sandbox`, `sandbox.*` settings, `allowedDomains` |
| **Prompt injection protections** | Detect and block malicious content in inputs | Command blocklist, context-aware analysis, isolated WebFetch context |
| **Credential security** | API keys/tokens encrypted at rest and in transit | OAuth tokens, API keys, mTLS, ZDR |
| **Data retention** | How long prompts and responses are stored | Consumer vs. commercial policies, ZDR |

### Built-in Protections Summary

| Protection | Description |
| :--- | :--- |
| **Write access boundary** | Claude Code can only write to the folder where it was started and subdirectories |
| **Command blocklist** | `curl`, `wget`, and similar tools blocked by default |
| **Network request approval** | Network-accessing tools require explicit user approval |
| **Isolated WebFetch context** | Web fetches use a separate context window to prevent prompt injection |
| **Trust verification** | First-time codebases and new MCP servers require trust confirmation |
| **Command injection detection** | Suspicious bash commands require manual approval even if previously allowlisted |
| **Fail-closed matching** | Unmatched commands default to requiring manual approval |
| **Secure credential storage** | API keys and tokens are encrypted |

### Sandboxing

#### Enable / Modes

| Method | Notes |
| :--- | :--- |
| `/sandbox` in session | Opens menu to choose mode or install dependencies |
| `sandbox.enabled: true` in `settings.json` | Programmatic enable |
| `sandbox.failIfUnavailable: true` | Hard failure if sandbox unavailable (managed deployments) |

| Mode | Behavior |
| :--- | :--- |
| **Auto-allow** | Sandboxed commands run automatically; non-sandboxable commands fall back to normal permission flow |
| **Regular permissions** | All commands go through standard permission flow even when sandboxed |

#### Platform Prerequisites

| Platform | Requirement |
| :--- | :--- |
| macOS | No install needed; uses Seatbelt built-in |
| Linux / WSL2 | `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) or `sudo dnf install bubblewrap socat` (Fedora) |
| Ubuntu 24.04+ | AppArmor profile for `bwrap` required (see reference doc) |
| WSL1 | Not supported |

#### Key Sandbox Settings (`settings.json`)

| Setting | Purpose |
| :--- | :--- |
| `sandbox.enabled` | Enable sandboxing |
| `sandbox.failIfUnavailable` | Fail hard if sandbox cannot start |
| `sandbox.filesystem.allowWrite` | Paths outside CWD subprocess commands may write |
| `sandbox.filesystem.denyWrite` | Block subprocess writes to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess reads from specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.allowedDomains` | Domains Bash commands may reach |
| `sandbox.network.deniedDomains` | Block specific domains within a broader `allowedDomains` wildcard |
| `sandbox.network.httpProxyPort` | Custom proxy port for TLS inspection |
| `sandbox.network.socksProxyPort` | SOCKS proxy port for custom rules |
| `sandbox.excludedCommands` | Commands forced to run outside the sandbox |
| `sandbox.allowManagedDomainsOnly` | Block all non-explicitly-allowed domains automatically |
| `allowUnsandboxedCommands` | Set `false` to disable the `dangerouslyDisableSandbox` escape hatch |
| `enableWeakerNestedSandbox` | Linux only; weakens sandbox for Docker-in-Docker (use cautiously) |

#### Path Prefix Conventions in Sandbox Settings

| Prefix | Resolves to |
| :--- | :--- |
| `/path` | Absolute path from filesystem root |
| `~/path` | Relative to home directory |
| `./path` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

When the same setting appears in multiple scopes, arrays are **merged** — not replaced.

#### Security Limitations of Sandboxing

- The built-in proxy does not terminate TLS; it cannot inspect encrypted traffic. Domain fronting may bypass the allowlist.
- `allowUnixSockets` can grant access to powerful services (e.g., Docker socket = host system access).
- Overly broad `allowWrite` paths (e.g., directories in `$PATH` or shell config files) can enable privilege escalation.
- `enableWeakerNestedSandbox` considerably weakens isolation; only use inside Docker with additional controls.

### Dev Containers

#### Minimal `devcontainer.json`

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

#### Persist Auth Across Rebuilds

```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

Use `${devcontainerId}` in the source name to isolate state per project.

#### Enforce Organization Policy

Place `managed-settings.json` at `/etc/claude-code/managed-settings.json` inside the container. Copy via Dockerfile:

```dockerfile
RUN mkdir -p /etc/claude-code
COPY managed-settings.json /etc/claude-code/managed-settings.json
```

For policy engineers cannot bypass by editing the repo, use server-managed settings or MDM delivery instead.

#### Skip Permission Prompts in Containers

Pass `--dangerously-skip-permissions` (CLI rejects this when run as root). Pair with network egress restrictions. To prevent engineers from using this flag at all, set `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

#### Useful `containerEnv` Variables

| Variable | Effect |
| :--- | :--- |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable telemetry + error reporting |
| `DISABLE_AUTOUPDATER=1` | Prevent Claude Code from auto-updating |

### Enterprise Network Configuration

#### Proxy Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Bypass proxy for listed hosts (comma- or space-separated, or `*` for all) |

Note: SOCKS proxies are not supported.

#### CA Certificate Configuration

| Variable/Setting | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE=bundled,system` | Default: trust bundled Mozilla CA set + OS store |
| `CLAUDE_CODE_CERT_STORE=bundled` | Trust only bundled Mozilla CAs |
| `CLAUDE_CODE_CERT_STORE=system` | Trust only OS certificate store |
| `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem` | Trust a custom enterprise CA certificate |

#### mTLS Authentication

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate PEM |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key PEM |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

#### Required Domain Allowlist

| Domain | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests + WebFetch domain safety check |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads; native installer and auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed and plugin marketplace install counts |

When using Bedrock, Vertex AI, or Microsoft Foundry, model traffic goes to that provider's endpoints instead of `api.anthropic.com`.

### Data Usage and Retention

#### Training Policy by Plan

| User type | Training default |
| :--- | :--- |
| Consumer (Free, Pro, Max) | Data used for model improvement when setting is on |
| Commercial (Team, Enterprise, API, Gov) | No training by default; opt-in via Development Partner Program |

#### Data Retention Periods

| User type | Retention |
| :--- | :--- |
| Consumer — allows model improvement | 5-year retention |
| Consumer — does not allow model improvement | 30-day retention |
| Commercial — standard | 30-day retention |
| Commercial — ZDR enabled | No server-side retention after response |
| Local session transcripts (all) | Stored in `~/.claude/projects/` for 30 days (`cleanupPeriodDays` configurable) |

#### Encryption at Rest by Provider

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR disables server-side persistence entirely |
| Amazon Bedrock | AES-256 with AWS-managed keys; CMEK available via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | Routes to Anthropic infrastructure with AES-256 disk encryption |

#### Telemetry Opt-Out Variables

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Operational metrics (latency, reliability, usage patterns) |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command sending data to Anthropic |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality survey |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | All of the above at once (not WebFetch check) |

Telemetry and error reporting default to **off** on Bedrock, Vertex, Foundry, and Claude Platform on AWS.

#### WebFetch Domain Safety Check

Before fetching a URL, WebFetch sends only the hostname to `api.anthropic.com` for a blocklist check. Results cached 5 minutes per hostname. Disable with `skipWebFetchPreflight: true` in settings. Runs regardless of model provider.

### Zero Data Retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only. When enabled, prompts and responses are not stored by Anthropic after the response is returned.

#### ZDR Scope

| Covered | Not covered |
| :--- | :--- |
| Claude Code inference on Claude for Enterprise | Chat on claude.ai, Cowork sessions |
| | Claude Code Analytics (collects usage metadata, not prompts) |
| | User/seat management administrative data |
| | Third-party tools, MCP servers, and external integrations |

#### Features Disabled Under ZDR

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side conversation history |
| Remote sessions from Desktop app | Requires persistent session data |
| Feedback submission (`/feedback`) | Sends conversation data to Anthropic |

#### ZDR Enablement

- Enabled per-organization by Anthropic account team (does not auto-apply to new orgs under same account)
- Required for BAA (HIPAA) coverage: BAA auto-extends to Claude Code when ZDR is active
- Contact sales or your account team to request ZDR

### Legal and Compliance Quick Reference

| Topic | Detail |
| :--- | :--- |
| Commercial terms | Apply to Team, Enterprise, and API users |
| Consumer terms | Apply to Free, Pro, and Max users |
| BAA (HIPAA) | Auto-extends to Claude Code when org has ZDR activated |
| Authentication for developers | Use API keys via Console; OAuth tokens are for personal subscription plans only; routing requests through Free/Pro/Max credentials on behalf of third-party users is not permitted |
| Security vulnerability reporting | HackerOne program |

### Security Best Practices

| Scenario | Recommendation |
| :--- | :--- |
| Sensitive code | Review all changes; use project-specific permissions; consider dev containers |
| Team / enterprise | Use managed settings to enforce org standards; share approved permission configs via version control |
| Monitoring | Use OpenTelemetry metrics; audit `ConfigChange` hooks to detect setting modifications |
| Prompt injection | Review commands before approval; avoid piping untrusted content; use VMs for external scripts |
| MCP servers | Use servers from trusted providers; review Anthropic listing criteria; configure permissions |
| Cloud sessions | Cloud VMs are isolated and auto-terminated; credentials go through secure proxy |

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, built-in protections, prompt injection safeguards, MCP/IDE/cloud security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, OS primitives (Seatbelt/bubblewrap), sandbox modes, configuration reference, security limitations, open source runtime
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persistent auth, policy enforcement, network egress restrictions, reference container walkthrough
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate store, custom CA, mTLS, required domain allowlist
- [Data usage](references/claude-code-data-usage.md) — training policy by plan, data retention periods, encryption at rest, telemetry services and opt-outs, WebFetch domain safety check
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, BAA/HIPAA, acceptable use policy, authentication and credential rules, trust center
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, features disabled under ZDR, data retention for policy violations, how to request ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
