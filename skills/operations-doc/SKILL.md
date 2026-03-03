---
name: operations-doc
description: Complete documentation for Claude Code operations — analytics dashboards and contribution metrics, cost management and rate limits, OpenTelemetry monitoring (metrics, events, configuration), troubleshooting installation/auth/performance issues, and the changelog. Load when discussing costs, token usage, monitoring, telemetry, analytics, troubleshooting errors, or operational concerns.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring/telemetry, troubleshooting, and the changelog.

## Quick Reference

### Cost Overview

Average cost: ~$6/developer/day (90th percentile < $12/day). API-based teams: ~$100-200/developer/month with Sonnet.

| Command | Purpose |
|:--------|:--------|
| `/cost` | Show session token usage and cost (API users) |
| `/stats` | View usage patterns (Pro/Max subscribers) |
| `/compact` | Reduce context size to save tokens |
| `/clear` | Reset context when switching tasks |

### Rate Limit Recommendations (per user)

| Team Size | TPM per User | RPM per User |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### Cost Reduction Strategies

- **Clear between tasks** with `/clear`; use `/compact` with focus instructions
- **Choose the right model**: Sonnet for most tasks, Opus for complex reasoning, Haiku for subagents
- **Reduce MCP overhead**: prefer CLI tools (`gh`, `aws`), disable unused servers, tune tool search threshold (`ENABLE_TOOL_SEARCH=auto:<N>`)
- **Move instructions to skills**: keep CLAUDE.md < 500 lines, use on-demand skills for specialized workflows
- **Adjust extended thinking**: lower `MAX_THINKING_TOKENS` or effort level for simple tasks
- **Delegate verbose ops**: use subagents for tests/logs/docs to keep main context small

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams/Enterprise | `claude.ai/analytics/claude-code` | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage, spend tracking, team insights |

Contribution metrics require GitHub app install + Owner role to configure. Data appears within 24 hours. PRs tagged `claude-code-assisted` in GitHub.

### OpenTelemetry Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp             # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Environment Variables

| Variable | Description |
|:---------|:-----------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required, set to `1`) |
| `OTEL_METRICS_EXPORTER` | Metrics exporter: `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter: `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | `1` to include prompt content in events |
| `OTEL_LOG_TOOL_DETAILS` | `1` to include MCP/skill names in tool events |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes (comma-separated `key=value`) |

### Exported Metrics

| Metric | Unit | Extra Attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | — |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.pull_request.count` | count | — |
| `claude_code.commit.count` | count | — |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type` (user/cli) |

### Exported Events (via logs exporter)

| Event | Key Attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type` |
| `claude_code.api_request` | `model`, `cost_usd`, `input_tokens`, `output_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` for correlation within a single user prompt.

### Common Troubleshooting

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; try `brew install --cask claude-code` |
| Install killed on Linux | Add 2GB swap; requires 4GB RAM |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| 403 Forbidden after login | Verify subscription; check Console role; check proxy |
| OAuth invalid code | Retry quickly; copy URL with `c` key |
| High CPU/memory | Use `/compact`, restart between tasks, gitignore build dirs |
| Search not working | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0` |
| Escape key not working (JetBrains) | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |
| Repeated permission prompts | Use `/permissions` to pre-approve tools |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (in VCS) |
| `.claude/settings.local.json` | Local project settings |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

Use `/doctor` to diagnose issues. Use `/bug` to report problems to Anthropic.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards, contribution metrics with GitHub integration, PR attribution, leaderboard, and data export
- [Manage costs effectively](references/claude-code-costs.md) -- token cost tracking, team spend limits, rate limit recommendations, cost reduction strategies, and background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel configuration, metrics and events reference, cardinality control, dynamic headers, backend recommendations, and security/privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues, authentication, performance, IDE integration, configuration reset, and search/discovery problems
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
