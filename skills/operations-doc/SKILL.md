---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running Claude Code at scale: analytics and usage tracking, cost management, OpenTelemetry monitoring, troubleshooting, configuration debugging, error recovery, and the release changelog and weekly digests.

## Quick Reference

### Analytics Dashboards

| Plan | URL | Includes |
| :--- | :-- | :------- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Usage metrics, spend per user, accept rate |

Contribution metrics (PRs and lines-of-code attributed to Claude Code) require the GitHub app installed at github.com/apps/claude and the GitHub analytics toggle enabled by an Owner. Not available with Zero Data Retention. Data appears within 24 hours with daily updates. Attribution window: 21 days before to 2 days after PR merge.

**Contribution metric definitions:**
- PRs with CC: merged PRs containing at least one Claude-assisted line
- Lines excluded: auto-generated files (lock files, build dirs, minified lines over 1,000 chars)
- Code rewritten more than 20% by developers is not attributed to Claude Code
- PRs labeled `claude-code-assisted` in GitHub when contribution metrics enabled

### Cost Tracking and Control

| Tool | What it does |
| :--- | :----------- |
| `/usage` | Session token stats, plan limits, per-skill/subagent/plugin breakdown (press `d`/`w` for 24 h / 7 d) |
| `/usage-credits` | Buy or request additional credits on Pro / Max / Team / Enterprise |
| `/compact [focus]` | Summarize conversation history to free context |
| `/clear` | Start a fresh conversation |
| `/effort` | Adjust extended thinking level (reduces thinking token spend on simpler tasks) |
| `/model` | Switch models mid-session (Sonnet costs less than Opus) |
| `/context` | See what is consuming the context window |

**Average enterprise cost:** ~$13/developer/active day, $150–250/month. 90% of users stay below $30/active day.

**Rate limit recommendations (TPM per user):**

| Team size | TPM/user | RPM/user |
| :-------- | :------- | :------- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**
- Clear context between unrelated tasks; keep CLAUDE.md under 200 lines
- Move specialized instructions into skills (loaded on-demand, not at startup)
- Disable unused MCP servers; prefer CLI tools (`gh`, `aws`) over MCP when available
- Delegate verbose operations (logs, tests) to subagents so output stays out of main context
- Use plan mode (Shift+Tab) before implementation to avoid expensive re-work
- Use `/compact Focus on X` to preserve only what matters during summarization
- For simple subagent tasks, set `model: haiku` in subagent configuration
- Agent teams use ~7x more tokens than standard sessions (each teammate has its own context window)

### OpenTelemetry Monitoring — Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp             # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Default | Purpose |
| :------- | :------ | :------ |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | off | Required master switch |
| `OTEL_METRICS_EXPORTER` | — | Metrics destination: `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | — | Events/logs destination: `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | — | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | Collector endpoint for all signals |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000 ms | Metrics flush interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000 ms | Logs flush interval |
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt content in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include tool params: Bash commands, MCP names, file paths, skill names |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool input/output bodies in trace spans |
| `OTEL_LOG_RAW_API_BODIES` | off | Emit full Messages API request/response JSON (`=1` inline, `=file:<dir>` to disk) |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include `session.id` on metric datapoints |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include `user.account_uuid` on metric datapoints |
| `OTEL_METRICS_INCLUDE_VERSION` | false | Include `app.version` on metric datapoints |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | false | Include `app.entrypoint` on metric datapoints |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | off | Enable distributed tracing (beta) |

**Exported metrics:**

| Metric | Unit | Key additional attributes |
| :----- | :--- | :------------------------ |
| `claude_code.session.count` | count | `start_type`: fresh / resume / continue |
| `claude_code.lines_of_code.count` | count | `type`: added / removed |
| `claude_code.pull_request.count` | count | — |
| `claude_code.commit.count` | count | — |
| `claude_code.cost.usage` | USD | `model`, `query_source`, `speed`, `effort`, `agent.name`, `skill.name`, `plugin.name`, `mcp_server.name` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model`, `query_source`, `effort` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type`: user / cli |

**Standard attributes on all metrics and events:** `session.id`, `user.id`, `user.email`, `user.account_uuid`, `organization.id`, `app.version`, `app.entrypoint`, `terminal.type`.

**Key events** (via `OTEL_LOGS_EXPORTER`):

| Event name | When emitted |
| :--------- | :----------- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.api_request` | API call completes |
| `claude_code.api_error` | API call fails after retries |
| `claude_code.api_refusal` | API returns `stop_reason: refusal` |
| `claude_code.api_retries_exhausted` | API request exhausts all retries |
| `claude_code.tool_result` | Tool execution completes |
| `claude_code.tool_decision` | Tool permission decided (accept/reject) |
| `claude_code.permission_mode_changed` | Permission mode changes |
| `claude_code.mcp_server_connection` | MCP server connects/fails/disconnects |
| `claude_code.plugin_installed` | Plugin install finishes |
| `claude_code.plugin_loaded` | Plugin active at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.compaction` | Context compaction completes |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` | Hook batch begins |
| `claude_code.hook_execution_complete` | Hook batch finishes |
| `claude_code.auth` | Login or logout |
| `claude_code.internal_error` | Unexpected internal error caught |
| `claude_code.feedback_survey` | Session quality survey shown/answered |
| `claude_code.at_mention` | `@`-mention resolved in a prompt |

**Event correlation:** The `prompt.id` attribute links all events (api_request, tool_result, etc.) triggered by a single user prompt. Filter by `prompt.id` to trace one full interaction.

**Tool decision `source` values:** `config`, `hook`, `user_permanent`, `user_temporary`, `user_abort`, `user_reject`.

**Traces (beta):** Enable with `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER`. Span hierarchy:
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook           (detailed beta only)
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```
Subprocesses receive `TRACEPARENT` env var; model and HTTP MCP requests carry `traceparent` header for end-to-end distributed tracing.

**Dynamic headers** (enterprise auth token refresh): set `otelHeadersHelper` in `.claude/settings.json` to a script path. The script must output valid JSON with string key-value HTTP headers. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`). Works only with `http/protobuf` and `http/json` protocols.

**Multi-team segmentation:** set `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"`. Custom keys become metric labels; use `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES=false` to include in resource block only (avoids cardinality bloat). No spaces in values; use percent-encoding if needed.

**SIEM integration:** Point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver. Set `OTEL_LOG_TOOL_DETAILS=1` for full MCP/Bash audit trails. Security event map:

| Signal | Event | Key attributes |
| :----- | :---- | :------------- |
| Tool allowed or denied | `tool_decision` | `decision`, `source`, `tool_name`, `tool_parameters` |
| Permission mode escalation | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Login/logout/auth failure | `auth` | `action`, `success`, `error_category` |
| MCP server connect or failure | `mcp_server_connection` | `status`, `server_name`, `is_plugin` |
| Plugin installed and its source | `plugin_installed` | `plugin.name`, `marketplace.name`, `marketplace.is_official` |

### Troubleshooting — Symptom Routing

| Symptom | Go to |
| :------ | :---- |
| `command not found`, PATH, `EACCES`, TLS errors during install | Troubleshoot installation and login |
| OAuth errors, `403 Forbidden`, "org disabled", Bedrock/Vertex creds | Troubleshoot installation and login (login section) |
| Settings ignored, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529 Overloaded`, `429`, validation errors | Error reference |
| `model not found` / no access to model | Error reference |
| High CPU/memory, hangs, search not finding files | Troubleshooting (performance section) |
| VS Code / JetBrains not detecting Claude | IDE-specific doc |

Run `/doctor` inside Claude Code for an automated check. If `claude` won't start, run `claude doctor` from your shell.

**Performance fixes:**
- High memory: use `/compact`, restart between tasks, add build dirs to `.gitignore`, run `/heapdump` for heap snapshot (written to `~/Desktop` or home dir on Linux)
- Auto-compact thrashing (`Autocompact is thrashing`): read large files in chunks, use `/compact` with a focus hint, move large-file work to a subagent, or `/clear`
- Command hangs: Ctrl+C; then `claude --resume` in the same directory to recover
- Garbled text in VS Code/Cursor terminal: run `/terminal-setup` to disable GPU acceleration
- Search not finding files: install `ripgrep` via your package manager, then set `USE_BUILTIN_RIPGREP=0`
- Slow search on WSL: ensure project is on Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`)

### Configuration Debugging Commands

| Command | Shows |
| :------ | :---- |
| `/context` | Full context breakdown (system prompt, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics, schema errors, install health |
| `/debug [issue]` | Enables debug logging; Claude diagnoses from the log |
| `/status` | Active settings sources, managed settings status |

**Clean-session test:** `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude` — bypasses all user and project config to isolate the cause. Or use `claude --safe-mode` to disable customizations while keeping authentication and model selection.

**Common configuration mistakes:**

| Symptom | Cause | Fix |
| :------ | :---- | :-- |
| Hook never fires | `matcher` is an array instead of a string | Use `"Edit\|Write"` (string with pipe separator) |
| Hook never fires | `matcher` is lowercase, e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks defined in a standalone file | Put hooks under `"hooks"` key in `settings.json` |
| Settings ignored | Config added to `~/.claude.json` | `permissions`, `hooks`, `env` go in `~/.claude/settings.json` |
| A settings.json value seems ignored | Same key set in `settings.local.json` | Local overrides project which overrides user |
| Skill missing from /skills | File at `.claude/skills/name.md` instead of folder | Use `.claude/skills/name/SKILL.md` |
| Skill appears but Claude never invokes it | `disable-model-invocation: true` in frontmatter | Check "user-only" badge in `/skills` |
| MCP server not loading | Project MCP in `.claude/.mcp.json` | Project MCP config goes at repo root as `.mcp.json` |
| MCP server fails from some dirs | `command` uses relative path | Use absolute paths for local scripts |
| MCP env vars missing in server | Vars in `settings.json` `env` | Set per-server `env` inside `.mcp.json` |

### Error Reference — Quick Index

| Error | Category | First action |
| :---- | :------- | :----------- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com, retry |
| `API Error: Repeated 529 Overloaded errors` | Server | Wait; `/model` to switch models |
| `Request timed out` | Server | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `Auto mode cannot determine the safety` | Server | Retry; run `/compact` if context is large |
| `You've hit your session/weekly limit` | Usage limit | Wait for reset shown in error; run `/usage` |
| `Usage credits required for 1M context` | Usage limit | `/model` to drop `[1m]` variant; or `/usage-credits` |
| `Request rejected (429)` | Rate limit | Check `/status` credential; reduce concurrency |
| `Credit balance is too low` | Usage limit | Add credits at platform.claude.com/settings/billing |
| `Not logged in · Please run /login` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for typos; run `env \| grep ANTHROPIC` |
| `This organization has been disabled` | Auth | Unset stale `ANTHROPIC_API_KEY` |
| `Your organization has disabled API key authentication` | Auth | Unset `ANTHROPIC_API_KEY`; run `/login` |
| `OAuth token revoked / expired` | Auth | Run `/login`; `/logout` first if recurring |
| `Unable to connect to API` | Network | `curl -I https://api.anthropic.com`; check proxy |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `403` with `x-deny-reason: host_not_allowed` | Network | Cloud session allowlist; add domain in environment settings |
| `Prompt is too long` | Request | `/compact`, `/clear`, disable unused MCP servers |
| `Error during compaction: Conversation too long` | Request | Esc twice to step back turns, then `/compact` |
| `Request too large` | Request | Esc twice; reference large files by path instead of pasting |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| `There's an issue with the selected model` | Request | `/model` to pick available model; check `ANTHROPIC_MODEL` env |
| `thinking.type.enabled is not supported` | Request | Run `claude update` (Opus 4.7 needs v2.1.111+, 4.8 needs v2.1.154+) |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` to recover checkpoint |
| `Usage Policy` refusal | Request | Esc twice or `/rewind`; rephrase prompt |
| Responses seem lower quality | Quality | Check `/model`, `/effort`, `/context` |

**Retry behavior:** Claude Code retries transient failures up to 10 times with exponential backoff before surfacing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000 ms).

**Common recovery commands:** `/rewind` or double-tap Esc to step back to a checkpoint; `/compact` to free context; `/model` to switch models; `/login` or `/logout` to reset auth; `/feedback` to report issues to Anthropic.

### What's New — Recent Weeks

| Week | Dates | Versions | Key features |
| :--- | :---- | :------- | :----------- |
| W22 | May 25–29, 2026 | v2.1.150–157 | Claude Opus 4.8 (new default on Max/Team/Enterprise/API), dynamic workflows (research preview), security-guidance plugin, fast mode on Opus 4.8 at $10/$50 per MTok |
| W21 | May 18–22, 2026 | v2.1.143–149 | Auto mode on Pro plan + Sonnet 4.6, `/usage` attribution breakdown by skill/subagent/plugin/MCP, `/code-review` command, background sessions |
| W20 | May 11–15, 2026 | v2.1.139–142 | Agent view (`claude agents`), `/goal` command, fast mode on Opus 4.7 by default, Rewind "Summarize up to here" |
| W19 | May 4–8, 2026 | v2.1.128–136 | Plugins from `.zip` archives and URLs, `worktree.baseRef`, auto mode hard deny rules, hooks see active effort level |
| W18 | Apr 27–May 1, 2026 | v2.1.120–126 | Windows without Git Bash (PowerShell tool), `claude ultrareview`, `claude project purge`, paste PR URL into `/resume` |
| W17 | Apr 20–24, 2026 | v2.1.114–119 | `/ultrareview` public preview (cloud bug-hunting agents), session recap, custom themes, Claude Code on the web redesign |
| W16 | Apr 13–17, 2026 | v2.1.105–113 | Claude Opus 4.7 (new default), `xhigh` effort level, Routines on the web, mobile push notifications, native CLI binaries |
| W15 | Apr 6–10, 2026 | v2.1.92–101 | Ultraplan early preview, Monitor tool, `/loop` self-pacing, `/team-onboarding`, `/autofix-pr` |
| W14 | Mar 30–Apr 3, 2026 | v2.1.86–91 | Computer use in CLI (research preview), `/powerup` interactive lessons, per-tool MCP result-size override up to 500K |
| W13 | Mar 23–27, 2026 | v2.1.83–85 | Auto mode (research preview), computer use in Desktop, PR auto-fix on web, transcript search, PowerShell tool, conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Dashboard URLs, contribution metrics setup, PR attribution, leaderboard, data export
- [Manage costs effectively](references/claude-code-costs.md) — `/usage`, spend limits, rate limit tables, agent team costs, context and token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Full env var reference, all metrics and events, traces beta, dynamic headers, SIEM integration, cardinality control
- [Troubleshooting](references/claude-code-troubleshooting.md) — CPU/memory, auto-compact thrashing, hangs, garbled text, search issues, WSL
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, TLS, network, Windows installer, WSL, permission errors, OAuth, Bedrock/Vertex credentials
- [Debug your configuration](references/claude-code-debug-your-config.md) — /context, /doctor, /hooks, /mcp, settings precedence, clean-session testing, common mistakes table
- [Error reference](references/claude-code-errors.md) — All runtime error messages with causes and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version-by-version release history
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index linking to all weekly entries
- [What's new W13](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use in Desktop, conditional `if` hooks (v2.1.83–v2.1.85)
- [What's new W14](references/claude-code-whats-new-2026-w14.md) — Computer use in CLI, /powerup (v2.1.86–v2.1.91)
- [What's new W15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool (v2.1.92–v2.1.101)
- [What's new W16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, Routines, mobile notifications (v2.1.105–v2.1.113)
- [What's new W17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, custom themes (v2.1.114–v2.1.119)
- [What's new W18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview (v2.1.120–v2.1.126)
- [What's new W19](references/claude-code-whats-new-2026-w19.md) — Plugins from zip/URL, auto mode hard deny (v2.1.128–v2.1.136)
- [What's new W20](references/claude-code-whats-new-2026-w20.md) — Agent view, /goal (v2.1.139–v2.1.142)
- [What's new W21](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro, /usage attribution (v2.1.143–v2.1.149)
- [What's new W22](references/claude-code-whats-new-2026-w22.md) — Opus 4.8, dynamic workflows, security-guidance plugin (v2.1.150–v2.1.157)

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
- What's new W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new W20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new W21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new W22: https://code.claude.com/docs/en/whats-new/2026-w22.md
