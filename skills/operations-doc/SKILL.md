---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating Claude Code at scale: analytics dashboards, cost tracking, OpenTelemetry monitoring, configuration debugging, error recovery, installation troubleshooting, and the changelog / What's New digest.

## Quick Reference

### Analytics Dashboards

| Plan | URL | Features |
|:-----|:----|:---------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API / Console | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user team insights |

**Contribution metrics (Teams/Enterprise only):** Require installing the GitHub app at github.com/apps/claude and enabling GitHub analytics in admin settings. Not available with Zero Data Retention. Data appears within 24 hours, updates daily.

**Key summary metrics:**

| Metric | Description |
|:-------|:------------|
| PRs with CC | Merged PRs containing at least one Claude Code-assisted line |
| Lines of code with CC | Effective added lines matched to Claude Code sessions |
| Suggestion accept rate | Fraction of Edit/Write/NotebookEdit suggestions accepted |
| Lines of code accepted | Accepted lines in current sessions (deletions not tracked) |

**PR attribution window:** Sessions from 21 days before to 2 days after PR merge date. Code rewritten >20% is not attributed. Auto-generated files (lock files, build artifacts, test fixtures) are excluded.

### Cost Tracking

**Commands:**

| Command | Purpose |
|:--------|:--------|
| `/usage` | Session token usage, cost estimate, plan limits breakdown |
| `/usage-credits` | Buy or request additional usage (Pro/Max/Team/Enterprise) |
| `/model` | Switch models mid-session |
| `/effort` | Adjust reasoning level (affects thinking token costs) |
| `/compact [focus]` | Summarize history to reduce context size |
| `/clear` | Start a fresh session |
| `/context` | See context window breakdown by category |

**Average enterprise costs:** ~$13/developer/active day; $150–$250/month. 90% of users stay below $30/active day.

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

**Token reduction strategies:**
- Use `/clear` between unrelated tasks; `/compact Focus on X` with custom instructions
- Use Sonnet for most tasks; reserve Opus for complex reasoning; Haiku for simple subagents
- Disable unused MCP servers (`/mcp disable <name>`)
- Keep CLAUDE.md under 200 lines; move specialized instructions to skills
- Lower thinking budget: `MAX_THINKING_TOKENS=8000` or `/effort` slider
- Use subagents to isolate verbose operations (tests, logs, docs fetching)
- Write specific prompts; use plan mode (Shift+Tab) to validate direction before coding

**Agent team cost note:** Each teammate runs its own context window. Agent teams use ~7x more tokens than standard sessions when running in plan mode. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to enable.

### OpenTelemetry Monitoring

**Minimum setup:**

```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key configuration variables:**

| Variable | Description | Default |
|:---------|:------------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | `otlp`, `console`, `none` | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | ms between metric exports | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | ms between log exports | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params/commands/names | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in spans | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response bodies | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include account UUID in metrics | true |

**Available metrics:**

| Metric | Unit |
|:-------|:-----|
| `claude_code.session.count` | count |
| `claude_code.lines_of_code.count` | count |
| `claude_code.pull_request.count` | count |
| `claude_code.commit.count` | count |
| `claude_code.cost.usage` | USD |
| `claude_code.token.usage` | tokens |
| `claude_code.code_edit_tool.decision` | count |
| `claude_code.active_time.total` | seconds |

**Available events (via `OTEL_LOGS_EXPORTER`):**

| Event name | Fired when |
|:-----------|:-----------|
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool finishes executing |
| `claude_code.tool_decision` | Tool permission decision made |
| `claude_code.api_request` | API request sent |
| `claude_code.api_error` | API request fails |
| `claude_code.api_request_body` | API request body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_response_body` | API response body (requires `OTEL_LOG_RAW_API_BODIES`) |
| `claude_code.api_retries_exhausted` | All retries exhausted |
| `claude_code.permission_mode_changed` | Mode switched (plan/auto/default/etc.) |
| `claude_code.auth` | `/login` or `/logout` |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects/fails |
| `claude_code.internal_error` | Unexpected internal error |
| `claude_code.plugin_installed` | Plugin installed |
| `claude_code.plugin_loaded` | Plugin loaded at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.hook_registered` | Hook registered at session start |
| `claude_code.hook_execution_start` | Hook batch starts |
| `claude_code.hook_execution_complete` | Hook batch finishes |
| `claude_code.hook_plugin_metrics` | Official plugin emits per-invocation metrics |
| `claude_code.compaction` | Context compaction completes |
| `claude_code.at_mention` | `@`-mention resolved |
| `claude_code.feedback_survey` | Session quality survey shown/answered |

**Tracing (beta):** Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`.

**Security audit via SIEM:** Point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver with `OTEL_LOG_TOOL_DETAILS=1` to capture tool calls, MCP activity, permission decisions, and auth events with full user identity.

**Dynamic headers** for rotating auth tokens: set `otelHeadersHelper` in `.claude/settings.json` to a script path; runs every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`). Only works with `http/protobuf` and `http/json` protocols.

### Configuration Debugging

**Diagnostic commands:**

| Command | Shows |
|:--------|:------|
| `/context` | Everything in the context window (system prompt, memory files, skills, MCP tools) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills and their sources |
| `/hooks` | Active hook configurations |
| `/mcp` | MCP server connection status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Invalid keys, schema errors, installation health |
| `/status` | Active settings sources; whether managed settings apply |
| `/debug [issue]` | Enable debug logging; Claude diagnoses from log output |

**Clean-slate test:**
```
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```
Bypasses all user/project config. Managed settings still apply. Credentials carry over on macOS (Keychain); re-login required on Linux/Windows.

**Common configuration pitfalls:**

| Symptom | Cause | Fix |
|:--------|:------|:----|
| Hook never fires | `matcher` is a JSON array | Use single string with `\|` separator |
| Hook never fires | Lowercase tool name (`bash`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Defined in standalone file | Put hooks under `"hooks"` key in `settings.json` |
| `permissions`/`hooks`/`env` ignored | Added to `~/.claude.json` | Put them in `~/.claude/settings.json` |
| settings.json value ignored | Overridden by `settings.local.json` | Check scope precedence |
| Skill not in `/skills` | `.claude/skills/name.md` (flat file) | Use folder: `.claude/skills/name/SKILL.md` |
| Skill appears but Claude won't invoke | `disable-model-invocation: true` in frontmatter | Check badge in `/skills` |
| MCP server not loading | Project-scoped server unapproved | Run `/mcp` and approve |
| MCP server fails from some dirs | Relative path in `command`/`args` | Use absolute paths |
| MCP env vars not reaching server | Vars in `settings.json` `env` | Set per-server `env` in `.mcp.json` |

### Error Recovery

**Automatic retries:** Claude Code retries server errors, 529 overloaded, timeouts, and transient 429s up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000 ms).

**Common runtime errors:**

| Error | Cause | Fix |
|:------|:------|:----|
| `API Error: 500` | Server-side failure | Check status.claude.com; retry; `/feedback` if persistent |
| `529 Overloaded` | API at capacity | Retry in minutes; switch model with `/model` |
| `Request timed out` | Slow network or large response | Retry; raise `API_TIMEOUT_MS`; break into smaller prompts |
| `You've hit your session/weekly limit` | Subscription usage exhausted | Wait for reset; `/usage-credits` for extra usage |
| `Request rejected (429)` | API key rate limit hit | Check `/status`; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console prepaid credits depleted | Add credits at Console billing; enable auto-reload |
| `Not logged in` | No valid credential | Run `/login`; set `ANTHROPIC_API_KEY` |
| `Invalid API key` | Key rejected or revoked | Check Console; look for stale key in env (`env \| grep ANTHROPIC`) |
| `OAuth token revoked/expired` | Session token invalid | `/logout` then `/login` |
| `Prompt is too long` | Exceeds context window | `/compact`; `/clear`; disable unused MCP servers |
| `Extra inputs are not permitted` | Gateway stripped `anthropic-beta` header | Configure gateway to forward header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `thinking.type.enabled is not supported` | Claude Code version too old for Opus 4.7/4.8 | Run `claude update` |
| `API Error: 400 due to tool use concurrency` | Corrupted conversation history | `/rewind` or double-press Esc |
| `403` with `x-deny-reason: host_not_allowed` | Cloud session network policy blocked host | Open environment settings; change network access to Custom; add domain |
| `SSL certificate verification failed` | Corporate TLS inspection | Set `NODE_EXTRA_CA_CERTS=/path/to/ca.pem` |

**Response quality issues:** Run `/model` (confirm model), `/effort` (confirm reasoning level), `/context` (check window fullness). Use `/rewind` or double-press Esc to step back past a bad turn rather than correcting in-thread.

### Installation Troubleshooting

**Quick diagnostic:**
```
claude doctor
```

**PATH fix (macOS/Linux):**
```
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

**PATH fix (Windows PowerShell):**
```
[Environment]::SetEnvironmentVariable('PATH', "$([Environment]::GetEnvironmentVariable('PATH','User'));$env:USERPROFILE\.local\bin", 'User')
```

**Common install errors:**

| Error | Fix |
|:------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH; restart terminal |
| HTML/403 from install script | Use Homebrew (`brew install --cask claude-code`) or WinGet (`winget install Anthropic.ClaudeCode`) |
| `Killed` on low-memory Linux | Add 2GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| `Error loading shared library` (Linux) | Check if glibc vs musl mismatch; install `libgcc libstdc++` on Alpine |
| `Illegal instruction` | Missing AVX; see github.com/anthropics/claude-code/issues/50384 |
| `dyld: cannot load` (macOS) | macOS < 13.0; update macOS |
| `Exec format error` (WSL1) | Convert to WSL2: `wsl --set-version <distro> 2` |
| `OAuth error: Invalid code` | Code expired; press Enter to retry login quickly |
| `403 Forbidden` after login | Subscription inactive; Console role missing "Claude Code"/"Developer" |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` overrides subscription; `unset ANTHROPIC_API_KEY` |
| `Could not load credentials` (Bedrock) | Run `aws sts get-caller-identity`; re-authenticate |
| `Could not load credentials` (Vertex) | Set `ANTHROPIC_VERTEX_PROJECT_ID` + `CLOUD_ML_REGION`; `gcloud auth application-default login` |
| Install hangs in Docker | Add `WORKDIR /tmp` before install command |

### Changelog & What's New

Run `claude --version` to check your version. The changelog lists every bug fix and minor improvement. The weekly What's New digest covers notable features with context and examples.

**Recent major releases (as of 2026-06-01):**
- **v2.1.159** (May 31, 2026): Internal infrastructure improvements
- **v2.1.158** (May 30, 2026): Auto mode on Bedrock/Vertex/Foundry for Opus 4.7 and 4.8 (opt in via `CLAUDE_CODE_ENABLE_AUTO_MODE=1`)
- **v2.1.157** (May 29, 2026): Plugins auto-load from `.claude/skills` directories; `claude plugin init <name>`; EnterWorktree mid-session switching
- **v2.1.154** (May 28, 2026): Opus 4.8, dynamic workflows, fast mode on Opus 4.8 at 2x cost/2.5x speed
- **Week 22** (May 25–29): Opus 4.8 default; dynamic workflows; security-guidance plugin; fast mode on Opus 4.8
- **Week 21** (May 18–22): Auto mode on Pro plan; `/usage` breakdown by skill/subagent/plugin/MCP; `/code-review` command; background sessions in `/resume`
- **Week 20** (May 11–15): `claude agents` view; `/goal` command; fast mode on Opus 4.7
- **Week 19** (May 4–8): Plugins from `.zip` archives and URLs; auto mode hard deny rules
- **Week 18** (April 27–May 1): Windows without Git Bash; `claude ultrareview`; `claude project purge`
- **Week 17** (April 20–24): `/ultrareview` public research preview; session recap; custom themes
- **Week 16** (April 13–17): Claude Opus 4.7; `xhigh` effort level; Routines on the web; mobile push notifications; native binaries
- **Week 15** (April 6–10): Ultraplan early preview; Monitor tool for streaming events; `/loop` self-pacing
- **Week 14** (March 30–April 3): Computer use in CLI research preview; `/powerup` interactive lessons
- **Week 13** (March 23–27): Auto mode research preview; transcript search with `/`; native PowerShell tool

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — Team analytics dashboards, contribution metrics setup, PR attribution, ROI measurement for Teams/Enterprise and API customers
- [Manage Costs](references/claude-code-costs.md) — Track token usage with `/usage`, team spend limits, rate limit recommendations, agent team costs, and strategies to reduce token consumption
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — Full OTel configuration, all metrics and events, trace spans, security/audit events, mTLS, dynamic headers, and SIEM integration
- [Debug Your Configuration](references/claude-code-debug-your-config.md) — Use `/context`, `/doctor`, `/hooks`, `/mcp`, and clean-session testing to diagnose why settings, hooks, MCP servers, or skills aren't working
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, auto-compact thrashing, hangs/freezes, and search/ripgrep issues
- [Troubleshoot Installation and Login](references/claude-code-troubleshoot-install.md) — Fix `command not found`, PATH, TLS/SSL, network, platform-specific (WSL, Windows, Docker, Alpine), and authentication errors
- [Error Reference](references/claude-code-errors.md) — Full list of runtime error messages with causes and recovery steps; server errors, usage limits, auth errors, network errors, request errors
- [Changelog](references/claude-code-changelog.md) — Full release notes by version number (generated from GitHub CHANGELOG.md)
- [What's New Index](references/claude-code-whats-new-index.md) — Weekly digest index linking to per-week feature summaries
- [What's New: Week 13](references/claude-code-whats-new-2026-w13.md) — Auto mode, computer use in Desktop, transcript search, PowerShell tool, conditional hooks
- [What's New: Week 14](references/claude-code-whats-new-2026-w14.md) — Computer use CLI preview, `/powerup` lessons, per-tool MCP result-size override
- [What's New: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop` self-pacing, `/team-onboarding`, `/autofix-pr`
- [What's New: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines on the web, mobile push notifications, native binaries
- [What's New: Week 17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview` public preview, session recap, custom themes, Claude Code on the web redesign
- [What's New: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`, PR URL in `/resume`
- [What's New: Week 19](references/claude-code-whats-new-2026-w19.md) — Plugins from `.zip`/URLs, `worktree.baseRef`, auto mode hard deny rules, hooks see effort level
- [What's New: Week 20](references/claude-code-whats-new-2026-w20.md) — `claude agents` view, `/goal` command, fast mode on Opus 4.7, Rewind menu summarization
- [What's New: Week 21](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro plan, `/usage` breakdown by skill/subagent/plugin/MCP, `/code-review` command, background sessions
- [What's New: Week 22](references/claude-code-whats-new-2026-w22.md) — Claude Opus 4.8 as new default, dynamic workflows, security-guidance plugin, fast mode on Opus 4.8

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Manage Costs: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug Your Configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot Installation and Login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error Reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New Index: https://code.claude.com/docs/en/whats-new/index.md
- What's New: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New: Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's New: Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's New: Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's New: Week 21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's New: Week 22: https://code.claude.com/docs/en/whats-new/2026-w22.md
