---
name: operations-doc
description: Complete official documentation for Claude Code operations — error reference, cost management, OpenTelemetry monitoring, analytics dashboards, troubleshooting, changelog, and weekly feature digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations, covering errors, costs, monitoring, analytics, troubleshooting, and release notes.

## Quick Reference

### Error lookup

Match the message in your terminal to a category. Claude Code retries transient failures up to 10 times (configurable via `CLAUDE_CODE_MAX_RETRIES`) with exponential backoff before surfacing any error.

| Error message pattern | Category |
| :--- | :--- |
| `API Error: 500 ...` / `Repeated 529 Overloaded` / `Request timed out` | Server errors |
| `You've hit your session limit` / `weekly limit` / `Opus limit` | Usage limits |
| `Server is temporarily limiting requests` / `Request rejected (429)` | Rate limiting |
| `Credit balance is too low` | Billing |
| `Not logged in` / `Invalid API key` / `OAuth token revoked` | Authentication |
| `Unable to connect to API` / `SSL certificate verification failed` | Network |
| `Prompt is too long` / `Request too large` / `Image was too large` | Request errors |
| `Extra inputs are not permitted` | Gateway stripping `anthropic-beta` header |
| `thinking.type.enabled is not supported` | CLI too old for Opus 4.7 |
| Responses seem lower quality | Check model, effort, context pressure |

Key recovery commands: `/login` (auth), `/model` (switch model), `/compact` or `/clear` (context), `/rewind` or Esc-Esc (corrupted turns), `/feedback` (report to Anthropic), `/doctor` (local config check).

### Retry tuning

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Retry attempts before surfacing error |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout (ms) |

### Cost management

Average enterprise cost: ~$13/developer/active day, $150-250/developer/month (90th percentile under $30/day).

| Command | Purpose |
| :--- | :--- |
| `/cost` | Session token usage and estimated cost (API users) |
| `/stats` | Usage patterns (subscription users) |
| `/usage` | Plan limits and reset times |
| `/extra-usage` | Buy additional usage (Pro/Max) or request from admin (Team/Enterprise) |
| `/context` | Context window breakdown |

**Reduce costs by**: clearing between tasks (`/clear`), choosing Sonnet over Opus for routine work, disabling unused MCP servers, lowering effort (`/effort`), delegating verbose operations to subagents, writing specific prompts, moving specialized instructions from CLAUDE.md to skills.

### Rate limit recommendations (TPM per user by team size)

| Team size | TPM/user | RPM/user |
| :--- | :--- | :--- |
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### OpenTelemetry monitoring

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. Supports metrics, logs/events, and traces (beta).

| Env var | Values | Purpose |
| :--- | :--- | :--- |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` | Metrics exporter |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` | Events exporter |
| `OTEL_TRACES_EXPORTER` | `otlp`, `console`, `none` | Traces exporter (requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` | OTLP protocol |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | URL | Collector endpoint |

**Key metrics**: `claude_code.session.count`, `claude_code.token.usage` (by type: input/output/cacheRead/cacheCreation), `claude_code.cost.usage` (USD), `claude_code.lines_of_code.count`, `claude_code.commit.count`, `claude_code.pull_request.count`, `claude_code.active_time.total`, `claude_code.code_edit_tool.decision`.

**Key events**: `user_prompt`, `tool_result`, `api_request`, `api_error`, `tool_decision`, `plugin_installed`, `skill_activated`, `api_request_body`, `api_response_body`.

**Privacy defaults**: prompts redacted (enable with `OTEL_LOG_USER_PROMPTS=1`), tool details redacted (`OTEL_LOG_TOOL_DETAILS=1`), tool content redacted (`OTEL_LOG_TOOL_CONTENT=1`), raw API bodies redacted (`OTEL_LOG_RAW_API_BODIES=1`).

**Dynamic headers**: set `otelHeadersHelper` in settings to a script that outputs JSON headers; refreshes every 29 minutes by default.

**Multi-team segmentation**: use `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values).

### Analytics dashboards

| Plan | URL | Features |
| :--- | :--- | :--- |
| Team / Enterprise | `claude.ai/analytics/claude-code` | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage, spend, team insights |

**Contribution metrics** (Team/Enterprise): requires GitHub app install + admin enablement. PRs labeled `claude-code-assisted` in GitHub. Attribution uses conservative matching within a 21-day window.

### Troubleshooting quick fixes

| Symptom | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| TLS/SSL errors | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| Repeated login prompts | Check system clock; on macOS, unlock Keychain |
| High CPU/memory | `/compact`, restart between tasks, `/heapdump` to diagnose |
| Auto-compact thrashing | Read files in chunks, move large-file work to subagent |
| Search not working | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0` |
| Stale `ANTHROPIC_API_KEY` overriding subscription | `unset ANTHROPIC_API_KEY` and remove from shell profile |
| Model not found | Check `--model`, `ANTHROPIC_MODEL`, settings files; use `/model` |
| JetBrains not detected on WSL2 | Configure Windows Firewall rule or switch to mirrored networking |

**Diagnostic commands**: `/doctor` (config check), `/status` (active credential), `/context` (window usage), `/feedback` (report to Anthropic).

### Configuration file locations

| File | Purpose |
| :--- | :--- |
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state, theme, OAuth, MCP servers |
| `.mcp.json` | Project MCP servers |

### What's new highlights (recent weeks)

| Week | Key features |
| :--- | :--- |
| W15 (Apr 6-10) | Ultraplan cloud planning, Monitor tool, self-pacing `/loop`, `/team-onboarding`, `/autofix-pr` from CLI |
| W14 (Mar 30-Apr 3) | Computer use in CLI, `/powerup` interactive lessons, flicker-free rendering, per-tool MCP result-size override, plugin executables on PATH |
| W13 (Mar 23-27) | Auto mode (permission classifier), computer use in Desktop, PR auto-fix on Web, transcript search, PowerShell tool, conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — full lookup table of runtime error messages with causes, recovery steps, and retry behavior.
- [Track team usage with analytics](references/claude-code-analytics.md) — Team/Enterprise and API Console analytics dashboards, contribution metrics with GitHub integration, PR attribution, leaderboard, and data export.
- [Manage costs effectively](references/claude-code-costs.md) — token cost tracking, team spend limits, rate limit recommendations, and strategies to reduce token usage (context management, model selection, hooks, skills, subagents).
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry setup for metrics, events, and traces (beta); all available metrics and events with attributes; privacy controls; dynamic headers; multi-team segmentation; backend considerations.
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation debugging (PATH, permissions, binary mismatches, Docker, WSL), authentication issues, performance/stability, IDE integration, and markdown formatting.
- [Changelog](references/claude-code-changelog.md) — version-by-version release notes with new features, improvements, and bug fixes.
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index of notable Claude Code features.
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use (Desktop), PR auto-fix (Web), transcript search, PowerShell tool, conditional hooks.
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — computer use (CLI), /powerup lessons, flicker-free rendering, MCP result-size override, plugin executables on PATH.
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — ultraplan, Monitor tool, /autofix-pr from CLI, /team-onboarding.

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 digest: https://code.claude.com/docs/en/whats-new/2026-w15.md
