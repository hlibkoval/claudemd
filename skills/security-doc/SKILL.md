---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- security architecture (permission-based model, built-in protections, write access restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection protection (permission system, context-aware analysis, input sanitization, command blocklist, network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching), sandboxing (sandbox modes auto-allow/regular, filesystem isolation with OS-level enforcement Seatbelt/bubblewrap, network isolation via proxy, sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead path settings with prefix resolution ~/ // /, excludedCommands, allowUnsandboxedCommands escape hatch, dangerouslyDisableSandbox, custom proxy httpProxyPort/socksProxyPort, security limitations domain fronting/unix sockets/filesystem escalation/enableWeakerNestedSandbox, open source sandbox-runtime), devcontainers (reference devcontainer setup, Dockerfile, init-firewall.sh, firewall whitelist default-deny, --dangerously-skip-permissions in container, VS Code Remote Containers), enterprise network configuration (proxy HTTPS_PROXY/HTTP_PROXY/NO_PROXY, custom CA NODE_EXTRA_CA_CERTS, mTLS CLAUDE_CODE_CLIENT_CERT/CLAUDE_CODE_CLIENT_KEY/CLAUDE_CODE_CLIENT_KEY_PASSPHRASE, required URLs api.anthropic.com/claude.ai/platform.claude.com/downloads.claude.ai, GitHub Enterprise IP allow list), data usage (consumer vs commercial training policy, Development Partner Program opt-in, /bug feedback retention 5 years, session quality surveys, data retention consumer 5yr or 30d/commercial 30d/ZDR, telemetry Statsig DISABLE_TELEMETRY/Sentry DISABLE_ERROR_REPORTING/bug reports DISABLE_BUG_COMMAND, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, default behaviors by API provider table, cloud execution data flow), legal and compliance (Commercial Terms/Consumer Terms, BAA with ZDR for healthcare, acceptable use policy, OAuth vs API key authentication credential restrictions, HackerOne vulnerability reporting), zero data retention (ZDR for Claude for Enterprise, per-organization enablement, ZDR scope covers/does not cover table, disabled features under ZDR Claude Code on the Web/remote sessions/feedback, data retention for policy violations 2yr, request ZDR process), MCP security, IDE security, cloud execution security (isolated VMs, network access controls, credential protection, branch restrictions, audit logging, automatic cleanup), Remote Control security (local execution, TLS, short-lived scoped credentials), security best practices (sensitive code review, project-specific permissions, devcontainers, /permissions audit, managed settings, OpenTelemetry monitoring, ConfigChange hooks). Load when discussing Claude Code security, sandboxing, sandbox configuration, filesystem isolation, network isolation, prompt injection protection, devcontainers, development containers, enterprise network config, proxy configuration, custom CA certificates, mTLS, data usage policy, data training, data retention, telemetry, Statsig, Sentry, DISABLE_TELEMETRY, zero data retention, ZDR, legal compliance, BAA, healthcare compliance, acceptable use, OAuth restrictions, credential management, HackerOne, vulnerability reporting, cloud execution security, sandbox permissions, allowWrite, denyRead, bubblewrap, Seatbelt, sandbox-runtime, HTTPS_PROXY, NODE_EXTRA_CA_CERTS, privacy, data flow, or any Claude Code security/privacy/compliance topic.
user-invocable: false
---

# Security, Privacy & Compliance Documentation

This skill provides the complete official documentation for Claude Code security safeguards, sandboxing, devcontainers, enterprise network configuration, data usage policies, legal compliance, and zero data retention.

## Quick Reference

### Security Architecture

Claude Code uses **read-only permissions by default**. Write operations require explicit user approval. Write access is confined to the directory where Claude Code was started (and subdirectories).

#### Built-in Protections

| Protection | Description |
|:-----------|:------------|
| Sandboxed bash tool | OS-level filesystem and network isolation; enable with `/sandbox` |
| Write access restriction | Cannot write outside the working directory without explicit permission |
| Prompt fatigue mitigation | Allowlist safe commands per-user, per-codebase, or per-organization |
| Accept Edits mode | Batch-accept edits while keeping command permission prompts |
| Command blocklist | `curl`, `wget` blocked by default to prevent fetching arbitrary web content |
| Network request approval | Tools making network requests require user approval by default |
| Trust verification | First-time codebases and new MCP servers require trust verification (disabled with `-p`) |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

#### Cloud Execution Security

| Control | Description |
|:--------|:------------|
| Isolated VMs | Each session runs in an isolated, Anthropic-managed VM |
| Network access controls | Limited by default; configurable to disable or allow specific domains |
| Credential protection | GitHub auth via secure proxy; credentials never enter sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions run locally -- no cloud VMs or sandboxing; connection uses multiple short-lived, narrowly scoped credentials over TLS.

### Sandboxing

OS-level isolation for bash commands using Seatbelt (macOS) or bubblewrap (Linux/WSL2). WSL1 is not supported. Enable with `/sandbox`.

#### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run automatically without permission; unsandboxable commands fall back to normal permission flow |
| Regular permissions | All commands go through standard permission flow, even when sandboxed |

Both modes enforce the same filesystem and network restrictions. Auto-allow works independently of the permission mode setting.

#### Filesystem Settings

| Setting | Purpose |
|:--------|:--------|
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside working directory |
| `sandbox.filesystem.denyWrite` | Block subprocess write access to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region (takes precedence) |

When `allowManagedReadPathsOnly` is enabled, only managed `allowRead` entries are respected.

Arrays from multiple settings scopes are **merged** (not replaced).

#### Path Prefix Resolution

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `//` | Absolute from filesystem root | `//tmp/build` becomes `/tmp/build` |
| `~/` | Relative to home directory | `~/.kube` becomes `$HOME/.kube` |
| `/` | Relative to settings file directory | `/build` becomes `$SETTINGS_DIR/build` |
| `./` or none | Relative path (resolved at runtime) | `./output` |

#### Network Isolation

Network access controlled via a proxy outside the sandbox. Only approved domains can be accessed. Custom proxy support available:

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

#### Escape Hatch

When a command fails due to sandbox restrictions, Claude may retry with `dangerouslyDisableSandbox` (goes through normal permission flow). Disable with `"allowUnsandboxedCommands": false`. Use `excludedCommands` for tools that cannot run sandboxed (e.g., `docker`, `watchman`).

#### Security Limitations

- Network filtering restricts domains only; does not inspect traffic. Domain fronting may bypass filtering
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- `enableWeakerNestedSandbox` (Linux) considerably weakens security; use only with additional isolation

#### Open Source

Sandbox runtime available as `npx @anthropic-ai/sandbox-runtime <command>` ([GitHub](https://github.com/anthropic-experimental/sandbox-runtime)).

### Devcontainers

Reference [devcontainer setup](https://github.com/anthropics/claude-code/tree/main/.devcontainer) with Dockerfile and firewall script. Three components:

| Component | Purpose |
|:----------|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image and installed tools (Node.js 20) |
| `init-firewall.sh` | Network security rules (whitelist-only, default-deny) |

Allows `claude --dangerously-skip-permissions` for unattended operation. Firewall restricts outbound to whitelisted domains only (npm registry, GitHub, Claude API, etc.). DNS and SSH outbound allowed.

### Enterprise Network Configuration

#### Proxy Configuration

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy (recommended) |
| `HTTP_PROXY` | HTTP proxy fallback |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` bypasses all) |

SOCKS proxies are not supported. For NTLM/Kerberos, use an LLM Gateway.

#### Custom CA & mTLS

| Variable | Purpose |
|:---------|:--------|
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

All environment variables can also be set in `settings.json`.

#### Required Network URLs

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication (claude.ai accounts) |
| `platform.claude.com` | Authentication (Console accounts) |
| `downloads.claude.ai` | Native installer, updates, manifests, executables |
| `storage.googleapis.com` | Legacy download bucket (deprecation in progress) |

For GitHub Enterprise Cloud with IP restrictions, enable IP allow list inheritance for installed GitHub Apps or manually add Anthropic API IP ranges.

### Data Usage

#### Training Policy

| Plan | Policy |
|:-----|:-------|
| Consumer (Free, Pro, Max) | Opt-in/out via privacy settings; training when enabled |
| Commercial (Team, Enterprise, API, 3P) | Not trained on unless customer opts in (e.g., Developer Partner Program) |

#### Data Retention

| Account Type | Retention |
|:-------------|:----------|
| Consumer (training allowed) | 5 years |
| Consumer (training not allowed) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Zero data retention (Enterprise only) |

Privacy settings: [claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls).

#### Telemetry Opt-Out

| Service | Env Variable |
|:--------|:-------------|
| Statsig (metrics) | `DISABLE_TELEMETRY=1` |
| Sentry (errors) | `DISABLE_ERROR_REPORTING=1` |
| Bug reports | `DISABLE_BUG_COMMAND=1` |
| Feedback surveys | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| All non-essential traffic | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` |

Statsig, Sentry, and bug reports are **off by default** for Bedrock, Vertex, and Foundry providers. Session quality surveys are on for all providers by default.

### Legal & Compliance

#### Applicable Terms

| Plan | Terms |
|:-----|:------|
| Team, Enterprise, API | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Free, Pro, Max | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |

#### Healthcare (BAA)

BAA automatically extends to Claude Code when the customer has executed a BAA **and** has ZDR activated. Per-organization enablement required.

#### Authentication Restrictions

- **OAuth tokens** (Free/Pro/Max): for Claude Code and claude.ai only; using in other products (including Agent SDK) violates Consumer Terms
- **API keys** (developers): use Console or supported cloud provider for products and services

#### Security Vulnerability Reporting

Report via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability). Do not disclose publicly before Anthropic addresses the issue.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are not stored after the response is returned. ZDR is enabled per-organization by the Anthropic account team.

#### ZDR Scope

**Covers:** Model inference calls through Claude Code on Claude for Enterprise (all Claude models).

**Does not cover:**

| Feature | Details |
|:--------|:--------|
| Chat on claude.ai | Web interface conversations |
| Cowork | Cowork sessions |
| Claude Code Analytics | Collects productivity metadata (no prompts/responses); contribution metrics unavailable |
| User/seat management | Administrative data retained under standard policies |
| Third-party integrations | MCP servers, external tools not covered |

#### Features Disabled Under ZDR

| Feature | Reason |
|:--------|:-------|
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions (Desktop) | Requires persistent session data |
| Feedback submission (`/feedback`) | Sends conversation data to Anthropic |

Policy violation retention: up to 2 years (consistent with standard ZDR policy).

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- security foundation (Anthropic Trust Center, SOC 2 Type 2, ISO 27001), permission-based architecture (read-only default, explicit approval for edits/commands), built-in protections (sandboxed bash, write access restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection safeguards (permission system, context-aware analysis, input sanitization, command blocklist curl/wget, network request approval, isolated context windows, trust verification, command injection detection, fail-closed matching), Windows WebDAV warning, best practices for untrusted content, MCP security (user-configured servers, permissions), IDE security, cloud execution security (isolated VMs, network controls, credential protection, branch restrictions, audit logging, cleanup), Remote Control security (local execution, TLS, scoped credentials), security best practices (sensitive code review, project permissions, devcontainers, /permissions audit), team security (managed settings, version control, OpenTelemetry, ConfigChange hooks), vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- sandbox overview and rationale (approval fatigue, reduced productivity, limited autonomy), filesystem isolation (default read/write behavior, OS-level enforcement Seatbelt/bubblewrap, configurable paths), network isolation (domain restrictions, user confirmation, custom proxy, comprehensive subprocess coverage), sandbox modes (auto-allow vs regular permissions), configuration (sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead, path prefix resolution //~//, settings scope merging, allowManagedReadPathsOnly, excludedCommands, allowUnsandboxedCommands escape hatch, dangerouslyDisableSandbox), security benefits (prompt injection protection, filesystem/network/monitoring, reduced attack surface), security limitations (domain-only filtering, domain fronting, unix socket escalation, filesystem permission escalation, enableWeakerNestedSandbox), sandbox vs permissions relationship, advanced usage (custom proxy httpProxyPort/socksProxyPort, devcontainer integration, enterprise policy enforcement), open source sandbox-runtime npm package, platform support and limitations
- [Development Containers](references/claude-code-devcontainer.md) -- reference devcontainer setup (devcontainer.json, Dockerfile, init-firewall.sh), key features (Node.js 20, firewall, ZSH, VS Code integration, session persistence), security features (whitelisted domains, allowed DNS/SSH, default-deny, startup verification, isolation), customization (extensions, resources, network, shell), use cases (secure client work, team onboarding, CI/CD environments)
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- proxy setup (HTTPS_PROXY, HTTP_PROXY, NO_PROXY space/comma-separated, basic auth in URL), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), network access requirements (api.anthropic.com, claude.ai, platform.claude.com, downloads.claude.ai, storage.googleapis.com), GitHub Enterprise Cloud IP allow list inheritance, all env vars configurable in settings.json
- [Data Usage](references/claude-code-data-usage.md) -- data training policy (consumer opt-in/out vs commercial no-train), Development Partner Program, /bug feedback retention (5yr), session quality surveys (numeric rating only, no transcripts, CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, feedbackSurveyRate), data retention (consumer 5yr/30d, commercial 30d/ZDR, local caching 30d), session deletion, local data flow diagram (NPM install, Anthropic API, Statsig, Sentry), cloud execution data flow (repo cloned to VM, credential proxy, network proxy, same policies), telemetry services (Statsig metrics DISABLE_TELEMETRY, Sentry errors DISABLE_ERROR_REPORTING, bug reports DISABLE_BUG_COMMAND), default behaviors by API provider table (Claude/Vertex/Bedrock/Foundry), CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- license (Commercial Terms for Team/Enterprise/API, Consumer Terms for Free/Pro/Max), commercial agreements (1P API and 3P Bedrock/Vertex), healthcare BAA (auto-extends with ZDR, per-organization), acceptable use policy, authentication restrictions (OAuth for Claude Code/claude.ai only, API keys for developers/Agent SDK, no third-party OAuth routing), trust and safety (Trust Center, Transparency Hub), vulnerability reporting (HackerOne)
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR for Claude for Enterprise (real-time processing, no storage), administrative capabilities (cost controls, analytics, server-managed settings, audit logs), ZDR scope (covers inference, does not cover chat/cowork/analytics/user-management/third-party), disabled features (Claude Code on Web, remote Desktop sessions, /feedback), data retention for policy violations (2yr), request ZDR process (contact account team, audit-logged enablement), migration from API keys to Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
