---
name: operations
description: Reference documentation for Claude Code operations — analytics dashboards, cost management and token optimization, OpenTelemetry monitoring and usage metrics, troubleshooting common issues, and the changelog. Use when tracking costs, setting spend limits, configuring telemetry, debugging installation or performance problems, or reviewing release history.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operational concerns: analytics, cost management, monitoring/telemetry, troubleshooting, and the changelog.

## Quick Reference

### Cost Summary

Average cost: ~$6/dev/day (~$100-200/dev/month with Sonnet). 90% of users stay under $12/day.

| Command    | Purpose                                           |
|:-----------|:--------------------------------------------------|
| `/cost`    | Show current session token usage and cost (API users) |
| `/stats`   | View usage patterns (subscribers)                 |
| `/compact` | Summarize context to reduce token usage           |
| `/clear`   | Reset context between unrelated tasks             |
| `/model`   | Switch models mid-session (Sonnet is cheaper)     |

### Rate Limit Recommendations (per user)

| Team size     | TPM per user | RPM per user |
|:--------------|:-------------|:-------------|
| 1-5 users     | 200k-300k    | 5-7          |
| 5-20 users    | 100k-150k    | 2.5-3.5      |
| 20-50 users   | 50k-75k      | 1.25-1.75    |
| 50-100 users  | 25k-35k      | 0.62-0.87    |
| 100-500 users | 15k-20k      | 0.37-0.47    |
| 500+ users    | 10k-15k      | 0.25-0.35    |

### Cost Reduction Strategies

- **Clear between tasks** (`/clear`) to avoid stale context
- **Use Sonnet** for most tasks; reserve Opus for complex reasoning
- **Reduce MCP overhead** -- prefer CLI tools (`gh`, `aws`) over MCP servers; disable unused servers
- **Move specialized CLAUDE.md instructions into skills** -- skills load on-demand, CLAUDE.md is always loaded
- **Delegate verbose operations to subagents** -- test output, logs, docs stay in subagent context
- **Lower extended thinking budget** for simple tasks (`MAX_THINKING_TOKENS=8000`)
- **Write specific prompts** -- vague requests trigger broad scanning

### Analytics Dashboards

| Plan                          | URL                                                        | Features                                           |
|:------------------------------|:-----------------------------------------------------------|:---------------------------------------------------|
| Teams / Enterprise            | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console)                 | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage, spend tracking, team insights               |

Contribution metrics require GitHub app installation + Owner role to configure. Not available with Zero Data Retention.

### OpenTelemetry Monitoring

Enable with environment variables:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp, prometheus, console
export OTEL_LOGS_EXPORTER=otlp             # otlp, console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

#### Key Metrics

| Metric                                | Unit   | Description                         |
|:--------------------------------------|:-------|:------------------------------------|
| `claude_code.session.count`           | count  | CLI sessions started                |
| `claude_code.lines_of_code.count`     | count  | Lines modified (attr: `type`)       |
| `claude_code.cost.usage`              | USD    | Session cost (attr: `model`)        |
| `claude_code.token.usage`             | tokens | Tokens used (attr: `type`, `model`) |
| `claude_code.pull_request.count`      | count  | PRs created                         |
| `claude_code.commit.count`            | count  | Commits created                     |
| `claude_code.code_edit_tool.decision` | count  | Edit tool accept/reject decisions   |
| `claude_code.active_time.total`       | s      | Active usage time                   |

#### Key Events (via logs exporter)

| Event                        | Logged when                     |
|:-----------------------------|:--------------------------------|
| `claude_code.user_prompt`    | User submits a prompt           |
| `claude_code.tool_result`    | Tool completes execution        |
| `claude_code.api_request`    | API request to Claude           |
| `claude_code.api_error`      | API request fails               |
| `claude_code.tool_decision`  | Tool permission decision made   |

All events share a `prompt.id` attribute for correlation within a single user prompt.

#### Privacy Defaults

- User prompt content: **not logged** (enable with `OTEL_LOG_USER_PROMPTS=1`)
- MCP/tool names: **not logged** (enable with `OTEL_LOG_TOOL_DETAILS=1`)
- Raw file contents: **never included** in telemetry

### Troubleshooting Quick Fixes

| Problem                        | Solution                                                          |
|:-------------------------------|:------------------------------------------------------------------|
| Auth issues                    | `/logout`, restart, re-authenticate; or `rm -rf ~/.config/claude-code/auth.json` |
| Repeated permission prompts    | Use `/permissions` to allow specific tools                        |
| High CPU/memory                | `/compact`, restart between tasks, `.gitignore` build dirs        |
| Search/skills not working      | Install system `ripgrep`, set `USE_BUILTIN_RIPGREP=0`             |
| WSL sandbox errors             | `sudo apt-get install bubblewrap socat`                           |
| Command hangs                  | Ctrl+C; if unresponsive, close terminal and restart               |
| `/doctor` check                | Run `/doctor` to diagnose installation, settings, MCP, and plugin issues |

### Configuration File Locations

| File                          | Purpose                                      |
|:------------------------------|:---------------------------------------------|
| `~/.claude/settings.json`     | User settings (permissions, hooks, model)     |
| `.claude/settings.json`       | Project settings (committed)                  |
| `.claude/settings.local.json` | Local project settings (not committed)        |
| `~/.claude.json`              | Global state (theme, OAuth, MCP)              |
| `.mcp.json`                   | Project MCP servers (committed)               |

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) -- dashboards, contribution metrics, GitHub integration, PR attribution, leaderboard
- [Costs](references/claude-code-costs.md) -- cost tracking, team spend limits, rate limits, token reduction strategies
- [Monitoring](references/claude-code-monitoring-usage.md) -- OpenTelemetry setup, all metrics/events, cardinality control, backend guidance
- [Troubleshooting](references/claude-code-troubleshooting.md) -- installation issues (Windows/WSL/Linux/Mac), auth, performance, IDE integration
- [Changelog](references/claude-code-changelog.md) -- release history and version changes

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
