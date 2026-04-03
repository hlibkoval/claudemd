---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and changelog. Covers analytics for Teams/Enterprise and API customers (contribution metrics, PR attribution, GitHub integration, leaderboard, CSV export), cost tracking (/cost command, /stats, workspace spend limits, rate limit recommendations by team size, agent team token costs), reducing token usage (context management, /clear, /compact, model selection, MCP overhead, code intelligence plugins, hooks and skills offloading, extended thinking budgets, subagent delegation, plan mode), OpenTelemetry configuration (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, OTEL_TRACES_EXPORTER, OTLP endpoints, Prometheus, console exporters, metrics cardinality control, distributed tracing beta, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs, mTLS authentication), available metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total), events (user_prompt, tool_result, api_request, api_error, tool_decision, prompt.id correlation), troubleshooting installation (PATH issues, TLS errors, low-memory Linux, Docker hangs, musl/glibc mismatch, WSL issues, Windows Git Bash, conflicting installations), authentication problems (OAuth errors, 403 Forbidden, disabled organization, token expiry), IDE integration (JetBrains WSL2, Escape key conflicts), configuration file locations, performance and stability, markdown formatting issues, and the full release changelog. Load when discussing Claude Code analytics, cost management, spend limits, rate limits, token usage optimization, OpenTelemetry, monitoring, telemetry, OTEL metrics, OTEL events, OTEL traces, troubleshooting Claude Code, installation issues, authentication issues, /cost command, /doctor command, PR attribution, contribution metrics, changelog, release notes, or any operations-related topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- analytics, cost management, OpenTelemetry monitoring, troubleshooting, and release changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

**Contribution metrics** (Teams/Enterprise only, public beta) require GitHub app installation at [github.com/apps/claude](https://github.com/apps/claude) plus admin enablement at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code). Not available with Zero Data Retention enabled.

### Key Analytics Metrics

| Metric | Description |
|:-------|:-----------|
| PRs with CC | Merged PRs containing Claude Code-assisted lines |
| Lines of code with CC | Effective lines (>3 chars after normalization) in merged PRs |
| PRs with CC (%) | Percentage of merged PRs with Claude Code assistance |
| Suggestion accept rate | Accept rate for Edit, Write, NotebookEdit tools |
| Lines of code accepted | Total accepted lines (excludes rejections, doesn't track deletions) |

**PR attribution**: merged PRs matched against sessions from 21 days before to 2 days after merge. Code with >20% developer rewrite is not attributed. PRs labeled `claude-code-assisted` in GitHub.

### Cost Overview

| Metric | Value |
|:-------|:------|
| Average daily cost | ~$6/developer/day (90th percentile: $12) |
| Average monthly cost (API) | ~$100-200/developer with Sonnet |
| Background token usage | ~$0.04/session |
| Agent teams multiplier | ~7x standard sessions (plan mode) |

**Commands**: `/cost` shows API token usage (API users); `/stats` shows usage patterns (subscribers).

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
| Clear between tasks | `/clear` (use `/rename` first, `/resume` to return) |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Choose cheaper models | Use Sonnet for most tasks, Opus for complex reasoning, `model: haiku` for subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`), disable unused servers via `/mcp` |
| Code intelligence plugins | Precise symbol navigation instead of grep + file reads |
| Offload to hooks/skills | Preprocess data before Claude sees it; move specialized CLAUDE.md content to skills |
| Adjust extended thinking | Lower `/effort`, disable in `/config`, or set `MAX_THINKING_TOKENS=8000` |
| Delegate to subagents | Isolate verbose operations (tests, logs) in subagent context |
| Write specific prompts | Targeted requests reduce file scanning |
| Use plan mode | Shift+Tab before complex tasks; course-correct early with Escape or `/rewind` |

### OpenTelemetry Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp             # otlp, console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

### Key OTel Environment Variables

| Variable | Description |
|:---------|:-----------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry (`1`) |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` |
| `OTEL_TRACES_EXPORTER` | `otlp`, `console`, `none` (requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint URL |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content (`1`) |
| `OTEL_LOG_TOOL_DETAILS` | Include tool parameters/input (`1`) |
| `OTEL_LOG_TOOL_CONTENT` | Include tool I/O in trace spans (`1`, truncated at 60 KB) |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes (`department=eng,team.id=platform`) |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |

### Metrics Cardinality Control

| Variable | Default | Controls |
|:---------|:--------|:---------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | `session.id` attribute |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | `app.version` attribute |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | `user.account_uuid` and `user.account_id` |

### Exported Metrics

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

### Exported Events

| Event Name | Key Attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters` (if enabled) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID) for correlating events to a single user prompt.

### Standard Telemetry Attributes

| Attribute | Description |
|:----------|:-----------|
| `session.id` | Unique session identifier |
| `app.version` | Claude Code version (opt-in) |
| `organization.id` | Organization UUID |
| `user.account_uuid` | Account UUID |
| `user.account_id` | Account ID in tagged format |
| `user.id` | Anonymous device/installation ID |
| `user.email` | User email (OAuth only) |
| `terminal.type` | Terminal type (iTerm.app, vscode, cursor, tmux) |

### Troubleshooting Quick Reference

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; try `brew install --cask claude-code` |
| `Killed` during install on Linux | Add 2 GB swap; requires 4 GB RAM minimum |
| Install hangs in Docker | Set `WORKDIR /tmp` before install |
| TLS/SSL connection errors | Update CA certificates; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| OAuth error / Invalid code | Retry quickly; press `c` to copy URL for remote sessions |
| 403 Forbidden | Check subscription; check for stale `ANTHROPIC_API_KEY` in shell profile |
| "Organization disabled" with active sub | Unset `ANTHROPIC_API_KEY`; remove from `~/.zshrc`/`~/.bashrc` |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| High CPU/memory | Use `/compact`, restart between tasks, `.gitignore` build dirs |
| Search/discovery issues | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0` |
| JetBrains not detected on WSL2 | Configure Windows Firewall for WSL2 subnet or use mirrored networking |
| Escape key not working in JetBrains | Settings > Tools > Terminal: uncheck "Move focus to editor with Escape" |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

### Diagnostic Commands

| Command | Purpose |
|:--------|:--------|
| `/cost` | Show API token usage for current session |
| `/stats` | Show usage patterns (subscribers) |
| `/doctor` | Check installation, settings, MCP, plugins, context usage |
| `/feedback` | Report problems directly to Anthropic |
| `claude --version` | Check installed version |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track Team Usage with Analytics](references/claude-code-analytics.md) -- Analytics dashboards for Teams/Enterprise and API customers, contribution metrics, PR attribution, GitHub integration, leaderboard, data export
- [Manage Costs Effectively](references/claude-code-costs.md) -- Cost tracking, workspace spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel configuration, metrics, events, traces (beta), dynamic headers, cardinality control, backend considerations, security/privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation issues, authentication problems, IDE integration, configuration, performance, search, markdown formatting
- [Changelog](references/claude-code-changelog.md) -- Release notes by version with new features, improvements, and bug fixes

## Sources

- Track Team Usage with Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs Effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
