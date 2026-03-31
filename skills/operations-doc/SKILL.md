---
name: operations-doc
description: Complete documentation for Claude Code operations -- covering analytics (Teams/Enterprise dashboard with usage metrics, contribution metrics via GitHub integration, leaderboard, data export, PR attribution; API Console dashboard with spend tracking and team insights), cost management (/cost command, /stats for subscribers, workspace spend limits, rate limit recommendations by team size with TPM/RPM tables, agent team token costs, prompt caching, auto-compaction, context management with /clear and /compact, model selection with /model, MCP overhead reduction, code intelligence plugins, hooks and skills for preprocessing, extended thinking budget, subagent delegation, writing specific prompts, plan mode, background token usage), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER with otlp/prometheus/console/none, OTEL_LOGS_EXPORTER, OTLP protocol and endpoint config, metrics cardinality control, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs, available metrics including session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events including user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation, standard attributes, managed settings configuration, Prometheus/OTLP/console exporter examples, backend considerations, ROI measurement guide), troubleshooting (installation issues with PATH/TLS/proxy/memory/Docker/Windows/WSL/musl-glibc diagnostics, authentication issues with OAuth/403/disabled-org/token-expired, configuration file locations and reset, performance and stability, IDE integration issues with JetBrains WSL2/Escape key, markdown formatting, search issues with ripgrep, /doctor command), and changelog (release notes by version). Load when discussing Claude Code analytics, usage dashboards, contribution metrics, PR attribution, cost management, token usage, /cost, /stats, spend limits, rate limits, TPM/RPM recommendations, reducing token usage, context management, OpenTelemetry, OTEL, telemetry, monitoring, CLAUDE_CODE_ENABLE_TELEMETRY, metrics export, Prometheus, OTLP, observability, ROI measurement, troubleshooting, installation issues, PATH problems, TLS errors, proxy configuration, authentication errors, OAuth issues, /doctor, IDE integration issues, JetBrains WSL2, search issues, ripgrep, changelog, release notes, version history, or any operations-related topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key features |
|:-----|:-------------|:-------------|
| **Teams / Enterprise** | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| **API (Console)** | `platform.claude.com/claude-code` | Lines accepted, accept rate, activity chart, spend tracking, team insights |

**Contribution metrics setup (Teams/Enterprise):** Install the Claude GitHub app at `github.com/apps/claude`, enable analytics and GitHub toggle at `claude.ai/admin-settings/claude-code`, complete GitHub auth. Requires Owner role. Data appears within 24 hours. Not available with Zero Data Retention enabled.

### Summary Metrics (Teams/Enterprise)

| Metric | Description |
|:-------|:------------|
| **PRs with CC** | Merged PRs containing Claude Code-assisted lines |
| **Lines of code with CC** | Effective lines (>3 chars after normalization) in merged PRs |
| **PRs with CC (%)** | Percentage of merged PRs with CC-assisted code |
| **Suggestion accept rate** | Accept rate for Edit/Write/NotebookEdit tool usage |
| **Lines of code accepted** | Total accepted lines (excludes rejections, ignores later deletions) |

### PR Attribution

- PRs tagged as "with Claude Code" when they contain at least one CC-assisted line
- Session matching window: 21 days before to 2 days after PR merge date
- Code rewritten >20% by developer is not attributed to CC
- Lines normalized before comparison (whitespace, quotes, case)
- Merged PRs labeled `claude-code-assisted` in GitHub
- Excluded: lock files, generated code, build directories, test fixtures, lines >1000 chars

### Cost Tracking

| Command / Setting | Purpose |
|:------------------|:--------|
| `/cost` | Session token usage and cost (API users only; subscribers use `/stats`) |
| `/stats` | Usage patterns for Claude Max/Pro subscribers |
| Workspace spend limits | Set at `platform.claude.com` for API teams |
| `CLAUDE_CODE_OTEL_*` | OpenTelemetry cost metrics export |

**Typical costs:** Average ~$6/developer/day, <$12/day for 90% of users. ~$100-200/developer/month with Sonnet 4.6 on API.

### Rate Limit Recommendations (TPM / RPM per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

TPM per user decreases with larger teams due to lower concurrent usage. Limits apply at the organization level, so individual users can temporarily exceed their share.

### Reducing Token Usage

| Strategy | Detail |
|:---------|:-------|
| `/clear` between tasks | Remove stale context when switching work |
| `/compact` with focus | Custom compaction: `/compact Focus on code samples and API usage` |
| Choose the right model | Sonnet for most tasks; Opus for complex reasoning; Haiku for simple subagents |
| Reduce MCP overhead | Prefer CLI tools (gh, aws, gcloud); disable unused servers via `/mcp` |
| Code intelligence plugins | Precise symbol navigation reduces file reads |
| Hooks for preprocessing | Filter large outputs (logs, test results) before context |
| Move instructions to skills | Skills load on demand; keep CLAUDE.md under ~500 lines |
| Lower extended thinking | `/effort` to reduce budget; `MAX_THINKING_TOKENS=8000`; disable in `/config` |
| Delegate to subagents | Verbose operations (tests, docs, logs) stay in subagent context |
| Specific prompts | "Add validation to auth.ts" beats "improve this codebase" |
| Plan mode (Shift+Tab) | Explore and propose before implementing; prevents expensive rework |

**Agent teams:** ~7x token usage vs standard sessions. Keep teams small, spawn prompts focused, clean up when done.

### OpenTelemetry Quick Start

```
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp             # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc | http/json | http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Environment Variables

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry (set to `1`) |
| `OTEL_METRICS_EXPORTER` | Exporter type(s), comma-separated |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter type(s) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for all signals |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint for all signals |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers for OTLP |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval in ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval in ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | Set `1` to include prompt content (off by default) |
| `OTEL_LOG_TOOL_DETAILS` | Set `1` to include tool parameters and input (off by default) |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom resource attributes for multi-team filtering (comma-separated key=value) |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |

**Cardinality control:**

| Variable | Default | Purpose |
|:---------|:--------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include session.id in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include app.version in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include user.account_uuid/account_id |

**Dynamic headers:** Set `otelHeadersHelper` in settings.json to a script that outputs JSON headers. Refreshes every 29 minutes by default (customize with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

### Available OTel Metrics

| Metric | Unit | Extra attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type`: added/removed |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type`: input/output/cacheRead/cacheCreation; `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type`: user/cli |

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

### Available OTel Events

| Event name | Key attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (when `OTEL_LOG_USER_PROMPTS=1`) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters`/`tool_input` (when `OTEL_LOG_TOOL_DETAILS=1`) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID v4) for correlating events triggered by the same user prompt, plus `event.sequence` for ordering within a session.

### Troubleshooting Quick Lookup

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; use `brew install --cask claude-code` or check region |
| `curl: (56) Failure writing` | Network interruption; retry or use Homebrew/WinGet |
| `Killed` during install | Add swap space (need 4GB+ RAM) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Failed to fetch version` | Check `storage.googleapis.com` reachability; set `HTTPS_PROXY` |
| `irm` / `&&` not recognized | Wrong shell on Windows; use PowerShell for `irm` or CMD for `curl` |
| `Requires git-bash` | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` if needed |
| `Error loading shared library` | musl/glibc binary mismatch; check `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |
| OAuth / 403 errors | Run `/logout` then restart; verify subscription; check proxy |
| "Organization disabled" | Unset stale `ANTHROPIC_API_KEY` env var overriding subscription |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| Search/`@file`/skills broken | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| High CPU/memory | `/compact` regularly; restart between tasks; `.gitignore` build dirs |
| JetBrains Esc key conflict | Settings > Tools > Terminal: uncheck "Move focus to editor with Escape" |
| JetBrains not detected (WSL2) | Configure Windows Firewall for WSL2 subnet or switch to mirrored networking |

**Diagnostics:** Run `/doctor` to check installation, settings, MCP servers, keybindings, context usage, and plugin/agent loading.

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings (permissions, hooks, model overrides) |
| `.claude/settings.json` | Project settings (version controlled) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP servers) |
| `.mcp.json` | Project MCP servers (version controlled) |
| `managed-mcp.json` | Managed MCP servers (system-level paths) |

### Changelog

The changelog tracks all Claude Code releases with features, improvements, and bug fixes. Check your version with `claude --version`. The full changelog is available in the reference file below.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- Analytics dashboards for Teams/Enterprise (usage metrics, contribution metrics with GitHub integration, leaderboard, CSV export, PR attribution criteria and process, adoption monitoring, ROI measurement) and API Console (lines accepted, accept rate, activity, spend, team insights)
- [Manage costs effectively](references/claude-code-costs.md) -- Cost tracking with /cost and /stats, workspace spend limits, rate limit recommendations by team size, agent team token costs, reducing token usage (context management, model selection, MCP overhead, code intelligence plugins, hooks/skills preprocessing, extended thinking budget, subagent delegation, specific prompts, plan mode), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- Full OTel configuration (environment variables, managed settings, exporters, protocols, endpoints, auth headers, cardinality control, dynamic headers, multi-team attributes), all available metrics (session/lines/PR/commit/cost/token/edit-decision/active-time counters with attributes), all events (user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation), example configurations, backend considerations, ROI measurement guide, security and privacy, Bedrock monitoring
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation diagnostics (PATH, network, proxy, TLS, permissions, binary verification, conflicting installs), common issues (HTML script, command not found, curl failures, low memory, Docker, Windows shell/git-bash, musl/glibc, architecture mismatch, macOS dyld, WSL), authentication (OAuth, 403, disabled org, token expiry, WSL2 browser), configuration file locations and reset, performance (CPU/memory, hangs, search/ripgrep, WSL disk), IDE integration (JetBrains WSL2/Escape, Windows IDE), markdown formatting, /doctor
- [Changelog](references/claude-code-changelog.md) -- Release notes for all Claude Code versions with features, improvements, and bug fixes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
