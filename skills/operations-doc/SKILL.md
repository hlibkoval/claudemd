---
name: operations-doc
description: Complete official documentation for Claude Code operations — analytics dashboards (Team/Enterprise and API), cost tracking and reduction strategies, OpenTelemetry monitoring (metrics, events, traces, span attributes), error reference (server errors, usage limits, authentication errors, network errors, request errors), troubleshooting performance and stability, debug configuration (CLAUDE.md, settings, hooks, MCP, skills), installation troubleshooting (PATH, auth, platform issues), changelog, and weekly what's-new digests.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for Claude Code operations: analytics, cost management, OpenTelemetry monitoring, error reference, troubleshooting, configuration debugging, and release notes.

## Quick Reference

### Analytics Dashboards

| Plan | Dashboard URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage, spend, per-user insights |

**Enabling contribution metrics (Teams/Enterprise):**
1. GitHub admin installs the Claude GitHub app at github.com/apps/claude
2. Owner enables "Claude Code analytics" at claude.ai/admin-settings/claude-code
3. Enable "GitHub analytics" toggle and complete GitHub auth

**Key summary metrics:**
- **PRs with CC** — merged PRs with at least one Claude Code-assisted line
- **Lines of code with CC** — effective lines (>3 chars, non-trivial) written with Claude Code
- **Suggestion accept rate** — % of Edit/Write/NotebookEdit suggestions accepted
- **Lines of code accepted** — accepted lines (excludes rejected; does not track deletions)

**PR attribution:** Sessions from 21 days before to 2 days after merge are considered. Code substantially rewritten by developers (>20% diff) is not attributed. Auto-generated files (lock files, build artifacts, minified files) are excluded.

---

### Cost Management

**Average enterprise cost:** ~$13/developer/active day; ~$150–250/developer/month; 90% of users stay below $30/active day.

**Track costs:** run `/usage` for session estimates. For authoritative billing, see the Claude Console Usage page.

**Rate limit recommendations by team size:**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Reduce token usage — key strategies:**

| Strategy | How |
| :--- | :--- |
| Clear between tasks | `/clear` between unrelated tasks; `/compact Focus on X` for targeted summaries |
| Right model | Sonnet for most tasks; Opus for complex reasoning; Haiku for simple subagent tasks (`/model`) |
| Reduce MCP overhead | `/mcp` to disable unused servers; prefer CLI tools over MCP when available |
| Move CLAUDE.md content to skills | Skills load on demand; keep CLAUDE.md under 200 lines |
| Lower extended thinking | `/effort` or `MAX_THINKING_TOKENS=8000` for simpler tasks |
| Use plan mode | Shift+Tab before implementation to avoid expensive re-work |
| Delegate verbose ops to subagents | Verbose output stays in subagent context; only summary returns |

**Agent team costs:** ~7x more tokens than standard sessions (each teammate has its own context window). Use Sonnet for teammates, keep teams small, clean up when done. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Background token usage:** ~$0.04/session for conversation summarization and command processing.

---

### OpenTelemetry Monitoring

**Quick start environment variables:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp        # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp           # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
```

**Key configuration variables:**

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | off | Required to enable telemetry |
| `OTEL_METRICS_EXPORTER` | — | Metrics exporter(s), comma-separated |
| `OTEL_LOGS_EXPORTER` | — | Logs/events exporter(s) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | — | `grpc`, `http/json`, `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | OTLP collector endpoint |
| `OTEL_METRIC_EXPORT_INTERVAL` | 60000ms | Metrics export interval |
| `OTEL_LOGS_EXPORT_INTERVAL` | 5000ms | Logs export interval |
| `OTEL_LOG_USER_PROMPTS` | off | Include prompt text in events |
| `OTEL_LOG_TOOL_DETAILS` | off | Include tool params (Bash cmds, MCP names, skill names) |
| `OTEL_LOG_TOOL_CONTENT` | off | Include tool I/O content in trace spans (60KB truncation) |
| `OTEL_LOG_RAW_API_BODIES` | off | Emit full API request/response bodies (`=1` inline, `=file:<dir>` to disk) |

**Metrics cardinality control:**

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | true | Include `session.id` in metrics |
| `OTEL_METRICS_INCLUDE_VERSION` | false | Include `app.version` in metrics |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | true | Include `user.account_uuid` / `user.account_id` |

**Traces (beta):** Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp`.

Span hierarchy:
```
claude_code.interaction
├── claude_code.llm_request
├── claude_code.hook
└── claude_code.tool
    ├── claude_code.tool.blocked_on_user
    └── claude_code.tool.execution
```

**Exported metrics:**

| Metric | Unit | Notes |
| :--- | :--- | :--- |
| `claude_code.session.count` | count | Session starts; attributes: `start_type` (fresh/resume/continue) |
| `claude_code.lines_of_code.count` | count | Code modifications; attributes: `type` (added/removed) |
| `claude_code.pull_request.count` | count | PRs created via shell or MCP |
| `claude_code.commit.count` | count | Git commits created |
| `claude_code.cost.usage` | USD | Per API request; attributes: `model`, `query_source`, `speed`, `effort`, `agent.name`, `skill.name`, `plugin.name` |
| `claude_code.token.usage` | tokens | Per API request; attributes: `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.code_edit_tool.decision` | count | Edit/Write/NotebookEdit accepts/rejects; attributes: `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | s | Active time; attributes: `type` (user/cli) |

**Standard attributes on all metrics/events:** `session.id`, `app.version`, `organization.id`, `user.account_uuid`, `user.account_id`, `user.id`, `user.email`, `terminal.type`

**Key events exported via logs exporter:**

| Event | When emitted |
| :--- | :--- |
| `claude_code.user_prompt` | User submits a prompt |
| `claude_code.tool_result` | Tool completes execution |
| `claude_code.api_request` | Each API call to Claude |
| `claude_code.api_error` | API call fails (after retries) |
| `claude_code.tool_decision` | Permission decision (accept/reject) |
| `claude_code.permission_mode_changed` | Mode switches (plan/auto/etc.) |
| `claude_code.auth` | `/login` or `/logout` completes |
| `claude_code.mcp_server_connection` | MCP server connects/disconnects/fails |
| `claude_code.plugin_installed` / `plugin_loaded` | Plugin events |
| `claude_code.skill_activated` | Skill invoked |
| `claude_code.compaction` | Conversation compacted |
| `claude_code.hook_registered` / `hook_execution_start` / `hook_execution_complete` | Hook lifecycle |
| `claude_code.feedback_survey` | Survey shown or answered |
| `claude_code.api_retries_exhausted` | Request exhausted all retries |

**Tool decision sources:** `config`, `hook`, `user_permanent`, `user_temporary`, `user_abort`, `user_reject`

**Dynamic headers (for token refresh):** set `otelHeadersHelper` in `.claude/settings.json` to a script path (outputs JSON headers). Runs every 29 minutes (configure with `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS`). Only for `http/protobuf` and `http/json` protocols.

**Multi-team attributes:**
```bash
export OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform,cost_center=eng-123"
```
No spaces in values; use underscores or percent-encoding.

**Service resource attributes:** `service.name=claude-code`, `service.version`, `os.type`, `os.version`, `host.arch`

---

### Error Reference

**Automatic retries:** transient server errors, 529 overloaded, timeouts, and 429 throttles are retried up to 10 times with exponential backoff. Spinner shows `Retrying in Ns · attempt x/y`. Tune with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000ms).

**Error lookup:**

| Error message | Category | Quick fix |
| :--- | :--- | :--- |
| `API Error: 500 ... Internal server error` | Server | Check status.claude.com; retry; run `/feedback` |
| `Repeated 529 Overloaded errors` | Server | Check status.claude.com; switch model with `/model` |
| `Request timed out` | Server / Network | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `Auto mode cannot determine safety` | Server | Retry; run `/compact` if context window exceeded |
| `You've hit your session/weekly limit` | Usage limit | Wait for reset; `/usage-credits`; upgrade plan |
| `Server is temporarily limiting requests` | Usage limit | Wait and retry |
| `Request rejected (429)` | Usage limit | Check rate limits; reduce concurrency; check active credential with `/status` |
| `Credit balance is too low` | Usage limit | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | Auth | Run `/login`; check `ANTHROPIC_API_KEY` |
| `Invalid API key` | Auth | Check key in Console; unset stale env vars; run `/status` |
| `This organization has been disabled` | Auth | Unset `ANTHROPIC_API_KEY`; confirm subscription with `/status` |
| `OAuth token revoked / expired` | Auth | Run `/logout` then `/login` |
| `Unable to connect to API` | Network | `curl -I https://api.anthropic.com`; check proxy; set `HTTPS_PROXY` |
| `SSL certificate verification failed` | Network | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `403` with `x-deny-reason: host_not_allowed` | Network (cloud) | Add domain to cloud environment allowlist via cloud icon → settings |
| `Prompt is too long` | Request | `/compact`, `/clear`, `/context` to inspect; disable unused MCP servers |
| `Request too large` | Request | Press Esc×2; reference files by path instead of pasting |
| `Image was too large` | Request | Press Esc×2; resize image (max 8000px single, 2000px multi) |
| `Extra inputs are not permitted` | Request | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Request | Run `/model`; use alias like `sonnet`; check stale `ANTHROPIC_MODEL` env var |
| `API Error: 400 due to tool use concurrency issues` | Request | Run `/rewind` or press Esc×2 to restore to checkpoint |
| Lower quality responses | — | Check `/model`, `/effort`, `/context` fullness; `/compact`; run `/rewind` to retry from before bad turn |

**SIEM integration:** point `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` at your SIEM's OTLP receiver. Key security events: `tool_decision`, `permission_mode_changed`, `auth`, `mcp_server_connection`, `plugin_installed`, `hook_execution_complete`.

---

### Troubleshooting

**Routing guide:**

| Symptom | Go to |
| :--- | :--- |
| `command not found`, PATH, `EACCES`, TLS install errors | Troubleshoot installation and login |
| Login loops, OAuth errors, Bedrock/Vertex/Foundry credentials | Troubleshoot installation and login (login section) |
| Settings not applying, hooks not firing, MCP not loading | Debug your configuration |
| `API Error: 5xx`, `529`, `429`, request validation | Error reference |
| High CPU/memory, hangs, search not finding files | Performance and stability (below) |

**Performance and stability:**
- High CPU/memory: use `/compact` regularly; restart between major tasks; add build dirs to `.gitignore`; run `/heapdump` for heap snapshot
- Auto-compact thrashing (`Autocompact is thrashing`): read large files in smaller chunks; use `/compact keep only the plan`; move large-file work to a subagent
- Hangs: Ctrl+C; restart terminal; `claude --resume` to continue session
- Search not working: install system `ripgrep` (`brew install ripgrep` / `apt install ripgrep`); set `USE_BUILTIN_RIPGREP=0`
- WSL slow search: use more specific searches; move project to Linux filesystem (`/home/`); use native Windows

---

### Debug Your Configuration

**Diagnostic commands:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in context window (system prompt, memory, skills, MCP tools, messages) |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills from all sources |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Configuration diagnostics: invalid keys, schema errors |
| `/debug [issue]` | Enable debug logging; Claude diagnoses from logs |
| `/status` | Active settings sources, whether managed settings apply |

**Settings precedence:** managed (highest) → local → project → user → env vars/flags. Run `/doctor` to validate; `/status` to see active sources.

**MCP troubleshooting:**
- Project-scoped servers in `.mcp.json` require one-time approval — run `/mcp` if dismissed
- Zero tools despite connected: select Reconnect in `/mcp`; run `claude --debug mcp` for stderr
- Relative paths in `command` resolve from directory Claude Code was launched from, not `.mcp.json` location

**Hooks troubleshooting:**
- Matcher must be a string with `|` separator, not an array (`"Edit|Write"` not `["Edit","Write"]`)
- Matching is case-sensitive: `Bash`, `Edit`, `Write`, `Read`
- Hooks go under `"hooks"` key in `settings.json`, not a standalone file
- After editing `settings.json`, changes take effect without restart; wait a few seconds and run `/hooks` to refresh

**Test with clean config:**
```bash
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

**Common configuration traps:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is an array | Use string with `\|` separator |
| Hook never fires | Lowercase tool name (`bash`) | Use `Bash` — case-sensitive |
| Global settings ignored | Config added to `~/.claude.json` | Put `permissions`/`hooks`/`env` in `~/.claude/settings.json` |
| A `settings.json` value ignored | Same key in `settings.local.json` | `settings.local.json` overrides `settings.json` |
| Skill not in `/skills` | File at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| Subdirectory CLAUDE.md ignored | Loads on demand, not at session start | Loaded when Claude reads a file in that dir via Read tool |
| MCP in `.mcp.json` never loads | File inside `.claude/` | Project MCP config goes at repo root as `.mcp.json` |
| MCP env vars missing | Set in `settings.json` env | Set per-server `env` inside `.mcp.json` |

---

### Installation Troubleshooting

**Install locations:**
- macOS/Linux: `~/.local/bin/claude`
- Windows: `%USERPROFILE%\.local\bin\claude.exe`

**Quick diagnostics:**
```bash
# Check network
curl -sI https://downloads.claude.ai/claude-code-releases/latest

# Check PATH
echo $PATH | tr ':' '\n' | grep -Fx "$HOME/.local/bin"

# Add to PATH (zsh)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

# Check multiple installs
which -a claude
npm -g ls @anthropic-ai/claude-code 2>/dev/null
```

**Common installation errors:**

| Error | Fix |
| :--- | :--- |
| `command not found: claude` | Add `~/.local/bin` to PATH; reload shell |
| `syntax error near unexpected token '<'` | Install returned HTML (region blocked); try `brew install --cask claude-code` |
| `curl: (56) Failure writing output` | Network interruption; retry; try Homebrew/WinGet |
| `TLS connect error` / `SSL secure channel` | Update CA certs; set `NODE_EXTRA_CA_CERTS`; try `--cacert` |
| `Killed` on Linux (low memory) | Add 2GB swap (`fallocate -l 2G /swapfile`); need ≥4GB RAM |
| `Error loading shared library` | musl/glibc mismatch; check with `ldd --version`; reinstall |
| `Illegal instruction` | Architecture mismatch or missing AVX; check `uname -m` |
| `dyld: cannot load` on macOS | Requires macOS 13.0+; update macOS |
| `Exec format error` in WSL | WSL1 issue; convert to WSL2: `wsl --set-version <distro> 2` |
| `Could not load credentials from any providers` | Bedrock/Vertex/Foundry not authenticated; run `aws sts get-caller-identity` / `gcloud auth application-default login` / `az login` |
| OAuth error in WSL2/SSH | Paste the login code shown in terminal; set `BROWSER` env var for WSL2 |

**Remove conflicting installs:**
```bash
npm uninstall -g @anthropic-ai/claude-code
rm -rf ~/.claude/local
brew uninstall --cask claude-code        # macOS Homebrew
winget uninstall Anthropic.ClaudeCode    # Windows WinGet
```

**Windows-specific:**
- Requires Git for Windows (Bash) or PowerShell 7; set `CLAUDE_CODE_GIT_BASH_PATH` if not auto-detected
- Use `Windows PowerShell` not `Windows PowerShell (x86)` — 64-bit required
- Claude Desktop may override `claude` command; update Claude Desktop to latest

---

### What's New (Recent Weeks)

| Week | Dates | Highlights |
| :--- | :--- | :--- |
| **Week 20** (v2.1.139–142) | May 11–15, 2026 | `claude agents` dashboard; `/goal` for multi-turn objectives; fast mode on Opus 4.7; Rewind "Summarize up to here" |
| **Week 19** (v2.1.128–136) | May 4–8, 2026 | Plugins from `.zip`/URLs; `worktree.baseRef`; auto mode hard deny rules; hooks see effort level |
| **Week 18** (v2.1.120–126) | Apr 27–May 1, 2026 | Windows without Git Bash (PowerShell as shell); `claude ultrareview`; `claude project purge`; paste PR URL into `/resume` |
| **Week 17** (v2.1.114–119) | Apr 20–24, 2026 | `/ultrareview` research preview; session recap; custom themes; Claude Code on web redesign |
| **Week 16** (v2.1.105–113) | Apr 13–17, 2026 | Claude Opus 4.7 default; `xhigh` effort level; `/effort` slider; Routines; mobile push notifications; native binaries |
| **Week 15** (v2.1.92–101) | Apr 6–10, 2026 | Ultraplan; Monitor tool for streaming background events; `/loop` self-pacing; `/team-onboarding`; `/autofix-pr` |
| **Week 14** (v2.1.86–91) | Mar 30–Apr 3, 2026 | Computer use in CLI (research preview); `/powerup` lessons; per-tool MCP result-size override (500K); plugin executables on PATH |
| **Week 13** (v2.1.83–85) | Mar 23–27, 2026 | Auto mode (research preview); computer use in Desktop; PR auto-fix on Web; transcript search with `/`; conditional `if` hooks |

For all bug fixes and minor improvements, see the full changelog reference.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — usage metrics, contribution metrics, GitHub integration, PR attribution, leaderboard, data export
- [Manage costs effectively](references/claude-code-costs.md) — token tracking, `/usage` command, team spend limits, rate limit recommendations, agent team costs, token reduction strategies
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — metrics, events, traces (beta), span attributes, dynamic headers, SIEM integration, backend considerations
- [Error reference](references/claude-code-errors.md) — server errors, usage limits, authentication errors, network errors, request errors, response quality, reporting errors
- [Troubleshooting](references/claude-code-troubleshooting.md) — high CPU/memory, auto-compact thrashing, hangs, search issues, WSL search performance
- [Debug your configuration](references/claude-code-debug-your-config.md) — CLAUDE.md, settings precedence, MCP debugging, hooks debugging, clean config testing, common configuration traps
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH issues, network errors, platform-specific install problems, authentication, Bedrock/Vertex/Foundry credentials
- [Changelog](references/claude-code-changelog.md) — complete version history with all bug fixes and improvements
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index linking to each week's feature highlights
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use in Desktop, conditional hooks
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use in CLI, MCP result-size override
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop`, `/team-onboarding`
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, `xhigh` effort, Routines, mobile notifications, native binaries
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes
- [What's new: Week 18](references/claude-code-whats-new-2026-w18.md) — Windows without Git Bash, `claude ultrareview`, `claude project purge`
- [What's new: Week 19](references/claude-code-whats-new-2026-w19.md) — plugin zip/URL loading, `worktree.baseRef`, auto mode hard deny, hooks effort level
- [What's new: Week 20](references/claude-code-whats-new-2026-w20.md) — `claude agents` dashboard, `/goal`, fast mode on Opus 4.7

## Sources

- Track team usage with analytics: https://code.claude.com/docs/en/analytics.md
- Manage costs effectively: https://code.claude.com/docs/en/costs.md
- Monitoring with OpenTelemetry: https://code.claude.com/docs/en/monitoring-usage.md
- Error reference: https://code.claude.com/docs/en/errors.md
- Troubleshooting: https://code.claude.com/docs/en/troubleshooting.md
- Debug your configuration: https://code.claude.com/docs/en/debug-your-config.md
- Troubleshoot installation and login: https://code.claude.com/docs/en/troubleshoot-install.md
- Changelog: https://code.claude.com/docs/en/changelog.md
- What's new index: https://code.claude.com/docs/en/whats-new/index.md
- What's new: Week 13: https://code.claude.com/docs/en/whats-new/2026-w13.md
- What's new: Week 14: https://code.claude.com/docs/en/whats-new/2026-w14.md
- What's new: Week 15: https://code.claude.com/docs/en/whats-new/2026-w15.md
- What's new: Week 16: https://code.claude.com/docs/en/whats-new/2026-w16.md
- What's new: Week 17: https://code.claude.com/docs/en/whats-new/2026-w17.md
- What's new: Week 18: https://code.claude.com/docs/en/whats-new/2026-w18.md
- What's new: Week 19: https://code.claude.com/docs/en/whats-new/2026-w19.md
- What's new: Week 20: https://code.claude.com/docs/en/whats-new/2026-w20.md
