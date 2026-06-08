---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics dashboards, cost management, OpenTelemetry monitoring, troubleshooting performance and stability issues, installation and login fixes, configuration debugging, runtime error reference, and the release changelog.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
|:-----|:-------------|:---------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage metrics, spend tracking, team insights |

**Contribution metrics setup (Teams/Enterprise):** Install the GitHub app at `github.com/apps/claude`, enable analytics at `claude.ai/admin-settings/claude-code`, enable GitHub analytics toggle, authenticate with GitHub. Data appears within 24 hours. Not available with Zero Data Retention.

**Key metrics:** PRs with CC, lines of code with CC, suggestion accept rate, lines of code accepted, DAU/sessions, PRs per user.

**Attribution window:** sessions from 21 days before to 2 days after PR merge date. PRs labeled `claude-code-assisted` in GitHub.

### Cost Tracking

| Command | What it shows |
|:--------|:-------------|
| `/usage` | Token usage, session cost estimate, plan limit bars, breakdown by skill/subagent/plugin/MCP |
| `/usage-credits` | Buy extra usage credits (Pro/Max) or request from admin (Team/Enterprise) |
| `/model` | Switch to Sonnet for cheaper tasks, Opus for complex ones |
| `/effort` | Adjust thinking depth (lower = fewer tokens) |
| `/compact` | Summarize context to reduce per-message costs |
| `/clear` | Start fresh to eliminate stale context |
| `/context` | See what is consuming the context window |

**Team rate limit guidelines (TPM/RPM per user):**

| Team size | TPM per user | RPM per user |
|:----------|:-------------|:-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 20-50 | 50k-75k | 1.25-1.75 |
| 50-100 | 25k-35k | 0.62-0.87 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

**Average enterprise cost:** ~$13/developer/active day; $150-250/developer/month.

**Cost reduction strategies:** use Sonnet for most tasks, keep CLAUDE.md under 200 lines, move specialized instructions to skills (load on demand), use subagents to isolate verbose operations, lower effort level for simple tasks, disable unused MCP servers.

### OpenTelemetry Monitoring

**Quick start environment variables:**

| Variable | Description | Example |
|:---------|:------------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | OTLP protocol | `grpc`, `http/protobuf`, `http/json` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval ms (default: 60000) | `5000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval ms (default: 5000) | `1000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) | `1` |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params/commands (default: off) | `1` |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in spans (default: off) | `1` |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response JSON | `1` or `file:<dir>` |

**Traces (beta):** also set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`.

**Available metrics:**

| Metric | Unit | Description |
|:-------|:-----|:------------|
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines of code modified |
| `claude_code.pull_request.count` | count | Pull requests created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | API cost per session |
| `claude_code.token.usage` | tokens | Tokens used |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit permission decisions |
| `claude_code.active_time.total` | s | Active session time |

**Key events:** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.tool_decision`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.mcp_server_connection`, `claude_code.skill_activated`, `claude_code.plugin_loaded`, `claude_code.compaction`, `claude_code.auth`

**Cardinality control:**

| Variable | Default | Controls |
|:---------|:--------|:---------|
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | `session.id` attribute on metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | `user.account_uuid` / `user.account_id` on metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | `app.version` on metrics |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | `false` | `app.entrypoint` on metrics |
| `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES` | `true` | Custom `OTEL_RESOURCE_ATTRIBUTES` as datapoint labels |

**Dynamic headers:** configure `otelHeadersHelper` in `.claude/settings.json` to point at a script that outputs `{"Header": "value"}` JSON. Refreshes every 29 minutes (configurable via `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Multi-team segmentation:** `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` — no spaces in values, comma-separated key=value pairs only.

### Troubleshooting Quick Lookup

| Symptom | Go to |
|:--------|:------|
| `command not found`, install fails, PATH, `EACCES`, TLS errors | Troubleshoot installation and login |
| Login loops, OAuth errors, `403 Forbidden`, Bedrock/Vertex/Foundry creds | Troubleshoot installation and login → Login and authentication |
| Settings not applying, hooks not firing, MCP servers not loading | Debug your configuration |
| `API Error: 5xx`, `529 Overloaded`, `429`, request validation errors | Error reference |
| High CPU/memory, slow responses, hangs, search not finding files | Troubleshooting → Performance and stability |

**Diagnostic commands:**

| Command | Purpose |
|:--------|:--------|
| `/doctor` | Check installation health, settings validity, MCP config, context usage |
| `/context` | See everything in the context window by category |
| `/memory` | Which CLAUDE.md files loaded |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Active allow and deny rules |
| `/status` | Active settings sources |
| `/debug [issue]` | Enable debug logging for the session |
| `claude --debug hooks` | Watch hook evaluation live |
| `CLAUDE_CONFIG_DIR=/tmp/claude-clean claude` | Test against a clean configuration |

**Common configuration mistakes:**

| Symptom | Cause | Fix |
|:--------|:------|:----|
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | Matcher is lowercase | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Permissions/hooks ignored globally | Config added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP servers in `.mcp.json` never load | File is under `.claude/` | Place `.mcp.json` at repository root |
| MCP server starts without env vars | Set in `settings.json` env | Set per-server `env` in `.mcp.json` |

### Error Reference Quick Lookup

**Automatic retries:** Claude Code retries up to 10 times (configurable via `CLAUDE_CODE_MAX_RETRIES`). Timeout: 600000ms (`API_TIMEOUT_MS`).

**Server errors:**

| Error | Cause | Fix |
|:------|:------|:----|
| `API Error: 500` | Temporary server failure | Check `status.claude.com`; retry |
| `API Error: 529 Overloaded` | API at capacity | Wait; try `/model` to switch to a less-loaded model |
| `Request timed out` | High load or large response | Retry; raise `API_TIMEOUT_MS` for slow networks |

**Usage limits:**

| Error | Fix |
|:------|:----|
| `You've hit your session/weekly limit` | Wait for reset; `/usage-credits` for more; upgrade plan |
| `Request rejected (429)` | Check rate limits in provider console; lower concurrency |
| `Credit balance is too low` | Add credits at `platform.claude.com/settings/billing` |

**Authentication errors:**

| Error | Fix |
|:------|:----|
| `Not logged in` | Run `/login` |
| `Invalid API key` | Check key; unset `ANTHROPIC_API_KEY` |
| `This organization has been disabled` | Unset stale `ANTHROPIC_API_KEY`; run `/status` |
| `OAuth token revoked or expired` | Run `/login` (or `/logout` then `/login`) |
| `OAuth token does not meet scope requirement` | Run `/login` to mint a new token |

**Request errors:**

| Error | Fix |
|:------|:----|
| `Prompt is too long` | `/compact` or `/clear`; disable unused MCP servers |
| `Request too large (max 30 MB)` | Remove large attached content; reference files by path |
| `There's an issue with the selected model` | Run `/model` to pick a valid model |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` to recover the conversation |

**Quality issues:** run `/model` (confirm model), `/effort` (raise reasoning level), `/context` (check window usage), `/compact` or `/clear` (free space).

### Installation Quick Fixes

| Error | Solution |
|:------|:---------|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; check network/region |
| `TLS connect error` | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate CA |
| `Killed` on low-memory Linux | Add 2GB swap: `sudo fallocate -l 2G /swapfile` |
| `Error loading shared library` | glibc/musl binary mismatch; reinstall correct variant |
| `Illegal instruction` | CPU missing AVX or architecture mismatch |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; update macOS |
| `Exec format error` on WSL | WSL1 issue; upgrade to WSL2 or use dynamic linker workaround |

**Install locations:**
- macOS/Linux: `~/.local/bin/claude`
- Windows: `%USERPROFILE%\.local\bin\claude.exe`

**Alternative installers:** macOS: `brew install --cask claude-code` | Windows: `winget install Anthropic.ClaudeCode`

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — Usage and contribution metrics dashboards, GitHub integration, PR attribution, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — Track token usage with `/usage`, team spend limits, rate limit guidelines, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel quick start, config variables, metrics, events, traces, SIEM integration, security/privacy
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, auto-compact thrashing, hangs, search issues, WSL performance
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, network, TLS, Windows, WSL, binary issues, OAuth and cloud provider auth
- [Debug your configuration](references/claude-code-debug-your-config.md) — Diagnosing CLAUDE.md, settings, hooks, MCP servers, and skills not loading
- [Error reference](references/claude-code-errors.md) — Runtime error messages, causes, and recovery for server, auth, network, and request errors
- [Claude Code changelog](references/claude-code-changelog.md) — Full release notes by version number
- [What's new index](references/claude-code-whats-new-index.md) — Weekly digests of notable features with context and demos
- [What's new: Week 13 (Mar 23–27, 2026)](references/claude-code-whats-new-2026-w13.md) — Auto mode research preview, computer use in Desktop, conditional hooks
- [What's new: Week 14 (Mar 30 – Apr 3, 2026)](references/claude-code-whats-new-2026-w14.md) — Computer use in CLI, /powerup lessons, per-tool MCP result-size override
- [What's new: Week 15 (Apr 6–10, 2026)](references/claude-code-whats-new-2026-w15.md) — Ultraplan preview, Monitor tool, /loop self-pacing
- [What's new: Week 16 (Apr 13–17, 2026)](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, xhigh effort level, Routines on web, native binaries
- [What's new: Week 17 (Apr 20–24, 2026)](references/claude-code-whats-new-2026-w17.md) — /ultrareview public preview, session recap, custom themes
- [What's new: Week 18 (Apr 27 – May 1, 2026)](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview, claude project purge
- [What's new: Week 19 (May 4–8, 2026)](references/claude-code-whats-new-2026-w19.md) — Plugins from zip/URL, worktree.baseRef, auto mode hard deny rules
- [What's new: Week 20 (May 11–15, 2026)](references/claude-code-whats-new-2026-w20.md) — Agent view (claude agents), /goal command, fast mode on Opus 4.7
- [What's new: Week 21 (May 18–22, 2026)](references/claude-code-whats-new-2026-w21.md) — Auto mode on Pro plan, /usage plan breakdown, /code-review command
- [What's new: Week 22 (May 25–29, 2026)](references/claude-code-whats-new-2026-w22.md) — Claude Opus 4.8 as new default, dynamic workflows, security-guidance plugin

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Claude Code changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new 2026-w13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new 2026-w14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new 2026-w15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new 2026-w16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new 2026-w17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new 2026-w18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new 2026-w19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new 2026-w20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's new 2026-w21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's new 2026-w22: https://code.claude.com/docs/en/whats-new/2026-w22.md
