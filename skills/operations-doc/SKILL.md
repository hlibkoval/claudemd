---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, error reference, changelog, and weekly feature digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations, covering analytics, cost management, monitoring, troubleshooting, errors, and release notes.

## Quick Reference

### Analytics dashboards

| Plan                     | Dashboard URL                                                    | Includes                                                    |
| :----------------------- | :--------------------------------------------------------------- | :---------------------------------------------------------- |
| Teams / Enterprise       | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console)     | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights                |

Contribution metrics require GitHub app install + Owner role. Not available with Zero Data Retention.

**PR attribution**: merged PRs are scanned against Claude Code session activity. Lines with high confidence are counted, PRs are labeled `claude-code-assisted` in GitHub. Session window: 21 days before to 2 days after merge. Code rewritten >20% is not attributed.

### Cost management

| Metric               | Typical value                                  |
| :-------------------- | :--------------------------------------------- |
| Average per active day | ~$13/developer                                |
| Average per month      | $150-250/developer                            |
| 90th percentile/day   | <$30                                           |

**Key commands**: `/cost` (session token usage), `/stats` (subscription usage patterns), `/usage` (plan limits).

**Rate limit recommendations (TPM per user)**:

| Team size     | TPM per user | RPM per user |
| :------------ | :----------- | :----------- |
| 1-5 users     | 200k-300k    | 5-7          |
| 5-20 users    | 100k-150k    | 2.5-3.5      |
| 20-50 users   | 50k-75k      | 1.25-1.75    |
| 50-100 users  | 25k-35k      | 0.62-0.87    |
| 100-500 users | 15k-20k      | 0.37-0.47    |
| 500+ users    | 10k-15k      | 0.25-0.35    |

**Reduce token usage**:
- `/clear` between tasks; `/compact` with custom focus
- Use Sonnet for most tasks, Opus for complex reasoning
- Lower effort with `/effort`; reduce `MAX_THINKING_TOKENS`
- Disable unused MCP servers (`/mcp`)
- Move specialized CLAUDE.md instructions into skills
- Delegate verbose operations to subagents
- Write specific prompts; use plan mode for complex tasks

### OpenTelemetry monitoring

**Quick start env vars**:

| Variable                         | Purpose                                | Values                                  |
| :------------------------------- | :------------------------------------- | :-------------------------------------- |
| `CLAUDE_CODE_ENABLE_TELEMETRY`   | Enable telemetry (required)            | `1`                                     |
| `OTEL_METRICS_EXPORTER`          | Metrics exporter                       | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER`             | Logs/events exporter                   | `otlp`, `console`, `none`              |
| `OTEL_EXPORTER_OTLP_PROTOCOL`   | OTLP protocol                          | `grpc`, `http/json`, `http/protobuf`   |
| `OTEL_EXPORTER_OTLP_ENDPOINT`   | Collector endpoint                     | `http://localhost:4317`                 |
| `OTEL_EXPORTER_OTLP_HEADERS`    | Auth headers                           | `Authorization=Bearer token`           |
| `OTEL_METRIC_EXPORT_INTERVAL`   | Metrics interval (ms)                  | `60000` (default)                      |
| `OTEL_LOGS_EXPORT_INTERVAL`     | Logs interval (ms)                     | `5000` (default)                       |

**Traces (beta)**: additionally set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER=otlp`. Subprocesses inherit `TRACEPARENT` for distributed tracing.

**Content logging controls**:

| Variable                 | What it logs                                      | Default |
| :----------------------- | :------------------------------------------------ | :------ |
| `OTEL_LOG_USER_PROMPTS`  | User prompt content                               | off     |
| `OTEL_LOG_TOOL_DETAILS`  | Tool parameters, bash commands, MCP/skill names   | off     |
| `OTEL_LOG_TOOL_CONTENT`  | Tool input/output in trace spans (60 KB cap)      | off     |
| `OTEL_LOG_RAW_API_BODIES`| Full API request/response JSON (60 KB cap)        | off     |

**Exported metrics**:

| Metric                                | Unit   | Key attributes                       |
| :------------------------------------ | :----- | :----------------------------------- |
| `claude_code.session.count`           | count  | standard                             |
| `claude_code.lines_of_code.count`     | count  | `type` (added/removed)               |
| `claude_code.pull_request.count`      | count  | standard                             |
| `claude_code.commit.count`            | count  | standard                             |
| `claude_code.cost.usage`              | USD    | `model`                              |
| `claude_code.token.usage`             | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count  | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total`       | s      | `type` (user/cli)                    |

**Exported events**: `user_prompt`, `tool_result`, `api_request`, `api_error`, `api_request_body`, `api_response_body`, `tool_decision`, `plugin_installed`, `skill_activated`. All events share `prompt.id` for correlation.

**Standard attributes**: `session.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `organization.id`, `terminal.type`. Control cardinality with `OTEL_METRICS_INCLUDE_SESSION_ID`, `OTEL_METRICS_INCLUDE_VERSION`, `OTEL_METRICS_INCLUDE_ACCOUNT_UUID`.

**Dynamic headers**: set `otelHeadersHelper` in settings.json to a script that outputs JSON headers; refreshes every 29 min (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team**: use `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values).

### Troubleshooting quick lookup

| Symptom                                        | Fix                                                    |
| :--------------------------------------------- | :----------------------------------------------------- |
| `command not found: claude`                    | Add `~/.local/bin` to PATH                             |
| TLS/SSL errors                                 | Update CA certs; set `NODE_EXTRA_CA_CERTS`              |
| `Killed` during install                        | Add swap space (4 GB RAM minimum)                       |
| Install hangs in Docker                        | Set `WORKDIR /tmp` before install                       |
| OAuth error / 403 Forbidden                    | `/logout`, restart, `/login` again                      |
| Repeated permission prompts                    | `/permissions` to allow tools                           |
| High CPU/memory                                | `/compact`; restart between tasks; `/heapdump` for diagnostics |
| Auto-compaction thrashing                      | Read files in chunks; `/compact` with focus; use subagents |
| Search/discovery not working                   | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0`   |

**Config file locations**:

| File                          | Purpose                              |
| :---------------------------- | :----------------------------------- |
| `~/.claude/settings.json`     | User settings                        |
| `.claude/settings.json`       | Project settings (committed)         |
| `.claude/settings.local.json` | Local project settings (gitignored)  |
| `~/.claude.json`              | Global state (theme, OAuth, MCP)     |
| `.mcp.json`                   | Project MCP servers                  |

**Diagnostics**: run `/doctor` to check installation, settings, MCP servers, keybindings, context usage, and plugin/agent errors.

### Error reference

**Automatic retries**: transient errors are retried up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` and `API_TIMEOUT_MS` (default 600000ms).

| Error message                                           | Category       | Recovery                                           |
| :------------------------------------------------------ | :------------- | :------------------------------------------------- |
| `API Error: 500 Internal server error`                  | Server         | Check status.claude.com; retry                      |
| `Repeated 529 Overloaded errors`                        | Server         | Switch model with `/model`; wait                    |
| `Request timed out`                                     | Server/Network | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session/weekly/Opus limit`             | Usage          | Wait for reset; `/usage`; `/extra-usage`            |
| `Request rejected (429)`                                | Usage          | Check `/status`; reduce concurrency                 |
| `Credit balance is too low`                             | Usage          | Add credits; enable auto-reload                     |
| `Not logged in`                                         | Auth           | `/login`; check `ANTHROPIC_API_KEY`                 |
| `Invalid API key`                                       | Auth           | Verify key in Console; unset stale env vars         |
| `This organization has been disabled`                   | Auth           | Unset `ANTHROPIC_API_KEY`; use subscription auth    |
| `OAuth token revoked/expired`                           | Auth           | `/login`; if repeated, `/logout` then `/login`      |
| `Unable to connect to API`                              | Network        | Check connectivity; set `HTTPS_PROXY`               |
| `SSL certificate verification failed`                   | Network        | Set `NODE_EXTRA_CA_CERTS`                           |
| `Prompt is too long`                                    | Request        | `/compact` or `/clear`; `/context` to check usage   |
| `Request too large` (max 30 MB)                         | Request        | Reference files by path instead of pasting          |
| `Extra inputs are not permitted`                        | Request        | Forward `anthropic-beta` header through gateway     |
| `thinking.type.enabled is not supported`                | Request        | `claude update` to v2.1.111+                        |
| Lower quality responses (no error)                      | Quality        | Check `/model`, `/effort`, `/context`; `/rewind`    |

### What's New (weekly digest)

| Week | Dates                | Versions        | Highlights                                                      |
| :--- | :------------------- | :-------------- | :-------------------------------------------------------------- |
| W15  | April 6-10, 2026     | v2.1.92-v2.1.101 | Ultraplan cloud planning, Monitor tool, `/loop` self-pacing, `/team-onboarding`, `/autofix-pr` from CLI |
| W14  | March 30 - April 3   | v2.1.86-v2.1.91  | Computer use in CLI, `/powerup` lessons, flicker-free rendering, per-tool MCP result-size override, plugin `bin/` on PATH |
| W13  | March 23-27, 2026    | v2.1.83-v2.1.85  | Auto mode, computer use in Desktop, PR auto-fix on Web, transcript search, PowerShell tool, conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) -- analytics dashboards for Teams/Enterprise and API customers, contribution metrics with GitHub integration, PR attribution, leaderboard, data export.
- [Manage costs effectively](references/claude-code-costs.md) -- cost tracking with `/cost`, team spend limits, rate limit recommendations by team size, agent team costs, strategies for reducing token usage (context management, model selection, MCP overhead, hooks, skills, thinking, subagents).
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- enabling telemetry, OTLP/Prometheus/console exporters, admin configuration via managed settings, traces (beta), dynamic headers, multi-team attributes, all exported metrics and events, cardinality control, event correlation, backend guidance, security and privacy.
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (PATH, TLS, memory, Docker, Windows, WSL), authentication (OAuth, API keys, 403), config file locations, performance, search issues, IDE integration, markdown formatting.
- [Error reference](references/claude-code-errors.md) -- runtime error messages with recovery steps: server errors (500, 529, timeouts), usage limits (session/rate/credit), authentication errors, network/SSL errors, request errors (prompt too long, request too large, model issues, thinking budget), response quality diagnostics.
- [Changelog](references/claude-code-changelog.md) -- full release notes by version with new features, improvements, and bug fixes.
- [What's New index](references/claude-code-whats-new-index.md) -- weekly dev digest index with links to individual weekly entries.
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) -- auto mode, computer use in Desktop, PR auto-fix, transcript search, PowerShell tool, conditional hooks.
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) -- computer use in CLI, /powerup lessons, flicker-free rendering, MCP result-size override, plugin executables on PATH.
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) -- Ultraplan cloud planning, Monitor tool, /loop self-pacing, /team-onboarding, /autofix-pr from CLI.

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New index: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 digest: https://code.claude.com/docs/en/whats-new/2026-w15.md
