---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, sandboxing (filesystem + network isolation), prompt injection protections, data usage policies, network configuration for enterprises, dev containers, zero data retention, and legal/compliance requirements.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, and compliance.

## Quick Reference

### Permission-Based Architecture

| Feature | Behavior |
| :--- | :--- |
| Default mode | Read-only; write/execute require explicit approval |
| Write scope | Only working directory and subdirectories (no parent dirs) |
| Accept Edits mode | Auto-approves file edits + safe FS commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) in working dir |
| Trust verification | Required on first-run and for new MCP servers (disabled with `-p` flag) |
| Command blocklist | `curl`, `wget` and similar blocked by default |
| Credential storage | API keys/tokens encrypted at rest |

### Built-in Prompt Injection Protections

| Protection | Description |
| :--- | :--- |
| Permission system | Sensitive operations always require approval |
| Context-aware analysis | Detects harmful instructions in full request context |
| Input sanitization | Prevents command injection |
| Isolated WebFetch | Runs in separate context window to prevent prompt injection |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Network approval | Tools making network requests require user approval by default |

### Sandboxing Overview

| Aspect | Details |
| :--- | :--- |
| Enable | `/sandbox` command |
| macOS | Seatbelt (built-in, no install needed) |
| Linux / WSL2 | bubblewrap + socat (`apt-get install bubblewrap socat`) |
| WSL1 | Not supported |
| Filesystem default | Read/write to cwd; read-only to rest of system (except denied dirs) |
| Network default | Domain allowlist enforced via proxy (proxy does not inspect TLS) |

### Sandbox Modes

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without approval prompts; commands needing non-allowed network fall back to normal flow |
| Regular permissions | All commands go through standard permission flow even when sandboxed |

### Sandbox Filesystem Settings

| Setting | Purpose |
| :--- | :--- |
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to additional paths |
| `sandbox.filesystem.denyWrite` | Block write access to specific paths |
| `sandbox.filesystem.denyRead` | Block read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `allowUnsandboxedCommands: false` | Disable escape hatch; all commands must be sandboxed or in `excludedCommands` |
| `allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |

### Path Prefix Conventions (Sandbox Filesystem)

| Prefix | Resolves to |
| :--- | :--- |
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

Note: settings arrays (`allowWrite`, `denyWrite`, etc.) **merge** across settings scopes — they do not override.

### Sandbox Security Limitations

- Built-in proxy does not terminate/inspect TLS — domain fronting possible with broad allowlists (e.g. `github.com`)
- `allowUnixSockets` can grant access to powerful services (e.g. Docker socket = host access)
- Overly broad `allowWrite` to `$PATH` dirs or shell config files enables privilege escalation
- Linux `enableWeakerNestedSandbox` mode significantly weakens isolation (Docker without privileged namespaces)

### OS-Level Enforcement

| Platform | Mechanism |
| :--- | :--- |
| macOS | Seatbelt |
| Linux | bubblewrap |
| WSL2 | bubblewrap |
| WSL1 | Not supported |

### Cloud Execution Security

| Control | Detail |
| :--- | :--- |
| Isolated VMs | Each session in an Anthropic-managed VM |
| Network access | Limited by default; configurable per-domain |
| Credential protection | GitHub auth via secure proxy with scoped credential |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session |

### Network Configuration (Enterprise)

**Required URLs to allowlist:**

| URL | Purpose |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads + auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed + marketplace install counts |

**Proxy environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Comma- or space-separated bypass list; `*` bypasses all |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM |
| `CLAUDE_CODE_CERT_STORE` | `bundled`, `system`, or `bundled,system` (default) |
| `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

Note: Claude Code does not support SOCKS proxies.

### Data Usage Policies

| User type | Training | Retention |
| :--- | :--- | :--- |
| Consumer (Free/Pro/Max) with training on | Data may train models | 5-year retention |
| Consumer with training off | No model training | 30-day retention |
| Commercial (Team/Enterprise/API) | Not used for training (unless opted in via Dev Partner Program) | 30-day retention |
| ZDR (Enterprise) | Not stored after response | No server-side persistence |

**Telemetry opt-out environment variables:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Operational metrics to Anthropic |
| `DISABLE_ERROR_REPORTING=1` | Error logging to Sentry |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command data upload |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic (surveys, etc.) |

Note: `skipWebFetchPreflight: true` in settings disables the WebFetch domain safety check (hostname sent to `api.anthropic.com` before each fetch).

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR available |
| Amazon Bedrock | AES-256 (AWS-managed); CMEK via AWS KMS |
| Google Cloud Vertex AI | Google-managed; CMEK available |
| Microsoft Foundry | AES-256 disk encryption |

### Zero Data Retention (ZDR)

- Available for Claude Code on Claude for Enterprise only
- Prompts and responses not stored after response is returned
- Enabled per-organization — each org must be enabled separately by Anthropic account team
- Automatically extends BAA coverage when ZDR is active
- Features disabled under ZDR: Claude Code on the web, Remote sessions from Desktop, `/feedback` command

**ZDR does not cover:** claude.ai chat, Cowork, Claude Code Analytics (metadata still collected), user/seat management data, third-party integrations.

### Dev Container Key Points

- Install via `ghcr.io/anthropics/devcontainer-features/claude-code:1.0` in `devcontainer.json`
- Persist `~/.claude` across rebuilds with a named volume mount
- Organization policy: copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` in Dockerfile
- Skip permission prompts with `--dangerously-skip-permissions` (requires non-root user; pair with network egress restrictions)
- Disable auto-update: `DISABLE_AUTOUPDATER=1` in `containerEnv`
- Sandbox open-source runtime: `npx @anthropic-ai/sandbox-runtime <command>`

### Security Best Practices Summary

1. Review all suggested changes before approval
2. Avoid piping untrusted content directly to Claude
3. Use dev containers for additional isolation
4. Enable sandboxing (`/sandbox`) for autonomous agent work
5. Use managed settings to enforce org-wide policy
6. Monitor activity via OpenTelemetry metrics
7. Audit/block settings changes with `ConfigChange` hooks
8. Report vulnerabilities via [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission-based architecture, prompt injection protections, MCP security, cloud execution security, and best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, sandbox modes, configuration, OS-level enforcement, security limitations, and custom proxy configuration
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth, enforcing org policy, restricting network egress, and running without permission prompts
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificates, mTLS, required URL allowlist, and provider-specific routing
- [Data usage](references/claude-code-data-usage.md) — training policies, data retention by account type, telemetry services, WebFetch domain safety check, and encryption at rest
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, BAA/healthcare compliance, acceptable use, authentication credential policies
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, covered/excluded features, disabled features, and how to request ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
