---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics and usage tracking, cost management, OpenTelemetry monitoring, configuration debugging, troubleshooting, error reference, changelog, and weekly what's-new digests.

## Quick Reference

### Analytics Dashboards by Plan

| Plan | URL | Includes |
|:-----|:----|:---------|
| Claude for Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Claude Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, per-user team insights |

Contribution metrics (GitHub) require: Owner role, GitHub app at [github.com/apps/claude](https://github.com/apps/claude), and "GitHub analytics" enabled at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code). Not available with Zero Data Retention enabled.

**Key contribution metrics**: PRs with CC, lines of code with CC, CC %, suggestion accept rate, lines accepted. Attribution window: sessions within 21 days before to 2 days after PR merge. PRs labeled `claude-code-assisted` in GitHub when matched.

### Cost Tracking Commands

| Command | What it shows |
|:--------|:-------------|
| `/usage` | Token usage, estimated cost, plan limits, per-source breakdown (skills/plugins/MCP) |
| `/usage-credits` | Buy additional usage (Pro/Max) or manage org limits (Team/Enterprise) |
| `/context` | What is consuming the context window |
| `/model` | Switch model mid-session |
| `/effort` | Adjust reasoning level |

### Cost Benchmarks

Average cost: ~$13/developer/active day, $150–250/month. 90th percentile: under $30/active day.

### Rate Limit Recommendations (API)

| Team size | TPM per user | RPM per user |
|:----------|:------------|:------------|
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

### Cost Reduction Strategies

| Strategy | How |
|:---------|:----|
| Clear between tasks | `/clear` when switching topics; `/compact Focus on X` for selective compaction |
| Choose the right model | Sonnet for most tasks; Opus for complex reasoning; Haiku for subagents |
| Reduce MCP overhead | Disable unused servers; prefer CLI tools (`gh`, `aws`) over MCP |
| Install code intelligence plugins | Symbol navigation vs. broad text search |
| Move instructions to skills | CLAUDE.md loads always; skills load on demand. Keep CLAUDE.md under 200 lines |
| Adjust extended thinking | Lower effort via `/effort` or `MAX_THINKING_TOKENS=8000` for simple tasks |
| Delegate to subagents | Keep verbose output in subagent context; only summary returns |
| Write specific prompts | Avoid vague "improve this codebase" — say exactly which file/function |
| Use plan mode | Shift+Tab before implementation to explore before committing |

### OpenTelemetry Quick Start

Enable telemetry with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. Configure exporters:

| Signal | Variable | Options |
|:-------|:---------|:--------|
| Metrics | `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` |
| Logs/Events | `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` |
| Traces (beta) | `OTEL_TRACES_EXPORTER` | `otlp`, `console`, `none` (also requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`) |

Common endpoint variables: `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_PROTOCOL` (`grpc`, `http/protobuf`, `http/json`), `OTEL_EXPORTER_OTLP_HEADERS`.

Default export intervals: 60s for metrics, 5s for logs.

### Available Metrics

| Metric | Description | Unit |
|:-------|:------------|:-----|
| `claude_code.session.count` | Sessions started | count |
| `claude_code.token.usage` | Tokens used (type: input/output/cacheRead/cacheCreation) | tokens |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.lines_of_code.count` | Lines added/removed | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.pull_request.count` | Pull requests created | count |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject decisions | count |
| `claude_code.active_time.total` | Active session time | seconds |

Cost/token metrics have additional attributes: `model`, `query_source`, `speed`, `effort`, `agent.name`, `skill.name`, `plugin.name`, `mcp_server.name`, `mcp_tool.name`.

### Available Events (OTEL Logs)

| Event name | When emitted |
|:-----------|:------------|
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.api_request` | Each API call to Claude |
| `claude_code.api_error` | API request fails |
| `claude_code.api_request_body` / `api_response_body` | Raw bodies when `OTEL_LOG_RAW_API_BODIES` set |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission accept/reject |
| `claude_code.permission_mode_changed` | Permission mode changes |
| `claude_code.auth` | Login/logout completes |
| `claude_code.mcp_server_connection` | MCP server connects/fails/disconnects |
| `claude_code.plugin_installed` | Plugin finishes installing |
| `claude_code.plugin_loaded` | Plugin active at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.hook_registered` | Hook active at session start |
| `claude_code.hook_execution_start` / `hook_execution_complete` | Hook execution begins/ends |
| `claude_code.compaction` | Context compaction completes |
| `claude_code.internal_error` | Unexpected internal error |
| `claude_code.api_retries_exhausted` | API request exhausts all retries |
| `claude_code.feedback_survey` | Session quality survey shown/answered |

All events carry standard attributes: `session.id`, `user.email`, `user.account_uuid`, `user.account_id`, `organization.id`, `user.id`, `app.version`, `app.entrypoint`, `terminal.type`. Events also include `prompt.id` for correlating all activity from a single user prompt.

### Privacy Flags for OTEL

| Flag | Default | What it unlocks |
|:-----|:--------|:----------------|
| `OTEL_LOG_USER_PROMPTS=1` | off | Prompt text in `user_prompt` events and spans |
| `OTEL_LOG_TOOL_DETAILS=1` | off | Bash commands, MCP server/tool names, file paths, skill names in events and spans |
| `OTEL_LOG_TOOL_CONTENT=1` | off | Tool input/output bodies in trace spans (60 KB cap) |
| `OTEL_LOG_RAW_API_BODIES=1` | off | Full Messages API request/response JSON (60 KB cap, inline) |
| `OTEL_LOG_RAW_API_BODIES=file:<dir>` | off | Full Messages API bodies written to files (no truncation) |

### OTel Cardinality Control

| Variable | Default | Effect |
|:---------|:--------|:-------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Session-level breakdown |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Per-user attribution |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | App version dimension |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | `false` | Launch method dimension |

### Configuration Debugging Commands

| Command | What it shows |
|:--------|:-------------|
| `/context` | Full context window breakdown (system prompt, skills, MCP tools, messages) |
| `/memory` | Loaded CLAUDE.md and rules files, auto-memory entries |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/skills` | Available skills from all sources |
| `/agents` | Configured subagents |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics — invalid keys, schema errors, install health |
| `/status` | Active settings sources; whether managed settings are in effect |
| `/debug [issue]` | Enables debug logging, prompts Claude to diagnose |

**Settings precedence** (highest wins): managed > local (`settings.local.json`) > project (`settings.json`) > user (`~/.claude/settings.json`). CLI flags and env vars can also override.

**Clean-config test**:
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```
Bypasses all `~/.claude` config. Managed settings still apply.

### Common Configuration Gotchas

| Symptom | Cause | Fix |
|:--------|:------|:----|
| Hook never fires | `matcher` is JSON array, not string | Use `"Edit\|Write"` not `["Edit","Write"]` |
| Hook never fires | Lowercase matcher e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hooks in wrong file | Defined in standalone file | Must be under `"hooks"` key in `settings.json` |
| Settings value ignored | Overridden by closer scope | Check `settings.local.json` > `settings.json` > `~/.claude/settings.json` |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Skill appears but Claude won't invoke | `disable-model-invocation: true` | Check badge in `/skills` |
| MCP server not loading | `mcpServers` in `settings.json` | Project MCP goes in `.mcp.json` at repo root |
| MCP server unapproved | Approval prompt was dismissed | Run `/mcp` to approve |
| MCP server relative path | Fails from some directories | Use absolute paths |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at startup | Loads when Claude reads a file there via Read tool |
| Settings applied from wrong file | Config in `~/.claude.json` not `~/.claude/settings.json` | These are different files; `hooks`/`env`/`permissions` go in `settings.json` |

### Error Quick Reference

| Error | Category | Fix |
|:------|:---------|:----|
| `API Error: 500` | Server | Check [status.claude.com](https://status.claude.com), retry |
| `Repeated 529 Overloaded` | Server | Wait, try `/model` to switch models |
| `Request timed out` | Server/Network | Retry; raise `API_TIMEOUT_MS` for slow proxies |
| `You've hit your session/weekly limit` | Usage | Wait for reset; `/usage-credits` for extra; upgrade plan |
| `Server is temporarily limiting requests` | Usage | Wait, retry |
| `Request rejected (429)` | Rate limit | Check rate limits; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Usage | Add credits at [platform.claude.com/settings/billing](https://platform.claude.com/settings/billing) |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check key in Console; unset `ANTHROPIC_API_KEY` for OAuth |
| `This organization has been disabled` | Auth | Unset stale `ANTHROPIC_API_KEY` from shell profile |
| `OAuth token revoked/expired` | Auth | `/login` |
| `Unable to connect to API` | Network | Check proxy (`HTTPS_PROXY`), firewall, `NODE_EXTRA_CA_CERTS` for TLS |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca.pem` |
| `Prompt is too long` | Request | `/compact`, `/clear`, disable unused MCP servers |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | `/model` to pick from available; use aliases like `sonnet` not versioned IDs |
| `Responses lower quality than usual` | Quality | Check `/model`, `/effort`, `/context` window usage |

Retries: Claude Code retries transient failures up to 10 times (`CLAUDE_CODE_MAX_RETRIES`). Errors shown mean retries were already exhausted.

### Installation Error Quick Reference

| Error | Fix |
|:------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH: `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc` |
| Install script returns HTML / `syntax error near '<'` | Use Homebrew (`brew install --cask claude-code`) or WinGet (`winget install Anthropic.ClaudeCode`) |
| `TLS connect error` / SSL failures | Update CA certs; set `NODE_EXTRA_CA_CERTS` for proxy CA; `HTTPS_PROXY` for corporate proxy |
| `Killed` on Linux (low memory) | Add 2GB swap: `sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| `Illegal instruction` | CPU lacks AVX; check VM hypervisor AVX passthrough |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <DistroName> 2` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; update macOS |
| `403 Forbidden` after login | Verify subscription active; check Console role is "Claude Code" or "Developer" |
| Bedrock: `Could not load credentials` | `aws sts get-caller-identity` to verify; authenticate AWS CLI |
| Vertex: `Could not load the default credentials` | Set `ANTHROPIC_VERTEX_PROJECT_ID` and `CLOUD_ML_REGION`; `gcloud auth application-default login` |

### Performance and Stability

| Issue | Fix |
|:------|:----|
| High CPU/memory | `/compact` regularly; close/restart between major tasks; add build dirs to `.gitignore` |
| Memory stays high | `/heapdump` to write snapshot to `~/Desktop` for inspection in Chrome DevTools |
| `Autocompact is thrashing` | Read large files in chunks; `/compact keep only X`; move large-file work to subagent; `/clear` |
| Command hangs | Ctrl+C; restart terminal; `claude --resume` to recover session |
| Search not finding files | Install system `ripgrep` + set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work from Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`) |

### What's New (Weeks 13–22, 2026)

| Week | Key features |
|:-----|:------------|
| W22 (May 25–29) | Claude Opus 4.8 (new default), dynamic workflows, security-guidance plugin, fast mode on Opus 4.8 |
| W21 (May 18–22) | Auto mode on Pro plan, `/usage` limit breakdown, `/code-review` command, background sessions in `/resume` |
| W20 (May 11–15) | `claude agents` view, `/goal` command, fast mode on Opus 4.7 by default, Rewind menu with "Summarize up to here" |
| W19 (May 4–8) | Plugins from `.zip`/URL, `worktree.baseRef`, auto mode hard deny rules, hooks see effort level |
| W18 (Apr 27 – May 1) | Windows without Git Bash (PowerShell tool), `claude ultrareview`, `claude project purge` |
| W17 (Apr 20–24) | `/ultrareview` public preview, session recap, custom themes, Claude Code on the web redesign |
| W16 (Apr 13–17) | Claude Opus 4.7 default, `xhigh` effort level, Routines on the web, mobile push notifications, native binaries |
| W15 (Apr 6–10) | Ultraplan early preview, Monitor tool, `/loop`, `/team-onboarding`, `/autofix-pr` |
| W14 (Mar 30 – Apr 3) | Computer use CLI research preview, `/powerup`, plugin executables on Bash PATH |
| W13 (Mar 23–27) | Auto mode research preview, PowerShell tool for Windows, conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Dashboard access, contribution metrics setup, PR attribution, leaderboard, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking with `/usage`, team spend limits, rate limit recommendations, cost reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, all metrics and events, span hierarchy, audit/SIEM integration, backend recommendations
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnostic commands, settings resolution, MCP/hooks/skills troubleshooting, clean-config testing
- [Troubleshooting](references/claude-code-troubleshooting.md) — Performance, stability, search issues, auto-compaction thrashing, WSL filesystem
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, TLS/SSL, low-memory Linux, WSL, OAuth errors, cloud provider credentials
- [Error reference](references/claude-code-errors.md) — All runtime error messages, causes, and recovery steps
- [Changelog](references/claude-code-changelog.md) — Full version history with all bug fixes and improvements
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digests index (weeks 13–22, 2026)
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — Auto mode research preview, PowerShell tool, conditional hooks
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — Computer use CLI, `/powerup`, plugin executables on PATH
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/team-onboarding`
- [Week 16 digest](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, `xhigh` effort, Routines, mobile notifications, native binaries
- [Week 17 digest](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes
- [Week 18 digest](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`
- [Week 19 digest](references/claude-code-whats-new-2026-w19.md) — Plugins from `.zip`/URL, `worktree.baseRef`, auto mode hard deny, hooks effort level
- [Week 20 digest](references/claude-code-whats-new-2026-w20.md) — `claude agents` view, `/goal`, fast mode on Opus 4.7
- [Week 21 digest](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro, `/usage` breakdown, `/code-review`
- [Week 22 digest](references/claude-code-whats-new-2026-w22.md) — Opus 4.8, dynamic workflows, security-guidance plugin, fast mode pricing

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
- Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- Week 21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- Week 22: https://code.claude.com/docs/en/whats-new/2026-w22.md
