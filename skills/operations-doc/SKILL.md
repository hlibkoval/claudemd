---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise usage metrics, contribution metrics with GitHub integration, PR attribution, leaderboard, CSV export; API Console dashboard with spend tracking and team insights), cost management (/cost command, /stats for subscribers, workspace spend limits, rate limit TPM/RPM recommendations by team size, agent team token costs, reducing token usage with context management /clear /compact, model selection /model, MCP overhead reduction, code intelligence plugins, hooks and skills for preprocessing, extended thinking budgets, subagent delegation, background token usage), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER, metrics -- session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events -- user_prompt/tool_result/api_request/api_error/tool_decision, prompt.id correlation, cardinality control, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs, Prometheus/OTLP/gRPC/HTTP configurations, backend considerations, ROI measurement guide), troubleshooting (installation issues -- PATH fixes, curl failures, TLS/SSL errors, low-memory Linux, Docker hangs, WSL setup, musl/glibc mismatch, Windows Git Bash; authentication -- OAuth errors, 403 forbidden, token expiry; configuration file locations; performance -- high CPU/memory, command hangs, search/ripgrep issues; IDE integration -- JetBrains WSL2, Escape key conflicts; markdown formatting issues; /doctor diagnostics; /bug reporting), and changelog (release notes by version). Load when discussing Claude Code analytics, usage dashboards, contribution metrics, PR attribution, cost tracking, /cost, /stats, token usage optimization, rate limits, TPM/RPM, spend limits, OpenTelemetry, OTEL, telemetry, monitoring, metrics export, Prometheus, Datadog, Honeycomb, observability, troubleshooting Claude Code, installation problems, PATH issues, authentication errors, /doctor, /bug, changelog, release notes, what's new in Claude Code, version history, or ROI measurement.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key Features |
|:-----|:-------------|:-------------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

#### Contribution Metrics Setup (Teams/Enterprise)

Requires Owner role + GitHub admin. Not available with Zero Data Retention.

1. GitHub admin installs Claude GitHub app at `github.com/apps/claude`
2. Owner enables Claude Code analytics at `claude.ai/admin-settings/claude-code`
3. Enable "GitHub analytics" toggle
4. Complete GitHub authentication and select organizations

Data appears within 24 hours. Supports GitHub Cloud and GitHub Enterprise Server.

#### PR Attribution

PRs tagged as "with Claude Code" when they contain at least one line written during a Claude Code session. Conservative matching with high-confidence threshold. Sessions from 21 days before to 2 days after merge date are considered. Code with >20% rewrite is not attributed. Merged PRs labeled `claude-code-assisted` in GitHub.

#### Summary Metrics

| Metric | Description |
|:-------|:------------|
| PRs with CC | Merged PRs containing Claude Code-assisted lines |
| Lines of code with CC | Effective lines (>3 chars after normalization) across merged PRs |
| PRs with Claude Code (%) | Percentage of merged PRs with CC-assisted code |
| Suggestion accept rate | Percentage of accepted Edit/Write/NotebookEdit tool usage |
| Lines of code accepted | Total accepted lines in sessions (excludes rejections) |

#### Console Dashboard Metrics (API)

| Metric | Description |
|:-------|:------------|
| Lines of code accepted | Accepted lines in sessions |
| Suggestion accept rate | Accept rate for code editing tools |
| Activity chart | Daily active users and sessions |
| Spend chart | Daily API costs alongside user count |
| Team insights table | Per-user spend and lines this month |

Console requires UsageView permission (Developer, Billing, Admin, Owner, Primary Owner roles).

### Cost Management

Average cost: ~$6/developer/day (90th percentile under $12/day). Team API usage: ~$100-200/developer/month with Sonnet 4.6.

#### Key Commands

| Command | Purpose |
|:--------|:--------|
| `/cost` | Session token usage and cost (API users) |
| `/stats` | Usage patterns (Pro/Max subscribers) |
| `/clear` | Reset context between tasks |
| `/compact [focus]` | Summarize context, optionally preserving specific topics |
| `/model` | Switch models mid-session |
| `/context` | See what consumes context space |
| `/mcp` | View/disable MCP servers |

#### Workspace Spend Limits

API users: set workspace spend limits at `platform.claude.com`. A "Claude Code" workspace is auto-created on first auth.

Bedrock/Vertex/Foundry: use LiteLLM or provider-native tools for cost tracking (no built-in metrics from Claude Code).

#### Rate Limit Recommendations (TPM/RPM per user)

| Team Size | TPM per User | RPM per User |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

Limits apply at org level (not per user), so individual users can temporarily burst higher.

#### Token Reduction Strategies

| Strategy | Impact |
|:---------|:-------|
| `/clear` between tasks | Eliminates stale context |
| Use Sonnet over Opus | Lower cost for most coding tasks |
| Reduce MCP server overhead | Disable unused servers, prefer CLI tools (`gh`, `aws`) |
| Install code intelligence plugins | Precise symbol nav reduces file reads |
| Use hooks to preprocess data | Filter logs/output before Claude sees them |
| Move detailed CLAUDE.md content to skills | Skills load on-demand, CLAUDE.md is always in context |
| Lower extended thinking budget | `MAX_THINKING_TOKENS=8000` or `/effort` for simple tasks |
| Delegate verbose ops to subagents | Test output stays in subagent context |
| Use plan mode for complex tasks | Shift+Tab prevents expensive wrong-direction work |
| Write specific prompts | Avoid broad scanning from vague requests |

#### Agent Team Costs

Agent teams use ~7x more tokens than standard sessions. Keep teams small, use Sonnet for teammates, keep spawn prompts focused, clean up when done. Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

### OpenTelemetry Monitoring

#### Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp             # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc | http/json | http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Key Configuration Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | -- |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s), comma-separated | -- |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s), comma-separated | -- |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for OTLP | -- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint (all signals) | -- |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | -- |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (disabled by default) | -- |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP server/tool/skill names | -- |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Temporality preference | delta |

Signal-specific endpoint/protocol overrides: `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`, `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL`, `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`, `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL`.

#### Cardinality Control

| Variable | Description | Default |
|:---------|:------------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version | false |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid | true |

#### Dynamic Headers

Set `otelHeadersHelper` in `.claude/settings.json` to a script that outputs JSON headers. Refreshes every 29 minutes by default (configure with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

#### Multi-Team Support

```bash
export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"
```

Values cannot contain spaces -- use underscores, camelCase, or percent-encoding.

#### Metrics

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

#### Events (via OTEL_LOGS_EXPORTER)

| Event | Key Attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if OTEL_LOG_USER_PROMPTS=1) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` (UUID v4) for correlating events within a single user prompt. All events include `event.sequence` for ordering within a session.

#### Admin Configuration

Centralize telemetry via managed settings (MDM or file-based):

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector.example.com:4317"
  }
}
```

### Troubleshooting

#### Installation Quick Diagnosis

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML -- use `brew install --cask claude-code` or check region |
| `curl: (56) Failure writing output` | Download script first, then run; or use Homebrew/WinGet |
| `Killed` during install (Linux) | Add 2GB swap space (`fallocate -l 2G /swapfile`) -- needs 4GB RAM minimum |
| TLS/SSL errors | Update CA certificates; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check network/proxy; set `HTTPS_PROXY` |
| `irm is not recognized` (Windows) | Wrong shell -- use PowerShell for `irm`, CMD for `curl` installer |
| `requires git-bash` (Windows) | Install Git for Windows; or set `CLAUDE_CODE_GIT_BASH_PATH` |
| `Error loading shared library` (Linux) | musl/glibc binary mismatch -- check `ldd /bin/ls` |
| `Illegal instruction` (Linux) | Architecture mismatch -- check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try Homebrew install |
| Docker install hangs | Set `WORKDIR /tmp` before install; increase Docker memory to 4GB |

#### Authentication Issues

| Issue | Fix |
|:------|:----|
| OAuth invalid code | Retry quickly; press `c` to copy URL for remote/SSH sessions |
| 403 Forbidden | Check subscription at `claude.ai/settings`; verify Console role; check proxy |
| WSL2 OAuth failure | Set `BROWSER` env var to Windows browser path; or copy URL manually |
| Token expired | Run `/login`; check system clock accuracy |

#### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

#### Performance

- Use `/compact` to reduce context; `/clear` between tasks
- Add large build directories to `.gitignore`
- Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` for search issues
- WSL: keep projects on Linux filesystem (`/home/`) for better search performance

#### IDE Integration

- JetBrains on WSL2: configure Windows Firewall for WSL2 subnet, or switch to `networkingMode=mirrored` in `.wslconfig`
- JetBrains Escape key conflict: Settings > Tools > Terminal > uncheck "Move focus to the editor with Escape"

#### Diagnostics

- `/doctor` -- checks installation, settings, MCP, keybindings, context usage, plugin/agent errors
- `/bug` -- reports problems directly to Anthropic

### Changelog

The changelog tracks release notes by version. Check installed version with `claude --version`. Full changelog mirrors [CHANGELOG.md on GitHub](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- Teams/Enterprise usage and contribution metrics with GitHub integration, PR attribution algorithm, leaderboard, CSV export; API Console dashboard with spend tracking and team insights; programmatic access via `claude-code-assisted` label
- [Costs](references/claude-code-costs.md) -- /cost and /stats commands, workspace spend limits, rate limit TPM/RPM recommendations by team size, agent team token costs, token reduction strategies (context management, model selection, MCP overhead, hooks, skills, extended thinking, subagents, plan mode), background token usage
- [Monitoring (OpenTelemetry)](references/claude-code-monitoring-usage.md) -- CLAUDE_CODE_ENABLE_TELEMETRY quick start, exporter configuration (otlp/prometheus/console), all environment variables, cardinality control, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs, complete metrics and events reference, prompt.id correlation, admin managed settings, backend considerations, ROI measurement guide, security and privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, curl, TLS, low memory, Docker, WSL, musl/glibc, architecture, macOS dyld), authentication (OAuth, 403, token expiry), configuration file locations, performance (CPU/memory, hangs, search/ripgrep), IDE integration (JetBrains WSL2, Escape key), markdown formatting, /doctor diagnostics, /bug reporting
- [Changelog](references/claude-code-changelog.md) -- release notes by version with new features, improvements, and bug fixes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring (OpenTelemetry): https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
