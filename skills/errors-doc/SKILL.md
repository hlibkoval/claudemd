---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — all error messages with causes and recovery steps, covering server errors (500, 529, timeouts, auto mode), usage limits (session/weekly limits, 429, credit balance), authentication errors (login, API key, OAuth, org policy), network errors (connection failures, SSL, host-not-allowed), request errors (context too long, image/PDF limits, beta header stripping, model issues, thinking config, tool-use mismatches, usage policy), and response quality diagnostics.
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors.

## Quick Reference

### Error Category Index

| Message pattern | Category |
| :--- | :--- |
| `API Error: 500 Internal server error` | [Server errors](#server-errors) |
| `API Error: Repeated 529 Overloaded errors` | [Server errors](#server-errors) |
| `Request timed out` | [Server errors](#server-errors) / [Network](#network-errors) |
| `<model> is temporarily unavailable` / `Auto mode could not evaluate` / `Auto mode classifier transcript exceeded context window` | [Server errors — auto mode](#server-errors) |
| `You've hit your session limit` / `You've hit your weekly limit` | [Usage limits](#usage-limits) |
| `Server is temporarily limiting requests` | [Usage limits](#usage-limits) |
| `Request rejected (429)` | [Usage limits](#usage-limits) |
| `Credit balance is too low` | [Usage limits](#usage-limits) |
| `Not logged in · Please run /login` | [Authentication](#authentication-errors) |
| `Invalid API key` | [Authentication](#authentication-errors) |
| `This organization has been disabled` | [Authentication](#authentication-errors) |
| `Your organization has disabled Claude subscription access` | [Authentication](#authentication-errors) |
| `Routines are disabled by your organization's policy` | [Authentication](#authentication-errors) |
| `OAuth token revoked` / `OAuth token has expired` | [Authentication](#authentication-errors) |
| `does not meet scope requirement user:profile` | [Authentication](#authentication-errors) |
| `Unable to connect to API` | [Network errors](#network-errors) |
| `SSL certificate verification failed` | [Network errors](#network-errors) |
| `403` with `x-deny-reason: host_not_allowed` | [Network errors](#network-errors) |
| `Prompt is too long` | [Request errors](#request-errors) |
| `Error during compaction: Conversation too long` | [Request errors](#request-errors) |
| `Request too large` | [Request errors](#request-errors) |
| `Image was too large` | [Request errors](#request-errors) |
| `Unable to resize image` | [Request errors](#request-errors) |
| `PDF too large` / `PDF is password protected` | [Request errors](#request-errors) |
| `Extra inputs are not permitted` | [Request errors](#request-errors) |
| `There's an issue with the selected model` | [Request errors](#request-errors) |
| `Claude Opus is not available with the Claude Pro plan` | [Request errors](#request-errors) |
| `thinking.type.enabled is not supported for this model` | [Request errors](#request-errors) |
| `max_tokens must be greater than thinking.budget_tokens` | [Request errors](#request-errors) |
| `API Error: 400 due to tool use concurrency issues` | [Request errors](#request-errors) |
| `Claude Code is unable to respond to this request` (usage policy) | [Request errors](#request-errors) |
| Responses seem lower quality than usual | [Response quality](#response-quality) |

### Automatic Retry Behavior

Claude Code retries transient failures before showing an error. Server errors, 529s, timeouts, temporary 429 throttles, and dropped connections are retried up to 10 times with exponential backoff. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

| Environment variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 (10 min) | Per-request timeout in ms |

### Server Errors

Originate from the inference provider's infrastructure (Anthropic, Bedrock, Vertex AI, Foundry, or custom gateway), not your account.

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `API Error: 500 Internal server error` | Unexpected server-side failure | Check status page named in message; retry; run `/feedback` if persistent |
| `API Error: Repeated 529 Overloaded errors` | API at capacity across all users (not your quota) | Check status page; try again in a few minutes; run `/model` to switch models |
| `Request timed out` | API didn't respond before connection deadline (default 10 min) | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode classifier unavailable | Classifier model overloaded | Retry after a few seconds; continue with read-only tasks |
| Auto mode classifier bad response | Unparseable classifier result | Retry; use `claude --debug` to inspect classifier output |
| `Auto mode classifier transcript exceeded context window` | Conversation too large for classifier | Approve/deny manually; run `/compact` to shrink conversation |

Auto mode read/edit actions inside the working directory skip the classifier and keep working in all classifier failure cases.

### Usage Limits

Tied to your account or plan; distinct from server-wide errors.

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `You've hit your session limit` / `You've hit your weekly limit` / `You've hit your Opus limit` | Rolling usage allowance exhausted | Wait for reset time shown; `/usage` to check limits; `/usage-credits` to buy more; upgrade at claude.com/pricing |
| `Server is temporarily limiting requests` | Short-lived API throttle unrelated to plan quota | Wait briefly; retry; check status page |
| `Request rejected (429)` | API key / Bedrock / Vertex AI rate limit hit | Run `/status` to confirm active credential; check provider console; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console org ran out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload; switch to subscription auth with `/login` |

### Authentication Errors

Run `/status` at any time to see which credential is currently active.

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Not logged in · Please run /login` | No valid credential available | Run `/login`; check `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | `ANTHROPIC_API_KEY` or `apiKeyHelper` returned a rejected key | Check for typos/revocation; run `env \| grep ANTHROPIC` to find stale keys; unset and use `/login` |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` from a disabled org overrides subscription | Unset `ANTHROPIC_API_KEY` from shell/profile; relaunch `claude`; run `/status` to confirm |
| `Your organization has disabled Claude subscription access` | Server-side org policy blocks subscription login | Ask admin to enable; use Console API key instead of subscription auth |
| `Routines are disabled by your organization's policy` | Admin turned off routines at org level | Ask admin to enable at claude.ai/admin-settings/claude-code; use scheduled tasks for one-off work |
| `OAuth token revoked` / `OAuth token has expired` | Saved login invalidated (signed out or admin removed access) | Run `/login`; if error recurs, run `/logout` then `/login` |
| `OAuth token does not meet scope requirement: user:profile` | Token predates a required permission scope | Run `/login` to mint a new token (no need to log out first) |

### Network Errors

Usually originate in local network, proxy, firewall, or cloud environment network policy.

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Unable to connect to API` (ECONNREFUSED/ECONNRESET/ETIMEDOUT) | TCP connection failed | `curl -I https://api.anthropic.com` to test; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for gateways; check firewall allowlist |
| `SSL certificate verification failed` / `Self-signed certificate detected` | Corporate proxy intercepting TLS | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; never set `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `HTTP 403` with `x-deny-reason: host_not_allowed` | Outbound request blocked by cloud session network policy | Edit cloud environment settings: change Network access to Custom and add blocked domain to Allowed domains |

Platform-specific network causes: WSL broken `/etc/resolv.conf` nameserver; macOS stale VPN `utun` interfaces; Docker Desktop intercepting traffic.

### Request Errors

API received the request but rejected its content.

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Prompt is too long` | Conversation + files exceeds model context window | `/compact` to summarize; `/clear` to start fresh; `/context` to see usage; disable unused MCP servers; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | `/compact` itself failed — no room for the summary | Press Esc twice to step back several turns, then retry `/compact`; if still failing, `/clear` (session preserved in `/resume`) |
| `Request too large (max 30 MB)` | HTTP body exceeded byte limit (distinct from context window) | Press Esc twice to step back; reference large files by path instead of pasting |
| `Image was too large` | Image exceeds size or dimension limits (8000px single / 2000px with many images) | Press Esc twice to remove image; resize before pasting; take tighter screenshot |
| `Unable to resize image` | Native image processor failed to downscale | Convert to PNG/JPEG/GIF/WebP; resize below reported limit before attaching |
| `PDF too large` / `PDF is password protected` / invalid PDF | PDF exceeds 100 pages/32 MB, is encrypted, or corrupted | Read page range via Read tool; extract text with `pdftotext`; remove password or re-export |
| `Extra inputs are not permitted … context_management` | Gateway stripped `anthropic-beta` header | Configure gateway to forward `anthropic-beta`; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model name unrecognized or account lacks access | Run `/model` to pick available model; use alias (`sonnet`, `opus`) instead of versioned ID; check stale `ANTHROPIC_MODEL` env var or settings files |
| `Claude Opus is not available with the Claude Pro plan` | Active plan doesn't include selected model | Run `/model` to select an included model; if recently upgraded, `/logout` then `/login` to refresh token |
| `thinking.type.enabled is not supported for this model` | Claude Code version too old for Opus 4.7 | Run `claude update` to v2.1.111+; or switch to Opus 4.6/Sonnet with `/model` |
| `max_tokens must be greater than thinking.budget_tokens` | Extended thinking budget exceeds provider output limit (Bedrock/Vertex AI) | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the thinking budget |
| `API Error: 400 due to tool use concurrency issues` / `unexpected tool_use_id` / `thinking blocks … cannot be modified` | Conversation history in inconsistent state after interrupted tool call | Run `/rewind` or press Esc twice to step back to a checkpoint before the corrupted turn |
| `Claude Code is unable to respond to this request` (usage policy) | Content in conversation triggered Usage Policy check | Press Esc twice or `/rewind` to step back; rephrase; `/clear` to start fresh (previous session preserved in `/resume`) |

### Response Quality Diagnostics

If responses seem lower quality but no error is shown:

| Check | Command | What to look for |
| :--- | :--- | :--- |
| Model selection | `/model` | Wrong model from previous `/model` choice or `ANTHROPIC_MODEL` env var |
| Effort level | `/effort` | Reasoning level below maximum; `ultrathink` shortcut raises it |
| Context pressure | `/context` | Window near capacity — run `/compact` or `/clear` |
| Stale instructions | `/doctor` | Oversized CLAUDE.md files or MCP tool definitions consuming context |

When a response goes wrong, rewinding works better than replying with corrections: press Esc twice or `/rewind` to step back before the bad turn, then rephrase. This prevents the wrong attempt from anchoring later answers.

To report an error not listed here: run `/feedback` inside Claude Code (includes transcript); run `/doctor` for local config issues; check [status.claude.com](https://status.claude.com); search [GitHub issues](https://github.com/anthropics/claude-code/issues).

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — all runtime error messages with causes and recovery steps, automatic retry behavior, and response quality diagnostics

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
