---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — error messages, causes, recovery steps, retry behavior, server/usage/auth/network/request errors, and response quality troubleshooting.
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors.

## Quick Reference

### Error Lookup Table

| Message | Category |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Server |
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
| `Routines are disabled by your organization's policy` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `SSL certificate verification failed` | Network |
| `403` with `x-deny-reason: host_not_allowed` in a cloud/routine session | Network |
| `Prompt is too long` | Request |
| `Error during compaction: Conversation too long` | Request |
| `Request too large` | Request |
| `Image was too large` | Request |
| `PDF too large` / `PDF is password protected` | Request |
| `Extra inputs are not permitted` | Request |
| `There's an issue with the selected model` | Request |
| `Claude Opus is not available with the Claude Pro plan` | Request |
| `thinking.type.enabled is not supported for this model` | Request |
| `max_tokens must be greater than thinking.budget_tokens` | Request |
| `API Error: 400 due to tool use concurrency issues` | Request |
| Responses seem lower quality than usual | Quality (no error shown) |

### Automatic Retry Behavior

Claude Code retries transient failures up to 10 times with exponential backoff before surfacing an error. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

| Env Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in ms (10 minutes) |

### Recovery Quick-Reference by Category

**Server errors** — Check [status.claude.com](https://status.claude.com), wait and retry, run `/feedback`. For 529 overloaded, switch models with `/model`.

**Usage limits** — Wait for reset time shown in error, run `/usage` to check limits, run `/extra-usage` for additional usage (Pro/Max), add credits at platform.claude.com/settings/billing.

**Authentication** — Run `/status` to see active credential. Run `/login` to re-authenticate. Unset stale `ANTHROPIC_API_KEY` from shell/profile if it overrides subscription auth. Run `/logout` then `/login` to fully refresh a revoked/expired OAuth token.

**Network** — Test with `curl -I https://api.anthropic.com`. Set `HTTPS_PROXY` for corporate proxies. Set `NODE_EXTRA_CA_CERTS` for SSL certificate errors (do not use `NODE_TLS_REJECT_UNAUTHORIZED=0`). Set `ANTHROPIC_BASE_URL` for LLM gateways.

**Request errors** — Run `/compact` or `/clear` for context/size issues. Press Esc twice to step back past oversized attachments. For model errors, run `/model` to switch. For beta header errors, configure gateway to forward `anthropic-beta` header or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

**Response quality** — Run `/model` (confirm model), `/effort` (check reasoning level), `/context` (check window fullness), `/doctor` (stale instructions). Use `/rewind` or press Esc twice to step back rather than correcting in-thread.

### Context Window Errors: Fix Order

1. `Prompt is too long` → run `/compact`, then `/clear` if needed. Run `/context` to see breakdown.
2. `Error during compaction: Conversation too long` → press Esc twice to step back several turns, then run `/compact` again. If still failing, run `/clear` (session preserved, reopen with `/resume`).
3. `Request too large (max 30 MB)` → press Esc twice, remove oversized attachment; reference large files by path instead.

### SSL Certificate Fix

```bash
NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem claude
```

### Cloud Session Host-Not-Allowed Fix

Open environment settings → change Network access from **Trusted** to **Custom** → add blocked domain to Allowed domains → Save changes.

### Reporting Errors

- Run `/feedback` inside Claude Code to submit transcript + description
- Run `/doctor` to check local configuration
- Check [status.claude.com](https://status.claude.com)
- Search [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues)

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — Full list of runtime error messages with causes and step-by-step recovery instructions

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
