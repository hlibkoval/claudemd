---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — error message lookup table, automatic retry behavior (CLAUDE_CODE_MAX_RETRIES, API_TIMEOUT_MS), server errors (500, 529, timeout, auto mode classifier failures), usage limit errors (session/weekly/Opus limits, rate limiting, credit balance), authentication errors (not logged in, invalid API key, disabled org, OAuth token issues, scope requirements), network errors (connection failures, SSL certificate errors, host-not-allowed in cloud sessions), request errors (prompt too long, compaction failure, request too large, image/PDF errors, extra inputs, model issues, thinking config, tool-use mismatch, usage policy refusal), response quality degradation diagnosis, and how to report errors.
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors.

## Quick Reference

### Error Lookup Table

| Error message | Category |
| :--- | :--- |
| `API Error: 500 Internal server error` | Server |
| `API Error: Repeated 529 Overloaded errors` | Server |
| `Request timed out` | Server / Network |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server |
| `Auto mode could not evaluate this action and is blocking it for safety` | Server |
| `Auto mode classifier transcript exceeded context window` | Server |
| `You've hit your session limit` / `You've hit your weekly limit` | Usage limits |
| `Server is temporarily limiting requests` | Usage limits |
| `Request rejected (429)` | Usage limits |
| `Credit balance is too low` | Usage limits |
| `Not logged in · Please run /login` | Authentication |
| `Invalid API key` | Authentication |
| `This organization has been disabled` | Authentication |
| `Your organization has disabled Claude subscription access` | Authentication |
| `Routines are disabled by your organization's policy` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `SSL certificate verification failed` | Network |
| `403` with `x-deny-reason: host_not_allowed` | Network |
| `Prompt is too long` | Request |
| `Error during compaction: Conversation too long` | Request |
| `Request too large` | Request |
| `Image was too large` | Request |
| `Unable to resize image` | Request |
| `PDF too large` / `PDF is password protected` | Request |
| `Extra inputs are not permitted` | Request |
| `There's an issue with the selected model` | Request |
| `Claude Opus is not available with the Claude Pro plan` | Request |
| `thinking.type.enabled is not supported for this model` | Request |
| `max_tokens must be greater than thinking.budget_tokens` | Request |
| `API Error: 400 due to tool use concurrency issues` | Request |
| Usage Policy refusal | Request |
| Responses seem lower quality than usual | Quality |

### Automatic Retries

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

Originate from the inference provider infrastructure (Anthropic, Bedrock, Vertex AI, Foundry, or a custom gateway).

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `500 Internal server error` | Unexpected API failure | Check status.claude.com; retry; run `/feedback` if it persists |
| `529 Overloaded` (repeated) | API at capacity across all users; not your quota | Check status.claude.com; retry; run `/model` to switch models |
| `Request timed out` | API did not respond before deadline (default 10 min) | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` |
| Auto mode classifier unavailable | Classifier model overloaded | Retry after a few seconds; continue with read-only tasks |
| Auto mode classifier bad response | Unparseable classifier result | Retry; run `claude --debug` to inspect raw classifier response |
| Auto mode classifier context exceeded | Conversation too large for classifier | Approve/deny in prompt; run `/compact` to reduce conversation size |

Auto mode classifier failures only block non-read-only actions outside the working directory. Reads, searches, and edits inside your working directory skip the classifier.

### Usage Limit Errors

Tied to your account or plan quota (distinct from server errors).

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `You've hit your session/weekly limit` | Rolling subscription allowance exhausted | Wait for reset time shown; run `/usage`; buy credits via `/usage-credits`; upgrade plan |
| `Server is temporarily limiting requests` | Short-lived throttle unrelated to your quota | Wait briefly and retry |
| `Request rejected (429)` | Rate limit on API key / Bedrock / Vertex project | Run `/status` to confirm active credential; reduce concurrency; request higher tier |
| `Credit balance is too low` | Console organization out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload |

To monitor remaining allowance: add `rate_limits` fields to a custom status line, or use the Desktop app usage ring.

### Authentication Errors

Run `/status` at any time to see which credential is currently active.

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `Not logged in` | No valid credential available | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Key rejected by API | Check for typos; run `env \| grep ANTHROPIC`; unset key and use `/login` |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` from disabled org overriding subscription | Unset `ANTHROPIC_API_KEY`; relaunch; run `/status` to confirm |
| `Your organization has disabled Claude subscription access` | Org-level policy blocks subscription login | Ask admin to enable; use Console API key instead |
| `Routines are disabled by your organization's policy` | Admin disabled routines org-wide | Ask admin to enable at claude.ai/admin-settings/claude-code |
| `OAuth token revoked` / `OAuth token has expired` | Saved login no longer valid | Run `/login`; if recurring, run `/logout` then `/login` |
| `does not meet scope requirement user:profile` | Token predates a required permission scope | Run `/login` to mint a new token |

Environment variable `ANTHROPIC_API_KEY` takes precedence over `/login` credentials. A key in your shell profile or `.env` file overrides a working subscription.

### Network Errors

| Error | Common Causes | Recovery |
| :--- | :--- | :--- |
| `Unable to connect to API` (ECONNREFUSED, ECONNRESET, ETIMEDOUT) | No internet; VPN blocking api.anthropic.com; proxy not configured | Run `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall |
| `SSL certificate verification failed` | Corporate proxy intercepting TLS | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `403` + `x-deny-reason: host_not_allowed` | Cloud session/routine network policy blocking outbound request | Edit cloud environment: change Network access to **Custom**, add allowed domain; or use **Full** for unrestricted |

Additional connection diagnostics: check `/etc/resolv.conf` on Linux/WSL; look for stale `utun` interfaces on macOS (leftover VPN); quit Docker Desktop/container runtimes and retry.

### Request Errors

The API received the request but rejected its content.

| Error | Cause | Recovery |
| :--- | :--- | :--- |
| `Prompt is too long` | Conversation + files exceed model context window | Run `/compact` or `/clear`; check `/context`; disable unused MCP servers; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Not enough free context to hold compaction summary | Press Esc twice to step back several turns; then retry `/compact`; or `/clear` and resume |
| `Request too large` (max 30 MB) | Raw HTTP request body too large | Press Esc twice; reference large files by path instead of pasting contents |
| `Image was too large` | Image exceeds API size/dimension limits | Press Esc twice; resize image (max 8000px longest edge for single image, 2000px with many images) |
| `Unable to resize image` | Native image processor failed | Convert to PNG/JPEG/GIF/WebP; resize below stated dimension/size limit |
| `PDF too large` / `PDF is password protected` | PDF exceeds 100 pages or 32 MB; or protected | Use Read tool for page ranges; extract text with pdftotext; remove password |
| `Extra inputs are not permitted` | Proxy/gateway dropped `anthropic-beta` header | Configure gateway to forward `anthropic-beta`; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model name unrecognized or no access | Run `/model`; use alias like `sonnet`/`opus`; check for stale model ID in settings/env vars |
| `Claude Opus is not available with the Claude Pro plan` | Plan does not include selected model | Run `/model`; upgrade plan; if recently upgraded, run `/logout` then `/login` |
| `thinking.type.enabled is not supported for this model` | Claude Code version too old for Opus 4.7 | Run `claude update` to upgrade to v2.1.111+; or switch to Opus 4.6 / Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Extended thinking budget exceeds output limit | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the thinking budget |
| `400 due to tool use concurrency issues` | Conversation history inconsistent (interrupted tool call or edited turn) | Run `/rewind` or press Esc twice to step back to a checkpoint before the corrupted turn |
| Usage Policy refusal | Content triggered Anthropic Usage Policy check | Press Esc twice or run `/rewind` to step back and rephrase; or `/clear` to start fresh |

### Response Quality Degradation

No error shown, but responses seem less capable. Check in order:

1. **Model**: run `/model` — a stale ID or `ANTHROPIC_MODEL` env var may have you on a smaller model
2. **Effort level**: run `/effort` — check and raise reasoning level; see `ultrathink` shortcut
3. **Context pressure**: run `/context` — if near capacity, run `/compact` or `/clear`
4. **Stale instructions**: run `/doctor` to flag oversized CLAUDE.md files and subagent definitions

Rewinding usually works better than replying with corrections — press Esc twice or run `/rewind` to step back before the bad turn.

### Reporting Errors

| Situation | Action |
| :--- | :--- |
| Error not on this page or fix didn't work | Run `/feedback` (includes transcript; offers prefilled GitHub issue) |
| On Bedrock / Vertex / Foundry / third-party | `/feedback` saves local archive for your Anthropic account rep |
| Check local config problems | Run `/doctor` |
| Check active incidents | Check status.claude.com |
| Search known issues | github.com/anthropics/claude-code/issues |

For errors from other components: MCP connection issues → see MCP docs; hook script failures → see hooks docs; install/permission errors → see troubleshoot-install docs.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — complete runtime error list with recovery steps, retry behavior, server/usage/auth/network/request error categories, response quality diagnosis, and reporting guidance

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
