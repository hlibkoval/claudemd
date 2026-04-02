---
name: security-doc
description: Complete documentation for Claude Code security, privacy, and compliance -- covering security architecture, permission-based access control, prompt injection protections, sandboxing (filesystem and network isolation via Seatbelt/bubblewrap, sandbox modes, /sandbox command, sandbox.filesystem.allowWrite/denyWrite/denyRead/allowRead, sandbox.network, excludedCommands, dangerouslyDisableSandbox escape hatch, allowUnsandboxedCommands), development containers (devcontainer.json, Dockerfile, init-firewall.sh, --dangerously-skip-permissions), enterprise network configuration (HTTPS_PROXY, HTTP_PROXY, NO_PROXY, NODE_EXTRA_CA_CERTS, CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, mTLS authentication, required URLs api.anthropic.com/claude.ai/platform.claude.com), data usage policies (consumer vs commercial training policy, data retention periods, Development Partner Program, /feedback data, session quality surveys, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, DISABLE_FEEDBACK_COMMAND, CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, telemetry by API provider), zero data retention (ZDR for Claude for Enterprise, ZDR scope, features disabled under ZDR, per-organization enablement), legal and compliance (commercial terms, consumer terms, BAA/healthcare compliance, acceptable use policy, OAuth vs API key authentication restrictions), MCP security, IDE security, cloud execution security (isolated VMs, credential protection, branch restrictions, audit logging), and security best practices. Load when discussing Claude Code security, sandboxing, sandbox settings, devcontainers, network configuration, proxy setup, mTLS, data usage, data retention, ZDR, zero data retention, legal compliance, BAA, prompt injection, privacy, telemetry, or any security-related topic for Claude Code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, data handling, and compliance.

## Quick Reference

### Security Architecture

| Layer | Protection |
|:------|:-----------|
| Permission system | Read-only by default; explicit approval for edits, commands, network requests |
| Sandboxing | OS-level filesystem and network isolation for bash commands |
| Write restriction | Can only write to the working directory and subdirectories |
| Prompt injection defense | Context-aware analysis, input sanitization, command blocklist (`curl`/`wget` blocked by default) |
| Command injection detection | Suspicious commands require manual approval even if previously allowlisted |
| Trust verification | Required for first-time codebase runs and new MCP servers (disabled with `-p` flag) |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Sandboxing

**Enable:** Run `/sandbox` in-session

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without permission prompts; unsandboxable commands fall back to normal flow |
| Regular permissions | All commands go through standard permission flow, even when sandboxed |

**OS enforcement:**

| Platform | Technology |
|:---------|:-----------|
| macOS | Seatbelt |
| Linux / WSL2 | bubblewrap + socat |
| WSL1 | Not supported |

**Linux prerequisites:** `sudo apt-get install bubblewrap socat` (Debian/Ubuntu) or `sudo dnf install bubblewrap socat` (Fedora)

**Key sandbox settings (`settings.json`):**

| Setting | Purpose |
|:--------|:--------|
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to paths outside cwd (e.g., `["~/.kube", "/tmp/build"]`) |
| `sandbox.filesystem.denyWrite` | Block subprocess write access to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port for network filtering |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port for network filtering |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to disable the `dangerouslyDisableSandbox` escape hatch |
| `sandbox.allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |
| `sandbox.allowManagedReadPathsOnly` | Ignore non-managed `allowRead` entries |

**Path prefix resolution:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `/` | Absolute path | `/tmp/build` |
| `~/` | Home-relative | `~/.kube` becomes `$HOME/.kube` |
| `./` or none | Project-relative (project settings) or `~/.claude`-relative (user settings) | `./output` |

Settings arrays from multiple scopes are **merged**, not replaced.

**Limitations:** Network filtering is domain-based only (no traffic inspection). Broad domains (e.g., `github.com`) may allow exfiltration. `allowUnixSockets` can enable privilege escalation. `enableWeakerNestedSandbox` for Docker considerably weakens security.

**Not covered by sandbox:** Built-in file tools (Read, Edit, Write) use the permission system directly. Computer use runs on the actual desktop.

**Open source runtime:** `npx @anthropic-ai/sandbox-runtime <command>` ([GitHub](https://github.com/anthropic-experimental/sandbox-runtime))

### Development Containers

Preconfigured devcontainer for secure, isolated environments with firewall rules.

| Component | Purpose |
|:----------|:--------|
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Container image and installed tools |
| `init-firewall.sh` | Network security rules (default-deny, whitelisted domains only) |

Enables `claude --dangerously-skip-permissions` for unattended operation. Only use with trusted repositories.

Reference setup: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

### Enterprise Network Configuration

**Proxy:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Space- or comma-separated bypass list; `*` bypasses all |

SOCKS proxies are not supported. Basic auth: `http://user:pass@proxy:8080`.

**Custom CA certificates:** `export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem`

**mTLS authentication:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key |

**Required URLs (allowlist in proxies/firewalls):**

| URL | Purpose |
|:----|:--------|
| `api.anthropic.com` | Claude API |
| `claude.ai` | Authentication (claude.ai accounts) |
| `platform.claude.com` | Authentication (Console accounts) |
| `storage.googleapis.com` | Binary downloads and auto-updater |
| `downloads.claude.ai` | Install script, version pointers, plugin executables |

For GitHub Enterprise Cloud with IP restrictions, enable [IP allow list inheritance for GitHub Apps](https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-allowed-ip-addresses-for-your-organization#allowing-access-by-github-apps). For self-hosted GHES, allowlist the [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Data Usage

**Training policy:**

| Plan | Policy |
|:-----|:-------|
| Free, Pro, Max | Opt-in: user controls training preference via [privacy settings](https://claude.ai/settings/privacy) |
| Team, Enterprise, API | Not used for training unless customer opts in (e.g., Developer Partner Program) |

**Data retention:**

| Scenario | Retention |
|:---------|:----------|
| Consumer (training on) | 5 years |
| Consumer (training off) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Not retained (except for law/abuse) |
| `/feedback` transcripts | 5 years |
| Local session cache | Up to 30 days (configurable) |

**Telemetry environment variables:**

| Variable | Disables |
|:---------|:---------|
| `DISABLE_TELEMETRY` | Statsig metrics |
| `DISABLE_ERROR_REPORTING` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic (includes surveys) |

Statsig, Sentry, and `/feedback` are on by default for Claude API, off by default for Bedrock/Vertex/Foundry. Session quality surveys are on for all providers.

### Zero Data Retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only. Enabled per-organization by Anthropic account team.

**What ZDR covers:** Model inference calls (prompts and responses not retained).

**What ZDR does NOT cover:** Chat on claude.ai, Cowork, Claude Code Analytics (collects metadata only), user/seat management, third-party integrations.

**Features disabled under ZDR:** Claude Code on the Web, remote sessions from Desktop app, `/feedback` submission.

**Policy violations:** Data may be retained up to 2 years if flagged for Usage Policy violations.

### Legal and Compliance

| Agreement | Applies To |
|:----------|:-----------|
| [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) | Team, Enterprise, API |
| [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) | Free, Pro, Max |
| [Usage Policy](https://www.anthropic.com/legal/aup) | All plans |

**BAA (Healthcare):** Automatically extends to Claude Code for customers with an executed BAA and ZDR activated. ZDR must be enabled per-organization.

**OAuth authentication** (Free/Pro/Max) is exclusively for Claude Code and Claude.ai. Using OAuth tokens in other products or the Agent SDK is prohibited. Developers building products must use API key authentication.

**Report vulnerabilities:** [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)

### Cloud Execution Security

| Control | Details |
|:--------|:--------|
| Isolated VMs | Each session runs in an Anthropic-managed VM |
| Network controls | Limited by default; configurable per-domain |
| Credential protection | Scoped credential in sandbox translated to actual GitHub token |
| Branch restrictions | Push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session |

Remote Control sessions run locally (no cloud VMs); connection uses multiple short-lived, narrowly scoped credentials.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- Security architecture, permission system, prompt injection protections, MCP/IDE/cloud security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) -- Filesystem and network isolation, sandbox modes, OS-level enforcement, configuration, security benefits and limitations
- [Development Containers](references/claude-code-devcontainer.md) -- Preconfigured devcontainer with firewall rules for secure isolated environments
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- Proxy, custom CA, mTLS, required URLs for enterprise environments
- [Data Usage](references/claude-code-data-usage.md) -- Training policy, data retention, telemetry services, data flow diagrams
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- Terms of service, BAA/healthcare compliance, acceptable use, authentication restrictions
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope, disabled features, data retention for policy violations, requesting ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
