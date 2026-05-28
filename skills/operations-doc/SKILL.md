---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code — covering analytics, cost management, OpenTelemetry monitoring, configuration debugging, troubleshooting, error reference, and the release changelog.

## Quick Reference

### Analytics Dashboards

| Plan | URL | Features |
|:-----|:----|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user insights |

Contribution metrics require: GitHub app installed at github.com/apps/claude + "GitHub analytics" toggle enabled in admin settings. Data appears within 24 hours, updated daily. Not available with Zero Data Retention.

**Key contribution metric definitions:**
- **PRs with CC**: merged PRs with at least one Claude Code–assisted line
- **Lines with CC**: effective lines (>3 chars, non-trivial) written with Claude Code in merged PRs
- **Suggestion accept rate**: % of Edit/Write/NotebookEdit tool uses accepted
- **Attribution window**: sessions from 21 days before to 2 days after merge date
- Lines more than 20% rewritten by a developer are not attributed to Claude Code

### Cost Management

**Average costs**: ~$13/developer/active day; ~$150–250/developer/month for most enterprise users.

**Track costs in-session**: `/usage` — shows token breakdown, estimated cost, and plan limit usage. Press `d`/`w` to switch 24h/7d view.

**Team rate limit recommendations (TPM/RPM per user):**

| Team size | TPM/user | RPM/user |
|:----------|:---------|:---------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Key cost-reduction strategies:**
- `/clear` between unrelated tasks; `/compact` with a focus instruction
- Use Sonnet for most tasks; reserve Opus for complex work; `/model` to switch
- Move specialized CLAUDE.md instructions into skills (loaded on-demand)
- Disable unused MCP servers (`/mcp`); CLI tools are more context-efficient than MCP
- Lower extended thinking with `/effort` or `MAX_THINKING_TOKENS=8000`
- Delegate verbose operations (log parsing, test runs) to subagents
- Agent teams use ~7x more tokens; keep teams small and tasks focused

**Workspace spend controls:**
- API: workspace spend limits at platform.claude.com
- Pro/Max: monthly spend limit via `/usage-credits`
- Bedrock/Vertex/Foundry: use LiteLLM for per-key spend tracking

### OpenTelemetry (OTel) Monitoring

**Minimum configuration:**
```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp        # or: prometheus, console, none
OTEL_LOGS_EXPORTER=otlp           # or: console, none
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key configuration variables:**

| Variable | Description |
|:---------|:------------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable (set to `1`) |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/protobuf`, `http/json` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector URL for all signals |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers, e.g. `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Default 60000ms |
| `OTEL_LOGS_EXPORT_INTERVAL` | Default 5000ms |
| `OTEL_LOG_USER_PROMPTS` | Set `1` to log prompt content (off by default) |
| `OTEL_LOG_TOOL_DETAILS` | Set `1` to log tool args/commands (off by default) |
| `OTEL_LOG_TOOL_CONTENT` | Set `1` to log tool input/output in spans (requires tracing) |
| `OTEL_LOG_RAW_API_BODIES` | `1` (inline, 60 KB cap) or `file:<dir>` (untruncated) |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom attributes, e.g. `department=eng,team.id=platform` |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Default `true` |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Default `true` |
| `OTEL_METRICS_INCLUDE_VERSION` | Default `false` |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | Default `false` |

**Available metrics:**

| Metric | Description | Unit |
|:-------|:------------|:-----|
| `claude_code.session.count` | Sessions started | count |
| `claude_code.lines_of_code.count` | Lines added/removed | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used (by type/model) | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject | count |
| `claude_code.active_time.total` | Active time | s |

**Key events (via `OTEL_LOGS_EXPORTER`):**

| Event name | When |
|:-----------|:-----|
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.api_request` | API request made |
| `claude_code.api_error` | API request fails |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission decision (accept/reject) |
| `claude_code.permission_mode_changed` | Permission mode changes |
| `claude_code.auth` | Login or logout |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects |
| `claude_code.compaction` | Conversation compaction completes |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` | Hook begins executing |
| `claude_code.hook_execution_complete` | Hook finishes |
| `claude_code.plugin_installed` | Plugin installed |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.api_retries_exhausted` | API request fails after all retries |
| `claude_code.internal_error` | Unexpected internal error |

**Distributed tracing (beta):** set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER=otlp`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` + `claude_code.tool.execution`.

**Dynamic headers** (for token refresh): set `otelHeadersHelper` in `.claude/settings.json` to a script path. Script must output JSON with string key-value pairs. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**SIEM export** (audit trail): set `OTEL_LOGS_EXPORTER=otlp` + `OTEL_LOG_TOOL_DETAILS=1`, then point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver or a Collector.

### Debugging Configuration

Run these commands to diagnose configuration problems:

| Command | What it shows |
|:--------|:--------------|
| `/context` | Everything in the context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | CLAUDE.md and rules files loaded; auto-memory entries |
| `/skills` | Available skills from project, user, and plugin sources |
| `/hooks` | Active hook configurations for the session |
| `/mcp` | Connected MCP servers and their status |
| `/permissions` | Resolved allow/deny rules in effect |
| `/doctor` | Config diagnostics: invalid keys, schema errors, installation health |
| `/status` | Active settings sources, including managed settings |
| `/debug [issue]` | Enable debug logging; prompt Claude to diagnose using log output |

**Test against a clean config:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**Common configuration mistakes:**

| Symptom | Cause | Fix |
|:--------|:------|:----|
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: e.g. `"Edit\|Write"` |
| Hook never fires | Tool name is lowercase | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks in a standalone file | Put hooks under `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Config in `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Settings value ignored | Overridden by `settings.local.json` | Check local > project > user precedence |
| Skill missing from `/skills` | Skill at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP servers in `.mcp.json` not loading | File under `.claude/` | Place `.mcp.json` at repository root |
| MCP server fails from some dirs | Relative path in `command` | Use absolute paths for local scripts |

### Error Reference (Quick Lookup)

| Error message | Category | Key fix |
|:--------------|:---------|:--------|
| `API Error: 500 Internal server error` | Server | Check status.claude.com; retry |
| `Repeated 529 Overloaded errors` | Server | Retry; try `/model` to switch models |
| `Request timed out` | Server | Break work into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session/weekly limit` | Usage limits | Wait for reset; `/usage-credits` to buy more |
| `Request rejected (429)` | Rate limit | Check active credential with `/status`; reduce concurrency |
| `Credit balance is too low` | Usage limits | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for typos or stale key via `env \| grep ANTHROPIC` |
| `OAuth token revoked/expired` | Auth | Run `/login` (or `/logout` then `/login`) |
| `Unable to connect to API` | Network | Check proxy; set `HTTPS_PROXY`; verify firewall allows api.anthropic.com |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | `/compact`, `/clear`, `/context` to diagnose; disable unused MCP servers |
| `Request too large` | Request | Reference large files by path instead of pasting |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| `There's an issue with the selected model` | Request | Run `/model` to pick an available model |

**Retry behavior**: Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

### Troubleshooting Performance

| Issue | Fix |
|:------|:----|
| High CPU/memory | `/compact` regularly; close and restart between major tasks; add build dirs to `.gitignore` |
| Memory leak investigation | `/heapdump` — writes heap snapshot to `~/Desktop` |
| Auto-compact thrashing | Ask Claude to read oversized files in chunks; use `/compact` with focus; move to subagent |
| Command hangs | Ctrl+C; close terminal; `claude --resume` to recover |
| Search not finding files | Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Move project to Linux filesystem (`/home/`); use more specific search queries |

### Installation Troubleshooting

| Error | Fix |
|:------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML — check network/region |
| Install `Killed` on Linux | Add swap space (`sudo fallocate -l 2G /swapfile`); needs 4 GB RAM |
| `TLS connect error` / SSL failure | Update CA certs; set `NODE_EXTRA_CA_CERTS`; use `--cacert` |
| `Illegal instruction` | Architecture mismatch or missing AVX; check `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; update macOS |
| `Exec format error` on WSL | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `Error loading shared library` | musl/glibc binary mismatch; check `ldd --version` |
| `OAuth error: Invalid code` | Code expired; press Enter to retry quickly; use `c` to copy URL |
| `403 Forbidden` after login | Verify subscription active; check Console role assignment |
| Bedrock/Vertex credentials not loading | Run `aws sts get-caller-identity` / `gcloud auth application-default login` / `az login` |

### What's New (Recent Weeks)

| Week | Key features |
|:-----|:-------------|
| Week 20 (May 11–15) | `claude agents` dashboard; `/goal` continuous-work command; fast mode on Opus 4.7 |
| Week 19 (May 4–8) | Plugins load from `.zip`/URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level |
| Week 18 (Apr 27–May 1) | Windows without Git Bash (PowerShell shell); `claude ultrareview` CLI; `claude project purge` |
| Week 17 (Apr 20–24) | `/ultrareview` public research preview; session recap; custom themes; web UI redesign |
| Week 16 (Apr 13–17) | Claude Opus 4.7; `xhigh` effort level; Routines (cloud scheduled agents); mobile push notifications |
| Week 15 (Apr 6–10) | Ultraplan early preview; Monitor tool for streaming background events; `/loop` self-pacing |
| Week 14 (Mar 30–Apr 3) | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override |
| Week 13 (Mar 23–27) | Auto mode (research preview); computer use in Desktop; PR auto-fix on Web; transcript search (`/`) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards, contribution metrics, GitHub integration, PR attribution, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking, spend limits, rate limit recommendations, agent team costs, cost-reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Full OTel configuration, all metrics and events, span hierarchy, security/privacy, SIEM integration
- [Debug your configuration](references/claude-code-debug-your-config.md) — How to use `/context`, `/doctor`, `/hooks`, `/mcp` to diagnose what loaded; clean-config testing
- [Troubleshooting](references/claude-code-troubleshooting.md) — Performance, memory, auto-compact thrashing, search issues, WSL file system
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, network, TLS, binary, platform, and authentication installation errors
- [Error reference](references/claude-code-errors.md) — All runtime error messages with causes and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version history and release notes
- [What's New index](references/claude-code-whats-new-index.md) — Weekly digest index (Weeks 13–20, 2026)
- [What's New: Week 13](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use, PR auto-fix, transcript search, PowerShell tool, conditional hooks
- [What's New: Week 14](references/claude-code-whats-new-2026-w14.md) — Computer use CLI, powerup lessons, per-tool MCP size override
- [What's New: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, loop self-pacing
- [What's New: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile push notifications, native binaries
- [What's New: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [What's New: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview CLI, project purge
- [What's New: Week 19](references/claude-code-whats-new-2026-w19.md) — Plugins from .zip/URLs, worktree.baseRef, auto mode hard deny, hooks effort level
- [What's New: Week 20](references/claude-code-whats-new-2026-w20.md) — Agent view dashboard, /goal command, fast mode on Opus 4.7

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New index: https://code.claude.com/docs/en/whats-new/index.md
- What's New Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's New Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's New Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
