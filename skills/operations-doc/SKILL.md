---
name: operations-doc
description: Quick reference for Claude Code operational topics — analytics dashboards, cost management, rate limits, OpenTelemetry monitoring, troubleshooting, and the changelog.
user-invocable: false
---

# Claude Code Operations Reference

## Analytics Dashboards

| Plan | Dashboard | Key Features |
|------|-----------|--------------|
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend, per-user insights |

**Contribution metrics** (Teams/Enterprise, public beta): connects GitHub org to track PR and line attribution. Requires GitHub app + Owner role. Not available with Zero Data Retention.

- PRs labeled `claude-code-assisted` when containing CC-assisted lines
- Attribution window: 21 days before to 2 days after PR merge
- Code rewritten >20% by developer is not attributed to Claude Code
- Auto-excluded: lock files, build artifacts, minified files, lines >1000 chars

## Cost Management

**Typical costs**: ~$6/dev/day avg; ~$100–200/dev/month with Sonnet 4.6.

| Command | Purpose |
|---------|---------|
| `/cost` | Show token usage and cost for current session (API users) |
| `/stats` | View usage patterns (Claude Max/Pro subscribers) |
| `/compact` | Summarize conversation to reduce context |
| `/clear` | Start fresh context (use `/rename` first to preserve session) |
| `/model` | Switch models mid-session |

**Rate limit guidance by team size (TPM per user)**:

| Team size | TPM/user | RPM/user |
|-----------|----------|----------|
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Token reduction strategies**:
- Clear context between unrelated tasks; use `/compact Focus on X` for targeted summarization
- Use Sonnet for most tasks; reserve Opus for complex reasoning
- Disable unused MCP servers (`/mcp`); prefer CLI tools (gh, aws, gcloud) over MCP
- Move specialized CLAUDE.md instructions into skills (load on-demand vs. always in context)
- Use plan mode (Shift+Tab) before implementation; use `/rewind` to undo wrong directions
- Delegate verbose operations (tests, log processing) to subagents
- Lower `MAX_THINKING_TOKENS` or disable thinking for simpler tasks

**Agent team costs**: ~7x more tokens than standard sessions. Keep teams small, tasks focused.

## OpenTelemetry Monitoring

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. All telemetry is opt-in.

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # otlp | prometheus | console
export OTEL_LOGS_EXPORTER=otlp             # otlp | console
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

**Key config variables**:

| Variable | Purpose | Default |
|----------|---------|---------|
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log MCP/skill names in tool events | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid | true |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom team/dept attributes (no spaces) | — |

**Available metrics**: `claude_code.session.count`, `claude_code.lines_of_code.count`, `claude_code.pull_request.count`, `claude_code.commit.count`, `claude_code.cost.usage`, `claude_code.token.usage`, `claude_code.code_edit_tool.decision`, `claude_code.active_time.total`

**Events** (via `OTEL_LOGS_EXPORTER`): `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`. All events share a `prompt.id` UUID for correlation.

## Troubleshooting

**Quick diagnostics**: run `/doctor` — checks install, search, settings validity, MCP errors, keybindings, context warnings.

**Common installation errors**:

| Error | Fix |
|-------|-----|
| `command not found: claude` | Add `~/.local/bin` to PATH |
| Install script returns HTML | Use `brew install --cask claude-code` or `winget install Anthropic.ClaudeCode` |
| `Killed` on Linux install | Need 4GB RAM; add swap: `sudo fallocate -l 2G /swapfile` |
| TLS/SSL errors | Update CA certs; set `NODE_EXTRA_CA_CERTS` for corporate proxies |
| `Illegal instruction` on Linux | Architecture mismatch; verify with `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13+; try Homebrew install |
| `Error loading shared library` | musl/glibc mismatch; check with `ldd /bin/ls` |
| Docker install hangs | Set `WORKDIR /tmp`; increase memory limits |
| WSL `node not found` | Ensure nvm loaded in non-interactive shells |

**Auth issues**:
- Repeated permission prompts: use `/permissions` to allow specific tools permanently
- OAuth broken: `/logout`, restart, re-authenticate
- 403 Forbidden: check subscription/Console role; corporate proxy may interfere

**Windows Git Bash**: set path if not auto-detected:
```json
{ "env": { "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe" } }
```

**Search not working** (ripgrep missing):
```bash
brew install ripgrep        # macOS
sudo apt install ripgrep    # Ubuntu/Debian
apk add ripgrep             # Alpine
```
Then set `USE_BUILTIN_RIPGREP=0`.

Reset all settings: `rm ~/.claude.json && rm -rf ~/.claude/`

## Reference Files

- [claude-code-analytics.md](references/claude-code-analytics.md) — Analytics dashboards, contribution metrics, GitHub integration
- [claude-code-costs.md](references/claude-code-costs.md) — Cost tracking, rate limits, token reduction strategies
- [claude-code-monitoring-usage.md](references/claude-code-monitoring-usage.md) — OpenTelemetry setup, metrics, events
- [claude-code-troubleshooting.md](references/claude-code-troubleshooting.md) — Installation issues, auth problems, IDE integration
- [claude-code-changelog.md](references/claude-code-changelog.md) — Release changelog
