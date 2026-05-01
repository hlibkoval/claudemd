---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, prompt injection protections, sandboxing with filesystem and network isolation, dev containers, enterprise network configuration, data usage and retention policies, zero data retention, and legal/compliance information.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, and compliance.

## Quick Reference

### Security architecture overview

| Layer | Mechanism | Scope |
| :--- | :--- | :--- |
| Permission system | User approves tool calls before execution | All tools (Bash, Read, Edit, WebFetch, MCP) |
| Sandboxing | OS-level filesystem and network isolation | Bash commands and their child processes |
| Prompt injection defenses | Allowlist/blocklist, context analysis, command injection detection | All inputs |
| Dev containers | Docker-based isolation for team environments | All Claude Code operations in container |
| MCP trust verification | First-run trust prompt for new MCP servers | MCP tool calls |

### Built-in protections

| Protection | Description |
| :--- | :--- |
| Write access restriction | Can only write to working directory and subdirectories |
| Command blocklist | `curl`, `wget` blocked by default |
| Allowlist support | Safe commands can be allowlisted per-user, per-codebase, per-org |
| Accept Edits mode | Batch accept edits; commands with side effects still require approval |
| Network request approval | Network-making tools require user approval by default |
| Isolated context windows | WebFetch uses a separate context to avoid prompt injection |
| Credential encryption | API keys and tokens are encrypted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Sandboxing quick reference

**Enable:** Run `/sandbox` in-session, or set `sandbox.enabled: true` in `settings.json`.

**OS support:** macOS (Seatbelt), Linux/WSL2 (bubblewrap + socat). WSL1 not supported.

**Install dependencies (Linux/WSL2):**
- Ubuntu/Debian: `sudo apt-get install bubblewrap socat`
- Fedora: `sudo dnf install bubblewrap socat`

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed bash commands run without permission prompts; non-sandboxable commands use normal flow |
| Regular permissions | All bash commands still prompt, even when sandboxed |

**Filesystem access defaults:**

| Access type | Default |
| :--- | :--- |
| Write | Current working directory and subdirectories only |
| Read | Entire filesystem, except explicitly denied paths |

**Key sandbox settings (`settings.json`):**

| Setting | Purpose |
| :--- | :--- |
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.filesystem.allowWrite` | Additional paths subprocesses may write to |
| `sandbox.filesystem.denyWrite` | Paths to block writes to |
| `sandbox.filesystem.denyRead` | Paths to block reads from |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.allowedDomains` | Domains bash commands may reach |
| `sandbox.network.deniedDomains` | Block specific domains even within an allowedDomains wildcard |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port for TLS inspection |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the escape hatch |
| `allowManagedDomainsOnly` | Block any domain not in allowedDomains automatically |
| `excludedCommands` | Commands that always run outside the sandbox |

**Path prefix conventions (sandbox filesystem settings):**

| Prefix | Resolved as |
| :--- | :--- |
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

**Security limitations:**
- Built-in proxy does not terminate/inspect TLS — no protection against domain fronting
- `allowUnixSockets` can expose powerful services (e.g., Docker socket)
- Broad `allowedDomains` (e.g., `github.com`) can allow data exfiltration
- `enableWeakerNestedSandbox` (Linux) weakens isolation for Docker environments

### Network configuration (enterprise)

**Proxy environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL fallback |
| `NO_PROXY` | Comma- or space-separated bypass list; `*` to bypass all |

Note: SOCKS proxies are not supported.

**Certificate / mTLS variables:**

| Variable | Purpose |
| :--- | :--- |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA cert PEM (required for Node.js runtime) |
| `CLAUDE_CODE_CERT_STORE` | Comma list: `bundled`, `system` (default: `bundled,system`) |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console account authentication |
| `downloads.claude.ai` | Plugin downloads, native installer, native auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |

### Data usage and retention

**Training policy:**

| User type | Default training use |
| :--- | :--- |
| Consumer (Free/Pro/Max) | Opt-in; training when enabled |
| Commercial (Team/Enterprise/API) | No training unless opted in via Developer Partner Program |

**Data retention:**

| User type | Retention |
| :--- | :--- |
| Consumer — allows model improvement | 5 years |
| Consumer — does not allow model improvement | 30 days |
| Commercial standard | 30 days |
| Commercial with ZDR | No server-side persistence (inference only) |
| Local client cache | 30 days (configurable via `cleanupPeriodDays`) |
| `/feedback` transcripts | 5 years |

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR available |
| Amazon Bedrock | AES-256; customer-managed keys via AWS KMS |
| Google Cloud Vertex AI | Google-managed; CMEK available |
| Microsoft Foundry | AES-256 via Anthropic infrastructure |

**Telemetry opt-out environment variables:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Statsig metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command sending data |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | All of the above at once (not WebFetch check) |

Telemetry (Statsig, Sentry, `/feedback`) is off by default for Bedrock, Vertex, and Foundry. Session quality surveys and the WebFetch domain safety check are on by default for all providers.

### Zero data retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only (not Bedrock/Vertex/Foundry).

- Must be enabled per-organization by Anthropic account team
- Covers: model inference calls through Claude Code
- Does NOT cover: claude.ai chat, Cowork, Analytics metadata, user management data, third-party integrations

**Features disabled under ZDR:**

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions from Desktop | Requires persistent session data |
| `/feedback` command | Sends conversation data to Anthropic |

### Dev container quick reference

Install via Dev Container Feature:
```json
{
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

**Persist auth across rebuilds** — mount a named volume at `~/.claude`:
```json
"mounts": ["source=claude-code-config,target=/home/node/.claude,type=volume"]
```

**Enforce organization policy** — copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` via Dockerfile (highest precedence in settings hierarchy).

**Disable auto-update and telemetry:**
```json
"containerEnv": {
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
  "DISABLE_AUTOUPDATER": "1"
}
```

**Run without prompts** — pass `--dangerously-skip-permissions` only with non-root `remoteUser` + network egress restrictions. To prevent engineers from using this flag, set `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

**Security warning:** When using `--dangerously-skip-permissions`, dev containers do not prevent a malicious project from exfiltrating `~/.claude` credentials. Only use with trusted repositories. Do not mount host secrets (`~/.ssh`, cloud credentials) into the container.

### Cloud execution security

| Control | Description |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in an Anthropic-managed VM |
| Network access controls | Limited by default; configurable to specific domains |
| Credential protection | Secure proxy with scoped credentials; GitHub token never enters sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | VMs terminated after session completion |

Remote Control sessions run differently — all execution is local; only API traffic flows through Anthropic over TLS.

### Legal and compliance highlights

| Topic | Key point |
| :--- | :--- |
| License | Commercial Terms (Team/Enterprise/API) or Consumer Terms (Free/Pro/Max) |
| Healthcare (BAA) | Automatically covers Claude Code if BAA + ZDR are both active |
| OAuth authentication | For subscription plan users only; not for third-party developers routing requests |
| API key auth | Required for developers building products or services with Claude |
| Security reporting | HackerOne program; do not disclose publicly |

### Security best practices

1. Review all suggested changes before approval
2. Use project-specific permission settings for sensitive repositories
3. Use dev containers or sandboxing for additional isolation
4. Use managed settings to enforce organizational standards
5. Monitor Claude Code usage through OpenTelemetry metrics
6. Audit or block settings changes with `ConfigChange` hooks
7. Avoid piping untrusted content directly to Claude
8. Use VMs when interacting with external web services
9. Report suspicious behavior with `/feedback`

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission-based architecture, built-in protections, prompt injection safeguards, MCP security, IDE security, cloud execution security, and security best practices
- [Sandboxing](references/claude-code-sandboxing.md) — OS-level filesystem and network isolation, sandbox modes, configuration reference, path prefixes, security limitations, custom proxy, and open source sandbox runtime
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth across rebuilds, enforcing organization policy, restricting network egress, running without permission prompts, and reference container
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy configuration, CA certificate store, custom CA certs, mTLS authentication, and network access requirements
- [Data usage](references/claude-code-data-usage.md) — training policies, feedback and survey data handling, data retention by account type, encryption at rest, telemetry services, WebFetch domain safety check, and opt-out variables
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, healthcare BAA, usage policy, authentication and credential use restrictions
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what it covers and doesn't cover, features disabled under ZDR, data retention for policy violations, and how to request ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
