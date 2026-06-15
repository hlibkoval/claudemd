---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations — analytics, cost management, monitoring with OpenTelemetry, troubleshooting, configuration debugging, error reference, and the changelog/what's-new digest.

## Quick Reference

### Analytics Dashboard Access

| Plan | Dashboard URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user team insights |

**Enable contribution metrics (Teams/Enterprise):**
1. GitHub admin installs the Claude GitHub app at github.com/apps/claude
2. Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Owner enables "GitHub analytics" toggle and completes GitHub auth

**PR attribution:** PRs tagged `claude-code-assisted` in GitHub when merged. 21-day session window (21 days before to 2 days after merge). Code rewritten >20% difference is not attributed.

### Cost Management Quick Reference

**Track usage:**
- `/usage` — current session token stats, plan usage breakdown (press `d`/`w` for 24h/7d)
- `/usage-credits` — buy or manage extra credits on Pro/Max plans

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**
- `/clear` between unrelated tasks; `/compact Focus on X` to preserve key parts
- `/model` to switch to Sonnet for most tasks; Opus for complex reasoning only
- `/mcp` to disable unused MCP servers (tool definitions consume context)
- Install code intelligence plugins for typed languages (reduces file reads)
- Move CLAUDE.md workflow instructions into skills (skills load on-demand)
- `/effort` to lower extended thinking level for simpler tasks
- Delegate verbose operations (tests, logs) to subagents

**Agent team costs:** ~7× more tokens than standard sessions. Use Sonnet for teammates, keep teams small, clean up when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Average enterprise cost:** ~$13/developer/active day, $150–250/developer/month.

### OpenTelemetry Monitoring Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

**Key OTel environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporters (comma-separated) | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporters | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log tool parameters and names | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in spans | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | disabled |

**Metrics cardinality control:**

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include `session.id` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include `user.account_uuid` / `user.account_id` |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include `app.version` |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | `false` | Include `app.entrypoint` |
| `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES` | `true` | Include custom `OTEL_RESOURCE_ATTRIBUTES` keys on datapoints |

**Available metrics:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit permission decisions | count |
| `claude_code.active_time.total` | Active time | seconds |

**Key events** (via `OTEL_LOGS_EXPORTER`): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.tool_decision`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_refusal`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.plugin_loaded`, `claude_code.skill_activated`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`

**Distributed traces (beta):** Set `CLAUDE_CODE_ENABLE_TELEMETRY=1`, `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`, and `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request` / `claude_code.tool` → `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`.

**SIEM export (events only, full tool detail):**
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_LOG_TOOL_DETAILS": "1",
    "OTEL_EXPORTER_OTLP_LOGS_PROTOCOL": "http/protobuf",
    "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT": "https://siem.example.com:4318/v1/logs",
    "OTEL_EXPORTER_OTLP_HEADERS": "Authorization=Bearer your-siem-token"
  }
}
```

### Troubleshooting Quick Reference

**Where to start by symptom:**

| Symptom | Go to |
| :--- | :--- |
| `command not found`, install fails, PATH issues | Troubleshoot installation |
| Login loops, OAuth errors, 403, Bedrock/Vertex credentials | Troubleshoot installation → Login section |
| Settings/hooks/MCP not loading | Debug your configuration |
| `API Error: 5xx`, 529, 429, validation errors | Error reference |
| `model not found` | Error reference → selected model section |
| High CPU/memory, hangs, search not finding files | Troubleshooting → Performance section |

**Run `/doctor` first** — checks installation health, settings validity, MCP config, and context usage in one pass. If `claude` won't start, run `claude doctor` from your shell.

**Performance fixes:**
- High CPU/memory: use `/compact` regularly, restart between major tasks, add build dirs to `.gitignore`, restart with `claude --safe-mode` to isolate plugins/hooks
- Auto-compact thrashing error: read oversized files in chunks, `/compact keep only the plan and the diff`, move large-file work to a subagent, or `/clear`
- Command hangs: Ctrl+C to cancel; `claude --resume` to pick up the session after restarting
- Garbled text in VS Code/Cursor terminal: run `/terminal-setup` to disable GPU acceleration
- Search not finding files: install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`
- WSL slow search: keep project on Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`)

### Debug Your Configuration

**Diagnostic commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics: invalid keys, schema errors, installation health |
| `/debug [issue]` | Enables debug logging and prompts Claude to diagnose |
| `/status` | Active settings sources including managed settings |

**Clean configuration test:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**`claude --safe-mode`** — disables all customizations (CLAUDE.md, skills, plugins, hooks, MCP, custom commands) while keeping authentication and built-in tools. Managed settings still partially apply.

**Common configuration mistakes:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | Matcher is lowercase (`"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Defined in a standalone file | Put hooks under `"hooks"` key in `settings.json` |
| Permissions/env ignored | Added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Settings value ignored | Same key in `settings.local.json` | Local overrides project overrides user settings |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP server never loads | File under `.claude/` or wrong format | Project MCP config goes at repo root as `.mcp.json` |

### Error Reference Quick Lookup

**Automatic retries:** Claude Code retries transient failures up to 10 times. Configure with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

**Common errors and fixes:**

| Error | Fix |
| :--- | :--- |
| `API Error: 500` | Check status.claude.com; retry; `/feedback` if persistent |
| `API Error: 529 Overloaded` | Check status.claude.com; retry in minutes; `/model` to switch models |
| `You've hit your session/weekly limit` | Wait for reset; `/usage-credits` to buy more; upgrade plan |
| `Request rejected (429)` | Check rate limits in Console; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Run `/login` |
| `Invalid API key` | Check `ANTHROPIC_API_KEY`; verify in Console; run `/status` |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` env var; use `/login` for subscription auth |
| `Unable to connect to API` | Check internet; set `HTTPS_PROXY`; check firewall for `api.anthropic.com` |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | `/compact`, `/clear`, disable unused MCP servers, trim CLAUDE.md |
| `There's an issue with the selected model` | `/model` to pick a valid model; check `ANTHROPIC_MODEL` env var |
| `Extra inputs are not permitted` | Gateway is stripping `anthropic-beta` header; configure gateway to forward it or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `OAuth token revoked/expired` | `/login` to re-authenticate |
| Usage Policy refusal | Press Esc twice to rewind; rephrase; or `/clear` to start fresh |

**Responses seem lower quality:** Check `/model` (correct model?), `/effort` (reasoning level?), `/context` (window near full? → `/compact`), stale CLAUDE.md instructions.

### What's New — Recent Highlights (Weeks 13–22, 2026)

| Week | Key Features |
| :--- | :--- |
| W22 (v2.1.150–157) | Claude Opus 4.8 (new default for Max/Team Premium/API); dynamic workflows; security-guidance plugin; fast mode on Opus 4.8 |
| W21 (v2.1.143–149) | Auto mode on Pro plan; `/usage` attribution breakdown; `/code-review` command; background sessions in `/resume` |
| W20 (v2.1.139–142) | Agent view (`claude agents`); `/goal` command; fast mode on Opus 4.7 by default; Rewind "Summarize up to here" |
| W19 (v2.1.128–136) | Plugins from `.zip`/URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level |
| W18 (v2.1.120–126) | Windows without Git Bash (PowerShell tool); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume` |
| W17 (v2.1.114–119) | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| W16 (v2.1.105–113) | Claude Opus 4.7 default; `xhigh` effort level; Routines on the web; mobile push notifications; native binaries |
| W15 (v2.1.92–101) | Ultraplan early preview; Monitor tool; `/loop` self-paces; `/team-onboarding`; `/autofix-pr` |
| W14 (v2.1.86–91) | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override |
| W13 (v2.1.83–85) | Auto mode research preview; computer use in Desktop; PR auto-fix on web; transcript search with `/`; PowerShell tool; conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — usage metrics, contribution metrics, PR attribution, leaderboard, API access, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — token tracking, spend limits, rate limit recommendations, cost reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel quick start, all metrics and events, traces (beta), SIEM integration, security audit
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, stability, search, auto-compact, hangs, garbled text
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH issues, install errors, TLS, platform-specific problems, OAuth, Bedrock/Vertex credentials
- [Debug your configuration](references/claude-code-debug-your-config.md) — diagnose CLAUDE.md, settings, hooks, MCP, skills not loading; clean config testing
- [Error reference](references/claude-code-errors.md) — runtime error messages, automatic retries, server/usage/auth/network/request errors, quality issues
- [Changelog](references/claude-code-changelog.md) — full version-by-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest overview (W13–W22, 2026)
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use Desktop, PowerShell tool, conditional hooks
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use CLI, /powerup, MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /team-onboarding
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile notifications, native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [What's new: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview, project purge
- [What's new: Week 19](references/claude-code-whats-new-2026-w19.md) — zip/URL plugins, worktree.baseRef, auto mode hard deny, hooks effort
- [What's new: Week 20](references/claude-code-whats-new-2026-w20.md) — Agent view, /goal, fast mode Opus 4.7, Rewind summarize
- [What's new: Week 21](references/claude-code-whats-new-2026-w21.md) — auto mode Pro, /usage attribution, /code-review, background sessions
- [What's new: Week 22](references/claude-code-whats-new-2026-w22.md) — Opus 4.8 default, dynamic workflows, security-guidance plugin

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
