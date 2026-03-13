---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export; Console usage/spend metrics, team insights), cost management (token usage tracking with /cost and /stats, team spend limits, rate limit recommendations by team size, agent team token costs, context reduction strategies including /clear, /compact, model selection, MCP server overhead, code intelligence plugins, hooks/skills offloading, extended thinking budget, subagent delegation, CLAUDE.md optimization), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER, OTLP endpoint/protocol/headers configuration, mTLS, dynamic headers via otelHeadersHelper, metrics cardinality control, multi-team OTEL_RESOURCE_ATTRIBUTES, metrics: session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events: user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation, standard attributes session.id/app.version/organization.id/user.account_uuid/user.id/user.email/terminal.type, Prometheus/OTLP/console exporters, ROI measurement guide), troubleshooting (installation diagnostics, PATH issues, conflicting installations, permission errors, TLS/SSL errors, low-memory Linux, Docker hangs, Windows WSL issues, musl/glibc mismatch, authentication OAuth/403, IDE integration JetBrains WSL2, search/ripgrep issues, /doctor diagnostics, config file locations, performance tips), and changelog (release notes by version). Load when discussing Claude Code analytics, usage metrics, contribution metrics, PR attribution, cost management, token costs, rate limits, spend limits, /cost command, OpenTelemetry, OTel, telemetry, monitoring, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, metrics export, Prometheus, observability, ROI measurement, troubleshooting Claude Code, installation issues, PATH problems, authentication errors, OAuth errors, /doctor, /bug, configuration files, performance issues, changelog, release notes, or what's new in Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code analytics, cost management, OpenTelemetry monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboard Access

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

Contribution metrics require Owner role + GitHub app install at github.com/apps/claude. Not available with Zero Data Retention.

### Analytics Summary Metrics

| Metric | Description |
|:-------|:------------|
| PRs with CC | Merged PRs containing Claude Code-assisted lines |
| Lines of code with CC | Effective lines (>3 chars after normalization) in merged PRs |
| PRs with Claude Code (%) | Percentage of merged PRs with CC-assisted code |
| Suggestion accept rate | Accept rate for Edit, Write, NotebookEdit tools |
| Lines of code accepted | Total accepted lines (excludes rejections, ignores later deletions) |

PR attribution: conservative matching, sessions within 21 days before to 2 days after merge. Code rewritten >20% by developers is not attributed. PRs labeled `claude-code-assisted` in GitHub.

### Cost Overview

| Metric | Value |
|:-------|:------|
| Average daily cost | ~$6/developer/day |
| 90th percentile | <$12/day |
| Monthly estimate (Sonnet) | ~$100-200/developer |
| Background token usage | <$0.04/session |

### Rate Limit Recommendations (per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 users | 200k-300k | 5-7 |
| 5-20 users | 100k-150k | 2.5-3.5 |
| 20-50 users | 50k-75k | 1.25-1.75 |
| 50-100 users | 25k-35k | 0.62-0.87 |
| 100-500 users | 15k-20k | 0.37-0.47 |
| 500+ users | 10k-15k | 0.25-0.35 |

Rate limits apply at the organization level. TPM per user decreases with team size due to lower concurrent usage.

### Cost Reduction Strategies

| Strategy | Approach |
|:---------|:---------|
| Clear between tasks | `/clear` to drop stale context; `/rename` first to preserve |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Choose right model | Sonnet for most tasks; reserve Opus for complex reasoning; `model: haiku` for subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`, `gcloud`); disable unused servers via `/mcp`; lower tool search threshold with `ENABLE_TOOL_SEARCH=auto:<N>` |
| Code intelligence plugins | Single "go to definition" replaces grep + file reads |
| Hooks preprocessing | Filter large outputs before Claude sees them (e.g., grep for ERROR in logs) |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; specialized instructions in on-demand skills |
| Adjust extended thinking | Lower effort in `/model`; disable in `/config`; or `MAX_THINKING_TOKENS=8000` |
| Delegate to subagents | Verbose ops (tests, docs, logs) stay in subagent context; summary returns to main |
| Agent teams | ~7x tokens vs standard sessions; keep teams small, use Sonnet for teammates |
| Specific prompts | "Add validation to login in auth.ts" vs "improve this codebase" |
| Plan mode | Shift+Tab before implementation; prevents expensive re-work |

### OpenTelemetry Quick Start

```
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp           # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc  # grpc, http/json, http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Environment Variables

| Variable | Description | Default/Example |
|:---------|:------------|:----------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter types | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter types | `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | `5000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | `1` to enable |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names in events | `1` to enable |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom team/dept attributes | `department=eng,team.id=platform` |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Metrics temporality | `delta` (default), `cumulative` |

### Cardinality Control

| Variable | Description | Default |
|:---------|:------------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id | `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version | `false` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid | `true` |

### Dynamic Headers

Set `otelHeadersHelper` in settings to a script that outputs JSON headers. Refreshes every 29 minutes by default; customize with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`.

### OTel Metrics

| Metric | Unit | Extra Attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type`: added/removed |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type`: input/output/cacheRead/cacheCreation; `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type`: user/cli |

Standard attributes on all metrics/events: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`.

### OTel Events

| Event Name | Key Attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_result_size_bytes`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID v4) to correlate events within a single user prompt. Also include `event.timestamp` and `event.sequence`.

### Troubleshooting Quick Lookup

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; retry or use `brew install --cask claude-code` |
| `curl: (56) Failure writing` | Network interruption; download script first or use brew/winget |
| `Killed` during install | Low memory; add swap (`fallocate -l 2G /swapfile`) or use 4GB+ RAM |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check `storage.googleapis.com` access; set `HTTPS_PROXY` if behind proxy |
| `irm` or `&&` not recognized | Wrong shell on Windows; use PowerShell for `irm`, CMD for `curl` installer |
| `requires git-bash` | Install Git for Windows; optionally set `CLAUDE_CODE_GIT_BASH_PATH` in settings |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` and reinstall correct variant |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` | macOS <13.0; update macOS or use brew |
| OAuth / 403 errors | Run `/logout` then restart; verify subscription or Console role |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| Search/skills not working | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| JetBrains Esc key conflict | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |
| JetBrains not detected on WSL2 | Configure Windows Firewall or switch to mirrored networking |
| High CPU/memory | `/compact` regularly; restart between tasks; `.gitignore` build dirs |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings (permissions, hooks, model) |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (committed) |

### Diagnostic Commands

| Command | Purpose |
|:--------|:--------|
| `/cost` | Token usage and cost for current session (API users) |
| `/stats` | Usage patterns (subscription users) |
| `/doctor` | Check installation, settings, MCP, keybindings, context issues |
| `/bug` | Report issues to Anthropic |
| `/context` | See what consumes context space |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- Teams/Enterprise dashboard (usage metrics, contribution metrics with GitHub integration, PR attribution, leaderboard, CSV export), Console dashboard (usage metrics, spend tracking, team insights), enabling contribution metrics, PR tagging criteria, attribution process and time window, excluded files, interpreting metrics
- [Manage costs effectively](references/claude-code-costs.md) -- /cost command, team spend limits, rate limit recommendations by team size, agent team token costs, context reduction strategies (clear/compact, model selection, MCP overhead, code intelligence plugins, hooks preprocessing, skills offloading, extended thinking, subagent delegation, specific prompts, plan mode), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel configuration (env vars, managed settings, mTLS, dynamic headers, multi-team attributes, cardinality control), all metrics (session/LOC/PR/commit/cost/token/edit decision/active time), all events (user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation), backend considerations, service info, ROI measurement resources, security and privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation diagnostics (network, PATH, conflicting installs, permissions, binary verification), common issues (HTML install script, command not found, curl failures, TLS/SSL, low memory, Docker, Windows shells, WSL, musl/glibc, architecture mismatch, macOS dyld), authentication (OAuth, 403, WSL2 browser), config file locations, performance, IDE integration (JetBrains WSL2, Esc key), search issues, markdown formatting, /doctor
- [Changelog](references/claude-code-changelog.md) -- release notes by version with new features, improvements, and bug fixes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
