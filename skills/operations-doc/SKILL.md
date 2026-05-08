---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting performance and stability, debug configuration, error reference, installation troubleshooting, changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running, monitoring, troubleshooting, and staying current with Claude Code.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics setup (Teams/Enterprise):**
1. GitHub admin installs Claude app at github.com/apps/claude
2. Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle and complete GitHub auth flow
- Data appears within 24 hours; not available with Zero Data Retention

**Key contribution metrics:**
- PRs with CC, Lines of code with CC, PRs with CC (%), Suggestion accept rate
- PR attribution window: 21 days before → 2 days after merge
- Excluded: lock files, generated code, dist/build/node_modules, lines >1,000 chars

### Cost Tracking and Management

**In-session tracking:**
- `/usage` — session token counts and cost estimate (local estimate, not authoritative billing)
- `/context` — breakdown of what's consuming context window

**Team spend management:**
- Set workspace spend limits at platform.claude.com (API customers)
- "Claude Code" workspace auto-created on first Console login; no API keys can be created for it

**Rate limit recommendations (API):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**
- `/clear` between unrelated tasks; `/compact Focus on X` for focused compaction
- `/model` to switch to Sonnet for most tasks; reserve Opus for complex work
- Move detailed workflow instructions from CLAUDE.md into skills (load on-demand)
- Use `MAX_THINKING_TOKENS=8000` or `/effort low` for simpler tasks
- Delegate verbose operations (test runs, log processing) to subagents
- Install code intelligence plugins to replace grep-based exploration

**Agent teams cost tips:**
- Use Sonnet for teammates (not Opus)
- Keep teams small; token usage scales with active teammates
- Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to enable; teams are off by default

### OpenTelemetry Monitoring

**Quick start:**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp       # or: prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp          # or: console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Description |
| :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required — enables telemetry |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers, e.g. `Authorization=Bearer token` |
| `OTEL_LOG_USER_PROMPTS` | Set `1` to include prompt content (redacted by default) |
| `OTEL_LOG_TOOL_DETAILS` | Set `1` to include Bash commands, MCP names, file paths |
| `OTEL_LOG_TOOL_CONTENT` | Set `1` to include tool input/output in spans (requires tracing) |
| `OTEL_LOG_RAW_API_BODIES` | `1` for inline bodies (60KB limit) or `file:<dir>` for untruncated |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Set `1` to enable distributed tracing (beta) |

**Exported metrics:**

| Metric | Description |
| :--- | :--- |
| `claude_code.session.count` | Sessions started |
| `claude_code.token.usage` | Tokens per request (input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage` | Estimated cost in USD |
| `claude_code.lines_of_code.count` | Lines added/removed |
| `claude_code.commit.count` | Git commits created |
| `claude_code.pull_request.count` | PRs created |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject counts |
| `claude_code.active_time.total` | Active time in seconds |

**Key events:** `user_prompt`, `tool_result`, `api_request`, `api_error`, `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `compaction`, `plugin_installed`, `skill_activated`

**Standard attributes on all metrics/events:** `session.id`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

**Multi-team segmentation:**
```bash
export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"
```
(No spaces in values; use underscores or percent-encode)

**Traces (beta):** set both `CLAUDE_CODE_ENABLE_TELEMETRY=1` and `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` plus `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` → `llm_request`, `tool`, `hook`.

**Admin deployment (managed settings):**
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector.example.com:4317"
  }
}
```

**SIEM integration:** point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver. Set `OTEL_LOG_TOOL_DETAILS=1` for full MCP/Bash audit trail.

**Security audit event map:**

| Signal | Event | Key attributes |
| :--- | :--- | :--- |
| Tool allowed/denied | `tool_decision` | `decision`, `source`, `tool_name` |
| Permission mode escalation | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Login/logout | `auth` | `action`, `success` |
| MCP server connect/fail | `mcp_server_connection` | `status`, `server_name` |
| Plugin installed | `plugin_installed` | `plugin.name`, `marketplace.name` |

### Troubleshooting (Runtime)

**Quick triage — go to the right page:**

| Symptom | Page |
| :--- | :--- |
| `command not found`, install fails, PATH, TLS | Troubleshoot installation and login |
| Login loops, OAuth errors, 403, org disabled | Troubleshoot installation and login |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529`, `429`, request validation | Error reference |
| High CPU/memory, hangs, search not finding files | Troubleshooting (performance) |

Run `/doctor` for an automated check of installation, settings, MCP, and context usage. If `claude` won't start, run `claude doctor` from your shell.

**Performance and stability:**
- High CPU/memory: `/compact` regularly, restart between major tasks, add large build dirs to `.gitignore`
- `/heapdump` writes heap snapshot + memory breakdown to `~/Desktop` (Linux: home dir)
- Auto-compaction thrashing (`Autocompact is thrashing`): read files in smaller chunks, run `/compact keep only the plan`, use a subagent, or `/clear`
- Hangs/freezes: Ctrl+C; restart with `claude --resume` to recover session
- Search issues (ripgrep): install platform ripgrep and set `USE_BUILTIN_RIPGREP=0`
- WSL slow search: keep projects on Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`)

### Debug Configuration

**Key diagnostic commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window by category |
| `/memory` | Which CLAUDE.md files loaded |
| `/hooks` | Active hooks for the session |
| `/mcp` | Connected MCP servers and status |
| `/doctor` | Config validation, schema errors, installation health |
| `/status` | Active settings sources, managed settings status |
| `/debug [issue]` | Enables debug logging and prompts Claude to diagnose |

**Clean-config test:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```
Bypasses all user/project settings to isolate the cause.

**Common config problems:**

| Symptom | Fix |
| :--- | :--- |
| Hook never fires | `matcher` must be a string with `\|`, not an array; tool names are capitalized (`Bash`, `Edit`) |
| Permissions/hooks ignored globally | Use `~/.claude/settings.json`, not `~/.claude.json` |
| Settings.json value seems ignored | Check `settings.local.json` — it overrides `settings.json` |
| Skill not in `/skills` | Must be a folder: `.claude/skills/name/SKILL.md` |
| MCP server in `.mcp.json` not loading | File goes at repo root, not inside `.claude/` |

### Error Reference

**Retry behavior:** Claude Code retries up to 10 times with exponential backoff before showing an error.

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in ms |

**Error quick-reference:**

| Error | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Check status.claude.com; retry; run `/feedback` |
| `529 Overloaded` | Server | Wait; switch model with `/model` |
| `Request timed out` | Server | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session/weekly limit` | Usage | Wait for reset; `/extra-usage` to buy more; `/usage` to check limits |
| `Request rejected (429)` | Rate limit | Lower concurrency; check active credential with `/status` |
| `Credit balance is too low` | Billing | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for typos; run `env \| grep ANTHROPIC` for stale keys |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; use subscription auth |
| `OAuth token revoked/expired` | Auth | Run `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy; set `HTTPS_PROXY`; verify firewall allows `api.anthropic.com` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | `/compact` or `/clear`; disable unused MCP servers; trim CLAUDE.md |
| `There's an issue with the selected model` | Request | Run `/model` to pick available model; use alias like `sonnet` not versioned ID |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `API Error: 400 due to tool use concurrency issues` | Request | Run `/rewind` or press Esc twice |

**Quality issues (no error shown):** check `/model` for unexpected model, `/effort` for reasoning level, `/context` for window pressure, `/doctor` for oversized memory files.

### Installation Troubleshooting

**Install locations:**
- macOS/Linux native: `~/.local/bin/claude`
- Windows native: `%USERPROFILE%\.local\bin\claude.exe`
- Prefer native installer over npm global install

**Common install errors:**

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; reload shell config |
| `syntax error near unexpected token '<'` | Install script returned HTML — try Homebrew or WinGet |
| `curl: (56) Failure writing output to destination` | Network interruption; retry or use `brew install --cask claude-code` |
| `Killed` on Linux VPS | Add 2GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| `dyld: cannot load` on macOS | Requires macOS 13+; update macOS |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `Illegal instruction` | Pre-2013 CPU or VM without AVX passthrough; no native binary workaround |
| `Error loading shared library` | musl/glibc mismatch; check `ldd --version` |
| TLS connect errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |

**Verify PATH:**
```bash
# macOS/Linux
echo $PATH | tr ':' '\n' | grep -Fx "$HOME/.local/bin"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

# Windows PowerShell
$env:PATH -split ';' | Select-String '\.local\\bin'
```

**Authentication issues:**
- Login loops: run `/logout` then `/login`; check system clock accuracy
- macOS Keychain locked: `security unlock-keychain ~/Library/Keychains/login.keychain-db`
- WSL2/SSH browser redirect: paste the code shown in terminal at the `Paste code here` prompt
- `ANTHROPIC_API_KEY` from disabled org overriding subscription: `unset ANTHROPIC_API_KEY`
- Bedrock: verify with `aws sts get-caller-identity`
- Vertex AI: `gcloud auth application-default login`; set `ANTHROPIC_VERTEX_PROJECT_ID` and `CLOUD_ML_REGION`

### Recent Changes (What's New)

**Week 17 (April 20–24, 2026 · v2.1.114–v2.1.119):**
- `/ultrareview` — public research preview; fleet of bug-hunting agents runs in the cloud; findings land in CLI or Desktop
- Session recap — automatic one-line recap when returning to a terminal; `/recap` for on-demand
- Custom themes — `/theme` picker or `~/.claude/themes/` JSON files; plugins can ship themes

**Week 16 (April 13–17, 2026 · v2.1.105–v2.1.113):**
- Claude Opus 4.7 — new default on Max and Team Premium; `xhigh` effort level added
- Routines — templated cloud agents triggered by schedule, GitHub event, or API call
- `/usage` breakdown — shows what's driving limits (parallel sessions, subagents, cache misses)
- Native binaries replace bundled JavaScript

**Week 15 (April 6–10, 2026 · v2.1.92–v2.1.101):**
- Ultraplan — draft plans in cloud, review in web editor, run remotely or pull local
- Monitor tool — streams background events into conversation for live log tailing

**Week 14 (March 30 – April 3, 2026 · v2.1.86–v2.1.91):**
- Computer use — research preview; Claude can open native apps and click through UI

**Week 13 (March 23–27, 2026 · v2.1.83–v2.1.85):**
- Auto mode — classifier handles permission prompts; safe actions run without interruption

**Check your version:** `claude --version`

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — usage dashboards, contribution metrics setup, PR attribution, GitHub integration, API customer Console analytics
- [Costs](references/claude-code-costs.md) — tracking with `/usage`, team spend limits, rate limit recommendations, agent team costs, and token reduction strategies
- [Monitoring Usage](references/claude-code-monitoring-usage.md) — OpenTelemetry quick start, all configuration variables, metrics, events, traces (beta), audit security events, SIEM integration
- [Debug Your Configuration](references/claude-code-debug-your-config.md) — `/context`, `/doctor`, `/hooks`, `/mcp`, common causes table, clean-config testing
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, stability, auto-compaction thrashing, hangs, search/ripgrep issues
- [Error Reference](references/claude-code-errors.md) — runtime errors by category: server, usage limits, auth, network, request errors, and quality issues
- [Troubleshoot Installation and Login](references/claude-code-troubleshoot-install.md) — PATH, install failures, Windows/WSL issues, binary compatibility, OAuth errors, Bedrock/Vertex credentials
- [Changelog](references/claude-code-changelog.md) — full release notes by version
- [What's New Index](references/claude-code-whats-new-index.md) — weekly feature digest index
- [What's New Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [What's New Week 16](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, Routines, /usage breakdown, native binaries
- [What's New Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /team-onboarding
- [What's New Week 14](references/claude-code-whats-new-2026-w14.md) — Computer use research preview, /powerup, flicker-free rendering
- [What's New Week 13](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use in Desktop, PR auto-fix on Web

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring Usage: https://code.claude.com/docs/en/monitoring-usage.md
- Debug Your Configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Error Reference: https://code.claude.com/docs/en/errors.md
- Troubleshoot Installation and Login: https://code.claude.com/docs/en/troubleshoot-install.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New Index: https://code.claude.com/docs/en/whats-new/index.md
- What's New Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
