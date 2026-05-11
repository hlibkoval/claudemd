---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, auto-mode configuration, and organization admin setup — settings scopes, precedence rules, all settings.json keys, permission rule syntax, managed-only settings, env var reference, and enterprise deployment decisions.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, auto-mode configuration, and organization admin setup.

## Quick Reference

### Configuration Scopes and File Locations

| Scope | Location | Shared with team? | Precedence |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, plist/registry, or `managed-settings.json` | Yes (IT-deployed) | Highest (1) |
| **Command line** | `--settings` flag | No | (2) |
| **Local** | `.claude/settings.local.json` | No (gitignored) | (3) |
| **Project** | `.claude/settings.json` | Yes (committed) | (4) |
| **User** | `~/.claude/settings.json` | No | Lowest (5) |

Other config files:

| File | Purpose |
| :--- | :--- |
| `~/.claude.json` | OAuth session, user-scope MCP config, per-project state |
| `.mcp.json` | Project-scope MCP servers |
| `CLAUDE.md` / `.claude/CLAUDE.md` | Memory / instructions (see memory-doc) |

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes — they are concatenated and de-duplicated, not replaced.

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules, defaultMode, sandbox | see below |
| `env` | Environment variables applied every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hooks | see hooks-doc |
| `autoMode` | Auto mode classifier config | see auto-mode-config |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Days before session files are deleted (default 30) | `20` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome!"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `editorMode` | `"normal"` (default) or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort: `low`/`medium`/`high`/`xhigh` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` servers | `true` |
| `language` | Claude's response language | `"japanese"` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `viewMode` | `"default"`, `"verbose"`, or `"focus"` | `"verbose"` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check | `true` |
| `enabledPlugins` | `"plugin@marketplace": true/false` | see plugins-doc |
| `extraKnownMarketplaces` | Add marketplace sources | see plugins-doc |
| `statusLine` | Custom status line command | `{"type":"command","command":"~/.claude/statusline.sh"}` |
| `worktree.baseRef` | `"fresh"` (default) or `"head"` | `"head"` |
| `autoMemoryEnabled` | Enable/disable auto memory (default true) | `false` |
| `attribution` | Git commit and PR attribution text | `{"commit":"...","pr":""}` |
| `plansDirectory` | Where plan files are stored | `"./plans"` |

The JSON schema at `https://json.schemastore.org/claude-code-settings.json` enables autocomplete in VS Code/Cursor.

### Permission Settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Rules that permit tool use without prompting | `["Bash(npm run *)"]` |
| `permissions.ask` | Rules that always prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.deny` | Rules that block tool use | `["WebFetch","Read(./.env)"]` |
| `permissions.defaultMode` | Starting permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to block bypass mode | `"disable"` |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass-mode confirmation | `true` |

Rule evaluation order: **deny → ask → allow**. First match wins.

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`

| Rule | Effect |
| :--- | :--- |
| `Bash` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Read(~/.zshrc)` | Reading home `.zshrc` |
| `Read(//Users/alice/*)` | Absolute path (double slash = absolute) |
| `Read(/src/**)` | Project-root-relative path |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

A single `*` matches any sequence including spaces. Space before `*` enforces word boundary: `Bash(ls *)` matches `ls -la` but not `lsof`.

Bash rules strip process wrappers (`timeout`, `nice`, `nohup`, `stdbuf`, bare `xargs`) before matching. Compound commands split on `&&`, `||`, `;`, `|` — each subcommand must match independently.

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, `mkdir`/`touch`/`mv`/`cp`/`rm`/`sed` | Iterating on code |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything, with background classifier | Long tasks, reducing fatigue |
| `dontAsk` | Only pre-approved tools | CI, locked-down scripts |
| `bypassPermissions` | Everything (no prompts) | Isolated containers/VMs only |

Switch with `Shift+Tab` in CLI, or `--permission-mode <mode>` at startup. Set persistent default with `permissions.defaultMode`.

**Auto mode requirements:** Max, Team, Enterprise, or API plan; Claude Sonnet 4.6 / Opus 4.6 / Opus 4.7; Anthropic API only (not Bedrock/Vertex/Foundry); Team/Enterprise require admin enablement.

**Protected paths** (never auto-approved except in bypassPermissions): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`), `.gitconfig`, `.bashrc`/`.zshrc`/`.profile`, `.mcp.json`, `.claude.json`.

### Managed-Only Settings

These keys are **only read from managed settings** (ignored in user/project files):

| Setting | Description |
| :--- | :--- |
| `allowedChannelPlugins` | Allowlist channel plugins that may push messages |
| `allowManagedHooksOnly` | Block all user/project hooks; only managed hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP servers are respected |
| `allowManagedPermissionRulesOnly` | Only managed allow/ask/deny rules apply |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Allow channels for the organization |
| `forceRemoteSettingsRefresh` | Block startup until remote settings freshly fetched |
| `pluginTrustMessage` | Custom message added to plugin trust warning |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowedDomains respected |
| `strictKnownMarketplaces` | Allowlist of permitted marketplace sources |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain too |

Also managed-only (per context): `policyHelper`, `parentSettingsBehavior`, `disableRemoteControl`.

### Sandbox Settings

Configure under `settings.json` → `sandbox`:

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable OS-level bash sandboxing |
| `sandbox.failIfUnavailable` | Hard fail at startup if sandbox can't start |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve sandboxed commands (default true) |
| `sandbox.excludedCommands` | Commands that run outside the sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default true) |
| `sandbox.filesystem.allowWrite` | Paths sandboxed commands can write to |
| `sandbox.filesystem.denyWrite` | Paths sandboxed commands cannot write to |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.filesystem.allowRead` | Re-allow reads within a denyRead region |
| `sandbox.network.allowedDomains` | Outbound domains allowed (supports wildcards) |
| `sandbox.network.deniedDomains` | Outbound domains blocked (takes precedence over allow) |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible (macOS only) |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |
| `sandbox.network.httpProxyPort` | HTTP proxy port for custom proxy |

Requires `bubblewrap` + `socat` on Linux/WSL2; macOS uses built-in Seatbelt.

### Auto Mode Configuration

Configure the classifier via `autoMode` (read from user settings, local project settings, managed settings — NOT shared `.claude/settings.json`):

| Field | Purpose |
| :--- | :--- |
| `autoMode.environment` | Prose list of trusted repos, buckets, domains |
| `autoMode.allow` | Exceptions to soft_deny blocks |
| `autoMode.soft_deny` | Destructive patterns; overridable by user intent or allow rules |
| `autoMode.hard_deny` | Unconditional security blocks; never overridable |

Include `"$defaults"` in any array to inherit built-in rules at that position. Omitting it replaces the entire default list.

Precedence inside the classifier: `hard_deny` > `soft_deny` > `allow` > explicit user intent.

CLI subcommands: `claude auto-mode defaults` (print built-ins), `claude auto-mode config` (print effective config), `claude auto-mode critique` (AI review of custom rules).

### Server-Managed Settings

Available for Teams and Enterprise plans. Delivered from Claude.ai admin console; received at auth time and polled hourly.

| Mechanism | Priority | Platforms |
| :--- | :--- | :--- |
| Server-managed (admin console) | Highest | All |
| plist / HKLM registry policy | High | macOS, Windows |
| File-based managed-settings.json | Medium | All |
| HKCU registry (Windows) | Lowest | Windows only |

Within managed tier, **first non-empty source wins** — sources do not merge across tiers.

File locations for file-based managed settings:
- macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
- Linux/WSL: `/etc/claude-code/managed-settings.json`
- Windows: `C:\Program Files\ClaudeCode\managed-settings.json`

Drop-in directory `managed-settings.d/*.json` (same location) allows separate teams to deploy independent fragments; base file merged first, then alphabetically sorted `*.json` files on top.

**Limitations of server-managed settings:** All users in org get same settings (no per-group config); MCP server configs not distributable; `policyHelper` and `wslInheritsWindowsSettings` require endpoint-managed delivery.

**Security approval dialogs** are shown to users before hooks, custom env vars, and shell-command settings are applied.

### Attribution Settings

Configure under `attribution`:

| Key | Description |
| :--- | :--- |
| `attribution.commit` | Attribution text for git commits; empty string = no attribution |
| `attribution.pr` | Attribution text for PR descriptions; empty string = no attribution |

### Key Environment Variables

A selection of the most commonly used variables (full list in reference):

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_MODEL` | Override model name |
| `ANTHROPIC_BASE_URL` | Proxy/gateway endpoint override |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default 120000) |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `CLAUDE_CODE_EFFORT_LEVEL` | Session effort: `low`/`medium`/`high`/`xhigh`/`max` |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen renderer |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess env |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy servers |
| `MCP_TIMEOUT` | MCP server startup timeout (default 30000) |
| `DISABLE_COMPACT` | Disable all context compaction |

All variables can also be set in `settings.json` under the `env` key to apply to every session.

### Organization Admin Setup Decision Map

| Decision | What you're choosing |
| :--- | :--- |
| API provider | Claude Teams/Enterprise vs. Console vs. Bedrock/Vertex/Foundry |
| Settings delivery | Server-managed (admin console) vs. plist/registry vs. file-based |
| Enforcement | Permission rules, sandboxing, MCP control, plugin marketplace control |
| Usage visibility | OpenTelemetry monitoring, analytics dashboard, cost tracking |
| Data handling | Standard retention vs. ZDR, encryption, compliance posture |

Verify managed settings delivery with `/status` — look for `Enterprise managed settings (remote|plist|HKLM|HKCU|file)`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — all settings.json keys, configuration scopes, settings files, precedence rules, permission/sandbox/attribution/hook/plugin settings, worktree settings
- [Permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns, working directories, managed settings, managed-only settings table
- [Permission Modes](references/claude-code-permission-modes.md) — all modes, switching modes, auto mode requirements and classifier behavior, dontAsk, bypassPermissions, protected paths
- [Auto Mode Configuration](references/claude-code-auto-mode-config.md) — defining trusted infrastructure, overriding block/allow rules, CLI subcommands, reviewing denials
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — configuring via admin console, delivery and caching, security approval dialogs, fail-closed startup, security considerations
- [Environment Variables](references/claude-code-env-vars.md) — complete reference for all environment variables controlling Claude Code behavior
- [Organization Admin Setup](references/claude-code-admin-setup.md) — deployment decision map: API providers, settings delivery mechanisms, enforcement controls, usage visibility, data handling

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Auto Mode Configuration: https://code.claude.com/docs/en/auto-mode-config.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Organization Admin Setup: https://code.claude.com/docs/en/admin-setup.md
