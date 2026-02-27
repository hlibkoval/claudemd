---
name: operations-doc
description: Reference documentation for Claude Code operations -- analytics dashboards, contribution metrics, cost tracking, spend limits, rate limits, token optimization, OpenTelemetry monitoring, metrics and events export, troubleshooting installation errors, authentication issues, IDE integration, and changelog.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, costs, monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan                          | Dashboard URL                                             | Includes                                                  |
|:------------------------------|:----------------------------------------------------------|:----------------------------------------------------------|
| Claude for Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console)          | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights              |

Contribution metrics require GitHub integration setup: install GitHub app at [github.com/apps/claude](https://github.com/apps/claude), enable analytics in admin settings, authenticate with GitHub. Data appears within 24 hours. Not available with Zero Data Retention.

### Cost Overview

| Metric                        | Value                                      |
|:------------------------------|:-------------------------------------------|
| Average daily cost            | ~$6/developer/day (90th percentile < $12)  |
| Monthly cost (Sonnet)         | ~$100-200/developer/month                  |
| Background token usage        | < $0.04 per session                        |

**Check costs**: `/cost` (API users) or `/stats` (subscribers).

### Rate Limit Recommendations (TPM/RPM per user)

| Team size     | TPM per user | RPM per user |
|:--------------|:-------------|:-------------|
| 1-5 users     | 200k-300k    | 5-7          |
| 5-20 users    | 100k-150k    | 2.5-3.5      |
| 20-50 users   | 50k-75k      | 1.25-1.75    |
| 50-100 users  | 25k-35k      | 0.62-0.87    |
| 100-500 users | 15k-20k      | 0.37-0.47    |
| 500+ users    | 10k-15k      | 0.25-0.35    |

### Cost Reduction Strategies

- `/clear` between tasks; `/compact` with custom focus instructions
- Use Sonnet for most tasks; reserve Opus for complex reasoning
- Disable unused MCP servers; prefer CLI tools over MCP when available
- Move specialized CLAUDE.md instructions into skills (load on-demand)
- Delegate verbose operations to subagents
- Reduce extended thinking budget for simpler tasks (`MAX_THINKING_TOKENS=8000`)

### OpenTelemetry Monitoring Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp           # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Metrics

| Metric Name                           | Unit   | Description                          |
|:--------------------------------------|:-------|:-------------------------------------|
| `claude_code.session.count`           | count  | CLI sessions started                 |
| `claude_code.lines_of_code.count`     | count  | Lines modified (type: added/removed) |
| `claude_code.token.usage`             | tokens | Tokens used (type: input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage`              | USD    | Session cost                         |
| `claude_code.pull_request.count`      | count  | PRs created                          |
| `claude_code.commit.count`            | count  | Commits created                      |
| `claude_code.code_edit_tool.decision` | count  | Edit tool accept/reject decisions    |
| `claude_code.active_time.total`       | s      | Active usage time                    |

### Key OTel Events

| Event Name                    | Description                     | Key Attributes                          |
|:------------------------------|:--------------------------------|:----------------------------------------|
| `claude_code.user_prompt`     | User submits a prompt           | `prompt_length`, `prompt` (opt-in)      |
| `claude_code.tool_result`     | Tool completes execution        | `tool_name`, `success`, `duration_ms`   |
| `claude_code.api_request`     | API request to Claude           | `model`, `cost_usd`, `input_tokens`     |
| `claude_code.api_error`       | API request fails               | `error`, `status_code`, `attempt`       |
| `claude_code.tool_decision`   | Tool permission decision        | `tool_name`, `decision`, `source`       |

All events share `prompt.id` for correlating events within a single user prompt.

### Troubleshooting Quick Lookup

| Symptom                                          | Fix                                            |
|:-------------------------------------------------|:-----------------------------------------------|
| `command not found: claude`                      | Add `~/.local/bin` to PATH                     |
| `syntax error near unexpected token '<'`         | Install script returned HTML; use `brew` or `winget` |
| `Killed` during install on Linux                 | Add 2GB swap; requires 4GB RAM minimum         |
| TLS/SSL connection errors                        | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| 403 Forbidden after login                        | Verify subscription; check Console role assignment |
| Search/` `@file` /skills not working              | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| `Claude Code on Windows requires git-bash`       | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |
| High CPU / memory usage                          | `/compact` regularly; `.gitignore` build dirs  |

### Configuration File Locations

| File                          | Purpose                                |
|:------------------------------|:---------------------------------------|
| `~/.claude/settings.json`     | User settings                          |
| `.claude/settings.json`       | Project settings (source control)      |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json`              | Global state (theme, OAuth, MCP)       |
| `.mcp.json`                   | Project MCP servers                    |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — cost tracking, spend limits, rate limits, token reduction strategies, agent team costs
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, metrics, events, admin setup, multi-team support, backend considerations
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation issues, authentication, PATH, permissions, IDE integration, performance, WSL, Windows
- [Changelog](references/claude-code-changelog.md) — release history and version changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
