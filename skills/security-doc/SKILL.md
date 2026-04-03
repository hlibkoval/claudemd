---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, legal compliance, and zero data retention. Covers security architecture (permission-based system, built-in protections, prompt injection defenses, command blocklist, input sanitization, context-aware analysis), sandboxing (filesystem isolation with Seatbelt/bubblewrap, network isolation via proxy, sandbox modes auto-allow/regular-permissions, /sandbox command, sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead, sandbox.network.httpProxyPort/socksProxyPort, excludedCommands, allowUnsandboxedCommands, allowManagedDomainsOnly, allowUnixSockets, enableWeakerNestedSandbox, sandbox.failIfUnavailable, OS-level enforcement macOS/Linux/WSL2, open-source sandbox-runtime npm package), devcontainers (reference devcontainer setup, Dockerfile, init-firewall.sh, --dangerously-skip-permissions, firewall whitelisting, VS Code Dev Containers extension), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY, NODE_EXTRA_CA_CERTS, mTLS with CLAUDE_CODE_CLIENT_CERT/CLAUDE_CODE_CLIENT_KEY/CLAUDE_CODE_CLIENT_KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com/storage.googleapis.com/downloads.claude.ai, GitHub Enterprise IP allowlisting), data usage (training policy consumer vs commercial, Development Partner Program, /feedback data, session quality surveys, data retention 5-year/30-day/ZDR, telemetry Statsig/Sentry, DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING/DISABLE_FEEDBACK_COMMAND/CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY/CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, default behaviors by API provider), legal and compliance (Commercial Terms, Consumer Terms, BAA with ZDR, acceptable use policy, OAuth vs API key authentication, HackerOne vulnerability reporting), zero data retention (ZDR scope, features disabled under ZDR including Claude Code on the Web and remote sessions and /feedback, ZDR does not cover chat/Cowork/analytics/seat management/third-party integrations, data retention for policy violations up to 2 years, requesting ZDR for Claude for Enterprise). Load when discussing Claude Code security, sandboxing, sandbox configuration, devcontainers, network configuration, proxy setup, mTLS, data usage, data retention, training policy, telemetry, zero data retention, ZDR, legal compliance, BAA, HIPAA, prompt injection, permission system, firewall rules, filesystem isolation, network isolation, bubblewrap, Seatbelt, enterprise network, custom CA certificates, or any security-related topic for Claude Code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security -- permission-based architecture, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal compliance, and zero data retention.

## Quick Reference

### Security Architecture

| Layer | Protection |
|:------|:-----------|
| **Permission system** | Read-only by default; explicit approval for edits, commands, and tool use |
| **Sandboxing** | OS-level filesystem and network isolation for bash commands |
| **Command blocklist** | Blocks risky commands (`curl`, `wget`) by default |
| **Input sanitization** | Prevents command injection by processing user inputs |
| **Context-aware analysis** | Detects potentially harmful instructions by analyzing full request |
| **Trust verification** | First-time codebase runs and new MCP servers require trust verification (disabled with `-p` flag) |
| **Command injection detection** | Suspicious bash commands require manual approval even if previously allowlisted |
| **Fail-closed matching** | Unmatched commands default to requiring manual approval |
| **Isolated context windows** | Web fetch uses a separate context window to avoid prompt injection |
| **Secure credential storage** | API keys and tokens are encrypted |

### Prompt Injection Best Practices

1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external web services
5. Report suspicious behavior with `/feedback`

### Cloud Execution Security

| Control | Description |
|:--------|:-----------|
| Isolated VMs | Each session runs in an isolated, Anthropic-managed VM |
| Network access controls | Limited by default; configurable to disable or allow specific domains |
| Credential protection | Auth handled via secure proxy; GitHub credentials never enter sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions run locally (no cloud VMs); data flows over TLS via Anthropic API with short-lived, narrowly scoped credentials.

### Sandboxing

#### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands run without permission prompts; non-sandboxable commands fall back to regular flow |
| **Regular permissions** | All commands go through standard permission flow even when sandboxed |

Enable with `/sandbox`. Both modes enforce the same filesystem and network restrictions.

#### OS-Level Enforcement

| Platform | Technology |
|:---------|:-----------|
| macOS | Seatbelt (built-in) |
| Linux | bubblewrap + socat (install required) |
| WSL2 | bubblewrap + socat (same as Linux) |
| WSL1 | Not supported |

#### Filesystem Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside working directory |
| `sandbox.filesystem.denyWrite` | Block subprocess write access to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reading within a `denyRead` region (takes precedence) |

Path prefix conventions:

| Prefix | Meaning |
|:-------|:--------|
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

Settings arrays from multiple scopes are **merged**, not replaced.

#### Network Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `allowedDomains` | Domains bash commands can reach |
| `allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |

#### Sandbox Escape and Safety Settings

| Setting | Purpose |
|:--------|:--------|
| `excludedCommands` | Commands forced to run outside sandbox |
| `allowUnsandboxedCommands` | Set `false` to disable the escape hatch entirely |
| `sandbox.failIfUnavailable` | Set `true` to hard-fail if sandbox cannot start |
| `allowUnixSockets` | Grant access to unix sockets (use with caution) |
| `enableWeakerNestedSandbox` | Weaker sandbox for Docker environments (considerably reduces security) |

#### Security Limitations

- Network filtering restricts domains only; does not inspect traffic content
- Broad domains (e.g., `github.com`) may allow data exfiltration
- Domain fronting may bypass network filtering
- `allowUnixSockets` can enable privilege escalation (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- `enableWeakerNestedSandbox` considerably weakens security

#### Sandbox Open Source

The sandbox runtime is available as `@anthropic-ai/sandbox-runtime` on npm. Can sandbox any program:

```
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

### Devcontainer

Reference setup at `github.com/anthropics/claude-code/tree/main/.devcontainer` with three components:

| File | Purpose |
|:-----|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image, installed tools (Node.js 20, git, ZSH, fzf) |
| `init-firewall.sh` | Network security rules (default-deny, whitelisted domains only) |

Enables `claude --dangerously-skip-permissions` for unattended operation. Works with VS Code Dev Containers extension.

### Enterprise Network Configuration

#### Proxy Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass proxy (space or comma separated; `*` for all) |

SOCKS proxies are not supported. All variables can also be set in `settings.json`.

#### Custom CA and mTLS

| Variable | Purpose |
|:---------|:--------|
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

#### Required URLs

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication (claude.ai accounts) |
| `platform.claude.com` | Authentication (Anthropic Console accounts) |
| `storage.googleapis.com` | Native installer, auto-updater binary |
| `downloads.claude.ai` | Install script, version pointers, manifests, signing keys, plugin executables |

For GitHub Enterprise Cloud with IP restrictions: enable IP allow list inheritance for installed GitHub Apps, or manually add Anthropic API IP addresses.

### Data Usage

#### Training Policy

| Plan | Policy |
|:-----|:-------|
| Free, Pro, Max (consumer) | User chooses whether data is used for training; controlled in privacy settings |
| Team, Enterprise, API (commercial) | Anthropic does not train on data unless customer opts into Development Partner Program |

#### Data Retention

| Account Type | Retention |
|:-------------|:----------|
| Consumer (training allowed) | 5 years |
| Consumer (training not allowed) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Not retained after response returned |
| Local session cache | Up to 30 days (configurable) |

#### Telemetry and Opt-Out

| Variable | Disables |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Statsig metrics |
| `DISABLE_ERROR_REPORTING` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic (including surveys) |

Default behaviors by provider: Statsig, Sentry, and `/feedback` are **on** for Claude API, **off** for Vertex/Bedrock/Foundry. Session quality surveys are **on** for all providers.

### Legal and Compliance

| Topic | Details |
|:------|:--------|
| **Commercial Terms** | Team, Enterprise, API users |
| **Consumer Terms** | Free, Pro, Max users |
| **BAA (HIPAA)** | Extends to Claude Code if customer has BAA + ZDR enabled; per-organization |
| **Acceptable Use** | Subject to Anthropic Usage Policy |
| **OAuth tokens** | For Claude Code and claude.ai only; using in other products violates Consumer Terms |
| **API keys** | Required for Agent SDK, third-party products, and developer integrations |
| **Vulnerability reporting** | HackerOne program |

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses not stored after response returned.

#### ZDR Scope

**Covers**: model inference calls through Claude Code on Claude for Enterprise (any Claude model).

**Does not cover**: chat on claude.ai, Cowork, Claude Code Analytics (collects metadata only), user/seat management, third-party integrations. These follow standard retention policies.

#### Features Disabled Under ZDR

| Feature | Reason |
|:--------|:-------|
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions from Desktop app | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

#### Policy Violation Retention

Even with ZDR, Anthropic may retain data for up to 2 years for law compliance or Usage Policy violations.

#### Requesting ZDR

Contact your Anthropic account team. ZDR is enabled per-organization; each new organization requires separate enablement. All enablement actions are audit-logged.

### Security Best Practices

**Working with sensitive code:**
- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repositories
- Consider devcontainers for additional isolation
- Audit permission settings with `/permissions`

**Team security:**
- Use managed settings to enforce organizational standards
- Share approved permission configurations through version control
- Monitor usage through OpenTelemetry metrics
- Audit config changes with `ConfigChange` hooks

**Reporting vulnerabilities:**
1. Do not disclose publicly
2. Report through HackerOne program
3. Include detailed reproduction steps
4. Allow time for remediation before disclosure

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Security architecture, permission system, prompt injection protections, MCP security, cloud execution security, IDE security, best practices, vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) -- Filesystem and network isolation, OS-level enforcement (Seatbelt/bubblewrap), sandbox modes, configuration (allowWrite/denyWrite/denyRead/allowRead, network proxy, excludedCommands), security benefits, limitations, open-source sandbox-runtime
- [Development Containers](references/claude-code-devcontainer.md) -- Reference devcontainer setup, Dockerfile, firewall rules, --dangerously-skip-permissions, VS Code integration, customization
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- Proxy configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication, required URLs and firewall allowlisting
- [Data Usage](references/claude-code-data-usage.md) -- Training policy (consumer vs commercial), data retention periods, telemetry services (Statsig/Sentry), opt-out environment variables, default behaviors by API provider
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- Commercial and Consumer Terms, BAA/HIPAA compliance with ZDR, acceptable use policy, authentication restrictions, HackerOne vulnerability reporting
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope and coverage, features disabled under ZDR, policy violation retention, requesting ZDR for Claude for Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
