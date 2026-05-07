---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost tracking, OpenTelemetry monitoring, error reference, installation troubleshooting, configuration debugging, changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations, observability, troubleshooting, and release history.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key Metrics |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Lines accepted, accept rate, activity, spend |

Contribution metrics require GitHub app installation at github.com/apps/claude and the GitHub analytics toggle enabled. Data appears within 24 hours of setup. Not available with Zero Data Retention.

**PR Attribution:** PRs tagged `claude-code-assisted` when they contain at least one Claude-assisted line. 21-day session window. Lock files, build artifacts, and minified files are excluded. Code with >20% developer rewrite is not attributed.

### Cost Management

| Strategy | Command / Setting |
| :--- | :--- |
| Check session usage | `/usage` |
| Clear stale context | `/clear` (use `/rename` first, then `/resume` to return) |
| Compact with focus | `/compact Focus on code samples and API usage` |
| Switch model | `/model` (Sonnet for most tasks, Opus for complex reasoning) |
| Check context breakdown | `/context` |
| Adjust thinking budget | `/effort` or `MAX_THINKING_TOKENS=8000` |
| Disable MCP servers | `/mcp disable <name>` |

**Average cost benchmarks:** ~$13/dev/active day; $150–250/dev/month; 90th percentile <$30/active day.

**Agent teams cost:** ~7x more tokens than standard sessions (each teammate runs its own context window). Use Sonnet for teammates; keep teams small and spawn prompts focused.

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

### OpenTelemetry Monitoring

**Required env vars to enable:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp, prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp           # otlp, console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key configuration variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics exporter(s) | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter(s) | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content (default: redacted) | off |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params, Bash commands, MCP names | off |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in trace spans (60 KB cap) | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | off |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid in metrics | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version in metrics | false |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Enable distributed tracing (beta) | off |

**Available metrics:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines of code modified | count |
| `claude_code.pull_request.count` | Pull requests created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost estimate | USD |
| `claude_code.token.usage` | Tokens used | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit permission decisions | count |
| `claude_code.active_time.total` | Active time (excludes idle) | seconds |

**Available events (via `OTEL_LOGS_EXPORTER`):** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_request_body`, `claude_code.api_response_body`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.internal_error`, `claude_code.plugin_installed`, `claude_code.skill_activated`, `claude_code.at_mention`, `claude_code.api_retries_exhausted`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`, `claude_code.compaction`.

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`.

**Traces (beta):** Set `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` / `claude_code.tool.execution`.

**SIEM export example (managed settings):**

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

### Error Reference

**Automatic retries:** Claude Code retries server errors, 529 overload, timeouts, and temporary 429s up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

**Error lookup table:**

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com; retry; `/feedback` |
| `API Error: Repeated 529 Overloaded` | Server | Wait; `/model` to switch to less-loaded model |
| `Request timed out` | Server / Network | Retry; raise `API_TIMEOUT_MS` for slow networks |
| `You've hit your session/weekly limit` | Usage limit | Wait for reset shown in message; `/extra-usage` to buy more |
| `Server is temporarily limiting requests` | Usage limit | Wait briefly and retry |
| `Request rejected (429)` | Usage limit | Check active credential with `/status`; request higher tier; reduce concurrency |
| `Credit balance is too low` | Usage limit | Add credits at platform.claude.com/settings/billing |
| `Not logged in · Please run /login` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check for typos; run `env | grep ANTHROPIC`; use `/status` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY` stale env var |
| `OAuth token revoked / expired` | Auth | Run `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy (`HTTPS_PROXY`); verify firewall allows `api.anthropic.com` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS` to corporate CA bundle |
| `Prompt is too long` | Request | `/compact`, `/clear`, disable unused MCP servers |
| `Error during compaction: Conversation too long` | Request | Press Esc twice, step back, retry `/compact` |
| `Request too large (max 30 MB)` | Request | Press Esc twice; reference large files by path |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | `/model` to pick available model; use alias like `sonnet` not versioned ID |
| `API Error: 400 due to tool use concurrency issues` | Request | `/rewind` or double-press Esc to restore checkpoint |

**Responses seem lower quality:** Check `/model` (correct model?), `/effort` (effort level?), `/context` (window full?), `/doctor` (stale instructions?). Rewind and rephrase rather than correcting in-thread.

### Troubleshooting: Performance & Stability

| Symptom | Fix |
| :--- | :--- |
| High CPU/memory | `/compact` regularly; restart between major tasks; add build dirs to `.gitignore` |
| Memory stays high | `/heapdump` writes snapshot to `~/Desktop` for Chrome DevTools analysis |
| Autocompact thrashing | Read files in smaller chunks; `/compact` with focus; move large-file work to subagent |
| Command hangs | Ctrl+C; restart terminal; `claude --resume` to recover session |
| Search not finding files | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| Slow search on WSL | Work in Linux filesystem (`/home/`), not Windows filesystem (`/mnt/c/`) |

**Symptom routing:**

| Problem | Go to |
| :--- | :--- |
| `command not found`, PATH, EACCES, TLS on install | Troubleshoot installation |
| Login loops, OAuth errors, 403, Bedrock/Vertex credentials | Troubleshoot installation (auth section) |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| API Error 5xx, 529, 429, request validation | Error reference |

### Troubleshoot Installation

**PATH fix (macOS/Linux):**

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
claude --version
```

**Install location:** `~/.local/bin/claude` (macOS/Linux), `%USERPROFILE%\.local\bin\claude.exe` (Windows).

**Common install errors:**

| Error | Fix |
| :--- | :--- |
| Script returns HTML / `syntax error near '<'` | Region not supported; or use Homebrew/WinGet alternative |
| `curl: (56) Failure writing output` | Network interruption; retry; use Homebrew/WinGet |
| TLS / SSL connect error | Update CA certs; set `NODE_EXTRA_CA_CERTS`; use `--cacert` for install |
| `Killed` on Linux (OOM) | Add 2 GB swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| `Illegal instruction` | CPU lacks AVX; or architecture mismatch; check `uname -m` |
| `dyld: cannot load` on macOS | macOS must be 13.0+; update macOS |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <DistroName> 2` |
| `Error loading shared library` (musl/glibc mismatch) | Check `ldd --version`; on Alpine: `apk add libgcc libstdc++ ripgrep` |

**Authentication issues:**

- **OAuth error / Invalid code:** Re-run `/login` quickly after browser opens; press `c` to copy URL for manual paste in SSH/WSL
- **403 Forbidden:** Verify subscription active; confirm account has Developer role in Console
- **Organization disabled with active subscription:** Stale `ANTHROPIC_API_KEY` env var overriding subscription — unset it
- **WSL2 / SSH login:** Paste the code shown in terminal into the `Paste code here if prompted` field; or `claude auth login`
- **Bedrock/Vertex not loading:** Run `aws sts get-caller-identity` / `gcloud auth application-default login` / `az login`

### Debug Your Configuration

**Inspection commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window by category |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics: invalid keys, schema errors |
| `/status` | Active settings sources and managed settings status |

**Common configuration surprises:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase matcher like `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks in standalone `.claude/hooks.json` | Move to `"hooks"` key in `settings.json` |
| Global settings ignored | Config added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Settings value seems ignored | Same key set in `settings.local.json` | Local overrides project overrides user |
| Skill not in `/skills` | Skill file at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loads when Claude reads a file in that dir |
| MCP server `.mcp.json` never loads | File inside `.claude/` or wrong format | Put `.mcp.json` at repository root |
| MCP server starts, no env vars | `settings.json` env doesn't propagate to MCP | Set `env` inside `.mcp.json` per-server |

**Settings scope precedence (highest to lowest):** managed policy → `settings.local.json` (local) → `settings.json` (project) → `~/.claude/settings.json` (user).

### Recent Releases

**Weekly digests (What's New):**

| Week | Dates | Highlights |
| :--- | :--- | :--- |
| Week 17 | April 20–24, 2026 | `/ultrareview` research preview (cloud bug-hunting agents); session recap; custom themes; Claude Code on the web redesign |
| Week 16 | April 13–17, 2026 | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort level; Routines on web; native binaries |
| Week 15 | April 6–10, 2026 | Ultraplan (cloud plan drafting); Monitor tool streams background events; `/loop` self-pacing |
| Week 14 | March 30 – April 3, 2026 | Computer use in CLI (research preview); `/powerup` lessons; flicker-free rendering |
| Week 13 | March 23–27, 2026 | Auto mode (research preview); computer use in Desktop; transcript search; PowerShell tool for Windows |

For full release notes, see [claude-code-changelog.md](references/claude-code-changelog.md). Run `claude --version` to check your installed version.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — usage dashboards, contribution metrics, GitHub integration, PR attribution, and data export
- [Manage costs effectively](references/claude-code-costs.md) — token tracking, team spend limits, rate limit recommendations, and strategies to reduce token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — full OTel config reference, all metrics and events, span attributes, SIEM integration, and security audit guidance
- [Error reference](references/claude-code-errors.md) — complete runtime error lookup with recovery steps for every error code
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, stability, high memory, auto-compact thrashing, and search issues
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, permissions, platform-specific install errors, and authentication failures
- [Debug your configuration](references/claude-code-debug-your-config.md) — diagnose why CLAUDE.md, settings, hooks, MCP servers, or skills aren't taking effect
- [Changelog](references/claude-code-changelog.md) — full release notes by version number
- [What's New index](references/claude-code-whats-new-index.md) — weekly digest index with summaries of each release week
- [What's New: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use, transcript search, PowerShell tool
- [What's New: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, /powerup, flicker-free rendering
- [What's New: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop self-pacing
- [What's New: Week 16](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, xhigh effort, Routines, native binaries
- [What's New: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes, web redesign

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New index: https://code.claude.com/docs/en/whats-new/index.md
- What's New: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
