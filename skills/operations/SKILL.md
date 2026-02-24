---
name: operations
description: Reference documentation for Claude Code operations — analytics dashboards, cost management, rate limits, token usage optimization, OpenTelemetry monitoring (metrics, events, configuration), troubleshooting installation/permissions/performance issues, and the changelog.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, troubleshooting, and the changelog.

## Quick Reference

### Cost Overview

Average cost: ~$6/developer/day (90th percentile < $12/day). API usage: ~$100-200/developer/month with Sonnet.

| Command   | Purpose                                         |
|:----------|:------------------------------------------------|
| `/cost`   | Show token usage and cost for current session   |
| `/stats`  | View usage patterns (Max/Pro subscribers)       |
| `/compact` | Summarize context to reduce token usage        |
| `/clear`  | Reset context between unrelated tasks           |

### Rate Limit Recommendations (per user)

| Team size     | TPM per user | RPM per user |
|:--------------|:-------------|:-------------|
| 1-5 users     | 200k-300k    | 5-7          |
| 5-20 users    | 100k-150k    | 2.5-3.5      |
| 20-50 users   | 50k-75k      | 1.25-1.75    |
| 50-100 users  | 25k-35k      | 0.62-0.87    |
| 100-500 users | 15k-20k      | 0.37-0.47    |
| 500+ users    | 10k-15k      | 0.25-0.35    |

### Cost Reduction Strategies

- **Clear between tasks**: `/clear` when switching to unrelated work
- **Choose the right model**: Sonnet for most tasks; Opus for complex reasoning
- **Reduce MCP overhead**: Prefer CLI tools (`gh`, `aws`, `gcloud`) over MCP servers
- **Delegate to subagents**: Offload verbose operations to keep main context lean
- **Move instructions to skills**: Keep CLAUDE.md under ~500 lines; specialized workflows go in skills
- **Adjust thinking budget**: Lower `MAX_THINKING_TOKENS` for simpler tasks
- **Write specific prompts**: Targeted requests avoid broad scanning

### Analytics Dashboards

| Plan                          | Dashboard URL                                    | Features                                |
|:------------------------------|:-------------------------------------------------|:----------------------------------------|
| Teams / Enterprise            | claude.ai/analytics/claude-code                  | Usage, contribution metrics, leaderboard, CSV export |
| API (Console)                 | platform.claude.com/claude-code                  | Usage, spend tracking, team insights    |

Contribution metrics require GitHub app installation and Owner role. Not available with Zero Data Retention.

### OpenTelemetry Monitoring — Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp             # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Environment Variables

| Variable                           | Description                                    |
|:-----------------------------------|:-----------------------------------------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY`     | Enable telemetry (required, set to `1`)        |
| `OTEL_METRICS_EXPORTER`            | Metrics exporter: `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER`               | Logs exporter: `otlp`, `console`               |
| `OTEL_EXPORTER_OTLP_PROTOCOL`      | Protocol: `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT`      | Collector endpoint URL                         |
| `OTEL_METRIC_EXPORT_INTERVAL`      | Export interval in ms (default: 60000)         |
| `OTEL_LOG_USER_PROMPTS`            | Log prompt content (default: disabled)         |
| `OTEL_LOG_TOOL_DETAILS`            | Log MCP/skill names in events (default: disabled) |
| `OTEL_RESOURCE_ATTRIBUTES`         | Custom attributes for team/dept filtering      |

### Exported Metrics

| Metric Name                           | Description                         | Unit   |
|:--------------------------------------|:------------------------------------|:-------|
| `claude_code.session.count`           | CLI sessions started                | count  |
| `claude_code.lines_of_code.count`     | Lines modified (added/removed)      | count  |
| `claude_code.pull_request.count`      | Pull requests created               | count  |
| `claude_code.commit.count`            | Git commits created                 | count  |
| `claude_code.cost.usage`              | Session cost                        | USD    |
| `claude_code.token.usage`             | Tokens used (input/output/cache)    | tokens |
| `claude_code.code_edit_tool.decision` | Edit tool accept/reject decisions   | count  |
| `claude_code.active_time.total`       | Active usage time                   | s      |

### Exported Events

| Event Name                    | Trigger                          | Key attributes                       |
|:------------------------------|:---------------------------------|:-------------------------------------|
| `claude_code.user_prompt`     | User submits a prompt            | `prompt_length`, `prompt.id`         |
| `claude_code.tool_result`     | Tool completes execution         | `tool_name`, `success`, `duration_ms` |
| `claude_code.api_request`     | API request to Claude            | `model`, `cost_usd`, token counts    |
| `claude_code.api_error`       | API request fails                | `error`, `status_code`, `attempt`    |
| `claude_code.tool_decision`   | Tool permission decision made    | `tool_name`, `decision`, `source`    |

### Troubleshooting Quick Fixes

| Issue                         | Solution                                              |
|:------------------------------|:------------------------------------------------------|
| Permission errors on install  | Use native installer: `curl -fsSL https://claude.ai/install.sh \| bash` |
| Repeated permission prompts   | Use `/permissions` to allow specific tools            |
| Auth issues                   | `/logout`, restart, re-auth; or `rm -rf ~/.config/claude-code/auth.json` |
| High CPU/memory               | `/compact` regularly; restart between major tasks     |
| Search not working            | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Hangs/freezes                 | Ctrl+C to cancel; close terminal and restart          |
| General diagnostics           | Run `/doctor` for installation, settings, MCP checks  |

### Configuration File Locations

| File                          | Purpose                                          |
|:------------------------------|:-------------------------------------------------|
| `~/.claude/settings.json`     | User settings (permissions, hooks, model)        |
| `.claude/settings.json`       | Project settings (checked into VCS)              |
| `.claude/settings.local.json` | Local project settings (not committed)           |
| `~/.claude.json`              | Global state (theme, OAuth, MCP servers)         |
| `.mcp.json`                   | Project MCP servers (checked into VCS)           |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- team usage dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard
- [Cost Management](references/claude-code-costs.md) -- tracking costs, team spend limits, rate limits, token reduction strategies, agent team costs
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- metrics, events, configuration variables, exporter setup, dynamic headers, security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (Windows/WSL/Linux/Mac), auth, performance, IDE integration, markdown formatting
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Cost Management: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
