---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, changelog, and weekly release digests. Covers team analytics (usage metrics, contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export), API Console analytics (spend tracking, team insights), cost tracking (/cost command, /stats), team spend limits, rate limit recommendations by team size, agent team token costs, reducing token usage (context management, /clear, /compact, model selection, MCP overhead, hooks, skills, extended thinking, subagents), OpenTelemetry configuration (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, OTEL_TRACES_EXPORTER, OTLP endpoints, Prometheus, console exporters, dynamic headers, otelHeadersHelper, multi-team OTEL_RESOURCE_ATTRIBUTES, metrics cardinality control, distributed traces beta), available metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total), events (user_prompt, tool_result, api_request, api_error, tool_decision, prompt.id correlation), troubleshooting (installation errors, PATH issues, TLS/SSL, WSL, Docker, permissions, authentication, OAuth, IDE integration, search, performance, markdown formatting, /doctor), changelog (version history, release notes), and weekly dev digests (What's New). Load when discussing Claude Code analytics, costs, monitoring, OpenTelemetry, OTel, telemetry, troubleshooting, installation issues, changelog, release notes, what's new, cost tracking, spend limits, rate limits, contribution metrics, PR attribution, usage metrics, token usage, /cost, /stats, /doctor, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, CLAUDE_CODE_ENABLE_TELEMETRY, or any Claude Code operations topic.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, troubleshooting, and release information.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key Features |
|:-----|:-------------|:-------------|
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

**Teams/Enterprise metrics:** PRs with CC, lines of code with CC, PRs with CC (%), suggestion accept rate, lines accepted, adoption chart (users/sessions), PRs per user, leaderboard (top 10)

**Contribution metrics setup:** Install GitHub app at [github.com/apps/claude](https://github.com/apps/claude), enable at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code), authenticate GitHub. Requires Owner role. Not available with Zero Data Retention.

**PR attribution:** Conservative matching -- PRs tagged `claude-code-assisted` in GitHub. Sessions within 21 days before to 2 days after merge. Code with >20% developer rewrite not attributed. Lock files, generated code, build dirs, test fixtures excluded.

### Cost Management

| Item | Details |
|:-----|:--------|
| Average cost | ~$6/developer/day (90th percentile under $12/day) |
| API average | ~$100-200/developer/month (Sonnet 4.6) |
| Check session cost | `/cost` command (API users) or `/stats` (subscribers) |
| Workspace limits | Set at [platform.claude.com](https://platform.claude.com) |
| Background usage | ~$0.04/session for summarization and command processing |

### Rate Limit Recommendations (per user)

| Team Size | TPM per User | RPM per User |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### Reducing Token Usage

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` (use `/rename` first to preserve session) |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Choose cheaper models | Use Sonnet for most tasks; reserve Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`); disable unused servers via `/mcp` |
| Code intelligence plugins | Install language server plugins for precise symbol navigation |
| Offload to hooks/skills | Preprocess data in hooks; move specialized instructions from CLAUDE.md to skills |
| Adjust extended thinking | `/effort` to lower effort; disable thinking in `/config`; `MAX_THINKING_TOKENS=8000` |
| Use subagents | Delegate verbose operations (tests, logs) to subagents |
| Specific prompts | Avoid vague requests; target specific files and functions |
| Plan mode | Shift+Tab for plan mode before complex implementations |

### OpenTelemetry Monitoring

**Quick start environment variables:**

| Variable | Description | Values |
|:---------|:-----------|:-------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `otlp`, `console`, `none` |
| `OTEL_TRACES_EXPORTER` | Traces exporter (requires beta flag) | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | `60000` (default) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | `5000` (default) |

**Traces (beta):** Also set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER=otlp`.

**Privacy controls:**

| Variable | Default | Effect when enabled |
|:---------|:--------|:-------------------|
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt content in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include tool parameters/input in events |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool I/O content in trace spans (truncated at 60 KB) |

**Cardinality controls:**

| Variable | Default | Description |
|:---------|:--------|:-----------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include session.id in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include app.version in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include user.account_uuid/id in metrics |

**Dynamic headers:** Set `otelHeadersHelper` in settings.json to a script path. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team:** Use `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values; use percent-encoding for special chars).

### Available Metrics

| Metric | Unit | Extra Attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type`: added/removed |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type`: input/output/cacheRead/cacheCreation, `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type`: user/cli |

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

### Available Events

| Event Name | Key Attributes |
|:-----------|:--------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (opt-in) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters` (opt-in) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID) for correlating events to a single user prompt.

### Troubleshooting Quick Reference

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `Killed` during install (Linux) | Add swap: `sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| OAuth error / 403 Forbidden | `/logout`, restart, re-authenticate; verify subscription at claude.ai/settings |
| "organization disabled" with active sub | Unset `ANTHROPIC_API_KEY` (stale key overriding OAuth) |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| High CPU/memory | `/compact` regularly; restart between tasks |
| Search/discovery broken | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| JetBrains Esc not working | Settings > Tools > Terminal: uncheck "Move focus to editor with Escape" |
| WSL2 IDE not detected | Configure Windows Firewall or use mirrored networking |
| Install hangs in Docker | Set `WORKDIR /tmp` before install |

**Diagnostic command:** `/doctor` checks installation, search, auto-update, settings validity, MCP config, keybindings, context usage, and plugin/agent errors.

**Config file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (committed) |

### What's New (Weekly Digests)

**Week 14 (Mar 30 - Apr 3, 2026, v2.1.86-v2.1.91):** Computer use in CLI (research preview), `/powerup` interactive lessons, flicker-free alt-screen rendering (`CLAUDE_CODE_NO_FLICKER=1`), per-tool MCP result-size override (`anthropic/maxResultSizeChars` up to 500K), plugin executables on PATH via `bin/` directory.

**Week 13 (Mar 23-27, 2026, v2.1.83-v2.1.85):** Auto mode (research preview, `defaultMode: "auto"`), computer use in Desktop app, PR auto-fix on Web, transcript search (`/` in Ctrl+O), PowerShell tool (`CLAUDE_CODE_USE_POWERSHELL_TOOL=1`), conditional `if` hooks.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- Analytics dashboards for Teams/Enterprise and API Console, contribution metrics with GitHub integration, PR attribution
- [Manage costs effectively](references/claude-code-costs.md) -- Token usage tracking, team spend limits, rate limit recommendations, strategies to reduce costs
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- Full OTel configuration, available metrics and events, traces beta, backend considerations, security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation issues, authentication, permissions, performance, IDE integration, markdown formatting
- [Changelog](references/claude-code-changelog.md) -- Complete version-by-version release notes
- [What's New index](references/claude-code-whats-new-index.md) -- Weekly dev digest index with feature highlights
- [What's New: Week 13](references/claude-code-whats-new-2026-w13.md) -- Auto mode, computer use, PR auto-fix, transcript search, PowerShell tool, conditional hooks
- [What's New: Week 14](references/claude-code-whats-new-2026-w14.md) -- CLI computer use, /powerup lessons, flicker-free rendering, MCP result-size override, plugin executables

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New index: https://code.claude.com/docs/en/whats-new/index.md
- What's New Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
