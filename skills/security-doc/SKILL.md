---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, prompt injection protections, sandboxing (filesystem/network isolation), dev containers, enterprise network configuration (proxy, CA certs, mTLS), data usage policies, zero data retention, and legal/compliance information.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, compliance, and enterprise network configuration.

## Quick Reference

### Security architecture overview

| Layer | Mechanism | Scope |
| :--- | :--- | :--- |
| Permission system | Explicit approval for edits, commands, network requests | All tools |
| Sandboxing | OS-level filesystem + network isolation for Bash commands | Bash and subprocesses |
| Write restrictions | Writes confined to working directory and subdirectories | All file tools |
| Prompt injection | Command blocklist, context analysis, input sanitization, isolated web fetch context | All inputs |
| Credential storage | API keys/tokens encrypted at rest | Auth |

### Sandboxing

**Enable:** run `/sandbox` in a session. Requires `bubblewrap` and `socat` on Linux/WSL2 (`sudo apt-get install bubblewrap socat`). Works out of the box on macOS (Seatbelt).

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed bash commands run without approval; unsandboxable commands fall back to normal permission flow |
| Regular permissions | All commands use standard approval flow even when sandboxed |

**OS enforcement:** macOS uses Seatbelt; Linux and WSL2 use bubblewrap. WSL1 is not supported.

**Key sandbox settings (in `settings.json`):**

| Setting | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable sandboxing |
| `sandbox.filesystem.allowWrite` | Additional paths subprocesses may write to |
| `sandbox.filesystem.denyWrite` | Paths to block subprocess writes |
| `sandbox.filesystem.denyRead` | Paths to block subprocess reads |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port for advanced filtering |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `allowManagedDomainsOnly` | Block all domains not in the allowed list |
| `allowUnsandboxedCommands` | Set to `false` to disable the `dangerouslyDisableSandbox` escape hatch |
| `sandbox.failIfUnavailable` | Treat sandbox startup failure as a hard error |
| `excludedCommands` | Commands forced to run outside the sandbox (e.g., `docker *`) |

**Path prefix conventions for sandbox filesystem settings:**

| Prefix | Resolves to |
| :--- | :--- |
| `/path` | Absolute path from filesystem root |
| `~/path` | Relative to home directory |
| `./path` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

Arrays from `allowWrite`, `denyWrite`, etc. are **merged** across settings scopes — they do not replace each other.

**Sandboxing limitations:**
- Network filtering restricts domains but does not inspect traffic content
- Broad domains like `github.com` can potentially allow data exfiltration
- `allowUnixSockets` for paths like `/var/run/docker.sock` may grant host access
- Linux `enableWeakerNestedSandbox` mode significantly weakens isolation (only for Docker-without-privileged-namespaces environments)
- Does not cover built-in file tools (Read, Edit, Write) or computer use

### Prompt injection protections

- Permission system: sensitive operations always require explicit approval
- Command blocklist: `curl`, `wget`, and similar commands blocked by default
- Input sanitization: prevents command injection
- Isolated web fetch context: WebFetch uses a separate context window
- Trust verification: first-time codebases and new MCP servers require trust confirmation (disabled with `-p` flag)
- Command injection detection: suspicious commands require manual approval even if allowlisted
- Fail-closed matching: unmatched commands default to manual approval

**Best practices with untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs or devcontainers when interacting with external web services
5. Report suspicious behavior with `/feedback`

### Dev containers

Reference setup: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

Key components:
- `devcontainer.json` — container settings, extensions, volume mounts
- `Dockerfile` — image and tools
- `init-firewall.sh` — network security rules (default-deny outbound except allowlisted domains)

Allows running `claude --dangerously-skip-permissions` for unattended operation inside the isolated environment. Only use with trusted repositories — devcontainers do not prevent credential exfiltration by malicious projects.

### Enterprise network configuration

**Proxy environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Bypass proxy (space- or comma-separated hostnames/IPs) |

SOCKS proxies are not supported. For basic auth, embed credentials in the proxy URL. For NTLM/Kerberos, use an LLM Gateway service.

**CA certificate configuration:**

| Variable / Setting | Purpose |
| :--- | :--- |
| `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem` | Trust a custom enterprise CA |
| `CLAUDE_CODE_CERT_STORE=bundled,system` | Control which CA stores to use (default: both) |

Enterprise TLS-inspection proxies (CrowdStrike Falcon, Zscaler) work automatically when their root cert is in the OS trust store, using the native binary distribution.

**mTLS client certificate authentication:**

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
| `downloads.claude.ai` | Plugin downloads, native installer/auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome WebSocket bridge |

When using Bedrock, Vertex AI, or Microsoft Foundry, model traffic goes to the provider instead of `api.anthropic.com`. WebFetch still calls `api.anthropic.com` for domain safety checks unless `skipWebFetchPreflight: true` is set.

### Data usage policies

**Training data:**
- Consumer users (Free/Pro/Max): data used for model training by default; opt out at [claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls)
- Commercial users (Team/Enterprise/API): Anthropic does not train on data unless customer explicitly opts in (e.g., Developer Partner Program)

**Data retention:**

| User type | Retention |
| :--- | :--- |
| Consumer — training allowed | 5 years |
| Consumer — training not allowed | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Not stored after response returned |

Local session transcripts stored in `~/.claude/projects/` for 30 days (adjustable via `cleanupPeriodDays`).

**Encryption in transit:** TLS 1.2+ for all API traffic.

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR available |
| Amazon Bedrock | AES-256 with AWS-managed or customer-managed KMS keys |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | AES-256 disk encryption via Anthropic infrastructure |

**Telemetry opt-outs:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Statsig metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic (not WebFetch check) |

By default, Statsig, Sentry, and feedback are **off** when using Bedrock, Vertex, or Foundry providers.

**WebFetch domain safety check:** Before fetching, only the hostname is sent to `api.anthropic.com` for blocklist checking. Results are cached 5 minutes per hostname. Disable with `skipWebFetchPreflight: true` in settings.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only (not Bedrock/Vertex/Foundry).

- ZDR is enabled **per organization** — new orgs must be enabled separately by your Anthropic account team
- Prompts and responses are not stored after the response is returned
- ZDR org features: cost controls per user, analytics dashboard, server-managed settings, audit logs

**What ZDR does not cover:**

| Feature | Notes |
| :--- | :--- |
| Chat on claude.ai | Follows standard retention |
| Cowork sessions | Follows standard retention |
| Claude Code Analytics | Collects usage metadata (not prompts); contribution metrics unavailable under ZDR |
| User/seat management | Admin data follows standard policies |
| Third-party integrations / MCP servers | Review those services independently |

**Features disabled under ZDR:** Claude Code on the Web, Remote sessions from Desktop app, `/feedback` submission.

**Policy violations:** Anthropic may retain data up to 2 years if flagged for a usage policy violation.

To request ZDR: contact [sales](https://www.anthropic.com/contact-sales) or your Anthropic account team.

### Legal and compliance highlights

- **Healthcare (BAA):** BAA automatically extends to Claude Code when the customer has both an executed BAA and ZDR enabled.
- **Licensing:** Commercial Terms apply for Team/Enterprise/API; Consumer Terms for Free/Pro/Max.
- **Auth policy:** OAuth authentication is for direct Anthropic plan subscribers only. Third-party developers must use API keys. Routing requests through Free/Pro/Max credentials on behalf of third-party users is not permitted.
- **Security vulnerability reporting:** [HackerOne VDP form](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)
- **Trust Center:** [trust.anthropic.com](https://trust.anthropic.com) (SOC 2 Type 2, ISO 27001, etc.)

### Cloud execution security

Each cloud session runs in an isolated Anthropic-managed VM with:
- Network access limited by default (configurable)
- GitHub auth via secure proxy (credentials never enter sandbox)
- Git push restricted to current working branch
- Audit logging of all operations
- Automatic environment cleanup after session

Remote Control sessions run on your local machine; no cloud VMs involved. Uses multiple short-lived, narrowly scoped credentials.

### Security best practices summary

- Use `/permissions` to audit permission settings regularly
- Use managed settings to enforce org-wide standards
- Use `ConfigChange` hooks to audit or block settings changes during sessions
- Monitor via OpenTelemetry metrics
- Use devcontainers or sandboxing for additional isolation with untrusted code
- Share approved permission configurations via version control

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, built-in protections, prompt injection safeguards, MCP/IDE/cloud security, and best practices
- [Sandboxing](references/claude-code-sandboxing.md) — OS-level filesystem and network isolation, sandbox modes, configuration, limitations, and open source sandbox runtime
- [Development containers](references/claude-code-devcontainer.md) — preconfigured secure dev container with firewall rules for isolated, unattended operation
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate trust, mTLS authentication, and required network allowlist
- [Data usage](references/claude-code-data-usage.md) — training policies, data retention by account type, encryption, telemetry, and WebFetch domain safety check
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, coverage exclusions, and how to request enablement
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, healthcare BAA, usage policy, authentication rules, and trust/safety resources

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
