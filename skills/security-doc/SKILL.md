---
name: security-doc
description: Complete documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage policies, zero data retention, and legal compliance. Load when discussing security best practices, prompt injection, sandbox configuration, data retention, enterprise proxy/mTLS setup, or compliance requirements.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, and compliance.

## Quick Reference

### Security Architecture

Claude Code uses permission-based architecture: read-only by default, explicit approval required for writes and commands. Built-in protections include sandboxed bash, write-access restriction to project directory, prompt fatigue mitigation via allowlists, and Accept Edits mode.

### Prompt Injection Protections

| Protection | Description |
|:-----------|:------------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects harmful instructions by analyzing full request |
| Input sanitization | Prevents command injection in user inputs |
| Command blocklist | Blocks `curl`, `wget` by default |
| Network request approval | Tools making network requests need user approval |
| Isolated context windows | Web fetch uses separate context to avoid injection |
| Trust verification | First-time codebases and new MCP servers require trust check |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without permission; unsandboxable commands fall back to normal flow |
| Regular permissions | All commands go through standard permission flow, even when sandboxed |

### Sandbox OS Support

| Platform | Technology |
|:---------|:-----------|
| macOS | Seatbelt (built-in) |
| Linux | bubblewrap + socat (install required) |
| WSL2 | bubblewrap + socat (same as Linux) |
| WSL1 | Not supported |

### Sandbox Settings

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "//tmp/build"],
      "denyWrite": [...],
      "denyRead": [...]
    },
    "network": {
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

Path prefixes: `//` = absolute from root, `~/` = home directory, `/` = relative to settings file dir, `./` = relative path.

### Enterprise Network Configuration

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL |
| `HTTP_PROXY` | HTTP proxy (fallback) |
| `NO_PROXY` | Bypass proxy for specified hosts |
| `NODE_EXTRA_CA_CERTS` | Custom CA certificate path |
| `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS client private key |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key |

Required URLs: `api.anthropic.com`, `claude.ai`, `platform.claude.com`.

### Data Retention

| Account type | Retention |
|:-------------|:----------|
| Consumer (training on) | 5 years |
| Consumer (training off) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | No retention (Enterprise only) |

### Telemetry Opt-Out

| Service | Env variable |
|:--------|:------------|
| Statsig (metrics) | `DISABLE_TELEMETRY=1` |
| Sentry (errors) | `DISABLE_ERROR_REPORTING=1` |
| Bug reports | `DISABLE_BUG_COMMAND=1` |
| Session surveys | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| All non-essential | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` |

Bedrock, Vertex, and Foundry disable all non-essential traffic by default.

### ZDR Features Disabled

When Zero Data Retention is enabled, these features are blocked: Claude Code on the Web, Remote sessions from Desktop app, Feedback submission (`/feedback`).

### Legal Quick Reference

| User type | Governing terms |
|:----------|:---------------|
| Free, Pro, Max | [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |
| Team, Enterprise, API | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |

Report security vulnerabilities via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability).

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) -- permission architecture, prompt injection protections, MCP/IDE/cloud security, best practices, vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) -- filesystem and network isolation, OS-level enforcement, sandbox modes, configuration, security benefits and limitations
- [Development Containers](references/claude-code-devcontainer.md) -- devcontainer setup, firewall rules, secure isolated environments for CI/CD and client work
- [Enterprise Network Configuration](references/claude-code-network-config.md) -- proxy setup, custom CA certificates, mTLS authentication, required URLs
- [Data Usage](references/claude-code-data-usage.md) -- training policies, data retention, telemetry services, cloud data flow, opt-out variables
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) -- license terms, BAA/healthcare compliance, acceptable use, authentication policies
- [Zero Data Retention](references/claude-code-zero-data-retention.md) -- ZDR scope, disabled features, data retention for policy violations, requesting ZDR

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
