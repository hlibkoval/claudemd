---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- security architecture (permission-based model, built-in protections, prompt injection defenses, MCP security, IDE security, cloud execution security), sandboxing (filesystem isolation with allowWrite/denyWrite/denyRead/allowRead, network isolation with domain restrictions and custom proxy, OS-level enforcement via Seatbelt/bubblewrap, sandbox modes auto-allow vs regular permissions, /sandbox command, excludedCommands, dangerouslyDisableSandbox escape hatch, allowUnsandboxedCommands, enableWeakerNestedSandbox), development containers (devcontainer.json/Dockerfile/init-firewall.sh, --dangerously-skip-permissions, firewall whitelisting), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY, custom CA certs NODE_EXTRA_CA_CERTS, mTLS with CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com, GitHub Enterprise IP allowlisting), data usage (training policy consumer vs commercial, Development Partner Program, /feedback data, session quality surveys, data retention 5-year/30-day/ZDR, telemetry Statsig/Sentry, DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING, default behaviors by API provider), legal and compliance (Commercial Terms vs Consumer Terms, BAA with ZDR, acceptable use policy, OAuth vs API key authentication restrictions, HackerOne vulnerability reporting), zero data retention (ZDR scope and coverage, features disabled under ZDR including Claude Code on Web and remote sessions and /feedback, data retention for policy violations, per-organization enablement). Load when discussing Claude Code security, sandboxing, sandbox configuration, filesystem isolation, network isolation, devcontainers, development containers, enterprise proxy, mTLS, custom CA certificates, data usage, data retention, training policy, telemetry, zero data retention, ZDR, legal terms, BAA, HIPAA, compliance, prompt injection protection, HackerOne, trust center, or privacy safeguards.
user-invocable: false
---

# Security, Privacy & Compliance Documentation

This skill provides the complete official documentation for Claude Code's security architecture, sandboxing, data handling, network configuration, and legal compliance.

## Quick Reference

### Security Architecture

Claude Code uses a **permission-based architecture**: read-only by default, explicit approval required for writes and command execution. Users control whether to approve once or allow automatically.

**Built-in protections:**

| Protection | Description |
|:-----------|:------------|
| Sandboxed bash tool | OS-level filesystem and network isolation; enable with `/sandbox` |
| Write access restriction | Can only write within the started folder and subfolders |
| Prompt fatigue mitigation | Allowlisting safe commands per-user, per-codebase, or per-org |
| Accept Edits mode | Batch accept edits while keeping command permission prompts |
| Command blocklist | `curl`, `wget` blocked by default to prevent fetching arbitrary web content |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

**Prompt injection defenses:**

- Permission system requires explicit approval for sensitive operations
- Context-aware analysis detects harmful instructions
- Input sanitization prevents command injection
- Network requests require approval; web fetch uses isolated context window
- First-time codebase runs and new MCP servers require trust verification (disabled with `-p` flag)
- Secure credential storage with encryption

**Cloud execution security (Claude Code on the web):**

- Isolated VMs per session, network access controls, credential protection via secure proxy
- Git push restricted to current working branch, audit logging, automatic cleanup

**Remote Control sessions** run locally -- no cloud VMs, connection uses short-lived scoped credentials over TLS.

### Sandboxing

OS-level enforcement using **Seatbelt** (macOS) and **bubblewrap** (Linux/WSL2). WSL1 is not supported.

**Linux prerequisites:** `bubblewrap` and `socat` packages required.

**Sandbox modes (set via `/sandbox`):**

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run automatically; non-sandboxable commands fall back to permission flow |
| Regular permissions | All commands go through standard permission flow even when sandboxed |

Auto-allow mode works independently of the permission mode setting.

**Filesystem isolation defaults:**

| Access | Scope |
|:-------|:------|
| Read + Write | Current working directory and subdirectories |
| Read only | Entire computer (except denied directories) |
| Blocked | Modifications outside working directory |

**Filesystem path configuration (`sandbox.filesystem.*` in settings.json):**

| Setting | Purpose |
|:--------|:--------|
| `allowWrite` | Grant subprocess write access to additional paths |
| `denyWrite` | Block subprocess write access to specific paths |
| `denyRead` | Block subprocess read access to specific paths |
| `allowRead` | Re-allow reading within a `denyRead` region (takes precedence) |
| `allowManagedReadPathsOnly` | Only respect managed `allowRead` entries |

Path arrays from multiple settings scopes are **merged** (not replaced). Paths from `sandbox.filesystem` and permission rules (`Read(...)`, `Edit(...)`) are merged into the final sandbox config.

**Path prefix resolution:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `/` | Absolute from filesystem root | `/tmp/build` |
| `~/` | Relative to home directory | `~/.kube` -> `$HOME/.kube` |
| `./` or none | Relative to project root (project settings) or `~/.claude` (user settings) | `./output` |

**Network isolation:**

- Domain-based restrictions via proxy server running outside the sandbox
- New domain requests trigger permission prompts
- `allowManagedDomainsOnly` blocks non-allowed domains automatically
- Custom proxy support via `sandbox.network.httpProxyPort` / `socksProxyPort`

**Escape hatch:** When a command fails due to sandbox restrictions, Claude may retry with `dangerouslyDisableSandbox` (goes through normal permission flow). Disable with `"allowUnsandboxedCommands": false`. Alternatively, list incompatible tools in `excludedCommands`.

**Security limitations:**

- Network filtering is domain-based only; does not inspect traffic content
- Broad domains (e.g., `github.com`) may allow data exfiltration; domain fronting possible
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad filesystem writes can enable privilege escalation
- `enableWeakerNestedSandbox` (for Docker without privileged namespaces) considerably weakens security

**Incompatible tools:** `watchman` (use `jest --no-watchman`), `docker` (add to `excludedCommands`)

### Development Containers

Reference devcontainer at `github.com/anthropics/claude-code/.devcontainer`. Enables `--dangerously-skip-permissions` for unattended operation.

**Components:** `devcontainer.json` (settings, extensions, mounts), `Dockerfile` (image, tools), `init-firewall.sh` (network rules).

**Security features:** Outbound connections restricted to whitelisted domains only (npm, GitHub, Claude API), default-deny policy, startup firewall verification, system isolation.

### Enterprise Network Configuration

**Proxy configuration:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` for all) |

SOCKS proxies are not supported. Basic auth via `http://user:pass@proxy:port`. All env vars can also go in `settings.json`.

**Custom CA certificates:** `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem`

**mTLS authentication:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key |

**Required network access:**

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication (claude.ai accounts) |
| `platform.claude.com` | Authentication (Console accounts) |
| `downloads.claude.ai` | Native installer and updates |
| `storage.googleapis.com` | Legacy download bucket (deprecation in progress) |

For GitHub Enterprise Cloud with IP restrictions: enable IP allow list inheritance for installed GitHub Apps, or manually add ranges from Anthropic API IP addresses page.

### Data Usage & Retention

**Training policy:**

| Plan type | Policy |
|:----------|:-------|
| Consumer (Free/Pro/Max) | Opt-in choice to allow training; configurable in privacy settings |
| Commercial (Team/Enterprise/API) | Not used for training unless opted into Development Partner Program |

**Data retention:**

| Scenario | Retention |
|:---------|:----------|
| Consumer, training allowed | 5 years |
| Consumer, training disallowed | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Not retained (except law/misuse) |
| Local session cache | Up to 30 days (configurable) |
| `/feedback` transcripts | 5 years |
| Session quality surveys | Numeric rating only (1/2/3/dismiss); no conversation data |

**Telemetry environment variables:**

| Variable | Disables |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Statsig operational metrics |
| `DISABLE_ERROR_REPORTING` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic including surveys |

Bedrock, Vertex, and Foundry providers have telemetry **off by default** (except session quality surveys).

### Legal & Compliance

**Applicable terms:** Commercial Terms (Team/Enterprise/API) or Consumer Terms (Free/Pro/Max). Existing commercial agreements apply to Claude Code usage.

**Healthcare (BAA):** Automatically extends to Claude Code if customer has executed a BAA **and** has ZDR activated. ZDR is per-organization.

**Authentication restrictions:** OAuth tokens from Free/Pro/Max are for Claude Code and claude.ai only -- using them in other products (including Agent SDK) violates Consumer Terms. Developers building products must use API keys via Claude Console.

**Vulnerability reporting:** HackerOne program at `hackerone.com/anthropic-vdp`.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are not stored after the response is returned.

**ZDR covers:** Model inference calls through Claude Code on Claude for Enterprise.

**ZDR does NOT cover:** Chat on claude.ai, Cowork, Claude Code Analytics (metadata only), user/seat management, third-party integrations.

**Features disabled under ZDR:**

| Feature | Reason |
|:--------|:-------|
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions from Desktop app | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

**Policy violations:** Flagged sessions may be retained up to 2 years.

**Enablement:** Per-organization, contact Anthropic account team. Does not auto-apply to new organizations.

### Security Best Practices

- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Consider devcontainers for additional isolation
- Audit permissions with `/permissions`
- Use managed settings for organizational standards
- Monitor usage via OpenTelemetry metrics
- Audit settings changes with `ConfigChange` hooks
- Report vulnerabilities via HackerOne (do not disclose publicly)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- security foundation (Anthropic Trust Center, SOC 2, ISO 27001), permission-based architecture, built-in protections (sandboxed bash, write access restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection defenses (permission system, context-aware analysis, input sanitization, command blocklist for curl/wget), privacy safeguards (retention periods, restricted access, training preferences), additional safeguards (network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching, credential encryption), Windows WebDAV warning, best practices for untrusted content, MCP security, IDE security, cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control sessions (local execution, short-lived scoped credentials), security best practices for sensitive code and teams, vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- overview and motivation (approval fatigue, reduced productivity), filesystem isolation (default read/write to CWD, configurable allowWrite/denyWrite/denyRead/allowRead paths, path prefix resolution, settings scope merging, allowManagedReadPathsOnly), network isolation (domain restrictions, user confirmation, allowManagedDomainsOnly, custom proxy support), OS-level enforcement (Seatbelt on macOS, bubblewrap on Linux/WSL2), getting started (prerequisites, /sandbox command), sandbox modes (auto-allow vs regular permissions), configuration (sandbox.filesystem settings, path prefixes, compatibility notes for watchman/docker, dangerouslyDisableSandbox escape hatch, allowUnsandboxedCommands), security benefits (prompt injection protection, filesystem/network protection, monitoring), security limitations (domain-based filtering only, domain fronting, Unix socket risks, filesystem permission escalation, enableWeakerNestedSandbox weakness), sandbox vs permissions relationship, advanced usage (custom proxy httpProxyPort/socksProxyPort, integration with permissions/devcontainers/enterprise policies), best practices, open source sandbox-runtime npm package, platform limitations
- [Development Containers](references/claude-code-devcontainer.md) -- reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), key features (Node.js 20, security firewall, dev tools, VS Code integration, session persistence), getting started steps, configuration breakdown, security features (whitelisted domains, allowed outbound DNS/SSH, default-deny, startup verification, isolation), customization options, example use cases (secure client work, team onboarding, CI/CD environments)
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY with space/comma-separated formats, basic auth, no SOCKS support), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), required network URLs (api.anthropic.com, claude.ai, platform.claude.com, downloads.claude.ai, storage.googleapis.com), GitHub Enterprise IP allow list inheritance, all env vars configurable in settings.json
- [Data Usage](references/claude-code-data-usage.md) -- training policy (consumer opt-in choice, commercial not trained, Development Partner Program), /feedback data handling, session quality surveys (numeric rating only, CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, feedbackSurveyRate setting), data retention (consumer 5-year or 30-day, commercial 30-day or ZDR, local cache up to 30 days, session deletion), data access (local vs cloud data flows), telemetry services (Statsig metrics, Sentry errors, /feedback transcripts), default behaviors by API provider table (Claude/Vertex/Bedrock/Foundry), DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING/DISABLE_FEEDBACK_COMMAND/CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- license (Commercial Terms for Team/Enterprise/API, Consumer Terms for Free/Pro/Max), commercial agreements (1P and 3P providers), BAA coverage (requires ZDR, per-organization), acceptable use policy, authentication and credential restrictions (OAuth for Claude Code/claude.ai only, API keys for developers/Agent SDK, no third-party Claude.ai login routing), trust center and transparency hub, HackerOne vulnerability reporting
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope (Claude Code inference on Claude for Enterprise only, per-organization enablement), what ZDR covers (prompts and responses not retained), what ZDR does NOT cover (chat on claude.ai, Cowork, Analytics metadata, user management, third-party integrations), features disabled under ZDR (Claude Code on Web, remote Desktop sessions, /feedback), data retention for policy violations (up to 2 years), requesting ZDR (contact account team, audit-logged enablement), migration from API keys to Claude for Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
