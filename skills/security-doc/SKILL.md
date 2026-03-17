---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- permission-based architecture (read-only default, explicit approval, Accept Edits mode, allowlisting), prompt injection protections (context-aware analysis, input sanitization, command blocklist, isolated context windows, command injection detection, fail-closed matching, trust verification), sandboxing (filesystem isolation with Seatbelt/bubblewrap, network isolation via proxy, OS-level enforcement, auto-allow mode, sandbox.filesystem.allowWrite/denyWrite/denyRead path prefixes, excludedCommands, allowUnsandboxedCommands escape hatch, custom proxy httpProxyPort/socksProxyPort, enableWeakerNestedSandbox, /sandbox command, sandbox modes), devcontainers (reference Dockerfile, init-firewall.sh whitelisted domains, default-deny policy, --dangerously-skip-permissions, VS Code integration), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY, proxy basic auth, NODE_EXTRA_CA_CERTS custom CA, mTLS with CLAUDE_CODE_CLIENT_CERT/CLIENT_KEY/CLIENT_KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, GitHub Enterprise IP allow list), data usage (consumer vs commercial training policy, Development Partner Program, /bug feedback retention, session quality surveys, data retention 5-year/30-day/ZDR, local vs cloud data flow, telemetry Statsig/Sentry opt-out DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING/DISABLE_BUG_COMMAND/CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, feedbackSurveyRate, default behaviors by API provider), zero data retention (ZDR scope, per-organization enablement, features disabled under ZDR -- Claude Code on the Web/remote sessions/feedback, ZDR does not cover chat/Cowork/analytics/third-party, policy violation retention up to 2 years), legal and compliance (Commercial Terms vs Consumer Terms, BAA with ZDR for healthcare, acceptable use policy, OAuth vs API key authentication restrictions, HackerOne vulnerability reporting), MCP security, IDE security, cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging), Remote Control security (local execution, TLS, short-lived credentials), Windows WebDAV risk. Load when discussing Claude Code security, sandboxing, sandbox configuration, prompt injection, permissions architecture, devcontainers, network configuration, proxy setup, custom CA certificates, mTLS, data usage, data retention, training policy, telemetry, zero data retention, ZDR, legal compliance, BAA, HIPAA, authentication credentials, MCP security, cloud execution security, privacy, data flow, vulnerability reporting, or enterprise security configuration.
user-invocable: false
---

# Security, Privacy & Compliance Documentation

This skill provides the complete official documentation for Claude Code's security architecture, sandboxing, data handling, enterprise network configuration, and legal compliance.

## Quick Reference

### Security Architecture

Claude Code uses read-only permissions by default. Every write or command requires explicit approval.

| Layer | Mechanism | Scope |
|:------|:----------|:------|
| **Permissions** | User approval before tool execution | All tools (Bash, Read, Edit, WebFetch, MCP) |
| **Sandboxing** | OS-level filesystem + network isolation | Bash commands and child processes only |
| **Devcontainer** | Container-level isolation with firewall | Full environment (enables `--dangerously-skip-permissions`) |
| **Prompt injection defense** | Input sanitization, command blocklist, isolated context windows | All user and fetched content |

### Prompt Injection Protections

| Protection | Details |
|:-----------|:--------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects harmful instructions by analyzing full request |
| Input sanitization | Prevents command injection in user inputs |
| Command blocklist | Blocks `curl`, `wget` by default |
| Isolated context windows | Web fetch uses separate context to avoid injecting malicious prompts |
| Trust verification | First-time codebase runs and new MCP servers require trust verification (disabled with `-p`) |
| Command injection detection | Suspicious commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Credential storage | API keys and tokens are encrypted |

### Sandboxing

Enable with `/sandbox`. Two modes available:

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands run without permission prompts; non-sandboxable commands fall back to normal flow |
| **Regular permissions** | All commands go through standard permission flow, even when sandboxed |

**OS enforcement**: macOS uses Seatbelt; Linux/WSL2 uses bubblewrap (install `bubblewrap` and `socat`). WSL1 is not supported.

**Filesystem isolation defaults**: read/write to CWD and subdirectories; read-only to the rest of the system (with certain denied directories).

**Key settings**:

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside CWD |
| `sandbox.filesystem.denyWrite` | Block subprocess write access to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess read access to specific paths |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `sandbox.allowedDomains` | Domains Bash commands can reach |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the escape hatch |
| `sandbox.excludedCommands` | Commands that always run outside the sandbox (e.g., `docker`) |

**Path prefix conventions** for `allowWrite`/`denyWrite`/`denyRead`:

| Prefix | Resolved to |
|:-------|:------------|
| `//` | Absolute from filesystem root (`//tmp/build` -> `/tmp/build`) |
| `~/` | Relative to home directory |
| `/` | Relative to the settings file's directory |
| `./` or none | Relative path (resolved by sandbox runtime) |

Arrays in `allowWrite`/`denyWrite`/`denyRead` merge across all settings scopes (managed, user, project, local).

**Security limitations**: network filtering is domain-based only (no traffic inspection); `allowUnixSockets` can expose powerful system services (e.g., Docker socket); overly broad filesystem write paths can enable privilege escalation; Linux `enableWeakerNestedSandbox` considerably weakens security.

### Devcontainers

The reference devcontainer provides container-level isolation enabling unattended operation with `--dangerously-skip-permissions`.

| Component | File |
|:----------|:-----|
| Container settings | `devcontainer.json` |
| Image definition | `Dockerfile` (Node.js 20 base) |
| Firewall rules | `init-firewall.sh` (default-deny, whitelisted domains only) |

Security features: outbound connections restricted to whitelisted domains, DNS and SSH allowed, default-deny policy, startup firewall validation.

### Enterprise Network Configuration

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy server URL |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` for all) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

All environment variables can also be set in `settings.json`.

**Required URLs** (must be allowlisted in proxy/firewall):

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Anthropic Console accounts |

SOCKS proxies are not supported. For proxies requiring NTLM/Kerberos, use an LLM Gateway.

### Data Usage & Retention

| Account type | Training policy | Retention |
|:-------------|:---------------|:----------|
| **Consumer** (Free, Pro, Max) | Opt-in/opt-out via privacy settings | 5 years (training on) or 30 days (training off) |
| **Commercial** (Team, Enterprise, API) | Not used for training (unless opted in via Developer Partner Program) | 30 days standard |
| **Enterprise with ZDR** | Not used for training | Zero retention (prompts/responses not stored after response returned) |

**Telemetry opt-out**:

| Service | Env var to disable |
|:--------|:-------------------|
| Statsig (metrics) | `DISABLE_TELEMETRY=1` |
| Sentry (errors) | `DISABLE_ERROR_REPORTING=1` |
| Bug reports | `DISABLE_BUG_COMMAND=1` |
| Session quality surveys | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| All non-essential traffic | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` |

For Bedrock, Vertex, and Foundry providers, telemetry/errors/bug-reports are off by default. Session quality surveys are on by default for all providers.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. ZDR is enabled per-organization by Anthropic account team.

**Features disabled under ZDR**: Claude Code on the Web, remote sessions from Desktop app, feedback submission (`/feedback`).

**Not covered by ZDR**: Chat on claude.ai, Cowork, Claude Code Analytics metadata, user/seat management, third-party integrations.

Policy violations may result in data retention up to 2 years regardless of ZDR status.

### Legal & Compliance

| Topic | Details |
|:------|:--------|
| **License** | Commercial Terms (Team/Enterprise/API) or Consumer Terms (Free/Pro/Max) |
| **BAA (Healthcare)** | Extends to Claude Code when customer has BAA + ZDR enabled |
| **Acceptable use** | Subject to Anthropic Usage Policy |
| **OAuth tokens** | For Claude Code and claude.ai only; not for Agent SDK or third-party tools |
| **API keys** | Required for building products/services, Agent SDK |
| **Vulnerability reporting** | HackerOne program |

### Cloud Execution Security

| Control | Details |
|:--------|:--------|
| Isolated VMs | Each session runs in an Anthropic-managed VM |
| Network controls | Limited by default; configurable to disable or allow specific domains |
| Credential protection | Secure proxy with scoped credential (never enters sandbox) |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions run locally (no cloud VMs); connection uses short-lived, narrowly scoped credentials over TLS.

### Security Best Practices

1. Review all suggested changes before approval
2. Use project-specific permission settings for sensitive repos
3. Consider devcontainers for additional isolation
4. Audit permissions regularly with `/permissions`
5. Use managed settings to enforce organizational standards
6. Share approved permission configurations via version control
7. Monitor usage through OpenTelemetry metrics
8. Audit settings changes with `ConfigChange` hooks
9. Avoid piping untrusted content directly to Claude
10. Report vulnerabilities through HackerOne (do not disclose publicly)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- security foundation (Anthropic Trust Center, SOC 2, ISO 27001), permission-based architecture (read-only default, explicit approval, Accept Edits mode, allowlisting, prompt fatigue mitigation), built-in protections (sandboxed bash, write access restriction, Accept Edits), prompt injection protections (permission system, context-aware analysis, input sanitization, command blocklist, isolated context windows, trust verification, command injection detection, fail-closed matching, credential storage, Windows WebDAV risk), privacy safeguards (retention periods, restricted access, training preferences), MCP security, IDE security, cloud execution security (isolated VMs, network controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control security (local execution, TLS, short-lived credentials), best practices for teams (managed settings, version-controlled permissions, OpenTelemetry monitoring, ConfigChange hooks), vulnerability reporting (HackerOne)
- [Sandboxing](references/claude-code-sandboxing.md) -- overview, why sandboxing matters (approval fatigue, reduced productivity, limited autonomy), filesystem isolation (default writes/read behavior, configurable allowWrite/denyWrite/denyRead, path prefix conventions, settings scope merging), network isolation (domain restrictions, user confirmation, custom proxy, comprehensive subprocess coverage), OS-level enforcement (macOS Seatbelt, Linux bubblewrap, WSL2/WSL1 support), getting started (prerequisites, /sandbox command, auto-allow vs regular permissions mode), configuration (allowWrite paths, excludedCommands, dangerouslyDisableSandbox escape hatch, allowUnsandboxedCommands toggle), security benefits (prompt injection protection, filesystem/network/monitoring protections, reduced attack surface), security limitations (domain-only network filtering, domain fronting risk, allowUnixSockets escalation, filesystem permission escalation, enableWeakerNestedSandbox), sandbox-permissions relationship, advanced usage (custom proxy httpProxyPort/socksProxyPort, integration with permissions/devcontainers/enterprise policies), open source sandbox-runtime npm package, platform limitations
- [Development containers](references/claude-code-devcontainer.md) -- reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), key features (Node.js 20, custom firewall, ZSH, VS Code integration, session persistence), getting started steps, security features (whitelisted domains, DNS/SSH allowed, default-deny, startup validation, isolation), customization options, example use cases (secure client work, team onboarding, consistent CI/CD)
- [Enterprise network configuration](references/claude-code-network-config.md) -- proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY, basic auth, no SOCKS support), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), required URLs (api.anthropic.com, claude.ai, platform.claude.com), GitHub Enterprise IP allow list configuration
- [Data usage](references/claude-code-data-usage.md) -- data training policy (consumer opt-in/opt-out, commercial no-training default, Developer Partner Program), /bug feedback retention (5 years), session quality surveys (numeric only, no transcripts, CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, feedbackSurveyRate), data retention (consumer 5-year/30-day, commercial 30-day, ZDR, local caching 30-day configurable), data access (local vs cloud data flow diagrams), telemetry services (Statsig metrics, Sentry errors, /bug reports, opt-out env vars), default behaviors by API provider table (Claude API, Vertex, Bedrock, Foundry)
- [Legal and compliance](references/claude-code-legal-and-compliance.md) -- legal agreements (Commercial Terms, Consumer Terms), commercial agreements (1P and 3P coverage), healthcare compliance (BAA extends to Claude Code with ZDR), acceptable use policy, authentication and credential use (OAuth for Claude Code/claude.ai only, API keys for Agent SDK/products, enforcement), trust and safety (Trust Center, Transparency Hub), vulnerability reporting (HackerOne)
- [Zero data retention](references/claude-code-zero-data-retention.md) -- ZDR scope (per-organization, Claude for Enterprise only, does not apply to Bedrock/Vertex/Foundry), what ZDR covers (model inference calls), what ZDR does not cover (chat on claude.ai, Cowork, Analytics metadata, user management, third-party integrations), features disabled under ZDR (Claude Code on the Web, remote sessions, feedback submission), data retention for policy violations (up to 2 years), requesting ZDR enablement, migration from API key ZDR to Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
