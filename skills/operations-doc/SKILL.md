---
name: operations-doc
description: Complete official documentation for operating Claude Code in teams and production — analytics dashboards (Teams/Enterprise and API Console), cost tracking and spend limits, OpenTelemetry monitoring (metrics, events, traces, SIEM), config debugging (/context, /doctor, /hooks, /mcp, /status), troubleshooting performance and stability, installation/login error fixes, runtime error reference (500/529/429, auth, network, request errors), changelog, and weekly "What's new" digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, troubleshooting, and staying current with Claude Code.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | What's included |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API / Console | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics** (Teams/Enterprise beta) require installing the GitHub app at github.com/apps/claude and enabling GitHub analytics at claude.ai/admin-settings/claude-code. Data appears within 24 hours; updated daily. Not available with Zero Data Retention enabled.

**Summary metrics**: PRs with CC, lines of code with CC, suggestion accept rate, lines of code accepted. Attribution window: 21 days before to 2 days after PR merge. Code with >20% rewrite is not attributed. Auto-generated files (lock files, dist/, build/, node_modules/) are excluded.

### Cost Tracking

| Command | What it does |
| :--- | :--- |
| `/usage` | Current session token usage, cost estimate, and plan breakdown by skill/plugin/subagent |
| `/usage-credits` | Buy or request additional usage credits (Pro/Max/Team/Enterprise) |
| `/model` | Switch models to balance capability and cost |
| `/effort` | Adjust reasoning effort to reduce thinking tokens |
| `/compact [instructions]` | Summarize context to reduce token costs |
| `/clear` | Reset context to start fresh |

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies**: use Sonnet for most work (Opus for complex tasks), keep CLAUDE.md under 200 lines, move workflows into skills (load on-demand), use subagents to isolate verbose output, write specific prompts, use plan mode before implementation, set `MAX_THINKING_TOKENS=8000` for simpler tasks.

**Agent teams**: ~7x more tokens than standard sessions; use Sonnet for teammates, keep teams small, clean up when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

### OpenTelemetry Monitoring

**Quick start:**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp             # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics backend | none |
| `OTEL_LOGS_EXPORTER` | Events/logs backend | none |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics flush interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs flush interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content in events | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool names, commands, args | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | session.id on metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | user.account_uuid on metrics | true |

**Available metrics:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | Sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified (added/removed) | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used (input/output/cache) | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject | count |
| `claude_code.active_time.total` | Active time (user/cli) | s |

**Standard attributes on all metrics/events**: `session.id`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`, `app.version`

**Key events** (via `OTEL_LOGS_EXPORTER`): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.plugin_installed`, `claude_code.plugin_loaded`, `claude_code.skill_activated`, `claude_code.compaction`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`

**Distributed traces** (beta): enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request` / `claude_code.tool` → `claude_code.tool.blocked_on_user` + `claude_code.tool.execution`.

**Security/SIEM audit**: point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver. Set `OTEL_LOG_TOOL_DETAILS=1` for full MCP/Bash audit. Key signals: `tool_decision` (allow/deny + source), `permission_mode_changed` (escalation), `auth` (login/logout), `mcp_server_connection` (server activity).

**Dynamic headers** (for token refresh): set `otelHeadersHelper` in `.claude/settings.json` to a script path; runs at startup and every 29 minutes. Only applies to `http/protobuf` and `http/json` protocols.

**Multi-team segmentation**: `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values).

### Debug Your Configuration

**Inspection commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules in effect |
| `/doctor` | Configuration diagnostics (invalid keys, schema errors, health) |
| `/status` | Active settings sources, managed settings status |
| `/debug [issue]` | Enable debug logging + prompt Claude to diagnose |

**Common configuration surprises:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use `"Edit\|Write"` with pipe separator |
| Hook never fires | `matcher` value is lowercase (e.g., `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks defined in a standalone file | Define under `"hooks"` key in `settings.json` |
| Setting ignored | Added to `~/.claude.json` | Config belongs in `~/.claude/settings.json` |
| Setting overridden | Same key in `settings.local.json` | `local` > `project` > `user` precedence |
| Skill not in `/skills` | File at `.claude/skills/name.md` (flat) | Must be `.claude/skills/name/SKILL.md` |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loads when Claude uses Read tool in that dir |
| MCP servers in `.mcp.json` not loading | File is under `.claude/` | Project MCP config goes at the repo root |
| Project MCP server not appearing | One-time approval dismissed | Run `/mcp` and approve |

**Clean-slate test**: `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude`

### Troubleshooting (Runtime)

| Symptom | Resolution |
| :--- | :--- |
| High CPU/memory | Use `/compact` regularly; close between major tasks; add build dirs to `.gitignore`; run `/heapdump` if needed |
| Autocompact thrashing | Read large files in chunks; `/compact keep only...`; move work to subagent; or `/clear` |
| Command hangs | Ctrl+C to cancel; restart terminal; `claude --resume` to recover |
| Search not finding files | Install system ripgrep; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work from Linux filesystem (`/home/`), not Windows mounts (`/mnt/c/`) |

### Installation Error Quick-Fix

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install script returns HTML / 403 | Use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| TLS / SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Killed` during Linux install | Add 2 GB swap; need ≥4 GB RAM |
| `Illegal instruction` | Pre-2013 CPU lacks AVX; see GitHub issue #50384 |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; update macOS |
| `403 Forbidden` after login | Check subscription active; verify Console "Claude Code" role |
| `This organization has been disabled` | Unset stale `ANTHROPIC_API_KEY` env var |
| Bedrock/Vertex creds not loading | Run `aws sts get-caller-identity` / `gcloud auth application-default login` / `az login` |

### Runtime Error Quick-Fix

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server-side failure | Check status.claude.com; retry; `/feedback` |
| `API Error: 529 Overloaded` | API at capacity | Try again in minutes; `/model` to switch models |
| `You've hit your session limit` | Plan quota reached | Wait for reset; `/usage-credits` for more |
| `Request rejected (429)` | Rate limit hit | Reduce concurrency; check workspace rate limits |
| `Credit balance is too low` | Console credits exhausted | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | No credential available | `/login` |
| `Invalid API key` | Key revoked or wrong | Check Console; unset `ANTHROPIC_API_KEY`; `/login` |
| `Unable to connect to API` | Network/proxy issue | Set `HTTPS_PROXY`; check firewall allows api.anthropic.com |
| `SSL certificate verification failed` | Corporate TLS inspection | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Context window full | `/compact`; `/clear`; disable unused MCP servers |
| `There's an issue with the selected model` | Model not recognized/accessible | `/model` to pick available model; use aliases like `sonnet` |
| `API Error: 400 due to tool use concurrency issues` | Corrupted conversation history | `/rewind` or double-Esc to step back |
| `Extra inputs are not permitted` | Gateway stripping `anthropic-beta` header | Configure gateway to forward header; or `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |

**Retry behavior**: Claude Code retries server errors, 529, timeouts, and temporary 429s up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

### Changelog and What's New

Run `claude --version` to check your installed version. The changelog at `references/claude-code-changelog.md` lists every release with bug fixes and improvements.

Recent notable releases (2026):

| Week | Version range | Highlights |
| :--- | :--- | :--- |
| W20 (May 11–15) | v2.1.139–v2.1.142 | Agent view (`claude agents`), `/goal` completion conditions, fast mode on Opus 4.7 |
| W19 (May 4–8) | v2.1.128–v2.1.136 | Plugins from `.zip`/URLs, `worktree.baseRef`, auto mode hard deny rules, hooks see effort level |
| W18 (Apr 27–May 1) | v2.1.120–v2.1.126 | Windows without Git Bash (PowerShell tool), `claude ultrareview` CLI, `claude project purge` |
| W17 (Apr 20–24) | v2.1.114–v2.1.119 | `/ultrareview` public preview, session recap, custom themes, Claude Code on the web redesign |
| W16 (Apr 13–17) | v2.1.105–v2.1.113 | Claude Opus 4.7 default, `xhigh` effort, Routines on web, mobile push notifications, native binaries |
| W15 (Apr 6–10) | v2.1.92–v2.1.101 | Ultraplan early preview, Monitor tool, `/loop` self-pacing, `/team-onboarding` |
| W14 (Mar 30–Apr 3) | v2.1.86–v2.1.91 | Computer use in CLI (research preview), `/powerup` lessons |
| W13 (Mar 23–27) | v2.1.83–v2.1.85 | Auto mode (research preview), computer use in Desktop, PR auto-fix on web, PowerShell tool |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — dashboards for Teams/Enterprise and API Console, contribution metrics setup, GitHub integration, PR attribution algorithm, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, team spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry quick start, all config variables, metrics, events, traces (beta), SIEM audit, security/privacy details
- [Debug your configuration](references/claude-code-debug-your-config.md) — inspection commands, settings scope resolution, MCP server debugging, hooks debugging, clean-slate testing, common cause lookup table
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance/stability issues, high resource usage, auto-compact thrashing, search problems, ripgrep setup
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — install errors by platform, PATH issues, TLS/SSL, Windows installer, WSL issues, OAuth/login failures, cloud provider credentials
- [Error reference](references/claude-code-errors.md) — all runtime error messages with recovery steps: server errors, usage limits, authentication, network, request errors, response quality
- [Changelog](references/claude-code-changelog.md) — full release history with every bug fix and improvement
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index linking to each weekly feature summary
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use, PR auto-fix, PowerShell tool
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, `/powerup` lessons
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/team-onboarding`
- [Week 16 digest](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, Routines, mobile push notifications, native binaries
- [Week 17 digest](references/claude-code-whats-new-2026-w17.md) — `/ultrareview` preview, session recap, custom themes, web redesign
- [Week 18 digest](references/claude-code-whats-new-2026-w18.md) — Windows PowerShell tool, `claude ultrareview` CLI
- [Week 19 digest](references/claude-code-whats-new-2026-w19.md) — plugins from .zip/URLs, `worktree.baseRef`, auto mode hard deny
- [Week 20 digest](references/claude-code-whats-new-2026-w20.md) — agent view, `/goal` completion conditions, fast mode on Opus 4.7

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
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
