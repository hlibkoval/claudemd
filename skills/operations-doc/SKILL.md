---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards, cost management, OpenTelemetry monitoring, configuration debugging, troubleshooting installation and runtime issues, error reference, changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for running, monitoring, debugging, and maintaining Claude Code in individual and organizational deployments.

## Quick Reference

### Analytics dashboards

| Plan | Dashboard URL | Includes |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, GitHub contribution metrics, leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, per-user team insights |

Contribution metrics require installing the GitHub app at github.com/apps/claude and enabling GitHub analytics in admin settings. Data appears within 24 hours and updates daily. Not available with Zero Data Retention enabled.

**Attribution rules:** PRs tagged `claude-code-assisted` when they contain at least one Claude Code-assisted line. Session window is 21 days before to 2 days after merge. Code rewritten more than 20% by developers is not attributed. Auto-generated files (lock files, dist/, build/, node_modules/) are excluded.

**Console dashboard metrics:** lines of code accepted, suggestion accept rate, daily active users/sessions, spend per user (estimates — use billing page for authoritative costs).

### Cost management

**Average API costs:** ~$13/developer/active day; $150–250/developer/month; 90th percentile under $30/active day.

**Check session cost:** `/usage` (dollar figure is a local estimate, not billing-authoritative).

**Team rate limit recommendations (TPM/RPM per user):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Reduce token usage:**

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear`; use `/rename` first so you can `/resume` later |
| Custom compaction | `/compact Focus on code samples and API usage` |
| Right-size model | `/model` — Sonnet for most tasks, Opus for complex reasoning, Haiku for subagents |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools (gh, aws, gcloud) over MCP |
| Move to skills | Keep CLAUDE.md under 200 lines; move workflow instructions into skills (load on-demand) |
| Reduce extended thinking | `/effort` to lower level; set `MAX_THINKING_TOKENS=8000`; or disable in `/config` |
| Subagents for verbose ops | Delegate log processing, test runs, doc fetches — verbose output stays in subagent context |
| Specific prompts | "add input validation to login function in auth.ts" not "improve this codebase" |
| Plan mode | Shift+Tab before implementation to explore and approve an approach |
| Delegate to hooks | PreToolUse hooks can filter/preprocess data before Claude sees it |

**Agent teams token cost:** ~7x more tokens than standard sessions (each teammate has its own context window). Use Sonnet for teammates, keep teams small, clean up when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Background token usage:** conversation summarization and some commands use a small amount of tokens even when idle (typically under $0.04/session).

### OpenTelemetry monitoring (quick start)

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

**Key OTel environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Required to enable telemetry | (off) |
| `OTEL_METRICS_EXPORTER` | Metrics exporter: `otlp`, `prometheus`, `console`, `none` | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter: `otlp`, `console`, `none` | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `grpc`, `http/json`, `http/protobuf` | — |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Include prompt content in events | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Include tool parameters/commands in events | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in trace spans | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Emit full API request/response JSON | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user.account_uuid in metrics | true |
| `OTEL_METRICS_INCLUDE_VERSION` | Include app.version in metrics | false |

**Traces (beta):** set `CLAUDE_CODE_ENABLE_TELEMETRY=1`, `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`, and `OTEL_TRACES_EXPORTER`.

**Span hierarchy:**
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

**Available metrics:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines of code modified | count |
| `claude_code.pull_request.count` | Pull requests created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used (by type: input/output/cacheRead/cacheCreation) | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit permission decisions | count |
| `claude_code.active_time.total` | Active time (user + cli) | s |

**Available log events:** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.api_request_body`, `claude_code.api_response_body`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.internal_error`, `claude_code.plugin_installed`, `claude_code.skill_activated`, `claude_code.api_retries_exhausted`, `claude_code.hook_execution_start`, `claude_code.hook_execution_complete`, `claude_code.compaction`.

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`. Events also include `prompt.id` (for correlating all events from one user prompt).

**Multi-team segmentation:** `export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"` (no spaces in values).

**Dynamic headers helper:** configure `"otelHeadersHelper": "/bin/generate_headers.sh"` in `.claude/settings.json`; refreshes every 29 minutes (tunable with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`).

**Service resource attributes:** `service.name: claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`. Meter name: `com.anthropic.claude_code`.

### Configuration debugging

**Inspect what loaded:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from project, user, plugin sources |
| `/hooks` | Active hook configurations |
| `/mcp` | MCP servers and connection status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics (invalid keys, schema errors, install health) |
| `/status` | Active settings sources, managed settings status |

**Common configuration mistakes:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | `matcher` is lowercase (`"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write`, `Read` |
| Hook never fires | Hooks in a standalone `.claude/hooks.json` | Define hooks under `"hooks"` key in `settings.json` |
| Permissions/hooks/env ignored globally | Added to `~/.claude.json` | Use `~/.claude/settings.json` — these are different files |
| A settings.json value seems ignored | Same key set in `settings.local.json` | Local overrides project overrides user settings |
| Skill not in `/skills` | File at `.claude/skills/name.md` not in folder | Must be `.claude/skills/name/SKILL.md` |
| Skill appears but Claude never invokes it | `disable-model-invocation: true` in frontmatter | Check `/skills` for "user-only" badge |
| Subdirectory CLAUDE.md instructions ignored | Subdirectory files load on demand | Load when Claude reads a file there with Read tool, not at launch |
| Subagent ignores CLAUDE.md instructions | Subagents don't always inherit project memory | Put critical rules in the agent file body |
| MCP server in .mcp.json never loads | File is inside `.claude/` or uses Desktop format | Project MCP config goes at repo root as `.mcp.json` |
| Project MCP server added but doesn't appear | One-time approval prompt was dismissed | Run `/mcp` to approve |
| MCP server fails from some directories | Relative path in `command` or `args` | Use absolute paths for local scripts |
| MCP server starts without expected env vars | `settings.json` `env` doesn't propagate to MCP children | Set per-server `env` inside `.mcp.json` |
| `Bash(rm *)` deny rule doesn't block `/bin/rm` | Prefix rules match literal command string | Add explicit patterns; use PreToolUse hook or sandbox for hard guarantees |

**Settings scope precedence (highest to lowest):** managed settings → local (`.claude/settings.local.json`) → project (`.claude/settings.json`) → user (`~/.claude/settings.json`).

### Troubleshooting — installation quick lookup

| What you see | Solution |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` (macOS/Linux) or `%USERPROFILE%\.local\bin` (Windows) to PATH |
| `syntax error near unexpected token '<'` / HTML returned | Network/proxy issue or region block; try Homebrew/winget alternative install |
| `Killed` during install on Linux | OOM killer — add 2 GB swap with `fallocate -l 2G /swapfile` |
| `TLS connect error` / `SSL/TLS secure channel` | Update CA certs; set `NODE_EXTRA_CA_CERTS`; corporate proxy may intercept TLS |
| `Error loading shared library libstdc++.so.6` | musl/glibc mismatch — check `ldd /bin/ls` and reinstall correct variant |
| `Illegal instruction` on Linux | CPU architecture mismatch — check `uname -m` |
| `dyld: cannot load` on macOS | macOS 13.0+ required — check About This Mac |
| Install hangs in Docker | Set `WORKDIR /tmp` before installer; increase Docker memory |
| `node not found` in WSL | WSL using Windows Node — install Node via Linux package manager or nvm |
| Windows Desktop overrides `claude` CLI | Update Claude Desktop to latest version |

**Diagnostic commands:**
- `claude --version` — check installed version
- `which -a claude` — find conflicting installations  
- `ldd $(which claude) | grep "not found"` — check missing Linux shared libraries
- `/doctor` — checks install type, version, search, MCP config, settings schema, keybindings, context warnings

**Authentication troubleshooting:**

| Issue | Fix |
| :--- | :--- |
| Repeated permission prompts | Use `/permissions` to allow specific tools |
| Browser doesn't open at login | Press `c` to copy OAuth URL and open manually |
| `403 Forbidden` after login | Verify subscription is active; confirm Console role has "Claude Code" permission |
| `Model not found` | Check `--model` flag, `ANTHROPIC_MODEL` env var, settings files in that order; use `/model` to pick |
| `OAuth error: Invalid code` | Press Enter quickly after browser opens; use `c` to copy URL in SSH sessions |
| Not logged in / token expired | `/login` to re-auth; check system clock (token validation requires accurate time) |
| macOS Keychain login failure | Run `claude doctor`; `security unlock-keychain ~/Library/Keychains/login.keychain-db` |
| OAuth login fails in WSL2 | Set `BROWSER` env var to Windows browser path, or press `c` to copy URL |

**Performance:**
- High CPU/memory: use `/compact` regularly; close and restart between major tasks
- Auto-compaction thrashing error: read oversized files in smaller chunks; use `/compact keep only X`; move large-file work to a subagent
- Search/`@file` not working: install system `ripgrep` and set `USE_BUILTIN_RIPGREP=0`
- Slow search on WSL: project files should be on Linux filesystem (`/home/`) not Windows filesystem (`/mnt/c/`)

**Configuration file locations:**

| File | Purpose |
| :--- | :--- |
| `~/.claude/settings.json` | User settings (permissions, hooks, model overrides) |
| `.claude/settings.json` | Project settings (source-controlled) |
| `.claude/settings.local.json` | Local project settings (not committed) |
| `~/.claude.json` | Global state (theme, OAuth, MCP servers) |
| `.mcp.json` | Project MCP servers (source-controlled) |

Reset all settings: `rm ~/.claude.json && rm -rf ~/.claude/` (removes all settings, MCP config, and session history).

### Changelog and what's new

- Run `claude --version` to check your installed version
- Run `claude update` to upgrade
- Full changelog at github.com/anthropics/claude-code/blob/main/CHANGELOG.md
- Weekly digests at code.claude.com/docs/en/whats-new/index.md

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — usage dashboards, GitHub contribution metrics, leaderboard, PR attribution, ROI measurement
- [Manage costs effectively](references/claude-code-costs.md) — token tracking, team spend limits, rate limit recommendations, context management strategies, reducing token usage
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel quick start, admin config, all environment variables, metrics, events, traces (beta), dynamic headers, multi-team support, backend recommendations
- [Debug your configuration](references/claude-code-debug-your-config.md) — /context, /doctor, /status, settings precedence, MCP debugging, hook debugging, common causes table
- [Troubleshooting](references/claude-code-troubleshooting.md) — installation issues, PATH fixes, conflicting installs, permission errors, auth issues, performance, IDE integration, WSL2
- [Error reference](references/claude-code-errors.md) — full runtime error index with recovery steps for server, usage limit, auth, network, and request errors
- [Changelog](references/claude-code-changelog.md) — release notes by version
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index
- [What's new: Week 13 (March 23–27, 2026)](references/claude-code-whats-new-2026-w13.md) — auto mode research preview
- [What's new: Week 14 (March 30 – April 3, 2026)](references/claude-code-whats-new-2026-w14.md) — computer use CLI preview, flicker-free rendering
- [What's new: Week 15 (April 6–10, 2026)](references/claude-code-whats-new-2026-w15.md) — Ultraplan preview, Monitor tool, /loop improvements
- [What's new: Week 16 (April 13–17, 2026)](references/claude-code-whats-new-2026-w16.md) — Claude Opus 4.7, xhigh effort, Routines, /ultrareview, native binaries
- [What's new: Week 17 (April 20–24, 2026)](references/claude-code-whats-new-2026-w17.md) — /ultrareview public preview, session recap, custom themes

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new 2026-W13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new 2026-W14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new 2026-W15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new 2026-W16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new 2026-W17: https://code.claude.com/docs/en/whats-new/2026-w17.md
