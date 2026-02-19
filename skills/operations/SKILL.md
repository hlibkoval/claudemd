---
name: operations
description: Reference documentation for Claude Code operational concerns: analytics dashboards, cost tracking and token optimization, OpenTelemetry monitoring, troubleshooting common issues, and the release changelog. Use when configuring OTel telemetry, managing team spend, interpreting usage metrics, diagnosing installation or authentication errors, or checking what changed in a recent release.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code analytics, cost management, monitoring/telemetry, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:--------------|:---------|
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage, spend tracking, per-user insights |

**Contribution metrics** require: GitHub app at `github.com/apps/claude` + Owner role enabling analytics + GitHub analytics toggle. Data appears within 24 hours. Not available with Zero Data Retention.

**Key contribution metrics:** PRs with CC, lines of code with CC, suggestion accept rate, lines of code accepted.

### Cost Management

Average cost: ~$6/developer/day; ~$100–200/developer/month (Sonnet 4.6).

**Useful commands:**

| Command | Purpose |
|:--------|:--------|
| `/cost` | Session token usage (API users) |
| `/stats` | Usage patterns (subscribers) |
| `/clear` | Start fresh to reduce context |
| `/compact [focus hint]` | Summarize history |
| `/model` | Switch model mid-session |

**Rate limit recommendations (TPM/RPM per user):**

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:** use Sonnet over Opus for most tasks; keep CLAUDE.md under ~500 lines; move specialized instructions to skills (load on-demand); disable unused MCP servers; delegate verbose operations to subagents; use plan mode before complex work; set `MAX_THINKING_TOKENS=8000` for simpler tasks.

**Agent teams:** ~7x more tokens than standard sessions. Keep teams small, spawn prompts focused. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

### OpenTelemetry Monitoring

**Minimum setup:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp           # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Description | Default |
|:---------|:------------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names in tool events | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include `session.id` in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include `user.account_uuid` | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include `app.version` | false |

**Available metrics:**

| Metric | Unit |
|:-------|:-----|
| `claude_code.session.count` | count |
| `claude_code.token.usage` | tokens (+ `type`, `model` attrs) |
| `claude_code.cost.usage` | USD (+ `model` attr) |
| `claude_code.lines_of_code.count` | count (+ `type`: added/removed) |
| `claude_code.commit.count` | count |
| `claude_code.pull_request.count` | count |
| `claude_code.code_edit_tool.decision` | count |
| `claude_code.active_time.total` | seconds |

**Events** (via `OTEL_LOGS_EXPORTER`): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`. All events share a `prompt.id` for correlation.

Multi-team segmentation: `export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values).

### Troubleshooting

**Installation:**

| Problem | Fix |
|:--------|:----|
| WSL: Windows `npm` used | `npm config set os linux` or `npm install -g @anthropic-ai/claude-code --force --no-os-check` |
| Node not found in WSL | Install Node via Linux package manager or nvm; ensure `which node` points to `/usr/` |
| Linux/Mac: permission error | Use native installer: `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows: Git Bash missing | Install [Git for Windows](https://git-scm.com/downloads/win); set `CLAUDE_CODE_GIT_BASH_PATH` |
| Windows: `claude` not in PATH | Add `%USERPROFILE%\.local\bin` to User PATH in Environment Variables |
| WSL2 sandbox error | `apt install bubblewrap socat` |

**Auth issues:** run `/logout`, close Claude Code, relaunch and re-authenticate.

**Diagnose with:** `claude doctor`

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — usage dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard, and data export
- [Costs](references/claude-code-costs.md) — token cost tracking, team spend limits, rate limit tables, and token reduction strategies
- [Monitoring Usage](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, all metrics and events, cardinality controls, dynamic headers, and backend guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation issues on all platforms, auth problems, performance, and common error resolutions
- [Changelog](references/claude-code-changelog.md) — release history and what changed in each version

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring Usage: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
