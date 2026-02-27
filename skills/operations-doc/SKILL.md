---
name: operations-doc
description: Reference documentation for operating Claude Code at scale — analytics dashboards, cost tracking, token usage, OpenTelemetry monitoring, troubleshooting installation and auth issues, and the changelog. Load when asked about costs, spend limits, usage metrics, telemetry, monitoring, or diagnosing problems.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running and operating Claude Code — covering analytics, cost management, OpenTelemetry monitoring, troubleshooting, and the release changelog.

## Quick Reference

### Cost Estimates

| Scope | Typical cost |
|:------|:-------------|
| Individual developer | ~$6/day; 90% of users stay under $12/day |
| Team (API) | ~$100–200/developer/month with Sonnet 4.6 |
| Background idle | Under $0.04/session |

Use `/cost` in-session to see current token spend. Use `/stats` for subscription users (Max/Pro).

### Rate Limit Recommendations (API teams)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

### Analytics Dashboards

| Plan | URL | Features |
|:-----|:----|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

To enable contribution metrics (Teams/Enterprise): install the GitHub app at github.com/apps/claude, then enable Claude Code analytics and GitHub analytics in admin settings at claude.ai/admin-settings/claude-code.

### Cost Reduction Strategies

| Strategy | How |
|:---------|:----|
| Clear context between tasks | `/clear` to start fresh; `/compact Focus on X` for custom compaction |
| Choose the right model | `/model` to switch; use Haiku for simple subagents |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools over MCP |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; use skills for specialized workflows |
| Reduce extended thinking | Lower effort in `/model`, set `MAX_THINKING_TOKENS=8000`, or disable in `/config` |
| Delegate verbose ops | Use subagents to isolate high-output operations |

### OpenTelemetry Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp           # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

### Key OTel Environment Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s), comma-separated | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s), comma-separated | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content in events | off |
| `OTEL_LOG_TOOL_DETAILS` | Include MCP/skill names in tool events | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include `session.id` in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include `user.account_uuid` in metrics | true |

### Exported Metrics

| Metric | Unit | Description |
|:-------|:-----|:------------|
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines of code modified (`type`: added/removed) |
| `claude_code.pull_request.count` | count | Pull requests created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Cost per API request (`model` attribute) |
| `claude_code.token.usage` | tokens | Tokens used (`type`: input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept or reject decisions |
| `claude_code.active_time.total` | s | Active time (`type`: user/cli) |

### Troubleshooting Quick Lookup

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install script returns HTML | Network/region issue; try Homebrew or WinGet |
| `curl: (56) Failure writing output` | Network interrupted; retry or use Homebrew |
| `Killed` during install on Linux | Add 2 GB swap space (needs 4 GB RAM) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate CA |
| `403 Forbidden` after login | Check subscription or Console role assignment |
| JetBrains not detected on WSL2 | Configure Windows Firewall or switch to mirrored networking |
| Search/`@file` not working | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| High CPU/memory | Run `/compact` regularly; close between major tasks |

Run `/doctor` inside Claude Code to automatically diagnose installation, settings, MCP, and plugin issues.

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP servers) |
| `.mcp.json` | Project MCP servers (committed) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — usage dashboards, GitHub contribution metrics, PR attribution, leaderboard, and CSV export
- [Manage Costs](references/claude-code-costs.md) — token tracking, team spend limits, rate limit recommendations, and token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, all exported metrics and events, backend recommendations, and security/privacy notes
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation issues, authentication failures, IDE problems, WSL quirks, and performance fixes
- [Changelog](references/claude-code-changelog.md) — release history and version notes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
