---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and changelog. Covers analytics (Teams/Enterprise dashboard at claude.ai/analytics/claude-code with usage metrics, contribution metrics via GitHub integration, PR attribution, leaderboard, CSV export; API/Console dashboard at platform.claude.com/claude-code with spend tracking and team insights), cost management (/cost command for token usage, /stats for subscribers, workspace spend limits, rate limit recommendations by team size 1-5 to 500+ users with TPM/RPM, agent team token costs, context reduction strategies -- /clear between tasks, /compact with custom instructions, model selection with /model, MCP server overhead reduction, code intelligence plugins, hooks for preprocessing, skills for domain knowledge, extended thinking budget, subagent delegation, specific prompts, plan mode), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY=1, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER otlp/console, OTLP endpoint and protocol config, metrics cardinality control, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs, metrics: session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events: user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation, standard attributes session.id/app.version/organization.id/user.account_uuid/user.id/user.email/terminal.type, Prometheus/OTLP/console exporters, separate metrics and logs endpoints, mTLS support, Bedrock monitoring guide), troubleshooting (installation issues -- PATH fixes, conflicting installations, permission errors, network/proxy/TLS issues, low-memory Linux servers, Docker hangs, Windows Git Bash requirement, musl/glibc mismatch, architecture mismatch; authentication -- OAuth errors, 403 forbidden, disabled org with ANTHROPIC_API_KEY override, WSL2 browser login; config file locations -- ~/.claude/settings.json, .claude/settings.json, .claude/settings.local.json, ~/.claude.json, .mcp.json; performance -- high CPU/memory, command hangs, search/ripgrep issues, WSL disk performance; IDE integration -- JetBrains WSL2 detection, Escape key conflicts; /doctor diagnostic command), changelog (release notes by version). Load when discussing Claude Code analytics, usage metrics, contribution metrics, PR attribution, cost management, token usage, spend limits, rate limits, TPM/RPM recommendations, reducing token usage, context management, /cost, /stats, OpenTelemetry, OTEL, telemetry, monitoring, metrics export, prometheus, OTLP, observability, troubleshooting, installation issues, PATH problems, authentication errors, OAuth, 403 forbidden, configuration files, performance issues, /doctor, changelog, release notes, what's new, version history, ROI measurement, or any operations/observability topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- analytics, cost management, monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key features |
|:-----|:-------------|:-------------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

#### Contribution Metrics Setup (Teams/Enterprise)

Requires: Owner role + GitHub admin to install Claude GitHub app.

1. GitHub admin installs app at `github.com/apps/claude`
2. Owner enables Claude Code analytics at `claude.ai/admin-settings/claude-code`
3. Enable "GitHub analytics" toggle
4. Complete GitHub authentication, select orgs

Data appears within 24 hours. Not available with Zero Data Retention enabled.

#### Summary Metrics

| Metric | Description |
|:-------|:------------|
| PRs with CC | Merged PRs containing Claude Code-assisted lines |
| Lines of code with CC | Effective lines (>3 chars after normalization) in merged PRs |
| PRs with Claude Code (%) | Percentage of merged PRs with CC-assisted code |
| Suggestion accept rate | Accept rate for Edit, Write, NotebookEdit tools |
| Lines of code accepted | Total accepted lines (excludes rejections) |

#### PR Attribution

- Matches sessions from 21 days before to 2 days after PR merge
- Lines normalized (whitespace trimmed, quotes standardized, lowercased)
- Code with >20% developer modification not attributed
- Excludes: lock files, generated code, build dirs, test fixtures, lines >1000 chars
- Tagged PRs labeled `claude-code-assisted` in GitHub

### Cost Management

#### Average Costs

| Plan | Typical cost |
|:-----|:-------------|
| Pro/Max (subscription) | Included; use `/stats` for usage patterns |
| API | ~$6/dev/day average, <$12/day for 90% of users |
| API (monthly) | ~$100-200/dev/month with Sonnet |

#### Rate Limit Recommendations (per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

Rates are org-level, not per-user. Fewer users are concurrent in larger orgs.

#### Token Reduction Strategies

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to discard stale context |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Choose cheaper model | Sonnet for most tasks, Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | Prefer CLI tools (gh, aws, gcloud); disable unused servers; lower tool search threshold with `ENABLE_TOOL_SEARCH=auto:<N>` |
| Code intelligence plugins | Precise symbol navigation reduces file reads |
| Preprocessing hooks | Filter verbose output before Claude sees it |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; use skills for specialized workflows |
| Lower thinking budget | `/effort` or `MAX_THINKING_TOKENS=8000` for simple tasks |
| Delegate to subagents | Isolate verbose operations (tests, docs, logs) |
| Write specific prompts | Targeted requests reduce broad scanning |
| Plan mode | Shift+Tab to plan before implementing |

#### Agent Team Costs

~7x more tokens than standard sessions. Each teammate has its own context window. Use Sonnet for teammates, keep teams small, clean up when done.

### OpenTelemetry Monitoring

#### Quick Start

```
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Key Environment Variables

| Variable | Description | Values |
|:---------|:------------|:-------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | Default: `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | Default: `5000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | `1` to enable |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names | `1` to enable |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes | `department=eng,team.id=platform` |

Signal-specific overrides: `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL`, `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`, `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL`, `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`.

Dynamic headers: set `otelHeadersHelper` in settings.json pointing to a script that outputs JSON headers. Refreshes every 29 min (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

#### Cardinality Control

| Variable | Default | Description |
|:---------|:--------|:------------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include session.id |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include app.version |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include user.account_uuid/id |

#### Metrics

| Metric | Unit | Extra attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type` (user/cli) |

Standard attributes on all metrics: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

#### Events

| Event | Key attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID v4) for correlation within a single user prompt.

### Troubleshooting Quick Reference

#### Installation Issues

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; retry or use `brew install --cask claude-code` |
| `curl: (56) Failure writing` | Network interruption; download script first or use Homebrew/WinGet |
| `Killed` on Linux | Add swap space (min 4GB RAM required) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY` if behind proxy |
| Windows `irm` not recognized | Use PowerShell for `irm` command, or CMD installer |
| `requires git-bash` | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` if needed |
| Shared library errors | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |

#### Authentication Issues

| Symptom | Fix |
|:--------|:----|
| OAuth invalid code | Retry quickly; press `c` to copy URL |
| 403 Forbidden | Check subscription at claude.ai/settings; verify Console role |
| "org disabled" with active sub | Unset `ANTHROPIC_API_KEY` env var overriding subscription |
| WSL2 login fails | Set `BROWSER` env var or copy URL manually |

#### Diagnostic Commands

| Command | Purpose |
|:--------|:--------|
| `/doctor` | Check install, settings, MCP, keybindings, context usage |
| `/cost` | Session token usage and cost (API users) |
| `/stats` | Usage patterns (subscribers) |
| `/context` | See what consumes context space |
| `/feedback` | Report problems to Anthropic |
| `claude --version` | Check installed version |

#### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings (permissions, hooks, model) |
| `.claude/settings.json` | Project settings (checked in) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state (theme, OAuth, MCP servers) |
| `.mcp.json` | Project MCP servers (checked in) |

### Changelog

The changelog tracks all Claude Code releases with features, improvements, and bug fixes. Check `claude --version` for your current version. The full changelog is maintained at `github.com/anthropics/claude-code/blob/main/CHANGELOG.md`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- track team usage with analytics dashboards; Teams/Enterprise dashboard with usage metrics, contribution metrics via GitHub integration, PR attribution process, leaderboard, CSV export; API/Console dashboard with spend tracking and team insights; enabling contribution metrics setup steps; summary metrics definitions; adoption, PRs-per-user, and pull request charts; PR attribution criteria, time window, excluded files, attribution notes; monitoring adoption, measuring ROI, identifying power users
- [Cost management](references/claude-code-costs.md) -- manage costs effectively; track costs with /cost command; managing costs for teams with workspace spend limits; rate limit recommendations by team size; agent team token costs; reduce token usage strategies including context management, model selection, MCP server overhead reduction, code intelligence plugins, hooks and skills for preprocessing, extended thinking adjustment, subagent delegation, specific prompts, plan mode; background token usage; LiteLLM for Bedrock/Vertex/Foundry cost tracking
- [Monitoring](references/claude-code-monitoring-usage.md) -- OpenTelemetry monitoring; quick start configuration; administrator managed settings; all environment variables for metrics and logs exporters, OTLP endpoints, protocols, authentication, export intervals, cardinality control; dynamic headers with otelHeadersHelper; multi-team OTEL_RESOURCE_ATTRIBUTES; example configurations for console, OTLP/gRPC, Prometheus, multiple exporters, separate endpoints; complete metrics reference (8 metrics with attributes); complete events reference (5 event types with attributes); prompt.id correlation; interpret metrics for usage monitoring, cost monitoring, alerting; backend considerations for time series, columnar stores, observability platforms; service information and resource attributes; ROI measurement resources; security and privacy; Bedrock monitoring guide
- [Troubleshooting](references/claude-code-troubleshooting.md) -- solutions to common issues; installation debugging (network connectivity, PATH verification, conflicting installations, directory permissions, binary verification); common installation issues (HTML instead of script, command not found, curl failures, TLS/SSL errors, version fetch failures, Windows shell issues, low-memory Linux, Docker hangs, Claude Desktop override, Git Bash requirement, musl/glibc mismatch, architecture mismatch, macOS dyld errors, WSL errors, WSL2 sandbox setup, permission errors); authentication issues (repeated permission prompts, OAuth errors, 403 forbidden, disabled org, WSL2 login, token expiry); configuration file locations and reset; performance and stability (CPU/memory, hangs, search/ripgrep issues, WSL disk performance); IDE integration issues (JetBrains WSL2, Escape key conflicts); markdown formatting issues; /doctor diagnostic command
- [Changelog](references/claude-code-changelog.md) -- release notes for all Claude Code versions with new features, improvements, and bug fixes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Cost management: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
