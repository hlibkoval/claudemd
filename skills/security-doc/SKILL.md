---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- covering security architecture (permission-based system, built-in protections, prompt injection defenses, command blocklist, input sanitization, context-aware analysis, fail-closed matching, command injection detection, trust verification, secure credential storage, Accept Edits mode), sandboxing (filesystem isolation with Seatbelt/bubblewrap, network isolation via proxy, OS-level enforcement on macOS/Linux/WSL2, /sandbox command, auto-allow vs regular permissions modes, sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead path rules with ~//./ prefixes, path merging across scopes, excludedCommands, allowUnsandboxedCommands escape hatch, sandbox.failIfUnavailable, custom proxy with httpProxyPort/socksProxyPort, allowedDomains, allowManagedDomainsOnly, allowManagedReadPathsOnly, enableWeakerNestedSandbox, domain fronting risk, Unix socket escalation, open source sandbox-runtime npm package), devcontainers (reference devcontainer setup with Dockerfile and init-firewall.sh, --dangerously-skip-permissions, firewall rules, whitelisted domains only, default-deny policy, VS Code Dev Containers extension), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY environment variables, custom CA certs via NODE_EXTRA_CA_CERTS, mTLS with CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, downloads.claude.ai, GitHub Enterprise IP allowlisting), data usage (consumer vs commercial training policies, Development Partner Program, /feedback data, session quality surveys with CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, data retention 5-year/30-day by plan, ZDR for Enterprise, local caching, telemetry via Statsig/Sentry with DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING, default behaviors by API provider Claude/Vertex/Bedrock/Foundry, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC), zero data retention (ZDR scope for Claude for Enterprise, per-org enablement, covers inference not chat/Cowork/analytics/integrations, disabled features under ZDR: Code on the Web/remote sessions/feedback, 2-year retention for policy violations), legal and compliance (Commercial Terms/Consumer Terms, BAA with ZDR for healthcare, Acceptable Use Policy, OAuth vs API key authentication rules, HackerOne vulnerability reporting), cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control security (local execution, TLS, short-lived scoped credentials), MCP security (user-configured servers, source control settings, no Anthropic audit), IDE security, team security (managed settings, OpenTelemetry, ConfigChange hooks), Windows WebDAV risk. Load when discussing Claude Code security, privacy, data usage, data retention, training policy, sandboxing, sandbox configuration, devcontainer, network configuration, proxy settings, mTLS, custom CA certificates, ZDR, zero data retention, BAA, HIPAA, compliance, legal terms, prompt injection protection, command blocklist, firewall rules, telemetry opt-out, Statsig, Sentry, error reporting, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, sandbox.filesystem, allowWrite, denyWrite, denyRead, excludedCommands, bubblewrap, Seatbelt, sandbox modes, allowedDomains, domain restrictions, NODE_EXTRA_CA_CERTS, HTTPS_PROXY, HackerOne, vulnerability reporting, trust verification, credential storage, cloud execution security, Remote Control security, MCP security, IDE security, accept edits mode, permission-based architecture, data training opt-out, session quality surveys, managed settings enforcement, or any security/privacy/compliance topic for Claude Code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, data handling, and compliance.

## Quick Reference

### Security Architecture

| Layer | Protection |
|:------|:-----------|
| **Permission system** | Read-only by default; explicit approval for edits and commands |
| **Sandboxing** | OS-level filesystem and network isolation for bash commands |
| **Prompt injection defenses** | Context-aware analysis, input sanitization, command blocklist, fail-closed matching |
| **Trust verification** | Required for first-time codebases and new MCP servers (disabled with `-p` flag) |
| **Command injection detection** | Suspicious commands require manual approval even if allowlisted |
| **Credential storage** | API keys and tokens encrypted on disk |
| **Accept Edits mode** | Batch accept file edits while maintaining command permission prompts |
| **Write restriction** | Can only write to the working directory and subdirectories |

### Prompt Injection Defenses

| Defense | Detail |
|:--------|:-------|
| **Permission system** | Sensitive operations require explicit approval |
| **Context-aware analysis** | Detects potentially harmful instructions by analyzing the full request |
| **Input sanitization** | Prevents command injection by processing user inputs |
| **Command blocklist** | Blocks `curl`, `wget`, and similar commands by default |
| **Network request approval** | Network tools require user approval by default |
| **Isolated context windows** | Web fetch uses separate context window to avoid prompt injection |
| **Fail-closed matching** | Unmatched commands default to requiring manual approval |
| **Natural language descriptions** | Complex bash commands include plain-language explanations |

### Sandboxing

#### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands run without permission prompts; unsandboxable commands fall back to normal permission flow |
| **Regular permissions** | All commands go through standard permission flow, even when sandboxed |

Enable with `/sandbox`. Both modes enforce identical filesystem and network restrictions -- the difference is only whether sandboxed commands are auto-approved.

#### OS-Level Enforcement

| Platform | Mechanism |
|:---------|:----------|
| **macOS** | Seatbelt (built-in, works out of the box) |
| **Linux / WSL2** | bubblewrap + socat (`apt-get install bubblewrap socat` or `dnf install bubblewrap socat`) |
| **WSL1** | Not supported (missing kernel features) |

#### Filesystem Rules

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside cwd (e.g., `["~/.kube", "/tmp/build"]`) |
| `sandbox.filesystem.denyWrite` | Block subprocess writes to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess reads from specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads inside a `denyRead` region (takes precedence) |

Path arrays are **merged** across settings scopes (managed, user, project, local) -- not replaced.

**Path prefix conventions:**

| Prefix | Meaning |
|:-------|:--------|
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

#### Network Rules

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.allowedDomains` | Domains bash commands can reach |
| `sandbox.network.allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |

#### Other Sandbox Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `sandbox.excludedCommands` | Commands forced to run outside sandbox (e.g., `docker`) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the escape hatch that retries failed commands outside sandbox |
| `sandbox.allowManagedReadPathsOnly` | Only managed `allowRead` entries respected; user/project/local entries ignored |
| `enableWeakerNestedSandbox` | Weaker isolation for Docker environments without privileged namespaces (significantly reduces security) |

#### Security Limitations

- **Network filtering** restricts domains only; does not inspect traffic content. Users must ensure only trusted domains are allowed
- **Domain fronting** may bypass network filtering in some cases
- **Unix sockets** (`allowUnixSockets`) can grant access to powerful system services (e.g., Docker socket enables host-system access)
- **Broad filesystem writes** to `$PATH` directories, system config, or shell rc files can enable privilege escalation
- **Sandbox does not cover** built-in Read/Edit/Write tools (these use the permission system) or computer use (runs on actual desktop)

#### Open Source Sandbox Runtime

```
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

Available as an npm package for use in other agent projects or to sandbox arbitrary programs (e.g., MCP servers). Source: [github.com/anthropic-experimental/sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime)

### Development Containers

The reference [devcontainer setup](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides:

| Component | Purpose |
|:----------|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Node.js 20 image with dev tools (git, ZSH, fzf) |
| `init-firewall.sh` | Firewall: whitelisted domains only, default-deny, DNS/SSH allowed |

The container's isolation + firewall rules support `claude --dangerously-skip-permissions` for unattended operation. Use trusted repositories only -- devcontainers do not prevent exfiltration of anything accessible inside the container (including credentials).

### Enterprise Network Configuration

#### Proxy Settings

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL (fallback) |
| `NO_PROXY` | Bypass proxy -- space or comma-separated domains, or `*` for all |

Basic auth: `http://username:password@proxy.example.com:8080`. SOCKS proxies are not supported. For advanced auth (NTLM, Kerberos), use an LLM Gateway.

#### Certificates and mTLS

| Variable | Purpose |
|:---------|:--------|
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

All environment variables can also be configured in `settings.json`.

#### Required Network Access

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Anthropic Console accounts |
| `downloads.claude.ai` | Native installer, update checks, binaries |
| `storage.googleapis.com` | Legacy download bucket (deprecation in progress) |

GitHub Enterprise Cloud with IP restrictions: enable [IP allow list inheritance for installed GitHub Apps](https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-allowed-ip-addresses-for-your-organization#allowing-access-by-github-apps), or manually add [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Data Usage and Retention

#### Training Policy

| Plan | Policy |
|:-----|:-------|
| **Free, Pro, Max** (consumer) | User chooses whether data is used for training; toggle in privacy settings |
| **Team, Enterprise, API** (commercial) | Anthropic does not train on data under commercial terms unless customer opts in (e.g., Developer Partner Program) |
| **Bedrock / Vertex / Foundry** | Governed by those platforms' policies |

#### Data Retention

| Condition | Retention |
|:----------|:----------|
| Consumer, training allowed | 5 years |
| Consumer, training not allowed | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR on Enterprise) | Not retained (real-time processing only) |
| `/feedback` transcripts | 5 years |
| ZDR policy violation flag | Up to 2 years |
| Local session cache | Up to 30 days (configurable) |

#### Telemetry and Opt-Out

| Service | Default (Claude API) | Default (Vertex/Bedrock/Foundry) | Disable with |
|:--------|:---------------------|:---------------------------------|:-------------|
| **Statsig** (metrics) | On | Off | `DISABLE_TELEMETRY=1` |
| **Sentry** (errors) | On | Off | `DISABLE_ERROR_REPORTING=1` |
| **Feedback** (`/feedback`) | On | Off | `DISABLE_FEEDBACK_COMMAND=1` |
| **Session surveys** | On | On | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |

Set `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` to disable all non-essential traffic at once (including surveys). Frequency control for surveys: `feedbackSurveyRate` (0-1) in settings. Session surveys only record a numeric rating (1/2/3/dismiss) -- no transcripts or session data.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. ZDR is per-organization -- each org must be enabled separately by your Anthropic account team.

**What ZDR covers:** Model inference calls through Claude Code on Claude for Enterprise (prompts and responses not retained).

**What ZDR does not cover:**

| Feature | Detail |
|:--------|:-------|
| Chat on claude.ai | Not covered |
| Cowork sessions | Not covered |
| Analytics | Metadata (emails, usage stats) retained; contribution metrics unavailable |
| Seat management | Administrative data retained under standard policies |
| Third-party integrations | Review those services' policies independently |

**Features disabled under ZDR:**

| Feature | Reason |
|:--------|:-------|
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions (Desktop) | Requires persistent session data |
| `/feedback` | Sends conversation data to Anthropic |

### Legal and Compliance

| Topic | Detail |
|:------|:-------|
| **Commercial Terms** | Team, Enterprise, and API users: [anthropic.com/legal/commercial-terms](https://www.anthropic.com/legal/commercial-terms) |
| **Consumer Terms** | Free, Pro, and Max users: [anthropic.com/legal/consumer-terms](https://www.anthropic.com/legal/consumer-terms) |
| **BAA (Healthcare)** | Automatically extends to Claude Code if customer has BAA + ZDR enabled |
| **Acceptable Use** | Subject to [Anthropic Usage Policy](https://www.anthropic.com/legal/aup) |
| **OAuth auth** | Claude Code and claude.ai only; using OAuth tokens in other products/Agent SDK violates Consumer Terms |
| **API key auth** | Required for developers building products/services, via Claude Console or cloud provider |
| **Vulnerability reporting** | [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) |
| **Trust Center** | [trust.anthropic.com](https://trust.anthropic.com) -- SOC 2 Type 2, ISO 27001, etc. |

### Cloud Execution Security

| Control | Detail |
|:--------|:-------|
| **Isolated VMs** | Each cloud session in an Anthropic-managed VM |
| **Network controls** | Limited by default; configurable to disable or allow specific domains only |
| **Credential protection** | Secure proxy with scoped sandbox credential translated to actual GitHub token |
| **Branch restrictions** | Git push restricted to current working branch |
| **Audit logging** | All operations logged |
| **Automatic cleanup** | Environments terminated after session completion |

### Remote Control Security

Web interface connects to local Claude Code process. All execution stays local. Data flows through Anthropic API over TLS (same as normal local usage). Uses multiple short-lived, narrowly scoped credentials to limit blast radius.

### Security Best Practices

**Working with untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external web services
5. Report suspicious behavior with `/feedback`

**Team security:**
- Use managed settings to enforce organizational standards
- Share approved permission configurations through version control
- Monitor usage through OpenTelemetry metrics
- Audit settings changes with `ConfigChange` hooks

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Security architecture, permission-based system, built-in protections, prompt injection defenses (command blocklist, input sanitization, context-aware analysis, fail-closed matching, command injection detection, trust verification, isolated context windows, secure credential storage), privacy safeguards, MCP security, IDE security, cloud execution security (isolated VMs, network controls, credential protection, branch restrictions, audit logging), Remote Control security (local execution, TLS, short-lived scoped credentials), Windows WebDAV risk, best practices for untrusted content, team security (managed settings, OpenTelemetry, ConfigChange hooks), vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- Sandboxed bash tool overview, filesystem isolation (allowWrite/denyWrite/denyRead/allowRead, path prefix conventions, scope merging), network isolation (proxy-based domain restrictions, allowedDomains, allowManagedDomainsOnly, custom proxy ports), OS-level enforcement (Seatbelt macOS, bubblewrap Linux/WSL2), sandbox modes (auto-allow vs regular permissions), configuration (excludedCommands, allowUnsandboxedCommands escape hatch, failIfUnavailable, enableWeakerNestedSandbox), security limitations (domain fronting, Unix socket escalation, filesystem permission escalation), sandbox vs permissions relationship, open source sandbox-runtime npm package, compatibility notes (watchman, docker)
- [Development containers](references/claude-code-devcontainer.md) -- Reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), firewall with whitelisted domains and default-deny policy, --dangerously-skip-permissions for unattended operation, key features (Node.js 20, security firewall, ZSH tools, VS Code integration, session persistence), customization options
- [Enterprise network configuration](references/claude-code-network-config.md) -- Proxy settings (HTTPS_PROXY, HTTP_PROXY, NO_PROXY), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE), required URLs (api.anthropic.com, claude.ai, platform.claude.com, downloads.claude.ai), GitHub Enterprise IP allowlisting
- [Data usage](references/claude-code-data-usage.md) -- Training policy (consumer opt-in vs commercial no-training default), Development Partner Program, /feedback data handling, session quality surveys, data retention (5-year/30-day by plan, ZDR, local caching), data flow diagrams (local and cloud), telemetry services (Statsig, Sentry, opt-out env vars), default behaviors by API provider (Claude/Vertex/Bedrock/Foundry), CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- Commercial Terms, Consumer Terms, BAA extending to Claude Code with ZDR, Acceptable Use Policy, OAuth vs API key authentication rules, HackerOne vulnerability reporting, Anthropic Trust Center
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR scope for Claude for Enterprise, per-org enablement, what ZDR covers (inference) and does not cover (chat, Cowork, analytics, seat management, third-party integrations), features disabled under ZDR (Code on the Web, remote sessions, /feedback), 2-year retention for policy violations, requesting ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
