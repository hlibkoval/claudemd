---
name: operations-doc
description: Reference documentation for operating Claude Code at scale: analytics and dashboards, cost tracking and spend limits, OpenTelemetry monitoring, troubleshooting (performance/stability/search), installation and login error fixes, configuration debugging, runtime error codes, and the changelog and weekly What's New digests. Use when questions involve costs, usage metrics, OTel setup, errors, debugging configs, or recent releases.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code at scale.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Available Metrics |
|------|--------------|-------------------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage, contribution (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend, team insights per user |

**Contribution metrics** (Teams/Enterprise, public beta): require GitHub app install + Owner enabling at claude.ai/admin-settings/claude-code. Data updates daily. Not available with Zero Data Retention. Attribution window: 21 days before to 2 days after PR merge.

### Cost Tracking

| Command | Purpose |
|---------|---------|
| `/usage` | Current session token usage and cost estimate; plan usage breakdown on Pro/Max/Team |
| `/usage-credits` | Buy or request additional usage credits |
| `/model` | Switch models mid-session to manage costs |
| `/compact [focus]` | Summarize history to reduce context size |
| `/clear` | Start fresh session |

**Typical costs**: ~$13/developer/active day; ~$150–250/month. 90% of users stay under $30/active day.

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
|-----------|-------------|-------------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Token reduction strategies**: Use `/effort` to lower thinking budget; move CLAUDE.md instructions to skills (load on-demand); use subagents for verbose operations; install code intelligence plugins; preprocess with hooks; write specific prompts.

### OpenTelemetry Monitoring

**Quick start env vars:**

| Variable | Purpose | Example Values |
|----------|---------|---------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval ms (default: 60000) | `10000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms (default: 5000) | `5000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) | `1` |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params/commands (default: off) | `1` |
| `OTEL_LOG_TOOL_CONTENT` | Log tool I/O in spans (default: off) | `1` |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response bodies | `1` or `file:<dir>` |

**Exported metrics:**

| Metric | Unit | Description |
|--------|------|-------------|
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.token.usage` | tokens | Tokens used (type: input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage` | USD | API cost per request |
| `claude_code.lines_of_code.count` | count | Lines modified (type: added/removed) |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept/reject decisions |
| `claude_code.active_time.total` | s | Active time (type: user/cli) |

**Key OTel events**: `user_prompt`, `tool_result`, `tool_decision`, `api_request`, `api_error`, `api_refusal`, `mcp_server_connection`, `permission_mode_changed`, `auth`, `compaction`, `plugin_installed`, `plugin_loaded`, `skill_activated`, `hook_registered`, `hook_execution_start`, `hook_execution_complete`

**Traces (beta)**: enable with `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request` / `claude_code.tool` (→ `blocked_on_user` + `execution`) / `claude_code.hook`.

**Administrator config**: deploy via managed settings file using `"env"` key. Dynamic headers via `otelHeadersHelper` script in settings.json. Runs every 29 min by default (`CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` to customize).

### Troubleshooting Quick Reference

**Which page to go to:**

| Symptom | Resource |
|---------|----------|
| `command not found`, PATH issues, TLS errors, install fails | Troubleshoot installation and login |
| OAuth errors, 403 Forbidden, login loops, Bedrock/Vertex credentials | Troubleshoot installation and login (login section) |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| API errors (5xx, 529, 429), request validation | Error reference |
| High CPU/memory, hangs, search not finding files | Troubleshooting (performance) |

**Common configuration issues:**

| Symptom | Cause | Fix |
|---------|-------|-----|
| Hook never fires | `matcher` is array, not string | Use `"Edit\|Write"` (pipe-separated string) |
| Hook never fires | Lowercase tool name in matcher | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Settings key ignored | Set in `~/.claude.json` instead of `~/.claude/settings.json` | These are different files |
| `settings.json` value ignored | Same key in `settings.local.json` | Local overrides project; project overrides user |
| Skill not in `/skills` | `.claude/skills/name.md` instead of folder | Use `.claude/skills/name/SKILL.md` |
| MCP server in `.mcp.json` never loads | File placed under `.claude/` | Must be at repo root as `.mcp.json` |

**Debug commands:**

| Command | Shows |
|---------|-------|
| `/context` | Everything in context window by category |
| `/memory` | Which CLAUDE.md files loaded |
| `/skills` | Available skills |
| `/hooks` | Active hook configurations |
| `/mcp` | MCP server status |
| `/doctor` | Config diagnostics, invalid keys, schema errors |
| `/status` | Active settings sources |
| `/debug [issue]` | Enable debug logging |

**Clean test**: `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude`  
**Safe mode**: `claude --safe-mode` — disables CLAUDE.md, plugins, skills, hooks, MCP servers (requires v2.1.169+)

### Runtime Error Quick Reference

**Automatic retries**: Claude Code retries up to 10 times (tunable via `CLAUDE_CODE_MAX_RETRIES`). `API_TIMEOUT_MS` defaults to 600000ms.

| Error | Category | Fix |
|-------|----------|-----|
| `API Error: 500` | Server | Check status.claude.com; retry |
| `API Error: 529 Overloaded` | Server | Retry or `/model` switch |
| `Request timed out` | Server | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session limit` | Usage | Wait for reset or `/usage-credits` |
| `Request rejected (429)` | Rate limit | Lower concurrency; check Console limits |
| `Credit balance is too low` | Usage | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check key not revoked; unset stale `ANTHROPIC_API_KEY` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; use subscription auth |
| `OAuth token revoked or expired` | Auth | `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy (`HTTPS_PROXY`); check firewall rules |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | `/compact` or `/clear`; disable unused MCP servers |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| `There's an issue with the selected model` | Request | `/model` to pick valid model; check `ANTHROPIC_MODEL` env var |

### Recent Releases (What's New)

| Week | Dates | Key Feature | Versions |
|------|-------|-------------|---------|
| W22 | May 25–29, 2026 | Claude Opus 4.8 default; dynamic workflows; security-guidance plugin | v2.1.150–157 |
| W21 | May 18–22, 2026 | Auto mode on Pro plan; `/usage` breakdown by skill/agent/MCP | v2.1.143–149 |
| W20 | May 11–15, 2026 | Agent view (`claude agents`); `/goal` command; fast mode on Opus 4.7 | v2.1.139–142 |
| W19 | May 4–8, 2026 | Plugin loading from `.zip`/URLs; auto mode hard deny rules | v2.1.128–136 |
| W18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell tool); `claude ultrareview` | v2.1.120–126 |
| W17 | Apr 20–24, 2026 | `/ultrareview` cloud bug-hunting agents; custom themes; web redesign | v2.1.114–119 |
| W16 | Apr 13–17, 2026 | Claude Opus 4.7 default; `xhigh` effort; Routines; native binaries | v2.1.105–113 |
| W15 | Apr 6–10, 2026 | Ultraplan; Monitor tool; `/loop` self-pacing | v2.1.92–101 |
| W14 | Mar 30–Apr 3, 2026 | Computer use (research preview) CLI; `/powerup` lessons | v2.1.86–91 |
| W13 | Mar 23–27, 2026 | Auto mode (research preview); native PowerShell tool; conditional `if` hooks | v2.1.83–85 |

**Latest release: v2.1.170** (June 9, 2026) — Claude Fable 5 (Mythos-class model); fixed session transcript saving from VS Code integrated terminal.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API customers, contribution metrics with GitHub integration, PR attribution
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking, spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, available metrics and events, traces (beta), audit/SIEM integration
- [Troubleshooting](references/claude-code-troubleshooting.md) — Performance/stability issues, high CPU/memory, auto-compaction thrashing, search problems
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — Installation errors, PATH issues, TLS errors, login and authentication failures
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnosing CLAUDE.md, settings, hooks, MCP, and skill configuration issues
- [Error reference](references/claude-code-errors.md) — Runtime error messages with causes and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full release notes by version
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digests index (W13–W22, 2026)
- [What's new W13](references/claude-code-whats-new-2026-w13.md) — Auto mode research preview, PowerShell tool, conditional hooks
- [What's new W14](references/claude-code-whats-new-2026-w14.md) — Computer use CLI preview, /powerup, per-tool MCP result-size override
- [What's new W15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop self-pacing, /autofix-pr
- [What's new W16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7 default, xhigh effort, Routines, mobile push notifications, native binaries
- [What's new W17](references/claude-code-whats-new-2026-w17.md) — /ultrareview public preview, session recap, custom themes, web redesign
- [What's new W18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview in CI, claude project purge
- [What's new W19](references/claude-code-whats-new-2026-w19.md) — Plugin loading from zip/URL, auto mode hard deny rules, hooks see effort level
- [What's new W20](references/claude-code-whats-new-2026-w20.md) — Agent view, /goal command, fast mode on Opus 4.7, Rewind menu compression
- [What's new W21](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro plan with Sonnet 4.6, /usage breakdown, /code-review command
- [What's new W22](references/claude-code-whats-new-2026-w22.md) — Opus 4.8 default, dynamic workflows, security-guidance plugin, fast mode on Opus 4.8

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new W20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new W21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new W22: https://code.claude.com/docs/en/whats-new/2026-w22.md
