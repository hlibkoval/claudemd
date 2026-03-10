---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards (Teams/Enterprise contribution metrics, API Console usage), cost management (token tracking, team spend limits, rate limits, agent team costs, token reduction strategies), OpenTelemetry monitoring (metrics, events, configuration, exporters, cardinality control, dynamic headers, multi-team support, backend options), troubleshooting (installation, PATH, permissions, authentication, IDE integration, performance, WSL, Windows, sandboxing), and changelog. Load when discussing Claude Code costs, billing, token usage, analytics, monitoring, telemetry, OpenTelemetry, OTEL, troubleshooting installation or authentication problems, rate limits, or usage tracking.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code analytics, cost management, OpenTelemetry monitoring, troubleshooting, and changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|:-----|:-------------|:---------|
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

**Teams/Enterprise summary metrics:** PRs with CC, lines of code with CC, PRs with CC (%), suggestion accept rate, lines of code accepted.

**Contribution metrics setup (Teams/Enterprise):** Requires GitHub app install at [github.com/apps/claude](https://github.com/apps/claude), Owner role to configure, and GitHub analytics toggle enabled at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code). Data appears within 24 hours. Not available with Zero Data Retention enabled.

**PR attribution:** PRs tagged as "with Claude Code" when they contain at least one AI-assisted line. Uses a 21-day lookback window. Code rewritten >20% by the developer is not attributed. Excluded files: lock files, generated code, build directories, test fixtures, lines >1000 chars.

**Console dashboard (API):** Shows lines accepted, accept rate, activity chart (DAU/sessions), spend chart, and per-user team insights table. Requires UsageView permission.

### Cost Management

**Average costs:** ~$6/dev/day (90th percentile < $12/day). ~$100-200/dev/month with Sonnet.

**Track costs:** `/cost` shows session token usage (API users). `/stats` for subscribers.

**Team spend management:** Set workspace limits in [Console](https://platform.claude.com). "Claude Code" workspace auto-created on first auth. For Bedrock/Vertex/Foundry, consider [LiteLLM](https://docs.litellm.ai/docs/proxy/virtual_keys#tracking-spend) for spend tracking.

**Rate limit recommendations (TPM/RPM per user):**

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Reduce token usage strategies:**

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` to reset context; `/rename` + `/resume` to revisit |
| Choose cheaper model | Sonnet for most tasks; `/model` to switch; `model: haiku` for subagents |
| Reduce MCP overhead | Prefer CLI tools; disable unused servers; lower tool search threshold |
| Install code intelligence plugins | Precise symbol navigation reduces file reads |
| Hooks/skills for preprocessing | Filter verbose output before Claude sees it |
| Move instructions to skills | Keep CLAUDE.md < ~500 lines; use on-demand skills for specialized workflows |
| Adjust extended thinking | Lower budget or disable for simple tasks (`MAX_THINKING_TOKENS=8000`) |
| Delegate to subagents | Isolate verbose operations (tests, logs, docs) |
| Write specific prompts | Avoid vague requests that trigger broad scanning |
| Use plan mode | Shift+Tab before implementation to prevent rework |

**Agent team costs:** ~7x standard tokens (each teammate has own context window). Use Sonnet for teammates, keep teams small, keep spawn prompts focused, clean up idle teammates.

**Background token usage:** Conversation summarization and command processing consume ~$0.04/session even when idle.

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
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms) | `60000` (default) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms) | `5000` (default) |

**Admin configuration:** Set in managed settings file for org-wide control. Distributed via MDM. Cannot be overridden by users.

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

**Cardinality control:**

| Variable | Description | Default |
|:---------|:------------|:--------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id | `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version | `false` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid | `true` |

**Exported events:**

| Event name | Trigger | Key attributes |
|:-----------|:--------|:---------------|
| `claude_code.user_prompt` | User submits prompt | `prompt_length`, `prompt` (opt-in via `OTEL_LOG_USER_PROMPTS=1`) |
| `claude_code.tool_result` | Tool completes | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` |
| `claude_code.api_request` | API call made | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `speed` |
| `claude_code.api_error` | API call fails | `model`, `error`, `status_code`, `attempt`, `speed` |
| `claude_code.tool_decision` | Permission decision | `tool_name`, `decision`, `source` |

Events share `prompt.id` for correlation across a single user prompt. `OTEL_LOG_TOOL_DETAILS=1` enables MCP server/tool names and skill names in events.

**Dynamic headers:** Configure `otelHeadersHelper` in settings.json pointing to a script that outputs JSON headers. Refreshes every 29 minutes by default (`CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team support:** Use `OTEL_RESOURCE_ATTRIBUTES` for custom attributes (e.g., `department=engineering,team.id=platform`). No spaces allowed in values; use percent-encoding for special characters.

**Service info:** `service.name: claude-code`, includes `os.type`, `os.version`, `host.arch`, `wsl.version` (WSL only).

**Security:** Telemetry is opt-in. No raw file contents exported. User prompts redacted by default. MCP/tool names redacted by default.

### Troubleshooting

**Installation diagnostic lookup:**

| Symptom | Solution |
|:--------|:---------|
| `command not found: claude` | Fix PATH -- add `~/.local/bin` |
| `syntax error near unexpected token '<'` | Install script returned HTML; use `brew install --cask claude-code` |
| `curl: (56) Failure writing output` | Download script first, then run |
| `Killed` on Linux | Add swap space (4 GB RAM required) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Failed to fetch version` | Check network; set `HTTPS_PROXY` if behind proxy |
| `irm is not recognized` | Use correct shell (PowerShell vs CMD) |
| `requires git-bash` | Install Git for Windows; set `CLAUDE_CODE_GIT_BASH_PATH` |
| `Error loading shared library` | musl/glibc mismatch; check with `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check with `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; try Homebrew |

**Authentication fixes:**

| Issue | Fix |
|:------|:----|
| OAuth errors | Run `/logout`, restart, re-authenticate |
| 403 Forbidden | Verify subscription/role; check proxy |
| Browser won't open (WSL2) | Set `BROWSER` env var or press `c` to copy URL |
| Token expired | Run `/login`; check system clock |

**Configuration file locations:**

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

**Reset all settings:** `rm ~/.claude.json && rm -rf ~/.claude/ && rm -rf .claude/ && rm .mcp.json`

**Performance:** Use `/compact` regularly, close between tasks, add build dirs to `.gitignore`. Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` if search is broken.

**IDE issues (JetBrains):** WSL2 detection may need firewall rule or mirrored networking. Escape key conflict: disable "Move focus to the editor with Escape" in Settings > Tools > Terminal.

**Diagnostics:** Run `/doctor` to check installation, settings, MCP servers, keybindings, context usage, and plugin loading. Use `/bug` to report issues.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards for Teams/Enterprise and API Console, contribution metrics setup (GitHub integration), PR attribution, summary metrics, charts, leaderboard, data export
- [Manage costs effectively](references/claude-code-costs.md) -- token tracking with /cost, team spend limits, rate limit recommendations, agent team costs, token reduction strategies (context management, model selection, MCP overhead, hooks, skills, extended thinking, subagents), background token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- quick start, admin configuration, environment variables, metrics (session, LOC, PR, commit, cost, token, edit decisions, active time), events (user prompt, tool result, API request/error, tool decision), cardinality control, dynamic headers, multi-team support, backend options, security/privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, HTML scripts, TLS, low memory, Docker, WSL, Windows), authentication, config file locations, performance, IDE integration, markdown formatting
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
