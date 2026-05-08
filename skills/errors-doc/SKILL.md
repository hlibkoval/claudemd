---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — error message lookup, automatic retry behavior, server errors, usage limits, authentication errors, network errors, request errors, and response quality troubleshooting.
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors and how to recover from them.

## Quick Reference

### Error Message Index

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
| `403` with `x-deny-reason: host_not_allowed` | Network (cloud session) |
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

### Automatic Retry Behavior

Claude Code retries transient failures up to 10 times with exponential backoff before surfacing an error. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

**Retried automatically:** server errors, 529 overloaded responses, request timeouts, temporary 429 throttles, dropped connections.

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Retry attempt count |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| 500 Internal server error | Unexpected API failure | Check status.claude.com; retry; `/feedback` if persistent |
| 529 Overloaded | API at capacity | Check status.claude.com; retry in minutes; `/model` to switch models |
| Request timed out | No response before deadline (default 10 min) | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` |
| Auto mode classifier unavailable | Classifier model overloaded | Retry after a few seconds; continue with read-only tasks |

### Usage Limits

| Error | Cause | Fix |
| :--- | :--- | :--- |
| Session/weekly/model limit hit | Rolling subscription quota exhausted | Wait for reset time shown; `/usage`; `/extra-usage` to buy more; upgrade plan |
| Server is temporarily limiting requests | Short-lived API throttle (not your quota) | Wait briefly; check status.claude.com |
| Request rejected (429) | API key / Bedrock / Vertex rate limit | Check `/status`; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY`; request higher tier |
| Credit balance is too low | Console org out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload |

### Authentication Errors

| Error | Fix |
| :--- | :--- |
| Not logged in | `/login`; confirm `ANTHROPIC_API_KEY` is exported; use `apiKeyHelper` for CI |
| Invalid API key | Check for typos; run `env \| grep ANTHROPIC`; unset stale key; run `/status` |
| Organization disabled | Unset `ANTHROPIC_API_KEY`; relaunch; run `/status` to confirm credential |
| OAuth token revoked/expired | `/login`; if persists: `/logout` then `/login` |
| OAuth scope requirement | `/login` (no logout needed) to mint token with current scopes |

Run `/status` at any time to see which credential is currently active.

### Network Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| Unable to connect to API | No internet, VPN, proxy not configured | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for LLM gateway |
| SSL certificate verification failed | Corporate TLS interception | `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| 403 host_not_allowed (cloud session) | Cloud env network policy blocked outbound request | Edit environment → Network access → Custom → add domain to allowed list |

### Request Errors

| Error | Fix |
| :--- | :--- |
| Prompt is too long | `/compact`; `/clear`; `/context` to diagnose; disable unused MCP servers; trim CLAUDE.md |
| Error during compaction: Conversation too long | Press Esc twice to step back several turns, then `/compact`; or `/clear` (use `/resume` to reopen) |
| Request too large (max 30 MB) | Press Esc twice; reference large files by path instead of pasting |
| Image was too large | Press Esc twice; resize image (max 8000px longest edge; 2000px with many images in context) |
| PDF too large (max 100 pages, 32 MB) | Read page range with Read tool; extract text with `pdftotext` |
| PDF is password protected | Remove password or re-export from source app |
| Extra inputs are not permitted | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| Issue with selected model | `/model`; use alias (`sonnet`, `opus`) instead of versioned ID; check `ANTHROPIC_MODEL` env var and settings files |
| Opus not available on Pro plan | `/model` to select included model; `/logout` then `/login` after upgrading |
| thinking.type.enabled not supported | `claude update` to v2.1.111+; or use Opus 4.6 / Sonnet |
| max_tokens must be greater than thinking.budget_tokens | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| Tool use / thinking block mismatch | `/rewind` or press Esc twice to step back to checkpoint before corrupted turn |

### Response Quality Checklist (No Error Shown)

1. **Model selection** — run `/model` to confirm expected model; check `ANTHROPIC_MODEL` env var
2. **Effort level** — run `/effort` to check reasoning level; use `ultrathink` shortcut for hard tasks
3. **Context pressure** — run `/context` to see window fullness; `/compact` or `/clear` if near capacity
4. **Stale instructions** — run `/doctor` for oversized CLAUDE.md or subagent definitions; `/context` for MCP token usage
5. **Rewind instead of correcting** — press Esc twice or `/rewind` to step back; correcting in-thread anchors answers to the bad turn

### Reporting Errors

- `/feedback` — sends transcript + description to Anthropic (unavailable on Bedrock, Vertex AI, Foundry)
- `/doctor` — checks local configuration problems
- [status.claude.com](https://status.claude.com) — active incidents
- [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues) — existing issues

Related guides: MCP errors → `/mcp`; hook failures → hooks-doc; install errors → troubleshoot-install.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — complete runtime error listing with causes, recovery steps, automatic retry behavior, and response quality troubleshooting

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
