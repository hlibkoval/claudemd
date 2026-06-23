---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating Claude Code in production: analytics, cost management, telemetry/monitoring, troubleshooting, error recovery, configuration debugging, the changelog, and weekly "what's new" digests.

## Quick Reference

### Analytics Dashboards

| Plan | URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage + contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage + spend, team insights table |

Contribution metrics require GitHub app installation and are **not** available with Zero Data Retention enabled. Data appears within 24 hours, updates daily.

**Key contribution metrics**: PRs with CC, lines of code with CC, PRs with CC (%), suggestion accept rate, lines of code accepted. Attribution window: 21 days before to 2 days after PR merge. Code rewritten >20% is not attributed.

### Cost Tracking

| Command | Purpose |
| :--- | :--- |
| `/usage` | Session token usage and plan limit breakdown (day/week toggle with `d`/`w`) |
| `/usage-credits` | Buy extra usage credits (Pro/Max) or request from admin (Team/Enterprise) |
| `/compact [focus]` | Summarize conversation to free context |
| `/clear` | Start fresh context |
| `/model` | Switch models mid-session |
| `/effort` | Adjust reasoning level |

**Average enterprise cost**: ~$13/developer/active day, $150–250/month. 90% of users stay below $30/active day.

**Rate limit recommendations (TPM per user)**:

| Team size | TPM/user | RPM/user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Token reduction strategies**: use `/compact` regularly, choose Sonnet over Opus for most tasks, disable unused MCP servers (`/mcp`), move large CLAUDE.md sections into skills, use subagents for verbose operations, set `MAX_THINKING_TOKENS` lower for simple tasks.

### OpenTelemetry Monitoring

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. All other env vars are optional.

**Core env vars**:

| Variable | Options | Default |
| :--- | :--- | :--- |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | URL | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | `Key=Value` | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | ms | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | ms | 5000 |
| `OTEL_LOG_USER_PROMPTS` | `1` to enable | disabled |
| `OTEL_LOG_TOOL_DETAILS` | `1` to enable | disabled |
| `OTEL_LOG_TOOL_CONTENT` | `1` to enable | disabled |
| `OTEL_LOG_RAW_API_BODIES` | `1` or `file:<dir>` | disabled |

**Exported metrics**:

| Metric | Unit | Key extra attributes |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | `start_type` |
| `claude_code.token.usage` | tokens | `type`, `model`, `query_source`, `effort` |
| `claude_code.cost.usage` | USD | `model`, `query_source`, `effort`, `skill.name`, `agent.name` |
| `claude_code.lines_of_code.count` | count | `type` (added/removed), `model` |
| `claude_code.commit.count` | count | — |
| `claude_code.pull_request.count` | count | — |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | s | `type` (user/cli) |

**Standard attributes on all metrics/events**: `session.id`, `user.id`, `user.email`, `user.account_uuid`, `organization.id`, `terminal.type`, `app.version`, `app.entrypoint`.

**Key log events**: `claude_code.user_prompt`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_refusal`, `claude_code.tool_result`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.skill_activated`, `claude_code.plugin_loaded`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`.

**Traces (beta)**: enable with `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` plus `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`.

### Troubleshooting: Issue Routing

| Symptom | Go to |
| :--- | :--- |
| `command not found`, PATH, `EACCES`, TLS install errors | Troubleshoot installation and login |
| OAuth errors, 403, Bedrock/Vertex/Foundry credentials | Troubleshoot installation and login |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `5xx`, `529`, `429`, request validation errors | Error reference |
| High CPU/memory, hangs, search not finding files | Troubleshooting (performance) |

**First step always**: run `/doctor` inside Claude Code (or `claude doctor` from the shell if it won't start).

### Configuration Debugging Commands

| Command | What it shows |
| :--- | :--- |
| `/context` | Everything in the context window by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hooks grouped by event |
| `/mcp` | MCP servers and connection status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config validation, schema errors, install health |
| `/status` | Active settings sources and auth method |
| `/debug [issue]` | Enable debug logging for the session |

**Safe mode**: `claude --safe-mode` disables CLAUDE.md, skills, plugins, hooks, MCP, custom commands. Auth and built-in tools still work. If the problem disappears, one of those surfaces is the cause.

**Clean config test**:
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

### Common Configuration Gotchas

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use `"Edit\|Write"` with pipe separator |
| Hook never fires | Lowercase matcher (e.g. `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Defined in a standalone file | Must be under `"hooks"` key in `settings.json` |
| Permissions ignored | Added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Setting seems ignored | Overridden in `settings.local.json` | Local overrides project, project overrides user |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP server not loading | Project server in `.mcp.json` needs approval | Run `/mcp` and approve |
| MCP env vars not set | `env` in `settings.json` doesn't propagate to MCP | Set `env` inside `.mcp.json` instead |

### Error Quick Reference

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Check status.claude.com; retry |
| `529 Overloaded` | Server | Check status; `/model` to switch |
| `429` | Rate limit | Check workspace limits; reduce concurrency |
| `You've hit your session/weekly limit` | Usage | Wait for reset; `/usage-credits` |
| `Credit balance is too low` | Usage | Add credits at Console billing page |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check/unset `ANTHROPIC_API_KEY`; run `/status` |
| `This organization has been disabled` | Auth | Unset stale `ANTHROPIC_API_KEY` |
| `OAuth token revoked` | Auth | `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy; set `HTTPS_PROXY`; firewall |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS` |
| `Prompt is too long` | Request | `/compact` or `/clear`; disable unused MCP |
| `There's an issue with the selected model` | Request | `/model` to pick a valid model |
| `Extra inputs are not permitted` | Request | Gateway must forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |

**Retry behavior**: Claude Code retries up to 10 times (capped at 15 from v2.1.186) with exponential backoff. Set `CLAUDE_CODE_RETRY_WATCHDOG=1` for indefinite retry of capacity errors in CI.

### Installation Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; restart terminal |
| Install script returns HTML / 403 | Network block or unsupported region; try `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| TLS errors | Update CA certs; set `NODE_EXTRA_CA_CERTS`; check corporate proxy |
| `Killed` during install (Linux) | Add 2 GB swap; need 4 GB RAM minimum |
| `Illegal instruction` | CPU lacks AVX or architecture mismatch; check `uname -m` |
| `Exec format error` on WSL1 | Upgrade to WSL2: `wsl --set-version <distro> 2` |
| `dyld: cannot load` on macOS | macOS 13.0 required; update macOS |
| Multiple `claude` binaries conflict | Remove old npm install: `npm uninstall -g @anthropic-ai/claude-code` |

### Weekly Digest Summary (latest)

| Week | Dates | Highlight |
| :--- | :--- | :--- |
| 24 | Jun 8–12, 2026 | `/cd` moves session; subagents can spawn subagents (5 levels deep); `--safe-mode` |
| 23 | Jun 1–5, 2026 | Auto mode on Bedrock/Vertex/Foundry; safer edits in acceptEdits mode; version requirements |
| 22 | May 25–29, 2026 | Claude Opus 4.8 default; dynamic workflows; security-guidance plugin; fast mode |
| 21 | May 18–22, 2026 | Auto mode on Pro plan; `/usage` plan limit breakdown; `/code-review` command |
| 20 | May 11–15, 2026 | `claude agents` view; `/goal` persists across turns; fast mode on Opus 4.7 |
| 19 | May 4–8, 2026 | Plugins from `.zip`/URLs; `worktree.baseRef`; auto mode hard deny rules |
| 18 | Apr 27–May 1 | Windows without Git Bash (PowerShell); `claude ultrareview`; paste PR URL into `/resume` |
| 17 | Apr 20–24, 2026 | `/ultrareview` cloud bug-hunting; session recap; custom themes |
| 16 | Apr 13–17, 2026 | Claude Opus 4.7 default; `xhigh` effort; Routines; mobile push notifications |
| 15 | Apr 6–10, 2026 | Ultraplan cloud preview; Monitor tool for live log tailing; `/loop` |
| 14 | Mar 30–Apr 3 | Computer use in CLI (research preview); `/powerup`; per-tool MCP result-size override |
| 13 | Mar 23–27, 2026 | Auto mode research preview; conditional `if` hooks; native PowerShell tool |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — Usage and contribution metrics dashboards for Teams/Enterprise and API customers
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking, team spend limits, rate limits, and cost reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Full OTel config, all metrics, all events, span hierarchy, audit/SIEM guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) — Performance, stability, high CPU/memory, compaction thrashing, search issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — Install failures, PATH, TLS, authentication, WSL, Windows-specific issues
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnosing why CLAUDE.md, settings, hooks, MCP, or skills don't take effect
- [Error reference](references/claude-code-errors.md) — All runtime error messages with causes and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version-by-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index (w13–w24)
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use in Desktop, conditional hooks, PowerShell tool
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — Computer use CLI, /powerup, MCP result-size override, plugin executables
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /team-onboarding, /autofix-pr
- [Week 16 digest](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile push, /usage, native binaries
- [Week 17 digest](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [Week 18 digest](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview CLI, project purge, PR URL in /resume
- [Week 19 digest](references/claude-code-whats-new-2026-w19.md) — Plugin zip/URL loading, worktree.baseRef, auto mode hard deny, effort in hooks
- [Week 20 digest](references/claude-code-whats-new-2026-w20.md) — claude agents view, /goal, fast mode on Opus 4.7, Rewind "Summarize up to here"
- [Week 21 digest](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro, /usage plan breakdown, /code-review, background sessions
- [Week 22 digest](references/claude-code-whats-new-2026-w22.md) — Opus 4.8 default, dynamic workflows, security-guidance plugin, fast mode
- [Week 23 digest](references/claude-code-whats-new-2026-w23.md) — Auto mode on Bedrock/Vertex/Foundry, safer acceptEdits, /plugin list, version requirements
- [Week 24 digest](references/claude-code-whats-new-2026-w24.md) — /cd command, nested subagents (5 levels), --safe-mode, fallbackModel chains

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
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
- Week 18 digest: https://code.claude.com/docs/en/whats-new/2026-w18.md
- Week 19 digest: https://code.claude.com/docs/en/whats-new/2026-w19.md
- Week 20 digest: https://code.claude.com/docs/en/whats-new/2026-w20.md
- Week 21 digest: https://code.claude.com/docs/en/whats-new/2026-w21.md
- Week 22 digest: https://code.claude.com/docs/en/whats-new/2026-w22.md
- Week 23 digest: https://code.claude.com/docs/en/whats-new/2026-w23.md
- Week 24 digest: https://code.claude.com/docs/en/whats-new/2026-w24.md
