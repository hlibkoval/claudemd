---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, OpenTelemetry monitoring, troubleshooting, configuration debugging, error reference, and what's new.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Includes |
| :--- | :------------ | :------- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

Contribution metrics require GitHub app installation + GitHub analytics toggle enabled. Not available with Zero Data Retention.

### Cost commands

| Command | What it does |
| :------ | :----------- |
| `/usage` | Session token usage, cost estimate, plan limits breakdown by skill/plugin/MCP |
| `/usage-credits` | Buy extra credits (Pro/Max) or request from admin (Team/Enterprise) |
| `/compact [focus]` | Summarize conversation to free context |
| `/clear` | Start fresh session |
| `/model` | Switch model (Sonnet for most tasks; Opus for complex reasoning) |
| `/effort` | Adjust reasoning level to balance cost vs. quality |
| `/context` | See what's consuming the context window |

### Average API cost benchmarks

| Metric | Value |
| :----- | :---- |
| Average per active developer per day | ~$13 |
| Typical monthly per developer | $150–250 |
| 90th percentile daily cap | <$30/active day |

### Rate limit recommendations (API)

| Team size | TPM per user | RPM per user |
| :-------- | :----------- | :----------- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

### OpenTelemetry quick start

Enable telemetry with these environment variables:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

### Key OTel environment variables

| Variable | Description | Default |
| :------- | :---------- | :------ |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Master enable switch | off |
| `OTEL_METRICS_EXPORTER` | Metrics backend(s) | — |
| `OTEL_LOGS_EXPORTER` | Logs/events backend(s) | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics flush interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs flush interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt text in events | off |
| `OTEL_LOG_TOOL_DETAILS` | Include Bash commands, MCP names, skill names | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Log full Messages API request/response JSON | off |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Enable distributed tracing (beta) | off |

### Available OTel metrics

| Metric | Description | Unit |
| :----- | :---------- | :--- |
| `claude_code.session.count` | Sessions started | count |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.lines_of_code.count` | Lines added/removed | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.code_edit_tool.decision` | Accept/reject decisions | count |
| `claude_code.active_time.total` | Active usage time | s |

### OTel event types

`user_prompt` · `tool_result` · `tool_decision` · `api_request` · `api_error` · `api_refusal` · `api_request_body` · `api_response_body` · `permission_mode_changed` · `auth` · `mcp_server_connection` · `internal_error` · `plugin_installed` · `plugin_loaded` · `skill_activated` · `at_mention` · `api_retries_exhausted` · `hook_registered` · `hook_execution_start` · `hook_execution_complete` · `hook_plugin_metrics` · `compaction` · `feedback_survey`

All events share standard attributes: `session.id`, `user.id`, `user.email`, `user.account_uuid`, `organization.id`, `terminal.type`, `app.version`, `app.entrypoint`.

### Tracing span hierarchy (beta)

```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    ├── claude_code.tool.execution
    └── (Agent tool) subagent spans
```

Enable with `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` plus an OTel traces exporter.

### Troubleshooting symptom index

| Symptom | Go to |
| :------ | :---- |
| `command not found`, PATH issues, `EACCES`, TLS install errors | Troubleshoot installation and login |
| Login loops, OAuth errors, `403 Forbidden`, cloud credentials | Troubleshoot installation and login — login section |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529`, `429`, validation errors | Error reference |
| `model not found` or access errors | Error reference — model section |
| High CPU/memory, hangs, search not finding files | Troubleshooting — performance section |

Run `/doctor` for an automated check of installation, settings, MCP, and context.

### Debug commands reference

| Command | Shows |
| :------ | :---- |
| `/context` | Everything in the context window by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics, schema errors, installation health |
| `/status` | Active settings sources |
| `/debug [issue]` | Enables debug logging for the session |

### Common config pitfalls

| Symptom | Cause | Fix |
| :------ | :---- | :-- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|` separating tool names |
| Hook never fires | Lowercase matcher like `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook in wrong file | Defined in standalone file | Put hooks under `"hooks"` key in `settings.json` |
| Settings.json key ignored | Overridden by `settings.local.json` | Check local scope; it wins over project scope |
| Skill not in `/skills` | File at `.claude/skills/name.md` not in a folder | Use `.claude/skills/name/SKILL.md` |
| MCP server from `.mcp.json` never loads | Approval prompt was dismissed | Run `/mcp` and approve |
| MCP env vars missing | Set in `settings.json env`, not per-server | Set `env` inside `.mcp.json` for the server |

### Error recovery quick reference

| Error | Action |
| :---- | :----- |
| `529 Overloaded` | Wait, then retry; run `/model` to switch models |
| `429 Request rejected` | Check rate limits; reduce concurrency |
| `You've hit your session limit` | Wait for reset or run `/usage-credits` |
| `Prompt is too long` | Run `/compact` or `/clear`; disable unused MCP |
| `Error during compaction: Conversation too long` | Press Esc twice to step back, then `/compact` |
| `OAuth token revoked` | Run `/login` |
| `Invalid API key` | Check key in Console; unset stale `ANTHROPIC_API_KEY` |
| `model not found` | Run `/model` to pick valid model; check `ANTHROPIC_MODEL` env var |
| `Extra inputs are not permitted` | Configure proxy to forward `anthropic-beta` header |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS` to your CA bundle |

Claude Code retries transient failures up to 10 times (configurable via `CLAUDE_CODE_MAX_RETRIES`) before surfacing an error.

### Clean-config test

```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

Bypasses all user and project settings. Start with `claude --safe-mode` to disable customizations (CLAUDE.md, skills, plugins, hooks, MCP) while keeping auth and permissions.

### What's new (recent highlights)

| Week | Highlights |
| :--- | :--------- |
| W22 (May 25–29) | Claude Opus 4.8 default; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8 at $10/$50/MTok |
| W21 (May 18–22) | Auto mode on Pro; `/usage` skill/plugin/MCP breakdown; `/code-review` command; background sessions in `/resume` |
| W20 (May 11–15) | `claude agents` view; `/goal` command; fast mode on Opus 4.7; Rewind "Summarize up to here" |
| W19 (May 4–8) | Plugins from `.zip`/URL; `worktree.baseRef`; auto mode hard deny; hooks see effort level |
| W18 (Apr 27–May 1) | Windows without Git Bash (PowerShell tool); `claude ultrareview`; paste PR URL into `/resume` |
| W17 (Apr 20–24) | `/ultrareview` public preview; session recap; custom themes; Claude Code on the web redesign |
| W16 (Apr 13–17) | Claude Opus 4.7 default; `xhigh` effort; Routines on web; mobile push notifications; native binaries |
| W15 (Apr 6–10) | Ultraplan early preview; Monitor tool; `/loop` self-pacing |
| W14 (Mar 30–Apr 3) | Computer use in CLI research preview |
| W13 (Mar 23–27) | Auto mode research preview; native PowerShell tool; conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API customers, contribution metrics setup, PR attribution
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking, spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Full OTel setup, all metrics and events, traces beta, security audit, SIEM integration
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, hangs, auto-compact thrashing, search issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, TLS, auth errors, WSL, platform-specific install issues
- [Debug your configuration](references/claude-code-debug-your-config.md) — Inspecting loaded context, settings resolution, hook/MCP debugging, clean-config tests
- [Error reference](references/claude-code-errors.md) — All runtime error messages with recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version history
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index linking all weekly highlights
- [What's new W13–W22](references/claude-code-whats-new-2026-w13.md) — Individual weekly digests (w13 through w22)

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new W20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new W21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new W22: https://code.claude.com/docs/en/whats-new/2026-w22.md
