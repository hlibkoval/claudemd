---
name: operations-doc
description: Complete documentation for Claude Code operations — analytics dashboards (Teams/Enterprise/API), cost management and token optimization, OpenTelemetry monitoring and metrics export, troubleshooting installation and configuration issues, and the changelog. Load when discussing costs, usage tracking, telemetry, OTel, monitoring, analytics, debugging, or troubleshooting Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operational topics: analytics, cost management, monitoring, troubleshooting, and the changelog.

## Quick Reference

### Cost Management

Average cost: ~$6/developer/day (90th percentile below $12/day). API teams: ~$100-200/developer/month with Sonnet.

| Command | Purpose |
|:--------|:--------|
| `/cost` | Show session token usage and cost (API users) |
| `/stats` | View usage patterns (subscription users) |
| `/compact` | Reduce context size to save tokens |
| `/clear` | Reset context between unrelated tasks |
| `/model` | Switch models mid-session |

**Rate limit recommendations (TPM per user by team size):**

| Team size | TPM/user | RPM/user |
|:----------|:---------|:---------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Key cost reduction strategies:** clear between tasks, use Sonnet for most work (reserve Opus for complex reasoning), reduce MCP server overhead, write specific prompts, use plan mode for complex tasks, delegate verbose operations to subagents, move specialized CLAUDE.md instructions into skills.

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

Contribution metrics require GitHub app installation and Owner role. Data appears within 24 hours. PRs labeled `claude-code-assisted` in GitHub.

### OpenTelemetry Monitoring

**Minimal setup:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Description |
|:---------|:-----------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required, set to `1`) |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval ms (default: 60000) |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names (default: off) |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes for team segmentation |

**Exported metrics:**

| Metric | Unit |
|:-------|:-----|
| `claude_code.session.count` | count |
| `claude_code.lines_of_code.count` | count |
| `claude_code.pull_request.count` | count |
| `claude_code.commit.count` | count |
| `claude_code.cost.usage` | USD |
| `claude_code.token.usage` | tokens |
| `claude_code.code_edit_tool.decision` | count |
| `claude_code.active_time.total` | seconds |

**Exported events:** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`. All linked by `prompt.id`.

### Troubleshooting Quick-Reference

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; use `brew install --cask claude-code` |
| Install killed on Linux | Add swap space (min 4 GB RAM needed) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| Search/skills not working | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0` |
| OAuth error: Invalid code | Retry quickly; copy URL with `c` if browser does not open |
| 403 Forbidden | Check subscription/role; check proxy config |
| Escape key not working in JetBrains | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |

**Diagnostic commands:** `/doctor` (checks installation, settings, MCP, keybindings, context usage), `/bug` (report issues to Anthropic).

**Config file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- dashboards for Teams/Enterprise and API, contribution metrics setup, GitHub integration, PR attribution, leaderboard
- [Manage costs effectively](references/claude-code-costs.md) -- token tracking, team spend limits, rate limit recommendations, context management, cost reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel configuration, metrics and events schemas, exporter setup, admin configuration, security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues, PATH fixes, auth problems, performance, IDE integration, config reset
- [Changelog](references/claude-code-changelog.md) -- version history and release notes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
