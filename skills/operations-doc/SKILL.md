---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards, cost management, OpenTelemetry monitoring, error reference, troubleshooting, configuration debugging, changelog, and what's new.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code in individual, team, and enterprise environments.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Includes |
| :--- | :------------ | :------- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Usage metrics, spend, per-user insights |

Contribution metrics require a GitHub app install and are in public beta. They are not available with Zero Data Retention. Attribution uses a 21-day look-back window; PRs with at least one Claude Code-assisted line are labeled `claude-code-assisted` in GitHub.

### Cost tracking and management

**Key commands**

| Command | Purpose |
| :------ | :------ |
| `/cost` (or `/usage`) | Show token usage and estimated spend for the current session (API users) |
| `/stats` (or `/usage`) | View usage patterns (subscription users) |
| `/compact` | Summarize history to free context window |
| `/clear` | Start a fresh context |
| `/context` | See what is consuming context |
| `/model` | Switch models mid-session |
| `/effort` | Adjust reasoning level |

**Average enterprise costs:** ~$13/developer/active day, $150–250/month; 90% of users stay under $30/active day.

**Rate limit recommendations (API, per user)**

| Team size | TPM per user | RPM per user |
| :-------- | :----------- | :----------- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Top cost-reduction strategies**

- Clear context between unrelated tasks (`/clear`, then `/rename` first so you can `/resume` later)
- Use Sonnet for most tasks; reserve Opus for complex reasoning
- Move bulk/verbose operations to subagents so large output stays out of the main context
- Move specialized CLAUDE.md sections to on-demand skills (keep CLAUDE.md under 200 lines)
- Disable unused MCP servers; prefer CLI tools (gh, aws) over MCP where available
- Lower `MAX_THINKING_TOKENS` or use `/effort low` for simpler tasks
- Use plan mode (Shift+Tab) before implementation to avoid expensive re-work
- Agent teams use ~7x more tokens than standard sessions; keep teams small

**Agent team token tips:** use Sonnet for teammates, keep teams small, write focused spawn prompts, clean up teams when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

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

**Key OTel environment variables**

| Variable | Description | Default |
| :------- | :---------- | :------ |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | — |
| `OTEL_TRACES_EXPORTER` | Traces exporter (beta) | — |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Enable distributed traces | off |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | off |
| `OTEL_LOG_TOOL_DETAILS` | Log tool parameters and names | off |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include account UUID in metrics | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version in metrics | false |

**Exported metrics**

| Metric | Unit | Notes |
| :----- | :--- | :---- |
| `claude_code.session.count` | count | Attributes: `start_type` (fresh/resume/continue) |
| `claude_code.token.usage` | tokens | Attributes: `type` (input/output/cacheRead/cacheCreation), `model`, `query_source`, `speed`, `effort` |
| `claude_code.cost.usage` | USD | Per API request; attributes: `model`, `query_source`, `speed`, `effort` |
| `claude_code.lines_of_code.count` | count | Attributes: `type` (added/removed) |
| `claude_code.commit.count` | count | — |
| `claude_code.pull_request.count` | count | — |
| `claude_code.code_edit_tool.decision` | count | Attributes: `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | s | Attributes: `type` (user/cli) |

**Exported log events:** `user_prompt`, `tool_result`, `api_request`, `api_error`, `api_request_body`, `api_response_body`, `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `internal_error`, `plugin_installed`, `skill_activated`, `api_retries_exhausted`, `hook_execution_start`, `hook_execution_complete`, `compaction`

**Trace span hierarchy (beta)**

```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

Propagates W3C `TRACEPARENT` to child processes. In `-p`/SDK sessions, reads inbound `TRACEPARENT` to nest under caller's trace.

### Error reference (runtime errors)

**Server errors**

| Message | Cause | Fix |
| :------ | :---- | :-- |
| `API Error: 500 Internal server error` | Anthropic infrastructure failure | Check status.claude.com; retry; run `/feedback` |
| `API Error: Repeated 529 Overloaded errors` | Capacity across all users | Wait; switch model with `/model` |
| `Request timed out` | No response before deadline (10 min default) | Retry; raise `API_TIMEOUT_MS`; break into smaller prompts |

**Usage limit errors**

| Message | Cause | Fix |
| :------ | :---- | :-- |
| `You've hit your session limit` | Plan quota exhausted | Wait for reset; `/usage` to check limits; `/extra-usage` to buy more |
| `Server is temporarily limiting requests` | Short-lived server throttle | Wait briefly; check status.claude.com |
| `Request rejected (429)` | API key / workspace rate limit | Check `/status`; raise tier; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console prepaid credits exhausted | Add credits at platform.claude.com/settings/billing |

**Authentication errors**

| Message | Fix |
| :------ | :-- |
| `Not logged in · Please run /login` | Run `/login`; check `ANTHROPIC_API_KEY` is exported |
| `Invalid API key` | Check key in Console; run `env | grep ANTHROPIC`; unset stale key |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY`; re-run `/login` |
| `OAuth token revoked / expired` | Run `/logout` then `/login` |
| `OAuth token does not meet scope requirement` | Run `/login` to mint a new token |

**Network errors**

| Message | Fix |
| :------ | :-- |
| `Unable to connect to API` | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS`; see network-config docs |

**Request errors**

| Message | Fix |
| :------ | :-- |
| `Prompt is too long` | `/compact` or `/clear`; check `/context`; disable unused MCP |
| `Error during compaction: Conversation too long` | Press Esc twice to step back; then `/compact` again |
| `Request too large (max 30 MB)` | Press Esc twice; reference files by path instead of pasting |
| `Image was too large` | Press Esc twice; resize to under 8000px on longest edge |
| `PDF too large` / `PDF is password protected` | Extract text first or read page range with Read tool |
| `Extra inputs are not permitted` | Gateway is stripping `anthropic-beta` header; set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` as fallback |
| `There's an issue with the selected model` | Run `/model`; use an alias (sonnet, opus) instead of versioned ID |
| `thinking.type.enabled is not supported` | Run `claude update` to v2.1.111+; or switch to an older model |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` or press Esc twice to restore conversation |

**Retry behavior:** Claude Code retries transient failures up to 10 times with exponential backoff (tune with `CLAUDE_CODE_MAX_RETRIES`, default 10; `API_TIMEOUT_MS`, default 600000).

### Troubleshooting: installation issues

| Symptom | Fix |
| :------ | :-- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install script returns HTML | Regional block or network issue; try Homebrew / WinGet |
| `Killed` during install on Linux | Add 2 GB swap; need 4 GB RAM minimum |
| `Error loading shared library` | musl/glibc mismatch; check `ldd /bin/ls` |
| `Illegal instruction` | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13+; try Homebrew |
| TLS / SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` |
| Windows: `irm` not recognized | Use PowerShell, not CMD |
| Install hangs in Docker | Set `WORKDIR /tmp` before installer |

### Debug your configuration

**Diagnostic commands**

| Command | Shows |
| :------ | :---- |
| `/context` | Everything in the context window, by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics: invalid keys, schema errors, install health |
| `/status` | Active settings sources, managed settings status |

**Common config surprises**

| Symptom | Cause | Fix |
| :------ | :---- | :-- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use `"Edit\|Write"` string with `\|` separator |
| Hook never fires | Lowercase matcher (e.g. `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks in a standalone `.claude/hooks.json` | Define under `"hooks"` key in `settings.json` |
| Settings key ignored | Same key in `settings.local.json` overrides it | Check local scope; `settings.local.json` wins over `settings.json` |
| Settings in `~/.claude.json` ignored | Wrong file — that's app state, not config | Put `permissions`, `hooks`, `env` in `~/.claude/settings.json` |
| Skill missing from `/skills` | File at `.claude/skills/name.md` not in a folder | Use `.claude/skills/name/SKILL.md` |
| MCP server not loading | `.mcp.json` is inside `.claude/` | Put it at the repo root as `.mcp.json` |
| MCP server requires re-approval | One-time approval was dismissed | Run `/mcp` and approve |
| MCP server fails from some dirs | Relative path in `command`/`args` | Use absolute paths for local scripts |

Settings scope priority (highest to lowest): managed settings → `settings.local.json` → project `settings.json` → user `~/.claude/settings.json`.

### Changelog and what's new

- Run `claude --version` to check your installed version.
- Latest release as of April 2026 (v2.1.118): vim visual mode, `/cost` and `/stats` merged into `/usage`, custom themes from `/theme`, hooks can invoke MCP tools via `type: "mcp_tool"`, `DISABLE_UPDATES` env var, WSL inherits Windows-side managed settings, and more.
- Weekly digests cover notable features with demos; the full changelog covers every fix.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — dashboard access, contribution metrics setup, PR attribution, leaderboard, CSV export, and how to measure ROI
- [Manage costs effectively](references/claude-code-costs.md) — token tracking, team spend limits, rate limit recommendations, and strategies to reduce context and token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — full OTel configuration, all metrics and events, span hierarchy, dynamic headers, multi-team segmentation, and backend recommendations
- [Error reference](references/claude-code-errors.md) — every runtime error message with cause and recovery steps, plus retry behavior
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation issues, PATH fixes, authentication problems, configuration file locations, performance, IDE integration, and WSL issues
- [Debug your configuration](references/claude-code-debug-your-config.md) — using /context, /doctor, /hooks, /mcp to see what loaded; common causes table for config surprises
- [Changelog](references/claude-code-changelog.md) — full release notes by version number
- [What's new (index)](references/claude-code-whats-new-index.md) — weekly digest index linking to per-week feature highlights
- [What's new: Week 13 (2026)](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, PR auto-fix on Web, transcript search, PowerShell tool, conditional hooks
- [What's new: Week 14 (2026)](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, /powerup lessons, per-tool MCP result-size override, plugin executables on PATH
- [What's new: Week 15 (2026)](references/claude-code-whats-new-2026-w15.md) — Ultraplan preview, Monitor tool, /loop self-pacing, /team-onboarding, /autofix-pr

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new (index): https://code.claude.com/docs/en/whats-new/index.md
- What's new: Week 13 (2026): https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new: Week 14 (2026): https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 15 (2026): https://code.claude.com/docs/en/whats-new/2026-w15.md
