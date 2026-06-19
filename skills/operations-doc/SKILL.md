---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating Claude Code at scale — analytics, cost management, OpenTelemetry monitoring, troubleshooting, error reference, and release history.

## Quick Reference

### Analytics Dashboards

| Plan | URL | Key metrics |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend, per-user lines/cost |

**Enable contribution metrics (Teams/Enterprise):** install the GitHub app at github.com/apps/claude, then enable Analytics + GitHub analytics in claude.ai/admin-settings/claude-code. Data appears within 24 hours; daily updates.

**PR attribution criteria:**
- PR tagged `claude-code-assisted` if at least one line matches Claude Code session output
- Sessions within 21 days before to 2 days after merge date are considered
- Code with >20% rewrite from developer is not attributed
- Auto-excluded: lock files, build artifacts, minified files, generated protobuf, test fixtures, lines over 1,000 characters

### Cost Management

| Topic | Key info |
| :--- | :--- |
| Average enterprise cost | ~$13/dev/active day; $150–250/dev/month; 90% under $30/active day |
| Track usage | `/usage` — token stats, plan breakdown by skill/subagent/plugin/MCP |
| Set spend limits | Console workspace limits for API users; `/usage-credits` for Pro/Max monthly cap |
| Agent team overhead | ~7x more tokens than standard sessions (each teammate has its own context window) |

**Rate limit recommendations (TPM per user):**

| Team size | TPM/user | RPM/user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Token reduction strategies:**
- `/clear` between unrelated tasks; `/compact [focus]` to summarize; `/rename` first so you can `/resume` later
- `/model` to switch to Sonnet for most tasks; reserve Opus for complex reasoning
- Move detailed workflow instructions out of CLAUDE.md into skills (load on demand, not at session start); keep CLAUDE.md under 200 lines
- Disable unused MCP servers with `/mcp`; prefer CLI tools (gh, aws) over MCP for lower overhead
- Use PreToolUse hooks to filter verbose output (e.g. grep logs for errors before Claude sees them)
- `MAX_THINKING_TOKENS=8000` or `/effort` to reduce extended thinking on simple tasks
- Delegate verbose suboperations to subagents so output stays in their context

### OpenTelemetry (OTel) Monitoring

**Quick start:**
```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console | none
OTEL_LOGS_EXPORTER=otlp             # otlp | console | none
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key configuration variables:**

| Variable | Description |
| :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry (`1`) |
| `OTEL_METRICS_EXPORTER` | Metrics exporter (`otlp`, `prometheus`, `console`, `none`) |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter (`otlp`, `console`, `none`) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers (`Authorization=Bearer token`) |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval ms (default: 60000) |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms (default: 5000) |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (`1` to enable) |
| `OTEL_LOG_TOOL_DETAILS` | Log Bash commands, MCP names, skill names, tool input (`1`) |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in trace spans, truncated at 60 KB (`1`) |
| `OTEL_LOG_RAW_API_BODIES` | Emit full Messages API request/response (`1` = inline 60 KB; `file:<dir>` = untruncated on disk) |
| `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` | Dynamic headers refresh interval (default: 1740000ms / 29 min) |

**Distributed tracing (beta):** enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` and `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`, then set `OTEL_TRACES_EXPORTER`. Span hierarchy:
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook          (requires detailed beta tracing)
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

**Exported metrics:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | Sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Code edit permission decisions | count |
| `claude_code.active_time.total` | Active time | seconds |

**Key events exported via logs:**

| Event | When |
| :--- | :--- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Permission decision made (accept/reject) |
| `claude_code.api_request` | API call to Claude |
| `claude_code.api_error` | API request fails after retries |
| `claude_code.api_refusal` | API returns `stop_reason: "refusal"` |
| `claude_code.api_request_body` | Full request body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_response_body` | Full response body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.permission_mode_changed` | Permission mode changes |
| `claude_code.auth` | Login/logout completes |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects/fails |
| `claude_code.plugin_installed` | Plugin finishes installing |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.hook_registered` | Hook configured at session start |
| `claude_code.hook_execution_start` | Hook(s) begin executing |
| `claude_code.hook_execution_complete` | Hook(s) finish |
| `claude_code.compaction` | Conversation compaction completes |
| `claude_code.internal_error` | Unexpected internal error |

**Tool decision `source` values:** `config` (auto from rules/settings), `hook`, `user_permanent` (don't ask again), `user_temporary` (one-time), `user_abort` (dismissed), `user_reject` (said No).

**Standard attributes on all metrics/events:** `session.id`, `user.id`, `user.email`, `user.account_uuid`, `organization.id`, `terminal.type`, `app.version`, `app.entrypoint`.

**Multi-team segmentation:** `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"` — no spaces in values, use underscores or percent-encode.

**SIEM integration:** set `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` to your SIEM's OTLP receiver. Security-relevant events: `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `plugin_installed`.

### Troubleshooting Quick Index

| Symptom | Resolution |
| :--- | :--- |
| `command not found`, PATH, EACCES, TLS errors at install | See install troubleshooting reference |
| Login loops, 403, OAuth errors, Bedrock/Vertex/Foundry creds | See install troubleshooting reference |
| Settings not applying, hooks not firing, MCP not loading | Run `/doctor`, `/status`, `/hooks`, `/mcp`, `/context` |
| `API Error: 5xx`, `529`, `429`, request validation errors | See error reference |
| `model not found` | See error reference |
| VS Code extension not connecting | See VS Code integration docs |
| High CPU/memory, slow responses, search not finding files | See troubleshooting reference |

**Performance issues:**
- High CPU/memory: use `/compact` regularly, restart between major tasks, add build dirs to `.gitignore`, try `claude --safe-mode` to isolate plugins/hooks
- Heap dump: run `/heapdump` — writes `.heapsnapshot` and memory breakdown to `~/Desktop` (or home dir on Linux)
- Auto-compact thrashing (`Autocompact is thrashing: the context refilled...`): ask Claude to read oversized files in chunks; run `/compact keep only the plan and the diff`; move large-file work to a subagent; `/clear` if needed
- Frozen/hangs: Ctrl+C; restart terminal; `claude --resume` to pick session back up
- Garbled text in VS Code/Cursor terminal: run `/terminal-setup` to disable GPU acceleration
- Search not finding files: install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`
- Slow search on WSL: work on Linux filesystem (`/home/`) not Windows filesystem (`/mnt/c/`)

### Configuration Debugging

**Commands to inspect what loaded:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics, invalid keys, schema errors |
| `/debug [issue]` | Enable debug logging; prompts Claude to diagnose |
| `/status` | Active settings sources, managed settings status |

**Common configuration mistakes:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is JSON array instead of string | Use `"Edit\|Write"` string with `\|` separator |
| Hook never fires | Matcher is lowercase, e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks defined in standalone file | Define under `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Config added to `~/.claude.json` | Use `~/.claude/settings.json` (different file) |
| `settings.json` value ignored | Same key in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill missing from `/skills` | Skill at `.claude/skills/name.md` (flat) | Use folder: `.claude/skills/name/SKILL.md` |
| MCP in `.mcp.json` never loads | File is inside `.claude/` | Project MCP config goes at repo root as `.mcp.json` |
| MCP server fails from some dirs | `command` or `args` uses relative path | Use absolute paths for local scripts |

**Clean session test:** `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude`

### Error Reference Quick Index

**Automatic retries:** Claude Code retries up to 10 times with exponential backoff for server errors, 529, 429, timeouts, and dropped connections. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server-side failure | Check status.claude.com; retry; `/feedback` |
| `API Error: 529 Overloaded` | API at capacity | Wait; try `/model` to switch models |
| `Request timed out` | Slow network or large response | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session/weekly limit` | Plan quota exhausted | Wait for reset time shown; `/usage-credits`; upgrade plan |
| `Usage credits required for 1M context` | 1M window not included in plan | `/model` to switch to non-1M variant; `/usage-credits` |
| `Request rejected (429)` | Rate limit hit | Check `/status` for active credential; reduce concurrency; request higher tier |
| `Credit balance is too low` | Console org out of credits | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | No credential found | `/login`; check `ANTHROPIC_API_KEY` is exported |
| `Invalid API key` | Key rejected by API | Check for typos, revocation; unset and `/login` |
| `This organization has been disabled` | Stale API key from disabled org | Unset `ANTHROPIC_API_KEY`; relaunch `claude` |
| `OAuth token revoked or expired` | Stored login no longer valid | `/login`; `/logout` then `/login` if it persists |
| `Unable to connect to API` | Network/firewall/proxy | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY` |
| `SSL certificate verification failed` | Corporate TLS inspection | `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Context window full | `/compact`; `/context` to see what's consuming space |
| `Error during compaction: Conversation too long` | Window full at compact time | Press Esc twice to step back; then `/compact` again |
| `Extra inputs are not permitted` | Gateway dropped `anthropic-beta` header | Configure gateway to forward header; or `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model name not recognized or no access | `/model` to pick available model; use aliases like `sonnet`, `opus` |
| `Claude Opus is not available with the Claude Pro plan` | Plan doesn't include selected model | `/model` to switch; re-auth if upgraded recently |
| `API Error: 400 due to tool use concurrency issues` | Corrupted conversation history | `/rewind` or Esc twice to step back |
| `Usage Policy refusal` | Content triggered policy check | Esc twice or `/rewind`; `/clear` for fresh session |

### Recent Releases (What's New)

| Week | Dates | Highlights |
| :--- | :--- | :--- |
| W24 | June 8–12, 2026 | `/cd` to change working directory mid-session; sub-agents can spawn sub-agents (capped at 5 levels); `--safe-mode`; `fallbackModel` list |
| W23 | June 1–5, 2026 | Auto mode on Bedrock/Vertex/Foundry; safer auto edits for runnable files; `/plugin list`; version requirements for managed deployments |
| W22 | May 25–29, 2026 | Claude Opus 4.8 as new default (Max/Team Premium/Enterprise); dynamic workflows for dozens of subagents; security-guidance plugin; fast mode on Opus 4.8 |
| W21 | May 18–22, 2026 | Auto mode on Pro plan (Sonnet 4.6 + Opus); `/usage` breakdown by skill/subagent/plugin/MCP; `/code-review` command; background sessions in `/resume` |
| W20 | May 11–15, 2026 | Agent view (`claude agents`); `/goal` for multi-turn persistence; fast mode default on Opus 4.7; Rewind "Summarize up to here" |
| W19 | May 4–8, 2026 | Plugins from `.zip` archives and URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level |
| W18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell as shell tool); `claude ultrareview` for CI; `claude project purge`; paste PR URL into `/resume` |
| W17 | Apr 20–24, 2026 | `/ultrareview` public research preview (cloud bug-hunting agents); session recap; custom themes; Claude Code on the web redesign |
| W16 | Apr 13–17, 2026 | Claude Opus 4.7 as new default; `xhigh` effort level; Routines on web; mobile push notifications; `/usage` limit breakdown; native binaries |
| W15 | Apr 6–10, 2026 | Ultraplan early preview (cloud plan editor); Monitor tool for streaming background events; `/loop` self-pacing |
| W14 | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override up to 500K |
| W13 | Mar 23–27, 2026 | Auto mode research preview; computer use in Desktop; PR auto-fix on web; transcript search (`/`); native PowerShell tool for Windows |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards, contribution metrics, PR attribution, GitHub integration
- [Manage costs effectively](references/claude-code-costs.md) — cost tracking, team spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, all metrics, all events, span attributes, security/SIEM integration
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, stability, high CPU/memory, auto-compact thrashing, search issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — command not found, PATH, permissions, network, TLS, auth errors, WSL, Windows issues
- [Debug your configuration](references/claude-code-debug-your-config.md) — diagnosing CLAUDE.md, settings, hooks, MCP servers, skills not taking effect
- [Error reference](references/claude-code-errors.md) — runtime error messages, causes, and recovery steps
- [Changelog](references/claude-code-changelog.md) — full version-by-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index of notable features
- [What's new: Week 13 (Mar 23–27)](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use, PR auto-fix, transcript search, PowerShell tool
- [What's new: Week 14 (Mar 30–Apr 3)](references/claude-code-whats-new-2026-w14.md) — computer use CLI, /powerup, MCP result-size override
- [What's new: Week 15 (Apr 6–10)](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop self-pacing
- [What's new: Week 16 (Apr 13–17)](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile push, native binaries
- [What's new: Week 17 (Apr 20–24)](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [What's new: Week 18 (Apr 27–May 1)](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview, project purge
- [What's new: Week 19 (May 4–8)](references/claude-code-whats-new-2026-w19.md) — zip/URL plugins, worktree.baseRef, auto mode hard deny, effort in hooks
- [What's new: Week 20 (May 11–15)](references/claude-code-whats-new-2026-w20.md) — Agent view, /goal, fast mode on Opus 4.7, Rewind summarize
- [What's new: Week 21 (May 18–22)](references/claude-code-whats-new-2026-w21.md) — auto mode on Pro, /usage breakdown, /code-review, background sessions
- [What's new: Week 22 (May 25–29)](references/claude-code-whats-new-2026-w22.md) — Opus 4.8 default, dynamic workflows, security-guidance plugin, fast mode
- [What's new: Week 23 (Jun 1–5)](references/claude-code-whats-new-2026-w23.md) — auto mode on Bedrock/Vertex/Foundry, safer auto edits, /plugin list, version requirements
- [What's new: Week 24 (Jun 8–12)](references/claude-code-whats-new-2026-w24.md) — /cd command, nested sub-agents, --safe-mode, fallbackModel list

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
- What's new 2026-W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new 2026-W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new 2026-W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new 2026-W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new 2026-W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new 2026-W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new 2026-W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new 2026-W20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new 2026-W21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new 2026-W22: https://code.claude.com/docs/en/whats-new/2026-w22.md
- What's new 2026-W23: https://code.claude.com/docs/en/whats-new/2026-w23.md
- What's new 2026-W24: https://code.claude.com/docs/en/whats-new/2026-w24.md
