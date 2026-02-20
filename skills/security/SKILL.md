---
name: security
description: Reference documentation for Claude Code security, sandboxing, data usage, network configuration, devcontainers, and legal compliance. Use when configuring sandbox modes, setting up enterprise proxies or mTLS, understanding data retention policies, reviewing prompt injection protections, or assessing legal and compliance requirements.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data privacy, network configuration, devcontainers, and legal compliance.

## Quick Reference

### Permission-Based Architecture

Claude Code uses strict read-only defaults. Write operations are confined to the project directory. Sensitive actions require explicit approval. Use `/permissions` to audit settings.

### Prompt Injection Protections

| Protection                    | Description                                                    |
|:------------------------------|:---------------------------------------------------------------|
| Permission system             | Sensitive operations require explicit approval                 |
| Context-aware analysis        | Detects potentially harmful instructions                       |
| Input sanitization            | Prevents command injection                                     |
| Command blocklist             | Blocks `curl`, `wget` by default                               |
| Network request approval      | Tools making network requests require approval                 |
| Isolated context windows      | Web fetch uses separate context to avoid injection             |
| Trust verification            | First-time codebases and new MCP servers require verification  |
| Command injection detection   | Suspicious bash commands require manual approval               |
| Fail-closed matching          | Unmatched commands default to manual approval                  |

### Sandboxing

Enable with `/sandbox`. Uses OS-level primitives (Seatbelt on macOS, bubblewrap on Linux/WSL2).

| Mode                   | Behavior                                                              |
|:-----------------------|:----------------------------------------------------------------------|
| Auto-allow             | Sandboxed commands run without permission; unsandboxable ones fall back to normal flow |
| Regular permissions    | All commands go through standard permission flow, even when sandboxed |

**Filesystem isolation**: Read/write to CWD and subdirectories; read-only elsewhere (with denied dirs). **Network isolation**: Domain-based allow-list enforced via proxy outside the sandbox.

**Linux prerequisites**: `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) or `sudo dnf install bubblewrap socat` (Fedora).

**Escape hatch**: Commands failing due to sandbox restrictions may retry with `dangerouslyDisableSandbox` (goes through normal permissions). Disable with `"allowUnsandboxedCommands": false`.

**Custom proxy** (advanced):
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

### Enterprise Network Configuration

| Variable                             | Purpose                              |
|:-------------------------------------|:-------------------------------------|
| `HTTPS_PROXY`                        | HTTPS proxy URL                      |
| `HTTP_PROXY`                         | HTTP proxy (fallback)                |
| `NO_PROXY`                           | Bypass proxy (space or comma-separated) |
| `NODE_EXTRA_CA_CERTS`                | Custom CA certificate path           |
| `CLAUDE_CODE_CLIENT_CERT`            | mTLS client certificate              |
| `CLAUDE_CODE_CLIENT_KEY`             | mTLS client private key              |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE`  | Passphrase for encrypted key         |

**Required URLs**: `api.anthropic.com`, `claude.ai`, `platform.claude.com`

### Data Retention

| Account type                               | Retention                |
|:-------------------------------------------|:-------------------------|
| Consumer (training allowed)                | 5 years                  |
| Consumer (training disallowed)             | 30 days                  |
| Commercial (standard)                      | 30 days                  |
| Commercial (zero data retention API keys)  | No server-side retention |

**Training policy**: Commercial users (Team, Enterprise, API) -- Anthropic does not train on data unless customer opts in (e.g., Developer Partner Program). Consumer users choose via privacy settings.

### Telemetry Opt-Out

| Service              | Env var to disable                         |
|:---------------------|:-------------------------------------------|
| Statsig (metrics)    | `DISABLE_TELEMETRY=1`                      |
| Sentry (errors)      | `DISABLE_ERROR_REPORTING=1`                |
| Bug reports          | `DISABLE_BUG_COMMAND=1`                    |
| Session surveys      | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`    |
| All non-essential    | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` |

Bedrock, Vertex, and Foundry providers have all non-essential traffic disabled by default.

### Devcontainer Security

The [reference devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides firewall-based network isolation (default-deny, whitelist-only outbound) allowing `claude --dangerously-skip-permissions` for unattended operation. Components: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`.

### Legal & Compliance

| Agreement       | Applies to                                      |
|:----------------|:------------------------------------------------|
| Commercial Terms| Team, Enterprise, API users                     |
| Consumer Terms  | Free, Pro, Max users                            |
| BAA (healthcare)| Extends automatically with ZDR-enabled API keys |

**OAuth tokens** from Free/Pro/Max accounts are for Claude Code and claude.ai only -- not permitted in Agent SDK or third-party tools. Developers must use API key authentication.

**Vulnerability reporting**: [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- permission architecture, prompt injection protections, MCP security, IDE security, cloud execution security, and best practices
- [Sandboxing](references/claude-code-sandboxing.md) -- filesystem and network isolation, sandbox modes, OS-level enforcement, custom proxy config, and security limitations
- [Network Configuration](references/claude-code-network-config.md) -- proxy setup, custom CA certificates, mTLS authentication, and required URLs
- [Data Usage](references/claude-code-data-usage.md) -- training policy, retention periods, telemetry services, and cloud execution data flow
- [Development Containers](references/claude-code-devcontainer.md) -- devcontainer setup, firewall rules, customization, and use cases
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- license terms, BAA coverage, acceptable use, and credential policies

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
