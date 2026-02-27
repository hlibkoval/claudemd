---
name: security-doc
description: Reference documentation for Claude Code security — permission-based architecture, prompt injection protections, sandboxing (filesystem and network isolation), devcontainers, enterprise network configuration (proxy, CA certs, mTLS), data usage and retention policies, zero data retention (ZDR), legal and compliance, MCP security, and cloud execution security.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, data privacy, and compliance.

## Quick Reference

### Built-in Security Protections

| Protection | Description |
|:-----------|:------------|
| Permission-based architecture | Read-only by default; explicit approval required for edits, commands, and network requests |
| Write access restriction | Can only write to the working directory and its subdirectories |
| Command blocklist | Blocks `curl`, `wget`, and similar commands that fetch arbitrary web content by default |
| Command injection detection | Suspicious bash commands require manual approval even if previously allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Isolated context windows | Web fetch uses a separate context to avoid injecting malicious prompts |
| Trust verification | First-time codebase runs and new MCP servers require trust confirmation |
| Secure credential storage | API keys and tokens are encrypted |
| Accept Edits mode | Batch accept edits while retaining permission prompts for side-effect commands |

### Sandboxing

Enable with `/sandbox`. Uses OS-level primitives: Seatbelt on macOS, bubblewrap on Linux/WSL2.

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without permission; unsandboxable commands fall back to normal flow |
| Regular permissions | All commands go through standard permission flow, even when sandboxed |

**Prerequisites (Linux/WSL2)**: `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) or `sudo dnf install bubblewrap socat` (Fedora).

**Filesystem isolation**: Read/write to CWD and subdirectories; read-only elsewhere; blocked outside sandbox.

**Network isolation**: Domain-based restrictions via proxy; only approved domains accessible; new domains trigger permission prompts.

**Escape hatch**: Commands that fail due to sandbox restrictions can retry outside the sandbox (goes through normal permissions). Disable with `"allowUnsandboxedCommands": false`.

### Enterprise Network Configuration

| Setting | Environment Variable | Purpose |
|:--------|:--------------------|:--------|
| HTTPS proxy | `HTTPS_PROXY` | Route traffic through corporate proxy |
| HTTP proxy | `HTTP_PROXY` | Fallback if HTTPS proxy unavailable |
| No proxy | `NO_PROXY` | Bypass proxy for specific hosts (space or comma separated) |
| Custom CA | `NODE_EXTRA_CA_CERTS` | Trust custom Certificate Authority |
| Client cert | `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate path |
| Client key | `CLAUDE_CODE_CLIENT_KEY` | mTLS private key path |
| Key passphrase | `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required URLs**: `api.anthropic.com`, `claude.ai`, `platform.claude.com`

### Data Retention

| Account Type | Retention |
|:-------------|:----------|
| Consumer (training ON) | 5 years |
| Consumer (training OFF) | 30 days |
| Commercial (Team, Enterprise, API) | 30 days |
| Zero Data Retention (Enterprise) | Not stored after response is returned |

### Telemetry Opt-Out

| Service | Env Variable to Disable |
|:--------|:-----------------------|
| Statsig (metrics) | `DISABLE_TELEMETRY=1` |
| Sentry (errors) | `DISABLE_ERROR_REPORTING=1` |
| Bug reports | `DISABLE_BUG_COMMAND=1` |
| Session surveys | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| All non-essential | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` |

Non-essential traffic is disabled by default for Bedrock, Vertex, and Foundry providers.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are not stored after the response is returned. ZDR is enabled per-organization; contact your Anthropic account team.

**Features disabled under ZDR**: Claude Code on the Web, Remote sessions from Desktop app, Feedback submission (`/feedback`).

**Not covered by ZDR**: Chat on claude.ai, Cowork, Analytics metadata, user/seat management, third-party integrations.

### Devcontainer Security

The [reference devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides isolated environments with firewall rules restricting outbound connections to whitelisted domains only. Enables `claude --dangerously-skip-permissions` for unattended operation within the container.

### Reporting Security Vulnerabilities

Report through [Anthropic's HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability). Do not disclose publicly. Include detailed reproduction steps.

### Legal Agreements

| Plan | Terms |
|:-----|:------|
| Team, Enterprise, API | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Free, Pro, Max | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |

Healthcare BAA automatically extends to Claude Code when the customer has ZDR activated.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection protections, MCP security, IDE security, cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, sandbox modes, OS-level enforcement, security benefits, advanced proxy configuration
- [Development Containers](references/claude-code-devcontainer.md) — devcontainer setup, firewall rules, customization, use cases for secure isolated environments
- [Enterprise Network Configuration](references/claude-code-network-config.md) — proxy servers, custom CA certificates, mTLS authentication, required URLs
- [Data Usage](references/claude-code-data-usage.md) — data training policy, retention periods, telemetry services, data flow diagrams, opt-out settings
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — license terms, BAA/healthcare compliance, acceptable use, authentication credential policies
- [Zero Data Retention](references/claude-code-zero-data-retention.md) — ZDR scope, covered and excluded features, disabled features, data retention for policy violations

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
