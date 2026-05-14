---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards, cost management, OpenTelemetry monitoring, configuration debugging, troubleshooting performance and stability, installation and login troubleshooting, error reference, changelog, and weekly "What's new" digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, and troubleshooting Claude Code.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Includes |
| :--- | :--- | :--- |
| Claude for Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Claude Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Key contribution metrics (Teams/Enterprise):**

| Metric | Description |
| :--- | :--- |
| PRs with CC | Merged PRs containing at least one Claude Code-assisted line |
| Lines of code with CC | Effective lines (>3 chars, not blank/trivial) written with Claude Code |
| Suggestion accept rate | % of Edit/Write/NotebookEdit suggestions accepted |
| Lines of code accepted | Total lines accepted by users (excludes rejected suggestions) |

- Attribution window: 21 days before to 2 days after PR merge date
- PR attribution: >20% developer rewrite removes Claude Code credit
- Excluded: lock files, generated code, build dirs, test fixtures, lines >1,000 chars
- GitHub app required for contribution metrics; data appears within 24 hours
- Zero Data Retention orgs: contribution metrics unavailable

### Cost Management

**Average costs:** ~$13/developer/active day; ~$150–250/developer/month; 90th percentile under $30/active day.

**Check usage:**

```bash
/usage          # Token usage stats for current session
/clear          # Start fresh context (use /rename first to save session name)
/compact        # Summarize earlier turns; append focus: /compact Focus on code samples
/context        # See context window breakdown by category
```

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 users | 200k–300k | 5–7 |
| 5–20 users | 100k–150k | 2.5–3.5 |
| 20–50 users | 50k–75k | 1.25–1.75 |
| 50–100 users | 25k–35k | 0.62–0.87 |
| 100–500 users | 15k–20k | 0.37–0.47 |
| 500+ users | 10k–15k | 0.25–0.35 |

**Cost reduction strategies:**

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` to drop stale context |
| Custom compaction | `/compact Focus on X` or add compact instructions to CLAUDE.md |
| Model selection | `/model` — use Sonnet for most tasks; reserve Opus for complex reasoning |
| MCP overhead | `/mcp` to disable unused servers; prefer CLI tools (`gh`, `aws`) |
| Skills over CLAUDE.md | Move specialized instructions to skills (on-demand) vs. CLAUDE.md (always loaded) |
| Reduce thinking | `/effort` to lower effort level; set `MAX_THINKING_TOKENS=8000` |
| Subagents for verbose ops | Delegate log processing, test runs; only summary returns to main context |
| Specific prompts | Name files/functions; avoid "improve this codebase" style requests |
| Plan mode | Shift+Tab — explore before implementing; prevent expensive re-work |

**Agent team cost notes:** ~7x token usage vs. standard sessions (each teammate has own context window). Use Sonnet for teammates; keep teams small; clean up when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Background token usage:** ~$0.04/session max for conversation summarization and command processing.

### OpenTelemetry Monitoring

**Quick start:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp             # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

**Key configuration variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry | — |
| `OTEL_METRICS_EXPORTER` | Metrics exporter (otlp, prometheus, console, none) | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter (otlp, console, none) | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol for all signals (grpc, http/json, http/protobuf) | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Enable logging of prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log Bash commands, MCP names, skill names, tool input | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in trace spans (60 KB truncation) | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON (`=1` inline, `=file:<dir>` on disk) | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid in metrics | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version in metrics | false |

**Exported metrics:**

| Metric | Unit | Description |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | CLI sessions started |
| `claude_code.lines_of_code.count` | count | Lines of code modified |
| `claude_code.pull_request.count` | count | Pull requests created |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Cost per API request |
| `claude_code.token.usage` | tokens | Token usage per request |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept/reject decisions |
| `claude_code.active_time.total` | s | Active time (user + cli) |

**Exported events (via `OTEL_LOGS_EXPORTER`):**

| Event Name | When emitted |
| :--- | :--- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.api_request` | API request to Claude |
| `claude_code.api_error` | API request fails |
| `claude_code.api_request_body` | Per-request (when `OTEL_LOG_RAW_API_BODIES` set) |
| `claude_code.api_response_body` | Per-response (when `OTEL_LOG_RAW_API_BODIES` set) |
| `claude_code.tool_decision` | Tool permission decision (accept/reject) |
| `claude_code.permission_mode_changed` | Permission mode changes (Shift+Tab, etc.) |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.mcp_server_connection` | MCP server connects, disconnects, or fails |
| `claude_code.internal_error` | Unexpected internal error |
| `claude_code.plugin_installed` | Plugin finishes installing |
| `claude_code.plugin_loaded` | Plugin enabled at session start |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.at_mention` | `@`-mention resolved in prompt |
| `claude_code.api_retries_exhausted` | API request fails after all retries |
| `claude_code.hook_registered` | Hook active at session start |
| `claude_code.hook_execution_start` | Hooks begin executing |
| `claude_code.hook_execution_complete` | All hooks for event finish |
| `claude_code.compaction` | Conversation compaction completes |
| `claude_code.feedback_survey` | Session quality survey shown or answered |

**Traces (beta):** Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` and `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`, then set `OTEL_TRACES_EXPORTER`. Span hierarchy:

```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook  (requires detailed beta tracing)
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    ├── claude_code.tool.execution
    └── (Task tool) subagent spans
```

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

**Service resource attributes:** `service.name: claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`

**Admin managed-settings configuration:**

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

**SIEM export (events only, full tool detail):**

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

**Multi-team attribute tagging:**

```bash
export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"
# No spaces allowed in values; use percent-encoding for special characters
```

### Debug Your Configuration

**Inspect what loaded:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from project, user, and plugin sources |
| `/agents` | Configured subagents and settings |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules in effect |
| `/doctor` | Configuration diagnostics; invalid keys, schema errors, installation health |
| `/debug [issue]` | Enable debug logging; Claude diagnoses using log output |
| `/status` | Active settings sources, including managed settings |

**Clean test session:**

```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```
Bypasses `~/.claude` and project config. Managed settings still apply.

**Common configuration problems:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array instead of a string | Use `"Edit\|Write"` string with `\|` separator |
| Hook never fires | Matcher is lowercase (`bash`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks defined in standalone file | Define under `"hooks"` key in `settings.json` |
| Global permissions/hooks ignored | Added to `~/.claude.json` not `~/.claude/settings.json` | Use `~/.claude/settings.json` for `permissions`, `hooks`, `env` |
| Settings value seems ignored | Same key in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill not in `/skills` | Skill at `.claude/skills/name.md` (flat file) | Use folder: `.claude/skills/name/SKILL.md` |
| Skill never invoked by Claude | `disable-model-invocation: true` or description mismatch | Check "user-only" badge in `/skills` |
| Subdirectory CLAUDE.md ignored | Subdirectory files load on demand (not at session start) | They load when Claude reads a file in that dir via Read tool |
| Subagent ignores CLAUDE.md | Subagents don't always inherit project memory | Put critical rules in agent file body |
| MCP servers in `.mcp.json` never load | File under `.claude/` or wrong format | `.mcp.json` goes at repository root |
| MCP server fails from some dirs | `command`/`args` uses relative file path | Use absolute paths for local scripts |
| MCP server starts without env vars | `settings.json` `env` doesn't propagate to MCP processes | Set per-server `env` inside `.mcp.json` |
| `Bash(rm *)` deny rule doesn't block `/bin/rm` | Prefix rules match literal command string, not executable | Add explicit patterns; use PreToolUse hook or sandbox |

### Troubleshooting Performance and Stability

| Symptom | Resolution |
| :--- | :--- |
| High CPU/memory | Run `/compact` regularly; restart between major tasks; add build dirs to `.gitignore` |
| Memory stays high | Run `/heapdump` — writes `.heapsnapshot` and breakdown to `~/Desktop` |
| Auto-compaction thrashing | Ask Claude to read oversized file in chunks; run `/compact keep only X`; move to subagent; run `/clear` |
| Command hangs/freezes | Press Ctrl+C; if unresponsive close terminal; run `claude --resume` to recover |
| Search not finding files | Install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0` |
| Slow/incomplete search on WSL | Use specific searches with directory/type filters; move project to `/home/`; use native Windows |

**Get more help:** `/doctor` for automated check; `/feedback` to report to Anthropic; [github.com/anthropics/claude-code](https://github.com/anthropics/claude-code) for known issues.

### Troubleshoot Installation and Login

**Installation error index:**

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; see Verify your PATH |
| `syntax error near unexpected token '<'` (HTML from install script) | Use Homebrew (`brew install --cask claude-code`) or WinGet (`winget install Anthropic.ClaudeCode`) |
| `Killed` during install on Linux | Add swap: `sudo fallocate -l 2G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| TLS/SSL connect errors | Update CA certs; set `NODE_EXTRA_CA_CERTS`; add `--ssl-revoke-best-effort` on Windows |
| `Illegal instruction` | Architecture mismatch or missing AVX; check `uname -m`; track GitHub issue #50384 |
| `Error loading shared library` | musl/glibc binary mismatch; check `ldd --version`; on Alpine: `apk add libgcc libstdc++ ripgrep` |
| `dyld: cannot load` / `Abort trap` (macOS) | Requires macOS 13.0+; update macOS |
| `Exec format error` in WSL1 | Convert to WSL2: `wsl --set-version <DistroName> 2` |
| `The process cannot access the file` (Windows install) | Delete `%USERPROFILE%\.claude\downloads` and retry |
| Install hangs in Docker | Set `WORKDIR /tmp` before installer runs |

**PATH setup:**

```bash
# macOS/Linux (Zsh)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

# macOS/Linux (Bash)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# Verify
claude --version
```

**Check for conflicting installations:**

```bash
which -a claude                              # All claude binaries on PATH
npm -g ls @anthropic-ai/claude-code 2>/dev/null  # npm global install
npm uninstall -g @anthropic-ai/claude-code   # Remove npm global install
rm -rf ~/.claude/local                       # Remove legacy local npm install
```

**Login and authentication issues:**

| Symptom | Fix |
| :--- | :--- |
| OAuth error: Invalid code | Re-run `/login` quickly after browser opens; press `c` to copy URL |
| 403 Forbidden after login | Verify subscription active; confirm "Claude Code" or "Developer" role in Console |
| Organization disabled despite active subscription | Unset `ANTHROPIC_API_KEY` from shell profile; relaunch |
| OAuth in WSL2/SSH/containers | Paste the login code at `Paste code here if prompted`; or `claude auth login` |
| Token expired frequently | Check system clock accuracy; on macOS, run `claude doctor` for Keychain check |
| Bedrock: `Could not load credentials` | Run `aws sts get-caller-identity` to verify credentials |
| Vertex: `Could not load the default credentials` | Set `ANTHROPIC_VERTEX_PROJECT_ID`/`CLOUD_ML_REGION`; run `gcloud auth application-default login` |
| Foundry: `ChainedTokenCredential authentication failed` | Set `ANTHROPIC_FOUNDRY_API_KEY` or run `az login` |

**Clean re-authentication (resolves most login issues):**

1. Run `/logout`
2. Close Claude Code
3. Restart with `claude` and re-authenticate

### Error Reference

**Automatic retries:** Claude Code retries transient failures up to 10 times with exponential backoff. Control with `CLAUDE_CODE_MAX_RETRIES` (default: 10) and `API_TIMEOUT_MS` (default: 600000).

**Server errors (Anthropic infrastructure):**

| Error | Recovery |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Check status.claude.com; wait and retry; run `/feedback` |
| `API Error: Repeated 529 Overloaded errors` | Check status.claude.com; wait a few minutes; switch model with `/model` |
| `Request timed out` | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| Auto mode classifier unavailable | Retry after seconds; read/search/edit in working dir still work |
| Auto mode classifier transcript too long | Run `/compact`; approve/deny in the prompt that appears |

**Usage limits:**

| Error | Recovery |
| :--- | :--- |
| `You've hit your session/weekly limit` | Wait for reset; run `/extra-usage` to buy more; check `/usage` |
| `Request rejected (429)` | Check `/status` for active credential; reduce concurrency with `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing; enable auto-reload |

**Authentication errors:**

| Error | Recovery |
| :--- | :--- |
| `Not logged in` | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported |
| `Invalid API key` | Check for typos; run `env | grep ANTHROPIC`; run `/status` |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell profile |
| `OAuth token revoked or expired` | Run `/login`; if recurring, `/logout` then `/login` |
| `OAuth token does not meet scope requirement` | Run `/login` to mint new token |

**Request errors:**

| Error | Recovery |
| :--- | :--- |
| `Prompt is too long` | Run `/compact` or `/clear`; check `/context`; disable unused MCP servers |
| `Error during compaction: Conversation too long` | Press Esc twice to step back; run `/compact`; or `/clear` |
| `Request too large (max 30 MB)` | Press Esc twice; reference large files by path |
| `Image was too large` | Press Esc twice; resize before pasting (max 8000px single, 2000px with many) |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model`; use alias (`sonnet`, `opus`); check `ANTHROPIC_MODEL` env var |
| `thinking.type.enabled is not supported for this model` | Run `claude update` to v2.1.111+; or switch to Opus 4.6/Sonnet |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` or press Esc twice to restore a checkpoint |

**Response quality (no error shown):** Check model with `/model`, effort with `/effort`, context fill with `/context`, stale instructions with `/doctor`. Rewinding (`/rewind` or Esc twice) works better than correcting in-thread.

### Changelog and What's New

- **Latest version:** 2.1.141 (May 13, 2026). Run `claude --version` to check your version.
- **Changelog:** full per-version release notes at the changelog reference file.
- **What's new weekly digests:** weeks 13–19 (March 23 – May 8, 2026) covering auto mode, computer use, routines, Opus 4.7, ultraplan, ultrareview, plugin ZIP loading, and more.

**Recent highlights (Weeks 13–19, 2026):**

| Week | Highlight |
| :--- | :--- |
| W19 (May 4–8) | Plugins from `.zip` archives and URLs (`--plugin-dir`, `--plugin-url`); Ctrl+R history search across all projects |
| W18 (Apr 27–May 1) | Windows without Git Bash (PowerShell as shell tool); `claude ultrareview` for CI; `/resume` with PR URL |
| W17 (Apr 20–24) | `/ultrareview` public research preview (cloud bug-hunting agent fleet); session recap; custom themes |
| W16 (Apr 13–17) | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort level; Routines on web; mobile push notifications |
| W15 (Apr 6–10) | Ultraplan early preview; Monitor tool for streaming events; `/loop` self-pacing |
| W14 (Mar 30–Apr 3) | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override up to 500K |
| W13 (Mar 23–27) | Auto mode research preview; computer use in Desktop; PR auto-fix on Web; transcript search with `/` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API customers, contribution metrics, GitHub integration, PR attribution, leaderboard, and data export
- [Manage costs effectively](references/claude-code-costs.md) — token tracking, team spend limits, rate limit recommendations, agent team costs, and token reduction strategies
- [Monitoring](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, all configuration variables, available metrics and events, traces (beta), span attributes, security/audit events, and SIEM integration
- [Debug your configuration](references/claude-code-debug-your-config.md) — diagnosing why CLAUDE.md, settings, hooks, MCP servers, or skills aren't taking effect; clean test sessions; common causes table
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, auto-compaction thrashing, hangs, search/discovery issues, and WSL performance
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — command not found, PATH, permissions, TLS errors, Windows install issues, login/OAuth failures, Bedrock/Vertex/Foundry credentials
- [Error reference](references/claude-code-errors.md) — runtime error messages with categories, recovery steps, automatic retries, and response quality troubleshooting
- [Changelog](references/claude-code-changelog.md) — full per-version release notes
- [What's new index](references/claude-code-whats-new-index.md) — weekly digests index (weeks 13–19, 2026)
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use, PR auto-fix, transcript search (v2.1.83–v2.1.85)
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use CLI, `/powerup`, per-tool MCP size override (v2.1.86–v2.1.91)
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — ultraplan, Monitor tool, `/loop` self-pacing (v2.1.92–v2.1.101)
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, mobile push notifications (v2.1.105–v2.1.113)
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview, session recap, custom themes (v2.1.114–v2.1.119)
- [What's new: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, claude ultrareview for CI (v2.1.120–v2.1.126)
- [What's new: Week 19](references/claude-code-whats-new-2026-w19.md) — plugins from .zip/URLs, Ctrl+R cross-project history, worktree.baseRef (v2.1.128–v2.1.136)

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring: https://code.claude.com/docs/en/monitoring-usage.md
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
- What's new Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
