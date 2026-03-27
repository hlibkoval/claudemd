---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog. Covers analytics (Teams/Enterprise dashboard at claude.ai/analytics/claude-code with usage metrics, contribution metrics via GitHub integration, PR attribution, leaderboard, CSV export; API Console dashboard at platform.claude.com/claude-code with usage/spend/team insights), cost management (/cost command for API users, /stats for subscribers, workspace spend limits, rate limit recommendations by team size TPM/RPM, agent team token costs, context management with /clear and /compact, model selection Sonnet vs Opus, MCP overhead reduction, code intelligence plugins, hooks and skills for offloading, extended thinking budget MAX_THINKING_TOKENS, subagent delegation, background token usage), OpenTelemetry monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER otlp/prometheus/console, OTEL_LOGS_EXPORTER, OTLP endpoints and protocols grpc/http-json/http-protobuf, mTLS, dynamic headers via otelHeadersHelper, OTEL_RESOURCE_ATTRIBUTES for multi-team, metrics cardinality control OTEL_METRICS_INCLUDE_SESSION_ID/VERSION/ACCOUNT_UUID, metrics claude_code.session.count/lines_of_code.count/pull_request.count/commit.count/cost.usage/token.usage/code_edit_tool.decision/active_time.total, events user_prompt/tool_result/api_request/api_error/tool_decision with prompt.id correlation, OTEL_LOG_USER_PROMPTS and OTEL_LOG_TOOL_DETAILS, Prometheus/Datadog/Honeycomb/ClickHouse backend guidance, ROI measurement guide), troubleshooting (installation issues -- PATH, HTML install script, curl failures, low-memory Linux, TLS/SSL errors, network connectivity, Windows irm/git-bash, musl/glibc mismatch, illegal instruction, dyld macOS, Docker hangs, WSL2 setup; authentication -- OAuth errors, 403 forbidden, disabled organization, ANTHROPIC_API_KEY override, token expiry; configuration file locations; performance -- high CPU/memory, command hangs, ripgrep search issues, WSL slow search; IDE integration -- JetBrains WSL2 detection, Escape key conflicts; markdown formatting; /doctor diagnostic command), and the full changelog with release notes. Load when discussing Claude Code analytics, usage metrics, contribution metrics, PR attribution, cost management, token usage, spend limits, rate limits, TPM, RPM, agent team costs, OpenTelemetry, OTel, OTEL, telemetry, monitoring, metrics export, Prometheus, Datadog, Honeycomb, observability, troubleshooting, installation issues, PATH problems, authentication errors, /doctor, changelog, release notes, what's new, version history, ROI measurement, /cost command, /stats command, workspace spend, background token usage, or any operations-related topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- covering analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, and the changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key features |
|:-----|:-------------|:-------------|
| **Teams / Enterprise** | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| **API (Console)** | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

**Teams/Enterprise summary metrics:** PRs with CC, lines of code with CC, PRs with Claude Code (%), suggestion accept rate, lines of code accepted.

**Console metrics:** lines of code accepted, suggestion accept rate, daily active users/sessions, daily API spend, per-user spend and lines this month.

**Contribution metrics setup** (Teams/Enterprise only, requires Owner role):

1. GitHub admin installs [github.com/apps/claude](https://github.com/apps/claude)
2. Owner enables Claude Code analytics at `claude.ai/admin-settings/claude-code`
3. Enable "GitHub analytics" toggle
4. Complete GitHub authentication and select organizations

Data appears within 24 hours. Not available with Zero Data Retention.

**PR attribution:** PRs with at least one Claude Code-assisted line are labeled `claude-code-assisted` in GitHub. Attribution uses a 21-day pre-merge to 2-day post-merge window. Lines rewritten by developers (>20% difference) are not attributed. Lock files, generated code, build directories, test fixtures, and lines >1,000 chars are excluded.

### Cost Management

**Average costs:** ~$6/developer/day (90th percentile under $12/day). API users: ~$100-200/developer/month with Sonnet 4.6.

| Command | Purpose |
|:--------|:--------|
| `/cost` | Session token usage and cost (API users) |
| `/stats` | Usage patterns (Pro/Max subscribers) |
| `/clear` | Reset context between tasks |
| `/compact [focus]` | Summarize context, optionally preserving specific topics |

**Team spend management:**

| Method | Details |
|:-------|:--------|
| Workspace spend limits | Set in Claude Console for API workspaces |
| Bedrock/Vertex/Foundry | Use LiteLLM or provider-native tools for tracking |

**Rate limit recommendations (TPM / RPM per user):**

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

Rate limits apply at the organization level, not per-user. Concurrent usage is typically lower in larger teams.

**Cost reduction strategies:**

| Strategy | Impact |
|:---------|:-------|
| Use `/clear` between tasks | Avoids stale context tokens |
| Choose Sonnet over Opus for routine work | Lower per-token cost |
| Reduce MCP overhead (prefer CLIs like `gh`, `aws`) | Fewer tool-listing tokens |
| Install code intelligence plugins | Precise navigation vs. broad grep |
| Offload processing to hooks/skills | Smaller context per message |
| Lower extended thinking budget (`MAX_THINKING_TOKENS`) | Fewer output tokens |
| Delegate verbose operations to subagents | Summary returns to main context |
| Write specific prompts | Less scanning and file reads |
| Use plan mode for complex tasks | Prevents expensive re-work |
| Move detailed CLAUDE.md instructions into skills | On-demand loading vs. always-in-context |

**Agent teams** use ~7x more tokens than standard sessions when teammates run in plan mode. Keep team tasks small and self-contained.

**Background token usage:** summarization jobs and some commands consume a small amount (~$0.04/session) even when idle.

### OpenTelemetry Monitoring

**Enable telemetry:**

```
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp             # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc    # grpc | http/json | http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Purpose | Default |
|:---------|:--------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Master switch (required) | -- |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s), comma-separated | -- |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s), comma-separated | -- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | -- |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for all signals | -- |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | -- |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Include tool parameters and input | disabled |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Temporality | `delta` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes for multi-team filtering | -- |

Separate metrics/logs endpoints are supported with `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`, `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`, and their protocol variants.

**Dynamic headers:** set `otelHeadersHelper` in settings to a script that outputs JSON headers. Refreshes every 29 minutes by default (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Admin configuration:** use the managed settings file to enforce telemetry org-wide via the `env` block.

**Cardinality control:**

| Variable | Controls | Default |
|:---------|:---------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_VERSION` | app.version in metrics | false |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | user.account_uuid/id in metrics | true |

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

All metrics include standard attributes: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

**Exported events** (via logs exporter):

| Event | Key attributes |
|:------|:---------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (if enabled) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `decision_source`, `tool_parameters`/`tool_input` (if enabled) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `speed` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt`, `speed` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events include `prompt.id` (UUID) for correlating events within a single user prompt.

**Resource attributes on all data:** `service.name` = `claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`. Meter name: `com.anthropic.claude_code`.

### Troubleshooting Quick Lookup

**Installation issues:**

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script returned HTML; use Homebrew/WinGet instead |
| `curl: (56) Failure writing` | Download script first, then run; or use Homebrew |
| `Killed` on Linux | Add 2GB swap; need 4GB+ RAM |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY` if behind proxy |
| Windows `irm` not recognized | Use PowerShell, not CMD |
| `requires git-bash` | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |
| Missing shared library (Linux) | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try Homebrew |
| Install hangs in Docker | Set `WORKDIR /tmp` before install |

**Authentication issues:**

| Symptom | Fix |
|:--------|:----|
| OAuth invalid code | Retry quickly; press `c` to copy URL |
| 403 Forbidden | Verify subscription/role; check proxy |
| "Organization disabled" with active subscription | Unset `ANTHROPIC_API_KEY` env var |
| Token expired | Run `/login`; check system clock |

**Configuration file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (committed) |

**Performance:**

| Issue | Fix |
|:------|:----|
| High CPU/memory | Use `/compact`; restart between tasks; `.gitignore` build dirs |
| Command hangs | Ctrl+C to cancel; restart terminal |
| Search/skills not working | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Move project to Linux filesystem (`/home/`); use specific search terms |

**IDE integration:**

| Issue | Fix |
|:------|:----|
| JetBrains not detected on WSL2 | Configure Windows Firewall for WSL2 subnet, or use mirrored networking |
| Escape key not working in JetBrains | Disable "Move focus to editor with Escape" in Settings > Tools > Terminal |

**Diagnostics:** Run `/doctor` to check installation, settings, MCP servers, keybindings, context usage, and plugin loading.

### Changelog

The changelog contains release notes for every Claude Code version. It is generated from [CHANGELOG.md on GitHub](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md). Run `claude --version` to check your installed version.

See the full changelog reference for detailed per-version release notes.

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- Teams/Enterprise dashboard (usage metrics, contribution metrics with GitHub integration, PR attribution process and tagging criteria, leaderboard, CSV export), Console dashboard (usage, spend, team insights), enabling contribution metrics (GitHub app install, Owner setup steps), summary metrics (PRs with CC, lines of code with CC, suggestion accept rate), charts (adoption, PRs per user, pull requests breakdown), attribution details (21-day window, normalization, excluded files, >20% rewrite exclusion, claude-code-assisted label), getting the most from analytics (monitoring adoption, measuring ROI with DORA metrics, identifying power users, programmatic access via GitHub labels)
- [Cost Management](references/claude-code-costs.md) -- /cost command (session token usage for API users), /stats for subscribers, managing costs for teams (workspace spend limits, "Claude Code" workspace auto-creation, LiteLLM for Bedrock/Vertex/Foundry), rate limit recommendations by team size (TPM/RPM tables), agent team token costs (Sonnet for teammates, small teams, focused spawn prompts, cleanup), reducing token usage (context management with /clear and /compact, custom compaction instructions, model selection Sonnet vs Opus, MCP overhead reduction, code intelligence plugins, hooks and skills offloading, CLAUDE.md to skills migration, extended thinking budget MAX_THINKING_TOKENS and /effort, subagent delegation, specific prompts, plan mode, course-correct early, verification targets), background token usage (~$0.04/session)
- [OpenTelemetry Monitoring](references/claude-code-monitoring-usage.md) -- Quick start setup, environment variables (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER, OTLP endpoint/protocol/headers, mTLS, export intervals, OTEL_LOG_USER_PROMPTS, OTEL_LOG_TOOL_DETAILS, temporality preference), administrator configuration via managed settings, cardinality control (OTEL_METRICS_INCLUDE_SESSION_ID/VERSION/ACCOUNT_UUID), dynamic headers (otelHeadersHelper, refresh interval), multi-team support (OTEL_RESOURCE_ATTRIBUTES), example configurations (console/OTLP-gRPC/Prometheus/multiple exporters/separate endpoints/metrics-only/events-only), exported metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total with per-metric attributes), events (user_prompt, tool_result with tool_parameters/tool_input, api_request, api_error, tool_decision with prompt.id correlation), data interpretation (usage monitoring, cost monitoring, alerting, event analysis), backend considerations (Prometheus, ClickHouse, Honeycomb, Datadog, Elasticsearch, Loki), service information (resource attributes), ROI measurement guide, security and privacy, Bedrock monitoring guide
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation issues (PATH, HTML install script, curl failures, low-memory Linux swap, TLS/SSL, network connectivity, Windows irm/git-bash, musl/glibc mismatch, illegal instruction, dyld macOS, Docker hangs, Claude Desktop overrides, WSL2 setup), debugging steps (network check, PATH verify, conflicting installs, directory permissions, binary verification), authentication (OAuth errors, 403 forbidden, disabled organization with ANTHROPIC_API_KEY, WSL2 OAuth, token expiry), configuration file locations and reset, performance (CPU/memory, hangs, ripgrep search, WSL slow search), IDE integration (JetBrains WSL2 detection with firewall/mirrored networking, Escape key), markdown formatting issues, /doctor diagnostics, /feedback for reporting
- [Changelog](references/claude-code-changelog.md) -- Full release notes for every Claude Code version, including new features, improvements, and bug fixes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Cost Management: https://code.claude.com/docs/en/costs.md
- OpenTelemetry Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
