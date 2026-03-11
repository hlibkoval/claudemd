---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise contribution metrics, GitHub integration, PR attribution, leaderboards, Console usage/spend), cost management (/cost command, team spend limits, rate limit recommendations by team size, agent team token costs, reducing token usage via context management/model selection/MCP overhead/hooks/skills/extended thinking/subagents), OpenTelemetry monitoring (metrics and events export, OTLP/Prometheus/console exporters, environment variable configuration, available metrics like session/token/cost/LOC/commit/PR/active-time counters, events like user_prompt/tool_result/api_request/api_error/tool_decision, cardinality control, dynamic headers, multi-team attributes, backend considerations, ROI measurement), troubleshooting (installation issues, PATH fixes, TLS/SSL errors, Windows/WSL setup, permission errors, authentication/OAuth issues, IDE integration, performance, search issues, markdown formatting, /doctor command), and the changelog. Load when discussing Claude Code analytics, usage tracking, contribution metrics, cost optimization, token usage, spend limits, rate limits, OpenTelemetry, monitoring, telemetry, OTLP, Prometheus, troubleshooting, installation problems, debugging, /cost, /doctor, or the changelog.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code analytics, cost management, monitoring via OpenTelemetry, and troubleshooting.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

**Teams/Enterprise metrics**: PRs with CC, lines of code with CC, PR percentage, suggestion accept rate, lines accepted. Includes adoption chart (DAU/sessions), PRs-per-user chart, PR breakdown, and leaderboard (top 10 + CSV export).

**Contribution metrics** require GitHub integration (install Claude GitHub app, enable in admin settings). Data appears within 24 hours. Not available with Zero Data Retention.

**PR attribution**: merged PRs are analyzed by matching Claude Code session activity against PR diffs. Sessions within 21 days before to 2 days after merge are considered. Code rewritten >20% is not attributed. Matched PRs get the `claude-code-assisted` label in GitHub.

**Console metrics**: lines accepted, suggestion accept rate, DAU/sessions chart, daily spend chart, per-user spend and lines table.

### Cost Management

**Typical costs**: ~$6/developer/day average (90th percentile under $12/day). ~$100-200/developer/month with Sonnet 4.6 for API users.

**Track costs**: `/cost` shows session token usage (API users). `/stats` shows usage patterns (subscribers).

**Team spend limits**: set workspace spend limits in Claude Console. A "Claude Code" workspace is auto-created on first auth.

#### Rate Limit Recommendations (per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

Rate limits apply at organization level, not per individual.

#### Reducing Token Usage

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to drop stale context; `/compact` with custom instructions |
| Choose right model | Sonnet for most tasks, Opus for complex reasoning; `/model` to switch; `model: haiku` for simple subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`, `sentry-cli`); disable unused servers; lower tool search threshold with `ENABLE_TOOL_SEARCH=auto:<N>` |
| Code intelligence plugins | Symbol navigation instead of grep + file reads; auto type-error reporting |
| Hooks and skills | Preprocess data in hooks (filter logs before Claude reads them); move specialized instructions from CLAUDE.md to skills for on-demand loading |
| Extended thinking | Lower effort level in `/model`, disable in `/config`, or set `MAX_THINKING_TOKENS=8000` |
| Subagents | Delegate verbose operations (tests, docs, logs) so only summaries return to main context |
| Agent teams | ~7x tokens vs standard sessions; keep tasks small; use Sonnet for teammates |
| Specific prompts | Avoid vague requests; name files and functions directly |
| Plan mode | Shift+Tab before implementation; course-correct early with Escape; `/rewind` to restore checkpoints |

### OpenTelemetry Monitoring

#### Quick Start

```
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp           # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc  # grpc | http/json | http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

Admin-managed: set env vars in managed settings JSON under `"env"` key. Distributed via MDM; users cannot override.

#### Key Environment Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | -- |
| `OTEL_METRICS_EXPORTER` | Exporter type(s), comma-separated | -- |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter type(s) | -- |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for all signals | -- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | -- |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | Metrics-specific endpoint override | -- |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` | Logs-specific endpoint override | -- |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers for OTLP | -- |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (set `1`) | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names in events (set `1`) | disabled |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Metrics temporality | `delta` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes (comma-separated `key=value`) | -- |

#### Cardinality Control

| Variable | Default |
|:---------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` |

#### Dynamic Headers

Set `otelHeadersHelper` in settings.json to a script path that outputs JSON headers. Refreshes every 29 minutes by default (`CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

#### Available Metrics

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

Standard attributes on all metrics: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`.

#### Available Events (via logs exporter)

| Event Name | Key Attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID v4) for correlating events within a single user prompt. All events include `event.sequence` for ordering within a session.

#### Service Resource Attributes

`service.name`: `claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`, `wsl.version` (if applicable). Meter name: `com.anthropic.claude_code`.

### Troubleshooting Quick Lookup

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `curl: (56) Failure writing output` | Download script first then run, or use Homebrew/WinGet |
| `Killed` during Linux install | Add 2GB swap (`fallocate -l 2G /swapfile`); needs 4GB RAM minimum |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check network to `storage.googleapis.com`; set `HTTPS_PROXY` if behind proxy |
| `irm`/`&&` not recognized (Windows) | Use correct shell: PowerShell for `irm`, CMD for `curl` installer |
| `Error loading shared library` | Wrong binary variant (musl/glibc mismatch); check `ldd /bin/ls` |
| `Illegal instruction` on Linux | Architecture mismatch; verify with `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; try `brew install --cask claude-code` |
| 403 Forbidden after login | Verify subscription/role; check proxy config |
| OAuth `Invalid code` | Retry quickly; copy full URL with `c` key |
| Repeated permission prompts | Use `/permissions` to pre-approve commands |
| High CPU/memory | `/compact` regularly; restart between tasks; gitignore build dirs |
| Search/discovery broken | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| JetBrains Escape key | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |
| JetBrains not detected on WSL2 | Configure Windows Firewall or switch to mirrored networking |

**Diagnostic command**: `/doctor` checks installation, auto-update, settings, MCP servers, keybindings, context usage, plugins, and agents.

**Report bugs**: `/bug` command sends reports directly to Anthropic.

#### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards for Teams/Enterprise and API customers, contribution metrics, GitHub integration setup, PR attribution, leaderboard, data export, summary metrics, adoption charts
- [Manage costs effectively](references/claude-code-costs.md) -- /cost command, team spend limits, rate limit recommendations by team size, agent team token costs, reducing token usage (context management, model selection, MCP overhead, hooks, skills, extended thinking, subagents), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- enabling telemetry, OTLP/Prometheus/console exporters, environment variables, administrator configuration, dynamic headers, multi-team attributes, metrics (session/token/cost/LOC/commit/PR/active-time), events (user_prompt/tool_result/api_request/api_error/tool_decision), backend considerations, ROI measurement, security and privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, TLS, network, permissions, Windows/WSL, Docker), authentication problems, IDE integration, performance, search issues, markdown formatting, /doctor diagnostic command
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
