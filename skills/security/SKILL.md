---
name: security
description: Reference documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, and legal compliance. Use when configuring sandbox isolation, enterprise proxy/mTLS settings, understanding data retention policies, securing MCP servers, setting up devcontainers, or reviewing permission architecture.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, network configuration, data privacy, and compliance.

## Quick Reference

Claude Code uses a permission-based architecture: read-only by default, explicit approval required for writes and commands. Built-in protections include sandboxed bash, write-access restriction to the working directory, command blocklists, and prompt injection detection.

### Sandboxing

OS-level isolation for bash commands. Enable with `/sandbox`.

| Platform   | Enforcement         | Prerequisites                    |
|:-----------|:--------------------|:---------------------------------|
| macOS      | Seatbelt            | Built-in, no setup needed        |
| Linux/WSL2 | bubblewrap          | `apt install bubblewrap socat`   |
| WSL1       | Not supported       | Requires WSL2 kernel features    |

**Sandbox modes:**

| Mode               | Behavior                                                              |
|:-------------------|:----------------------------------------------------------------------|
| Auto-allow         | Sandboxed commands run without permission; unsandboxable commands fall back to normal flow |
| Regular permissions| All commands go through standard permission flow, even when sandboxed  |

**Key sandbox settings** (in `settings.json`):

| Setting                    | Purpose                                                       |
|:---------------------------|:--------------------------------------------------------------|
| `sandbox.allowedDomains`   | Domains bash commands can reach                               |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port for network inspection            |
| `sandbox.network.socksProxyPort`| Custom SOCKS proxy port for network inspection           |
| `allowUnsandboxedCommands` | `false` to disable the escape hatch (forces all commands sandboxed) |
| `excludedCommands`         | Commands that always run outside the sandbox (e.g. `docker`)  |

Open-source sandbox runtime: `npx @anthropic-ai/sandbox-runtime <command>`

### Sandbox Security Limitations

- Network filtering is domain-based only; it does not inspect traffic content
- Broad domains like `github.com` may allow data exfiltration
- Domain fronting can bypass network filtering in some cases
- `allowUnixSockets` can expose powerful system services (e.g. Docker socket)
- Overly broad filesystem writes can enable privilege escalation
- Linux `enableWeakerNestedSandbox` mode considerably weakens security

### Prompt Injection Protections

| Protection                     | Description                                                   |
|:-------------------------------|:--------------------------------------------------------------|
| Permission system              | Sensitive operations require explicit approval                 |
| Context-aware analysis         | Detects potentially harmful instructions                      |
| Input sanitization             | Prevents command injection                                    |
| Command blocklist              | Blocks `curl`, `wget` by default                              |
| Isolated context windows       | Web fetch uses separate context to avoid injection             |
| Command injection detection    | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching           | Unmatched commands default to requiring manual approval        |
| Trust verification             | First-time codebases and new MCP servers require trust verification |

### Enterprise Network Configuration

**Proxy:**

```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost 192.168.1.1 example.com"
```

**Custom CA certificates:**

```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem
```

**mTLS authentication:**

```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="your-passphrase"
```

**Required URLs:** `api.anthropic.com`, `claude.ai`, `platform.claude.com`

### Devcontainers

Preconfigured development containers with firewall rules for isolated, secure environments. Enables `claude --dangerously-skip-permissions` for unattended operation. Components: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`. Reference setup: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

### Data Retention

| Account type          | Training policy             | Retention                           |
|:----------------------|:----------------------------|:------------------------------------|
| Free / Pro / Max      | Opt-in/out via settings     | 5 years (if training on) / 30 days  |
| Team / Enterprise / API | Not trained on by default | 30 days (or ZDR with configured keys)|

### Telemetry Opt-Out

| Service               | Environment variable                           |
|:----------------------|:-----------------------------------------------|
| Statsig (metrics)     | `DISABLE_TELEMETRY=1`                          |
| Sentry (errors)       | `DISABLE_ERROR_REPORTING=1`                    |
| Bug reports           | `DISABLE_BUG_COMMAND=1`                        |
| Session surveys       | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`        |
| All non-essential     | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`   |

Non-essential traffic is disabled by default for Bedrock, Vertex, and Foundry providers.

### Legal

| Plan                   | Terms                                                            |
|:-----------------------|:-----------------------------------------------------------------|
| Team / Enterprise / API| [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Free / Pro / Max       | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |

Healthcare BAA extends to Claude Code automatically when ZDR is activated. Report security vulnerabilities via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability).

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- permission architecture, prompt injection protections, MCP security, cloud execution security, and best practices
- [Sandboxing](references/claude-code-sandboxing.md) -- filesystem and network isolation, sandbox modes, OS-level enforcement, custom proxy configuration, and limitations
- [Development Containers](references/claude-code-devcontainer.md) -- devcontainer setup, firewall configuration, and use cases
- [Network Configuration](references/claude-code-network-config.md) -- proxy, custom CA, mTLS, and required URLs for enterprise environments
- [Data Usage](references/claude-code-data-usage.md) -- data training policies, retention periods, telemetry services, and opt-out controls
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- license terms, BAA/healthcare compliance, and vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
