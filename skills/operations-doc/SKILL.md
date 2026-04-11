---
name: operations-doc
description: Complete documentation for Claude Code day-two operations — analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting installs and auth, and release notes. Covers tracking team usage metrics and contribution attribution, managing spend and rate limits, exporting OTel metrics/events/traces, diagnosing common install and permission issues, and the latest changelog entries.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running Claude Code in production — analytics, costs, monitoring, troubleshooting, and release notes.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Includes |
| --- | --- | --- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend tracking, team insights (no GitHub contribution metrics) |

**Enable contribution metrics (Teams/Enterprise):** GitHub admin installs github.com/apps/claude, then Owner enables "Claude Code analytics" and "GitHub analytics" at claude.ai/admin-settings/claude-code. Data appears within 24 hours. Not available with Zero Data Retention.

**Attribution:** PRs are tagged `claude-code-assisted` in GitHub. Sessions from 21 days before to 2 days after merge are considered. Lines normalized (whitespace, quotes, case) before matching. Lock files, generated code, build dirs, test fixtures, and lines over 1,000 chars are excluded. Code rewritten with more than 20% difference is not attributed.

**Console required permissions:** `UsageView` (Developer, Billing, Admin, Owner, Primary Owner roles).

### Cost management

- **`/cost`** — per-session token stats (API users only; Max/Pro subscribers use `/stats`).
- **Workspace limits** — set spend caps on the auto-created "Claude Code" workspace in Console.
- **Typical cost:** ~$13/dev/active day, $150–250/dev/month; <$30/day for 90% of users.

**TPM/RPM per user by team size:**

| Team size | TPM per user | RPM per user |
| --- | --- | --- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Reduce token usage:** `/clear` between tasks, `/compact` with custom instructions, prefer Sonnet over Opus, use CLI tools over MCP, install code intelligence plugins, offload to hooks/skills, move CLAUDE.md workflow blocks into skills (keep CLAUDE.md under 200 lines), lower extended thinking `/effort` or set `MAX_THINKING_TOKENS=8000`, delegate verbose ops to subagents, use plan mode for complex tasks. Agent teams use ~7x more tokens than standard sessions.

### OpenTelemetry monitoring

**Enable:** `CLAUDE_CODE_ENABLE_TELEMETRY=1` plus at least one exporter.

**Core env vars:**

| Variable | Values / Default |
| --- | --- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` (required) |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | e.g. `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | e.g. `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | default `60000` ms |
| `OTEL_LOGS_EXPORT_INTERVAL` | default `5000` ms |
| `OTEL_LOG_USER_PROMPTS` | `1` to include prompt text |
| `OTEL_LOG_TOOL_DETAILS` | `1` to include tool args (Bash cmds, MCP/skill names) |
| `OTEL_LOG_TOOL_CONTENT` | `1` to include tool I/O in traces (60 KB cap) |
| `OTEL_RESOURCE_ATTRIBUTES` | comma-separated `key=value` — no spaces allowed |

**Traces (beta):** set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`. Bash/PowerShell subprocesses inherit `TRACEPARENT` for distributed tracing.

**Cardinality toggles:** `OTEL_METRICS_INCLUDE_SESSION_ID` (true), `OTEL_METRICS_INCLUDE_VERSION` (false), `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (true).

**Metrics exported:**

| Metric | Unit |
| --- | --- |
| `claude_code.session.count` | count |
| `claude_code.lines_of_code.count` | count |
| `claude_code.pull_request.count` | count |
| `claude_code.commit.count` | count |
| `claude_code.cost.usage` | USD |
| `claude_code.token.usage` | tokens |
| `claude_code.code_edit_tool.decision` | count |
| `claude_code.active_time.total` | seconds |

**Events:** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`. All share `prompt.id` for correlating per-prompt activity (excluded from metrics to prevent unbounded cardinality).

**Retry exhaustion:** single `api_error` event is emitted after all retries; `attempt` attribute greater than `CLAUDE_CODE_MAX_RETRIES` (default `10`) means transient failure.

**Dynamic headers:** set `otelHeadersHelper` in settings.json to a script that prints `{"Authorization": "..."}`. Refreshed every 29 min by default (`CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

### Troubleshooting quick lookup

| Symptom | Fix |
| --- | --- |
| `command not found: claude` | Add `~/.local/bin` to PATH in rc file |
| Install script returns HTML | Download script first, then run — likely HTTP redirect issue |
| `curl: (56) Failure writing output` | Download script to file, then execute |
| `Killed` during Linux install | Add swap space (low-memory VPS) |
| TLS / SSL connect errors | Update CA certs or configure corporate CA |
| `irm` or `&&` not recognized (Windows) | Use correct shell (PowerShell vs CMD) |
| `Claude Code on Windows requires git-bash` | Install/configure Git Bash |
| `Error loading shared library` on Linux | musl vs glibc binary mismatch |
| `Illegal instruction` on Linux | Architecture mismatch |
| `dyld: cannot load` on macOS | Binary incompatibility |
| `App unavailable in region` | Country not supported |
| OAuth error / 403 Forbidden | Re-run `/login`; check org status |
| Multiple installs | Keep only `~/.local/bin/claude`; uninstall npm global / Homebrew cask |
| Auto-compaction thrashing | Clear context, switch to a new session |

**Diagnostic commands:** `which -a claude`, `claude --version`, `claude doctor`. Config lives under `~/.claude/` (settings, state, logs); reset with `rm -rf ~/.claude` (user-level) or remove project `.claude/`.

### Changelog and digests

- **`claude --version`** to check your installed version.
- **Changelog** mirrors github.com/anthropics/claude-code CHANGELOG.md (per-version bullet lists).
- **What's new** — weekly dev digest with runnable snippets; recent entries: Week 13 (Auto mode, computer use in Desktop, PR auto-fix on Web, transcript search, PowerShell tool, conditional `if` hooks — v2.1.83–v2.1.85) and Week 14 (computer use in CLI, `/powerup` lessons, flicker-free alt-screen, per-tool MCP size override to 500K, plugin executables on Bash PATH — v2.1.86–v2.1.91).

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — dashboards, contribution attribution, GitHub integration, ROI
- [Manage costs effectively](references/claude-code-costs.md) — `/cost`, workspace limits, TPM/RPM recommendations, token-reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel env vars, metrics, events, traces beta, backend guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) — install, PATH, TLS, WSL, permissions, auth, IDE integration, markdown issues
- [Changelog](references/claude-code-changelog.md) — full version-by-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — landing page for weekly dev digests
- [What's new — 2026 W13](references/claude-code-whats-new-2026-w13.md) — Week 13 digest (Auto mode, transcript search)
- [What's new — 2026 W14](references/claude-code-whats-new-2026-w14.md) — Week 14 digest (computer use in CLI, `/powerup`)

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new — 2026 W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new — 2026 W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
