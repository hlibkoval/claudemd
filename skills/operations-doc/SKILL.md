---
name: operations-doc
description: Complete documentation for Claude Code operations — analytics dashboards (Teams/Enterprise and API Console), contribution metrics with GitHub integration, PR attribution, cost management (tracking, team spend limits, rate limit recommendations, token reduction strategies), OpenTelemetry monitoring (metrics, events, configuration, exporters, cardinality control, dynamic headers), troubleshooting (installation issues, PATH fixes, TLS/SSL errors, permission errors, authentication, IDE integration, performance, WSL), and the changelog. Load when discussing usage analytics, cost optimization, token usage, OpenTelemetry setup, monitoring, troubleshooting installation or runtime issues, or the /cost and /doctor commands.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Claude for Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Teams/Enterprise summary metrics:** PRs with CC, Lines of code with CC, PRs with Claude Code (%), Suggestion accept rate, Lines of code accepted

**Console metrics:** Lines of code accepted, Suggestion accept rate, Activity (DAU/sessions), Spend (daily API costs)

#### Contribution Metrics Setup (Teams/Enterprise)

Requires Owner role. Not available with Zero Data Retention enabled.

1. GitHub admin installs Claude GitHub app at github.com/apps/claude
2. Claude Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle
4. Complete GitHub authentication flow and select organizations

Data appears within 24 hours with daily updates. Supports GitHub Cloud and GitHub Enterprise Server.

#### PR Attribution

PRs tagged as "with Claude Code" if they contain at least one AI-assisted line. Sessions from 21 days before to 2 days after the PR merge date are considered. Code with >20% developer rewrite is not attributed. Merged PRs are labeled `claude-code-assisted` in GitHub.

**Excluded from analysis:** lock files, generated code, build directories, test fixtures, lines over 1,000 characters.

### Cost Management

Average cost: ~$6/developer/day (90th percentile under $12/day). API usage: ~$100-200/developer/month with Sonnet 4.6.

#### /cost Command

Shows API token usage for the current session (intended for API users; Claude Max/Pro subscribers use /stats instead).

#### Team Spend Limits

Set workspace spend limits at platform.claude.com. A "Claude Code" workspace is auto-created on first authentication. For Bedrock/Vertex/Foundry, consider LiteLLM for spend tracking.

#### Rate Limit Recommendations (TPM/RPM per user)

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 users | 200k-300k | 5-7 |
| 5-20 users | 100k-150k | 2.5-3.5 |
| 20-50 users | 50k-75k | 1.25-1.75 |
| 50-100 users | 25k-35k | 0.62-0.87 |
| 100-500 users | 15k-20k | 0.37-0.47 |
| 500+ users | 10k-15k | 0.25-0.35 |

Rate limits apply at the organization level. TPM per user decreases at scale because fewer users are concurrent.

#### Token Reduction Strategies

| Strategy | Details |
|:---------|:--------|
| Manage context | Use `/clear` between tasks, `/compact` with custom instructions, `/cost` to check usage |
| Choose the right model | Sonnet for most tasks, Opus for complex reasoning, `model: haiku` for simple subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`), disable unused servers, lower tool search threshold (`ENABLE_TOOL_SEARCH=auto:<N>`) |
| Code intelligence plugins | Install LSP plugins for precise symbol navigation instead of grep-based search |
| Hooks and skills | Preprocess data in hooks to reduce context; use skills for domain knowledge |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; move specialized instructions into on-demand skills |
| Adjust extended thinking | Lower effort level, disable thinking, or set `MAX_THINKING_TOKENS=8000` for simpler tasks |
| Delegate to subagents | Isolate verbose operations (tests, logs, docs) in subagents; only summary returns |
| Agent team costs | ~7x more tokens than standard sessions; keep teams small and tasks self-contained |
| Write specific prompts | Avoid vague requests; target specific files/functions |

**Background token usage:** ~$0.04/session for conversation summarization and command processing.

### OpenTelemetry Monitoring

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. Exports metrics via OTel metrics protocol and events via logs/events protocol.

#### Quick Start Environment Variables

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

#### Signal-Specific Endpoint Overrides

| Variable | Description |
|:---------|:------------|
| `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL` | Protocol for metrics only |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | Endpoint for metrics only |
| `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL` | Protocol for logs only |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` | Endpoint for logs only |

#### Metrics Cardinality Control

| Variable | Default | Description |
|:---------|:--------|:------------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include session.id |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include app.version |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include user.account_uuid |

#### Dynamic Headers

Set `otelHeadersHelper` in settings.json to a script that outputs JSON headers. Refreshes every 29 minutes by default (configure via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

#### Multi-Team Support

Use `OTEL_RESOURCE_ATTRIBUTES` for team identification: `department=engineering,team.id=platform,cost_center=eng-123`. No spaces allowed in values (use underscores or percent-encoding).

#### Exported Metrics

| Metric | Description | Extra Attributes |
|:-------|:------------|:-----------------|
| `claude_code.session.count` | Sessions started | -- |
| `claude_code.lines_of_code.count` | Lines modified | `type` (added/removed) |
| `claude_code.pull_request.count` | PRs created | -- |
| `claude_code.commit.count` | Commits created | -- |
| `claude_code.cost.usage` | Session cost (USD) | `model` |
| `claude_code.token.usage` | Tokens used | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | Edit tool decisions | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | Active time (seconds) | `type` (user/cli) |

#### Standard Attributes (all metrics/events)

| Attribute | Description |
|:----------|:------------|
| `session.id` | Unique session identifier |
| `app.version` | Claude Code version |
| `organization.id` | Organization UUID |
| `user.account_uuid` | Account UUID |
| `user.id` | Anonymous device/installation identifier |
| `user.email` | User email (OAuth only) |
| `terminal.type` | Terminal type (iTerm, vscode, cursor, tmux) |

#### Exported Events

| Event | Name | Key Attributes |
|:------|:-----|:---------------|
| User prompt | `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| Tool result | `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters` |
| API request | `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| API error | `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt`, `speed` |
| Tool decision | `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID v4) for correlating events from the same user prompt. Use `event.sequence` for ordering within a session.

#### Service Resource Attributes

`service.name`: `claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`, `wsl.version` (WSL only). Meter name: `com.anthropic.claude_code`.

### Troubleshooting

#### Installation Quick Reference

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; retry or use Homebrew/WinGet |
| `curl: (56) Failure writing output` | Network interruption; retry or use alternative install |
| `Killed` during install on Linux | Add swap space (min 4 GB RAM required) |
| TLS/SSL connection errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY` if behind proxy |
| `irm`/`&&` not recognized (Windows) | Use correct shell (PowerShell vs CMD) |
| `Claude Code on Windows requires git-bash` | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` if needed |
| `Error loading shared library` | musl/glibc mismatch; check with `ldd /bin/ls` |
| `Illegal instruction` on Linux | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; try Homebrew |

#### Install Methods

| Platform | Primary | Alternative |
|:---------|:--------|:-----------|
| macOS/Linux | `curl -fsSL https://claude.ai/install.sh \| bash` | `brew install --cask claude-code` |
| Windows (PowerShell) | `irm https://claude.ai/install.ps1 \| iex` | `winget install Anthropic.ClaudeCode` |
| Windows (CMD) | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd` | WinGet |

#### Authentication Issues

- Run `/logout`, close Claude Code, restart and re-authenticate
- Press `c` to copy OAuth URL if browser does not open
- 403 Forbidden: verify subscription at claude.ai/settings or confirm Console role
- WSL2: set `BROWSER` env var to Windows browser path

#### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

#### Performance Fixes

- Use `/compact` regularly to reduce context
- Restart between major tasks
- Add build directories to `.gitignore`
- Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` if search is broken
- WSL: keep projects on Linux filesystem (`/home/`) for better performance

#### /doctor Command

Checks installation type/version, search functionality, auto-update status, settings file validity, MCP server config, keybinding config, context usage warnings, and plugin/agent loading errors.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards for Teams/Enterprise and API Console, contribution metrics with GitHub integration, PR attribution, leaderboard, CSV export, summary metrics, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) -- cost tracking (/cost command), team spend limits, rate limit recommendations, token reduction strategies, context management, model selection, MCP overhead, extended thinking, subagents, agent team costs
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- telemetry configuration, environment variables, exporters (OTLP/Prometheus/console), metrics catalog, events catalog, standard attributes, cardinality control, dynamic headers, multi-team support, backend considerations, security/privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, TLS, permissions, Docker, WSL, Windows), authentication, IDE integration, performance, search issues, markdown formatting, /doctor command
- [Changelog](references/claude-code-changelog.md) -- release notes and version history

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
