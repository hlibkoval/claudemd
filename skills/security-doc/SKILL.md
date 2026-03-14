---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- security architecture (permission-based model, built-in protections, prompt injection defenses, command blocklist, prompt fatigue mitigation, Accept Edits mode, MCP security, IDE security), sandboxing (OS-level enforcement via Seatbelt/bubblewrap, filesystem isolation allowWrite/denyWrite/denyRead path prefixes, network isolation domain restrictions allowedDomains allowManagedDomainsOnly, sandbox modes auto-allow/regular-permissions, /sandbox command, custom proxy httpProxyPort/socksProxyPort, excludedCommands, allowUnsandboxedCommands, dangerouslyDisableSandbox escape hatch, enableWeakerNestedSandbox, security limitations domain fronting unix sockets), devcontainers (reference devcontainer setup, Dockerfile, init-firewall.sh, firewall whitelisting, --dangerously-skip-permissions, VS Code Remote Containers), enterprise network configuration (proxy HTTPS_PROXY/HTTP_PROXY/NO_PROXY, custom CA certificates NODE_EXTRA_CA_CERTS, mTLS authentication CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, GitHub Enterprise IP allow lists), data usage (training policy consumer vs commercial, Development Partner Program, /bug feedback, session quality surveys, data retention 5-year/30-day/ZDR, local vs cloud data flow, telemetry Statsig/Sentry opt-out DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING, default behaviors by API provider Bedrock/Vertex/Foundry nonessential traffic), zero data retention (ZDR scope per-organization, covered vs not-covered features, disabled features under ZDR Claude Code on the web/remote sessions/feedback, policy violation retention, requesting ZDR), legal and compliance (Commercial Terms/Consumer Terms, BAA healthcare compliance, acceptable use policy, OAuth vs API key authentication restrictions, HackerOne vulnerability reporting, Anthropic Trust Center). Load when discussing Claude Code security, sandboxing, sandbox configuration, filesystem isolation, network isolation, devcontainers, development containers, enterprise network config, proxy configuration, mTLS, custom CA certificates, data usage, data retention, training policy, zero data retention, ZDR, legal compliance, BAA, healthcare compliance, prompt injection protection, MCP security, cloud execution security, telemetry opt-out, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, permission system, --dangerously-skip-permissions, security best practices, or vulnerability reporting.
user-invocable: false
---

# Security, Privacy & Compliance Documentation

This skill provides the complete official documentation for Claude Code security safeguards, sandboxing, devcontainers, enterprise network configuration, data usage policies, zero data retention, and legal compliance.

## Quick Reference

### Security Architecture

Claude Code uses a **permission-based architecture**: read-only by default, explicit approval required for edits, commands, and network requests.

| Protection | Description |
|:-----------|:------------|
| Sandboxed bash tool | OS-level filesystem and network isolation via `/sandbox` |
| Write access restriction | Can only write to the CWD and its subdirectories |
| Prompt fatigue mitigation | Allowlisting safe commands per-user, per-codebase, or per-org |
| Accept Edits mode | Batch accept edits while keeping prompts for side-effect commands |
| Command blocklist | `curl`, `wget` blocked by default to prevent fetching arbitrary content |
| Isolated context windows | Web fetch uses separate context to avoid prompt injection |
| Trust verification | First-time codebase runs and new MCP servers require trust confirmation |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Credential encryption | API keys and tokens stored encrypted |

#### Cloud Execution Security

Each cloud session runs in an isolated, Anthropic-managed VM with network access controls, credential protection via secure proxy, branch restrictions (current branch only), audit logging, and automatic cleanup.

Remote Control sessions run locally -- no cloud VMs, uses multiple short-lived scoped credentials over TLS.

### Sandboxing

OS-level enforcement: **Seatbelt** on macOS, **bubblewrap** on Linux/WSL2. WSL1 is not supported.

#### Prerequisites

macOS: works out of the box. Linux/WSL2: install `bubblewrap` and `socat`.

#### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without permission prompts; non-sandboxable commands fall back to normal flow |
| Regular permissions | All commands go through standard permission flow, even when sandboxed |

Enable with `/sandbox`. Both modes enforce the same filesystem and network restrictions.

#### Filesystem Isolation Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant write access to paths outside CWD |
| `sandbox.filesystem.denyWrite` | Block write access to specific paths |
| `sandbox.filesystem.denyRead` | Block read access to specific paths |

Path arrays are **merged** across settings scopes (managed, user, project), not replaced.

| Path prefix | Resolution |
|:------------|:-----------|
| `//` | Absolute from filesystem root (`//tmp/build` -> `/tmp/build`) |
| `~/` | Relative to home directory |
| `/` | Relative to the settings file's directory |
| `./` or none | Relative path resolved by sandbox runtime |

#### Network Isolation Settings

Network is controlled through a proxy server outside the sandbox. Only approved domains can be accessed. `allowManagedDomainsOnly` blocks non-allowed domains automatically instead of prompting.

#### Sandbox Escape Hatch

When a command fails due to sandbox restrictions, Claude may retry with `dangerouslyDisableSandbox` (goes through normal permissions). Disable with `"allowUnsandboxedCommands": false`. Use `excludedCommands` for tools incompatible with sandboxing (e.g., `docker`, `watchman`).

#### Custom Proxy

```json
{
  "sandbox": {
    "network": {
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

#### Security Limitations

- Network filtering restricts domains only, does not inspect traffic; domain fronting may bypass filtering
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- `enableWeakerNestedSandbox` on Linux considerably weakens security (for Docker without privileged namespaces)

### Devcontainers

Reference setup: [.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) with `devcontainer.json`, `Dockerfile`, and `init-firewall.sh`.

| Component | Purpose |
|:----------|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image, Node.js 20, development tools |
| `init-firewall.sh` | Network security rules (whitelist-only outbound) |

The firewall's default-deny policy allows `--dangerously-skip-permissions` for unattended operation. Compatible with VS Code Remote Containers extension.

### Enterprise Network Configuration

#### Proxy

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL (fallback) |
| `NO_PROXY` | Bypass proxy for specific hosts (space or comma separated; `*` for all) |

SOCKS proxies are not supported. Basic auth: include credentials in proxy URL.

#### Custom CA & mTLS

| Variable | Purpose |
|:---------|:--------|
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

#### Required Network Access

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Anthropic Console accounts |

For GitHub Enterprise Cloud with IP restrictions: enable IP allow list inheritance for installed GitHub Apps, or manually add ranges from the Anthropic API IP addresses page.

### Data Usage & Retention

#### Training Policy

| Account type | Policy |
|:-------------|:-------|
| Consumer (Free, Pro, Max) | Opt-in: user chooses whether data trains future models |
| Commercial (Team, Enterprise, API) | Not trained on, unless customer opts into Development Partner Program |

#### Data Retention

| Account type | Retention |
|:-------------|:----------|
| Consumer, training allowed | 5 years |
| Consumer, training disallowed | 30 days |
| Commercial, standard | 30 days |
| Commercial, ZDR | Not retained (per-organization, Claude for Enterprise only) |
| Local session cache | Up to 30 days (configurable) |

#### Telemetry Opt-Out

| Variable | Disables |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Statsig operational metrics |
| `DISABLE_ERROR_REPORTING` | Sentry error logging |
| `DISABLE_BUG_COMMAND` | `/bug` report submission |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All of the above at once |

Bedrock, Vertex, and Foundry providers disable all non-essential traffic by default.

### Zero Data Retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only. Enabled per-organization by Anthropic account team.

#### ZDR Scope

**Covered**: model inference calls (prompts and responses not retained).

**Not covered**: Chat on claude.ai, Cowork, Claude Code Analytics metadata, user/seat management, third-party integrations.

**Disabled under ZDR**: Claude Code on the Web, remote sessions from Desktop app, feedback submission (`/feedback`).

**Policy violations**: Anthropic may retain flagged data up to 2 years.

### Legal & Compliance

| Resource | URL |
|:---------|:----|
| Commercial Terms | https://www.anthropic.com/legal/commercial-terms |
| Consumer Terms | https://www.anthropic.com/legal/consumer-terms |
| Privacy Policy | https://www.anthropic.com/legal/privacy |
| Trust Center | https://trust.anthropic.com |
| HackerOne (vulnerability reports) | https://hackerone.com/anthropic-vdp |

**BAA (healthcare)**: automatically extends to Claude Code if customer has executed a BAA and has ZDR enabled. Applies per-organization.

**OAuth tokens** from Free/Pro/Max accounts are exclusively for Claude Code and claude.ai. Using them in other products or Agent SDK is not permitted. Developers building products must use API key authentication.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- security architecture, permission-based model, built-in protections, prompt injection defenses (command blocklist, input sanitization, context-aware analysis, isolated context windows), MCP security, IDE security, cloud execution security (isolated VMs, network controls, credential protection, audit logging), Remote Control security, best practices for teams and sensitive code, vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- OS-level enforcement (Seatbelt/bubblewrap), filesystem isolation (allowWrite/denyWrite/denyRead, path prefix resolution), network isolation (domain restrictions, allowManagedDomainsOnly, custom proxy), sandbox modes (auto-allow/regular-permissions), /sandbox command, excludedCommands, dangerouslyDisableSandbox escape hatch (allowUnsandboxedCommands to disable), enableWeakerNestedSandbox, security limitations (domain fronting, unix sockets, filesystem escalation), sandbox and permissions interaction, open source sandbox-runtime npm package
- [Development containers](references/claude-code-devcontainer.md) -- reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), firewall whitelisting, --dangerously-skip-permissions for unattended operation, VS Code Remote Containers integration, customization options, use cases (secure client work, team onboarding, CI/CD environments)
- [Enterprise network configuration](references/claude-code-network-config.md) -- proxy setup (HTTPS_PROXY, HTTP_PROXY, NO_PROXY, basic auth), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE), required URLs (api.anthropic.com, claude.ai, platform.claude.com), GitHub Enterprise Cloud IP allow lists
- [Data usage](references/claude-code-data-usage.md) -- training policy (consumer opt-in vs commercial no-train), Development Partner Program, /bug feedback retention, session quality surveys, data retention periods (5-year/30-day/ZDR), local and cloud data flow diagrams, telemetry services (Statsig, Sentry) with opt-out variables, default behaviors by API provider (Claude API/Vertex/Bedrock/Foundry)
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR scope and coverage (per-organization, Claude for Enterprise), covered vs not-covered features, disabled features under ZDR (Claude Code on the Web, remote sessions, feedback), data retention for policy violations, requesting ZDR enablement
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- Commercial Terms vs Consumer Terms, BAA healthcare compliance (requires ZDR), acceptable use policy, OAuth vs API key authentication restrictions, security vulnerability reporting via HackerOne, Anthropic Trust Center and Transparency Hub

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
