---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics, cost management, monitoring, troubleshooting, and changelog. Covers analytics dashboards (claude.ai/analytics/claude-code for Teams/Enterprise with usage metrics, contribution metrics via GitHub integration, leaderboard, CSV export; platform.claude.com/claude-code for API customers with spend and usage), enabling contribution metrics (GitHub app install, enable analytics toggle, authenticate GitHub orgs, 24h data delay), PR attribution (conservative matching, 21-day session window, excluded auto-generated files, normalized line comparison, claude-code-assisted label), summary metrics (PRs with CC, lines of code with CC, suggestion accept rate, lines accepted), cost management (/cost command for API users showing session token cost, /stats for subscribers, workspace spend limits via Console, rate limit TPM/RPM recommendations by team size 1-5 through 500+ users, agent team token costs scaling with teammates), reducing token usage (manage context with /clear between tasks, custom compaction instructions, choose right model with /model, reduce MCP overhead with CLI tools and /mcp, code intelligence plugins, hooks for preprocessing, skills for domain knowledge, adjust extended thinking with /effort and MAX_THINKING_TOKENS, delegate verbose operations to subagents, write specific prompts, use plan mode), background token usage (~$0.04 per session for summarization), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY=1, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER otlp/console, OTEL_EXPORTER_OTLP_PROTOCOL grpc/http-json/http-protobuf, OTEL_EXPORTER_OTLP_ENDPOINT, signal-specific protocol/endpoint overrides, OTEL_EXPORTER_OTLP_HEADERS for auth, OTEL_METRIC_EXPORT_INTERVAL default 60000ms, OTEL_LOGS_EXPORT_INTERVAL default 5000ms, OTEL_LOG_USER_PROMPTS=1 to include prompt content, OTEL_LOG_TOOL_DETAILS=1 for tool inputs/MCP/skill names), metrics cardinality control (OTEL_METRICS_INCLUDE_SESSION_ID/VERSION/ACCOUNT_UUID), dynamic headers (otelHeadersHelper setting, 29-min refresh default, CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS), multi-team OTEL_RESOURCE_ATTRIBUTES, managed settings for centralized telemetry config, available metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage in USD, token.usage with type input/output/cacheRead/cacheCreation, code_edit_tool.decision with tool_name/decision/source/language, active_time.total with type user/cli), OTel events (user_prompt with prompt.id correlation, tool_result with tool_name/success/duration_ms/decision_type/tool_parameters, api_request with model/cost_usd/tokens/speed, api_error with error/status_code/attempt, tool_decision with decision/source), standard attributes (session.id, app.version, organization.id, user.account_uuid, user.account_id, user.id, user.email, terminal.type), Prometheus exporter, ROI measurement guide, troubleshooting (installation issues table, PATH fixes for macOS/Linux/Windows, conflicting installations, permission errors, binary verification, common issues like HTML instead of script, command not found, curl 56, TLS/SSL errors, low-memory Linux killed, Docker hangs, Windows irm/git-bash/Claude Desktop override, musl/glibc mismatch, illegal instruction, dyld cannot load, WSL issues including nvm conflicts and sandbox setup, authentication issues including OAuth errors and 403 forbidden and disabled org and WSL2 login, config file locations, resetting config, performance issues, search and discovery with ripgrep, IDE integration JetBrains WSL2 and Escape key, markdown formatting, /doctor diagnostics), changelog (release notes by version). Load when discussing analytics, cost management, costs, spending, token usage, monitoring, OpenTelemetry, OTel, telemetry, metrics, troubleshooting, installation issues, debugging Claude Code, /cost, /stats, changelog, release notes, what's new, rate limits, TPM, RPM, contribution metrics, PR attribution, ROI, spend limits, CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, workspace spend, or any operations-related topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

**Teams/Enterprise metrics**: PRs with CC, lines of code with CC, suggestion accept rate, lines accepted, adoption chart, PRs per user, leaderboard (top 10, export all as CSV).

**Contribution metrics setup** (Teams/Enterprise only, requires Owner role):
1. GitHub admin installs the Claude GitHub app at [github.com/apps/claude](https://github.com/apps/claude)
2. Owner enables Claude Code analytics at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code)
3. Enable "GitHub analytics" toggle
4. Complete GitHub authentication and select orgs

Data appears within 24 hours. Not available with Zero Data Retention enabled.

**PR attribution**: PRs are tagged `claude-code-assisted` in GitHub. Sessions from 21 days before to 2 days after merge are considered. Code with >20% developer rewrite is not attributed. Lock files, generated code, build dirs, test fixtures, and lines >1000 chars are excluded.

**API Console metrics**: lines of code accepted, suggestion accept rate, daily active users/sessions, daily spend, per-user spend and lines this month.

### Cost Management

| Topic | Details |
|:------|:--------|
| Average cost | ~$6/dev/day (90th percentile <$12/day); ~$100-200/dev/month with Sonnet |
| Check session cost | `/cost` (API users) or `/stats` (subscribers) |
| Team spend limits | Set via [Console workspace limits](https://platform.claude.com) |
| Background usage | ~$0.04/session for conversation summarization |

**Rate limit recommendations (TPM / RPM per user)**:

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Reduce token usage**:
- `/clear` between tasks; custom compaction instructions via `/compact <focus>`
- Use Sonnet for most tasks, Opus for complex reasoning (`/model` to switch)
- Reduce MCP overhead: prefer CLI tools (`gh`, `aws`), disable unused servers, lower tool search threshold (`ENABLE_TOOL_SEARCH=auto:<N>`)
- Install code intelligence plugins for typed languages
- Use hooks to preprocess data; use skills for domain knowledge
- Lower extended thinking: `/effort`, `MAX_THINKING_TOKENS=8000`, or disable in `/config`
- Delegate verbose operations to subagents
- Write specific prompts; use plan mode (Shift+Tab) for complex tasks

**Agent team costs**: ~7x standard sessions. Use Sonnet for teammates, keep teams small, keep spawn prompts focused, clean up when done.

### OpenTelemetry Monitoring

**Quick start**:
```
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp             # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc | http/json | http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables**:

| Variable | Description | Default |
|:---------|:-----------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | - |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s), comma-separated | - |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s), comma-separated | - |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol for all signals | - |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint for all signals | - |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | - |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log tool inputs, MCP/skill names | disabled |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Temporality preference | delta |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom key=value attrs (no spaces) | - |

Signal-specific overrides: `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL`, `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`, `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL`, `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`.

**Cardinality control**: `OTEL_METRICS_INCLUDE_SESSION_ID` (default true), `OTEL_METRICS_INCLUDE_VERSION` (default false), `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (default true).

**Dynamic headers**: set `otelHeadersHelper` in settings.json to a script that outputs JSON headers. Refreshes every 29 min (customize with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Available metrics**:

| Metric | Unit | Extra attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | - |
| `claude_code.lines_of_code.count` | count | `type`: added/removed |
| `claude_code.pull_request.count` | count | - |
| `claude_code.commit.count` | count | - |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type`: input/output/cacheRead/cacheCreation, `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type`: user/cli |

**Standard attributes** (on all metrics/events): `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

**Events** (via `OTEL_LOGS_EXPORTER`):

| Event | Key attributes |
|:------|:--------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID correlating events to a single user prompt) and `event.sequence` (monotonic counter).

### Troubleshooting Quick Reference

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; use `brew install --cask claude-code` |
| `Killed` during install on Linux | Add swap space (min 4 GB RAM needed) |
| TLS/SSL errors | Update CA certificates; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check proxy/firewall; set `HTTPS_PROXY` |
| `irm is not recognized` (Windows) | Use PowerShell, not CMD |
| `requires git-bash` (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |
| OAuth / 403 errors | Run `/logout` then restart; check subscription; unset stale `ANTHROPIC_API_KEY` |
| High CPU/memory | Use `/compact`; restart between tasks |
| Search not working | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Run diagnostics | `/doctor` checks install, settings, MCP, keybindings, context usage |

**Config file locations**: `~/.claude/settings.json` (user), `.claude/settings.json` (project), `.claude/settings.local.json` (local project), `~/.claude.json` (global state), `.mcp.json` (project MCP).

### Changelog

The changelog contains release notes for every Claude Code version. Run `claude --version` to check your installed version. The full changelog is available in the reference file linked below.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- Analytics dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard
- [Manage costs effectively](references/claude-code-costs.md) -- Token cost tracking, team spend limits, rate limit recommendations, strategies to reduce usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel setup, environment variables, metrics, events, backend considerations, security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation issues, authentication problems, performance, IDE integration, diagnostics
- [Changelog](references/claude-code-changelog.md) -- Release notes by version with new features, improvements, and bug fixes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
