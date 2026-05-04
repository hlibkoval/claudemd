---
name: operations-doc
description: Complete official documentation for operating Claude Code at scale — analytics dashboards, cost tracking, OpenTelemetry monitoring, configuration debugging, installation troubleshooting, error reference, and release notes.
user-invocable: false
---

# Operations Documentation

This skill provides the complete official documentation for operating, monitoring, and troubleshooting Claude Code.

## Quick Reference

### Analytics Dashboards

| Plan | URL | Features |
| :--- | :--- | :--- |
| Teams / Enterprise | claude.ai/analytics/claude-code | Usage metrics, contribution metrics (GitHub), leaderboard, CSV export |
| API (Console) | platform.claude.com/claude-code | Usage metrics, spend tracking, team insights |

**Enable contribution metrics (Teams/Enterprise):** Install the GitHub app at github.com/apps/claude, then enable analytics and GitHub analytics at claude.ai/admin-settings/claude-code. Data appears within 24 hours; requires no Zero Data Retention policy.

**Key metrics:** PRs with CC, lines of code with CC, suggestion accept rate, lines of code accepted, daily active users/sessions, PRs per user.

**PR attribution window:** Sessions from 21 days before to 2 days after PR merge are considered. Code substantially rewritten (>20% difference) is not attributed. Lock files, build dirs, and generated code are excluded.

### Cost Tracking

```bash
/usage        # Session token usage and estimated cost
/context      # See what's consuming the context window
```

**Average enterprise costs:** ~$13/developer/active day, $150–250/month per developer.

**Team rate limit recommendations (TPM per user):**

| Team size | TPM per user | RPM per user |
| :--- | :--- | :--- |
| 1–5 | 200k–300k | 5–7 |
| 5–20 | 100k–150k | 2.5–3.5 |
| 20–50 | 50k–75k | 1.25–1.75 |
| 50–100 | 25k–35k | 0.62–0.87 |
| 100–500 | 15k–20k | 0.37–0.47 |
| 500+ | 10k–15k | 0.25–0.35 |

**Reduce token usage:**
- `/clear` between unrelated tasks; `/compact Focus on X` to preserve what matters
- Use Sonnet for most tasks; reserve Opus for complex reasoning; specify `model: haiku` in subagents
- Keep CLAUDE.md under 200 lines; move specialized instructions to skills (load on demand)
- Lower `/effort` or set `MAX_THINKING_TOKENS=8000` for simpler tasks
- Use `ENABLE_TOOL_SEARCH` to defer MCP tool definitions
- Delegate verbose operations (logs, tests) to subagents
- Agent teams use ~7x tokens; each teammate has its own context window

### OpenTelemetry Monitoring

**Quick start:**

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp         # otlp | prometheus | console | none
export OTEL_LOGS_EXPORTER=otlp            # otlp | console | none
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"
claude
```

**Key environment variables:**

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (required) | — |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | — |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics export interval (ms) | 60000 |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs export interval (ms) | 5000 |
| `OTEL_LOG_USER_PROMPTS` | Log prompt content | disabled |
| `OTEL_LOG_TOOL_DETAILS` | Log tool params/commands | disabled |
| `OTEL_LOG_TOOL_CONTENT` | Log tool input/output in spans | disabled |
| `OTEL_LOG_RAW_API_BODIES` | Log full API request/response JSON | disabled |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id in metrics | true |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | Include user account IDs | true |

**Enable distributed traces (beta):**

```bash
export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
export OTEL_TRACES_EXPORTER=otlp
```

**Available metrics:**

| Metric | Description | Unit |
| :--- | :--- | :--- |
| `claude_code.session.count` | CLI sessions started | count |
| `claude_code.lines_of_code.count` | Lines modified (added/removed) | count |
| `claude_code.pull_request.count` | PRs created | count |
| `claude_code.commit.count` | Git commits created | count |
| `claude_code.cost.usage` | Session cost | USD |
| `claude_code.token.usage` | Tokens used (input/output/cache) | tokens |
| `claude_code.code_edit_tool.decision` | Edit/Write/NotebookEdit decisions | count |
| `claude_code.active_time.total` | Active time (user + cli) | s |

**Key events:** `claude_code.user_prompt`, `claude_code.tool_result`, `claude_code.api_request`, `claude_code.api_error`, `claude_code.tool_decision`, `claude_code.permission_mode_changed`, `claude_code.auth`, `claude_code.mcp_server_connection`, `claude_code.compaction`, `claude_code.skill_activated`, `claude_code.plugin_installed`.

All events share `session.id`, `organization.id`, `user.account_uuid`, `user.email`, `terminal.type` standard attributes. Events include `prompt.id` for correlating all events from a single user prompt.

**Multi-team segmentation:** `OTEL_RESOURCE_ATTRIBUTES="department=engineering,team.id=platform"` (no spaces in values).

### Debug Configuration

**Inspect what loaded:**

| Command | Shows |
| :--- | :--- |
| `/context` | Everything in the context window |
| `/memory` | Which CLAUDE.md and rules files loaded |
| `/skills` | Available skills |
| `/hooks` | Active hook configurations |
| `/mcp` | Connected MCP servers and status |
| `/permissions` | Resolved allow/deny rules |
| `/doctor` | Config diagnostics, schema errors, install health |
| `/status` | Active settings sources, managed settings status |

**Common configuration issues:**

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Hook never fires | `matcher` is a JSON array | Use a string with `\|`: `"Edit\|Write"` |
| Hook never fires | `matcher` is lowercase (`"bash"`) | Tool names are capitalized: `Bash`, `Edit`, `Write` |
| Hook never fires | Hooks in standalone `.claude/hooks.json` | Define under `"hooks"` key in `settings.json` |
| Global settings ignored | Config added to `~/.claude.json` | Use `~/.claude/settings.json` instead |
| Skill not in `/skills` | Skill at `.claude/skills/name.md` | Use folder: `.claude/skills/name/SKILL.md` |
| MCP server missing | `.mcp.json` inside `.claude/` | Put `.mcp.json` at repo root |
| Project MCP server not loading | One-time approval was dismissed | Run `/mcp` to approve |
| MCP server vars not inherited | Vars in settings `env`, not server config | Set per-server `env` in `.mcp.json` |

### Installation Troubleshooting

**Install locations:**
- macOS/Linux: `~/.local/bin/claude`
- Windows: `%USERPROFILE%\.local\bin\claude.exe`

**Quick diagnostics:**
```bash
claude doctor           # full diagnostic (when claude won't start)
/doctor                 # inside a session
claude --version
```

**Check PATH:**
```bash
# macOS/Linux
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

# Windows PowerShell
$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
[Environment]::SetEnvironmentVariable('PATH', "$currentPath;$env:USERPROFILE\.local\bin", 'User')
```

**Remove conflicting installations:**
```bash
npm uninstall -g @anthropic-ai/claude-code   # remove npm global
rm -rf ~/.claude/local                        # remove legacy local npm
brew uninstall --cask claude-code             # remove Homebrew (macOS)
winget uninstall Anthropic.ClaudeCode         # remove WinGet (Windows)
```

**Low-memory Linux (OOM killed during install):**
```bash
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
curl -fsSL https://claude.ai/install.sh | bash
```

**Alternative installers:**
```bash
brew install --cask claude-code       # macOS
winget install Anthropic.ClaudeCode   # Windows
```

**TLS/SSL errors:** Set `NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem`

**WSL login (browser callback can't reach localhost):** Press `c` to copy OAuth URL, open in local browser, paste the code back into the terminal. Or: `claude auth login` reads code from stdin.

**Bedrock/Vertex/Foundry credentials:**
```bash
aws sts get-caller-identity                   # verify Bedrock creds
gcloud auth application-default login         # set Vertex creds
az login                                      # set Foundry creds
```

### Error Reference

**Automatic retries:** Claude Code retries server errors, 529, timeouts, and 429s up to 10 times with exponential backoff. Control with `CLAUDE_CODE_MAX_RETRIES` (default 10) and `API_TIMEOUT_MS` (default 600000).

**Common errors and recovery:**

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Server-side failure | Check status.claude.com; retry |
| `API Error: 529 Overloaded` | API at capacity | Wait; try `/model` to switch models |
| `You've hit your session/weekly limit` | Plan quota reached | Wait for reset; `/extra-usage` for more; `/usage` to check reset time |
| `Request rejected (429)` | Rate limit hit | Check `/status` for active credential; reduce concurrency |
| `Credit balance is too low` | Console credits exhausted | Add credits at platform.claude.com/settings/billing |
| `Not logged in` | No valid credential | `/login` |
| `Invalid API key` | Key revoked or typo | Check Console; unset `ANTHROPIC_API_KEY` and `/login` |
| `OAuth token revoked/expired` | Token no longer valid | `/login` (or `/logout` then `/login`) |
| `Unable to connect to API` | Network/proxy/firewall | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY` |
| `SSL certificate verification failed` | Corporate TLS interception | `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `Prompt is too long` | Context window full | `/compact` or `/clear`; disable unused MCP servers |
| `Request too large` | HTTP body >30 MB | Escape twice; reference large files by path |
| `Extra inputs are not permitted` | Gateway strips `anthropic-beta` header | Configure gateway to forward header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Unknown/inaccessible model | `/model` to pick available model; use aliases like `sonnet` |
| `API Error: 400 due to tool use concurrency issues` | Corrupt conversation history | `/rewind` or Esc×2 to restore checkpoint |
| `Autocompact is thrashing` | Large file refills context after compact | Read in chunks; `/compact keep only X`; use subagent; `/clear` |

**Lower-quality responses (no error):** Check `/model` (correct model selected?), `/effort` (reasoning level?), `/context` (window near full?), `/doctor` (oversized CLAUDE.md?). Use `/rewind` to step back and rephrase rather than correcting in-thread.

### Version and Release Notes

```bash
claude --version          # check installed version
claude update             # update to latest
```

**Recent highlights (latest first):**
- **v2.1.126 (May 2026):** `claude project purge`, gateway model listing via `/v1/models`, `claude auth login` paste-code fallback, OTel `skill_activated` event with `invocation_trigger`
- **v2.1.121+ (Apr 2026):** `alwaysLoad` MCP option, `claude plugin prune`, PostToolUse hook output replacement for all tools
- **Week 17 (Apr 20–24):** `/ultrareview` public research preview (cloud bug-hunting agents), session recap, custom themes
- **Week 16 (Apr 13–17):** Claude Opus 4.7, `xhigh` effort level, `/effort` slider, Routines on web
- **Week 15 (Apr 6–10):** Ultraplan, Monitor tool for streaming background events, `/autofix-pr`
- **Week 14 (Mar 30–Apr 3):** Computer use in CLI/Desktop (research preview), per-tool MCP result-size override
- **Week 13 (Mar 23–27):** Auto mode research preview, native PowerShell tool, conditional `if` hooks

Full release notes: see [changelog](references/claude-code-changelog.md) and [what's new](references/claude-code-whats-new-index.md) reference files.

## Full Documentation

For the complete official documentation, see the reference files:

- [Track team usage with analytics](references/claude-code-analytics.md) — analytics dashboards for Teams/Enterprise and API customers, contribution metrics setup, PR attribution, GitHub integration, CSV export
- [Manage costs effectively](references/claude-code-costs.md) — token cost tracking with `/usage`, team spend limits, rate limit recommendations, agent team costs, context management, model selection, hooks/skills for cost reduction
- [Monitoring with OpenTelemetry](references/claude-code-monitoring-usage.md) — OTel quick start, all configuration variables, metrics cardinality, distributed traces (beta), span hierarchy, all metrics and events with attributes, security/privacy controls
- [Debug your configuration](references/claude-code-debug-your-config.md) — `/context`, `/doctor`, `/status`, `/hooks`, `/mcp`, `/permissions` commands; common configuration failures and fixes for CLAUDE.md, hooks, MCP, settings, and skills
- [Troubleshooting](references/claude-code-troubleshooting.md) — performance (high CPU/memory, `/heapdump`), auto-compaction thrashing, hangs, search/ripgrep issues, WSL slow search
- [Troubleshoot installation and login](references/claude-code-troubleshoot-install.md) — PATH issues, install errors, TLS/SSL, WSL, Windows-specific issues, conflicting installations, OAuth errors, Bedrock/Vertex/Foundry credential setup
- [Error reference](references/claude-code-errors.md) — all runtime error messages, automatic retry behavior, server/usage/auth/network/request errors with recovery steps
- [Changelog](references/claude-code-changelog.md) — full release notes by version
- [What's new index](references/claude-code-whats-new-index.md) — weekly digest index of notable features
- [What's new: Week 13](references/claude-code-whats-new-2026-w13.md) — auto mode, computer use Desktop, PowerShell tool, conditional hooks
- [What's new: Week 14](references/claude-code-whats-new-2026-w14.md) — computer use CLI, per-tool MCP result size, plugin executables on PATH
- [What's new: Week 15](references/claude-code-whats-new-2026-w15.md) — Ultraplan, Monitor tool, `/loop` self-pacing, `/autofix-pr`
- [What's new: Week 16](references/claude-code-whats-new-2026-w16.md) — Opus 4.7, xhigh effort, `/effort` slider, Routines
- [What's new: Week 17](references/claude-code-whats-new-2026-w17.md) — `/ultrareview`, session recap, custom themes, Claude Code on web redesign

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
