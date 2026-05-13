---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost tracking and reduction, OpenTelemetry monitoring, error reference, troubleshooting (installation, runtime, configuration), and the what's-new weekly digest and full changelog.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, telemetry, error handling, troubleshooting, and release notes.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key metrics |
| :--- | :------------ | :---------- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Lines accepted, accept rate, activity, spend, per-user breakdown |

Enable contribution metrics: install the GitHub app → enable analytics at `claude.ai/admin-settings/claude-code` → authenticate GitHub. Data appears within 24 hours.

PR attribution: sessions within 21 days before to 2 days after merge are matched. Code with >20% developer changes is not attributed.

### Cost Management

Average cost: ~$13/developer/active day; ~$150–250/month.

**Track costs:** run `/usage` for session token stats and estimated cost.

**Team spend limits:** set workspace spend limits at [platform.claude.com](https://platform.claude.com); use LiteLLM for Bedrock/Vertex/Foundry cost tracking.

**Rate limit recommendations (TPM / RPM per user):**

| Team size | TPM / user | RPM / user |
| :-------- | :--------- | :--------- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Key cost-reduction strategies:**

| Strategy | Mechanism |
| :-------- | :-------- |
| `/clear` between tasks | Drop stale context |
| `/compact Focus on X` | Targeted summarization |
| `/model` → Sonnet | Lower per-token cost |
| Disable unused MCP servers | MCP tool defs consume tokens |
| Move CLAUDE.md content to skills | Skills load on-demand only |
| `/effort` or `MAX_THINKING_TOKENS=8000` | Reduce extended thinking tokens |
| Delegate verbose ops to subagents | Keep verbose output out of main context |
| Hooks to preprocess data | Filter before Claude sees it |

Agent teams use ~7x more tokens than standard sessions. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to enable; use Sonnet for teammates.

Background token usage: ~$0.04/session for conversation summarization and command processing.

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

**Key configuration variables:**

| Variable | Default | Description |
| :------- | :------ | :---------- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | off | Required to enable telemetry |
| `OTEL_METRICS_EXPORTER` | — | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | — | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | — | `grpc`, `http/protobuf`, `http/json` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | Collector URL |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000ms | Metrics export interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000ms | Logs export interval |
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt content in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include Bash commands, MCP names, file paths |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool input/output in trace spans (requires tracing) |
| `OTEL_LOG_RAW_API_BODIES` | off | Emit full Messages API request/response JSON |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include `user.account_uuid` in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | false | Include `app.version` in metrics |

**Distributed traces (beta):** also set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`.

**Exported metrics:**

| Metric | Unit | Description |
| :----- | :--- | :---------- |
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines modified (`type`: added/removed) |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Session cost (`model`, `query_source`, `speed`, `effort`, `agent.name`, `skill.name`) |
| `claude_code.token.usage` | tokens | Tokens used (`type`: input/output/cacheRead/cacheCreation) |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept/reject decisions |
| `claude_code.active_time.total` | s | Active time (`type`: user/cli) |

**Key events (via `OTEL_LOGS_EXPORTER`):** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.skill_activated`, `claude_code.plugin_loaded`, `claude_code.plugin_installed`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`, `claude_code.internal_error`, `claude_code.feedback_survey`.

All metrics and events share standard attributes: `session.id`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`, `app.version`.

Service name: `claude-code`. Meter name: `com.anthropic.claude_code`.

**SIEM export (events only, full tool detail):**

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

### Error Reference

**Retry behavior:** transient failures are retried up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

**Error lookup table:**

| Error message | Category | Fix |
| :------------ | :------- | :-- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com; retry; `/feedback` |
| `API Error: Repeated 529 Overloaded` | Server | Check status.claude.com; retry in minutes; `/model` to switch |
| `Request timed out` | Server | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session/weekly limit` | Usage | Wait for reset; `/extra-usage`; upgrade plan |
| `Server is temporarily limiting requests` | Usage | Wait briefly; check status.claude.com |
| `Request rejected (429)` | Usage | Check `/status` for active credential; reduce concurrency |
| `Credit balance is too low` | Usage | Add credits at Console billing; enable auto-reload |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check key in Console; unset `ANTHROPIC_API_KEY`; run `/login` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; use `/login` |
| `OAuth token revoked/expired` | Auth | `/logout` then `/login` |
| `Unable to connect to API` | Network | Check internet; set `HTTPS_PROXY`; verify firewall allowlist |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS` to corporate CA bundle |
| `403` + `x-deny-reason: host_not_allowed` | Network | Add domain to cloud environment's Custom allowed list |
| `Prompt is too long` | Request | `/compact`; `/clear`; disable unused MCP servers; trim CLAUDE.md |
| `Request too large (max 30 MB)` | Request | Remove/shrink attached content (Esc ×2) |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | `/model` to pick available model; use alias not versioned ID |
| `thinking.type.enabled is not supported` | Request | Run `claude update` to v2.1.111+ |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` to restore conversation |
| Responses seem lower quality | Quality | Check `/model`, `/effort`, `/context`; `/compact` or `/clear`; `/rewind` |

Run `/feedback` to report errors to Anthropic. Check [status.claude.com](https://status.claude.com) for incidents.

### Troubleshooting (Runtime)

| Symptom | Page |
| :------ | :--- |
| `command not found`, PATH, `EACCES`, TLS install errors | [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) |
| Login loops, OAuth, 403, Bedrock/Vertex/Foundry credentials | [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) |
| Settings not applying, hooks not firing, MCP not loading | [Debug your configuration](references/claude-code-debug-your-config.md) |
| `5xx`, `529`, `429`, request validation errors | [Error reference](references/claude-code-errors.md) |
| VS Code extension not connecting | [VS Code integration](/en/vs-code) |
| High CPU/memory, hangs, search issues | [Troubleshooting](references/claude-code-troubleshooting.md) |

Run `/doctor` for an automated health check. Run `claude doctor` if the CLI won't start.

**High memory:** run `/heapdump` to write a heap snapshot to `~/Desktop`.

**Auto-compact thrashing** (`Autocompact is thrashing...`): read large files in chunks; `/compact keep only X`; move work to a subagent; `/clear`.

**Search not finding files:** install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`.

### Debug Your Configuration

| Command | Shows |
| :------ | :---- |
| `/context` | Everything loaded into context |
| `/memory` | CLAUDE.md and rules files loaded |
| `/skills` | Available skills |
| `/hooks` | Active hook configurations |
| `/mcp` | MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config validation, schema errors, install health |
| `/status` | Active settings sources |
| `/debug [issue]` | Enable debug logging for session |

**Clean-slate test:** `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude`

**Common config mistakes:**

| Symptom | Cause | Fix |
| :------ | :---- | :-- |
| Hook never fires | `matcher` is a JSON array | Use string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase matcher | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hook defined in standalone file | Hooks go under `"hooks"` key in `settings.json` |
| Settings ignored | Added to `~/.claude.json` | Use `~/.claude/settings.json` for `permissions`, `hooks`, `env` |
| Skill missing from `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP servers in `.mcp.json` never load | File is under `.claude/` | Project MCP config goes at repo root as `.mcp.json` |
| Project MCP server missing | One-time approval dismissed | Run `/mcp` to approve |

### Installation Quick Fixes

| Error | Fix |
| :---- | :-- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install script returns HTML | Regional restriction or network issue; use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `Killed` on Linux | Add 2 GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| `Error loading shared library` | Wrong binary (musl vs glibc); reinstall |
| `Illegal instruction` | Old CPU lacking AVX, or architecture mismatch |
| `dyld: cannot load` on macOS | macOS 13.0+ required |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <DistroName> 2` |
| `403 Forbidden` after login | Verify subscription at claude.ai/settings; check Console role |
| `Could not load credentials` (Bedrock) | `aws sts get-caller-identity`; ensure AWS credentials are valid |
| `Could not load credentials` (Vertex) | `gcloud auth application-default login`; set `ANTHROPIC_VERTEX_PROJECT_ID` |

### What's New (Weekly Digest)

Recent weeks (see [full index](references/claude-code-whats-new-index.md)):

| Week | Dates | Highlights |
| :--- | :---- | :--------- |
| W19 | May 4–8, 2026 | Plugins from `.zip`/URL; `Ctrl+R` global history search; `worktree.baseRef`; auto mode hard deny rules; hooks see `$CLAUDE_EFFORT` |
| W18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell tool); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume` |
| W17 | Apr 20–24, 2026 | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| W16 | Apr 13–17, 2026 | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort; Routines on web; mobile push notifications; native binaries |
| W15 | Apr 6–10, 2026 | Ultraplan early preview; Monitor tool; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| W14 | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override up to 500K |
| W13 | Mar 23–27, 2026 | Auto mode research preview; computer use in Desktop; PR auto-fix on web; transcript search with `/`; conditional `if` hooks |

For every bug fix and minor improvement, see the [full changelog](references/claude-code-changelog.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — usage/contribution metrics, GitHub integration, PR attribution, leaderboard, API customer dashboard
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, team spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, all metrics and events, span hierarchy, SIEM audit, backend selection
- [Debug your configuration](references/claude-code-debug-your-config.md) — `/context`, `/doctor`, `/status`, MCP/hook debugging, clean-session testing, common config mistakes
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, auto-compact thrashing, hangs, search/ripgrep issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, permissions, TLS, Windows/WSL/macOS install issues, OAuth login, cloud provider credentials
- [Error reference](references/claude-code-errors.md) — all runtime error messages, recovery steps, retry behavior
- [What's new (index)](references/claude-code-whats-new-index.md) — weekly digest index with links to each week's features
- [What's new: Week 19](references/claude-code-whats-new-2026-w19.md) — plugins from .zip/URL, global history search, worktree.baseRef, hard deny rules
- [What's new: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows PowerShell shell tool, ultrareview CLI, project purge
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview research preview, session recap, custom themes
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile notifications, native binaries
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /team-onboarding
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use CLI, /powerup, MCP result-size override
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, conditional if hooks, PowerShell tool
- [Full changelog](references/claude-code-changelog.md) — complete version history with every bug fix and improvement

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- What's new (index): https://code.claude.com/docs/en/whats-new/index.md
- What's new: Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new: Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Full changelog: https://code.claude.com/docs/en/changelog.md
