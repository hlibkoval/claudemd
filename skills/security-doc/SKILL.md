---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal/compliance, and zero data retention -- permission-based architecture, prompt injection protections, sandbox modes (auto-allow, regular), OS-level enforcement (Seatbelt on macOS, bubblewrap on Linux), filesystem and network isolation, sandbox settings (allowWrite, denyWrite, denyRead, allowedDomains, excludedCommands, allowUnsandboxedCommands, allowUnixSockets, allowManagedDomainsOnly), custom proxy configuration, devcontainer setup (Dockerfile, firewall, init-firewall.sh), enterprise proxy (HTTPS_PROXY, HTTP_PROXY, NO_PROXY), custom CA certs (NODE_EXTRA_CA_CERTS), mTLS (CLAUDE_CODE_CLIENT_CERT/KEY), required network URLs, data training policies (consumer vs commercial), data retention periods, telemetry services (Statsig, Sentry), environment variable opt-outs (DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, DISABLE_BUG_COMMAND, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC), ZDR scope and disabled features, legal terms, BAA/healthcare compliance, authentication credential policies, security vulnerability reporting. Load when discussing Claude Code security, sandboxing, sandbox configuration, devcontainers, network configuration, proxy setup, data privacy, data retention, telemetry, zero data retention, ZDR, legal terms, compliance, BAA, mTLS, prompt injection protection, or enterprise security deployment.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code's security model, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal/compliance, and zero data retention.

## Quick Reference

### Permission-Based Architecture

Claude Code uses strict read-only permissions by default. Write operations are confined to the project directory and its subdirectories. Sensitive operations require explicit user approval. Use `/permissions` to audit settings.

### Built-In Protections

| Protection | Description |
|:-----------|:------------|
| Sandboxed bash | OS-level filesystem and network isolation via `/sandbox` |
| Write restriction | Can only write to the working directory and children |
| Command blocklist | `curl`, `wget` blocked by default to prevent fetching arbitrary web content |
| Command injection detection | Suspicious commands require manual approval even if allowlisted |
| Network request approval | Tools making network requests require user approval by default |
| Isolated web fetch | Separate context window to avoid prompt injection from fetched content |
| Trust verification | Required on first run in a codebase and for new MCP servers (disabled with `-p`) |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys and tokens are encrypted |

### Prompt Injection Defenses

- Permission system gates sensitive operations
- Context-aware analysis detects harmful instructions
- Input sanitization prevents command injection
- Natural language descriptions accompany complex bash commands

### Sandboxing

Sandboxing provides OS-level filesystem and network isolation for bash commands, reducing permission prompts while maintaining security. Enable with `/sandbox`.

#### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands run automatically; unsandboxable commands fall back to permission flow |
| **Regular permissions** | All commands go through standard permission flow even when sandboxed |

Auto-allow works independently of permission mode -- sandboxed bash commands run without prompting even when file edit tools would normally require approval.

#### OS-Level Enforcement

| Platform | Technology |
|:---------|:-----------|
| macOS | Seatbelt |
| Linux | bubblewrap (`bwrap`) |
| WSL2 | bubblewrap (WSL1 not supported) |

Linux prerequisites: `sudo apt-get install bubblewrap socat` (Debian/Ubuntu) or `sudo dnf install bubblewrap socat` (Fedora).

#### Filesystem Isolation Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside the working directory |
| `sandbox.filesystem.denyWrite` | Block subprocess write access to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess read access to specific paths |

Path prefix resolution:

| Prefix | Meaning |
|:-------|:--------|
| `//` | Absolute from filesystem root (`//tmp/build` becomes `/tmp/build`) |
| `~/` | Relative to home directory |
| `/` | Relative to settings file's directory |
| `./` or none | Relative path resolved by sandbox runtime |

When defined in multiple settings scopes, arrays are **merged** (not replaced).

#### Network Isolation Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.allowedDomains` | Domains bash commands can reach |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `sandbox.network.allowManagedDomainsOnly` | Block non-allowed domains silently (no prompt) |

#### Other Sandbox Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.excludedCommands` | Commands that always run outside the sandbox (e.g., `docker`) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the escape hatch that retries failed commands outside sandbox |
| `sandbox.allowUnixSockets` | Allow access to Unix sockets (use with caution -- can bypass sandbox via Docker socket, etc.) |
| `sandbox.enableWeakerNestedSandbox` | Linux-only: weaker sandbox for Docker environments without privileged namespaces |

#### Security Limitations

- Network filtering restricts domains but does not inspect traffic content
- Broad domains like `github.com` may enable data exfiltration
- Domain fronting can potentially bypass network filtering
- `allowUnixSockets` with Docker socket grants host-level access
- Overly broad filesystem write permissions can enable privilege escalation
- `enableWeakerNestedSandbox` considerably weakens security

### Devcontainers

The reference devcontainer provides isolated environments with a default-deny firewall. The container's security allows running `claude --dangerously-skip-permissions` for unattended operation.

Components: `devcontainer.json` (settings, extensions, mounts), `Dockerfile` (image, tools), `init-firewall.sh` (network rules).

Key features: Node.js 20, custom firewall (whitelisted outbound only), default-deny policy, ZSH with productivity tools, VS Code integration, session persistence.

### Enterprise Network Configuration

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` for all) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate bundle (PEM) |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

All environment variables can also be set in `settings.json`. SOCKS proxies are not supported.

#### Required Network URLs

- `api.anthropic.com` -- Claude API endpoints
- `claude.ai` -- authentication for claude.ai accounts
- `platform.claude.com` -- authentication for Anthropic Console accounts

### Data Usage Policies

#### Training Policy

| Account type | Training policy |
|:-------------|:---------------|
| Consumer (Free, Pro, Max) | User-controlled opt-in/out via privacy settings |
| Commercial (Team, Enterprise, API, 3P) | Not used for training unless customer opts in (e.g., Developer Partner Program) |

#### Data Retention

| Account type | Retention |
|:-------------|:----------|
| Consumer -- training allowed | 5 years |
| Consumer -- training not allowed | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Zero retention (Enterprise only) |
| `/bug` reports | 5 years |
| Local session cache | Up to 30 days (configurable) |

#### Telemetry Opt-Out

| Variable | Disables |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Statsig operational metrics |
| `DISABLE_ERROR_REPORTING` | Sentry error logging |
| `DISABLE_BUG_COMMAND` | `/bug` report functionality |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | "How is Claude doing?" survey |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All of the above at once |

Bedrock, Vertex, and Foundry providers have all non-essential traffic disabled by default.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. When enabled, prompts and responses are not stored after the response is returned.

**Features disabled under ZDR:** Claude Code on the Web, remote sessions from Desktop app, feedback submission (`/feedback`).

**Not covered by ZDR:** Chat on claude.ai, Cowork, Claude Code Analytics (collects metadata only), user/seat management, third-party integrations.

ZDR is enabled per-organization. Contact your Anthropic account team to request it.

### Legal and Compliance

| Topic | Details |
|:------|:--------|
| Commercial terms | Team, Enterprise, API users |
| Consumer terms | Free, Pro, Max users |
| BAA (healthcare) | Extends to Claude Code if BAA is executed and ZDR is activated, per-organization |
| OAuth tokens | For Claude Code and claude.ai only; not permitted in Agent SDK or third-party tools |
| API keys | Required for developers building products via Claude Console or cloud providers |
| Vulnerability reporting | HackerOne program |

### Cloud Execution Security

- Each session runs in an isolated, Anthropic-managed VM
- Network access limited by default, configurable per environment
- GitHub authentication via secure proxy with scoped credentials
- Git push restricted to the current working branch
- All operations logged for audit
- Environments auto-terminated after session completion

### Security Best Practices

- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Use devcontainers for additional isolation
- Audit permissions regularly with `/permissions`
- Use managed settings for organizational standards
- Share approved permission configs through version control
- Monitor usage through OpenTelemetry metrics
- Audit settings changes with `ConfigChange` hooks
- Report vulnerabilities through HackerOne (do not disclose publicly)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- permission-based architecture, built-in protections, prompt injection defenses, MCP security, IDE security, cloud execution security, best practices for sensitive code and teams, vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) -- sandbox modes (auto-allow, regular), OS-level enforcement (Seatbelt, bubblewrap), filesystem and network isolation, sandbox settings (allowWrite, denyWrite, denyRead, allowedDomains, excludedCommands), custom proxy, security limitations, open source runtime
- [Development containers](references/claude-code-devcontainer.md) -- reference devcontainer setup, Dockerfile, firewall configuration, VS Code integration, customization options
- [Enterprise network configuration](references/claude-code-network-config.md) -- proxy setup (HTTPS_PROXY, HTTP_PROXY, NO_PROXY), custom CA certificates, mTLS authentication, required network URLs
- [Data usage](references/claude-code-data-usage.md) -- training policies (consumer vs commercial), data retention periods, telemetry services (Statsig, Sentry), opt-out environment variables, default behaviors by API provider, data flow diagrams
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- license terms, commercial agreements, BAA/healthcare compliance, acceptable use policy, authentication credential policies, vulnerability reporting
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR scope and coverage, features disabled under ZDR, data retention for policy violations, how to request ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
