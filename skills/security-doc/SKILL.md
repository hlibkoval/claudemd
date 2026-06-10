---
name: security-doc
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, data privacy, network configuration, compliance, and the security guidance plugin.

## Quick Reference

### Permission-Based Architecture

| Default behavior | Details |
| :--- | :--- |
| Read-only by default | Claude Code requests explicit permission for edits, commands, and file changes |
| Write scope limited | Can only write to the folder where Claude Code was started and subfolders |
| Allowlisting | Frequently used safe commands can be allowlisted per-user, per-codebase, or per-org |
| Accept Edits mode | Auto-approves file edits and a fixed set of filesystem Bash commands in the working directory |

### Built-in Sandboxed Bash Tool

Enable with `/sandbox` in a session. Stores config in `.claude/settings.local.json` (project) or `~/.claude/settings.json` (user).

| Platform | Sandboxing mechanism | Setup |
| :--- | :--- | :--- |
| macOS | Seatbelt (built-in) | None |
| Linux / WSL2 | bubblewrap + socat | `sudo apt-get install bubblewrap socat` |
| Native Windows | Not supported | Use WSL2 or container |

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without prompting; unsandboxed fall back to regular permission flow |
| Regular permissions | All commands prompt even when sandboxed |

**Key sandbox settings (`settings.json`):**

| Key | Effect |
| :--- | :--- |
| `sandbox.enabled` | Enable/disable the sandbox |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot initialize (for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | Set `false` to enforce strict mode (no `dangerouslyDisableSandbox` escape hatch) |
| `sandbox.filesystem.allowWrite` | Grant write access to additional paths |
| `sandbox.filesystem.denyRead` / `denyWrite` | Block access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.allowedDomains` | Pre-allow network domains for Bash commands |
| `sandbox.network.deniedDomains` | Block specific domains even within a broader allowlist |
| `sandbox.excludedCommands` | Commands that always run outside the sandbox |
| `allowManagedReadPathsOnly` | Lock `allowRead` to managed-settings values only |
| `allowManagedDomainsOnly` | Lock network domains to managed-settings values only |

**Filesystem path prefix conventions (sandbox settings only):**

| Prefix | Resolves to |
| :--- | :--- |
| `/` | Absolute path |
| `~/` | Home directory |
| `./` or no prefix | Project root (project settings) or `~/.claude` (user settings) |

**Common troubleshooting:**

| Problem | Fix |
| :--- | :--- |
| `jest` hangs | Run `jest --no-watchman` |
| `docker` fails | Add `docker *` to `excludedCommands` |
| Go CLIs fail TLS on macOS | List in `excludedCommands` or use `enableWeakerNetworkIsolation: true` with MITM proxy |
| bubblewrap fails inside container | Set `enableWeakerNestedSandbox: true` (weakens security) |
| Ubuntu 24.04 bubblewrap error | Add AppArmor profile for `bwrap` and reload AppArmor |

### Sandbox Environments Comparison

| Approach | Isolates | Requires Docker | Setup |
| :--- | :--- | :--- | :--- |
| Sandboxed Bash tool | Bash commands and child processes only | No | Minimal |
| Sandbox runtime (`@anthropic-ai/sandbox-runtime`) | Entire Claude Code process (tools, MCP, hooks) | No | Low |
| Dev container | Full dev environment | Yes | Medium |
| Custom container | Full dev environment | Yes | Medium–high |
| Virtual machine | Full OS | No | High |
| Claude Code on the web | Full OS (Anthropic-managed) | No | None (needs subscription + GitHub) |

Use `npx @anthropic-ai/sandbox-runtime claude` to launch Claude Code through the sandbox runtime.

### Dev Container Quick Setup

```json
// .devcontainer/devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

Persist `~/.claude` across rebuilds with a named volume:

```json
"mounts": ["source=claude-code-config,target=/home/node/.claude,type=volume"]
```

Managed settings path inside container: `/etc/claude-code/managed-settings.json`

To run unattended: use `--dangerously-skip-permissions` with a non-root user (`remoteUser` set accordingly). Pair with network egress restrictions.

### Prompt Injection Protections

- Sensitive operations require explicit approval
- Network commands (`curl`, `wget`) are not auto-approved by default
- Web fetch uses an isolated context window
- New codebases and MCP servers require trust verification on first run
- Command injection detection: suspicious commands require manual approval even if allowlisted
- Unmatched commands default to requiring manual approval (fail-closed)
- Credentials stored in macOS Keychain (macOS) or file-permission-protected storage (Linux/Windows)

### Enterprise Network Configuration

| Env var | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` / `HTTP_PROXY` | Route traffic through corporate proxy |
| `NO_PROXY` | Bypass proxy (space- or comma-separated) |
| `NODE_EXTRA_CA_CERTS` | Trust a custom CA certificate |
| `CLAUDE_CODE_CERT_STORE` | `bundled`, `system`, or `bundled,system` (default) |
| `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

SOCKS proxies are not supported.

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads and auto-updater |
| `raw.githubusercontent.com` | Changelog feed and release notes |
| `bridge.claudeusercontent.com` | Claude in Chrome extension |

### Data Usage and Telemetry

**Training policy:**
- Consumer (Free/Pro/Max): data may be used for model training unless opted out at `claude.ai/settings/data-privacy-controls`
- Commercial (Team/Enterprise/API): Anthropic does not train on data unless customer opts in (e.g., Developer Partner Program)

**Data retention:**

| Account type | Default retention |
| :--- | :--- |
| Consumer (training on) | 5 years |
| Consumer (training off) | 30 days |
| Commercial | 30 days |
| ZDR (Enterprise) | No server-side retention after response |

Local session transcripts: stored under `~/.claude/projects/` for 30 days by default (adjust with `cleanupPeriodDays`).

**Telemetry opt-out environment variables:**

| Variable | Effect |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Disable operational metrics (Anthropic) |
| `DISABLE_ERROR_REPORTING=1` | Disable error logging (Sentry) |
| `DISABLE_FEEDBACK_COMMAND=1` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable all non-essential traffic at once |
| `skipWebFetchPreflight: true` (settings) | Disable WebFetch domain safety check |

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR available |
| Amazon Bedrock | AES-256; CMEK via AWS KMS |
| Google Vertex AI | Google-managed; CMEK available |
| Microsoft Foundry | AES-256 via Anthropic infrastructure |

### Zero Data Retention (ZDR)

- Available to qualified accounts on Claude for Enterprise (not included in standard plan)
- Prompts and responses not retained after response is returned
- Must be enabled per-organization by Anthropic account team
- Features disabled under ZDR: Claude Code on the Web, Desktop cloud sessions, `/feedback`
- Models requiring data retention (e.g., Claude Fable 5) are unavailable under ZDR
- Contact sales or account team to request ZDR

### Security Guidance Plugin

Install: `/plugin install security-guidance@claude-plugins-official` then `/reload-plugins`

The plugin reviews Claude's own code changes for vulnerabilities at three layers:

| Layer | Trigger | Depth | Cost |
| :--- | :--- | :--- | :--- |
| Per-edit pattern check | Each file write | Pattern match (no model call) | None |
| End-of-turn diff review | After each turn | Model review of full turn diff | Model usage |
| Commit/push review | `git commit` or `git push` by Claude | Agentic review with surrounding code | Model usage |

**Custom rules:**
- `.claude/claude-security-guidance.md` — plain-language guidance for model-backed reviews
- `.claude/security-patterns.yaml` (or `.json`) — regex/substring patterns for per-edit checks

**Disable individual layers:**

| Variable | Effect |
| :--- | :--- |
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit/push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable the plugin entirely |

### Compliance and Legal

- SOC 2 Type 2, ISO 27001: see [Anthropic Trust Center](https://trust.anthropic.com)
- Healthcare (BAA): requires ZDR; extends automatically once both are active
- Commercial terms apply to Team/Enterprise/API users; Consumer Terms to Free/Pro/Max
- Report vulnerabilities via [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new)

### Security Best Practices

- Use dev containers or VMs for untrusted code
- Audit permission settings with `/permissions`
- Use managed settings to enforce org-wide standards
- Monitor usage with OpenTelemetry
- Audit settings changes with `ConfigChange` hooks
- Never enable WebDAV on Windows when using Claude Code

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Permission architecture, prompt injection protections, MCP/IDE/cloud security, and best practices
- [Sandboxing](references/claude-code-sandboxing.md) — Sandboxed Bash tool setup, modes, filesystem/network configuration, org enforcement, and limitations
- [Development Containers](references/claude-code-devcontainer.md) — Installing Claude Code in dev containers, org policy enforcement, network egress, and unattended operation
- [Network Configuration](references/claude-code-network-config.md) — Proxy setup, CA certificates, mTLS, and required network allowlist
- [Data Usage](references/claude-code-data-usage.md) — Training policies, data retention, telemetry services, and WebFetch domain safety check
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — License terms, BAA/healthcare compliance, authentication policy, and trust resources
- [Zero Data Retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, model availability, and how to request ZDR
- [Sandbox Environments](references/claude-code-sandbox-environments.md) — Comparison of all isolation approaches and guidance for choosing one
- [Security Guidance Plugin](references/claude-code-security-guidance.md) — In-session vulnerability detection, custom rules, usage cost, and integration with other security tools

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
- Sandbox Environments: https://code.claude.com/docs/en/sandbox-environments.md
- Security Guidance Plugin: https://code.claude.com/docs/en/security-guidance.md
