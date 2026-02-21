---
name: operations
description: Reference documentation for Claude Code operations — analytics dashboards, cost management, rate limits, OpenTelemetry monitoring, troubleshooting installation and configuration issues, and the changelog. Covers team usage tracking, token costs, spend limits, OTel metrics/events, telemetry configuration, and common fixes for installation, permissions, performance, and IDE integration problems.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running and managing Claude Code in production — analytics, cost tracking, monitoring, troubleshooting, and changelog.

## Quick Reference

### Cost Overview

| Metric | Value |
|:-------|:------|
| Average daily cost (Pro/Teams) | ~$6/developer/day |
| 90th percentile daily cost | < $12/day |
| Average monthly cost (API, Sonnet) | ~$100-200/developer/month |
| Background token usage | < $0.04/session |

### Rate Limit Recommendations (TPM/RPM per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### Cost Reduction Strategies

| Strategy | Impact |
|:---------|:-------|
| Use `/clear` between tasks | Removes stale context from subsequent messages |
| Use `/compact` with instructions | Controls what is preserved during summarization |
| Switch to Sonnet for routine tasks | Lower per-token cost than Opus |
| Reduce MCP server overhead | Fewer idle tool definitions in context |
| Move CLAUDE.md instructions to skills | Skills load on-demand; CLAUDE.md is always loaded |
| Delegate verbose operations to subagents | Summary returns instead of full output |
| Lower extended thinking budget | Thinking tokens billed as output tokens |
| Write specific prompts | Avoids broad scanning of codebase |

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

### OpenTelemetry Quick Start

Enable telemetry with these environment variables:

| Variable | Purpose | Example |
|:---------|:--------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter type | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter type | `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | `60000` (default) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | `5000` (default) |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | `1` to enable |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names | `1` to enable |

### OTel Metrics

| Metric Name | Description | Unit |
|:------------|:------------|:-----|
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Edit permission decisions | count |
| `claude_code.active_time.total` | Active time | seconds |

### OTel Events (via logs exporter)

| Event Name | When logged |
|:-----------|:------------|
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.api_request` | Each API request to Claude |
| `claude_code.api_error` | API request fails |
| `claude_code.tool_decision` | Tool permission decision made |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings (permissions, hooks, model) |
| `.claude/settings.json` | Project settings (in source control) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (in source control) |

### Common Troubleshooting

| Issue | Fix |
|:------|:----|
| Permission errors on install (Linux/Mac) | Use native installer via install.sh |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| Authentication issues | Run `/logout`, restart, re-authenticate |
| High CPU/memory | Use `/compact`, restart between tasks |
| Search/discovery not working | Install system ripgrep, set `USE_BUILTIN_RIPGREP=0` |
| JetBrains Escape key conflict | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |
| General diagnostics | Run `/doctor` to check installation health |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- team usage dashboards, contribution metrics with GitHub integration, PR attribution, leaderboard, CSV export
- [Costs](references/claude-code-costs.md) -- token usage tracking, team spend limits, rate limits, cost reduction strategies, agent team costs
- [Monitoring (OpenTelemetry)](references/claude-code-monitoring-usage.md) -- OTel setup, environment variables, metrics, events, dynamic headers, cardinality control, backend recommendations
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation fixes (Windows/WSL/Linux/Mac), authentication, config file locations, performance, IDE integration, markdown formatting
- [Changelog](references/claude-code-changelog.md) -- version history and release notes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
