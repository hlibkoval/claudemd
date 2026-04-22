---
name: operations-doc
description: Claude Code operations — analytics dashboards, cost tracking and reduction, OpenTelemetry monitoring (metrics, events, traces), config debugging (/context, /doctor, /hooks, /mcp), troubleshooting installation/auth/performance, changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, configuration debugging, troubleshooting, and release notes.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | What's included |
|---|---|---|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user table |

**Contribution metrics setup** (Teams/Enterprise, public beta):
1. GitHub admin installs the Claude GitHub app at github.com/apps/claude
2. Owner enables Claude Code analytics at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle and authenticate with GitHub

**Key contribution metrics:** PRs with CC, lines of code with CC, PRs with CC (%), suggestion accept rate, lines of code accepted. Attribution window: sessions from 21 days before to 2 days after merge. Code rewritten more than 20% is not attributed.

---

### Cost management

**Typical API cost:** ~$13/developer/active day; ~$150–250/developer/month.

**Track costs:** `/cost` (API users) or `/stats` (subscribers). Console billing: platform.claude.com/usage.

**Rate limit recommendations (TPM/RPM per user):**

| Team size | TPM per user | RPM per user |
|---|---|---|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost-reduction strategies:**

| Strategy | How |
|---|---|
| Clear between tasks | `/clear` then `/rename` + `/resume` to return later |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Choose right model | Sonnet for most tasks; Opus for complex reasoning; Haiku for subagents |
| Reduce MCP overhead | Disable unused servers with `/mcp`; prefer CLI tools (gh, aws, gcloud) |
| Offload to hooks | Pre-process large outputs (grep log files) before Claude sees them |
| Move instructions to skills | Keep CLAUDE.md under 200 lines; move workflows to on-demand skills |
| Reduce thinking | `/effort` to lower effort level, or set `MAX_THINKING_TOKENS=8000` |
| Delegate verbose ops | Use subagents so verbose output stays out of main context |
| Write specific prompts | "add input validation to login function in auth.ts" not "improve codebase" |
| Plan mode first | Shift+Tab to enter plan mode before implementation |

**Agent team token costs:** ~7x more tokens than standard sessions. Use Sonnet for teammates; keep teams small; enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

---

### OpenTelemetry monitoring

**Quick start:**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp       # otlp, prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp          # otlp, console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

**Key environment variables:**

| Variable | Description | Values |
|---|---|---|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `console`, `otlp`, `prometheus`, `none` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `console`, `otlp`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Transport protocol | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval ms (default: 60000) | `5000`, `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms (default: 5000) | `1000`, `10000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) | `1` |
| `OTEL_LOG_TOOL_DETAILS` | Log tool parameters/commands (default: off) | `1` |
| `OTEL_LOG_TOOL_CONTENT` | Log tool I/O in trace spans (default: off) | `1` |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response bodies | `1` or `file:<dir>` |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics (default: true) | `false` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid (default: true) | `false` |

**Traces (beta):** Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request`, `claude_code.tool` (→ `blocked_on_user`, `tool.execution`), `claude_code.hook`.

**Available metrics:**

| Metric | Description | Unit |
|---|---|---|
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit decisions | count |
| `claude_code.active_time.total` | Active time | seconds |

**Events exported:** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_request_body`, `claude_code.api_response_body`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.internal_error`, `claude_code.plugin_installed`, `claude_code.skill_activated`, `claude_code.api_retries_exhausted`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`, `claude_code.compaction`.

**Dynamic headers:** configure `"otelHeadersHelper"` in `.claude/settings.json` pointing to a script that outputs JSON headers. Refreshed every 29 minutes (adjust with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team segmentation:** `export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"` — no spaces in values; percent-encode special characters.

---

### Debug your configuration

**Start here:** `/context` shows everything in the current context window (system prompt, memory files, skills, MCP tools).

| Command | What it shows |
|---|---|
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and their status |
| `/permissions` | Resolved allow/deny rules in effect |
| `/doctor` | Configuration diagnostics, invalid keys, installation health |
| `/status` | Active settings sources, managed settings status |

**Common config problems:**

| Symptom | Cause | Fix |
|---|---|---|
| Hook never fires | `matcher` is a JSON array | Use a string with `\|` separator, e.g. `"Edit\|Write"` |
| Hook never fires | Matcher is lowercase, e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks in a standalone file | Hooks go under `"hooks"` key in `settings.json` only |
| Global settings ignored | Config added to `~/.claude.json` | `permissions`/`hooks`/`env` belong in `~/.claude/settings.json` |
| Settings value ignored | Same key in `settings.local.json` | Local overrides project, which overrides user settings |
| Skill not in `/skills` | Skill file at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Skill never invokes | `disable-model-invocation: true` in frontmatter | Check `/skills` badge; remove the flag if Claude should auto-invoke |
| Subdirectory CLAUDE.md ignored | Subdirectory files load on demand | They load when Claude reads a file there with the Read tool |
| MCP server not loading | `.mcp.json` is under `.claude/` | Place `.mcp.json` at repository root |
| MCP server approved but zero tools | Server started but not returning tools | Run `/mcp` → Reconnect; if still zero, use `claude --debug mcp` |
| MCP relative path fails | Relative paths resolve from launch directory | Use absolute paths in `command` and `args` |
| MCP env vars missing | `settings.json` env doesn't propagate to MCP | Set per-server `env` inside `.mcp.json` |

---

### Troubleshooting quick lookup

**Installation error index:**

| Error | Solution |
|---|---|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML — check region support or use Homebrew/WinGet |
| `curl: (56) Failure writing output` | Network interruption — retry or use `brew install --cask claude-code` |
| `Killed` during install on Linux | OOM — add 2GB swap (`sudo fallocate -l 2G /swapfile && sudo swapon /swapfile`) |
| TLS / SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Error loading shared library` | musl/glibc binary mismatch — reinstall or `apk add libgcc libstdc++ ripgrep` |
| `Illegal instruction` on Linux | Architecture mismatch — verify with `uname -m` |
| `dyld: cannot load` on macOS | macOS version too old (requires 13.0+); try `brew install --cask claude-code` |

**Auth issues:**
- `403 Forbidden`: check subscription is active; confirm "Claude Code" or "Developer" role in Console
- `OAuth error: Invalid code`: retry quickly after browser opens; use `c` to copy URL for remote sessions
- `This organization has been disabled`: stale `ANTHROPIC_API_KEY` overriding subscription — unset it
- WSL2 OAuth: set `BROWSER=/mnt/c/Program Files/Google/Chrome/Application/chrome.exe`

**Performance:**
- High memory: use `/compact` regularly; run `/heapdump` to capture snapshot for GitHub issue
- Auto-compaction thrashing: read files in smaller chunks; use `/compact` with a focus directive; delegate to subagent
- Search not working: install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`
- Slow WSL search: keep project on Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`)

**Config file locations:**

| File | Purpose |
|---|---|
| `~/.claude/settings.json` | User settings (permissions, hooks, model) |
| `.claude/settings.json` | Project settings (committable) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global state (theme, OAuth, MCP servers) |
| `.mcp.json` | Project MCP servers (committable) |

Run `/doctor` to diagnose: checks installation, search, auto-update, settings validity, MCP config, keybindings, context warnings, plugin errors.

---

### Recent releases (weekly digests)

| Week | Dates | Key features |
|---|---|---|
| Week 15 | Apr 6–10, 2026 (v2.1.92–101) | Ultraplan cloud planning, Monitor tool for streaming events, self-pacing /loop, /autofix-pr from CLI, /team-onboarding |
| Week 14 | Mar 30–Apr 3, 2026 (v2.1.86–91) | Computer use in CLI, /powerup interactive lessons, flicker-free rendering, per-tool MCP result-size override up to 500K, plugin executables on PATH |
| Week 13 | Mar 23–27, 2026 (v2.1.83–85) | Auto mode for hands-off permissions, computer use in Desktop, PR auto-fix on web, transcript search with /, native PowerShell tool, conditional `if` hooks |

For all bug fixes and minor improvements, see the [full changelog](references/claude-code-changelog.md).

---

## Full Documentation

For the complete official documentation, see the reference files:

- [claude-code-analytics.md](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API customers, contribution metrics, GitHub integration, PR attribution
- [claude-code-costs.md](references/claude-code-costs.md) — Cost tracking with /cost, team spend limits, rate limit recommendations, token-reduction strategies
- [claude-code-monitoring-usage.md](references/claude-code-monitoring-usage.md) — Full OpenTelemetry reference: all env vars, metrics, events, traces, span attributes, backend guidance
- [claude-code-debug-your-config.md](references/claude-code-debug-your-config.md) — Diagnosing CLAUDE.md, settings, hooks, MCP, and skills using /context, /doctor, /hooks, /mcp
- [claude-code-troubleshooting.md](references/claude-code-troubleshooting.md) — Installation, authentication, performance, IDE integration, and markdown formatting issues
- [claude-code-changelog.md](references/claude-code-changelog.md) — Full version-by-version release notes
- [claude-code-whats-new-index.md](references/claude-code-whats-new-index.md) — Index of weekly feature digests
- [claude-code-whats-new-2026-w13.md](references/claude-code-whats-new-2026-w13.md) — Week 13 digest: auto mode, computer use in Desktop, PR auto-fix, transcript search, PowerShell tool, conditional hooks
- [claude-code-whats-new-2026-w14.md](references/claude-code-whats-new-2026-w14.md) — Week 14 digest: computer use in CLI, /powerup lessons, flicker-free rendering, MCP result-size override, plugin executables on PATH
- [claude-code-whats-new-2026-w15.md](references/claude-code-whats-new-2026-w15.md) — Week 15 digest: Ultraplan, Monitor tool, /autofix-pr, /team-onboarding

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring (OpenTelemetry): https://code.claude.com/docs/en/monitoring-usage.md
- Debug your config: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
