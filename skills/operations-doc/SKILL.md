---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards, cost management, OpenTelemetry monitoring, configuration debugging, troubleshooting (install, runtime, performance), runtime error reference, changelog, and weekly feature digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running, monitoring, troubleshooting, and keeping Claude Code up to date in production environments.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Contribution metrics setup (Teams/Enterprise):**
1. GitHub admin installs the Claude GitHub App at github.com/apps/claude
2. Claude Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle and complete GitHub auth

Key dashboard metrics: PRs with CC, lines of code with CC, suggestion accept rate, daily active users/sessions.

**Attribution rules:** sessions from 21 days before to 2 days after merge date are considered; code with >20% developer rewriting is not attributed; auto-generated files (lock files, dist/, build/) are excluded.

### Cost Management

**Average enterprise costs:** ~$13 per developer per active day; $150–250 per month.

**Track usage:** `/usage` shows session token stats and cost estimate (local approximation; see Console for billing).

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

**Reduce token usage:**

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` to drop stale context; `/compact` to summarize |
| Choose right model | `/model` — Sonnet for most tasks; Opus for complex reasoning; Haiku for subagents |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools (gh, aws) over MCP |
| Move instructions to skills | Keep CLAUDE.md under 200 lines; move specialized workflows to skills |
| Adjust extended thinking | `/effort` or `MAX_THINKING_TOKENS=8000` for simpler tasks |
| Delegate verbose ops to subagents | Test runs, log parsing — keeps verbose output out of main context |
| Write specific prompts | "Add validation to login function in auth.ts" beats "improve this codebase" |
| Use plan mode | Shift+Tab before implementation — explore then execute, not retry |

**Agent team costs:** ~7x more tokens than standard sessions (each teammate has its own context window).

**Background token usage:** <$0.04 per session for summarization and command processing.

### OpenTelemetry Monitoring

**Quick start:**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp       # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp          # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

**Key environment variables:**

| Variable | Default | Description |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | — | Required to enable telemetry (`1`) |
| `OTEL_METRICS_EXPORTER` | — | Metrics exporter: `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | — | Logs/events exporter: `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | — | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | OTLP collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | — | Auth headers, e.g. `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000 | Metrics export interval in ms |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000 | Logs export interval in ms |
| `OTEL_LOG_USER_PROMPTS` | off | Set `1` to log prompt content |
| `OTEL_LOG_TOOL_DETAILS` | off | Set `1` to log tool parameters and Bash commands |
| `OTEL_LOG_TOOL_CONTENT` | off | Set `1` to log tool input/output in trace spans |
| `OTEL_LOG_RAW_API_BODIES` | off | `1` (inline, 60KB) or `file:<dir>` (untruncated) for full API bodies |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include `user.account_uuid` in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | false | Include `app.version` in metrics |

**Traces (beta):** set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER=otlp` in addition to telemetry enable. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request` / `claude_code.tool` → `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`.

**Available metrics:**

| Metric | Unit | Description |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines of code modified |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Session API cost |
| `claude_code.token.usage` | tokens | Tokens used (input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept or reject decisions |
| `claude_code.active_time.total` | s | Active time (user + cli) |

**Key events (via `OTEL_LOGS_EXPORTER`):** `user_prompt`, `tool_result`, `tool_decision`, `api_request`, `api_error`, `api_request_body`, `api_response_body`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `skill_activated`, `plugin_installed`, `plugin_loaded`, `hook_registered`, `hook_execution_start`, `hook_execution_complete`, `compaction`, `at_mention`, `api_retries_exhausted`, `internal_error`.

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

**SIEM integration example (events only):**
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

**Security questions → events mapping:**

| Signal | Event | Key attributes |
| :--- | :--- | :--- |
| Tool call allowed/denied | `tool_decision` | `decision`, `source`, `tool_name` |
| Permission mode escalation | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Policy hook blocked action | `hook_execution_complete` | `hook_event`, `num_blocking` |
| Login/logout/auth failure | `auth` | `action`, `success`, `error_category` |
| MCP server connect/fail | `mcp_server_connection` | `status`, `server_name`, `error_code` |
| Plugin installed | `plugin_installed` | `plugin.name`, `marketplace.name`, `marketplace.is_official` |
| Commands run/files touched | `tool_result` with `OTEL_LOG_TOOL_DETAILS=1` | `tool_parameters`, `tool_input` |

**Dynamic headers** (for token refresh): set `otelHeadersHelper` in `.claude/settings.json` pointing to a script that outputs JSON headers. Runs every 29 minutes (configure with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`). Only applies to `http/protobuf` and `http/json` protocols.

**Multi-team segmentation:** `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"` (no spaces in values; use underscores or percent-encoding).

### Configuration Debugging

**Primary commands:**

| Command | What it shows |
| :--- | :--- |
| `/context` | Everything in context: system prompt, memory, skills, MCP tools, messages |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics: invalid keys, schema errors, install health |
| `/status` | Active settings sources; whether managed settings are in effect |
| `/debug [issue]` | Enable debug logging; prompts Claude to diagnose from logs |

**Settings scope override order:** managed → local → project → user. Environment variables act as another override layer.

**Common configuration surprises:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | Matcher is lowercase, e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks defined in a standalone file | Define under `"hooks"` key in `settings.json` |
| Permissions/env set globally ignored | Config added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| settings.json value ignored | Same key set in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill missing from /skills | Skill file at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Skill not invoked by Claude | `disable-model-invocation: true` or description mismatch | Check `/skills` badge; adjust description |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loads when Claude reads a file in that directory |
| MCP servers in .mcp.json not loading | File inside `.claude/` instead of repo root | Put `.mcp.json` at repository root |
| MCP server fails from some dirs | Relative path in `command` or `args` | Use absolute paths for local scripts |
| Project MCP server not appearing | One-time approval prompt was dismissed | Run `/mcp` to approve |

**Clean-room test:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```
Bypasses all user and project config. If the problem disappears, narrow down the cause by reintroducing files one at a time.

### Troubleshooting: Runtime Issues

**Routing guide:**

| Symptom | Go to |
| :--- | :--- |
| `command not found`, install fails, PATH issues, `EACCES`, TLS errors | Troubleshoot installation and login |
| Login loops, OAuth errors, `403 Forbidden`, Bedrock/Vertex/Foundry credentials | Troubleshoot installation and login — Login and authentication |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529`, `429`, request validation errors | Error reference |
| High CPU/memory, slow responses, hangs, search not finding files | Troubleshooting — Performance and stability |

**Performance and stability:**

- High CPU/memory: run `/compact` regularly; close and restart between major tasks; add build dirs to `.gitignore`
- Memory heap dump: `/heapdump` — writes `.heapsnapshot` and breakdown to `~/Desktop` (or home dir on Linux)
- Auto-compaction thrashing (`Autocompact is thrashing`): read oversized files in chunks; run `/compact` with focus; move large-file work to a subagent; run `/clear`
- Command hangs: Ctrl+C to cancel; relaunch and run `claude --resume` to pick up the session
- Search not finding files: install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`
- Slow search on WSL: keep projects on Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`)

### Troubleshooting: Installation and Login

**Quick diagnostic checks:**
```bash
curl -sI https://downloads.claude.ai/claude-code-releases/latest  # network check
echo $PATH | tr ':' '\n' | grep -Fx "$HOME/.local/bin"            # PATH check
which -a claude                                                    # conflicting installs
ldd "$(command -v claude)" | grep "not found"                      # missing libraries (Linux)
claude --version
```

**Common install errors:**

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; reload shell config |
| `syntax error near unexpected token '<'` (HTML) | App unavailable in region; retry; use Homebrew or WinGet |
| `curl: (56) Failure writing output to destination` | Network interrupted; retry; use Homebrew/WinGet |
| `Killed` during install on Linux | OOM — add swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate CAs |
| `irm is not recognized` | Use PowerShell, not CMD |
| `'bash' is not recognized` | Use PowerShell installer: `irm https://claude.ai/install.ps1 \| iex` |
| `Error loading shared library` | musl/glibc binary mismatch; check `ldd --version` |
| `Illegal instruction` | CPU lacks AVX or architecture mismatch; check `uname -m` |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `dyld: cannot load` on macOS | macOS 13.0+ required; update macOS |
| Install hangs in Docker | Set `WORKDIR /tmp` before installer; increase memory limit |
| Windows: `The process cannot access the file` | Delete `%USERPROFILE%\.claude\downloads` and retry |

**Login issues:**

| Issue | Fix |
| :--- | :--- |
| OAuth error: Invalid code | Complete login quickly after browser opens; use `c` to copy URL |
| 403 Forbidden after login | Verify active subscription; confirm "Claude Code" or "Developer" role in Console |
| Disabled organization with active subscription | Unset `ANTHROPIC_API_KEY` from shell profile; relaunch |
| OAuth login fails in WSL2/SSH/containers | Paste login code at `Paste code here` prompt; set `BROWSER` env var; use `claude auth login` |
| Token expired frequently | Check system clock accuracy; on macOS check Keychain — run `claude doctor` |
| Bedrock: `Could not load credentials` | Run `aws sts get-caller-identity`; confirm AWS credentials |
| Vertex: `Could not load the default credentials` | Set `ANTHROPIC_VERTEX_PROJECT_ID` and `CLOUD_ML_REGION`; run `gcloud auth application-default login` |
| Foundry: `ChainedTokenCredential authentication failed` | Set `ANTHROPIC_FOUNDRY_API_KEY` or run `az login` |

### Changelog and What's New

**Check your version:** `claude --version`

**Changelog:** full release notes at https://code.claude.com/docs/en/changelog.md (GitHub: github.com/anthropics/claude-code/blob/main/CHANGELOG.md)

**Weekly digest** (notable features with demos and context): https://code.claude.com/docs/en/whats-new/index.md

Recent weekly highlights:

| Week | Dates | Highlight |
| :--- | :--- | :--- |
| Week 19 | May 4–8, 2026 | Plugins from .zip archives and URLs; history search across all projects (Ctrl+R) |
| Week 18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell shell tool); `claude ultrareview` for CI; `claude project purge` |
| Week 17 | Apr 20–24, 2026 | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| Week 16 | Apr 13–17, 2026 | Claude Opus 4.7 as default; `xhigh` effort level; Routines on web; mobile push notifications; native CLI binaries |
| Week 15 | Apr 6–10, 2026 | Ultraplan early preview; Monitor tool for background event streaming; `/loop` self-pacing |
| Week 14 | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview); `/powerup` interactive lessons |
| Week 13 | Mar 23–27, 2026 | Auto mode research preview; computer use in Desktop; transcript search with `/` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API customers, contribution metrics setup, PR attribution, leaderboard, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — cost tracking with `/usage`, team spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — full OTel configuration, all metrics and events, span tracing (beta), SIEM integration, security audit events, backend recommendations
- [Debug your configuration](references/claude-code-debug-your-config.md) — diagnosing CLAUDE.md, settings, hooks, MCP servers, and skills; `/context`, `/doctor`, `/hooks`, `/mcp` commands; clean-room testing
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, stability, search issues, high CPU/memory, auto-compaction thrashing, command hangs
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — install errors by platform, PATH issues, TLS/SSL errors, login failures, OAuth errors, Bedrock/Vertex/Foundry credentials
- [Error reference](references/claude-code-errors.md) — runtime error messages, all error categories (server, usage limits, auth, network, request), automatic retries, response quality troubleshooting
- [Changelog](references/claude-code-changelog.md) — release notes for every Claude Code version
- [What's new index](references/claude-code-whats-new-index.md) — weekly feature digest index with links to each week's highlights
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, transcript search, native PowerShell tool, conditional hooks
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, `/powerup` lessons, per-tool MCP result-size override, plugin executables on PATH
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop` self-pacing, `/team-onboarding`, `/autofix-pr`
- [Week 16 digest](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile push notifications, `/usage` limit detail, native CLI binaries
- [Week 17 digest](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes, Claude Code on the web redesign
- [Week 18 digest](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview` for CI, `claude project purge`, paste PR URL into `/resume`
- [Week 19 digest](references/claude-code-whats-new-2026-w19.md) — plugins from .zip/URL, Ctrl+R history search across projects, `worktree.baseRef`, auto mode hard deny rules, hooks see effort level

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
- Week 13 digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 digest: https://code.claude.com/docs/en/whats-new/2026-w15.md
- Week 16 digest: https://code.claude.com/docs/en/whats-new/2026-w16.md
- Week 17 digest: https://code.claude.com/docs/en/whats-new/2026-w17.md
- Week 18 digest: https://code.claude.com/docs/en/whats-new/2026-w18.md
- Week 19 digest: https://code.claude.com/docs/en/whats-new/2026-w19.md
