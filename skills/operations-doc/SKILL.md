---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, troubleshooting, and tracking costs in Claude Code.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Includes |
| :--- | :------------ | :------- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub integration), leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics setup** (Teams/Enterprise only): install GitHub app at github.com/apps/claude, then enable in claude.ai/admin-settings/claude-code. Data appears within 24 hours. Not available with Zero Data Retention.

**PR attribution**: PRs tagged `claude-code-assisted` if they contain at least one line of Claude Code output. Attribution window: 21 days before to 2 days after merge. Excluded: lock files, generated code, build dirs, lines over 1,000 chars, code rewritten more than 20%.

### Cost tracking and management

| Command | Purpose |
| :------ | :------- |
| `/usage` | Session token counts and estimated cost |
| `/usage-credits` | Buy additional usage credits |
| `/model` | Switch to a cheaper model mid-session |
| `/effort` | Adjust thinking level (lower = cheaper) |
| `/compact` | Summarize conversation to free context |
| `/clear` | Start fresh context |
| `/context` | See what's consuming context tokens |

**Average enterprise cost**: ~$13/developer/active day, $150–250/month. 90th percentile stays under $30/active day.

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :-------- | :----------- | :----------- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**
- Use Sonnet for most tasks; reserve Opus for complex reasoning
- Keep CLAUDE.md under 200 lines; move specialized instructions into skills (load on demand)
- Disable unused MCP servers (`/mcp disable <name>`)
- Use `DISABLE_AUTO_COMPACT` off (auto-compact saves tokens)
- Lower `MAX_THINKING_TOKENS` for simpler tasks
- Delegate verbose operations (tests, log parsing) to subagents
- Agent teams use ~7x more tokens than standard sessions

### OpenTelemetry monitoring (quick start)

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
| :------- | :---------- | :------ |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry | off |
| `OTEL_METRICS_EXPORTER` | Metrics sink | — |
| `OTEL_LOGS_EXPORTER` | Events/logs sink | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt text in events | off |
| `OTEL_LOG_TOOL_DETAILS` | Include Bash commands, MCP names, file paths | off |
| `OTEL_LOG_TOOL_CONTENT` | Include full tool input/output in trace spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full Messages API request/response bodies | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include account UUID/ID in metrics | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version in metrics | false |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Enable distributed trace spans (beta) | off |

**Admin deployment** (managed settings file):
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector.example.com:4317",
    "OTEL_EXPORTER_OTLP_HEADERS": "Authorization=Bearer example-token"
  }
}
```

**Exported metrics:**

| Metric | Unit | Key extra attributes |
| :----- | :--- | :------------------- |
| `claude_code.session.count` | count | `start_type` (fresh/resume/continue) |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.pull_request.count` | count | — |
| `claude_code.commit.count` | count | — |
| `claude_code.cost.usage` | USD | `model`, `query_source`, `speed`, `effort`, `agent.name`, `skill.name`, `plugin.name` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model`, `query_source` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | s | `type` (user/cli) |

**Exported events** (via `OTEL_LOGS_EXPORTER`):

| Event name | Fires when |
| :--------- | :--------- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes |
| `claude_code.tool_decision` | Tool permission accepted/rejected |
| `claude_code.api_request` | API call to Claude |
| `claude_code.api_error` | API call fails |
| `claude_code.api_retries_exhausted` | All retries failed |
| `claude_code.api_request_body` | Per-attempt body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_response_body` | Per-response body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.permission_mode_changed` | Mode changes (plan, auto, etc.) |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects/fails |
| `claude_code.plugin_installed` | Plugin install finishes |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.at_mention` | `@`-mention resolved |
| `claude_code.compaction` | Conversation compacted |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` | Hooks begin executing for an event |
| `claude_code.hook_execution_complete` | All hooks for an event finish |
| `claude_code.hook_plugin_metrics` | Official-marketplace plugin emits metrics |
| `claude_code.internal_error` | Unexpected internal error caught |
| `claude_code.feedback_survey` | Session quality survey shown/answered |

All events share standard attributes: `session.id`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`, `app.version`. Events also carry `prompt.id` linking all events from a single user prompt.

**Trace span hierarchy** (beta, requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`):
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

**Security/SIEM mapping:**

| Signal | Event | Key attributes |
| :----- | :---- | :------------- |
| Tool allowed or denied | `tool_decision` | `decision`, `source`, `tool_name` |
| Permission mode escalation | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Policy hook blocked action | `hook_execution_complete` | `hook_event`, `num_blocking` |
| Login/logout/auth failure | `auth` | `action`, `success`, `error_category` |
| MCP connect or failure | `mcp_server_connection` | `status`, `server_name`, `error_code` |
| Plugin installed | `plugin_installed` | `plugin.name`, `marketplace.name` |
| Commands/files touched | `tool_result` with `OTEL_LOG_TOOL_DETAILS=1` | `tool_parameters`, `tool_input` |

### Error reference (quick lookup)

| Error message | Category | First action |
| :------------ | :------- | :----------- |
| `API Error: 500` | Server | Check status.claude.com; retry |
| `Repeated 529 Overloaded` | Server | Wait; `/model` to switch models |
| `Request timed out` | Server | Retry; raise `API_TIMEOUT_MS` if slow network |
| `You've hit your session/weekly limit` | Usage limits | Wait for reset time; `/usage-credits` |
| `Request rejected (429)` | Rate limit | Check `/status`; reduce concurrency |
| `Credit balance is too low` | Billing | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check key in Console; unset stale `ANTHROPIC_API_KEY` |
| `OAuth token revoked/expired` | Auth | `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy; set `HTTPS_PROXY`; verify firewall |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS` to your CA bundle |
| `Prompt is too long` | Request | `/compact`, `/clear`, disable unused MCP servers |
| `Request too large` | Request | Esc twice; reference large files by path |
| `There's an issue with the selected model` | Request | `/model` to pick available model |
| Responses seem lower quality | Quality | Check `/model`, `/effort`, `/context` fullness |

**Automatic retries**: Claude Code retries transient errors up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default: 10) and `API_TIMEOUT_MS` (default: 600000 ms).

### Configuration debugging commands

| Command | What it shows |
| :------ | :------------ |
| `/context` | Everything in the current context window by category |
| `/memory` | Loaded CLAUDE.md and rules files |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics (invalid keys, schema errors) |
| `/status` | Active settings sources; which credential is active |
| `/debug [issue]` | Enable debug logging and diagnose |

**Clean-config test** (bypass all user/project config):
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**Common config gotchas:**

| Symptom | Cause | Fix |
| :------ | :---- | :-- |
| Hook never fires | `matcher` is a JSON array | Use `"Edit\|Write"` string form |
| Hook never fires | Lowercase matcher (`"bash"`) | Capitalize: `Bash`, `Edit`, `Write` |
| Settings key ignored | Same key in `settings.local.json` | `local.json` wins over `settings.json` |
| Skill missing from `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP server loads but no tools | One-time approval dismissed | Run `/mcp` to approve |
| MCP server env vars missing | `env` in `settings.json` doesn't propagate | Set `env` inside `.mcp.json` instead |

### Troubleshooting performance issues

| Issue | Fix |
| :---- | :-- |
| High CPU/memory | `/compact` regularly; add build dirs to `.gitignore`; restart between major tasks |
| Memory stays high | `/heapdump` writes heap snapshot to `~/Desktop` |
| Auto-compact thrashing | Read oversized files in chunks; `/compact` with focus; move to subagent |
| Command hangs | Ctrl+C to cancel; restart terminal; `claude --resume` to continue |
| Search not finding files | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Keep project on Linux filesystem (`/home/`); use more specific search queries |

### Installation troubleshooting (quick lookup)

| Error | Fix |
| :---- | :-- |
| `command not found: claude` | Add `~/.local/bin` to PATH; see Verify your PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML (region unavailable, or retry) |
| `Killed` on Linux VPS | Add 2 GB swap; Claude Code needs 4 GB RAM |
| TLS / SSL errors | `NODE_EXTRA_CA_CERTS=/path/to/ca.pem`; or `--cacert` during install |
| `Error loading shared library` | musl/glibc binary mismatch; check with `ldd --version` |
| `Illegal instruction` | CPU lacks AVX; or architecture mismatch |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; update macOS |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `OAuth error: Invalid code` | Code expired; retry `/login` quickly; copy URL with `c` |
| `403 Forbidden` after login | Verify subscription at claude.ai/settings |
| Bedrock/Vertex creds not loading | Ensure CLI auth: `aws sts get-caller-identity` / `gcloud auth application-default login` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — usage dashboards, contribution metrics, GitHub integration, and PR attribution for Teams and Enterprise
- [Manage Costs](references/claude-code-costs.md) — track token usage, set spend limits, rate limit guidance, and reduce token consumption
- [Monitoring Usage (OpenTelemetry)](references/claude-code-monitoring-usage.md) — full OTel configuration, all metrics and events, trace spans, SIEM integration, and security auditing
- [Debug Your Configuration](references/claude-code-debug-your-config.md) — diagnose why settings, hooks, MCP servers, or skills aren't taking effect
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, hangs, auto-compact thrashing, search problems
- [Troubleshoot Installation and Login](references/claude-code-troubleshoot-install.md) — PATH, permission, TLS, and authentication errors during install and login
- [Error Reference](references/claude-code-errors.md) — full list of runtime error messages with causes and recovery steps
- [Changelog](references/claude-code-changelog.md) — release notes for all Claude Code versions
- [What's New Index](references/claude-code-whats-new-index.md) — weekly digest of notable features
- [What's New: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, PowerShell tool, conditional hooks
- [What's New: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, `/powerup`, MCP result-size override
- [What's New: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/autofix-pr`
- [What's New: Week 16](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, Routines, `/effort`, native binaries
- [What's New: Week 17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes
- [What's New: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`
- [What's New: Week 19](references/claude-code-whats-new-2026-w19.md) — plugins from `.zip`/URLs, `worktree.baseRef`, auto mode hard deny rules
- [What's New: Week 20](references/claude-code-whats-new-2026-w20.md) — agent view (`claude agents`), `/goal`, fast mode on Opus 4.7, Rewind "Summarize up to here"

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs: https://code.claude.com/docs/en/costs.md
- Monitoring Usage: https://code.claude.com/docs/en/monitoring-usage.md
- Debug Your Configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot Installation and Login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error Reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New Index: https://code.claude.com/docs/en/whats-new/index.md
- What's New Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's New Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's New Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
