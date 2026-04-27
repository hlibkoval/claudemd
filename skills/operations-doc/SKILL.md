---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost tracking and reduction, OpenTelemetry monitoring, error reference, troubleshooting, configuration debugging, changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code deployments, including usage analytics, cost management, observability, error recovery, troubleshooting, and release notes.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Access role |
| :--- | :--- | :--- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Admin or Owner |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | UsageView permission |

**Contribution metrics** (Teams/Enterprise only, requires GitHub app):
- Install the Claude GitHub app at github.com/apps/claude
- Enable Claude Code analytics at claude.ai/admin-settings/claude-code
- Data appears within 24 hours; daily updates thereafter
- Not available with Zero Data Retention enabled

**Key metrics**: lines of code accepted, suggestion accept rate, DAU/sessions, PRs with Claude Code (%), leaderboard, CSV export

**PR attribution**: sessions within 21 days before to 2 days after merge; 20%+ rewrites not attributed; auto-generated files (lock files, build dirs) excluded

---

### Cost management

**Average costs**: ~$13/developer/active day; $150–250/developer/month; 90th percentile under $30/active day

**Check session cost**: `/usage`

**Rate limit recommendations by team size**:

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Reduce token usage**:
- `/clear` between unrelated tasks; `/compact` with focus instructions
- Use Sonnet for most tasks; reserve Opus for complex reasoning
- Move detailed CLAUDE.md sections into on-demand skills
- Set `MAX_THINKING_TOKENS=8000` or lower effort with `/effort` for simpler tasks
- Delegate verbose operations (logs, test output) to subagents
- Use `DISABLE_AUTO_COMPACT` only if managing compaction manually

**Agent team costs**: ~7x standard token usage; keep teams small; clean up when done; enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

---

### OpenTelemetry monitoring

**Enable telemetry**:
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key configuration variables**:

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | off | Required to enable telemetry |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000ms | Metrics export interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000ms | Logs export interval |
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt content in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include tool args/names in events |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool input/output in spans |
| `OTEL_LOG_RAW_API_BODIES` | off | Emit full API request/response bodies |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include session.id in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include user account IDs in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | false | Include app.version in metrics |

**Traces (beta)**: set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`

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

**Key events**: `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.skill_activated`

Use `prompt.id` (UUID) to correlate all events from a single user prompt.

---

### Error reference (quick lookup)

**Automatic retries**: up to 10 attempts with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com; retry; `/feedback` |
| `API Error: Repeated 529 Overloaded errors` | Server | Check status.claude.com; try `/model` to switch models |
| `Request timed out` | Server | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session limit` | Usage | Wait for reset; `/extra-usage`; upgrade plan |
| `Request rejected (429)` | Usage | Check `/status` for stale API key; reduce concurrency |
| `Credit balance is too low` | Usage | Add credits at Console billing; enable auto-reload |
| `Not logged in · Please run /login` | Auth | Run `/login`; check `ANTHROPIC_API_KEY` is set |
| `Invalid API key` | Auth | Check for typos; run `env | grep ANTHROPIC`; try `/login` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; relaunch |
| `OAuth token revoked / expired` | Auth | Run `/logout` then `/login` |
| `Unable to connect to API` | Network | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS`; see network-config |
| `Prompt is too long` | Request | `/compact`; `/context` to review window; disable unused MCP |
| `Request too large (max 30 MB)` | Request | Press Esc twice; reference large files by path |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `thinking.type.enabled is not supported` | Request | `claude update` to v2.1.111+; or switch model |
| `max_tokens must be greater than thinking.budget_tokens` | Request | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` or press Esc twice |

**Response quality issues**: run `/model` (check model), `/effort` (check reasoning level), `/context` (check window fullness), `/doctor` (check stale instructions). Rewind rather than correcting in-thread.

---

### Troubleshooting (installation)

**Common install errors**:

| Symptom | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; see Verify your PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; try Homebrew/WinGet |
| `Killed` during install on Linux | Add 2 GB swap: `fallocate -l 2G /swapfile` |
| TLS/SSL errors | `NODE_EXTRA_CA_CERTS=/path/to/ca.pem`; update CA certs |
| `Error loading shared library` | musl/glibc mismatch; check with `ldd /bin/ls` |
| `Illegal instruction` on Linux | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; try Homebrew |

**Config file locations**:

| File | Purpose |
| :--- | :--- |
| `~/.claude/settings.json` | User settings (hooks, permissions, model) |
| `.claude/settings.json` | Project settings (commit to repo) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

---

### Configuration debugging

**Diagnostic commands**:

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, skills, MCP, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics: invalid keys, schema errors, installation health |
| `/status` | Active settings sources and managed settings status |

**Common config issues**:

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use `"Edit\|Write"` not `["Edit", "Write"]` |
| Hook never fires | Lowercase matcher (`"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Global settings ignored | Config added to `~/.claude.json` | Use `~/.claude/settings.json` for hooks/permissions/env |
| Settings value ignored | Same key in `settings.local.json` | Local overrides project overrides user |
| Skill missing from `/skills` | Skill is at `.claude/skills/name.md` | Must be in folder: `.claude/skills/name/SKILL.md` |
| MCP server in `.mcp.json` never loads | `.mcp.json` inside `.claude/` | Place at repo root, not inside `.claude/` |
| Project MCP server not appearing | One-time approval dismissed | Run `/mcp` and approve |

---

### What's new (recent digests)

| Week | Dates | Key features |
| :--- | :--- | :--- |
| Week 15 | April 6–10, 2026 (v2.1.92–v2.1.101) | Ultraplan cloud planning, Monitor tool, self-pacing `/loop`, `/team-onboarding`, `/autofix-pr` |
| Week 14 | March 30 – April 3, 2026 (v2.1.86–v2.1.91) | Computer use in CLI, `/powerup` lessons, flicker-free rendering, per-tool MCP result-size override (up to 500K), plugin executables on Bash PATH |
| Week 13 | March 23–27, 2026 (v2.1.83–v2.1.85) | Auto mode (research preview), computer use in Desktop app, PR auto-fix on Web, transcript search with `/`, native PowerShell tool, conditional `if` hooks |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API customers, contribution metrics, PR attribution, GitHub integration
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking, spend limits, rate limit recommendations, context reduction strategies, agent team costs
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, all metrics and events, span schema, traces beta, dynamic headers, multi-team support
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnosing CLAUDE.md, settings, hooks, MCP, and skills loading issues; common cause table
- [Troubleshooting](references/claude-code-troubleshooting.md) — Installation issues, platform-specific fixes, authentication problems, performance, IDE integration
- [Error reference](references/claude-code-errors.md) — All runtime errors with causes and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version history and bug fix details
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use (Desktop), PR auto-fix, transcript search, PowerShell tool
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — Computer use (CLI), interactive lessons, rendering improvements, MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, self-pacing loop, team onboarding, PR auto-fix CLI

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
