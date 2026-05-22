---
name: security-doc
description: Complete official documentation for Claude Code security — permission-based architecture, built-in protections, prompt injection safeguards, sandboxed Bash tool (filesystem/network isolation, sandbox modes, managed settings enforcement), sandbox environment comparison (sandboxed Bash tool, sandbox runtime, dev containers, custom containers, VMs, Claude Code on the web), dev containers (setup, policy enforcement, egress restriction, --dangerously-skip-permissions), enterprise network configuration (proxy, custom CA, mTLS, allowlist URLs), data usage policies (training, retention, telemetry opt-outs), zero data retention (ZDR scope, disabled features), and legal/compliance (BAA, acceptable use, authentication policies).
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security.

## Quick Reference

### Permission-Based Architecture

Claude Code uses **read-only permissions by default**. Additional actions (editing files, running commands) require explicit user approval. Users can approve once or allowlist commands permanently.

Key built-in protections:

| Protection | Description |
| :--- | :--- |
| Sandboxed Bash tool | OS-level filesystem and network isolation; enable with `/sandbox` |
| Write access restriction | Can only write to the folder where Claude Code was started and subfolders |
| Command allowlisting | Frequently used safe commands can be allowlisted per-user, per-codebase, or per-org |
| Accept Edits mode | Auto-approves file edits and safe filesystem commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) in scope |
| Command blocklist | `curl`, `wget` blocked by default to prevent fetching arbitrary web content |
| Credential encryption | API keys and tokens are encrypted at rest |

### Prompt Injection Safeguards

| Safeguard | How it works |
| :--- | :--- |
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Analyzes full request for harmful instructions |
| Input sanitization | Prevents command injection from user inputs |
| Network request approval | Network tools require user approval by default |
| Isolated WebFetch context | Separate context window prevents injecting malicious prompts |
| Trust verification | First-time codebase runs and new MCP servers require trust verification |
| Command injection detection | Suspicious commands require manual approval even if previously allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Sandbox Environments Comparison

| Approach | What is isolated | Requires Docker | Setup effort |
| :--- | :--- | :--- | :--- |
| Sandboxed Bash tool | Bash commands and child processes | No | Minimal (macOS); low (Linux/WSL2) |
| Sandbox runtime | Whole Claude Code process (Bash, file tools, MCP, hooks) | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium to high |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, hosted by Anthropic | No | None (requires subscription + GitHub) |

**Choosing an approach:**

| Goal | Recommended approach |
| :--- | :--- |
| Reduce permission prompts during everyday work | Sandboxed Bash tool (`/sandbox`) |
| Unattended runs with `--dangerously-skip-permissions` | Dev container, any container/VM, or sandbox runtime |
| Isolate MCP servers and hooks without Docker | Sandbox runtime |
| Work on an untrusted repository | Dedicated VM, or Claude Code on the web |
| Standardize environment across a team | Dev container (copy preconfigured example to repo) |
| Require isolation for every developer in org | Enforce via managed settings (Bash sandbox) or container/MDM policy |

### Sandboxed Bash Tool

Enable with `/sandbox`. Supported on macOS (Seatbelt), Linux, and WSL2 (bubblewrap + socat). Native Windows is not supported.

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without prompting; non-sandboxable commands fall back to normal permission flow |
| Regular permissions | All commands go through the normal permission flow, even when sandboxed |

**Key sandbox settings (`settings.json`):**

| Setting | Type | Description |
| :--- | :--- | :--- |
| `sandbox.enabled` | boolean | Enable the sandbox |
| `sandbox.failIfUnavailable` | boolean | Hard-fail if sandbox cannot initialize (for managed deployments) |
| `sandbox.allowUnsandboxedCommands` | boolean | Allow retry outside sandbox when sandboxed run fails (default true) |
| `sandbox.filesystem.allowWrite` | string[] | Additional paths commands may write to |
| `sandbox.filesystem.denyWrite` | string[] | Paths to block from writing |
| `sandbox.filesystem.denyRead` | string[] | Paths to block from reading |
| `sandbox.filesystem.allowRead` | string[] | Re-allow specific reads within a denyRead region |
| `sandbox.allowedDomains` | string[] | Pre-allowed network domains (no prompt) |
| `sandbox.deniedDomains` | string[] | Blocked domains even when a wildcard would permit |
| `sandbox.excludedCommands` | string[] | Commands that always run outside the sandbox |
| `sandbox.allowManagedDomainsOnly` | boolean | Ignore user/project domain additions; only honor managed allowedDomains |
| `sandbox.allowManagedReadPathsOnly` | boolean | Ignore user/project allowRead additions; only honor managed values |
| `sandbox.network.httpProxyPort` | number | Custom proxy HTTP port |
| `sandbox.network.socksProxyPort` | number | Custom proxy SOCKS port |
| `sandbox.enableWeakerNestedSandbox` | boolean | Use bind-mounted /proc for Docker environments (weakens security) |
| `sandbox.enableWeakerNetworkIsolation` | boolean | For MITM proxy with custom CA on macOS |

**Sandbox path prefix conventions:**

| Prefix | Resolves to |
| :--- | :--- |
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

**Default filesystem behavior:**
- Write: only the working directory and subdirectories
- Read: entire system except explicitly denied paths (including `~/.aws/credentials`, `~/.ssh/` by default — add to `denyRead` to block)

**Managed org enforcement:**
```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false
  }
}
```

**Linux/WSL2 setup:** Install `bubblewrap` and `socat`. On Ubuntu 24.04+, may need AppArmor profile for bwrap. Optionally install `npm install -g @anthropic-ai/sandbox-runtime` for seccomp Unix socket blocking.

**Sandbox runtime** (`@anthropic-ai/sandbox-runtime`): wraps the entire Claude Code process, covering file tools, MCP servers, and hooks — not just Bash. Beta research preview. Configure `~/.srt-settings.json` then run `npx @anthropic-ai/sandbox-runtime claude`.

**Scope limitations of the Bash sandbox:** Built-in tools (Read, Edit, WebFetch) and MCP servers run on the host, not through the Bash sandbox. Use the sandbox runtime, dev container, or VM to cover those.

### Dev Containers

Add Claude Code via the [Dev Container Feature](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code):

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

**Persist auth across rebuilds:** Mount a named volume at `~/.claude`:
```json
"mounts": ["source=claude-code-config,target=/home/node/.claude,type=volume"]
```

**Enforce org policy:** Copy managed settings into `/etc/claude-code/managed-settings.json` from Dockerfile. For bypass-proof policy, use server-managed settings or MDM.

**Restrict network egress:** Use `init-firewall.sh` pattern from the reference container. Requires `NET_ADMIN` and `NET_RAW` capabilities via `runArgs`.

**Run without permission prompts:** Use `--dangerously-skip-permissions` when container runs as non-root. CLI rejects this flag when running as root. Pair with network egress restrictions.

### Enterprise Network Configuration

**Proxy environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `HTTPS_PROXY` | Route traffic through corporate proxy |
| `HTTP_PROXY` | Fallback if HTTPS proxy unavailable |
| `NO_PROXY` | Bypass proxy (space- or comma-separated) |

Note: SOCKS proxies are not supported.

**CA certificates:**

| Setting | Description |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE=bundled,system` | Default: trust both Mozilla bundled CA and OS store |
| `CLAUDE_CODE_CERT_STORE=bundled` | Trust only Mozilla bundled CA |
| `CLAUDE_CODE_CERT_STORE=system` | Trust only OS certificate store |
| `NODE_EXTRA_CA_CERTS=/path/to/ca.pem` | Trust a custom enterprise CA |

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
| `platform.claude.com` | Anthropic Console account authentication |
| `downloads.claude.ai` | Plugin downloads, native installer/updater |
| `bridge.claudeusercontent.com` | Claude in Chrome WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed, release notes, marketplace counts |

When using Bedrock, Vertex, or Foundry, model traffic goes to those providers instead of `api.anthropic.com`. WebFetch still calls `api.anthropic.com` for domain safety checks unless `skipWebFetchPreflight: true` is set.

### Data Usage and Telemetry

**Training policy:**

| User type | Training default |
| :--- | :--- |
| Consumer (Free/Pro/Max) | Data used for model improvement when setting is on |
| Commercial (Team/Enterprise/API) | Not trained on by default unless opted in (e.g., Developer Partner Program) |

**Data retention:**

| User type | Retention |
| :--- | :--- |
| Consumer (allows training) | 5 years |
| Consumer (disallows training) | 30 days |
| Commercial (standard) | 30 days |
| Commercial (ZDR) | No server-side persistence after response returned |
| Local session transcripts | 30 days in `~/.claude/projects/` (configurable via `cleanupPeriodDays`) |
| Feedback via `/feedback` | 5 years |
| Session transcript shared via quality survey | Up to 6 months |

**Encryption at rest:**

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption (ZDR = no server-side persistence) |
| Amazon Bedrock | AES-256, AWS-managed or CMEK via KMS |
| Google Cloud Vertex AI | Google-managed keys, CMEK available |
| Microsoft Foundry | AES-256 via Anthropic infrastructure |

**Telemetry opt-out environment variables:**

| Variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Operational metrics sent to Anthropic |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command sending transcripts to Anthropic |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | All non-essential traffic at once (not WebFetch check) |
| `DO_NOT_TRACK` | Same as `DISABLE_TELEMETRY` |

Note: Telemetry, Sentry, and `/feedback` are **off by default** for Bedrock, Vertex, Foundry, and Claude Platform on AWS. Session quality surveys and WebFetch domain safety check are **on** for all providers regardless.

**WebFetch domain safety check:** Sends only the hostname (not full URL) to `api.anthropic.com` before fetching. Results cached per hostname for 5 minutes. Disable with `skipWebFetchPreflight: true` in settings.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. Prompts and responses are not stored after response is returned (except for law/misuse compliance).

**ZDR does not cover:**

| Feature | Notes |
| :--- | :--- |
| Chat on claude.ai | Follows standard retention |
| Cowork sessions | Follows standard retention |
| Claude Code Analytics | Collects productivity metadata (not prompts), no contribution metrics |
| User/seat management | Administrative data retained under standard policies |
| Third-party integrations | Review each service's policies independently |

**Features disabled under ZDR:**

| Feature | Reason |
| :--- | :--- |
| Claude Code on the web | Requires server-side conversation history storage |
| Remote sessions from Desktop | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

ZDR is enabled per-organization. Each new org must have ZDR enabled separately by the Anthropic account team. Policy violations may result in retention of inputs/outputs for up to 2 years.

### Legal and Compliance

**License:** Commercial Terms (Team/Enterprise/API) or Consumer Terms (Free/Pro/Max).

**Healthcare (BAA):** BAA automatically extends to Claude Code when the customer has an active BAA and ZDR enabled. Per-organization — each org must have ZDR enabled separately.

**Authentication policy:**
- **OAuth** is for subscription plan users (Free/Pro/Max/Team/Enterprise) for personal use of Claude Code
- **API key** required for developers building products/services with the Agent SDK
- Third-party developers cannot route requests through Free/Pro/Max plan credentials on behalf of their users

**Reporting vulnerabilities:** Use the [HackerOne program](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new). Do not disclose publicly; allow time to fix before public disclosure.

### Cloud Execution Security (Claude Code on the web)

| Control | Description |
| :--- | :--- |
| Isolated VMs | Each session runs in an isolated, Anthropic-managed VM |
| Network access controls | Limited by default; configurable to disable or allow specific domains |
| Credential protection | Auth handled via secure proxy; scoped credential inside sandbox, never the actual GitHub token |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions differ: web interface connects to Claude Code on your local machine; no cloud VMs or sandboxing involved. Connection uses multiple short-lived, narrowly scoped credentials.

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission-based architecture, built-in protections, prompt injection safeguards, MCP/IDE/cloud security, best practices, and vulnerability reporting
- [Configure the sandboxed Bash tool](references/claude-code-sandboxing.md) — enabling the sandbox, sandbox modes, filesystem/network isolation, sandbox settings, org enforcement, custom proxy, and troubleshooting
- [Choose a sandbox environment](references/claude-code-sandbox-environments.md) — comparison of all isolation approaches (sandboxed Bash tool, sandbox runtime, dev containers, custom containers, VMs, Claude Code on the web), how isolation relates to permission modes, and org enforcement
- [Development containers](references/claude-code-devcontainer.md) — installing Claude Code in a dev container, persisting auth, enforcing org policy, restricting network egress, and running without permission prompts
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificate store, custom CA, mTLS, network allowlist URLs
- [Data usage](references/claude-code-data-usage.md) — training policies, data retention by account type, encryption at rest, telemetry services, opt-out variables, WebFetch domain safety check
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what it covers and does not cover, features disabled under ZDR, requesting ZDR
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, BAA/healthcare compliance, acceptable use policy, authentication restrictions, security and trust resources

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Configure the sandboxed Bash tool: https://code.claude.com/docs/en/sandboxing.md
- Choose a sandbox environment: https://code.claude.com/docs/en/sandbox-environments.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
