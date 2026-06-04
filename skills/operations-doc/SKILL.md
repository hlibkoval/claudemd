---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics dashboards, cost tracking and reduction, OpenTelemetry monitoring, configuration debugging, troubleshooting performance and installation issues, runtime error recovery, and the changelog/what's-new digests.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key metrics |
|:-----|:--------------|:------------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage, contribution metrics (with GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Lines accepted, accept rate, activity, spend, per-user team insights |

Contribution metrics require a GitHub app install + Owner-role toggle. Data appears within 24 hours. Not available when Zero Data Retention is enabled.

#### PR Attribution

- PRs tagged `claude-code-assisted` in GitHub when they contain Claude Code-assisted lines
- Session window: 21 days before to 2 days after merge date
- Lines are normalized (trimmed, lowercased, quotes standardized) before matching
- Excluded: lock files, generated code, build dirs, test fixtures, lines over 1,000 chars
- Code rewritten >20% by developers is not attributed

### Cost Management

#### `/usage` command

Shows session token usage, cost estimate, and (on subscription plans) plan limit breakdown by skill, subagent, plugin, and MCP server. Press `d`/`w` to toggle 24h vs 7-day view.

#### Team rate limit recommendations (API users)

| Team size | TPM per user | RPM per user |
|:----------|:------------|:------------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

#### Cost reduction strategies

| Strategy | How |
|:---------|:----|
| Context management | `/clear` between tasks, `/compact Focus on…`, keep CLAUDE.md under 200 lines |
| Model selection | `/model` — Sonnet for most tasks, Opus for complex reasoning, Haiku for simple subagents |
| MCP overhead | Disable unused servers with `/mcp`; prefer CLI tools (`gh`, `aws`) over MCP |
| Extended thinking | Lower effort with `/effort` or set `MAX_THINKING_TOKENS=8000` for simpler tasks |
| Subagents | Delegate verbose ops (test runs, log fetching) to subagents to isolate context |
| Hooks | Use `PreToolUse` hooks to preprocess data (e.g., filter logs) before Claude sees it |
| Skills | Move CLAUDE.md workflow instructions to skills (load on-demand only) |
| Agent teams | Each teammate runs its own context window — keep teams small; use Sonnet for teammates |

Background token usage (summarization, `/usage` polling) is typically under $0.04/session.

### OpenTelemetry Monitoring

#### Quick start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp       # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp          # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

#### Key environment variables

| Variable | Default | Description |
|:---------|:--------|:------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | off | Required to enable telemetry |
| `OTEL_METRICS_EXPORTER` | — | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | — | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | — | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | Collector endpoint for all signals |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000ms | Metrics export interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000ms | Logs export interval |
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt content in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include Bash commands, MCP names, skill names in events |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool input/output in trace spans (requires tracing) |
| `OTEL_LOG_RAW_API_BODIES` | off | Emit full API request/response JSON (`1` inline, `file:<dir>` to disk) |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include `session.id` label on metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include `user.account_uuid` label |
| `OTEL_METRICS_INCLUDE_VERSION` | false | Include `app.version` label |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | false | Include `app.entrypoint` label |

#### Exported metrics

| Metric | Unit | Description |
|:-------|:-----|:------------|
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines of code modified (added/removed) |
| `claude_code.pull_request.count` | count | Pull requests created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Cost per API request |
| `claude_code.token.usage` | tokens | Tokens used (input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | count | Accept/reject decisions on Edit/Write/NotebookEdit |
| `claude_code.active_time.total` | s | Active time (user interaction + CLI processing) |

#### Exported events (via `OTEL_LOGS_EXPORTER`)

| Event name | Trigger |
|:-----------|:--------|
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission decision (accept/reject) |
| `claude_code.api_request` | Each API call to Claude |
| `claude_code.api_error` | API request fails after retries |
| `claude_code.api_request_body` | Full API request body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_response_body` | Full API response body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.permission_mode_changed` | Permission mode changes (e.g., via Shift+Tab) |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.mcp_server_connection` | MCP server connects, disconnects, or fails |
| `claude_code.plugin_installed` | Plugin install completes |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill is invoked |
| `claude_code.at_mention` | `@`-mention resolves |
| `claude_code.api_retries_exhausted` | API request fails after all retry attempts |
| `claude_code.hook_registered` | Hook inventory at session start |
| `claude_code.hook_execution_start` | Hook(s) begin executing |
| `claude_code.hook_execution_complete` | Hook(s) finish executing |
| `claude_code.hook_plugin_metrics` | Official-marketplace plugin hook emits metrics |
| `claude_code.compaction` | Conversation compaction completes |
| `claude_code.feedback_survey` | Session quality survey shown or answered |
| `claude_code.internal_error` | Unexpected internal error caught |

#### Tool decision `source` values

| Value | Meaning |
|:------|:--------|
| `config` | Decided automatically by settings, rules, flags, or session grant |
| `hook` | A `PreToolUse`/`PermissionRequest` hook returned the decision |
| `user_permanent` | User chose "Yes, don't ask again" — saves an allow rule |
| `user_temporary` | User chose "Yes" for one-time approval |
| `user_abort` | User dismissed the prompt without answering |
| `user_reject` | User chose "No" |

#### Traces (beta)

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`.

Span hierarchy:
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook       (detailed beta only)
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

Bash/PowerShell subprocesses automatically inherit `TRACEPARENT`. HTTP MCP requests also carry `traceparent`.

#### Dynamic headers (for token refresh)

Add to `.claude/settings.json`:
```json
{ "otelHeadersHelper": "/bin/generate_opentelemetry_headers.sh" }
```
Script must output JSON key-value pairs. Refreshes every 29 minutes (override with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`). Only works with `http/protobuf` and `http/json` protocols.

#### SIEM integration example (managed settings)

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_LOG_TOOL_DETAILS": "1",
    "OTEL_EXPORTER_OTLP_LOGS_PROTOCOL": "http/protobuf",
    "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT": "https://siem.example.com:4318/v1/logs",
    "OTEL_EXPORTER_OTLP_HEADERS": "Authorization=Bearer your-siem-token"
  }
}
```

### Debug Your Configuration

#### Diagnostic commands

| Command | Shows |
|:--------|:------|
| `/context` | Everything in the context window (system prompt, memory, skills, MCP, messages) |
| `/memory` | Which `CLAUDE.md` and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules in effect |
| `/doctor` | Configuration diagnostics — invalid keys, schema errors, installation health |
| `/debug [issue]` | Enable debug logging and prompt Claude to diagnose |
| `/status` | Active settings sources, whether managed settings apply |

#### Common configuration gotchas

| Symptom | Cause | Fix |
|:--------|:------|:----|
| Hook never fires | `matcher` is JSON array instead of string | Use `"Edit\|Write"` (pipe-separated string) |
| Hook never fires | `matcher` is lowercase | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Defined in a standalone file | Hooks go under `"hooks"` key in `settings.json` |
| Settings ignored | Added to `~/.claude.json` | `permissions`, `hooks`, `env` belong in `~/.claude/settings.json` |
| `settings.json` value ignored | Same key set in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill not in `/skills` | File at `.claude/skills/name.md` (flat) | Use folder: `.claude/skills/name/SKILL.md` |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loads when Claude reads a file there with the Read tool |
| MCP server not loading | `.mcp.json` inside `.claude/` | Project MCP config goes at the repo root as `.mcp.json` |
| MCP server env vars missing | Set in `settings.json` `env` | Set per-server `env` inside `.mcp.json` instead |

Test with a clean session: `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude`

### Troubleshooting (Runtime)

Run `/doctor` first for an automated check. For issues before Claude Code starts, run `claude doctor` from the shell.

| Symptom | Page |
|:--------|:-----|
| `command not found`, PATH issues, TLS errors | [Troubleshoot installation](#install-troubleshooting-quick-lookup) |
| Login loops, OAuth errors, `403 Forbidden` | [Troubleshoot installation — login section](#login-quick-lookup) |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration (above) |
| `API Error: 5xx`, `529`, `429`, validation errors | Error reference (below) |

#### Performance fixes

| Issue | Fix |
|:------|:----|
| High CPU/memory | `/compact` regularly; close/restart between tasks; add build dirs to `.gitignore` |
| Persistent high memory | `/heapdump` writes a snapshot and breakdown to `~/Desktop` |
| Auto-compact thrashing | Read oversized files in chunks; `/compact keep only the plan and diff`; use subagent |
| Command hangs | Ctrl+C to cancel; `claude --resume` to recover session |
| Garbled text in VS Code / Cursor terminal | `/terminal-setup` to disable GPU acceleration |
| Search not finding files | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work from Linux filesystem (`/home/`) not Windows filesystem (`/mnt/c/`) |

### Installation Troubleshooting Quick Lookup

| Error | Fix |
|:------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH in shell profile |
| Install script returns HTML / `syntax error near '<'` | Network/region issue; try `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `curl: (56) Failure writing output` | Network instability; retry or use alternative installer |
| `Killed` during install on Linux | OOM — add 2GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| TLS / SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate CA |
| `irm is not recognized` | Wrong shell — use PowerShell for `irm`, CMD for `curl` |
| `Error loading shared library` | musl/glibc mismatch — check with `ldd --version` |
| `Illegal instruction` | Missing AVX or architecture mismatch — check `uname -m` |
| `dyld: cannot load` on macOS | macOS < 13.0; update macOS |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <distro> 2` |
| `The process cannot access the file` on Windows | Clear `%USERPROFILE%\.claude\downloads` and retry |
| Install hangs in Docker | Set `WORKDIR /tmp` before installing |

### Login Quick Lookup

| Error | Fix |
|:------|:----|
| `OAuth error: Invalid code` | Code expired — retry quickly; press `c` to copy URL and open manually |
| `403 Forbidden` after login | Check subscription active; confirm "Claude Code" role in Console |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` overriding subscription — `unset ANTHROPIC_API_KEY` |
| OAuth fails in WSL2/SSH/containers | Browser opens on wrong host — paste the login code shown in terminal |
| Token expired repeatedly | Check system clock; on macOS run `security unlock-keychain ~/Library/Keychains/login.keychain-db` |
| Bedrock: `Could not load credentials` | Run `aws sts get-caller-identity` to verify AWS credentials |
| Vertex: `Could not load the default credentials` | Run `gcloud auth application-default login` |
| Foundry: `ChainedTokenCredential authentication failed` | Run `az login` |

### Error Reference Quick Lookup

Claude Code retries transient failures up to 10 times (configurable via `CLAUDE_CODE_MAX_RETRIES`, default 10). Timeout configurable via `API_TIMEOUT_MS` (default 600000ms).

| Error | Category | Fix |
|:------|:---------|:----|
| `API Error: 500` | Server | Retry; check status.claude.com |
| `API Error: 529 Overloaded` | Server | Retry; switch model with `/model` |
| `Request timed out` | Server | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session/weekly limit` | Usage limit | Wait for reset; `/usage-credits` to buy more |
| `Server is temporarily limiting requests` | Usage limit | Wait briefly and retry |
| `Request rejected (429)` | Rate limit | Check `/status`; reduce `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Usage limit | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check key in Console; unset stale `ANTHROPIC_API_KEY` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY` |
| `OAuth token revoked/expired` | Auth | `/login`; if recurring, `/logout` then `/login` |
| `Unable to connect to API` | Network | Check internet; set `HTTPS_PROXY`; verify firewall allows `api.anthropic.com` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `403` with `x-deny-reason: host_not_allowed` | Network (cloud) | Add domain to cloud environment's allowed domains list |
| `Prompt is too long` | Request | `/compact`; `/context` to inspect; disable unused MCP servers |
| `Error during compaction: Conversation too long` | Request | Esc twice to step back; then `/compact` or `/clear` |
| `Request too large` | Request | Esc twice; reference large files by path instead of pasting |
| `There's an issue with the selected model` | Request | `/model` to pick available model; clear stale `ANTHROPIC_MODEL` env var |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| `thinking.type.enabled is not supported` | Request | `claude update` (need v2.1.111+ for Opus 4.7, v2.1.154+ for Opus 4.8) |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` or Esc twice to restore checkpoint |
| `Claude Code is unable to respond…Usage Policy` | Request | Esc twice or `/rewind` to step back past triggering content |

### What's New (Weekly Digest) — Recent Highlights

| Week | Versions | Key features |
|:-----|:---------|:-------------|
| W22 (May 25–29) | v2.1.150–157 | Claude Opus 4.8 as default; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8 |
| W21 (May 18–22) | v2.1.143–149 | Auto mode on Pro plan; `/usage` plan breakdown by skill/plugin; `/code-review`; background sessions |
| W20 (May 11–15) | v2.1.139–142 | `claude agents` view; `/goal` continuous-work mode; fast mode on Opus 4.7; Rewind "Summarize up to here" |
| W19 (May 4–8) | v2.1.128–136 | Plugins load from `.zip` and URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level |
| W18 (Apr 27–May 1) | v2.1.120–126 | Windows without Git Bash (PowerShell as shell tool); `claude ultrareview`; `claude project purge` |
| W17 (Apr 20–24) | v2.1.114–119 | `/ultrareview` public preview; session recap; custom themes; Claude Code on the web redesign |
| W16 (Apr 13–17) | v2.1.105–113 | Claude Opus 4.7; `xhigh` effort level; Routines (scheduled cloud agents); mobile push notifications |
| W15 (Apr 6–10) | v2.1.92–101 | Ultraplan (cloud planning + web editor); Monitor tool for live log tailing; `/loop` self-pacing |
| W14 (Mar 30–Apr 3) | v2.1.86–91 | Computer use CLI (research preview); `/powerup` lessons; per-tool MCP result-size override |
| W13 (Mar 23–27) | v2.1.83–85 | Auto mode (research preview); computer use in Desktop; PR auto-fix on Web; native PowerShell tool |

Run `claude --version` to check your installed version. Full changelog at: https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API customers, GitHub integration for contribution metrics, PR attribution, leaderboard, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, team rate limits, agent team costs, token reduction strategies (context, model, MCP, thinking, hooks, skills, subagents)
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Complete OTel setup, all env vars, metrics and events schemas, traces (beta), dynamic headers, SIEM integration, cardinality control
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnosing why CLAUDE.md, settings, hooks, MCP, or skills aren't taking effect; `/context`, `/doctor`, `/hooks`, `/mcp`; clean session testing; common cause table
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, auto-compact thrashing, hangs, garbled text, search/discovery issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — Installation errors by platform, PATH fixes, TLS/SSL, Windows-specific, WSL, OAuth errors, Bedrock/Vertex/Foundry credentials
- [Error reference](references/claude-code-errors.md) — All runtime error messages with recovery steps: server errors, usage limits, authentication, network, request errors, response quality
- [Changelog](references/claude-code-changelog.md) — Full release notes by version number
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index with summaries of each week's highlights
- [What's new 2026-W13](references/claude-code-whats-new-2026-w13.md) — Auto mode research preview, computer use in Desktop, PR auto-fix on Web, PowerShell tool, conditional hooks
- [What's new 2026-W14](references/claude-code-whats-new-2026-w14.md) — Computer use CLI preview, `/powerup`, MCP result-size override, plugin executables on PATH
- [What's new 2026-W15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop` self-pacing, `/team-onboarding`, `/autofix-pr`
- [What's new 2026-W16](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, `xhigh` effort, Routines, mobile push notifications, CLI native binaries
- [What's new 2026-W17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview` public preview, session recap, custom themes, web redesign
- [What's new 2026-W18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview` in CI, `claude project purge`, PR URL in `/resume`
- [What's new 2026-W19](references/claude-code-whats-new-2026-w19.md) — Plugin zip/URL loading, `worktree.baseRef`, auto mode hard deny rules, hooks effort access
- [What's new 2026-W20](references/claude-code-whats-new-2026-w20.md) — `claude agents` view, `/goal`, fast mode on Opus 4.7, Rewind "Summarize up to here"
- [What's new 2026-W21](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro, `/usage` breakdown, `/code-review`, background sessions in `/resume`
- [What's new 2026-W22](references/claude-code-whats-new-2026-w22.md) — Claude Opus 4.8, dynamic workflows, security-guidance plugin, fast mode on Opus 4.8

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
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
