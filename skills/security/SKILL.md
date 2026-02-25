---
name: security
description: Reference documentation for Claude Code security — permission-based architecture, prompt injection protections, sandboxing (filesystem and network isolation), devcontainer setup, enterprise network configuration (proxy, custom CA, mTLS), data usage and retention policies, MCP security, cloud execution security, and legal compliance. Use when configuring security controls, sandboxing, network policies, or reviewing data handling practices.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data usage, network configuration, devcontainers, and legal compliance.

## Quick Reference

### Permission-Based Architecture

Claude Code uses strict read-only permissions by default. Write operations require explicit approval. Claude Code can only write to the folder where it was started and subfolders.

### Built-In Protections

| Protection                    | Description                                                      |
|:------------------------------|:-----------------------------------------------------------------|
| Sandboxed bash tool           | OS-level filesystem and network isolation via `/sandbox`         |
| Write access restriction      | Writes confined to project directory and subfolders              |
| Command blocklist             | `curl`, `wget` blocked by default                                |
| Command injection detection   | Suspicious commands require manual approval even if allowlisted  |
| Fail-closed matching          | Unmatched commands default to requiring manual approval          |
| Trust verification            | First-time codebase runs and new MCP servers need verification   |
| Isolated context windows      | Web fetch uses a separate context to avoid prompt injection      |
| Secure credential storage     | API keys and tokens are encrypted                                |

### Sandboxing

Enable with `/sandbox`. Uses OS-level primitives: **Seatbelt** on macOS, **bubblewrap** on Linux/WSL2.

| Mode              | Behavior                                                                |
|:------------------|:------------------------------------------------------------------------|
| Auto-allow        | Sandboxed commands run without permission; unsandboxable ones fall back |
| Regular           | All commands go through standard permission flow, even when sandboxed   |

**Filesystem isolation**: Read/write to CWD and subdirectories; read-only elsewhere; blocked outside sandbox.

**Network isolation**: Domain-based proxy filtering; only approved domains accessible; all child processes inherit restrictions.

**Linux prerequisites**: `sudo apt-get install bubblewrap socat` (Debian/Ubuntu) or `sudo dnf install bubblewrap socat` (Fedora).

**Escape hatch**: Commands failing in sandbox may retry with `dangerouslyDisableSandbox` (goes through normal permissions). Disable with `"allowUnsandboxedCommands": false`.

**Sandbox limitations**:
- Network filtering is domain-based only; does not inspect traffic content
- Broad domains (e.g. `github.com`) may allow data exfiltration
- `allowUnixSockets` can grant unintended access (e.g. Docker socket)
- `enableWeakerNestedSandbox` on Linux considerably weakens security
- `watchman` incompatible; use `jest --no-watchman`
- `docker` incompatible; add to `excludedCommands`

### Custom Proxy Configuration (Sandbox)

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

| Setting                             | Env var / config                           |
|:------------------------------------|:-------------------------------------------|
| HTTPS proxy                         | `HTTPS_PROXY=https://proxy.example.com:8080` |
| HTTP proxy                          | `HTTP_PROXY=http://proxy.example.com:8080`  |
| Bypass proxy                        | `NO_PROXY="localhost,192.168.1.1"`          |
| Custom CA certs                     | `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem`  |
| mTLS client cert                    | `CLAUDE_CODE_CLIENT_CERT=/path/to/cert.pem`  |
| mTLS client key                     | `CLAUDE_CODE_CLIENT_KEY=/path/to/key.pem`    |
| mTLS key passphrase                 | `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE=...`      |

**Required URLs to allowlist**: `api.anthropic.com`, `claude.ai`, `platform.claude.com`

### Data Retention

| Account type                                     | Retention    |
|:-------------------------------------------------|:-------------|
| Consumer (training on)                           | 5 years      |
| Consumer (training off)                          | 30 days      |
| Commercial (Team, Enterprise, API)               | 30 days      |
| Commercial with zero data retention (ZDR)        | None         |

Commercial users: Anthropic does not train on your data unless you opt in (e.g. Developer Partner Program).

### Telemetry Opt-Out

| Service               | Disable with                                  |
|:----------------------|:----------------------------------------------|
| Statsig (metrics)     | `DISABLE_TELEMETRY=1`                          |
| Sentry (errors)       | `DISABLE_ERROR_REPORTING=1`                    |
| Bug reports           | `DISABLE_BUG_COMMAND=1`                        |
| Session surveys       | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`        |
| All non-essential     | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`   |

Third-party providers (Bedrock, Vertex, Foundry) disable all non-essential traffic by default.

### Devcontainer Security

The reference [devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides isolation + firewall for running `claude --dangerously-skip-permissions`. Components: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`. Default-deny firewall policy; only whitelisted domains allowed.

### Cloud Execution Security

| Control                  | Description                                              |
|:-------------------------|:---------------------------------------------------------|
| Isolated VMs             | Each cloud session in an Anthropic-managed VM            |
| Network access controls  | Limited by default; configurable domain restrictions     |
| Credential protection    | GitHub auth via secure proxy; credentials never enter VM |
| Branch restrictions      | Git push restricted to current working branch            |
| Audit logging            | All operations logged                                    |
| Automatic cleanup        | Environments terminated after session completion         |

### Legal Agreements

| Plan                        | Governing terms                                                |
|:----------------------------|:---------------------------------------------------------------|
| Team, Enterprise, API       | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Free, Pro, Max              | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms)     |

Healthcare BAA extends to Claude Code when ZDR is activated.

**Report vulnerabilities**: [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- permission architecture, prompt injection protections, MCP security, IDE security, cloud execution security, and best practices
- [Sandboxing](references/claude-code-sandboxing.md) -- filesystem and network isolation, OS-level enforcement, sandbox modes, custom proxy, security limitations, and open source runtime
- [Development Containers](references/claude-code-devcontainer.md) -- devcontainer setup, firewall rules, isolation features, and customization
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- proxy, custom CA, mTLS, and required URL allowlisting
- [Data Usage](references/claude-code-data-usage.md) -- training policy, retention periods, telemetry services, data flow diagrams, and opt-out controls
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- license terms, BAA/healthcare compliance, acceptable use, and vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
