---
name: security-doc
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data privacy, network configuration, and compliance.

## Quick Reference

### Permission-Based Architecture

Claude Code uses strict read-only permissions by default. Write access is confined to the folder where it was started and its subfolders.

| Protection | Description |
|:-----------|:------------|
| Sandboxed Bash tool | OS-level filesystem and network isolation for Bash commands |
| Write access restriction | Writes confined to working directory and subfolders |
| Accept Edits mode | Auto-approves file edits + a fixed set of safe Bash commands in the working directory |
| Prompt fatigue mitigation | Allowlist frequently used safe commands per-user, per-codebase, or per-org |

### Prompt Injection Protections

| Protection | Description |
|:-----------|:------------|
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects potentially harmful instructions |
| Input sanitization | Prevents command injection |
| Command blocklist | Blocks `curl`, `wget` by default |
| Network request approval | Tools that make network requests require user approval by default |
| Isolated context windows | WebFetch uses a separate context window |
| Trust verification | First-time codebase runs and new MCP servers require trust verification |
| Command injection detection | Suspicious Bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Secure credential storage | API keys and tokens are encrypted |

### Sandboxed Bash Tool

Enable with `/sandbox`. Supported on macOS, Linux, and WSL2 (not native Windows).

| Platform | Sandboxing mechanism |
|:---------|:--------------------|
| macOS | Seatbelt (built-in, nothing to install) |
| Linux / WSL2 | `bubblewrap` + `socat` (install via package manager) |

**Sandbox modes:**

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without prompting; unsandboxable commands fall back to regular permission flow |
| Regular permissions | All commands go through normal permission flow even when sandboxed |

**Key sandbox settings (`settings.json`):**

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable the sandbox |
| `sandbox.failIfUnavailable` | Fail hard if sandbox cannot start (for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | Set `false` for strict mode — disables `dangerouslyDisableSandbox` escape hatch |
| `sandbox.filesystem.allowWrite` | Additional paths commands can write to |
| `sandbox.filesystem.denyWrite` | Paths to block writes |
| `sandbox.filesystem.denyRead` | Paths to block reads |
| `sandbox.filesystem.allowRead` | Re-allow specific reads within a `denyRead` region |
| `sandbox.allowedDomains` | Pre-allow network domains to avoid prompts |
| `sandbox.deniedDomains` | Block specific domains even under a broad wildcard allow |
| `sandbox.excludedCommands` | Commands to always run outside the sandbox |
| `sandbox.allowManagedDomainsOnly` | Honor only managed-settings domain entries |
| `sandbox.allowManagedReadPathsOnly` | Honor only managed-settings `allowRead` entries |
| `sandbox.network.httpProxyPort` | Custom proxy HTTP port |
| `sandbox.network.socksProxyPort` | Custom proxy SOCKS port |
| `sandbox.enableWeakerNetworkIsolation` | For MITM proxy with custom CA on macOS |
| `sandbox.enableWeakerNestedSandbox` | For running inside unprivileged containers |

**Filesystem path prefix conventions:**

| Prefix | Resolves to |
|:-------|:------------|
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (in project settings) or `~/.claude` (in user settings) |

**Sandbox security limitations:**
- Built-in proxy does not terminate TLS — domain fronting possible; use custom proxy for TLS inspection
- `allowUnixSockets` can expose system services (e.g., Docker socket grants host access)
- Overly broad `allowWrite` to `$PATH` dirs or shell config files enables privilege escalation
- Sandbox covers only Bash subprocesses; file tools (Read, Edit, Write) run under the permission system; MCP servers and hooks run unconstrained on the host

### Sandbox Environments Comparison

| Approach | What is isolated | Requires Docker | Setup effort |
|:---------|:----------------|:----------------|:-------------|
| Sandboxed Bash tool | Bash commands and child processes | No | Minimal (macOS) / Low (Linux/WSL2) |
| Sandbox runtime | Whole Claude Code process incl. MCP servers and hooks | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium–high |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, hosted by Anthropic | No | None (requires subscription + GitHub) |

**When to use each:**

| Goal | Approach |
|:-----|:---------|
| Reduce permission prompts during everyday work | Sandboxed Bash tool (`/sandbox`) |
| Unattended with `--dangerously-skip-permissions` | Dev container, VM, or sandbox runtime |
| Isolate MCP servers and hooks without Docker | Sandbox runtime |
| Untrusted repository | Dedicated VM or Claude Code on the web |
| Standardize sandboxed env across a team | Dev container |

### Security Guidance Plugin

Install from the official Anthropic marketplace:

```
/plugin install security-guidance@claude-plugins-official
/reload-plugins
```

Enable for cloud sessions/all repo cloners via `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true
  }
}
```

**Three review layers:**

| Layer | Trigger | Cost |
|:------|:--------|:-----|
| Per-edit pattern check | Every file write | None (no model call) |
| End-of-turn diff review | After each turn | Model usage (Opus 4.7 by default) |
| Commit/push review | When Claude runs `git commit` or `git push` | Model usage, agentic, capped 20/hour |

**Disable individual layers:**

| Variable | Effect |
|:---------|:-------|
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn diff review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit/push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable the plugin entirely |
| `SECURITY_REVIEW_MODEL` | Override model for end-of-turn review |
| `SG_AGENTIC_MODEL` | Override model for commit review |

**Custom rules:**
- `.claude/claude-security-guidance.md` — plain-language guidance for model-backed reviews (8 KB cap; loaded from user, project, and project-local scopes)
- `.claude/security-patterns.yaml` — per-edit regex/substring patterns (up to 50 rules)

Custom patterns schema:

| Field | Type | Description |
|:------|:-----|:------------|
| `rule_name` | string | Identifier shown in warning |
| `reminder` | string | Warning text (capped at 1 KB) |
| `regex` | string | Python regex matched against edited content |
| `substrings` | list | Literal substrings (provide this or `regex`) |
| `paths` | list | Optional glob patterns; prefix with `**/` for project-relative |
| `exclude_paths` | list | Optional globs to skip |

### Dev Containers

Add Claude Code via the Dev Container Feature:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

Persist auth across rebuilds by mounting a named volume at `~/.claude`:

```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

Run without permission prompts (non-root user only): pass `--dangerously-skip-permissions`. Prevent its use via `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

Managed policy: copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` in the Dockerfile. For tamper-proof policy, use server-managed settings instead.

Recommended `containerEnv` for CI/unattended use:

```json
"containerEnv": {
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
  "DISABLE_AUTOUPDATER": "1"
}
```

### Network Configuration

**Required domains to allowlist:**

| URL | Required for |
|:----|:-------------|
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads; native installer/updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed and plugin marketplace data |

**Proxy environment variables:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy URL (recommended) |
| `HTTP_PROXY` | HTTP proxy URL |
| `NO_PROXY` | Comma- or space-separated bypass list; `*` to bypass all |
| `NODE_EXTRA_CA_CERTS` | Custom CA certificate path |
| `CLAUDE_CODE_CERT_STORE` | `bundled`, `system`, or `bundled,system` (default) |
| `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | mTLS key passphrase |

Note: SOCKS proxies are not supported.

### Data Usage and Retention

**Training policy:**
- Consumer users (Free/Pro/Max): data may be used for training when the opt-in setting is on
- Commercial users (Team/Enterprise/API): Anthropic does not train on code or prompts unless the customer explicitly opts in via the Developer Partner Program

**Retention periods:**

| User type | Retention |
|:----------|:----------|
| Consumer — training opt-in on | 5 years |
| Consumer — training opt-in off | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | Not retained after response |

Local session transcripts are stored in plaintext at `~/.claude/projects/` for 30 days by default (configure with `cleanupPeriodDays`).

**Telemetry opt-out variables:**

| Variable | Effect |
|:---------|:-------|
| `DISABLE_TELEMETRY=1` | Disable operational metrics (Anthropic API only by default) |
| `DISABLE_ERROR_REPORTING=1` | Disable Sentry error logging (Anthropic API only) |
| `DISABLE_FEEDBACK_COMMAND=1` | Disable `/feedback` submission |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential traffic at once |

**WebFetch domain safety check:** Before fetching any URL, the hostname is sent to `api.anthropic.com` for blocklist lookup (not the full URL or content). Runs regardless of model provider. Disable with `skipWebFetchPreflight: true` in settings.

**Encryption at rest by provider:**

| Provider | Encryption |
|:---------|:-----------|
| Anthropic API | AES-256 disk encryption; ZDR available |
| Amazon Bedrock | AES-256, AWS-managed keys; CMEK via KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | Anthropic infrastructure AES-256 |

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only.

- Prompts and responses are not retained by Anthropic after the response is returned
- ZDR is per-organization — each new org must have ZDR enabled separately by the account team
- Features disabled under ZDR: Claude Code on the Web, Remote Desktop sessions, `/feedback` submission

**ZDR does NOT cover:** chat on claude.ai, Cowork sessions, Claude Code Analytics, user/seat management data, third-party integrations.

**BAA (HIPAA):** If a customer has a BAA and has ZDR activated, the BAA automatically extends to cover Claude Code API traffic.

### Legal and Compliance

| Plan | Agreement |
|:-----|:----------|
| Team, Enterprise, API | Commercial Terms of Service |
| Free, Pro, Max | Consumer Terms of Service |

Security vulnerabilities: report via [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new). Do not disclose publicly before coordinating.

Trust Center resources (SOC 2 Type 2, ISO 27001): [trust.anthropic.com](https://trust.anthropic.com).

### Cloud Execution Security

When using Claude Code on the web:

| Control | Description |
|:--------|:------------|
| Isolated VMs | Each session runs in an Anthropic-managed VM |
| Network access controls | Limited by default; configurable per session |
| Credential protection | GitHub token stays outside the sandbox via a secure proxy |
| Branch restrictions | Git push limited to the current working branch |
| Audit logging | All operations logged |
| Automatic cleanup | Environments terminated after session |

### Security Best Practices

**Working with sensitive code:**
- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Consider dev containers for additional isolation
- Audit permission settings with `/permissions`

**Team security:**
- Use managed settings to enforce organizational standards
- Share approved permission configurations via version control
- Monitor usage via OpenTelemetry metrics
- Audit or block settings changes with `ConfigChange` hooks

**Working with untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts that interact with external web services
5. Report suspicious behavior with `/feedback`

**Windows note:** Avoid enabling WebDAV when running Claude Code on Windows — WebDAV is deprecated by Microsoft and may allow Claude Code to trigger network requests to remote hosts, bypassing the permission system.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Core security model, permission architecture, prompt injection protections, MCP/IDE/cloud execution security, and best practices
- [Security Guidance Plugin](references/claude-code-security-guidance.md) — Install and configure the in-session security review plugin, custom rules, usage cost, and disable/uninstall options
- [Sandboxing](references/claude-code-sandboxing.md) — Configure the sandboxed Bash tool: modes, filesystem/network isolation, OS-level enforcement, organization enforcement, and troubleshooting
- [Sandbox Environments](references/claude-code-sandbox-environments.md) — Compare isolation approaches (sandboxed Bash, sandbox runtime, dev containers, VMs, Claude Code on the web) and choose one for your threat model
- [Dev Container](references/claude-code-devcontainer.md) — Run Claude Code inside a Docker dev container for consistent, isolated environments across a team
- [Network Configuration](references/claude-code-network-config.md) — Proxy servers, custom CA certificates, mTLS, and required domain allowlist for enterprise environments
- [Data Usage](references/claude-code-data-usage.md) — Data training policies, retention periods, telemetry services, WebFetch domain safety check, and encryption at rest
- [Zero Data Retention](references/claude-code-zero-data-retention.md) — ZDR scope, features disabled under ZDR, HIPAA BAA coverage, and how to request enablement
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — License agreements, healthcare compliance (BAA), acceptable use policy, and security vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Security Guidance Plugin: https://code.claude.com/docs/en/security-guidance.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Sandbox Environments: https://code.claude.com/docs/en/sandbox-environments.md
- Dev Container: https://code.claude.com/docs/en/devcontainer.md
- Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
