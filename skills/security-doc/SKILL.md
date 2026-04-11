---
name: security-doc
description: Complete documentation for Claude Code security — permission architecture, sandboxing (filesystem and network isolation), devcontainers, enterprise network configuration (proxies, CAs, mTLS), data usage and retention policies, Zero Data Retention (ZDR), and legal and compliance information. Covers prompt injection protections, cloud execution security, and best practices for working with sensitive code.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, devcontainers, enterprise network configuration, data usage, zero data retention, and legal/compliance.

## Quick Reference

### Security architecture

Claude Code uses a **permission-based architecture** with strict read-only defaults. Writing, editing, and command execution require explicit approval. Core protections:

| Protection | Description |
| :--- | :--- |
| Sandboxed bash tool | OS-level filesystem and network isolation via `/sandbox` |
| Write access restriction | Writes confined to the startup folder and its subfolders |
| Command blocklist | Blocks risky commands that fetch web content (curl, wget) by default |
| Network request approval | Network-accessing tools require approval by default |
| Isolated context windows | Web fetch uses a separate context window to prevent injection |
| Trust verification | First-time codebases and new MCP servers require trust verification |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to manual approval |
| Secure credential storage | API keys and tokens are encrypted |

**Windows WebDAV warning**: Avoid enabling WebDAV or allowing access to `\\*` paths — WebDAV can bypass the permission system.

**Trust verification is disabled** when running non-interactively with `-p`.

### Sandboxing

The sandboxed bash tool provides OS-level filesystem and network isolation, reducing permission prompts while maintaining security. Enable with `/sandbox`.

**OS enforcement**:

| Platform | Mechanism |
| :--- | :--- |
| macOS | Seatbelt (built-in, no setup) |
| Linux | bubblewrap (`apt-get install bubblewrap socat` / `dnf install bubblewrap socat`) |
| WSL2 | bubblewrap (WSL1 not supported) |
| Windows (native) | Planned |

**Sandbox modes**:

- **Auto-allow**: Sandboxed bash commands run without permission prompts. Commands that cannot be sandboxed fall back to regular permission flow. Works independently of "accept edits" mode.
- **Regular permissions**: All bash commands go through the standard permission flow, even when sandboxed.

**Filesystem defaults**:

- Writes: current working directory and subdirectories only
- Reads: entire computer except denied paths
- Extend via `sandbox.filesystem.allowWrite`; restrict via `denyWrite` / `denyRead`; re-allow via `allowRead`

Paths from multiple settings scopes are **merged**, not replaced. `allowRead` takes precedence over `denyRead`.

**Path prefix resolution**:

| Prefix | Meaning | Example |
| :--- | :--- | :--- |
| `/` | Absolute path | `/tmp/build` stays `/tmp/build` |
| `~/` | Home directory | `~/.kube` becomes `$HOME/.kube` |
| `./` or none | Project root (project settings) or `~/.claude` (user settings) | `./output` resolves to `<project-root>/output` |

The older `//path` prefix still works for absolute paths. Sandbox path syntax **differs** from `Read`/`Edit` permission rules (which use `//` for absolute and `/` for project-relative).

**Example — block home but allow project**:

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "denyRead": ["~/"],
      "allowRead": ["."]
    }
  }
}
```

**Network isolation**: Proxy server outside the sandbox; only approved domains reachable. New domain requests prompt unless `allowManagedDomainsOnly` is set. Custom proxy ports configurable via `sandbox.network.httpProxyPort` and `socksProxyPort`.

**Hard failure mode**: Set `sandbox.failIfUnavailable: true` to fail instead of running unsandboxed.

**Escape hatch**: When a sandboxed command fails, Claude may retry with `dangerouslyDisableSandbox` (requires user permission). Disable entirely with `"allowUnsandboxedCommands": false`.

**Known incompatibilities**: `watchman` (use `jest --no-watchman`), `docker` (add `docker *` to `excludedCommands`).

**Sandbox limitations**:

- Network filtering allows broad domains like `github.com`, which can enable exfiltration or domain fronting
- `allowUnixSockets` can bypass sandbox (e.g., `/var/run/docker.sock` grants host access)
- Broad filesystem writes (to `$PATH`, shell rc files) enable privilege escalation
- Linux `enableWeakerNestedSandbox` mode considerably weakens security; use only with other isolation

**What sandboxing does NOT cover**: Built-in Read/Edit/Write tools (use permissions directly), computer use (runs on real desktop with per-app prompts).

### Open source

The sandbox runtime is available as `@anthropic-ai/sandbox-runtime` on npm:

```bash
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

Source: [sandbox-runtime on GitHub](https://github.com/anthropic-experimental/sandbox-runtime).

### Prompt injection defenses

Best practices for untrusted content:

1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs when interacting with external web services
5. Report suspicious behavior with `/feedback`

### Cloud execution security

Claude Code on the web runs each session in an isolated Anthropic-managed VM. Network access is limited by default; credentials go through a secure proxy (scoped sandbox credential translated to actual GitHub token); git push is restricted to the current branch; all operations audit-logged; VMs auto-terminated after the session.

**Remote Control** differs: the web UI connects to a local Claude Code process. Execution stays local, traffic flows through the Anthropic API over TLS, credentials are short-lived and narrowly scoped.

### Devcontainer

Reference [devcontainer setup](https://github.com/anthropics/claude-code/tree/main/.devcontainer) with Node.js 20, custom firewall, git/ZSH/fzf, VS Code integration. Works with the VS Code Dev Containers extension.

**Enables `claude --dangerously-skip-permissions`** for unattended operation. Warning: does not prevent malicious projects from exfiltrating anything accessible inside the container (including Claude Code credentials). Use only with trusted repositories.

Three config files: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`. Firewall default-denies outbound except whitelisted domains (npm, GitHub, Claude API) plus DNS and SSH.

Setup: install VS Code + Dev Containers extension, clone the reference repo, open in VS Code, click "Reopen in Container".

### Enterprise network configuration

**Proxy environment variables** (also settable via `settings.json`):

```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,192.168.1.1,example.com,.example.com"
export NO_PROXY="*"  # bypass for all
```

SOCKS proxies are **not supported**. For NTLM/Kerberos, use an LLM Gateway.

Basic auth: `HTTPS_PROXY=http://user:pass@proxy.example.com:8080`.

**CA certificates**:

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE` | Comma list of `bundled`, `system` (default: `bundled,system`) |
| `NODE_EXTRA_CA_CERTS` | Path to additional CA cert PEM (required for Node.js runtime merge of system CAs) |

`CLAUDE_CODE_CERT_STORE` has no `settings.json` schema key — set via `env` block in `~/.claude/settings.json` or process env.

**mTLS client certificates**:

```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="your-passphrase"
```

**Required network access URLs**:

| URL | Purpose |
| :--- | :--- |
| `api.anthropic.com` | Claude API endpoints |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `storage.googleapis.com` | Binary and auto-updater download bucket |
| `downloads.claude.ai` | Install script, version pointers, manifests, plugin executables |

For Claude Code on the web and Code Review, if your GitHub Enterprise Cloud org restricts by IP, enable IP allow list inheritance for installed GitHub Apps (the Claude GitHub App registers its ranges). Or allowlist Anthropic API IP ranges manually. Same applies to self-hosted GitHub Enterprise Server instances.

### Data usage and retention

**Training**:

- **Consumer (Free, Pro, Max)**: Opt-in training toggle; data used for model improvement when on.
- **Commercial (Team, Enterprise, API, Bedrock, Vertex, Gov)**: No training on prompts/code unless explicitly opted in (Development Partner Program — first-party API only).

**Retention periods**:

| Account type | Retention |
| :--- | :--- |
| Consumer, training opt-in | 5 years |
| Consumer, training opt-out | 30 days |
| Commercial standard | 30 days |
| Enterprise with ZDR | No retention (see below) |
| `/feedback` transcripts | 5 years |
| Local session transcripts | 30 days by default in `~/.claude/projects/` (adjust via `cleanupPeriodDays`) |

**Session quality surveys**: Only the numeric rating (1–3 or dismiss) is stored — no transcripts, inputs, outputs. Does not affect training preferences. Disable via `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`, `DISABLE_TELEMETRY`, or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`. Control frequency with `feedbackSurveyRate` (0–1).

**Telemetry opt-outs**:

| Service | Variable |
| :--- | :--- |
| Statsig metrics | `DISABLE_TELEMETRY=1` |
| Sentry errors | `DISABLE_ERROR_REPORTING=1` |
| `/feedback` command | `DISABLE_FEEDBACK_COMMAND=1` |
| All non-essential traffic | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` |

**Provider defaults**: On Bedrock, Vertex, and Foundry, telemetry, error reporting, and `/feedback` are **off by default**. Session quality surveys appear regardless of provider.

Claude Code data in transit is TLS-encrypted; not encrypted at rest by default. Compatible with most VPNs and LLM proxies.

### Zero Data Retention (ZDR)

Available for **Claude Code on Claude for Enterprise**. Prompts and responses are processed in real time and not stored after response return, except as required by law or abuse mitigation. Enabled **per-organization**; must be requested separately for each new org via your Anthropic account team.

**Enterprise admin features unlocked**: cost controls per user, analytics dashboard, server-managed settings, audit logs.

**Features disabled under ZDR** (require storing prompts/completions):

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side conversation storage |
| Remote sessions from the Desktop app | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

**What ZDR does NOT cover** (standard retention still applies): claude.ai chat, Cowork sessions, Claude Code Analytics metadata, user/seat management, third-party integrations/MCP servers.

**ZDR on Bedrock, Vertex, Foundry**: Refer to those platforms' policies — Anthropic's ZDR applies only to the first-party platform.

**Policy violation retention**: Even with ZDR, flagged sessions may retain inputs/outputs for up to 2 years.

### Legal and compliance

- **License**: [Commercial Terms](https://www.anthropic.com/legal/commercial-terms) (Team, Enterprise, API) or [Consumer Terms](https://www.anthropic.com/legal/consumer-terms) (Free, Pro, Max)
- **Commercial agreements**: Existing 1P (Claude API) or 3P (Bedrock, Vertex) agreements apply to Claude Code automatically
- **Healthcare (BAA)**: BAA extends to Claude Code if the customer has executed a BAA **and** ZDR is enabled. Per-org ZDR enablement required
- **Acceptable use**: Subject to [Anthropic Usage Policy](https://www.anthropic.com/legal/aup). Pro/Max advertised limits assume ordinary individual use of Claude Code and the Agent SDK
- **Authentication**:
  - **OAuth** is reserved for Free/Pro/Max/Team/Enterprise subscription holders using native Anthropic apps
  - **API keys** are required for developers building third-party products with Claude (including Agent SDK). Do not route third-party users through Free/Pro/Max plan credentials
- **Trust Center**: [trust.anthropic.com](https://trust.anthropic.com) — SOC 2 Type 2, ISO 27001, etc.
- **Vulnerability reporting**: Anthropic [HackerOne program](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) — do not disclose publicly first

### Security best practices

- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Use devcontainers for additional isolation
- Audit permissions with `/permissions`
- Enforce org standards via managed settings
- Share approved permission configurations via version control
- Monitor via OpenTelemetry metrics
- Audit or block settings changes during sessions with `ConfigChange` hooks
- Start sandbox rules restrictive and expand; use environment-specific configs; test against real workflows

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Security foundation, permission architecture, prompt injection defenses, MCP/IDE/cloud security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — OS-level filesystem and network isolation for the bash tool, sandbox modes, settings, limitations
- [Development containers](references/claude-code-devcontainer.md) — Reference devcontainer setup with Node.js 20, custom firewall, and VS Code integration
- [Enterprise network configuration](references/claude-code-network-config.md) — Proxies, CA certificates, mTLS, required network URLs
- [Data usage](references/claude-code-data-usage.md) — Training, retention, telemetry, per-provider defaults
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, enabled admin features, features disabled under ZDR
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — License, commercial agreements, BAA, usage policy, authentication, vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
