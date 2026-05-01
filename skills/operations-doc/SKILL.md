---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards and contribution metrics, cost tracking and token optimization, OpenTelemetry monitoring and observability, configuration debugging, runtime error reference, installation troubleshooting, and release notes (changelog and weekly digests).
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code — covering analytics, cost management, OpenTelemetry monitoring, debugging, errors, installation troubleshooting, and release notes.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Key metrics |
| :--- | :--- | :--- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, per-user lines and spend |

Contribution metrics require GitHub integration (Owner role + GitHub admin). Data updates daily; appears within 24 hours. Not available with Zero Data Retention enabled.

**PR attribution**: tagged `claude-code-assisted` in GitHub. Session window: 21 days before to 2 days after merge. Lines normalized; code rewritten >20% is not attributed.

### Cost management

| Scope | Action |
| :--- | :--- |
| Check session cost | `/usage` — shows local cost estimate; authoritative billing at [platform.claude.com/usage](https://platform.claude.com/usage) |
| Team spend limits | Console workspace limits at [platform.claude.com](https://platform.claude.com) |
| See token breakdown | `/context` — shows what's consuming the context window |
| Switch model | `/model` — use `sonnet` alias for most tasks; reserve `opus` for complex work |
| Reduce context | `/compact`, `/clear`, `/rename` before clearing |
| Adjust thinking | `/effort` or `MAX_THINKING_TOKENS=8000` to reduce thinking cost |

**Rate limit guidelines (API, TPM per user):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Average enterprise cost**: ~$13/developer/active day; $150–250/developer/month; 90th percentile under $30/active day.

### OpenTelemetry monitoring (quick start)

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

**Key OTel environment variables:**

| Variable | Default | Description |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | off | Required to enable telemetry |
| `OTEL_METRICS_EXPORTER` | — | `otlp`, `prometheus`, `console`, or `none` |
| `OTEL_LOGS_EXPORTER` | — | `otlp`, `console`, or `none` |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000ms | Metrics export interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000ms | Logs export interval |
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt content in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include tool parameters and Bash commands |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool I/O in trace spans (requires tracing) |
| `OTEL_LOG_RAW_API_BODIES` | off | Full Messages API request/response bodies; `=1` inline (60KB), `=file:<dir>` untruncated on disk |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include `user.account_uuid` in metrics |

**Distributed tracing (beta):** also set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`.

**Available metrics:**

| Metric | Unit | Description |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | Sessions started |
| `claude_code.token.usage` | tokens | Tokens used (type: input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage` | USD | Cost per API request |
| `claude_code.lines_of_code.count` | count | Lines added/removed |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.code_edit_tool.decision` | count | Accept/reject decisions on Edit/Write/NotebookEdit |
| `claude_code.active_time.total` | s | Active time (type: user/cli) |

**OTel events** (via `OTEL_LOGS_EXPORTER`): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_request_body`, `claude_code.api_response_body`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.internal_error`, `claude_code.plugin_installed`, `claude_code.skill_activated`, `claude_code.at_mention`, `claude_code.api_retries_exhausted`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`, `claude_code.compaction`.

All events carry `prompt.id` (UUID v4) linking all events for a single user prompt.

### Configuration debugging

| Command | What it shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from project, user, and plugin sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics (invalid keys, schema errors, installation health) |
| `/status` | Active settings sources; whether managed settings are in effect |

**Common configuration gotchas:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | `matcher` is lowercase (`bash`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks in standalone `.claude/hooks.json` | Hooks go under `"hooks"` key in `settings.json` |
| Settings ignored | Set in `~/.claude.json` | Global settings go in `~/.claude/settings.json` |
| `settings.json` value ignored | Overridden by `settings.local.json` | Local file takes precedence over project file |
| Skill missing from `/skills` | Skill file at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Skill not auto-invoked | `disable-model-invocation: true` | Check `/skills` badge; remove flag if Claude should trigger it |
| Subagent ignores CLAUDE.md | Subagents don't always inherit project memory | Put critical rules in the agent file body |
| Project MCP server not loading | One-time approval was dismissed | Run `/mcp` and approve |

### Runtime error quick lookup

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server error | Check [status.claude.com](https://status.claude.com); retry |
| `529 Overloaded` | Server error | Retry in minutes; `/model` to switch models |
| `Request timed out` | Server error | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session limit` | Usage limit | Wait for reset time; `/extra-usage` to buy more |
| `Request rejected (429)` | Rate limit | Check workspace limits; reduce concurrency |
| `Credit balance is too low` | Billing | Add credits at Console billing page |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check key in Console; `env \| grep ANTHROPIC` for stale keys |
| `OAuth token revoked/expired` | Auth | `/login` (or `/logout` then `/login`) |
| `Unable to connect to API` | Network | Check proxy; set `HTTPS_PROXY`; verify `NODE_EXTRA_CA_CERTS` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS` to CA bundle path |
| `Prompt is too long` | Request | `/compact` or `/clear`; disable unused MCP servers |
| `Request too large (max 30 MB)` | Request | Double-press Esc to step back; reference large files by path |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `thinking.type.enabled is not supported` | Request | Run `claude update` to upgrade to v2.1.111+ |

Retries: Claude Code retries up to 10 times with exponential backoff before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

### Installation troubleshooting (quick lookup)

| Symptom | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; restart terminal |
| `syntax error near unexpected token '<'` | Install script returned HTML; try Homebrew/WinGet or retry |
| `curl: (56) Failure writing output` | Network interruption; retry or use `brew install --cask claude-code` |
| `Killed` on Linux install | OOM — add 2GB swap with `fallocate -l 2G /swapfile` |
| TLS/SSL connect errors | Update CA certs; for corporate proxy set `NODE_EXTRA_CA_CERTS` |
| `Error loading shared library` | Wrong libc binary; check `ldd --version` for glibc vs musl |
| `Illegal instruction` | CPU instruction mismatch or old CPU lacking AVX |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `dyld: cannot load` on macOS | macOS version too old; requires macOS 13.0+ |
| `OAuth error: Invalid code` | Code expired; retry quickly or type `c` to copy URL |
| `403 Forbidden` after login | Check subscription is active; verify account has Claude Code role |
| `Could not load credentials` (Bedrock/Vertex) | Run `aws sts get-caller-identity` or `gcloud auth application-default login` |

Install locations: `~/.local/bin/claude` (macOS/Linux), `%USERPROFILE%\.local\bin\claude.exe` (Windows).

### Recent releases (weekly digest highlights)

| Week | Versions | Highlights |
| :--- | :--- | :--- |
| W17 (Apr 20–24) | v2.1.114–119 | `/ultrareview` research preview (cloud bug-hunting agents); session recap; custom themes; Claude Code on the web redesign |
| W16 (Apr 13–17) | v2.1.105–113 | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort level; Routines on web; `/ultrareview`; native binaries |
| W15 (Apr 6–10) | v2.1.92–101 | Ultraplan early preview; Monitor tool (stream background events); `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| W14 (Mar 30–Apr 3) | v2.1.86–91 | Computer use in CLI (research preview); `/powerup` interactive lessons; flicker-free rendering; MCP result-size override up to 500K |
| W13 (Mar 23–27) | v2.1.83–85 | Auto mode research preview; computer use in Desktop; PR auto-fix on web; transcript search with `/`; native PowerShell tool |

For all bug fixes and minor changes, see the full [changelog](references/claude-code-changelog.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API customers, enabling contribution metrics with GitHub integration, PR attribution logic, and interpreting metrics
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, workspace spend limits, rate limit recommendations, agent team costs, context management strategies, model selection, MCP overhead, hooks and skills to offload processing
- [Monitoring (OpenTelemetry)](references/claude-code-monitoring-usage.md) — full OTel configuration reference, all metrics and events schemas, span hierarchy for distributed tracing, dynamic headers, multi-team segmentation, security and privacy guidance
- [Debug your configuration](references/claude-code-debug-your-config.md) — using `/context`, `/memory`, `/hooks`, `/mcp`, `/doctor`, `/status`; resolving settings conflicts; common configuration issues table
- [Error reference](references/claude-code-errors.md) — all runtime errors with exact messages and recovery steps (server errors, usage limits, auth, network, request errors, response quality)
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — `command not found`, PATH fixes, TLS/SSL errors, platform-specific issues (WSL, Windows, Docker, Alpine), OAuth login failures, Bedrock/Vertex credentials
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, auto-compact thrashing, command hangs, search and discovery issues, ripgrep installation
- [Changelog](references/claude-code-changelog.md) — full release notes by version number
- [What's new: index](references/claude-code-whats-new-index.md) — weekly digest index (W13–W17, 2026)
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, PR auto-fix, transcript search, PowerShell tool
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, `/powerup`, flicker-free rendering, MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/team-onboarding`, `/autofix-pr`
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, xhigh effort, Routines, `/ultrareview`, native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview` public preview, session recap, custom themes, web redesign

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring (OpenTelemetry): https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
