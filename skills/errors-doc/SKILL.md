---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors: what each message means, how to recover, and when to report.

## Quick Reference

### Error Message Index

| Message | Category |
|:--------|:---------|
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
| `403` + `x-deny-reason: host_not_allowed` in cloud session | Network |
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
| `Claude Code is unable to respond to this request...Usage Policy` | Request |
| Responses seem lower quality than usual | Quality |

### Automatic Retry Behavior

| Variable | Default | Effect |
|:---------|:--------|:-------|
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Retry attempts before showing error |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

Claude Code retries server errors, 529s, timeouts, temporary 429s, and dropped connections with exponential backoff. When you see an error, retries are already exhausted.

### Server Errors — Quick Fixes

| Error | Fix |
|:------|:----|
| `500 Internal server error` | Check status.claude.com; retry; run `/feedback` if persistent |
| `529 Overloaded` | Check status.claude.com; wait; switch model with `/model` |
| `Request timed out` | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode classifier unavailable | Retry in a few seconds; read-only tasks keep working |
| Auto mode classifier context exceeded | Run `/compact`; approve the action manually in the prompt |

### Usage Limit Errors — Quick Fixes

| Error | Fix |
|:------|:----|
| Session/weekly/Opus limit | Wait for reset time shown; run `/usage`; buy credits with `/usage-credits` |
| Server temporarily limiting | Wait briefly; check status.claude.com |
| `429` rate limit | Check active credential with `/status`; reduce `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing; enable auto-reload |

### Authentication Errors — Quick Fixes

| Error | Fix |
|:------|:----|
| `Not logged in` | Run `/login`; check `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos; run `env \| grep ANTHROPIC`; unset stale key and `/login` |
| Disabled organization | Unset `ANTHROPIC_API_KEY`; relaunch; run `/status` to verify credential |
| Subscription access disabled | Ask admin to enable; use Console API key instead |
| Routines disabled | Ask admin to enable Routines at claude.ai/admin-settings/claude-code |
| OAuth revoked/expired | Run `/logout` then `/login`; check system clock |
| OAuth scope outdated | Run `/login` to mint a new token (no logout needed) |

### Network Errors — Quick Fixes

| Error | Fix |
|:------|:----|
| `Unable to connect to API` | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; see network config docs |
| `403 host_not_allowed` (cloud session) | Change network access to Custom; add blocked domain to allowed list |

### Request Errors — Quick Fixes

| Error | Fix |
|:------|:----|
| `Prompt is too long` | Run `/compact` or `/clear`; disable unused MCP servers; trim CLAUDE.md |
| Compaction failed | Press Esc twice to step back, then retry `/compact`; or `/clear` and `/resume` |
| `Request too large` | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice; resize to ≤8000px longest edge (≤2000px when many images in context) |
| `Unable to resize image` | Convert to PNG/JPEG/GIF/WebP; resize below reported dimension limit |
| PDF too large/protected | Extract text with `pdftotext`; remove password protection |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| Issue with selected model | Run `/model`; use alias (`sonnet`, `opus`) instead of versioned ID; clear stale `ANTHROPIC_MODEL` |
| Opus not on Pro plan | Switch model with `/model`; `/logout` + `/login` if recently upgraded |
| `thinking.type.enabled` unsupported | Run `claude update`; needs v2.1.111+ for Opus 4.7, v2.1.154+ for Opus 4.8 |
| Thinking budget exceeds output | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| Tool use / thinking block mismatch | Update first if on Opus 4.7/4.8; run `/rewind` to step back to a clean checkpoint |
| Usage Policy refusal | Press Esc twice or `/rewind` to step back; rephrase; or `/clear` for a fresh session |

### Response Quality Checklist

When responses seem lower quality without an error:

1. **Model** — run `/model` to confirm you're on the expected model
2. **Effort** — run `/effort` to check reasoning level; raise for hard tasks
3. **Context pressure** — run `/context` to see window usage; run `/compact` if near full
4. **Stale instructions** — run `/doctor` to flag oversized CLAUDE.md or subagent definitions

Use `/rewind` rather than in-thread corrections — the bad turn stays in context otherwise.

### Reporting Errors

| Method | When to use |
|:-------|:------------|
| `/feedback` | Standard path — sends transcript + description to Anthropic; offers GitHub issue |
| `/doctor` | Check local configuration problems |
| status.claude.com | Check for active incidents |
| github.com/anthropics/claude-code/issues | Search existing reports |

For cloud providers (Bedrock, Vertex AI, Foundry), `/feedback` saves a local archive to send to your Anthropic account representative instead of submitting directly.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — Complete runtime error reference: all error messages, categories, automatic retry behavior, recovery steps, and response quality troubleshooting

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
