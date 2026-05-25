---
name: operations-doc
description: Complete official documentation for Claude Code operations — tracking team usage with analytics dashboards (Teams/Enterprise and API/Console), managing costs and token usage, monitoring with OpenTelemetry (metrics, events, traces, SIEM export), debugging configuration (CLAUDE.md, settings, hooks, MCP, skills), troubleshooting installation and login, runtime error reference, and the changelog/weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, debugging, troubleshooting, and error recovery.

## Quick Reference

### Analytics Dashboards

| Plan | URL | What's included |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub integration), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user insights |

Contribution metrics require: GitHub app installed at github.com/apps/claude + Owner enables GitHub analytics in admin settings. Data appears within 24 hours. Not available with Zero Data Retention.

**Key metrics**: PRs with CC, lines of code with CC (%), suggestion accept rate, lines of code accepted, daily active users, sessions, PRs per user.

**PR attribution**: Sessions within 21 days before to 2 days after merge are considered. Lines with >20% developer rewrite are not attributed. Lock files, build artifacts, and minified code are excluded.

### Cost Management

| Strategy | How |
| :--- | :--- |
| Check usage | `/usage` — shows token counts and estimated cost for the session |
| Clear stale context | `/clear` between unrelated tasks; `/compact Focus on X` to preserve specifics |
| Choose the right model | `/model` — Sonnet for most tasks, Opus for complex reasoning, Haiku for subagents |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools (`gh`, `aws`) over MCP |
| Move instructions to skills | Keep CLAUDE.md under 200 lines; move specialized workflows to skills (load on-demand) |
| Adjust thinking | Lower effort with `/effort`, disable in `/config`, or set `MAX_THINKING_TOKENS=8000` |
| Delegate verbose ops | Use subagents so large outputs stay in their context; only summary returns |
| Specific prompts | "add input validation to auth.ts" not "improve this codebase" |
| Plan mode | Shift+Tab before implementation to avoid expensive re-work |

**Rate limit recommendations (TPM per user)**:

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

Average enterprise cost: ~$13/developer/active day, $150–250/month. Agent teams use ~7x more tokens than standard sessions.

### OpenTelemetry Monitoring

**Minimal setup**:
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables**:

| Variable | Description |
| :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry. Set to `1` |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, or `none` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, or `none` |
| `OTEL_TRACES_EXPORTER` | Requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/protobuf`, `http/json` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers, e.g. `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Default 60000ms |
| `OTEL_LOGS_EXPORT_INTERVAL` | Default 5000ms |
| `OTEL_LOG_USER_PROMPTS` | Set `1` to include prompt text (redacted by default) |
| `OTEL_LOG_TOOL_DETAILS` | Set `1` to include Bash commands, MCP server/tool names, skill names |
| `OTEL_LOG_TOOL_CONTENT` | Set `1` to include tool input/output in trace spans (60 KB truncation) |
| `OTEL_LOG_RAW_API_BODIES` | `1` for inline (60 KB truncated), `file:<dir>` for untruncated to disk |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Default `true` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Default `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | Default `false` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes, e.g. `department=eng,team.id=platform` (no spaces in values) |

**Available metrics**:

| Metric | Description |
| :--- | :--- |
| `claude_code.session.count` | Sessions started |
| `claude_code.lines_of_code.count` | Lines added/removed |
| `claude_code.pull_request.count` | PRs created |
| `claude_code.commit.count` | Git commits created |
| `claude_code.cost.usage` | API cost in USD |
| `claude_code.token.usage` | Tokens used (by type: input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject counts |
| `claude_code.active_time.total` | Active time in seconds |

**Available events** (via `OTEL_LOGS_EXPORTER`): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_request_body`, `claude_code.api_response_body`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.internal_error`, `claude_code.plugin_installed`, `claude_code.plugin_loaded`, `claude_code.skill_activated`, `claude_code.at_mention`, `claude_code.api_retries_exhausted`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`, `claude_code.hook_plugin_metrics`, `claude_code.compaction`, `claude_code.feedback_survey`

**Standard attributes on all metrics/events**: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

**Traces (beta)**: Requires `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`. Bash subprocesses inherit `TRACEPARENT`.

**SIEM export**: Point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver with `OTEL_LOG_TOOL_DETAILS=1` for full MCP and Bash audit trail.

**Security event mapping**:

| Signal | Event | Key attributes |
| :--- | :--- | :--- |
| Tool allowed/denied | `tool_decision` | `decision`, `source`, `tool_name` |
| Permission mode change | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Policy hook blocked | `hook_execution_complete` | `hook_event`, `num_blocking` |
| Login/logout | `auth` | `action`, `success`, `error_category` |
| MCP server connect/fail | `mcp_server_connection` | `status`, `server_name`, `error_code` |
| Plugin installed | `plugin_installed` | `plugin.name`, `marketplace.name`, `marketplace.is_official` |
| Commands/files touched | `tool_result` + `OTEL_LOG_TOOL_DETAILS=1` | `tool_parameters`, `tool_input` |

### Debugging Configuration

**Diagnostic commands**:

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window, by category |
| `/memory` | Loaded CLAUDE.md and rules files |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config validation, schema errors, installation health |
| `/debug [issue]` | Enable debug logging + Claude diagnoses using log output |
| `/status` | Active settings sources and auth method |

**Test with a clean config**:
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**Common configuration problems**:

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase tool name e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks in a standalone file | Hooks go in `settings.json` under `"hooks"` key |
| Global settings ignored | Config in `~/.claude.json` | Use `~/.claude/settings.json` (different file) |
| Settings.json value ignored | Same key in `settings.local.json` | Local overrides project overrides user |
| Skill missing from `/skills` | Flat `.md` file instead of folder | Use `.claude/skills/name/SKILL.md` structure |
| Skill never invoked | `disable-model-invocation: true` | Check `/skills` for "user-only" badge |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loads when Claude reads a file in that directory |
| MCP in `.mcp.json` not loading | File under `.claude/` | `.mcp.json` goes at repo root, not in `.claude/` |
| MCP server fails from some dirs | Relative path in `command`/`args` | Use absolute paths |
| MCP env vars not reaching server | `env` in `settings.json` doesn't propagate | Set `env` inside `.mcp.json` per-server |
| Project MCP server not appearing | One-time approval dismissed | Run `/mcp` to approve |

### Troubleshooting Installation

**Quick error lookup**:

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; see [Verify your PATH](references/claude-code-troubleshoot-install.md) |
| `syntax error near unexpected token '<'` | Install script returned HTML — network/region issue |
| `curl: (22) 403` | Network/proxy blocking downloads.claude.ai |
| `Killed` on Linux | OOM — add swap: `sudo fallocate -l 2G /swapfile` |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corp CA |
| `Illegal instruction` | CPU lacks AVX or architecture mismatch |
| `Exec format error` on WSL | WSL1 regression — convert to WSL2 or use ld workaround |
| `dyld: cannot load` on macOS | Requires macOS 13.0+ |
| `OAuth error: Invalid code` | Code expired — retry quickly or press `c` to copy URL |
| `403 Forbidden` after login | Check subscription active; confirm Developer role in Console |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` overriding subscription — unset it |
| Bedrock/Vertex credentials failing | Run `aws sts get-caller-identity` or `gcloud auth application-default login` |

**Install locations**: `~/.local/bin/claude` (macOS/Linux), `%USERPROFILE%\.local\bin\claude.exe` (Windows)

**Alternative install methods**:
- macOS: `brew install --cask claude-code`
- Windows: `winget install Anthropic.ClaudeCode`

### Runtime Error Reference

**Automatic retries**: Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

**Error quick lookup**:

| Error | Category | Action |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Check status.claude.com; retry; `/feedback` if persistent |
| `529 Overloaded` | Server | Wait; try `/model` to switch to less-loaded model |
| `Request timed out` | Server/Network | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session/weekly limit` | Usage limits | Wait for reset shown; `/usage-credits`; upgrade plan |
| `Request rejected (429)` | Usage limits | Check rate limits in provider console; lower concurrency |
| `Credit balance is too low` | Usage limits | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check key not revoked; run `env \| grep ANTHROPIC` for stale keys |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; use subscription auth |
| `OAuth token revoked/expired` | Auth | `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy; set `HTTPS_PROXY`; verify `ANTHROPIC_BASE_URL` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | `/compact`; `/context` to see usage; disable unused MCP servers |
| `Error during compaction: too long` | Request | Press Esc twice to step back; run `/compact` again |
| `Request too large` | Request | Press Esc twice; reference large files by path |
| `There's an issue with the selected model` | Request | `/model` to pick available model; use aliases like `sonnet` |
| `Routines are disabled by your organization` | Auth | Admin enables in claude.ai/admin-settings/claude-code |
| `host_not_allowed` 403 in cloud session | Network | Edit cloud environment; change network access to Custom |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| Tool use/thinking block mismatch | Request | `/rewind` or Esc twice to step back to checkpoint |
| Usage policy refusal | Request | Esc twice or `/rewind`; rephrase; or `/clear` for fresh session |
| Low response quality | — | Check `/model`, `/effort`, `/context` fullness; `/compact` |

### Recent Releases (What's New)

| Week | Highlights |
| :--- | :--- |
| Week 20 (May 11–15) | `claude agents` view; `/goal` for multi-turn completion conditions; fast mode on Opus 4.7 by default; Rewind menu "Summarize up to here" |
| Week 19 (May 4–8) | Plugins load from `.zip` and URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see `effort.level` |
| Week 18 (Apr 27–May 1) | Windows without Git Bash (PowerShell tool); `claude ultrareview` CLI/CI; `claude project purge`; paste PR URL into `/resume` |
| Week 17 (Apr 20–24) | `/ultrareview` public research preview; session recap; custom themes; Claude Code web redesign |
| Week 16 (Apr 13–17) | Claude Opus 4.7 default; `xhigh` effort level; Routines on web; mobile push notifications; native binaries |
| Week 15 (Apr 6–10) | Ultraplan early preview; Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| Week 14 (Mar 30–Apr 3) | Computer use CLI research preview; `/powerup` lessons; per-tool MCP result-size override up to 500K |
| Week 13 (Mar 23–27) | Auto mode research preview; computer use in Desktop; PR auto-fix on web; transcript search `/`; PowerShell tool; conditional `if` hooks |

Run `claude --version` to check your installed version. Full changelog at [changelog reference](references/claude-code-changelog.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API/Console, contribution metrics setup, PR attribution, GitHub integration, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — usage tracking with `/usage`, team spend limits, rate limit recommendations, agent team costs, context management strategies, model selection, MCP overhead reduction, thinking budget adjustment
- [Monitoring](references/claude-code-monitoring-usage.md) — full OpenTelemetry setup, all configuration variables, metrics catalog, events catalog (20+ event types), distributed traces (beta), span attributes, SIEM integration, security audit patterns, backend recommendations
- [Debug your configuration](references/claude-code-debug-your-config.md) — using `/context`, `/memory`, `/hooks`, `/mcp`, `/doctor`, `/status`; checking settings precedence; testing with a clean config; common configuration problems table
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — error lookup table, network diagnostics, PATH fixes, conflicting installations, TLS/SSL fixes, platform-specific issues (Windows, WSL, Docker, Linux musl/glibc), OAuth and authentication failures, cloud provider credentials
- [Error reference](references/claude-code-errors.md) — all runtime error messages with recovery steps: server errors, usage limits, authentication errors, network/SSL errors, request errors (context, model, thinking, tool), response quality issues
- [Changelog](references/claude-code-changelog.md) — full version-by-version release notes
- [What's New index](references/claude-code-whats-new-index.md) — weekly digest index with highlights per week
- [What's New — Week 20](references/claude-code-whats-new-2026-w20.md) — agent view, /goal, fast mode on Opus 4.7
- [What's New — Week 19](references/claude-code-whats-new-2026-w19.md) — plugin zip/URL loading, worktree.baseRef, auto mode hard deny
- [What's New — Week 18](references/claude-code-whats-new-2026-w18.md) — PowerShell tool, ultrareview CLI, project purge
- [What's New — Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview preview, custom themes, web redesign
- [What's New — Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, native binaries
- [What's New — Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /autofix-pr
- [What's New — Week 14](references/claude-code-whats-new-2026-w14.md) — computer use CLI, /powerup, MCP result-size override
- [What's New — Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, transcript search, PowerShell tool, conditional hooks

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New index: https://code.claude.com/docs/en/whats-new/index.md
- What's New Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's New Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's New Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
