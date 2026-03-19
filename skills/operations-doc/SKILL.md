---
name: operations-doc
description: Complete documentation for Claude Code operations -- Analytics (Teams/Enterprise dashboard at claude.ai/analytics/claude-code, API Console dashboard at platform.claude.com/claude-code, usage metrics, contribution metrics with GitHub integration, PR attribution criteria, leaderboard, CSV export, adoption tracking, ROI measurement), Costs (average $6/dev/day, /cost command, workspace spend limits, rate limit TPM/RPM recommendations by team size, agent team token costs, context management /clear /compact, model selection Sonnet vs Opus, MCP server overhead, hooks for preprocessing, skills for on-demand context, extended thinking budget MAX_THINKING_TOKENS, subagent delegation, background token usage), Monitoring (OpenTelemetry CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER otlp/console, metrics claude_code.session.count/lines_of_code.count/token.usage/cost.usage/pull_request.count/commit.count/code_edit_tool.decision/active_time.total, events user_prompt/tool_result/api_request/api_error/tool_decision, prompt.id correlation, cardinality control, dynamic headers otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team, Prometheus/OTLP/console exporters, mTLS, Bedrock monitoring guide), Troubleshooting (installation issues PATH/TLS/curl/Docker/WSL/musl-glibc/macOS dyld, authentication OAuth/403/ANTHROPIC_API_KEY override, config file locations, performance /compact/ripgrep, IDE integration JetBrains WSL2/Escape key, /doctor diagnostics, markdown formatting), Changelog (release notes by version, new features, improvements, bug fixes). Load when discussing Claude Code analytics dashboard, usage metrics, contribution metrics, PR attribution, cost tracking, /cost command, spend limits, rate limits TPM RPM, token optimization, reducing costs, prompt caching, auto-compaction, OpenTelemetry, OTEL, telemetry, monitoring Claude Code, metrics export, Prometheus, OTLP, events logging, troubleshooting Claude Code, installation issues, authentication problems, /doctor, changelog, release notes, what's new in Claude Code, or any operations/observability topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code analytics, cost management, monitoring with OpenTelemetry, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

**Contribution metrics** (Teams/Enterprise only, requires GitHub App at `github.com/apps/claude`): PRs with CC, lines of code with CC, suggestion accept rate, lines accepted. Not available with Zero Data Retention.

**PR attribution:** Merged PRs are matched against Claude Code sessions within a 21-day window. Lines with >20% developer rewrite are not attributed. Lock files, generated code, build directories, and lines over 1,000 chars are excluded. Attributed PRs receive the `claude-code-assisted` GitHub label.

### Cost Management

**Typical costs:**

| Metric | Value |
|:-------|:------|
| Average per developer per day | ~$6 |
| 90th percentile daily | <$12 |
| Monthly with Sonnet 4.6 | ~$100-200/dev |
| Background token usage | <$0.04/session |

**Commands:** `/cost` shows session token usage (API users only; subscribers use `/stats`).

**Team spend limits:** Set workspace limits in the Claude Console. A "Claude Code" workspace is auto-created on first authentication.

**Rate limit recommendations (TPM per user):**

| Team Size | TPM/user | RPM/user |
|:----------|:---------|:---------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Token reduction strategies:**

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` (use `/rename` first to save session) |
| Custom compaction | `/compact Focus on ...` or CLAUDE.md compact instructions |
| Choose cheaper model | Sonnet for most tasks, Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools (gh, aws, gcloud) |
| Install code intelligence | Language server plugins for precise navigation instead of grep+read |
| Preprocess with hooks | Filter logs/output before Claude sees them (PreToolUse hooks) |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; use skills for specialized knowledge |
| Lower extended thinking | `/effort`, `MAX_THINKING_TOKENS=8000`, or disable in `/config` |
| Delegate to subagents | Isolate verbose operations (tests, docs, logs) in subagent context |
| Agent teams | Use Sonnet for teammates, keep teams small, clean up when done |

### OpenTelemetry Monitoring

**Quick start env vars:**

| Variable | Purpose | Values |
|:---------|:--------|:-------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | Default: `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | Default: `5000` |

**Metrics:**

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

**Standard attributes** (on all metrics/events): `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`.

**Cardinality control:**

| Variable | Default | Controls |
|:---------|:--------|:---------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | `app.version` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | `user.account_uuid` in metrics |

**Events** (via `OTEL_LOGS_EXPORTER`):

| Event Name | Key Attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (opt-in via `OTEL_LOG_USER_PROMPTS=1`) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` (UUID v4) for correlating events within a single user prompt. Do not use `prompt.id` in metrics (unbounded cardinality).

**Privacy controls:** `OTEL_LOG_USER_PROMPTS=1` to include prompt content. `OTEL_LOG_TOOL_DETAILS=1` to include MCP server/tool names and skill names.

**Dynamic headers:** Set `otelHeadersHelper` in settings to a script that outputs JSON headers. Refreshes every 29 minutes by default (customize with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team:** Use `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` for team-level filtering. Values must not contain spaces; use percent-encoding for special characters.

**Separate endpoints for metrics and logs:**

| Variable | Purpose |
|:---------|:--------|
| `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL` | Override protocol for metrics |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | Override endpoint for metrics |
| `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL` | Override protocol for logs |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` | Override endpoint for logs |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |

**Admin configuration:** Set telemetry env vars in the managed settings file (distributed via MDM) for centralized control that users cannot override.

### Troubleshooting

**Installation quick-fix table:**

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; try `brew install --cask claude-code` |
| `curl: (56) Failure writing output` | Download script first, then run; or use Homebrew/WinGet |
| `Killed` during install (Linux) | Add swap space (min 4 GB RAM) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY` if behind proxy |
| `irm is not recognized` (Windows) | Use PowerShell for `irm`, or use CMD installer |
| `requires git-bash` (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try Homebrew |

**Authentication issues:** Run `/logout` then restart. Press `c` to copy OAuth URL if browser does not open. For 403 errors, verify subscription or Console role. If "organization disabled" with active subscription, unset stale `ANTHROPIC_API_KEY` from shell profile.

**Config file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (committed) |

**Performance:** Use `/compact` regularly, close and restart between major tasks, add build dirs to `.gitignore`. Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` if search is broken. Use `/doctor` to diagnose issues (checks installation, settings, MCP, keybindings, context usage, plugins).

**JetBrains on WSL2:** Configure Windows Firewall for WSL2 subnet or switch to mirrored networking (`networkingMode=mirrored` in `.wslconfig`). For Escape key conflicts, uncheck "Move focus to the editor with Escape" in Settings > Tools > Terminal.

### Changelog

The changelog tracks all Claude Code releases with new features, improvements, and bug fixes. Check your version with `claude --version`. Full release history is published from [CHANGELOG.md on GitHub](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- Teams/Enterprise dashboard (usage metrics, contribution metrics with GitHub integration, PR attribution process and criteria, leaderboard, CSV export, adoption tracking, ROI measurement), API Console dashboard (lines accepted, suggestion accept rate, activity, spend, team insights), GitHub App setup for contribution metrics, summary metrics (PRs with CC, lines with CC, accept rate), charts (adoption, PRs per user, pull requests breakdown), attribution time window (21 days), excluded files (lock files, generated code, build dirs), programmatic access via claude-code-assisted label
- [Costs](references/claude-code-costs.md) -- average costs ($6/dev/day, <$12 for 90th percentile, ~$100-200/dev/month with Sonnet 4.6), /cost command, workspace spend limits, Claude Code workspace auto-creation, rate limit TPM/RPM recommendations by team size (1-5 through 500+), agent team token costs (Sonnet for teammates, small teams, focused spawn prompts), token reduction (context management /clear /compact, model selection Sonnet vs Opus, MCP server overhead /mcp /context ENABLE_TOOL_SEARCH, code intelligence plugins, hooks for preprocessing, skills for on-demand context, CLAUDE.md to skills migration, extended thinking /effort MAX_THINKING_TOKENS, subagent delegation, plan mode, write specific prompts, incremental testing), background token usage (<$0.04/session), LiteLLM for Bedrock/Vertex/Foundry cost tracking
- [Monitoring](references/claude-code-monitoring-usage.md) -- OpenTelemetry setup (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, OTEL_EXPORTER_OTLP_PROTOCOL/ENDPOINT/HEADERS), admin configuration via managed settings, common configuration variables table, cardinality control (OTEL_METRICS_INCLUDE_SESSION_ID/VERSION/ACCOUNT_UUID), dynamic headers (otelHeadersHelper, refresh interval CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS), multi-team OTEL_RESOURCE_ATTRIBUTES, example configurations (console/OTLP/Prometheus/multiple exporters/separate endpoints), metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total), events (user_prompt, tool_result, api_request, api_error, tool_decision), prompt.id correlation, standard attributes, metric details with per-metric attributes, usage/cost/alerting analysis, backend considerations (Prometheus, ClickHouse, Honeycomb, Datadog, Elasticsearch, Loki), service resource attributes, ROI measurement guide, security and privacy, Bedrock monitoring guide
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, HTML install script, curl failures, TLS/SSL, low-memory Linux, Docker hangs, WSL npm/nvm, Windows Git Bash, musl/glibc mismatch, Illegal instruction, dyld macOS, conflicting installations, directory permissions, binary verification), authentication (OAuth errors, 403 Forbidden, disabled organization with ANTHROPIC_API_KEY override, WSL2 OAuth, token expiration), config file locations, resetting configuration, performance (CPU/memory, command hangs, ripgrep for search, WSL slow search), IDE integration (JetBrains WSL2 networking/firewall, Escape key keybinding), markdown formatting (missing language tags, inconsistent spacing), /doctor diagnostics
- [Changelog](references/claude-code-changelog.md) -- release notes by version with dates, new features, improvements, bug fixes, security fixes, VSCode extension changes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
