---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise at claude.ai/analytics/claude-code with usage metrics, contribution metrics, GitHub integration, leaderboard, CSV export; API/Console at platform.claude.com/claude-code with spend tracking, team insights), PR attribution (conservative matching, 21-day session window, normalized line comparison, claude-code-assisted label, excluded files like lock files and build artifacts), cost management (/cost command for API users, /stats for subscribers, average ~$6/dev/day with 90% under $12, ~$100-200/dev/month with Sonnet, workspace spend limits, rate limit recommendations by team size from 200k-300k TPM for 1-5 users down to 10k-15k for 500+, agent team token costs ~7x standard), cost reduction strategies (context management with /clear and /compact, model selection with /model and Sonnet vs Opus, MCP server overhead reduction, code intelligence plugins, hooks for preprocessing, skills for domain knowledge, extended thinking budget with /effort and MAX_THINKING_TOKENS, subagent delegation, specific prompts, plan mode), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY=1, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER otlp/console, OTLP protocols grpc/http-json/http-protobuf, metrics cardinality control, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs), OTel metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage in USD, token.usage with input/output/cacheRead/cacheCreation types, code_edit_tool.decision with tool_name/decision/source/language, active_time.total with user/cli types), OTel events (user_prompt with prompt.id correlation, tool_result with tool_name/success/duration_ms/decision_type/tool_parameters, api_request with model/cost_usd/tokens/speed, api_error with status_code/attempt, tool_decision with decision/source), standard attributes (session.id, app.version, organization.id, user.account_uuid, user.account_id, user.id, user.email, terminal.type), administrator managed settings for telemetry, troubleshooting (installation issues with PATH/TLS/proxy/permissions/Docker/WSL/musl-glibc mismatch, authentication issues with OAuth/403/disabled org/API key override, performance issues with CPU/memory/search/WSL disk penalties, IDE integration with JetBrains WSL2 firewall/networking, markdown formatting, /doctor diagnostics, configuration file locations and reset), changelog (release notes by version). Load when discussing Claude Code analytics, usage metrics, contribution metrics, PR attribution, GitHub integration for analytics, cost management, token usage, spend limits, rate limits, pricing, cost reduction, context management for costs, OpenTelemetry, telemetry, monitoring, OTEL metrics, OTEL events, observability, Prometheus, OTLP, metrics export, troubleshooting Claude Code, installation issues, PATH issues, authentication errors, OAuth errors, 403 forbidden, performance issues, IDE integration issues, JetBrains WSL2, /doctor, /cost, /stats, changelog, release notes, what's new, version history, or operational concerns with Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Teams/Enterprise metrics:** PRs with CC, lines of code with CC, PRs with CC (%), suggestion accept rate, lines of code accepted.

**Console metrics:** lines of code accepted, suggestion accept rate, activity (DAU/sessions), spend (daily cost vs user count), per-user spend and lines this month.

#### Contribution Metrics Setup (Teams/Enterprise)

Requires Owner role + GitHub admin. Not available with Zero Data Retention.

1. GitHub admin installs Claude GitHub app at github.com/apps/claude
2. Claude Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle on the same page
4. Complete GitHub authentication and select organizations

Data appears within 24 hours with daily updates.

#### PR Attribution

PRs tagged as "with Claude Code" if they contain at least one Claude Code-assisted line. The `claude-code-assisted` label is applied in GitHub.

| Parameter | Value |
|:----------|:------|
| Session window | 21 days before to 2 days after merge |
| Rewrite threshold | >20% difference = not attributed |
| Line filtering | Only "effective lines" (>3 chars after normalization) |
| Excluded files | Lock files, generated code, build dirs, test fixtures, lines >1000 chars |

### Cost Management

| Metric | Value |
|:-------|:------|
| Average daily cost | ~$6/developer/day |
| 90th percentile | <$12/day |
| Monthly average (Sonnet) | ~$100-200/developer/month |
| Agent teams overhead | ~7x standard session tokens |
| Background token usage | <$0.04/session |

**Track costs:** `/cost` (API users), `/stats` (subscribers).

#### Rate Limit Recommendations (TPM/RPM per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

TPM per user decreases as team size grows because fewer users tend to be concurrent. Limits apply at org level, not per individual.

#### Cost Reduction Strategies

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to drop stale context |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Use cheaper models | Sonnet for most tasks, Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | Prefer CLI tools (gh, aws); disable unused servers via `/mcp`; lower tool search threshold with `ENABLE_TOOL_SEARCH=auto:<N>` |
| Code intelligence plugins | Precise symbol navigation reduces file reads |
| Preprocess with hooks | Filter logs/test output before Claude sees them |
| Domain knowledge in skills | Move specialized instructions from CLAUDE.md to on-demand skills |
| Adjust thinking budget | `/effort` to lower effort level, `MAX_THINKING_TOKENS=8000`, or disable in `/config` |
| Delegate to subagents | Isolate verbose operations (tests, docs, logs) so only summaries return |
| Write specific prompts | "add validation to auth.ts" not "improve this codebase" |
| Use plan mode | `Shift+Tab` to research before coding; prevents expensive re-work |

### OpenTelemetry Monitoring

#### Quick Start

```
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp             # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc, http/json, http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Key Configuration Variables

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required, set to `1`) |
| `OTEL_METRICS_EXPORTER` | Metrics exporter: `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter: `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: disabled, set `1`) |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names in tool events (default: disabled, set `1`) |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attrs for multi-team orgs (comma-separated key=value, no spaces) |

Separate endpoints for metrics vs logs: use `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`, `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` and their protocol variants.

Dynamic headers: set `otelHeadersHelper` in settings.json to a script path; refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

Cardinality control: `OTEL_METRICS_INCLUDE_SESSION_ID` (default true), `OTEL_METRICS_INCLUDE_VERSION` (default false), `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (default true).

Administrator config: set telemetry env vars in managed settings JSON under `"env"` key; distributed via MDM.

#### Metrics

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

#### Events

| Event | Key attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (opt-in) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` (UUID v4) linking events to the triggering user prompt.

#### Standard Attributes (all metrics and events)

`session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

Service resource: `service.name=claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`.

### Troubleshooting Quick Reference

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; use `brew install --cask claude-code` or retry |
| `Killed` during install (Linux) | Add 2 GB swap; needs 4 GB RAM |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY` if behind proxy |
| `irm` not recognized (Windows) | Use PowerShell for `irm` command, or CMD installer for CMD |
| `requires git-bash` (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` if needed |
| `Error loading shared library` (Linux) | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try `brew install --cask claude-code` |
| OAuth error / invalid code | Retry quickly; press `c` to copy URL; check for SSH session |
| 403 Forbidden | Verify subscription; check Console role; check proxy config |
| "Organization disabled" with active sub | Unset `ANTHROPIC_API_KEY` env var overriding subscription |
| High CPU/memory | `/compact` regularly; restart between tasks; `.gitignore` build dirs |
| Search/discovery broken | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Move project to Linux filesystem (`/home/`); use specific searches |
| JetBrains not detected on WSL2 | Configure Windows Firewall or switch to mirrored networking |
| Esc not working in JetBrains | Settings > Tools > Terminal: uncheck "Move focus to editor with Escape" |

#### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (committed) |

#### Diagnostics

Run `/doctor` to check installation, auto-update, settings validity, MCP config, keybindings, context usage, and plugin/agent loading.

Use `/feedback` to report issues to Anthropic. Check github.com/anthropics/claude-code for known issues.

### Changelog

The changelog tracks release notes by version. Run `claude --version` to check your installed version. The full changelog is maintained at github.com/anthropics/claude-code/blob/main/CHANGELOG.md.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- Teams/Enterprise dashboard (usage metrics, contribution metrics, GitHub integration setup, leaderboard, CSV export, PR attribution process, tagging criteria, session window, excluded files), Console dashboard (lines accepted, accept rate, activity, spend, team insights)
- [Manage costs effectively](references/claude-code-costs.md) -- /cost command, managing costs for teams (workspace spend limits, rate limit recommendations by team size, agent team token costs), reducing token usage (context management, model selection, MCP overhead, code intelligence plugins, hooks and skills, extended thinking, subagent delegation, specific prompts, plan mode, background token usage)
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- quick start, administrator config via managed settings, all configuration variables, metrics cardinality control, dynamic headers, multi-team OTEL_RESOURCE_ATTRIBUTES, example configs (console/OTLP/Prometheus/multi-exporter/split endpoints), all metrics with attributes, all events with attributes, prompt.id correlation, metrics interpretation (usage/cost/alerting/segmentation), backend considerations, service info, ROI measurement guide, security and privacy, Bedrock monitoring
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, TLS, proxy, permissions, Docker, WSL, musl/glibc, architecture, macOS compatibility), authentication (OAuth, 403, disabled org, API key override, WSL2 login), performance (CPU/memory, hangs, search/discovery, WSL disk), IDE integration (JetBrains WSL2, Escape key), markdown formatting, /doctor, configuration reset
- [Changelog](references/claude-code-changelog.md) -- release notes by version with new features, improvements, and bug fixes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
