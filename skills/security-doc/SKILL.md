---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, sandboxing (filesystem and network isolation), prompt injection protections, MCP security, cloud execution security, enterprise network configuration (proxy, CA certs, mTLS), data usage policies, zero data retention, dev containers, and legal compliance.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, and compliance.

## Quick Reference

### Security architecture overview

| Layer | Mechanism | Scope |
| :--- | :--- | :--- |
| Permissions | Read-only by default; explicit approval for writes and commands | All tools |
| Sandboxing | OS-level filesystem + network isolation for Bash commands | Bash and subprocesses |
| Prompt injection | Permission system, context-aware analysis, input sanitization, command blocklist | All sessions |
| Write access | Confined to working directory and subdirectories by default | File tools + sandbox |
| MCP trust | First-time MCP server requires trust verification | MCP tools |
| Cloud sessions | Isolated VMs, network controls, secure credential proxy, audit logging | Claude Code on the web |

### Sandboxing quick reference

Enable with `/sandbox`. Requires `bubblewrap` + `socat` on Linux/WSL2; works out-of-the-box on macOS.

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed bash runs without prompts; falls back to normal flow if unsandboxable |
| Regular permissions | All bash commands still go through the standard permission flow |

**OS-level enforcement:**

| Platform | Mechanism |
| :--- | :--- |
| macOS | Seatbelt |
| Linux / WSL2 | bubblewrap |
| WSL1 | Not supported |

**Key sandbox settings** (`settings.json` under `"sandbox"`):

| Setting | Description |
| :--- | :--- |
| `enabled` | Enable/disable sandboxing |
| `filesystem.allowWrite` | Additional paths subprocess can write to (merged across scopes) |
| `filesystem.denyWrite` | Paths to block from write access |
| `filesystem.denyRead` | Paths to block from read access |
| `filesystem.allowRead` | Re-allow specific paths within a denyRead region |
| `allowManagedReadPathsOnly` | When true, only managed allowRead entries apply |
| `allowedDomains` | Domains Bash commands can reach |
| `deniedDomains` | Domains to block even within a wildcard allowedDomains |
| `allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |
| `network.httpProxyPort` | Custom proxy port for HTTP |
| `network.socksProxyPort` | Custom proxy port for SOCKS |
| `excludedCommands` | Commands forced outside the sandbox (e.g. `docker *`) |
| `allowUnsandboxedCommands` | Set `false` to disable the escape hatch mechanism |
| `failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `enableWeakerNestedSandbox` | Docker-inside-sandbox mode; weakens security significantly |

**Path prefix conventions for sandbox filesystem settings:**

| Prefix | Resolves to |
| :--- | :--- |
| `/path` | Absolute path |
| `~/path` | Relative to home directory |
| `./path` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

**Security limitations:** The built-in proxy does not terminate/inspect TLS; domain fronting is possible. `allowUnixSockets` can grant host access via `docker.sock`. Overly broad `allowWrite` can enable privilege escalation.

### Prompt injection protections

| Protection | Description |
| :--- | :--- |
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects potentially harmful instructions in full request context |
| Input sanitization | Prevents command injection via user inputs |
| Command blocklist | `curl` and `wget` blocked by default |
| Network request approval | Tools that make network requests require user approval |
| Isolated web fetch | WebFetch uses a separate context window |
| Trust verification | New MCP servers and first-time codebases require trust verification |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys and tokens are encrypted |

**Best practices with untrusted content:** Review commands before approval; avoid piping untrusted content directly to Claude; use VMs for external web services; report suspicious behavior with `/feedback`.

### Enterprise network configuration

**Proxy environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Bypass proxy for listed hosts (space- or comma-separated) |

Note: SOCKS proxies are not supported.

**CA certificate configuration:**

| Variable / Setting | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE` | Comma-separated sources: `bundled` (Mozilla CA) and/or `system` (OS store). Default: `bundled,system` |
| `NODE_EXTRA_CA_CERTS` | Path to custom enterprise CA cert (needed when using Node.js runtime) |

**mTLS client certificate variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate PEM |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key PEM |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads and auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome WebSocket bridge |

### Data usage policies

**Training data:**

| Account type | Default training use |
| :--- | :--- |
| Consumer (Free, Pro, Max) | Used when setting is on; change at claude.ai/settings/data-privacy-controls |
| Commercial (Team, Enterprise, API) | Not used unless opted in (e.g. Developer Partner Program) |

**Data retention:**

| Account type | Retention |
| :--- | :--- |
| Consumer, allows training | 5 years |
| Consumer, no training | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Not retained server-side after response |
| Local session transcripts | 30 days in `~/.claude/projects/` (configurable via `cleanupPeriodDays`) |
| Feedback via `/feedback` | 5 years |
| Session transcript opt-in upload | Up to 6 months |

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; enable ZDR for no server-side persistence |
| Amazon Bedrock | AES-256, AWS-managed keys; CMEK via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | Routes to Anthropic infrastructure with AES-256 |

**Telemetry opt-out environment variables:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Statsig operational metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic except WebFetch check |

Statsig, Sentry, and `/feedback` reporting are **off by default** when using Bedrock, Vertex, or Foundry.

### Zero Data Retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only. Must be enabled per organization by the Anthropic account team.

**What ZDR covers:** Model inference calls (prompts + responses) made through Claude Code on Claude for Enterprise.

**What ZDR does not cover:**

| Feature | Notes |
| :--- | :--- |
| Chat on claude.ai | Standard retention applies |
| Cowork sessions | Standard retention applies |
| Claude Code Analytics | Collects usage metadata (no prompts/responses) |
| Third-party integrations / MCP servers | Review those services independently |

**Features disabled under ZDR:** Claude Code on the Web, Remote sessions from Desktop app, `/feedback` command.

**Policy violations:** Even with ZDR, Anthropic may retain flagged data up to 2 years.

### Dev containers (security-relevant config)

Dev containers run Claude Code inside Docker, confining command execution to the container.

| Concern | Approach |
| :--- | :--- |
| Organization policy enforcement | Copy `managed-settings.json` to `/etc/claude-code/` in Dockerfile |
| Network egress restriction | Use `init-firewall.sh` pattern with `NET_ADMIN`/`NET_RAW` capabilities |
| Skip permission prompts (CI) | `--dangerously-skip-permissions` (non-root user only); pair with network restrictions |
| Prevent bypass mode entirely | Set `permissions.disableBypassPermissionsMode: "disable"` in managed settings |
| Persist auth across rebuilds | Mount named volume at `~/.claude` |
| Disable telemetry | Set `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` in `containerEnv` |
| Pin Claude Code version | Install with `npm install -g @anthropic-ai/claude-code@X.Y.Z` + `DISABLE_AUTOUPDATER=1` |

Warning: With `--dangerously-skip-permissions`, malicious projects can exfiltrate anything inside the container including credentials in `~/.claude`. Only use with trusted repositories.

### Legal and compliance

| Topic | Details |
| :--- | :--- |
| Commercial users | Subject to Commercial Terms of Service |
| Consumer users | Subject to Consumer Terms of Service |
| Healthcare (HIPAA BAA) | BAA automatically extends to Claude Code if customer has BAA + ZDR enabled |
| OAuth authentication | For subscription plan users only; not for third-party developers |
| API key authentication | Required for developers building products/services with Claude |
| Security vulnerability reporting | HackerOne program |
| Trust Center | trust.anthropic.com (SOC 2 Type 2, ISO 27001, etc.) |

### Reporting security issues

1. Do not disclose publicly
2. Report via [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new)
3. Include detailed reproduction steps
4. Allow time for remediation before public disclosure

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — security foundation, permission-based architecture, built-in protections, prompt injection safeguards, MCP security, cloud execution security, best practices, vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, OS-level enforcement, sandbox modes, configuration reference, security benefits, limitations, custom proxy setup, open source sandbox runtime
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate configuration, mTLS authentication, required network allowlist for firewalls
- [Data usage](references/claude-code-data-usage.md) — training data policies, data retention by account type, encryption at rest, telemetry services and opt-out, WebFetch domain safety check, cloud execution data flow
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what it covers and excludes, features disabled under ZDR, how to request enablement
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth, enforcing org policy, restricting network egress, running without permission prompts, reference container
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, healthcare BAA, acceptable use policy, authentication credential rules, security trust resources

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
