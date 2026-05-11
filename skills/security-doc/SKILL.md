---
name: security-doc
description: Complete official documentation for Claude Code security, sandboxing, dev containers, network configuration, data usage policies, legal compliance, and zero data retention — permission architecture, prompt injection protections, sandbox settings, proxy/mTLS config, data retention periods, and ZDR scope.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, dev containers, enterprise network configuration, data usage, legal compliance, and zero data retention.

## Quick Reference

### Permission Architecture

| Layer | What it controls | Scope |
| :--- | :--- | :--- |
| Permissions | Which tools Claude can call; evaluated before any tool runs | All tools (Bash, Read, Edit, WebFetch, MCP) |
| Sandboxing | OS-level filesystem and network restrictions on Bash subprocesses | Bash commands and child processes only |
| Accept Edits mode | Auto-approves file edits + `mkdir`, `touch`, `rm`, `mv`, `cp`, `sed` in working dir | File ops within project scope |
| Allowlists | Permit specific frequently-used commands per-user/codebase/org | Named commands |

Write access is confined to the folder where Claude Code was started and its subdirectories. Read access extends to the entire system (useful for system libraries).

### Built-in Security Protections

| Protection | Description |
| :--- | :--- |
| Permission system | Sensitive operations require explicit user approval |
| Command blocklist | `curl`, `wget`, and similar commands blocked by default |
| Network request approval | Tools making network requests require approval by default |
| Isolated web fetch | WebFetch uses a separate context window to avoid prompt injection |
| Trust verification | First-time codebase runs and new MCP servers require trust confirmation |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys and tokens are encrypted |

Trust verification is disabled with `-p` flag (non-interactive), except for `--worktree` which still requires it.

### Prompt Injection Best Practices

1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs to run scripts interacting with external web services
5. Report suspicious behavior with `/feedback`

**Windows WebDAV warning:** Do not enable WebDAV or allow `\\*` paths — it can bypass the permission system by triggering network requests to remote hosts.

### Sandbox Configuration

Enable with `/sandbox`. Requires `bubblewrap` + `socat` on Linux/WSL2; macOS uses Seatbelt (built-in). WSL1 is not supported.

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without approval; non-sandboxable commands fall back to normal flow |
| Regular permissions | All commands go through standard permission flow even when sandboxed |

**Key sandbox settings (`settings.json`):**

| Setting | Purpose |
| :--- | :--- |
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside working directory |
| `sandbox.filesystem.denyWrite` | Block subprocess writes to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess reads from specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.allowedDomains` | Domains Bash commands can reach |
| `sandbox.network.deniedDomains` | Domains blocked even if a wildcard would allow them |
| `sandbox.network.allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |
| `sandbox.failIfUnavailable` | Hard failure if sandbox can't start (for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the escape hatch mechanism |
| `excludedCommands` | Commands that always run outside the sandbox |

**Path prefix conventions for sandbox filesystem settings:**

| Prefix | Resolves to |
| :--- | :--- |
| `/` | Absolute filesystem path |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

Multiple settings scopes merge `allowWrite`/`denyWrite`/`denyRead`/`allowRead` arrays — they are combined, not replaced.

**OS-level enforcement:** macOS uses Seatbelt; Linux and WSL2 use bubblewrap. All child processes inherit the same security boundaries.

**Security limitations:**
- Built-in proxy does not inspect TLS; broad domains like `github.com` can enable data exfiltration via domain fronting
- `allowUnixSockets` can inadvertently grant access to powerful services (e.g., `/var/run/docker.sock`)
- `enableWeakerNestedSandbox` (Linux/Docker without privileged namespaces) considerably weakens security
- Overly broad `allowWrite` paths can enable privilege escalation

### Cloud Execution Security

| Control | Description |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in a separate Anthropic-managed VM |
| Network access controls | Configurable: None, Trusted, Full, or Custom allowlist |
| Credential protection | Auth handled through a secure proxy; GitHub token never enters the sandbox |
| Branch restrictions | Git push limited to current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions use local execution — all code stays on your machine, transmitted to the Anthropic API over TLS.

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

**Persist auth across rebuilds** — mount a named volume at `~/.claude`:

```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

**Enforce organization policy** — managed settings at highest precedence:

```dockerfile
RUN mkdir -p /etc/claude-code
COPY managed-settings.json /etc/claude-code/managed-settings.json
```

**Disable telemetry and auto-update:**

```json
"containerEnv": {
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
  "DISABLE_AUTOUPDATER": "1"
}
```

**Run without permission prompts:** pass `--dangerously-skip-permissions` only with a non-root `remoteUser` and network egress restrictions in place. To prevent engineers from using this flag, set `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

### Enterprise Network Configuration

All environment variables can also be set in `settings.json`.

**Proxy:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Space- or comma-separated bypass list; `*` to bypass all |

SOCKS proxies are not supported.

**CA certificates:**

| Variable / Setting | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE` | `bundled` (Mozilla CA), `system` (OS store), or `bundled,system` (default) |
| `NODE_EXTRA_CA_CERTS` | Path to custom enterprise CA `.pem` file |

**mTLS:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads and auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed and release notes |

When using Bedrock, Vertex, or Foundry, model traffic goes to those providers instead of `api.anthropic.com`. WebFetch still calls `api.anthropic.com` for domain safety checks unless `skipWebFetchPreflight: true` is set.

### Data Usage Policies

**Training:**

| Account type | Training policy |
| :--- | :--- |
| Consumer (Free, Pro, Max) | Opt-in training; configurable at [claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls) |
| Commercial (Team, Enterprise, API) | No training by default; opt-in via Developer Partner Program |

**Data retention:**

| Account type | Retention period |
| :--- | :--- |
| Consumer — training allowed | 5 years |
| Consumer — training declined | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | No server-side persistence after response |
| Local session transcripts | 30 days under `~/.claude/projects/`; adjust with `cleanupPeriodDays` |
| `/feedback` transcripts | 5 years |
| Session quality survey transcripts (if uploaded) | Up to 6 months |

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR for no persistence |
| Amazon Bedrock | AES-256, AWS-managed keys; customer-managed via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | Routes to Anthropic infrastructure with AES-256 |

All traffic to the LLM is encrypted in transit via TLS 1.2+.

**Telemetry opt-out environment variables:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Anthropic operational metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic (not WebFetch check) |

Telemetry and error reporting default to **off** on Bedrock, Vertex, and Foundry. Session quality surveys and the WebFetch domain safety check default to on for all providers.

**WebFetch domain safety check:** Before fetching a URL, Claude Code sends only the hostname to `api.anthropic.com` to check against Anthropic's blocklist. Results cached per hostname for 5 minutes. Disable with `skipWebFetchPreflight: true` in settings.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only (not Bedrock, Vertex, or Foundry).

**What ZDR covers:** Claude Code inference — prompts and responses are not stored after the response is returned.

**What ZDR does NOT cover:**

| Feature | Notes |
| :--- | :--- |
| Chat on claude.ai | Follows standard retention |
| Cowork sessions | Follows standard retention |
| Claude Code Analytics | Collects metadata (emails, usage stats), not prompts |
| User/seat management | Administrative data retained under standard policies |
| Third-party integrations / MCP servers | Review those services independently |

**Features disabled under ZDR:**

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side conversation history storage |
| Remote sessions from Desktop | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

ZDR is enabled per-organization — each new organization must have it enabled separately by the Anthropic account team. Policy violations may result in data retention for up to 2 years.

**BAA (Healthcare):** A Business Associate Agreement automatically extends to cover Claude Code when the customer has both a signed BAA and ZDR enabled.

### Reporting Security Issues

Report vulnerabilities through [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new). Do not disclose publicly before Anthropic has addressed the issue.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection protections, MCP security, cloud execution security, and security best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, sandbox modes, configuration, security benefits and limitations, relation to permissions
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth, enforcing org policy, restricting network egress, running without permission prompts
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate stores, mTLS authentication, network access requirements for firewalls
- [Data usage](references/claude-code-data-usage.md) — training policies, data retention periods, telemetry services, WebFetch domain safety check, default behaviors by API provider
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, BAA / healthcare compliance, acceptable use policy, authentication credential rules
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what is and isn't covered, features disabled under ZDR, how to request enablement

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
