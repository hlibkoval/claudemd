---
name: operations-doc
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, troubleshooting, and tracking costs with Claude Code — including analytics dashboards, OpenTelemetry telemetry, cost management, error reference, configuration debugging, and weekly release digests.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Key Metrics |
|:-----|:-------------|:------------|
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Lines accepted, PR attribution, DAU, leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Lines accepted, accept rate, spend per user |

Contribution metrics (PR attribution) require GitHub app installation at `github.com/apps/claude` and enablement at `claude.ai/admin-settings/claude-code`. Data appears within 24 hours; not available with Zero Data Retention.

PR attribution window: 21 days before to 2 days after merge. Excluded: auto-generated files, lines over 1,000 chars, code modified >20% after Claude wrote it. Label applied to attributed PRs: `claude-code-assisted`.

### Cost Tracking

| Tool / Command | Purpose |
|:--------------|:--------|
| `/usage` | Current session token usage and cost estimate; plan limits on subscription plans |
| `/usage-credits` | Set monthly spend cap (Pro/Max) or buy additional credits |
| `platform.claude.com/usage` | Authoritative billing data |

Average enterprise cost: ~$13/developer/active day; $150–250/developer/month. 90th percentile stays below $30/active day.

**Rate limit guidelines (API users, per user):**

| Team size | TPM per user | RPM per user |
|:----------|:------------|:------------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**
- `/clear` between unrelated tasks; `/compact Focus on X` for targeted summarization
- `/model` to switch to Sonnet for routine tasks; reserve Opus for complex work
- Move detailed workflow instructions from CLAUDE.md to skills (skills load on demand)
- Delegate verbose operations (log tailing, test runs) to subagents
- Use plan mode (Shift+Tab) before implementation to avoid expensive rework
- Agent teams use ~7x more tokens than standard sessions; keep teams small

### OpenTelemetry (OTel) Setup

**Minimum configuration:**
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # or: prometheus, console
export OTEL_LOGS_EXPORTER=otlp             # optional
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

**Key environment variables:**

| Variable | Purpose | Default |
|:---------|:--------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics destination: `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | Events destination: `otlp`, `console`, `none` | — |
| `OTEL_TRACES_EXPORTER` | Trace spans (beta, requires `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`) | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc`, `http/protobuf`, `http/json` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers: `Authorization=Bearer token` | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics flush interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs flush interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt text in events | off |
| `OTEL_LOG_TOOL_DETAILS` | Include bash commands, MCP/skill names, file paths | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output content in trace spans (60 KB cap) | off |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON (`=1` inline, `=file:<dir>` on disk) | off |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom labels: `dept=eng,team.id=platform` (no spaces) | — |

**Available metrics:**

| Metric | Unit | Description |
|:-------|:-----|:------------|
| `claude_code.session.count` | count | Sessions started |
| `claude_code.token.usage` | tokens | Tokens used (type: input/output/cacheRead/cacheCreation) |
| `claude_code.cost.usage` | USD | Cost per API request |
| `claude_code.lines_of_code.count` | count | Lines added/removed |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept or reject |
| `claude_code.active_time.total` | s | Active time (user vs CLI) |

**Key events (via `OTEL_LOGS_EXPORTER`):** `claude_code.user_prompt`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_result`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.skill_activated`, `claude_code.plugin_loaded`, `claude_code.plugin_installed`, `claude_code.hook_registered`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`, `claude_code.at_mention`, `claude_code.api_retries_exhausted`, `claude_code.feedback_survey`, `claude_code.internal_error`

**`tool_decision` source values:** `config`, `hook`, `user_permanent`, `user_temporary`, `user_abort`, `user_reject`

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

### Configuration Debugging Commands

| Command | Shows |
|:--------|:------|
| `/context` | Everything in the context window, by category |
| `/memory` | Loaded CLAUDE.md and rules files |
| `/skills` | Available skills and their sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics (invalid keys, schema errors) |
| `/status` | Active settings sources |
| `/debug [issue]` | Enable debug logging for the session |

**Test with clean config:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**Common configuration gotchas:**

| Symptom | Cause | Fix |
|:--------|:------|:----|
| Hook never fires | `matcher` is a JSON array | Use string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase matcher (e.g., `"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Permissions/hooks ignored | Added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP servers in `.mcp.json` not loading | File is under `.claude/` | Place `.mcp.json` at repo root |
| Subdirectory CLAUDE.md ignored | Loads on demand (on file Read), not at session start | Expected behavior |
| MCP server not found after approval | One-time approval prompt was dismissed | Run `/mcp` to approve |

### Error Reference

**Server errors (retry automatically up to 10 times):**

| Error | Meaning | Fix |
|:------|:--------|:----|
| `API Error: 500` | Server-side failure | Check status.claude.com; retry |
| `API Error: 529 Overloaded` | Capacity issue | Wait or `/model` to switch |
| `Request timed out` | No response within 10 min | Retry; raise `API_TIMEOUT_MS` for slow networks |

**Usage limit errors:**

| Error | Meaning | Fix |
|:------|:--------|:----|
| `You've hit your session limit` | Plan quota exhausted | Wait for reset or `/usage-credits` |
| `Request rejected (429)` | API rate limit hit | Check `/status`, reduce concurrency |
| `Credit balance is too low` | Console prepaid credits empty | Add credits at platform.claude.com/settings/billing |

**Authentication errors:**

| Error | Fix |
|:------|:----|
| `Not logged in` | `/login` |
| `Invalid API key` | Check `ANTHROPIC_API_KEY`; run `/status` |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell profile |
| `OAuth token revoked/expired` | `/logout` then `/login` |
| `403 Forbidden` | Verify subscription active; check Console role |

**Request errors:**

| Error | Fix |
|:------|:----|
| `Prompt is too long` | `/compact`, `/clear`, or disable unused MCP servers |
| `Extra inputs are not permitted` | Gateway stripping `anthropic-beta` header; see LLM gateway docs |
| `There's an issue with the selected model` | `/model` to pick valid model; check `ANTHROPIC_MODEL` env var |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` (double-Esc) to restore checkpoint |

Retry tuning: `CLAUDE_CODE_MAX_RETRIES` (default 10), `API_TIMEOUT_MS` (default 600000).

### Installation Troubleshooting Quick Reference

| Symptom | Fix |
|:--------|:----|
| `command not found: claude` | Add `~/.local/bin` to PATH; restart terminal |
| Install script returns HTML / 403 | Regional restriction or proxy issue; try `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `Killed` during Linux install | Add 2 GB swap; server needs ≥4 GB RAM |
| TLS / SSL errors | Set `NODE_EXTRA_CA_CERTS`; update CA certs; check corporate proxy |
| `Illegal instruction` | CPU lacks AVX; check architecture with `uname -m` |
| `Exec format error` on WSL1 | Convert to WSL2: `wsl --set-version <Distro> 2` |
| `dyld: cannot load` on macOS | macOS < 13.0; update OS |
| Login loops / `403 Forbidden` | `/logout` then `/login`; verify subscription active |
| Bedrock/Vertex creds not loading | Run `aws sts get-caller-identity` / `gcloud auth application-default login` |

### Recent Releases (What's New)

| Week | Date | Highlights |
|:-----|:-----|:-----------|
| w22 | May 25–29, 2026 | Claude Opus 4.8 (new default on Max/Team/API); dynamic workflows (ultracode keyword); security-guidance plugin; fast mode on Opus 4.8 |
| w21 | May 18–22, 2026 | Auto mode on Pro plan; `/usage` breakdown by skill/plugin/MCP; `/code-review`; background sessions in `/resume` |
| w20 | May 11–15, 2026 | `claude agents` view; `/goal` for multi-turn completion; fast mode on Opus 4.7; Rewind "Summarize up to here" |
| w19 | May 4–8, 2026 | Plugins from `.zip`/URL; `worktree.baseRef`; auto mode hard deny; hooks see `effort.level` |
| w18 | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell shell tool); `claude ultrareview` CLI; `claude project purge`; PR URL in `/resume` |
| w17 | Apr 20–24, 2026 | `/ultrareview` cloud bug-hunting fleet; session recap; custom themes; web redesign |
| w16 | Apr 13–17, 2026 | Claude Opus 4.7 default; `xhigh` effort; Routines on web; mobile push notifications; native CLI binaries |
| w15 | Apr 6–10, 2026 | Ultraplan preview; Monitor tool; `/loop`; `/team-onboarding`; `/autofix-pr` |
| w14 | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview); `/powerup` lessons; 500K MCP result-size override |
| w13 | Mar 23–27, 2026 | Auto mode research preview; computer use in Desktop; transcript search; PowerShell tool; conditional `if` hooks |

See the changelog for every bug fix and minor improvement by version number.

## Full Documentation

For the complete official documentation, see the reference files:

- [Analytics](references/claude-code-analytics.md) — Team/Enterprise and API dashboards, contribution metrics, PR attribution, leaderboard, data export
- [Costs](references/claude-code-costs.md) — Token tracking with `/usage`, team spend limits, rate limit recommendations, agent team costs, context reduction strategies
- [Monitoring Usage](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, all config variables, available metrics and events, span hierarchy (traces beta), audit/SIEM guidance
- [Debug Your Config](references/claude-code-debug-your-config.md) — `/context`, `/doctor`, `/hooks`, `/mcp`, `/status` commands, settings scope resolution, clean-config testing, common gotcha table
- [Troubleshooting](references/claude-code-troubleshooting.md) — High CPU/memory, auto-compact thrashing, command hangs, ripgrep search issues, WSL filesystem performance
- [Troubleshoot Installation and Login](references/claude-code-troubleshoot-install.md) — PATH, TLS, permission errors, Windows-specific issues, WSL, OAuth errors, Bedrock/Vertex/Foundry credentials
- [Error Reference](references/claude-code-errors.md) — Every runtime error with meaning and recovery steps: server, usage limits, auth, network, request errors
- [Changelog](references/claude-code-changelog.md) — Full release notes by version number
- [What's New Index](references/claude-code-whats-new-index.md) — Weekly digest index with one-line summaries per week
- [What's New w13](references/claude-code-whats-new-2026-w13.md) — Week 13 digest (auto mode, computer use, PowerShell tool)
- [What's New w14](references/claude-code-whats-new-2026-w14.md) — Week 14 digest (computer use CLI, /powerup, MCP result size)
- [What's New w15](references/claude-code-whats-new-2026-w15.md) — Week 15 digest (Ultraplan, Monitor tool, /loop)
- [What's New w16](references/claude-code-whats-new-2026-w16.md) — Week 16 digest (Opus 4.7, Routines, native CLI binaries)
- [What's New w17](references/claude-code-whats-new-2026-w17.md) — Week 17 digest (/ultrareview, session recap, custom themes)
- [What's New w18](references/claude-code-whats-new-2026-w18.md) — Week 18 digest (Windows without Git Bash, claude ultrareview)
- [What's New w19](references/claude-code-whats-new-2026-w19.md) — Week 19 digest (plugin ZIP/URL, worktree.baseRef, auto mode hard deny)
- [What's New w20](references/claude-code-whats-new-2026-w20.md) — Week 20 digest (claude agents view, /goal, Rewind summarize)
- [What's New w21](references/claude-code-whats-new-2026-w21.md) — Week 21 digest (auto mode on Pro, /usage breakdown, /code-review)
- [What's New w22](references/claude-code-whats-new-2026-w22.md) — Week 22 digest (Opus 4.8, dynamic workflows, security-guidance plugin)

## Sources

- Analytics: https://code.claude.com/docs/en/analytics.md
- Costs: https://code.claude.com/docs/en/costs.md
- Monitoring Usage: https://code.claude.com/docs/en/monitoring-usage.md
- Debug Your Config: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Troubleshoot Installation and Login: https://code.claude.com/docs/en/troubleshoot-install.md
- Error Reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's New Index: https://code.claude.com/docs/en/whats-new/index.md
- What's New w13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's New w14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's New w15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's New w16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's New w17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's New w18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's New w19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's New w20: https://code.claude.com/docs/en/whats-new/2026-w20.md
- What's New w21: https://code.claude.com/docs/en/whats-new/2026-w21.md
- What's New w22: https://code.claude.com/docs/en/whats-new/2026-w22.md
