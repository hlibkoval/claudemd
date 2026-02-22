---
name: operations
description: Reference documentation for Claude Code operations — analytics dashboards, cost tracking and optimization, OpenTelemetry monitoring, troubleshooting installation and configuration issues, and the changelog. Use when managing team spend, setting up telemetry, diagnosing problems, or reviewing usage metrics.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, troubleshooting, and the changelog.

## Quick Reference

### Cost Overview

Average cost is ~$6/developer/day ($100-200/month with Sonnet). Use `/cost` for session token usage or `/stats` for subscribers.

### Rate Limit Recommendations (per user)

| Team size   | TPM per user | RPM per user |
|:------------|:-------------|:-------------|
| 1-5 users   | 200k-300k    | 5-7          |
| 5-20 users  | 100k-150k    | 2.5-3.5      |
| 20-50 users | 50k-75k      | 1.25-1.75    |
| 50-100      | 25k-35k      | 0.62-0.87    |
| 100-500     | 15k-20k      | 0.37-0.47    |
| 500+        | 10k-15k      | 0.25-0.35    |

### Reducing Token Usage

| Strategy                        | Details                                                              |
|:--------------------------------|:---------------------------------------------------------------------|
| Clear between tasks             | `/clear` to drop stale context; `/compact` to summarize             |
| Choose cheaper model            | Sonnet for most tasks; Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead             | Prefer CLI tools (`gh`, `aws`); disable unused servers via `/mcp`   |
| Move instructions to skills     | Keep CLAUDE.md under ~500 lines; skills load on-demand              |
| Adjust extended thinking        | Lower `MAX_THINKING_TOKENS` or disable in `/config`                 |
| Delegate to subagents           | Isolate verbose operations (tests, logs) in subagent context        |
| Write specific prompts          | Avoid vague requests that trigger broad scanning                    |

### Analytics Dashboards

| Plan                    | URL                                       | Features                                              |
|:------------------------|:------------------------------------------|:------------------------------------------------------|
| Teams / Enterprise      | claude.ai/analytics/claude-code           | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console)           | platform.claude.com/claude-code           | Usage, spend tracking, team insights                  |

Contribution metrics require GitHub app install + Owner role to enable. Data appears within 24 hours.

### OpenTelemetry Monitoring

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. Key environment variables:

| Variable                       | Description                           | Values                          |
|:-------------------------------|:--------------------------------------|:--------------------------------|
| `OTEL_METRICS_EXPORTER`        | Metrics exporter                      | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER`           | Events/logs exporter                  | `otlp`, `console`              |
| `OTEL_EXPORTER_OTLP_PROTOCOL`  | OTLP protocol                         | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT`  | Collector endpoint                    | e.g. `http://localhost:4317`   |
| `OTEL_EXPORTER_OTLP_HEADERS`   | Auth headers                          | `Authorization=Bearer token`   |
| `OTEL_METRIC_EXPORT_INTERVAL`  | Metrics interval (ms)                 | Default: `60000`               |
| `OTEL_LOG_USER_PROMPTS`        | Log prompt content                    | `1` to enable                  |
| `OTEL_LOG_TOOL_DETAILS`        | Log MCP/skill names in tool events    | `1` to enable                  |

#### Exported Metrics

| Metric                                | Unit   | Description                         |
|:--------------------------------------|:-------|:------------------------------------|
| `claude_code.session.count`           | count  | CLI sessions started                |
| `claude_code.lines_of_code.count`     | count  | Lines modified (added/removed)      |
| `claude_code.pull_request.count`      | count  | PRs created                         |
| `claude_code.commit.count`            | count  | Git commits created                 |
| `claude_code.cost.usage`             | USD    | Session cost                        |
| `claude_code.token.usage`            | tokens | Tokens used (input/output/cache)    |
| `claude_code.code_edit_tool.decision` | count  | Edit tool accept/reject decisions   |
| `claude_code.active_time.total`       | s      | Active time (user + CLI)            |

#### Exported Events

| Event                        | Key attributes                                                  |
|:-----------------------------|:----------------------------------------------------------------|
| `claude_code.user_prompt`    | `prompt_length`, `prompt` (if `OTEL_LOG_USER_PROMPTS=1`)       |
| `claude_code.tool_result`    | `tool_name`, `success`, `duration_ms`, `decision_type`          |
| `claude_code.api_request`    | `model`, `cost_usd`, `input_tokens`, `output_tokens`           |
| `claude_code.api_error`      | `model`, `error`, `status_code`, `attempt`                     |
| `claude_code.tool_decision`  | `tool_name`, `decision`, `source`                              |

All metrics/events share `session.id`, `organization.id`, `user.account_uuid`, `user.id`, `terminal.type`.

### Troubleshooting

| Problem                               | Solution                                                                       |
|:---------------------------------------|:-------------------------------------------------------------------------------|
| WSL platform detection errors          | `npm config set os linux` or install with `--force --no-os-check`             |
| `node: not found` in WSL              | Install Node via Linux package manager or `nvm`, not Windows Node             |
| Permission / command not found (Linux) | Use native installer: `curl -fsSL https://claude.ai/install.sh` ` | bash`     |
| Repeated permission prompts            | Use `/permissions` to allow specific tools                                    |
| Authentication issues                  | Run `/logout`, restart Claude, re-authenticate; or `rm -rf ~/.config/claude-code/auth.json` |
| High CPU / memory                      | `/compact` regularly; restart between tasks; `.gitignore` build dirs          |
| Search not working                     | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0`                         |
| JetBrains Esc key conflict             | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape"      |
| Diagnose issues                        | Run `/doctor` to check config, MCP, search, and plugin health                |

### Configuration File Locations

| File                          | Purpose                                    |
|:------------------------------|:-------------------------------------------|
| `~/.claude/settings.json`     | User settings (permissions, hooks, model)  |
| `.claude/settings.json`       | Project settings (committed)               |
| `.claude/settings.local.json` | Local project settings (gitignored)        |
| `~/.claude.json`              | Global state (theme, OAuth, MCP)           |
| `.mcp.json`                   | Project MCP servers (committed)            |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — team usage dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export
- [Costs](references/claude-code-costs.md) — token tracking, team spend limits, rate limit recommendations, cost reduction strategies, agent team costs
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, metrics/events reference, exporter configurations, cardinality control, dynamic headers, ROI measurement
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation fixes (Windows/WSL/Linux/Mac), authentication, configuration reset, IDE integration, performance, search issues
- [Changelog](references/claude-code-changelog.md) — version history and release notes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
