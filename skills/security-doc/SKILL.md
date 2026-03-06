---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- security architecture, permission system, prompt injection protections, sandboxing (filesystem/network isolation, OS-level enforcement, sandbox modes, configuration), development containers (devcontainer setup, firewall rules), enterprise network configuration (proxy, custom CA, mTLS), data usage policies (training, retention, telemetry, ZDR), legal and compliance (terms, BAA/healthcare, vulnerability reporting), MCP security, IDE security, and cloud execution security. Load when discussing Claude Code security, sandboxing, data privacy, data retention, zero data retention, devcontainers, network configuration, proxy setup, mTLS, compliance, or legal terms.
user-invocable: false
---

# Security, Privacy & Compliance Documentation

This skill provides the complete official documentation for Claude Code security safeguards, sandboxing, development containers, enterprise network configuration, data usage policies, legal/compliance, and zero data retention.

## Quick Reference

### Security Architecture

Claude Code uses a permission-based architecture with read-only defaults. Built-in protections include sandboxed bash, write access restricted to the project directory, prompt fatigue mitigation via allowlisting, and Accept Edits mode for batching file changes.

### Prompt Injection Protections

| Protection | Description |
|:-----------|:------------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects potentially harmful instructions |
| Input sanitization | Prevents command injection |
| Command blocklist | Blocks `curl`, `wget` by default |
| Network request approval | Tools making network requests need user approval |
| Isolated context windows | Web fetch uses separate context to avoid injection |
| Trust verification | First-time codebase runs and new MCP servers require trust verification |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Sandboxing

OS-level bash isolation using Seatbelt (macOS) or bubblewrap (Linux/WSL2). Provides filesystem and network restrictions enforced at the OS level for all child processes.

**Sandbox modes:**

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed bash commands run without permission prompts; unsandboxable commands fall back to normal permission flow |
| Regular permissions | All bash commands go through standard permission flow, even when sandboxed |

**Filesystem isolation defaults:**

| Access | Scope |
|:-------|:------|
| Read + Write | Current working directory and subdirectories |
| Read only | Entire computer (except denied directories) |
| Blocked | Cannot modify files outside working directory without permission |

**Path prefixes for sandbox filesystem settings:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `//` | Absolute from filesystem root | `//tmp/build` -> `/tmp/build` |
| `~/` | Relative to home directory | `~/.kube` -> `$HOME/.kube` |
| `/` | Relative to settings file directory | `/build` -> `$SETTINGS_DIR/build` |
| `./` or none | Relative path | `./output` |

**Network isolation:** Domain-based filtering via proxy server running outside the sandbox. New domain requests trigger permission prompts. Supports custom proxy configuration via `sandbox.network.httpProxyPort` and `sandbox.network.socksProxyPort`.

**Key sandbox settings:**

| Setting | Description |
|:--------|:------------|
| `sandbox.enabled` | Enable sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve sandboxed bash (default: true) |
| `sandbox.excludedCommands` | Commands that bypass sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: true) |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Blocked write paths |
| `sandbox.filesystem.denyRead` | Blocked read paths |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `sandbox.network.allowUnixSockets` | Allowed Unix socket paths |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Restrict to managed allowlist |

**Security limitations:**

- Network filtering is domain-level only; does not inspect traffic content
- Broad domains (e.g., `github.com`) may allow data exfiltration; domain fronting is possible
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- Linux `enableWeakerNestedSandbox` mode considerably weakens security (for Docker-in-Docker environments)

**Linux prerequisites:** `bubblewrap` and `socat` packages required. WSL1 is not supported.

**Open source:** Sandbox runtime available as `@anthropic-ai/sandbox-runtime` npm package.

### Development Containers

Preconfigured devcontainer with multi-layered security for isolated development. Components: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`.

| Feature | Description |
|:--------|:------------|
| Firewall | Default-deny outbound; whitelists npm, GitHub, Claude API only |
| Isolation | Separated from host system |
| `--dangerously-skip-permissions` | Safe to use inside devcontainer due to isolation and firewall |

Reference implementation: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

### Enterprise Network Configuration

| Feature | Environment variable | Description |
|:--------|:---------------------|:------------|
| HTTPS proxy | `HTTPS_PROXY` | Proxy URL (recommended) |
| HTTP proxy | `HTTP_PROXY` | Fallback proxy URL |
| No proxy | `NO_PROXY` | Bypass proxy (space- or comma-separated; `*` for all) |
| Custom CA | `NODE_EXTRA_CA_CERTS` | Path to CA certificate PEM file |
| mTLS cert | `CLAUDE_CODE_CLIENT_CERT` | Client certificate path |
| mTLS key | `CLAUDE_CODE_CLIENT_KEY` | Client private key path |
| mTLS passphrase | `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key |

**Required network access:** `api.anthropic.com`, `claude.ai`, `platform.claude.com`

SOCKS proxies are not supported. All env vars can also be set in `settings.json`.

### Data Usage & Retention

**Training policy:**

| Plan | Policy |
|:-----|:-------|
| Free, Pro, Max | User chooses via privacy settings; training occurs when setting is on |
| Team, Enterprise, API | Not used for training unless opted into Development Partner Program |

**Retention periods:**

| Plan | Retention |
|:-----|:----------|
| Consumer (training on) | 5 years |
| Consumer (training off) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Zero -- not stored after response returned |

**Telemetry services:**

| Service | Purpose | Opt-out variable |
|:--------|:--------|:-----------------|
| Statsig | Operational metrics (latency, reliability) | `DISABLE_TELEMETRY` |
| Sentry | Error logging | `DISABLE_ERROR_REPORTING` |
| `/bug` reports | Conversation history sent to Anthropic | `DISABLE_BUG_COMMAND` |
| Session surveys | Numeric rating only (no transcripts) | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` |

All non-essential traffic (telemetry, errors, bug reports, surveys) is disabled by default for Bedrock, Vertex, and Foundry. Set `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` to disable all at once.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are processed in real time and not stored after the response is returned.

**ZDR covers:** Model inference calls through Claude Code on Claude for Enterprise.

**ZDR does NOT cover:** Chat on claude.ai, Cowork sessions, Analytics metadata, user/seat management, third-party integrations.

**Features disabled under ZDR:** Claude Code on the Web, Remote sessions from Desktop app, `/feedback` submission.

ZDR is enabled per-organization -- each new org requires separate enablement by your Anthropic account team. Contact your account team to request.

### Cloud Execution Security

| Control | Description |
|:--------|:------------|
| Isolated VMs | Each session runs in an Anthropic-managed VM |
| Network controls | Limited by default; configurable domain allowlist |
| Credential protection | GitHub auth via secure proxy; credentials never enter sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions are different: execution stays local, no cloud VMs involved. Connection uses multiple short-lived, narrowly scoped credentials.

### Legal & Compliance

| Topic | Details |
|:------|:--------|
| Commercial users | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Consumer users | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |
| Healthcare (BAA) | Extends to Claude Code if BAA executed and ZDR activated; per-org |
| Usage policy | [Anthropic Usage Policy](https://www.anthropic.com/legal/aup) |
| OAuth tokens | For Claude Code and Claude.ai only; not for third-party products |
| API keys | Required for Agent SDK and third-party integrations |
| Vulnerability reporting | [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) |
| Trust center | [trust.anthropic.com](https://trust.anthropic.com) |

### MCP Security

MCP server list is configured in source code as part of Claude Code settings. Use your own or trusted MCP servers. Anthropic does not manage or audit third-party MCP servers. Permissions for MCP servers are configurable.

### Best Practices

- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Consider devcontainers for additional isolation
- Audit permissions regularly with `/permissions`
- Use managed settings for organizational standards
- Monitor usage through OpenTelemetry metrics
- Audit config changes with `ConfigChange` hooks
- Avoid piping untrusted content directly to Claude
- Use VMs for scripts interacting with external web services
- Report suspicious behavior with `/bug`

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- security architecture, permission system, prompt injection protections, MCP security, IDE security, cloud execution security, best practices, and vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) -- filesystem and network isolation, OS-level enforcement (Seatbelt/bubblewrap), sandbox modes, configuration, security benefits, limitations, custom proxy, and open source runtime
- [Development containers](references/claude-code-devcontainer.md) -- devcontainer setup, Dockerfile, firewall rules, security features, customization, and use cases
- [Enterprise network configuration](references/claude-code-network-config.md) -- proxy configuration, custom CA certificates, mTLS authentication, and network access requirements
- [Data usage](references/claude-code-data-usage.md) -- data training policy, retention periods, telemetry services (Statsig, Sentry), bug reporting, session surveys, local and cloud data flows, and provider-specific defaults
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- license terms, commercial agreements, healthcare compliance (BAA), acceptable use, authentication/credential policies, trust center, and vulnerability reporting
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR scope, what it covers and does not cover, disabled features, data retention for policy violations, and how to request ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
