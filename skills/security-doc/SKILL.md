---
name: security-doc
description: Complete official documentation for Claude Code security — permission architecture, prompt injection defenses, sandboxing, devcontainers, network configuration, data usage policies, data retention, zero data retention, telemetry, and legal compliance.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, data usage, and compliance.

## Quick Reference

### Permission-based architecture

Claude Code uses strict read-only permissions by default. Any action beyond reading (editing files, running commands) requires explicit user approval. Users can approve once or allowlist commands permanently.

### Built-in protections

| Protection                     | Description                                                                         |
| :----------------------------- | :---------------------------------------------------------------------------------- |
| Sandboxed bash tool            | OS-level filesystem and network isolation via `/sandbox`                             |
| Write access restriction       | Writes confined to the cwd and its subdirectories; reads allowed outside             |
| Prompt fatigue mitigation      | Allowlist safe commands per-user, per-codebase, or per-organization                  |
| Accept Edits mode              | Batch-accept edits while keeping permission prompts for side-effect commands         |
| Command blocklist              | `curl`, `wget`, and similar web-fetching commands blocked by default                 |
| Command injection detection    | Suspicious bash commands require manual approval even if previously allowlisted      |
| Isolated context windows       | Web fetch uses a separate context to avoid prompt injection                          |
| Trust verification             | First-time codebase runs and new MCP servers require trust confirmation              |
| Secure credential storage      | API keys and tokens are encrypted                                                   |

### Prompt injection defenses

- Permission system gates sensitive operations
- Context-aware analysis detects harmful instructions
- Input sanitization prevents command injection
- Network request approval required by default
- Fail-closed matching: unmatched commands default to manual approval

### Sandboxing

Enable with `/sandbox`. Two modes available:

| Mode                    | Behavior                                                                         |
| :---------------------- | :------------------------------------------------------------------------------- |
| Auto-allow              | Sandboxed commands run without approval; unsandboxable commands fall back to normal permissions |
| Regular permissions     | All commands go through the standard permission flow, even when sandboxed        |

#### OS-level enforcement

| Platform | Mechanism                                      |
| :------- | :--------------------------------------------- |
| macOS    | Seatbelt (built-in, no install needed)         |
| Linux    | bubblewrap + socat (`apt install bubblewrap socat`) |
| WSL2     | bubblewrap (same as Linux)                     |
| WSL1     | Not supported                                  |

#### Filesystem isolation settings

| Setting                                | Purpose                                                      |
| :------------------------------------- | :----------------------------------------------------------- |
| `sandbox.filesystem.allowWrite`        | Grant subprocess write access to paths outside cwd           |
| `sandbox.filesystem.denyWrite`         | Block subprocess write access to specific paths              |
| `sandbox.filesystem.denyRead`          | Block subprocess read access to specific paths               |
| `sandbox.filesystem.allowRead`         | Re-allow reading within a `denyRead` region                  |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` entries are respected        |

Path prefix conventions: `/` = absolute, `~/` = relative to home, `./` or no prefix = relative to project root (project settings) or `~/.claude` (user settings). Arrays from all settings scopes are **merged**, not replaced.

#### Network isolation settings

| Setting                               | Purpose                                              |
| :------------------------------------ | :--------------------------------------------------- |
| `sandbox.network.allowedDomains`      | Domains bash commands can reach                      |
| `sandbox.network.deniedDomains`       | Block specific domains even under a wildcard allow   |
| `sandbox.network.httpProxyPort`       | Custom HTTP proxy port                               |
| `sandbox.network.socksProxyPort`      | Custom SOCKS proxy port                              |
| `sandbox.allowUnsandboxedCommands`    | Set `false` to disable the escape hatch              |
| `sandbox.failIfUnavailable`           | Set `true` to hard-fail when sandbox cannot start    |
| `sandbox.excludedCommands`            | Commands forced to run outside the sandbox           |
| `sandbox.allowUnixSockets`            | Grant access to Unix sockets (use with caution)      |

#### Security limitations

- Network filtering restricts domains only; does not inspect traffic content
- Broad domains (e.g., `github.com`) may allow data exfiltration
- Domain fronting can potentially bypass network filtering
- `allowUnixSockets` can enable privilege escalation (e.g., Docker socket)
- Overly broad filesystem write permissions can enable privilege escalation
- `enableWeakerNestedSandbox` considerably weakens security (Docker-in-Docker only)

#### Open source sandbox runtime

```bash
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

Available at [github.com/anthropic-experimental/sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime).

### Development containers

The [reference devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) provides a preconfigured, isolated environment with firewall rules allowing `--dangerously-skip-permissions` for unattended operation.

| Component            | Purpose                                               |
| :------------------- | :---------------------------------------------------- |
| `devcontainer.json`  | Container settings, extensions, volume mounts         |
| `Dockerfile`         | Container image and installed tools                   |
| `init-firewall.sh`   | Network security rules (default-deny, whitelisted outbound only) |

### Enterprise network configuration

#### Proxy environment variables

| Variable         | Purpose                                            |
| :--------------- | :------------------------------------------------- |
| `HTTPS_PROXY`    | HTTPS proxy URL (recommended)                      |
| `HTTP_PROXY`     | HTTP proxy URL                                     |
| `NO_PROXY`       | Bypass proxy (space- or comma-separated; `*` for all) |

#### CA certificate store

`CLAUDE_CODE_CERT_STORE` accepts `bundled`, `system`, or `bundled,system` (default). Enterprise TLS-inspection proxies (CrowdStrike Falcon, Zscaler) work automatically when their root cert is in the OS trust store.

| Variable                           | Purpose                                     |
| :--------------------------------- | :------------------------------------------ |
| `NODE_EXTRA_CA_CERTS`              | Path to custom CA certificate PEM           |
| `CLAUDE_CODE_CLIENT_CERT`          | Client certificate for mTLS                 |
| `CLAUDE_CODE_CLIENT_KEY`           | Client private key for mTLS                 |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE`| Passphrase for encrypted private key        |

#### Required URLs to allowlist

| URL                              | Purpose                                          |
| :------------------------------- | :----------------------------------------------- |
| `api.anthropic.com`              | Claude API endpoints                             |
| `claude.ai`                      | Authentication for claude.ai accounts            |
| `platform.claude.com`            | Authentication for Anthropic Console accounts    |
| `storage.googleapis.com`         | Binary downloads and auto-updater                |
| `downloads.claude.ai`            | Install script, manifests, signing keys, plugins |
| `bridge.claudeusercontent.com`   | Chrome integration WebSocket bridge              |

### Data usage and retention

#### Training policy

| Plan                          | Training policy                                                        |
| :---------------------------- | :--------------------------------------------------------------------- |
| Free, Pro, Max (consumer)     | User chooses whether data is used for model improvement                |
| Team, Enterprise, API (commercial) | Not used for training unless customer opts in (e.g., Developer Partner Program) |

#### Retention periods

| Account type                        | Retention                                      |
| :---------------------------------- | :--------------------------------------------- |
| Consumer, training allowed          | 5 years                                        |
| Consumer, training not allowed      | 30 days                                        |
| Commercial (standard)               | 30 days                                        |
| Commercial (ZDR on Enterprise)      | Zero (not stored after response is returned)   |
| Local session cache (`~/.claude/projects/`) | 30 days (configurable via `cleanupPeriodDays`) |
| `/feedback` transcripts             | 5 years                                        |

#### Telemetry opt-out environment variables

| Variable                                   | What it disables                      |
| :----------------------------------------- | :------------------------------------ |
| `DISABLE_TELEMETRY`                        | Statsig metrics                       |
| `DISABLE_ERROR_REPORTING`                  | Sentry error logging                  |
| `DISABLE_FEEDBACK_COMMAND`                 | `/feedback` command                   |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY`      | Session quality surveys               |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | All non-essential traffic at once     |

Telemetry, error reporting, and bug reporting are **off by default** for Bedrock, Vertex, and Foundry providers.

### Zero Data Retention (ZDR)

Available for Claude Code on Claude for Enterprise. When enabled, prompts and responses are not stored after the response is returned.

**Features disabled under ZDR:**

| Feature                     | Reason                                                   |
| :-------------------------- | :------------------------------------------------------- |
| Claude Code on the Web      | Requires server-side conversation history storage        |
| Remote sessions (Desktop)   | Requires persistent session data                         |
| `/feedback` submission      | Sends conversation data to Anthropic                     |

ZDR is enabled per-organization. Each new organization must have ZDR enabled separately by the account team. The BAA automatically extends to cover Claude Code when ZDR is active.

Data may still be retained for up to 2 years for Usage Policy violations.

### Legal and compliance

| Agreement            | Applies to                               | URL                                             |
| :------------------- | :--------------------------------------- | :---------------------------------------------- |
| Commercial Terms     | Team, Enterprise, API                    | https://www.anthropic.com/legal/commercial-terms |
| Consumer Terms       | Free, Pro, Max                           | https://www.anthropic.com/legal/consumer-terms   |
| Acceptable Use Policy| All users                                | https://www.anthropic.com/legal/aup              |
| Privacy Policy       | All users                                | https://www.anthropic.com/legal/privacy          |

Security vulnerabilities: report via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability).

Trust and compliance resources: [Anthropic Trust Center](https://trust.anthropic.com), [Transparency Hub](https://www.anthropic.com/transparency).

### Cloud execution security

| Control                    | Description                                                   |
| :------------------------- | :------------------------------------------------------------ |
| Isolated VMs               | Each session runs in an Anthropic-managed VM                  |
| Network access controls    | Limited by default; configurable per-domain                   |
| Credential protection      | Scoped credential in sandbox, translated to actual GitHub token |
| Branch restrictions        | Git push restricted to current working branch                 |
| Audit logging              | All operations logged                                         |
| Automatic cleanup          | Environments terminated after session completion              |

Remote Control sessions run locally (no cloud VMs); connection uses multiple short-lived, narrowly scoped credentials.

### Security best practices

1. Review all suggested changes before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs for scripts interacting with external web services
5. Use project-specific permission settings for sensitive repos
6. Use devcontainers for additional isolation
7. Enforce organizational standards with managed settings
8. Monitor usage through OpenTelemetry metrics
9. Audit config changes with `ConfigChange` hooks
10. Report suspicious behavior with `/feedback`

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection defenses, MCP security, IDE security, cloud execution security, and best practices.
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem and network isolation, OS-level enforcement, sandbox modes, configuration, security benefits, limitations, and open source runtime.
- [Development containers](references/claude-code-devcontainer.md) — reference devcontainer setup, firewall configuration, customization, and use cases.
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificates, mTLS authentication, and required URL allowlists.
- [Data usage](references/claude-code-data-usage.md) — training policy, retention periods, telemetry services, data flow diagrams, and opt-out variables.
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license terms, commercial agreements, healthcare compliance (BAA), acceptable use, and authentication policies.
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, covered and excluded features, disabled features, policy violation retention, and how to request enablement.

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
