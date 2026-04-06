---
name: operations-doc
description: Complete documentation for Claude Code operations -- analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting, changelog, and weekly feature digests. Covers team/enterprise analytics (usage metrics, contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export), API console analytics (spend tracking, team insights), cost tracking (/cost command, /stats), team spend limits, rate limit recommendations by team size, token reduction strategies (context management, model selection, MCP overhead, hooks, skills, extended thinking, subagents, agent teams), OpenTelemetry configuration (OTLP, Prometheus, console exporters), metrics (session.count, lines_of_code.count, pull_request.count, commit.count, cost.usage, token.usage, code_edit_tool.decision, active_time.total), events (user_prompt, tool_result, api_request, api_error, tool_decision), traces (beta), dynamic headers, multi-team resource attributes, cardinality control, installation troubleshooting (PATH issues, TLS errors, WSL problems, Docker, Windows), authentication issues (OAuth, 403 Forbidden, API key conflicts), IDE integration (JetBrains on WSL2, Escape key), configuration file locations, performance and stability, markdown formatting, and the latest features from the weekly dev digest and full changelog. Load when discussing analytics, costs, monitoring, telemetry, OpenTelemetry, OTel, troubleshooting, installation issues, changelog, what's new, release notes, cost optimization, token usage, spend limits, rate limits, PR attribution, contribution metrics, or any operations-related topic for Claude Code.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations -- analytics, cost management, monitoring, troubleshooting, and release information.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

**Contribution metrics** require GitHub app install at `github.com/apps/claude` + Owner enables analytics at `claude.ai/admin-settings/claude-code`. Data appears within 24 hours. Not available with Zero Data Retention.

**Summary metrics**: PRs with CC, Lines of code with CC, PRs with CC (%), Suggestion accept rate, Lines of code accepted

**PR attribution**: merged PRs matched against Claude Code sessions within 21-day window; labeled `claude-code-assisted` in GitHub. Code with >20% developer rewriting is not attributed.

### Cost Overview

| Metric | Value |
|:-------|:------|
| Average cost per developer/day | ~$6 (90% under $12/day) |
| Average monthly cost (API, Sonnet) | ~$100-200/developer |
| Background token usage | Under $0.04/session |

**Commands**: `/cost` (API token usage, session stats), `/stats` (subscription usage patterns)

### Rate Limit Recommendations (per user)

| Team Size | TPM per user | RPM per user |
|:----------|:------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

### Cost Reduction Strategies

| Strategy | How |
|:---------|:----|
| Manage context | `/clear` between tasks, `/compact` with focus instructions |
| Choose right model | Sonnet for most tasks, Opus for complex reasoning, Haiku for subagents |
| Reduce MCP overhead | Prefer CLI tools (`gh`, `aws`), disable unused servers via `/mcp` |
| Install code intelligence | Plugins give precise symbol navigation, reducing file reads |
| Use hooks/skills | Preprocess data in hooks, load domain knowledge via skills |
| Move instructions to skills | Keep CLAUDE.md under 200 lines, use skills for specialized workflows |
| Adjust extended thinking | Lower effort with `/effort`, disable in `/config`, or `MAX_THINKING_TOKENS=8000` |
| Use subagents | Delegate verbose operations; summary returns to main context |
| Write specific prompts | Avoid vague requests that trigger broad scanning |
| Agent teams | Use Sonnet for teammates, keep teams small, clean up when done |

### OpenTelemetry Monitoring

**Required**: `CLAUDE_CODE_ENABLE_TELEMETRY=1`

| Variable | Options |
|:---------|:--------|
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` |
| `OTEL_TRACES_EXPORTER` | `otlp`, `console`, `none` (requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | e.g. `http://localhost:4317` |

**Default intervals**: metrics 60s, logs 5s, traces 5s

### OTel Metrics

| Metric | Unit | Extra Attributes |
|:-------|:-----|:-----------------|
| `claude_code.session.count` | count | -- |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.pull_request.count` | count | -- |
| `claude_code.commit.count` | count | -- |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type` (user/cli) |

### OTel Events

| Event | Key Attributes |
|:------|:--------------|
| `claude_code.user_prompt` | `prompt_length`, `prompt` (opt-in via `OTEL_LOG_USER_PROMPTS=1`) |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `decision_type`, `tool_parameters` (opt-in) |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `attempt` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |

All events share `prompt.id` for per-prompt correlation.

### Privacy Defaults

| Data | Default | Opt-in Variable |
|:-----|:--------|:----------------|
| User prompt content | Redacted | `OTEL_LOG_USER_PROMPTS=1` |
| Tool parameters/input | Not logged | `OTEL_LOG_TOOL_DETAILS=1` |
| Tool content in spans | Not logged | `OTEL_LOG_TOOL_CONTENT=1` (traces only, 60KB cap) |

### Cardinality Control

| Variable | Default | Controls |
|:---------|:--------|:---------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | `app.version` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | `user.account_uuid` and `user.account_id` in metrics |

### Troubleshooting Quick Lookup

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near '<'` | Install script got HTML; retry or use `brew install --cask claude-code` |
| `curl: (56) Failure writing` | Download script first, then run; or use Homebrew/WinGet |
| `Killed` during install (Linux) | Add 2GB swap (`fallocate -l 2G /swapfile`) |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxy |
| `Illegal instruction` (Linux) | Architecture mismatch; check `uname -m` |
| `dyld: cannot load` (macOS) | Requires macOS 13.0+; try Homebrew |
| OAuth/403 errors | `/logout`, restart, re-authenticate; check subscription status |
| Disabled org with active subscription | Unset `ANTHROPIC_API_KEY` env var |
| JetBrains not detected (WSL2) | Configure Windows Firewall or switch to mirrored networking |
| Escape key in JetBrains | Settings > Tools > Terminal > uncheck "Move focus to the editor with Escape" |
| High CPU/memory | `/compact` regularly; restart between tasks |
| Search/discovery issues | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |

### Configuration File Locations

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP) |
| `.mcp.json` | Project MCP servers |

### Latest Features (Week 14, v2.1.86-v2.1.91)

- **Computer use in CLI**: Claude opens native apps, clicks through UI, verifies changes from terminal
- **/powerup**: interactive lessons teaching Claude Code features
- **Flicker-free rendering**: alt-screen renderer with `CLAUDE_CODE_NO_FLICKER=1`
- **MCP result-size override**: `anthropic/maxResultSizeChars` up to 500K per tool
- **Plugin executables on PATH**: `bin/` directory at plugin root auto-added to Bash PATH

### Recent Features (Week 13, v2.1.83-v2.1.85)

- **Auto mode**: classifier handles permissions (`defaultMode: "auto"`)
- **Computer use** in Desktop app
- **PR auto-fix** on Web (CI failures + review comments)
- **Transcript search**: `/` in transcript mode, `n`/`N` to navigate
- **PowerShell tool**: native Windows cmdlets (`CLAUDE_CODE_USE_POWERSHELL_TOOL=1`)
- **Conditional hooks**: `if` field using permission rule syntax

## Full Documentation

For the complete official documentation, see the reference files:

- [Track Team Usage with Analytics](references/claude-code-analytics.md) -- Analytics dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard, CSV export
- [Manage Costs Effectively](references/claude-code-costs.md) -- Cost tracking, team spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) -- OTel configuration, metrics, events, traces, dynamic headers, multi-team support, privacy and security
- [Troubleshooting](references/claude-code-troubleshooting.md) -- Installation issues, authentication, IDE integration, performance, configuration
- [Changelog](references/claude-code-changelog.md) -- Full release notes by version
- [What's New Index](references/claude-code-whats-new-index.md) -- Weekly dev digest overview
- [Week 13 Digest](references/claude-code-whats-new-2026-w13.md) -- Auto mode, computer use, PR auto-fix, transcript search, PowerShell tool, conditional hooks
- [Week 14 Digest](references/claude-code-whats-new-2026-w14.md) -- CLI computer use, /powerup, flicker-free rendering, MCP result-size override, plugin executables

## Sources

- Track Team Usage with Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs Effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New Index: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 Digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 Digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
