---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost management, OpenTelemetry monitoring, configuration debugging, runtime troubleshooting, installation troubleshooting, error reference, changelog, and weekly what's new digests. Use when working with usage metrics, spend limits, OTel telemetry, diagnosing configuration issues (hooks, MCP, settings, skills not loading), fixing runtime or install errors, or looking up recent releases.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, costs, monitoring, debugging, troubleshooting, errors, and release history.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Key metrics |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Lines accepted, accept rate, DAU, PRs with CC, GitHub contribution metrics, leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Lines accepted, accept rate, activity chart, per-user spend and lines |

Contribution metrics (GitHub integration) require: Owner installs Claude GitHub app at github.com/apps/claude; Owner enables analytics + GitHub analytics at claude.ai/admin-settings/claude-code. Data appears within 24 hours. Not available with Zero Data Retention enabled.

Attribution window: sessions from 21 days before to 2 days after PR merge date. Code changed more than 20% from Claude's output is not attributed. Merged PRs with Claude Code lines are labeled `claude-code-assisted` in GitHub.

### Cost tracking

| Mechanism | How to use |
| :--- | :--- |
| `/usage` in-session | Session token counts, cost estimate, plan limits breakdown, per-skill/plugin/MCP breakdown; press `d`/`w` for 24h/7d view |
| Console billing page | Authoritative billing at platform.claude.com/usage |
| Workspace spend limits | Set at platform.claude.com (API customers); caps Claude Code workspace spend |
| `/usage-credits` | Buy extra usage credits on Pro/Max; request from admin on Team/Enterprise |

Average enterprise cost: ~$13/developer/active day; $150–250/month. 90% of users stay below $30/active day.

### Rate limit recommendations (API)

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

### Token reduction strategies

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` (use `/rename` first to preserve findability) |
| Custom compaction focus | `/compact Focus on code samples and API usage` |
| Right model | Sonnet for most tasks; reserve Opus for complex reasoning; `/model` to switch |
| MCP overhead | Disable unused servers with `/mcp disable <name>`; prefer CLI tools over MCP |
| Code intelligence plugins | Replace grep-based search with symbol navigation |
| Hooks for preprocessing | Filter logs/output before Claude sees them (PreToolUse hook) |
| Skills for domain knowledge | Move workflow-specific CLAUDE.md instructions into skills (load on demand) |
| Extended thinking | Lower effort with `/effort` or disable in `/config`; set `MAX_THINKING_TOKENS=8000` for fixed-budget models |
| Subagents for verbose ops | Delegate test runs, doc fetches, log processing to subagents — only summary returns |
| Agent team costs | Use Sonnet for teammates; keep teams small; shut down idle teammates |

Agent teams use approximately 7x more tokens than standard sessions (each teammate maintains its own context window).

### OpenTelemetry quick start

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

Managed settings example (distributable via MDM):
```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector.example.com:4317",
    "OTEL_EXPORTER_OTLP_HEADERS": "Authorization=Bearer example-token"
  }
}
```

### OTel key environment variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter: `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter: `otlp`, `console`, `none` | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for all signals: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers for OTLP | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content in logs | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool parameters, Bash commands, MCP names | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in trace spans (requires tracing) | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full Messages API request/response bodies | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include `session.id` attribute in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include `user.account_uuid` in metrics | true |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom key=value attributes for multi-team segmentation | — |

Traces (beta): set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER=otlp` in addition to the above.

### OTel exported metrics

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines of code modified (added/removed) | count |
| `claude_code.pull_request.count` | Pull requests created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session API cost | USD |
| `claude_code.token.usage` | Tokens used (input/output/cacheRead/cacheCreation) | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit accept or reject decisions | count |
| `claude_code.active_time.total` | Active time (user + cli) | seconds |

Standard attributes on all metrics: `session.id`, `user.id`, `user.email`, `user.account_uuid`, `organization.id`, `terminal.type`, plus custom keys from `OTEL_RESOURCE_ATTRIBUTES`.

### OTel exported events (log events)

| Event name | When emitted |
| :--- | :--- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.tool_decision` | Tool permission decision made (accept/reject) |
| `claude_code.api_request` | API request to Claude |
| `claude_code.api_error` | API request fails |
| `claude_code.api_refusal` | API returns `stop_reason: "refusal"` |
| `claude_code.api_request_body` | Full API request body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_response_body` | Full API response body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_retries_exhausted` | Request fails after multiple retry attempts |
| `claude_code.permission_mode_changed` | Permission mode changes (e.g., entering/leaving plan mode) |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.mcp_server_connection` | MCP server connects, disconnects, or fails |
| `claude_code.plugin_installed` | Plugin finishes installing |
| `claude_code.plugin_loaded` | Plugin enabled at session start |
| `claude_code.skill_activated` | Skill is invoked |
| `claude_code.at_mention` | `@`-mention in prompt resolved |
| `claude_code.hook_registered` | Hook configured at session start |
| `claude_code.hook_execution_start` | Hook begins executing |
| `claude_code.hook_execution_complete` | All hooks for an event finish |
| `claude_code.hook_plugin_metrics` | Official-marketplace plugin hook emits per-invocation metrics |
| `claude_code.compaction` | Conversation compaction completes |
| `claude_code.feedback_survey` | Session quality survey shown or answered |
| `claude_code.internal_error` | Unexpected internal error caught |

All events share a `prompt.id` UUID that links every event produced while processing a single user prompt.

### Tool decision source values

| Source | Meaning |
| :--- | :--- |
| `config` | Auto-decided by settings, allow/deny rules, flags, or permission mode |
| `hook` | A `PreToolUse` or `PermissionRequest` hook returned the decision |
| `user_permanent` | User chose "Yes, and don't ask again" — saves allow rule to personal settings |
| `user_temporary` | User chose "Yes" for one-time or session-scoped approval |
| `user_abort` | User dismissed prompt without answering (treated as reject) |
| `user_reject` | User chose "No" when prompted (treated as reject) |

### SIEM / security audit export

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

Security signal → event mapping:

| Signal | Event | Key attributes |
| :--- | :--- | :--- |
| Tool call allowed or denied | `tool_decision` | `decision`, `source`, `tool_name`, `tool_parameters` |
| Permission mode escalation | `permission_mode_changed` | `from_mode`, `to_mode`, `trigger` |
| Policy hook blocked action | `hook_execution_complete` | `hook_event`, `num_blocking` |
| Login / logout / auth failure | `auth` | `action`, `success`, `error_category` |
| MCP server connect or failure | `mcp_server_connection` | `status`, `server_name`, `is_plugin`, `error_code` |
| Plugin installed | `plugin_installed` | `plugin.name`, `marketplace.name`, `marketplace.is_official` |
| Commands run or files touched | `tool_result` / `tool_decision` + `OTEL_LOG_TOOL_DETAILS=1` | `tool_parameters`, `tool_input` |

### Debugging configuration

Commands to run first when something doesn't work:

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow and deny rules |
| `/doctor` | Configuration diagnostics — invalid keys, schema errors, installation health |
| `/status` | Active settings sources, whether managed settings are in effect |
| `/debug [issue]` | Enable debug logging for the session |

Test with a clean configuration:

```bash
# Disable all customizations for the session (plugins, CLAUDE.md, hooks, MCP, skills)
claude --safe-mode

# Bypass ~/.claude entirely (also skips project config if launched from /tmp)
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

Common configuration mistakes:

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use single string with `\|` separator: `"Edit\|Write"` |
| Hook never fires | `matcher` value is lowercase (e.g., `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Defined in a standalone file instead of `settings.json` | Put hooks under `"hooks"` key in `settings.json` |
| Permissions/hooks ignored | Added to `~/.claude.json` instead of `~/.claude/settings.json` | Two different files; use `settings.json` for permissions/hooks/env |
| `settings.json` value ignored | Same key set in `settings.local.json` | Local overrides project which overrides user scope |
| Skill missing from `/skills` | Skill file at `.claude/skills/name.md` (not in a folder) | Use `.claude/skills/name/SKILL.md` |
| Skill appears but Claude never uses it | `disable-model-invocation: true` in frontmatter | Check badge in `/skills` — user-only means Claude won't auto-trigger |
| MCP servers in `.mcp.json` not loading | File is inside `.claude/` instead of repo root | Place `.mcp.json` at repository root |
| Project MCP server not appearing | One-time approval prompt was dismissed | Run `/mcp` to approve |
| MCP server starts with no env vars | Vars set in `settings.json` env, not per-server `.mcp.json` env | Set env inside `.mcp.json` per-server block |

### Troubleshooting runtime issues

| Symptom | Solution |
| :--- | :--- |
| High CPU/memory | Use `/compact`; close and restart; add build dirs to `.gitignore`; run `claude --safe-mode` to isolate plugins/hooks |
| Autocompact thrashing error | Read file in chunks; run `/compact` with focus; move large-file work to subagent; `/clear` |
| Command hangs | Ctrl+C to cancel; close terminal and restart; run `claude --resume` to pick up session |
| Garbled text in VS Code/Cursor terminal | Run `/terminal-setup` to disable GPU acceleration |
| Search not finding files | Install system `ripgrep` (`brew install ripgrep`, `apt install ripgrep`); set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work from Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`) |

Run `/doctor` inside Claude Code for automated health check. If `claude` won't start, run `claude doctor` from the shell.

### Troubleshooting installation

Quick error lookup:

| What you see | Go to |
| :--- | :--- |
| `command not found: claude` or `claude is not recognized` | Add `~/.local/bin` to PATH (macOS/Linux) or `%USERPROFILE%\.local\bin` (Windows) |
| `syntax error near unexpected token '<'` or HTML in install output | Network/regional issue; use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `curl: (56) Failure writing output to destination` | Retry; test with `curl -sI https://downloads.claude.ai/claude-code-releases/latest` |
| `Killed` during install on Linux | OOM — add 2 GB swap: `sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Error loading shared library` | Linux musl/glibc mismatch — check `ldd --version`; reinstall or `apk add libgcc libstdc++` |
| `Illegal instruction` | Pre-2013 CPU or AVX not passed through VM; no workaround — track issue #50384 |
| `dyld: cannot load` on macOS | macOS < 13.0; update macOS |
| `Exec format error` on WSL | WSL1 regression — convert to WSL2: `wsl --set-version <DistroName> 2` |
| `OAuth error: Invalid code` | Code expired — retry login; press `c` to copy URL for manual browser paste |
| `403 Forbidden` after login | Check subscription active; confirm "Claude Code" or "Developer" role in Console |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` env var overriding subscription — unset it |
| Bedrock: `Could not load credentials` | Run `aws sts get-caller-identity` to confirm AWS credentials |
| Vertex: `Could not load the default credentials` | Set `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION`; run `gcloud auth application-default login` |
| Foundry: `ChainedTokenCredential authentication failed` | Set `ANTHROPIC_FOUNDRY_API_KEY` or run `az login` |

To check PATH: macOS/Linux: `echo $PATH | tr ':' '\n' | grep -Fx "$HOME/.local/bin"`. Windows PowerShell: `$env:PATH -split ';' | Select-String '\.local\\bin'`.

To check for conflicting installations: `which -a claude` (macOS/Linux) or `where.exe claude` (Windows). Remove npm global install with `npm uninstall -g @anthropic-ai/claude-code`. Native installer location: `~/.local/bin/claude`.

### Runtime error reference

| Category | Key errors |
| :--- | :--- |
| Server errors | `500 Internal server error`, `Repeated 529 Overloaded errors`, `Request timed out`, auto mode classifier failures |
| Usage limits | `You've hit your session/weekly limit`, `Usage credits required for 1M context`, `Request rejected (429)`, `Credit balance is too low` |
| Authentication | `Not logged in`, `Invalid API key`, `This organization has been disabled`, `OAuth token revoked`, `Organization has disabled API key/subscription access` |
| Network | `Unable to connect to API`, `SSL certificate verification failed`, `403` with `host_not_allowed` in cloud sessions |
| Request errors | `Prompt is too long`, `Request too large`, `Extra inputs are not permitted`, `There's an issue with the selected model`, thinking budget/tool use mismatches, Usage Policy refusal |

Automatic retries: Claude Code retries up to 10 times with exponential backoff before showing an error. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000 ms).

When quality seems lower: run `/model` to confirm model; `/effort` to check reasoning level; `/context` for context pressure; `/doctor` for stale instructions. Rewind rather than correct in-thread: press Esc twice or run `/rewind`.

### What's new — recent highlights (weekly digests)

| Week | Dates | Highlights |
| :--- | :--- | :--- |
| W24 | June 8–12, 2026 | `/cd` to move session to new directory; sub-agents can spawn sub-agents (capped 5 deep); `--safe-mode`; `fallbackModel` chain |
| W23 | June 1–5, 2026 | Auto mode on Bedrock/Vertex/Foundry; safer automatic edits in acceptEdits mode; `/plugin list`; version requirements |
| W22 | May 25–29, 2026 | Claude Opus 4.8 as new default; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8 |
| W21 | May 18–22, 2026 | Auto mode on Pro plan; `/usage` breaks down plan limits by skill/subagent/plugin/MCP; `/code-review`; background sessions in `/resume` |
| W20 | May 11–15, 2026 | `claude agents` agent view; `/goal` for multi-turn completion; fast mode on Opus 4.7; Rewind menu with "Summarize up to here" |
| W19 | May 4–8, 2026 | Plugins from `.zip` archives and URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level |
| W18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell tool); `claude ultrareview`; `claude project purge`; PR URL in `/resume` |
| W17 | Apr 20–24, 2026 | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| W16 | Apr 13–17, 2026 | Claude Opus 4.7 new default; `xhigh` effort level; Routines on Claude Code on the web; mobile push notifications; CLI native binaries |
| W15 | Apr 6–10, 2026 | Ultraplan early preview; Monitor tool streams background events; `/loop` self-pacing; `/autofix-pr` |
| W14 | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override (up to 500K) |
| W13 | Mar 23–27, 2026 | Auto mode research preview; computer use in Desktop; PR auto-fix on Web; transcript search with `/`; conditional `if` hooks |

Check `claude --version` for your current version. Full changelog at references/claude-code-changelog.md.

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — Usage dashboards for Teams/Enterprise and API customers, contribution metrics setup, PR attribution, leaderboard, CSV export
- [Manage costs](references/claude-code-costs.md) — Token tracking with `/usage`, workspace spend limits, rate limit recommendations, agent team costs, context reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel quick start, admin config, all environment variables, metrics cardinality, distributed tracing (beta), span hierarchy and attributes, all event types, audit/SIEM integration, backend recommendations
- [Debug your configuration](references/claude-code-debug-your-config.md) — Inspecting what loaded with `/context`, `/memory`, `/hooks`, `/mcp`; resolving settings conflicts; testing against clean configuration; common cause table
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, autocompact thrashing, hangs, garbled text, search and discovery issues, WSL performance
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH errors, install script failures, TLS errors, Linux binary mismatches, Windows-specific issues, OAuth errors, Bedrock/Vertex/Foundry credentials
- [Error reference](references/claude-code-errors.md) — Complete runtime error catalog: server errors, usage limits, authentication, network, request errors, response quality checklist
- [Changelog](references/claude-code-changelog.md) — Full version-by-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digest index (W13–W24, 2026)
- [What's new W13](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use in Desktop, PR auto-fix, conditional hooks
- [What's new W14](references/claude-code-whats-new-2026-w14.md) — Computer use in CLI, `/powerup`, per-tool MCP result-size
- [What's new W15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop` self-pacing
- [What's new W16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, `xhigh` effort, Routines, mobile push notifications
- [What's new W17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes
- [What's new W18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`
- [What's new W19](references/claude-code-whats-new-2026-w19.md) — Plugin zip/URL loading, `worktree.baseRef`, auto mode hard deny
- [What's new W20](references/claude-code-whats-new-2026-w20.md) — `claude agents`, `/goal`, fast mode on Opus 4.7, Rewind menu
- [What's new W21](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro, `/usage` breakdown, `/code-review`, background sessions
- [What's new W22](references/claude-code-whats-new-2026-w22.md) — Opus 4.8, dynamic workflows, security-guidance plugin
- [What's new W23](references/claude-code-whats-new-2026-w23.md) — Auto mode on Bedrock/Vertex/Foundry, safer edits, version requirements
- [What's new W24](references/claude-code-whats-new-2026-w24.md) — `/cd`, sub-agent chains, `--safe-mode`, `fallbackModel`

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new W18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new W19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new W20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new W21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new W22: https://code.claude.com/docs/en/whats-new/2026-w22.md
- What's new W23: https://code.claude.com/docs/en/whats-new/2026-w23.md
- What's new W24: https://code.claude.com/docs/en/whats-new/2026-w24.md
