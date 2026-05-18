---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, prompt injection protections, sandboxing (filesystem and network isolation), dev containers, enterprise network configuration (proxy, CA certs, mTLS), data usage and retention policies, zero data retention, and legal/compliance information.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, data privacy, enterprise network configuration, and compliance.

## Quick Reference

### Security Architecture Overview

| Layer | Mechanism | What it protects |
| :--- | :--- | :--- |
| **Permissions** | Explicit approval before tool use | Controls which tools Claude can call |
| **Sandboxing** | OS-level filesystem + network isolation | Restricts what Bash commands can access |
| **Dev containers** | Docker isolation | Full process and filesystem boundary |
| **Write restriction** | Scope limited to working directory | Prevents writes outside project by default |
| **Accept Edits mode** | Auto-approves file edits + safe Bash | Reduces prompts for common safe commands |
| **Command blocklist** | Blocks `curl`, `wget` by default | Prevents fetching arbitrary web content |

### Built-in Prompt Injection Protections

| Protection | Description |
| :--- | :--- |
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects harmful instructions by analyzing the full request |
| Input sanitization | Prevents command injection |
| Command blocklist | Blocks `curl`/`wget` by default |
| Isolated web fetch context | Separate context window for web fetches |
| Trust verification | First-time codebases and new MCP servers require trust confirmation |
| Command injection detection | Suspicious bash commands prompt manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring approval |

### Cloud Execution Security Controls

| Control | Description |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in a separate Anthropic-managed VM |
| Network access controls | Limited by default; configurable per-session |
| Credential protection | Secure proxy translates scoped sandbox credential to GitHub token |
| Branch restrictions | Git push limited to current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Environments terminated after session completion |

### Sandboxing

#### Platform Support

| Platform | Implementation | Notes |
| :--- | :--- | :--- |
| macOS | Seatbelt (built-in) | Works out of the box |
| Linux / WSL2 | bubblewrap + socat | Must install packages first |
| WSL1 | Not supported | Requires WSL2 for namespace primitives |

Install on Ubuntu/Debian: `sudo apt-get install bubblewrap socat`

Ubuntu 24.04+ requires an AppArmor profile for `bwrap` — see the full reference.

#### Sandbox Modes

| Mode | Behavior |
| :--- | :--- |
| **Auto-allow** | Sandboxed commands run automatically; non-sandboxable commands fall back to normal permission flow |
| **Regular permissions** | All commands go through standard permission flow even when sandboxed |

Enable with `/sandbox` in-session.

#### Sandbox Filesystem Path Prefixes

| Prefix | Resolves to |
| :--- | :--- |
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

#### Sandbox Settings (in `settings.json`)

| Setting | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable/disable sandbox |
| `sandbox.filesystem.allowWrite` | Paths subprocesses may write outside working dir |
| `sandbox.filesystem.denyWrite` | Paths subprocesses may not write |
| `sandbox.filesystem.denyRead` | Paths subprocesses may not read |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port for TLS inspection |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (managed deployments) |
| `allowUnsandboxedCommands` | Set `false` to disable the `dangerouslyDisableSandbox` escape hatch |
| `allowManagedDomainsOnly` | Block non-allowed domains automatically (no prompt) |
| `excludedCommands` | Commands that always run outside the sandbox |

Filesystem array settings (`allowWrite`, `denyWrite`, etc.) **merge** across settings scopes — they are not replaced.

#### What Sandboxing Does Not Cover

- Built-in file tools (Read, Edit, Write) — governed by permissions, not sandbox
- Computer use — runs on actual desktop, not sandboxed

#### Security Limitations

- Network proxy enforces allowlist by hostname only; does not terminate TLS — domain fronting is possible with broad allowlists
- `allowUnixSockets` can grant access to powerful services (e.g. Docker socket = host access)
- Overly broad `allowWrite` paths can enable privilege escalation

### Dev Containers

#### Key Configuration Options

| Goal | Configuration |
| :--- | :--- |
| Add Claude Code | `ghcr.io/anthropics/devcontainer-features/claude-code:1.0` in `features` |
| Persist auth across rebuilds | Mount named volume at `~/.claude` |
| Enforce org policy | Copy `managed-settings.json` → `/etc/claude-code/managed-settings.json` in Dockerfile |
| Restrict network egress | Use `init-firewall.sh` with `NET_ADMIN` + `NET_RAW` capabilities |
| Run unattended | `--dangerously-skip-permissions` (non-root user only) |
| Pin Claude Code version | Install via `npm install -g @anthropic-ai/claude-code@X.Y.Z` + `DISABLE_AUTOUPDATER=1` |

Disable auto-update + telemetry in `containerEnv`:
```json
"containerEnv": {
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
  "DISABLE_AUTOUPDATER": "1"
}
```

Security warning: `--dangerously-skip-permissions` does not prevent exfiltration of files accessible inside the container (including `~/.claude` credentials). Only use with trusted repositories. Do not mount host secrets like `~/.ssh` into the container.

### Enterprise Network Configuration

#### Proxy Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Bypass proxy — comma or space separated; `*` for all |

Basic auth: include credentials in URL (`http://user:pass@proxy:8080`). SOCKS proxies are not supported.

#### Certificate Configuration

| Variable / Setting | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE` | Comma-separated: `bundled` (Mozilla CA set) and/or `system` (OS store); default `bundled,system` |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM file |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted mTLS private key |

Enterprise TLS-inspection proxies (CrowdStrike Falcon, Zscaler) work without additional config when their root certificate is in the OS trust store.

#### Required Network Allowlist

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console account authentication |
| `downloads.claude.ai` | Plugin downloads; native installer and auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed and release notes |

When using Bedrock/Vertex/Foundry, model traffic goes to the provider instead of `api.anthropic.com`. The WebFetch domain safety check still calls `api.anthropic.com` unless `skipWebFetchPreflight: true` is set.

For GitHub Enterprise Server (GHES) or GitHub Enterprise Cloud IP restrictions, allowlist [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Data Usage and Retention

#### Data Training Policy by Plan

| Plan type | Training use |
| :--- | :--- |
| Free, Pro, Max (consumer) | Used when training opt-in is on (user-configurable at claude.ai/settings/data-privacy-controls) |
| Team, Enterprise, API (commercial) | Not used for training by default; opt-in via Developer Partner Program |

#### Data Retention by Plan

| Plan | Default retention |
| :--- | :--- |
| Consumer (allows training) | 5 years |
| Consumer (disallows training) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | No server-side persistence after response returned |

Local session transcripts stored at `~/.claude/projects/` for 30 days by default. Adjust with `cleanupPeriodDays`.

#### Telemetry and Opt-Out Variables

| Variable | What it disables |
| :--- | :--- |
| `DISABLE_TELEMETRY` | Operational metrics (latency, usage patterns) sent to Anthropic |
| `DISABLE_ERROR_REPORTING` | Error logs sent to Sentry |
| `DISABLE_FEEDBACK_COMMAND` | `/feedback` command sending data to Anthropic |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic at once (not WebFetch check) |

Telemetry and error reporting default **off** for Bedrock, Vertex, Foundry, and Claude Platform on AWS. Session quality surveys default on for all providers. WebFetch domain safety check always runs (opt out with `skipWebFetchPreflight: true` in settings).

#### WebFetch Domain Safety Check

Before fetching a URL, WebFetch sends the hostname (not full URL) to `api.anthropic.com` for blocklist check. Results cached per hostname for 5 minutes. Not affected by `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`.

#### Session Quality Survey Transcript Upload

A "Can Anthropic look at your session transcript?" follow-up after rating prompts uploads transcript data only on explicit **Yes**. Organizations with ZDR, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, or disabled product feedback never see this follow-up.

Transcripts submitted via the follow-up are retained up to 6 months and cannot be used for model training.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only (not Bedrock/Vertex/Foundry — those follow provider policies).

#### What ZDR Covers / Does Not Cover

| Covered | Not covered |
| :--- | :--- |
| Model inference calls through Claude Code terminal | Chat on claude.ai |
| All Claude models | Cowork sessions |
| — | Claude Code Analytics (collects metadata, not prompts) |
| — | User/seat management (administrative data) |
| — | Third-party integrations / MCP servers |

#### Features Disabled Under ZDR

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side conversation history storage |
| Remote sessions from Desktop app | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

ZDR is enabled per-organization — each organization must be enabled separately. Policy violations may result in data retained up to 2 years.

### Legal and Compliance

| Topic | Detail |
| :--- | :--- |
| License (commercial) | Anthropic Commercial Terms (Team, Enterprise, API users) |
| License (consumer) | Consumer Terms of Service (Free, Pro, Max users) |
| BAA (healthcare) | Automatically extends to Claude Code when ZDR is active for the org |
| Authentication (subscription users) | OAuth — intended for personal use of Claude Code |
| Authentication (developers/API) | API keys via Console or cloud provider; must not route third-party traffic through subscription credentials |
| Security reporting | HackerOne bug bounty program |

### Security Best Practices

**Working with sensitive code:**
- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Consider dev containers for additional isolation
- Audit permissions with `/permissions`

**Team / enterprise:**
- Use managed settings to enforce org standards
- Share approved permissions through version control
- Monitor with OpenTelemetry metrics
- Audit settings changes with `ConfigChange` hooks

**Untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for running scripts interacting with external web services
5. Report suspicious behavior with `/feedback`

**Windows caution:** Do not enable WebDAV or allow access to `\\*` paths — WebDAV is deprecated by Microsoft and can bypass the permission system.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — security architecture, permission model, prompt injection protections, MCP/IDE/cloud security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — OS-level filesystem and network isolation, sandbox modes, configuration, security limitations, advanced proxy setup
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth, enforcing org policy, network egress restrictions, unattended operation
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate store, custom CA certs, mTLS, required network allowlist
- [Data usage](references/claude-code-data-usage.md) — data training policy, retention periods, telemetry services, opt-out variables, WebFetch domain safety check, default behaviors by provider
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope and coverage, features disabled under ZDR, requesting ZDR for Enterprise
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, BAA for healthcare, usage policy, authentication requirements, security vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
