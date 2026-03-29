---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- covering security architecture (permission-based system, built-in protections, prompt injection defenses, command blocklist, trust verification, command injection detection, Windows WebDAV warning), sandboxing (filesystem isolation with Seatbelt/bubblewrap, network isolation via proxy, sandbox modes auto-allow vs regular, sandbox settings allowWrite/denyWrite/denyRead/allowRead/allowedDomains/excludedCommands/allowUnsandboxedCommands/failIfUnavailable, path prefix resolution, custom proxy, security limitations network filtering/unix sockets/filesystem escalation/Linux weaker nested sandbox, open source sandbox-runtime), development containers (devcontainer.json/Dockerfile/init-firewall.sh, firewall whitelisting, --dangerously-skip-permissions, VS Code integration), enterprise network configuration (HTTPS_PROXY/HTTP_PROXY/NO_PROXY, custom CA certs NODE_EXTRA_CA_CERTS, mTLS CLAUDE_CODE_CLIENT_CERT/CLAUDE_CODE_CLIENT_KEY, required URLs api.anthropic.com/claude.ai/platform.claude.com/downloads.claude.ai, GitHub Enterprise IP allow list), data usage (training policy consumer vs commercial, Development Partner Program, /feedback retention 5 years, session quality surveys with CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, data retention 30-day/5-year/ZDR, telemetry Statsig DISABLE_TELEMETRY/Sentry DISABLE_ERROR_REPORTING, default behaviors by API provider table, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC), legal and compliance (Commercial Terms vs Consumer Terms, BAA with ZDR, Anthropic Usage Policy, OAuth vs API key authentication restrictions, HackerOne vulnerability reporting), and zero data retention (ZDR scope covers Claude Code inference on Claude for Enterprise, ZDR exclusions chat/Cowork/Analytics/user-management/third-party, features disabled under ZDR web sessions/remote sessions/feedback, data retention for policy violations up to 2 years, per-organization enablement). Load when discussing Claude Code security, sandboxing, sandbox configuration, filesystem isolation, network isolation, bubblewrap, Seatbelt, devcontainers, development containers, enterprise network, proxy configuration, mTLS, custom CA certificates, data usage, data retention, zero data retention, ZDR, privacy, telemetry, Statsig, Sentry, error reporting, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, legal compliance, BAA, HIPAA, commercial terms, consumer terms, prompt injection, permission system, trust verification, security best practices, cloud execution security, MCP security, HackerOne, vulnerability reporting, or any security/privacy/compliance topic for Claude Code.
user-invocable: false
---

# Security, Privacy & Compliance Documentation

This skill provides the complete official documentation for Claude Code security, privacy, data usage, and compliance.

## Quick Reference

### Security Architecture

| Layer | Protection |
|:------|:-----------|
| **Permissions** | Read-only by default; explicit approval for edits, commands, network requests |
| **Sandboxing** | OS-level filesystem + network isolation for bash commands |
| **Command blocklist** | `curl`, `wget` blocked by default to prevent fetching arbitrary web content |
| **Trust verification** | Required on first-time codebase runs and new MCP servers (disabled with `-p` flag) |
| **Command injection detection** | Suspicious bash commands require manual approval even if allowlisted |
| **Fail-closed matching** | Unmatched commands default to requiring manual approval |
| **Credential storage** | API keys and tokens encrypted via system keychain |

### Prompt Injection Defenses

- Permission system gates sensitive operations
- Context-aware analysis detects harmful instructions
- Input sanitization prevents command injection
- Isolated context windows for web fetch (separate from main conversation)
- Network request approval required by default
- Natural language descriptions for complex bash commands

### Sandboxing

**Sandbox modes:**

| Mode | Behavior |
|:-----|:---------|
| **Auto-allow** | Sandboxed commands run without permission prompts; non-sandboxable commands fall back to normal flow |
| **Regular permissions** | All commands go through standard permission flow even when sandboxed |

**OS enforcement:**

| Platform | Technology |
|:---------|:-----------|
| macOS | Seatbelt |
| Linux | bubblewrap |
| WSL2 | bubblewrap (WSL1 not supported) |

**Prerequisites (Linux/WSL2):** `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) or `sudo dnf install bubblewrap socat` (Fedora)

**Enable:** Run `/sandbox` in Claude Code

**Key sandbox settings:**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.filesystem.allowWrite` | Grant write access to paths outside working directory |
| `sandbox.filesystem.denyWrite` | Block write access to specific paths |
| `sandbox.filesystem.denyRead` | Block read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reading within a `denyRead` region |
| `sandbox.network.allowedDomains` | Control which domains bash commands can reach |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `sandbox.excludedCommands` | Commands that always run outside the sandbox (e.g., `docker`) |
| `sandbox.allowUnsandboxedCommands` | Allow escape hatch for failed sandboxed commands (default true; set false to enforce) |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (default false) |
| `sandbox.allowManagedDomainsOnly` | Block non-allowed domains automatically instead of prompting |
| `sandbox.allowManagedReadPathsOnly` | Only respect managed `allowRead` entries |

**Path prefix resolution:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `/` | Absolute path | `/tmp/build` |
| `~/` | Relative to home | `~/.kube` becomes `$HOME/.kube` |
| `./` or none | Relative to project root (project settings) or `~/.claude` (user settings) | `./output` |

Path arrays from multiple settings scopes are **merged**, not replaced.

**Security limitations:**

- Network filtering restricts domains only; does not inspect traffic content. Domain fronting may bypass filtering
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- Linux `enableWeakerNestedSandbox` considerably weakens security (for Docker environments without privileged namespaces)

**Incompatible tools:** `watchman` (use `jest --no-watchman`), `docker` (add to `excludedCommands`)

### Cloud Execution Security

| Control | Details |
|:--------|:--------|
| Isolated VMs | Each session runs in an Anthropic-managed VM |
| Network controls | Limited by default; configurable to disable or allow specific domains |
| Credential protection | Scoped credential in sandbox, translated to actual GitHub token |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions run locally (no cloud VMs); connection uses multiple short-lived, narrowly scoped credentials.

### Enterprise Network Configuration

**Proxy settings:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL (fallback) |
| `NO_PROXY` | Bypass proxy (space or comma-separated; `*` for all) |

SOCKS proxies are not supported. Basic auth: include credentials in proxy URL. For NTLM/Kerberos, use an LLM Gateway.

**Certificate and mTLS:**

| Variable | Purpose |
|:---------|:--------|
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required URLs:**

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Console accounts |
| `downloads.claude.ai` | Native installer, update checks, manifests, executables |
| `storage.googleapis.com` | Legacy download bucket (deprecation in progress) |

For GitHub Enterprise Cloud with IP restrictions, enable IP allow list inheritance for installed GitHub Apps, or add ranges from the Anthropic API IP addresses page.

### Development Containers

- Reference setup at `github.com/anthropics/claude-code/tree/main/.devcontainer`
- Three components: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`
- Firewall whitelists only necessary outbound domains (npm, GitHub, Claude API)
- Default-deny policy for all other external access
- Enables `claude --dangerously-skip-permissions` for unattended operation
- Compatible with VS Code Dev Containers extension

### Data Usage & Retention

**Training policy:**

| Plan | Policy |
|:-----|:-------|
| Free, Pro, Max | User chooses whether data is used for training (setting at claude.ai/settings/data-privacy-controls) |
| Team, Enterprise, API | Not used for training unless customer opts in (e.g., Development Partner Program) |

**Retention periods:**

| Account type | Retention |
|:-------------|:----------|
| Consumer (training on) | 5 years |
| Consumer (training off) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Zero -- not stored after response returned |
| `/feedback` transcripts | 5 years |

**Telemetry opt-out environment variables:**

| Variable | Disables |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Statsig metrics |
| `DISABLE_ERROR_REPORTING` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic including surveys |

Telemetry, error reporting, and feedback are **off by default** for Bedrock, Vertex, and Foundry providers. Session quality surveys are on for all providers.

### Zero Data Retention (ZDR)

- Available for Claude Code on **Claude for Enterprise** only
- Enabled per-organization by Anthropic account team
- Covers model inference calls (prompts + responses not retained)
- Does **not** cover: chat on claude.ai, Cowork, Analytics metadata, user/seat management, third-party integrations
- Features **disabled** under ZDR: Claude Code on the Web, Remote sessions from Desktop app, `/feedback`
- Policy violations: data may be retained up to 2 years
- For Bedrock/Vertex/Foundry, refer to those platforms' retention policies

### Legal & Compliance

| Topic | Details |
|:------|:--------|
| **Commercial Terms** | Team, Enterprise, API users |
| **Consumer Terms** | Free, Pro, Max users |
| **BAA (Healthcare)** | Extends to Claude Code if customer has BAA + ZDR activated (per-organization) |
| **Usage Policy** | Subject to Anthropic Usage Policy |
| **OAuth auth** | For Claude Code and claude.ai only; not permitted in other tools/Agent SDK |
| **API key auth** | Required for developers building products with Claude API/Agent SDK |
| **Vulnerability reporting** | HackerOne: hackerone.com/anthropic-vdp |
| **Trust Center** | trust.anthropic.com |

### Security Best Practices

1. Review all suggested changes before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external web services
5. Use project-specific permission settings for sensitive repositories
6. Consider devcontainers for additional isolation
7. Audit permissions with `/permissions`
8. Use managed settings for organizational standards
9. Monitor usage through OpenTelemetry metrics
10. Audit settings changes with `ConfigChange` hooks
11. Report suspicious behavior with `/feedback`

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Security foundation, permission-based architecture, built-in protections (sandboxed bash, write access restriction, prompt fatigue mitigation, Accept Edits mode), prompt injection defenses (command blocklist, input sanitization, isolated context windows, trust verification, command injection detection, fail-closed matching, Windows WebDAV warning), best practices for untrusted content, MCP security, IDE security, cloud execution security (isolated VMs, network controls, credential protection, branch restrictions, audit logging), Remote Control security, team security with managed settings and OpenTelemetry, vulnerability reporting via HackerOne
- [Sandboxing](references/claude-code-sandboxing.md) -- Overview and motivation, filesystem isolation (default writes/reads, configurable paths, OS-level enforcement with Seatbelt/bubblewrap), network isolation (domain restrictions, custom proxy), sandbox modes (auto-allow vs regular permissions), enable with /sandbox, configuration (allowWrite/denyWrite/denyRead/allowRead with path prefix resolution and scope merging, excludedCommands, allowUnsandboxedCommands escape hatch, failIfUnavailable, allowManagedDomainsOnly, allowManagedReadPathsOnly), security benefits (prompt injection protection, reduced attack surface, transparent operation), security limitations (network filtering, Unix sockets, filesystem escalation, Linux weaker nested sandbox), relationship to permissions, advanced custom proxy configuration, integration with devcontainers and enterprise policies, open source sandbox-runtime npm package, platform limitations
- [Development Containers](references/claude-code-devcontainer.md) -- Reference devcontainer setup with Dockerfile and firewall script, key features (Node.js 20, firewall, ZSH, VS Code integration, session persistence), getting started steps, configuration breakdown (devcontainer.json, Dockerfile, init-firewall.sh), security features (precise access control, allowed outbound, default-deny, startup verification, isolation), customization options, example use cases (secure client work, team onboarding, consistent CI/CD)
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- Proxy configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY with space/comma formats, basic auth, no SOCKS support), custom CA certificates (NODE_EXTRA_CA_CERTS), mTLS authentication (CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), required URLs for API/auth/installer, GitHub Enterprise Cloud IP allow list configuration
- [Data Usage](references/claude-code-data-usage.md) -- Training policy (consumer opt-in vs commercial opt-out, Development Partner Program), /feedback retention, session quality surveys (CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, feedbackSurveyRate), data retention periods (consumer 5yr/30d, commercial 30d/ZDR, local caching 30d configurable), data access for local and remote sessions, local data flow diagram and dependencies (NPM install, Anthropic API, Statsig, Sentry), cloud execution data flow (code storage, credentials proxy, network traffic, session data), telemetry services (Statsig with DISABLE_TELEMETRY, Sentry with DISABLE_ERROR_REPORTING, /feedback with DISABLE_FEEDBACK_COMMAND), default behaviors by API provider table (Claude/Vertex/Bedrock/Foundry), CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- License (Commercial Terms for Team/Enterprise/API, Consumer Terms for Free/Pro/Max), commercial agreements (1P API and 3P Bedrock/Vertex), healthcare compliance (BAA extends to Claude Code with ZDR, per-organization), acceptable use policy, authentication restrictions (OAuth for Claude Code/claude.ai only, API keys for developers/Agent SDK, no third-party OAuth routing), security vulnerability reporting via HackerOne, Anthropic Trust Center and Transparency Hub
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope (Claude Code inference on Claude for Enterprise, per-organization enablement), what ZDR covers (model inference prompts and responses), what ZDR does not cover (chat, Cowork, Analytics metadata, user management, third-party integrations), features disabled under ZDR (Claude Code on the Web, Remote sessions, /feedback), data retention for policy violations (up to 2 years), requesting ZDR through Anthropic account team, transitioning from pay-as-you-go API keys to Claude for Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
