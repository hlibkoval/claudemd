---
name: operations-doc
description: Reference documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise contribution metrics, API Console usage), cost management (tracking, team spend limits, rate limits, token reduction strategies), OpenTelemetry monitoring (metrics, events, configuration variables, backend setup), troubleshooting (installation, authentication, IDE integration, performance), and changelog. Load when discussing cost optimization, usage monitoring, telemetry, debugging, or operational concerns.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics** (Teams/Enterprise only) require GitHub app install + Claude Owner enabling analytics at claude.ai/admin-settings/claude-code. Not available with Zero Data Retention.

**Summary metrics:** PRs with CC, lines of code with CC, PRs with CC (%), suggestion accept rate, lines of code accepted.

**PR attribution:** conservative matching -- only lines with high confidence in CC involvement. Sessions from 21 days before to 2 days after merge are considered. Code rewritten >20% is not attributed. Merged PRs get the `claude-code-assisted` GitHub label.

### Cost Management

**Average costs:** ~$6/developer/day (90th percentile <$12/day). API usage: ~$100-200/developer/month with Sonnet.

**Track costs:** `/cost` shows current session token usage (API users). `/stats` for subscribers.

**Team spend limits:** Set workspace limits at platform.claude.com. A "Claude Code" workspace is auto-created on first Console auth.

**Rate limit recommendations (per user):**

| Team Size | TPM/user | RPM/user |
|:----------|:---------|:---------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Token reduction strategies:**
- `/clear` between tasks, `/compact` with custom instructions
- Use Sonnet for most tasks, Opus for complex reasoning; `model: haiku` for subagents
- Disable unused MCP servers (`/mcp`); prefer CLI tools over MCP when available
- Move detailed instructions from CLAUDE.md to skills (on-demand loading)
- Delegate verbose operations to subagents
- Lower extended thinking budget (`MAX_THINKING_TOKENS=8000`) for simpler tasks
- Install code intelligence plugins for typed languages (reduces file reads)
- Write specific prompts; use plan mode (Shift+Tab) for complex tasks

**Agent teams:** ~7x more tokens than standard sessions. Use Sonnet for teammates, keep teams small, clean up when done. Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

### OpenTelemetry Monitoring

**Quick start:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp             # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Description | Default |
|:---------|:-----------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | -- |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s) | -- |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s) | -- |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for OTLP | -- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | -- |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | -- |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names | disabled |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes (team/dept) | -- |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Temporality | delta |

**Cardinality control:** `OTEL_METRICS_INCLUDE_SESSION_ID` (default: true), `OTEL_METRICS_INCLUDE_VERSION` (default: false), `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (default: true).

**Dynamic headers:** Set `otelHeadersHelper` in settings.json to a script path. Refreshes every 29 min (customize with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

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
| `claude_code.active_time.total` | s | `type` (user/cli) |

**Exported events** (via `OTEL_LOGS_EXPORTER`):

| Event Name | Key Attributes |
|:-----------|:--------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` (UUID v4) for correlating events within a single user prompt.

**Standard attributes** on all metrics/events: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`.

### Troubleshooting

**Installation quick-fix table:**

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML (region block or network issue); use `brew install --cask claude-code` |
| `curl: (56) Failure writing` | Download script first, then run; or use Homebrew/WinGet |
| `Killed` on Linux | Add 2GB swap (`fallocate -l 2G /swapfile`) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check proxy/firewall; set `HTTPS_PROXY` |
| `Illegal instruction` on Linux | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; try Homebrew |
| Shared library errors (Linux) | musl/glibc mismatch; check `ldd /bin/ls` |
| Windows `irm` not recognized | Use PowerShell, not CMD |
| `requires git-bash` (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` in settings |

**Auth issues:** `/logout` then restart. Press `c` to copy OAuth URL if browser doesn't open. 403 = check subscription/role/proxy.

**Performance:** `/compact` to reduce context, restart between tasks, add build dirs to `.gitignore`.

**Search not working:** Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0`.

**Diagnostics:** Run `/doctor` to check installation, settings, MCP servers, keybindings, context usage, and plugin loading.

**Config file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (committed) |

### Changelog

The changelog reference file contains the full release history for Claude Code. Consult it for version-specific changes, new features, bug fixes, and breaking changes.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- dashboards for Teams/Enterprise and API Console, contribution metrics, PR attribution, GitHub integration setup
- [Manage costs effectively](references/claude-code-costs.md) -- cost tracking, team spend limits, rate limit recommendations, token reduction strategies, agent team costs
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- metrics and events export, environment variables, dynamic headers, backend considerations, security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues, authentication, IDE integration, performance, configuration file locations
- [Changelog](references/claude-code-changelog.md) -- full release history with version-by-version changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
