---
name: operations
description: Reference documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting installation and configuration issues, and the changelog. Covers team usage tracking, token costs, rate limits, spend limits, OTel metrics/events export, telemetry configuration, and common error solutions.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations, monitoring, cost management, and troubleshooting.

## Quick Reference

### Cost Overview

Average cost is ~$6/developer/day ($100-200/developer/month with Sonnet). 90% of users stay below $12/day.

| Command   | Description                                      |
|:----------|:-------------------------------------------------|
| `/cost`   | Show session token usage and cost (API users)    |
| `/stats`  | View usage patterns (Max/Pro subscribers)        |
| `/compact` | Reduce context to save tokens                   |
| `/clear`  | Reset context between tasks                      |

### Rate Limit Recommendations (per user)

| Team size   | TPM per user | RPM per user |
|:------------|:-------------|:-------------|
| 1-5 users   | 200k-300k    | 5-7          |
| 5-20 users  | 100k-150k    | 2.5-3.5      |
| 20-50 users | 50k-75k      | 1.25-1.75    |
| 50-100      | 25k-35k      | 0.62-0.87    |
| 100-500     | 15k-20k      | 0.37-0.47    |
| 500+        | 10k-15k      | 0.25-0.35    |

### Analytics Dashboards

| Plan                          | URL                                                          |
|:------------------------------|:-------------------------------------------------------------|
| Claude for Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) |
| API (Claude Console)          | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) |

### OpenTelemetry Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp           # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Metrics

| Metric                                | Unit   | Description                         |
|:--------------------------------------|:-------|:------------------------------------|
| `claude_code.session.count`           | count  | CLI sessions started                |
| `claude_code.lines_of_code.count`     | count  | Lines of code modified              |
| `claude_code.pull_request.count`      | count  | Pull requests created               |
| `claude_code.commit.count`            | count  | Git commits created                 |
| `claude_code.cost.usage`             | USD    | Session cost                        |
| `claude_code.token.usage`            | tokens | Tokens used (input/output/cache)    |
| `claude_code.code_edit_tool.decision` | count  | Code edit permission decisions      |
| `claude_code.active_time.total`       | s      | Active time (user + CLI)            |

### Key OTel Events

| Event Name                    | Trigger                          | Notable attributes                      |
|:------------------------------|:---------------------------------|:----------------------------------------|
| `claude_code.user_prompt`     | User submits prompt              | `prompt_length`, `prompt` (opt-in)      |
| `claude_code.tool_result`     | Tool completes                   | `tool_name`, `success`, `duration_ms`   |
| `claude_code.api_request`     | API call made                    | `model`, `cost_usd`, token counts       |
| `claude_code.api_error`       | API call fails                   | `error`, `status_code`, `attempt`       |
| `claude_code.tool_decision`   | Permission decision              | `tool_name`, `decision`, `source`       |

### OTel Privacy Controls

| Variable                  | Default    | Description                                  |
|:--------------------------|:-----------|:---------------------------------------------|
| `OTEL_LOG_USER_PROMPTS`   | disabled   | Set `1` to include prompt content            |
| `OTEL_LOG_TOOL_DETAILS`   | disabled   | Set `1` to include MCP/skill names in events |

### Troubleshooting Quick Lookup

| Symptom                                       | Fix                                     |
|:----------------------------------------------|:----------------------------------------|
| ` ` `command not found: claude` ` `           | Add `~/.local/bin` to PATH              |
| `syntax error near unexpected token '<'`      | Install script returned HTML; use Homebrew |
| `Killed` during install on Linux              | Add swap space (need 4 GB RAM)          |
| TLS / SSL connection errors                   | Update CA certs; set `NODE_EXTRA_CA_CERTS` |
| 403 Forbidden after login                     | Verify subscription or Console role     |
| High CPU / memory usage                       | Use `/compact`; restart between tasks   |
| Search / `@file` / skills not working         | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0` |
| Escape key not working in JetBrains terminal  | Uncheck "Move focus to editor with Escape" |

### Configuration File Locations

| File                          | Purpose                            |
|:------------------------------|:-----------------------------------|
| `~/.claude/settings.json`     | User settings                      |
| `.claude/settings.json`       | Project settings (committed)       |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json`              | Global state (theme, OAuth, MCP)   |
| `.mcp.json`                   | Project MCP servers (committed)    |

### Useful Diagnostic Commands

| Command      | Description                                               |
|:-------------|:----------------------------------------------------------|
| `/doctor`    | Check installation, settings, MCP, plugins, context usage |
| `/bug`       | Report a problem directly to Anthropic                    |
| `/cost`      | Show current session token usage and cost                 |
| `/context`   | See what is consuming context window space                |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track Team Usage with Analytics](references/claude-code-analytics.md) -- dashboards for Teams/Enterprise and API customers, contribution metrics, GitHub integration, PR attribution
- [Manage Costs Effectively](references/claude-code-costs.md) -- token costs, spend limits, rate limit recommendations, cost reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel configuration, metrics, events, admin setup, dynamic headers, multi-team support, backend considerations
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues, authentication, configuration, performance, IDE integration, markdown formatting
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Track Team Usage with Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs Effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
