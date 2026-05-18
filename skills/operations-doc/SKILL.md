---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost tracking and reduction, OpenTelemetry monitoring, configuration debugging, troubleshooting, installation and login fixes, runtime error reference, changelog, and weekly feature digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, monitoring, debugging, troubleshooting, error reference, and release notes.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend, per-user insights |

**Key analytics metrics:** lines of code accepted, suggestion accept rate, daily active users, PRs with Claude Code, PRs per user.

**GitHub contribution metrics** (Teams/Enterprise beta): requires installing the GitHub app at github.com/apps/claude and enabling analytics at claude.ai/admin-settings/claude-code. Not available with Zero Data Retention enabled. Data appears within 24 hours with daily updates.

**PR attribution window:** sessions from 21 days before to 2 days after merge date. Code substantially rewritten (>20% diff) is not attributed. Auto-generated files (lock files, dist/, node_modules/) are excluded.

---

### Cost Management

**Average cost:** ~$13 per developer per active day; $150–250/month; 90% of users stay under $30/active day.

**Check usage:** `/usage` shows session token stats. Authoritative billing: platform.claude.com/usage.

**Team rate limits (TPM per user recommendations):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Agent teams** use ~7x more tokens than standard sessions (each teammate has its own context window). Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Token reduction strategies:**

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` + `/rename` first, then `/resume` to return |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Right model | Sonnet for most tasks; Opus for complex reasoning; `/model` to switch |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools (gh, aws) |
| Code intelligence plugins | Precise symbol navigation reduces grep + multi-file reads |
| Hooks for preprocessing | Filter large log files to errors before Claude sees them |
| Move bulk CLAUDE.md to skills | Skills load on-demand; keep CLAUDE.md under 200 lines |
| Adjust extended thinking | `/effort` or `MAX_THINKING_TOKENS=8000` for simpler tasks |
| Delegate verbose ops | Use subagents so output stays in their context window |
| Specific prompts | "add input validation to login function in auth.ts" vs "improve codebase" |
| Plan mode | Shift+Tab before implementation to avoid expensive rework |

**Background token usage:** ~$0.04/session for summarization and command processing.

---

### OpenTelemetry Monitoring

**Enable telemetry:**
```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable | off |
| `OTEL_METRICS_EXPORTER` | Metrics backend | — |
| `OTEL_LOGS_EXPORTER` | Events/logs backend | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval ms | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval ms | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Include tool params/commands | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Include tool I/O in spans | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Full API request/response bodies | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | user.account_uuid in metrics | true |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Enable distributed traces | off |
| `OTEL_TRACES_EXPORTER` | Traces backend | — |

**Traces (beta):** set both `CLAUDE_CODE_ENABLE_TELEMETRY=1` and `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`. Span hierarchy: `claude_code.interaction` → `claude_code.llm_request`, `claude_code.tool` (→ `claude_code.tool.blocked_on_user`, `claude_code.tool.execution`).

**Available metrics:**

| Metric | Unit | Description |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | Sessions started |
| `claude_code.lines_of_code.count` | count | Lines modified |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Session cost |
| `claude_code.token.usage` | tokens | Tokens used |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit decisions |
| `claude_code.active_time.total` | s | Active time |

**Key events** (via `OTEL_LOGS_EXPORTER`): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.plugin_installed`, `claude_code.plugin_loaded`, `claude_code.skill_activated`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`.

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

**Multi-team segmentation:**
```
OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"
```
No spaces allowed in values; use underscores or percent-encoding.

**Dynamic headers** (`http/protobuf` and `http/json` only): configure `otelHeadersHelper` in `.claude/settings.json` pointing to a script that outputs JSON key-value headers. Refreshes every 29 minutes (`CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Service resource attributes:** `service.name=claude-code`, `os.type`, `os.version`, `host.arch`.

---

### Debug Your Configuration

**Primary diagnostic commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics, invalid keys, schema errors |
| `/debug [issue]` | Enable debug logging and diagnose with log output |
| `/status` | Active settings sources, managed settings status |

**Settings scope precedence** (highest wins): managed policy → local (`settings.local.json`) → project (`settings.json`) → user (`~/.claude/settings.json`). CLI flags and env vars can override further.

**Clean config test:** `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude` — bypasses all user/project settings (managed settings still apply).

**Common configuration gotchas:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | `matcher` is lowercase (e.g. `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks defined in a standalone file | Hooks go under `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Added to `~/.claude.json` | App state file — use `~/.claude/settings.json` instead |
| `settings.json` value ignored | Overridden by `settings.local.json` | local overrides project overrides user |
| Skill not in `/skills` | Skill file at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP `.mcp.json` not loading | File is under `.claude/` | Project MCP config goes at repository root as `.mcp.json` |
| `mcpServers` in `settings.json` ignored | Wrong key location | Use `.mcp.json` or `claude mcp add --scope user` |
| MCP server not providing tools | One-time approval not completed | Run `/mcp` to approve |

---

### Troubleshooting (Runtime)

**Issue routing:**

| Symptom | Go to |
| :--- | :--- |
| `command not found`, install fails, PATH, `EACCES`, TLS errors | Troubleshoot installation |
| Login loops, OAuth errors, `403 Forbidden`, Bedrock/Vertex credentials | Troubleshoot installation → login section |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529`, `429`, validation errors | Error reference |
| `model not found` or no access | Error reference |

**Performance issues:**
- High CPU/memory: use `/compact` regularly; add build dirs to `.gitignore`; run `/heapdump` for a heap snapshot
- Auto-compact thrashing (`Autocompact is thrashing...`): read large files in chunks; `/compact` with a focus; move to subagent; `/clear`
- Command hangs: Ctrl+C to cancel; `claude --resume` in same directory to recover
- Search not finding files: install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`
- Slow search on WSL: use more specific searches; move project to Linux filesystem (`/home/`); use native Windows

**Run `/doctor`** for automated diagnostics on installation health, settings, MCP, and context.

---

### Installation & Login Troubleshooting

**Install locations:**
- macOS/Linux: `~/.local/bin/claude`
- Windows: `%USERPROFILE%\.local\bin\claude.exe`

**Check PATH:** `echo $PATH | tr ':' '\n' | grep -Fx "$HOME/.local/bin"` (macOS/Linux)

**Common installation errors:**

| Error | Solution |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; source shell config or restart terminal |
| Install script returns HTML | Regional restriction or network issue; try Homebrew (`brew install --cask claude-code`) or WinGet (`winget install Anthropic.ClaudeCode`) |
| `curl: (56) Failure writing output` | Network interruption; retry or use alternative installer |
| TLS/SSL errors | Update CA certs; `NODE_EXTRA_CA_CERTS=/path/to/ca.pem` for corporate proxy |
| Install `Killed` on Linux | OOM killer — add 2 GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| Docker install hangs | Set `WORKDIR /tmp` before installer; increase memory limits |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <DistroName> 2` |
| `Illegal instruction` | Pre-2013 CPU missing AVX; no workaround for native binary |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; update macOS |
| `Error loading shared library` on Linux | musl/glibc mismatch; check with `ldd --version`; on Alpine: `apk add libgcc libstdc++ ripgrep` |

**Multiple installations:** check with `which -a claude`. Remove npm global install: `npm uninstall -g @anthropic-ai/claude-code`. Remove Homebrew: `brew uninstall --cask claude-code`.

**Login issues:**

| Issue | Fix |
| :--- | :--- |
| OAuth error: Invalid code | Retry quickly after browser opens; press `c` to copy URL |
| `403 Forbidden` | Verify subscription active; confirm "Claude Code" role in Console |
| `This organization has been disabled` | `ANTHROPIC_API_KEY` env var from old org is overriding; `unset ANTHROPIC_API_KEY` |
| OAuth fails in WSL2/SSH | Paste the login code shown in the terminal at the `Paste code here` prompt |
| Token expired | Run `/login`; check system clock accuracy |
| Bedrock credentials not loading | `aws sts get-caller-identity` to test; confirm profile is active |
| Vertex credentials not loading | `gcloud auth application-default login`; set `ANTHROPIC_VERTEX_PROJECT_ID` and `CLOUD_ML_REGION` |
| Foundry credentials not loading | Set `ANTHROPIC_FOUNDRY_API_KEY` or `az login` |

---

### Error Reference

**Automatic retries:** up to 10 times with exponential backoff for server errors, overloaded, timeouts, and 429s. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

**Error quick lookup:**

| Error | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server | Check status.claude.com; retry; `/feedback` |
| `API Error: Repeated 529 Overloaded` | Server | Check status.claude.com; retry; `/model` to switch models |
| `Request timed out` | Server/Network | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `You've hit your session/weekly limit` | Usage | Wait for reset shown in error; `/usage`; `/extra-usage`; upgrade plan |
| `Server is temporarily limiting requests` | Usage | Wait briefly; auto-retried before showing |
| `Request rejected (429)` | Usage | Check rate limits in provider console; reduce concurrency |
| `Credit balance is too low` | Usage | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | `/login` |
| `Invalid API key` | Auth | Check `ANTHROPIC_API_KEY`; check for stale `.env` files |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY` |
| `OAuth token revoked/expired` | Auth | `/logout` then `/login` |
| `Unable to connect to API` | Network | Check internet; set `HTTPS_PROXY`; allow api.anthropic.com in firewall |
| `SSL certificate verification failed` | Network | `NODE_EXTRA_CA_CERTS=/path/to/ca.pem` |
| `403` with `x-deny-reason: host_not_allowed` | Network | Cloud session network policy; update environment allowlist |
| `Prompt is too long` | Request | `/compact`; `/clear`; disable unused MCP servers; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Request | Press Esc twice to step back; `/clear` |
| `Request too large` (>30 MB) | Request | Press Esc twice; reference files by path instead of pasting |
| `Image was too large` | Request | Press Esc twice; resize to max 8000px longest edge |
| `Extra inputs are not permitted` | Request | Gateway is stripping `anthropic-beta` header; configure gateway to forward it; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | `/model` to pick available model; use aliases (`sonnet`, `opus`) |
| `Claude Opus is not available with the Claude Pro plan` | Request | `/model` to select available model; `/logout` then `/login` if recently upgraded |
| `thinking.type.enabled is not supported` | Request | `claude update` to v2.1.111+; or switch to Opus 4.6/Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Request | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` or press Esc twice to step back to a checkpoint |

**Quality seems off (no error):** check `/model` (correct model?), `/effort` (reasoning level?), `/context` (window full?), CLAUDE.md size. Rewind with `/rewind` or Esc×2 rather than correcting in-thread.

---

### Release Notes Index (Weekly Digests)

| Week | Dates | Versions | Headline |
| :--- | :--- | :--- | :--- |
| 19 | May 4–8, 2026 | v2.1.128–136 | Plugins from `.zip` archives and URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see active effort level |
| 18 | Apr 27–May 1, 2026 | v2.1.120–126 | Windows without Git Bash (PowerShell as shell tool); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume` |
| 17 | Apr 20–24, 2026 | v2.1.114–119 | `/ultrareview` public research preview; session recap; custom themes; Claude Code on the web redesign |
| 16 | Apr 13–17, 2026 | v2.1.105–113 | Claude Opus 4.7 as new default; `xhigh` effort level; Routines on web; mobile push notifications; CLI native binaries |
| 15 | Apr 6–10, 2026 | v2.1.92–101 | Ultraplan early preview (cloud plan editor); Monitor tool for streaming events; `/loop` self-pacing |
| 14 | Mar 30–Apr 3, 2026 | v2.1.86–91 | Computer use in CLI (research preview); `/powerup` interactive lessons; per-tool MCP result-size override |
| 13 | Mar 23–27, 2026 | v2.1.83–85 | Auto mode research preview; computer use in Desktop; PR auto-fix on web; native PowerShell tool; conditional `if` hooks |

For full per-version changes, see the [changelog reference](references/claude-code-changelog.md).

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — team analytics dashboards, GitHub contribution metrics setup, PR attribution, adoption and ROI measurement
- [Costs](references/claude-code-costs.md) — cost tracking with `/usage`, team spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, all configuration variables, available metrics and events schemas, traces (beta), security/audit use cases
- [Debug your config](references/claude-code-debug-your-config.md) — diagnostic commands, settings scope resolution, MCP debugging, hook debugging, common configuration gotchas
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance and stability issues, auto-compact thrashing, search problems, WSL issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — installation errors by error message, PATH setup, conflicting installs, TLS/SSL, login and OAuth failures, Bedrock/Vertex/Foundry credentials
- [Error reference](references/claude-code-errors.md) — runtime error messages with recovery steps, automatic retry behavior, response quality checks
- [Changelog](references/claude-code-changelog.md) — full per-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — weekly feature digest index with highlights
- [Week 13 digest](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use, PowerShell tool, conditional hooks
- [Week 14 digest](references/claude-code-whats-new-2026-w14.md) — computer use CLI, /powerup, MCP result-size override
- [Week 15 digest](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop
- [Week 16 digest](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile notifications
- [Week 17 digest](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes
- [Week 18 digest](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview CLI, project purge
- [Week 19 digest](references/claude-code-whats-new-2026-w19.md) — plugins from .zip/URL, history search, worktree.baseRef, hard deny rules

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your config: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- Week 13 digest: https://code.claude.com/docs/en/whats-new/2026-w13.md
- Week 14 digest: https://code.claude.com/docs/en/whats-new/2026-w14.md
- Week 15 digest: https://code.claude.com/docs/en/whats-new/2026-w15.md
- Week 16 digest: https://code.claude.com/docs/en/whats-new/2026-w16.md
- Week 17 digest: https://code.claude.com/docs/en/whats-new/2026-w17.md
- Week 18 digest: https://code.claude.com/docs/en/whats-new/2026-w18.md
- Week 19 digest: https://code.claude.com/docs/en/whats-new/2026-w19.md
