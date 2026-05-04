---
name: errors-doc
description: Complete official documentation for Claude Code runtime error messages — what each error means, how to recover, automatic retry behavior, and when to report.
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors, including what each message means and how to recover.

## Quick Reference

### Error Index by Category

| Message | Category |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors / Network |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server errors |
| `You've hit your session limit` / `You've hit your weekly limit` | Usage limits |
| `Server is temporarily limiting requests` | Usage limits |
| `Request rejected (429)` | Usage limits |
| `Credit balance is too low` | Usage limits |
| `Not logged in · Please run /login` | Authentication |
| `Invalid API key` | Authentication |
| `This organization has been disabled` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `SSL certificate verification failed` | Network |
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
| Responses seem lower quality than usual | Response quality |

### Automatic Retries

Claude Code retries transient failures up to 10 times with exponential backoff before surfacing an error. The spinner shows `Retrying in Ns · attempt x/y` while retrying. When you see an error, all retries have been exhausted.

| Env Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors (Anthropic Infrastructure)

| Error | Recovery |
| :--- | :--- |
| `API Error: 500` | Check status.claude.com, wait and retry, use `/feedback` |
| `API Error: Repeated 529 Overloaded` | Check status.claude.com, wait, switch model with `/model` |
| `Request timed out` | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` |
| Auto mode safety classifier unavailable | Retry after a few seconds; continue with read-only tasks |

### Usage Limit Errors (Account/Plan)

| Error | Recovery |
| :--- | :--- |
| `You've hit your session/weekly limit` | Wait for reset shown in message; run `/usage`; `/extra-usage` for more |
| `Server is temporarily limiting requests` | Wait briefly, retry |
| `Request rejected (429)` | Check `/status` credential; check provider rate limits; reduce concurrency |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing; consider auto-reload |

### Authentication Errors

| Error | Recovery |
| :--- | :--- |
| `Not logged in` | Run `/login`; check `ANTHROPIC_API_KEY` is set; configure `apiKeyHelper` |
| `Invalid API key` | Check for typos; run `env \| grep ANTHROPIC`; confirm key not revoked |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell; relaunch `claude`; run `/status` |
| `OAuth token revoked/expired` | Run `/login`; if persists run `/logout` then `/login` |
| `OAuth scope requirement` | Run `/login` to mint a new token with current scopes |

### Network Errors

| Error | Recovery |
| :--- | :--- |
| `Unable to connect to API` | Test with `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |

### Request Errors (API Rejected Content)

| Error | Recovery |
| :--- | :--- |
| `Prompt is too long` | Run `/compact`, `/context`, `/clear`; disable unused MCP servers; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Press Esc twice to go back several turns, then retry `/compact`; or `/clear` + `/resume` |
| `Request too large (max 30 MB)` | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice; resize to under 8000px (longest edge); take tighter screenshot |
| `PDF too large` / `PDF is password protected` | Extract text with `pdftotext`; read page ranges with Read tool; re-export PDF |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model`; use aliases (`sonnet`, `opus`) instead of versioned IDs |
| `Claude Opus is not available with the Claude Pro plan` | Run `/model`; if plan was recently upgraded run `/logout` then `/login` |
| `thinking.type.enabled is not supported` | Run `claude update` to v2.1.111+; or switch to Opus 4.6/Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` or press Esc twice to step back to a good checkpoint |

### Response Quality Checks (No Error Shown)

When responses seem lower quality, check in order:

1. **Model**: run `/model` — confirm you are on the expected model
2. **Effort**: run `/effort` — raise for hard debugging/design work
3. **Context pressure**: run `/context` — run `/compact` if near capacity
4. **Stale instructions**: run `/doctor` — flags oversized CLAUDE.md and subagent definitions

Rewinding with `/rewind` (or Esc twice) usually works better than correcting in-thread — corrections keep the wrong attempt in context.

### Reporting Errors

- Run `/feedback` inside Claude Code to send transcript to Anthropic (unavailable on Bedrock/Vertex AI/Foundry)
- Run `/doctor` to check local configuration problems
- Check [status.claude.com](https://status.claude.com) for active incidents
- Search [existing issues](https://github.com/anthropics/claude-code/issues) on GitHub

For non-API errors: MCP failures → see MCP docs; hook failures → see hooks docs; install errors → see troubleshoot-install docs.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — runtime error messages, automatic retry behavior, server errors, usage limits, authentication errors, network errors, request errors, response quality, and how to report issues

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
