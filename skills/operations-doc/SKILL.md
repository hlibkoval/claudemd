---
name: operations-doc
description: Complete documentation for Claude Code operations -- covering analytics (Teams/Enterprise dashboard with usage metrics, contribution metrics via GitHub integration, PR attribution, leaderboard, CSV export; API Console dashboard with spend tracking, team insights, per-user metrics), cost management (token tracking with /cost, team spend limits, rate limit TPM/RPM recommendations by team size, agent team token costs, context management with /clear and /compact, model selection Sonnet vs Opus, MCP overhead reduction, code intelligence plugins, hooks and skills for preprocessing, extended thinking budgets, subagent delegation, specific prompts, plan mode), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER, OTLP endpoint/protocol/headers configuration, managed settings for admin rollout, metrics cardinality control, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs, metrics: session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events: user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation, standard attributes session.id/user.account_uuid/organization.id, backend considerations Prometheus/ClickHouse/Honeycomb/Datadog, ROI measurement guide, security and privacy opt-in controls, Bedrock monitoring guide), troubleshooting (installation issues PATH/TLS/network/permissions/low-memory/Docker/WSL/Windows, authentication OAuth/403/token-expired/ANTHROPIC_API_KEY override, configuration file locations and reset, performance CPU/memory/search, IDE integration JetBrains WSL2 firewall/Escape key, markdown formatting, /doctor diagnostics), and changelog (release notes by version). Load when discussing Claude Code analytics, usage dashboards, contribution metrics, PR attribution, cost management, token usage, spend limits, rate limits, /cost command, OpenTelemetry, OTEL, telemetry monitoring, metrics export, Prometheus, troubleshooting, installation issues, authentication problems, /doctor, changelog, release notes, ROI measurement, or any operations-related topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- covering analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key features |
|:-----|:-------------|:-------------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

**Contribution metrics setup** (Teams/Enterprise only, requires Owner role):

1. GitHub admin installs the Claude GitHub app at `github.com/apps/claude`
2. Claude Owner enables Claude Code analytics at `claude.ai/admin-settings/claude-code`
3. Enable the "GitHub analytics" toggle
4. Complete GitHub authentication and select organizations

Data appears within 24 hours. Not available with Zero Data Retention enabled.

**Summary metrics:** PRs with CC, Lines of code with CC, PRs with CC (%), Suggestion accept rate, Lines of code accepted

**PR attribution:** Merged PRs are matched against Claude Code session activity. Sessions from 21 days before to 2 days after merge date are considered. Code with >20% developer rewrite is not attributed. Matched PRs receive the `claude-code-assisted` label in GitHub.

### Cost Management

**Average costs:**

| Plan type | Average cost |
|:----------|:-------------|
| Pro/Max subscription | ~$6/developer/day (90th percentile < $12/day) |
| API (Console) | ~$100-200/developer/month with Sonnet |

**Rate limit recommendations (TPM per user):**

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 users | 200k-300k | 5-7 |
| 5-20 users | 100k-150k | 2.5-3.5 |
| 20-50 users | 50k-75k | 1.25-1.75 |
| 50-100 users | 25k-35k | 0.62-0.87 |
| 100-500 users | 15k-20k | 0.37-0.47 |
| 500+ users | 10k-15k | 0.25-0.35 |

**Cost reduction strategies:**

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to drop stale context; `/compact` with custom instructions |
| Choose the right model | Sonnet for most tasks; Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`); disable unused servers via `/mcp` |
| Use code intelligence plugins | LSP gives precise navigation, reducing file reads |
| Offload to hooks/skills | Preprocess data in hooks; put domain knowledge in skills |
| Move instructions to skills | Keep CLAUDE.md under ~500 lines; use skills for specialized workflows |
| Adjust extended thinking | `/effort` to lower effort; `MAX_THINKING_TOKENS=8000` to cap budget |
| Delegate to subagents | Isolate verbose operations (tests, logs) in subagents |
| Write specific prompts | Avoid broad requests like "improve this codebase" |

**Agent teams:** ~7x more tokens than standard sessions. Keep teams small, prompts focused, and clean up when done.

### OpenTelemetry Monitoring

**Quick start environment variables:**

| Variable | Purpose | Values |
|:---------|:--------|:-------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | Events/logs exporter | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | e.g., `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | Default: `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | Default: `5000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | `1` to enable |
| `OTEL_LOG_TOOL_DETAILS` | Log tool parameters/input | `1` to enable |

**Cardinality control:**

| Variable | Default | Description |
|:---------|:--------|:------------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include session.id |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include app.version |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include user.account_uuid |

**Exported metrics:**

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

**Exported events** (via logs exporter):

| Event name | Key attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` (if enabled) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, token counts, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` for correlation within a single user prompt.

**Standard resource attributes:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

**Dynamic headers:** Configure `otelHeadersHelper` in settings.json pointing to a script that outputs JSON headers. Refreshes every 29 minutes by default (`CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team support:** Use `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"`. No spaces in values; use percent-encoding for special characters.

### Troubleshooting Quick Reference

**Installation issues:**

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `curl: (56) Failure writing` | Download script first, then run; or use Homebrew/WinGet |
| `Killed` during install | Add swap space (need 4 GB RAM minimum) |
| TLS/SSL errors | Update CA certificates; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY`; try alternative install |
| `irm not recognized` | Wrong shell; use PowerShell for `irm`, CMD for `curl` |
| `requires git-bash` | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` if needed |
| `Error loading shared library` | musl/glibc mismatch; check with `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |

**Authentication issues:**

| Symptom | Fix |
|:--------|:----|
| OAuth error: Invalid code | Retry quickly; press `c` to copy URL |
| 403 Forbidden | Check subscription at `claude.ai/settings`; verify Console role; check proxy |
| "Organization disabled" with active sub | Unset `ANTHROPIC_API_KEY` env var overriding subscription |
| OAuth fails in WSL2 | Set `BROWSER` env var to Windows browser path |

**Configuration file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

**Diagnostics:** Run `/doctor` to check installation, settings, MCP, keybindings, context usage, and plugin errors.

### Changelog

The changelog contains release notes for every Claude Code version. Run `claude --version` to check your installed version. The full changelog is maintained at `github.com/anthropics/claude-code/blob/main/CHANGELOG.md`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track Team Usage with Analytics](references/claude-code-analytics.md) -- Teams/Enterprise dashboard (usage metrics, contribution metrics via GitHub integration, PR attribution with tagging criteria and attribution process, leaderboard, CSV export), API Console dashboard (spend tracking, team insights, per-user metrics), enabling contribution metrics setup steps, summary metrics definitions, adoption and PRs-per-user charts, pull requests breakdown, attribution time window and excluded files, accessing data programmatically via claude-code-assisted label, ROI measurement and power user identification
- [Manage Costs Effectively](references/claude-code-costs.md) -- Token usage tracking with /cost command, /stats for subscribers, team spend limits via Console workspace, rate limit TPM/RPM recommendations by team size (1-5 through 500+), agent team token costs (~7x multiplier), context management strategies (/clear, /compact, custom compaction instructions), model selection (Sonnet vs Opus, /model), MCP server overhead reduction (prefer CLI tools, disable unused servers), code intelligence plugins for typed languages, hooks and skills for preprocessing, moving CLAUDE.md instructions to skills, extended thinking budget adjustment (/effort, MAX_THINKING_TOKENS), subagent delegation for verbose operations, specific prompts, plan mode for complex tasks, background token usage (~$0.04/session), Bedrock/Vertex cost tracking via LiteLLM
- [OpenTelemetry Monitoring](references/claude-code-monitoring-usage.md) -- Quick start configuration, administrator managed settings, all environment variables (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, OTLP protocol/endpoint/headers, per-signal endpoint overrides, mTLS client key/certificate, export intervals, OTEL_LOG_USER_PROMPTS, OTEL_LOG_TOOL_DETAILS, temporality preference, dynamic headers helper debounce), cardinality control variables, dynamic headers via otelHeadersHelper script with refresh behavior, OTEL_RESOURCE_ATTRIBUTES for multi-team orgs (formatting requirements), example configurations (console/OTLP-gRPC/Prometheus/multiple exporters/split backends/metrics-only/events-only), complete metrics reference (session/lines_of_code/pull_request/commit/cost/token/code_edit_tool/active_time with all attributes), events reference (user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation), usage/cost/alerting analysis patterns, backend considerations (Prometheus/ClickHouse/Honeycomb/Datadog), service resource attributes, ROI measurement guide link, security and privacy controls, Bedrock monitoring guide link
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation diagnostics (network connectivity, PATH verification, conflicting installations, directory permissions, binary verification), common installation issues (HTML instead of script, command not found, curl failures, TLS/SSL errors, failed to fetch version, Windows irm/shell issues, low-memory Linux killed, Docker hangs, Claude Desktop CLI override, git-bash requirement, musl/glibc mismatch, illegal instruction, dyld cannot load, WSL errors and nvm conflicts, WSL2 sandbox setup, permission errors), authentication issues (repeated permission prompts, OAuth errors, 403 forbidden, disabled organization with active subscription, WSL2 OAuth, token expired), configuration file locations and reset, performance issues (CPU/memory, hangs/freezes, search/ripgrep, slow WSL search), IDE integration (JetBrains WSL2 firewall and networking, Escape key conflicts, Windows IDE issue reporting), markdown formatting (missing language tags, inconsistent spacing), /doctor diagnostics
- [Changelog](references/claude-code-changelog.md) -- Release notes for every Claude Code version with new features, improvements, and bug fixes

## Sources

- Track Team Usage with Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs Effectively: https://code.claude.com/docs/en/costs.md
- OpenTelemetry Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
