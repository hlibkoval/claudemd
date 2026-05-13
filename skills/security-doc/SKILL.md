---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, prompt injection protections, sandboxing (filesystem/network isolation, OS-level enforcement, configuration), dev containers, enterprise network configuration (proxy, CA certs, mTLS), data usage and retention policies, zero data retention (ZDR), and legal/compliance information.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, network configuration, data usage, and compliance.

## Quick Reference

### Security Architecture Overview

| Layer | Mechanism | What it protects |
| :---- | :-------- | :--------------- |
| Permissions | Read-only by default; explicit approval required | File edits, bash commands, network requests |
| Sandboxing | OS-level filesystem + network isolation | Limits blast radius of compromised commands |
| Dev containers | Docker isolation; non-root execution | Host machine from Claude Code commands |
| Network controls | Proxy, CA certs, mTLS, domain allowlists | Enterprise traffic routing and TLS inspection |
| Prompt injection defenses | Context analysis, input sanitization, command blocklist | Attacker-injected instructions |

### Built-in Security Protections

| Protection | Description |
| :--------- | :---------- |
| Write access restriction | Claude Code can only write to the working directory and subdirectories |
| Accept Edits mode | Auto-approves file edits + safe FS commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) in the working directory |
| Command blocklist | Blocks `curl`, `wget` by default to prevent arbitrary web content fetching |
| Network request approval | Tools making network requests require explicit user approval |
| Isolated web fetch context | WebFetch uses a separate context window to prevent prompt injection |
| Trust verification | First-time codebases and new MCP servers require trust confirmation |
| Command injection detection | Suspicious bash commands prompt even if previously allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys/tokens are encrypted |

### Sandboxing

#### Enabling Sandboxing

Run `/sandbox` to open the mode selection menu. Two modes:

| Mode | Behavior |
| :--- | :------- |
| Auto-allow | Sandboxed commands run without prompting; unsandboxable commands fall back to normal permission flow |
| Regular permissions | All commands go through the normal permission flow even when sandboxed |

#### Platform Prerequisites

| Platform | Requirements |
| :------- | :----------- |
| macOS | Works out of the box (Seatbelt) |
| Linux / WSL2 | `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) or `sudo dnf install bubblewrap socat` (Fedora) |
| Ubuntu 24.04+ | Add AppArmor profile granting `bwrap` the `userns` capability |
| WSL1 | Not supported |

#### Sandbox Filesystem Path Prefixes

| Prefix | Meaning |
| :----- | :------ |
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

Key settings under `sandbox.filesystem`: `allowWrite`, `denyWrite`, `denyRead`, `allowRead`. Arrays **merge** across settings scopes (not replaced).

#### Sandbox Network Configuration

```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

Use `allowedDomains` to whitelist domains; `deniedDomains` to block specific domains within a broader wildcard. Set `allowManagedDomainsOnly: true` to block all non-allowed domains automatically.

#### Sandbox Security Limitations

- Built-in proxy does not terminate or inspect TLS — does not guard against domain fronting
- `allowUnixSockets` can grant access to powerful services (e.g., `/var/run/docker.sock`)
- Overly broad `allowWrite` paths can enable privilege escalation
- `enableWeakerNestedSandbox` (Linux) weakens security — only use inside Docker with other isolation

#### Sandbox vs. Permissions

| | Permissions | Sandboxing |
| :- | :---------- | :--------- |
| Scope | All tools (Bash, Read, Edit, WebFetch, MCP) | Bash commands and child processes only |
| Enforcement | Evaluated before tool runs | OS-level (Seatbelt / bubblewrap) |
| Configuration | `settings.json` allow/deny rules | `sandbox.*` settings |

### Enterprise Network Configuration

#### Proxy Environment Variables

```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,192.168.1.1,example.com,.example.com"
```

Note: SOCKS proxies are not supported.

#### CA Certificate Configuration

| Variable | Purpose |
| :------- | :------ |
| `CLAUDE_CODE_CERT_STORE` | `bundled`, `system`, or `bundled,system` (default) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |

#### mTLS Authentication

```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="your-passphrase"
```

#### Required Network Domains (Allowlist)

| Domain | Required for |
| :----- | :----------- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads, native installer/updater |
| `bridge.claudeusercontent.com` | Claude in Chrome WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed and release notes |

### Dev Containers

Install via the [Claude Code Dev Container Feature](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code):

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

Key configuration options:

| Goal | Mechanism |
| :--- | :-------- |
| Persist auth across rebuilds | Mount named volume at `~/.claude` |
| Enforce org policy | Copy `managed-settings.json` to `/etc/claude-code/` in Dockerfile |
| Disable auto-update | `DISABLE_AUTOUPDATER=1` in `containerEnv` |
| Restrict network egress | `init-firewall.sh` + `NET_ADMIN`/`NET_RAW` capabilities |
| Run without prompts | `--dangerously-skip-permissions` (non-root user only) |

### Data Usage and Retention

#### Training Policy

| Account type | Default training use |
| :----------- | :------------------- |
| Consumer (Free, Pro, Max) | Used for model training when setting is on |
| Commercial (Team, Enterprise, API) | Not used unless opted in (e.g., Developer Partner Program) |

#### Data Retention Periods

| Account type | Retention |
| :----------- | :-------- |
| Consumer — allows training | 5 years |
| Consumer — opts out of training | 30 days |
| Commercial — standard | 30 days |
| Commercial — Zero Data Retention | No server-side persistence after response |
| Local session transcripts | 30 days (`~/.claude/projects/`); configurable via `cleanupPeriodDays` |
| `/feedback` shared transcripts | 5 years |
| Session quality survey transcripts | Up to 6 months |

#### Telemetry Opt-out Variables

| Variable | What it disables |
| :------- | :--------------- |
| `DISABLE_TELEMETRY=1` | Anthropic operational metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` transcript uploads |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | All non-essential traffic (not WebFetch safety check) |

Telemetry and error reporting default to **off** for Bedrock, Vertex, Foundry, and Claude Platform on AWS.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only. ZDR covers model inference calls — prompts and responses are not retained after the response is returned.

**Features disabled under ZDR:**

| Feature | Reason |
| :------ | :----- |
| Claude Code on the Web | Requires server-side conversation history |
| Desktop remote sessions | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

ZDR is enabled **per organization** — each new org must be enabled separately. Contact your Anthropic account team to request.

### Legal and Compliance

| Topic | Details |
| :---- | :------ |
| Commercial users | Subject to [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Consumer users | Subject to [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |
| Healthcare (BAA) | BAA extends to Claude Code if ZDR is also activated on the organization |
| Security vulnerability reporting | [HackerOne program](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new) |
| Trust certifications (SOC 2, ISO 27001) | [Anthropic Trust Center](https://trust.anthropic.com) |

### Cloud Execution Security Controls

When using Claude Code on the web:

- Each session runs in an isolated, Anthropic-managed VM
- Network access is limited by default (configurable per-session)
- Git push operations are restricted to the current working branch
- All operations are audit-logged
- Cloud environments terminate automatically after session completion

### Security Best Practices

1. Review all suggested changes before approval
2. Use project-specific permission settings for sensitive repositories
3. Use dev containers or sandboxing for additional isolation
4. Audit permission settings regularly with `/permissions`
5. Share approved permission configurations through version control
6. Monitor usage via OpenTelemetry metrics
7. Audit or block settings changes with `ConfigChange` hooks
8. Avoid piping untrusted content directly to Claude
9. Report suspicious behavior with `/feedback`

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission-based architecture, prompt injection protections, MCP/IDE/cloud security, security best practices, vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) — OS-level filesystem and network isolation, sandbox modes, configuration, security benefits and limitations, advanced proxy configuration
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth, enforcing org policy, restricting network egress, running without permission prompts
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate configuration, mTLS authentication, required network domain allowlist
- [Data usage](references/claude-code-data-usage.md) — training policy, data retention periods, telemetry services and opt-outs, WebFetch domain safety check
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, healthcare BAA, usage policy, authentication/credential rules, security reporting
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, features disabled under ZDR, how to request ZDR for Claude for Enterprise

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
