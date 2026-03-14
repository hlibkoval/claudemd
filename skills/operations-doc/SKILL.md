---
name: operations-doc
description: Complete documentation for Claude Code operations and maintenance -- analytics dashboards (Teams/Enterprise contribution metrics, GitHub integration, PR attribution, API Console usage/spend tracking, leaderboard, CSV export), cost management (token usage tracking, /cost command, team spend limits, rate limit TPM/RPM recommendations by team size, agent team token costs, reducing token usage strategies including context management /clear /compact, model selection /model, MCP server overhead reduction, code intelligence plugins, hooks/skills preprocessing, CLAUDE.md optimization, extended thinking budget, subagent delegation, background token usage), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER, OTLP endpoint/protocol/headers configuration, metrics cardinality control, dynamic headers otelHeadersHelper, multi-team OTEL_RESOURCE_ATTRIBUTES, metrics list session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation, metric attributes and details, backend considerations Prometheus/ClickHouse/Datadog/Honeycomb, ROI measurement, security and privacy controls OTEL_LOG_USER_PROMPTS/OTEL_LOG_TOOL_DETAILS, Bedrock monitoring), troubleshooting (installation issues PATH/TLS/SSL/curl errors/low-memory/Docker/Windows/WSL/musl-glibc mismatch/architecture mismatch, authentication OAuth/403/token expiry, permissions, configuration file locations and reset, performance CPU/memory/hangs, search and discovery ripgrep, IDE integration JetBrains/WSL2, markdown formatting, /doctor diagnostics, /bug reporting), changelog (release notes by version). Load when discussing Claude Code analytics, usage dashboards, contribution metrics, GitHub integration for analytics, PR attribution, cost management, token usage, /cost command, spend limits, rate limits TPM RPM, reducing costs, prompt caching, auto-compaction, /compact, context management, model selection for cost, MCP overhead, code intelligence plugins, extended thinking budget, background token usage, OpenTelemetry, OTEL, telemetry, monitoring, metrics export, OTLP, Prometheus, observability, otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES, ROI measurement, troubleshooting Claude Code, installation problems, command not found claude, PATH issues, TLS errors, SSL errors, WSL issues, authentication errors, OAuth errors, 403 forbidden, /doctor, /bug, performance issues, search not working, ripgrep, IDE integration issues, JetBrains detection, markdown formatting, changelog, release notes, what's new, version history.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations and maintenance -- analytics, cost management, monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics** (Teams/Enterprise, requires GitHub app setup):
- PRs with Claude Code, lines of code with CC, suggestion accept rate
- Requires Owner role + GitHub admin to install claude GitHub app
- Not available with Zero Data Retention enabled
- Data appears within 24 hours, updates daily

**PR attribution**: merged PRs analyzed for Claude Code involvement. Sessions from 21 days before to 2 days after merge. Auto-generated files (lock files, build artifacts, minified code) excluded. Code with >20% manual rewrite is not attributed.

**Console metrics** (API customers): lines of code accepted, suggestion accept rate, daily active users/sessions, daily spend, per-user spend/lines.

### Cost Management

Average cost: ~$6/developer/day (90th percentile <$12/day). Team API usage: ~$100-200/developer/month with Sonnet.

**Track costs**: `/cost` shows session token usage (API users). `/stats` for subscribers.

**Team spend limits**: set workspace spend limits in Console. "Claude Code" workspace auto-created on first auth. For Bedrock/Vertex/Foundry, use LiteLLM for spend tracking.

#### Rate Limit Recommendations (per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

TPM decreases with team size because fewer users are concurrent. Limits apply at org level, not per user.

#### Reducing Token Usage

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to drop stale context; `/compact` with custom focus instructions |
| Choose cheaper model | Sonnet for most tasks, Opus for complex reasoning; `/model` to switch; `model: haiku` for subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`); disable unused servers via `/mcp`; lower tool search threshold with `ENABLE_TOOL_SEARCH=auto:<N>` |
| Code intelligence plugins | Install LSP plugins for precise navigation instead of text search |
| Hooks for preprocessing | Filter verbose output before Claude sees it (e.g., grep test failures) |
| Move instructions to skills | Keep CLAUDE.md <500 lines; put specialized instructions in on-demand skills |
| Adjust extended thinking | Lower effort with `/effort`; disable in `/config`; set `MAX_THINKING_TOKENS=8000` |
| Delegate to subagents | Isolate verbose operations (tests, logs) so summary returns to main context |
| Write specific prompts | Avoid vague requests that trigger broad scanning |

**Agent teams**: ~7x more tokens than standard sessions. Keep tasks small and self-contained.

**Background usage**: conversation summarization and command processing use small amounts (~$0.04/session) even when idle.

### OpenTelemetry Monitoring

**Quick start**:
```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console
OTEL_LOGS_EXPORTER=otlp             # otlp, console
OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc, http/json, http/protobuf
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Key Configuration Variables

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required, set to `1`) |
| `OTEL_METRICS_EXPORTER` | Metrics exporters (comma-separated): `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs exporters: `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers (`Authorization=Bearer token`) |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: disabled, set `1`) |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names in events (default: disabled, set `1`) |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |

Per-signal endpoint overrides: `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`, `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` (with matching `_PROTOCOL` variants).

**Dynamic headers**: set `otelHeadersHelper` in settings.json to a script path. Runs at startup and every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team attributes**: `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"` -- no spaces in values, comma-separated key=value pairs.

**Cardinality control**: `OTEL_METRICS_INCLUDE_SESSION_ID` (default: true), `OTEL_METRICS_INCLUDE_VERSION` (default: false), `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (default: true).

#### Metrics

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

Standard attributes on all metrics: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`.

#### Events

| Event | Key attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` for correlation -- links events produced while processing a single user prompt.

**Admin configuration**: set OTel env vars in managed settings for org-wide control. Distribute via MDM.

### Troubleshooting Quick Reference

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; use `brew install --cask claude-code` |
| `curl: (56) Failure writing` | Network issue; download script first or use Homebrew |
| `Killed` on Linux | Add 2GB swap; need 4GB+ RAM |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY` if behind proxy |
| `irm not recognized` | Wrong shell -- use PowerShell for `irm`, CMD for `curl` |
| `requires git-bash` (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Need macOS 13.0+; try Homebrew |
| OAuth error / 403 | `/logout` then restart; verify subscription; check proxy |
| Search not working | Install system ripgrep; set `USE_BUILTIN_RIPGREP=0` |
| JetBrains not detected (WSL2) | Configure Windows Firewall or use mirrored networking |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| High CPU/memory | `/compact` regularly; restart between tasks |

**Configuration file locations**:

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

**Diagnostics**: `/doctor` checks installation, settings, MCP, keybindings, context usage, plugins. `/bug` reports issues to Anthropic.

### Changelog

The changelog tracks all Claude Code releases with features, fixes, and improvements by version. See the full reference for complete release history.

Run `claude --version` to check your installed version.

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- Teams/Enterprise analytics dashboard (usage metrics, contribution metrics, GitHub integration setup, PR attribution process, leaderboard, CSV export), Console analytics for API customers (usage, spend, team insights), ROI measurement tips
- [Cost management](references/claude-code-costs.md) -- /cost command, team spend limits, rate limit recommendations by team size, agent team token costs, reducing token usage (context management, model selection, MCP overhead, code intelligence plugins, hooks preprocessing, CLAUDE.md optimization, extended thinking, subagent delegation, specific prompts), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- full OTel configuration (env vars, OTLP/Prometheus/console exporters, dynamic headers, multi-team attributes, cardinality control), all metrics and events with attributes, event correlation via prompt.id, usage/cost/alerting analysis patterns, backend considerations, admin managed settings, security and privacy, Bedrock monitoring guide, ROI measurement resources
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, TLS/SSL, curl errors, low memory, Docker, Windows/WSL, musl/glibc, architecture), authentication (OAuth, 403, token expiry), configuration file locations and reset, performance and stability, search/discovery with ripgrep, IDE integration (JetBrains WSL2, Escape key), markdown formatting, /doctor diagnostics, /bug reporting
- [Changelog](references/claude-code-changelog.md) -- complete release notes by version with features, improvements, and bug fixes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Cost management: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
