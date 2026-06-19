---
name: security-doc
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security — permission architecture, sandboxing, dev containers, network configuration, data usage, legal compliance, zero data retention, sandbox environments comparison, and the security-guidance plugin.

## Quick Reference

### Security Architecture Layers

| Layer | What it covers | Configured via |
| :--- | :--- | :--- |
| Permission system | Which tools can run and whether prompts are shown | `permissions` in settings / permission modes |
| Sandboxed Bash tool | Filesystem and network access of Bash commands (OS-enforced) | `sandbox` in settings / `/sandbox` command |
| Dev container | Full environment isolation; all tools, MCP servers, hooks | `.devcontainer/devcontainer.json` |
| Custom container / VM | Full OS boundary | External tooling |
| Claude Code on the web | Anthropic-managed VM isolation per session | Claude subscription + GitHub |

### Built-in Protections

| Protection | Detail |
| :--- | :--- |
| Write access restriction | Can only write to the folder where Claude Code was started and its subfolders |
| Prompt fatigue mitigation | Allowlisting per-user, per-codebase, or per-organization |
| Accept Edits mode | Auto-approves file edits and fixed set of filesystem Bash commands in working directory |
| Network command approval | `curl`, `wget` are not auto-approved by default |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys stored in macOS Keychain or protected by file permissions on Windows/Linux |
| Isolated context windows | WebFetch uses a separate context window to prevent prompt injection |

### Sandboxing: Key Settings (`sandbox` in `settings.json`)

| Key | Type | Description |
| :--- | :--- | :--- |
| `enabled` | boolean | Enable the sandboxed Bash tool |
| `failIfUnavailable` | boolean | Block startup if sandbox cannot initialize (managed deployments) |
| `allowUnsandboxedCommands` | boolean | Allow `dangerouslyDisableSandbox` escape hatch (default: true) |
| `filesystem.allowWrite` | string[] | Additional paths commands can write to |
| `filesystem.denyWrite` | string[] | Paths to block writes to |
| `filesystem.denyRead` | string[] | Paths to block reads from |
| `filesystem.allowRead` | string[] | Re-allow reads within a `denyRead` region |
| `allowedDomains` | string[] | Pre-allowed outbound network domains |
| `deniedDomains` | string[] | Blocked domains even if a wildcard `allowedDomains` would permit them |
| `allowManagedDomainsOnly` | boolean | Only honor `allowedDomains` from managed settings |
| `allowManagedReadPathsOnly` | boolean | Only honor `allowRead` from managed settings |
| `excludedCommands` | string[] | Commands that run outside the sandbox |
| `network.httpProxyPort` | number | Custom HTTP proxy port |
| `network.socksProxyPort` | number | Custom SOCKS proxy port |
| `enableWeakerNestedSandbox` | boolean | For running inside unprivileged containers |
| `allowAppleEvents` | boolean | Allow `open`/`osascript` on macOS (weakens isolation) |

### Sandbox Modes

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without prompting; commands that can't be sandboxed fall back to regular permission flow |
| Regular permissions | All Bash commands go through the regular permission flow even when sandboxed |

### Sandbox: Default Filesystem Behavior

| Access type | Default |
| :--- | :--- |
| Write | Working directory + session temp directory (`$TMPDIR`) only |
| Read | Entire filesystem except denied directories (credential files like `~/.aws/credentials` and `~/.ssh/` are readable by default — add to `denyRead` to block) |

### Sandbox: OS Support

| Platform | Sandbox mechanism |
| :--- | :--- |
| macOS | Seatbelt (built-in, no install needed) |
| Linux / WSL2 | `bubblewrap` + `socat` (install separately) |
| Native Windows | Not supported; use WSL2 or a container |

Linux/WSL2 install:
- Ubuntu/Debian: `sudo apt-get install bubblewrap socat`
- Fedora: `sudo dnf install bubblewrap socat`
- Optional seccomp filter (blocks Unix domain sockets): `npm install -g @anthropic-ai/sandbox-runtime`

### Sandbox: Managed Organization Enforcement

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false
  }
}
```

Deliver via MDM file or server-managed settings. Boolean keys use managed value; array keys (e.g. `excludedCommands`, `allowRead`) are merged across scopes unless `allowManagedReadPathsOnly`/`allowManagedDomainsOnly` locks them.

### Sandbox Environments: Approach Comparison

| Approach | What is isolated | Requires Docker | Setup effort |
| :--- | :--- | :--- | :--- |
| Sandboxed Bash tool | Bash commands and child processes | No | Minimal (macOS) / Low (Linux/WSL2) |
| Sandbox runtime (`@anthropic-ai/sandbox-runtime`) | Whole Claude Code process (all tools, hooks, MCP) | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium to high |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, Anthropic-hosted | No | None (needs subscription + GitHub) |

### Choose a Sandbox Approach

| Goal | Use |
| :--- | :--- |
| Reduce permission prompts on your own machine | Sandboxed Bash tool (`/sandbox`) |
| Unattended with `--dangerously-skip-permissions` | Dev container, any container/VM, or sandbox runtime |
| Isolate MCP servers and hooks without Docker | Sandbox runtime |
| Work on untrusted repository | VM or Claude Code on the web |
| Standardize across a team | Dev container committed to repo |
| No local setup needed | Claude Code on the web |

### Dev Container Key Config

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  },
  "mounts": [
    "source=claude-code-config,target=/home/node/.claude,type=volume"
  ],
  "containerEnv": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

- Managed settings: copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` in the Dockerfile
- Unattended runs: pass `--dangerously-skip-permissions` (CLI blocks this flag when run as root; `remoteUser` must be non-root)
- Network egress: use `init-firewall.sh` pattern from reference container + `NET_ADMIN`/`NET_RAW` `runArgs`

### Network Configuration

| Env var / setting | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | Route traffic through HTTPS proxy |
| `HTTP_PROXY` | Route traffic through HTTP proxy |
| `NO_PROXY` | Bypass proxy (space- or comma-separated) |
| `NODE_EXTRA_CA_CERTS` | Custom CA certificate path |
| `CLAUDE_CODE_CERT_STORE` | `bundled`, `system`, or `bundled,system` (default) |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

Note: SOCKS proxies are not supported.

### Required Network Domains (for allowlists/firewalls)

| Domain | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console account authentication |
| `downloads.claude.ai` | Plugin downloads; native installer and auto-updater |
| `raw.githubusercontent.com` | Changelog feed; plugin marketplace install counts |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `*.claudeusercontent.com` | Viewing artifacts on claude.ai |

When using Bedrock/Vertex/Foundry, model traffic goes to your provider instead of `api.anthropic.com`. WebFetch domain safety check still calls `api.anthropic.com` unless `skipWebFetchPreflight: true` is set.

### Data Usage & Telemetry

| Plan type | Training on data | Default retention |
| :--- | :--- | :--- |
| Consumer (Free/Pro/Max) — training ON | Yes | 5 years |
| Consumer (Free/Pro/Max) — training OFF | No | 30 days |
| Commercial (Team/Enterprise/API) | No (unless Developer Partner Program) | 30 days |
| ZDR (Enterprise only) | No | Not retained (real-time processing only) |

Local caching: session transcripts stored at `~/.claude/projects/` for 30 days (adjust with `cleanupPeriodDays`).

| Service | Default (Claude API) | Disable via |
| :--- | :--- | :--- |
| Anthropic metrics (telemetry) | On | `DISABLE_TELEMETRY=1` |
| Sentry (error reporting) | On | `DISABLE_ERROR_REPORTING=1` |
| `/feedback` reports | On | `DISABLE_FEEDBACK_COMMAND=1` |
| Session quality surveys | On | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` |
| WebFetch domain safety check | On (all providers) | `skipWebFetchPreflight: true` in settings |
| All non-essential traffic | — | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` |

Telemetry and error reporting default to OFF for Bedrock, Vertex, Foundry, and Claude Platform on AWS.

### Zero Data Retention (ZDR)

- Available to qualified Claude for Enterprise accounts (not included in standard plan; requires separate enablement by Anthropic)
- Prompts and responses processed in real time, not stored after response is returned
- Per-organization enablement: each new org requires separate activation

**Disabled features under ZDR:**

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side storage |
| Desktop cloud sessions | Requires persistent session data |
| Artifacts | Requires storing published content |
| `/feedback` submission | Sends conversation data to Anthropic |

**Model availability:** Claude Fable 5 is unavailable under ZDR (requires data retention). The `best` alias resolves to Opus for ZDR organizations.

To request ZDR: contact sales or your Anthropic account team.

### Legal & Compliance

| Topic | Detail |
| :--- | :--- |
| Commercial users | Existing commercial agreement (1P API, or Bedrock/Vertex 3P) applies to Claude Code |
| Consumer users | Consumer Terms of Service applies |
| Healthcare BAA | Extends to Claude Code automatically when BAA + ZDR are active for the organization |
| Security vulnerability reporting | HackerOne program (link in reference doc) |
| Acceptable use | Subject to Anthropic Usage Policy |
| OAuth authentication | For Claude Free/Pro/Max/Team/Enterprise subscribers only; developers must use API keys |

### Security Guidance Plugin

Install: `/plugin install security-guidance@claude-plugins-official` (user scope), then `/reload-plugins`

Enable in project settings for cloud sessions:
```json
{
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true
  }
}
```

**Three review layers:**

| Layer | Trigger | Cost |
| :--- | :--- | :--- |
| Per-edit pattern match | Every file write by Claude | None (no model call) |
| End-of-turn diff review | After each turn where files changed | Model usage (Opus 4.7 default) |
| Commit/push review (agentic) | When Claude runs `git commit` or `git push` | Model usage; capped at 20/rolling hour |

- Per-edit check covers: `eval(`, `new Function`, `os.system`, `exec`, `pickle`, `dangerouslySetInnerHTML`, `.innerHTML =`, `document.write`, `.github/workflows/` edits
- End-of-turn catches: authorization bypass, insecure direct object references, injection, SSRF, weak cryptography
- None of the layers block writes/commits; findings are fed back to Claude as instructions

**Custom extension files:**

| File | Purpose |
| :--- | :--- |
| `.claude/claude-security-guidance.md` | Plain-language guidance for model-backed reviews |
| `.claude/security-patterns.yaml` | Custom per-edit regex/substring rules |

**Disable individual layers:**

| Env var | Effect |
| :--- | :--- |
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn diff review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit/push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable plugin entirely without uninstalling |

Diagnostics log: `~/.claude/security/log.txt`

### Prompt Injection Protections

- Permission system requires explicit approval for sensitive operations
- Network commands (`curl`, `wget`) are not auto-approved
- WebFetch uses an isolated context window (separate from main conversation)
- First-time codebase runs and new MCP servers require trust verification
- Command injection detection: suspicious commands prompt even if previously allowlisted
- Fail-closed: unmatched commands require manual approval

**Best practices for untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs when interacting with external web services
5. Report suspicious behavior with `/feedback`

### Cloud Execution Security

| Control | Detail |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in a separate Anthropic-managed VM |
| Network access controls | Limited by default; configurable per domain |
| Credential protection | Scoped credential proxy; GitHub token never enters sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environment terminated after session completion |

Remote Control sessions run differently: execution stays local, connection uses multiple short-lived scoped credentials.

### Security Best Practices

**Working with sensitive code:**
- Use project-specific permission settings for sensitive repositories
- Consider dev containers for additional isolation
- Regularly audit permission settings with `/permissions`
- Use managed settings to enforce organizational standards

**Reporting security issues:**
- Do not disclose publicly
- Report via HackerOne program
- Include detailed reproduction steps

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Permission architecture, prompt injection protections, MCP/IDE/cloud execution security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — Sandboxed Bash tool setup, modes, configuration, OS-level enforcement, limitations, troubleshooting
- [Sandbox environments](references/claude-code-sandbox-environments.md) — Comparison of all isolation approaches; choosing the right one; enforcement across an organization
- [Development containers](references/claude-code-devcontainer.md) — Dev container setup, persistent auth, org policy enforcement, network egress restriction, unattended operation
- [Network configuration](references/claude-code-network-config.md) — Proxy setup, CA certificates, mTLS, required domain allowlist
- [Data usage](references/claude-code-data-usage.md) — Training policies, data retention, telemetry services, WebFetch domain safety check
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — License terms, healthcare BAA, acceptable use, authentication restrictions
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, model availability, requesting enablement
- [Security guidance plugin](references/claude-code-security-guidance.md) — In-session vulnerability detection, per-edit patterns, end-of-turn review, commit review, custom rules

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Sandbox environments: https://code.claude.com/docs/en/sandbox-environments.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Security guidance plugin: https://code.claude.com/docs/en/security-guidance.md
