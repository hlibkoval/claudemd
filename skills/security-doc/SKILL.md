---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, legal compliance, and zero data retention. Covers security architecture (permission-based system, built-in protections, write access restriction to cwd subtree, prompt fatigue mitigation, Accept Edits mode), prompt injection protections (permission system, context-aware analysis, input sanitization, command blocklist for curl/wget, command injection detection, fail-closed matching, isolated context windows for WebFetch, trust verification on first run), sandboxing (OS-level enforcement with Seatbelt on macOS and bubblewrap on Linux/WSL2, filesystem isolation with sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead and path prefix resolution, network isolation via proxy with domain restrictions and allowedDomains/allowManagedDomainsOnly, sandbox modes auto-allow vs regular-permissions, /sandbox command, sandbox.failIfUnavailable, dangerouslyDisableSandbox escape hatch with allowUnsandboxedCommands disable, excludedCommands, custom proxy httpProxyPort/socksProxyPort, enableWeakerNestedSandbox for Docker, settings merge across scopes, allowManagedReadPathsOnly), devcontainers (reference setup from anthropics/claude-code repo, Dockerfile and init-firewall.sh, --dangerously-skip-permissions for unattended operation, firewall with default-deny and whitelisted domains, VS Code Dev Containers extension), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY environment variables, basic proxy authentication, NODE_EXTRA_CA_CERTS for custom CA certificates, mTLS with CLAUDE_CODE_CLIENT_CERT/CLAUDE_CODE_CLIENT_KEY/CLAUDE_CODE_CLIENT_KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, downloads.claude.ai for native installer, GitHub Enterprise IP allow list), data usage (consumer vs commercial training policies, Development Partner Program opt-in, /feedback transcript retention 5 years, session quality surveys numeric only with CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, data retention 5-year/30-day for consumer and 30-day/ZDR for commercial, local caching up to 30 days, telemetry Statsig DISABLE_TELEMETRY and Sentry DISABLE_ERROR_REPORTING, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, default behaviors by API provider table, feedbackSurveyRate setting), legal and compliance (Commercial Terms for Team/Enterprise/API, Consumer Terms for Free/Pro/Max, BAA extends to Claude Code with ZDR, Acceptable Use Policy, OAuth tokens for Claude Code only not Agent SDK, API keys for developers, HackerOne vulnerability reporting), zero data retention (ZDR for Claude for Enterprise, per-organization enablement, covers model inference not chat/Cowork/analytics/seat-management/third-party, disables Claude Code on Web and remote sessions and /feedback, 2-year retention for policy violations, contact account team to enable). Load when discussing Claude Code security, sandboxing, sandbox configuration, devcontainers, network configuration, proxy setup, data usage, data retention, ZDR, zero data retention, legal compliance, BAA, prompt injection, permission system, firewall, mTLS, custom CA certificates, HTTPS_PROXY, telemetry, data training policy, or any security-related topic for Claude Code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security -- covering the security architecture, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal compliance, and zero data retention.

## Quick Reference

### Security Architecture

Claude Code uses a permission-based architecture with strict read-only defaults. Sensitive operations (editing files, running commands) require explicit user approval.

| Protection | Description |
|:-----------|:------------|
| **Sandboxed bash tool** | OS-level filesystem and network isolation via `/sandbox` |
| **Write access restriction** | Can only write to the cwd and its subdirectories; reads allowed outside |
| **Prompt fatigue mitigation** | Allowlisting safe commands per-user, per-codebase, or per-organization |
| **Accept Edits mode** | Batch-accept file edits while keeping command permission prompts |
| **Command blocklist** | Blocks risky web-fetching commands (`curl`, `wget`) by default |
| **Command injection detection** | Suspicious bash commands require manual approval even if allowlisted |
| **Fail-closed matching** | Unmatched commands default to requiring manual approval |
| **Isolated context windows** | WebFetch uses a separate context to avoid prompt injection |
| **Trust verification** | First-time codebase runs and new MCP servers require verification (disabled with `-p` flag) |
| **Secure credential storage** | API keys and tokens are encrypted |

### Prompt Injection Protections

- Permission system gates sensitive operations
- Context-aware analysis detects harmful instructions
- Input sanitization prevents command injection
- Network request approval required by default
- Natural language descriptions for complex bash commands

### Cloud Execution Security

| Control | Description |
|:--------|:------------|
| Isolated VMs | Each session runs in an Anthropic-managed VM |
| Network access controls | Limited by default; configurable domain allowlists |
| Credential protection | Secure proxy with scoped credentials translated to actual GitHub tokens |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions run locally -- no cloud VMs involved; data flows over TLS through the Anthropic API.

### MCP Security

MCP server lists are configured in source control as part of Claude Code settings. Use trusted servers only. Anthropic does not manage or audit MCP servers.

### Sandboxing

OS-level isolation for bash commands using Seatbelt (macOS) or bubblewrap (Linux/WSL2). WSL1 is not supported.

**Prerequisites (Linux/WSL2):**

```
# Ubuntu/Debian
sudo apt-get install bubblewrap socat

# Fedora
sudo dnf install bubblewrap socat
```

**Enable:** Run `/sandbox` to choose a mode.

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands run without permission prompts; non-sandboxable commands fall back to normal flow |
| **Regular permissions** | All commands go through standard permission flow, even when sandboxed |

**Filesystem Isolation Settings:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant write access to paths outside cwd (e.g., `["~/.kube", "/tmp/build"]`) |
| `sandbox.filesystem.denyWrite` | Block write access to specific paths |
| `sandbox.filesystem.denyRead` | Block read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region (takes precedence over `denyRead`) |

Path prefix resolution:

| Prefix | Meaning |
|:-------|:--------|
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

Arrays are **merged** across settings scopes, not replaced.

**Network Isolation Settings:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.allowedDomains` | Domains bash commands can reach |
| `sandbox.network.allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompts) |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |

**Other Sandbox Settings:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.failIfUnavailable` | Hard fail if sandbox cannot start (for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the `dangerouslyDisableSandbox` escape hatch |
| `sandbox.excludedCommands` | Commands that always run outside the sandbox (e.g., `docker`) |
| `sandbox.enableWeakerNestedSandbox` | For Docker environments without privileged namespaces (weakens security) |
| `sandbox.allowManagedReadPathsOnly` | Only managed `allowRead` entries are respected |

**Security Limitations:**
- Network filtering is domain-based only; does not inspect traffic content
- Broad domains (e.g., `github.com`) may allow data exfiltration; domain fronting is possible
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- `enableWeakerNestedSandbox` considerably weakens security

**What sandboxing does NOT cover:** Built-in file tools (Read, Edit, Write) use the permission system directly. Computer use on Desktop runs on your actual desktop.

**Open source:** The sandbox runtime is available as `@anthropic-ai/sandbox-runtime` on npm.

### Devcontainers

The reference [devcontainer setup](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides a preconfigured container for secure, isolated development.

| Component | Purpose |
|:----------|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image with Node.js 20, git, ZSH, fzf |
| `init-firewall.sh` | Network security rules (default-deny, whitelisted domains only) |

The container's isolation allows running `claude --dangerously-skip-permissions` for unattended operation. Does not prevent exfiltration of accessible data including Claude Code credentials -- use only with trusted repositories.

### Enterprise Network Configuration

**Proxy:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` for all) |

SOCKS proxies are not supported. For basic auth: `http://username:password@proxy.example.com:8080`

**Custom CA Certificates:**

```
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem
```

**mTLS Authentication:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key |

**Required URLs:**

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Anthropic Console accounts |
| `downloads.claude.ai` | Native installer, updates, manifests, executables |

For GitHub Enterprise Cloud with IP restrictions: enable IP allow list inheritance for installed GitHub Apps, or manually add ranges from Anthropic API IP addresses documentation.

### Data Usage

**Training Policy:**

| Plan | Policy |
|:-----|:-------|
| Free, Pro, Max (consumer) | User choice to allow training; controlled via privacy settings |
| Team, Enterprise, API (commercial) | Anthropic does not train on data unless customer opts in (e.g., Developer Partner Program) |

**Data Retention:**

| Account type | Retention |
|:-------------|:----------|
| Consumer (training allowed) | 5 years |
| Consumer (training not allowed) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Zero data retention (Enterprise only) |
| Local session cache | Up to 30 days (configurable) |
| `/feedback` transcripts | 5 years |

**Telemetry and Opt-Out:**

| Service | Opt-out variable |
|:--------|:-----------------|
| Statsig (metrics) | `DISABLE_TELEMETRY=1` |
| Sentry (errors) | `DISABLE_ERROR_REPORTING=1` |
| `/feedback` command | `DISABLE_FEEDBACK_COMMAND=1` |
| Session quality surveys | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| All non-essential traffic | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` |

Statsig, Sentry, and `/feedback` are **on by default** for Claude API, **off by default** for Vertex/Bedrock/Foundry. Session quality surveys are on for all providers. Survey frequency can be tuned with `feedbackSurveyRate` setting (0-1).

Session quality surveys record only a numeric rating (1, 2, 3, or dismiss) -- no transcripts, inputs, or outputs.

### Legal and Compliance

| Agreement | Applies to |
|:----------|:-----------|
| [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) | Team, Enterprise, API |
| [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) | Free, Pro, Max |
| [Anthropic Usage Policy](https://www.anthropic.com/legal/aup) | All users |

**BAA (Healthcare):** Automatically extends to Claude Code for customers with an executed BAA and ZDR activated. Per-organization.

**Authentication restrictions:** OAuth tokens from Free/Pro/Max are exclusively for Claude Code and claude.ai -- not for the Agent SDK or third-party products. Developers building products must use API key authentication.

**Vulnerability reporting:** [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are not stored after the response is returned.

**ZDR scope:**

| Covered | Not covered |
|:--------|:------------|
| Model inference calls via Claude Code | Chat on claude.ai |
| All Claude models | Cowork sessions |
| | Claude Code Analytics (collects metadata, not prompts) |
| | User/seat management |
| | Third-party integrations |

**Features disabled under ZDR:**

| Feature | Reason |
|:--------|:-------|
| Claude Code on the Web | Requires server-side conversation history storage |
| Remote sessions from Desktop app | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

ZDR is enabled per-organization -- each new organization needs separate enablement by your Anthropic account team. Even with ZDR, data may be retained up to 2 years for Usage Policy violations.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Security foundation and approach, permission-based architecture, built-in protections (sandboxed bash, write access restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection protections (permission system, context-aware analysis, input sanitization, command blocklist, network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching, secure credential storage), Windows WebDAV warning, best practices for untrusted content, MCP security, IDE security, cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control sessions (local execution, TLS, short-lived scoped credentials), security best practices for sensitive code and teams, vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- OS-level sandboxing overview, filesystem isolation (default writes to cwd, configurable allowWrite/denyWrite/denyRead/allowRead, path prefix resolution, settings merge across scopes, allowManagedReadPathsOnly), network isolation (domain restrictions, allowManagedDomainsOnly, custom proxy httpProxyPort/socksProxyPort), OS-level enforcement (Seatbelt macOS, bubblewrap Linux/WSL2, WSL1 not supported), prerequisites and installation, /sandbox command, sandbox modes (auto-allow vs regular permissions), sandbox.failIfUnavailable, excludedCommands, dangerouslyDisableSandbox escape hatch with allowUnsandboxedCommands, protection against prompt injection (filesystem and network), security limitations (domain-only filtering, domain fronting, allowUnixSockets risks, filesystem escalation, enableWeakerNestedSandbox), relationship to permissions, advanced custom proxy, integration with devcontainers and managed settings, open source @anthropic-ai/sandbox-runtime
- [Development Containers](references/claude-code-devcontainer.md) -- Reference devcontainer setup from anthropics/claude-code repo, devcontainer.json/Dockerfile/init-firewall.sh components, security features (precise access control, whitelisted domains, default-deny, startup verification, isolation), --dangerously-skip-permissions for unattended operation, customization options, use cases (secure client work, team onboarding, CI/CD environments)
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- Proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY with space/comma-separated formats, basic auth, no SOCKS support), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), required URLs (api.anthropic.com, claude.ai, platform.claude.com, downloads.claude.ai), GitHub Enterprise Cloud IP allow list configuration
- [Data Usage](references/claude-code-data-usage.md) -- Data training policy (consumer choice, commercial no-train default, Developer Partner Program), /feedback retention (5 years), session quality surveys (numeric only, CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, feedbackSurveyRate), data retention by account type (consumer 5-year/30-day, commercial 30-day/ZDR, local cache 30 days), data access for local and cloud execution, telemetry services (Statsig with DISABLE_TELEMETRY, Sentry with DISABLE_ERROR_REPORTING, DISABLE_FEEDBACK_COMMAND, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC), default behaviors by API provider table
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- Legal agreements (Commercial Terms for Team/Enterprise/API, Consumer Terms for Free/Pro/Max), BAA healthcare compliance (extends to Claude Code with ZDR, per-organization), acceptable use policy, authentication and credential restrictions (OAuth for Claude Code/claude.ai only, API keys for developers/Agent SDK), security vulnerability reporting via HackerOne
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR for Claude Code on Claude for Enterprise, per-organization enablement, ZDR scope (covers inference, does not cover chat/Cowork/analytics/seat-management/third-party), features disabled under ZDR (Claude Code on Web, remote sessions, /feedback), 2-year retention for policy violations, how to request ZDR, migration from API keys to Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
