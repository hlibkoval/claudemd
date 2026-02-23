---
name: operations
description: Reference documentation for Claude Code operations — analytics dashboards, cost tracking and optimization, OpenTelemetry monitoring and usage metrics, troubleshooting installation and configuration issues, and changelog. Covers token usage, spend limits, rate limits, OTel exporters, metrics, events, PR attribution, and common fixes.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operational concerns: analytics, cost management, monitoring, troubleshooting, and changelog.

## Quick Reference

### Cost Overview

| Metric | Value |
|:-------|:------|
| Average daily cost (subscription) | ~$6/developer/day (90th percentile: $12) |
| Average monthly cost (API) | ~$100-200/developer with Sonnet |
| Background token usage | Under $0.04/session |
| Agent teams overhead | ~7x standard sessions (with plan mode) |

### Rate Limit Recommendations (per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### Cost Reduction Strategies

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to drop stale context |
| Custom compaction | `/compact <focus instructions>` |
| Use cheaper models | `/model` to switch; Sonnet for most tasks, reserve Opus for complex reasoning |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`); disable idle servers via `/mcp` |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; use on-demand skills |
| Adjust thinking budget | Lower effort level or set `MAX_THINKING_TOKENS=8000` |
| Delegate verbose ops | Use subagents for tests, log processing, doc fetching |
| Write specific prompts | Avoid vague requests that trigger broad scanning |

### Analytics Dashboards

| Plan | URL | Features |
|:-----|:----|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

Contribution metrics require GitHub app installation and Owner role setup. Not available with Zero Data Retention.

### OpenTelemetry Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp           # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Metrics

| Metric | Unit | Extra attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type`: added/removed |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type`: input/output/cacheRead/cacheCreation, `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type`: user/cli |

### Key OTel Events

| Event name | When logged | Notable attributes |
|:-----------|:------------|:-------------------|
| `claude_code.user_prompt` | User submits prompt | `prompt_length` (content redacted by default) |
| `claude_code.tool_result` | Tool completes | `tool_name`, `success`, `duration_ms` |
| `claude_code.api_request` | API call completes | `model`, `cost_usd`, `input_tokens`, `output_tokens` |
| `claude_code.api_error` | API call fails | `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | Permission decision | `tool_name`, `decision`, `source` |

All events share `prompt.id` for correlating activity from a single user prompt.

### Cardinality Control

| Variable | Controls | Default |
|:---------|:---------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `session.id` in metrics | `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | `app.version` in metrics | `false` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `user.account_uuid` in metrics | `true` |

### Troubleshooting Quick Fixes

| Problem | Fix |
|:--------|:----|
| Search/skills/agents broken | Install system ripgrep; set `USE_BUILTIN_RIPGREP=0` |
| WSL npm errors | `npm config set os linux` then reinstall with `--force --no-os-check` |
| WSL node not found | Install Node via Linux package manager or `nvm`, not Windows |
| Authentication fails | `/logout`, restart, re-authenticate; or `rm -rf ~/.config/claude-code/auth.json` |
| Repeated permission prompts | `/permissions` to allow specific tools |
| JetBrains Esc not working | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |
| IDE not detected (WSL2) | Configure Windows Firewall for WSL2 subnet or switch to mirrored networking |
| High CPU/memory | `/compact` regularly; restart between major tasks |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

Run `/doctor` to diagnose issues (installation, settings, MCP, keybindings, context usage, plugins).

## Full Documentation

For the complete official documentation, see the reference files:

- [Track Team Usage with Analytics](references/claude-code-analytics.md) -- dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard, data export
- [Manage Costs Effectively](references/claude-code-costs.md) -- token tracking, spend limits, rate limits, agent team costs, cost reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel configuration, metrics, events, admin setup, dynamic headers, backend recommendations, security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation fixes (Windows/WSL/Linux/Mac), authentication, IDE integration, performance, markdown formatting
- [Changelog](references/claude-code-changelog.md) -- version history and release notes

## Sources

- Track Team Usage with Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs Effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
