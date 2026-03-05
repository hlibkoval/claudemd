---
name: security-doc
description: Reference documentation for Claude Code security — permission-based architecture, prompt injection protections, sandboxed bash (filesystem and network isolation, OS-level enforcement, sandbox modes), devcontainers, enterprise network configuration (proxy, custom CA, mTLS), data usage and retention policies, telemetry opt-out, legal and compliance (BAA/HIPAA, authentication policy), and zero data retention (ZDR) for Enterprise.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data privacy, network configuration, and compliance.

## Quick Reference

### Permission-Based Architecture

Claude Code uses strict read-only permissions by default. Write operations are confined to the project directory (cwd and subdirectories). All sensitive actions require explicit user approval.

| Protection                    | Description                                                         |
|:------------------------------|:--------------------------------------------------------------------|
| Sandboxed bash tool           | OS-level filesystem and network isolation via `/sandbox`            |
| Write access restriction      | Can only write to cwd and subdirectories                            |
| Prompt fatigue mitigation     | Allowlisting safe commands per-user, per-codebase, per-org         |
| Accept Edits mode             | Batch accept edits while keeping command permission prompts         |
| Command injection detection   | Suspicious bash commands require manual approval even if allowlisted|
| Fail-closed matching          | Unmatched commands default to requiring manual approval             |
| Trust verification            | First-time codebase runs and new MCP servers require verification   |

### Prompt Injection Protections

- Permission system requires explicit approval for sensitive operations
- Context-aware analysis detects potentially harmful instructions
- Input sanitization prevents command injection
- Command blocklist blocks `curl`, `wget` by default
- Network request approval required by default
- Isolated context windows for web fetch (separate context to avoid injection)

### Sandboxing

Enable with `/sandbox`. Uses OS-level primitives for enforcement.

**Platform support:**

| Platform | Mechanism                       | Notes                          |
|:---------|:--------------------------------|:-------------------------------|
| macOS    | Seatbelt                        | Works out of the box           |
| Linux    | bubblewrap (`apt install bubblewrap socat`) | WSL2 supported, WSL1 not supported |

**Sandbox modes:**

| Mode                    | Behavior                                                              |
|:------------------------|:----------------------------------------------------------------------|
| Auto-allow              | Sandboxed commands run without permission; unsandboxable commands fall back to normal flow |
| Regular permissions     | All commands go through standard permission flow even when sandboxed   |

**Filesystem isolation** — default: read/write to cwd, read-only elsewhere, certain dirs denied. Configurable via `sandbox.filesystem.allowWrite`, `denyWrite`, `denyRead`.

**Path prefix resolution:**

| Prefix       | Meaning                                  | Example                          |
|:-------------|:-----------------------------------------|:---------------------------------|
| `//`         | Absolute from filesystem root            | `//tmp/build` -> `/tmp/build`    |
| `~/`         | Relative to home directory               | `~/.kube` -> `$HOME/.kube`      |
| `/`          | Relative to settings file directory      | `/build` -> `$SETTINGS_DIR/build`|
| `./` or none | Relative path (resolved by runtime)      | `./output`                       |

**Network isolation** — proxy-based, domain-level restrictions. Configure `allowedDomains` in sandbox settings. Custom proxy supported via `sandbox.network.httpProxyPort` / `socksProxyPort`.

**Escape hatch:** `dangerouslyDisableSandbox` retries failed commands outside sandbox (goes through normal permissions). Disable with `"allowUnsandboxedCommands": false`.

**Incompatible tools:** `watchman` (use `jest --no-watchman`), `docker` (add to `excludedCommands`).

**Security limitations:**
- Network filtering is domain-level only; does not inspect traffic content
- Broad domains (e.g., `github.com`) may allow data exfiltration; domain fronting possible
- `allowUnixSockets` can grant access to powerful system services (e.g., Docker socket)
- Overly broad `allowWrite` can enable privilege escalation
- Linux `enableWeakerNestedSandbox` considerably weakens security (for Docker without privileged namespaces)

### Devcontainers

Reference devcontainer setup at [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer). Enables `claude --dangerously-skip-permissions` for unattended operation.

**Components:** `devcontainer.json`, `Dockerfile`, `init-firewall.sh`

**Security features:**
- Whitelisted outbound domains only (npm, GitHub, Claude API)
- Default-deny firewall policy
- Startup firewall verification
- Isolated from host system

### Enterprise Network Configuration

| Setting                            | Env var / Config                                     |
|:-----------------------------------|:-----------------------------------------------------|
| HTTPS proxy                        | `HTTPS_PROXY=https://proxy.example.com:8080`         |
| HTTP proxy                         | `HTTP_PROXY=http://proxy.example.com:8080`           |
| Proxy bypass                       | `NO_PROXY="localhost 192.168.1.1 .example.com"`      |
| Custom CA certificate              | `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem`           |
| mTLS client cert                   | `CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem`   |
| mTLS client key                    | `CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem`     |
| mTLS key passphrase                | `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="..."`            |

**Required network access:** `api.anthropic.com`, `claude.ai`, `platform.claude.com`

SOCKS proxies are not supported.

### Data Usage and Retention

**Training policy:**
- Consumer (Free/Pro/Max): opt-in/opt-out via privacy settings
- Commercial (Team/Enterprise/API): Anthropic does NOT train on your data unless you opt into the Development Partner Program

**Retention periods:**

| Account type                          | Retention                |
|:--------------------------------------|:-------------------------|
| Consumer, training allowed            | 5 years                  |
| Consumer, training not allowed        | 30 days                  |
| Commercial (Team/Enterprise/API)      | 30 days                  |
| Commercial with ZDR                   | Zero (not stored)        |

**Telemetry opt-out:**

| Service              | Disable with                                  |
|:---------------------|:----------------------------------------------|
| Statsig (metrics)    | `DISABLE_TELEMETRY=1`                         |
| Sentry (errors)      | `DISABLE_ERROR_REPORTING=1`                   |
| Bug reporting        | `DISABLE_BUG_COMMAND=1`                       |
| Feedback surveys     | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`       |
| All non-essential    | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`  |

Bedrock, Vertex, and Foundry providers disable all non-essential traffic by default.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Per-organization enablement by Anthropic account team.

**What ZDR covers:** Model inference calls (prompts and responses not retained).

**What ZDR does NOT cover:** Chat on claude.ai, Cowork, Analytics metadata, user/seat management, third-party integrations.

**Features disabled under ZDR:** Claude Code on the Web, Remote sessions from Desktop app, Feedback submission (`/feedback`).

**Policy violations:** Data may be retained up to 2 years if flagged.

### Legal and Compliance

**Applicable terms:**
- Commercial: [Commercial Terms](https://www.anthropic.com/legal/commercial-terms)
- Consumer: [Consumer Terms](https://www.anthropic.com/legal/consumer-terms)

**BAA/HIPAA:** BAA automatically extends to Claude Code if customer has executed a BAA and has ZDR activated. Per-organization.

**Authentication policy:** OAuth tokens from Free/Pro/Max accounts are for Claude Code and claude.ai only — using them in other products (including Agent SDK) violates Consumer Terms. Developers must use API keys via Claude Console.

**Report vulnerabilities:** [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection protections, MCP security, IDE security, cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, OS-level enforcement, sandbox modes, configuration, security limitations
- [Development Containers](references/claude-code-devcontainer.md) — devcontainer setup, firewall configuration, VS Code integration
- [Enterprise Network Configuration](references/claude-code-network-config.md) — proxy, custom CA certificates, mTLS authentication, required URLs
- [Data Usage](references/claude-code-data-usage.md) — training policy, retention periods, telemetry services, cloud execution data flow
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — terms of service, BAA/HIPAA, authentication policy, vulnerability reporting
- [Zero Data Retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, data retention for policy violations, requesting ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
