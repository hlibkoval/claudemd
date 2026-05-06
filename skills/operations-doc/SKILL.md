---
name: operations-doc
description: Complete official documentation for operating Claude Code at team and enterprise scale — analytics dashboards, cost management, OpenTelemetry monitoring, error reference, troubleshooting, installation issues, and configuration debugging.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, and troubleshooting Claude Code.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
| :--- | :--- | :--- |
| Teams / Enterprise | [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code) | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console) | [platform.claude.com/claude-code](https://platform.claude.com/claude-code) | Usage metrics, spend tracking, team insights |

**Key contribution metrics** (Teams/Enterprise, requires GitHub app install):
- PRs with CC, Lines of code with CC, PRs with Claude Code (%), Suggestion accept rate, Lines of code accepted
- Attribution window: 21 days before to 2 days after PR merge date
- Auto-excluded: lock files, generated code, build dirs, test fixtures, lines >1,000 chars
- Code rewritten >20% by humans is not attributed; conservative matching is deliberate

### Cost Management

**Average costs**: ~$13/developer/active day; $150–250/developer/month; 90th percentile stays under $30/active day.

**Rate limit recommendations** (TPM / RPM per user):

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies**:
- `/usage` to check token spend; `/clear` between unrelated tasks; `/compact Focus on X` with custom instructions
- `/model` to switch to Sonnet for most tasks; Opus only for complex reasoning
- `/effort` or `MAX_THINKING_TOKENS=8000` to reduce extended thinking budget
- Disable unused MCP servers (`/mcp disable <name>`); MCP tools are deferred by default
- Keep CLAUDE.md under 200 lines; move workflow-specific instructions to skills
- Delegate verbose operations (test runs, log processing) to subagents
- Agent teams use ~7x tokens vs standard sessions; keep tasks small and self-contained

### OpenTelemetry Monitoring

**Quick start environment variables**:

| Variable | Purpose | Values |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | `1` |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `otlp`, `prometheus`, `console`, `none` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `otlp`, `console`, `none` |
| `OTEL_TRACES_EXPORTER` | Traces exporter (beta) | `otlp`, `console`, `none` |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol | `grpc`, `http/protobuf`, `http/json` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | `Authorization=Bearer token` |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics interval (ms, default 60000) | `10000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval (ms, default 5000) | `5000` |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: off) | `1` |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params/args (default: off) | `1` |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in spans (default: off) | `1` |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response bodies | `1` or `file:<dir>` |

**Traces (beta)**: requires `CLAUDE_CODE_ENABLE_TELEMETRY=1` and `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request`, `claude_code.tool` > `claude_code.tool.blocked_on_user`, `claude_code.tool.execution`.

**Available metrics**:

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines of code modified | count |
| `claude_code.pull_request.count` | Pull requests created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Code edit tool permission decisions | count |
| `claude_code.active_time.total` | Total active time | s |

**Key events exported** (via `OTEL_LOGS_EXPORTER`):
`claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.skill_activated`, `claude_code.plugin_installed`

**Standard attributes on all metrics/events**: `session.id`, `user.account_uuid`, `user.account_id`, `organization.id`, `user.id`, `user.email`, `terminal.type`, `app.version`

**Dynamic headers** for enterprise: set `otelHeadersHelper` in `.claude/settings.json` to a script path; script must output JSON `{"Header": "value"}`. Refresh interval controlled by `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` (default: 29 min).

**Cardinality control**:

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Include `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | `false` | Include `app.version` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Include `user.account_uuid` in metrics |

### Error Reference

**Automatic retries**: transient failures (5xx, 529, 429, timeouts, dropped connections) retry up to 10 times with exponential backoff. Configure with `CLAUDE_CODE_MAX_RETRIES` (default: 10) and `API_TIMEOUT_MS` (default: 600000).

**Error quick-lookup**:

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com; retry; `/feedback` |
| `Repeated 529 Overloaded errors` | Server | Wait; `/model` to switch model |
| `Request timed out` | Server/Network | Retry; raise `API_TIMEOUT_MS` |
| `You've hit your session/weekly limit` | Usage limits | Wait for reset; `/extra-usage`; upgrade plan |
| `Server is temporarily limiting requests` | Usage limits | Wait; auto-retried |
| `Request rejected (429)` | Rate limit | Check `/status`; reduce concurrency; raise tier |
| `Credit balance is too low` | Billing | Add credits at Console; enable auto-reload |
| `Not logged in` | Auth | `/login`; check `ANTHROPIC_API_KEY` is set |
| `Invalid API key` | Auth | Check for typos; run `env \| grep ANTHROPIC` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; `/login` |
| `OAuth token revoked/expired` | Auth | `/logout` then `/login` |
| `OAuth token does not meet scope requirement` | Auth | `/login` to mint new token |
| `Unable to connect to API` | Network | `curl -I https://api.anthropic.com`; check proxy |
| `SSL certificate verification failed` | Network | `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | `/compact`, `/clear`, `/context`, disable MCP servers |
| `Error during compaction: Conversation too long` | Request | Press Esc twice to go back; then `/compact` again |
| `Request too large` | Request | Press Esc twice; reference large files by path |
| `Image was too large` | Request | Press Esc twice; resize to <8000px longest edge |
| `PDF too large` / `PDF is password protected` | Request | Use Read tool for page ranges; extract text |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | `/model`; use alias like `sonnet` not versioned ID |
| `Claude Opus is not available with Claude Pro` | Request | `/model`; re-login after plan upgrade |
| `thinking.type.enabled is not supported for this model` | Request | `claude update` to v2.1.111+; switch to Opus 4.6 |
| `max_tokens must be greater than thinking.budget_tokens` | Request | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` or press Esc twice to restore checkpoint |

**Response quality seems lower**: check `/model` (correct model?), `/effort` (effort level?), `/context` (window full?), `/doctor` (oversized CLAUDE.md?). Use `/rewind` to step back to before the bad turn.

**Reporting**: `/feedback` (unavailable on Bedrock/Vertex/Foundry); `/doctor`; status.claude.com; GitHub issues.

### Troubleshooting Performance and Stability

| Problem | Fix |
| :--- | :--- |
| High CPU/memory | `/compact` regularly; restart between tasks; add build dirs to `.gitignore`; `/heapdump` for heap snapshot |
| Autocompact thrashing (`Autocompact is thrashing`) | Read large files in smaller chunks; `/compact keep only the plan and the diff`; move to subagent; `/clear` |
| Command hangs/freezes | Ctrl+C; restart terminal; `claude --resume` to recover |
| Search not finding files | Install platform ripgrep; set `USE_BUILTIN_RIPGREP=0` |
| Slow/incomplete search on WSL | Use more specific searches; move project to `/home/`; use native Windows |

### Configuration Debugging

**Diagnostic commands**:

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in context window by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/agents` | Configured subagents |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics, schema errors, installation health |
| `/status` | Active settings sources, managed settings status |

**Common config problems**:

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use single string with `\|`: `"Edit\|Write"` |
| Hook never fires | `matcher` is lowercase (`"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks in standalone `hooks.json` file | Define under `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Config in `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Settings value ignored | Same key in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill not in `/skills` | Skill at `.claude/skills/name.md` (file, not folder) | Use folder: `.claude/skills/name/SKILL.md` |
| Skill appears but Claude never invokes it | `disable-model-invocation: true` or description mismatch | Check badge in `/skills` for "user-only" label |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loads only when Claude reads a file there with Read tool |
| MCP servers in `.mcp.json` not loading | File under `.claude/` or wrong format | Repo root as `.mcp.json`, not inside `.claude/` |
| MCP server added but missing | One-time approval dismissed | Run `/mcp` to approve |
| MCP server missing env vars | `settings.json` `env` doesn't propagate to MCP | Set per-server `env` inside `.mcp.json` |
| `Bash(rm *)` deny rule not blocking all variants | Prefix rules match literal command string only | Add explicit patterns per variant, or use PreToolUse hook |

**Settings precedence**: managed > local > project > user. Environment variables and `--flags` are additional override layers. Run `/doctor` to validate; `/status` to see active sources.

### Installation Troubleshooting Quick Reference

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; source shell config |
| Install script returns HTML | Regional restriction or network issue; try Homebrew/WinGet |
| `curl: (56) Failure writing output` | Network instability; retry; use Homebrew/WinGet |
| `Killed` during install (Linux) | OOM; add 2GB swap; need 4GB RAM minimum |
| TLS/SSL errors | `NODE_EXTRA_CA_CERTS=/path/to/ca.pem`; update CA certs |
| `Error loading shared library` | musl/glibc mismatch; `apk add libgcc libstdc++ ripgrep` on Alpine |
| `Illegal instruction` | CPU lacks AVX or architecture mismatch |
| `dyld: cannot load` on macOS | macOS 13.0+ required |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `403 Forbidden` after login | Check subscription at claude.ai/settings; confirm "Claude Code" role in Console |
| Organization disabled | Unset stale `ANTHROPIC_API_KEY` from shell profile |
| OAuth fails in WSL2/SSH/containers | Paste the browser code at the terminal prompt; use `claude auth login` |
| Bedrock/Vertex/Foundry credentials not loading | `aws sts get-caller-identity`; `gcloud auth application-default login`; `az login` |

**Install locations**: `~/.local/bin/claude` (macOS/Linux native), `%USERPROFILE%\.local\bin\claude.exe` (Windows).

**Conflicting installs**: check `which -a claude`; remove extras with `npm uninstall -g @anthropic-ai/claude-code` or `brew uninstall --cask claude-code`.

### Changelog and What's New

The changelog is generated from GitHub. Run `claude --version` to check your installed version.

**Recent highlights**:
- **v2.1.129** (May 6, 2026): `--plugin-url` flag for zip plugin archives, `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` for auto-updates, `skillOverrides` setting, `claude_code.pull_request.count` now counts MCP-created PRs
- **v2.1.128** (May 4, 2026): `/mcp` shows tool count, `--plugin-dir` accepts `.zip` archives, `--channels` works with console auth
- **v2.1.126** (May 1, 2026): `claude project purge` command, `claude auth login` accepts pasted OAuth codes, `claude_code.skill_activated` OTel event with `invocation_trigger`
- **Week 17** (Apr 20–24): `/ultrareview` public research preview (cloud agent fleet for bug hunting), session recap, custom themes
- **Week 16** (Apr 13–17): Claude Opus 4.7 as default on Max/Team Premium, `xhigh` effort level, Routines on web, native binaries
- **Week 15** (Apr 6–10): Ultraplan cloud planning preview, Monitor tool for live log tailing, `/loop` self-pacing
- **Week 14** (Mar 30–Apr 3): Computer use research preview in CLI, `/powerup` lessons
- **Week 13** (Mar 23–27): Auto mode research preview (classifier handles permission prompts)

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — dashboards for Teams/Enterprise and API customers, contribution metrics setup, GitHub integration, PR attribution, leaderboard, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — `/usage` command, workspace spend limits, rate limit recommendations, agent team costs, context management strategies, model selection, MCP overhead reduction, subagents, extended thinking tuning
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — full OTel configuration, all metrics and events with attributes, distributed traces (beta), span hierarchy, dynamic headers, multi-team support, SIEM integration, security/privacy controls
- [Error reference](references/claude-code-errors.md) — every runtime error message with recovery steps, automatic retry behavior, response quality troubleshooting
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance/stability issues, high CPU/memory, auto-compact thrashing, hangs, search problems, ripgrep setup
- [Debug your configuration](references/claude-code-debug-your-config.md) — diagnostic commands, settings precedence, MCP server debugging, hook debugging, common config mistakes table
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH issues, install failures, TLS errors, Windows-specific issues, WSL issues, auth errors, Bedrock/Vertex/Foundry credentials
- [Changelog](references/claude-code-changelog.md) — full release notes by version number
- [What's new index](references/claude-code-whats-new-index.md) — weekly feature digests with links
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, PowerShell tool, conditional hooks
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, `/powerup`, MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop` self-pacing, `/team-onboarding`
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, `xhigh` effort, Routines on web, `/ultrareview`, native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview` public preview, session recap, custom themes, Claude Code on the web redesign

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
