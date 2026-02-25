---
name: operations
description: Reference documentation for Claude Code operations — analytics dashboards, cost management, rate limits, OpenTelemetry monitoring, troubleshooting installation and auth issues, and the changelog. Use when tracking usage, managing spend, exporting telemetry, diagnosing errors, or checking what changed between versions.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan                          | URL                                                                        | Includes                                                  |
|:------------------------------|:---------------------------------------------------------------------------|:----------------------------------------------------------|
| Claude for Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage, contribution metrics (GitHub), leaderboard, export |
| API (Claude Console)          | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage, spend tracking, team insights                      |

Contribution metrics require GitHub app install + Owner enabling at `claude.ai/admin-settings/claude-code`. Not available with Zero Data Retention.

### Cost Tracking

- **Session cost**: `/cost` command (API users; subscribers use `/stats`)
- **Average cost**: ~$6/dev/day ($100-200/dev/month with Sonnet 4.6)
- **Workspace limits**: set in [Console workspace settings](https://platform.claude.com/docs/en/build-with-claude/workspaces#workspace-limits)
- **Background usage**: ~$0.04/session for conversation summarization

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

| Strategy                         | How                                                      |
|:---------------------------------|:---------------------------------------------------------|
| Clear between tasks              | `/clear` to drop stale context                           |
| Use right model                  | `/model` to switch; Sonnet for most tasks, Opus for complex |
| Reduce MCP overhead              | Prefer CLI tools; disable unused servers                 |
| Move instructions to skills      | Keep CLAUDE.md under ~500 lines                          |
| Lower thinking budget            | `MAX_THINKING_TOKENS=8000` or adjust in `/config`        |
| Delegate verbose ops             | Use subagents for tests, logs, docs                      |
| Write specific prompts           | Avoid broad "improve this codebase" requests             |

### OpenTelemetry Monitoring

Quick start:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp           # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Exported Metrics

| Metric                                | Unit   | Extra attributes                   |
|:--------------------------------------|:-------|:-----------------------------------|
| `claude_code.session.count`           | count  | --                                 |
| `claude_code.lines_of_code.count`     | count  | `type` (added/removed)             |
| `claude_code.pull_request.count`      | count  | --                                 |
| `claude_code.commit.count`            | count  | --                                 |
| `claude_code.cost.usage`              | USD    | `model`                            |
| `claude_code.token.usage`             | tokens | `type`, `model`                    |
| `claude_code.code_edit_tool.decision` | count  | `tool_name`, `decision`, `source`  |
| `claude_code.active_time.total`       | s      | `type` (user/cli)                  |

#### Exported Events (via logs exporter)

| Event Name                    | Key attributes                                        |
|:------------------------------|:------------------------------------------------------|
| `claude_code.user_prompt`     | `prompt_length`, `prompt` (opt-in)                    |
| `claude_code.tool_result`     | `tool_name`, `success`, `duration_ms`                 |
| `claude_code.api_request`     | `model`, `cost_usd`, `input_tokens`, `output_tokens`  |
| `claude_code.api_error`       | `error`, `status_code`, `attempt`                     |
| `claude_code.tool_decision`   | `tool_name`, `decision`, `source`                     |

All metrics/events share: `session.id`, `user.account_uuid`, `organization.id`, `user.id`, `user.email`, `terminal.type`.

#### Cardinality Control

| Variable                            | Default | Description                  |
|:------------------------------------|:--------|:-----------------------------|
| `OTEL_METRICS_INCLUDE_SESSION_ID`   | `true`  | Include session.id in metrics |
| `OTEL_METRICS_INCLUDE_VERSION`      | `false` | Include app.version          |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true`  | Include user.account_uuid    |

### Troubleshooting Quick Reference

| Symptom                               | Fix                                                    |
|:--------------------------------------|:-------------------------------------------------------|
| `command not found: claude`           | Add `~/.local/bin` to PATH                             |
| `syntax error near unexpected token`  | Install script returned HTML; try `brew install --cask claude-code` |
| `Killed` during install (Linux)       | Add swap: `fallocate -l 2G /swapfile`                  |
| TLS / SSL errors                      | Update CA certs; set `NODE_EXTRA_CA_CERTS` for proxies |
| `Illegal instruction` (Linux)         | Architecture mismatch; check `uname -m`                |
| OAuth / 403 Forbidden                 | Run `/logout` then re-authenticate                     |
| Search / `@file` not working          | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0`  |
| High CPU / memory                     | `/compact` regularly; restart between tasks             |

#### Config File Locations

| File                          | Purpose                           |
|:------------------------------|:----------------------------------|
| `~/.claude/settings.json`     | User settings                     |
| `.claude/settings.json`       | Project settings (committed)      |
| `.claude/settings.local.json` | Local project settings (ignored)  |
| `~/.claude.json`              | Global state, OAuth, MCP servers  |
| `.mcp.json`                   | Project MCP servers               |

#### Diagnostic Commands

- `/doctor` -- checks installation, search, settings, MCP, keybindings, plugins
- `/bug` -- report issues directly to Anthropic
- `claude --version` -- check current version

## Full Documentation

For the complete official documentation, see the reference files:

- [Track Team Usage with Analytics](references/claude-code-analytics.md) -- dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard
- [Manage Costs Effectively](references/claude-code-costs.md) -- tracking costs, team spend limits, rate limits, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- full OTel setup, metrics, events, configuration variables, backend guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation, auth, PATH, config, performance, IDE integration, WSL issues
- [Changelog](references/claude-code-changelog.md) -- version history and release notes

## Sources

- Track Team Usage with Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs Effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
