---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating Claude Code at scale: analytics, cost management, OpenTelemetry monitoring, troubleshooting, and release notes.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Key metrics |
|------|--------------|-------------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API / Console | platform.claude.com/claude-code | Usage, spend, per-user lines/cost |

Contribution metrics require GitHub app installation + Owner-level toggle at `claude.ai/admin-settings/claude-code`. Data appears within 24 hours; updated daily. Not available with Zero Data Retention enabled.

**Attribution rules:** PRs tagged `claude-code-assisted` if ≥1 line matched; 21-day session window; >20% developer rewrite disqualifies; auto-generated files (lock files, dist/, build/) excluded.

### Cost management

| Technique | Command / Setting |
|-----------|------------------|
| Check session cost | `/cost` (API users); `/stats` (subscribers) |
| Clear context | `/clear` or `/compact Focus on X` |
| Switch model mid-session | `/model` |
| Set effort level | `/effort` |
| Limit extended thinking | `MAX_THINKING_TOKENS=8000` |
| View context breakdown | `/context` |

**Rate limit recommendations (TPM per user):**

| Team size | TPM/user | RPM/user |
|-----------|----------|----------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost averages:** ~$13/developer/active day; $150–250/month; 90th percentile under $30/active day.

**Agent team note:** ~7x token usage vs standard sessions. Prefer Sonnet for teammates; keep teams small.

### OpenTelemetry monitoring

**Enable telemetry (minimum config):**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Purpose | Default |
|----------|---------|---------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics backend | — |
| `OTEL_LOGS_EXPORTER` | Events/logs backend | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics flush interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs flush interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt text in events | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Include tool params/args | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Include tool I/O in spans | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response JSON | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | user.account_uuid in metrics | true |
| `OTEL_METRICS_INCLUDE_VERSION` | app.version in metrics | false |

**Traces (beta):** Set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER`. Subprocesses inherit `TRACEPARENT` for distributed tracing. Spans redact prompts and tool content by default.

**Dynamic headers:** Set `otelHeadersHelper` in `.claude/settings.json` to a script that outputs JSON headers; refreshes every 29 minutes by default.

**Available metrics:**

| Metric | Unit | Notes |
|--------|------|-------|
| `claude_code.session.count` | count | Per session start |
| `claude_code.token.usage` | tokens | type: input/output/cacheRead/cacheCreation |
| `claude_code.cost.usage` | USD | Approximate; per API request |
| `claude_code.lines_of_code.count` | count | type: added/removed |
| `claude_code.commit.count` | count | Git commits via Claude Code |
| `claude_code.pull_request.count` | count | PRs created via Claude Code |
| `claude_code.code_edit_tool.decision` | count | accept/reject for Edit/Write/NotebookEdit |
| `claude_code.active_time.total` | s | type: user/cli |

**Events (via `OTEL_LOGS_EXPORTER`):** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_request_body`, `claude_code.api_response_body`, `claude_code.tool_decision`, `claude_code.plugin_installed`, `claude_code.skill_activated`. All events carry a `prompt.id` UUID for correlation within a single user turn.

### Troubleshooting quick-lookup

| Symptom | Solution |
|---------|----------|
| `command not found: claude` | Fix PATH: add `~/.local/bin` to shell profile |
| HTML instead of install script | Regional block or network issue; try Homebrew/WinGet |
| `curl: (56) Failure writing output` | Network interruption; retry or use Homebrew/WinGet |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate CA |
| `Killed` during install (Linux) | Add 2 GB swap; need ≥4 GB RAM |
| Install hangs in Docker | Set `WORKDIR /tmp` before install |
| `Illegal instruction` on Linux | CPU/arch mismatch; verify with `uname -m` |
| `dyld: cannot load` on macOS | macOS <13.0; update or use Homebrew |
| `command not found` after WSL install | Use Linux npm/node, not Windows paths |
| OAuth error / 403 Forbidden | `/logout` then re-login; check subscription/role |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` env var overriding OAuth |
| High CPU/memory | `/compact` regularly; use subagents for verbose ops |
| Autocompact thrashing | `/compact keep only X`; read files in chunks; use subagent |
| Search not working | Install system ripgrep; set `USE_BUILTIN_RIPGREP=0` |
| JetBrains not detected on WSL2 | Configure Windows Firewall for WSL2 subnet or use mirrored networking |

**Config file locations:**

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

**Diagnostic commands:** `/doctor` (checks install, settings, MCP, plugins), `/heapdump` (memory snapshot), `claude --version`.

### Recent releases (What's New)

| Week | Dates | Highlights |
|------|-------|-----------|
| W15 | Apr 6–10, 2026 (v2.1.92–101) | Ultraplan cloud planning, Monitor tool + self-pacing /loop, /autofix-pr CLI, /team-onboarding |
| W14 | Mar 30 – Apr 3, 2026 (v2.1.86–91) | Computer use in CLI, /powerup lessons, flicker-free rendering, MCP per-tool result-size override, plugin bin/ on PATH |
| W13 | Mar 23–27, 2026 (v2.1.83–85) | Auto mode (permissions classifier), computer use in Desktop, PR auto-fix on Web, transcript search (/), PowerShell tool, conditional hooks |

Latest release as of docs: **v2.1.116** (April 20, 2026). Run `claude --version` to check your version.

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — Team/Enterprise and API analytics dashboards, GitHub contribution metrics, PR attribution methodology
- [Costs](references/claude-code-costs.md) — Cost tracking, team spend limits, rate limit recommendations, token reduction strategies
- [Monitoring](references/claude-code-monitoring-usage.md) — Full OpenTelemetry configuration reference, all metrics/events schemas, backend recommendations
- [Troubleshooting](references/claude-code-troubleshooting.md) — Installation, auth, performance, IDE, and markdown issues with step-by-step fixes
- [Changelog](references/claude-code-changelog.md) — Full version-by-version release notes
- [What's New Index](references/claude-code-whats-new-index.md) — Weekly digest index linking to recent feature highlights
- [What's New W13](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use, PR auto-fix, transcript search, PowerShell tool, conditional hooks
- [What's New W14](references/claude-code-whats-new-2026-w14.md) — Computer use in CLI, /powerup, flicker-free rendering, MCP result-size override, plugin bin/
- [What's New W15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /autofix-pr, /team-onboarding

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New Index: https://code.claude.com/docs/en/whats-new/index.md
- What's New W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
