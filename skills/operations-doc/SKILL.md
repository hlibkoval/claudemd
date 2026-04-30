---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards, cost management and token budgets, OpenTelemetry monitoring, configuration debugging, troubleshooting performance and stability, installation and login troubleshooting, runtime error reference, changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating and maintaining Claude Code deployments — covering observability, cost control, debugging, error recovery, and release history.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | `claude.ai/analytics/claude-code` | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | `platform.claude.com/claude-code` | Usage, spend, per-user insights |

Contribution metrics require the GitHub app installed at `github.com/apps/claude` and the GitHub analytics toggle enabled at `claude.ai/admin-settings/claude-code`. Data appears within 24 hours; PRs are labeled `claude-code-assisted` in GitHub. Attribution window: 21 days before to 2 days after merge.

### Cost management

| Strategy | Command / Setting |
| :--- | :--- |
| Check session spend | `/usage` |
| Clear stale context | `/clear`, `/compact Focus on X` |
| Switch model | `/model` (use `sonnet` for most tasks, `opus` for complex reasoning) |
| Set effort level | `/effort` or `MAX_THINKING_TOKENS=8000` |
| View context breakdown | `/context` |
| Disable unused MCP servers | `/mcp disable <name>` |

Average enterprise cost: ~$13/developer/active day, $150–250/month. Set workspace spend limits at `platform.claude.com`.

**Rate limit recommendations by team size (TPM / RPM per user):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

### OpenTelemetry monitoring (quick start)

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp       # or: prometheus, console, none
export OTEL_LOGS_EXPORTER=otlp          # or: console, none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

**Key OTel environment variables:**

| Variable | Purpose | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | off |
| `OTEL_METRICS_EXPORTER` | Metrics backend | — |
| `OTEL_LOGS_EXPORTER` | Events/logs backend | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Export interval ms | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs interval ms | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content | off |
| `OTEL_LOG_TOOL_DETAILS` | Include tool parameters | off |
| `OTEL_LOG_TOOL_CONTENT` | Include tool I/O in spans | off |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response bodies | off |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Enable distributed tracing (beta) | off |

**Exported metrics:**

| Metric | Unit | Description |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | Sessions started |
| `claude_code.lines_of_code.count` | count | Lines added/removed |
| `claude_code.pull_request.count` | count | PRs created |
| `claude_code.commit.count` | count | Commits created |
| `claude_code.cost.usage` | USD | API cost per request |
| `claude_code.token.usage` | tokens | Tokens used (input/output/cache) |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accept/reject |
| `claude_code.active_time.total` | s | Active user + CLI time |

**Key OTel events:** `user_prompt`, `tool_result`, `api_request`, `api_error`, `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `compaction`, `skill_activated`, `hook_execution_start`, `hook_execution_complete`

**Traces (beta):** Enable with `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and set `OTEL_TRACES_EXPORTER`. Span hierarchy: `claude_code.interaction` > `claude_code.llm_request` / `claude_code.tool` > `claude_code.tool.blocked_on_user` + `claude_code.tool.execution`.

### Configuration debugging commands

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window |
| `/memory` | Loaded CLAUDE.md and rules files |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics and schema validation |
| `/status` | Active settings sources |

**Common configuration gotchas:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | Lowercase matcher, e.g. `"bash"` | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks in a standalone `.claude/hooks.json` | Hooks go under `"hooks"` key in `settings.json` |
| Settings ignored | Value in `settings.local.json` overrides | `settings.local.json` takes precedence |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use a folder: `.claude/skills/name/SKILL.md` |
| MCP server not loading | `.mcp.json` is under `.claude/` | Project MCP config goes at the repository root |
| Project MCP server missing | Approval prompt was dismissed | Run `/mcp` to approve |

### Runtime error quick reference

| Error message | Category | Fix |
| :--- | :--- | :--- |
| `API Error: 500 Internal server error` | Server | Check status.claude.com; retry; `/feedback` |
| `API Error: Repeated 529 Overloaded errors` | Server | Wait; switch model with `/model` |
| `Request timed out` | Server / Network | Retry; raise `API_TIMEOUT_MS` |
| `You've hit your session limit` | Usage | Wait for reset; run `/extra-usage`; upgrade plan |
| `Request rejected (429)` | Usage | Check credential with `/status`; reduce concurrency |
| `Credit balance is too low` | Usage | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | Run `/login` |
| `Invalid API key` | Auth | Check key; run `/status`; unset stale `ANTHROPIC_API_KEY` |
| `OAuth token revoked` | Auth | Run `/logout` then `/login` |
| `Unable to connect to API` | Network | Check proxy/firewall; set `HTTPS_PROXY` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Request | `/compact`; `/clear`; `/context` to find what's large |
| `Request too large` | Request | Esc twice to remove attachment; reference files by path |
| `Extra inputs are not permitted` | Request | Gateway dropping `anthropic-beta` header; set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | `/model` to pick available model; use alias like `sonnet` |

Automatic retries: Claude Code retries server errors, 529, timeouts, and transient 429s up to 10 times with exponential backoff. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

### Installation troubleshooting quick reference

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH |
| `syntax error near unexpected token '<'` | Install script returned HTML; try Homebrew/WinGet |
| `TLS connect error` | Update CA certs; set `NODE_EXTRA_CA_CERTS` for proxy CA |
| `Killed` during install on Linux | Add 2 GB swap; need 4 GB RAM minimum |
| `Error loading shared library` | Wrong musl/glibc binary; check with `ldd --version` |
| `Illegal instruction` | Architecture mismatch or pre-2013 CPU lacking AVX |
| `OAuth error` / `403 Forbidden` | Reset login: `/logout`, close, reopen, `/login` |
| `Could not load credentials from any providers` | Bedrock: `aws sts get-caller-identity`; Vertex: `gcloud auth application-default login` |

### Performance and stability

| Issue | Solution |
| :--- | :--- |
| High CPU/memory | `/compact` regularly; restart between major tasks; add build dirs to `.gitignore` |
| Memory stays high | `/heapdump` to generate snapshot for Chrome DevTools |
| Auto-compact thrashing | Read large files in chunks; use `/compact keep only X`; move to subagent |
| Command hangs | Ctrl+C; restart terminal; `claude --resume` to recover |
| Search not finding files | Install system `ripgrep`; set `USE_BUILTIN_RIPGREP=0` |
| WSL slow search | Move project to Linux filesystem (`/home/`); use native Windows |

### Recent releases (what's new)

| Week | Highlights |
| :--- | :--- |
| W17 (Apr 20–24, v2.1.114–119) | `/ultrareview` public preview; session recap (`/recap`); custom themes (`/theme`); Claude Code on the web redesign |
| W16 (Apr 13–17, v2.1.105–113) | Claude Opus 4.7 default on Max/Team Premium; `xhigh` effort level; Routines on web; `/ultrareview` cloud review |
| W15 (Apr 6–10, v2.1.92–101) | Ultraplan early preview; Monitor tool for streaming events; `/loop` self-pacing; `/team-onboarding` |
| W14 (Mar 30–Apr 3, v2.1.86–91) | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override up to 500K |
| W13 (Mar 23–27, v2.1.83–85) | Auto mode research preview; PR auto-fix on web; transcript search (`/`); PowerShell tool; conditional `if` hooks |

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — usage metrics, GitHub contribution metrics, attribution, dashboards for Teams/Enterprise and API customers
- [Manage costs effectively](references/claude-code-costs.md) — token tracking, workspace spend limits, rate limit recommendations, cost-reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel configuration, metrics, events, trace spans, dynamic headers, backend guidance
- [Debug your configuration](references/claude-code-debug-your-config.md) — `/context`, `/doctor`, `/hooks`, `/mcp` usage; common configuration mistakes and fixes
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance, stability, auto-compact thrashing, search issues, WSL file system
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH, permissions, TLS, memory, platform-specific issues, OAuth and cloud provider auth
- [Error reference](references/claude-code-errors.md) — all runtime error messages with recovery steps
- [Changelog](references/claude-code-changelog.md) — full version-by-version release history
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest overview (W13–W17)
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use, PR auto-fix, transcript search, PowerShell tool, conditional hooks
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, /powerup, MCP result-size override, plugin executables on PATH
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, /loop self-pacing, /team-onboarding, /autofix-pr
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, Routines, /ultrareview, /usage improvements, native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — /ultrareview public preview, session recap, custom themes, web redesign

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
- What's new: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
