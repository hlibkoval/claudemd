---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, legal/compliance, and zero data retention. Covers permission-based architecture, prompt injection protections, MCP security, IDE security, cloud execution security, sandbox modes (auto-allow, regular), filesystem isolation (allowWrite, denyWrite, denyRead, allowRead), network isolation (allowedDomains, custom proxy), OS-level enforcement (Seatbelt on macOS, bubblewrap on Linux), sandbox settings, excludedCommands, dangerouslyDisableSandbox, devcontainer setup, firewall rules, enterprise proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY), required URLs for network access, data training policies (consumer vs commercial), data retention periods, telemetry services (Statsig, Sentry), feedback data handling, session quality surveys, default behaviors by API provider, legal agreements (Commercial Terms, Consumer Terms), BAA/healthcare compliance, acceptable use policy, authentication and credential use, zero data retention (ZDR) for Enterprise, ZDR scope, features disabled under ZDR, and security best practices. Load when discussing security, sandboxing, sandbox, devcontainer, development container, network configuration, proxy, CA certificates, mTLS, data usage, data retention, data training, telemetry, privacy, legal, compliance, BAA, HIPAA, ZDR, zero data retention, prompt injection, permission system, firewall, isolation, trust center, or any security-related topic for Claude Code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal/compliance, and zero data retention.

## Quick Reference

### Security Architecture

| Layer | Description |
|:------|:-----------|
| Permission system | Read-only by default; explicit approval required for edits, commands, network requests |
| Sandboxing | OS-level filesystem and network isolation for bash commands |
| Write restriction | Can only write to the working directory and subdirectories |
| Command blocklist | `curl`, `wget` blocked by default to prevent fetching arbitrary content |
| Trust verification | Required on first-time codebase runs and new MCP servers (disabled with `-p` flag) |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Credential storage | API keys and tokens are encrypted |

### Prompt Injection Protections

| Protection | Detail |
|:-----------|:-------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects harmful instructions by analyzing the full request |
| Input sanitization | Prevents command injection in user inputs |
| Network request approval | Tools making network requests require approval by default |
| Isolated context windows | Web fetch uses a separate context window |
| Natural language descriptions | Complex bash commands include explanations |

### Sandboxing

#### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed bash commands run automatically without permission; non-sandboxable commands fall back to normal permission flow |
| Regular permissions | All bash commands go through standard permission flow, even when sandboxed |

Enable with `/sandbox`. Both modes enforce the same filesystem and network restrictions.

#### OS-Level Enforcement

| Platform | Technology |
|:---------|:-----------|
| macOS | Seatbelt (built-in) |
| Linux | bubblewrap (requires `bubblewrap` + `socat` packages) |
| WSL2 | bubblewrap (same as Linux) |
| WSL1 | Not supported |

#### Filesystem Isolation Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant write access to paths outside working directory |
| `sandbox.filesystem.denyWrite` | Block write access to specific paths |
| `sandbox.filesystem.denyRead` | Block read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region (takes precedence) |

Path prefix conventions: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-relative (in project settings) or `~/.claude`-relative (in user settings). Arrays from multiple settings scopes are **merged**, not replaced.

When `allowManagedReadPathsOnly` is enabled in managed settings, only managed `allowRead` entries are respected.

#### Network Isolation Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.allowedDomains` | Domains bash commands can reach |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |

#### Other Sandbox Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `sandbox.excludedCommands` | Commands that always run outside the sandbox (e.g., `docker *`) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the escape hatch (`dangerouslyDisableSandbox`) |
| `sandbox.enableWeakerNestedSandbox` | For Docker environments without privileged namespaces (considerably weakens security) |

#### Sandbox Security Limitations

- Network filtering restricts domains only; does not inspect traffic content
- Broad domains like `github.com` may allow data exfiltration
- Domain fronting may bypass network filtering
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation

#### Sandbox Open Source

The sandbox runtime is available as an npm package: `npx @anthropic-ai/sandbox-runtime <command>`. Source: [github.com/anthropic-experimental/sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime).

### Development Containers

| Feature | Detail |
|:--------|:-------|
| Base | Node.js 20, ZSH, git, fzf |
| Firewall | Default-deny with whitelisted domains (npm, GitHub, Claude API) |
| Skip permissions | `claude --dangerously-skip-permissions` safe inside devcontainer |
| Setup | VS Code + Dev Containers extension, then "Reopen in Container" |
| Components | `devcontainer.json`, `Dockerfile`, `init-firewall.sh` |

Reference implementation: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

### Enterprise Network Configuration

#### Proxy Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL (fallback) |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` for all) |

SOCKS proxies are not supported. Basic auth: include credentials in the URL (`http://user:pass@proxy:8080`).

#### Custom CA & mTLS

| Variable | Purpose |
|:---------|:--------|
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate PEM for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key PEM for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

All environment variables can also be configured in `settings.json`.

#### Required Network URLs

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication (claude.ai accounts) |
| `platform.claude.com` | Authentication (Anthropic Console accounts) |
| `storage.googleapis.com` | Binary downloads and auto-updater |
| `downloads.claude.ai` | Install script, version pointers, manifests, plugins |

For GitHub Enterprise Cloud with IP restrictions, enable IP allow list inheritance for installed GitHub Apps or manually add [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Data Usage

#### Data Training Policy

| Plan | Policy |
|:-----|:-------|
| Free, Pro, Max (consumer) | User choice to allow/disallow training; controlled in privacy settings |
| Team, Enterprise, API (commercial) | Not used for training unless opted into Development Partner Program |

#### Data Retention

| Scenario | Retention |
|:---------|:----------|
| Consumer, training allowed | 5 years |
| Consumer, training disallowed | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR on Enterprise) | Not retained after response returned |
| `/feedback` transcripts | 5 years |
| Local session cache (`~/.claude/projects/`) | 30 days (configurable via `cleanupPeriodDays`) |

#### Telemetry Opt-Out

| Variable | Controls |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Statsig metrics |
| `DISABLE_ERROR_REPORTING` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic (includes surveys) |

#### Default Telemetry by Provider

| Service | Claude API | Vertex / Bedrock / Foundry |
|:--------|:-----------|:--------------------------|
| Statsig (metrics) | On | Off |
| Sentry (errors) | On | Off |
| `/feedback` reports | On | Off |
| Session quality surveys | On | On |

### Legal & Compliance

| Topic | Detail |
|:------|:-------|
| Commercial Terms | Team, Enterprise, API users |
| Consumer Terms | Free, Pro, Max users |
| BAA (Healthcare) | Auto-extends to Claude Code if customer has BAA + ZDR enabled |
| Acceptable use | Subject to Anthropic Usage Policy |
| Vulnerability reporting | [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) |
| Trust Center | [trust.anthropic.com](https://trust.anthropic.com) |

#### OAuth vs API Key Authentication

| Method | Intended for |
|:-------|:-------------|
| OAuth | Purchasers of Free, Pro, Max, Team, Enterprise subscription plans |
| API key | Developers building products/services, Agent SDK users |

Third-party developers may not route requests through Free/Pro/Max plan credentials on behalf of their users.

### Zero Data Retention (ZDR)

| Aspect | Detail |
|:-------|:-------|
| Availability | Claude Code on Claude for Enterprise only |
| Scope | Model inference calls (prompts and responses not retained) |
| Enablement | Per-organization; contact Anthropic account team |
| Policy violations | Data may be retained up to 2 years |

#### Features Disabled Under ZDR

| Feature | Reason |
|:--------|:-------|
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions (Desktop app) | Requires persistent session data |
| `/feedback` | Sends conversation data to Anthropic |

#### ZDR Does Not Cover

Chat on claude.ai, Cowork, Claude Code Analytics (collects metadata only), user/seat management, or third-party integrations.

### Cloud Execution Security

| Control | Detail |
|:--------|:-------|
| Isolated VMs | Each session in an Anthropic-managed VM |
| Network controls | Default-limited; configurable to disabled or specific domains |
| Credential protection | Secure proxy with scoped credentials; real tokens never enter sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session completion |

### Security Best Practices

**Working with sensitive code:** Review all changes before approval, use project-specific permissions, consider devcontainers, audit permissions with `/permissions`.

**Team security:** Use managed settings for org standards, share permission configs via version control, monitor usage via OpenTelemetry, audit config changes with `ConfigChange` hooks.

**Reporting vulnerabilities:** Do not disclose publicly. Report via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability). Include reproduction steps. Allow time for remediation.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Permission architecture, prompt injection protections, MCP security, IDE security, cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) -- Filesystem and network isolation, sandbox modes, OS enforcement, configuration, security benefits, limitations, open source runtime
- [Development Containers](references/claude-code-devcontainer.md) -- Devcontainer setup, firewall rules, security features, customization
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- Proxy setup, custom CA certificates, mTLS authentication, required URLs
- [Data Usage](references/claude-code-data-usage.md) -- Training policy, retention periods, telemetry services, default behaviors by API provider, data flow diagrams
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- License terms, BAA/healthcare compliance, acceptable use, authentication policy, vulnerability reporting
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope, disabled features, data retention for policy violations, how to request ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
