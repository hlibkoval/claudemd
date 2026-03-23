---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, legal compliance, and zero data retention -- permission-based architecture (read-only default, explicit approval for edits/commands), built-in protections (sandboxed bash tool, write access restriction to project scope, prompt fatigue mitigation with allowlists, Accept Edits mode), prompt injection safeguards (permission system, context-aware analysis, input sanitization, command blocklist for curl/wget, isolated context windows for web fetch, trust verification, command injection detection, fail-closed matching), MCP security (user-configured servers, settings checked into source control), IDE and cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging), Remote Control (local execution, TLS, short-lived scoped credentials), sandbox modes (auto-allow and regular permissions), OS-level enforcement (Seatbelt on macOS, bubblewrap on Linux/WSL2), filesystem isolation (allowWrite, denyWrite, denyRead, allowRead, path prefix resolution with / ~ ./ conventions, merged arrays across settings scopes, allowManagedReadPathsOnly), network isolation (domain restrictions, user confirmation prompts, allowManagedDomainsOnly, custom proxy with httpProxyPort/socksProxyPort), sandbox escape hatch (dangerouslyDisableSandbox parameter, allowUnsandboxedCommands setting), excludedCommands, enableWeakerNestedSandbox, sandbox limitations (domain fronting, Unix socket escalation, filesystem permission escalation), sandbox and permissions complementary layers, devcontainer setup (Dockerfile, init-firewall.sh, devcontainer.json, --dangerously-skip-permissions, firewall whitelisting, VS Code Remote-Containers), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY, NODE_EXTRA_CA_CERTS for custom CA, mTLS with CLAUDE_CODE_CLIENT_CERT/CLAUDE_CODE_CLIENT_KEY/CLAUDE_CODE_CLIENT_KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, download URLs downloads.claude.ai/storage.googleapis.com, GitHub Enterprise IP allow list), data usage policies (consumer vs commercial training policy, Development Partner Program opt-in, /feedback transcript retention 5 years, session quality surveys numeric-only, data retention 5-year consumer with training on or 30-day without or 30-day commercial or ZDR for Enterprise, local data flow with TLS encryption, cloud data flow with isolated VMs and credential proxy, telemetry Statsig/Sentry with DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING env vars, default behaviors by API provider table), legal and compliance (Commercial Terms vs Consumer Terms, BAA extending to Claude Code with ZDR, OAuth vs API key authentication restrictions, HackerOne vulnerability reporting), zero data retention (ZDR for Claude for Enterprise, per-organization enablement, covers inference calls only, does not cover chat/Cowork/analytics/seat-management/third-party integrations, features disabled under ZDR including Claude Code on Web and remote sessions and /feedback, 2-year retention for policy violations, request through account team). Load when discussing Claude Code security, sandboxing, sandbox configuration, filesystem isolation, network isolation, devcontainers, development containers, prompt injection protection, permission architecture, data usage, data retention, training policy, zero data retention, ZDR, enterprise network config, proxy configuration, custom CA certificates, mTLS, legal compliance, BAA, HIPAA, commercial terms, trust center, security best practices, MCP security, cloud execution security, Remote Control security, WebDAV risk, security vulnerability reporting, HackerOne, telemetry opt-out, Sentry, Statsig, or data privacy.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal compliance, and zero data retention.

## Quick Reference

Claude Code is built with security at its core, following Anthropic's comprehensive security program (SOC 2 Type 2, ISO 27001 -- see [Anthropic Trust Center](https://trust.anthropic.com)). It uses strict read-only permissions by default and requires explicit approval for edits, commands, and other actions.

### Permission-Based Architecture

| Layer | Protection |
|:------|:-----------|
| **Read-only default** | Claude can only read by default; writing/executing requires approval |
| **Write scope restriction** | Writes confined to the folder where Claude Code was started and its subfolders |
| **Sandboxed bash** | OS-level filesystem and network isolation via `/sandbox` |
| **Prompt fatigue mitigation** | Allowlist frequently used safe commands per-user, per-codebase, or per-org |
| **Accept Edits mode** | Batch accept file edits while maintaining command permission prompts |

### Prompt Injection Protections

| Protection | Description |
|:-----------|:------------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects potentially harmful instructions by analyzing full request |
| Input sanitization | Prevents command injection via input processing |
| Command blocklist | Blocks `curl`, `wget` by default; when allowed, pattern limitations apply |
| Isolated context windows | Web fetch uses separate context to avoid injecting malicious prompts |
| Trust verification | First-time codebase runs and new MCP servers require trust verification (disabled with `-p`) |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Sandboxing

Sandbox provides OS-level enforcement for bash commands, reducing permission prompts while maintaining security. Enable with `/sandbox`.

**Sandbox modes:**

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands run without permission prompts; non-sandboxable commands fall back to normal flow |
| **Regular permissions** | All commands go through standard permission flow even when sandboxed |

**OS-level enforcement:**

| Platform | Mechanism |
|:---------|:----------|
| macOS | Seatbelt (built-in, works out of the box) |
| Linux / WSL2 | bubblewrap + socat (install via `apt-get` or `dnf`) |
| WSL1 | Not supported |
| Windows native | Planned |

**Filesystem isolation settings:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside project (e.g., `["~/.kube", "/tmp/build"]`) |
| `sandbox.filesystem.denyWrite` | Block subprocess writes to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess reads from specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region (takes precedence) |
| `allowManagedReadPathsOnly` | Only managed `allowRead` entries are respected; user/project/local entries ignored |

**Path prefix resolution:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `/` | Absolute path | `/tmp/build` |
| `~/` | Relative to home | `~/.kube` becomes `$HOME/.kube` |
| `./` or none | Relative to project root (in project settings) or `~/.claude` (in user settings) | `./output` |

Arrays are **merged** across settings scopes (managed + user + project), not replaced.

**Network isolation:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.network.allowedDomains` | Domains bash commands can reach |
| `allowManagedDomainsOnly` | Blocks non-allowed domains automatically (no user prompt) |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |

**Escape hatch:** Commands that fail due to sandbox restrictions may retry with `dangerouslyDisableSandbox`, going through normal permission flow. Disable with `"allowUnsandboxedCommands": false`.

**Sandbox security limitations:**
- Network filtering restricts domains only; does not inspect traffic. Domain fronting may bypass filtering.
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket).
- Overly broad filesystem write permissions can enable privilege escalation via executables in `$PATH` or shell config files.
- Linux `enableWeakerNestedSandbox` mode (for Docker without privileged namespaces) considerably weakens security.

### Devcontainers

The reference [devcontainer setup](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides a preconfigured container for secure, isolated development. Components: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`.

| Feature | Details |
|:--------|:--------|
| Firewall | Default-deny policy; whitelists npm registry, GitHub, Claude API, DNS, SSH only |
| Isolation | Separated from host system |
| Unattended mode | Enables `claude --dangerously-skip-permissions` |
| Platform support | macOS, Windows, Linux |
| VS Code integration | Remote-Containers extension |

### Enterprise Network Configuration

**Proxy:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` for all) |

SOCKS proxies are not supported. For advanced auth (NTLM, Kerberos), use an LLM Gateway.

**Custom CA:** `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem`

**mTLS:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key (optional) |

**Required network access:**

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API |
| `claude.ai` | Authentication (claude.ai accounts) |
| `platform.claude.com` | Authentication (Console accounts) |
| `downloads.claude.ai` | Native installer, updates |
| `storage.googleapis.com` | Legacy downloads (deprecating) |

For GitHub Enterprise Cloud with IP restrictions, enable IP allow list inheritance for installed GitHub Apps or add ranges from [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Data Usage & Retention

**Training policy:**

| Plan type | Training |
|:----------|:---------|
| Free, Pro, Max (consumer) | Opt-in via privacy settings (on by default) |
| Team, Enterprise, API (commercial) | Not used for training unless opted in via Development Partner Program |

**Data retention:**

| Account type | Retention |
|:-------------|:----------|
| Consumer (training on) | 5 years |
| Consumer (training off) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | No retention (except law/misuse) |
| `/feedback` transcripts | 5 years |
| Local session cache | Up to 30 days (configurable) |

**Telemetry opt-out:**

| Service | Env var to disable |
|:--------|:-------------------|
| Statsig (metrics) | `DISABLE_TELEMETRY=1` |
| Sentry (errors) | `DISABLE_ERROR_REPORTING=1` |
| `/feedback` command | `DISABLE_FEEDBACK_COMMAND=1` |
| Session quality surveys | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| All non-essential traffic | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` |

Bedrock, Vertex, and Foundry have telemetry/error reporting/feedback **off by default** (session surveys still on).

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Enabled per-organization by Anthropic account team.

**ZDR covers:** Model inference calls (prompts and responses not retained).

**ZDR does not cover:** Chat on claude.ai, Cowork, Claude Code Analytics metadata, user/seat management, third-party integrations.

**Features disabled under ZDR:** Claude Code on the Web, remote sessions from Desktop app, `/feedback` submission.

**Policy violations:** Data may be retained up to 2 years if flagged.

### Legal & Compliance

| Topic | Details |
|:------|:--------|
| License | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) (Team, Enterprise, API) or [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) (Free, Pro, Max) |
| BAA (HIPAA) | Extends to Claude Code when customer has BAA + ZDR activated |
| OAuth tokens | Exclusively for Claude Code and claude.ai; using in other products/Agent SDK violates Consumer Terms |
| API keys | Required for developers building products with Agent SDK or cloud providers |
| Vulnerability reporting | [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) |

### Cloud Execution Security

| Control | Description |
|:--------|:------------|
| Isolated VMs | Each session runs in an Anthropic-managed VM |
| Network access controls | Limited by default; configurable per-domain |
| Credential protection | GitHub auth via secure proxy with scoped credentials |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session completion |

### Security Best Practices

- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Consider devcontainers for additional isolation
- Audit permissions with `/permissions`
- Use managed settings for organizational standards
- Share approved permission configs via version control
- Monitor usage through OpenTelemetry metrics
- Audit config changes with `ConfigChange` hooks
- Avoid piping untrusted content directly to Claude
- Use VMs for scripts interacting with external web services

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- permission-based architecture (read-only default, explicit approval, write access restriction), built-in protections (sandboxed bash, prompt fatigue mitigation, Accept Edits mode), prompt injection safeguards (permission system, context-aware analysis, input sanitization, command blocklist, isolated context windows, trust verification, command injection detection, fail-closed matching, natural language descriptions, secure credential storage, Windows WebDAV warning), best practices for untrusted content, MCP security (user-configured servers, settings in source control), IDE security, cloud execution security (isolated VMs, network controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control (local execution, TLS, short-lived scoped credentials), team security (managed settings, version-controlled permissions, OpenTelemetry monitoring, ConfigChange hooks), vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- sandbox overview and motivation (approval fatigue, reduced productivity, limited autonomy), OS-level enforcement (Seatbelt on macOS, bubblewrap on Linux/WSL2), sandbox modes (auto-allow, regular permissions), filesystem isolation (allowWrite, denyWrite, denyRead, allowRead, path prefix resolution, merged arrays across scopes, allowManagedReadPathsOnly), network isolation (domain restrictions, allowManagedDomainsOnly, custom proxy httpProxyPort/socksProxyPort), escape hatch (dangerouslyDisableSandbox, allowUnsandboxedCommands), excludedCommands, security benefits (prompt injection protection, reduced attack surface, transparent operation), security limitations (domain fronting, Unix socket escalation, filesystem permission escalation, enableWeakerNestedSandbox), sandboxing and permissions complementary layers, advanced custom proxy configuration, integration with permissions/devcontainers/enterprise policies, open source sandbox-runtime npm package
- [Development containers](references/claude-code-devcontainer.md) -- reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), firewall configuration (whitelisted domains, default-deny, DNS/SSH allowed), --dangerously-skip-permissions for unattended operation, VS Code Remote-Containers integration, customization options, use cases (secure client work, team onboarding, consistent CI/CD)
- [Enterprise network configuration](references/claude-code-network-config.md) -- proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY, basic auth), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), required URLs (api.anthropic.com, claude.ai, platform.claude.com), download URLs (downloads.claude.ai, storage.googleapis.com), GitHub Enterprise Cloud IP allow list inheritance
- [Data usage](references/claude-code-data-usage.md) -- training policy (consumer opt-in, commercial not trained), Development Partner Program, /feedback transcript retention, session quality surveys (numeric only, no transcript data), data retention periods (5-year consumer with training, 30-day without, 30-day commercial, ZDR), local and cloud data flows, telemetry services (Statsig metrics, Sentry errors, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, DISABLE_FEEDBACK_COMMAND), default behaviors by API provider (Claude/Vertex/Bedrock/Foundry table), CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- license terms (Commercial Terms for Team/Enterprise/API, Consumer Terms for Free/Pro/Max), commercial agreements (1P API and 3P Bedrock/Vertex), BAA for healthcare compliance (extends to Claude Code with ZDR), acceptable use policy, OAuth vs API key authentication restrictions (OAuth for Claude Code/claude.ai only, API keys for developers/Agent SDK), HackerOne vulnerability reporting, trust center and transparency hub
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR for Claude for Enterprise (per-organization enablement, covers inference calls only), what ZDR does not cover (chat on claude.ai, Cowork, analytics metadata, seat management, third-party integrations), features disabled under ZDR (Claude Code on Web, remote Desktop sessions, /feedback), data retention for policy violations (up to 2 years), requesting ZDR through account team, transitioning from API keys to Enterprise with ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
