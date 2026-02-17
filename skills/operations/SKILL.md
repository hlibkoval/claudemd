---
name: operations
description: Reference documentation for Claude Code operations — cost management, OpenTelemetry monitoring, analytics dashboards, and troubleshooting. Use when tracking costs, setting rate limits, configuring telemetry, viewing team analytics, diagnosing installation issues, or optimizing token usage.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code cost management, monitoring, analytics, and troubleshooting.

## Cost Management

Average cost: ~$6/developer/day (90th percentile <$12/day). Team average: ~$100-200/developer/month with Sonnet.

### Track Costs

| Command  | Purpose                                     |
|:---------|:--------------------------------------------|
| `/cost`  | Session token usage and cost (API users)    |
| `/stats` | Usage patterns (Max/Pro subscribers)        |

### Rate Limits by Team Size

| Team size     | TPM per user | RPM per user |
|:--------------|:-------------|:-------------|
| 1-5 users     | 200k-300k    | 5-7          |
| 5-20 users    | 100k-150k    | 2.5-3.5      |
| 20-50 users   | 50k-75k      | 1.25-1.75    |
| 50-100 users  | 25k-35k      | 0.62-0.87    |
| 100-500 users | 15k-20k      | 0.37-0.47    |
| 500+ users    | 10k-15k      | 0.25-0.35    |

### Reduce Token Usage

| Strategy                           | Detail                                                        |
|:-----------------------------------|:--------------------------------------------------------------|
| Clear between tasks                | `/clear` to drop stale context; `/rename` + `/resume` later   |
| Custom compaction                  | `/compact Focus on ...` or add compact instructions to CLAUDE.md |
| Choose right model                 | Sonnet for most tasks; Opus for complex reasoning; `/model`   |
| Reduce MCP overhead                | Prefer CLI tools (`gh`, `aws`); `/mcp` to disable unused servers |
| Code intelligence plugins          | Single "go to definition" replaces grep + multi-file reads    |
| Hooks for preprocessing            | Filter logs/test output before Claude sees it                 |
| Move instructions to skills        | Skills load on-demand; keep CLAUDE.md under ~500 lines        |
| Adjust extended thinking           | Lower budget (`MAX_THINKING_TOKENS=8000`) for simple tasks    |
| Delegate to subagents              | Verbose operations stay in subagent context                   |
| Write specific prompts             | Avoid "improve this codebase"; target specific files/functions |

### Agent Team Costs

Agent teams use ~7x more tokens than standard sessions. Mitigation: use Sonnet for teammates, keep teams small, keep spawn prompts focused, clean up when done.

## OpenTelemetry Monitoring

### Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp             # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc | http/json | http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key Environment Variables

| Variable                              | Description                                    |
|:--------------------------------------|:-----------------------------------------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY`        | Enable telemetry (required, set to `1`)        |
| `OTEL_METRICS_EXPORTER`               | Exporter: `otlp`, `prometheus`, `console`      |
| `OTEL_LOGS_EXPORTER`                  | Logs exporter: `otlp`, `console`               |
| `OTEL_EXPORTER_OTLP_ENDPOINT`         | Collector endpoint                             |
| `OTEL_EXPORTER_OTLP_HEADERS`          | Auth headers (`Authorization=Bearer token`)    |
| `OTEL_METRIC_EXPORT_INTERVAL`         | Export interval ms (default: 60000)            |
| `OTEL_LOG_USER_PROMPTS`               | Log prompt content (`1` to enable)             |
| `OTEL_LOG_TOOL_DETAILS`               | Log MCP/skill names (`1` to enable)            |
| `OTEL_RESOURCE_ATTRIBUTES`            | Custom attrs (`department=eng,team.id=platform`)|

### Available Metrics

| Metric                                | Unit   | Description                        |
|:--------------------------------------|:-------|:-----------------------------------|
| `claude_code.session.count`           | count  | CLI sessions started               |
| `claude_code.lines_of_code.count`     | count  | Lines modified (attr: added/removed)|
| `claude_code.pull_request.count`      | count  | PRs created                        |
| `claude_code.commit.count`            | count  | Commits created                    |
| `claude_code.cost.usage`             | USD    | Session cost                       |
| `claude_code.token.usage`            | tokens | Tokens used (attr: input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | count  | Edit tool accept/reject decisions  |
| `claude_code.active_time.total`       | s      | Active usage time                  |

### Events (via `OTEL_LOGS_EXPORTER`)

| Event Name                    | Key Attributes                                     |
|:------------------------------|:---------------------------------------------------|
| `claude_code.user_prompt`     | prompt_length, prompt (if enabled)                 |
| `claude_code.tool_result`     | tool_name, success, duration_ms, decision           |
| `claude_code.api_request`     | model, cost_usd, duration_ms, input/output_tokens  |
| `claude_code.api_error`       | model, error, status_code, attempt                 |
| `claude_code.tool_decision`   | tool_name, decision, source                        |

### Admin Configuration

Use managed settings for org-wide telemetry. Dynamic auth headers via `otelHeadersHelper` in settings.json (refreshes every 29 min by default).

## Analytics Dashboards

| Plan                | URL                                              | Features                                        |
|:--------------------|:-------------------------------------------------|:------------------------------------------------|
| Teams / Enterprise  | claude.ai/analytics/claude-code                  | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console)       | platform.claude.com/claude-code                  | Usage, spend, team insights                     |

### Contribution Metrics (Teams/Enterprise)

Requires GitHub app install at github.com/apps/claude + Owner role to enable. PRs tagged `claude-code-assisted` in GitHub. Attribution uses conservative matching within a 21-day window. Excludes lock files, generated code, build dirs, and lines >1000 chars.

### Console Metrics (API)

Per-user: lines accepted, suggestion accept rate, daily active users/sessions, spend. Requires UsageView permission.

## Troubleshooting

### Installation

| Issue                              | Fix                                                           |
|:-----------------------------------|:--------------------------------------------------------------|
| WSL OS/platform detection          | `npm config set os linux` or `--force --no-os-check`          |
| WSL node not found                 | Install Node via Linux package manager or nvm                 |
| Linux/Mac permission errors        | Use native installer: `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows git-bash not found         | Set `CLAUDE_CODE_GIT_BASH_PATH` env var                       |
| Windows PATH missing               | Add `%USERPROFILE%\.local\bin` to user PATH                   |

### Common Fixes

| Problem                    | Solution                                                       |
|:---------------------------|:---------------------------------------------------------------|
| Repeated permission prompts| `/permissions` to allow specific tools                         |
| Authentication issues      | `/logout`, restart, re-authenticate; or `rm -rf ~/.config/claude-code/auth.json` |
| High CPU/memory            | `/compact`, restart between tasks, `.gitignore` build dirs     |
| Command hangs              | Ctrl+C; close terminal if unresponsive                         |
| Search/discovery broken    | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0`          |
| Slow search on WSL         | Move project to Linux filesystem (`/home/`)                    |
| JetBrains Esc key conflict | Settings > Tools > Terminal > uncheck "Move focus to editor with Escape" |

### Configuration File Locations

| File                          | Purpose                              |
|:------------------------------|:-------------------------------------|
| `~/.claude/settings.json`     | User settings                        |
| `.claude/settings.json`       | Project settings (committed)         |
| `.claude/settings.local.json` | Local project settings (not committed)|
| `~/.claude.json`              | Global state (theme, OAuth, MCP)     |
| `.mcp.json`                   | Project MCP servers (committed)      |

### Diagnostics

Run `/doctor` to check installation, settings, MCP servers, keybindings, context usage, and plugin/agent loading errors. Use `/bug` to report issues to Anthropic.

## Full Documentation

For the complete official documentation, see the reference files:

- [Costs](references/claude-code-costs.md) -- cost tracking, rate limits, token reduction strategies
- [Monitoring](references/claude-code-monitoring-usage.md) -- OpenTelemetry setup, metrics, events, backend considerations
- [Analytics](references/claude-code-analytics.md) -- dashboards, contribution metrics, GitHub integration, ROI measurement
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation, permissions, performance, IDE integration

## Sources

- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Analytics: https://code.claude.com/docs/en/analytics.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
