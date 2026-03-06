---
name: operations-doc
description: Complete documentation for Claude Code operations — analytics dashboards (Teams/Enterprise and API Console), contribution metrics with GitHub integration, PR attribution, cost management (tracking costs with /cost, team spend limits, rate limit recommendations, agent team token costs, reducing token usage), OpenTelemetry monitoring (metrics, events, configuration variables, exporters, dynamic headers, cardinality control, multi-team attributes), and troubleshooting (installation issues, PATH, permissions, authentication, IDE integration, performance, WSL, Docker, Windows). Load when discussing usage analytics, cost optimization, token usage, spend limits, rate limits, OpenTelemetry setup, telemetry configuration, monitoring dashboards, ROI measurement, or debugging installation and runtime problems.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring with OpenTelemetry, and troubleshooting.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Teams/Enterprise summary metrics:** PRs with CC, Lines of code with CC, PRs with CC (%), Suggestion accept rate, Lines of code accepted

**Teams/Enterprise charts:** Adoption (daily users/sessions), PRs per user, Pull requests breakdown, Leaderboard (top 10 + CSV export)

**Console metrics:** Lines of code accepted, Suggestion accept rate, Activity (daily users/sessions), Spend (daily costs + user count), Team insights table (per-user spend and lines)

### Contribution Metrics Setup (Teams/Enterprise)

Requires GitHub integration. Owner role needed for configuration. Not available with Zero Data Retention.

1. GitHub admin installs Claude GitHub app at github.com/apps/claude
2. Claude Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle on the same page
4. Complete GitHub authentication and select GitHub organizations

Data appears within 24 hours. Supports GitHub Cloud and GitHub Enterprise Server.

### PR Attribution

- PRs tagged as "with Claude Code" if they contain at least one line written during a Claude Code session
- Sessions from 21 days before to 2 days after PR merge date are considered
- Lines normalized before comparison (whitespace trimmed, quotes standardized, lowercase)
- Code rewritten >20% by developers is not attributed to Claude Code
- Excluded files: lock files, generated code, build directories, test fixtures, lines over 1,000 characters
- Merged PRs labeled `claude-code-assisted` in GitHub

### Cost Management

**Average costs:** ~$6/developer/day (90th percentile <$12/day); ~$100-200/developer/month with Sonnet

| Command | Purpose |
|:--------|:--------|
| `/cost` | View current session token usage and cost (API users) |
| `/stats` | View usage patterns (Max/Pro subscribers) |

**Workspace spend limits:** Set via Console at platform.claude.com. A "Claude Code" workspace is auto-created on first authentication.

### Rate Limit Recommendations (TPM/RPM per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

TPM per user decreases with team size because fewer users are concurrent in larger organizations. Rate limits apply at the organization level, not per individual user.

### Token Usage Reduction Strategies

| Strategy | How |
|:---------|:----|
| Manage context | `/clear` between tasks, `/compact` with custom instructions |
| Choose right model | Sonnet for most tasks, Opus for complex reasoning, Haiku for simple subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`), disable unused servers, lower tool search threshold |
| Code intelligence plugins | Precise symbol navigation reduces file reads |
| Hooks and skills | Preprocess data in hooks, provide domain knowledge via skills |
| Move CLAUDE.md to skills | Keep CLAUDE.md <500 lines; use on-demand skills for specialized instructions |
| Adjust extended thinking | Lower effort level, disable thinking, or reduce `MAX_THINKING_TOKENS` |
| Delegate to subagents | Isolate verbose operations (tests, docs, logs) in subagents |
| Write specific prompts | Avoid vague requests; target specific files and functions |
| Plan mode | Shift+Tab before implementation to prevent expensive re-work |

**Agent teams:** ~7x more tokens than standard sessions. Use Sonnet for teammates, keep teams small, clean up when done.

**Background token usage:** Conversation summarization and command processing consume ~$0.04 per session even when idle.

### OpenTelemetry Monitoring

**Quick start:**

```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console
OTEL_LOGS_EXPORTER=otlp             # otlp, console
OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc, http/json, http/protobuf
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Configuration Variables

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required. Set to `1` to enable |
| `OTEL_METRICS_EXPORTER` | `console`, `otlp`, `prometheus` (comma-separated) |
| `OTEL_LOGS_EXPORTER` | `console`, `otlp` (comma-separated) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint for all signals |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers (e.g., `Authorization=Bearer token`) |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval in ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval in ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | `1` to include prompt content (disabled by default) |
| `OTEL_LOG_TOOL_DETAILS` | `1` to log MCP server/tool names and skill names (disabled by default) |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes for multi-team filtering (e.g., `department=engineering,team.id=platform`) |

**Cardinality control:** `OTEL_METRICS_INCLUDE_SESSION_ID` (default: true), `OTEL_METRICS_INCLUDE_VERSION` (default: false), `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (default: true)

**Dynamic headers:** Set `otelHeadersHelper` in settings.json to a script that outputs JSON headers. Refreshes every 29 minutes by default (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Admin configuration:** Use managed settings file to centrally configure OTel for all users via MDM.

### OTel Metrics

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

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`

### OTel Events

| Event | Key attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID v4) for correlating events within a single user prompt.

### Troubleshooting Quick Lookup

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; use `brew install --cask claude-code` |
| `curl: (56) Failure writing output` | Network issue; download script first, then run it |
| `Killed` during install (Linux) | Add swap space (need 4 GB RAM) |
| TLS/SSL connection errors | Update CA certificates; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `irm is not recognized` | Use PowerShell, not CMD |
| `Claude Code on Windows requires git-bash` | Install Git for Windows; optionally set `CLAUDE_CODE_GIT_BASH_PATH` |
| `Error loading shared library` | Wrong binary variant (musl/glibc mismatch) |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try Homebrew install |
| OAuth error / 403 Forbidden | Run `/logout`, restart, re-authenticate; check subscription/role |
| JetBrains IDE not detected (WSL2) | Configure Windows Firewall or switch to mirrored networking |
| Escape key not working (JetBrains) | Uncheck "Move focus to the editor with Escape" in Settings > Tools > Terminal |
| High CPU/memory | Use `/compact`, restart between tasks, gitignore build dirs |
| Search/discovery not working | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0` |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

### Diagnostic Commands

| Command | Purpose |
|:--------|:--------|
| `/doctor` | Check installation, settings, MCP, keybindings, context usage |
| `/bug` | Report problems directly to Anthropic |
| `claude --version` | Check current version |
| `claude --debug` | Verbose plugin/loading details |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards for Teams/Enterprise and API Console, contribution metrics setup, GitHub integration, PR attribution, summary metrics, charts, leaderboard, CSV export, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) -- tracking costs with /cost, team spend limits, rate limit recommendations by team size, agent team token costs, reducing token usage (context management, model selection, MCP overhead, hooks, skills, extended thinking, subagents), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- enabling telemetry, configuration variables, OTLP/Prometheus/console exporters, metrics (session, lines of code, cost, tokens, active time), events (user prompt, tool result, API request, API error, tool decision), dynamic headers, multi-team attributes, cardinality control, admin configuration, backend recommendations, security and privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, permissions, TLS, network, Docker, WSL, Windows), authentication (OAuth, 403, token expiry), IDE integration (JetBrains, VSCode, WSL2), performance, search issues, markdown formatting, configuration reset, diagnostic commands
- [Changelog](references/claude-code-changelog.md) -- release notes and version history

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
