---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise and API Console), contribution metrics with GitHub integration, PR attribution, cost management (/cost command, workspace spend limits, rate limit recommendations per team size, agent team token costs), token reduction strategies (context management, model selection, MCP overhead, hooks/skills offloading, extended thinking, subagent delegation), OpenTelemetry monitoring (metrics and events export, OTLP/gRPC/Prometheus/console exporters, metrics cardinality control, dynamic headers, multi-team resource attributes), OTel metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total), OTel events (user_prompt, tool_result, api_request, api_error, tool_decision with prompt.id correlation), troubleshooting (installation issues, PATH fixes, TLS/SSL errors, WSL setup, IDE integration, authentication, performance, /doctor diagnostics), and the changelog. Load when discussing Claude Code analytics, usage tracking, cost optimization, token usage, spend limits, rate limits, OpenTelemetry, OTel, telemetry, monitoring, metrics export, Prometheus, OTLP, contribution metrics, PR attribution, troubleshooting installation, PATH issues, TLS errors, WSL problems, IDE detection issues, JetBrains terminal, /cost, /doctor, /bug, background token usage, or Claude Code operational concerns.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring/telemetry, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics** (Teams/Enterprise only, public beta) require GitHub app install + Claude Owner enabling the feature. Not available with Zero Data Retention. Data appears within 24 hours.

#### Summary Metrics

| Metric | Description |
|:-------|:------------|
| PRs with CC | Merged PRs containing Claude Code-assisted lines |
| Lines of code with CC | Effective lines (>3 chars after normalization) in merged PRs |
| PRs with Claude Code (%) | Percentage of merged PRs with CC-assisted code |
| Suggestion accept rate | Accept rate for Edit/Write/NotebookEdit tools |
| Lines of code accepted | Total accepted lines (excludes rejections, ignores later deletions) |

#### PR Attribution

- PRs tagged when they contain at least one CC-assisted line (conservative matching)
- Time window: 21 days before to 2 days after merge
- Lines normalized (whitespace, quotes, case) before matching
- Code rewritten >20% by developers is not attributed
- Excluded: lock files, generated code, build dirs, test fixtures, lines >1000 chars
- Merged PRs labeled `claude-code-assisted` in GitHub

#### Console Dashboard (API)

| Metric | Description |
|:-------|:------------|
| Lines of code accepted | Accepted lines in sessions |
| Suggestion accept rate | Edit/Write/NotebookEdit accept percentage |
| Activity | Daily active users and sessions chart |
| Spend | Daily API costs alongside user count |
| Team insights | Per-user spend and lines this month |

### Cost Management

**Average costs:** ~$6/developer/day (90th percentile <$12/day). API teams: ~$100-200/developer/month with Sonnet.

#### Commands

| Command | Purpose |
|:--------|:--------|
| `/cost` | Show session token usage and cost (API users; subscribers use `/stats`) |
| `/clear` | Reset context between tasks |
| `/compact [instructions]` | Summarize context with optional focus |
| `/model` | Switch models mid-session |
| `/config` | Set default model |
| `/context` | See what consumes context space |
| `/mcp` | View/disable MCP servers |

#### Rate Limit Recommendations (per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

Rate limits apply at the organization level. Individual users can temporarily exceed their share when others are inactive.

#### Token Reduction Strategies

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to drop stale context |
| Custom compaction | `/compact Focus on X` or CLAUDE.md compact instructions |
| Use Sonnet by default | Reserve Opus for complex architectural/reasoning tasks |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`); disable unused servers; lower tool search threshold (`ENABLE_TOOL_SEARCH=auto:<N>`) |
| Code intelligence plugins | LSP gives precise navigation, reduces file reads |
| Offload to hooks/skills | Preprocess data in hooks; domain knowledge in skills |
| Adjust extended thinking | Lower effort level, disable thinking, or reduce budget (`MAX_THINKING_TOKENS=8000`) |
| Delegate to subagents | Verbose operations (tests, logs) in subagent context |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; specialized workflows in skills |
| Specific prompts | Avoid "improve this codebase"; target specific files/functions |
| Plan mode | Shift+Tab before implementation to prevent expensive re-work |

#### Agent Team Costs

Agent teams use ~7x more tokens than standard sessions. Each teammate has its own context window. Use Sonnet for teammates, keep teams small, keep spawn prompts focused, clean up when done.

#### Background Token Usage

Summarization and command processing use small amounts (~$0.04/session) even without active interaction.

### OpenTelemetry Monitoring

#### Quick Start

```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console
OTEL_LOGS_EXPORTER=otlp             # otlp | console
OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc | http/json | http/protobuf
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Key Environment Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s), comma-separated | none |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s) | none |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for all signals | -- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | -- |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | -- |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names in tool events | disabled |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Metrics temporality | delta |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes (comma-separated key=value, no spaces in values) | -- |

Signal-specific endpoint/protocol overrides: `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL`, `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`, `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL`, `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`.

#### Cardinality Control

| Variable | Default | Description |
|:---------|:--------|:------------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include session.id |
| `OTEL_METRICS_INCLUDE_VERSION` | false | Include app.version |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include user.account_uuid |

#### Dynamic Headers

Set `otelHeadersHelper` in settings.json to a script path. Script outputs JSON headers. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

#### Admin Configuration

Set OTel env vars in managed settings file under `"env"` key for org-wide deployment via MDM.

#### Standard Attributes (all metrics/events)

| Attribute | Description |
|:----------|:------------|
| `session.id` | Unique session ID |
| `app.version` | Claude Code version |
| `organization.id` | Organization UUID |
| `user.account_uuid` | Account UUID |
| `user.id` | Anonymous device/installation ID |
| `user.email` | Email (OAuth only) |
| `terminal.type` | Terminal type (iTerm, vscode, cursor, tmux) |

#### Metrics

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

#### Events (via OTEL_LOGS_EXPORTER)

All events include `prompt.id` (UUID v4) for correlating events from a single user prompt. Do not use `prompt.id` in metrics (unbounded cardinality).

| Event | Key Attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `error`, `decision_type`, `decision_source`, `tool_result_size_bytes`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `cache_creation_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events carry `event.timestamp` (ISO 8601) and `event.sequence` (monotonic counter).

#### Service Resource Attributes

`service.name`: `claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`, `wsl.version` (WSL only). Meter name: `com.anthropic.claude_code`.

#### Backend Recommendations

- **Time series (Prometheus):** rate calculations, aggregated metrics
- **Columnar (ClickHouse):** complex queries, unique user analysis
- **Observability platforms (Honeycomb, Datadog):** advanced querying, visualization, alerting
- **Log aggregation (Elasticsearch, Loki):** full-text search, event analysis

ROI measurement guide: github.com/anthropics/claude-code-monitoring-guide

### Troubleshooting

#### Installation Quick Diagnosis

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script got HTML; retry or use `brew install --cask claude-code` |
| `curl: (56) Failure writing` | Network interruption; download script first or use brew/winget |
| `Killed` on Linux | Add swap (4 GB RAM required) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check connectivity to storage.googleapis.com; set `HTTPS_PROXY` |
| `irm not recognized` | Wrong shell; use PowerShell for `irm` or CMD for `curl` installer |
| `requires git-bash` | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` in settings |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; try brew install |
| `App unavailable in region` | Not available in your country |
| OAuth/403 errors | `/logout`, restart, re-auth; check subscription/role |

#### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

#### Key Diagnostic Commands

| Command | Purpose |
|:--------|:--------|
| `/doctor` | Check installation, settings, MCP, keybindings, context |
| `/bug` | Report problems to Anthropic |
| `claude --version` | Check current version |
| `/debug` or `claude --debug` | Detailed debug output |

#### WSL-Specific Issues

- Set `BROWSER` env var if OAuth browser won't open
- Install `bubblewrap socat` for WSL2 sandboxing
- WSL1 does not support sandboxing
- Keep projects on Linux filesystem (`/home/`) for performance
- Ensure nvm is loaded in shell config to avoid Windows node conflicts

#### JetBrains IDE Issues

- WSL2: configure Windows Firewall for WSL2 subnet or switch to mirrored networking (`networkingMode=mirrored` in `.wslconfig`)
- Escape key conflict: Settings > Tools > Terminal > uncheck "Move focus to the editor with Escape"

#### Performance Tips

- Use `/compact` regularly to reduce context size
- Close and restart between major tasks
- Add large build directories to `.gitignore`
- Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` if search is broken

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards for Teams/Enterprise and API Console, contribution metrics with GitHub integration, PR attribution criteria and process, summary metrics, adoption charts, leaderboard, CSV export
- [Manage costs effectively](references/claude-code-costs.md) -- /cost command, workspace spend limits, rate limit recommendations by team size, agent team token costs, token reduction strategies (context management, model selection, MCP overhead, hooks/skills, extended thinking, subagents), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- enabling OTel, exporter configuration (OTLP, Prometheus, console), all environment variables, admin configuration via managed settings, dynamic headers, multi-team resource attributes, cardinality control, complete metrics and events reference, backend considerations, ROI measurement, security and privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, TLS, network, permissions, WSL, Docker, Windows), authentication (OAuth, 403, token expiry), configuration file locations, IDE integration (JetBrains, WSL2), performance, search issues, markdown formatting, /doctor diagnostics
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
