---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — what each error message means, how to recover from it, automatic retry behavior, and quality degradation troubleshooting.
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors.

## Quick Reference

Claude Code retries transient failures up to **10 times** with exponential backoff before showing an error. When you see an error below, retries are already exhausted.

### Retry tuning

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Error index

| Message | Category |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Server |
| `API Error: Repeated 529 Overloaded errors` | Server |
| `Request timed out` | Server / Network |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server |
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
| Responses seem lower quality than usual | Quality |

### Server errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Unexpected API failure | Check status.claude.com; type `try again`; run `/feedback` |
| `API Error: Repeated 529 Overloaded errors` | API at capacity | Check status.claude.com; wait; switch model with `/model` |
| `Request timed out` | No response before deadline (default 10 min) | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| `auto mode cannot determine the safety of <tool>` | Safety classifier overloaded | Retry after a few seconds; continue with read-only tasks |

### Usage limit errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `You've hit your session/weekly limit` | Subscription quota reached | Wait for reset shown in message; `/usage`; `/extra-usage`; upgrade plan |
| `Server is temporarily limiting requests` | Short-lived throttle (not quota) | Wait briefly; check status.claude.com |
| `Request rejected (429)` | API key / Bedrock / Vertex rate limit | Check `/status`; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console prepaid credits exhausted | Add credits at platform.claude.com/settings/billing; switch to subscription auth |

### Authentication errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Not logged in` | No valid credential | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported |
| `Invalid API key` | Key rejected by API | Check for typos/revocation; run `env \| grep ANTHROPIC`; unset and use `/login` |
| `This organization has been disabled` | Stale env var from disabled org | Unset `ANTHROPIC_API_KEY`; relaunch; run `/status` |
| `OAuth token revoked/expired` | Login no longer valid | Run `/logout` then `/login`; check system clock |
| `OAuth scope requirement user:profile` | Token predates a new scope | Run `/login` to mint a new token |

### Network errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Unable to connect to API` (ECONNREFUSED/ECONNRESET/ETIMEDOUT) | No internet / VPN / proxy | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` |
| `SSL certificate verification failed` | TLS interception by proxy/appliance | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; never use `NODE_TLS_REJECT_UNAUTHORIZED=0` |

### Request errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Prompt is too long` | Context window exceeded | `/compact`; `/clear`; `/context` to inspect; disable unused MCP; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Window full when compact runs | Press Esc twice to step back; then `/compact`; or `/clear` + `/resume` |
| `Request too large (max 30 MB)` | HTTP body size limit (not context) | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Image exceeds size/dimension limits | Press Esc twice; resize (max 8000px single / 2000px many); tighter screenshot |
| `PDF too large` / `PDF is password protected` | PDF limits (100 pages / 32 MB) | Read page range with Read tool; extract text with `pdftotext`; remove password |
| `Extra inputs are not permitted` | Gateway stripped `anthropic-beta` header | Configure gateway to forward the header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Unknown or inaccessible model ID | `/model` to pick available model; use alias (`sonnet`, `opus`) instead of versioned ID |
| `Claude Opus is not available with the Claude Pro plan` | Plan does not include model | `/model` to switch; `/logout` then `/login` after upgrading plan |
| `thinking.type.enabled is not supported for this model` | CLI version too old for Opus 4.7 | Run `claude update` to v2.1.111+; or switch to Opus 4.6 / Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Thinking budget exceeds output limit | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Corrupted tool_use / thinking history | Run `/rewind` or press Esc twice to step back past corrupted turn |

### Response quality checklist

When responses seem lower quality with no error shown:

1. `/model` — confirm you are on the model you expect
2. `/effort` — check reasoning level; raise for hard work; try `ultrathink`
3. `/context` — check window fill; `/compact` or `/clear` if near capacity
4. `/doctor` — flags oversized CLAUDE.md files and subagent definitions
5. `/rewind` — step back before a bad turn rather than correcting in-thread
6. `/feedback` — report a regression with transcript attached

### Reporting errors

| Situation | Where to look |
| :--- | :--- |
| MCP server failed to connect | [MCP docs](/en/mcp) |
| Hook script failed or blocked a tool | [Hooks docs](/en/hooks#debug-hooks) |
| Permission denied during install | [Troubleshooting](/en/troubleshooting) |
| Error not listed here | `/feedback`; `/doctor`; status.claude.com; GitHub issues |

Note: `/feedback` is unavailable on Bedrock, Vertex AI, and Foundry deployments.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — runtime error messages with meanings, recovery steps, automatic retry behavior, and response quality troubleshooting.

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
