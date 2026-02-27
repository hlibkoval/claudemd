---
name: security
description: Reference documentation for Claude Code security — permission-based architecture, prompt injection protections, sandboxing (filesystem and network isolation), devcontainers, enterprise network configuration (proxy, CA, mTLS), data usage and retention policies, and legal/compliance information.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security features, isolation mechanisms, enterprise network configuration, data policies, and compliance.

## Quick Reference

### Permission Architecture

Claude Code uses read-only permissions by default. Write and execute actions require explicit approval. Key built-in protections:

| Protection | Description |
|:-----------|:------------|
| Write access restriction | Writes limited to the working directory and subdirectories |
| Sandboxed bash | OS-level filesystem and network isolation via `/sandbox` |
| Accept Edits mode | Batch accept file edits while keeping prompts for side-effect commands |
| Command allowlisting | Frequently-used safe commands can be auto-approved per user/codebase/org |
| Command blocklist | `curl`, `wget`, and similar web-fetch commands blocked by default |

### Prompt Injection Protections

| Safeguard | Details |
|:----------|:--------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects potentially harmful instructions |
| Input sanitization | Prevents command injection |
| Isolated web fetch | Runs in a separate context window |
| Trust verification | First-time codebases and new MCP servers require trust confirmation |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys and tokens are encrypted |

### Sandboxing

Enable with `/sandbox`. Requires `bubblewrap` + `socat` on Linux/WSL2 (`sudo apt-get install bubblewrap socat`); works out of the box on macOS.

**Sandbox modes:**

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without prompts; non-sandboxable commands fall back to normal flow |
| Regular permissions | All commands go through the standard approval flow even when sandboxed |

**OS-level enforcement:**

| Platform | Technology |
|:---------|:-----------|
| macOS | Seatbelt |
| Linux / WSL2 | bubblewrap |
| WSL1 | Not supported |

**Key sandbox settings** (in `settings.json`):

| Setting | Effect |
|:--------|:-------|
| `allowUnsandboxedCommands: false` | Disables the escape hatch; commands must be sandboxed or in `excludedCommands` |
| `excludedCommands` | Force specific commands (e.g. `docker`) to run outside the sandbox |
| `sandbox.network.allowedDomains` | Domains Bash commands can reach |
| `sandbox.network.httpProxyPort` / `socksProxyPort` | Custom proxy for enterprise traffic inspection |
| `enableWeakerNestedSandbox` | Weakened Linux sandbox for Docker-without-privileges (use with caution) |

Both filesystem and network isolation are required for effective sandboxing — each alone can be bypassed.

### Devcontainers

The reference devcontainer (`github.com/anthropics/claude-code/tree/main/.devcontainer`) provides:

- Custom firewall: outbound restricted to npm, GitHub, Claude API, DNS, SSH
- Default-deny for all other network traffic
- Allows `claude --dangerously-skip-permissions` for unattended use (trusted repos only)

### Enterprise Network Configuration

All settings can be set via environment variables or `settings.json`.

**Proxy:**

```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,example.com"
# With basic auth:
export HTTPS_PROXY=http://username:password@proxy.example.com:8080
```

Note: SOCKS proxies are not supported.

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

**Required network access** (allowlist in firewalls/proxies):

- `api.anthropic.com` — Claude API
- `claude.ai` — claude.ai account authentication
- `platform.claude.com` — Anthropic Console account authentication

### Data Usage & Retention

| Account type | Training | Default retention |
|:-------------|:---------|:------------------|
| Consumer (Free/Pro/Max) — training on | Yes | 5 years |
| Consumer (Free/Pro/Max) — training off | No | 30 days |
| Commercial (Team/Enterprise/API) | No (unless opted in) | 30 days |
| Commercial with Zero Data Retention | No | None (no server retention) |

**Telemetry opt-outs:**

| Variable | Effect |
|:---------|:-------|
| `DISABLE_TELEMETRY=1` | Disable Statsig operational metrics |
| `DISABLE_ERROR_REPORTING=1` | Disable Sentry error logging |
| `DISABLE_BUG_COMMAND=1` | Disable `/bug` report sending |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable all of the above at once |

Bedrock, Vertex, and Foundry providers have all non-essential traffic disabled by default.

### Cloud Execution Security

When using Claude Code on the web, each session runs in an isolated Anthropic-managed VM with:

- Network access limited by default (configurable per-domain)
- GitHub credentials handled via secure proxy (never enter sandbox)
- Git push restricted to current working branch
- Audit logging of all operations
- Automatic cleanup after session

### Legal / Compliance

- Healthcare (HIPAA/BAA): BAA extends to Claude Code when ZDR (Zero Data Retention) is activated
- Security reporting: HackerOne — `hackerone.com/anthropic-vdp`
- Trust center: `trust.anthropic.com`
- OAuth tokens (Free/Pro/Max) may not be used in third-party tools or the Agent SDK — use API keys via Console instead

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection protections, MCP/IDE/cloud security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, sandbox modes, configuration, limitations
- [Development Containers](references/claude-code-devcontainer.md) — preconfigured secure devcontainer setup and firewall rules
- [Enterprise Network Configuration](references/claude-code-network-config.md) — proxy, custom CA, mTLS environment variables
- [Data Usage](references/claude-code-data-usage.md) — training policies, retention periods, telemetry opt-outs
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — terms, BAA/healthcare compliance, authentication rules

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
