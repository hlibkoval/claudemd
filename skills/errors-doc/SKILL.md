---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors: what each error message means, how to recover from it, retry behavior, and how to report errors that aren't listed.

## Quick Reference

### Error Index

| Message | Category |
|:--------|:---------|
| `API Error: 500 Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors |
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

### Automatic Retry Behavior

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. The spinner shows `Retrying in Ns · attempt x/y`. When you see an error, all retries have already been exhausted.

| Env Variable | Default | Effect |
|:-------------|:--------|:-------|
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors (5xx / 529)

| Error | Cause | Fix |
|:------|:------|:----|
| `500 Internal server error` | Unexpected API infrastructure failure | Check status.claude.com; retry; run `/feedback` if persistent |
| `529 Overloaded` | API at capacity across all users | Check status page; retry in a few minutes; switch model with `/model` |
| `Request timed out` | No response before connection deadline (default 10 min) | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` |

### Usage Limit Errors

| Error | Cause | Fix |
|:------|:------|:----|
| `You've hit your session/weekly limit` | Subscription rolling allowance exhausted | Wait for reset time shown; run `/usage`; buy credits with `/usage-credits`; upgrade plan |
| `Server is temporarily limiting requests` | Short-lived API throttle (not your quota) | Wait briefly and retry |
| `Request rejected (429)` | Rate limit on API key / provider project | Check `/status`; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console org prepaid credits depleted | Add credits at platform.claude.com/settings/billing; enable auto-reload |

### Authentication Errors

| Error | Fix |
|:------|:----|
| `Not logged in` | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos; run `env \| grep ANTHROPIC`; unset key and use `/login` |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` and remove from shell profile; relaunch |
| `Organization disabled Claude subscription access` | Ask admin to enable; use Console API key instead |
| `Routines disabled by org policy` | Ask admin to enable Routines toggle at claude.ai/admin-settings/claude-code |
| `OAuth token revoked or expired` | Run `/login` (run `/logout` first if error recurs in same session) |
| `OAuth scope requirement user:profile` | Run `/login` to mint a new token with current scopes |

### Network Errors

| Error | Common Causes | Fix |
|:------|:-------------|:----|
| `Unable to connect to API` | No internet; VPN blocking; unconfigured proxy | Run `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall rules |
| `SSL certificate verification failed` | Corporate proxy intercepting TLS | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; never use `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `403` + `x-deny-reason: host_not_allowed` | Cloud/routine session network policy | Edit cloud environment: change Network access to Custom; add blocked domain to Allowed domains |

### Request Errors

| Error | Fix |
|:------|:----|
| `Prompt is too long` | Run `/compact` or `/clear`; run `/context` to see usage; disable unused MCP servers with `/mcp disable` |
| `Error during compaction: Conversation too long` | Press Esc twice to step back several turns, then `/compact`; or `/clear` to start fresh |
| `Request too large (max 30 MB)` | Press Esc twice and remove oversized content; reference large files by path |
| `Image was too large` | Press Esc twice; resize image to under 8000px (or 2000px when many images in context) |
| `Unable to resize image` | Convert image to PNG/JPEG/GIF/WebP; manually resize below the limit shown |
| `PDF too large` / `PDF is password protected` | Use Read tool on page range; extract text with `pdftotext`; remove password |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model` (interactive) or `--model` flag (non-interactive); use aliases like `sonnet` or `opus` |
| `Claude Opus not available with Pro plan` | Run `/model` to switch; run `/logout` then `/login` if you recently upgraded |
| `thinking.type.enabled is not supported` | Run `claude update`; Opus 4.7 needs v2.1.111+, Opus 4.8 needs v2.1.154+ |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the budget |
| `400 due to tool use concurrency issues` | Update to v2.1.156+ first; then run `/rewind` to step back past the corrupted turn |
| Usage Policy refusal | Press Esc twice or `/rewind` to step back; rephrase; or `/clear` for a fresh session |

### Response Quality Issues (No Error Shown)

Check these in order:

1. **Model**: run `/model` — a stale `ANTHROPIC_MODEL` env var or settings entry may have you on the wrong model
2. **Effort**: run `/effort` — raise it for hard debugging or design work
3. **Context pressure**: run `/context` — if near capacity, run `/compact` at a breakpoint or `/clear`
4. **Stale instructions**: run `/doctor` to flag oversized CLAUDE.md or subagent definitions

When a response goes wrong, use `/rewind` (or press Esc twice) to step back and rephrase rather than replying with corrections in-thread.

### Reporting Errors

| Situation | Action |
|:----------|:-------|
| Error not listed here / fix didn't work | Run `/feedback` inside Claude Code |
| `/feedback` unavailable (Bedrock, Vertex, Foundry) | `/feedback` saves a local archive to send to your Anthropic rep |
| Local config problems | Run `/doctor` |
| Active incidents | Check status.claude.com |
| Known issues | Search github.com/anthropics/claude-code/issues |

Related guides: MCP connection errors → `mcp-doc`; Hook failures → `hooks-doc`; Installation errors → operations-doc troubleshoot-install.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — Full error index, per-error explanations and recovery steps, retry configuration, response quality troubleshooting, and how to report errors

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
