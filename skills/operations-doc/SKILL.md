---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating Claude Code in production: analytics, cost management, monitoring with OpenTelemetry, troubleshooting, and the changelog/what's-new releases.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
|------|--------------|---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user insights |

**Contribution metrics setup (Teams/Enterprise):**
1. GitHub admin installs the Claude GitHub app at github.com/apps/claude
2. Claude Owner enables analytics at claude.ai/admin-settings/claude-code
3. Enable the "GitHub analytics" toggle and authenticate
- Data appears within 24 hours; daily updates thereafter
- Not available with Zero Data Retention enabled

**Key contribution metric definitions:**
- `PRs with CC`: merged PRs containing at least one Claude-assisted line
- `Lines of code with CC`: effective lines (>3 chars, non-trivial) across merged PRs
- Attribution window: sessions 21 days before to 2 days after PR merge
- Code rewritten >20% by developer is not attributed to Claude Code

### Cost Management

| Strategy | Command/Setting |
|----------|----------------|
| Check session usage | `/usage` |
| Clear context between tasks | `/clear` |
| Add compact instructions | `/compact Focus on code samples` |
| Switch model | `/model` |
| Check context breakdown | `/context` |
| Set effort level | `/effort` |
| Disable unused MCP servers | `/mcp disable <name>` |
| Set usage credit limit (Pro/Max) | `/usage-credits` |

**Average enterprise costs:** ~$13/developer/active day; $150–250/month. 90% of users stay below $30/active day.

**TPM/RPM recommendations per user:**

| Team size | TPM per user | RPM per user |
|-----------|-------------|-------------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Agent team costs:** ~7x standard session tokens. Use Sonnet for teammates, keep teams small, clean up when done.

### Monitoring with OpenTelemetry

**Minimum setup:**
```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp          # or: prometheus, console, none
OTEL_LOGS_EXPORTER=otlp             # or: console, none
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key configuration variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s) | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s) | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content in logs | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool params/commands in logs | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom key=value attributes (no spaces); appear as metric datapoint labels | — |

**Metrics cardinality control:**

| Variable | Default | Purpose |
|----------|---------|---------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include `session.id` on metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include `user.account_uuid`/`user.account_id` |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include `app.version` |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | `false` | Include `app.entrypoint` |
| `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES` | `true` | Include `OTEL_RESOURCE_ATTRIBUTES` as datapoint labels |

**Distributed tracing (beta):** requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` plus `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request`, `claude_code.tool` (with `blocked_on_user` and `execution` children). Active `TRACEPARENT` propagated to Bash subprocesses and HTTP MCP requests.

**Available metrics:**

| Metric | Description | Unit |
|--------|-------------|------|
| `claude_code.session.count` | Sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Accept/reject decisions | count |
| `claude_code.active_time.total` | Active time | seconds |

**Key events (via `OTEL_LOGS_EXPORTER`):**

| Event | When |
|-------|------|
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission decided (accept/reject) |
| `claude_code.api_request` | Each API call to Claude |
| `claude_code.api_error` | API call fails after retries |
| `claude_code.api_refusal` | API returns `stop_reason: "refusal"` |
| `claude_code.api_request_body` | Full request JSON (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_response_body` | Full response JSON (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_retries_exhausted` | API request fails after multiple attempts |
| `claude_code.permission_mode_changed` | Permission mode changes (e.g. Shift+Tab) |
| `claude_code.auth` | Login or logout completes |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects/fails |
| `claude_code.compaction` | Context compaction completes |
| `claude_code.plugin_installed` | Plugin finishes installing |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` | Hook event begins |
| `claude_code.hook_execution_complete` | Hook event finishes |
| `claude_code.hook_plugin_metrics` | Official-marketplace plugin hook emits per-invocation metrics |
| `claude_code.at_mention` | `@`-mention resolved in a prompt |
| `claude_code.feedback_survey` | Session quality survey shown or answered |
| `claude_code.internal_error` | Unexpected internal error caught |

**`prompt.id` attribute** links all events from a single user prompt (user_prompt + api_request(s) + tool_result(s)) — use for event-level audit trails.

**Standard attributes on every metric/event:** `session.id`, `user.id`, `user.email`, `user.account_uuid`, `organization.id`, `terminal.type`, `app.version` (opt-in)

**Admin deployment (managed settings):**
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector.example.com:4317"
  }
}
```

**SIEM audit export (events only, full tool detail):**
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_LOG_TOOL_DETAILS": "1",
    "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT": "https://siem.example.com:4318/v1/logs"
  }
}
```

**Security audit event map:**

| Signal | Event | Key attributes |
|--------|-------|---------------|
| Tool allowed/denied | `tool_decision` | `decision`, `source`, `tool_name` |
| Permission mode escalation | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Login/logout | `auth` | `action`, `success` |
| MCP server connect/fail | `mcp_server_connection` | `status`, `server_name` |
| Plugin installed | `plugin_installed` | `plugin.name`, `marketplace.is_official` |
| Commands run and files touched | `tool_result` / `tool_decision` (with `OTEL_LOG_TOOL_DETAILS=1`) | `tool_parameters`, `tool_input` |

### Troubleshooting Quick Triage

| Symptom | Go to |
|---------|-------|
| `command not found`, PATH, `EACCES`, TLS install errors | troubleshoot-install |
| OAuth errors, 403 Forbidden, org disabled | troubleshoot-install (login section) |
| Settings not applying, hooks not firing, MCP not loading | debug-your-config |
| `API Error: 5xx`, `529`, `429`, request validation | errors reference |
| `model not found` | errors reference (model section) |
| High CPU/memory, hangs, search broken | troubleshooting (performance section) |

**First step:** run `/doctor` inside Claude Code for automated diagnostics. If `claude` won't start, run `claude doctor` from the shell. Use `--safe-mode` (v2.1.169+) to start with all customizations disabled for troubleshooting.

**Common configuration gotchas:**

| Symptom | Cause | Fix |
|---------|-------|-----|
| Hook never fires | `matcher` is a JSON array | Use a string with `\|` separator: `"Edit\|Write"` |
| Hook never fires | Lowercase tool name in matcher | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Settings key ignored | Set in `~/.claude.json` | Move `permissions`/`hooks`/`env` to `~/.claude/settings.json` |
| Skill missing from `/skills` | Flat `.md` file, not a folder | Use `.claude/skills/name/SKILL.md` |
| MCP server not loading | `.mcp.json` inside `.claude/` | Place `.mcp.json` at repo root |
| MCP server needs approval | One-time prompt was dismissed | Run `/mcp` to approve |
| `settings.json` value ignored | Same key in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Subdirectory `CLAUDE.md` ignored | Loads on-demand, not at startup | Loads when Claude reads a file in that directory |

**Diagnostic commands:**

| Command | Shows |
|---------|-------|
| `/context` | Everything in context window by category |
| `/memory` | Which CLAUDE.md files loaded |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/doctor` | Config diagnostics, schema errors |
| `/status` | Active settings sources |
| `/debug [issue]` | Enable debug logging + diagnose |
| `/skills` | Available skills from all sources |
| `/permissions` | Resolved allow/deny rules |

**Test with clean config:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

### Error Reference Quick Lookup

| Error | Category | Fix |
|-------|----------|-----|
| `API Error: 500` | Server | Check status.claude.com; retry |
| `API Error: 529 Overloaded` | Server | Retry; try `/model` to switch |
| `Request timed out` | Server | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `Auto mode classifier transcript exceeded context window` | Server | `/compact` to reduce context; approve manually |
| `You've hit your session limit` | Usage | Wait for reset; `/usage` to check; `/usage-credits` to buy more |
| `Server is temporarily limiting requests` | Usage | Wait briefly; retry |
| `Request rejected (429)` | Rate limit | Check rate limits; reduce concurrency |
| `Credit balance is too low` | Billing | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check key; `env \| grep ANTHROPIC` for stale keys |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; use subscription login |
| `Your organization has disabled Claude subscription access` | Auth | Contact admin or use API key |
| `Routines are disabled by your organization's policy` | Auth | Ask admin to enable at claude.ai/admin-settings/claude-code |
| `OAuth token revoked` | Auth | Run `/login` (or `/logout` then `/login`) |
| `Unable to connect to API` | Network | Check proxy; set `HTTPS_PROXY`; verify `api.anthropic.com` reachable |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `403` with `x-deny-reason: host_not_allowed` | Network | In cloud session: update environment to allow the domain |
| `Prompt is too long` | Request | `/compact`; `/clear`; disable unused MCP servers |
| `Error during compaction: Conversation too long` | Request | Press Esc twice to step back turns, then `/compact` |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| `There's an issue with the selected model` | Request | Run `/model` to pick valid model |
| `thinking.type.enabled is not supported for this model` | Request | Run `claude update`; needs v2.1.111+ for Opus 4.7, v2.1.154+ for Opus 4.8 |
| `max_tokens must be greater than thinking.budget_tokens` | Request | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |

**Retry behavior:** Claude Code auto-retries server errors, 529, 429, and timeouts up to 10 times with exponential backoff. Override with `CLAUDE_CODE_MAX_RETRIES` (default: 10) and `API_TIMEOUT_MS` (default: 600000 ms).

**For poor response quality (no error shown):** run `/model` to confirm model, `/effort` to check reasoning level, `/context` to check window fullness, `/doctor` to flag oversized memory files. Use `/rewind` (Esc twice) to step back and rephrase rather than correcting in-thread.

### Recent Releases (What's New)

| Week | Dates | Versions | Highlights |
|------|-------|---------|-----------|
| W22 | May 25–29, 2026 | v2.1.150–v2.1.157 | Claude Opus 4.8 as new default; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8 |
| W21 | May 18–22, 2026 | v2.1.143–v2.1.149 | Auto mode on Pro plan; `/usage` limit breakdown by skill/plugin; `/code-review`; background sessions in `/resume` |
| W20 | May 11–15, 2026 | v2.1.139–v2.1.142 | Agent view (`claude agents`); `/goal` for multi-turn completion; fast mode on Opus 4.7 by default; Rewind menu |
| W19 | May 4–8, 2026 | v2.1.128–v2.1.136 | Plugin zip/URL loading; `worktree.baseRef`; auto mode hard deny rules; hooks see `effort.level` |
| W18 | Apr 27–May 1, 2026 | v2.1.120–v2.1.126 | Windows without Git Bash (PowerShell as shell tool); `claude ultrareview`; `claude project purge` |
| W17 | Apr 20–24, 2026 | v2.1.114–v2.1.119 | `/ultrareview` public research preview; session recap; custom themes; Claude Code on web redesign |
| W16 | Apr 13–17, 2026 | v2.1.105–v2.1.113 | Claude Opus 4.7 as new default; `xhigh` effort level; Routines on web; mobile push notifications; native binaries |
| W15 | Apr 6–10, 2026 | v2.1.92–v2.1.101 | Ultraplan early preview; Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| W14 | Mar 30–Apr 3, 2026 | v2.1.86–v2.1.91 | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override |
| W13 | Mar 23–27, 2026 | v2.1.83–v2.1.85 | Auto mode research preview; computer use in Desktop; PR auto-fix on web; transcript search with `/` |

**Notable recent changelog entries (post-W22):**

| Version | Date | Key changes |
|---------|------|------------|
| 2.1.169 | Jun 8, 2026 | `--safe-mode` / `CLAUDE_CODE_SAFE_MODE` disables all customizations; `/cd` command; `disableBundledSkills` setting; many background-agent and MCP policy fixes |
| 2.1.166 | Jun 6, 2026 | `fallbackModel` setting (up to 3 fallback models); glob support in deny rule tool-name position; `MAX_THINKING_TOKENS=0` disables thinking on models that think by default |
| 2.1.163 | Jun 4, 2026 | `requiredMinimumVersion`/`requiredMaximumVersion` managed settings; `/plugin list` command; Stop/SubagentStop hooks can return `additionalContext` |
| 2.1.161 | Jun 2, 2026 | `OTEL_RESOURCE_ATTRIBUTES` values now included as metric datapoint labels; parallel tool calls: failed Bash no longer cancels batch |
| 2.1.160 | Jun 2, 2026 | Prompt before writing shell startup files; `acceptEdits` mode now prompts before build-tool config files; renamed dynamic-workflow trigger from `workflow` to `ultracode` |

For the full version-by-version changelog, see [references/claude-code-changelog.md](references/claude-code-changelog.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — Usage dashboards, contribution metrics with GitHub integration, PR attribution, ROI measurement
- [Costs](references/claude-code-costs.md) — Cost tracking with `/usage`, team spend limits, rate limit recommendations, token reduction strategies
- [Monitoring Usage](references/claude-code-monitoring-usage.md) — Full OpenTelemetry configuration reference: metrics, events, traces, SIEM integration
- [Debug Your Config](references/claude-code-debug-your-config.md) — Diagnose CLAUDE.md, settings, hooks, MCP, and skills not taking effect
- [Troubleshooting](references/claude-code-troubleshooting.md) — Performance, memory, search, and stability issues once Claude Code is running
- [Troubleshoot Install](references/claude-code-troubleshoot-install.md) — Installation failures, PATH issues, TLS errors, and authentication problems
- [Error Reference](references/claude-code-errors.md) — Runtime error messages with meanings and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version-by-version release notes
- [What's New Index](references/claude-code-whats-new-index.md) — Weekly digest index linking to all weekly summaries
- [What's New W13](references/claude-code-whats-new-2026-w13.md) — Week of March 23–27, 2026
- [What's New W14](references/claude-code-whats-new-2026-w14.md) — Week of March 30–April 3, 2026
- [What's New W15](references/claude-code-whats-new-2026-w15.md) — Week of April 6–10, 2026
- [What's New W16](references/claude-code-whats-new-2026-w16.md) — Week of April 13–17, 2026
- [What's New W17](references/claude-code-whats-new-2026-w17.md) — Week of April 20–24, 2026
- [What's New W18](references/claude-code-whats-new-2026-w18.md) — Week of April 27–May 1, 2026
- [What's New W19](references/claude-code-whats-new-2026-w19.md) — Week of May 4–8, 2026
- [What's New W20](references/claude-code-whats-new-2026-w20.md) — Week of May 11–15, 2026
- [What's New W21](references/claude-code-whats-new-2026-w21.md) — Week of May 18–22, 2026
- [What's New W22](references/claude-code-whats-new-2026-w22.md) — Week of May 25–29, 2026

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring Usage: https://code.claude.com/docs/en/monitoring-usage.md
- Debug Your Config: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot Install: https://code.claude.com/docs/en/troubleshoot-install.md
- Error Reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New Index: https://code.claude.com/docs/en/whats-new/index.md
- What's New W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's New W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's New W20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's New W21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's New W22: https://code.claude.com/docs/en/whats-new/2026-w22.md
