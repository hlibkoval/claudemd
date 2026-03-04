---
name: settings-doc
description: Claude Code settings, permissions, and server-managed settings — configuration scopes, settings.json fields, permission rules and modes, sandbox settings, managed-only settings, and enterprise policy delivery.
user-invocable: false
---

# Claude Code Settings Quick Reference

## Configuration Scopes & Precedence

| Scope | Location | Shared? | Precedence |
|-------|----------|---------|-----------|
| **Managed** | Server, plist/registry, or `managed-settings.json` | Yes (IT deployed) | Highest |
| **Local** | `.claude/settings.local.json` | No (gitignored) | 3rd |
| **Project** | `.claude/settings.json` | Yes (committed) | 4th |
| **User** | `~/.claude/settings.json` | No | Lowest |

Command line arguments override local/project/user settings but not managed.

## Settings File Locations

| Feature | User | Project | Local |
|---------|------|---------|-------|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| MCP | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md` |

## Key `settings.json` Fields

| Key | Description |
|-----|-------------|
| `permissions` | `allow`, `ask`, `deny`, `defaultMode`, `additionalDirectories` |
| `model` | Override default model (e.g. `"claude-sonnet-4-6"`) |
| `availableModels` | Restrict which models users can select |
| `hooks` | Lifecycle hook commands |
| `env` | Environment variables for every session |
| `language` | Claude's response language (e.g. `"japanese"`) |
| `outputStyle` | System prompt adjustment style |
| `statusLine` | Custom status line config |
| `cleanupPeriodDays` | Session retention (default: 30) |
| `companyAnnouncements` | Messages shown at startup |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `attribution` | Customize git commit/PR attribution |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Custom plan file storage path |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `teammateMode` | Agent team display: `auto`, `in-process`, `tmux` |

## Permission Modes (`defaultMode`)

| Mode | Description |
|------|-------------|
| `default` | Prompts on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions |
| `plan` | Analysis only — no file edits or commands |
| `dontAsk` | Auto-denies unless pre-approved |
| `bypassPermissions` | Skips all prompts (isolated environments only) |

## Permission Rule Syntax

Rules evaluated: **deny → ask → allow** (first match wins)

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git commit *)", "Read(~/.zshrc)"],
    "deny":  ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "ask":   ["Bash(git push *)"]
  }
}
```

### Rule Patterns

| Pattern | Matches |
|---------|---------|
| `Bash(npm run build)` | Exact command |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Read(./.env)` | Specific file |
| `Read(./secrets/**)` | Recursive directory |
| `WebFetch(domain:example.com)` | Specific domain |
| `mcp__puppeteer` | All tools from MCP server |
| `Agent(Explore)` | Specific subagent |

### Read/Edit Path Prefixes

| Prefix | Meaning |
|--------|---------|
| `//path` | Absolute from filesystem root |
| `~/path` | From home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to current directory |

## Managed-Only Settings

| Setting | Description |
|---------|-------------|
| `disableBypassPermissionsMode` | Set `"disable"` to block `bypassPermissions` |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `allowManagedHooksOnly` | Block user/project/plugin hooks |
| `allowManagedMcpServersOnly` | Restrict to admin-defined MCP allowlist |
| `blockedMarketplaces` | Block plugin marketplace sources |
| `strictKnownMarketplaces` | Control which marketplaces users can add |
| `allow_remote_sessions` | Allow/deny Remote Control & web sessions |

## Server-Managed Settings (Beta)

Available for Teams/Enterprise. Configure via Claude.ai admin console:
**Admin Settings → Claude Code → Managed settings**

- Delivered at auth time, cached locally, polled hourly
- Take precedence over endpoint-managed settings
- Security dialogs shown for shell commands, env vars, hooks
- Not available with Bedrock/Vertex/Foundry/custom `ANTHROPIC_BASE_URL`

## Managed Settings Delivery (Endpoint)

- **macOS**: `com.anthropic.claudecode` managed preferences (MDM)
- **Windows**: `HKLM\SOFTWARE\Policies\ClaudeCode` registry key
- **File**: `managed-settings.json` in `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows)

## Reference Files

- [claude-code-settings.md](references/claude-code-settings.md) — full settings reference
- [claude-code-permissions.md](references/claude-code-permissions.md) — permission system, modes, rule syntax
- [claude-code-server-managed-settings.md](references/claude-code-server-managed-settings.md) — server-managed settings for organizations
