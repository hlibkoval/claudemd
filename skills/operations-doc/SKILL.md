---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, configuration debugging, error reference, changelog, and weekly what's-new digests. Use when asked about usage tracking, spend limits, token costs, OTel metrics/events/traces, performance issues, install errors, error messages, runtime errors, or recent releases.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Key metrics |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Lines accepted, accept rate, DAU, sessions, PRs with CC (requires GitHub app), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Lines accepted, accept rate, activity chart, spend, per-user spend/lines |

**Enable contribution metrics (Team/Enterprise):** Install the GitHub app at github.com/apps/claude, enable Claude Code analytics at claude.ai/admin-settings/claude-code, then enable GitHub analytics toggle. Data appears within 24 hours; updates daily. Not available with Zero Data Retention.

**PR attribution rules:** Sessions within 21 days before to 2 days after merge date are considered. Code with >20% developer rewrite is not attributed. Lock files, generated code, and build artifacts are excluded. Lines >1,000 characters are excluded. Only lines with >3 characters (after normalization) count.

### Cost management

| Topic | Key info |
| :--- | :--- |
| Average cost | ~$13/developer/active day; $150–250/month; 90% of users below $30/active day |
| Check usage | `/usage` shows session token counts and cost estimate; `d`/`w` toggle for 24h/7d |
| Team spend limits | Set workspace spend limits at platform.claude.com; set monthly limit with `/usage-credits` on Pro/Max |
| Rate limit guidance | See table below for TPM/RPM recommendations by team size |

**Rate limit recommendations (API):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Reduce token usage strategies:**
- `/clear` between unrelated tasks; `/compact Focus on ...` for targeted compaction
- `/model` to switch to Sonnet for most tasks; reserve Opus for complex work
- Add custom compaction instructions in CLAUDE.md under a `# Compact instructions` section
- Move specialized CLAUDE.md instructions into skills (load on-demand, not at session start)
- Use `MCP tool deferred loading` — tools only enter context when used
- Delegate verbose operations (logs, test output) to subagents
- Use plan mode (Shift+Tab) for complex tasks to avoid expensive re-work
- `/effort` or `/model` to lower extended thinking budget; `MAX_THINKING_TOKENS=8000` for fixed-budget models

**Agent team costs:** ~7x more tokens than standard sessions; each teammate has its own context window. Use Sonnet for teammates; keep teams small and spawns focused; clean up when done.

### OpenTelemetry monitoring (quick start)

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp       # or: prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp          # or: console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

**Key OTel environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter: `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter: `otlp`, `console`, `none` | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/protobuf`, `http/json` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) | — |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params, Bash commands, MCP names, skill names | — |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in trace spans (requires tracing) | — |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON (`1` = inline, `file:<dir>` = disk) | — |

**Metrics exported:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | Sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified (added/removed) | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used (input/output/cacheRead/cacheCreation) | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject decisions | count |
| `claude_code.active_time.total` | Active time (user + cli) | seconds |

**Events exported (via `OTEL_LOGS_EXPORTER`):**

| Event name | When fired |
| :--- | :--- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission decision (accept/reject) |
| `claude_code.api_request` | API request to Claude |
| `claude_code.api_error` | API request fails |
| `claude_code.api_refusal` | API returns `stop_reason: "refusal"` |
| `claude_code.api_request_body` / `claude_code.api_response_body` | Full API bodies (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.permission_mode_changed` | Permission mode changes |
| `claude_code.auth` | Login or logout completes |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects/fails |
| `claude_code.plugin_installed` | Plugin installation completes |
| `claude_code.plugin_loaded` | Plugin enabled at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.at_mention` | `@`-mention resolved |
| `claude_code.compaction` | Conversation compaction completes |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` / `hook_execution_complete` | Hook begins/finishes |
| `claude_code.hook_plugin_metrics` | Official-marketplace plugin hook emits per-invocation metrics |
| `claude_code.internal_error` | Unexpected internal error caught |
| `claude_code.api_retries_exhausted` | API request fails after all retries |
| `claude_code.feedback_survey` | Session quality survey shown or answered |

**Traces (beta):** Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request` / `claude_code.tool` → `claude_code.tool.blocked_on_user` + `claude_code.tool.execution`.

**Standard attributes on all metrics/events:** `session.id`, `user.id`, `user.email`, `user.account_uuid`, `user.account_id`, `organization.id`, `app.version`, `app.entrypoint`, `terminal.type`. Service name is `claude-code`.

**Cardinality control:**

| Variable | Default |
| :--- | :--- |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | `false` |
| `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES` | `true` |

**SIEM configuration:** Point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver. Key security events to monitor: `tool_decision` (allow/deny), `permission_mode_changed`, `auth`, `mcp_server_connection`, `plugin_installed`. Set `OTEL_LOG_TOOL_DETAILS=1` for full MCP call detail.

**Dynamic headers:** Set `otelHeadersHelper` in `.claude/settings.json` to a script path that outputs JSON headers; runs at startup and every 29 minutes (configure with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`). Only applies to `http/protobuf` and `http/json` protocols.

### Troubleshooting guide (runtime)

Run `/doctor` first — checks installation health, settings validity, MCP config, and context usage.

| Symptom | Solution |
| :--- | :--- |
| High CPU/memory | `/compact` regularly; restart between tasks; add build dirs to `.gitignore`; `claude --safe-mode` to isolate plugins/hooks |
| Memory still high | `/heapdump` → writes `.heapsnapshot` + breakdown to `~/Desktop` (or home on Linux) |
| Auto-compact thrashing | Ask Claude to read files in chunks; `/compact keep only the plan`; move to subagent; `/clear` |
| Command hangs | Ctrl+C to cancel; close terminal and restart; `claude --resume` to recover |
| Garbled text in editor terminal | `/terminal-setup` to set GPU acceleration off |
| Search not finding files | Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work on Linux filesystem (`/home/`) not Windows filesystem (`/mnt/c/`); use more specific searches |

### Troubleshooting installation and login

**Quick error lookup:**

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML — network/region issue |
| `curl: (56) Failure writing output` | Network instability; retry or use `brew`/`winget` |
| `Killed` during Linux install | Add swap space (need 4 GB RAM); `sudo fallocate -l 2G /swapfile` |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Error loading shared library` | musl/glibc binary mismatch — check `ldd --version`, reinstall |
| `Illegal instruction` | CPU lacks AVX; or architecture mismatch |
| `dyld: cannot load` on macOS | macOS < 13.0; update macOS |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <distro> 2` |
| `403 Forbidden` after login | Check subscription at claude.ai/settings; confirm "Claude Code" role in Console |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` overriding subscription — unset it |
| Bedrock `Could not load credentials` | Run `aws sts get-caller-identity`; check AWS credentials |
| Vertex `Could not load default credentials` | Set `ANTHROPIC_VERTEX_PROJECT_ID` + `CLOUD_ML_REGION`; run `gcloud auth application-default login` |
| Foundry `ChainedTokenCredential failed` | Set `ANTHROPIC_FOUNDRY_API_KEY` or run `az login` |

**Install locations:** macOS/Linux: `~/.local/bin/claude`. Windows: `%USERPROFILE%\.local\bin\claude.exe`.

### Debugging configuration

**Diagnostic commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics: invalid keys, schema errors, installation health |
| `/debug [issue]` | Enable debug logging; diagnose using log output |
| `/status` | Active settings sources; whether managed settings are in effect |

**Test against clean config:** `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude` — bypasses all user and project settings. Also use `claude --safe-mode` to disable customizations while keeping auth/model/tools.

**Common configuration mistakes:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of string | Use `"Edit\|Write"` (string with pipe separator) |
| Hook never fires | `matcher` is lowercase (`"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Permissions/hooks ignored | Added to `~/.claude.json` instead of `~/.claude/settings.json` | These are different files |
| Settings value ignored | Overridden by `settings.local.json` | local > project > user scope order |
| Skill not in `/skills` | Skill file at `.claude/skills/name.md` (not in folder) | Use `.claude/skills/name/SKILL.md` |
| Subdirectory CLAUDE.md ignored | Loads on demand (when Read tool visits that directory) | Not loaded at session start |
| MCP servers not loading | `.mcp.json` is inside `.claude/` | Project MCP config goes at repo root as `.mcp.json` |
| MCP server fails from some dirs | `command` uses relative path | Use absolute paths for local scripts |

### Error reference (runtime)

**Automatic retries:** Claude Code retries up to 10 times with exponential backoff before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

**Key error messages:**

| Error | Category | Action |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Check status.claude.com; retry; `/feedback` |
| `API Error: Repeated 529 Overloaded` | Server | Wait; `/model` to switch models |
| `Request timed out` | Server | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session limit` | Usage limit | Wait for reset; `/usage-credits` for extra usage |
| `Usage credits required for 1M context` | Usage limit | `/model` to switch to non-1M variant; `/usage-credits` |
| `Request rejected (429)` | Rate limit | Check active credential with `/status`; reduce concurrency |
| `Credit balance is too low` | Billing | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check for typos/revocation; unset stale `ANTHROPIC_API_KEY` |
| `OAuth token revoked/expired` | Auth | `/login` |
| `Unable to connect to API` | Network | Check `curl -I https://api.anthropic.com`; configure `HTTPS_PROXY` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | `/compact`; `/context` to audit; trim CLAUDE.md |
| `Request too large` | Request | Reference large files by path; press Esc twice to step back |
| `There's an issue with the selected model` | Request | `/model` to pick available model; check `ANTHROPIC_MODEL` env var |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` or double-press Esc to step back |
| `Claude Code is unable to respond ... Usage Policy` | Request | Press Esc twice; rephrase prompt; `/clear` to start fresh |

**Responses seem lower quality:** Check `/model` (may be on wrong model), `/effort` (may be low), `/context` (may be near capacity). Rewind and rephrase rather than correcting in-thread.

### What's new — recent weekly digests

| Week | Dates | Key features |
| :--- | :--- | :--- |
| W24 | June 8–12, 2026 | `/cd` moves session to new directory; sub-agents can spawn sub-agents (5 levels deep for background); `--safe-mode`; `fallbackModel` chains up to 3 fallbacks |
| W23 | June 1–5, 2026 | Auto mode on Bedrock/Vertex/Foundry for Opus 4.7/4.8; safer auto-edits in `acceptEdits` mode; `/plugin list` inline; version requirements for managed deployments |
| W22 | May 25–29, 2026 | Claude Opus 4.8 new default for Max/Team Premium/Enterprise/API; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8 |
| W21 | May 18–22, 2026 | Auto mode on Pro plan (Sonnet 4.6 + Opus); `/usage` usage attribution by skill/subagent/plugin/MCP; `/code-review` command; background sessions in `/resume` |
| W20 | May 11–15, 2026 | Agent view (`claude agents`); `/goal` command; fast mode default on Opus 4.7; Rewind menu with "Summarize up to here" |
| W19 | May 4–8, 2026 | Plugins from `.zip` archives and URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see `effort.level` via `$CLAUDE_EFFORT` |
| W18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell as shell tool); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume` |
| W17 | Apr 20–24, 2026 | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| W16 | Apr 13–17, 2026 | Claude Opus 4.7 new default; `xhigh` effort level; Routines on web (scheduled cloud agents); mobile push notifications; native binaries |
| W15 | Apr 6–10, 2026 | Ultraplan early preview (cloud plan + web editor + remote run); Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| W14 | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override (up to 500K) |
| W13 | Mar 23–27, 2026 | Auto mode research preview; computer use in Desktop; PR auto-fix on web; transcript search with `/`; native PowerShell tool; conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API Console; contribution metrics with GitHub integration; PR attribution algorithm; leaderboard and data export
- [Manage costs effectively](references/claude-code-costs.md) — Token cost tracking with `/usage`, team spend limits, rate limit recommendations, agent team costs, and all strategies for reducing token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Full OTel configuration, all metrics and events schemas, span tracing (beta), SIEM integration, dynamic headers, and security/privacy guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) — Performance, stability, and search problems: high CPU/memory, auto-compact thrashing, command hangs, garbled text, ripgrep issues, WSL search
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — Installation errors, PATH issues, TLS failures, Windows-specific issues, login failures, OAuth errors, cloud provider credentials
- [Debug your configuration](references/claude-code-debug-your-config.md) — How to inspect what loaded via `/context`, `/memory`, `/hooks`, `/mcp`, `/doctor`, `/status`; common configuration mistakes and fixes; clean-config testing
- [Error reference](references/claude-code-errors.md) — All runtime error messages with causes and recovery steps; server errors, usage limits, authentication errors, network errors, request errors
- [Changelog](references/claude-code-changelog.md) — Full release notes for every Claude Code version
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index with one-line summaries of each week's headline features
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — Auto mode research preview; computer use in Desktop; transcript search; PowerShell tool; conditional hooks
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — Computer use in CLI; `/powerup` lessons; per-tool MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan; Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr`
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7; `xhigh` effort; Routines; mobile push notifications; native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview` research preview; session recap; custom themes; web redesign
- [What's new: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash; `claude ultrareview`; `claude project purge`; PR URL resume
- [What's new: Week 19](references/claude-code-whats-new-2026-w19.md) — Plugin zip/URL loading; `worktree.baseRef`; auto mode hard deny; hooks see effort level
- [What's new: Week 20](references/claude-code-whats-new-2026-w20.md) — Agent view; `/goal` command; fast mode on Opus 4.7; Rewind "Summarize up to here"
- [What's new: Week 21](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro; `/usage` attribution; `/code-review`; background sessions
- [What's new: Week 22](references/claude-code-whats-new-2026-w22.md) — Claude Opus 4.8; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8
- [What's new: Week 23](references/claude-code-whats-new-2026-w23.md) — Auto mode on Bedrock/Vertex/Foundry; safer auto-edits; `/plugin list`; version requirements
- [What's new: Week 24](references/claude-code-whats-new-2026-w24.md) — `/cd` command; nested sub-agents; `--safe-mode`; `fallbackModel` chains

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
