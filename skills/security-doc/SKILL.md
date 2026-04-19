---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, prompt injection defenses, sandboxing, devcontainers, enterprise network configuration, data usage and retention, legal and compliance, and zero data retention.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, data privacy, and compliance.

## Quick Reference

### Security architecture overview

Claude Code uses **read-only permissions by default**. Any action beyond reading (editing files, running commands) requires explicit user approval. Organizations enforce standards through managed settings.

| Layer                    | What it does                                                                     |
| :----------------------- | :------------------------------------------------------------------------------- |
| **Permission system**    | Explicit approval for sensitive operations; allowlisting for safe commands        |
| **Sandboxing**           | OS-level filesystem and network isolation for bash commands                       |
| **Command blocklist**    | Blocks risky commands (`curl`, `wget`) by default                                |
| **Context-aware analysis** | Detects potentially harmful instructions in requests                           |
| **Input sanitization**   | Prevents command injection by processing user inputs                             |
| **Trust verification**   | First-time codebase runs and new MCP servers require trust verification          |
| **Fail-closed matching** | Unmatched commands default to requiring manual approval                           |

### Prompt injection defenses

| Protection                       | Detail                                                                         |
| :------------------------------- | :----------------------------------------------------------------------------- |
| Permission system                | Sensitive ops require explicit approval                                         |
| Network request approval         | Tools making network requests require user approval by default                  |
| Isolated context windows         | Web fetch uses a separate context window to avoid injecting malicious prompts   |
| Command injection detection      | Suspicious bash commands require manual approval even if previously allowlisted |
| Secure credential storage        | API keys and tokens are encrypted                                              |

Best practices: review commands before approval, avoid piping untrusted content to Claude, verify changes to critical files, use VMs for scripts interacting with external services, report suspicious behavior with `/feedback`.

### Sandboxing

Enable with `/sandbox`. Two modes available:

| Mode                     | Behavior                                                                        |
| :----------------------- | :------------------------------------------------------------------------------ |
| **Auto-allow**           | Sandboxed commands run without permission; non-sandboxable commands fall back to normal flow |
| **Regular permissions**  | All commands go through standard permission flow, even when sandboxed            |

#### OS-level enforcement

| Platform  | Technology                                    |
| :-------- | :-------------------------------------------- |
| macOS     | Seatbelt (built-in, no install needed)        |
| Linux     | bubblewrap + socat (`apt install bubblewrap socat`) |
| WSL2      | bubblewrap (same as Linux)                    |
| WSL1      | Not supported                                 |

#### Filesystem isolation settings

| Setting                            | Purpose                                                    |
| :--------------------------------- | :--------------------------------------------------------- |
| `sandbox.filesystem.allowWrite`    | Grant subprocess write access to paths outside cwd         |
| `sandbox.filesystem.denyWrite`     | Block subprocess write access to specific paths            |
| `sandbox.filesystem.denyRead`      | Block subprocess read access to specific paths             |
| `sandbox.filesystem.allowRead`     | Re-allow reading specific paths within a denyRead region   |

Path prefixes: `/` = absolute, `~/` = home-relative, `./` or bare = project-relative (in project settings) or `~/.claude`-relative (in user settings). Arrays merge across all settings scopes.

#### Network isolation settings

| Setting                              | Purpose                                                  |
| :----------------------------------- | :------------------------------------------------------- |
| `sandbox.network.allowedDomains`     | Domains bash commands can reach                          |
| `sandbox.network.deniedDomains`      | Block specific domains even if a wildcard would allow    |
| `sandbox.network.httpProxyPort`      | Custom HTTP proxy port for advanced filtering            |
| `sandbox.network.socksProxyPort`     | Custom SOCKS proxy port                                  |
| `sandbox.allowUnsandboxedCommands`   | Set `false` to disable the escape hatch entirely         |
| `sandbox.failIfUnavailable`          | Set `true` to hard-fail if sandbox cannot start          |

#### Security limitations of sandboxing

- Network filtering restricts domains only; does not inspect traffic content
- Broad domains like `github.com` could enable data exfiltration
- Domain fronting may bypass network filtering
- `allowUnixSockets` can grant access to powerful services (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- Linux `enableWeakerNestedSandbox` considerably weakens security (Docker-in-Docker fallback)

Open source sandbox runtime: `npx @anthropic-ai/sandbox-runtime <command>`

### Development containers

The reference devcontainer provides a preconfigured Docker environment with a multi-layered firewall (default-deny outbound, whitelisted domains only). Suitable for running `claude --dangerously-skip-permissions` in isolated environments.

| Component          | File                                                                                |
| :----------------- | :---------------------------------------------------------------------------------- |
| Container config   | `.devcontainer/devcontainer.json`                                                   |
| Docker image       | `.devcontainer/Dockerfile` (Node.js 20, git, ZSH, fzf)                             |
| Firewall rules     | `.devcontainer/init-firewall.sh` (outbound DNS, SSH, whitelisted domains only)      |

Reference implementation: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

### Enterprise network configuration

| Variable                             | Purpose                                                    |
| :----------------------------------- | :--------------------------------------------------------- |
| `HTTPS_PROXY` / `HTTP_PROXY`        | Route traffic through corporate proxy                      |
| `NO_PROXY`                           | Bypass proxy for specific hosts (space or comma separated) |
| `NODE_EXTRA_CA_CERTS`               | Trust custom CA certificate (PEM file path)                |
| `CLAUDE_CODE_CERT_STORE`            | CA trust sources: `bundled`, `system`, or both (default: `bundled,system`) |
| `CLAUDE_CODE_CLIENT_CERT`           | mTLS client certificate path                               |
| `CLAUDE_CODE_CLIENT_KEY`            | mTLS client private key path                               |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key                       |

All env vars can also be set in `settings.json`.

#### Required network access

| URL                          | Purpose                                          |
| :--------------------------- | :----------------------------------------------- |
| `api.anthropic.com`          | Claude API endpoints                             |
| `claude.ai`                  | Authentication for claude.ai accounts            |
| `platform.claude.com`        | Authentication for Console accounts              |
| `storage.googleapis.com`     | Binary downloads and auto-updater                |
| `downloads.claude.ai`        | Install script, version pointers, plugin executables |
| `bridge.claudeusercontent.com` | Chrome integration WebSocket bridge (if used)  |

For GitHub Enterprise Cloud with IP restrictions: enable [IP allow list inheritance for installed GitHub Apps](https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-allowed-ip-addresses-for-your-organization#allowing-access-by-github-apps) or manually add [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Data usage and retention

| Account type                        | Training policy                                      | Retention period                   |
| :---------------------------------- | :--------------------------------------------------- | :--------------------------------- |
| **Free / Pro / Max** (training on)  | Data may be used for model improvement               | 5 years                           |
| **Free / Pro / Max** (training off) | Data NOT used for model improvement                  | 30 days                           |
| **Team / Enterprise / API**         | Never trained on unless opted into Developer Partner Program | 30 days (or ZDR)          |

Privacy settings: [claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls)

Local caching: session transcripts stored in `~/.claude/projects/` for 30 days by default (configurable via `cleanupPeriodDays`).

#### Telemetry controls

| Env var                                   | Disables                                |
| :---------------------------------------- | :-------------------------------------- |
| `DISABLE_TELEMETRY`                       | Statsig metrics                         |
| `DISABLE_ERROR_REPORTING`                 | Sentry error logging                    |
| `DISABLE_FEEDBACK_COMMAND`                | `/feedback` command                     |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY`     | Session quality surveys                 |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`| All non-essential traffic (including surveys) |

Bedrock, Vertex, and Foundry: error reporting, telemetry, and feedback are off by default. Session quality surveys are on by default for all providers.

### Zero data retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only. Prompts and responses are not stored after the response is returned (except for legal/abuse compliance).

| Aspect                | Detail                                                         |
| :-------------------- | :------------------------------------------------------------- |
| **Scope**             | Model inference calls through Claude Code on CfE               |
| **Per-org enablement**| Each organization must be enabled separately by account team   |
| **BAA coverage**      | Automatically extends to Claude Code if customer has BAA + ZDR |

#### Features disabled under ZDR

| Feature                          | Reason                                              |
| :------------------------------- | :-------------------------------------------------- |
| Claude Code on the Web           | Requires server-side conversation storage            |
| Remote sessions (Desktop app)   | Requires persistent session data                     |
| Feedback submission (`/feedback`)| Sends conversation data to Anthropic                 |
| Contribution metrics (Analytics) | Not available; usage metrics only                   |

What ZDR does **not** cover: chat on claude.ai, Cowork, Claude Code Analytics metadata, user/seat management, third-party integrations. These follow standard retention policies.

### Cloud execution security

| Control                  | Detail                                                    |
| :----------------------- | :-------------------------------------------------------- |
| Isolated VMs             | Each session runs in an Anthropic-managed isolated VM     |
| Network access controls  | Limited by default; configurable domain restrictions      |
| Credential protection    | Scoped credential in sandbox, translated to GitHub token  |
| Branch restrictions      | Git push restricted to current working branch             |
| Audit logging            | All operations logged for compliance                      |
| Automatic cleanup        | Environments terminated after session completion          |

Remote Control sessions are different: execution stays local, connection uses short-lived narrowly scoped credentials over TLS.

### Legal and compliance

| Plan type               | Governing terms                                                                    |
| :---------------------- | :--------------------------------------------------------------------------------- |
| Team / Enterprise / API | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms)               |
| Free / Pro / Max        | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms)                   |

BAA: automatically extends to Claude Code if customer has executed a BAA and has ZDR activated on CfE.

Acceptable use: subject to [Anthropic Usage Policy](https://www.anthropic.com/legal/aup).

Security vulnerabilities: report via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability).

Trust and compliance: [Anthropic Trust Center](https://trust.anthropic.com) (SOC 2 Type 2, ISO 27001, etc.).

### Security best practices

**Working with sensitive code:**
- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repositories
- Consider devcontainers for additional isolation
- Audit permissions with `/permissions`

**Team security:**
- Use managed settings to enforce organizational standards
- Share approved permission configurations through version control
- Monitor usage through OpenTelemetry metrics
- Audit settings changes with `ConfigChange` hooks

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — security foundation, permission architecture, prompt injection protections, MCP security, IDE security, cloud execution security, and best practices.
- [Sandboxing](references/claude-code-sandboxing.md) — sandboxed bash tool, filesystem and network isolation, OS-level enforcement (Seatbelt/bubblewrap), sandbox modes, configuration, security limitations, and open source runtime.
- [Development containers](references/claude-code-devcontainer.md) — preconfigured devcontainer with firewall, Dockerfile, getting started, customization, and use cases.
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy configuration, custom CA certificates, mTLS authentication, required URLs, and GitHub Enterprise IP allowlisting.
- [Data usage](references/claude-code-data-usage.md) — training policy by plan type, data retention periods, telemetry services, local and cloud data flows, and opt-out environment variables.
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, commercial agreements, BAA/healthcare compliance, acceptable use policy, and vulnerability reporting.
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what it covers and does not cover, features disabled under ZDR, data retention for policy violations, and how to request enablement.

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
