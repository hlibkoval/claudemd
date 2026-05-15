---
name: operations-doc
description: Complete official documentation for operating Claude Code in teams and organizations — analytics dashboards, cost tracking, spend limits, rate limits, OpenTelemetry monitoring, configuration debugging, error reference, installation troubleshooting, performance issues, and the changelog / weekly what's new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code in teams and organizations.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | What's included |
| :--- | :--- | :--- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, per-user team insights |

Contribution metrics (PRs and lines of code with Claude Code assistance) require installing the GitHub app at [github.com/apps/claude](https://github.com/apps/claude) and enabling the toggle in [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code). Not available with Zero Data Retention. PRs tagged as `claude-code-assisted` in GitHub.

**Attribution window:** 21 days before to 2 days after PR merge. Code rewritten more than 20% is not attributed.

### Cost Tracking and Limits

| Scope | How |
| :--- | :--- |
| Current session | `/usage` — shows token counts and estimated cost |
| API workspace | Set workspace spend limits at [platform.claude.com](https://platform.claude.com/docs/en/build-with-claude/workspaces#workspace-limits) |
| Bedrock/Vertex/Foundry | Use LiteLLM for spend tracking by key |

**Average enterprise cost:** ~$13/developer/active day, $150–250/month. 90% of users stay below $30/active day.

**Team rate limit recommendations (TPM/RPM per user):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

### Cost Reduction Strategies

| Strategy | How |
| :--- | :--- |
| Clear between unrelated tasks | `/clear` then `/resume` |
| Custom compaction focus | `/compact Focus on code samples and API usage` |
| Switch models | `/model` — Sonnet for most tasks, Opus for complex reasoning |
| Check context usage | `/context` or configure status line |
| Limit MCP overhead | `/mcp disable <name>` for unused servers; prefer CLI tools |
| Move CLAUDE.md instructions to skills | Skills load on demand; keep CLAUDE.md under 200 lines |
| Reduce extended thinking | `/effort` or `MAX_THINKING_TOKENS=8000` |
| Delegate verbose operations | Use subagents to isolate high-volume work |

**Agent team cost note:** Agent teams use ~7x more tokens than standard sessions (each teammate has its own context window). Use Sonnet for teammates, keep teams small.

### OpenTelemetry Quick Setup

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp       # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp          # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

**Key OTel environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval ms | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval ms | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool parameters/commands | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output bodies in spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid in metrics | true |

**Traces (beta):** Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`.

**Exported metrics:**

| Metric | Description |
| :--- | :--- |
| `claude_code.session.count` | CLI sessions started |
| `claude_code.token.usage` | Tokens used (type: input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage` | Session cost in USD |
| `claude_code.lines_of_code.count` | Lines of code modified (type: added/removed) |
| `claude_code.commit.count` | Git commits created |
| `claude_code.pull_request.count` | Pull requests created |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept/reject counts |
| `claude_code.active_time.total` | Active time in seconds (type: user/cli) |

**Key log events:** `user_prompt`, `tool_result`, `api_request`, `api_error`, `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `compaction`, `plugin_installed`, `plugin_loaded`, `skill_activated`, `hook_registered`, `hook_execution_start`, `hook_execution_complete`

**SIEM export (managed settings):**

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

### Configuration Debugging Commands

| Command | What it shows |
| :--- | :--- |
| `/context` | Everything loaded into the context window |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills |
| `/hooks` | Active hook configurations |
| `/mcp` | MCP servers and their connection status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Validates config files; press `f` to send diagnostics to Claude |
| `/status` | Active settings sources, including managed settings |
| `/debug [issue]` | Enables debug logging; prompts Claude to diagnose |

**Clean-slate test session:**

```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**Common configuration gotchas:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is an array instead of a string | Use `"Edit\|Write"` (pipe-separated string) |
| Hook never fires | Lowercase tool name (e.g. `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hooks/permissions ignored | Added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Settings.json value ignored | Same key in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill missing from `/skills` | Skill at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loads when Claude reads a file there with the Read tool |
| MCP in `.mcp.json` not loading | File is inside `.claude/` | Root-level `.mcp.json`, not `.claude/.mcp.json` |
| MCP env vars missing | Set in `settings.json` `env` | Set per-server `env` inside `.mcp.json` |

### Error Reference Quick Lookup

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com; type `try again` |
| `API Error: Repeated 529 Overloaded errors` | Server | Switch model with `/model`; try again in minutes |
| `Request timed out` | Server/Network | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session limit` | Usage limit | Wait for reset; run `/extra-usage`; upgrade plan |
| `Request rejected (429)` | Rate limit | Check active credential with `/status`; reduce concurrency |
| `Credit balance is too low` | Usage limit | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for stale key with `env \| grep ANTHROPIC` |
| `OAuth token revoked` | Auth | Run `/login` (or `/logout` then `/login`) |
| `Unable to connect to API` | Network | Check proxy; verify firewall allows api.anthropic.com |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | Run `/compact` or `/clear`; disable unused MCP servers |
| `Request too large (max 30 MB)` | Request | Press Esc twice; reference large files by path |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| `There's an issue with the selected model` | Request | Run `/model` to select a valid model |

**Retry behavior:** Claude Code retries up to 10 times with exponential backoff before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

### Installation Troubleshooting Quick Reference

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH: `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc` |
| Install script returns HTML | Use Homebrew (`brew install --cask claude-code`) or WinGet (`winget install Anthropic.ClaudeCode`) |
| `Killed` on Linux install | Add 2GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| TLS/SSL errors | Set `NODE_EXTRA_CA_CERTS=/path/to/corp-ca.pem`; update CA certs |
| `Error loading shared library` | Wrong musl/glibc binary; check with `ldd --version` |
| `Illegal instruction` | CPU lacks AVX or architecture mismatch; check `uname -m` |
| `dyld: cannot load` on macOS | macOS 13.0+ required; update macOS |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <distro> 2` |
| Install hangs in Docker | Set `WORKDIR /tmp` before installer; increase memory to 4GB |
| `403 Forbidden` after login | Verify subscription active; confirm "Claude Code" or "Developer" role in Console |
| `Could not load credentials` (Bedrock) | Run `aws sts get-caller-identity`; check AWS credentials |
| `Could not load credentials` (Vertex) | Run `gcloud auth application-default login` |

**Install locations:**
- macOS/Linux: `~/.local/bin/claude`
- Windows: `%USERPROFILE%\.local\bin\claude.exe`

### Performance and Stability Issues

| Problem | Fix |
| :--- | :--- |
| High CPU/memory | Use `/compact` regularly; restart between major tasks; add build dirs to `.gitignore` |
| Memory still high | Run `/heapdump` to write snapshot to `~/Desktop` |
| Auto-compact thrashing | Read oversized files in smaller chunks; run `/compact keep only the plan and the diff`; use subagent |
| Command hangs | Press Ctrl+C; restart and run `claude --resume` |
| Search not finding files | Install ripgrep for your platform; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Move project to Linux filesystem (`/home/`); use native Windows |

### What's New (Recent Highlights)

| Week | Notable features |
| :--- | :--- |
| W19 (May 4–8, 2026) | Plugins from `.zip` archives and URLs (`--plugin-url`); `worktree.baseRef` setting; auto mode hard deny rules; hooks see effort level via `$CLAUDE_EFFORT` |
| W18 (Apr 27–May 1) | Windows without Git Bash (PowerShell as shell tool); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume` |
| W17 (Apr 20–24) | `/ultrareview` cloud bug-hunting agents; session recap; custom themes; Claude Code on the web redesign |
| W16 (Apr 13–17) | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort level; Routines; mobile push notifications; native binaries |
| W15 (Apr 6–10) | Ultraplan cloud planning; Monitor tool streams background events; `/loop` self-pacing; `/team-onboarding` |
| W14 (Mar 30–Apr 3) | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override up to 500K |
| W13 (Mar 23–27) | Auto mode (research preview); computer use in Desktop; transcript search with `/`; PowerShell tool for Windows; conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — usage dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, spend limits, rate limit recommendations, agent team costs, context management, model selection, token reduction strategies
- [Monitoring (OpenTelemetry)](references/claude-code-monitoring-usage.md) — OTel setup, all configuration variables, metrics, events, traces (beta), span hierarchy, SIEM integration, security and privacy
- [Debug your configuration](references/claude-code-debug-your-config.md) — `/context`, `/doctor`, `/hooks`, `/mcp`, settings precedence, clean-slate testing, common gotchas table
- [Error reference](references/claude-code-errors.md) — all runtime errors with recovery steps: server errors, usage limits, authentication, network, request errors, response quality
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH issues, install failures, TLS errors, Windows-specific issues, Linux musl/glibc, WSL, login/OAuth errors, cloud provider credentials
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, memory, auto-compaction thrashing, hangs, search/ripgrep issues, WSL file system
- [Changelog](references/claude-code-changelog.md) — full release notes by version
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index (W13–W19, 2026)
- [What's new W13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, PowerShell tool, conditional hooks
- [What's new W14](references/claude-code-whats-new-2026-w14.md) — computer use CLI, `/powerup`, MCP result-size override
- [What's new W15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/team-onboarding`
- [What's new W16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, `xhigh` effort, Routines, mobile notifications, native binaries
- [What's new W17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes, web redesign
- [What's new W18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`
- [What's new W19](references/claude-code-whats-new-2026-w19.md) — plugins from zip/URL, cross-project history search, `worktree.baseRef`, hard deny rules

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring (OpenTelemetry): https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
