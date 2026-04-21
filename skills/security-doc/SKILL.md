---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, sandboxing, prompt injection protections, devcontainers, enterprise network configuration, data usage policies, legal compliance, and zero data retention.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, and compliance.

## Quick Reference

### Permission-based architecture

- **Default**: read-only access; write/exec requires explicit user approval
- **Write scope**: confined to the working directory and its subdirectories; reads may extend outside
- **Allowlisting**: frequently used safe commands can be allowlisted per-user, per-project, or per-org
- **Accept Edits mode**: batch-accept file edits while keeping command approval prompts

### Prompt injection protections

| Protection | Details |
| :--- | :--- |
| Permission system | Sensitive ops always require explicit approval |
| Command blocklist | `curl`, `wget`, and similar commands blocked by default |
| Isolated web fetch | Fetched content processed in a separate context window |
| Trust verification | New codebases and MCP servers require trust confirmation |
| Command injection detection | Suspicious bash commands flagged even if allowlisted |
| Fail-closed matching | Unrecognized commands default to requiring manual approval |
| Credential storage | API keys and tokens encrypted at rest |

Windows WebDAV paths (`\\*`) should not be used with Claude Code — WebDAV is deprecated by Microsoft and can bypass the permission system.

### Sandboxing

Enable with `/sandbox` in the Claude Code terminal.

| Feature | Details |
| :--- | :--- |
| Filesystem isolation | Read/write restricted to CWD by default; configurable via `sandbox.filesystem.allowWrite` / `denyWrite` / `denyRead` / `allowRead` |
| Network isolation | Domain allowlist enforced through an out-of-sandbox proxy; unknown domains prompt the user |
| OS enforcement | macOS: Seatbelt; Linux/WSL2: bubblewrap (`sudo apt-get install bubblewrap socat`) |
| Sandbox modes | **Auto-allow**: sandboxed commands run without prompts; **Regular permissions**: all commands still prompt |
| Escape hatch | Blocked commands can retry outside sandbox via `dangerouslyDisableSandbox`; disable with `"allowUnsandboxedCommands": false` |
| Merging paths | `allowWrite`, `denyWrite`, `denyRead`, `allowRead` arrays merge across all settings scopes |

Path prefix conventions for sandbox filesystem settings:

| Prefix | Resolves to |
| :--- | :--- |
| `/` | Absolute filesystem path |
| `~/` | Home directory |
| `./` or no prefix | Project root (project settings) or `~/.claude` (user settings) |

**Security limitations**: broad domains like `github.com` risk data exfiltration; `allowUnixSockets` can expose powerful sockets (e.g. Docker); overly wide `allowWrite` can enable privilege escalation.

Sandbox runtime available as open source: `npx @anthropic-ai/sandbox-runtime <command>`

### Cloud execution security

| Control | Details |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in a separate Anthropic-managed VM |
| Network access | Limited by default; configurable per-session |
| Credential protection | GitHub auth via secure proxy — token never enters sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All cloud operations logged |
| Auto cleanup | VMs terminated after session ends |

Remote Control sessions use local execution; no cloud VMs involved.

### Development containers (devcontainer)

Reference setup: `github.com/anthropics/claude-code/tree/main/.devcontainer`

- Firewall restricts outbound connections to whitelisted domains (npm, GitHub, Claude API, etc.)
- Default-deny policy for all other external network access
- Enables `claude --dangerously-skip-permissions` for unattended operation
- Only use devcontainers with **trusted repositories** — credentials inside the container can still be exfiltrated by a malicious project

### Enterprise network configuration

| Setting | Details |
| :--- | :--- |
| `HTTPS_PROXY` / `HTTP_PROXY` | Route traffic through a corporate proxy (SOCKS not supported) |
| `NO_PROXY` | Bypass proxy for specific hosts (space- or comma-separated) |
| `CLAUDE_CODE_CERT_STORE` | `bundled` (Mozilla CA), `system` (OS trust store), or `bundled,system` (default) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM |
| `CLAUDE_CODE_CLIENT_CERT` / `CLAUDE_CODE_CLIENT_KEY` | Client certificate for mTLS authentication |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted mTLS private key |

Required network allowlist:

| URL | Purpose |
| :--- | :--- |
| `api.anthropic.com` | Claude API |
| `claude.ai` | claude.ai account auth |
| `platform.claude.com` | Anthropic Console auth |
| `storage.googleapis.com` | Binary downloads and auto-updater |
| `downloads.claude.ai` | Install script, manifests, plugin executables |
| `bridge.claudeusercontent.com` | Chrome integration WebSocket bridge |

### Data usage and retention

| Account type | Training default | Retention |
| :--- | :--- | :--- |
| Consumer (Free/Pro/Max) — training on | Opted in | 5 years |
| Consumer (Free/Pro/Max) — training off | Opted out | 30 days |
| Commercial (Team/Enterprise/API) | Off (unless opted in via Dev Partner Program) | 30 days standard |
| Commercial with ZDR | Off | No retention (see ZDR) |

Local caching: session transcripts stored at `~/.claude/projects/` for 30 days (configurable via `cleanupPeriodDays`).

Telemetry opt-outs:

| Variable | Effect |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Disable Statsig metrics |
| `DISABLE_ERROR_REPORTING=1` | Disable Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable all of the above at once |

Bedrock, Vertex, and Foundry users have Statsig, Sentry, and `/feedback` **off by default**; session quality surveys remain on by default for all providers.

### Zero Data Retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only. Contact your Anthropic account team to enable.

- Prompts and model responses not stored after the response is returned
- Enabled **per-organization** — each new org must be enabled separately
- Includes: cost controls, analytics dashboard, server-managed settings, audit logs

What ZDR does NOT cover:

| Feature | Notes |
| :--- | :--- |
| Chat on claude.ai | Follows standard retention |
| Cowork sessions | Follows standard retention |
| Claude Code Analytics | Stores usage metadata, not prompts |
| User/seat management | Administrative data retained |
| Third-party integrations | Review each service independently |

Features disabled under ZDR: Claude Code on the Web, Remote sessions from Desktop, `/feedback` submissions.

Policy violation exception: Anthropic may retain data for up to 2 years if a session is flagged for a usage policy violation.

### Legal and compliance

- **Consumer users**: [Consumer Terms of Service](https://www.anthropic.com/legal/consumer-terms)
- **Commercial users**: [Commercial Terms](https://www.anthropic.com/legal/commercial-terms)
- **BAA (healthcare)**: Automatically covers Claude Code API traffic when the org has both a BAA and ZDR enabled
- **Authentication**: OAuth tokens for subscription plan users; API keys for developers building products — do not route third-party user requests through Free/Pro/Max credentials
- **Vulnerability reporting**: [HackerOne VDP form](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)
- **Trust Center**: [trust.anthropic.com](https://trust.anthropic.com)

### Security best practices summary

- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Use devcontainers for additional isolation
- Audit permission settings with `/permissions`
- Enforce org standards via managed settings and version-controlled permission configs
- Monitor activity via OpenTelemetry metrics
- Audit or block settings changes with `ConfigChange` hooks

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection protections, MCP/IDE/cloud security, and best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, OS-level enforcement, configuration, limitations, and open source runtime
- [Development containers](references/claude-code-devcontainer.md) — preconfigured secure devcontainer with firewall, VS Code integration, and team onboarding
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificates, mTLS authentication, and required URL allowlist
- [Data usage](references/claude-code-data-usage.md) — training policies, data retention by account type, telemetry services, and opt-out env vars
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, healthcare BAA, usage policy, authentication rules
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, request process

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
