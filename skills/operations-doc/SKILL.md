---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, troubleshooting, and tracking costs for Claude Code deployments.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub integration), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user team insights |

**Contribution metrics setup (Teams/Enterprise):** Install the GitHub app at github.com/apps/claude → enable Claude Code analytics at claude.ai/admin-settings/claude-code → enable GitHub analytics toggle → authenticate with GitHub. Data appears within 24 hours. Not available with Zero Data Retention.

**Key metric definitions:**

| Metric | Description |
| :--- | :--- |
| PRs with CC | Merged PRs containing at least one Claude-assisted line |
| Lines of code with CC | Effective lines (>3 chars after normalization) across merged PRs |
| Suggestion accept rate | % of Edit, Write, and NotebookEdit uses that were accepted |
| Lines of code accepted | Accepted lines written by Claude (not tracking post-acceptance deletions) |

Attribution window: sessions from 21 days before to 2 days after PR merge date. PRs are labeled `claude-code-assisted` in GitHub.

---

### Cost Tracking

**Commands:**

| Command | Description |
| :--- | :--- |
| `/usage` | Token/cost breakdown for current session; plan usage bars for subscribers |
| `/usage-credits` | Buy extra usage credits (Pro/Max) or request from admin (Team/Enterprise) |
| `/model` | Switch model to manage cost |
| `/effort` | Adjust reasoning level to reduce thinking-token spend |
| `/compact [focus]` | Summarize context; custom focus preserves what matters |
| `/clear` | Start fresh session to shed stale context |

**Average enterprise cost:** ~$13/developer/active day; $150–250/month. 90% of users stay below $30/active day.

**Team rate limit recommendations (TPM/RPM per user):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Token reduction strategies:**

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` when switching unrelated work |
| Choose the right model | Sonnet for most tasks; reserve Opus for complex reasoning |
| Reduce MCP overhead | Disable unused servers with `/mcp`; prefer CLI tools (gh, aws, etc.) |
| Use plan mode | Shift+Tab before implementation to avoid expensive re-work |
| Delegate verbose ops | Send test runs, log processing to subagents |
| Move instructions to skills | Keep CLAUDE.md under 200 lines; skills load on demand |
| Adjust extended thinking | `/effort` or lower `MAX_THINKING_TOKENS` for simpler tasks |
| Write specific prompts | Target file + function, not broad codebase requests |

**Agent team cost notes:** Teams use ~7x more tokens than standard sessions. Use Sonnet for teammates, keep teams small, shut down teammates when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

---

### OpenTelemetry Monitoring

**Enable telemetry (minimum config):**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log tool names, commands, MCP server/tool names | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in trace spans | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response JSON | disabled |

**Available metrics:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost estimate | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit permission decisions | count |
| `claude_code.active_time.total` | Active time (user + cli) | s |

**Key events exported via `OTEL_LOGS_EXPORTER`:**

| Event | Fires when |
| :--- | :--- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission accept/reject decision |
| `claude_code.api_request` | API call made |
| `claude_code.api_error` | API call fails (after retries exhausted) |
| `claude_code.api_refusal` | API returns `stop_reason: "refusal"` |
| `claude_code.permission_mode_changed` | Permission mode changes |
| `claude_code.mcp_server_connection` | MCP server connects/fails/disconnects |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.compaction` | Context compaction completes |
| `claude_code.plugin_installed` | Plugin installed |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.hook_execution_complete` | Hook batch finishes |
| `claude_code.internal_error` | Unexpected internal error caught |

**Tracing (beta):** Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`.

**SIEM integration (managed settings example):**

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

**Security event mapping:**

| Signal | Event | Key attributes |
| :--- | :--- | :--- |
| Tool allow/deny | `tool_decision` | `decision`, `source`, `tool_name` |
| Permission escalation | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Hook blocked action | `hook_execution_complete` | `hook_event`, `num_blocking` |
| Login/logout/auth failure | `auth` | `action`, `success`, `error_category` |
| MCP connect/fail | `mcp_server_connection` | `status`, `server_name`, `error_code` |
| Plugin installed | `plugin_installed` | `plugin.name`, `marketplace.is_official` |

---

### Troubleshooting Quick Lookup

**Route to the right page:**

| Symptom | Go to |
| :--- | :--- |
| `command not found`, PATH, `EACCES`, TLS install errors | Troubleshoot installation and login |
| Login loops, OAuth errors, `403 Forbidden`, Bedrock/Vertex/Foundry credentials | Troubleshoot installation and login (login section) |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529 Overloaded`, `429`, request validation errors | Error reference |
| `model not found` | Error reference (selected model section) |
| High CPU/memory, hangs, search not finding files | Troubleshooting (performance section) |

**Run `/doctor`** for an automated check of installation, settings, MCP servers, and context usage. If `claude` won't start, run `claude doctor` from your shell.

**Performance fixes:**

| Problem | Fix |
| :--- | :--- |
| High CPU/memory | `/compact` regularly; restart between major tasks; `claude --safe-mode` to isolate plugins |
| Memory stays high | `/heapdump` writes snapshot + breakdown to ~/Desktop (or ~/ on Linux) |
| Thrashing error | Smaller chunks; `/compact keep only ...`; move large-file work to a subagent; `/clear` |
| Hang or freeze | Ctrl+C; restart and run `claude --resume` to recover |
| Garbled text in VS Code terminal | `/terminal-setup` to disable GPU acceleration |
| Search not finding files | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work from Linux filesystem (`/home/`), not `/mnt/c/`; specify directories in search queries |

---

### Debug Your Configuration

**Inspection commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | MCP server status and tools |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics, schema errors, installation health |
| `/status` | Active settings sources including managed settings |
| `/debug [issue]` | Enable debug logging + prompt Claude to diagnose |

**Clean-session test:**

```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

Or use `claude --safe-mode` to disable all customizations for the session.

**Common configuration mistakes:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is JSON array, not string | Use `"Edit\|Write"` (string with pipe) |
| Hook never fires | Lowercase matcher e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks in a standalone file | Define under `"hooks"` key in `settings.json` |
| Settings ignored | Placed in `~/.claude.json` instead of `~/.claude/settings.json` | Use the correct file |
| Skill not in `/skills` | Flat file at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP server never loads | File at `.claude/.mcp.json` | Place `.mcp.json` at the repository root |
| MCP server not approved | One-time approval prompt dismissed | Run `/mcp` and approve |

---

### Error Reference Quick Lookup

**Automatic retries:** Claude Code retries server errors, 529, timeouts, and transient 429s up to 10 times. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

**Error categories:**

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server-side failure | Check status.claude.com; retry; `/feedback` |
| `API Error: 529 Overloaded` | API at capacity | Check status page; retry; `/model` to switch |
| `Request timed out` | API didn't respond in time | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session limit` | Plan quota exhausted | Wait for reset; `/usage-credits`; upgrade plan |
| `Request rejected (429)` | Rate limit hit | Check `/status` for credential; reduce concurrency |
| `Credit balance is too low` | Console credits depleted | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | No valid credential | `/login` |
| `Invalid API key` | Key rejected | Check for typos; check Console for revocation |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` overriding subscription | Unset `ANTHROPIC_API_KEY` |
| `Unable to connect to API` | Network failure | Check proxy; verify `curl -I https://api.anthropic.com` |
| `SSL certificate verification failed` | Corporate TLS inspection | Set `NODE_EXTRA_CA_CERTS` to CA bundle path |
| `Prompt is too long` | Context window full | `/compact`; `/clear`; disable unused MCP servers |
| `Extra inputs are not permitted` | Gateway stripping `anthropic-beta` header | Configure gateway to forward the header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model not found or no access | `/model` to pick available model; check config locations for stale ID |
| `thinking.type.enabled is not supported` | Claude Code version too old for Opus 4.7/4.8 | `claude update` and restart |
| `API Error: 400 due to tool use concurrency issues` | Conversation history inconsistent after interruption | `/rewind` to restore checkpoint |
| Usage Policy refusal | Content triggered policy check | `/rewind` and rephrase; or `/clear` |

---

### Changelog and What's New

The changelog (`claude-code-changelog.md`) lists every version's bug fixes and improvements. Run `claude --version` to check your installed version.

The weekly "What's new" digest (`claude-code-whats-new-index.md` and per-week files w13–w24) highlights major features with runnable examples. Recent highlights:
- **Week 24 (v2.1.166–v2.1.176):** `/cd` to change working directory mid-session; sub-agents spawning sub-agents (5 levels deep); `--safe-mode`; `fallbackModel`
- **Week 23 (v2.1.158–v2.1.165):** Auto mode on Bedrock/Vertex/Foundry; safer automatic edits; version requirements in managed deployments
- **Week 22 (v2.1.150–v2.1.157):** Claude Opus 4.8 as default for Max/Team Premium; dynamic workflows; fast mode on Opus 4.8
- **Week 21 (v2.1.143–v2.1.149):** Auto mode on Pro plan; `/usage` skill/plugin breakdown; `/code-review` command; background sessions

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Analytics dashboards for Teams/Enterprise and API, contribution metrics, GitHub integration, PR attribution, leaderboard, data export
- [Manage costs effectively](references/claude-code-costs.md) — Token tracking, team spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring (OpenTelemetry)](references/claude-code-monitoring-usage.md) — Full OTel configuration, all metrics and events with attributes, tracing (beta), SIEM integration, cardinality control, backend recommendations
- [Troubleshooting](references/claude-code-troubleshooting.md) — Performance and stability issues: high CPU/memory, thrashing, hangs, search problems, WSL
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — Installation errors, PATH, TLS, platform-specific issues, authentication, Bedrock/Vertex/Foundry credentials
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnosing why settings, hooks, MCP servers, and skills aren't applying; clean-session testing; common mistakes table
- [Error reference](references/claude-code-errors.md) — Runtime error messages with causes and recovery steps; server errors, usage limits, auth errors, network errors, request errors
- [Changelog](references/claude-code-changelog.md) — Full release notes for every Claude Code version
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest overview linking to per-week feature highlights
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — Week of March 23, 2026
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — Week of March 30, 2026
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Week of April 6, 2026
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Week of April 13, 2026
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — Week of April 20, 2026
- [What's new: Week 18](references/claude-code-whats-new-2026-w18.md) — Week of April 27, 2026
- [What's new: Week 19](references/claude-code-whats-new-2026-w19.md) — Week of May 4, 2026
- [What's new: Week 20](references/claude-code-whats-new-2026-w20.md) — Week of May 11, 2026 (Agent view, /goal, fast mode on Opus 4.7)
- [What's new: Week 21](references/claude-code-whats-new-2026-w21.md) — Week of May 18, 2026 (Auto mode on Pro, /usage skill breakdown, /code-review)
- [What's new: Week 22](references/claude-code-whats-new-2026-w22.md) — Week of May 25, 2026 (Claude Opus 4.8, dynamic workflows, fast mode)
- [What's new: Week 23](references/claude-code-whats-new-2026-w23.md) — Week of June 1, 2026 (Auto mode on Bedrock/Vertex/Foundry, safer edits)
- [What's new: Week 24](references/claude-code-whats-new-2026-w24.md) — Week of June 8, 2026 (/cd, sub-agent chains, --safe-mode, fallbackModel)

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring (OpenTelemetry): https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new: Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new: Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new: Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new: Week 21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new: Week 22: https://code.claude.com/docs/en/whats-new/2026-w22.md
- What's new: Week 23: https://code.claude.com/docs/en/whats-new/2026-w23.md
- What's new: Week 24: https://code.claude.com/docs/en/whats-new/2026-w24.md
