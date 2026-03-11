---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal and compliance, and zero data retention -- permission-based architecture, prompt injection protections, sandbox modes (auto-allow/regular), OS-level enforcement (Seatbelt/bubblewrap), filesystem isolation (allowWrite/denyWrite/denyRead path prefixes), network isolation (domain allowlists, custom proxy, allowManagedDomainsOnly), devcontainer setup (Dockerfile, firewall, VS Code integration), enterprise proxy (HTTPS_PROXY, HTTP_PROXY, NO_PROXY), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (client cert/key), data training policies (consumer vs commercial), data retention periods (30-day, 5-year, ZDR), telemetry services (Statsig, Sentry, bug reports), provider defaults (Claude API vs Bedrock/Vertex/Foundry), legal agreements (Commercial Terms, Consumer Terms), BAA/HIPAA compliance, ZDR scope and disabled features, MCP security, cloud execution security, and security vulnerability reporting. Load when discussing Claude Code security, sandboxing, sandbox configuration, bash isolation, devcontainers, network configuration, proxy setup, mTLS, data privacy, data retention, training policies, telemetry, ZDR, zero data retention, legal compliance, BAA, HIPAA, prompt injection, or security best practices.
user-invocable: false
---

# Security, Sandboxing, Data & Compliance Documentation

This skill provides the complete official documentation for Claude Code security safeguards, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal agreements, and zero data retention.

## Quick Reference

### Security Architecture

Claude Code uses strict read-only permissions by default. All sensitive operations require explicit user approval before execution.

**Built-in protections:**

| Protection | Description |
|:-----------|:------------|
| Sandboxed bash tool | OS-level filesystem and network isolation via `/sandbox` |
| Write access restriction | Writes confined to project directory and subdirectories |
| Prompt fatigue mitigation | Allowlisting safe commands per-user, per-codebase, or per-org |
| Accept Edits mode | Batch accept edits while keeping prompts for side-effect commands |
| Command blocklist | `curl`, `wget` blocked by default to prevent fetching arbitrary content |
| Isolated context windows | Web fetch uses separate context to avoid prompt injection |
| Trust verification | First-time codebase runs and new MCP servers require trust verification (disabled in `-p` mode) |
| Command injection detection | Suspicious commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

**Prompt injection defenses:** permission system, context-aware analysis, input sanitization, command blocklist, network request approval, natural language descriptions for complex commands.

### Sandboxing

The sandboxed bash tool uses OS-level primitives to enforce filesystem and network isolation, reducing permission prompts while maintaining security.

#### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands auto-approved; non-sandboxable commands fall back to regular permissions |
| **Regular permissions** | All commands go through standard permission flow, even when sandboxed |

Enable with `/sandbox`. Both modes enforce the same restrictions -- the difference is only auto-approval behavior.

#### OS-Level Enforcement

| Platform | Mechanism |
|:---------|:----------|
| macOS | Seatbelt (built-in, no setup needed) |
| Linux / WSL2 | bubblewrap + socat (`apt-get install bubblewrap socat`) |
| WSL1 | Not supported |

#### Filesystem Isolation

- **Default writes**: read/write to current working directory and subdirectories
- **Default reads**: read access to entire system, except denied directories
- Configure additional writable paths via `sandbox.filesystem.allowWrite`
- Block access via `sandbox.filesystem.denyWrite` and `sandbox.filesystem.denyRead`
- Paths from sandbox settings and permission rules are merged together

**Path prefixes for sandbox settings:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `//` | Absolute from filesystem root | `//tmp/build` becomes `/tmp/build` |
| `~/` | Home directory | `~/.kube` becomes `$HOME/.kube` |
| `/` | Relative to settings file directory | `/build` becomes `$SETTINGS_DIR/build` |
| `./` or none | Relative (resolved by sandbox runtime) | `./output` |

Arrays (`allowWrite`, `denyWrite`, `denyRead`) are **merged** across settings scopes, not replaced.

#### Network Isolation

- Domain restrictions via proxy server running outside the sandbox
- New domain requests trigger permission prompts (unless `allowManagedDomainsOnly` is set)
- Custom proxy support for HTTPS inspection and custom filtering
- All subprocesses inherit network restrictions

**Custom proxy config:**
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

- Network filtering restricts domains only -- does not inspect traffic content; domain fronting may bypass filtering
- `allowUnixSockets` can grant access to powerful services (e.g. Docker socket) that bypass sandbox
- Overly broad `allowWrite` to `$PATH` directories or shell config files enables privilege escalation
- Linux `enableWeakerNestedSandbox` mode (for Docker without privileged namespaces) considerably weakens security

#### Escape Hatch

Commands that fail due to sandbox restrictions may retry with `dangerouslyDisableSandbox`, which goes through normal permissions. Disable with `"allowUnsandboxedCommands": false`.

### Devcontainers

Preconfigured development container with multi-layered security for isolated, unattended operation.

**Components:** `devcontainer.json` (settings, extensions, mounts), `Dockerfile` (image, tools), `init-firewall.sh` (network security rules).

**Security features:** precise outbound access control (whitelisted domains only), allowed DNS and SSH, default-deny policy, startup firewall verification, system isolation.

The container's security allows running `claude --dangerously-skip-permissions` for unattended operation. Reference setup: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

### Enterprise Network Configuration

| Setting | Environment Variable | Purpose |
|:--------|:--------------------|:--------|
| HTTPS proxy | `HTTPS_PROXY` | Route traffic through corporate proxy |
| HTTP proxy | `HTTP_PROXY` | Fallback if HTTPS unavailable |
| Proxy bypass | `NO_PROXY` | Space- or comma-separated bypass list; `*` bypasses all |
| Custom CA certs | `NODE_EXTRA_CA_CERTS` | Path to PEM file for enterprise CAs |
| Client cert (mTLS) | `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate PEM |
| Client key (mTLS) | `CLAUDE_CODE_CLIENT_KEY` | Path to client private key PEM |
| Key passphrase (mTLS) | `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key |

All environment variables can also be set in `settings.json`.

SOCKS proxies are not supported. For NTLM/Kerberos authentication, use an LLM Gateway.

**Required network access:** `api.anthropic.com` (Claude API), `claude.ai` (claude.ai auth), `platform.claude.com` (Console auth).

### Data Usage & Retention

#### Training Policy

| Account Type | Training Policy |
|:-------------|:---------------|
| **Consumer** (Free, Pro, Max) | User choice -- opt in/out via privacy settings |
| **Commercial** (Team, Enterprise, API, 3P) | Not trained on unless customer opts in (e.g. Developer Partner Program) |

#### Retention Periods

| Account Type | Retention |
|:-------------|:----------|
| Consumer, training allowed | 5 years |
| Consumer, training not allowed | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Zero -- not stored after response returned |
| `/bug` transcripts | 5 years |
| Local session cache | Up to 30 days (configurable) |

#### Telemetry Opt-Out

| Service | Env Variable | Default (Claude API) | Default (Bedrock/Vertex/Foundry) |
|:--------|:-------------|:---------------------|:--------------------------------|
| Statsig (metrics) | `DISABLE_TELEMETRY=1` | On | Off |
| Sentry (errors) | `DISABLE_ERROR_REPORTING=1` | On | Off |
| Bug reports | `DISABLE_BUG_COMMAND=1` | On | Off |
| Session surveys | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | On | Off |
| All non-essential | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | -- | -- |

Session quality surveys record only numeric ratings (1, 2, 3, or dismiss) -- no conversation data.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are processed in real time and not stored after the response is returned.

**ZDR covers:** model inference calls through Claude Code on Claude for Enterprise.

**ZDR does NOT cover:** chat on claude.ai, Cowork sessions, Claude Code Analytics metadata, user/seat management, third-party integrations.

**Features disabled under ZDR:** Claude Code on the Web, Remote sessions from Desktop app, Feedback submission (`/feedback`).

**Per-org enablement:** ZDR must be enabled separately for each organization by the Anthropic account team.

**Policy violation retention:** flagged sessions may be retained up to 2 years.

### Legal & Compliance

| Document | Applies To |
|:---------|:-----------|
| [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) | Team, Enterprise, API users |
| [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) | Free, Pro, Max users |
| [Usage Policy](https://www.anthropic.com/legal/aup) | All users |
| [Privacy Policy](https://www.anthropic.com/legal/privacy) | All users |

**Authentication restrictions:** OAuth tokens (Free/Pro/Max) are for Claude Code and claude.ai only -- using them in other products or the Agent SDK is prohibited. Developers building products must use API key authentication.

**BAA/HIPAA:** customers with a BAA and ZDR enabled automatically have the BAA extend to Claude Code API traffic. ZDR must be enabled per-organization.

**Security vulnerability reporting:** [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) -- do not disclose publicly, include reproduction steps, allow time for resolution.

**Trust Center:** [trust.anthropic.com](https://trust.anthropic.com) -- SOC 2 Type 2, ISO 27001, and other compliance artifacts.

### Cloud Execution Security

- Isolated VMs per session
- Network access limited by default, configurable per environment
- GitHub auth via secure proxy with scoped credentials (never enter sandbox)
- Git push restricted to current working branch
- All operations audit-logged
- Environments auto-terminated after session completion

### MCP Security

MCP server lists are configured in source-controlled Claude Code settings. Use your own servers or servers from trusted providers. Anthropic does not manage or audit any MCP servers.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- permission-based architecture, built-in protections, prompt injection defenses, MCP security, IDE security, cloud execution security, security best practices, team security, vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) -- sandbox modes (auto-allow/regular), OS-level enforcement (Seatbelt/bubblewrap), filesystem isolation (allowWrite/denyWrite/denyRead, path prefixes), network isolation (domain allowlists, custom proxy), security benefits, limitations, escape hatch, permissions integration, open source runtime
- [Development containers](references/claude-code-devcontainer.md) -- reference devcontainer setup, Dockerfile, firewall rules, key features, security features, customization, example use cases
- [Enterprise network configuration](references/claude-code-network-config.md) -- proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY), basic auth, custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication, required network URLs
- [Data usage](references/claude-code-data-usage.md) -- training policies (consumer vs commercial), Developer Partner Program, feedback and survey data, retention periods, local and cloud data flows, telemetry services (Statsig, Sentry), provider defaults table
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- license agreements (Commercial/Consumer Terms), BAA/HIPAA compliance with ZDR, usage policy, authentication and credential restrictions, trust and safety resources, vulnerability reporting
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR scope and coverage, features disabled under ZDR, per-org enablement, data retention for policy violations, requesting ZDR, transitioning from API to Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
