---
name: operations-doc
description: Complete official documentation for operating Claude Code — analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting install and runtime issues, release changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running Claude Code in production: measuring usage, controlling spend, monitoring fleets with OpenTelemetry, fixing common problems, and tracking what's new across releases.

## Quick Reference

### Analytics dashboards

| Plan | URL | Includes |
|---|---|---|
| Claude for Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (with GitHub app), leaderboard, CSV export |
| API (Claude Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

Contribution metrics are public beta; require GitHub app install and Owner role; unavailable with Zero Data Retention.

### Cost tracking commands

| Command | Purpose |
|---|---|
| `/cost` | Token usage + local dollar estimate for the current session (API users) |
| `/stats` | Usage patterns (for Pro/Max subscribers where `/cost` is not billing-relevant) |
| Claude Console → Usage | Authoritative billing |

Enterprise average: ~$13/developer/active day, ~$150–250/developer/month; 90% of users stay under $30/active day.

### Rate limit recommendations (per user)

| Team size | TPM | RPM |
|---|---|---|
| 1–5 | 200k–300k | 5–7 |
| 6–20 | 150k–250k | 4–6 |
| 21–50 | 100k–200k | 3–5 |
| 50+ | 80k–150k | 2–4 |

(See the full doc for exact values; tune based on observed P95.)

### Token-reduction levers

| Lever | How |
|---|---|
| Manage context proactively | `/clear` between tasks, `/compact <instructions>`, `/btw` for side questions |
| Choose the right model | Haiku for triage, Sonnet for default, Opus for hard planning; set via `/model` |
| Reduce MCP overhead | Disable unused servers, tighten tool allowlists, use per-tool result-size overrides |
| Code-intelligence plugins | Typed-language plugins let Claude jump by symbol instead of re-reading files |
| Offload to hooks and skills | Deterministic work in hooks; move CLAUDE.md prose into on-demand skills |
| Tune extended thinking | `/effort` down, `CLAUDE_CODE_EFFORT_LEVEL`, `MAX_THINKING_TOKENS` |
| Delegate to subagents | Long exploration in a separate context that returns a summary |
| Agent team costs | Cap participants, use lighter models for reviewers |

### OpenTelemetry quick start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer ..."
```

Default export intervals: 60s metrics, 5s logs. Configure for all users via the managed settings file.

### Key telemetry env vars

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_ENABLE_TELEMETRY=1` | Required to enable export |
| `OTEL_METRICS_EXPORTER` / `OTEL_LOGS_EXPORTER` | Choose exporters (comma-separated) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` / `_PROTOCOL` | OTLP endpoint and protocol (grpc, http/json, http/protobuf) |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers (e.g. `Authorization=Bearer ...`) |
| `OTEL_METRIC_EXPORT_INTERVAL` / `OTEL_LOGS_EXPORT_INTERVAL` | Export cadence in ms |
| `OTEL_LOG_USER_PROMPTS` / `OTEL_LOG_TOOL_DETAILS` / `OTEL_LOG_TOOL_CONTENT` | Opt-in verbose content logging |
| `OTEL_METRICS_INCLUDE_SESSION_ID` / `_VERSION` / `_ACCOUNT_UUID` | Cardinality controls |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER` | Enable distributed tracing (beta) |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | `delta` (default) or `cumulative` |

### Core metrics

| Metric | Meaning | Unit |
|---|---|---|
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Token consumption by type | tokens |
| `claude_code.api.request.count` / `.duration` | API call volume and latency | count / ms |

Standard attributes: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

### Installation troubleshooting quick lookup

| Symptom | Fix |
|---|---|
| `command not found: claude` | Fix PATH; verify install directory is exported |
| `syntax error near unexpected token '<'` | Install script returned HTML — retry with correct URL |
| `curl: (56) Failure writing output` | Download script first, then run it |
| `Killed` during install on Linux | Add swap space (low-memory host) |
| `TLS connect error` / `unable to get local issuer certificate` | Update CA certs or configure corporate CA |
| `Failed to fetch version` | Check network/proxy connectivity to `storage.googleapis.com` |
| `irm is not recognized` / `'bash' is not recognized` | Use the right shell's install command on Windows |
| `Claude Code on Windows requires git-bash` | Install/configure Git Bash |
| `Error loading shared library` | Wrong binary variant (musl vs glibc) |
| `Illegal instruction` on Linux | Architecture mismatch |
| `dyld: cannot load` / `Abort trap` on macOS | Binary incompatibility |
| `App unavailable in region` | Country not supported |

### Runtime troubleshooting

| Area | Topics covered |
|---|---|
| Permissions & auth | Repeated permission prompts, OAuth errors, 403 Forbidden, model not found, disabled org, WSL2 OAuth, expired tokens |
| Config | `~/.claude/` locations, resetting configuration |
| Performance | High CPU/memory, auto-compaction thrashing, hangs, slow search (WSL) |
| IDE | JetBrains detection on WSL2, Escape-key in JetBrains terminals, Windows IDE reports |
| Formatting | Missing code-block language tags, inconsistent spacing |

### Release tracking

| Resource | Scope |
|---|---|
| Changelog | Full per-version notes, generated from GitHub `CHANGELOG.md`. Run `claude --version` to check your installed version. |
| What's new index | Weekly digests with demos, code, and feature context |
| Weekly digests (2026-w13 → w15) | Auto mode, computer use (Desktop + CLI), PR auto-fix, transcript search, PowerShell tool, `/powerup`, flicker-free rendering, Ultraplan, Monitor tool, self-pacing `/loop`, `/team-onboarding`, `/autofix-pr` |

### Interpreting telemetry

| Goal | Approach |
|---|---|
| Usage monitoring | Track `session.count`, active users via `user.id`, per-team segmentation via resource attributes |
| Cost monitoring | Aggregate `cost.usage` and `token.usage`; alert on spikes |
| Detect retry exhaustion | Watch API error events and request-duration tails |
| Alerting | Per-team thresholds, break-out by `terminal.type` or `app.version` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Dashboards for Team/Enterprise and API customers; GitHub-app setup for contribution metrics; CSV export.
- [Manage costs effectively](references/claude-code-costs.md) — `/cost` command, workspace spend limits, per-user TPM/RPM recommendations, token-reduction strategies, background token usage.
- [Monitoring](references/claude-code-monitoring-usage.md) — Full OpenTelemetry reference: env vars, metrics, events, traces (beta), cardinality controls, multi-team resource attributes, backend considerations, privacy.
- [Troubleshooting](references/claude-code-troubleshooting.md) — Symptom-to-fix table plus detailed guides for installation, permissions, auth, configuration, performance, IDE integration, and markdown formatting.
- [Changelog](references/claude-code-changelog.md) — Per-version release notes for every Claude Code version, generated from the GitHub CHANGELOG.
- [What's new index](references/claude-code-whats-new-index.md) — Index of weekly dev digests summarizing the features most likely to change how you work.
- [Week 13 digest (Mar 23–27, 2026)](references/claude-code-whats-new-2026-w13.md) — Auto mode, Desktop computer use, cloud PR auto-fix, transcript search, PowerShell tool, conditional `if` hooks.
- [Week 14 digest (Mar 30 – Apr 3, 2026)](references/claude-code-whats-new-2026-w14.md) — CLI computer use, `/powerup` lessons, flicker-free rendering, per-tool MCP result-size overrides, plugin executables on PATH.
- [Week 15 digest (Apr 6–10, 2026)](references/claude-code-whats-new-2026-w15.md) — Ultraplan cloud planning, the Monitor tool, self-pacing `/loop`, `/team-onboarding`, terminal-launched `/autofix-pr`.

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new Week 13 (2026): https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new Week 14 (2026): https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new Week 15 (2026): https://code.claude.com/docs/en/whats-new/2026-w15.md
