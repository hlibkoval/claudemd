---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, troubleshooting, and tracking costs for Claude Code deployments.

## Quick Reference

### Diagnostics and Debug Commands

| Command | What it shows |
| :--- | :--- |
| `/doctor` | Config validity, invalid keys, schema errors, installation health |
| `/context` | Everything in the context window, broken down by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and their status |
| `/permissions` | Resolved allow and deny rules in effect |
| `/status` | Active settings sources; whether managed settings are in effect |
| `/debug [issue]` | Enables debug logging; prompts Claude to diagnose |
| `claude --safe-mode` | Launch with all customizations disabled (plugins, hooks, MCP, CLAUDE.md) |
| `cd /tmp && CLAUDE_CODE_DIR=/tmp/claude-clean claude` | Launch against a clean config dir to isolate the cause |

### Troubleshooting Quick-Match

| Symptom | Go to |
| :--- | :--- |
| `command not found`, PATH issues, `EACCES`, TLS errors | [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) |
| Login loops, OAuth errors, `403 Forbidden`, Bedrock/Vertex credentials | [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md#login-and-authentication) |
| Settings not applying, hooks not firing, MCP servers not loading | [Debug your configuration](references/claude-code-debug-your-config.md) |
| `API Error: 5xx`, `529 Overloaded`, `429`, request validation errors | [Error reference](references/claude-code-errors.md) |
| `model not found` or access errors | [Error reference](references/claude-code-errors.md#there's-an-issue-with-the-selected-model) |
| High CPU/memory, hangs, slow search | [Troubleshooting](references/claude-code-troubleshooting.md) |

### Common Configuration Gotchas

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array, not a string | Use a single string with `\|` separator, e.g. `"Edit\|Write"` |
| Hook never fires | Lowercase tool name e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Defined in a standalone file instead of `settings.json` | Hooks must be under the `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Added to `~/.claude.json` instead of `~/.claude/settings.json` | These are two different files |
| Skill doesn't appear in `/skills` | Skill file at `.claude/skills/name.md` | Use a folder: `.claude/skills/name/SKILL.md` |
| MCP servers in `.mcp.json` not loading | File is inside `.claude/` | Project MCP config goes at the repo root as `.mcp.json` |
| MCP server starts without env vars | Variables set in `settings.json` `env` don't propagate to MCP | Set per-server `env` inside `.mcp.json` |

### Error Categories and Recovery

| Category | Common errors | Recovery |
| :--- | :--- | :--- |
| Server errors | `500`, `529 Overloaded`, `Request timed out` | Retry; check status.claude.com; switch model with `/model` |
| Usage limits | `You've hit your session limit`, `429`, `Credit balance is too low` | Wait for reset; run `/usage`; buy credits with `/usage-credits` |
| Authentication | `Not logged in`, `Invalid API key`, `OAuth token revoked` | Run `/login`; check `ANTHROPIC_API_KEY` env var; run `/status` |
| Network | `Unable to connect to API`, `SSL certificate errors` | Check proxy; set `NODE_EXTRA_CA_CERTS`; verify `HTTPS_PROXY` |
| Request errors | `Prompt is too long`, `Request too large`, `model not found` | Run `/compact` or `/clear`; check `/model` |

Claude Code retries transient failures up to 10 times before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default: 10) and `API_TIMEOUT_MS` (default: 600000ms).

### Costs and Token Usage

| Strategy | How |
| :--- | :--- |
| Check current session cost | Run `/usage` (shows token breakdown and estimated cost) |
| Clear stale context | `/clear` between unrelated tasks; use `/compact` with focus instructions |
| Choose the right model | Sonnet for most tasks; Opus for complex reasoning; Haiku for subagents |
| Reduce MCP overhead | MCP tool definitions are deferred by default; disable unused servers with `/mcp` |
| Limit extended thinking | Lower effort with `/effort` or `MAX_THINKING_TOKENS=8000`; disable in `/config` |
| Delegate verbose ops | Use subagents for log/doc fetching so verbose output stays in their context |
| Move instructions to skills | Keep CLAUDE.md under 200 lines; put specialized workflows in skills (load on demand) |

#### Average Costs (API users)

~$13/developer/active day; ~$150–250/developer/month; <$30/active day for 90% of users.

#### Rate Limit Recommendations (API)

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

### OpenTelemetry Monitoring

Enable telemetry by setting `CLAUDE_CODE_ENABLE_TELEMETRY=1`. Configure exporters via:

| Variable | Options | Notes |
| :--- | :--- | :--- |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` | Metrics backend |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` | Events/logs backend |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/protobuf`, `http/json` | Transport protocol |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | e.g. `http://localhost:4317` | Collector endpoint |
| `OTEL_LOG_USER_PROMPTS` | `1` to enable | Prompt content (off by default) |
| `OTEL_LOG_TOOL_DETAILS` | `1` to enable | Tool args, Bash commands, MCP names (off by default) |
| `OTEL_LOG_TOOL_CONTENT` | `1` to enable | Full tool input/output in traces (off by default) |
| `OTEL_LOG_RAW_API_BODIES` | `1` or `file:<dir>` | Full Messages API request/response bodies (off by default) |

#### Key Exported Metrics

| Metric | Description |
| :--- | :--- |
| `claude_code.session.count` | Sessions started |
| `claude_code.token.usage` | Tokens used (input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage` | Estimated cost in USD |
| `claude_code.lines_of_code.count` | Lines added/removed |
| `claude_code.commit.count` | Git commits created |
| `claude_code.pull_request.count` | Pull requests created |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject counts |
| `claude_code.active_time.total` | Active time in seconds |

#### Key Exported Events

`claude_code.user_prompt`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_refusal`, `claude_code.tool_result`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.skill_activated`, `claude_code.compaction`, `claude_code.plugin_installed`, `claude_code.plugin_loaded`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`.

All metrics and events share standard attributes: `session.id`, `user.id`, `user.email`, `user.account_uuid`, `organization.id`, `app.version`, `terminal.type`.

For distributed tracing (beta), also set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`.

### Analytics Dashboard

| Plan | URL | Includes |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user insights |

Contribution metrics (Teams/Enterprise) require installing the GitHub app at github.com/apps/claude and enabling analytics in admin settings. Data appears within 24 hours; daily updates thereafter.

### What's New (Recent Weeks)

| Week | Dates | Highlights |
| :--- | :--- | :--- |
| W24 | Jun 8–12, 2026 | `/cd` mid-session; sub-agents spawn sub-agents (5-level cap); `--safe-mode`; `fallbackModel` |
| W23 | Jun 1–5, 2026 | Auto mode on Bedrock/Vertex/Foundry; safer `acceptEdits`; `/plugin list`; version requirements |
| W22 | May 25–29, 2026 | Claude Opus 4.8 default; dynamic workflows; security-guidance plugin; fast mode |
| W21 | May 18–22, 2026 | Auto mode on Pro; `/usage` breakdown by skill/subagent/plugin/MCP; `/code-review` command |
| W20 | May 11–15, 2026 | Agent view (`claude agents`); `/goal` command; fast mode on Opus 4.7 default; Rewind compression |
| W19 | May 4–8, 2026 | Plugins from `.zip`/URL; `worktree.baseRef`; auto mode hard deny; hooks see effort level |
| W18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell tool); `claude ultrareview`; `claude project purge` |
| W17 | Apr 20–24, 2026 | `/ultrareview` research preview; session recap; custom themes; Claude Code on web redesign |
| W16 | Apr 13–17, 2026 | Claude Opus 4.7 default; Routines; mobile push notifications; `/effort` slider; native binaries |
| W15 | Apr 6–10, 2026 | Ultraplan early preview; Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| W14 | Mar 30–Apr 3, 2026 | Computer use CLI preview; `/powerup`; per-tool MCP result-size override; plugin executables on PATH |
| W13 | Mar 23–27, 2026 | Auto mode research preview; computer use in Desktop; PR auto-fix on Web; PowerShell tool; `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Usage dashboards, contribution metrics with GitHub integration, PR attribution, and ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking, team spend limits, rate limit recommendations, and token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Full OTel configuration, all exported metrics, events, span attributes, and security audit guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, auto-compaction thrashing, hangs, search issues, and WSL performance
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH issues, install errors, TLS failures, authentication, and cloud provider credentials
- [Debug your configuration](references/claude-code-debug-your-config.md) — Why CLAUDE.md, settings, hooks, MCP servers, or skills aren't taking effect
- [Error reference](references/claude-code-errors.md) — All runtime error messages with meaning and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full release notes by version
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index of notable features
- [What's new: Week 13 (Mar 23–27, 2026)](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use Desktop, PowerShell tool, `if` hooks
- [What's new: Week 14 (Mar 30–Apr 3, 2026)](references/claude-code-whats-new-2026-w14.md) — Computer use CLI, `/powerup`, MCP result-size override
- [What's new: Week 15 (Apr 6–10, 2026)](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop` self-pacing
- [What's new: Week 16 (Apr 13–17, 2026)](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, Routines, mobile push, `/effort` slider, native binaries
- [What's new: Week 17 (Apr 20–24, 2026)](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes
- [What's new: Week 18 (Apr 27–May 1, 2026)](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`
- [What's new: Week 19 (May 4–8, 2026)](references/claude-code-whats-new-2026-w19.md) — Plugins from `.zip`/URL, `worktree.baseRef`, auto mode hard deny
- [What's new: Week 20 (May 11–15, 2026)](references/claude-code-whats-new-2026-w20.md) — Agent view, `/goal`, fast mode on Opus 4.7
- [What's new: Week 21 (May 18–22, 2026)](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro, `/usage` breakdown, `/code-review`
- [What's new: Week 22 (May 25–29, 2026)](references/claude-code-whats-new-2026-w22.md) — Opus 4.8, dynamic workflows, security-guidance plugin
- [What's new: Week 23 (Jun 1–5, 2026)](references/claude-code-whats-new-2026-w23.md) — Auto mode on Bedrock/Vertex/Foundry, safer `acceptEdits`
- [What's new: Week 24 (Jun 8–12, 2026)](references/claude-code-whats-new-2026-w24.md) — `/cd`, nested sub-agents, `--safe-mode`, `fallbackModel`

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
- What's new Week 23: https://code.claude.com/docs/en/whats-new/2026-w23.md
- What's new Week 24: https://code.claude.com/docs/en/whats-new/2026-w24.md
