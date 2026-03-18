---
name: operations-doc
description: Complete documentation for Claude Code operations — analytics dashboards (Teams/Enterprise usage metrics, contribution metrics with GitHub integration, leaderboard, PR attribution), cost management (token costs, /cost command, team spend limits, rate limit recommendations per team size, agent team token costs, reducing token usage via context management, model selection, MCP overhead, hooks/skills offloading, extended thinking, subagent delegation), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, metrics like session.count/token.usage/cost.usage/lines_of_code.count/active_time.total, events like user_prompt/tool_result/api_request/api_error/tool_decision, standard attributes, cardinality control, dynamic headers, multi-team OTEL_RESOURCE_ATTRIBUTES, Prometheus/OTLP/console exporters, ROI measurement), troubleshooting (installation issues, PATH fixes, TLS/SSL errors, WSL setup, IDE integration, permissions/authentication, /doctor diagnostics), and changelog (release notes by version). Load when discussing Claude Code analytics, usage tracking, contribution metrics, PR attribution, cost management, token costs, /cost, spend limits, rate limits, reducing token usage, context management, OpenTelemetry, OTEL, telemetry, monitoring, metrics export, Prometheus, OTLP, session.count, token.usage, cost.usage, tool_result events, api_request events, troubleshooting, installation issues, command not found claude, PATH setup, TLS errors, WSL issues, IDE detection, /doctor, /bug, changelog, release notes, or Claude Code operations.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code analytics, cost management, monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Summary metrics (Teams/Enterprise):** PRs with CC, lines of code with CC, PRs with CC (%), suggestion accept rate, lines of code accepted.

**Console metrics (API):** lines of code accepted, suggestion accept rate, activity (DAU/sessions), spend (daily cost + user count), per-user spend/lines this month.

#### Contribution Metrics Setup

Requires Owner role. Not available with Zero Data Retention enabled.

1. GitHub admin installs Claude GitHub app at github.com/apps/claude
2. Claude Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle on same page
4. Complete GitHub authentication flow and select organizations

Data appears within 24 hours with daily updates.

#### PR Attribution

PRs are tagged `claude-code-assisted` in GitHub when they contain at least one line written during a Claude Code session. Time window: 21 days before to 2 days after merge. Code with >20% developer rewrite is not attributed. Excluded: lock files, generated code, build dirs, test fixtures, lines >1000 chars.

### Cost Management

Average cost: ~$6/developer/day (90th percentile below $12/day). API usage: ~$100-200/developer/month with Sonnet 4.6.

#### /cost Command

Shows session token usage (total cost, API duration, wall duration, code changes). For API users only; subscribers use `/stats`.

#### Team Rate Limit Recommendations

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

TPM per user decreases with team size because fewer users are concurrent. Rate limits apply at organization level, not per individual.

#### Reducing Token Usage

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` when switching unrelated work; `/compact` with custom focus |
| Choose right model | Sonnet for most tasks, Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | Prefer CLI tools (gh, aws); disable unused servers; lower tool search threshold with `ENABLE_TOOL_SEARCH=auto:<N>` |
| Code intelligence plugins | Precise symbol nav replaces broad file reads |
| Offload to hooks/skills | Hooks preprocess data; skills provide domain knowledge on-demand |
| Move CLAUDE.md to skills | Keep CLAUDE.md under ~500 lines; move specialized instructions to skills |
| Adjust extended thinking | Lower effort with `/effort`; disable in `/config`; set `MAX_THINKING_TOKENS` |
| Delegate to subagents | Isolate verbose operations (tests, logs); only summary returns |
| Write specific prompts | Targeted requests reduce broad scanning |
| Use plan mode | Shift+Tab for complex tasks; prevents expensive re-work |

#### Agent Team Token Costs

~7x more tokens than standard sessions. Each teammate has its own context window. Use Sonnet for teammates, keep teams small, keep spawn prompts focused, clean up when done.

### OpenTelemetry Monitoring

#### Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp             # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Key Configuration Variables

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) |
| `OTEL_METRICS_EXPORTER` | `console`, `otlp`, `prometheus` (comma-separated) |
| `OTEL_LOGS_EXPORTER` | `console`, `otlp` (comma-separated) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | `1` to log prompt content (default: disabled) |
| `OTEL_LOG_TOOL_DETAILS` | `1` to log MCP/tool/skill names (default: disabled) |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes for multi-team orgs (comma-separated key=value, no spaces) |

**Cardinality control:** `OTEL_METRICS_INCLUDE_SESSION_ID` (default: true), `OTEL_METRICS_INCLUDE_VERSION` (default: false), `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (default: true).

**Dynamic headers:** configure `otelHeadersHelper` in settings.json to point to a script that outputs JSON headers. Runs at startup and every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Admin configuration:** set OTel env vars in the managed settings file under `"env"` for centralized control.

#### Metrics

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

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`.

#### Events (via OTEL_LOGS_EXPORTER)

| Event | Key Attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled), `prompt.id` |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `event.timestamp`, `event.sequence`, and `prompt.id` for correlation.

### Troubleshooting Quick Lookup

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; use `brew install --cask claude-code` or retry |
| Install killed on Linux | Add swap space (4 GB RAM required) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| Failed to fetch version | Check network; set `HTTPS_PROXY` |
| `irm` not recognized (Windows) | Use PowerShell, not CMD |
| Requires git-bash (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |
| Shared library error (Linux) | musl/glibc mismatch; check with `ldd /bin/ls` |
| OAuth error / 403 Forbidden | `/logout`, restart, re-authenticate; check subscription/role |
| Disabled org with active subscription | Unset stale `ANTHROPIC_API_KEY` from shell profile |
| Search/skills not working | Install system ripgrep; set `USE_BUILTIN_RIPGREP=0` |
| High CPU/memory | `/compact` regularly; restart between tasks |
| Escape key in JetBrains | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |
| JetBrains not detected on WSL2 | Configure Windows Firewall or switch to mirrored networking |

**Diagnostics:** run `/doctor` to check installation, settings, MCP servers, keybindings, context usage, and plugin loading. Use `/bug` to report issues directly.

#### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

### Changelog

The changelog tracks all Claude Code releases with features, improvements, and bug fixes. Check your version with `claude --version`. The full changelog is available in the reference file below and on [GitHub](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards (Teams/Enterprise vs API Console), enabling contribution metrics (GitHub app setup, Owner role, Zero Data Retention caveat), summary metrics (PRs with CC, lines of code, suggestion accept rate), adoption/PRs-per-user/pull-requests charts, leaderboard and CSV export, PR attribution (tagging criteria, attribution process, time window, excluded files, attribution notes), getting the most from analytics (monitor adoption, measure ROI, identify power users), Console dashboard for API customers (lines accepted, accept rate, activity, spend, team insights)
- [Manage costs effectively](references/claude-code-costs.md) -- average costs, /cost command, managing costs for teams (workspace spend limits, auto-created Claude Code workspace), rate limit recommendations by team size (1-5 through 500+ users), agent team token costs, reducing token usage (context management, /clear, /compact, model selection, MCP overhead, CLI vs MCP, tool search threshold, code intelligence plugins, hooks/skills offloading, CLAUDE.md optimization, extended thinking adjustment, subagent delegation, specific prompts, plan mode, incremental testing), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- quick start, administrator configuration (managed settings), configuration variables (all OTEL env vars, cardinality control, dynamic headers with otelHeadersHelper, multi-team OTEL_RESOURCE_ATTRIBUTES), example configurations (console/OTLP/Prometheus/multiple exporters/separate endpoints/metrics-only/events-only), available metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total with all attributes), events (user_prompt, tool_result, api_request, api_error, tool_decision with all attributes and prompt.id correlation), interpreting metrics (usage/cost monitoring, alerting, event analysis), backend considerations (Prometheus, ClickHouse, Honeycomb, Datadog, Elasticsearch), service information, ROI measurement resources, security and privacy, Bedrock monitoring guide
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, HTML install script, curl failures, TLS/SSL, low memory, Docker hangs, Windows git-bash, musl/glibc, architecture mismatch, macOS dyld, WSL issues), debug steps (network, PATH, conflicting installations, permissions, binary verification), permissions and authentication (repeated prompts, OAuth errors, 403 Forbidden, disabled org, WSL2 OAuth, token expiration), configuration file locations and reset, performance (CPU/memory, hangs, search/ripgrep, WSL search), IDE integration (JetBrains WSL2, Escape key, Windows IDE issues), markdown formatting, /doctor diagnostics, /bug reporting
- [Changelog](references/claude-code-changelog.md) -- release notes for all Claude Code versions with new features, improvements, and bug fixes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
