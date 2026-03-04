---
name: operations-doc
description: Complete documentation for Claude Code operations — analytics dashboards, cost management, rate limits, OpenTelemetry monitoring (metrics, events, configuration), and troubleshooting (installation, authentication, IDE integration, performance). Load when discussing usage tracking, cost optimization, telemetry setup, or debugging Claude Code issues.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations, monitoring, and troubleshooting.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics** require GitHub app install + Owner role. Not available with Zero Data Retention. Setup: install GitHub app at github.com/apps/claude, enable analytics at claude.ai/admin-settings/claude-code, enable GitHub toggle, authenticate.

**Summary metrics**: PRs with CC, Lines of code with CC, PRs with CC (%), Suggestion accept rate, Lines of code accepted.

**PR attribution**: conservative matching -- PRs tagged as "with Claude Code" if they contain at least one line written during a Claude Code session. Sessions from 21 days before to 2 days after merge are considered. Code with >20% difference not attributed. PRs labeled `claude-code-assisted` in GitHub.

### Cost Management

Average cost: ~$6/dev/day ($12 for 90th percentile). API usage: ~$100-200/dev/month with Sonnet 4.6. Check session cost with `/cost` command. Subscribers use `/stats` instead.

**Rate limit recommendations (TPM per user)**:

| Team size | TPM/user | RPM/user |
|:----------|:---------|:---------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Key cost-saving strategies**: `/clear` between tasks, `/compact` with focus instructions, use Sonnet over Opus for most tasks, disable unused MCP servers, move specialized CLAUDE.md instructions to skills, lower extended thinking budget for simple tasks, delegate verbose operations to subagents, write specific prompts.

### OpenTelemetry Monitoring

**Quick start env vars**:

| Variable | Purpose | Values |
|:---------|:--------|:-------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | default `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | default `5000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | `1` to enable |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names | `1` to enable |

**Cardinality control**:

| Variable | Default | Description |
|:---------|:--------|:------------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include session.id |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include app.version |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include user.account_uuid |

**Exported metrics**:

| Metric | Unit | Extra attributes |
|:-------|:-----|:----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type` (user/cli) |

**Exported events** (via `OTEL_LOGS_EXPORTER`):

| Event name | Key attributes |
|:-----------|:--------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, token counts, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` (UUID v4) for correlation within a single user prompt.

**Dynamic headers**: set `otelHeadersHelper` in settings.json to a script path. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team**: use `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values).

### Troubleshooting Quick Reference

**Installation**:

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | HTML returned instead of script; use `brew install --cask claude-code` |
| `Killed` during install (Linux) | Add 2GB swap; needs 4GB RAM |
| `TLS connect error` | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Needs macOS 13.0+; try Homebrew |
| Git Bash required (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |

**Authentication**:

| Issue | Fix |
|:------|:----|
| OAuth error: Invalid code | Retry quickly; press `c` to copy URL |
| 403 Forbidden | Verify subscription/role; check proxy config |
| Login fails in WSL2 | Set `BROWSER` env var to Windows browser path |

**Performance**: `/compact` to reduce context, restart between tasks, add build dirs to `.gitignore`.

**Search issues**: install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0`.

**IDE (JetBrains on WSL2)**: configure Windows Firewall for WSL2 subnet or switch to `networkingMode=mirrored`.

**Escape key in JetBrains**: Settings -> Tools -> Terminal -> uncheck "Move focus to the editor with Escape".

**Config file locations**:

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (VCS) |
| `.claude/settings.local.json` | Local project settings |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

**Diagnostics**: run `/doctor` to check installation, settings, MCP, keybindings, context usage, and plugin errors. Use `/bug` to report issues.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- dashboards for Teams/Enterprise and API, contribution metrics setup, PR attribution, leaderboard
- [Manage costs effectively](references/claude-code-costs.md) -- cost tracking, team spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- telemetry configuration, metrics and events reference, backend considerations, security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues, authentication, IDE integration, performance, config file locations
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
