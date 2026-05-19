---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — error message lookup table, automatic retry behavior, server errors, usage limits, authentication errors, network and connection errors, request errors, response quality troubleshooting, and how to report errors.
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors and how to recover from them.

## Quick Reference

### Error Lookup Table

| Message | Category |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors (or Network if connection mentioned) |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server errors |
| `Auto mode could not evaluate this action and is blocking it for safety` | Server errors |
| `Auto mode classifier transcript exceeded context window` | Server errors |
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
| `403` with `x-deny-reason: host_not_allowed` in a cloud session | Network |
| `Prompt is too long` | Request errors |
| `Error during compaction: Conversation too long` | Request errors |
| `Request too large` | Request errors |
| `Image was too large` | Request errors |
| `PDF too large` / `PDF is password protected` | Request errors |
| `Extra inputs are not permitted` | Request errors |
| `There's an issue with the selected model` | Request errors |
| `Claude Opus is not available with the Claude Pro plan` | Request errors |
| `thinking.type.enabled is not supported for this model` | Request errors |
| `max_tokens must be greater than thinking.budget_tokens` | Request errors |
| `API Error: 400 due to tool use concurrency issues` | Request errors |
| `Claude Code is unable to respond to this request...Usage Policy` | Request errors |
| Responses seem lower quality than usual | Response quality |

### Automatic Retry Behavior

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. While retrying, the spinner shows `Retrying in Ns · attempt x/y`.

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Unexpected failure inside the API | Check status.claude.com; retry; run `/feedback` if it persists |
| `API Error: Repeated 529 Overloaded errors` | API at capacity; not your usage limit | Check status.claude.com; retry in a few minutes; run `/model` to switch models |
| `Request timed out` | API did not respond before deadline | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode classifier errors | Classifier unavailable, returned bad response, or context window exceeded | Retry; run `/compact` to reduce conversation size; fall back to manual approval |

### Usage Limit Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `You've hit your session/weekly/Opus limit` | Subscription rolling allowance exhausted | Wait for reset time shown; run `/usage`; buy credits with `/usage-credits`; upgrade at claude.com/pricing |
| `Server is temporarily limiting requests` | Short-lived server throttle (not your quota) | Wait briefly and retry |
| `Request rejected (429)` | API key, Bedrock, or Vertex AI rate limit | Run `/status`; check provider console; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console org out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload |

### Authentication Errors

Run `/status` to see which credential is currently active.

| Error | Fix |
| :--- | :--- |
| `Not logged in` | Run `/login`; confirm `ANTHROPIC_API_KEY` is set; configure `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos; run `env \| grep ANTHROPIC`; unset key and `/login` for subscription auth |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` in shell and profile; relaunch `claude`; run `/status` to verify |
| `Your organization has disabled Claude subscription access` | Ask admin to enable access; use Console API key instead |
| `Routines are disabled` | Ask admin to enable Routines toggle at claude.ai/admin-settings/claude-code |
| `OAuth token revoked or expired` | Run `/login`; if recurring, run `/logout` then `/login` |
| `OAuth scope requirement (user:profile)` | Run `/login` to mint a new token with current scopes |

### Network and Connection Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Unable to connect to API` | No internet, VPN blocking, proxy not configured | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for gateways |
| `SSL certificate verification failed` | Corporate proxy intercepting TLS | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `403` `x-deny-reason: host_not_allowed` | Cloud session blocked by network policy | Open environment settings; change Network Access to Custom; add blocked domain to Allowed Domains |

### Request Errors

| Error | Fix |
| :--- | :--- |
| `Prompt is too long` | Run `/compact` or `/clear`; run `/context` for breakdown; disable unused MCP servers; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Press Esc twice to step back several turns, then compact; or `/clear` and `/resume` |
| `Request too large` (max 30 MB) | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice; resize image before pasting (max 8000px single, 2000px with many images) |
| `PDF too large / password protected` | Ask Claude to read a page range; extract text with `pdftotext`; remove password and re-export |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model`; use alias (e.g., `sonnet`) not versioned ID; check `ANTHROPIC_MODEL` and settings files for stale ID |
| `Claude Opus is not available with the Claude Pro plan` | Run `/model`; if just upgraded, `/logout` then `/login` to refresh token |
| `thinking.type.enabled is not supported` | Run `claude update` to v2.1.111+; or switch to Opus 4.6 / Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` or press Esc twice to step back to a valid checkpoint |
| Usage Policy refusal | Press Esc twice or `/rewind`; rephrase or `/clear` for a fresh session |

### Response Quality Troubleshooting

When responses seem lower quality than usual (no error shown), check in order:

1. **Model**: Run `/model` — confirm you are on the expected model. Check `ANTHROPIC_MODEL` env var.
2. **Effort level**: Run `/effort` — raise it for hard debugging. Use `ultrathink` shortcut.
3. **Context pressure**: Run `/context` — if near capacity, run `/compact` at a natural break or `/clear`.
4. **Stale instructions**: Run `/doctor` — flags oversized CLAUDE.md files and subagent definitions.

When a response goes wrong, use `/rewind` or Esc twice to step back before the bad turn, then rephrase. Correcting in-thread keeps the bad attempt in context and can anchor later answers.

### Reporting Errors

| Situation | Action |
| :--- | :--- |
| Error not listed or fix doesn't work | Run `/feedback` to send transcript + description to Anthropic |
| On Bedrock, Vertex AI, or third-party providers | `/feedback` saves a local archive to send to your Anthropic rep |
| Configuration problems | Run `/doctor` |
| Active incidents | Check status.claude.com |
| Known issues | Search github.com/anthropics/claude-code/issues |

Related guides for component-specific errors:
- MCP failures: see MCP documentation
- Hook failures: see Hooks documentation
- Installation/login errors: see Troubleshoot Installation documentation

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — runtime error messages, automatic retries, server errors, usage limits, authentication errors, network errors, request errors, response quality troubleshooting, and error reporting

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
