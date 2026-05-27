---
name: security-doc
description: Complete official documentation for Claude Code security — core security model (permission-based architecture, built-in protections, prompt injection safeguards, MCP/IDE/cloud security), the security-guidance plugin (per-edit pattern checks, end-of-turn review, commit review, custom rules, env-var controls), sandboxed Bash tool (modes, filesystem/network config, OS enforcement, org enforcement), sandbox environment comparison (Bash sandbox vs sandbox runtime vs dev containers vs VMs), dev containers (setup, org policy, network egress, running without prompts), data usage and privacy (training policy, retention periods, telemetry opt-outs, WebFetch safety check), zero data retention (ZDR scope, disabled features, request process), enterprise network config (proxy, CA certificates, mTLS, allowlist URLs), and legal/compliance (agreements, BAA/healthcare, auth policy, vulnerability reporting).
user-invocable: false
---

# Security Documentation

This skill provides the complete official documentation for Claude Code security, data handling, sandboxing, and compliance.

## Quick Reference

### Core Security Architecture

| Layer | What it does |
| :--- | :--- |
| Permission-based architecture | Read-only by default; explicit approval required for file edits, commands, and network requests |
| Write access restriction | Claude can only write to the folder it was started in and its subfolders |
| Prompt injection protections | Context-aware analysis, input sanitization, blocklist for `curl`/`wget`, isolated web-fetch context windows |
| Trust verification | First-time codebase runs and new MCP servers require trust; disabled with `-p` (except `--worktree`) |
| Credential storage | API keys and tokens are encrypted |
| Command injection detection | Suspicious Bash commands require manual approval even if previously allowlisted |

**Accept Edits mode** auto-approves file edits and a fixed set of filesystem commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) within the working directory. Other Bash commands and out-of-scope paths still prompt.

**Windows WebDAV warning**: avoid enabling WebDAV or allowing `\\*` paths — WebDAV is deprecated by Microsoft and can trigger network requests that bypass the permission system.

### Built-in Protections

| Protection | Description |
| :--- | :--- |
| Sandboxed Bash | Filesystem + network isolation for Bash commands; enable with `/sandbox` |
| Prompt fatigue mitigation | Allowlist frequently used safe commands per-user, per-codebase, or per-org |
| Network request approval | Tools making network requests require approval by default |
| Isolated web-fetch context | WebFetch uses a separate context window to prevent prompt injection |
| Fail-closed matching | Unmatched commands default to requiring manual approval |

### Cloud Execution Security

| Control | Details |
| :--- | :--- |
| Isolated VMs | Each cloud session runs in an isolated Anthropic-managed VM |
| Network access controls | Limited by default; configurable to none/trusted/full/custom |
| Credential protection | GitHub auth via secure proxy with scoped credentials inside the sandbox |
| Branch restrictions | Git push restricted to the current working branch |
| Audit logging | All operations logged for compliance |
| Automatic cleanup | Cloud environments terminated after session completion |

Remote Control sessions run locally — all code execution stays on your machine. Uses short-lived, narrowly scoped credentials per purpose.

---

### Security-Guidance Plugin

The `security-guidance` plugin reviews Claude's own code changes for vulnerabilities and fixes them in-session. Runs automatically — nothing to invoke.

**Install:**
```text
/plugin install security-guidance@claude-plugins-official
/reload-plugins
```

**Enable for cloud/shared repos** — add to `.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true
  }
}
```

#### Three Review Layers

| Layer | Trigger | Depth | Cost |
| :--- | :--- | :--- | :--- |
| Per-edit pattern check | Every file write | Deterministic string match, no model call | None |
| End-of-turn review | After each turn | Background model review of full turn's diff (up to 30 files, max 3 re-prompts) | Model usage |
| Commit/push review | Claude runs `git commit` or `git push` via Bash | Agentic review with surrounding code context (max 20/hour) | Model usage (agentic) |

End-of-turn and commit reviews use a **separate Claude instance** with a fresh context — not the same instance that wrote the code.

#### Built-in Per-Edit Pattern Categories

- Dynamic code execution: `eval(`, `new Function`, `os.system`, `child_process.exec`
- Unsafe deserialization: `pickle`
- DOM injection: `dangerouslySetInnerHTML`, `.innerHTML =`, `document.write`
- Workflow files: edits under `.github/workflows/`

#### Custom Rules

**Guidance for model reviews** — create `.claude/claude-security-guidance.md`:
```markdown
- Do not log `customer_id` or `account_number` at INFO level or above.
- All routes under `/admin` must call `require_role("admin")`.
```

**Custom per-edit patterns** — create `.claude/security-patterns.yaml`:

| Field | Type | Description |
| :--- | :--- | :--- |
| `rule_name` | string | Identifier shown in the warning |
| `reminder` | string | Warning text (capped at 1 KB) |
| `regex` | string | Python regex matched against edited content |
| `substrings` | list | Literal substrings (alternative to `regex`) |
| `paths` | list | Optional glob patterns; prefix with `**/` for project-relative |
| `exclude_paths` | list | Optional globs to skip |

Rule file lookup paths (same for guidance and patterns):

| Scope | Path |
| :--- | :--- |
| User | `~/.claude/claude-security-guidance.md` |
| Project | `.claude/claude-security-guidance.md` |
| Project local | `.claude/claude-security-guidance.local.md` |

Combined cap: 8 KB for guidance; up to 50 custom rules. Concatenates all locations that exist.

#### Disable / Uninstall Controls

| Variable | Effect |
| :--- | :--- |
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit/push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable plugin entirely |
| `SECURITY_REVIEW_MODEL=<model>` | Override model for end-of-turn review |
| `SG_AGENTIC_MODEL=<model>` | Override model for commit review |

Default model for both reviews: Claude Opus 4.7.

Disable from session: `/plugin disable security-guidance@claude-plugins-official`
Uninstall: `/plugin uninstall security-guidance@claude-plugins-official`

Diagnostics log: `~/.claude/security/log.txt`

#### Security Tool Stack (Defense in Depth)

| Stage | Tool | Coverage |
| :--- | :--- | :--- |
| In session | Security guidance plugin | Common vulnerabilities while Claude writes |
| On demand | `/security-review` command | One-time security pass on current branch |
| On PR | Code Review (Team/Enterprise) | Multi-agent review with full codebase context |
| In CI | Static analysis / dep scanners | Language-specific rules, supply chain |

---

### Sandboxed Bash Tool (`/sandbox`)

Restricts what Bash commands and their child processes can access. Enable with `/sandbox`.

**Platform support:** macOS (Seatbelt, built-in), Linux/WSL2 (bubblewrap + socat). Not supported on native Windows.

**Linux/WSL2 setup:**
```bash
sudo apt-get install bubblewrap socat          # Ubuntu/Debian
sudo dnf install bubblewrap socat              # Fedora
npm install -g @anthropic-ai/sandbox-runtime   # optional seccomp filter
```

#### Sandbox Modes

| Mode | Behavior |
| :--- | :--- |
| Auto-allow | Sandboxed commands run without prompting; unsandboxable commands fall back to regular permission flow |
| Regular permissions | All commands go through regular permission flow even when sandboxed |

In auto-allow mode, deny rules, `rm`/`rmdir` on critical system paths, and ask rules still apply.

#### Filesystem Defaults

| Behavior | Default |
| :--- | :--- |
| Write access | Working directory and subdirectories only |
| Read access | Entire filesystem (including `~/.aws/credentials`, `~/.ssh/`; add to `denyRead` to block) |
| Settings files | Sandbox automatically denies writes to `settings.json` files at all scopes |

#### Key Configuration (`settings.json` → `sandbox` key)

| Setting | Effect |
| :--- | :--- |
| `sandbox.enabled` | Enable sandbox |
| `sandbox.filesystem.allowWrite` | Add write-accessible paths (merged across scopes) |
| `sandbox.filesystem.denyWrite` | Block write access to paths |
| `sandbox.filesystem.denyRead` | Block read access to paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `sandbox.network.allowedDomains` | Pre-allow domains (no prompt needed) |
| `sandbox.network.deniedDomains` | Block specific domains within a broader allowedDomains wildcard |
| `sandbox.allowUnsandboxedCommands` | `false` = strict mode, disable `dangerouslyDisableSandbox` escape hatch |
| `sandbox.failIfUnavailable` | `true` = fail hard if sandbox can't start (for managed deployments) |
| `sandbox.excludedCommands` | Commands that run outside the sandbox |
| `allowManagedReadPathsOnly` | Only honor `allowRead` from managed settings |
| `allowManagedDomainsOnly` | Only honor `allowedDomains` from managed settings |

Path prefix convention: `/` = absolute, `~/` = relative to home, `./` or no prefix = relative to project root (in project settings).

#### Managed Org Enforcement

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false
  }
}
```

For boolean keys, managed value wins. For array keys (`excludedCommands`, `allowRead`), entries merge across scopes — use `allowManagedReadPathsOnly` / `allowManagedDomainsOnly` to lock them.

#### Security Limitations

- Network proxy makes allow decisions from the client-supplied hostname without TLS inspection — domain fronting is possible with broad allowlists like `github.com`
- `allowUnixSockets` can grant access to powerful system services (e.g., `/var/run/docker.sock` = host access)
- Broad `allowWrite` to `$PATH` directories or shell config files can enable privilege escalation
- `enableWeakerNestedSandbox` (for containers) considerably weakens isolation
- Sandboxed Bash commands inherit the parent environment including credentials; set `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` to strip them

#### Common Troubleshooting

| Issue | Fix |
| :--- | :--- |
| Host-not-allowed error | Approve domain when prompted, or pre-allow in `allowedDomains` |
| `jest` hangs | Run `jest --no-watchman` |
| Go CLIs fail TLS on macOS | Add to `excludedCommands` |
| `docker` commands fail | Add `docker *` to `excludedCommands` |
| Bubblewrap fails inside container | Set `enableWeakerNestedSandbox: true` |
| `--dangerously-skip-permissions` fails as root | Use a dev container running as non-root |

---

### Sandbox Environment Comparison

| Approach | What is isolated | Requires Docker | Setup effort |
| :--- | :--- | :--- | :--- |
| Sandboxed Bash tool | Bash commands and child processes | No | Minimal (macOS) / Low (Linux/WSL2) |
| Sandbox runtime | Whole Claude Code process (file tools, MCP, hooks) | No | Low |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium–High |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, hosted by Anthropic | No | None (needs Claude subscription + GitHub) |

**Choose by goal:**

| Goal | Approach |
| :--- | :--- |
| Reduce prompts during everyday work | Sandboxed Bash tool (`/sandbox`) |
| Unattended with `--dangerously-skip-permissions` | Dev container, any container/VM, or sandbox runtime |
| Isolate MCP + hooks without Docker | Sandbox runtime |
| Untrusted repository | VM or Claude Code on the web |
| Standardize across team | Dev container |
| Native Windows host | Container, VM, or Bash sandbox inside WSL2 |

**Sandbox runtime** (`@anthropic-ai/sandbox-runtime`) wraps the entire Claude Code process. Configure `~/.srt-settings.json` (allow writes to project dir, `~/.claude`, and needed network domains), then:
```bash
npx @anthropic-ai/sandbox-runtime claude
```

---

### Dev Containers

Add Claude Code to any dev container via the Dev Container Feature:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  }
}
```

**Persist auth across rebuilds** — mount a named volume at `~/.claude`:
```json
"mounts": [
  "source=claude-code-config,target=/home/node/.claude,type=volume"
]
```

**Org policy** — copy to `/etc/claude-code/managed-settings.json` from Dockerfile (highest precedence). For policy that can't be bypassed via repo edits, use server-managed settings or MDM instead.

**Disable telemetry / auto-update** via `containerEnv`:
```json
"containerEnv": {
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
  "DISABLE_AUTOUPDATER": "1"
}
```

**Unattended operation** — pass `--dangerously-skip-permissions` when running as non-root user (CLI rejects flag as root). Pair with network egress restrictions.

Reference container at `anthropics/claude-code/.devcontainer/` includes egress firewall (`init-firewall.sh`), volume mounts, and Zsh shell.

---

### Data Usage

#### Training Policy

| Plan type | Default training |
| :--- | :--- |
| Consumer (Free, Pro, Max) | Opted in by default; toggle at `claude.ai/settings/data-privacy-controls` |
| Commercial (Team, Enterprise, API) | Not used for training unless explicitly opted in (e.g., Developer Partner Program) |

#### Data Retention

| Account type | Retention |
| :--- | :--- |
| Consumer — allows training | 5 years |
| Consumer — disallows training | 30 days |
| Commercial (Team, Enterprise, API) | 30 days standard |
| Commercial with ZDR | No server-side persistence (see ZDR section) |
| Local session transcripts | 30 days (`~/.claude/projects/`); adjust with `cleanupPeriodDays` |
| `/feedback` transcripts | 5 years |
| Session quality survey transcripts (if "Yes" selected) | Up to 6 months |

#### Telemetry Opt-Out Variables

| Variable | Effect |
| :--- | :--- |
| `DISABLE_TELEMETRY=1` | Opt out of operational metrics |
| `DISABLE_ERROR_REPORTING=1` | Opt out of Sentry error logging |
| `DISABLE_FEEDBACK_COMMAND=1` | Opt out of `/feedback` sending data to Anthropic |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` | Disable session quality survey |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential outbound traffic (does not affect WebFetch safety check) |

#### Default Behaviors by Provider

| Service | Claude API | Vertex / Bedrock / Foundry |
| :--- | :--- | :--- |
| Metrics (Anthropic) | On by default | Off by default |
| Error reporting (Sentry) | On by default | Off by default |
| `/feedback` reports | On by default | Off by default |
| Session quality surveys | On (all providers) | On (all providers) |
| WebFetch domain safety check | On (all providers) | On (all providers) |

#### WebFetch Domain Safety Check

Before fetching a URL, WebFetch sends **only the hostname** to `api.anthropic.com` to check against a safety blocklist. Results cached per hostname for 5 minutes. Disable with `skipWebFetchPreflight: true` in settings (not affected by `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`).

#### Encryption at Rest by Provider

| Provider | Encryption |
| :--- | :--- |
| Anthropic API | AES-256 disk encryption; ZDR available for no server-side persistence |
| Amazon Bedrock | AES-256, AWS-managed keys; CMEK via AWS KMS |
| Google Cloud Vertex AI | Google-managed keys; CMEK available |
| Microsoft Foundry | AES-256 via Anthropic infrastructure |

---

### Zero Data Retention (ZDR)

Available for Claude Code on **Claude for Enterprise** only (not Bedrock/Vertex/Foundry — use their own policies). Prompts and responses are not stored after the response is returned.

**Per-organization**: each new org must have ZDR enabled separately by the Anthropic account team.

#### What ZDR Covers vs. Does Not Cover

| Feature | ZDR status |
| :--- | :--- |
| Claude Code inference (terminal) | Covered — prompts and responses not retained |
| Chat on claude.ai | Not covered |
| Cowork sessions | Not covered |
| Claude Code Analytics | Not covered (collects usage metadata, not prompts) |
| User/seat management data | Not covered |
| Third-party MCP servers | Not covered |

#### Features Disabled Under ZDR

| Feature | Reason |
| :--- | :--- |
| Claude Code on the Web | Requires server-side storage of conversation history |
| Remote sessions from Desktop app | Requires persistent session data |
| Feedback submission (`/feedback`) | Sends conversation data to Anthropic |

Policy-violation data retention: up to 2 years even under ZDR.

**Request ZDR**: contact sales or your Anthropic account team.

---

### Enterprise Network Configuration

#### Proxy

```bash
export HTTPS_PROXY=https://proxy.example.com:8080
export HTTP_PROXY=http://proxy.example.com:8080
export NO_PROXY="localhost,192.168.1.1,example.com,.example.com"
# Basic auth:
export HTTPS_PROXY=http://username:password@proxy.example.com:8080
```

SOCKS proxies are not supported.

#### CA Certificates

| Config | Value |
| :--- | :--- |
| `CLAUDE_CODE_CERT_STORE` | Comma-separated: `bundled` (Mozilla CA set), `system` (OS store). Default: `bundled,system` |
| `NODE_EXTRA_CA_CERTS` | Path to custom CA `.pem` for enterprise CAs |

Enterprise TLS-inspection proxies (CrowdStrike Falcon, Zscaler) work without extra config when their root cert is in the OS trust store.

#### mTLS Authentication

```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="your-passphrase"   # optional
```

#### Required Network Allowlist

| URL | Required for |
| :--- | :--- |
| `api.anthropic.com` | Claude API requests |
| `claude.ai` | claude.ai account authentication |
| `platform.claude.com` | Anthropic Console authentication |
| `downloads.claude.ai` | Plugin downloads; native installer and auto-updater |
| `bridge.claudeusercontent.com` | Claude in Chrome extension WebSocket bridge |
| `raw.githubusercontent.com` | Changelog feed, release notes, plugin marketplace install counts |

When using Bedrock/Vertex/Foundry, model traffic goes to those providers. WebFetch still calls `api.anthropic.com` for its safety check unless `skipWebFetchPreflight: true`.

For GitHub Enterprise Cloud with IP allowlists: enable **IP allow list inheritance for installed GitHub Apps** so the Claude GitHub App's IP ranges are auto-included.

---

### Legal and Compliance

#### License / Terms

| Plan | Agreement |
| :--- | :--- |
| Team, Enterprise, API | Commercial Terms of Service |
| Free, Pro, Max | Consumer Terms of Service |

Existing commercial agreements (1P API, Bedrock, Vertex) extend to Claude Code unless mutually agreed otherwise.

#### Healthcare (BAA)

BAA automatically extends to cover Claude Code if the customer has:
1. An executed BAA with Anthropic
2. Zero Data Retention (ZDR) enabled

ZDR is per-organization; each org must have it enabled separately.

#### Authentication Policy

| Auth type | Who it's for |
| :--- | :--- |
| OAuth tokens | Purchasers of Free, Pro, Max, Team, Enterprise subscriptions for ordinary Claude Code use |
| API keys (Claude Console or cloud provider) | Developers building products/services or using the Agent SDK |

Third-party developers may not offer Claude.ai login or route requests through Free/Pro/Max credentials on behalf of users.

#### Vulnerability Reporting

Report security vulnerabilities via [HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new). Do not disclose publicly before Anthropic has addressed the issue.

Trust Center: https://trust.anthropic.com — includes SOC 2 Type 2, ISO 27001.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Security](references/claude-code-security.md) — core security model, permission architecture, prompt injection protections, MCP/IDE/cloud security, best practices, vulnerability reporting
- [Security-guidance plugin](references/claude-code-security-guidance.md) — in-session vulnerability review, three-layer checks, custom rules, env-var controls, troubleshooting
- [Configure the sandboxed Bash tool](references/claude-code-sandboxing.md) — modes, filesystem/network config, OS-level enforcement, org enforcement, custom proxy, limitations
- [Choose a sandbox environment](references/claude-code-sandbox-environments.md) — compare all isolation approaches, choose by goal, enforce across an org
- [Development containers](references/claude-code-devcontainer.md) — setup, auth persistence, org policy, network egress, running without prompts, reference container
- [Data usage](references/claude-code-data-usage.md) — training policy, retention periods, telemetry opt-outs, WebFetch safety check, encryption by provider
- [Zero data retention](references/claude-code-zero-data-retention.md) — ZDR scope, what's covered and not, disabled features, requesting ZDR
- [Enterprise network configuration](references/claude-code-network-config.md) — proxy setup, CA certificates, mTLS, network access allowlist
- [Legal and compliance](references/claude-code-legal-and-compliance.md) — license agreements, BAA/healthcare, authentication policy, vulnerability reporting

## Sources

- Security: https://code.claude.com/docs/en/security.md
- Security-guidance plugin: https://code.claude.com/docs/en/security-guidance.md
- Configure the sandboxed Bash tool: https://code.claude.com/docs/en/sandboxing.md
- Choose a sandbox environment: https://code.claude.com/docs/en/sandbox-environments.md
- Development containers: https://code.claude.com/docs/en/devcontainer.md
- Data usage: https://code.claude.com/docs/en/data-usage.md
- Zero data retention: https://code.claude.com/docs/en/zero-data-retention.md
- Enterprise network configuration: https://code.claude.com/docs/en/network-config.md
- Legal and compliance: https://code.claude.com/docs/en/legal-and-compliance.md
