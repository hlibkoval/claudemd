---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards (Teams/Enterprise and API), cost tracking and spend limits, OpenTelemetry monitoring (metrics, events, traces), error reference (server/usage/auth/network/request errors), troubleshooting (performance, stability, search), install/login troubleshooting, configuration debugging, changelog, and weekly What's New digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, troubleshooting, and staying up to date with Claude Code.

## Quick Reference

### Analytics Dashboards

| Plan | URL | Requires |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Admin or Owner role |
| API (Claude Console) | platform.claude.com/claude-code | UsageView permission |

Key metrics: lines of code accepted, suggestion accept rate, daily active users, PRs with Claude Code (%). Contribution metrics (GitHub integration) require enabling GitHub analytics in admin settings — not available with Zero Data Retention.

### Cost Tracking

- **In-session**: run `/usage` for token counts and estimated cost
- **Team spend limits**: set workspace spend limits at platform.claude.com (Console) or use workspace rate limits to cap Claude Code's share
- **Average cost**: ~$13/developer/active day; $150–250/month across enterprise deployments
- **Agent teams**: ~7x more tokens than standard sessions (each teammate has its own context window)

### Rate Limit Recommendations (API)

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

### Cost Reduction Strategies

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` to drop stale context; `/compact Focus on X` for targeted summarization |
| Right-size the model | Sonnet for most tasks; Haiku for subagents; Opus for complex reasoning |
| Reduce MCP overhead | MCP tools are deferred by default; disable unused servers with `/mcp` |
| Shrink CLAUDE.md | Move specialized workflows to skills (load on demand, not at session start); keep CLAUDE.md under 200 lines |
| Preprocess with hooks | Use PreToolUse hooks to filter large outputs before Claude sees them |
| Lower thinking budget | `/effort` or `MAX_THINKING_TOKENS=8000` for simpler tasks |
| Delegate verbose ops | Subagents keep verbose output in their own context window |

### OpenTelemetry Quick Start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Key OTel Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include user prompt content | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool params, Bash commands, MCP names | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in trace spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid in metrics | true |

### Available Metrics

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | Sessions started | count |
| `claude_code.lines_of_code.count` | Lines of code modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used (type: input/output/cacheRead/cacheCreation) | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit permission decisions | count |
| `claude_code.active_time.total` | Active time (type: user/cli) | s |

### Available OTel Events

| Event name | Fired when |
| :--- | :--- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.api_request` | API call made |
| `claude_code.api_error` | API call fails |
| `claude_code.api_request_body` | API call attempt (when `OTEL_LOG_RAW_API_BODIES` set) |
| `claude_code.api_response_body` | Successful API response (when `OTEL_LOG_RAW_API_BODIES` set) |
| `claude_code.tool_decision` | Permission accept/reject |
| `claude_code.permission_mode_changed` | Mode changes (default/plan/auto/etc.) |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.mcp_server_connection` | MCP server connects, disconnects, or fails |
| `claude_code.internal_error` | Unexpected internal error caught |
| `claude_code.plugin_installed` | Plugin installed |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.at_mention` | `@`-mention resolved in a prompt |
| `claude_code.api_retries_exhausted` | API request fails after all retries |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` | Hooks begin executing |
| `claude_code.hook_execution_complete` | Hooks finish executing |
| `claude_code.compaction` | Conversation compaction completes |
| `claude_code.feedback_survey` | Session quality survey appears or is answered |

### Traces (Beta)

Enable: `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`

Span hierarchy per user prompt:
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook  (requires detailed beta)
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    ├── claude_code.tool.execution
    └── (Task tool) subagent spans
```

Bash and PowerShell subprocesses inherit `TRACEPARENT` for end-to-end distributed tracing.

### Standard OTel Attributes (on all metrics and events)

`session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

### Error Reference Quick Lookup

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com; retry; `/feedback` |
| `API Error: Repeated 529 Overloaded errors` | Server | Check status.claude.com; try `/model` to switch model |
| `Request timed out` | Server | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session/weekly limit` | Usage limits | Wait for reset; `/usage-credits` to buy more |
| `Request rejected (429)` | Rate limit | Check `/status`; request higher tier; lower concurrency |
| `Credit balance is too low` | Usage limits | Add credits at platform.claude.com/settings/billing |
| `Not logged in · Please run /login` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for typos; run `env | grep ANTHROPIC` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; run `/status` |
| `OAuth token revoked / expired` | Auth | Run `/logout` then `/login` |
| `Unable to connect to API` | Network | Check `curl -I https://api.anthropic.com`; set `HTTPS_PROXY` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `403` with `x-deny-reason: host_not_allowed` | Network | Add domain to cloud environment allowed domains |
| `Prompt is too long` | Request | `/compact`; `/context`; disable unused MCP servers |
| `Error during compaction: Conversation too long` | Request | Double-Esc to step back; then `/compact` |
| `There's an issue with the selected model` | Request | `/model` to switch; use alias like `sonnet` not versioned ID |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header |
| `thinking.type.enabled is not supported for this model` | Request | Run `claude update` to v2.1.111+ |

Retry behavior: Claude Code retries transient errors up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default: 10) and `API_TIMEOUT_MS` (default: 600000).

### Troubleshooting Quick Reference

| Symptom | First step |
| :--- | :--- |
| `command not found: claude` after install | Fix PATH — see troubleshoot-install |
| OAuth error / 403 Forbidden | See login and authentication section |
| Settings/hooks/MCP not applying | Run `/doctor`; see debug-your-config |
| High CPU or memory | `/compact`; close and restart; run `/heapdump` if persistent |
| Auto-compact thrashing | Read file in chunks; `/compact` with focus; move to subagent |
| Command hangs / freezes | Ctrl+C; restart; use `claude --resume` to continue |
| Search not finding files | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Search slow/incomplete on WSL | Use specific searches; move project to Linux filesystem (`/home/`) |

### Configuration Debugging Commands

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics and schema validation |
| `/status` | Active settings sources and credential |
| `/debug [issue]` | Enable debug logging; Claude diagnoses live |

Test against a clean config (bypasses all user/project settings):
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

### Common Configuration Gotchas

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use `"Edit\|Write"` (single string with `\|`) |
| Hook never fires | Matcher is lowercase (e.g. `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Setting seems ignored | Same key set in `settings.local.json` | local > project > user precedence |
| Skill not in `/skills` | Skill at `.claude/skills/name.md` (not in folder) | Use `.claude/skills/name/SKILL.md` |
| MCP server not loading | `.mcp.json` is inside `.claude/` or uses wrong format | Place `.mcp.json` at repository root |
| MCP server in settings never appears | `mcpServers` key not read from `settings.json` | Use `.mcp.json` or `claude mcp add --scope user` |

### Version and What's New

Run `claude --version` to check your installed version. Run `claude update` to upgrade.

Recent weekly highlights:
- **Week 19 (v2.1.128–136)**: Plugins load from `.zip` archives and URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level
- **Week 18 (v2.1.120–126)**: Windows without Git Bash (uses PowerShell); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume`
- **Week 17 (v2.1.114–119)**: `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign
- **Week 16 (v2.1.105–113)**: Claude Opus 4.7 as new default; `xhigh` effort level; Routines on web; mobile push notifications; native CLI binaries
- **Week 15 (v2.1.92–101)**: Ultraplan early preview; Monitor tool streams background events; `/loop` self-pacing; `/team-onboarding`
- **Week 14 (v2.1.86–91)**: Computer use in CLI research preview; `/powerup` lessons; per-tool MCP result-size override
- **Week 13 (v2.1.83–85)**: Auto mode research preview; computer use in Desktop; PR auto-fix on Web; transcript search

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — usage and contribution metrics, GitHub integration, dashboards for Teams/Enterprise and API customers, PR attribution
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, workspace spend limits, rate limit recommendations, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, all metrics and events, traces beta, SIEM integration, cardinality controls
- [Error reference](references/claude-code-errors.md) — runtime error messages, recovery steps, retry behavior reference
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance/stability issues, auto-compact thrashing, search problems, WSL
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — install errors, PATH issues, authentication failures, platform-specific issues
- [Debug your configuration](references/claude-code-debug-your-config.md) — CLAUDE.md, settings, hooks, MCP, and skills not loading; common config gotchas
- [Changelog](references/claude-code-changelog.md) — full release notes by version
- [What's new (index)](references/claude-code-whats-new-index.md) — weekly digest index with links to each week's highlights
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, PR auto-fix on Web
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use CLI preview, /powerup, MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop, /team-onboarding
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile push, native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign
- [What's new: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview, project purge
- [What's new: Week 19](references/claude-code-whats-new-2026-w19.md) — plugins from zip/URL, worktree.baseRef, auto mode hard deny, hooks see effort

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new (index): https://code.claude.com/docs/en/whats-new/index.md
- What's new: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new: Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new: Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
