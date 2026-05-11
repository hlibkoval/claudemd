---
name: operations-doc
description: Complete official documentation for operating Claude Code in teams and production — analytics, cost management, OpenTelemetry monitoring, configuration debugging, troubleshooting, error reference, and the weekly What's New digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, and troubleshooting Claude Code, including analytics dashboards, cost tracking and reduction, OpenTelemetry telemetry, configuration debugging, installation troubleshooting, runtime error reference, and weekly release digests.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key Metrics |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Lines accepted, accept rate, spend, per-user table |

Contribution metrics require GitHub app installation and Owner role. Needs GitHub analytics toggle enabled at `claude.ai/admin-settings/claude-code`. Data updates daily; attribution window is 21 days before to 2 days after PR merge.

### Cost Management

| Strategy | Command / Setting |
| :--- | :--- |
| Check session spend | `/usage` |
| Clear context between tasks | `/clear`, then `/resume` later |
| Compact with focus | `/compact Focus on code changes` |
| Switch model | `/model` (Sonnet default; Opus for hard tasks) |
| Adjust thinking budget | `/effort` or `MAX_THINKING_TOKENS=8000` |
| View what's in context | `/context` |

**Average cost:** ~$13/developer/active day; ~$150–250/month. For API teams, set workspace spend limits at `platform.claude.com`.

**Rate limit guidance (TPM per user by team size):**

| Team size | TPM/user | RPM/user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

### OpenTelemetry (Monitoring)

**Minimal setup:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key env vars:**

| Variable | Purpose | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics backend: `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | Events backend: `otlp`, `console`, `none` | — |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content in events | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool args, Bash cmds, MCP names | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in trace spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full request/response JSON (`1` or `file:<dir>`) | off |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics flush interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs flush interval (ms) | 5000 |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid in metrics | true |

**Exported metrics:**

| Metric | Unit |
| :--- | :--- |
| `claude_code.session.count` | count |
| `claude_code.token.usage` | tokens (type: input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage` | USD |
| `claude_code.lines_of_code.count` | count (type: added/removed) |
| `claude_code.commit.count` | count |
| `claude_code.pull_request.count` | count |
| `claude_code.code_edit_tool.decision` | count (tool, decision, source, language) |
| `claude_code.active_time.total` | seconds (type: user/cli) |

**Exported events:** `user_prompt`, `tool_result`, `tool_decision`, `api_request`, `api_error`, `api_request_body`, `api_response_body`, `api_retries_exhausted`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `internal_error`, `plugin_installed`, `skill_activated`, `at_mention`, `hook_execution_start`, `hook_execution_complete`, `compaction`

**Distributed tracing (beta):** Set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER=otlp`. Spans: `claude_code.interaction` > `llm_request`, `tool` > `tool.blocked_on_user`, `tool.execution`.

**Audit / SIEM:** Use `OTEL_LOG_TOOL_DETAILS=1` and point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver.

### Debugging Configuration

| Command | What it shows |
| :--- | :--- |
| `/context` | Everything in the context window |
| `/memory` | Which CLAUDE.md files loaded |
| `/skills` | Available skills (project, user, plugin) |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics; press `f` to have Claude fix issues |
| `/status` | Active settings sources, managed settings |
| `/debug [issue]` | Enable debug logging for the session |

**Test against clean config:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**Common config problems:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | matcher is JSON array, not string | Use `"Edit\|Write"` (pipe-separated string) |
| Hook never fires | lowercase matcher e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Permissions ignored | Config in `~/.claude.json` | Use `~/.claude/settings.json` for hooks/permissions/env |
| Skill missing from `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP server never loads | File under `.claude/` not repo root | Place `.mcp.json` at repository root |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at start | Triggers when Claude reads a file in that directory |

### Troubleshooting Installation

**Quick diagnostic:** run `claude doctor` (before login) or `/doctor` (in session).

**Common install errors:**

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; re-source shell config |
| `syntax error near unexpected token '<'` | Install returned HTML; try `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `Killed` on Linux | Low memory; add swap: `sudo fallocate -l 2G /swapfile` |
| `TLS connect error` | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Error loading shared library` | musl/glibc mismatch; check with `ldd --version` |
| `Illegal instruction` | Missing AVX or wrong arch; check `uname -m` |
| `dyld: cannot load` (macOS) | macOS < 13.0; update macOS |
| `Exec format error` (WSL1) | Convert to WSL2: `wsl --set-version <distro> 2` |

**Auth issues:**

| Error | Fix |
| :--- | :--- |
| `Not logged in` | Run `/login` |
| `Invalid API key` | Check `ANTHROPIC_API_KEY` in env; run `env \| grep ANTHROPIC` |
| Organization disabled | Unset stale `ANTHROPIC_API_KEY` from shell profile |
| OAuth error in WSL2/SSH | Paste the code shown in terminal; press `c` to copy OAuth URL |
| Bedrock/Vertex creds | Run `aws sts get-caller-identity` or `gcloud auth application-default login` |

### Runtime Error Reference

Retries: up to 10 attempts with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

**Error categories:**

| Category | Key errors |
| :--- | :--- |
| Server | 500 Internal error, 529 Overloaded, Request timed out, Auto mode classifier failure |
| Usage limits | Session/weekly limit hit, 429 rate limit, Credit balance too low |
| Authentication | Not logged in, Invalid API key, Organization disabled, OAuth expired |
| Network | Unable to connect (ECONNREFUSED/ETIMEDOUT), SSL cert failure, Host not allowed (cloud/routine) |
| Request | Prompt too long, Compaction failed, Request too large (>30MB), Image too large, PDF errors, Extra inputs not permitted, Model not found, Opus not on Pro plan, Thinking budget exceeded, Tool use mismatch |

**Recovery commands:** `/compact`, `/clear`, `/rewind` (Esc+Esc), `/model`, `/login`, `/logout`, `/feedback`

### What's New (Recent Releases)

| Week | Dates | Highlights |
| :--- | :--- | :--- |
| W19 | May 4–8, 2026 (v2.1.128–136) | Plugins from `.zip` archives and `--plugin-url`; `worktree.baseRef`; auto mode hard deny rules; hooks get effort level via `$CLAUDE_EFFORT` |
| W18 | Apr 27–May 1 (v2.1.120–126) | Windows without Git Bash (PowerShell fallback); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume` |
| W17 | Apr 20–24 (v2.1.114–119) | `/ultrareview` public research preview; session recap; custom themes from `/theme` or plugin; Claude Code on the web redesign |
| W16 | Apr 13–17 (v2.1.105–113) | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort level; Routines on web; mobile push notifications; `/usage` shows limit breakdown |
| W15 | Apr 6–10 (v2.1.92–101) | Ultraplan early preview; Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| W14 | Mar 30–Apr 3 (v2.1.86–91) | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override (up to 500K) |
| W13 | Mar 23–27 (v2.1.83–85) | Auto mode (research preview); computer use in Desktop; PR auto-fix on Web; transcript search with `/`; PowerShell tool; conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — team usage dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard
- [Manage costs](references/claude-code-costs.md) — track spend with `/usage`, team rate limits, agent team costs, context reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — full env var reference, all metrics, all events, trace spans, SIEM integration
- [Debug your configuration](references/claude-code-debug-your-config.md) — /context, /doctor, hook debugging, MCP diagnostics, clean-config test, common causes table
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, permissions, TLS, Windows/WSL issues, OAuth errors, cloud provider credentials
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, high CPU/memory, auto-compact thrashing, hangs, search issues
- [Error reference](references/claude-code-errors.md) — every runtime error message with recovery steps
- [Changelog](references/claude-code-changelog.md) — full version history of all releases
- [What's New index](references/claude-code-whats-new-index.md) — weekly digest index (W13–W19)
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use Desktop, PR auto-fix, PowerShell tool, conditional hooks
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — computer use CLI, /powerup, MCP result-size override, plugin executables on PATH
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /team-onboarding, /autofix-pr
- [Week 16 digest](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile notifications, native binaries
- [Week 17 digest](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [Week 18 digest](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview CLI, claude project purge
- [Week 19 digest](references/claude-code-whats-new-2026-w19.md) — zip/URL plugins, cross-project history search, worktree.baseRef, auto mode hard deny

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New index: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 digest: https://code.claude.com/docs/en/whats-new/2026-w15.md
- Week 16 digest: https://code.claude.com/docs/en/whats-new/2026-w16.md
- Week 17 digest: https://code.claude.com/docs/en/whats-new/2026-w17.md
- Week 18 digest: https://code.claude.com/docs/en/whats-new/2026-w18.md
- Week 19 digest: https://code.claude.com/docs/en/whats-new/2026-w19.md
