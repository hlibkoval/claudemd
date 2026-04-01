---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise contribution metrics with GitHub integration, PR attribution, leaderboard, API Console usage/spend), cost management (token tracking with /cost, team spend limits, rate limit recommendations by team size, agent team token costs, context reduction strategies including /clear, model selection, MCP overhead, hooks/skills offloading, extended thinking tuning, subagent delegation), OpenTelemetry monitoring (metrics export via OTLP/Prometheus/console, events via logs protocol, env var configuration, metrics like session.count/token.usage/cost.usage/lines_of_code.count, events like user_prompt/tool_result/api_request/api_error/tool_decision, cardinality control, dynamic headers, mTLS, multi-team OTEL_RESOURCE_ATTRIBUTES, Bedrock monitoring guide), troubleshooting (installation errors, PATH issues, TLS/SSL, WSL, permission errors, authentication, IDE integration, performance, /doctor), and changelog (release notes by version). Load when discussing analytics, usage tracking, contribution metrics, PR attribution, cost management, spend limits, rate limits, token usage, /cost, monitoring, OpenTelemetry, OTEL, telemetry, metrics export, Prometheus, OTLP, troubleshooting, installation errors, command not found, TLS errors, WSL issues, IDE detection, /doctor, or changelog and release notes.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- analytics, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics setup** (Teams/Enterprise only, requires Owner role):
1. GitHub admin installs Claude GitHub App at github.com/apps/claude
2. Claude Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle on the same page
4. Complete GitHub authentication and select organizations

Not available with Zero Data Retention enabled.

**Key summary metrics:** PRs with CC, Lines of code with CC, PRs with CC (%), Suggestion accept rate, Lines of code accepted.

**PR attribution:** Merged PRs are analyzed by matching Claude Code session output against PR diffs. Sessions from 21 days before to 2 days after merge are considered. Code with >20% rewrite is not attributed. Matched PRs are labeled `claude-code-assisted` in GitHub.

### Cost Management

**Average costs:**
- Per developer per day: ~$6 (90th percentile under $12)
- Per developer per month (API, Sonnet): ~$100-200

**Rate limit recommendations (TPM/RPM per user):**

| Team Size | TPM per User | RPM per User |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Key cost reduction strategies:**
- `/clear` between tasks to shed stale context
- `/compact` with focus instructions to control summarization
- Use Sonnet for most tasks, reserve Opus for complex reasoning
- Prefer CLI tools (`gh`, `aws`) over MCP servers for lower context overhead
- Move specialized instructions from CLAUDE.md to skills (load on-demand)
- Lower extended thinking budget with `/effort` or `MAX_THINKING_TOKENS`
- Delegate verbose operations (tests, logs) to subagents

**Agent teams:** ~7x more tokens than standard sessions. Keep teams small, use Sonnet for teammates, clean up when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

### OpenTelemetry Monitoring

**Quick start env vars:**

| Variable | Purpose | Values |
|:---------|:--------|:-------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | Events/logs exporter | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | `60000` (default) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | `5000` (default) |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | `1` to enable |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params/input | `1` to enable |

**Cardinality control:**

| Variable | Default | Controls |
|:---------|:--------|:---------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | `app.version` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | `user.account_uuid` / `user.account_id` |

**Exported metrics:**

| Metric | Unit | Extra Attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type` (user/cli) |

**Exported events** (via `OTEL_LOGS_EXPORTER`):

| Event Name | Key Attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` (if enabled) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` (UUID) for correlating events within a single user prompt.

**Dynamic headers:** Set `otelHeadersHelper` in settings.json to a script that outputs JSON headers. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team attributes:** Use `OTEL_RESOURCE_ATTRIBUTES="department=eng,team.id=platform"` (no spaces allowed in values).

**Admin deployment:** Set OTel env vars in managed settings for org-wide rollout.

### Troubleshooting

**Common installation errors:**

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `curl: (56) Failure writing output` | Network issue; retry or use alternative installer |
| `Killed` during install (Linux) | Add 2GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| TLS/SSL errors | Update CA certificates; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try `brew install --cask claude-code` |
| Install hangs in Docker | Set `WORKDIR /tmp` before running installer |

**Authentication issues:**
- Run `/logout`, close, restart with `claude`, re-authenticate
- OAuth "Invalid code": retry quickly, press `c` to copy URL
- 403 after login: check subscription at claude.ai/settings or Console role
- "Organization disabled" with active subscription: unset `ANTHROPIC_API_KEY` env var

**Configuration file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

**Diagnostics:** Run `/doctor` to check installation, auto-update, settings validation, MCP servers, keybindings, context usage, and plugin/agent loading.

### Changelog

The changelog tracks all Claude Code releases with features, fixes, and improvements. Check your version with `claude --version`. The full changelog is available in the reference file; it is also maintained at https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- Analytics dashboards for Teams/Enterprise (contribution metrics with GitHub integration, PR attribution algorithm, adoption charts, leaderboard, CSV export) and API Console (usage, spend, team insights), setup steps for contribution metrics, summary metrics definitions, chart descriptions, attribution criteria and time windows, excluded files, ROI measurement tips
- [Manage costs effectively](references/claude-code-costs.md) -- Token cost tracking with /cost, team spend limits via Console workspaces, rate limit recommendations by team size, agent team costs, cost reduction strategies (context management, model selection, MCP overhead, hooks/skills offloading, extended thinking, subagent delegation, specific prompts, plan mode), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- Full OTel configuration (env vars, admin managed settings, OTLP/Prometheus/console exporters, mTLS, dynamic headers), all exported metrics (session, lines of code, PR, commit, cost, token, code edit decision, active time) with attributes, all exported events (user_prompt, tool_result, api_request, api_error, tool_decision) with attributes, event correlation via prompt.id, cardinality control, multi-team resource attributes, backend recommendations, service info, ROI measurement guide, security and privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation debugging (network, PATH, conflicting installs, permissions, binary verification), common errors (HTML install script, command not found, curl failures, TLS/SSL, low memory, Docker hangs, Windows-specific, WSL, musl/glibc mismatch, architecture mismatch, macOS dyld), authentication (OAuth, 403, disabled org, WSL2 login), configuration file locations, performance (CPU/memory, hangs, search issues), IDE integration (JetBrains on WSL2, Escape key), markdown formatting, /doctor diagnostics
- [Changelog](references/claude-code-changelog.md) -- Release notes for all Claude Code versions with new features, improvements, bug fixes, and breaking changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
