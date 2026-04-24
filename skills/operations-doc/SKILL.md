---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards, cost tracking, OpenTelemetry monitoring, config debugging, troubleshooting installation and runtime errors, error reference, changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and monitoring Claude Code.

## Quick Reference

### Analytics dashboards

| Plan | URL | What's included |
| :--- | :--- | :--- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, per-user insights |

**Contribution metrics** (Teams/Enterprise): requires installing the GitHub app at [github.com/apps/claude](https://github.com/apps/claude) and enabling GitHub analytics in Claude admin settings. Data appears within 24 hours. Not available with Zero Data Retention.

**PR attribution window**: sessions from 21 days before to 2 days after merge date are considered. Code with more than 20% deviation from Claude output is not attributed.

### Cost management

| Tool | Notes |
| :--- | :--- |
| `/usage` | Session token usage + estimated cost (subscribers see plan bars) |
| `/clear` | Start fresh; stale context wastes tokens on every message |
| `/compact [focus]` | Summarize conversation; add focus to control what is kept |
| `/effort` | Adjust extended thinking level; lower effort = fewer tokens |
| `/model` | Switch to Sonnet for most tasks; reserve Opus for complex reasoning |
| `/context` | See what is consuming context space |

**Average enterprise cost**: ~$13/developer/active day; ~$150–250/developer/month.

**Rate limit recommendations by team size** (TPM / RPM per user):

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Token reduction strategies**:
- Use `/compact` and `/clear` between unrelated tasks
- Prefer Sonnet; use Haiku for simple subagent tasks (`model: haiku` in subagent frontmatter)
- Disable unused MCP servers with `/mcp disable <name>`
- Use PreToolUse hooks to preprocess verbose tool output before Claude sees it
- Move specialized CLAUDE.md instructions into skills (skills load on-demand; CLAUDE.md loads every session)
- Set `MAX_THINKING_TOKENS=8000` to cap extended thinking budget
- Use `--dangerously-disable-sandbox` on Bedrock/Vertex where metrics aren't sent; use LiteLLM for spend tracking there

### OpenTelemetry monitoring

**Required env var**: `CLAUDE_CODE_ENABLE_TELEMETRY=1`

**Common configuration variables**:

| Variable | Values / Notes |
| :--- | :--- |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | e.g. `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | e.g. `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | ms; default 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | ms; default 5000 |
| `OTEL_LOG_USER_PROMPTS` | `1` to include prompt content (redacted by default) |
| `OTEL_LOG_TOOL_DETAILS` | `1` to include bash commands, file paths, skill/MCP names |
| `OTEL_LOG_TOOL_CONTENT` | `1` to include tool input/output (requires tracing) |
| `OTEL_LOG_RAW_API_BODIES` | `1` (inline, 60KB truncated) or `file:<dir>` (untruncated on disk) |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` (default) |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` (default) |

**Distributed traces (beta)**: also set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`.

**Span hierarchy**:
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

**Exported metrics**:

| Metric | Unit | Description |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines modified (type: added/removed) |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Per-API-request cost estimate |
| `claude_code.token.usage` | tokens | Token usage (type: input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept/reject decisions |
| `claude_code.active_time.total` | s | Active time (type: user/cli) |

**Exported events**: `user_prompt`, `tool_result`, `api_request`, `api_error`, `api_request_body`, `api_response_body`, `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `internal_error`, `plugin_installed`, `skill_activated`, `api_retries_exhausted`, `hook_execution_start`, `hook_execution_complete`, `compaction`.

All metrics and events share standard attributes: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

**Multi-team segmentation**: set `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values; use `_` or percent-encoding).

### Debug your configuration

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills and their sources |
| `/hooks` | Active hook configurations |
| `/mcp` | MCP server statuses |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics, invalid keys, installation health |
| `/status` | Active settings sources, managed settings status |

**Common config pitfalls**:

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a single string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase matcher e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hook defined in standalone file | Define under `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Config added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| `settings.json` value ignored | Same key in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill missing from `/skills` | Skill at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP servers in `.mcp.json` not loading | File is under `.claude/` | Put `.mcp.json` at the repo root |
| Project MCP server not available | Approval prompt was dismissed | Run `/mcp` and approve it |

### Troubleshooting installation

**Quick diagnosis**: `claude doctor` — checks install, search, settings, MCP, plugins.

**Common errors**:

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install script returns HTML | Network/region issue; try Homebrew/WinGet |
| `Killed` during Linux install | Add 2GB+ swap; Claude Code requires 4GB RAM |
| `dyld: cannot load` on macOS | Requires macOS 13+; try Homebrew |
| `Error loading shared library` (Linux) | musl/glibc mismatch; `apk add libgcc libstdc++ ripgrep` on Alpine |
| `TLS connect error` | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `403 Forbidden` after login | Check subscription; ensure "Claude Code" or "Developer" role |
| `ANTHROPIC_API_KEY` org disabled | Unset `ANTHROPIC_API_KEY`; run `/login` for subscription auth |
| Search/`@file` not working | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |

**Config file locations**:

| File | Purpose |
| :--- | :--- |
| `~/.claude/settings.json` | User settings (permissions, hooks, model) |
| `.claude/settings.json` | Project settings (checked in) |
| `.claude/settings.local.json` | Local overrides (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers (checked in) |

### Runtime error quick reference

| Error | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Retry; check status.claude.com; run `/feedback` |
| `Repeated 529 Overloaded` | Server | Wait; switch model with `/model` |
| `Request timed out` | Server / Network | Retry; break into smaller tasks; raise `API_TIMEOUT_MS` |
| `You've hit your session limit` | Usage | Wait for reset; run `/extra-usage`; upgrade plan |
| `Request rejected (429)` | Usage | Check rate limits in Console; reduce `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Usage | Add credits at platform.claude.com; enable auto-reload |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for stale `ANTHROPIC_API_KEY`; run `env \| grep ANTHROPIC` |
| `OAuth token revoked/expired` | Auth | Run `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy (`HTTPS_PROXY`); verify `curl -I https://api.anthropic.com` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS` to CA bundle |
| `Prompt is too long` | Request | Run `/compact` or `/clear`; disable unused MCP servers |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| Responses seem lower quality | Quality | Check `/model`, `/effort`, `/context`; use `/rewind` to step back past bad turn |

**Retry behavior**: Claude Code retries server errors, 529, timeouts, and transient 429s up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

### Recent releases (as of April 2026)

| Week / Version | Highlights |
| :--- | :--- |
| Week 15 (v2.1.92–v2.1.101) | Ultraplan cloud planning preview, Monitor tool for background event streaming, `/loop` self-pacing, `/autofix-pr`, `/team-onboarding` |
| Week 14 (v2.1.86–v2.1.91) | Computer use in CLI (research preview), `/powerup` interactive lessons, flicker-free alt-screen rendering, MCP per-tool result-size override (500K chars), plugin bin/ on PATH |
| Week 13 (v2.1.83–v2.1.85) | Auto mode (research preview), computer use in Desktop, PR auto-fix on Web, transcript search with `/`, PowerShell tool, conditional `if` hooks |
| v2.1.119 | `/config` settings persist to settings.json; `prUrlTemplate`; hooks `PostToolUse` includes `duration_ms`; OTel `tool_result` includes `tool_use_id` and `tool_input_size_bytes` |
| v2.1.118 | Vim visual mode; `/cost` + `/stats` merged into `/usage`; custom themes; hooks can invoke MCP tools (`type: "mcp_tool"`); `DISABLE_UPDATES` env var |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — dashboards for Teams/Enterprise and API customers, contribution metrics, PR attribution, GitHub integration, data export
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, workspace spend limits, rate limit recommendations by team size, token reduction strategies, agent team costs
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, all metrics and events, span hierarchy for distributed traces, backend options, security and privacy
- [Debug your configuration](references/claude-code-debug-your-config.md) — `/context`, `/memory`, `/hooks`, `/mcp`, `/doctor`, `/status`, and a table of common config pitfalls with fixes
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation errors, PATH issues, authentication issues, performance, IDE integration, WSL setup
- [Error reference](references/claude-code-errors.md) — runtime error messages, automatic retry behavior, server/usage/auth/network/request errors, response quality checks
- [Changelog](references/claude-code-changelog.md) — full version-by-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index linking to weekly feature summaries
- [What's new: Week 15 (April 6–10, 2026)](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /autofix-pr, /team-onboarding
- [What's new: Week 14 (March 30 – April 3, 2026)](references/claude-code-whats-new-2026-w14.md) — Computer use in CLI, /powerup, flicker-free rendering, MCP result-size override
- [What's new: Week 13 (March 23–27, 2026)](references/claude-code-whats-new-2026-w13.md) — Auto mode, PR auto-fix, transcript search, PowerShell tool, conditional hooks

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
