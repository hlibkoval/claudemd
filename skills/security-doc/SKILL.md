---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, prompt injection protections, sandboxing, network configuration, data usage and retention, zero data retention, dev containers, and legal compliance.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code's security model, data handling, network configuration, sandboxing, dev containers, and legal compliance.

## Quick Reference

### Permission Architecture

- **Default**: read-only; explicit approval required for edits, commands, and bash execution
- **Write restriction**: Claude Code can only write within the directory where it was started (and subdirectories)
- **Accept Edits mode**: auto-approves file edits and a fixed set of filesystem commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) within the working directory; other bash commands still prompt
- **Allowlisting**: frequently-used safe commands can be allowlisted per-user, per-codebase, or per-organization

### Prompt Injection Protections

| Protection | Description |
| :--- | :--- |
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects potentially harmful instructions |
| Input sanitization | Prevents command injection |
| Command blocklist | Blocks `curl`, `wget`, and similar commands by default |
| Network request approval | Network-touching tools require user approval by default |
| Isolated context windows | WebFetch uses a separate context window |
| Trust verification | First-time codebase runs and new MCP servers require trust verification |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys and tokens are encrypted |

**Best practices with untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external web services
5. Report suspicious behavior with `/feedback`

### Cloud Execution Security

| Control | Detail |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in an isolated, Anthropic-managed VM |
| Network access controls | Limited by default; configurable to allow specific domains |
| Credential protection | Secure proxy translates scoped sandbox credential → GitHub token |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations in cloud environments are logged |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions use local execution; code stays on your machine and travels over TLS via the Anthropic API. No cloud VMs involved. Uses multiple short-lived, narrowly scoped credentials.

### MCP Security

- Allowed MCP servers are configured in source control as part of Claude Code settings
- Write your own MCP servers or use servers from providers you trust
- Anthropic does not manage or audit any MCP servers

### Security Best Practices

**Working with sensitive code:**
- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repositories
- Consider dev containers for additional isolation
- Regularly audit permission settings with `/permissions`

**Team security:**
- Use managed settings to enforce organizational standards
- Share approved permission configurations through version control
- Monitor usage through OpenTelemetry metrics
- Audit or block settings changes during sessions with `ConfigChange` hooks

**Reporting vulnerabilities:** HackerOne program — do not disclose publicly; include reproduction steps.

---

### Sandboxing

Enable with `/sandbox`. Uses OS-level primitives (Seatbelt on macOS, bubblewrap on Linux/WSL2). WSL1 not supported.

**Prerequisites (Linux/WSL2):**
```bash
# Ubuntu/Debian
sudo apt-get install bubblewrap socat
# Fedora
sudo dnf install bubblewrap socat
```

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run automatically without prompts; unsandboxable commands fall back to normal flow |
| Regular permissions | All commands go through standard permission flow even when sandboxed |

**Filesystem isolation:**

| Rule type | Setting | Notes |
| :--- | :--- | :--- |
| Allow writes | `sandbox.filesystem.allowWrite` | Paths merged across all settings scopes |
| Deny writes | `sandbox.filesystem.denyWrite` | Merged from all sources |
| Deny reads | `sandbox.filesystem.denyRead` | Merged from all sources |
| Allow reads (override deny) | `sandbox.filesystem.allowRead` | Takes precedence over `denyRead` |

**Path prefix conventions:**

| Prefix | Resolution |
| :--- | :--- |
| `/` | Absolute from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

**Network isolation:** proxy-based; controls domains reachable by all subprocesses. Use `allowedDomains` and `deniedDomains` in sandbox settings.

**Security limitations:**
- Built-in proxy does not inspect TLS; domain fronting is possible with broad allowlists
- `allowUnixSockets` can grant access to powerful services (e.g., Docker socket)
- Overly broad `allowWrite` to `$PATH` directories can enable privilege escalation
- `enableWeakerNestedSandbox` (Linux/Docker) considerably weakens security

**Escape hatch:** when a sandboxed command fails, Claude may retry with `dangerouslyDisableSandbox` (goes through normal permissions). Disable with `"allowUnsandboxedCommands": false`.

**What sandboxing does NOT cover:** built-in file tools (Read, Edit, Write) and computer use — these use the permission system directly.

**Open source sandbox runtime:**
```bash
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

---

### Enterprise Network Configuration

**Proxy environment variables:**
```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,example.com,.example.com"   # or * for all
```
SOCKS proxies are not supported.

**CA certificate configuration:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE` | Comma-separated list: `bundled`, `system` (default: `bundled,system`) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |

**mTLS authentication:**
```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="your-passphrase"   # optional
```

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads, native installer/updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed, release notes |

WebFetch domain safety check always calls `api.anthropic.com` regardless of model provider (disable with `skipWebFetchPreflight: true` in settings).

---

### Data Usage and Retention

**Training policy:**

| Account type | Default training use |
| :--- | :--- |
| Free, Pro, Max | Used for model improvement when setting is on; toggle at claude.ai/settings/data-privacy-controls |
| Team, Enterprise, API | Not used for training unless explicitly opted in (e.g., Developer Partner Program) |

**Data retention:**

| Account type | Standard retention | Notes |
| :--- | :--- | :--- |
| Consumer (training on) | 5 years | Supports model development |
| Consumer (training off) | 30 days | |
| Commercial (Team/Enterprise/API) | 30 days | ZDR available for Enterprise |
| Local session transcripts | 30 days default | Stored at `~/.claude/projects/`; adjust with `cleanupPeriodDays` |
| `/feedback` transcripts | 5 years | |
| Policy-flagged ZDR data | Up to 2 years | |

**Telemetry opt-outs:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Operational metrics (latency, usage patterns) |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command and transcript upload |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic at once (not WebFetch check) |

Default behaviors for Bedrock, Vertex, Foundry: telemetry, error reporting, and feedback are **off** by default; surveys and WebFetch safety check are **on** regardless of provider.

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR available |
| Amazon Bedrock | AES-256 with AWS-managed keys; CMEK via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | AES-256 via Anthropic infrastructure |

**WebFetch domain safety check:** sends only the hostname (not full URL) to `api.anthropic.com`; results cached 5 minutes per hostname.

---

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only. When enabled, prompts and responses are not stored after the response is returned (except for law/misuse compliance).

**ZDR scope — what IS covered:** Claude Code inference calls on Claude for Enterprise.

**ZDR scope — what is NOT covered:**

| Feature | Notes |
| :--- | :--- |
| Chat on claude.ai | Standard retention applies |
| Cowork | Standard retention applies |
| Claude Code Analytics | Collects productivity metadata (emails, usage stats); contribution metrics unavailable |
| User/seat management | Admin data retained under standard policies |
| Third-party integrations | Review those services independently |

**Features disabled under ZDR:**

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side storage |
| Remote sessions from Desktop app | Requires persistent session data |
| Feedback submission (`/feedback`) | Sends conversation data to Anthropic |

**ZDR enablement:** per-organization, not automatic for new orgs. Contact your Anthropic account team or [sales](https://www.anthropic.com/contact-sales) to request.

---

### Development Containers

Dev containers run Claude Code inside Docker for consistent, isolated environments. Commands execute inside the container; file edits appear in the local repository via bind mount.

**Install via Dev Container Feature:**
```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

**Persist auth and settings across rebuilds** (mount a named volume at `~/.claude`):
```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

**Enforce organization policy** (managed settings at highest precedence):
```dockerfile
RUN mkdir -p /etc/claude-code
COPY managed-settings.json /etc/claude-code/managed-settings.json
```

**Disable telemetry and auto-update in `containerEnv`:**
```json
"containerEnv": {
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
  "DISABLE_AUTOUPDATER": "1"
}
```

**Run without permission prompts:** pass `--dangerously-skip-permissions` (rejected when run as root). Pair with network egress restrictions. To prevent this flag entirely, set `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

**Security warning:** `--dangerously-skip-permissions` does not prevent data exfiltration of anything accessible inside the container (including `~/.claude` credentials). Only use with trusted repositories. Do not mount host secrets (`~/.ssh`, cloud credentials) into the container.

---

### Legal and Compliance

**Applicable licenses:**
- Commercial Terms of Service: Team, Enterprise, and Claude API users
- Consumer Terms of Service: Free, Pro, and Max users

**Healthcare (HIPAA/BAA):** BAA extends to Claude Code automatically when the customer has both a BAA and Zero Data Retention (ZDR) activated. ZDR must be enabled per organization.

**Authentication:**
- OAuth tokens: for subscription plan holders (Free, Pro, Max, Team, Enterprise) using Claude Code natively
- API keys: for developers building products/services; required for Agent SDK usage
- Third-party developers may not route requests through consumer plan credentials on behalf of users

**Security vulnerability reporting:** HackerOne — [submit here](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new). Do not disclose publicly.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection protections, MCP security, cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, sandbox modes, configuration, security limitations, advanced usage
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificates, mTLS, network allowlist requirements
- [Data usage](references/claude-code-data-usage.md) — training policy, data retention, telemetry services, encryption at rest, WebFetch safety check
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, enablement process
- [Development containers](references/claude-code-devcontainer.md) — installation, persistent volumes, organization policy, network egress, permission prompts
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, BAA/healthcare compliance, authentication policy, vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
