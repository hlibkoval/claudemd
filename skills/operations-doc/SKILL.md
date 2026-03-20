---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics (Teams/Enterprise dashboard with usage metrics/contribution metrics/leaderboard/CSV export, API Console dashboard with spend tracking/team insights, GitHub integration for PR attribution, contribution metrics setup, PR tagging criteria and attribution process, excluded files, ROI measurement), cost management (/cost command, workspace spend limits, rate limit TPM/RPM recommendations by team size, agent team token costs, reduce token usage strategies including context management /clear /compact, model selection Sonnet vs Opus, MCP server overhead /context, code intelligence plugins, hooks and skills for preprocessing, CLAUDE.md to skills migration, extended thinking budget MAX_THINKING_TOKENS, subagent delegation, plan mode, background token usage), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER otlp/console, OTLP endpoint and protocol configuration, dynamic headers otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team, metrics cardinality control session.id/version/account_uuid, metrics claude_code.session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events user_prompt/tool_result/api_request/api_error/tool_decision, prompt.id correlation, standard attributes session.id/app.version/organization.id/user.account_uuid/user.id/user.email/terminal.type, security and privacy opt-in/redacted prompts/OTEL_LOG_USER_PROMPTS/OTEL_LOG_TOOL_DETAILS, Bedrock monitoring guide, ROI measurement guide), troubleshooting (installation issues PATH/HTML script/curl failure/low memory/TLS errors/network/Windows irm/git-bash/musl-glibc mismatch/illegal instruction/dyld macOS/Docker hangs/WSL issues/WSL2 sandbox setup, permissions and authentication repeated prompts/OAuth errors/403 forbidden/disabled organization/WSL2 OAuth/token expired, configuration file locations and reset, performance high CPU/hangs/search issues/WSL search, IDE integration JetBrains WSL2/Escape key, markdown formatting missing language tags/spacing, /doctor diagnostics), changelog (release notes by version). Load when discussing Claude Code analytics, cost management, spend limits, rate limits, token usage, OpenTelemetry, monitoring, telemetry, metrics, events, troubleshooting, installation issues, PATH errors, TLS errors, proxy configuration, WSL issues, IDE integration problems, performance issues, /cost, /doctor, changelog, release notes, PR attribution, contribution metrics, ROI measurement, or operational concerns.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code analytics, cost management, OpenTelemetry monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

**Teams/Enterprise summary metrics:** PRs with CC, Lines of code with CC, PRs with CC (%), Suggestion accept rate, Lines of code accepted

**Console metrics:** Lines of code accepted, Suggestion accept rate, Activity (DAU/sessions), Spend (daily cost)

**Contribution metrics setup (Teams/Enterprise, requires Owner role):**

1. GitHub admin installs Claude GitHub app (`github.com/apps/claude`)
2. Claude Owner enables Claude Code analytics at `claude.ai/admin-settings/claude-code`
3. Enable "GitHub analytics" toggle on same page
4. Complete GitHub authentication and select organizations

Data appears within 24 hours. Not available with Zero Data Retention enabled.

**PR attribution:** PRs tagged as `claude-code-assisted` in GitHub. Sessions from 21 days before to 2 days after merge are considered. Code with >20% developer rewriting is not attributed. Normalized comparison (whitespace, quotes, case). Excluded files: lock files, generated code, build directories, test fixtures, lines over 1,000 characters.

### Cost Management

**Average costs:** ~$6/developer/day (90th percentile <$12/day). ~$100-200/developer/month with Sonnet.

**Track costs:** `/cost` command shows session token usage (API users). `/stats` for subscribers.

**Team spend limits:** Set workspace limits at `platform.claude.com`. "Claude Code" workspace auto-created on first auth. For Bedrock/Vertex/Foundry, use LiteLLM for spend tracking.

**Rate limit recommendations (TPM / RPM per user):**

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

TPM per user decreases at larger scales due to lower concurrency. Limits apply at organization level.

**Reduce token usage strategies:**

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to drop stale context; `/rename` first to save session |
| Custom compaction | `/compact Focus on ...` or set instructions in CLAUDE.md |
| Choose right model | Sonnet for most tasks; Opus for complex reasoning; `model: haiku` for subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`); disable unused servers via `/mcp`; `/context` to inspect |
| Tool search | Auto-defers when tools exceed 10% of context; adjust with `ENABLE_TOOL_SEARCH=auto:<N>` |
| Code intelligence plugins | Precise symbol nav replaces text search + multi-file reads |
| Hooks for preprocessing | Filter verbose output before Claude sees it (e.g., grep errors from logs) |
| Move CLAUDE.md to skills | Keep CLAUDE.md under ~500 lines; specialized instructions load on-demand via skills |
| Adjust extended thinking | Lower effort with `/effort`; disable in `/config`; `MAX_THINKING_TOKENS=8000` |
| Delegate to subagents | Verbose operations (tests, logs) stay in subagent context; summary returns |
| Agent teams | ~7x token usage; keep teams small, tasks self-contained |
| Specific prompts | "Add validation to auth.ts" beats "improve this codebase" |
| Plan mode | Shift+Tab before implementation; prevents expensive re-work |

**Background token usage:** ~$0.04/session for conversation summarization and command processing.

### OpenTelemetry Monitoring

**Quick start env vars:**

| Variable | Purpose | Values |
|:---------|:--------|:-------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console` |
| `OTEL_LOGS_EXPORTER` | Events/logs exporter | `otlp`, `console` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (default 60000ms) | `5000`, `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (default 5000ms) | `1000`, `10000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) | `1` |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names (default: off) | `1` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom team/dept attributes | `department=engineering,team.id=platform` |

Separate endpoints for metrics and logs supported via `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` / `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`.

**Cardinality control:**

| Variable | Attribute | Default |
|:---------|:----------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `session.id` | `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | `app.version` | `false` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `user.account_uuid` | `true` |

**Dynamic headers:** Set `otelHeadersHelper` in settings.json to a script that outputs JSON headers. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Admin configuration:** Use managed settings file to centrally control telemetry for all users. Env vars in managed settings have high precedence and cannot be overridden.

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

**Standard attributes (all metrics/events):** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.id`, `user.email`, `terminal.type`

**Exported events (via OTEL_LOGS_EXPORTER):**

| Event name | Key attributes |
|:-----------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID v4) for correlating events within a single user prompt. Do not use `prompt.id` in metrics (unique per prompt, unbounded cardinality).

**Service resource attributes:** `service.name: claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`, `wsl.version` (WSL only). Meter name: `com.anthropic.claude_code`.

**Temporality:** Default is `delta`. Set `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=cumulative` if needed.

### Troubleshooting

**Installation quick-fix table:**

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; use `brew install --cask claude-code` or check region |
| `curl: (56) Failure writing` | Download script first, then run; or use Homebrew/WinGet |
| `Killed` on Linux | Add swap space (need 4 GB RAM minimum) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Failed to fetch version` | Check `storage.googleapis.com` access; set `HTTPS_PROXY` |
| `irm not recognized` (Windows) | Use PowerShell, not CMD |
| `requires git-bash` (Windows) | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` in settings |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try Homebrew |
| Hangs in Docker | Set `WORKDIR /tmp` before install; increase memory to 4 GB |

**Authentication fixes:**

| Issue | Fix |
|:------|:----|
| Repeated permission prompts | Use `/permissions` to allowlist commands |
| OAuth invalid code | Retry quickly; press `c` to copy URL |
| 403 Forbidden | Check subscription; verify Console role; check proxy |
| "Organization disabled" with active sub | Unset `ANTHROPIC_API_KEY`; remove from shell profile |
| OAuth fails in WSL2 | Set `BROWSER` to Windows browser path; or copy URL manually |
| Token expired | `/login` to re-authenticate; check system clock |

**Configuration file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (committed) |

**Performance:**

- `/compact` to reduce context; restart between major tasks
- Ctrl+C to cancel; close terminal if unresponsive
- Install system `ripgrep` + `USE_BUILTIN_RIPGREP=0` for search issues
- WSL: move project to Linux filesystem (`/home/`) for better search performance

**IDE integration:**

- JetBrains on WSL2: configure Windows Firewall rule or switch to mirrored networking (`networkingMode=mirrored` in `.wslconfig`)
- JetBrains Escape key: Settings -> Tools -> Terminal -> uncheck "Move focus to editor with Escape"

**Diagnostics:** `/doctor` checks installation, auto-update, settings validation, MCP configs, keybindings, context usage, plugin/agent loading.

### Changelog

Release notes published per version at the changelog URL below. Run `claude --version` to check installed version. Also available on GitHub at `github.com/anthropics/claude-code/blob/main/CHANGELOG.md`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- Teams/Enterprise dashboard (usage metrics, contribution metrics with GitHub integration, leaderboard, CSV export), API Console dashboard (lines accepted, accept rate, activity, spend, team insights), contribution metrics setup (GitHub app install, Owner role, analytics toggle, GitHub auth), PR attribution process (tagging criteria, attribution matching, time window 21 days before to 2 days after merge, excluded files lock/generated/build/fixtures, normalization, 20% rewriting threshold, claude-code-assisted label), summary metrics (PRs with CC, lines with CC, accept rate, lines accepted), charts (adoption DAU/sessions, PRs per user, PR breakdown, lines view), leaderboard (top 10, CSV export all users), best practices (monitor adoption, measure ROI with DORA metrics, identify power users, query via claude-code-assisted label), not available with Zero Data Retention
- [Cost Management](references/claude-code-costs.md) -- average costs (~$6/dev/day, <$12 for 90th percentile, ~$100-200/dev/month with Sonnet), /cost command (token usage, API users only, /stats for subscribers), team cost management (workspace spend limits, auto-created Claude Code workspace, Bedrock/Vertex/Foundry LiteLLM tracking), rate limit TPM/RPM recommendations by team size (1-5 through 500+), agent team token costs (~7x standard, Sonnet for teammates, small teams, focused prompts, cleanup), reduce token usage (/clear between tasks, /compact with custom instructions, model selection Sonnet vs Opus vs Haiku, MCP overhead /context /mcp, ENABLE_TOOL_SEARCH auto threshold, code intelligence plugins, hooks for preprocessing, CLAUDE.md to skills migration under ~500 lines, extended thinking /effort MAX_THINKING_TOKENS, subagent delegation, agent team management, specific prompts, plan mode Shift+Tab, /rewind, verification targets, incremental testing), background token usage (~$0.04/session for summarization and commands)
- [OpenTelemetry Monitoring](references/claude-code-monitoring-usage.md) -- quick start (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER otlp/console, OTLP protocol grpc/http-json/http-protobuf, endpoint config, auth headers, export intervals), admin configuration (managed settings file, MDM distribution, high precedence env vars), configuration details (common env vars table, per-signal endpoint/protocol overrides, mTLS client cert/key, cardinality control session.id/version/account_uuid, dynamic headers otelHeadersHelper with 29-min refresh, OTEL_RESOURCE_ATTRIBUTES for multi-team with formatting requirements), example configurations (console/OTLP-gRPC/Prometheus/multiple exporters/split endpoints/metrics-only/logs-only), metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total with per-metric attributes), events (user_prompt, tool_result with tool_parameters/bash_command/mcp details, api_request with cost/tokens/speed, api_error with status_code/attempt, tool_decision), prompt.id event correlation, standard attributes (session.id, app.version, organization.id, user.account_uuid, user.id, user.email, terminal.type), interpret metrics (usage monitoring, cost monitoring, alerting, event analysis), backend considerations (Prometheus/ClickHouse/Honeycomb/Datadog for metrics, Elasticsearch/Loki for logs), service info (service.name claude-code, os.type, host.arch, wsl.version, meter com.anthropic.claude_code), ROI measurement guide (GitHub repo with Docker Compose/Prometheus/OTel configs), security and privacy (opt-in, no raw file content, tool_parameters may contain sensitive values, user.email included with OAuth, prompt content off by default OTEL_LOG_USER_PROMPTS, MCP/skill names off by default OTEL_LOG_TOOL_DETAILS), Bedrock monitoring guide
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (quick-fix lookup table, network diagnostics curl storage.googleapis.com, PATH verification per platform, conflicting installations which -a claude, directory permissions ~/.local/bin ~/.claude, binary verification ldd/--version), common installation problems (HTML instead of script/region unavailable, command not found PATH fix, curl 56 failure, TLS/SSL errors CA certs NODE_EXTRA_CA_CERTS TLS 1.2, failed to fetch version proxy, Windows irm/&& shell mismatch, OOM killed swap space 4GB RAM, Docker hangs WORKDIR /tmp, Claude Desktop overrides CLI, Windows git-bash CLAUDE_CODE_GIT_BASH_PATH, Linux musl/glibc mismatch, illegal instruction architecture, dyld cannot load macOS 13.0+, WSL2 npm/node/nvm issues appendWindowsPath, WSL2 sandbox bubblewrap socat, permission errors), authentication (repeated prompts /permissions, OAuth invalid code, 403 forbidden subscription/role/proxy, disabled organization ANTHROPIC_API_KEY override, WSL2 OAuth BROWSER env, token expired /login), configuration file locations table (settings.json user/project/local, ~/.claude.json, .mcp.json, managed settings), resetting configuration, performance (high CPU /compact restart, hangs Ctrl+C, search issues ripgrep USE_BUILTIN_RIPGREP=0, WSL slow search Linux filesystem), IDE integration (JetBrains WSL2 firewall/mirrored networking, Windows IDE issue reporting, JetBrains Escape key terminal settings), markdown formatting (missing language tags, spacing issues, reduce issues with conventions), /doctor diagnostics (installation, auto-update, settings validation, MCP errors, keybindings, context warnings, plugin/agent errors)
- [Changelog](references/claude-code-changelog.md) -- release notes by version with new features, improvements, and bug fixes; generated from GitHub CHANGELOG.md; check version with `claude --version`

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Cost Management: https://code.claude.com/docs/en/costs.md
- OpenTelemetry Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
