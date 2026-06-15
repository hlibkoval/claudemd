---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors — what each error message means and how to recover from it.

## Quick Reference

### Error Index

| Message | Category |
| :--- | :--- |
| `API Error: 500 Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server errors |
| `Auto mode could not evaluate this action and is blocking it for safety` | Server errors |
| `Auto mode classifier transcript exceeded context window` | Server errors |
| `You've hit your session limit` / `You've hit your weekly limit` | Usage limits |
| `Usage credits required for 1M context` | Usage limits |
| `Server is temporarily limiting requests` | Usage limits |
| `Request rejected (429)` | Usage limits |
| `Credit balance is too low` | Usage limits |
| `Not logged in · Please run /login` | Authentication |
| `Could not resolve authentication method` | Authentication |
| `Invalid API key` | Authentication |
| `This organization has been disabled` | Authentication |
| `Your organization has disabled API key authentication` | Authentication |
| `Your organization has disabled Claude subscription access` | Authentication |
| `Routines are disabled by your organization's policy` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `SSL certificate verification failed` | Network |
| `403` with `x-deny-reason: host_not_allowed` in a cloud or routine session | Network |
| `Prompt is too long` | Request errors |
| `Error during compaction: Conversation too long` | Request errors |
| `Request too large` | Request errors |
| `Image was too large` | Request errors |
| `Unable to resize image` | Request errors |
| `PDF too large` / `PDF is password protected` | Request errors |
| `Extra inputs are not permitted` | Request errors |
| `There's an issue with the selected model` | Request errors |
| `Claude Opus is not available with the Claude Pro plan` | Request errors |
| `thinking.type.enabled is not supported for this model` | Request errors |
| `max_tokens must be greater than thinking.budget_tokens` | Request errors |
| `API Error: 400 due to tool use concurrency issues` | Request errors |
| `Claude Code is unable to respond to this request, which appears to violate our Usage Policy` | Request errors |
| Responses seem lower quality than usual | Response quality |

### Automatic Retries

Claude Code retries transient failures up to 10 times with exponential backoff before surfacing an error. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `500 Internal server error` | Unexpected failure inside API infrastructure | Check status.claude.com; retry; run `/feedback` if it persists |
| `Repeated 529 Overloaded errors` | API at capacity (not your quota) | Check status.claude.com; retry after a few minutes; switch model with `/model` |
| `Request timed out` | API did not respond within deadline (default 10 min) | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode classifier unavailable | Classifier model overloaded; classifier returned bad response; transcript too long | Retry after a few seconds; run `/compact` if transcript exceeded context window; approve manually |

### Usage Limit Errors

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `You've hit your session/weekly limit` | Subscription rolling allowance exhausted | Wait for reset time shown; run `/usage`; buy credits with `/usage-credits`; upgrade plan |
| `Usage credits required for 1M context` | 1M context not included in your plan | Run `/model` to switch to standard context; run `/usage-credits` to enable metered billing |
| `Server is temporarily limiting requests` | Short-lived API throttle, unrelated to quota | Wait briefly and retry; check status.claude.com |
| `Request rejected (429)` | Rate limit for your API key or provider project | Run `/status` to confirm credential; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY`; request higher tier |
| `Credit balance is too low` | Console org ran out of prepaid credits | Add credits at platform.claude.com; enable auto-reload; switch to subscription auth |

### Authentication Errors

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `Not logged in` | No valid credential for this session | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported |
| `Could not resolve authentication method` | Session reached API client without any credential (common in background/cloud sessions) | Upgrade to v2.1.174+; confirm env vars set in worker process environment |
| `Invalid API key` | Key rejected by API | Check for typos; confirm key not revoked; run `env \| grep ANTHROPIC` for stale keys |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` from disabled org overrides subscription login | Unset `ANTHROPIC_API_KEY` from shell profile; relaunch `claude` |
| `Organization has disabled API key authentication` | Admin turned off API keys for org | Unset `ANTHROPIC_API_KEY` or `apiKeyHelper`; run `/login` |
| `Organization has disabled Claude subscription access` | Server-side org setting blocking subscription login | Ask admin to enable; or use Console API key instead |
| `Routines are disabled by your organization's policy` | Admin disabled routines at org level | Ask admin to enable at claude.ai/admin-settings/claude-code |
| `OAuth token revoked or expired` | Login no longer valid | Run `/login`; if it recurs run `/logout` then `/login` |
| `does not meet scope requirement user:profile` | Token predates newer OAuth scope | Run `/login` to mint new token (no need to log out first) |

### Network and Connection Errors

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `Unable to connect to API` (ECONNREFUSED, ECONNRESET, ETIMEDOUT) | No internet, VPN blocking `api.anthropic.com`, or unconfigured proxy | Run `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check `/etc/resolv.conf` on WSL; quit Docker Desktop |
| `SSL certificate verification failed` | Corporate proxy intercepting TLS with its own cert | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT set `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `403` with `x-deny-reason: host_not_allowed` | Cloud session/routine blocked by sandbox network policy | In routine/cloud session settings, change Network access to Custom; add the blocked domain to Allowed domains |

### Request Errors

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `Prompt is too long` | Conversation + files exceed model's context window | Run `/compact` or `/clear`; run `/context` for breakdown; disable unused MCP servers; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Not enough free context to produce the compaction summary | Press Esc twice to step back; then `/compact`; or run `/clear` and `/resume` |
| `Request too large` (max 30 MB) | HTTP request body too large before tokenization | Press Esc twice to remove oversized content; reference large files by path instead of pasting |
| `Image was too large` | Pasted image exceeds API limits | Resize to under 8000px on longest edge (2000px when many images in context); take tighter screenshot |
| `Unable to resize image` | Image processor could not downscale image | Convert to PNG/JPEG/GIF/WebP; resize below stated limit before attaching |
| `PDF too large` / `PDF is password protected` / `PDF not valid` | PDF exceeds 100 pages/32 MB, is encrypted, or corrupt | Extract text with `pdftotext`; remove password; re-export from source application |
| `Extra inputs are not permitted` | Gateway stripped `anthropic-beta` header | Configure gateway to forward `anthropic-beta`; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model name not recognized or no access | Run `/model`; use alias (e.g., `sonnet`) instead of versioned ID; check `ANTHROPIC_MODEL` env var and settings files in priority order |
| `Claude Opus is not available with the Claude Pro plan` | Plan does not include selected model | Run `/model` and pick an included model; re-authenticate if you recently upgraded |
| `thinking.type.enabled is not supported for this model` | Claude Code version too old for Opus 4.7/4.8 | Run `claude update`; Opus 4.7 needs v2.1.111+, Opus 4.8 needs v2.1.154+ |
| `max_tokens must be greater than thinking.budget_tokens` | Thinking budget exceeds provider's output limit | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Conversation history corrupted after interrupted tool call or mid-stream edit | Run `claude update` if on Opus 4.7/4.8 before v2.1.156; then run `/rewind` to step back to a clean checkpoint |
| Usage Policy refusal | Content in conversation triggered Usage Policy check | Press Esc twice or `/rewind` to step back; rephrase; or `/clear` to start fresh |

### Response Quality Checklist

When responses seem lower quality than expected with no error shown:

| Check | Command | Notes |
| :--- | :--- | :--- |
| Model selection | `/model` | Confirm you are on the intended model; check `ANTHROPIC_MODEL` env var |
| Effort level | `/effort` | Raise for hard debugging or design work; use `ultrathink` shortcut |
| Context pressure | `/context` | Near-full window degrades quality; run `/compact` or `/clear` |
| Stale instructions | `/doctor` | Flags oversized memory files and subagent definitions |

When a response goes wrong, **rewind rather than correct in-thread**: press Esc twice or run `/rewind` to step back before the bad turn and rephrase. Correcting in-thread anchors later answers to the wrong attempt.

Claude Code does not silently change model versions. It can switch in three cases: a configured `--fallback-model` activates (shown in transcript), a Bedrock/Vertex startup check finds the default unavailable, or automatic model fallback on Fable 5 (shown in transcript).

### Reporting Errors

| Situation | Action |
| :--- | :--- |
| Error not listed here or fix did not help | Run `/feedback` inside Claude Code to send transcript + description to Anthropic |
| `/feedback` unavailable (Bedrock, Vertex, Foundry) | `/feedback` saves a local archive to send to your account rep |
| Local config problem | Run `/doctor` |
| Active incident | Check status.claude.com |
| Known GitHub issues | Search github.com/anthropics/claude-code/issues |

Other guides for related errors:
- MCP connection/auth failures: see MCP documentation
- Hook script failures: see Hooks documentation (`/hooks` > Debug hooks)
- Install / filesystem permission errors: see Troubleshoot installation and login

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — Complete error catalog with messages, causes, and step-by-step recovery for every runtime error Claude Code can display

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
