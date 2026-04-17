---
name: operations-doc
description: Complete official documentation for Claude Code operations — error reference, analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, changelog, and weekly "what's new" digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: errors, analytics, costs, monitoring, troubleshooting, and release notes.

## Quick Reference

### Error lookup

| Message | Category |
| :------ | :------- |
| `API Error: 500 ... Internal server error` | Server |
| `API Error: Repeated 529 Overloaded errors` | Server |
| `Request timed out` | Server / Network |
| `You've hit your session limit` / `weekly limit` / `Opus limit` | Usage limits |
| `Server is temporarily limiting requests` | Usage limits |
| `Request rejected (429)` | Usage limits |
| `Credit balance is too low` | Usage limits |
| `Not logged in`, `Invalid API key`, `OAuth token revoked` | Authentication |
| `This organization has been disabled` | Authentication |
| `Unable to connect to API` / `SSL certificate verification failed` | Network |
| `Prompt is too long` / `Request too large` | Request |
| `Extra inputs are not permitted` | Request (gateway header issue) |
| `There's an issue with the selected model` | Request |

Automatic retries: up to 10 attempts with exponential backoff for transient failures. Tunable via `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

Common recovery commands:

| Symptom | Fix |
| :------ | :-- |
| 500/529 server errors | Check status.claude.com, wait, retry |
| Usage limit hit | `/usage`, `/extra-usage`, or wait for reset |
| Auth failure | `/login`, or unset stale `ANTHROPIC_API_KEY` |
| Network / SSL | Set `HTTPS_PROXY`, `NODE_EXTRA_CA_CERTS` |
| Prompt too long | `/compact`, `/clear`, `/context` |
| Gateway drops headers | Forward `anthropic-beta` header, or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| Model not found | `/model` to pick from available models |
| Lower quality responses | Check `/model`, `/effort`, `/context`; rewind instead of correcting |
| Tool use mismatch (400) | `/rewind` or Esc twice |

### Analytics dashboards

| Plan | URL | Includes |
| :--- | :-- | :------- |
| Team / Enterprise | claude.ai/analytics/claude-code | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend tracking, team insights |

Contribution metrics require GitHub app install + owner toggle at `claude.ai/admin-settings/claude-code`. Not available with Zero Data Retention.

Key contribution metrics: PRs with CC, lines of code with CC, suggestion accept rate. Attribution uses conservative matching within a 21-day window. Code rewritten >20% by developer is not attributed.

### Cost management

Typical enterprise costs: ~$13/dev/active day, $150-250/dev/month. 90% of users stay under $30/active day.

| Strategy | How |
| :------- | :-- |
| Track costs | `/cost` (API users), `/stats` (subscribers) |
| Team spend limits | Console workspace limits |
| Clear between tasks | `/clear`, `/rename`, `/resume` |
| Choose right model | Sonnet for most tasks, Opus for complex reasoning |
| Reduce MCP overhead | `/mcp` disable unused; prefer CLI tools (`gh`, `aws`) |
| Adjust thinking | `/effort` to lower level, or `MAX_THINKING_TOKENS=8000` |
| Subagent delegation | Isolate verbose ops (tests, logs) in subagents |
| Move instructions to skills | Keep CLAUDE.md under 200 lines |
| Specific prompts | Avoid "improve this codebase" |

Background token usage: ~$0.04 per session for summarization and command processing.

Rate limit recommendations (TPM per user by team size):

| Team size | TPM per user | RPM per user |
| :-------- | :----------- | :----------- |
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### OpenTelemetry monitoring

Quick start env vars:

| Variable | Purpose | Values |
| :------- | :------ | :----- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | Events/logs exporter | `otlp`, `console`, `none` |
| `OTEL_TRACES_EXPORTER` | Traces exporter (beta) | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | e.g. `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Transport protocol | `grpc`, `http/json`, `http/protobuf` |

Traces require `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` in addition to `ENABLE_TELEMETRY`.

Available metrics:

| Metric | Unit |
| :----- | :--- |
| `claude_code.session.count` | count |
| `claude_code.lines_of_code.count` | count (attrs: `type` added/removed) |
| `claude_code.pull_request.count` | count |
| `claude_code.commit.count` | count |
| `claude_code.cost.usage` | USD (attrs: `model`) |
| `claude_code.token.usage` | tokens (attrs: `type`, `model`) |
| `claude_code.code_edit_tool.decision` | count (attrs: `tool_name`, `decision`, `source`, `language`) |
| `claude_code.active_time.total` | seconds (attrs: `type` user/cli) |

Key events: `user_prompt`, `tool_result`, `api_request`, `api_error`, `tool_decision`, `plugin_installed`, `skill_activated`. Events share `prompt.id` for correlation.

Privacy controls:

| Variable | Default | Reveals |
| :------- | :------ | :------ |
| `OTEL_LOG_USER_PROMPTS` | off | Prompt content |
| `OTEL_LOG_TOOL_DETAILS` | off | Bash commands, MCP names, tool input |
| `OTEL_LOG_TOOL_CONTENT` | off | Full tool input/output (60KB cap, traces only) |
| `OTEL_LOG_RAW_API_BODIES` | off | Full API request/response JSON (60KB cap) |

Dynamic auth headers: set `otelHeadersHelper` in settings.json to a script path; refreshes every 29 min (tunable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

### Troubleshooting quick fixes

| Issue | Fix |
| :---- | :-- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install returns HTML | Use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| Install killed (low memory) | Add 2GB swap: `fallocate -l 2G /swapfile && mkswap && swapon` |
| TLS/SSL errors | `sudo apt install ca-certificates`, or set `NODE_EXTRA_CA_CERTS` |
| Repeated permission prompts | `/permissions` to allow specific tools |
| Auth issues | `/logout`, close, restart, `/login` |
| `This organization has been disabled` | Unset stale `ANTHROPIC_API_KEY` |
| High CPU/memory | `/compact`, restart between tasks, `/heapdump` for diagnostics |
| Search not working | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0` |
| JetBrains IDE not detected (WSL2) | Configure Windows Firewall rule for WSL2 subnet, or switch to mirrored networking |
| Esc key in JetBrains | Settings > Tools > Terminal > uncheck "Move focus to the editor with Escape" |
| Autocompact thrashing | Read files in chunks, `/compact` with focus, use subagents, or `/clear` |

Config file locations:

| File | Purpose |
| :--- | :------ |
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state, OAuth, MCP |
| `.mcp.json` | Project MCP servers |

Diagnostics: `/doctor` checks installation, settings, MCP, keybindings, context, plugins/agents.

### What's new highlights (recent weeks)

**Week 15** (v2.1.92-v2.1.101): Ultraplan cloud planning, Monitor tool for background event streaming, self-pacing `/loop`, `/team-onboarding`, `/autofix-pr` from terminal.

**Week 14** (v2.1.86-v2.1.91): Computer use in CLI, `/powerup` interactive lessons, flicker-free alt-screen rendering, per-tool MCP result-size override (up to 500K), plugin executables on PATH.

**Week 13** (v2.1.83-v2.1.85): Auto mode for permissions, computer use in Desktop app, PR auto-fix on Web, transcript search with `/`, native PowerShell tool, conditional `if` hooks.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — Runtime error messages with causes and recovery steps: server errors (500, 529, timeouts), usage limits (session/weekly limits, 429, credit balance), authentication (login, API key, OAuth), network (connection, SSL), request errors (prompt too long, model issues, gateway headers), and response quality troubleshooting.
- [Analytics](references/claude-code-analytics.md) — Team and Enterprise analytics dashboard (usage metrics, contribution metrics with GitHub integration, leaderboard, CSV export), API Console analytics (spend, team insights), PR attribution methodology, and how to enable contribution metrics.
- [Costs](references/claude-code-costs.md) — Token-based pricing, `/cost` command, workspace spend limits, rate limit recommendations by team size, strategies to reduce token usage (context management, model selection, MCP overhead, extended thinking, subagents, hooks, skills), agent team costs, and background token usage.
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry setup (metrics, events/logs, traces beta), environment variable reference, available metrics and events with attributes, cardinality control, dynamic auth headers, multi-team support, backend recommendations, distributed tracing with TRACEPARENT propagation, and security/privacy controls.
- [Troubleshooting](references/claude-code-troubleshooting.md) — Installation debugging (PATH, permissions, conflicting installs, TLS, low memory, Docker, WSL, musl/glibc), authentication issues (OAuth, 403, model not found, disabled org), performance (CPU/memory, autocompact thrashing, search), IDE integration (JetBrains WSL2, Escape key), and markdown formatting.
- [Changelog](references/claude-code-changelog.md) — Complete version-by-version changelog of all Claude Code releases.
- [What's new index](references/claude-code-whats-new-index.md) — Weekly dev digest index with summaries of each week's notable features.
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use (Desktop), PR auto-fix (Web), transcript search, PowerShell tool, conditional hooks.
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — Computer use (CLI), /powerup lessons, flicker-free rendering, MCP result-size override, plugin executables on PATH.
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan cloud planning, Monitor tool, /autofix-pr from terminal, /team-onboarding.

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 digest: https://code.claude.com/docs/en/whats-new/2026-w15.md
