---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, prompt injection protections, sandbox environments (built-in Bash sandbox, sandbox runtime, dev containers, custom containers, VMs), sandboxing configuration and OS-level enforcement, network configuration for enterprises (proxy, CA certs, mTLS), data usage and retention policies, zero data retention for Enterprise, and legal/compliance information.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, network configuration, data usage, and compliance.

## Quick Reference

### Permission-Based Architecture

Claude Code uses read-only permissions by default. Additional actions (editing files, running commands) require explicit approval. Key built-in protections:

| Protection | Description |
| :--- | :--- |
| Write access restriction | Can only write to the folder where started and its subfolders |
| Sandboxed Bash tool | Filesystem and network isolation for Bash commands via `/sandbox` |
| Accept Edits mode | Auto-approves file edits and safe filesystem Bash commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) within working directory |
| Prompt fatigue mitigation | Allowlist frequently-used safe commands per-user, per-codebase, or per-org |
| Command blocklist | Blocks `curl`, `wget`, and other commands that fetch arbitrary web content by default |
| Credential storage | API keys and tokens are encrypted |

### Prompt Injection Protections

| Safeguard | How it works |
| :--- | :--- |
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects harmful instructions by analyzing full request |
| Input sanitization | Prevents command injection from user inputs |
| Network request approval | Tools making network requests require user approval by default |
| Isolated context windows | WebFetch uses separate context window to avoid injecting malicious prompts |
| Trust verification | First-time codebase runs and new MCP servers require trust verification |
| Command injection detection | Suspicious Bash commands require manual approval even if previously allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Sandbox Environments Comparison

| Approach | What is isolated | Requires Docker | Setup effort |
| :--- | :--- | :--- | :--- |
| Sandboxed Bash tool (`/sandbox`) | Bash commands and child processes only | No | Minimal (macOS); Low (Linux/WSL2) |
| Sandbox runtime (`@anthropic-ai/sandbox-runtime`) | Entire Claude Code process (all tools, MCP, hooks) | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium–High |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, hosted by Anthropic | No | None (requires subscription + GitHub) |

**Choosing an approach:**

| Goal | Recommended approach |
| :--- | :--- |
| Reduce permission prompts on own machine | Sandboxed Bash tool (`/sandbox`) |
| Unattended run with `--dangerously-skip-permissions` or auto mode | Dev container, custom container/VM, or sandbox runtime |
| Isolate MCP servers and hooks too, without Docker | Sandbox runtime |
| Untrusted repository | Dedicated VM or Claude Code on the web |
| Standardize across a team | Dev container committed to repo |
| No local setup | Claude Code on the web |

### Sandboxed Bash Tool — Key Settings

Enable with `/sandbox`. Requires macOS, Linux, or WSL2 (not native Windows).

| Setting | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable/disable the sandbox |
| `sandbox.failIfUnavailable` | Hard-fail instead of warning when sandbox can't start |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default `true`) |
| `sandbox.filesystem.allowWrite` | Additional paths subprocess can write to |
| `sandbox.filesystem.denyWrite` | Block write access to specific paths |
| `sandbox.filesystem.denyRead` | Block read access to specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.allowedDomains` | Pre-allow specific network domains |
| `sandbox.deniedDomains` | Block domains even if a wildcard would allow them |
| `sandbox.allowManagedDomainsOnly` | Only honor domains from managed settings (org lockdown) |
| `sandbox.allowManagedReadPathsOnly` | Only honor `allowRead` from managed settings |
| `sandbox.excludedCommands` | Commands that always run outside the sandbox |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port for corporate inspection |
| `sandbox.network.socksProxyPort` | Custom SOCKS proxy port |
| `sandbox.enableWeakerNestedSandbox` | For unprivileged containers (weakens security) |

**Filesystem path prefix conventions:**

| Prefix | Resolves to |
| :--- | :--- |
| `/path` | Absolute path from filesystem root |
| `~/path` | Relative to home directory |
| `./path` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

**Sandbox modes:**
- **Auto-allow**: Sandboxed commands run without prompting. Deny rules and `rm` targeting `/` or home directory still prompt.
- **Regular permissions**: All Bash commands go through the regular permission flow even when sandboxed.

**Security limitations of the built-in sandbox:**
- Does not terminate or inspect TLS; broad domains (e.g., `github.com`) can allow data exfiltration via domain fronting
- Unix socket access (`allowUnixSockets`) can grant host system access (e.g., Docker socket)
- Broad `allowWrite` paths can enable privilege escalation
- By default, reads `~/.aws/credentials`, `~/.ssh/` — add to `denyRead` if needed
- `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` strips Anthropic/cloud credentials from subprocesses

**Linux/WSL2 setup:** Install `bubblewrap` and `socat`; Ubuntu 24.04+ may need AppArmor profile for bubblewrap.

### Sandbox Runtime

The `@anthropic-ai/sandbox-runtime` package wraps the entire Claude Code process (all tools, hooks, MCP servers) using the same Seatbelt/bubblewrap primitives. Configure via `~/.srt-settings.json`. Launch with:

```bash
npx @anthropic-ai/sandbox-runtime claude
```

Denies all write and network access by default — must explicitly allow `~/.claude`, `~/.claude.json`, project directory, and `api.anthropic.com`.

### Dev Container Configuration

Install via the [Claude Code Dev Container Feature](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code):

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

| Topic | Key detail |
| :--- | :--- |
| Persist auth across rebuilds | Mount named volume at `~/.claude`: `"source=claude-code-config,target=/home/node/.claude,type=volume"` |
| Managed policy | Copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` in Dockerfile |
| Disable telemetry in container | Set `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` in `containerEnv` |
| Pin Claude Code version | Install via `npm install -g @anthropic-ai/claude-code@X.Y.Z` in Dockerfile + `DISABLE_AUTOUPDATER=1` |
| Skip permission prompts | Pass `--dangerously-skip-permissions`; container must run as non-root |
| Network egress restriction | Use `init-firewall.sh` from reference container with `NET_ADMIN` + `NET_RAW` capabilities |

Reference container: `anthropics/claude-code` repo at `.devcontainer/`.

### Cloud Execution Security

| Control | Description |
| :--- | :--- |
| Isolated VMs | Each cloud session in an isolated, Anthropic-managed VM |
| Network access controls | Limited by default; configurable per domain |
| Credential protection | Secure proxy translates scoped sandbox credential to actual GitHub token |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All cloud operations logged |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions follow local data flow — all execution stays on your machine; Anthropic API traffic uses TLS.

### Enterprise Network Configuration

All network settings can be configured via environment variables or `settings.json`.

**Proxy:**

```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,192.168.1.1,.example.com"
```

Note: SOCKS proxies are not supported.

**CA Certificates:**

| Variable | Effect |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE=bundled,system` | Default: trust both bundled Mozilla CA set and OS trust store |
| `CLAUDE_CODE_CERT_STORE=bundled` | Trust only bundled Mozilla CA set |
| `CLAUDE_CODE_CERT_STORE=system` | Trust only OS certificate store |
| `NODE_EXTRA_CA_CERTS=/path/to/ca.pem` | Add custom enterprise CA |

**mTLS:**

```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="passphrase"
```

**Required network allowlist:**

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin executable downloads, native installer/auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed, plugin marketplace install counts |

When using Bedrock/Vertex/Foundry, model traffic goes to the provider instead of `api.anthropic.com`. WebFetch still calls `api.anthropic.com` for domain safety checks unless `skipWebFetchPreflight: true` is set.

### Data Usage and Retention

**Training policy:**

| Plan | Training default |
| :--- | :--- |
| Consumer (Free, Pro, Max) | Data used for training when setting is ON (user-controllable at claude.ai/settings/data-privacy-controls) |
| Commercial (Team, Enterprise, API) | Not used for training unless opted in (e.g., Development Partner Program) |

**Retention periods:**

| User type | Retention |
| :--- | :--- |
| Consumer (allows model improvement) | 5 years |
| Consumer (no model improvement) | 30 days |
| Commercial (standard) | 30 days |
| Enterprise with ZDR | Not retained after response returned |
| Local session transcripts | 30 days under `~/.claude/projects/` (configurable via `cleanupPeriodDays`) |
| `/feedback` transcripts | 5 years |
| Session quality survey transcripts (if shared) | Up to 6 months |

**Telemetry opt-out environment variables:**

| Variable | Effect |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Opt out of metrics (Anthropic API only — default on) |
| `DISABLE_ERROR_REPORTING=1` | Opt out of Sentry error logging (Anthropic API only — default on) |
| `DISABLE_FEEDBACK_COMMAND=1` | Opt out of `/feedback` command sending data |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Opt out of session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential traffic at once (except WebFetch preflight) |
| `DO_NOT_TRACK` | Also disables telemetry |

Bedrock, Vertex, Foundry, and Claude Platform on AWS have telemetry and error reporting **off by default**.

**WebFetch domain safety check:** Sends hostname (not full URL) to `api.anthropic.com` before fetching. Results cached 5 minutes per hostname. Disable with `skipWebFetchPreflight: true` in settings.

**Encryption at rest by provider:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 (infrastructure-level); ZDR = no server-side persistence |
| Amazon Bedrock | AES-256; customer-managed keys via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | AES-256 via Anthropic infrastructure |

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise only. Prompts and responses are not retained after the response is returned.

**Not covered by ZDR:**
- Chat on claude.ai
- Cowork sessions
- Claude Code Analytics (collects usage metadata but not prompts/responses)
- User/seat management data
- Third-party integrations

**Features disabled under ZDR:**
- Claude Code on the Web
- Remote sessions from Desktop app
- Feedback submission (`/feedback`)

ZDR is per-organization — each new organization must have it enabled separately by Anthropic account team.

### Legal and Compliance

| Topic | Detail |
| :--- | :--- |
| License (Team/Enterprise/API) | [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) |
| License (Free/Pro/Max) | [Consumer Terms of Service](https://www.anthropic.com/legal/consumer-terms) |
| Healthcare (BAA) | BAA auto-extends to Claude Code if customer has BAA + ZDR activated |
| OAuth authentication | For Free/Pro/Max/Team/Enterprise subscription holders only; not for routing third-party developer requests |
| API key authentication | Required for developers building products/services with the Agent SDK |
| Security vulnerability reporting | [HackerOne program](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new) |
| Trust Center | [trust.anthropic.com](https://trust.anthropic.com) (SOC 2 Type 2, ISO 27001, etc.) |

### Security Best Practices

**Working with sensitive code:**
- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repositories
- Use dev containers for additional isolation
- Audit permission settings with `/permissions`

**Team security:**
- Use managed settings to enforce organizational standards
- Share approved permission configurations through version control
- Monitor Claude Code usage with OpenTelemetry metrics
- Audit/block settings changes with `ConfigChange` hooks
- Report vulnerabilities via HackerOne (do not disclose publicly)

**Working with untrusted content:**
- Review suggested commands before approval
- Avoid piping untrusted content directly to Claude
- Verify proposed changes to critical files
- Use VMs for scripts interacting with external web services
- Use `/feedback` to report suspicious behavior

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission-based architecture, built-in protections, prompt injection safeguards, MCP security, cloud execution security, security best practices
- [Configure the sandboxed Bash tool](references/claude-code-sandboxing.md) — enabling the sandbox, sandbox modes (auto-allow vs. regular), filesystem and network isolation, permission interaction, org enforcement, troubleshooting
- [Choose a sandbox environment](references/claude-code-sandbox-environments.md) — comparison of all isolation approaches (sandboxed Bash, sandbox runtime, dev containers, custom containers, VMs, Claude Code on the web), choosing by use case, org enforcement
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in dev containers, persisting auth across rebuilds, enforcing org policy, restricting network egress, running without permission prompts, reference container
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate store, custom CA certs, mTLS, network allowlist requirements
- [Data usage](references/claude-code-data-usage.md) — training policy, data retention by plan, telemetry services and opt-out, WebFetch domain safety check, default behaviors by API provider, encryption at rest
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what is/isn't covered, features disabled under ZDR, requesting ZDR
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — legal agreements, healthcare BAA compliance, acceptable use policy, authentication/credential rules, security vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Configure the sandboxed Bash tool: https://code.claude.com/docs/en/sandboxing.md
- Choose a sandbox environment: https://code.claude.com/docs/en/sandbox-environments.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
