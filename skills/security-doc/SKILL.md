---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal and compliance, and zero data retention -- security architecture (permission-based model, built-in protections, write access restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection protections (permission system, context-aware analysis, input sanitization, command blocklist, network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching), MCP security, IDE security, cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control sessions, security best practices (sensitive code review, team security with managed settings and OpenTelemetry, reporting via HackerOne), sandboxing (filesystem isolation with Seatbelt/bubblewrap, network isolation with proxy, sandbox modes auto-allow vs regular permissions, sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead, sandbox.network.allowedDomains, path prefixes / ~/ ./, OS-level enforcement macOS/Linux/WSL2, excludedCommands, allowUnsandboxedCommands, enableWeakerNestedSandbox, custom proxy httpProxyPort/socksProxyPort, security limitations domain fronting and Unix sockets and filesystem escalation), devcontainers (reference setup, Dockerfile, init-firewall.sh, --dangerously-skip-permissions, firewall rules, VS Code integration), enterprise network configuration (proxy setup HTTPS_PROXY/HTTP_PROXY/NO_PROXY, custom CA certificates NODE_EXTRA_CA_CERTS, mTLS authentication CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, GitHub Enterprise IP allow list), data usage (training policy consumer vs commercial, Development Partner Program, /feedback data, session quality surveys, data retention 5-year/30-day/ZDR, local data flow and dependencies, cloud execution data flow, telemetry Statsig/Sentry, defaults by API provider Claude/Vertex/Bedrock/Foundry, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING), legal and compliance (Commercial Terms, Consumer Terms, BAA/healthcare compliance with ZDR, acceptable use policy, OAuth vs API key authentication restrictions, HackerOne vulnerability reporting), zero data retention (ZDR scope for Claude for Enterprise, per-organization enablement, ZDR covers inference not chat/Cowork/Analytics/integrations, features disabled under ZDR including web sessions and remote sessions and /feedback, data retention for policy violations up to 2 years). Load when discussing Claude Code security, sandboxing, sandbox configuration, devcontainers, development containers, network configuration, proxy setup, enterprise network, mTLS, custom CA certificates, data usage, data retention, data training policy, privacy, telemetry, Statsig, Sentry, legal terms, compliance, BAA, healthcare compliance, HIPAA, zero data retention, ZDR, prompt injection protection, cloud execution security, MCP security, permission system security, security best practices, HackerOne, vulnerability reporting, firewall rules, --dangerously-skip-permissions, write access restriction, command blocklist, credential protection, or any security/privacy/compliance topic for Claude Code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, devcontainers, enterprise network configuration, data usage, legal and compliance, and zero data retention.

## Quick Reference

### Security Architecture

Claude Code uses a permission-based architecture with strict read-only defaults. Key built-in protections:

| Protection | Description |
|:-----------|:------------|
| Sandboxed bash tool | OS-level filesystem and network isolation via `/sandbox` |
| Write access restriction | Can only write to CWD and subdirectories; parent directories require explicit permission |
| Prompt fatigue mitigation | Allowlisting safe commands per-user, per-codebase, or per-organization |
| Accept Edits mode | Batch accept edits while maintaining command permission prompts |
| Command blocklist | Blocks risky web-fetching commands (`curl`, `wget`) by default |
| Network request approval | Tools making network requests require user approval by default |
| Trust verification | First-time codebase runs and new MCP servers require trust verification (disabled with `-p` flag) |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys and tokens are encrypted |

### Prompt Injection Protections

| Safeguard | Detail |
|:----------|:-------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects potentially harmful instructions by analyzing full request |
| Input sanitization | Prevents command injection by processing user inputs |
| Isolated context windows | Web fetch uses separate context to avoid injecting malicious prompts |

### Cloud Execution Security

| Control | Description |
|:--------|:------------|
| Isolated VMs | Each session runs in an isolated, Anthropic-managed VM |
| Network access controls | Limited by default; configurable to disable or allow specific domains |
| Credential protection | Auth handled via secure proxy with scoped credentials |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions run locally (no cloud VMs); the web interface connects to a local Claude Code process with short-lived, narrowly scoped credentials.

### Sandboxing

**OS-level enforcement:** macOS uses Seatbelt; Linux/WSL2 uses bubblewrap. WSL1 is not supported.

**Prerequisites:** macOS works out of the box. Linux/WSL2 requires `bubblewrap` and `socat`.

**Sandbox modes:**

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without permission; non-sandboxable commands fall back to normal flow |
| Regular permissions | All commands go through standard permission flow, even when sandboxed |

**Filesystem isolation:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant write access to paths outside CWD |
| `sandbox.filesystem.denyWrite` | Block writes to specific paths |
| `sandbox.filesystem.denyRead` | Block reads from specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within `denyRead` regions |

Path prefix resolution: `/` = absolute, `~/` = home-relative, `./` or bare = project-relative (in project settings) or `~/.claude`-relative (in user settings).

Arrays from multiple settings scopes are **merged**, not replaced.

**Network isolation:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.allowedDomains` | Domains accessible from sandbox (supports `*.example.com`) |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS5 proxy port |

**Key sandbox settings:**

| Setting | Default | Purpose |
|:--------|:--------|:--------|
| `sandbox.enabled` | false | Enable sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | true | Auto-approve sandboxed bash |
| `sandbox.excludedCommands` | -- | Commands that run outside sandbox |
| `sandbox.allowUnsandboxedCommands` | true | Allow `dangerouslyDisableSandbox` escape hatch |
| `sandbox.enableWeakerNestedSandbox` | false | For unprivileged Docker (weakens security) |

**Security limitations:** Network filtering restricts domains only (does not inspect traffic). Broad domains like `github.com` may allow exfiltration. Domain fronting may bypass filtering. `allowUnixSockets` for Docker socket grants host access. Overly broad filesystem write permissions enable escalation.

### Devcontainers

Reference devcontainer at [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer). Three components:

| File | Purpose |
|:-----|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image and installed tools (Node.js 20, git, ZSH, fzf) |
| `init-firewall.sh` | Network security rules (default-deny, whitelisted domains only) |

The container's isolation allows running `claude --dangerously-skip-permissions` for unattended operation. Devcontainers do not prevent exfiltration of data accessible inside the container, including Claude Code credentials.

### Enterprise Network Configuration

**Proxy configuration:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass list (space or comma separated; `*` bypasses all) |

SOCKS proxies are not supported. For proxies requiring NTLM/Kerberos, use an LLM Gateway.

**Custom CA certificates:**

```
NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem
```

**mTLS authentication:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key (optional) |

**Required network access:**

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication (claude.ai accounts) |
| `platform.claude.com` | Authentication (Console accounts) |
| `downloads.claude.ai` | Native installer and updates |

For GitHub Enterprise Cloud with IP restrictions, enable IP allow list inheritance for installed GitHub Apps.

### Data Usage

**Training policy:**

| Plan type | Policy |
|:----------|:-------|
| Consumer (Free, Pro, Max) | User-controlled opt-in for model improvement training |
| Commercial (Team, Enterprise, API) | Not used for training unless opted into Development Partner Program |

**Data retention:**

| Scenario | Retention |
|:---------|:----------|
| Consumer, training allowed | 5 years |
| Consumer, training not allowed | 30 days |
| Commercial, standard | 30 days |
| Commercial, ZDR | No retention (except for law/policy violations) |
| `/feedback` transcripts | 5 years |
| Local session caching | Up to 30 days (configurable) |

**Telemetry services:**

| Service | Data | Opt-out variable |
|:--------|:-----|:-----------------|
| Statsig | Operational metrics (latency, reliability, usage) -- no code or file paths | `DISABLE_TELEMETRY` |
| Sentry | Error logging | `DISABLE_ERROR_REPORTING` |
| `/feedback` | Full conversation history | `DISABLE_FEEDBACK_COMMAND` |
| Session quality surveys | Numeric rating only (1, 2, 3, or dismiss) -- no transcripts | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` |

Disable all non-essential traffic (including surveys): `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`.

**Defaults by provider:** Statsig, Sentry, and `/feedback` are on by default for Claude API, off by default for Vertex/Bedrock/Foundry. Session surveys are on for all providers.

### Legal and Compliance

| Agreement | Applies to |
|:----------|:-----------|
| [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) | Team, Enterprise, API users |
| [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) | Free, Pro, Max users |
| [Anthropic Usage Policy](https://www.anthropic.com/legal/aup) | All users |

**OAuth vs API key authentication:** OAuth tokens from Free/Pro/Max accounts are exclusively for Claude Code and claude.ai -- using them in other products (including Agent SDK) violates Consumer Terms. Developers building products must use API key authentication.

**Healthcare compliance (BAA):** Automatically extends to Claude Code when customer has executed a BAA and has ZDR activated. ZDR is per-organization.

**Security vulnerability reporting:** Via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability).

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are not stored after the response is returned.

**ZDR covers:** Model inference calls made through Claude Code on Claude for Enterprise.

**ZDR does NOT cover:**

| Feature | Note |
|:--------|:-----|
| Chat on claude.ai | Not covered |
| Cowork | Not covered |
| Claude Code Analytics | Collects productivity metadata (no prompts/responses) |
| User/seat management | Administrative data retained under standard policies |
| Third-party integrations | Review those services independently |

**Features disabled under ZDR:**

| Feature | Reason |
|:--------|:-------|
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions (Desktop app) | Requires persistent session data |
| `/feedback` | Sends conversation data to Anthropic |

ZDR is per-organization; each new organization must have ZDR enabled separately by the Anthropic account team.

Policy violations may result in data retention up to 2 years even with ZDR enabled.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- security architecture and philosophy, permission-based model, built-in protections (sandboxed bash, write access restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection protections (permission system, context-aware analysis, input sanitization, command blocklist, network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching), privacy safeguards, MCP security, IDE security, cloud execution security (isolated VMs, network controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control session security, security best practices for sensitive code and teams, reporting vulnerabilities via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- sandboxed bash tool overview, filesystem isolation (Seatbelt on macOS, bubblewrap on Linux/WSL2), network isolation via proxy, sandbox modes (auto-allow vs regular permissions), configuration (sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead, sandbox.network.allowedDomains/allowUnixSockets/httpProxyPort/socksProxyPort), path prefix resolution, excludedCommands, allowUnsandboxedCommands escape hatch, security benefits (prompt injection protection, reduced attack surface), security limitations (domain fronting, Unix socket escalation, filesystem permission escalation, enableWeakerNestedSandbox), relationship to permissions, custom proxy configuration, open source sandbox runtime npm package
- [Development containers](references/claude-code-devcontainer.md) -- reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), --dangerously-skip-permissions for unattended operation, firewall configuration (whitelisted domains, default-deny, DNS and SSH allowed), Node.js 20 base image, VS Code integration, session persistence, customization options, use cases (secure client work, team onboarding, CI/CD environments)
- [Enterprise network configuration](references/claude-code-network-config.md) -- proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY, basic auth), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), required URLs (api.anthropic.com, claude.ai, platform.claude.com, downloads.claude.ai), GitHub Enterprise Cloud IP allow list configuration
- [Data usage](references/claude-code-data-usage.md) -- data training policy (consumer opt-in, commercial no-train by default, Development Partner Program), /feedback and session quality surveys, data retention periods (consumer 5-year/30-day, commercial 30-day, ZDR), local and cloud data flow diagrams, telemetry services (Statsig metrics, Sentry errors), opt-out environment variables, default behaviors by API provider (Claude API, Vertex, Bedrock, Foundry)
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- Commercial Terms and Consumer Terms, commercial agreement applicability (1P and 3P), healthcare compliance BAA with ZDR requirement, acceptable use policy, OAuth vs API key authentication restrictions, Anthropic Trust Center and Transparency Hub, HackerOne vulnerability reporting
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR scope for Claude for Enterprise, per-organization enablement, what ZDR covers (inference calls) and does not cover (chat, Cowork, Analytics, integrations), features disabled under ZDR (web sessions, remote sessions, /feedback), data retention for policy violations (up to 2 years), requesting ZDR from account team

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
