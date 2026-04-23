---
name: security-doc
description: Complete official documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, zero data retention, and legal compliance.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, and compliance.

## Quick Reference

### Security architecture

| Protection | Description |
| :--------- | :---------- |
| **Permission-based** | Read-only by default; explicit approval required for writes, commands, and network requests |
| **Write scope** | Claude Code can only write to the working directory and subdirectories |
| **Sandboxing** | OS-level filesystem + network isolation via `/sandbox` command |
| **Allowlisting** | Frequently used safe commands can be allowlisted per-user, per-project, or per-org |
| **Prompt injection guards** | Input sanitization, command blocklist (`curl`, `wget`), isolated web-fetch context windows |
| **Trust verification** | First-time codebases and new MCP servers require trust verification (disabled with `-p` flag) |
| **Credential storage** | API keys and tokens are encrypted at rest |

### Built-in prompt injection safeguards

- Permission system: sensitive operations always require explicit approval
- Isolated context window for WebFetch to prevent injecting malicious prompts
- Command injection detection: suspicious commands require manual approval even when allowlisted
- Fail-closed matching: unrecognized commands default to manual approval
- Natural language descriptions of complex bash commands for review

### Sandboxing

Enable with `/sandbox`. Requires `bubblewrap` + `socat` on Linux/WSL2 (built-in on macOS via Seatbelt).

**Sandbox modes:**

| Mode | Behavior |
| :--- | :------- |
| **Auto-allow** | Sandboxed commands run automatically; commands needing disallowed network access fall back to normal permission flow |
| **Regular permissions** | All commands still go through normal approval flow even when sandboxed |

**Key sandbox settings in `settings.json`:**

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": false,
    "allowUnsandboxedCommands": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "/tmp/build"],
      "denyWrite": [],
      "denyRead": ["~/"],
      "allowRead": ["."]
    },
    "network": {
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

**Filesystem path prefixes:**

| Prefix | Resolves to |
| :----- | :---------- |
| `/` | Absolute path |
| `~/` | Home directory |
| `./` or no prefix | Project root (project settings) or `~/.claude` (user settings) |

**Key limitations:** `watchman` and `docker` are incompatible with the sandbox; exclude via `excludedCommands`. WSL1 not supported (requires WSL2).

### Cloud execution security

| Control | Detail |
| :------ | :----- |
| Isolated VMs | Each cloud session runs in an Anthropic-managed, isolated VM |
| Network controls | Network access limited by default; configurable per domain |
| Credential protection | GitHub auth via secure proxy; credentials never enter the sandbox |
| Branch restrictions | Git push restricted to the current working branch |
| Audit logging | All cloud operations logged |
| Auto cleanup | Cloud environments terminated after session completion |

### MCP security

Anthropic does not manage or audit third-party MCP servers. Write your own or use servers from trusted providers only. Allowed MCP servers are configured in Claude Code settings checked into source control.

### Network configuration (enterprise)

Proxy environment variables:

```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,example.com,.example.com"
```

Custom CA and mTLS:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CERT_STORE=bundled,system   # default
```

**Required allowlist URLs:**

| URL | Purpose |
| :-- | :------ |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Console account authentication |
| `downloads.claude.ai` | Plugin and native binary downloads/updates |
| `bridge.claudeusercontent.com` | Claude in Chrome WebSocket bridge |

### Devcontainers

The [reference devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides isolated environments with a custom firewall (default-deny outbound, whitelisted domains only). Enables `--dangerously-skip-permissions` for unattended operation with reduced risk. Not immune to credential exfiltration — use only with trusted repositories.

### Data usage and retention

**Training policy:**

| Account type | Model training |
| :----------- | :------------- |
| Consumer (Free/Pro/Max) | Data used for training when setting is on (opt-out available at claude.ai/settings/data-privacy-controls) |
| Commercial (Team/Enterprise/API) | Not used for training unless explicitly opted in (e.g. Developer Partner Program) |

**Retention periods:**

| Account type | Default | With model training opt-in |
| :----------- | :------ | :------------------------ |
| Consumer | 30 days | 5 years |
| Commercial | 30 days | — |
| ZDR (Enterprise) | Not retained after response | — |

Local session transcripts are stored in `~/.claude/projects/` for 30 days (configurable via `cleanupPeriodDays`).

**Telemetry opt-out env vars:**

| Variable | Effect |
| :------- | :----- |
| `DISABLE_TELEMETRY=1` | Disable Statsig metrics |
| `DISABLE_ERROR_REPORTING=1` | Disable Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable all non-essential traffic (surveys, telemetry, error reporting) |

Bedrock, Vertex, and Foundry users have Statsig, Sentry, and feedback reporting **off by default**. Session quality surveys and the WebFetch domain safety check are on by default for all providers.

**WebFetch domain safety check:** Sends only the hostname (not path or content) to `api.anthropic.com` before fetching. Cached per hostname for 5 minutes. Disable with `skipWebFetchPreflight: true` in settings. Not affected by `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only (not Bedrock/Vertex/Foundry). Must be enabled per-organization by your Anthropic account team.

**Features disabled under ZDR:**

| Feature | Reason |
| :------ | :----- |
| Claude Code on the Web | Requires server-side storage |
| Remote sessions from Desktop app | Requires persistent session data |
| `/feedback` command | Sends conversation data to Anthropic |

**ZDR does not cover:** chat on claude.ai, Cowork sessions, Analytics metadata, user/seat management, third-party integrations.

Policy violation exception: Anthropic may retain flagged data for up to 2 years.

### Legal and compliance

| Account type | Applicable agreement |
| :----------- | :------------------- |
| Team/Enterprise/API | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Free/Pro/Max | [Consumer Terms of Service](https://www.anthropic.com/legal/consumer-terms) |
| Bedrock/Vertex (3P) | Existing commercial agreement with cloud provider |

**Healthcare (BAA):** BAA automatically extends to Claude Code when the customer has both an executed BAA and ZDR enabled. Must be enabled per-organization.

**Authentication rules:** OAuth tokens are for direct Anthropic subscription plans only. Third-party developers building products must use API key authentication. Routing requests through Free/Pro/Max credentials on behalf of other users is not permitted.

### Reporting security vulnerabilities

Report via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability). Do not disclose publicly before Anthropic has addressed the issue.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection safeguards, MCP/IDE/cloud security, best practices, and vulnerability reporting
- [Sandboxing](references/claude-code-sandboxing.md) — sandbox modes, filesystem and network isolation, OS-level enforcement, configuration, limitations, and open-source sandbox runtime
- [Development containers](references/claude-code-devcontainer.md) — reference devcontainer setup, firewall configuration, and use cases for isolated environments
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificates, mTLS authentication, and required URL allowlist
- [Data usage](references/claude-code-data-usage.md) — training policy, data retention periods, telemetry services, opt-out variables, and WebFetch domain safety check
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, data retention for policy violations, and how to request ZDR
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — legal agreements, healthcare BAA, usage policy, authentication rules, and trust center

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
