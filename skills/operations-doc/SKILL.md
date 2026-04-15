---
name: operations-doc
description: Complete official documentation for operating Claude Code in production — analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting installation/auth/performance issues, the version-by-version changelog, and the weekly What's New digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating Claude Code: analytics, cost management, OpenTelemetry monitoring, troubleshooting, the changelog, and the weekly What's New digests.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Includes |
| :--- | :------------ | :------- |
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage, contribution metrics (with GitHub app), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage, spend, team insights (no GitHub contribution metrics) |

Key metrics: **PRs with CC**, **Lines of code with CC**, **PRs with CC (%)**, **Suggestion accept rate**, **Lines of code accepted**, **DAU / sessions**, **PRs per user**.

PR attribution looks at sessions in a window of **21 days before to 2 days after** PR merge. Merged PRs containing Claude Code-assisted lines are tagged `claude-code-assisted` on GitHub. Auto-generated files (lock files, build artifacts, minified files, lines >1,000 chars) are excluded. Contribution metrics are not available with Zero Data Retention enabled.

### Cost management

| Tool | Purpose |
| :--- | :------ |
| `/cost` | Token usage & dollar cost for current session (API users) |
| `/stats` | Usage patterns for Pro/Max/Team subscribers |
| `/context` | See what's consuming context window |
| `/compact` | Summarize history (`/compact <focus>` for custom guidance) |
| `/clear` | Reset context between unrelated tasks |
| `/effort` | Lower extended-thinking effort to cut output tokens |

Average enterprise cost: **~$13/dev/active day**, **$150-250/dev/month**, with 90% of users under $30/active day.

Per-user TPM/RPM rate-limit guidance (organization-wide allocation):

| Team size | TPM/user | RPM/user |
| :-------- | :------- | :------- |
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

Cost-reduction levers: clear context proactively, prefer Sonnet (use Haiku for trivial subagents), prefer CLI tools over MCP servers, install code intelligence plugins, offload verbose output to hooks/skills/subagents, write specific prompts, use plan mode, keep `CLAUDE.md` under ~200 lines, lower extended thinking effort with `/effort` or `MAX_THINKING_TOKENS`. Agent teams use approximately 7x more tokens than standard sessions.

For Bedrock/Vertex/Foundry, Claude Code does NOT send cost metrics from your cloud — track spend via your provider or [LiteLLM](https://docs.litellm.ai/docs/proxy/virtual_keys#tracking-spend) gateway.

### OpenTelemetry monitoring

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. Choose exporters via `OTEL_METRICS_EXPORTER` (`otlp`, `prometheus`, `console`, `none`) and `OTEL_LOGS_EXPORTER` (`otlp`, `console`, `none`). Distributed traces (beta) require `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` plus `OTEL_TRACES_EXPORTER`.

Key environment variables:

| Variable | Purpose |
| :------- | :------ |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Master switch (`1` to enable) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc` / `http/json` / `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector URL |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers |
| `OTEL_METRIC_EXPORT_INTERVAL` | Default 60000ms |
| `OTEL_LOGS_EXPORT_INTERVAL` | Default 5000ms |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content (off by default) |
| `OTEL_LOG_TOOL_DETAILS` | Include tool args/parameters (off by default) |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in trace spans (off by default) |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom team/department tags (no spaces!) |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Cardinality control (default `true`) |
| `otelHeadersHelper` (in settings.json) | Script that emits dynamic auth headers |

Exported metrics:

| Metric | Unit | Notes |
| :----- | :--- | :---- |
| `claude_code.session.count` | count | New sessions started |
| `claude_code.lines_of_code.count` | count | `type`: added/removed |
| `claude_code.pull_request.count` | count | PRs created from CC |
| `claude_code.commit.count` | count | Git commits from CC |
| `claude_code.cost.usage` | USD | Tagged with `model` (estimates only) |
| `claude_code.token.usage` | tokens | `type`: input/output/cacheRead/cacheCreation |
| `claude_code.code_edit_tool.decision` | count | accept/reject by Edit/Write/NotebookEdit |
| `claude_code.active_time.total` | seconds | `type`: user/cli |

Exported events (via OTEL logs): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.plugin_installed`, `claude_code.skill_activated`. All share `prompt.id` to correlate everything triggered by one user prompt.

Standard attributes on every event/metric: `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`. Resource attributes: `service.name=claude-code`, `os.type`, `os.version`, `host.arch`.

Detect retry exhaustion: a `claude_code.api_error` event's `attempt` attribute exceeding `CLAUDE_CODE_MAX_RETRIES` (default 10) means retries were exhausted on a transient error.

### Troubleshooting cheat sheet

| Symptom | Fix |
| :------ | :-- |
| `command not found: claude` | Add `~/.local/bin` (or `%USERPROFILE%\.local\bin`) to `PATH` |
| `syntax error near unexpected token '<'` | Install script returned HTML — check network/proxy |
| `curl: (56) Failure writing output` | Download install script first, then run it |
| `Killed` during install on Linux | Add swap space (low-memory server) |
| `TLS connect error` / `unable to get local issuer certificate` | Update CA certs; configure corporate CA |
| `irm is not recognized` on Windows | Use the right install command for your shell |
| `Claude Code on Windows requires git-bash` | Install/configure Git Bash |
| `Error loading shared library` on Linux | Wrong musl/glibc binary variant |
| `Illegal instruction` on Linux | CPU architecture mismatch |
| `dyld: cannot load` on macOS | Binary incompatibility |
| `App unavailable in region` | Country not supported |
| `OAuth error` / `403 Forbidden` | Re-authenticate; check token |

Other troubleshooting categories: permissions/auth, configuration file locations and resets, performance and stability, IDE integration, markdown formatting issues. See the reference for full procedures.

### Changelog & What's New

- **Changelog** (`/en/changelog`): per-version bullet list of changes, generated from the public GitHub `CHANGELOG.md`. Run `claude --version` to check installed version.
- **What's New** (`/en/whats-new`): weekly digest of the most notable features with demos and code snippets, typically tied to a range of versions. The most recent weeks are bundled here.

Recent What's New highlights:

| Week | Dates | Versions | Headline features |
| :--- | :---- | :------- | :---------------- |
| W13 | Mar 23-27, 2026 | 2.1.83-2.1.85 | Auto mode (classifier-driven permissions), Computer use in Desktop, PR auto-fix on Web, transcript search, PowerShell tool, conditional `if` hooks |
| W14 | Mar 30 - Apr 3, 2026 | 2.1.86-2.1.91 | Computer use in CLI, `/powerup` interactive lessons, flicker-free rendering, per-tool MCP `anthropic/maxResultSizeChars`, plugin executables on `PATH` |
| W15 | Apr 6-10, 2026 | 2.1.92-2.1.101 | Ultraplan (cloud plan-mode), Monitor tool (background event streaming), self-pacing `/loop`, `/team-onboarding`, `/autofix-pr` from CLI, `/cost` per-model breakdown for subscribers |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API customers, contribution metrics setup with GitHub, summary metrics, charts, leaderboard, and PR attribution algorithm.
- [Manage costs effectively](references/claude-code-costs.md) — `/cost` command, workspace spend limits, per-team rate-limit recommendations, agent-team token costs, and strategies to reduce token usage (context management, model selection, MCP overhead, hooks, skills, extended thinking, subagents).
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, environment variables, metrics cardinality controls, traces beta, dynamic headers, multi-team attributes, full list of exported metrics and events, interpretation guidance, and security/privacy notes.
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation issues by error message, network/proxy debugging, PATH fixes, permissions and authentication, configuration file locations, performance and stability, IDE integration, markdown formatting, and where to get more help.
- [Changelog](references/claude-code-changelog.md) — per-version release notes for Claude Code (new features, improvements, bug fixes), generated from the public GitHub `CHANGELOG.md`.
- [What's new](references/claude-code-whats-new-index.md) — index of the weekly dev digests highlighting the features most likely to change how you work.
- [Week 13 - March 23-27, 2026](references/claude-code-whats-new-2026-w13.md) — Auto mode, Computer use (Desktop), PR auto-fix on Web, transcript search, PowerShell tool, conditional hooks (v2.1.83-2.1.85).
- [Week 14 - March 30 - April 3, 2026](references/claude-code-whats-new-2026-w14.md) — Computer use in the CLI, `/powerup` lessons, flicker-free rendering, MCP per-tool result-size override, plugin executables on `PATH` (v2.1.86-2.1.91).
- [Week 15 - April 6-10, 2026](references/claude-code-whats-new-2026-w15.md) — Ultraplan cloud planning, the Monitor tool, self-pacing `/loop`, `/team-onboarding`, `/autofix-pr` from the terminal (v2.1.92-2.1.101).

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 - March 23-27, 2026: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 - March 30 - April 3, 2026: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 - April 6-10, 2026: https://code.claude.com/docs/en/whats-new/2026-w15.md
