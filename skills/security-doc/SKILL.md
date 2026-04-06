---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, legal/compliance, and zero data retention. Covers permission-based architecture, prompt injection protections, MCP security, IDE security, cloud execution security, sandbox modes (auto-allow, regular permissions), filesystem isolation (Seatbelt on macOS, bubblewrap on Linux), network isolation via proxy, sandbox filesystem settings (allowWrite, denyWrite, denyRead, allowRead), OS-level enforcement, custom proxy configuration, devcontainer setup (Dockerfile, firewall, VS Code integration), enterprise network config (HTTPS_PROXY, HTTP_PROXY, NO_PROXY, NODE_EXTRA_CA_CERTS, mTLS with CLAUDE_CODE_CLIENT_CERT/KEY), required network URLs (api.anthropic.com, claude.ai, platform.claude.com), data training policies (consumer vs commercial), data retention periods (5-year with training, 30-day without, ZDR for Enterprise), telemetry services (Statsig, Sentry), telemetry env vars (DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, DISABLE_FEEDBACK_COMMAND, CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC), legal agreements (Commercial Terms, Consumer Terms), BAA/healthcare compliance, acceptable use policy, authentication credential use (OAuth vs API keys), zero data retention scope and limitations, features disabled under ZDR, and security best practices. Load when discussing security, sandboxing, sandbox configuration, devcontainers, network configuration, proxy setup, data usage, data retention, privacy, telemetry, legal compliance, ZDR, zero data retention, BAA, mTLS, prompt injection, MCP security, cloud execution security, or any security-related topic for Claude Code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data usage, network configuration, legal compliance, and zero data retention.

## Quick Reference

### Security Architecture

| Layer | Description |
|:------|:-----------|
| Permission system | Read-only by default; explicit approval for edits, commands, network requests |
| Sandboxed bash | OS-level filesystem and network isolation via `/sandbox` |
| Write restriction | Can only write to cwd and subdirectories |
| Command blocklist | `curl`, `wget` blocked by default |
| Trust verification | Required on first codebase run and new MCP servers (disabled with `-p` flag) |
| Command injection detection | Suspicious commands require manual approval even if allowlisted |
| Credential storage | API keys and tokens encrypted |

### Prompt Injection Protections

| Protection | Details |
|:-----------|:--------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects harmful instructions by analyzing full request |
| Input sanitization | Prevents command injection |
| Network request approval | Network tools require user approval by default |
| Isolated context windows | Web fetch uses separate context window |
| Fail-closed matching | Unmatched commands default to manual approval |

### Sandboxing

| Feature | Details |
|:--------|:--------|
| Enable | `/sandbox` command |
| macOS enforcement | Seatbelt (built-in) |
| Linux/WSL2 enforcement | bubblewrap + socat (`apt install bubblewrap socat`) |
| WSL1 | Not supported |
| Auto-allow mode | Sandboxed commands run without permission prompts |
| Regular permissions mode | All commands go through standard permission flow |
| Escape hatch | `dangerouslyDisableSandbox` parameter (disable with `allowUnsandboxedCommands: false`) |
| Open source runtime | `npx @anthropic-ai/sandbox-runtime <command>` |

### Sandbox Filesystem Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant write access to paths outside cwd |
| `sandbox.filesystem.denyWrite` | Block write access to specific paths |
| `sandbox.filesystem.denyRead` | Block read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start |
| `allowManagedReadPathsOnly` | Only managed `allowRead` entries respected |

### Sandbox Path Prefixes

| Prefix | Resolution |
|:-------|:-----------|
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

### Sandbox Network Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `allowedDomains` | Domains bash commands can reach |
| `allowManagedDomainsOnly` | Block non-allowed domains without prompting |

### Devcontainer Features

| Component | Purpose |
|:----------|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image and installed tools (Node.js 20) |
| `init-firewall.sh` | Network security rules (default-deny, whitelisted domains) |

Devcontainer enables `claude --dangerously-skip-permissions` for unattended operation. Reference setup: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

### Enterprise Network Configuration

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL (fallback) |
| `NO_PROXY` | Bypass proxy (space or comma separated; `*` for all) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM |
| `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

### Required Network URLs

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Console accounts |
| `storage.googleapis.com` | Binary downloads and auto-updater |
| `downloads.claude.ai` | Install script, version pointers, manifests, plugin executables |

### Data Training Policy

| Plan | Policy |
|:-----|:-------|
| Free, Pro, Max | User choice via privacy settings (on = data used for training) |
| Team, Enterprise, API | Not used for training unless opted into Developer Partner Program |
| Bedrock, Vertex, Foundry | Refer to platform-specific policies |

### Data Retention

| Scenario | Retention |
|:---------|:----------|
| Consumer, training allowed | 5 years |
| Consumer, training not allowed | 30 days |
| Commercial (Team, Enterprise, API) | 30 days |
| Zero data retention (Enterprise) | Not stored after response returned |
| ZDR policy violation | Up to 2 years |
| `/feedback` transcripts | 5 years |
| Local session cache | Up to 30 days (configurable) |

### Telemetry Environment Variables

| Variable | Effect |
|:---------|:-------|
| `DISABLE_TELEMETRY` | Disable Statsig metrics |
| `DISABLE_ERROR_REPORTING` | Disable Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential traffic including surveys |

### Default Telemetry by Provider

| Service | Claude API | Vertex/Bedrock/Foundry |
|:--------|:-----------|:----------------------|
| Statsig (metrics) | On by default | Off by default |
| Sentry (errors) | On by default | Off by default |
| `/feedback` reports | On by default | Off by default |
| Session quality surveys | On by default | On by default |

### Zero Data Retention (ZDR)

| Aspect | Details |
|:-------|:--------|
| Availability | Claude for Enterprise only |
| Scope | Model inference calls via Claude Code |
| Enablement | Per-organization, by Anthropic account team |
| Not covered | Chat on claude.ai, Cowork, analytics metadata, third-party integrations |
| Disabled features | Claude Code on the Web, Remote sessions from Desktop, `/feedback` |

### Legal Agreements

| Plan | Agreement |
|:-----|:----------|
| Team, Enterprise, API | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Free, Pro, Max | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |
| All | [Privacy Policy](https://www.anthropic.com/legal/privacy) |
| Healthcare (BAA) | Extends to Claude Code when ZDR is enabled on the organization |

### Security Vulnerability Reporting

Report via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability). Do not disclose publicly. Include reproduction steps.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Security safeguards, permission architecture, prompt injection protections, MCP security, cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) -- Filesystem and network isolation, sandbox modes, OS-level enforcement, configuration, security limitations
- [Development Containers](references/claude-code-devcontainer.md) -- Devcontainer setup, firewall configuration, VS Code integration, customization
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- Proxy setup, custom CA certificates, mTLS authentication, required URLs
- [Data Usage](references/claude-code-data-usage.md) -- Training policies, retention periods, telemetry services, data flow diagrams
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- License terms, BAA/healthcare compliance, acceptable use, authentication policies
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope, disabled features, data retention for policy violations, how to request ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
