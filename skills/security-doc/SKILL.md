---
name: security-doc
description: Complete official documentation for Claude Code security, sandboxing, devcontainer isolation, enterprise network configuration (proxies, CAs, mTLS), data usage and retention policies, legal and compliance (BAA, OAuth vs API key auth), and Zero Data Retention (ZDR) on Claude for Enterprise.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, sandboxing, devcontainers, network configuration, data usage, legal/compliance, and Zero Data Retention.

## Quick Reference

### Security model at a glance

| Layer | What it does |
| :---- | :----------- |
| **Permissions** | Gate every tool invocation; read-only by default; configurable allow/ask/deny rules |
| **Sandboxing** | OS-level filesystem + network isolation for Bash subprocesses |
| **Write boundary** | Claude can only write inside the project directory unless explicitly allowed |
| **Devcontainer** | Disposable VM-like environment with firewall for unattended runs |
| **Trust verification** | First-time codebase + new MCP server prompts; disabled with `-p` non-interactive |
| **Cloud sandbox** | Claude Code on the web runs in isolated Anthropic-managed VMs |

### Prompt injection protections (built-in)

- Permission system gates sensitive ops
- Context-aware analysis of full request
- Input sanitization
- Default blocklist of risky web-fetching commands (e.g., `curl`, `wget`)
- Network requests require approval by default
- Web fetch uses isolated context window
- Trust verification for new codebases and MCP servers
- Command injection detection (suspicious commands re-prompt even if allowlisted)
- Fail-closed matching (unmatched commands require manual approval)
- Encrypted credential storage

Caveat: on Windows, do not enable WebDAV access — it bypasses the permission system.

### Sandboxing essentials

| Aspect | Detail |
| :----- | :----- |
| **Enable** | Run `/sandbox` in the CLI |
| **macOS backend** | Seatbelt (built-in, no install) |
| **Linux/WSL2 backend** | bubblewrap + socat (`apt install bubblewrap socat`) |
| **WSL1** | Not supported |
| **Modes** | `auto-allow` (sandboxed commands skip prompts) and `regular permissions` |
| **Default writes** | Current working directory and subdirectories only |
| **Default reads** | Whole filesystem except denied paths |
| **Network** | Domain allowlist via proxy; new domains prompt unless `allowManagedDomainsOnly` |
| **Hard fail** | Set `sandbox.failIfUnavailable: true` to require sandbox to start |
| **Escape hatch** | `dangerouslyDisableSandbox` parameter; disable with `allowUnsandboxedCommands: false` |

Sandbox filesystem path prefixes:

| Prefix | Resolves to |
| :----- | :---------- |
| `/foo` | Absolute filesystem path |
| `~/foo` | `$HOME/foo` |
| `./foo` or `foo` | Project root (project settings) or `~/.claude` (user settings) |
| `//foo` | Older absolute-path syntax (still works) |

Multi-scope merging: `allowWrite`, `denyWrite`, `allowRead`, `denyRead` arrays from all settings scopes are merged, not replaced. `allowRead` takes precedence over `denyRead`. With `allowManagedReadPathsOnly`, only managed-scope `allowRead` entries are honored.

Sandbox-incompatible tools (suggestions): use `jest --no-watchman`; add `docker *` to `excludedCommands`.

Sandbox security limitations to be aware of:
- Network filtering only checks domains, not traffic content; broad domains like `github.com` enable exfiltration; domain fronting may bypass.
- `allowUnixSockets` to powerful sockets (e.g., `/var/run/docker.sock`) grants host access.
- Writable paths in `$PATH` or shell rc files enable privilege escalation.
- Linux `enableWeakerNestedSandbox` is significantly weaker; only use with other isolation.

### Devcontainer

- Reference setup at `anthropics/claude-code/.devcontainer` (Node.js 20 base + firewall)
- Allows safe use of `claude --dangerously-skip-permissions` for unattended runs
- Default-deny firewall, allowlists npm registry, GitHub, Claude API, DNS, SSH
- Three files: `devcontainer.json`, `Dockerfile`, `init-firewall.sh`
- Recommended only for **trusted repositories** — does not stop a malicious repo from exfiltrating credentials inside the container

### Enterprise network configuration

Proxy env vars:

| Variable | Purpose |
| :------- | :------ |
| `HTTPS_PROXY` | Recommended HTTPS proxy URL |
| `HTTP_PROXY` | Fallback if HTTPS unavailable |
| `NO_PROXY` | Bypass list (space- or comma-separated, or `*` for all) |

SOCKS proxies are **not** supported. For NTLM/Kerberos, use an LLM gateway.

CA trust:

| Variable | Purpose |
| :------- | :------ |
| `NODE_EXTRA_CA_CERTS` | Path to extra CA bundle (required on Node.js runtime to merge OS store) |
| `CLAUDE_CODE_CERT_STORE` | Comma list of `bundled`,`system` (default: `bundled,system`) |

mTLS client cert env vars:

| Variable | Purpose |
| :------- | :------ |
| `CLAUDE_CODE_CLIENT_CERT` | PEM client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | PEM private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Optional key passphrase |

Required allowlisted hosts:

| Host | Use |
| :--- | :-- |
| `api.anthropic.com` | Claude API |
| `claude.ai` | claude.ai account auth |
| `platform.claude.com` | Console account auth |
| `storage.googleapis.com` | Native installer + auto-updater |
| `downloads.claude.ai` | Install scripts, manifests, plugins |
| `bridge.claudeusercontent.com` | Chrome extension WebSocket (only if using Chrome integration) |

For GitHub Enterprise Cloud with IP allowlists, enable **IP allow list inheritance for installed GitHub Apps** so the Claude GitHub App's ranges are honored. For self-hosted GHES behind a firewall, allowlist Anthropic's API IP ranges so the cloud reaches your host.

### Data usage policy

| Account type | Default training use | Default retention |
| :----------- | :------------------- | :---------------- |
| Free / Pro / Max (consumer) | Optional, controlled in privacy settings | 5 years if training enabled, 30 days if not |
| Team / Enterprise / API / 3P | **Not** used for training (unless DPP opt-in) | 30 days standard |
| Enterprise with ZDR | Not used for training | No retention of inference (with exceptions) |

- Local session transcripts: plaintext under `~/.claude/projects/`, 30 days by default (`cleanupPeriodDays`).
- Development Partner Program: explicit opt-in (admin-level); **first-party API only**, not Bedrock/Vertex.
- `/feedback` transcripts retained **5 years**.
- Session quality survey: **only** the numeric rating (1/2/3/dismiss) is stored — no transcripts, never used for training.

### Telemetry / non-essential traffic and opt-outs

| Service | Purpose | Disable with |
| :------ | :------ | :----------- |
| Statsig | Operational metrics (no code/paths) | `DISABLE_TELEMETRY=1` |
| Sentry | Error logging | `DISABLE_ERROR_REPORTING=1` |
| `/feedback` | Sends full conversation + code to Anthropic | `DISABLE_FEEDBACK_COMMAND=1` |
| Session quality survey | Numeric rating only | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` (or `feedbackSurveyRate`) |
| All non-essential traffic | All of the above at once | `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` |

Defaults by API provider: Statsig, Sentry, and `/feedback` are **on** for the Claude API and **off** for Bedrock, Vertex, and Foundry. Session quality surveys default **on** for all providers.

### Legal and compliance

- License: Commercial Terms (Team/Enterprise/API) or Consumer Terms (Free/Pro/Max)
- BAA / HIPAA: BAA extends to Claude Code automatically when the customer has executed a BAA **and** has Zero Data Retention enabled (per organization)
- Acceptable use governed by the Anthropic Usage Policy
- Authentication intent:
  - **OAuth** (Free/Pro/Max/Team/Enterprise) is for ordinary use of native Anthropic apps
  - **API key** auth (Console or cloud provider) is for developers building products, including Agent SDK apps
  - Routing third-party users through OAuth on consumer plans is not permitted
- Vulnerability reports go through Anthropic's HackerOne program

### Zero Data Retention (ZDR)

- Available for Claude Code on **Claude for Enterprise** only (Anthropic's direct platform; not Bedrock/Vertex/Foundry)
- Enabled **per organization** by your account team — does not auto-apply to new orgs
- **Covers**: model inference (prompts and responses) made through Claude Code
- **Does not cover**: claude.ai chat, Cowork, Claude Code Analytics metadata, user/seat admin data, third-party integrations (including MCP servers)
- **Disables under ZDR** (backend-enforced):
  - Claude Code on the Web
  - Remote sessions from the Desktop app
  - `/feedback` submission
- Admin features ZDR unlocks: per-user cost controls, analytics dashboard (usage only — no contribution metrics), server-managed settings, audit logs
- Policy violation exception: flagged sessions may retain inputs/outputs up to 2 years

### Cloud execution security (Claude Code on the web)

- Each session runs in an isolated, Anthropic-managed VM
- Network access limited by default; configurable to disabled or allowlist
- GitHub auth handled via secure proxy with scoped credentials inside sandbox
- Git push restricted to the current working branch
- All operations audit-logged
- Environments auto-terminated after session

Note: Remote Control sessions are different — code execution and file access stay on your local machine; only Anthropic API traffic over TLS is involved (no cloud VMs).

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Security foundation, permission-based architecture, prompt injection protections, MCP security, IDE security, cloud execution security, best practices, and how to report vulnerabilities.
- [Sandboxing](references/claude-code-sandboxing.md) — OS-level filesystem and network isolation for the Bash tool: how it works (Seatbelt/bubblewrap), enabling with `/sandbox`, modes, configuration of `allowWrite`/`denyRead`/etc., security benefits, limitations, escape hatch, and how sandboxing relates to permissions.
- [Development containers](references/claude-code-devcontainer.md) — Reference devcontainer setup with firewall rules, key features, getting started, configuration breakdown, security features, and use cases for using `claude --dangerously-skip-permissions` safely.
- [Enterprise network configuration](references/claude-code-network-config.md) — Proxy configuration, custom CA certificates, `CLAUDE_CODE_CERT_STORE`, mTLS authentication, and required network allowlist hosts (including GitHub Enterprise considerations).
- [Data usage](references/claude-code-data-usage.md) — Training, retention, and feedback policies for consumer vs commercial users; data flow diagrams; telemetry services (Statsig, Sentry); per-provider defaults and opt-out env vars.
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — Commercial vs consumer terms, BAA / HIPAA compliance via ZDR, acceptable use, OAuth vs API key authentication policy, and vulnerability reporting.
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope on Claude for Enterprise, what it covers and excludes, features disabled under ZDR, retention exception for policy violations, and how to request enablement.

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
