---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors — what each message means and how to recover from it.

## Quick Reference

### Error lookup table

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
| `Invalid API key` | Authentication |
| `This organization has been disabled` | Authentication |
| `Your organization has disabled API key authentication` | Authentication |
| `Your organization has disabled Claude subscription access` | Authentication |
| `Routines are disabled by your organization's policy` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `SSL certificate verification failed` | Network |
| `403` with `x-deny-reason: host_not_allowed` in a cloud/routine session | Network |
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
| `Claude Code is unable to respond to this request...` (Usage Policy) | Request errors |
| Responses seem lower quality than usual | Response quality |

### Automatic retry behavior

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. Retrying errors include: server errors, 529 overloaded, request timeouts, temporary 429 throttles, dropped connections. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

| Env var | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in ms |

### Server errors — key recoveries

| Error | Primary fix |
| :--- | :--- |
| 500 Internal server error | Check status.claude.com; type `try again`; run `/feedback` if persistent |
| 529 Overloaded | Check status; wait a few minutes; run `/model` to switch to a less-loaded model |
| Request timed out | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode classifier unavailable | Retry after a few seconds; continue with read-only work |
| Auto mode classifier unparseable | Retry; use `claude --debug` to inspect the classifier response |
| Auto mode context window exceeded | Approve/deny the manual prompt that appears; run `/compact` to shrink context |

### Usage limit errors — key recoveries

| Error | Primary fix |
| :--- | :--- |
| Session/weekly/Opus limit hit | Wait for reset shown in message; `/usage` to check limits; `/usage-credits` to buy more |
| Usage credits required for 1M context | `/model` to pick the non-`[1m]` variant; `/usage-credits` to enable metered billing |
| Server temporarily limiting requests | Wait briefly; retry |
| Request rejected (429) | `/status` to confirm active credential; check provider rate-limit tier; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| Credit balance too low | Add credits at platform.claude.com/settings/billing; enable auto-reload |

### Authentication errors — key recoveries

| Error | Primary fix |
| :--- | :--- |
| Not logged in | `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| Invalid API key | Check for typos/revoked key; run `env \| grep ANTHROPIC`; run `/status` |
| Organization disabled | Unset `ANTHROPIC_API_KEY`; relaunch `claude`; run `/status` |
| Org disabled API key auth | Unset `ANTHROPIC_API_KEY` or `apiKeyHelper`; run `/login` |
| Org disabled subscription access | Ask admin to enable; use Console API key instead |
| Routines disabled by org policy | Ask admin to enable Routines toggle at claude.ai/admin-settings/claude-code |
| OAuth token revoked/expired | `/login` (run `/logout` first if error returns after re-auth) |
| OAuth scope requirement | `/login` to mint a new token with current scopes |

### Network errors — key recoveries

| Error | Primary fix |
| :--- | :--- |
| Unable to connect to API | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for gateways |
| SSL certificate errors | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| Host not allowed in cloud session | Edit cloud environment: change Network access to Custom; add blocked domain to Allowed domains |

### Request errors — key recoveries

| Error | Primary fix |
| :--- | :--- |
| Prompt is too long | `/compact`; `/context` to inspect usage; disable unused MCP servers; trim CLAUDE.md |
| Compaction: Conversation too long | Press Esc twice to step back several turns, then `/compact`; or `/clear` |
| Request too large (>30 MB) | Press Esc twice; reference large files by path instead of pasting |
| Image was too large | Resize to <8000px (or <2000px when many images in context); take tighter screenshot |
| Unable to resize image | Convert to PNG/JPEG/GIF/WebP; manually resize below stated limit |
| PDF too large / protected | Read page ranges with Read tool; use `pdftotext`; remove PDF password |
| Extra inputs are not permitted | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| Issue with selected model | `/model` (interactive); `--model` flag or `ANTHROPIC_MODEL` (non-interactive); check model config priority order |
| Opus not available on Pro plan | `/model` to select a supported model; `/logout` then `/login` after plan upgrade |
| thinking.type.enabled unsupported | `claude update` (Opus 4.7 needs v2.1.111+; Opus 4.8 needs v2.1.154+); or switch to Opus 4.6 / Sonnet |
| Thinking budget exceeds output limit | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above thinking budget |
| Tool use / thinking block mismatch | `claude update` if on Opus 4.7/4.8 (needs v2.1.156+); then `/rewind` or press Esc twice |
| Usage Policy refusal | Press Esc twice or `/rewind` to step back; rephrase; `/clear` for a fresh conversation |

### Response quality checks (no error shown)

Run these commands in order when responses seem lower quality than expected:

1. `/model` — confirm you are on the model you intend
2. `/effort` — check reasoning level; raise it for hard debugging/design work
3. `/context` — check window fullness; `/compact` or `/clear` if near capacity
4. `/doctor` — flags oversized memory files and subagent definitions

When a response goes wrong, rewinding (Esc twice or `/rewind`) usually works better than correcting in-thread, since the wrong attempt stays in context otherwise.

### Reporting errors

| Situation | Action |
| :--- | :--- |
| Error not listed or fix didn't help | `/feedback` inside Claude Code |
| Local config problems | `/doctor` |
| Active incidents | Check status.claude.com |
| Community issues | github.com/anthropics/claude-code/issues |
| MCP connect/auth failure | See mcp-doc skill |
| Hook script failed | See hooks-doc skill |
| Installation / filesystem errors | See operations-doc skill (troubleshoot-install) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — Complete runtime error messages with meanings and recovery steps, covering server errors, usage limits, authentication, network, request errors, and response quality

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
