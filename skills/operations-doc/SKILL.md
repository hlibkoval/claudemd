---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost tracking and reduction, OpenTelemetry monitoring, error reference, troubleshooting (performance, stability, search), installation troubleshooting, configuration debugging, and release changelogs.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, error handling, troubleshooting, and release history.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API / Console | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage, spend tracking, per-user insights |

**Contribution metrics** (Teams/Enterprise): requires GitHub app install + "GitHub analytics" toggle. Data appears within 24 hours; updated daily. PRs tagged `claude-code-assisted` in GitHub.

**PR attribution window**: sessions from 21 days before to 2 days after merge date. Code with >20% developer rewrites is not attributed.

**Excluded from analysis**: lock files, generated code, build dirs (`dist/`, `build/`, `node_modules/`), test fixtures, lines >1,000 chars.

### Cost Management

**Average costs**: ~$13/developer/active day; $150–250/developer/month (90th percentile: under $30/active day).

**Track costs:**
- `/usage` — session token stats and estimated cost
- [platform.claude.com/usage](https://platform.claude.com/usage) — authoritative billing

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**
- `/clear` between unrelated tasks; `/compact Focus on X` to control summaries
- `/model` to switch to Sonnet for most tasks; reserve Opus for complex reasoning
- `/context` to see what consumes context; disable unused MCP servers
- Move detailed workflow instructions from `CLAUDE.md` into skills (load on-demand)
- Lower extended thinking: `/effort`, `/model`, or `MAX_THINKING_TOKENS=8000`
- Delegate verbose operations (test runs, log parsing) to subagents
- Use plan mode (Shift+Tab) before implementation to avoid costly re-work

**Agent teams**: ~7x token usage vs. standard sessions. Each teammate has its own context window.

**Background token usage**: ~$0.04/session for conversation summarization and command processing.

### OpenTelemetry Monitoring

**Quick setup:**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

**Key configuration variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool params/commands | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool I/O in spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version | false |

**Distributed traces (beta):** set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`. Spans propagate `TRACEPARENT` to subprocesses (W3C trace context).

**Span hierarchy:**
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

**Exported metrics:**

| Metric | Unit |
| :--- | :--- |
| `claude_code.session.count` | count |
| `claude_code.lines_of_code.count` | count (type: added/removed) |
| `claude_code.pull_request.count` | count |
| `claude_code.commit.count` | count |
| `claude_code.cost.usage` | USD |
| `claude_code.token.usage` | tokens (type: input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | count (tool_name, decision, source, language) |
| `claude_code.active_time.total` | seconds (type: user/cli) |

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

**Key events:** `user_prompt`, `tool_result`, `api_request`, `api_error`, `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `compaction`, `skill_activated`, `plugin_installed`

**Multi-team segmentation:**
```bash
export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"
```
No spaces in values; use underscores or percent-encoding.

**Dynamic headers (enterprise):** set `otelHeadersHelper` in `.claude/settings.json` to a script path. Default refresh: 29 minutes (`CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Administrator config:** deploy via `env` key in managed settings file (MDM-distributable); high precedence, cannot be user-overridden.

### Error Reference

**Automatic retries:** Claude Code retries server errors, 529 overloads, timeouts, and temporary 429s up to 10 times (configurable: `CLAUDE_CODE_MAX_RETRIES`, default 10; `API_TIMEOUT_MS`, default 600000).

**Common errors and fixes:**

| Error | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Check status.claude.com; retry; `/feedback` |
| `529 Overloaded` | Server | Wait; `/model` to switch models |
| `Request timed out` | Server/Network | Retry; raise `API_TIMEOUT_MS` |
| `You've hit your session/weekly limit` | Usage | Wait for reset; `/extra-usage`; upgrade plan |
| `Request rejected (429)` | Usage | Check `/status` for active credential; reduce concurrency |
| `Credit balance is too low` | Usage | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check for stale `ANTHROPIC_API_KEY` in env |
| `OAuth token revoked/expired` | Auth | `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy (`HTTPS_PROXY`); firewall; `curl -I https://api.anthropic.com` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca.pem` |
| `Prompt is too long` | Request | `/compact`; `/context`; disable unused MCP servers |
| `Request too large` | Request | Esc twice; reference files by path |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | `/model` to pick valid model; use alias (sonnet/opus) not versioned ID |
| `API Error: 400 due to tool use concurrency` | Request | `/rewind` to recover conversation |
| Low response quality | — | `/model` (check model), `/effort` (check reasoning level), `/context` (check fullness), `/compact` |

### Configuration Debugging

**Inspect what loaded:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in context window (system, memory, skills, tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics: invalid keys, schema errors |
| `/status` | Active settings sources (including managed settings) |

**Common config issues:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase tool name (e.g., `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks in standalone `.claude/hooks.json` | Hooks go under `"hooks"` key in `settings.json` |
| Settings value ignored | Same key in `settings.local.json` | local > project > user precedence |
| Skill not in `/skills` | `.claude/skills/name.md` (flat file) | Use folder: `.claude/skills/name/SKILL.md` |
| Skill appears but never invoked | `disable-model-invocation: true` in frontmatter | Remove flag or invoke manually |
| Subdirectory CLAUDE.md ignored | Loads on demand via Read tool, not at session start | Normal behavior; use Read tool in that dir |
| MCP `.mcp.json` not loading | File is under `.claude/` or wrong format | Project MCP config goes at repo root as `.mcp.json` |
| Project MCP server not appearing | One-time approval prompt dismissed | Run `/mcp` and approve |
| MCP server env vars missing | `settings.json` env doesn't propagate to MCP children | Set `env` per-server inside `.mcp.json` |

### Troubleshooting: Performance and Stability

| Issue | Fix |
| :--- | :--- |
| High CPU/memory | `/compact` regularly; restart between major tasks; add build dirs to `.gitignore` |
| Memory stays high | `/heapdump` → inspect snapshot in Chrome DevTools → report on GitHub |
| Auto-compact thrashing | Read file in chunks; `/compact keep only X`; move to subagent; `/clear` |
| Command hangs | Ctrl+C; restart terminal; `claude --resume` to pick session back up |
| Search not finding files | Install system `ripgrep` + set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work from Linux filesystem (`/home/`), not `/mnt/c/`; use more specific search queries |

### Installation Troubleshooting Quick Reference

**Install locations:** `~/.local/bin/claude` (macOS/Linux) · `%USERPROFILE%\.local\bin\claude.exe` (Windows)

**PATH fix (macOS/Linux):**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

**Diagnostic commands:**
```bash
curl -sI https://downloads.claude.ai/claude-code-releases/latest  # test connectivity
which -a claude        # find all claude binaries
claude --version       # verify binary works
claude doctor          # run diagnostics
```

**Common install issues:**

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install script returns HTML | App unavailable in region, or network issue; try `brew install --cask claude-code` (macOS) or `winget install Anthropic.ClaudeCode` (Windows) |
| `curl: (56) Failure` | Network interruption; retry or use Homebrew/WinGet |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS`; try `--cacert` with curl |
| Install `Killed` on Linux | OOM; add swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| Install hangs in Docker | Set `WORKDIR /tmp` before running installer |
| `Illegal instruction` | CPU lacks AVX; or architecture mismatch (`uname -m`) |
| `Exec format error` in WSL | WSL1 regression; convert to WSL2: `wsl --set-version <Distro> 2` |
| `dyld: cannot load` on macOS | macOS version too old; requires macOS 13.0+ |
| `Error loading shared library` | musl/glibc binary mismatch; check `ldd --version` |

**Authentication fixes:**
- Login loops: `/logout` → close → restart → `/login`
- OAuth in WSL2/SSH: browser opens on wrong host; paste the login code shown in terminal
- `403 Forbidden`: verify subscription at claude.ai/settings; confirm account has Claude Code role
- Org disabled: unset `ANTHROPIC_API_KEY` (it overrides subscription OAuth)
- Bedrock: `aws sts get-caller-identity` to verify credentials
- Vertex: set `ANTHROPIC_VERTEX_PROJECT_ID` + `CLOUD_ML_REGION` + `gcloud auth application-default login`

### What's New (Recent Releases)

| Week | Highlights |
| :--- | :--- |
| W17 (Apr 20–24, 2026) | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| W16 (Apr 13–17, 2026) | Claude Opus 4.7 default; `xhigh` effort level; Routines on web; `/usage` limit breakdown; native binaries |
| W15 (Apr 6–10, 2026) | Ultraplan early preview; Monitor tool for background event streaming; `/loop` self-pacing; `/autofix-pr` |
| W14 (Mar 30–Apr 3, 2026) | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override up to 500K |
| W13 (Mar 23–27, 2026) | Auto mode research preview; computer use in Desktop; PR auto-fix on Web; transcript search; PowerShell tool |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API, contribution metrics, PR attribution, GitHub integration, leaderboard, data export
- [Manage costs effectively](references/claude-code-costs.md) — cost tracking with `/usage`, team rate limits, agent team costs, context management, model selection, MCP overhead, extended thinking settings
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, all metrics and events, span tracing (beta), dynamic headers, multi-team segmentation, backend recommendations, security and privacy
- [Debug your configuration](references/claude-code-debug-your-config.md) — inspecting loaded context, checking settings scopes, MCP and hook debugging, common causes table
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, auto-compact thrashing, hangs, search issues, WSL performance
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH fixes, conflicting installs, TLS errors, Windows issues, low-memory installs, Docker hangs, OAuth errors, Bedrock/Vertex credentials
- [Error reference](references/claude-code-errors.md) — all runtime error messages with causes and recovery steps, automatic retry behavior
- [Changelog](references/claude-code-changelog.md) — full version history with all bug fixes and improvements
- [What's new index](references/claude-code-whats-new-index.md) — weekly feature digest index
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, PR auto-fix, transcript search
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use CLI, /powerup, MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /autofix-pr
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign

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
- What's new: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
