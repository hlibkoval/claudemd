---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating Claude Code at scale: analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, configuration debugging, runtime error reference, and the changelog / weekly what's new digests.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend, per-user team insights |

Contribution metrics require installing the Claude GitHub app and enabling the GitHub analytics toggle at `claude.ai/admin-settings/claude-code`. Data appears within 24 hours.

### Key Analytics Metrics

| Metric | Description |
|:-------|:------------|
| PRs with CC | Merged PRs containing at least one Claude Code–assisted line |
| Lines of code with CC | Lines in merged PRs written with Claude Code assistance |
| Suggestion accept rate | % of Edit/Write/NotebookEdit decisions accepted |
| Lines of code accepted | Total accepted lines (excludes rejected; doesn't track deletions) |

PR attribution window: sessions from 21 days before to 2 days after merge date. Code substantially rewritten by developers (>20% diff) is not attributed.

### Cost Tracking

| Command | Purpose |
|:--------|:--------|
| `/usage` | Current session token/cost breakdown; plan usage bars for subscribers |
| `/usage-credits` | Set a monthly spend limit on usage credits (Pro/Max) |
| `/model` | Switch model mid-session to control costs |
| `/effort` | Adjust reasoning level; lower effort = fewer thinking tokens |
| `/compact [focus]` | Summarize context to reduce token usage |
| `/clear` | Reset context between unrelated tasks |
| `/context` | See what is consuming context window space |

**Average enterprise cost**: ~$13/developer/active day; $150–250/month. 90th percentile stays below $30/active day.

### Rate Limit Recommendations (API)

| Team size | TPM per user | RPM per user |
|:----------|:------------|:------------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

### OpenTelemetry (OTel) Quick Start

Required env vars to enable telemetry:

```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console | none
OTEL_LOGS_EXPORTER=otlp             # otlp | console | none
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Configuration Variables

| Variable | Default | Purpose |
|:---------|:--------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | off | Master switch (set to `1`) |
| `OTEL_METRICS_EXPORTER` | — | Metrics sink |
| `OTEL_LOGS_EXPORTER` | — | Events/logs sink |
| `OTEL_TRACES_EXPORTER` | — | Distributed traces sink (beta) |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000 ms | Metrics flush interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000 ms | Logs flush interval |
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt text in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include Bash commands, MCP names, tool args |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool input/output in trace spans |
| `OTEL_LOG_RAW_API_BODIES` | off | Emit full Messages API request/response JSON |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include `session.id` on metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include `user.account_uuid` on metrics |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | off | Enable distributed traces (beta) |

### Available Metrics

| Metric | Unit | Description |
|:-------|:-----|:------------|
| `claude_code.session.count` | count | Sessions started |
| `claude_code.lines_of_code.count` | count | Lines added/removed |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Per-request API cost |
| `claude_code.token.usage` | tokens | Tokens used (input/output/cache) |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept/reject |
| `claude_code.active_time.total` | s | Active user + CLI time |

### Available OTel Events

| Event name | When emitted |
|:-----------|:-------------|
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission decision made |
| `claude_code.api_request` | Each API call to Claude |
| `claude_code.api_error` | API call fails after all retries |
| `claude_code.api_request_body` | API request body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_response_body` | API response body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_retries_exhausted` | Request exhausted all retries |
| `claude_code.permission_mode_changed` | Permission mode changes |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects/fails |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.plugin_installed` | Plugin finishes installing |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.at_mention` | `@`-mention resolved |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` | Hooks begin executing |
| `claude_code.hook_execution_complete` | Hooks finish executing |
| `claude_code.hook_plugin_metrics` | Official-marketplace plugin hook emits metrics |
| `claude_code.compaction` | Context compaction completes |
| `claude_code.internal_error` | Unexpected internal error caught |
| `claude_code.feedback_survey` | Session quality survey shown/answered |

### Troubleshooting Quick Lookup

| Symptom | Go to |
|:--------|:------|
| `command not found`, PATH, `EACCES`, TLS errors | [Troubleshoot install](references/claude-code-troubleshoot-install.md) |
| Login loops, OAuth errors, `403 Forbidden`, Bedrock/Vertex creds | [Troubleshoot install — login](references/claude-code-troubleshoot-install.md) |
| Settings not applying, hooks not firing, MCP not loading | [Debug your config](references/claude-code-debug-your-config.md) |
| `5xx`, `529`, `429`, request validation errors | [Error reference](references/claude-code-errors.md) |
| High CPU/memory, hangs, search not finding files | [Troubleshooting](references/claude-code-troubleshooting.md) |

Run `/doctor` to auto-check installation, settings, MCP servers, and context usage. If `claude` won't start, run `claude doctor` from the shell.

### Debug Commands

| Command | Purpose |
|:--------|:--------|
| `/doctor` | Configuration diagnostics: invalid keys, schema errors, install health |
| `/debug [issue]` | Enable debug logging; Claude diagnoses from log output |
| `/status` | Active settings sources; which credentials are in use |
| `/context` | Full context window breakdown |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |

### Common Config Gotchas

| Symptom | Cause | Fix |
|:--------|:------|:----|
| Hook never fires | `matcher` is an array instead of a string | Use `"Edit\|Write"` not `["Edit","Write"]` |
| Hook never fires | `matcher` value is lowercase | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Settings value ignored | Same key in `settings.local.json` | Local overrides project; project overrides user |
| Skill not in `/skills` | File at `.claude/skills/name.md` not in a folder | Must be `.claude/skills/name/SKILL.md` |
| MCP servers in `.mcp.json` never load | File is under `.claude/` | Goes at the repo root as `.mcp.json` |
| Subagent ignores CLAUDE.md | Explore/Plan agents skip CLAUDE.md | Restate instructions in the delegating prompt |

### Runtime Error Quick Reference

| Error | Category | Fix |
|:------|:---------|:----|
| `API Error: 500` | Server | Retry; check status.claude.com |
| `API Error: 529 Overloaded` | Server | Retry; switch model with `/model` |
| `You've hit your session limit` | Usage | Wait for reset or run `/usage-credits` |
| `Request rejected (429)` | Rate limit | Check active credential with `/status`; reduce concurrency |
| `Credit balance is too low` | Billing | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check `ANTHROPIC_API_KEY`; run `/status` |
| `OAuth token revoked` | Auth | Run `/logout` then `/login` |
| `Prompt is too long` | Request | Run `/compact` or `/clear`; disable unused MCP servers |
| `Extra inputs are not permitted` | Request | Configure proxy to forward `anthropic-beta` header |
| `There's an issue with the selected model` | Request | Run `/model` to pick a valid model |

Automatic retries: Claude Code retries transient failures up to 10 times before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

### What's New (Recent Weeks)

| Week | Highlights |
|:-----|:---------|
| W22 (May 25–29, 2026) | Claude Opus 4.8 as new default; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8 |
| W21 (May 18–22, 2026) | Auto mode on Pro plan; `/usage` plan-limit breakdown; `/code-review` command; background sessions |
| W20 (May 11–15, 2026) | Agent view (`claude agents`); `/goal` command; fast mode on Opus 4.7 by default; Rewind summarize |
| W19 (May 4–8, 2026) | Plugins load from `.zip`/URL; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level |
| W18 (Apr 27–May 1, 2026) | Windows without Git Bash; `claude ultrareview`; `claude project purge`; PR URL in `/resume` |
| W17 (Apr 20–24, 2026) | `/ultrareview` public preview; session recap; custom themes; Claude Code on web redesign |
| W16 (Apr 13–17, 2026) | Claude Opus 4.7 default; `xhigh` effort; Routines on web; mobile push notifications; native binaries |
| W15 (Apr 6–10, 2026) | Ultraplan preview; Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| W14 (Mar 30–Apr 3, 2026) | Computer use CLI preview; `/powerup` lessons; per-tool MCP result-size override |
| W13 (Mar 23–27, 2026) | Auto mode research preview; computer use in Desktop; PR auto-fix; `/` transcript search; PowerShell tool |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API, contribution metrics setup, PR attribution, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — Cost tracking with `/usage`, team spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel quick start, all configuration variables, full metrics and events catalog, traces beta, SIEM audit guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, auto-compact thrashing, hangs, search/discovery issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — Installation errors, PATH issues, TLS errors, OAuth errors, Bedrock/Vertex/Foundry credentials
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnosing CLAUDE.md, settings, hooks, MCP servers, and skills not loading; clean-config testing
- [Error reference](references/claude-code-errors.md) — Complete runtime error messages, causes, and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version-by-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index of notable features
- [What's new: Week 13 (Mar 23–27, 2026)](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use in Desktop, PowerShell tool
- [What's new: Week 14 (Mar 30–Apr 3, 2026)](references/claude-code-whats-new-2026-w14.md) — Computer use CLI, `/powerup`, MCP result-size override
- [What's new: Week 15 (Apr 6–10, 2026)](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/team-onboarding`
- [What's new: Week 16 (Apr 13–17, 2026)](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, `xhigh` effort, Routines, mobile notifications, native binaries
- [What's new: Week 17 (Apr 20–24, 2026)](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes
- [What's new: Week 18 (Apr 27–May 1, 2026)](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`
- [What's new: Week 19 (May 4–8, 2026)](references/claude-code-whats-new-2026-w19.md) — Plugin zip/URL loading, `worktree.baseRef`, hard deny rules, hooks effort level
- [What's new: Week 20 (May 11–15, 2026)](references/claude-code-whats-new-2026-w20.md) — Agent view, `/goal`, fast mode on Opus 4.7, Rewind summarize
- [What's new: Week 21 (May 18–22, 2026)](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro, `/usage` breakdown, `/code-review`, background sessions
- [What's new: Week 22 (May 25–29, 2026)](references/claude-code-whats-new-2026-w22.md) — Opus 4.8 default, dynamic workflows, security-guidance plugin

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
- What's new Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new Week 21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new Week 22: https://code.claude.com/docs/en/whats-new/2026-w22.md
