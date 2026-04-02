---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and changelog. Covers Teams/Enterprise analytics (usage metrics, contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export), API Console analytics (spend tracking, team insights), cost tracking (/cost command, /stats), team cost management (workspace spend limits, rate limit recommendations by team size, TPM/RPM tables), agent team token costs, reducing token usage (context management, /clear, /compact, model selection, MCP overhead, code intelligence plugins, hooks/skills for preprocessing, extended thinking budget, subagents, plan mode), background token usage, OpenTelemetry setup (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, OTLP/gRPC/Prometheus/console exporters), admin managed settings for telemetry, OTel environment variables (OTEL_EXPORTER_OTLP_PROTOCOL, OTEL_EXPORTER_OTLP_ENDPOINT, OTEL_EXPORTER_OTLP_HEADERS, OTEL_METRIC_EXPORT_INTERVAL, OTEL_LOGS_EXPORT_INTERVAL, OTEL_LOG_USER_PROMPTS, OTEL_LOG_TOOL_DETAILS, OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE), metrics cardinality control (OTEL_METRICS_INCLUDE_SESSION_ID, OTEL_METRICS_INCLUDE_VERSION, OTEL_METRICS_INCLUDE_ACCOUNT_UUID), dynamic OTel headers (otelHeadersHelper, CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS), OTEL_RESOURCE_ATTRIBUTES for multi-team, exported metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total), exported events (user_prompt, tool_result, api_request, api_error, tool_decision), prompt.id event correlation, standard OTel attributes (session.id, app.version, organization.id, user.account_uuid, user.id, user.email, terminal.type), backend recommendations, ROI measurement, troubleshooting installation (PATH issues, curl errors, TLS/SSL, low-memory Linux, Docker hangs, Windows Git Bash, musl/glibc mismatch, architecture mismatch, macOS dyld errors, WSL issues), authentication troubleshooting (OAuth errors, 403 Forbidden, disabled organization, token expiry), configuration file locations, IDE integration issues (JetBrains on WSL2, Escape key), performance (CPU/memory, command hangs, search/ripgrep issues, WSL search performance), markdown formatting issues, and changelog/release notes. Load when discussing Claude Code analytics, costs, billing, token usage, spend limits, rate limits, TPM, RPM, OpenTelemetry, OTel, telemetry, monitoring, metrics, events, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, troubleshooting, installation issues, PATH problems, TLS errors, authentication errors, /cost, /stats, /doctor, changelog, release notes, or any operations/observability topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

**Contribution metrics setup** (Teams/Enterprise): Install GitHub app at [github.com/apps/claude](https://github.com/apps/claude), enable at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code), authenticate GitHub. Data appears within 24 hours. Not available with Zero Data Retention.

**PR attribution**: merged PRs containing Claude Code-assisted code are labeled `claude-code-assisted` in GitHub. Sessions from 21 days before to 2 days after PR merge are considered. Code with >20% developer rewrite is not attributed. Only "effective lines" (>3 chars after normalization) are counted.

### Cost Overview

| Metric | Value |
|:-------|:------|
| Average daily cost | ~$6/developer/day |
| 90th percentile daily | <$12/day |
| Monthly average (API, Sonnet) | ~$100-200/developer/month |
| Background token usage | ~$0.04/session |

### Rate Limit Recommendations (TPM/RPM per User)

| Team Size | TPM per User | RPM per User |
|:----------|:------------|:-------------|
| 1-5 users | 200k-300k | 5-7 |
| 5-20 users | 100k-150k | 2.5-3.5 |
| 20-50 users | 50k-75k | 1.25-1.75 |
| 50-100 users | 25k-35k | 0.62-0.87 |
| 100-500 users | 15k-20k | 0.37-0.47 |
| 500+ users | 10k-15k | 0.25-0.35 |

### Cost Reduction Strategies

| Strategy | Details |
|:---------|:--------|
| Clear between tasks | `/clear` to drop stale context; `/compact` with focus instructions |
| Choose the right model | Sonnet for most tasks; Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | Prefer CLI tools (gh, aws, gcloud); disable unused servers |
| Code intelligence plugins | Precise symbol navigation reduces file reads |
| Offload to hooks/skills | Preprocess data before Claude sees it; move instructions from CLAUDE.md to skills |
| Adjust extended thinking | `/effort` to lower; disable in `/config`; `MAX_THINKING_TOKENS=8000` |
| Delegate to subagents | Verbose operations (tests, logs) stay in subagent context |
| Write specific prompts | Avoid vague requests that trigger broad scanning |
| Use plan mode | Shift+Tab before implementation to prevent expensive re-work |
| Agent teams | ~7x tokens vs standard; use Sonnet for teammates; keep teams small |

### OpenTelemetry Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp, prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp           # otlp, console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc  # grpc, http/json, http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

### Key OTel Environment Variables

| Variable | Description | Default |
|:---------|:-----------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | -- |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s), comma-separated | -- |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s), comma-separated | -- |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for all signals | -- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | -- |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | -- |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log tool parameters/input | disabled |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Metrics temporality | `delta` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes (e.g. `team.id=platform`) | -- |

### Metrics Cardinality Control

| Variable | Description | Default |
|:---------|:-----------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id | `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version | `false` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid/id | `true` |

### Exported Metrics

| Metric | Unit | Extra Attributes |
|:-------|:-----|:----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type` (user/cli) |

### Exported Events

| Event Name | Key Attributes |
|:-----------|:--------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (opt-in) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` (opt-in) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` (UUID v4) for correlating events within a single user prompt.

### Standard OTel Attributes (All Metrics and Events)

| Attribute | Description |
|:----------|:-----------|
| `session.id` | Unique session identifier |
| `user.id` | Anonymous device/installation identifier |
| `user.account_uuid` | Account UUID (when authenticated) |
| `user.account_id` | Account ID in tagged format |
| `user.email` | Email (OAuth only) |
| `organization.id` | Organization UUID |
| `terminal.type` | Terminal type (iTerm.app, vscode, cursor, tmux) |
| `app.version` | Claude Code version (opt-in) |

### Common Troubleshooting

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; retry or use `brew install --cask claude-code` |
| `curl: (56) Failure writing` | Download script first, then run; or use Homebrew/WinGet |
| `Killed` on Linux install | Add swap space (min 4 GB RAM required) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| OAuth error / 403 Forbidden | `/logout`, restart, re-authenticate; check subscription status |
| `ANTHROPIC_API_KEY` overriding subscription | `unset ANTHROPIC_API_KEY`; remove from shell profile |
| High CPU/memory | `/compact` regularly; restart between tasks; `.gitignore` build dirs |
| Search not working | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| JetBrains not detected on WSL2 | Configure Windows Firewall or switch to mirrored networking |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

### Diagnostic Commands

| Command | Purpose |
|:--------|:--------|
| `/cost` | Show session token usage and cost (API users) |
| `/stats` | View usage patterns (subscribers) |
| `/doctor` | Diagnose installation, settings, MCP, plugins, context issues |
| `/feedback` | Report problems to Anthropic |
| `claude --version` | Check installed version |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- Analytics dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard
- [Manage costs effectively](references/claude-code-costs.md) -- Cost tracking, team spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel setup, environment variables, exported metrics and events, backend recommendations
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation issues, authentication, configuration, performance, IDE integration
- [Changelog](references/claude-code-changelog.md) -- Release notes by version with new features, improvements, and bug fixes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
