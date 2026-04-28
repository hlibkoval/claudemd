---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, sandboxing (filesystem and network isolation), prompt injection protections, dev containers, enterprise network config (proxy/CA/mTLS), data usage and retention policies, zero data retention, and legal/compliance information.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, isolation, data handling, and compliance.

## Quick Reference

### Security architecture overview

| Layer | What it covers |
| :--- | :--- |
| **Permission system** | Which tools Claude can use; requires explicit approval per tool call |
| **Sandboxing** | OS-level filesystem and network isolation for Bash commands |
| **Prompt injection mitigations** | Command blocklist, context-aware analysis, isolated web fetch context |
| **Data policies** | Retention periods, training opt-out, ZDR |
| **Enterprise network** | Proxy, custom CA, mTLS, firewall allowlist |

---

### Permission-based architecture

- **Default**: read-only; all other actions require explicit user approval.
- **Write scope**: Claude Code can only write to the working directory and subfolders (not parent directories).
- **Allowlisting**: frequently used safe commands can be allowlisted per-user, per-project, or per-org.
- **Accept Edits mode**: batch-accept file edits while keeping prompts for commands with side effects.

---

### Sandboxing

Enable with `/sandbox` (macOS: built-in Seatbelt; Linux/WSL2: bubblewrap + socat).

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| **Auto-allow** | Sandboxed commands run without approval prompts; unsandboxable commands fall back to normal flow |
| **Regular permissions** | All commands still require explicit approval even inside sandbox |

**Key sandbox settings (`settings.json`):**

| Key | Purpose |
| :--- | :--- |
| `sandbox.enabled` | Enable sandbox |
| `sandbox.filesystem.allowWrite` | Extra write paths (merged across settings scopes) |
| `sandbox.filesystem.denyWrite` | Block write access to paths |
| `sandbox.filesystem.denyRead` | Block read access to paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.allowedDomains` | Domains Bash commands can reach |
| `sandbox.network.deniedDomains` | Block specific domains within a broader wildcard |
| `sandbox.network.allowManagedDomainsOnly` | Silently block all non-allowed domains |
| `sandbox.failIfUnavailable` | Hard-fail if sandbox cannot start (for managed deployments) |
| `allowUnsandboxedCommands` | Set `false` to disable the `dangerouslyDisableSandbox` escape hatch |
| `sandbox.network.httpProxyPort` / `socksProxyPort` | Custom inspection proxy |

**Path prefix conventions for sandbox filesystem rules:**

| Prefix | Resolves to |
| :--- | :--- |
| `/path` | Absolute filesystem path |
| `~/path` | Relative to home directory |
| `./path` or no prefix | Relative to project root (in project settings) or `~/.claude` (in user settings) |

**What sandboxing does NOT cover**: built-in Read/Edit/Write tools (those use the permission system); computer use.

**Security limitations to be aware of:**
- Network filtering restricts domains but does not inspect traffic content (domain fronting possible).
- `allowUnixSockets` can grant access to powerful system services (e.g. Docker socket).
- Overly broad `allowWrite` paths (shell config files, `$PATH` directories) can enable privilege escalation.
- `enableWeakerNestedSandbox` (Linux inside Docker without privileged namespaces) considerably weakens isolation.

**Open source sandbox runtime:**

```bash
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

---

### Prompt injection protections

| Safeguard | Detail |
| :--- | :--- |
| Permission system | Sensitive operations always require explicit approval |
| Command blocklist | `curl`, `wget`, and similar commands blocked by default |
| Isolated web fetch context | Web fetch runs in a separate context window |
| Trust verification | New codebases and MCP servers require trust confirmation (disabled with `-p`) |
| Command injection detection | Suspicious bash commands escalate to manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring approval |
| Natural language descriptions | Complex bash commands show explanations before approval |
| Secure credential storage | API keys/tokens encrypted at rest |

**Windows warning**: Do not enable WebDAV or allow paths like `\\*` — deprecated by Microsoft and may allow network requests that bypass the permission system.

**Best practices for untrusted content:**
1. Review suggested commands before approval.
2. Avoid piping untrusted content directly to Claude.
3. Verify proposed changes to critical files.
4. Use VMs for scripts and tool calls involving external web services.
5. Report suspicious behavior with `/feedback`.

---

### Cloud execution security

| Control | Detail |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in an Anthropic-managed VM |
| Network access | Limited by default; configurable per-session |
| Credential protection | GitHub auth via secure proxy; scoped credential inside sandbox |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All cloud operations logged |
| Automatic cleanup | VM terminated after session completes |

**Remote Control** sessions differ: execution stays on your local machine; no cloud VMs or sandboxing involved. Multiple short-lived, narrowly-scoped credentials limit blast radius.

---

### MCP security

- Allowed MCP servers configured in source-controlled settings.
- Anthropic does not manage or audit third-party MCP servers — only use servers you trust.

---

### Dev containers

Dev containers run Claude Code in an isolated Docker environment; commands execute inside the container; file edits appear in the host repository.

**Install via devcontainer.json:**

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

**Key configuration patterns:**

| Goal | Mechanism |
| :--- | :--- |
| Persist auth/settings across rebuilds | Named volume at `~/.claude` |
| Enforce organization policy | `managed-settings.json` at `/etc/claude-code/` (via Dockerfile COPY) |
| Disable telemetry and auto-update | `containerEnv: { CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1", DISABLE_AUTOUPDATER: "1" }` |
| Restrict network egress | `init-firewall.sh` script + `NET_ADMIN`/`NET_RAW` capabilities in `runArgs` |
| Run without permission prompts | `--dangerously-skip-permissions` (non-root user only) |

**Warning**: `--dangerously-skip-permissions` does not prevent file exfiltration from within the container. Only use with trusted repositories and pair with network egress restrictions. Avoid mounting host secrets (`~/.ssh`, cloud credentials) into containers.

---

### Enterprise network configuration

All variables below can also be set in `settings.json` under the `env` key.

**Proxy:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | Route traffic through HTTPS proxy |
| `HTTP_PROXY` | Fallback if HTTPS proxy unavailable |
| `NO_PROXY` | Comma- or space-separated bypass list (`*` to bypass all) |

Note: SOCKS proxies are not supported. For NTLM/Kerberos auth, use an LLM Gateway service.

**CA certificates:**

| Variable / Setting | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE=bundled,system` | Default: trust both Mozilla bundle and OS store |
| `CLAUDE_CODE_CERT_STORE=bundled` | Trust only Mozilla bundle |
| `CLAUDE_CODE_CERT_STORE=system` | Trust only OS certificate store |
| `NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem` | Trust a custom enterprise CA (required on Node.js runtime) |

**mTLS:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate PEM |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key PEM |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads, native installer/auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |

When using Bedrock/Vertex/Foundry, model traffic goes to your provider instead of `api.anthropic.com`. WebFetch still contacts `api.anthropic.com` for domain safety checks unless `skipWebFetchPreflight: true` is set.

---

### Data usage and retention

**Training policy:**

| User type | Default training use |
| :--- | :--- |
| Consumer (Free, Pro, Max) | On by default; toggle at claude.ai/settings/data-privacy-controls |
| Commercial (Team, Enterprise, API) | Off by default; opt-in via Developer Partner Program only |

**Retention periods:**

| User type | Period |
| :--- | :--- |
| Consumer — allows training | 5 years |
| Consumer — disallows training | 30 days |
| Commercial — standard | 30 days |
| Commercial — ZDR | No server-side storage after response (see ZDR section) |
| Local session transcripts | 30 days (configurable via `cleanupPeriodDays`); stored at `~/.claude/projects/` |
| Feedback via `/feedback` | 5 years |
| Session transcript uploaded after quality survey | Up to 6 months |

**Telemetry opt-out environment variables:**

| Variable | What it disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Statsig operational metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality survey |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | All of the above (except WebFetch domain check) |

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR for no server-side persistence |
| Amazon Bedrock | AES-256, AWS-managed keys; CMEK via AWS KMS |
| Google Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | AES-256 disk encryption via Anthropic infrastructure |

**WebFetch domain safety check**: before fetching, the hostname is sent to `api.anthropic.com` for blocklist lookup (hostname only, not full URL). Results cached 5 minutes per hostname. Disable with `skipWebFetchPreflight: true` in settings.

---

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only (not Bedrock, Vertex, or Foundry).

- Prompts and responses are not stored after the response is returned.
- Enabled per-organization; each new org must be enabled separately by your Anthropic account team.
- Automatically extends to cover HIPAA BAA (if a BAA is already in place).

**Features disabled under ZDR:**

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side conversation history |
| Remote sessions from Desktop | Requires persistent session data |
| Feedback submission (`/feedback`) | Sends conversation data to Anthropic |

**What ZDR does not cover** (follows standard retention):
- Chat on claude.ai, Cowork sessions, Analytics (productivity metadata), user/seat management, third-party integrations.

**Policy violation exception**: Anthropic may retain flagged inputs/outputs for up to 2 years.

To request ZDR: contact sales or your Anthropic account team.

---

### Legal and compliance

| Topic | Detail |
| :--- | :--- |
| Commercial users | Subject to [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| Consumer users | Subject to [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) |
| HIPAA/BAA | Automatically extends to Claude Code if BAA + ZDR are both active |
| Acceptable use | Subject to [Anthropic Usage Policy](https://www.anthropic.com/legal/aup) |
| OAuth authentication | For purchasers of Claude subscription plans only; developers must use API keys |
| Security vulnerability reporting | Via [HackerOne program](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new) |
| Trust Center / compliance certs | [trust.anthropic.com](https://trust.anthropic.com) (SOC 2 Type 2, ISO 27001, etc.) |

---

### Team security best practices

| Concern | Recommendation |
| :--- | :--- |
| Sensitive repositories | Use project-specific permission settings; consider dev containers |
| Organizational standards | Use managed settings to enforce; share via version control |
| Usage monitoring | OpenTelemetry metrics (`/en/monitoring-usage`) |
| Audit settings changes | `ConfigChange` hooks |
| Reporting vulnerabilities | Do not disclose publicly; use HackerOne |

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, built-in protections, prompt injection safeguards, MCP and IDE security, cloud execution security, and team best practices
- [Sandboxing](references/claude-code-sandboxing.md) — how filesystem and network isolation works, sandbox modes, configuration reference, security benefits and limitations, and relation to permissions
- [Development containers](references/claude-code-devcontainer.md) — adding Claude Code to a dev container, persisting auth, enforcing org policy, restricting network egress, and running without permission prompts
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate configuration, mTLS authentication, and required network allowlist
- [Data usage](references/claude-code-data-usage.md) — training policies, retention periods, telemetry services and opt-outs, encryption at rest, WebFetch domain safety check, and cloud execution data flow
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, features disabled under ZDR, what ZDR does not cover, and how to request enablement
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, commercial agreements, HIPAA BAA, acceptable use policy, and authentication rules

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
