---
name: operations-doc
description: Complete official documentation for operating Claude Code at team and enterprise scale — analytics dashboards (Teams/Enterprise and API/Console), OpenTelemetry monitoring (metrics, events, traces, span hierarchy, security/SIEM auditing), cost tracking and reduction (token usage, rate limits, agent team costs, context strategies), error reference (server/usage/auth/network/request errors with recovery steps), installation and login troubleshooting (PATH, TLS, Windows/WSL/Linux issues, OAuth), configuration debugging (/context, /doctor, /hooks, /mcp, settings scopes), performance troubleshooting (CPU/memory, auto-compaction, search), and the weekly What's New digest.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, troubleshooting, and maintaining Claude Code at team and enterprise scale.

## Quick Reference

### Operations Topic Map

| Topic | Use when |
| :--- | :--- |
| **Analytics** | Viewing usage metrics, contribution metrics, GitHub integration, leaderboard, CSV export |
| **Monitoring (OTel)** | Exporting metrics/events/traces to Prometheus, Grafana, Datadog, SIEM |
| **Costs** | Tracking spend, setting limits, reducing token usage |
| **Error reference** | Looking up a runtime error message and its fix |
| **Troubleshoot install** | `command not found`, PATH, TLS, Windows/WSL/Linux install failures, OAuth login errors |
| **Debug config** | Settings not applying, hooks not firing, MCP not loading, skills missing |
| **Troubleshooting** | High CPU/memory, hangs, auto-compact thrashing, search not finding files |
| **What's New** | Latest feature releases and weekly digests |

---

### Analytics Dashboards

| Plan | Dashboard URL | Available metrics |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Teams/Enterprise contribution metrics setup:**
1. GitHub admin installs the Claude GitHub app at github.com/apps/claude
2. Claude Owner enables analytics at claude.ai/admin-settings/claude-code
3. Enable the "GitHub analytics" toggle and complete OAuth flow
4. Data appears within 24 hours; updates daily

Attribution: PRs tagged `claude-code-assisted` in GitHub. 21-day session window (21 days before to 2 days after merge). Excluded: lock files, generated code, build dirs, test fixtures, lines over 1,000 chars. Code rewritten by developers by more than 20% is not attributed.

---

### OpenTelemetry Monitoring — Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

**Key configuration variables:**

| Variable | Default | Description |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | — | Required to enable; set to `1` |
| `OTEL_METRICS_EXPORTER` | — | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | — | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | — | `grpc`, `http/protobuf`, `http/json` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | Collector endpoint for all signals |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000 ms | Metrics export interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000 ms | Logs export interval |
| `OTEL_LOG_USER_PROMPTS` | disabled | Set to `1` to log prompt content |
| `OTEL_LOG_TOOL_DETAILS` | disabled | Set to `1` to log tool params, Bash commands, MCP/skill names |
| `OTEL_LOG_TOOL_CONTENT` | disabled | Set to `1` to log tool input/output content (requires tracing) |
| `OTEL_LOG_RAW_API_BODIES` | disabled | `1` for inline (truncated 60 KB) or `file:<dir>` for untruncated files |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include `user.account_uuid`/`user.account_id` |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include `app.version` |

**Traces (beta):** Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`.

Trace span hierarchy:
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

**Exported metrics:**

| Metric | Unit | Description |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines of code modified (`type`: `added`/`removed`) |
| `claude_code.pull_request.count` | count | Pull requests created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | API cost per request |
| `claude_code.token.usage` | tokens | Tokens used (`type`: `input`/`output`/`cacheRead`/`cacheCreation`) |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept/reject decisions |
| `claude_code.active_time.total` | seconds | Active time (`type`: `user`/`cli`) |

**Key events** (via `OTEL_LOGS_EXPORTER`): `user_prompt`, `tool_result`, `api_request`, `api_error`, `api_request_body`, `api_response_body`, `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `plugin_installed`, `plugin_loaded`, `skill_activated`, `compaction`, `hook_registered`, `hook_execution_start`, `hook_execution_complete`, `at_mention`, `api_retries_exhausted`, `feedback_survey`.

**SIEM/audit:** Point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver. Enable `OTEL_LOG_TOOL_DETAILS=1` for full MCP/Bash audit. Key security events: `tool_decision` (allow/deny), `permission_mode_changed` (escalation), `auth` (login/logout), `mcp_server_connection`, `plugin_installed`.

**Service resource attributes:** `service.name=claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`.

---

### Cost Management

**Average costs:** ~$13/developer/active day; $150–250/developer/month; 90% of users below $30/active day.

**Track costs:**
- `/usage` — session token usage, cost estimate, plan limits (press `d`/`w` for 24h/7d breakdown)
- Console: platform.claude.com/usage for authoritative billing

**Team rate limit recommendations:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` to start fresh; `/rename` first to find session later |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Right model | `/model sonnet` for most tasks; `/model haiku` for simple subagents |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools like `gh`, `aws` |
| Move CLAUDE.md to skills | Keep CLAUDE.md under 200 lines; use skills for specialized workflows |
| Adjust thinking | `/effort`, `MAX_THINKING_TOKENS=8000`, or disable in `/config` |
| Use subagents for verbose ops | Running tests/logs in subagent keeps verbose output out of main context |
| Specific prompts | "add validation to login function in auth.ts" not "improve this codebase" |
| Plan mode | Shift+Tab before implementation to avoid expensive re-work |
| Agent team costs | Use Sonnet for teammates; keep teams small; `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to enable |

Agent teams use ~7x more tokens than standard sessions (each teammate has its own context window).

---

### Error Reference — Quick Lookup

**Automatic retries:** Server errors, 529, timeouts, temporary 429s retried up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000 ms).

**Server errors:**

| Error | Fix |
| :--- | :--- |
| `API Error: 500 Internal server error` | Check status page in message; retry; run `/feedback` if persistent |
| `API Error: Repeated 529 Overloaded errors` | Check status page; wait; run `/model` to switch models |
| `Request timed out` | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| `<model> is temporarily unavailable` (auto mode) | Retry after seconds; continue with read-only tasks |
| `Auto mode could not evaluate this action` | Retry; use `claude --debug` to inspect |
| `Auto mode classifier transcript exceeded context window` | Approve/deny manually; run `/compact` |

**Usage limits:**

| Error | Fix |
| :--- | :--- |
| `You've hit your session limit` / `You've hit your weekly limit` | Wait for reset time shown; `/usage`; `/usage-credits`; upgrade at claude.com/pricing |
| `Server is temporarily limiting requests` | Wait briefly; retry |
| `Request rejected (429)` | Check `/status` for active credential; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing; enable auto-reload |

**Authentication errors** (run `/status` to see active credential):

| Error | Fix |
| :--- | :--- |
| `Not logged in · Please run /login` | Run `/login`; check `ANTHROPIC_API_KEY` is exported; use `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos/revocation; `env \| grep ANTHROPIC` for stale keys; unset and use `/login` |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell/profile; relaunch `claude` |
| `Your organization has disabled Claude subscription access` | Ask admin to enable; use Console API key instead |
| `Routines are disabled by your organization's policy` | Ask admin to enable at claude.ai/admin-settings/claude-code |
| `OAuth token revoked` / `OAuth token has expired` | Run `/login`; if recurs, `/logout` then `/login` |
| `OAuth token does not meet scope requirement: user:profile` | Run `/login` (no need to log out first) |

**Network errors:**

| Error | Fix |
| :--- | :--- |
| `Unable to connect to API` (ECONNREFUSED/ECONNRESET/ETIMEDOUT) | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for gateways |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; never set `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `HTTP 403` with `x-deny-reason: host_not_allowed` | Edit cloud environment: change Network access to Custom; add domain to Allowed domains |

**Request errors:**

| Error | Fix |
| :--- | :--- |
| `Prompt is too long` | `/compact`; `/clear`; `/context` to see usage; disable unused MCP servers |
| `Error during compaction: Conversation too long` | Press Esc twice to step back; retry `/compact`; `/clear` if needed |
| `Request too large (max 30 MB)` | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice; resize image (8000px single / 2000px with many images) |
| `Unable to resize image` | Convert to PNG/JPEG/GIF/WebP; resize below reported limit |
| `PDF too large` / `PDF is password protected` | Read page range via Read tool; extract text with `pdftotext`; remove password |
| `Extra inputs are not permitted … context_management` | Configure gateway to forward `anthropic-beta`; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | `/model`; use alias (`sonnet`, `opus`); check stale `ANTHROPIC_MODEL` env var or settings files |
| `Claude Opus is not available with the Claude Pro plan` | `/model` to select included model; if recently upgraded, `/logout` then `/login` |
| `thinking.type.enabled is not supported for this model` | `claude update` to v2.1.111+; or switch to Opus 4.6/Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | `/rewind` or Esc twice to step back to checkpoint |
| `Claude Code is unable to respond to this request` (usage policy) | Press Esc twice or `/rewind`; rephrase; `/clear` to start fresh |

**Response quality diagnostics (no error shown):**

| Check | Command | What to look for |
| :--- | :--- | :--- |
| Model selection | `/model` | Wrong model or stale `ANTHROPIC_MODEL` |
| Effort level | `/effort` | Below maximum; use `ultrathink` for one-off deep reasoning |
| Context pressure | `/context` | Window near capacity — `/compact` or `/clear` |
| Stale instructions | `/doctor` | Oversized CLAUDE.md or MCP tool definitions |

Rewinding works better than correcting in-thread: press Esc twice or `/rewind` before the bad turn, then rephrase.

---

### Troubleshoot Installation

**Quick lookup:**

| Symptom | Fix |
| :--- | :--- |
| `command not found: claude` / `'claude' is not recognized` | Add `~/.local/bin` (macOS/Linux) or `%USERPROFILE%\.local\bin` (Windows) to PATH |
| `syntax error near unexpected token '<'` / HTML returned | Install script returned HTML (regional block or proxy); try `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `curl: (56) Failure writing output to destination` | Network interrupted; retry or use alternative installer |
| `Killed` during install on Linux | OOM killer; add 2 GB swap space (`sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile`) |
| `TLS connect error` / `SSL/TLS secure channel` | Update CA certs; use `NODE_EXTRA_CA_CERTS` for corporate CA; `--cacert` for install step |
| `irm is not recognized` or `&& is not valid` | Wrong shell; use `irm https://claude.ai/install.ps1 \| iex` in PowerShell |
| `Error loading shared library` | musl/glibc binary mismatch; check `ldd --version`; reinstall correct variant |
| `Illegal instruction` | CPU lacks AVX or architecture mismatch; check `uname -m` and `/proc/cpuinfo` |
| `dyld: cannot load` / `Abort trap: 6` on macOS | macOS version too old; requires macOS 13.0+; update macOS |
| `Exec format error` on WSL | WSL1 issue; convert to WSL2: `wsl --set-version <distro> 2` |
| `OAuth error` / `403 Forbidden` after login | Check subscription active; confirm "Claude Code" or "Developer" role in Console |
| `Could not load credentials` (Bedrock/Vertex/Foundry) | Run `aws sts get-caller-identity` / `gcloud auth application-default login` / `az login` |

**Install locations:**
- macOS/Linux: `~/.local/bin/claude`
- Windows: `%USERPROFILE%\.local\bin\claude.exe`
- Legacy (older versions): `~/.claude/local/`

**Multiple installations:** `which -a claude` (macOS/Linux) or `where.exe claude` (Windows). Remove extras with `npm uninstall -g @anthropic-ai/claude-code`, `rm -rf ~/.claude/local`, or `brew uninstall --cask claude-code`.

**WSL OAuth:** Browser may open on wrong machine. Copy displayed URL and open in local browser; paste login code at prompt. Set `BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"` if browser doesn't open.

---

### Debug Your Configuration

**Start with `/context`** — shows everything in the context window: system prompt, memory files, skills, MCP tools, conversation messages.

**Inspection commands:**

| Command | Shows |
| :--- | :--- |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from project, user, and plugin sources |
| `/agents` | Configured subagents |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics (press `f` to have Claude fix issues) |
| `/status` | Active settings sources; whether managed settings are in effect |

**Common configuration problems:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use a single string with `\|`: `"Edit\|Write"` |
| Hook never fires | `matcher` is lowercase (e.g., `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks defined in standalone file, not `settings.json` | Define hooks under `"hooks"` key in `settings.json` |
| Permissions/hooks/env set globally are ignored | Added to `~/.claude.json` | These belong in `~/.claude/settings.json` (two different files) |
| `settings.json` value ignored | Same key set in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill missing from `/skills` | Skill at `.claude/skills/name.md` instead of a folder | Use folder: `.claude/skills/name/SKILL.md` |
| Skill appears but Claude never invokes it | `disable-model-invocation: true` in frontmatter | Check badge in `/skills`; update frontmatter |
| Subdirectory CLAUDE.md instructions ignored | Subdirectory files load on demand (when Read tool reads a file in that dir) | Restate instructions in delegating prompt |
| MCP servers in `.mcp.json` never load | File is inside `.claude/` or uses wrong format | Project MCP config goes at repo root as `.mcp.json` |
| MCP server added but doesn't appear | One-time approval prompt was dismissed | Run `/mcp` to approve |
| MCP server fails from some directories | `command`/`args` uses relative path | Use absolute paths for local scripts |

**Test against clean config:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```
Bypasses all user config. Managed settings (org-deployed) still apply. If problem disappears, reintroduce files one at a time to isolate the cause.

---

### Performance and Stability

| Problem | Fix |
| :--- | :--- |
| High CPU/memory | `/compact` regularly; close/restart between major tasks; add large build dirs to `.gitignore`; run `/heapdump` for JS heap analysis |
| `Autocompact is thrashing` | Read oversized files in chunks; `/compact keep only the plan and the diff`; move to subagent; `/clear` |
| Command hangs/freezes | Press Ctrl+C to cancel; close terminal and restart; `claude --resume` to pick session back up |
| Search not finding files | Bundled `ripgrep` may not run; install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` |
| Slow/incomplete search on WSL | Working across WSL/Windows filesystems; use specific searches; move project to `/home/` on Linux filesystem |

**Diagnostics:** run `/doctor` inside Claude Code; or `claude doctor` from shell if Claude Code won't start.

---

### What's New — Recent Highlights

| Week | Key features |
| :--- | :--- |
| **W20 (May 11–15, 2026)** v2.1.139–v2.1.142 | `claude agents` agent view dashboard; `/goal` completion-condition looping; fast mode on Opus 4.7 by default; Rewind "Summarize up to here" |
| **W19 (May 4–8, 2026)** v2.1.128–v2.1.136 | Plugins load from `.zip` archives and `--plugin-url`; `worktree.baseRef` config; auto mode hard deny rules; hooks see `effort.level` and `$CLAUDE_EFFORT` |
| **W18 (Apr 27–May 1, 2026)** v2.1.120–v2.1.126 | Windows without Git Bash (PowerShell tool); `claude ultrareview` in CI/scripts; `claude project purge`; paste PR URL into `/resume` |
| **W17 (Apr 20–24, 2026)** v2.1.114–v2.1.119 | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| **W16 (Apr 13–17, 2026)** v2.1.105–v2.1.113 | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort level; Routines on web; mobile push notifications; native binaries |
| **W15 (Apr 6–10, 2026)** v2.1.92–v2.1.101 | Ultraplan early preview; Monitor tool for streaming background events; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| **W14 (Mar 30–Apr 3, 2026)** v2.1.86–v2.1.91 | Computer use in CLI (research preview); `/powerup` interactive lessons; flicker-free alt-screen rendering; per-tool MCP result-size override up to 500K |
| **W13 (Mar 23–27, 2026)** v2.1.83–v2.1.85 | Auto mode research preview; computer use in Desktop app; PR auto-fix on Web; transcript search with `/`; native PowerShell tool; conditional `if` hooks |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API/Console, contribution metrics setup, PR attribution, GitHub integration
- [Manage costs effectively](references/claude-code-costs.md) — /usage command, workspace spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring (OpenTelemetry)](references/claude-code-monitoring-usage.md) — OTel quick start, configuration variables, metrics/events reference, distributed traces (beta), span hierarchy and attributes, SIEM auditing, backend recommendations
- [Debug your configuration](references/claude-code-debug-your-config.md) — /context, /doctor, /status, MCP debugging, hooks debugging, settings scopes, common config problems and fixes
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, auto-compact thrashing, hangs, search issues, WSL filesystem performance
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH verification, conflicting installs, TLS errors, Windows/WSL/Linux install issues, OAuth login failures, Bedrock/Vertex/Foundry credentials
- [Error reference](references/claude-code-errors.md) — all runtime error messages with causes and recovery steps, automatic retry behavior, response quality diagnostics
- [Changelog](references/claude-code-changelog.md) — full version history and bug fixes
- [What's New index](references/claude-code-whats-new-index.md) — weekly digest index with summaries of each release week
- [What's New W13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use (Desktop), PR auto-fix, transcript search, PowerShell tool, conditional hooks
- [What's New W14](references/claude-code-whats-new-2026-w14.md) — computer use (CLI), /powerup, flicker-free rendering, MCP result-size override
- [What's New W15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop self-pacing, /team-onboarding, /autofix-pr
- [What's New W16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile push notifications, native binaries
- [What's New W17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [What's New W18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview, claude project purge, PR URL in /resume
- [What's New W19](references/claude-code-whats-new-2026-w19.md) — plugins from .zip/URL, worktree.baseRef, auto mode hard deny, hooks effort level
- [What's New W20](references/claude-code-whats-new-2026-w20.md) — claude agents, /goal, fast mode on Opus 4.7, Rewind summarize up to here

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring (OpenTelemetry): https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New index: https://code.claude.com/docs/en/whats-new/index.md
- What's New W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's New W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's New W20: https://code.claude.com/docs/en/whats-new/2026-w20.md
