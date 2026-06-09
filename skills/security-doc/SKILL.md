---
name: security-doc
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security: the core security model and protections, sandboxed Bash tool configuration, dev container isolation, network and proxy configuration, data usage and retention policies, zero data retention, sandbox environment options, legal and compliance, and the security guidance plugin for in-session vulnerability review.

## Quick Reference

### Security Architecture Overview

| Layer | What it does |
|:------|:-------------|
| Permission system | Read-only by default; explicit approval required for writes, edits, and commands |
| Sandboxed Bash tool | OS-level filesystem and network isolation for Bash commands and subprocesses |
| Write access restriction | Writes confined to the working directory; reads allowed more broadly |
| Prompt injection safeguards | Context-aware analysis, input sanitization, command blocklist, isolated WebFetch context |
| Credential storage | API keys and tokens encrypted at rest |
| Trust verification | First-time codebase runs and new MCP servers require trust confirmation |

### Sandbox Environments: Comparison

| Approach | What is isolated | Requires Docker | Setup effort |
|:---------|:----------------|:----------------|:-------------|
| Sandboxed Bash tool (`/sandbox`) | Bash commands and subprocesses only | No | Minimal (macOS); low (Linux/WSL2) |
| Sandbox runtime (`@anthropic-ai/sandbox-runtime`) | Entire Claude Code process (file tools, MCP, hooks) | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium to high |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, Anthropic-hosted | No | None (subscription + GitHub required) |

Use `--dangerously-skip-permissions` only inside a container, VM, or the sandbox runtime so file tools and hooks are also inside the isolation boundary.

### Sandboxed Bash Tool: Key Settings (`sandbox.*` in `settings.json`)

| Key | Type | Description |
|:----|:-----|:------------|
| `sandbox.enabled` | boolean | Enable/disable the sandbox |
| `sandbox.failIfUnavailable` | boolean | Hard-fail on startup if sandbox cannot initialize (managed deployments) |
| `sandbox.allowUnsandboxedCommands` | boolean | Allow `dangerouslyDisableSandbox` escape hatch (default `true`); set `false` for strict mode |
| `sandbox.filesystem.allowWrite` | string[] | Additional paths subprocess can write to |
| `sandbox.filesystem.denyWrite` | string[] | Paths to block writes to |
| `sandbox.filesystem.denyRead` | string[] | Paths to block reads from |
| `sandbox.filesystem.allowRead` | string[] | Re-allow reads within a `denyRead` region |
| `sandbox.allowedDomains` | string[] | Pre-approved network domains for Bash commands |
| `sandbox.deniedDomains` | string[] | Block specific domains even under a broad `allowedDomains` wildcard |
| `sandbox.excludedCommands` | string[] | Commands that bypass the sandbox entirely |
| `sandbox.allowManagedDomainsOnly` | boolean | Managed: honor only managed-settings `allowedDomains` |
| `sandbox.allowManagedReadPathsOnly` | boolean | Managed: honor only managed-settings `allowRead` entries |
| `sandbox.network.httpProxyPort` | number | Custom proxy HTTP port |
| `sandbox.network.socksProxyPort` | number | Custom proxy SOCKS port |
| `sandbox.enableWeakerNetworkIsolation` | boolean | Required with MITM proxy + custom CA on macOS |
| `sandbox.enableWeakerNestedSandbox` | boolean | Required inside unprivileged containers |

### Sandbox Filesystem Path Prefix Conventions

| Prefix | Resolves to |
|:-------|:------------|
| `/` | Absolute from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

### Sandbox Modes

| Mode | Behavior |
|:-----|:---------|
| Auto-allow | Sandboxed commands run without prompting; deny rules and dangerous `rm` targets still prompt |
| Regular permissions | All Bash commands go through the normal permission flow, even when sandboxed |

### OS-Level Sandbox Implementation

| Platform | Mechanism |
|:---------|:----------|
| macOS | Seatbelt (built-in; no packages needed) |
| Linux | bubblewrap + socat (`sudo apt-get install bubblewrap socat`) |
| WSL2 | bubblewrap + socat (same as Linux) |
| Windows (native) | Not supported; use WSL2 or a container |

Ubuntu 24.04+: may require an AppArmor profile for bubblewrap user namespaces. Check `sysctl kernel.apparmor_restrict_unprivileged_userns`.

### Dev Container Key Configurations

| Goal | How |
|:-----|:----|
| Install Claude Code | Add `ghcr.io/anthropics/devcontainer-features/claude-code:1.0` feature |
| Persist auth/settings across rebuilds | Mount named volume at `~/.claude` |
| Enforce org policy | Copy `managed-settings.json` to `/etc/claude-code/managed-settings.json` in Dockerfile |
| Restrict network egress | Use `init-firewall.sh` with `NET_ADMIN` and `NET_RAW` capabilities in `runArgs` |
| Disable auto-update | Set `DISABLE_AUTOUPDATER=1` in `containerEnv` |
| Disable telemetry | Set `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` in `containerEnv` |
| Run unattended | Use `--dangerously-skip-permissions` (requires non-root user; `remoteUser` must not be root) |

### Network Configuration

| Variable / Setting | Purpose |
|:-------------------|:--------|
| `HTTPS_PROXY` / `HTTP_PROXY` | Route traffic through a corporate proxy |
| `NO_PROXY` | Bypass proxy for specific hosts (comma- or space-separated) |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA certificate PEM |
| `CLAUDE_CODE_CERT_STORE` | `bundled`, `system`, or `bundled,system` (default) |
| `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS client private key path |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted mTLS private key |

**Required network domains:**

| URL | Required for |
|:----|:------------|
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console account authentication |
| `downloads.claude.ai` | Plugin downloads and auto-updater |
| `raw.githubusercontent.com` | Changelog feed and release notes |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |

### Data Usage and Retention

| User type | Training default | Retention |
|:----------|:----------------|:----------|
| Consumer (Free/Pro/Max) | Opt-in (user controls in settings) | 5 years if training enabled; 30 days otherwise |
| Commercial (Team/Enterprise/API) | No training by default | 30 days standard |
| Enterprise with ZDR | No training | No server-side persistence after response |

**Telemetry opt-out variables:**

| Variable | Effect |
|:---------|:-------|
| `DISABLE_TELEMETRY=1` | Disable operational metrics (Anthropic API only by default) |
| `DISABLE_ERROR_REPORTING=1` | Disable Sentry error logging (Anthropic API only by default) |
| `DISABLE_FEEDBACK_COMMAND=1` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Disable all non-essential traffic at once |
| `skipWebFetchPreflight: true` (settings) | Disable WebFetch domain safety check |

Bedrock, Vertex AI, and Foundry providers default to telemetry and error reporting OFF.

### Zero Data Retention (ZDR)

Available to qualified Claude for Enterprise accounts (not included in standard plan; contact account team).

| Aspect | Detail |
|:-------|:-------|
| What ZDR covers | Claude Code inference on Claude for Enterprise (prompts and responses not retained) |
| What ZDR does NOT cover | Chat on claude.ai, Cowork, Analytics (usage metadata), user/seat management, third-party MCP servers |
| Features disabled under ZDR | Claude Code on the Web, Remote sessions from Desktop, `/feedback` command |
| Policy violation exception | Data may be retained up to 2 years if a session is flagged for usage policy violations |
| Scope | Per-organization; each new org requires separate ZDR enablement |

### Legal and Compliance

| Topic | Detail |
|:------|:-------|
| Healthcare (BAA) | BAA extends to Claude Code if the org has ZDR activated |
| Vulnerability reporting | HackerOne program (do not disclose publicly first) |
| Acceptable use | Subject to Anthropic Usage Policy; Pro/Max limits assume individual use |
| OAuth tokens | For individual subscription users only; not for building products or routing third-party requests |
| API keys | Required for developers building products, using Agent SDK |

### Security Guidance Plugin

Installs via `/plugin install security-guidance@claude-plugins-official`. Reviews Claude's own code changes for vulnerabilities in the same session.

**Review layers:**

| Layer | When | Cost | What it catches |
|:------|:-----|:-----|:----------------|
| Per-edit pattern check | On each file write | None (no model call) | Known risky patterns: `eval`, `pickle`, `innerHTML`, `.github/workflows/` edits |
| End-of-turn diff review | After each turn completes | Model usage | Authorization bypass, IDOR, injection, SSRF, weak crypto |
| Commit/push agentic review | When Claude runs `git commit`/`git push` | Model usage (agentic) | Same as above, with surrounding code context; low false positives |

**Disable individual layers:**

| Variable | Effect |
|:---------|:-------|
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn diff review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit and push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable entire plugin without uninstalling |

**Custom rules files:**

| File | Purpose |
|:-----|:--------|
| `.claude/claude-security-guidance.md` | Markdown guidance for model-backed reviews (project-specific threat model) |
| `.claude/security-patterns.yaml` | Custom regex/substring patterns for per-edit check |

### Security Best Practices Summary

- Use `sandbox.failIfUnavailable: true` and `allowUnsandboxedCommands: false` in managed settings for hard enforcement
- Add `denyRead` entries for `~/.aws`, `~/.ssh` (sandbox reads credential files by default)
- For `--dangerously-skip-permissions`, always run inside a container, VM, or sandbox runtime
- Pair broad `allowedDomains` entries with a TLS-inspecting custom proxy to prevent data exfiltration via domain fronting
- Avoid mounting host secrets (`~/.ssh`, cloud credentials) into dev containers; use short-lived tokens instead
- Report security vulnerabilities via HackerOne (do not publicly disclose first)

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — Core security model: permission architecture, prompt injection protections, MCP/IDE/cloud execution security, best practices, vulnerability reporting
- [Configure the sandboxed Bash tool](references/claude-code-sandboxing.md) — Enable, configure, and enforce the sandboxed Bash tool; filesystem/network isolation; sandbox modes; organizational enforcement; troubleshooting and limitations
- [Development containers](references/claude-code-devcontainer.md) — Install Claude Code in a dev container, persist auth, enforce org policy, restrict network egress, and run unattended
- [Enterprise network configuration](references/claude-code-network-config.md) — Proxy setup, CA certificates, mTLS authentication, required network domains
- [Data usage](references/claude-code-data-usage.md) — Training policies, data retention by plan, telemetry services and opt-out, WebFetch domain safety check
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — Legal agreements, healthcare BAA, usage policy, authentication credential rules, trust center
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what it covers and excludes, disabled features, how to request enablement
- [Choose a sandbox environment](references/claude-code-sandbox-environments.md) — Compare all isolation approaches; choose by goal and threat model; organizational enforcement
- [Catch security issues as Claude writes code](references/claude-code-security-guidance.md) — Security guidance plugin: review layers, custom rules, usage cost, disable/uninstall, integration with other security tools

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Configure the sandboxed Bash tool: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Choose a sandbox environment: https://code.claude.com/docs/en/sandbox-environments.md
- Catch security issues as Claude writes code: https://code.claude.com/docs/en/security-guidance.md
