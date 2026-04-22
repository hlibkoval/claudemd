---
name: security-doc
description: Claude Code security — permission architecture, prompt injection safeguards, sandboxing, network config, devcontainers, data usage policies, zero data retention, and legal/compliance.
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, privacy, data usage, and compliance.

## Quick Reference

### Permission-based architecture

- **Read-only by default**: Claude Code only requests additional permissions (file edits, commands) as needed
- **Write scope**: Can only write to the directory where it was started and its subdirectories; reads outside the working directory are permitted
- **Audit permissions**: Run `/permissions` to review current settings
- **Accept Edits mode**: Batch-accept file edits while keeping command prompts active

---

### Prompt injection protections

| Protection | How it works |
| :--- | :--- |
| Permission system | Sensitive operations require explicit approval |
| Context-aware analysis | Detects harmful instructions in the full request |
| Input sanitization | Prevents command injection via user inputs |
| Command blocklist | Blocks `curl`, `wget`, and similar by default |
| Network request approval | Tools making network requests require user approval |
| Isolated web-fetch context | Separate context window prevents injecting malicious prompts |
| Trust verification | First-run codebases and new MCP servers require explicit trust |
| Command injection detection | Suspicious bash commands require manual approval even if allowlisted |
| Fail-closed matching | Unmatched commands default to requiring manual approval |
| Credential storage | API keys and tokens are encrypted |

**Best practices for untrusted content:**
1. Review suggested commands before approval
2. Avoid piping untrusted content directly to Claude
3. Verify proposed changes to critical files
4. Use VMs when interacting with external web services
5. Report suspicious behavior with `/feedback`

**Windows WebDAV warning:** Do not enable WebDAV or allow access to `\\*` paths; WebDAV is deprecated and can bypass the permission system.

---

### Sandboxing

Enable with `/sandbox`. Uses OS-level primitives (macOS: Seatbelt; Linux/WSL2: bubblewrap).

**Prerequisites (Linux/WSL2):**
```bash
sudo apt-get install bubblewrap socat   # Ubuntu/Debian
sudo dnf install bubblewrap socat       # Fedora
```

**Sandbox modes:**

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without prompts; unsafe fallback triggers normal flow |
| Regular permissions | All commands go through standard approval flow even inside sandbox |

**Key settings (`settings.json`):**

| Setting | Purpose |
| :--- | :--- |
| `sandbox.enabled` | Enable/disable sandboxing |
| `sandbox.filesystem.allowWrite` | Grant subprocess write access to extra paths |
| `sandbox.filesystem.denyWrite` | Block subprocess writes to specific paths |
| `sandbox.filesystem.denyRead` | Block subprocess reads from specific paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.allowedDomains` | Domains Bash commands can reach |
| `sandbox.network.deniedDomains` | Block specific domains despite a broader wildcard |
| `sandbox.failIfUnavailable` | Fail hard if sandbox cannot start (managed deployments) |
| `allowUnsandboxedCommands` | Set `false` to disable the escape-hatch mechanism |
| `excludedCommands` | Commands forced to run outside the sandbox |

**Path prefix conventions (sandbox filesystem):**

| Prefix | Resolves to |
| :--- | :--- |
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

**What sandbox does NOT cover:** Read/Edit/Write file tools (use permission rules), computer use (screen control).

**Open-source sandbox runtime:**
```bash
npx @anthropic-ai/sandbox-runtime <command-to-sandbox>
```

---

### Network configuration (enterprise)

All settings below can be placed in `settings.json` in addition to the environment.

**Proxy:**
```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,example.com,.example.com"
# Basic auth: include credentials in URL
# SOCKS proxies are NOT supported
```

**CA certificates:**
```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem       # custom CA
export CLAUDE_CODE_CERT_STORE=bundled,system           # default; comma-separated
```

**mTLS:**
```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="passphrase"  # optional
```

**Required URLs to allowlist:**

| URL | Purpose |
| :--- | :--- |
| `api.anthropic.com` | Claude API endpoints and WebFetch safety check |
| `claude.ai` | Authentication for claude.ai accounts |
| `platform.claude.com` | Authentication for Anthropic Console accounts |
| `downloads.claude.ai` | Native installer, updater, version pointers, plugin executables |
| `storage.googleapis.com` | Legacy download host (older clients) |
| `bridge.claudeusercontent.com` | Chrome extension WebSocket bridge |

---

### Devcontainer (isolated environment)

Reference setup: [github.com/anthropics/claude-code/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

**Key features:**
- Custom firewall: whitelisted outbound connections only; default-deny everything else
- Allows `claude --dangerously-skip-permissions` safely within the container
- Works on macOS, Windows, Linux via VS Code Dev Containers extension

**Components:**

| File | Purpose |
| :--- | :--- |
| `devcontainer.json` | Container settings, extensions, volume mounts |
| `Dockerfile` | Image definition and installed tools |
| `init-firewall.sh` | Network security rules on startup |

**Warning:** Even inside devcontainers, a malicious project can exfiltrate data accessible within the container (including Claude Code credentials). Only use with trusted repositories.

---

### Data usage policies

**Training data:**

| Account type | Training default |
| :--- | :--- |
| Consumer (Free/Pro/Max) | Data used for model training unless you opt out at [claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls) |
| Commercial (Team/Enterprise/API) | Not used for training unless opted into Developer Partner Program |

**Data retention:**

| Account type | Default retention |
| :--- | :--- |
| Consumer — opts in to training | 5 years |
| Consumer — opts out of training | 30 days |
| Commercial | 30 days |
| Commercial with ZDR | Prompts/responses not retained after response returned |

Local session transcripts are stored in `~/.claude/projects/` for 30 days (adjust via `cleanupPeriodDays`). Transcripts are not encrypted at rest.

**Telemetry opt-outs:**

| Env variable | Disables |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Statsig metrics |
| `DISABLE_ERROR_REPORTING=1` | Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | All non-essential traffic (not WebFetch check) |

**Default behaviors by provider:**

| Service | Claude API | Vertex / Bedrock / Foundry |
| :--- | :--- | :--- |
| Statsig (metrics) | Default on | Default off |
| Sentry (errors) | Default on | Default off |
| `/feedback` reports | Default on | Default off |
| Session quality surveys | Default on | Default on |
| WebFetch domain safety check | Default on | Default on |

**WebFetch domain safety check:** Before fetching a URL, only the hostname is sent to `api.anthropic.com` to check a blocklist. Cached per hostname for 5 minutes. Opt out with `skipWebFetchPreflight: true` in settings.

---

### Zero data retention (ZDR)

Available for Claude Code on Claude for Enterprise only (not Bedrock/Vertex/Foundry).

- Prompts and responses not retained after response is returned
- Enabled per-organization; each new org must be enabled separately by your Anthropic account team
- Request via [contact sales](https://www.anthropic.com/contact-sales?utm_source=claude_code&utm_medium=docs&utm_content=zero_data_retention_request)

**Features disabled under ZDR:**

| Feature | Reason |
| :--- | :--- |
| Claude Code on the web | Requires server-side storage of conversation history |
| Remote sessions from Desktop | Requires persistent session data |
| `/feedback` submission | Sends conversation data to Anthropic |

**Not covered by ZDR (follows standard retention):**
- Chat on claude.ai, Cowork, Claude Code Analytics metadata, user/seat management data, third-party integrations

**Policy violation exception:** Anthropic may retain flagged inputs/outputs up to 2 years even under ZDR.

---

### Legal and compliance

| Topic | Summary |
| :--- | :--- |
| Consumer terms | [anthropic.com/legal/consumer-terms](https://www.anthropic.com/legal/consumer-terms) (Free/Pro/Max) |
| Commercial terms | [anthropic.com/legal/commercial-terms](https://www.anthropic.com/legal/commercial-terms) (Team/Enterprise/API) |
| Usage policy | [anthropic.com/legal/aup](https://www.anthropic.com/legal/aup) |
| Healthcare (BAA) | BAA auto-extends to Claude Code when ZDR is active; per-org enablement required |
| Trust Center | [trust.anthropic.com](https://trust.anthropic.com) — SOC 2 Type 2, ISO 27001, etc. |
| Vulnerability reporting | [HackerOne VDP](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability) |

**Authentication rules:**
- OAuth is for Free/Pro/Max/Team/Enterprise users of Claude natively
- API key auth is for developers building products or services
- Third-party developers must not route requests through consumer plan credentials

---

### Cloud execution security

| Control | Details |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in an Anthropic-managed VM |
| Network access | Limited by default; configurable per session |
| Credential protection | Scoped credential inside sandbox translated via secure proxy to actual GitHub token |
| Branch restrictions | Git push restricted to current working branch |
| Audit logging | All cloud operations logged |
| Automatic cleanup | Environments terminated after session completion |

Remote Control sessions run locally; all code execution stays on your machine over TLS.

---

### Security best practices

**Sensitive code:**
- Review all suggested changes before approval
- Use project-specific permission settings for sensitive repos
- Use devcontainers for additional isolation
- Audit permissions with `/permissions`

**Team/organization:**
- Use managed settings to enforce org standards
- Share approved permission configs via version control
- Monitor usage via OpenTelemetry metrics
- Audit or block settings changes with `ConfigChange` hooks

**Reporting vulnerabilities:**
1. Do not disclose publicly
2. Report via [HackerOne](https://hackerone.com/anthropic-vdp/reports/new?type=team&report_type=vulnerability)
3. Include detailed reproduction steps

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — permission architecture, prompt injection safeguards, MCP/IDE/cloud security, best practices
- [Sandboxing](references/claude-code-sandboxing.md) — filesystem/network isolation, OS-level enforcement, sandbox modes, configuration, security limitations
- [Development Containers](references/claude-code-devcontainer.md) — devcontainer setup, firewall rules, VS Code integration, use cases
- [Enterprise Network Configuration](references/claude-code-network-config.md) — proxy, CA certs, mTLS, required URLs, GitHub Enterprise network requirements
- [Data Usage](references/claude-code-data-usage.md) — training policy, retention periods, telemetry, provider defaults, WebFetch safety check
- [Zero Data Retention](references/claude-code-zero-data-retention.md) — ZDR scope, disabled features, request process
- [Legal and Compliance](references/claude-code-legal-and-compliance.md) — license, BAA, usage policy, authentication rules, Trust Center

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Sandboxing: https://code.claude.com/docs/en/sandboxing.md
- Development Containers: https://code.claude.com/docs/en/devcontainer.md
- Enterprise Network Configuration: https://code.claude.com/docs/en/network-config.md
- Data Usage: https://code.claude.com/docs/en/data-usage.md
- Zero Data Retention: https://code.claude.com/docs/en/zero-data-retention.md
- Legal and Compliance: https://code.claude.com/docs/en/legal-and-compliance.md
