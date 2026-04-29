---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards and contribution metrics, cost tracking and token reduction strategies, OpenTelemetry monitoring and observability, configuration debugging, troubleshooting runtime and installation errors, the error reference, the full version changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code deployments.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Claude Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage, spend tracking, per-user team insights |

**Contribution metrics** (Teams/Enterprise, public beta): connect GitHub via `claude.ai/admin-settings/claude-code`. Data appears within 24 hours with daily updates. PRs tagged `claude-code-assisted` in GitHub. Metrics are deliberately conservative; sessions 21 days before to 2 days after PR merge are considered. Zero Data Retention orgs see usage only.

**Key summary metrics**: PRs with CC, Lines of code with CC, PR%, Suggestion accept rate, Lines of code accepted.

### Cost management

**Average cost**: ~$13/developer/active day; $150–250/month. 90% of users stay below $30/active day.

**Track costs**: run `/usage` for current session estimate. Authoritative billing: [platform.claude.com/usage](https://platform.claude.com/usage).

**Rate limit recommendations by team size (Anthropic API)**:

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Token reduction strategies**:

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` to start fresh; `/compact Focus on X` to summarize selectively |
| Choose right model | `/model` to switch; Sonnet for most tasks, Opus for complex reasoning |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools (`gh`, `aws`) |
| Use skills over CLAUDE.md | Move workflow-specific instructions to skills (load on demand vs. always) |
| Adjust effort/thinking | `/effort` or `MAX_THINKING_TOKENS=8000` for simpler tasks |
| Delegate verbose ops | Use subagents so large output stays in their context |
| Write specific prompts | Target specific files/functions instead of broad requests |
| Plan before acting | Shift+Tab for plan mode to avoid expensive re-work |

**Agent teams** use ~7x more tokens than standard sessions; keep teams small and tasks self-contained.

**Background token usage**: ~$0.04/session for conversation summarization and command processing.

### OpenTelemetry monitoring

**Minimum setup**:
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # or: prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp             # or: console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key configuration variables**:

| Variable | Purpose | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics destination | — |
| `OTEL_LOGS_EXPORTER` | Events/logs destination | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval in ms | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval in ms | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt text in events | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool params, bash commands, skill names | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in spans (requires tracing) | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include `session.id` attribute | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include `user.account_uuid` attribute | true |

**Traces (beta)**: set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request` / `claude_code.tool` → `claude_code.tool.blocked_on_user` + `claude_code.tool.execution`.

**Exported metrics**:

| Metric | Unit |
| :--- | :--- |
| `claude_code.session.count` | count |
| `claude_code.lines_of_code.count` | count |
| `claude_code.pull_request.count` | count |
| `claude_code.commit.count` | count |
| `claude_code.cost.usage` | USD |
| `claude_code.token.usage` | tokens |
| `claude_code.code_edit_tool.decision` | count |
| `claude_code.active_time.total` | seconds |

**Key events**: `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.skill_activated`, `claude_code.plugin_installed`.

Use `prompt.id` (UUID v4) to correlate all events from a single user prompt.

**Admin deployment** (managed settings):
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector.example.com:4317"
  }
}
```

Dynamic auth headers: set `otelHeadersHelper` in `.claude/settings.json` pointing to a script that outputs JSON `{"Authorization": "Bearer token"}`. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

Multi-team segmentation: `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` — no spaces in values.

### Debug your configuration

**Diagnostic commands**:

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system, memory, skills, MCP, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Invalid keys, schema errors, installation health |
| `/status` | Active settings sources, managed settings status |

**Common configuration issues**:

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase matcher, e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | In a standalone `hooks.json` file | Define under `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Settings value seems ignored | Same key in `settings.local.json` | Local overrides project overrides user |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Skill appears but Claude never invokes it | `disable-model-invocation: true` or mismatched description | Check badge in `/skills` |
| Subdirectory CLAUDE.md ignored | Subdirectory files load on demand | Loads when Claude reads a file in that directory with Read tool |
| MCP servers in `.mcp.json` never load | File inside `.claude/` | Project MCP config goes at repo root as `.mcp.json` |
| MCP server fails from some directories | Relative path in `command` or `args` | Use absolute paths for local scripts |
| `Bash(rm *)` deny rule doesn't block variants | Prefix rules match literal command string | Add patterns for each variant or use a PreToolUse hook |

Settings precedence: `managed` > `local` (`.claude/settings.local.json`) > `project` (`.claude/settings.json`) > `user` (`~/.claude/settings.json`). CLI flags and env vars add another override layer.

### Troubleshooting quick guide

| Symptom | Go to |
| :--- | :--- |
| `command not found`, PATH, `EACCES`, TLS install errors | Troubleshoot installation and login |
| Login loops, OAuth errors, `403 Forbidden`, cloud credentials | Login and authentication section |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529`, `429`, validation errors | Error reference |
| High CPU/memory, slow responses, search not finding files | Performance and stability |

**Performance**:
- High memory: use `/compact` regularly, close and restart between major tasks, run `/heapdump` to diagnose
- Auto-compact thrashing (`Autocompact is thrashing: the context refilled to the limit...`): read file in chunks, run `/compact` with a focus, or use a subagent
- Hangs: Ctrl+C to cancel; `claude --resume` to pick up session after restart
- Search issues (ripgrep): install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`

**Install locations**: `~/.local/bin/claude` (macOS/Linux native), `%USERPROFILE%\.local\bin\claude.exe` (Windows).

### Error reference quick lookup

**Automatic retries**: transient failures are retried up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000 ms).

| Error | Category | Action |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Check status.claude.com; retry |
| `API Error: Repeated 529 Overloaded` | Server | Wait; `/model` to switch to less-loaded model |
| `Request timed out` | Server | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session/weekly limit` | Usage limit | Wait for reset; `/extra-usage` to buy more |
| `Request rejected (429)` | Usage limit | Check rate limits; reduce concurrency |
| `Credit balance is too low` | Usage limit | Add credits at Console; enable auto-reload |
| `Not logged in · Please run /login` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for typos or stale key; run `env \| grep ANTHROPIC` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; run `/login` |
| `OAuth token revoked / expired` | Auth | Run `/login` (or `/logout` then `/login`) |
| `Unable to connect to API` | Network | Check proxy (`HTTPS_PROXY`); firewall rules for `api.anthropic.com` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | Run `/compact` or `/clear`; disable unused MCP servers |
| `Request too large (max 30 MB)` | Request | Esc×2 to step back; reference large files by path |
| `There's an issue with the selected model` | Request | Run `/model` to pick available model; use alias like `sonnet` |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `API Error: 400 due to tool use concurrency` | Request | Run `/rewind` or Esc×2 to step back |

**Response quality checklist**: run `/model` (confirm model), `/effort` (check reasoning level), `/context` (check window fullness), `/doctor` (CLAUDE.md size, subagent defs).

### What's new (weekly digests)

Recent highlights:

| Week | Dates | Key features |
| :--- | :--- | :--- |
| Week 17 | Apr 20–24, 2026 | `/ultrareview` research preview, session recap (`/recap`), custom themes (`/theme`), Claude Code on the web redesign |
| Week 16 | Apr 13–17, 2026 | Claude Opus 4.7 (default on Max/Team Premium), `xhigh` effort level, Routines on web, `/ultrareview` cloud review, native binaries |
| Week 15 | Apr 6–10, 2026 | Ultraplan (cloud plan editor), Monitor tool for live log streaming, `/loop`, `/team-onboarding`, `/autofix-pr` |
| Week 14 | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview), `/powerup` lessons, flicker-free rendering |
| Week 13 | Mar 23–27, 2026 | Auto mode research preview, computer use in Desktop, PR auto-fix on web, transcript search with `/`, native PowerShell tool, conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — usage dashboards for Teams/Enterprise and API customers, contribution metrics setup, PR attribution, leaderboard, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, workspace spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry quick start, all configuration variables, metrics reference, events reference, traces (beta), span hierarchy and attributes, backend considerations
- [Debug your configuration](references/claude-code-debug-your-config.md) — `/context`, `/doctor`, `/hooks`, `/mcp`, `/status` commands, common causes table, settings precedence
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, auto-compact thrashing, hangs, search issues, WSL performance, ripgrep fix
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH issues, TLS/SSL errors, network/proxy setup, Windows-specific issues, WSL npm errors, login and OAuth errors, cloud provider credentials
- [Error reference](references/claude-code-errors.md) — all runtime error messages with causes and recovery steps, automatic retry behavior
- [Changelog](references/claude-code-changelog.md) — full release notes for every version
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index (weeks 13–17)
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, conditional hooks
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, `/powerup`, flicker-free rendering
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/team-onboarding`
- [Week 16 digest](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, `xhigh` effort, Routines, native binaries
- [Week 17 digest](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes, web redesign

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 digest: https://code.claude.com/docs/en/whats-new/2026-w15.md
- Week 16 digest: https://code.claude.com/docs/en/whats-new/2026-w16.md
- Week 17 digest: https://code.claude.com/docs/en/whats-new/2026-w17.md
