---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, data usage, and compliance -- covering security architecture (permission-based design, built-in protections, user responsibility), prompt injection defenses (permission system, context-aware analysis, input sanitization, command blocklist, network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching, credential storage), sandboxing (filesystem isolation with Seatbelt/bubblewrap, network isolation via proxy, sandbox modes auto-allow/regular, /sandbox command, sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead, sandbox.network httpProxyPort/socksProxyPort, excludedCommands, allowUnsandboxedCommands, allowManagedDomainsOnly, failIfUnavailable, enableWeakerNestedSandbox, OS-level enforcement macOS/Linux/WSL2, open source @anthropic-ai/sandbox-runtime), devcontainers (Dockerfile, init-firewall.sh, devcontainer.json, --dangerously-skip-permissions, firewall whitelisting, VS Code Dev Containers extension), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY, NODE_EXTRA_CA_CERTS custom CA certificates, mTLS with CLAUDE_CODE_CLIENT_CERT/CLAUDE_CODE_CLIENT_KEY/CLAUDE_CODE_CLIENT_KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, installer URLs downloads.claude.ai/storage.googleapis.com, GitHub Enterprise IP allowlisting), data usage (training policy consumer vs commercial, Development Partner Program, /feedback data handling, session quality surveys with CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, data retention 5-year/30-day/ZDR, telemetry Statsig/Sentry with DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, default behaviors by API provider), cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging, automatic cleanup), remote control security (local execution, TLS, short-lived credentials), legal and compliance (Commercial Terms vs Consumer Terms, BAA with ZDR for healthcare, OAuth vs API key authentication, acceptable use policy, HackerOne vulnerability reporting), and zero data retention (ZDR scope covers inference on Claude for Enterprise, does not cover chat/Cowork/analytics/seat management/third-party integrations, features disabled under ZDR web/remote sessions/feedback, per-organization enablement, 2-year retention for policy violations). Load when discussing Claude Code security, sandboxing, prompt injection, data privacy, data retention, zero data retention, ZDR, enterprise network configuration, proxy setup, mTLS, custom CA certificates, devcontainers, firewall rules, compliance, BAA, HIPAA, legal terms, telemetry, data training policy, MCP security, cloud execution security, or any security-related topic.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data usage, network configuration, and compliance.

## Quick Reference

### Security Architecture

| Layer | Description |
|:------|:------------|
| **Permission system** | Read-only by default; explicit approval required for edits, commands, network requests |
| **Sandboxing** | OS-level filesystem and network isolation for bash commands (`/sandbox` to enable) |
| **Command blocklist** | Blocks `curl`, `wget`, and other risky web-fetching commands by default |
| **Write restriction** | Claude Code can only write to the working directory and its subdirectories |
| **Prompt injection detection** | Context-aware analysis, input sanitization, command injection detection, fail-closed matching |
| **Trust verification** | Required on first-time codebase runs and new MCP servers (disabled with `-p` flag) |
| **Isolated context windows** | Web fetch uses a separate context window to avoid injecting malicious prompts |
| **Credential storage** | API keys and tokens are encrypted |

### Sandboxing

| Setting | Purpose |
|:--------|:--------|
| `/sandbox` | Enable sandboxing interactively (choose auto-allow or regular permissions mode) |
| `sandbox.enabled` | Enable/disable sandboxing in settings |
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside the working directory |
| `sandbox.filesystem.denyWrite` | Block subprocess write access to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port for network filtering |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port for network filtering |
| `sandbox.allowedDomains` | Domains bash commands can reach |
| `sandbox.excludedCommands` | Commands that run outside the sandbox (e.g., `docker`) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the escape hatch for unsandboxed retries |
| `sandbox.allowManagedDomainsOnly` | Block non-allowed domains automatically instead of prompting |
| `sandbox.failIfUnavailable` | Hard failure if sandbox cannot start (for managed deployments) |
| `sandbox.enableWeakerNestedSandbox` | Weaker sandbox for Docker environments without privileged namespaces |

**OS enforcement:** macOS uses Seatbelt; Linux/WSL2 uses bubblewrap. WSL1 is not supported.

**Path prefixes in sandbox settings:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `/` | Absolute path from filesystem root | `/tmp/build` |
| `~/` | Relative to home directory | `~/.kube` |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) | `./output` |

**Linux prerequisites:** `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) or `sudo dnf install bubblewrap socat` (Fedora).

**Sandbox modes:**
- **Auto-allow mode** -- Sandboxed commands run without permission prompts; non-sandboxable commands fall back to regular permission flow
- **Regular permissions mode** -- All commands go through standard permission flow even when sandboxed

**Open source runtime:** `npx @anthropic-ai/sandbox-runtime <command>` -- available for use in your own agent projects.

### Enterprise Network Configuration

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL (fallback) |
| `NO_PROXY` | Bypass proxy for specific hosts (space or comma separated; `*` for all) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS authentication |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required URLs:**

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Anthropic Console accounts |
| `downloads.claude.ai` | Native installer, update checks, manifests, executables |
| `storage.googleapis.com` | Legacy download bucket (deprecation in progress) |

For GitHub Enterprise Cloud with IP restrictions: enable IP allow list inheritance for installed GitHub Apps, or manually add Anthropic API IP addresses.

### Data Usage and Retention

| Account type | Training policy | Default retention |
|:-------------|:----------------|:------------------|
| **Free, Pro, Max** (consumer) | Opt-in/out via privacy settings at claude.ai/settings/data-privacy-controls | 5 years (training on) / 30 days (training off) |
| **Team, Enterprise, API** (commercial) | Not used for training unless opted into Development Partner Program | 30 days standard |
| **Enterprise with ZDR** | Not used for training | Zero data retention (prompts and responses not stored after response is returned) |

### Telemetry Controls

| Variable | Controls |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Disable Statsig metrics telemetry |
| `DISABLE_ERROR_REPORTING` | Disable Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential traffic (telemetry, errors, surveys) |

Telemetry, error reporting, and feedback are **off by default** for Bedrock, Vertex, and Foundry providers. Session quality surveys are on for all providers.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Enabled per-organization by Anthropic account team.

**ZDR covers:** Model inference calls (prompts and responses not retained).

**ZDR does not cover:** Chat on claude.ai, Cowork, Claude Code Analytics metadata, user/seat management, third-party integrations.

**Features disabled under ZDR:** Claude Code on the Web, remote sessions from Desktop app, `/feedback` submission.

**Policy violations:** Data may be retained up to 2 years if flagged for Usage Policy violation.

### Cloud Execution Security

| Control | Description |
|:--------|:------------|
| Isolated VMs | Each cloud session runs in an isolated, Anthropic-managed VM |
| Network access controls | Limited by default; configurable to disable or allow specific domains |
| Credential protection | GitHub auth via secure proxy; credentials never enter the sandbox |
| Branch restrictions | Git push restricted to the current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Environments terminated after session completion |

**Remote Control** sessions run locally on your machine (no cloud VMs). Connection uses multiple short-lived, narrowly scoped credentials over TLS.

### Devcontainers

Reference setup: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

| Component | Purpose |
|:----------|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image and installed tools (Node.js 20, git, ZSH, fzf) |
| `init-firewall.sh` | Network security rules (default-deny, whitelisted domains only) |

Enables `claude --dangerously-skip-permissions` for unattended operation. Use only with trusted repositories.

### Legal and Compliance

| Topic | Details |
|:------|:--------|
| **Commercial Terms** | Team, Enterprise, API users: [anthropic.com/legal/commercial-terms](https://www.anthropic.com/legal/commercial-terms) |
| **Consumer Terms** | Free, Pro, Max users: [anthropic.com/legal/consumer-terms](https://www.anthropic.com/legal/consumer-terms) |
| **BAA (Healthcare)** | Extends to Claude Code automatically if customer has executed BAA and has ZDR activated (per-organization) |
| **OAuth authentication** | For Claude Code and claude.ai only; not permitted in third-party products or Agent SDK |
| **API key authentication** | Required for developers building products via Claude Console or cloud providers |
| **Vulnerability reporting** | [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) |
| **Trust Center** | [trust.anthropic.com](https://trust.anthropic.com) (SOC 2 Type 2, ISO 27001) |

### Best Practices

1. Review all suggested changes before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external web services
5. Use project-specific permission settings for sensitive repositories
6. Consider devcontainers for additional isolation
7. Audit permission settings with `/permissions`
8. Use managed settings to enforce organizational standards
9. Monitor usage through OpenTelemetry metrics
10. Report suspicious behavior with `/feedback`

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Security foundation, permission-based architecture, built-in protections (sandboxed bash, write restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection defenses (permission system, context-aware analysis, input sanitization, command blocklist, network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching, credential storage), privacy safeguards, MCP security, IDE security, cloud execution security (isolated VMs, network controls, credential protection, branch restrictions, audit logging), remote control security, best practices for sensitive code and team security, vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- Filesystem isolation (default writes to cwd, configurable allowWrite/denyWrite/denyRead/allowRead, path prefix resolution), network isolation (domain restrictions, user confirmation, custom proxy, comprehensive coverage), OS-level enforcement (Seatbelt on macOS, bubblewrap on Linux/WSL2), sandbox modes (auto-allow vs regular permissions), configuration (sandbox settings in settings.json, excludedCommands, allowUnsandboxedCommands, allowManagedDomainsOnly, failIfUnavailable), security benefits (prompt injection protection, reduced attack surface, transparent operation), security limitations (network filtering, Unix socket escalation, filesystem permission escalation, enableWeakerNestedSandbox), relationship with permissions, advanced usage (custom proxy, integration with security tools), open source sandbox-runtime npm package
- [Development Containers](references/claude-code-devcontainer.md) -- Reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), key features (Node.js 20, firewall, ZSH, VS Code integration, session persistence), security features (whitelisted domains, default-deny policy, startup verification, isolation), customization options, example use cases (secure client work, team onboarding, CI/CD environments)
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- Proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY, basic authentication), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), required network URLs, GitHub Enterprise Cloud IP allowlisting, GitHub Enterprise Server firewall configuration
- [Data Usage](references/claude-code-data-usage.md) -- Data training policy (consumer vs commercial, Development Partner Program), feedback and survey data handling, data retention (consumer 5-year/30-day, commercial 30-day, ZDR), data access and flow diagrams (local and cloud), telemetry services (Statsig, Sentry), default behaviors by API provider (Claude API, Vertex, Bedrock, Foundry)
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- License and legal agreements (Commercial Terms, Consumer Terms), commercial agreements (1P and 3P), healthcare compliance (BAA with ZDR), acceptable use policy, authentication and credential use restrictions (OAuth vs API keys), trust and safety resources, vulnerability reporting
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope (covers inference on Claude for Enterprise, does not cover chat/Cowork/analytics/seat management/third-party integrations), features disabled under ZDR (web, remote sessions, /feedback), per-organization enablement, data retention for policy violations (up to 2 years), requesting ZDR, transitioning from API to Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
